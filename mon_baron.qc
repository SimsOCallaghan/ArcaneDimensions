/*==============================================================================
 Large Baron Knight (model/animation from Nehara MOD)

  Interesting QC traits
  * Has a floor damage attack to encourage players to jump
  * Uses the new flame (sprite) projectile system
  * Moves forward and backward to create extra idle animations
  * Changes sword animations if been in combat before and reset
  * Has logic to break attacks and switch based on enemy distance
  * Has special attack and damage if infighting other monsters
  * Attachment system used for casting sprite for magic attack
  * Extra burst/rage mode for flame attack enabled via entity key
  
  * Extra assets are not included in AD anymore, only the QC is left
  * mon_baron.mdl, h_baron.mdl, s_baronmagic.spr, w_baronsword.mdl
 
==============================================================================*/

// (000-010) Taunt - Wave at the Player
$frame wave1 wave2 wave3 wave4 wave5 wave6 wave7 wave8
$frame wave9 wave10 wave11

// (011-021) Taunt - Point at the Player
$frame point1 point2 point3 point4 point5 point6 point7 point8
$frame point9 point10 point11

// (022-040) Crouching Idle (with sword), looking left and right
$frame cstand1 cstand2 cstand3 cstand4 cstand5 cstand6 cstand7 cstand8
$frame cstand9 cstand10 cstand11 cstand12 cstand13 cstand14 cstand15 cstand16
$frame cstand17 cstand18 cstand19

// (041-043) Pain - Throw head backward
$frame painA1 painA2 painA3

// (044-049) Death - Front
$frame death1 death2 death3 death4 death5 death6

// (050-055) Death - Back
$frame deathB1 deathB2 deathB3 deathB4 deathB5 deathB6

// (056-061) Run (very quick)
$frame run1 run2 run3 run4 run5 run6

// (062-066) Take sword out for combat
$frame draw1 draw2 draw3 draw4 draw5

// (067-078) Melee - Attack with right fist to ground
$frame smack1 smack2 smack3 smack4 smack5 smack6 smack7 smack8
$frame smack9 smack10 smack11 smack12

// (079-098) Idle (without sword)
$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8
$frame stand9 stand10 stand11 stand12 stand13 stand14 stand15 stand16
$frame stand17 stand18 stand19 stand20

// (099-102) Pain - thrown backward
$frame painB1 painB2 painB3 painB4

// (103-108) Melee - Strike sword forward
$frame strike1 strike2 strike3 strike4 strike5 strike6

// (109-115) Range - Expell something from sword
$frame magic1 magic2 magic3 magic4 magic5 magic6 magic7

// (116-124) Taunt - Not sure!
$frame taunt1 taunt2 taunt3 taunt4 taunt5 taunt6 taunt7 taunt8 taunt9

// (125-130) Jump
$frame jump1 jump2 jump3 jump4 jump5 jump6

float BARON_STAND = 1;
float BARON_WALK = 5;
float BARON_RUN = 10;
float BARON_MELEE = 12;
float BARON_MAGIC = 14;
float BARON_FLAME = 16;
float BARON_PAIN = 20;
float BARON_DEAD = 21;

//============================================================================
// Attachment management (create, finish and delete)
//============================================================================
void() baron_create_attachment =
{
	// Are the attachments setup yet?
	if (!self.attachment) {
		self.attachment = spawn();
		self.attachment.owner = self;
		self.attachment.classtype = CT_ATTACHMENT;
	}
};

//----------------------------------------------------------------------
void() baron_finish_attachment =
{
	if (self.attachment) {
		setmodel(self.attachment, "");
		self.attachment.state = STATE_OFF;
	}
};

//----------------------------------------------------------------------
void() baron_remove_attachment =
{
	if (self.attachment) {
		self.attachment.think = SUB_Remove;
		self.attachment.nextthink = time + 0.1;
	}
};

//----------------------------------------------------------------------
void(float att_frame) baron_update_attachment =
{
	makevectors(self.angles);
	self.attachment.origin = self.origin + attack_vector(self.meleeoffset);
	setorigin(self.attachment, self.attachment.origin);
	self.attachment.frame = att_frame;
};

//----------------------------------------------------------------------
void() baron_setup_attachment = 
{
	// Check if attachment has been setup yet
	if (!self.attachment) baron_create_attachment();
	self.attachment.state = STATE_ON;
	setmodel(self.attachment, self.weaponglow);
	self.attachment.skin = 0;
	baron_update_attachment(0);
};

