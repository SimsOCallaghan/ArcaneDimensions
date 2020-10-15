/*==============================================================================
 Small floating robot which drops mines (model/animation by Benoit Stordeur)
 * QC was created for Bal's Hypnagogia project

  Interesting QC traits
  * All enemy states go through one function so drone sound is consistent
  * Can start with a blue shield and waits for trigger event (like seeker)
  * The laser version is designed for tight ceiling space area's
  * The sweeper will not pursue enemies, instead it prefers to wait
  * If the sweeper loses sight of the enemy for more than 20s, reset location
  * The mine attack is using the new rocket seeking system
  * The mine stops steering towards the enemy if too close
  * Extra checks are done for space below before firing mines

  Assets required to get this monster working in AD
    (model's in 'progs' and wav's in 'sound' sub directories)
  * mon_sweeper.mdl (complete model)
  * proj_sweeper1.mdl (Small 8x8x8 mine)
  * proj_sweeper2.mdl (hell knight like spike)
  * gib_sweeper1.mdl (middle piece with light)
  * gib_sweeper2.mdl (top rotating part with spikes)
  * gib_sweeper3.mdl (bottom rotating part)
  * gib_sweeper4.mdl (spike from top)

==============================================================================*/

// (000) 
$frame blank1

// (001-010) Stand by mode (spinning bottom part)
$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8
$frame stand9 stand10

// (011-020) Opening up top spikes
$frame wakeup1 wakeup2 wakeup3 wakeup4 wakeup5 wakeup6 wakeup7 wakeup8
$frame wakeup9 wakeup10

// (021-030) Walking animation + top spikes
$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8
$frame walk9 walk10

// (031-040) Open the middle part
$frame open1 open2 open3 open4 open5 open6 open7 open8
$frame open9 open10

// (041-050) Run animation
$frame run1 run2 run3 run4 run5 run6 run7 run8
$frame run9 run10

// (051-060) Spin Attack
$frame spin1 spin2 spin3 spin4 spin5 spin6 spin7 spin8
$frame spin9 spin10

// (061-070) Mine Attack
$frame mine1 mine2 mine3 mine4 mine5 mine6 mine7 mine8
$frame mine9 mine10

// (071-080) Idle 1 - spin + dance top spikes
$frame idleA1 idleA2 idleA3 idleA4 idleA5 idleA6 idleA7 idleA8
$frame idleA9 idleA10

// (081-090) Idle 2 - spin + tilt around body
$frame idleB1 idleB2 idleB3 idleB4 idleB5 idleB6 idleB7 idleB8
$frame idleB9 idleB10

// (091-100) Laser Attack
$frame laser1 laser2 laser3 laser4 laser5 laser6 laser7 laser8
$frame laser9 laser10

float SW_STAND = 0;			// Bobbing up/down
float SW_STAND2WALK = 1;	// Blending - raise up head arms
float SW_STAND2RUN = 2;		// Blending - Open middle
float SW_WALK = 5;			// Head tentacles up
float SW_WALK2STAND = 6;	// Blending - lower head arms
float SW_WALK2RUN = 7;		// Blending - Opein middle
float SW_RUN = 10;			// Middle section opened
float SW_RUN2STAND = 11;	// Blending - Close middle
float SW_RUN2WALK = 12;		// Blending - Close middle
float SW_ATTACKSPIN = 15;	// Spin attack from top
float SW_ATTACKMINE = 16;	// Mine attack from bottom
float SW_ATTACKBLOB = 20;	// Spin attack from bottom
float SW_ATTACKLASER = 21;	// Laser attack from middle
float SW_PAIN = 30;			// Quick Spin around
float SW_DEATH = 31;		// Do nothing

// Size of each animation block
float SW_ANIMBLEND = 9;
float SW_ANIMBLOCK = 10;

void() sweeper_fire_mine;
void(float offset) sweeper_fire_laser;
void(float offset) sweeper_fire_hazard;

//============================================================================
// Attachment management (create, finish and delete)
//============================================================================
void() sweeper_create_attachment =
{
	// Are the attachments setup yet?
	if (!self.attachment) {
		self.attachment = spawn();
		self.attachment.owner = self;
		self.attachment.classtype = CT_ATTACHMENT;
	}
};

