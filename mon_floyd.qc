/*==============================================================================
FLOYD (from Rubicon 2 MOD - john fitzgibbons)
==============================================================================*/

// (000-000) Used to create skin
$frame base1

// (001-001) Idle : Single frame
$frame idle1

// (002-017) Walk : Slow plond
$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8
$frame walk9 walk10 walk11 walk12 walk13 walk14 walk15 walk16

// (018-025) Run : Faster
$frame run1 run2 run3 run4 run5 run6 run7 run8

// (026-034) Attack : 3 fast lazers
$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8
$frame attack9

// (035-040) Pain : Short reflex
$frame paina1 paina2 paina3 paina4 paina5 paina6
// (041-050) Pain : Long reflex
$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8
$frame painb9 painb10
// (051-064) Pain : Backward Stumble
$frame painc1 painc2 painc3 painc4 painc5 painc6 painc7 painc8
$frame painc9 painc10 painc11 painc12 painc13 painc14

// (065-080) Death : Fall on floor
$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11 death12 death13 death14 death15 death16

//======================================================================
void () floyd_sleep = [$idle1, floyd_sleep] {};

//======================================================================
void() floyd_standframe =
{
	// Make sure alive
	if (self.health < 0) return;
	
	// Single IDLE frame unfortunately
	self.frame = $idle1;
	
	// Beginning of animation block
	if (self.walkframe == 0) monster_idle_sound();

	// Move frame forward, check for conditions
	self.walkframe = self.walkframe + 1;
	if (self.walkframe > 9) self.walkframe = 0;
	self.nextthink = time + 0.1;
	self.think = floyd_standframe;

	ai_stand();
};

//----------------------------------------------------------------------
void()	floyd_stand1 =[ $idle1, floyd_stand1 ] {
	self.walkframe = 0; floyd_standframe();
};

//======================================================================
void() floyd_walkframe =
{
	// Make sure alive
	if (self.health < 0) return;
	
	// Move animation forward
	self.frame = $walk1 + self.walkframe;
	
	// Beginning of animation block
	if (self.walkframe == 0) monster_idle_sound();
	else if (self.walkframe == 3) monster_footstep(FALSE);
	else if (self.walkframe == 11) monster_footstep(FALSE);

	// Move frame forward, check for conditions
	self.walkframe = self.walkframe + 1;
	if (self.walkframe > 15) self.walkframe = 0;
	self.nextthink = time + 0.1;
	self.think = floyd_walkframe;

	ai_walk(1.875);
};

//----------------------------------------------------------------------
void()	floyd_walk1 =[ $walk1, floyd_walk1 ] {
	self.walkframe = 0; floyd_walkframe();
};

//======================================================================
void() floyd_runframe =
{
	// Make sure alive
	if (self.health < 0) return;
	
	// Move animation forward
	self.frame = $run1 + self.walkframe;
	
	// Beginning of animation block
	if (self.walkframe == 0) monster_idle_sound();
	else if (self.walkframe == 1) monster_footstep(FALSE);
	else if (self.walkframe == 5) monster_footstep(FALSE);

	// Move frame forward, check for conditions
	self.walkframe = self.walkframe + 1;
	if (self.walkframe > 7) self.walkframe = 0;
	self.nextthink = time + 0.1;
	self.think = floyd_runframe;

	ai_run(3.75);
};

//----------------------------------------------------------------------
void()	floyd_run1 =[ $run1, floyd_run1 ] {
	self.walkframe = 0; floyd_runframe();
};
void()	floyd_run5 =[ $run5, floyd_run5 ] {
	self.walkframe = 4; floyd_runframe();
};

//======================================================================
void(float muzzle) floyd_fire =
{
	local vector org, targ_org, dir, muzoff;

	if (!self.enemy) return;
	if (self.health < 1) return;

	self.effects = self.effects | EF_MUZZLEFLASH;
	self.attack_speed = SPEED_FLOYDBOLT + (skill * SPEED_FLOYDSKILL);
	sound (self, CHAN_WEAPON, "floyd/fire.wav", 1, ATTN_NORM);

	// Create left/right laser vector
	muzoff = '0 0 0'; muzoff_y = muzzle;

	makevectors (self.angles);
	org = self.origin + attack_vector(self.attack_offset + muzoff);
	
	// Aim plasma bolt towards the enemy feet (using view_ofs)
	if (self.enemy.flags & FL_CLIENT) targ_org = self.enemy.origin - '0 0 20';
	else targ_org = self.enemy.origin - self.enemy.view_ofs;
	dir = normalize(targ_org - self.origin);

	launch_plasma(org, dir, CT_MONFLOYD, self.attack_speed);
};

