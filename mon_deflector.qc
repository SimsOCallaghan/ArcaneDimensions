/*==============================================================================
 The Deflector (Original from Zerstorer MOD)
 * I Added Yellow skin and modified blue skin to match better
 
 Originally had 150 HP, fired a plasma bolt and 'drunk' rockets
 The shield was a 100% no damage setup and only down when attacking.
 Personally I found the shield confusing at first because it
 never had any visual feedback that nothing was doing damage.
 
==============================================================================*/

// 000-007 (No Shield)
$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7

// 008-022 (Shield active)
$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8
$frame walk9 walk10 walk11 walk12 walk13 walk14 walk15 walk16

// 023-030 (Shield active)
$frame run1 run2 run3 run4 run5 run6 run7 run8

// 031-050 (Plasma Cannon)
$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8
$frame attack9 attack10 attack11 attack12 attack13 attack14 attack15 attack16
$frame attack17 attack18 attack19 attack20

// 051-064 (No Shield)
$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11 death12 death13 death14

// 065-075 (No Shield)
$frame fdeath1 fdeath2 fdeath3 fdeath4 fdeath5 fdeath6 fdeath7 fdeath8
$frame fdeath9 fdeath10 fdeath11

// A=076-079 B=080-084 C=085-092 D=093-111
$frame paina1 paina2 paina3 paina4
$frame painb1 painb2 painb3 painb4 painb5
$frame painc1 painc2 painc3 painc4 painc5 painc6 painc7 painc8
// Stumble forward
$frame paind1 paind2 paind3 paind4 paind5 paind6 paind7 paind8
$frame paind9 paind10 paind11 paind12 paind13 paind14 paind15 paind16
$frame paind17 paind18 paind19

// 112-118 (Rocket Attack)
$frame attackp1 attackp2 attackp3 attackp4 attackp5 attackp6 attackp7

// 119-125 (Shield turns on/off)
$frame fieldon1 fieldon2 fieldon3 fieldon4 fieldon5 fieldon6 fieldon7

//----------------------------------------------------------------------
// Shield status (IDLE=OFF, WALK=ON, RUN=ON)
//----------------------------------------------------------------------
float DEFLECT_IDLE = 0;
float DEFLECT_WALK = 1;
float DEFLECT_RUN = 2;

//===========================================================================
void() deflect_shieldon =
{
	self.takedamage = DAMAGE_YES;	// Grenades bounce off
	self.bouncegrenade = TRUE;		// Warning to other monsters
	self.reflectnails = TRUE;		// Reflect nail projectiles
	self.reflectlightning = TRUE;	// Reflect lightning strikes
	self.reflectplasma = TRUE;		// Reflect plasma projectiles
	self.reflectaxe = TRUE;			// Prevent axe damage
	// Visually show resistance and reduce damage taken
	self.resist_shells = self.resist_nails = 0.25;
	self.resist_rockets = 0.25; self.resist_cells = 0.75;
};

//----------------------------------------------------------------------
void() deflect_shieldoff =
{
	self.takedamage = DAMAGE_AIM;	// Grenades can make contact
	self.bouncegrenade = FALSE;		// Reset to default
	self.reflectnails = FALSE;		// Allow nail projectiles
	self.reflectlightning = TRUE;	// Reflect lightning strikes
	self.reflectplasma = TRUE;		// Reflect plasma projectiles
	self.reflectaxe = FALSE;		// Allow axe damage
	self.resist_shells = self.resist_nails = 0;
	self.resist_rockets = 0; self.resist_cells = 0.5;
};

//----------------------------------------------------------------------
void() deflect_shieldsound_on = {
	sound (self, CHAN_ITEM, "deflector/shield_on.wav", 1, ATTN_NORM);
};

//----------------------------------------------------------------------
void() deflect_shieldsound_off = {
	sound (self, CHAN_ITEM, "deflector/shield_off.wav", 1, ATTN_NORM);
};

//----------------------------------------------------------------------
void() deflect_shieldparticle = {
	self.pos1 = self.origin;
	// Randomize position from middle to feet (particles float up)
	self.pos1_z = self.pos1_z - (random()*20);
	self.cnt = rint(5 + random()*10);
	if (self.spawnflags & MON_DEFLECTOR_PLASMA)
		particle_explode(self.pos1, self.cnt, 1, PARTICLE_BURST_BLUE, PARTICLE_BURST_UPWARD); 
	else
		particle_explode(self.pos1, self.cnt, 1, PARTICLE_BURST_YELLOW, PARTICLE_BURST_UPWARD); 
};