//======================================================================
// Stand, walk and run all work with single functions
// Because of animation blends
//----------------------------------------------------------------------
void() baron_standframe =
{
	// Dead barons don't fight anymore
	if (self.health < 1) return;
	if (self.state == BARON_DEAD) return;
	
	// Keep looping
	self.nextthink = time + 0.1;
	self.think = baron_standframe;

	// Beginning of animation block
	if (self.walkframe == 0) monster_idle_sound();
	
	// Check which direction
	if (self.cnt == 0) {
		if (self.idleframe == 0) self.frame = $stand1 + self.walkframe;
		else self.frame = $cstand1 + self.walkframe;
	}
	else if (self.cnt == 1) {
		if (self.idleframe == 0) self.frame = $stand1 + (19-self.walkframe);
		else self.frame = $cstand1 + (18-self.walkframe);
	}
	else if (self.cnt == 2) self.frame = $wave1 + self.walkframe;
	
	// Move frame forward, check for conditions
	self.walkframe = self.walkframe + 1;
	
	// Check for extra idle has finished?
	if (self.cnt == 2 && self.walkframe > 10) {
		// Back to stand animation
		self.walkframe = self.cnt = 0;
	}
	// Finished animation set?
	else if (self.walkframe > 18) {
		self.walkframe = 0;
		// time for an idle animation?
		if (self.idleframe == 0 && random() < MON_IDLE_ANIMATION) 
			self.cnt = 2;
		else {
			// Reverse the stand set
			self.cnt = self.cnt + 1;
			if (self.cnt > 1) self.cnt = 0;
		}
	}
	// Check for combat
	ai_stand();	
};

//----------------------------------------------------------------------
// Walk and run use the same animations, but with different move speeds
// Model has no walk like animation (great shame)
void() baron_runframe =
{
	// Dead barons don't fight anymore
	if (self.health < 1) return;
	if (self.state == BARON_DEAD) return;
	
	// Keep looping
	self.nextthink = time + 0.1;
	self.think = baron_runframe;

	// Beginning of animation block
	if (self.walkframe == 0) monster_idle_sound();
	if (self.walkframe == 1 || self.walkframe == 4) monster_footstep(FALSE);

	// Update frame and move forward
	self.frame = $run1 + self.walkframe;
	self.walkframe = self.walkframe + 1;
	// Finished animation set?
	if (self.walkframe > 5) self.walkframe = 0;
	// Walk/Run like crazy
	if (self.state == BARON_WALK) ai_walk(12);
	else ai_run(24);
};

//----------------------------------------------------------------------
void() baron_meleeframe =
{
	// Dead barons don't fight anymore
	if (self.health < 1) return;
	if (self.state == BARON_DEAD) return;

	// Keep looping
	self.nextthink = time + 0.1;
	self.think = baron_meleeframe;

	// Keep turning towards enemy
	ai_face();
	// Do specific stuff on certain animation frames
	if (self.walkframe == 0) {
		// Warn the player of impact
		sound (self, CHAN_WEAPON, "baron/smash_roar.wav", 1, ATTN_NORM);
	}
	// Sneaky distance check before floor smash (must have enemy as well)
	else if (self.walkframe == 6 && self.enemy) {
		// Check if player outside of slam attack range
		self.enemydist = range_distance(self.enemy, FALSE);
		// Cancel melee attack (fist smash ground)
		if (self.enemydist > MONAI_MELEEBARON) self.attack_sidestep = TRUE;
	}
	// Time for fist meets ground?
	else if (self.walkframe == 7) {
		// Move toward enemy
		ai_chargenoturn(4); 
		// Setup impact sound
		self.meleehitsound = "baron/smash_ground.wav";
		// Pre-defined variables in defscustom.qc
		ai_shockwave(MONAI_BARONIMPACT, MONAI_BARONDAMAGE, MONAI_BARONRADIUS, MONAI_BARONFORWARD, MONAI_BARONUP);
	}
	
	// Enemy has moved too far away for stomp attack to be useful
	// Switch to the jump attack to get closer to the enemy
	// Jump attack is instant so it can blend easily with exit point
	if (self.attack_sidestep) {
		self.walkframe = 0;
		if (random() < 0.7) self.th_jump();
		else self.th_missile();
	}
	else {
		// Update frame and move forward
		self.frame = $smack1 + self.walkframe;
		self.walkframe = self.walkframe + 1;
		// Finished animation set?
		if (self.walkframe > 11) self.th_run();
	}
};