//----------------------------------------------------------------------
void()	floyd_ready1 =[$run1, floyd_ready2] {ai_face();};
void()	floyd_ready2 =[$run2, floyd_ready3] {ai_face();};
void()	floyd_ready3 =[$run3, floyd_ready4] {ai_face();};
void()	floyd_ready4 =[$run4, floyd_attack1] {
	ai_face();
	// Check if sightline is broken by monster/world
	if (visblocked_wide(self.enemy, self.attack_offset, '0 0 0'))
		self.think = floyd_run5;
};
void()	floyd_attack1 =[$attack1, floyd_attack2] {floyd_fire(6);};
void()	floyd_attack2 =[$attack2, floyd_attack3] {ai_face();};
void()	floyd_attack3 =[$attack3, floyd_attack4] {ai_face();};
void()	floyd_attack4 =[$attack4, floyd_attack5] {floyd_fire(0);};
void()	floyd_attack5 =[$attack5, floyd_attack6] {ai_face();};
void()	floyd_attack6 =[$attack6, floyd_attack7] {ai_face();};
void()	floyd_attack7 =[$attack7, floyd_attack8] {floyd_fire(-6);};
void()	floyd_attack8 =[$attack8, floyd_attack9] {ai_face();};
void()	floyd_attack9 =[$attack9, floyd_run1] {ai_face();
	// Special double fire mode (used by soliders/enforcers)
	SUB_CheckRefire (floyd_attack1);
};

//======================================================================
// A = Short pain animation
void () floyd_paina1 = [$paina1, floyd_paina2] {};
void () floyd_paina2 = [$paina2, floyd_paina3] {};
void () floyd_paina3 = [$paina3, floyd_paina4] {};
void () floyd_paina4 = [$paina4, floyd_paina5] {};
void () floyd_paina5 = [$paina5, floyd_paina6] {};
void () floyd_paina6 = [$paina6, floyd_run1]   {};

//----------------------------------------------------------------------
// B = Long pain animation
void () floyd_painb1 =  [$painb1,  floyd_painb2]  {};
void () floyd_painb2 =  [$painb2,  floyd_painb3]  {};
void () floyd_painb3 =  [$painb3,  floyd_painb4]  {};
void () floyd_painb4 =  [$painb4,  floyd_painb5]  {};
void () floyd_painb5 =  [$painb5,  floyd_painb6]  {};
void () floyd_painb6 =  [$painb6,  floyd_painb7]  {};
void () floyd_painb7 =  [$painb7,  floyd_painb8]  {};
void () floyd_painb8 =  [$painb8,  floyd_painb9]  {};
void () floyd_painb9 =  [$painb9,  floyd_painb10] {};
void () floyd_painb10 = [$painb10,  floyd_run1]   {};

//----------------------------------------------------------------------
// C = Long stumble animation
void () floyd_painc1 =  [$painc1,  floyd_painc2]  {};
void () floyd_painc2 =  [$painc2,  floyd_painc3]  {};
void () floyd_painc3 =  [$painc3,  floyd_painc4]  {};
void () floyd_painc4 =  [$painc4,  floyd_painc5]  {};
void () floyd_painc5 =  [$painc5,  floyd_painc6]  {};
void () floyd_painc6 =  [$painc6,  floyd_painc7]  {};
void () floyd_painc7 =  [$painc7,  floyd_painc8]  {ai_painforward(1.25);};
void () floyd_painc8 =  [$painc8,  floyd_painc9]  {ai_painforward(1.25);};
void () floyd_painc9 =  [$painc9,  floyd_painc10] {ai_painforward(1.25);};
void () floyd_painc10 = [$painc10, floyd_painc11] {ai_painforward(1.25);};
void () floyd_painc11 = [$painc11, floyd_painc12] {ai_painforward(1.25);};
void () floyd_painc12 = [$painc12, floyd_painc13] {ai_painforward(1.25);};
void () floyd_painc13 = [$painc13, floyd_painc14] {ai_painforward(1.25);};
void () floyd_painc14 = [$painc14, floyd_run1]    {ai_painforward(1.25);};