//===========================================================================
void() deflect_stands7;	// Forward compiler reference
void() deflect_stand1=[ $stand1, deflect_stand2] {ai_stand();

	// Work out if shield was on before this state
	if (self.weaponstate == DEFLECT_WALK && self.health > 0) {
		self.weaponstate = DEFLECT_IDLE;
		deflect_stands7();
	}
	// No idle sound at same time as shield sound
	else monster_idle_sound();
};
// Switch off shield (reverse animation)
void() deflect_stands7=[ $fieldon7, deflect_stands6] {ai_stand();
	deflect_shieldoff();deflect_shieldsound_off();};
void() deflect_stands6=[ $fieldon6, deflect_stands5] {ai_stand();};
void() deflect_stands5=[ $fieldon5, deflect_stand2] {ai_stand();};

//----------------------------------------------------------------------
void() deflect_stand2=[ $stand2, deflect_stand3] {ai_stand();};
void() deflect_stand3=[ $stand3, deflect_stand4] {ai_stand();};
void() deflect_stand4=[ $stand4, deflect_stand5] {ai_stand();};
void() deflect_stand5=[ $stand5, deflect_stand6] {ai_stand();};
void() deflect_stand6=[ $stand6, deflect_stand7] {ai_stand();};
void() deflect_stand7=[ $stand7, deflect_stand1] {ai_stand();};

//===========================================================================
void() deflect_walks5;	// Forward compiler reference
void() deflect_walk1=[ $walk1, deflect_walk2] {ai_walk(2);
	// Work out if shield was on before this state
	if (self.weaponstate == DEFLECT_IDLE && self.health > 0) {
		self.weaponstate = DEFLECT_WALK;
		deflect_walks5();
	}
	// No idle sound at same time as shield sound
	else monster_idle_sound();
};
// Switch on shield (forward animation)
void() deflect_walks5=[ $fieldon5, deflect_walks6] {ai_walk(0);
	deflect_shieldon();deflect_shieldsound_on();};
void() deflect_walks6=[ $fieldon6, deflect_walks7] {ai_walk(0);};
void() deflect_walks7=[ $fieldon7, deflect_walk2] {ai_walk(0);};

//----------------------------------------------------------------------
void() deflect_walk2=[ $walk2, deflect_walk3] {
	deflect_shieldparticle(); monster_footstep(FALSE);ai_walk(4);};
void() deflect_walk3=[ $walk3, deflect_walk4] {ai_walk(4);};
void() deflect_walk4=[ $walk4, deflect_walk5] {ai_walk(3);};
void() deflect_walk5=[ $walk5, deflect_walk6] {ai_walk(1);};
void() deflect_walk6=[ $walk6, deflect_walk7] {ai_walk(2);};
void() deflect_walk7=[ $walk7, deflect_walk8] {ai_walk(2);};
void() deflect_walk8=[ $walk8, deflect_walk9] {ai_walk(1);};
void() deflect_walk9=[ $walk9, deflect_walk10] {ai_walk(2);};
void() deflect_walk10=[ $walk10, deflect_walk11] {
	deflect_shieldparticle(); monster_footstep(FALSE); ai_walk(4);};
void() deflect_walk11=[ $walk11, deflect_walk12] {ai_walk(4);};
void() deflect_walk12=[ $walk12, deflect_walk13] {ai_walk(1);};
void() deflect_walk13=[ $walk13, deflect_walk14] {ai_walk(2);};
void() deflect_walk14=[ $walk14, deflect_walk15] {ai_walk(3);};
void() deflect_walk15=[ $walk15, deflect_walk16] {ai_walk(4);};
void() deflect_walk16=[ $walk16, deflect_walk1] {ai_walk(2);};

//===========================================================================
// Two speed run animation based on enemy visibility
//===========================================================================
void()	deflect_slow1;
void()	deflect_fast1;

// run state has two animation speeds (single function required)
void(float movespd) deflect_run =
{
	// Block all checks if dead
	if (self.health < 1) return;
	// idle functions work for both animation sets
	if (self.walkframe == 0) monster_idle_sound();
	
	// Work out if shield was on/off before this state
	if (self.weaponstate == DEFLECT_IDLE) {
		self.weaponstate = DEFLECT_RUN;
		deflect_shieldsound_on();
	}
	// Both walk/run animations have shield on!
	deflect_shieldon();
		
	// Change animation set based on enemy visibilty
	// Ignore frame 0 for checks (endless loop)
	// Make sure animations don't switch too rapid (timer)
	if (self.enemy) {
		if (self.walkframe > 0 && self.attack_switch < time) {
			// Prevent rapid switching (attack_switch)
			self.attack_switch = time + 1 + random();
			enemy_vis = visible(self.enemy);
			if (!enemy_vis) self.think = deflect_fast1;
			else self.think = deflect_slow1;
		}
	}
	
	// Check run/attack functions
	ai_run(movespd);
	// Walk through animation sets (reset on frame 0)
	self.walkframe = self.walkframe + 1;
};