//----------------------------------------------------------------------
void() baron_infightframe =
{
	// Dead barons don't fight anymore
	if (self.health < 1) return;
	if (self.state == BARON_DEAD) return;

	// Keep looping
	self.nextthink = time + 0.1;
	self.think = baron_infightframe;

	// Keep turning towards enemy
	ai_face();
	// Do specific stuff on certain animation frames
	if (self.walkframe == 0 && random() > 0.5) {
		sound (self, CHAN_WEAPON, "baron/smash_roar.wav", 1, ATTN_NORM);
	}
	// sword meets flesh! This is nasty 0-600 damage
	else if (self.walkframe == 5) {
		self.meleehitsound = "baron/smash_ground.wav";
		self.meleecontact = TRUE;
		ai_meleesmash(MONAI_BARONDAMAGE);
		self.meleecontact = FALSE;
	}
	
	// Update frame and move forward
	self.frame = $strike1 + self.walkframe;
	self.walkframe = self.walkframe + 1;
	// Finished animation set?
	if (self.walkframe > 5) self.th_run();
};

//----------------------------------------------------------------------
void() baron_firemagic =
{
	local vector org, dir, avel;
	if (!self.enemy) return;
	if (self.health < 1) return;
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "baron/magic_fire.wav", 1, ATTN_NORM);	

	// Maximum speed, initial speed set in Launch_Missile
	self.attack_speed = SPEED_BARONMISSILE + (skill * SPEED_BARONSKILL);
	
	// check for enemy origin (based on sight test)
	// if cannot see enemy fire at last known location
	ai_trackenemy();

	makevectors (self.angles);
	org = self.origin + attack_vector(self.meleeoffset);
	dir = normalize(self.attack_track - org);
	avel = avel = vecrand(100,200,FALSE);
	
	Launch_Missile (org, dir, avel, CT_PROJ_BARON, self.attack_speed);
};

//----------------------------------------------------------------------
void() baron_magicframe =
{
	// Dead barons don't fight anymore
	if (self.health < 1) return;
	if (self.state == BARON_DEAD) return;

	// Keep looping
	self.nextthink = time + 0.1;
	self.think = baron_magicframe;
	
	ai_face();
	// Do specific stuff on certain animation frames
	if (self.walkframe == 0) {
		// Warn the player of firing magic spikes
		sound (self, CHAN_WEAPON, "baron/magic_attack.wav", 1, ATTN_NORM);
		self.frame = $magic1; baron_setup_attachment();
		self.attack_track = self.enemy.origin;
	}
	else if (self.walkframe >= 1 && self.walkframe <= 3) {
		self.frame = $magic2; baron_update_attachment(self.walkframe);
		particle_implode(self.attachment.origin, 20+random()*20, 100, 100, PARTICLE_BURST_YELLOW);
		ai_trackenemy();
	}
	else if (self.walkframe >= 4 && self.walkframe <= 7) { 
		self.frame = $magic3 + (self.walkframe-4);
		baron_update_attachment(self.walkframe);
		// frame 4=easy, 5=normal, 6=hard, 7=nm
		if ((self.walkframe-4) <= skill) baron_firemagic();
	}
	else if (self.walkframe == 8) {
		self.frame = $magic7;
		SpawnExplosion(EXPLODE_BURST_SMOKE, self.attachment.origin, SOUND_RESIST_ROCKET);
		baron_finish_attachment();
	}
	else self.th_run();

	// Update frame and move forward
	self.walkframe = self.walkframe + 1;
};