//----------------------------------------------------------------------
void(entity inflictor, entity attacker, float damage) floyd_pain =
{
	// Check all pain conditions and set up what to do next
	monster_pain_check(attacker, damage);

	// Any pain animation/sound required?
	if (self.pain_check > 0) {
		sound (self, CHAN_VOICE, self.pain_sound, 1, ATTN_NORM);

		// Rolling around on floor?
		if (self.spawnflags & MON_FLOYDROLL) return;
		
		// No pain animation for first hit
		if (self.meleeattack) { 
			self.meleeattack = FALSE;
			self.pain_finished = time + 1;
		}
		else {
			// Only do pain animation if required
			if (self.pain_check == 1 || self.pain_check == 2) {
				// Find out facing direction
				self.lip = anglemod(self.angles_y - self.ideal_yaw);
				//lurch forward if hit in the back
				if (self.lip > 90 && self.lip < 270) {
					floyd_painc1 ();
					self.pain_finished = time + 2;
				}
				else if (random() < 0.4) {
					floyd_paina1 ();
					self.pain_finished = time + 1;
				}
				else {
					floyd_painb1 ();
					self.pain_finished = time + 2;
				}
			}
		}
	}
};

//======================================================================
void() floyd_explode =
{
	// no more FLOYD!
	entity_hide (self);
	// Make sure gibs go flying up
	self.max_health = MON_GIBFOUNTAIN;
	self.health = -100;

	// ID style explosion
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	T_RadiusDamage (self, self, self.death_dmg, world, DAMAGEALL);
	
	// Sprite + Dust
	SpawnExplosion(EXPLODE_BIG, self.origin, self.death_sound2);
	SpawnProjectileSmoke(self.origin, 200, 250, 100);
	SpawnProjectileSmoke(self.origin, 200, 250, 100);

	// Only throw head if a quick gib death
	if (self.gibbed) ThrowGib(25, 1);
	
	// Metal and custom body parts
	self.gibtype = GIBTYPE_METAL;
	ThrowGib(11, 2 + rint(random()*2));
	ThrowGib(12, 4 + rint(random()*2));
	ThrowGib(13, 4 + rint(random()*2));
};

//----------------------------------------------------------------------
//skip $death1, which is the idle frame
void() floyd_death2 = [ $death2, floyd_death3 ] {ai_painforward(-3.33);};
void() floyd_death3 = [ $death3, floyd_death4 ] {ai_painforward(-3.34);};
void() floyd_death4 = [ $death4, floyd_death5 ] {ai_painforward(-3.33);};
void() floyd_death5 = [ $death5, floyd_death6 ] {ai_painforward(-5);};
void() floyd_death6 = [ $death6, floyd_death7 ] {ai_painforward(-5);};
void() floyd_death7 = [ $death7, floyd_death8 ] {ai_painforward(-8);};
void() floyd_death8 = [ $death8, floyd_death9 ] {ai_painforward(-8);};
void() floyd_death9 = [ $death9, floyd_death10 ] {ai_painforward(-8);};
void() floyd_death10 = [ $death10, floyd_death11 ] {ai_painforward(-8);};
void() floyd_death11 = [ $death11, floyd_death12 ] {};
void() floyd_death12 = [ $death12, floyd_death13 ] {};
void() floyd_death13 = [ $death13, floyd_death14 ] {};
void() floyd_death14 = [ $death14, floyd_death15 ] {};
void() floyd_death15 = [ $death15, floyd_explode ] {};

//----------------------------------------------------------------------
void() floyd_die =
{
	// Pre-check routine to tidy up extra entities
	monster_death_precheck();

	// Check for rolling on floor first
	if (self.spawnflags & MON_FLOYDROLL) floyd_explode();
	else {
		// Check for a quick gib death
		if ( self.health < -35 || self.gibondeath) self.gibbed = TRUE;
		
		// regular death (no head model)
		if (!self.gibbed) {
			sound (self, CHAN_VOICE, self.death_sound, 1, ATTN_NORM);
			floyd_death2 ();
		}
		// Quick explosion with head model
		else floyd_explode();
	}
};

//======================================================================
// Floyd ASLEEP functions
//======================================================================
void() floyd_default_state =
{
	// Setup default pain parameters
	self.pain_timeout = 1.5;
	self.pain_flinch = 150;

	// Default AI function/states
	self.th_stand = floyd_stand1;
	self.th_walk = floyd_walk1;
	self.th_run = floyd_run1;
	self.th_missile = floyd_ready1;
	self.th_pain = floyd_pain;
};

//----------------------------------------------------------------------
void() floyd_awake =
{
	// Cannot be woken up if dead
	if (self.health < 1) return;
	
	floyd_default_state();	// Restore default monster states
	self.skin = 0;			// Default (light on) skin
	self.think = self.th_stand;		// Default is idle/stand
	self.nextthink = time + 0.1;	// Next frame
	monster_targets();		// Find target (angry/path_corner)
};

