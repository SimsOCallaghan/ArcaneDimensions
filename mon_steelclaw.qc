/*==============================================================================
STEELCLAW (Hexen2 spider model by Raven Software)
==============================================================================*/
$frame idle1 idle2 idle3 idle4 idle5 idle6 idle7 idle8
$frame idle9 idle10 idle11 idle12 idle13

$frame idleup1 idleup2 idleup3 idleup4 idleup5 idleup6 idleup7 idleup8
$frame idleup9 idleup10 idleup11 idleup12 idleup13

$frame drop1 drop2 drop3 drop4 drop5 drop6

$frame grow1 grow2 grow3 grow4 grow5 grow6 grow7 grow8 grow9 grow10

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8
$frame walk9 walk10 walk11 walk12 walk13 walk14 walk15 walk16

// Lift spider up on to back legs
$frame atkup1 atkup2 atkup3 atkup4 atkup5 atkup6 atkup7 atkup8
$frame atkup9 atkup10 atkup11 atkup12

// Forward attacking (looping)
$frame atkloop1 atkloop2 atkloop3 atkloop4 atkloop5 atkloop6 atkloop7 atkloop8
$frame atkloop9 atkloop10

// Jumping up
$frame jump1 jump2 jump3 jump4 jump5 jump6 jump7 jump8
$frame jump9 jump10 jump11 jump12 jump13 jump14 jump15 jump16

// on all legs (pain backwards)
$frame paindown1 paindown2 paindown3 paindown4 paindown5 paindown6 paindown7 paindown8
$frame paindown9 paindown10

// On back legs (pain backwards)
$frame painup1 painup2 painup3 painup4 painup5 painup6 painup7 painup8

// roll over death on back (looks odd)
$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11 death12 death13 death14 death15 death16
$frame death17 death18 death19 death20

//======================================================================
void() steelc_idle1 =[ $idle1, steelc_idle2] {monster_idle_sound();ai_stand();};
void() steelc_idle2 =[ $idle2, steelc_idle3] {ai_stand();};
void() steelc_idle3 =[ $idle3, steelc_idle4] {ai_stand();};
void() steelc_idle4 =[ $idle4, steelc_idle5] {ai_stand();};
void() steelc_idle5 =[ $idle5, steelc_idle6] {ai_stand();};
void() steelc_idle6 =[ $idle6, steelc_idle7] {ai_stand();};
void() steelc_idle7 =[ $idle7, steelc_idle8] {ai_stand();};
void() steelc_idle8 =[ $idle8, steelc_idle9] {ai_stand();};
void() steelc_idle9 =[ $idle9, steelc_idle10] {ai_stand();};
void() steelc_idle10 =[ $idle10, steelc_idle11] {ai_stand();};
void() steelc_idle11 =[ $idle11, steelc_idle12] {ai_stand();};
void() steelc_idle12 =[ $idle12, steelc_idle13] {ai_stand();};
void() steelc_idle13 =[ $idle13, steelc_idle1] {ai_stand();};

//======================================================================
void() steelc_walk1 =[ $walk1, steelc_walk2] {monster_idle_sound();ai_walk(4);};
void() steelc_walk2 =[ $walk3, steelc_walk3] {monster_footstep(FALSE); ai_walk(3);};
void() steelc_walk3 =[ $walk5, steelc_walk4] {ai_walk(4);};
void() steelc_walk4 =[ $walk7, steelc_walk5] {ai_walk(5);};
void() steelc_walk5 =[ $walk9, steelc_walk6] {ai_walk(4);};
void() steelc_walk6 =[ $walk11, steelc_walk7] {monster_footstep(FALSE); ai_walk(3);};
void() steelc_walk7 =[ $walk13, steelc_walk8] {ai_walk(4);};
void() steelc_walk8 =[ $walk15, steelc_walk1] {ai_walk(5);};

//======================================================================
void() steelc_runpause =
{
	// Do nothing is not to fight or dead
	if (!self.enemy) return;
	if (self.health < 1) return;

	if (self.jump_flag < time) self.th_run();
	// Is the enemy too close? no more pausing, fight!
	self.enemydist = range_distance(self.enemy, FALSE);
	if (self.enemydist < MONAI_RUNPAUSE) self.th_run();
};