// Walk animation with 150% movement speed
//----------------------------------------------------------------------
void()	deflect_slow1=[ $walk1,	deflect_slow2 ] {self.walkframe=0;deflect_run(3);};
void()	deflect_slow2=[ $walk2,	deflect_slow3 ] {
	deflect_shieldparticle(); monster_footstep(FALSE); deflect_run(6);
};
void()	deflect_slow3=[ $walk3, deflect_slow4 ] {deflect_run(6);};
void()	deflect_slow4=[ $walk4, deflect_slow5 ] {deflect_run(4.5);};
void()	deflect_slow5=[ $walk5, deflect_slow6 ] {deflect_run(1.5);};
void()	deflect_slow6=[ $walk6, deflect_slow7 ] {deflect_run(3);};
void()	deflect_slow7=[ $walk7, deflect_slow8 ] {deflect_run(3);};
void()	deflect_slow8=[ $walk8, deflect_slow9 ] {deflect_run(1.5);};
void()	deflect_slow9=[ $walk9, deflect_slow10] {deflect_run(3);};
void()	deflect_slow10=[ $walk10, deflect_slow11] {
	deflect_shieldparticle(); monster_footstep(FALSE); deflect_run(6);
};
void()	deflect_slow11=[ $walk11, deflect_slow12] {deflect_run(6);};
void()	deflect_slow12=[ $walk12, deflect_slow13] {deflect_run(1.5);};
void()	deflect_slow13=[ $walk13, deflect_slow14] {deflect_run(3);};
void()	deflect_slow14=[ $walk14, deflect_slow15] {deflect_run(4.5);};
void()	deflect_slow15=[ $walk15, deflect_slow16] {deflect_run(6);};
void()	deflect_slow16=[ $walk16, deflect_slow1] {deflect_run(3);};

// Typical run animation (used when enemy out of sight)
//----------------------------------------------------------------------
void()	deflect_fast1=[ $run1, deflect_fast2] {self.walkframe=0;deflect_run(18); };
void()	deflect_fast2=[ $run2, deflect_fast3] {deflect_run(14);};
void()	deflect_fast3=[ $run3, deflect_fast4] {
	deflect_shieldparticle(); monster_footstep(FALSE); deflect_run(7);
};
void()	deflect_fast4=[ $run4, deflect_fast5] {deflect_run(12);};
void()	deflect_fast5=[ $run5, deflect_fast6] {deflect_run(14);};
void()	deflect_fast6=[ $run6, deflect_fast7] {deflect_run(14);};
void()	deflect_fast7=[ $run7, deflect_fast8] {
	deflect_shieldparticle(); monster_footstep(FALSE); deflect_run(7);
};
void()	deflect_fast8=[ $run8, deflect_fast1] {deflect_run(11);};

//======================================================================
// MELEE Range (Flames)
//----------------------------------------------------------------------
void(float fire_explode) deflect_fireflame =
{
	local vector org, eorg, torg, dir, ang;
	local float expl_type, targetang;

	if (!self.enemy) return;
	if (self.health < 1) return;

	// Whooshing attack sound
	sound (self, CHAN_WEAPON, "deflector/flame_fire.wav", 1, ATTN_NORM);
	
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
		else expl_type = EXPLODE_SMALL;
		SpawnExplosion(expl_type, eorg, "deflector/flame_explode.wav");
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
	dir = (v_forward + (v_up * (random()*0.1)) ) * SPEED_FLAME;

	// Fire that flame!
	// target, origin, v_forward, colour, size, lifetime, speed
	Launch_Flame (self, org, dir, FLAME_RED, -1, -1, SPEED_FLAME);
	// Next arc position
	self.proj_attarc = self.proj_attarc + 1;
};