//----------------------------------------------------------------------
void(entity inflictor, entity attacker, float damage) floyd_painawake =
{
	// Cannot be attacked by other robots or woken up if dead
	if (attacker.classgroup == CG_ROBOT) return;
	if (self.health < 1) return;
	
	floyd_default_state();	// Restore default monster states
	self.skin = 0;			// Default (light on) skin
	self.enemy = attacker;	// Attack the inflictor of pain
	self.think = FoundTarget;		// Find the pain attacker
	self.nextthink = time + 0.1;	// Next frame
	self.pain_finished = time + 2;	// no more pain for a while
};

//======================================================================
// Floyd ROLLING functions
//======================================================================
void () floyd_roll = {
	self.frame = self.frame + 1;
	
	if (self.frame > $death15 || self.frame < $death10) {
		self.frame = $death10;
		monster_idle_sound();
	}
	
	self.think = floyd_roll;
	self.nextthink = time + 0.1;
};

//----------------------------------------------------------------------
// This chunk of code is straight from rubicon2 MOD (unchanged)
// Personally I would have created a maximum bbox radius of the floyd model
// but this system is much better and unfortunately more complex (maths)
//----------------------------------------------------------------------
vector (vector testmoos, float testang, float testradius, float minmax) test_moos_angle =
{
	local vector testangs, floyd_moos;
	floyd_moos = testmoos;
	testangs = '0 0 0';
	testangs_y = testang;
	makevectors(testangs); 
	v_forward_y = v_forward_y * testradius;
	v_forward_x = v_forward_x * testradius;
	if (minmax == 1) //1 for maxes, 0 for mins
	{
		if (v_forward_y > floyd_moos_y) floyd_moos_y = v_forward_y;
		if (v_forward_x > floyd_moos_x) floyd_moos_x = v_forward_x;
	} else {
		if (v_forward_y < floyd_moos_y) floyd_moos_y = v_forward_y;
		if (v_forward_x < floyd_moos_x) floyd_moos_x = v_forward_x;
	}
	return floyd_moos;
};

//----------------------------------------------------------------------
vector (entity floyd) get_floyd_mins =
{
	local float feetyaw;
	local vector floyd_mins;
	
	floyd_mins = '0 0 -24';
	feetyaw = anglemod(floyd.angles_y);

	// Foot / Shoulder / Head / Shoulder / Foot
	floyd_mins = test_moos_angle(floyd_mins, feetyaw + 17.4, 38, 0);		//foot
	floyd_mins = test_moos_angle(floyd_mins, feetyaw + 180 - 17.4, 38, 0);	//shoulder
	floyd_mins = test_moos_angle(floyd_mins, feetyaw + 180, 40, 0);			//head
	floyd_mins = test_moos_angle(floyd_mins, feetyaw + 180 + 17.4, 38, 0);	//shoulder
	floyd_mins = test_moos_angle(floyd_mins, feetyaw + 360 - 17.4, 38, 0);	//foot

	return floyd_mins;
};

//----------------------------------------------------------------------
vector (entity floyd) get_floyd_maxs =
{
	local float feetyaw;
	local vector floyd_maxs;
	
	floyd_maxs = '0 0 12';
	feetyaw = anglemod(floyd.angles_y);

	// Foot / Shoulder / Head / Shoulder / Foot
	floyd_maxs = test_moos_angle(floyd_maxs, feetyaw + 17.4, 38, 1); 		//foot
	floyd_maxs = test_moos_angle(floyd_maxs, feetyaw + 180 - 17.4, 38, 1);	//shoulder
	floyd_maxs = test_moos_angle(floyd_maxs, feetyaw + 180, 40, 1); 		//head
	floyd_maxs = test_moos_angle(floyd_maxs, feetyaw + 180 + 17.4, 38, 1);	//shoulder
	floyd_maxs = test_moos_angle(floyd_maxs, feetyaw + 360 - 17.4, 38, 1);	//foot
	
	return floyd_maxs;
};