//----------------------------------------------------------------------
void(float fire_explode) baron_fireflame =
{
	local vector org, eorg, torg, dir, ang;
	local float expl_type, targetang;

	if (!self.enemy) return;
	if (self.health < 1) return;

	// Whooshing attack sound
	sound (self, CHAN_WEAPON, "baron/flame_fire.wav", 1, ATTN_NORM);
	
	// Facing angle
	ai_face();
	makevectors (self.angles);	
	org = self.origin + attack_vector(self.attack_offset);
	
	// Setup explosion origin (infront)
	eorg = org + attack_vector('16 0 16');
	// Explosion infront and above impact point
	if (fire_explode == TRUE) {
		// Wall of flame, left > right (maximum arc)
		self.proj_attarc = 1 + skill;
		// Within range? Easy = 3(-1/1), Normal = 5(-2/2), Hard/NM = 7(-3/3)
		if (self.proj_attarc > 3) self.proj_attarc = 3;
		// Invert maximum arc to create beginning/current
		self.proj_attarc = -self.proj_attarc;
		// Randomize explosion type
		if (random() < 0.5) expl_type = EXPLODE_MED;
		else expl_type = EXPLODE_BIG;
		SpawnExplosion(expl_type, eorg, "baron/flame_explode.wav");
	}
	// Small particle
	else {
		if (random() > 0.5) SpawnProjectileSmoke(eorg, 200, 50, 250);
	}

	// Start with facing angle
	makevectors (self.angles);	
	// Work out offset (24 unit) from left to right (- to +)
	torg = self.enemy.origin + (v_right * (self.proj_attarc*24));
	targetang = SUB_Elevation(ELEV_DEFAULT, self.origin, torg, SPEED_FLAME);
	// Work out angle
	ang = vectoangles(torg - org);
	ang_x = -targetang;	// Negative = upwards angle 
	makevectors (ang);
	// fire flames forward with slight Z wobble
	dir = (v_forward + (v_up * (random()*0.2)) ) * SPEED_FLAME;

	// Fire that flame!
	// target, origin, v_forward, colour, size, lifetime, speed
	Launch_Flame (self, org, dir, FLAME_RED, -1, -1, SPEED_FLAME);
	// Next arc position
	self.proj_attarc = self.proj_attarc + 1;
};

//----------------------------------------------------------------------
void() baron_flameframe =
{
	// Dead barons don't fight anymore
	if (self.health < 1) return;
	if (self.state == BARON_DEAD) return;

	// Keep looping
	self.nextthink = time + 0.1;
	self.think = baron_flameframe;
	// Do specific stuff on certain animation frames
	// Check for last frame (exit) first!
	if (self.walkframe < 0) {
		self.frame = $strike1;
		// Slow down flame attacks with attack timer/blocker
		self.attack_timer = time + 1 + random();
		// Back to regular movement
		self.attack_state = AS_STRAIGHT;
		self.think = self.th_run;
	}
	else if (self.walkframe == 0) { self.frame = $strike1; ai_face();
		sound (self, CHAN_WEAPON, "baron/flame_attack.wav", 1, ATTN_NORM);}
	else if (self.walkframe == 1) { self.frame = $strike2; ai_face();}
	// MAIN ATTACK LOOP ---------------------------------------------------
	else if (self.walkframe == 2) { self.frame = $strike3; ai_face();
		// Sprite Count = Base (X) * (Skill * Y) Maximum = Z
		self.attack_count = SpriteCount_Flame(self.proj_attqty);
	}
	else if (self.walkframe == 3) { self.frame = $strike4; ai_face();}
	else if (self.walkframe == 4) { self.frame = $strike5; baron_fireflame(TRUE); }
	else if (self.walkframe >= 5) { 
		// Keep counting down flame attacks (3/5/7 sets)
		self.attack_count = self.attack_count - 1;
		if (self.attack_count > 0) {
			self.frame = $strike6; 
			baron_fireflame(FALSE);
			self.nextthink = time + 0.05;
		}
		else { 
			self.frame = $magic1;
			self.walkframe = -10;
			// Extra flame attacks?
			if (self.attack_rage == TRUE) {
				// Sprite Count = Base (X) * (Skill * Y) Maximum = Z
				self.attack_count = SpriteCount_Flame(self.proj_attqty);
				// Any sprite space left for flame burst attack?
				if (HazardProjectile_CheckLimit(self, self.attack_count)) {
					// Can see player?
					if (visxray(self.enemy, self.attack_offset, '0 0 0', FALSE)) {
						// Back around animation loop
						self.frame = $strike2; 
						self.walkframe = 1;
					}
				}
			}
		}
	}

	// Update frame and move forward
	self.walkframe = self.walkframe + 1;
};