//----------------------------------------------------------------------
void() sweeper_finish_attachment =
{
	if (self.attachment) {
		setmodel(self.attachment, "");
		self.attachment.state = STATE_OFF;
	}
};

//----------------------------------------------------------------------
void() sweeper_remove_attachment =
{
	if (self.attachment) {
		self.attachment.think = SUB_Remove;
		self.attachment.nextthink = time + 0.1;
	}
}

//----------------------------------------------------------------------
void() sweeper_setup_attachment = 
{
	// Check if attachment has been setup yet
	if (!self.attachment) sweeper_create_attachment();
	self.attachment.state = STATE_ON;
	setmodel(self.attachment, self.weaponglow);
	self.attachment.skin = 0;
}

//----------------------------------------------------------------------
void() sweeper_update_attachment =
{
	setorigin(self.attachment, self.origin);
	self.attachment.angles = self.angles;
	self.attachment.frame = self.frame;
	self.attachment.alpha = 0.3 + random()*0.7;
};

//======================================================================
void() sweeper_frame = 
{
	// If sooty is dead, no more updates
	if (self.health < 1) return;
	if (self.state == SW_DEATH) return;

	// Update the drone sound
	if (self.t_width < time) {
		self.t_width = time + 0.9;
		// Play on auto channel so it overlaps with existing sound
		sound (self, CHAN_AUTO, "sweeper/idledrone1.wav", 0.5, ATTN_WEAPON);
	}

	// Setup function loop
	self.nextthink = time + 0.1;
	self.think = sweeper_frame;

	// Beginning of annimation block (out of combat only)
	if (self.walkframe == 0 && !self.enemy) monster_idle_sound();
	
	//----------------------------------------------------------------------
	if (self.state == SW_WALK2STAND) {
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_STEP;
		self.walkframe = self.walkframe + 2;
		if (self.walkframe >= SW_ANIMBLEND) {
			self.idlebusy = time + 0.5;
			self.walkframe = 0;
			self.velocity = '0 0 0';
			self.state = SW_STAND;
		}
		else self.frame = $wakeup1 + (SW_ANIMBLEND - self.walkframe);
	}
	else if (self.state == SW_RUN2STAND) {
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_STEP;
		self.walkframe = self.walkframe + 2;
		if (self.walkframe >= SW_ANIMBLEND) {
			self.idlebusy = time + 0.5;
			self.walkframe = 0;
			self.velocity = '0 0 0';
			self.state = SW_STAND;
		}
		else self.frame = $open1 + (SW_ANIMBLEND - self.walkframe);
	}
	if (self.state == SW_STAND) {
		// Standing idle has gentle bobbing up and down
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_FLY;
		
		// Check for idle animations (shield = exception)
		if (self.walkframe == 0 && !(self.spawnflags & MON_SWEEPER_SHIELD)) {
			// Reset standing frame
			self.idleframe = $stand1;
			// Check for idle animations
			if (random() < MON_IDLE_ANIMATION && self.idlebusy < time) {
				self.idlebusy = time + 0.5;
				if (self.lefty) self.idleframe = $idleA1; 
				else self.idleframe = $idleB1;
				self.lefty = 1 - self.lefty;
			}
		}
		// Update frame
		self.frame = self.idleframe + self.walkframe;
		self.walkframe = self.walkframe + 1;
		if (self.walkframe >= SW_ANIMBLOCK) self.walkframe = 0;

		// Check velocity movement before bobbing up/down
		if (self.velocity_x == 0 && self.velocity_y == 0) {
			if (self.attack_timer < time) {
				self.attack_timer = time + 1;
				if (self.lip < 1) self.lip = 1;
				else self.lip = -1;
				self.velocity_z = 4 * self.lip;
			}
		}
		else {
			// Slowdown the velocity (movement = no friction)
			self.velocity = self.velocity * self.velocityfriction;
			if (self.velocity_x > -5 && self.velocity_x < 5) self.velocity_x = 0;
			if (self.velocity_y > -5 && self.velocity_y < 5) self.velocity_y = 0;
			if (self.velocity_z > -5 && self.velocity_z < 5) self.velocity_z = 0;
			// Don't go into attack straight away when velocity is active
			self.attack_finished = time + 0.5;
		}
		// Update shield or check for enemies
		if (self.spawnflags & MON_SWEEPER_SHIELD) sweeper_update_attachment();
		else ai_stand();	
	}
	//----------------------------------------------------------------------
	if (self.state == SW_STAND2WALK) {
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_STEP;
		self.walkframe = self.walkframe + 2;
		if (self.walkframe >= SW_ANIMBLEND) {
			self.walkframe = 0;
			self.state = SW_WALK;
		}
		else self.frame = $wakeup1 + self.walkframe;
	}
	else if (self.state == SW_RUN2WALK) {
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_STEP;
		self.walkframe = self.walkframe + 2;
		if (self.walkframe >= SW_ANIMBLEND) {
			self.walkframe = 0;
			self.state = SW_WALK;
		}
		else self.frame = $open1 + (SW_ANIMBLEND - self.walkframe);
	}
	if (self.state == SW_WALK) {
		// Movement is steps, not velocity
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_STEP;
		self.velocity = '0 0 0';
		self.frame = $walk1 + self.walkframe;
		self.walkframe = self.walkframe + 1;
		if (self.walkframe >= SW_ANIMBLOCK) self.walkframe = 0;
		ai_walk(6);
	}
	//----------------------------------------------------------------------
	if (self.state == SW_STAND2RUN) {
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_STEP;
		self.walkframe = self.walkframe + 2;
		if (self.walkframe >= SW_ANIMBLEND) {
			self.walkframe = 0;
			self.state = SW_RUN;
		}
		else self.frame = $open1 + self.walkframe;
	}
	else if (self.state == SW_WALK2RUN) {
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_STEP;
		self.walkframe = self.walkframe + 2;
		if (self.walkframe >= SW_ANIMBLEND) {
			self.walkframe = 0;
			self.state = SW_RUN;
		}
		else self.frame = $open1 + self.walkframe;
	}
	if (self.state == SW_RUN) {
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_STEP;
		self.velocity = '0 0 0';
		self.frame = $run1 + self.walkframe;
		self.walkframe = self.walkframe + 1;
		if (self.walkframe >= SW_ANIMBLOCK) self.walkframe = 0;
		enemy_vis = visible(SUB_entEnemyTarget());
		if (enemy_vis) ai_run(12);
		else ai_run(0);
		if (self.movespeed != 0) ai_face();
	}

	//----------------------------------------------------------------------
	if (self.state == SW_PAIN) {
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_STEP;
		// Speed up spin animation (5 frames)
		self.walkframe = self.walkframe + 2;
		// End of pain animation?
		if (self.walkframe >= SW_ANIMBLOCK) {
			self.angles_x = self.angles_z = 0;	// reset pitch/roll
			self.walkframe = 0;					// reset animation
			self.state = SW_RUN;				// Back to running
		}
		else {
			// Keep moving in the pitch/roll direction
			self.angles = self.angles + (self.pos1 * 0.25);
			// Update spin animation
			self.frame = $spin1 + self.walkframe;
		}
	}
	else if (self.state == SW_ATTACKSPIN) {
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_STEP;
		self.frame = $spin1 + self.walkframe;
		if (self.walkframe < 2) ai_trackenemy();
		if (self.walkframe > 0 && self.walkframe < 8) {
			sweeper_fire_hazard(self.walkframe - 4);
		}
		self.walkframe = self.walkframe + 1;
		if (self.walkframe >= SW_ANIMBLOCK) {
			self.walkframe = 0;					// reset animation
			self.state = SW_RUN;				// Back to running
		}
	}
	else if (self.state == SW_ATTACKMINE) {
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_STEP;
		self.frame = $mine1 + self.walkframe;
		if (self.walkframe == 0) self.attack_track = self.enemy.origin;
		else if (self.walkframe > 0 && self.walkframe < 3) ai_trackenemy();
		if (self.walkframe == 3) sweeper_fire_mine();
		
		self.walkframe = self.walkframe + 1;
		if (self.walkframe >= SW_ANIMBLOCK) {
			self.walkframe = 0;					// reset animation
			self.state = SW_RUN;				// Back to running
		}
	}
	else if (self.state == SW_ATTACKLASER) {
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_STEP;
		self.frame = $laser1 + self.walkframe;
		ai_trackenemy();
		// Laser projectiles : Skill EASY = 1, NORMAL = 2, HARD/NM = 3
		if (self.walkframe == 3) sweeper_fire_laser(0);
		else if (self.walkframe == 5 && skill > SKILL_EASY) sweeper_fire_laser(-2);
		else if (self.walkframe == 7 && skill > SKILL_NORMAL) sweeper_fire_laser(2);
		self.walkframe = self.walkframe + 1;
		if (self.walkframe >= SW_ANIMBLOCK) {
			self.walkframe = 0;					// reset animation
			self.state = SW_RUN;				// Back to running
		}
	}
};