/*======================================================================
QUAKED monster_floyd (1 0 0) (-24 -24 -24) (24 24 64) Ambush
======================================================================*/
void() monster_floyd =
{
	// Check all spawn exceptions (monsters.qc)
	if (monster_checkspawn() == TRUE) return;

	// Let the mapper override the mdl keys so that they can
	// create different skin versions, a rusty floyd anyone?
	if (self.mdl == "") self.mdl = "progs/mon_floyd.mdl";			// Dusty the bin
	if (self.headmdl == "") self.headmdl = "progs/h_floyd.mdl";		// Top part
	if (self.gib1mdl == "") self.gib1mdl = "progs/gib_floyd1.mdl";	// wreckage.mdl
	if (self.gib2mdl == "") self.gib2mdl = "progs/gib_metal1.mdl";	// Breakable metal
	if (self.gib3mdl == "") self.gib3mdl = "progs/gib_metal3.mdl";	// Breakable metal

	precache_model (self.mdl);
	precache_model (self.headmdl);
	precache_model (self.gib1mdl);		// Large chunk of floyd metal
	precache_model (self.gib2mdl);		// Generic metal1_2
	precache_model (self.gib3mdl);		// Generic metal1_2
	
	self.idle_sound = "floyd/idle.wav";
	precache_sound (self.idle_sound);

	// Extra load/fire sounds
	precache_model (MODEL_PROJ_LASERBLUE);
	precache_sound("floyd/fire.wav");
	precache_sound (SOUND_PLASMA_FIRE);
	precache_sound (SOUND_PLASMA_HIT);

	self.death_sound = "floyd/death.wav";
	self.death_sound2 = "seeker/explode_major.wav";
	precache_sound (self.death_sound);
	precache_sound (self.death_sound2);
	self.pain_sound = "floyd/pain.wav";
	precache_sound (self.pain_sound);
	
	self.sight_sound = "floyd/sight.wav";
	precache_sound (self.sight_sound);

	self.solid = SOLID_NOT;				// No interaction with world
	self.movetype = MOVETYPE_NONE;		// Static item, no movement
	if (self.bboxtype < 1) self.bboxtype = BBOX_XTALL;
	// Half health for rolling floyd
	if (self.health < 1) {
		if (self.spawnflags & MON_FLOYDROLL) self.health = 75;
		else self.health = 175;
	}
	self.gibhealth = MON_NEVERGIB;		// Special explosion death
	self.gibbed = FALSE;
	self.steptype = FS_TYPELARGE;		// Heavy robot feet
	self.pain_longanim = FALSE;			// cannot be chopped with shadow axe
	if (self.death_dmg < 1) self.death_dmg = DAMAGE_FLOYD;
	self.blockudeath = TRUE;			// no humanoid death sound
	self.poisonous = FALSE;				// Robots are not poisonous
	self.deathstring = " was made obsolete by an Automaton\n";
	self.no_liquiddmg = TRUE;			// Immune to slime/lava
	self.meleeattack = TRUE;			// Always short pain first
	self.attack_offset = '24 0 30';		// Laser offset
	self.frame = 1;						// Frame 0 is special skin version

	// Always reset Ammo Resistance to be consistent
	self.resist_shells = self.resist_nails = 0;
	self.resist_rockets = self.resist_cells = 0;
	
	self.th_checkattack = FloydCheckAttack;
	self.th_die = floyd_die;

	self.classtype = CT_MONFLOYD;
	self.classgroup = CG_ROBOT;
	self.classmove = MON_MOVEWALK;
	
	// Rolling mode (lower HP) waiting for pain/death
	if (self.spawnflags & MON_FLOYDROLL) {
		// Setting the angle key in the editor to UP/DOWN = random rotation	
		if (self.angles_y < 0) self.angles_y = rint(random()*359);
		// Work out bounding box based on rotation angle
		setsize(self, get_floyd_mins(self), get_floyd_maxs(self));
		// Save bounding box for later
		self.bbmins = self.mins; self.bbmaxs = self.maxs;
		self.bboxtype = BBOX_CUSTOM;	// bbox override
		self.classmove = MON_MOVEFLY;	// No drop to floor
		// Setup AI state functions (rolling)
		self.th_stand = floyd_roll;
		self.th_walk = floyd_roll;
		self.th_run = floyd_roll;
		self.th_pain = floyd_pain;
		self.think1 = floyd_roll;
	}
	// Standby/Sleep mode (light off) waiting for trigger/pain
	else if (self.spawnflags & MON_FLOYDASLEEP) {
		self.th_stand = floyd_sleep;
		self.th_walk = floyd_sleep;
		self.th_run = floyd_sleep;
		self.th_missile = floyd_sleep;
		self.th_pain = floyd_painawake;
		self.think1 = floyd_awake;
		self.pain_finished = 0;		// Always wakeup on any pain
		self.pain_timeout = -1;		// Pain finished is never set
		self.pain_flinch = -100;	// Projectile shotguns are tricky
		self.exactskin = 1;			// Lights off Skin
	}
	else floyd_default_state();
	
	monster_start();
};