//======================================================================
// Blend animations for sword on back or in hand
//----------------------------------------------------------------------
void() baron_sheathsword =
{
	// Dead barons don't fight anymore
	if (self.health < 1) return;
	if (self.state == BARON_DEAD) return;
	
	// Sword going back
	self.weaponstate = FALSE;
	// Keep looping
	self.nextthink = time + 0.1;
	self.think = baron_sheathsword;
	// Put sword away sound
	if (self.walkframe == 2) 
		sound (self, CHAN_WEAPON, "baron/sword_sheath.wav", 1, ATTN_NORM);
	// Step backward through sword draw animation
	self.frame = $draw1 + (4-self.walkframe);
	self.walkframe = self.walkframe + 1;
	// Check if finished animation
	if (self.walkframe > 4) {
		self.walkframe = 0;
		baron_standframe();
	}
};

//----------------------------------------------------------------------
void() baron_drawsword =
{
	// Dead barons don't fight anymore
	if (self.health < 1) return;
	if (self.state == BARON_DEAD) return;

	// Sword coming out from back
	self.weaponstate = TRUE;
	// Keep looping
	self.nextthink = time + 0.1;
	self.think = baron_drawsword;
	// Draw sword from sheath
	if (self.walkframe == 2) 
		sound (self, CHAN_WEAPON, "baron/sword_draw.wav", 1, ATTN_NORM);
	// Step through sword draw animation
	self.frame = $draw1 + self.walkframe;
	self.walkframe = self.walkframe + 1;
	// Check if finished animation
	if (self.walkframe > 4) {
		self.walkframe = 0;
		// Where to go next?
		if (self.state == BARON_MELEE) {
			// Special setup for monster infighting
			if (self.enemy.flags & FL_MONSTER) baron_infightframe();
			else baron_meleeframe();
		}
		else if (self.state == BARON_MAGIC) baron_magicframe();
		else if (self.state == BARON_FLAME) baron_flameframe();
		else baron_runframe();
	}
};

//======================================================================
// Entry point for Stand, Walk and Run monster states
// All have to cope with sword out/on back blend animations
//----------------------------------------------------------------------
void() baron_stand = { 
	// Reset animation set
	self.walkframe = 0;
	self.state = BARON_STAND;
	// Has been in combat and weapon drawn?
	if (!self.idlebusy && self.weaponstate) baron_sheathsword();
	else {
		// Is the sword in hands?
		if (self.weaponstate) self.idleframe = TRUE;
		baron_standframe();
	}
};

//----------------------------------------------------------------------
void() baron_walk =  { 
	// Reset animation set
	self.walkframe = 0;
	// Is the sword out in hands?
	if (!self.weaponstate && self.state == BARON_STAND) {
		self.state = BARON_WALK; 
		// Draw sword first
		baron_drawsword();
	}
	else {
		// Slower run animation
		self.state = BARON_WALK; 
		baron_runframe();
	}
};

//----------------------------------------------------------------------
void() baron_run = {
	// Reset animation set
	self.walkframe = 0;
	// Don't start combat with a jump!
	if (!self.idlebusy) self.jump_flag = time + 2;
	// Been in combat, crouch stand animation enabled
	self.idlebusy = TRUE;
	// Is the sword out in hands?
	if (!self.weaponstate && self.state == BARON_STAND) {
		self.state = BARON_RUN; 
		// Draw sword first
		baron_drawsword();
	}
	else {
		self.state = BARON_RUN; 
		baron_runframe();
	}
};

//----------------------------------------------------------------------
void() baron_melee = {
	// Reset animation set
	self.walkframe = 0;
	// Reset jump attack decision branch
	self.attack_sidestep = FALSE;
	// Been in combat, crouch stand animation enabled
	self.idlebusy = TRUE;
	self.state = BARON_MELEE; 
	self.pain_finished = time + 1;
	
	// Is the sword out in hands?
	if (!self.weaponstate) baron_drawsword();
	else {
		// Special setup for monster infighting
		if (self.enemy.flags & FL_MONSTER) baron_infightframe();
		else baron_meleeframe();
	}
};