//======================================================================
// All monster states (stand,walk etc) have to go through one function
// because the robot has a constant sound update at specific intervals
//
void() sweeper_stand = { 
	self.walkframe = 0;
	self.idlebusy = time + 0.5;
	self.idleframe = $stand1;
	if (self.state == SW_WALK) self.state = SW_WALK2STAND;
	else if (self.state == SW_RUN) self.state = SW_RUN2STAND;
	else self.state = SW_STAND;
	if (self.spawnflags & MON_SEEK_SHIELD) sweeper_setup_attachment(); 
	sweeper_frame();
};

void() sweeper_walk = {
	self.walkframe = 0;
	if (self.state == SW_STAND) self.state = SW_STAND2WALK;
	else if (self.state == SW_RUN) self.state = SW_RUN2WALK;
	else self.state = SW_WALK;
	sweeper_frame();
};

void() sweeper_run = {
	self.walkframe = 0;
	// First time in combat?
	if (self.attack_chance) {
		self.attack_chance = FALSE;
		// Do no attack steaight away, slight pause
		self.attack_finished = time + 0.3;
		self.weaponstate = TRUE;	// Default = mines/lasers
	}
	if (self.state == SW_STAND) self.state = SW_STAND2RUN;
	else if (self.state == SW_WALK) self.state = SW_WALK2RUN;
	else self.state = SW_RUN; 
	sweeper_frame();
};