//----------------------------------------------------------------------
void()	steelc_runp1	=[	$idle1,	steelc_runp2	] {steelc_runpause();};
void()	steelc_runp2	=[	$idle2,	steelc_runp3	] {steelc_runpause();};
void()	steelc_runp3	=[	$idle3,	steelc_runp4	] {steelc_runpause();};
void()	steelc_runp4	=[	$idle4,	steelc_runp5	] {steelc_runpause();};
void()	steelc_runp5	=[	$idle5,	steelc_runp6	] {steelc_runpause();};
void()	steelc_runp6	=[	$idle6,	steelc_runp7	] {steelc_runpause();};
void()	steelc_runp7	=[	$idle7,	steelc_runp8	] {steelc_runpause();};
void()	steelc_runp8	=[	$idle8,	steelc_runp9	] {steelc_runpause();};
void()	steelc_runp9	=[	$idle9,	steelc_runp10	] {steelc_runpause();};
void()	steelc_runp10	=[	$idle10,steelc_runp11	] {steelc_runpause();};
void()	steelc_runp11	=[	$idle11,steelc_runp12	] {steelc_runpause();};
void()	steelc_runp12	=[	$idle12,steelc_runp13	] {steelc_runpause();};
void()	steelc_runp13	=[	$idle13,steelc_runp1	] {steelc_runpause();};

//----------------------------------------------------------------------
void(float dist) steelc_checkpause =
{
	// Do nothing is not to fight or dead
	if (!self.enemy) return;
	if (self.health < 1) return;

	// make spider run in bursts of speed (reset every run animation cycle)
	self.movespeed = self.movespeed + 1;
	// Do run code to check for enemies
	ai_run(dist + self.movespeed);
	
	// Check if target is too close?
	if (self.enemydist < MONAI_RUNPAUSE) return;
	// Random chance to stop and pause running
	if (self.movespeed > 7 && random() < 0.2) {
		self.jump_flag = time + random();
		self.think = steelc_runp1;
	}
};

//----------------------------------------------------------------------
void()	steelc_run1 =[ $walk1, steelc_run2 ] {self.movespeed = 0; monster_idle_sound();steelc_checkpause(8);};
void()	steelc_run2 =[ $walk3, steelc_run3 ] {monster_footstep(FALSE); steelc_checkpause(6);};
void()	steelc_run3 =[ $walk5, steelc_run4 ] {steelc_checkpause(8);};
void()	steelc_run4 =[ $walk7, steelc_run5 ] {steelc_checkpause(10);};
void()	steelc_run5 =[ $walk9, steelc_run6 ] {steelc_checkpause(8);};
void()	steelc_run6 =[ $walk11, steelc_run7 ] {monster_footstep(FALSE); steelc_checkpause(6);};
void()	steelc_run7 =[ $walk13, steelc_run8 ] {steelc_checkpause(8);};
void()	steelc_run8 =[ $walk15, steelc_run1 ] {steelc_checkpause(10);};

//======================================================================
void()	steelc_slide1 =[ $walk1, steelc_slide2 ] {ai_run_slide(6); monster_idle_sound();};
void()	steelc_slide2 =[ $walk3, steelc_slide3 ] {ai_run_slide(4);};
void()	steelc_slide3 =[ $walk5, steelc_slide4 ] {ai_run_slide(6);};
void()	steelc_slide4 =[ $walk7, steelc_slide5 ] {ai_run_slide(4);};
void()	steelc_slide5 =[ $walk9, steelc_slide6 ] {ai_run_slide(6);};
void()	steelc_slide6 =[ $walk11, steelc_slide7 ] {ai_run_slide(4);};
void()	steelc_slide7 =[ $walk13, steelc_slide8 ] {ai_run_slide(6);};
void()	steelc_slide8 =[ $walk15, steelc_run1 ] {ai_run(4);};