//----------------------------------------------------------------------
void() baron_range = {
	// Reset animation set
	self.walkframe = 0;
	// Been in combat, crouch stand animation enabled
	self.idlebusy = TRUE;
	
	// Easy/Normal = get more spikes Hard/NM = get more flames
	// Easy=0.6, Normal=0.5, Hard=0.4, NM=0.3
	self.attack_chance = 0.6 - (skill * 0.1);
	if (random() > self.attack_chance) self.state = BARON_FLAME;
	else self.state = BARON_MAGIC;
	// Flame attack does not go up stairs or ledges very well
	if (self.enemy.origin_z > (self.origin_z+MONAI_STEPLARGE)) 
		self.state = BARON_MAGIC;
	
	// Forced pause between FLAME attacks
	if (self.attack_timer < time) {
		// Sprite Count = Base (X) * (Skill * Y) Maximum = Z
		self.attack_count = SpriteCount_Flame(self.proj_attqty);
		// Any sprite space left for hazard projectiles? (min = 1 wave)
		if ( !(HazardProjectile_CheckLimit(self, self.attack_count)) )
			self.state = BARON_MAGIC;
	}
	// Do magic attack instead
	else self.state = BARON_MAGIC;
	
	// No pain interruption
	self.pain_finished = time + 1;
	// Is the sword out in hands?
	if (!self.weaponstate) baron_drawsword();
	else {
		// Sword ready, lets attack!
		if (self.state == BARON_FLAME) baron_flameframe();
		else baron_magicframe();
	}
};

//======================================================================
// Lunge forward (leaving ground) and do heavy damage on touch
//----------------------------------------------------------------------
void() baron_JumpTouch =
{
	local float ldmg;
	
	if (self.health < 1) return;
	ai_jumpbreakable(30);			// Damage any breakables
	self.touch = SUB_Null;			// No more touching
	self.think = self.th_jumpexit;	// Exit frame
	self.jumptouch = other;			// Keep track of touch target

	if ( CanDamage(other, self) ) {
		if ( vlen(self.velocity) > 300 ) {
		  ldmg = 20 + 10*random();
			T_Damage (other, self, self, ldmg, DAMARMOR);	
			spawn_touchblood (self, self.enemy, ldmg*3);
		}
	}

	// Is the Baron floating in the air?
	if (!checkbottom(self)) {
		// Is the Baron standing on something?		
		if (self.flags & FL_ONGROUND) {	
			// Do an extra jump if got the count
			if (self.count < 2)  self.think = self.th_jump;
		}
	}

	// Next timer
	self.nextthink = time + 0.1;
};

//----------------------------------------------------------------------
void() baron_lunge1 = [ $jump1, baron_lunge2 ] {ai_face();
	self.jump_flag = time + MONAI_JUMPBARONTIME;
	sound (self, CHAN_WEAPON, "baron/leap1.wav", 1, ATTN_NORM);
	self.jumptouch = world;		// Reset last object touched
	self.count = 0;				// Number of times jumped
	self.touch = baron_JumpTouch;
	makevectors (self.angles);
	self.velocity = (v_forward*self.jumpdist_x) + ('0 0 1'*self.jumpdist_z);
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.oldorigin = self.origin;
};

void() baron_lunge2 = [ $jump2, baron_lunge3 ] {};
void() baron_lunge3 = [ $jump3, baron_lunge4 ] {
	// Double check monster is still falling?
	if (CheckZeroVector(self.velocity) || self.oldorigin == self.origin) {
		self.ideal_yaw = random() * 360; 	//random jump angle
		self.think = baron_lunge4;			// Keep jumping
	}
	self.oldorigin = self.origin;
};

//----------------------------------------------------------------------
// Landed with a thud
void()	baron_lunge4 = [ $jump4, baron_lunge5 ] {monster_footstep(FALSE);};
void()	baron_lunge5 = [ $jump5, baron_lunge6 ] {};
void()	baron_lunge6 = [ $jump6, baron_run ] {
	// Make sure attack state is reset (can then decide melee or range)
	self.attack_state = AS_STRAIGHT; ai_resetangles(); ai_face(); };

//======================================================================
// Pain, Death and Taxes!
//----------------------------------------------------------------------
void()	baron_painA1 =[ $painA1, baron_painA2 ] {};
void()	baron_painA2 =[ $painA2, baron_painA3 ] {};
void()	baron_painA3 =[ $painA3, baron_painA4 ] {};
void()	baron_painA4 =[ $painA2, baron_painA5 ] {};
void()	baron_painA5 =[ $painA1, baron_run ] {};