void() sweeper_fire = {
	self.walkframe = 0; 
	self.pain_finished = time + 1;
	// weaponstate set in SweeperCheckAttack
	if (self.weaponstate) {
		// Can change mine to laser (spawnflags)
		if (self.spawnflags & MON_SWEEPER_LASER) self.state = SW_ATTACKLASER;
		else self.state = SW_ATTACKMINE;
	}
	else self.state = SW_ATTACKSPIN; 
	sweeper_frame();
};

//======================================================================
void(float offset) sweeper_fire_hazard =
{
	local vector org, torg, dir, ang, avel;
	local float targetang, haz_loop;
	
	if (!self.enemy) return;
	if (self.health < 1) return;
	
	// Play firing sound like hell knight (0.1s rapid fire)
	sound (self, CHAN_WEAPON, "sweeper/hazard_fire.wav", 1, ATTN_NORM);
	
	makevectors(self.angles);
	org = self.origin + attack_vector(self.meleeoffset);

	if (skill < SKILL_HARD) haz_loop = 1;
	else haz_loop = 2;
	while(haz_loop > 0) {
		// Keep looping
		haz_loop = haz_loop - 1;
		// Workout target origin (self.enemy)
		torg = SUB_orgEnemyTarget();
		// Allow for large target area
		torg_x = torg_x + (crandom() * 64);
		torg_y = torg_y + (crandom() * 64);
		targetang = SUB_Elevation(ELEV_DEFAULT, self.origin, torg, SPEED_SWEEPER);
		// Work out angle
		ang = vectoangles(torg - org);
		ang_x = -targetang;	// Negative = upwards angle 
		makevectors (ang);
		// fire plasma in arc pattern (offset)
		dir = ( (v_forward * (1 + random()*0.5)) + (v_right * (offset*0.1)) ) * SPEED_SWEEPER;	
		// Some random angle rotation
		avel = vecrand(100,200,FALSE);
		Launch_Hazard(org, dir, avel, CT_PROJ_SWEEPER2);
	}
};