//----------------------------------------------------------------------
void() deflect_flameframe =
{
	// Dead Deflectors don't reflect back
	if (self.health < 1) return;

	// Keep looping
	self.nextthink = time + 0.1;
	self.think = deflect_flameframe;
	// Check for last frame (exit) first!
	if (self.walkframe < 0) {
		self.frame = $attack20;
		// last frame needs shield coming on
		deflect_shieldon(); deflect_shieldsound_on();
		// Slow down flame attacks with attack timer/blocker
		self.attack_timer = time + 1 + random();
		// Back to regular movement
		self.attack_state = AS_STRAIGHT;
		self.think = self.th_run;
	}
	else if (self.walkframe == 0) { self.frame = $attack1; 
		self.attack_switch = self.attack_timer = 0;
		sound (self, CHAN_WEAPON, "deflector/melee_attack.wav", 1, ATTN_NORM);
	}
	else if (self.walkframe == 1) { self.frame = $attack2;ai_face();
		deflect_shieldoff(); deflect_shieldsound_off();
	}
	else if (self.walkframe == 2) { self.frame = $attack3; ai_face();}
	// MAIN ATTACK LOOP ---------------------------------------------------
	else if (self.walkframe == 3) { self.frame = $attack14; ai_face();
		// Sprite Count = Base (X) * (Skill * Y) Maximum = Z
		self.attack_count = SpriteCount_Flame(self.proj_attqty);
	}
	else if (self.walkframe == 4) { self.frame = $attack15; ai_face();}
	else if (self.walkframe == 5) { self.frame = $attack16; deflect_fireflame(TRUE);}
	else if (self.walkframe >= 6) {
		// Keep counting down flame attacks (3/5/7 sets)
		self.attack_count = self.attack_count - 1;
		if (self.attack_count > 0) {
			self.frame = $attack17; 
			deflect_fireflame(FALSE);
			self.nextthink = time + 0.05;
		}
		else {
			// End of flame attack checks
			self.frame = $attack19; 
			self.walkframe = -10;
			// Extra flame attacks?
			if (self.attack_rage == TRUE) {
				// Sprite Count = Base (X) * (Skill * Y) Maximum = Z
				self.attack_count = SpriteCount_Flame(self.proj_attqty);
				// Any sprite space left for flame burst attack?
				if (HazardProjectile_CheckLimit(self, self.attack_count)) {
					// Can see player and within range?
					if (ai_checkmelee(MONAI_RANGEDEFLECT,FALSE) && 
						visxray(self.enemy, self.attack_offset, '0 0 0', FALSE)) {
						// Back around animation loop
						self.frame = $attack3; 
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
// MELEE Range (Plasma)
//----------------------------------------------------------------------
void(float sideang) deflect_fireplasma =
{
	local vector org, targ_org, dir;

	if (!self.enemy) return;

	// Keep adding up projectile counter
	self.attack_count = self.attack_count + 1;
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, SOUND_PLASMA_FIRE, 1, ATTN_NORM);
	self.attack_speed = SPEED_DEFLECTBOLT + (skill * SPEED_DEFLECTBSKILL);

	ai_trackenemy();
	makevectors (self.angles);
	org = self.origin + attack_vector(self.attack_offset);
	targ_org = self.attack_track + '0 0 -16' + (v_right * (sideang * 24));
	dir = normalize(targ_org - self.origin);

	launch_plasma(org, dir, CT_MONDEFLECTOR, self.attack_speed);
};

//----------------------------------------------------------------------
void() deflect_plasmaframe =
{
	// Dead Deflectors don't reflect back
	if (self.health < 1) return;

	// Keep looping
	self.nextthink = time + 0.1;
	self.think = deflect_plasmaframe;
	
	// Do specific stuff on certain animation frames
	if (self.walkframe == 0) { self.frame = $attack1; ai_face();
		self.attack_count = self.attack_switch = self.attack_timer = 0;
		sound (self, CHAN_WEAPON, "deflector/melee_attack.wav", 1, ATTN_NORM);
	}
	else if (self.walkframe == 1) { self.frame = $attack2; ai_face();
		self.attack_track = SUB_orgEnemyTarget();
		deflect_shieldoff(); deflect_shieldsound_off();
	}
	else if (self.walkframe == 2) { self.frame = $attack3; ai_trackenemy();}
	// MAIN ATTACK LOOP ---------------------------------------------------
	else if (self.walkframe == 3) { self.frame = $attack14; ai_trackenemy();}
	else if (self.walkframe == 4) { self.frame = $attack15; deflect_fireplasma(0);}
	else if (self.walkframe == 5) { self.frame = $attack16; ai_trackenemy();}
	else if (self.walkframe == 6) { self.frame = $attack17; deflect_fireplasma(-1);}
	else if (self.walkframe == 7) { self.frame = $attack18; ai_trackenemy();}
	else if (self.walkframe == 8) { self.frame = $attack19; deflect_fireplasma(1);}
	else if (self.walkframe >= 9) {
		// Has burst mode been switched off?
		if (self.attack_rage == FALSE) self.attack_count = self.proj_attqty_z+1;
		
		// Burst mode still active? Can see player?
		if (self.attack_count <= self.proj_attqty_z &&
			visxray(self.enemy, self.attack_offset, '0 0 0', FALSE) ) {
			// Keep looping
			self.walkframe = 3; self.frame = $attack14; ai_trackenemy();
		}
		else {
			self.frame = $attack20;
			// last frame needs shield coming on
			deflect_shieldon(); deflect_shieldsound_on();
			// Slow down plasma attacks with attack timer/blocker
			self.attack_timer = time + 1 + random();
			self.attack_state = AS_STRAIGHT;
			self.think = self.th_run;
		}
	}

	// Update frame and move forward
	self.walkframe = self.walkframe + 1;
};

//----------------------------------------------------------------------
void() deflect_melee = { 
	self.walkframe = 0;		// Frame counter
	self.attack_count = 0;	// Plasma/Flame counter
	self.attack_switch = 0;	// switching run modes
	// Switch melee attack types - Flame/Plasma
	if (self.spawnflags & MON_DEFLECTOR_PLASMA) deflect_plasmaframe();
	else deflect_flameframe();
};

//======================================================================
// LONG Range (Rocket Launcher)
//----------------------------------------------------------------------
void(float sideang) deflect_fire_rocket =
{
	local vector org, torg, dir;
	
	if (!self.enemy) return;
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "deflector/rocket_fire.wav", 1, ATTN_NORM);	

	// Maximum speed, initial speed set in Launch_Missile
	self.attack_speed = SPEED_DEFLECTROCKET + (skill * SPEED_DEFLECTRSKILL);

	// check for enemy origin (based on sight test)
	// if cannot see enemy fire at last known location
	ai_trackenemy();

	makevectors (self.angles);
	org = self.origin + attack_vector(self.meleeoffset);
	torg = self.attack_track + (v_right * (sideang * 24));
	dir = normalize(torg - org);

	Launch_Missile (org, dir, '0 0 0', CT_PROJ_DEFLECT1, self.attack_speed);
};

//----------------------------------------------------------------------
void() deflect_rocketframe =
{
	// Dead deflectors don't fight anymore
	if (self.health < 1) return;

	// Keep looping
	self.nextthink = time + 0.1;
	self.think = deflect_rocketframe;
	
	// Do specific stuff on certain animation frames
	if (self.walkframe == 0) { ai_face();
		self.frame = $attackp1;
		self.pain_finished = time + 1;
		self.attack_track = SUB_orgEnemyTarget();
		sound (self, CHAN_WEAPON, "deflector/rocket_load.wav", 1, ATTN_NORM);
	}
	else if (self.walkframe == 1) { 
		ai_trackenemy(); self.frame = $attackp2;
		deflect_shieldoff(); deflect_shieldsound_off();
	}
	else if (self.walkframe == 2) { ai_trackenemy(); self.frame = $attackp3; }
	else if (self.walkframe == 3) { ai_trackenemy(); self.frame = $attackp4; }
	else if (self.walkframe == 4) { self.frame = $attackp5; deflect_fire_rocket(0); }
	else if (self.walkframe == 5) { self.frame = $attackp4; 
	if (skill >= SKILL_NORMAL) deflect_fire_rocket(-1); }
	else if (self.walkframe == 6) { self.frame = $attackp5; 
	if (skill >= SKILL_HARD) deflect_fire_rocket(1); }
	else if (self.walkframe == 7) { self.frame = $attackp4; }
	else if (self.walkframe == 8) { self.frame = $attackp3; }
	else if (self.walkframe == 9) { self.frame = $attackp2; }
	else if (self.walkframe >= 10) { 
		self.frame = $attackp1;
		// last frame has shield coming on
		deflect_shieldon(); deflect_shieldsound_on();
		self.attack_state = AS_STRAIGHT;
		self.think = self.th_run;
	}
	// Update frame and move forward
	self.walkframe = self.walkframe + 1;
};

//----------------------------------------------------------------------
void() deflector_range = { self.walkframe = 0; deflect_rocketframe(); };

//============================================================================
// Classic enforcer 4 pain animation sets
//============================================================================
void() deflect_paina1=[ $paina1, deflect_paina2] {};
void() deflect_paina2=[ $paina2, deflect_paina3] {};
void() deflect_paina3=[ $paina3, deflect_paina4] {};
void() deflect_paina4=[ $paina4, deflect_slow1] {
	// Last pain frame has shield coming on
	deflect_shieldon();deflect_shieldsound_on();};

//----------------------------------------------------------------------
void() deflect_painb1=[ $painb1, deflect_painb2] {};
void() deflect_painb2=[ $painb2, deflect_painb3] {};
void() deflect_painb3=[ $painb3, deflect_painb4] {};
void() deflect_painb4=[ $painb4, deflect_painb5] {};
void() deflect_painb5=[ $painb5, deflect_slow1] {
	// Last pain frame has shield coming on
	deflect_shieldon();deflect_shieldsound_on();};

//----------------------------------------------------------------------
void() deflect_painc1=[ $painc1, deflect_painc2] {};
void() deflect_painc2=[ $painc2, deflect_painc3] {monster_footstep(FALSE);};
void() deflect_painc3=[ $painc3, deflect_painc4] {};
void() deflect_painc4=[ $painc4, deflect_painc5] {};
void() deflect_painc5=[ $painc5, deflect_painc6] {};
void() deflect_painc6=[ $painc6, deflect_painc7] {};
void() deflect_painc7=[ $painc7, deflect_painc8] {};
void() deflect_painc8=[ $painc8, deflect_slow1] {
	// Last pain frame has shield coming on
	deflect_shieldon();deflect_shieldsound_on();};

//----------------------------------------------------------------------
void() deflect_paind1=[ $paind1, deflect_paind2] {};
void() deflect_paind2=[ $paind2, deflect_paind3] {};
void() deflect_paind3=[ $paind3, deflect_paind4] {monster_footstep(FALSE);};
void() deflect_paind4=[ $paind4, deflect_paind5] {ai_painforward(2);};
void() deflect_paind5=[ $paind5, deflect_paind6] {ai_painforward(1);};
void() deflect_paind6=[ $paind6, deflect_paind7] {};
void() deflect_paind7=[ $paind7, deflect_paind8] {};
void() deflect_paind8=[ $paind8, deflect_paind9] {};
void() deflect_paind9=[ $paind9, deflect_paind10] {};
void() deflect_paind10=[ $paind10, deflect_paind11] {};
void() deflect_paind11=[ $paind11, deflect_paind12] {ai_painforward(1);};
void() deflect_paind12=[ $paind12, deflect_paind13] {ai_painforward(1);};
void() deflect_paind13=[ $paind13, deflect_paind14] {ai_painforward(1);};
void() deflect_paind14=[ $paind14, deflect_paind15] {};
void() deflect_paind15=[ $paind15, deflect_paind16] {};
void() deflect_paind16=[ $paind16, deflect_paind17] {ai_pain(1);};
void() deflect_paind17=[ $paind17, deflect_paind18] {ai_pain(1);};
void() deflect_paind18=[ $paind18, deflect_paind19] {};
void() deflect_paind19=[ $paind19, deflect_slow1] {
	// Last pain frame has shield coming on
	deflect_shieldon();deflect_shieldsound_on();};

//----------------------------------------------------------------------
void(entity inflictor, entity attacker, float damage) deflect_pain =
{
	// Check all pain conditions and set up what to do next
	monster_pain_check(attacker, damage);

	// Any pain animation/sound required?
	if (self.pain_check > 0) {
		self.lip = random ();
		if (self.lip < 0.5) sound (self, CHAN_VOICE, self.pain_sound, 1, ATTN_NORM);
		else sound (self, CHAN_VOICE, self.pain_sound2, 1, ATTN_NORM);

		// Turn off shield
		deflect_shieldoff();
		deflect_shieldsound_off();
		
		if (self.pain_check == 1) {
			// Randomly pick which pain animation to play
			if (self.lip < 0.2) deflect_paina1 ();
			else if (self.lip < 0.4) deflect_painb1 ();
			else if (self.lip < 0.7) deflect_painc1 ();
			else {
				self.pain_finished = time + 2;
				deflect_paind1 ();
			}
		}
		// The new axe forces monsters into long pain animations
		else if (self.pain_check == 2) {
			// reset axe hit and setup short pain recovery
			self.pain_finished = time + 1.9;
			self.axhitme = 0;
			deflect_paind1 ();
		}
	}
};

//============================================================================
void() deflect_die1=[ $death1, deflect_die2] {};
void() deflect_die2=[ $death2, deflect_die3] {monster_check_gib();};
void() deflect_die3=[ $death3, deflect_die4] {monster_check_gib();
	self.solid = SOLID_NOT; if (!self.gibbed) DropBackpack();};
void() deflect_die4=[ $death4, deflect_die5] {ai_forward(14);};
void() deflect_die5=[ $death5, deflect_die6] {ai_forward(2);};
void() deflect_die6=[ $death6, deflect_die7] {};
void() deflect_die7=[ $death7, deflect_die8] {};
void() deflect_die8=[ $death8, deflect_die9] {};
void() deflect_die9=[ $death9, deflect_die10] {ai_forward(3);};
void() deflect_die10=[ $death10, deflect_die11] {ai_forward(5);};
void() deflect_die11=[ $death11, deflect_die12] {ai_forward(5);};
void() deflect_die12=[ $death12, deflect_die13] {ai_forward(5);};
void() deflect_die13=[ $death13, deflect_die14] {monster_death_postcheck();};
void() deflect_die14=[ $death14, deflect_die14] {monster_deadbody_check();};

//----------------------------------------------------------------------
void() deflect_fdie1=[ $fdeath1, deflect_fdie2] {};
void() deflect_fdie2=[ $fdeath2, deflect_fdie3] {monster_check_gib();};
void() deflect_fdie3=[ $fdeath3, deflect_fdie4] {monster_check_gib();
	self.solid = SOLID_NOT; if (!self.gibbed) DropBackpack();};
void() deflect_fdie4=[ $fdeath4, deflect_fdie5] {};
void() deflect_fdie5=[ $fdeath5, deflect_fdie6] {};
void() deflect_fdie6=[ $fdeath6, deflect_fdie7] {};
void() deflect_fdie7=[ $fdeath7, deflect_fdie8] {};
void() deflect_fdie8=[ $fdeath8, deflect_fdie9] {};
void() deflect_fdie9=[ $fdeath9, deflect_fdie10] {};
void() deflect_fdie10=[ $fdeath10, deflect_fdie11] {monster_death_postcheck();};
void() deflect_fdie11=[ $fdeath11, deflect_fdie11] {monster_deadbody_check();};

//----------------------------------------------------------------------
void() deflect_die =
{
	// Pre-check routine to tidy up extra entities
	monster_death_precheck();

	// regular death
	if (!self.gibbed) {
		// Turn off shield
		deflect_shieldsound_off();

		// Typical forward/backward death + unique sound
		if (random() > 0.5) {
			deflect_die1 ();
			sound (self, CHAN_VOICE, self.death_sound2, 1, ATTN_NORM);
		}
		else {
			deflect_fdie1 ();
			sound (self, CHAN_VOICE, self.death_sound, 1, ATTN_NORM);
		}
	}
};

/*======================================================================
 QUAKED monster_deflector (1 0 0) (-16 -16 -24) (16 16 40) Ambush
======================================================================*/
void() monster_deflector =
{
	// Check all spawn exceptions (monsters.qc)
	if (monster_checkspawn() == TRUE) return;
	
	self.mdl = "progs/mon_deflector.mdl";
	self.headmdl = "progs/h_deflector.mdl";
	self.gib1mdl = "progs/w_enforcergun.mdl";	// Unique weapon
	precache_model (self.mdl);
	precache_model (self.headmdl);
	precache_model (self.gib1mdl);
	self.gib1sound = GIB_IMPACT_WOOD;	// Gib sound for gun

	// Melee attack (Fire/plasma)
	precache_sound ("deflector/melee_attack.wav");

	// Alternative spawnflag, lasers instead of mines
	if (self.spawnflags & MON_DEFLECTOR_PLASMA) {
		// Original BLUE version (plasma/rocket)
		self.exactskin = 1;		// Blue armour
		self.gib1skin = 3;		// Blue weapon
		self.part_trstyle = PARTICLE_TRAIL_BLUE;
		self.dpp_name = DPP_TRAILPARTB;			// Projectile particles
		// Range attack (Blue laser model)
		precache_model (MODEL_PROJ_LASERBLUE);
		precache_sound (SOUND_LASER_FIRE);
		precache_sound (SOUND_LASER_HIT);
		precache_sound (SOUND_LASER_RIC);
	}
	else {
		// New YELLOW version (flame/rocket)
		// Melee attack (Projectile Flames)
		PreCache_Flame();
		precache_sound ("deflector/flame_fire.wav");
		precache_sound ("deflector/flame_explode.wav");
		// Range attack (rocket model)
		precache_model (MODEL_PROJ_ROCKET);
	}
	
	self.idle_sound = "deflector/idle1.wav";
	precache_sound (self.idle_sound);
	self.sight_count = 3;
	self.sight_sound = "deflector/sight1.wav";
	self.sight_sound2 = "deflector/sight2.wav";
	self.sight_sound3 = "deflector/sight3.wav";
	precache_sound (self.sight_sound);
	precache_sound (self.sight_sound2);
	precache_sound (self.sight_sound3);
	
	// Shield off, shield on!
	precache_sound ("deflector/shield_off.wav");
	precache_sound ("deflector/shield_on.wav");

	// Projectile fire and impact (used in projectiles)
	precache_sound ("deflector/rocket_load.wav");
	precache_sound ("deflector/rocket_fire.wav");
	precache_sound ("deflector/rocket_hit.wav");

	// Extra load/fire sounds
	precache_sound (SOUND_PLASMA_LOAD);
	precache_sound (SOUND_PLASMA_FIRE);
	precache_sound (SOUND_PLASMA_HIT);

	// Plenty of death and pain sounds
	self.pain_sound = "deflector/pain1.wav";
	self.pain_sound2 = "deflector/pain2.wav";
	precache_sound (self.pain_sound);
	precache_sound (self.pain_sound2);
	self.death_sound = "deflector/death1.wav";
	self.death_sound2 = "deflector/death2.wav";
	precache_sound (self.death_sound);
	precache_sound (self.death_sound2);

	self.solid = SOLID_NOT;				// No interaction with world
	self.movetype = MOVETYPE_NONE;		// Static item, no movement
	if (self.bboxtype < 1) self.bboxtype = BBOX_TALL;
	if (self.health < 1) self.health = 250;
	// The Deflector is really just a monster with lots of attacks and HP++
	// It don't need bossflag protection, the combat is standard stuff
	//self.bossflag = TRUE;				// Boss flag (like FL_MONSTER)

	self.gibhealth = -50;
	self.gibbed = FALSE;				// Starts complete
	self.pain_flinch = 400;				// High pain threshold
	self.pain_longanim = FALSE;			// cannot be chopped with shadow axe
	self.pain_timeout = 2;				// High pain threshold
	self.infightextra = 4;				// High infighting damage
	self.steptype = FS_TYPEHEAVY;		// heavy player
	self.poisonous = FALSE;				// No Poison version
	self.no_liquiddmg = TRUE;			// Immune to slime/lava
	self.weaponstate = DEFLECT_IDLE;	// No Shield active
	self.meleeoffset = '8 8 28';		// Shoulder gun
	self.attack_offset = '28 8.5 16';	// End of Gun
	self.deathstring = " was crushed by the Deflector\n";
	// Setup default timer/counters
	self.attack_count = self.attack_timer = 0;
	self.part_exitpuff = self.part_exitsound = TRUE;
	
	// Setup default burst mode (=-1 to disable, def=TRUE)
	if (self.attack_rage < 0) self.attack_rage = FALSE;
	else if (self.attack_rage >= 0) self.attack_rage = TRUE;
	// Default is half flame limit for burst mode
	if (self.attack_rage == TRUE && self.proj_limit == 0)
		self.proj_limit = PROJ_MAXLIMIT * 0.5;
	
	// Plasma and flame have different projectile limits
	if (self.spawnflags & MON_DEFLECTOR_PLASMA) {
		if (self.proj_attqty_z <= 0) self.proj_attqty_z = MONAI_DEFLECTMAX; }
	else {
		// Setup default Proj Count = Base (X) * (Skill * Y) Maximum = Z
		if (CheckZeroVector(self.proj_attqty)) self.proj_attqty = '3 2 7'; }

	// ALL ammo resistances done in shield functions
	deflect_shieldoff();
	
	self.th_checkattack = DeflectorCheckAttack;
	self.th_stand = deflect_stand1;
	self.th_walk = deflect_walk1;
	self.th_run = deflect_slow1;
	self.th_melee = deflect_melee;
	self.th_missile = deflector_range;
	self.th_pain = deflect_pain;
	self.th_die = deflect_die;

	self.classtype = CT_MONDEFLECTOR;
	self.classgroup = CG_DCAPTAIN;
	self.classmove = MON_MOVEWALK;

	// Start monster (default)
	monster_start();
};