//======================================================================
// BITE - bleed attack or simple bite
//======================================================================
void() steelc_melee =
{
	local float ldmg;

	if (!self.enemy) return;
	if (self.health < 1) return;
		
	ai_charge(10);									// Get closer for extra bite
	ai_damagebreakable(10);							// Damage any breakables
	if (!ai_checkmelee(MONAI_MELEESTEELCLAW,FALSE)) return;	// Too far away

	// Can the target bleed?
	if (!self.enemy.takedamage) return;

	if (random() < 0.5) sound(self, CHAN_WEAPON, "steelclaw/attackmunch.wav", TRUE, TRUE);
	else sound(self, CHAN_WEAPON, "steelclaw/attacktear.wav", TRUE, TRUE);

	// Spider bite (damage 1-9) is very weak
	ldmg = (random() + random() + random()) * 3;
	if (ldmg < 1) ldmg = 1;
	T_Damage (self.enemy, self, self, ldmg, DAMARMOR);

	// Spawn blood at mouth
	spawn_touchblood (self, self.enemy, ldmg*3);
};

//----------------------------------------------------------------------
void() steelc_bite9;
void() steelc_bite1 = [ $atkup1, steelc_bite2 ] {ai_face();};
void() steelc_bite2 = [ $atkup5, steelc_bite3 ] {ai_face();};
void() steelc_bite3 = [ $atkup7, steelc_bite4 ] {ai_face();
	if (!ai_checkmelee(MONAI_MELEESPIDER,FALSE) && self.health > 0) 
		self.think = steelc_bite9;};
void() steelc_bite4 = [ $atkloop1, steelc_bite5 ] {ai_face();};
void() steelc_bite5 = [ $atkloop3, steelc_bite6 ] {ai_face();};
void() steelc_bite6 = [ $atkloop5, steelc_bite7 ] {steelc_melee();};
void() steelc_bite7 = [ $atkloop7, steelc_bite8 ] {};
void() steelc_bite8 = [ $atkup7, steelc_bite9 ] {};
void() steelc_bite9 = [ $atkup3, steelc_run1 ] {};

//============================================================================
// JUMP FUNCTION (range)
//============================================================================
void() steelc_JumpTouch =
{
	if (self.health <= 0) return;
	ai_jumpbreakable(20);			// Damage any breakables
	self.touch = SUB_Null;			// No more touching
	self.count = self.count + 1;	// Total amount of touch jumps
	self.think = self.th_jumpexit;	// Exit frame
	self.jumptouch = other;			// Keep track of touch target

	// Prevents packs from killing themselves
	if (self.classgroup != other.classgroup && other.takedamage) {
		sound (self, CHAN_VOICE, "steelclaw/jumphit.wav", 1, ATTN_NORM);
		BleedDeBuff(other);
		spawn_touchblood (self, self.enemy, 100);
	}

	// Is floating in the air?
	if (!checkbottom(self)) {
		// Is standing on something?		
		if (self.flags & FL_ONGROUND) {	
			// Do an extra jump if got the count
			if (self.count < 2)  self.think = self.th_jump;
		}
	}

	// Next timer
	self.nextthink = time + 0.1;
};