//----------------------------------------------------------------------
void(float offset) sweeper_fire_laser =
{
	local vector org, dir, vec;

	if (!self.enemy) return;
	if (self.health < 1) return;
	
	// Always make sure there is no monster or obstacle in the way
	// Cannot use enemy entity direct, enemytarget will be active
	if ( !visxray(SUB_entEnemyTarget(), '0 0 0', '0 0 12', FALSE) ) return;

	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, SOUND_LASER_FIRE, 1, ATTN_NORM);

	makevectors (self.angles);
	// Shift left/right 2+ lasers
	org = self.origin + (v_right * offset);

	// Aim high to catch jumping players
	dir = SUB_orgEnemyTarget() + '0 0 12';
	vec = normalize(dir - org);
	// Variable laser speed, original unit was just 800 every skill
	self.attack_speed = SPEED_SWEEPERPROJ + (skill * SPEED_SWEEPERPROJSKILL);
	launch_projectile(org, vec, CT_PROJ_LASER, self.attack_speed);
};

//----------------------------------------------------------------------
void() sweeper_fire_mine =
{
	local vector org, dir;
	local float veclen, vecdown;
	
	if (!self.enemy) return;
	if (self.health < 1) return;
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "sweeper/mine_launch.wav", 1, ATTN_NORM);	

	// Maximum speed, initial speed set in Launch_Missile
	self.attack_speed = SPEED_SWEEPERPROJ + (skill * SPEED_SWEEPERPROJSKILL);

	// check for enemy origin (based on sight test)
	// if cannot see enemy fire at last known location
	ai_trackenemy();

	makevectors (self.angles);
	org = self.origin + attack_vector(self.attack_offset);
	
	// Check for space below for downward force of mine/rocket
	traceline(self.origin, self.origin-'0 0 1024', TRUE, self);
	veclen = vlen(self.origin - trace_endpos);
	// Normalize (0-1) vector length (cap at 100%)
	if (veclen > 100) veclen = 100;
	// Workout base + random % of downward force
	vecdown = (veclen*0.004) + (random() * (veclen*0.005));
	dir = normalize(self.attack_track - org) + (-v_up * vecdown);
	// Rocket, smoke and particles
	Launch_Missile (org, dir, '400 0 0', CT_PROJ_SWEEP1, self.attack_speed);
	SpawnExplosion(EXPLODE_BURST_SMOKE, self.origin+'0 0 -24', "");
	SpawnProjectileSmoke(self.origin, 50, -25, -25);
};

//======================================================================
void(entity inflictor, entity attacker, float damage) sweeper_pain =
{
	// Check all pain conditions and set up what to do next
	monster_pain_check(attacker, damage);

	// Always play a pain sound
	if (random() < 0.5) sound (self, CHAN_VOICE, self.pain_sound, 1, ATTN_NORM);
	else sound (self, CHAN_VOICE, self.pain_sound2, 1, ATTN_NORM);

	// Spawn a pile of sparks and dust falling down
	particle_dust(self.origin, 10+random()*10, 16, PARTICLE_BURST_YELLOW);
	SpawnProjectileSmoke(self.origin, 150, 50, 150);
	SpawnProjectileSmoke(self.origin, 150, 50, 150);
	
	// Work out which direction the damage came from (enemy)
	self.pos2 = self.origin - attacker.origin;
	self.pos1 = vectoangles(self.pos2);
	self.pos1_y = 0;
	
	// Start pain animation
	self.state = SW_PAIN;
	self.walkframe = 0;
	self.velocity = '0 0 0';
};

//======================================================================
void() sweeper_die =
{
	// Pre-check routine to tidy up extra entities
	monster_death_precheck();

	// Final fireworks!
	particle_dust(self.origin, 10+random()*10, 16, PARTICLE_BURST_YELLOW);
	SpawnProjectileSmoke(self.origin, 150, 50, 150);
	SpawnProjectileSmoke(self.origin, 150, 50, 150);
	SpawnExplosion(EXPLODE_BIG, self.origin, self.death_sound);

	// no more sweeper
	entity_hide (self);
	self.state = SW_DEATH;
	sweeper_remove_attachment();
	// Make sure gibs go flying up
	self.max_health = MON_GIBFOUNTAIN;
	self.health = -100;

	// Metal and custom body parts
	self.gibtype = GIBTYPE_METAL;
	ThrowGib(11, 1);						// middle piece with light
	ThrowGib(12, 1 + rint(random()*2));		// top rotating part with spikes
	ThrowGib(13, 2 + rint(random()*2));		// bottom rotating part
	ThrowGib(14, 1 + rint(random()*2));		// spike from top
	ThrowGib(15, 2 + rint(random()*3));		// Generic metal
};