//----------------------------------------------------------------------
void()	baron_painB1 =[ $painB4, baron_painB2 ] {};
void()	baron_painB2 =[ $painB3, baron_painB3 ] {};
void()	baron_painB3 =[ $painB2, baron_painB4 ] {};
void()	baron_painB4 =[ $painB1, baron_painB5 ] {};
void()	baron_painB5 =[ $painB2, baron_painB6 ] {};
void()	baron_painB6 =[ $painB3, baron_painB7 ] {};
void()	baron_painB7 =[ $painB4, baron_run ] {};

//----------------------------------------------------------------------
void(entity inflictor, entity attacker, float damage) baron_pain =
{
	// Check all pain conditions and set up what to do next
	monster_pain_check(attacker, damage);

	// Any pain animation/sound required?
	if (self.pain_check > 0) {
		sound (self, CHAN_VOICE, self.pain_sound, 1, ATTN_NORM);
		if (self.pain_check == 1) {
			// Randomly pick which pain animation to play
			if (random() < 0.85) baron_painA1 ();	// Super quick
			else {
				baron_painB1 ();				// Still very quick
				self.pain_finished = time + 1;	// long animation
			}
		}
	}
};

//======================================================================
void() baron_die1 =[ $death1, baron_die2 ] {};
void() baron_die2 =[ $death2, baron_die3 ] {monster_check_gib();};
void() baron_die3 =[ $death3, baron_die4 ] {monster_check_gib();
	self.solid = SOLID_NOT;self.nextthink = time + 0.15;};
void() baron_die4 =[ $death4, baron_die5 ] {self.nextthink = time + 0.15;};
void() baron_die5 =[ $death5, baron_die6 ] {monster_death_postcheck();
	sound (self, CHAN_WEAPON, GIB_SOUND_METALA, 1, ATTN_NORM);};
void() baron_die6 =[ $death6, baron_die6 ] {monster_deadbody_check();};

//----------------------------------------------------------------------
void() baron_dieB1 =[ $deathB1, baron_dieB2 ] {};
void() baron_dieB2 =[ $deathB2, baron_dieB3 ] {monster_check_gib();};
void() baron_dieB3 =[ $deathB3, baron_dieB4 ] {monster_check_gib();
	self.solid = SOLID_NOT;self.nextthink = time + 0.15;};
void() baron_dieB4 =[ $deathB4, baron_dieB5 ] {self.nextthink = time + 0.15;};
void() baron_dieB5 =[ $deathB5, baron_dieB6 ] {monster_death_postcheck();
	sound (self, CHAN_WEAPON, GIB_SOUND_METALA, 1, ATTN_NORM);};
void() baron_dieB6 =[ $deathB6, baron_dieB6 ] {monster_deadbody_check();};

//----------------------------------------------------------------------
void() baron_die =
{
	// Pre-check routine to tidy up extra entities
	monster_death_precheck();
	self.state = BARON_DEAD;
	baron_remove_attachment();
	
	// regular death
	if (!self.gibbed) {
		sound (self, CHAN_VOICE, self.death_sound, 1, ATTN_NORM);
		if (random() > 0.5) baron_die1 ();
		else baron_dieB1 ();
	}
};