//----------------------------------------------------------------------------
void() steelc_leap1 =[ $jump1, steelc_leap2 ] {ai_face();
	self.jump_flag = time + MONAI_JUMPSTEELTIME; // Stop jumping so much
	if (random() > 0.5) {
		self.volume = 0.5 + (random()*0.5);
		if (self.lefty < 1) sound (self, CHAN_VOICE, "steelclaw/jumpattack1.wav", self.volume, ATTN_NORM);
		else sound (self, CHAN_VOICE, "steelclaw/jumpattack2.wav", self.volume, ATTN_NORM);
		self.lefty = 1 - self.lefty;
	}
};
void() steelc_leap2 =[ $jump3, steelc_leap3 ] {ai_face();};
void() steelc_leap3 =[ $jump5, steelc_leap4 ] {ai_face();
	// Throw the steelclaw like a grenade!
	self.attack_speed = self.jumpdist_x + (random()*self.jumpdist_z);
	// Aiming at the players head (+24 z axis)
	self.pos2 = self.enemy.origin + '0 0 24';
	self.attack_elev = SUB_Elevation(ELEV_DEFAULT, self.origin, self.pos2, self.attack_speed);
	self.pos1 = vectoangles(self.pos2 - self.origin);
	self.pos1_x = -self.attack_elev;
	makevectors (self.pos1);
	self.velocity = v_forward * self.attack_speed;
	
	self.jump_flag = time + MONAI_JUMPSTEELTIME; // Stop jumping so much
	self.touch = steelc_JumpTouch;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.oldorigin = self.origin;
};
void() steelc_leap4 =[ $jump7, steelc_leap5 ] {};
void() steelc_leap5 =[ $jump8, steelc_leap6 ] {};	
void() steelc_leap6 =[ $jump9, steelc_leap7 ] {};
void() steelc_leap7 =[ $jump10, steelc_leap8 ] {
	// Double check monster is still falling?
	if (CheckZeroVector(self.velocity) || self.oldorigin == self.origin) {
		self.ideal_yaw = random() * 360; //random jump angle
		self.think = steelc_leap3;
	}
	self.oldorigin = self.origin;
};

//----------------------------------------------------------------------
void() steelc_leap8 =[ $jump11, steelc_leap9] {monster_footstep(FALSE);};
void() steelc_leap9 =[ $jump13, steelc_leap10] {monster_footstep(FALSE);};
void() steelc_leap10 =[ $jump15, steelc_run1] {ai_resetangles();};

//============================================================================
void() steelc_paind1 =[$paindown1, steelc_paind2] {};
void() steelc_paind2 =[$paindown3, steelc_paind3] {};
void() steelc_paind3 =[$paindown5, steelc_paind4] {};
void() steelc_paind4 =[$paindown7, steelc_paind5] {};
void() steelc_paind5 =[$paindown9, steelc_run1] {};

//----------------------------------------------------------------------------
// Front legs up (in melee or missile attack)
void() steelc_painu1 =[$painup1, steelc_painu2] {};
void() steelc_painu2 =[$painup3, steelc_painu3] {};
void() steelc_painu3 =[$painup5, steelc_painu4] {};
void() steelc_painu4 =[$painup6, steelc_run1] {};

//----------------------------------------------------------------------------
void(entity inflictor, entity attacker, float damage) steelc_pain = 
{
	// Check all pain conditions and set up what to do next
	monster_pain_check(attacker, damage);

	// Any pain animation/sound required?
	if (self.pain_check > 0) {
		if (random() < 0.5) sound (self, CHAN_VOICE, self.pain_sound, 1, ATTN_NORM);
		else sound (self, CHAN_VOICE, self.pain_sound2, 1, ATTN_NORM);
		self.pain_finished = time + 1;

		if (self.pain_check == 1 || self.pain_check == 2) {
			if (self.pain_check == 2) {
				// reset axe hit and setup short pain recovery
				self.pain_finished = time + 0.4;
				self.axhitme = 0;
			}
			// Different types of pain animations based on current attack
			if ( self.frame > $atkup8 && self.frame < $atkloop10 ) steelc_painu1();
			else steelc_paind1();
		}
	}
};

//============================================================================
void() steelc_die1 =[$death1, steelc_die2] {};
void() steelc_die2 =[$death3, steelc_die3] {monster_check_gib();};
void() steelc_die3 =[$death5, steelc_die4] {monster_check_gib();
	self.solid = SOLID_NOT;};
void() steelc_die4 =[$death7, steelc_die5] {};
void() steelc_die5 =[$death9, steelc_die6] {};
void() steelc_die6 =[$death11, steelc_die7] {};
void() steelc_die7 =[$death13, steelc_die8] {};
void() steelc_die8 =[$death15, steelc_die9] {};
void() steelc_die9 =[$death17, steelc_die10] {monster_death_postcheck();};
void() steelc_die10 =[$death19, steelc_die10] {monster_deadbody_check();};