//============================================================================
void() sweeper_shieldon =
{
	self.takedamage = DAMAGE_YES;	// Grenades bounce off
	self.bouncegrenade = TRUE;		// Warning to other monsters
	self.reflectnails = TRUE;		// Reflect nail projectiles
	self.reflectlightning = TRUE;	// Reflect lightning strikes
	self.reflectplasma = TRUE;		// Reflect plasma projectiles
	self.reflectaxe = TRUE;			// Prevent axe damage
	// Visually show resistance and reduce damage taken
	self.resist_shells = self.resist_nails = 1;
	self.resist_rockets = self.resist_cells = 1;
};

//----------------------------------------------------------------------
void() sweeper_shieldoff =
{
	self.takedamage = DAMAGE_AIM;	// Grenades can make contact
	self.bouncegrenade = FALSE;		// Reset to default
	self.reflectnails = FALSE;		// Allow nail projectiles
	self.reflectlightning = FALSE;	// Allow lightning strikes
	self.reflectplasma = FALSE;		// Allow plasma projectiles
	self.reflectaxe = FALSE;		// Allow axe damage
	self.resist_shells = self.resist_nails = 0;
	self.resist_cells = 0;
	self.resist_rockets = -1;	// Double damage from grenades/rockets
};

//----------------------------------------------------------------------
void() sweeper_shield = 
{
	// Setup particle emitter for shield effect
	self.part_active = PARTICLE_STYLE_FFIELD;
	self.spr_frame = PARTICLE_BURST_BLUE;
	self.part_vol = '12 12 24';		// Bounding box volume
	self.part_limit = 50;			// Medium amount of particles
	self.part_life = 4;				// Longer lifetime
	self.part_ofs = '0 0 0';		// Move up from monster origin
	self.part_vel = '0 0 4';		// Move up from monster origin
	self.part_emitter = spawn_pemitter(self, self, self.part_active, PARTICLE_START_ON);
	// Back into (default) stand around loop
	sweeper_stand();
};

//----------------------------------------------------------------------
void() sweeper_wakeup =
{
	// Check for sudden death!
	if (self.health < 0) return;
	
	self.use = SUB_Null;				// no re-trigger
	sweeper_finish_attachment();		// Remove shield + spawnflag
	self.spawnflags = self.spawnflags - (self.spawnflags & MON_SWEEPER_SHIELD);
	
	// Switch off shield sound
	sound (self, CHAN_WEAPON, "ambience/power_off.wav", 1, ATTN_NORM);
	// Switch OFF any particle emitter
	if (self.part_emitter) misc_particle_off(self.part_emitter);
	
	// Check for any trigger off events (trigger_once)
	if (self.target2 != "") trigger_strs(self.target2, self);
	self.target2 = "";
	
	// Restore all think functions
	self.th_stand = sweeper_stand;
	self.th_walk = sweeper_walk;
	self.th_run = sweeper_run;
	self.th_missile = sweeper_fire;
	self.th_pain = sweeper_pain;
	self.th_die = sweeper_die;
	sweeper_shieldoff();			// Ammo resist + reflection
	monster_targets();				// Check for targets
};