//======================================================================
/*QUAKED monster_baron (1 0 0) (-16 -16 -24) (16 16 40) Ambush
======================================================================*/
// Not used anymore, use monster_justice instead
// QC left for reference reasons only
void() monster_deadbaron =
{
	// Check all spawn exceptions (monsters.qc)
	if (monster_checkspawn() == TRUE) return;
	
	self.mdl = "progs/mon_baron.mdl";			// Baron Knight
	self.headmdl = "progs/h_baron.mdl";			// Bloody head
	self.gib1mdl = "progs/w_baronsword.mdl";	// Unique sword

	precache_model (self.mdl);
	precache_model (self.headmdl);
	precache_model (self.gib1mdl);
	self.gib1sound = GIB_IMPACT_METALA;

	self.idle_sound = "baron/idle1.wav";
	precache_sound (self.idle_sound);
	
	// Smash the floor with fist
	precache_model (MODEL_PROJ_RINGSHOCK);
	precache_sound ("baron/smash_roar.wav");
	precache_sound ("baron/smash_ground.wav");
	
	// Fire attack
	PreCache_Flame();
	precache_sound ("baron/flame_attack.wav");
	precache_sound ("baron/flame_fire.wav");
	precache_sound ("baron/flame_explode.wav");
	
	// Spike attack
	precache_model (MODEL_PROJ_BARON1);	// Copy of proj_serg.mdl
	self.weaponglow = "progs/s_baronmagic.spr";
	precache_model (self.weaponglow);
	precache_sound ("baron/magic_attack.wav");
	precache_sound ("baron/magic_fire.wav");
	precache_sound ("baron/magic_hit.wav");
	
	// Crazy leapin! (re-used from player)
	precache_sound ("baron/leap1.wav");
	
	// Strange roar of monks!
	self.sight_sound = "baron/sight1.wav";
	precache_sound (self.sight_sound);

	self.pain_sound = "baron/pain1.wav";
	self.death_sound = "baron/death1.wav";
	precache_sound (self.pain_sound);
	precache_sound (self.death_sound);

	// New sword sweep/slash sounds
	precache_sound ("baron/sword_draw.wav");
	precache_sound ("baron/sword_sheath.wav");
	
	self.solid = SOLID_NOT;				// No interaction with world
	self.movetype = MOVETYPE_NONE;		// Static item, no movement
	if (self.bboxtype < 1) self.bboxtype = BBOX_TALL;
	if (self.health < 1) self.health = 400;

	self.gibhealth = -50;
	self.gibbed = FALSE;				// Starts complete
	self.pain_flinch = 400;				// Really low chance of pain
	self.pain_longanim = FALSE;			// cannot be chopped with shadow axe
	self.pain_timeout = 2;				// High pain level
	if (self.infightextra <= 0) self.infightextra = 4; // High infighting damage
	self.steptype = FS_TYPEHEAVY;		// Heavy feet
	self.poisonous = FALSE;				// No Poison version
	self.no_liquiddmg = TRUE;			// Immune to slime/lava
	self.meleecontact = FALSE;			// Smash contact
	self.meleerange = MONAI_BARONSMASHRANGE;	// Fist range
	self.weaponstate = FALSE;			// Sword on back
	self.state = BARON_STAND;			// Default state
	self.idleframe = 0;					// Default stand state
	if (!self.idlebusy) self.idlebusy = 0;	// Switch to crouch stand
	self.meleeoffset = '24 0 16';		// Spike explosion
	self.meleerange = MONAI_CLOSEBARON;	// Really close melee
	self.attack_offset = '24 0 -16';	// Fireball explosion
	self.deathstring = " was toasted by The Baron\n";
	// Setup default timer/counters
	self.attack_count = self.attack_timer = 0;
	self.part_exitpuff = self.part_exitsound = TRUE;

	// Setup default burst mode (=-1 to disable, def=FALSE)
	if (self.attack_rage <= 0) self.attack_rage = FALSE;
	else if (self.attack_rage > 0) self.attack_rage = TRUE;
	// Default is half flame limit for burst mode
	if (self.attack_rage == TRUE && self.proj_limit == 0)
		self.proj_limit = PROJ_MAXLIMIT * 0.5;
	
	// Setup default Proj Count = Base (X) * (Skill * Y) Maximum = Z
	if (CheckZeroVector(self.proj_attqty)) self.proj_attqty = '3 2 7';
	
	// Default jump forward/up distance
	if (CheckZeroVector(self.jumpdist)) self.jumpdist = '500 0 250';
	if (self.jumprange_x <= 0) self.jumprange_x = MONAI_JUMPBARONNEAR;
	if (self.jumprange_y <= self.jumprange_x) self.jumprange_y = MONAI_JUMPBARONFAR;

	// Always reset Ammo Resistance to be consistent
	self.resist_shells = self.resist_nails = self.resist_rockets = 0;
	self.resist_cells = 0.75;
	self.reflectlightning = TRUE;	// Reflect lightning strikes
	self.reflectplasma = TRUE;		// Reflect plasma projectiles

	self.th_checkattack = BaronCheckAttack;
	self.th_stand = baron_stand;
	self.th_walk = baron_walk;
	self.th_run = baron_run;
	self.th_melee = baron_melee;
	self.th_missile = baron_range;
	self.th_jump = baron_lunge1;
	self.th_jumpexit = baron_lunge4;
	self.th_pain = baron_pain;
	self.th_die = baron_die;

	self.classtype = CT_MONBARON;
	self.classgroup = CG_DCAPTAIN;
	self.classmove = MON_MOVEWALK;

	// Start monster (default)
	monster_start();
};