//----------------------------------------------------------------------------
void() steelc_die = 
{
	// Gibs don't bounce far
	self.max_health = MON_NOGIBVELOCITY;
	// Pre-check routine to tidy up extra entities
	monster_death_precheck();
	// regular death
	if (!self.gibbed) {
		sound (self, CHAN_VOICE, self.death_sound, 1, ATTN_NORM);
		steelc_die1();
	}
};

//======================================================================
/*QUAKED monster_steelclaw (1 0 0) (-16 -16 -24) (16 16 24) Ambush
======================================================================*/
void() monster_steelclaw =
{
	// Check all spawn exceptions (monsters.qc)
	if (monster_checkspawn() == TRUE) return;

	self.mdl = "progs/mon_steelclaw.mdl";
	self.headmdl = "progs/h_steelclaw.mdl";		// Front Jaws
	self.gib1mdl = "progs/gib_steelleg.mdl";	// Single Leg
	self.gib2mdl = "progs/gib_steelbody.mdl";	// Back Body

	precache_model (self.mdl);
	precache_model (self.headmdl);
	precache_model (self.gib1mdl);
	precache_model (self.gib2mdl);

	// Head/Body and Special GIB models
	self.gib1frame = 9;

	// IDLE/COMBAT and SIGHT sounds
	self.idle_sound = "steelclaw/idle1.wav";
	self.idle_sound2 = "steelclaw/idle2.wav";
	precache_sound (self.idle_sound);
	precache_sound (self.idle_sound2);

	// death/pain/attack sounds
	self.pain_sound = "steelclaw/pain1.wav";
	self.pain_sound2 = "steelclaw/pain2.wav";
	precache_sound(self.pain_sound);
	precache_sound(self.pain_sound2);
	self.death_sound = "steelclaw/death1.wav";
	precache_sound(self.death_sound);

	precache_sound("steelclaw/attackmunch.wav");
	precache_sound("steelclaw/attacktear.wav");
	precache_sound("steelclaw/jumpattack1.wav");
	precache_sound("steelclaw/jumpattack2.wav");
	precache_sound("steelclaw/jumphit.wav");
	precache_sound("steelclaw/jumpland.wav");
	
	self.sight_sound = "steelclaw/sight1.wav";
	precache_sound (self.sight_sound);

	self.solid = SOLID_NOT;				// No interaction with world
	self.movetype = MOVETYPE_NONE;		// Static item, no movement
	if (self.bboxtype < 1) self.bboxtype = BBOX_TINY;
	if (self.health < 1) self.health = 75;
	self.gibhealth = -20;
	self.gibbed = FALSE;
	self.idlemoreoften = TRUE;			// More creepy idle sounds
	self.pain_flinch = 10;				// Always flinch
	self.steptype = FS_TYPELIGHT;
	self.poisonous = FALSE;				// Never poisonous
	self.pain_longanim = TRUE;			// can be chopped with shadow axe
	self.blockudeath = TRUE;			// No humanoid death sound
	self.meleeoffset = '24 0 20';		// Bite attack offset
	self.movespeed = 1;					// Can never be a turret
	self.deathstring = " was bled out by a Steelclaw\n";

	// Default jump forward/up distance
	if (CheckZeroVector(self.jumpdist)) self.jumpdist = '650 0 50';
	if (self.jumprange_x <= 0) self.jumprange_x = MONAI_JUMPSTEELNEAR;
	if (self.jumprange_y <= self.jumprange_x) self.jumprange_y = MONAI_JUMPSTEELFAR;

	// Always reset Ammo Resistance to be consistent
	self.resist_shells = self.resist_nails = 0;
	self.resist_rockets = self.resist_cells = 0;

	self.th_checkattack = SteelclawCheckAttack;	
	self.th_stand = steelc_idle1;
	self.th_walk = steelc_walk1;
	self.th_run = steelc_run1;
	self.th_melee = steelc_bite1;
	self.th_slide = steelc_slide1;
	self.th_jump = steelc_leap1;
	self.th_jumpexit = steelc_leap9;
	self.th_pain = steelc_pain;
	self.th_die = steelc_die;
	
	self.classtype = CT_MONSTEELCLAW;
	self.classgroup = CG_SPIDER;
	self.classmove = MON_MOVEWALK;

	monster_start();
};