/*======================================================================
QUAKED monster_sweeper (1 0 0) (-16 -16 -24) (16 16 24) Ambush
======================================================================*/
void() monster_sweeper =
{
	// Check all spawn exceptions (monsters.qc)
	if (monster_checkspawn() == TRUE) return;

	self.mdl = "progs/mon_sweeper.mdl";			// Sentinel clone
//	self.headmdl = "progs/h_sweeper.mdl";		// Not used
	self.weaponglow = "progs/mon_sweeper_glow.mdl";
	self.gib1mdl = "progs/gib_sweeper1.mdl";	// middle piece with light
	self.gib2mdl = "progs/gib_sweeper2.mdl";	// top rotating part with spikes
	self.gib3mdl = "progs/gib_sweeper3.mdl";	// bottom rotating part
	self.gib4mdl = "progs/gib_sweeper4.mdl";	// spike from top
	self.gib5mdl = "progs/gib_metal1.mdl";		// generic metal chunk

	precache_model (self.mdl);			// Sweeper
	precache_model (self.weaponglow);	// Glowing blue shield
//	precache_model (self.headmdl);		// Not used
	precache_model (self.gib1mdl);		// middle piece with light
	precache_model (self.gib2mdl);		// top rotating part with spikes
	precache_model (self.gib3mdl);		// bottom rotating part
	precache_model (self.gib4mdl);		// spike from top
	precache_model (self.gib5mdl);		// generic metal chunk

	// Robot talktalk
	self.idle_sound = "sweeper/idle1.wav";
	precache_sound (self.idle_sound);

	// Constant drone sound (background)
	precache_sound ("sweeper/idledrone1.wav");
	
	// Alternative spawnflag, lasers instead of mines
	if (self.spawnflags & MON_SWEEPER_LASER) {
		// red version (new)
		if (self.exactskin == 0) self.exactskin = 1;
		precache_model (MODEL_PROJ_LASER);		// Copy of enforcer laser
		precache_sound (SOUND_LASER_FIRE);
		precache_sound (SOUND_LASER_HIT);
		self.part_trstyle = PARTICLE_TRAIL_RED;
		self.attack_proj2 = MODEL_PROJ_SWEEPER2R;	// Red hazard plasma
	}
	else {
		// blue version (default)
		precache_model (MODEL_PROJ_SWEEPER1);	// Floating mine
		precache_sound ("sweeper/mine_launch.wav");
		precache_sound ("sweeper/mine_fire.wav");
		precache_sound ("sweeper/mine_hit.wav");
		self.part_trstyle = PARTICLE_TRAIL_BLUE;
		self.attack_proj2 = MODEL_PROJ_SWEEPER2B;	// Blue hazard plasma
	}
	// Cache hazard projectile/sounds
	precache_model (self.attack_proj2);	
	precache_sound ("sweeper/hazard_fire.wav");
	precache_sound ("sweeper/hazard_miss.wav");
	
	self.pain_sound = "sweeper/pain1.wav";
	self.pain_sound2 = "sweeper/pain2.wav";
	precache_sound (self.pain_sound);
	precache_sound (self.pain_sound2);
	self.death_sound = "sweeper/explode_major.wav";
	precache_sound (self.death_sound);
	// Power off sound for shield setup
	precache_sound ("ambience/power_off.wav");
	
	self.sight_sound = "sweeper/sight1.wav";
	precache_sound (self.sight_sound);

	self.solid = SOLID_NOT;				// No interaction with world
	self.movetype = MOVETYPE_NONE;		// Static item, no movement
	if (self.bboxtype < 1) self.bboxtype = BBOX_SHORT;
	if (self.health < 1) self.health = 200;
	self.gibhealth = MON_NEVERGIB;		// Special explosion death
	self.gibbed = FALSE;
	self.pain_flinch = 30;				// Sometimes flinch
	self.steptype = FS_FLYING;			// Silent feet
	self.pain_longanim = FALSE;			// No long pain animation
	self.blockudeath = TRUE;			// No humanoid death sound
	self.poisonous = FALSE;				// Robots are not poisonous
	if (self.height < 1) self.height = (MONAI_ABOVEDIST * 0.5);
	self.no_liquiddmg = TRUE;			// Immune to slime/lava
	self.meleeoffset = '0 0 16';		// Top of body
	self.attack_offset = '0 0 -16';		// Bottom of body
	self.yaw_speed = 45;				// Super fast turning
	if (self.velocityfriction <= 0) self.velocityfriction = 0.8 + (random() * 0.1);
	self.sight_nofront = TRUE;			// Has no front facing
	self.deathstring = " was mined by a Sweeper\n";
	self.attack_chance = TRUE;			// First time attack setup

	//----------------------------------------------------------------------
	if (self.spawnflags & MON_SWEEPER_SHIELD) {
		sweeper_shieldon();				// Ammo resist + reflection
		self.th_stand = sweeper_shield;	// Setup Shield
		self.think1 = sweeper_wakeup;	// Wakeup function when triggered
	}
	else {
		sweeper_shieldoff();			// Ammo resist + reflection
		self.th_stand = sweeper_stand;
		self.th_walk = sweeper_walk;
		self.th_run = sweeper_run;
		self.th_missile = sweeper_fire;
		self.th_pain = sweeper_pain;
		self.th_die = sweeper_die;
	}

	self.th_checkattack = SweeperCheckAttack;
	self.classtype = CT_MONSWEEPER;
	self.classgroup = CG_ROBOT;
	self.classmove = MON_MOVEFLY;
	
	monster_start();
};
