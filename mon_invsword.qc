/*====================================================================
SWORD
======================================================================*/
$cd /qwork/xpack/models/sword
$origin 0 0 24
$base base
$skin badass3

// Upright
$frame stand1

// Running with sword out (stab action)
$frame run1 run2 run3 run4 run5 run6 run7 run8

// Overhead smash attack
$frame melee1 melee2 melee3 melee4 melee5 melee6 melee7 melee8
$frame melee9 melee10

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9 deathb10 deathb11

float SWORD_STAND = 1;
float SWORD_WALK = 5;
float SWORD_RUN = 10;

//============================================================================
void() invsword_sword_sound =
{
	self.lip = random();
	if (self.lip < 0.25) sound (self, CHAN_WEAPON, "weapons/sword1a.wav", 1, ATTN_NORM);
	else if (self.lip < 0.5) sound (self, CHAN_WEAPON, "weapons/sword2a.wav", 1, ATTN_NORM);
	else if (self.lip < 0.75) sound (self, CHAN_WEAPON, "weapons/sword1b.wav", 1, ATTN_NORM);
	else sound (self, CHAN_WEAPON, "weapons/sword2b.wav", 1, ATTN_NORM);
};

//======================================================================
void() invsword_stand1 = [ $stand1, invsword_stand1] {ai_stand();};
void() invsword_stand = { self.state = SWORD_STAND; invsword_stand1(); };

//======================================================================
// Walk and run use the same animations, but with different move speeds
// Model has no walk like animation (great shame)
void() invsword_runframe =
{
	// Dead swords are dead!
	if (self.health < 1) return;
	
	// Pain Animation unblocked
	self.attack_timer = FALSE;
	// No more delays on wakeup
	self.delay = 0;

	// Keep looping
	self.nextthink = time + 0.1;
	self.think = invsword_runframe;

	// animation block events
	if (self.walkframe == 0) invsword_sword_sound();
	if (self.walkframe == 4 && self.state == SWORD_RUN) 
		invsword_sword_sound();

	// Update frame and move forward
	self.frame = $run1 + self.walkframe;
	self.walkframe = self.walkframe + 1;
	// Finished animation set?
	if (self.walkframe > 7) self.walkframe = 0;
	
	// Walk/Run
	if (self.state == SWORD_WALK) ai_walk(7);
	else ai_run(14);
};

//----------------------------------------------------------------------
void() invsword_walk =  { 
	self.walkframe = 0; self.state = SWORD_WALK;
	invsword_runframe();
};

//----------------------------------------------------------------------
void() invsword_run =  { 
	self.walkframe = 0; self.state = SWORD_RUN;
	// Any wakeup delay?
	if (self.delay == 0) invsword_runframe();
	else {
		self.think = invsword_runframe;
		self.nextthink = time + self.delay;
	}
};

//----------------------------------------------------------------------
// MELEE attack - overhead swing
//----------------------------------------------------------------------
void() invsword_atk1 =[ $melee1, invsword_atk2] {
	invsword_sword_sound(); ai_charge(14);};
void() invsword_atk2 =[ $melee2, invsword_atk3] {ai_charge(14);};
void() invsword_atk3 =[ $melee3, invsword_atk4] {ai_charge(14);};
void() invsword_atk4 =[ $melee4, invsword_atk5] {ai_charge(14);};
void() invsword_atk5 =[ $melee5, invsword_atk6] {
	invsword_sword_sound(); ai_melee();};
void() invsword_atk6 =[ $melee6, invsword_atk7] {ai_melee();};
void() invsword_atk7 =[ $melee7, invsword_atk8] {ai_melee();};
void() invsword_atk8 =[ $melee8, invsword_atk9] {
	invsword_sword_sound(); ai_charge(14);};
void() invsword_atk9 =[ $melee9, invsword_atk10] {ai_charge(14);};
void() invsword_atk10 =[ $melee10,invsword_run] {ai_charge(14);};

//======================================================================
void() invsword_pain1 =[ $melee2, invsword_pain2] {ai_back(3);}
void() invsword_pain2 =[ $melee3, invsword_pain3] {ai_back(3);}
void() invsword_pain3 =[ $melee4, invsword_pain4] {ai_back(2);}
void() invsword_pain4 =[ $melee5, invsword_run] {}

//----------------------------------------------------------------------
void(entity inflictor, entity attacker, float damage) invsword_pain =
{
	// Block pain on first combat wakeup
	if (self.attack_timer == TRUE) return;
	// Check all pain conditions and set up what to do next
	monster_pain_check(attacker, damage);

	// Any pain animation/sound required?
	if (self.pain_check > 0) {
		sound (self, CHAN_VOICE, self.pain_sound, 1, ATTN_NORM);
		// Only do pain animation if required
		if (self.pain_check == 1 || self.pain_check == 2)
			invsword_pain1();
	}
};

//======================================================================
void() invsword_die1 =[ $death1, invsword_die2] {};
void() invsword_die2 =[ $death2, invsword_die3] {monster_check_gib();};
void() invsword_die3 =[ $death3, invsword_die4] {monster_check_gib();
	self.solid = SOLID_NOT;};
void() invsword_die4 =[ $death4, invsword_die5] {};
void() invsword_die5 =[ $death5, invsword_die6] {};
void() invsword_die6 =[ $death6, invsword_die7] {};
void() invsword_die7 =[ $death7, invsword_die8] {
	sound (self, CHAN_WEAPON, GIB_SOUND_METALB, 1, ATTN_NORM);};
void() invsword_die8 =[ $death8, invsword_die9] {};
void() invsword_die9 =[ $death9, invsword_die10] {monster_death_postcheck();};
void() invsword_die10 =[ $death10, invsword_die10] {monster_deadbody_check();};

//----------------------------------------------------------------------
void() invsword_dieb1 =[ $deathb1, invsword_dieb2] {};
void() invsword_dieb2 =[ $deathb2, invsword_dieb3] {monster_check_gib();};
void() invsword_dieb3 =[ $deathb3, invsword_dieb4] {monster_check_gib();
	self.solid = SOLID_NOT;};
void() invsword_dieb4 =[ $deathb4, invsword_dieb5] {};
void() invsword_dieb5 =[ $deathb5, invsword_dieb6] {};
void() invsword_dieb6 =[ $deathb6, invsword_dieb7] {};
void() invsword_dieb7 =[ $deathb7, invsword_dieb8] {
	sound (self, CHAN_WEAPON, GIB_SOUND_METALB, 1, ATTN_NORM);};
void() invsword_dieb8 =[ $deathb8, invsword_dieb9] {};
void() invsword_dieb9 =[ $deathb9, invsword_dieb10] {};
void() invsword_dieb10 =[ $deathb10, invsword_dieb11] {monster_death_postcheck();};
void() invsword_dieb11 =[ $deathb11, invsword_dieb11] {monster_deadbody_check();};

//----------------------------------------------------------------------
void() invsword_die =
{
	// Pre-check routine to tidy up extra entities
	monster_death_precheck();

	sound (self, CHAN_VOICE, self.death_sound, 1, ATTN_NORM);
	if (random() > 0.5) invsword_die1 ();	// Forward
	else invsword_dieb1 ();					// Backward
};

/*======================================================================
 QUAKED monster_sword (1 0 0) (-16 -16 -24) (16 16 40) Ambush
======================================================================*/
void() monster_sword =
{
	// Check all spawn exceptions (monsters.qc)
	if (monster_checkspawn() == TRUE) return;

	self.mdl = "progs/mon_sword.mdl";
	precache_model (self.mdl);
	
	self.gib1sound = GIB_IMPACT_METALA;
	if (random() < 0.5) self.gib2mdl = "";
	if (random() < 0.5) self.gib3mdl = "";

	self.idle_sound = SOUND_EMPTY;
	precache_sound (self.idle_sound);
	
	// precache sight, pain and death!
	self.sight_sound = "knight/ksight.wav";
	precache_sound (self.sight_sound);
	self.pain_sound = SOUND_IMP_METAL2;
	precache_sound (self.pain_sound);
	self.death_sound = SOUND_BRK_METAL;
	precache_sound (self.death_sound);

	// Dead impact sound for sword on ground
	precache_sound (GIB_SOUND_METALB);

	// New sword sweep/slash sounds
	precache_sound ("weapons/sword1a.wav");
	precache_sound ("weapons/sword1b.wav");
	precache_sound ("weapons/sword2a.wav");
	precache_sound ("weapons/sword2b.wav");
	
	self.solid = SOLID_NOT;				// No interaction with world
	self.movetype = MOVETYPE_NONE;		// Static item, no movement
	if (self.bboxtype < 1) self.bboxtype = BBOX_SHORT;
	if (self.health < 1) self.health = 75;
	self.gibhealth = MON_NEVERGIB;		// Cannot be gibbed by weapons
	self.gibbed = FALSE;				// Still in one peice
	self.pain_flinch = 30;				// Low pain threshold
	self.attack_timer = TRUE;			// Pain blocked on wakeup
	self.blockudeath = TRUE;			// no humanoid death sound
	self.pain_longanim = FALSE;			// No long stagger animation
	self.bleedcolour = MON_BCOLOR_WHITE;	// Grey dust
	self.steptype = FS_FLYING;			// Where's the tiny swordfeet!
	self.deathstring = " was slit open by a Phantom Swordsman\n";

	// Short delay before combat?
	if (self.delay <= 0) self.delay = 0.1;
	
	// Always reset Ammo Resistance to be consistent
	self.resist_shells = self.resist_nails = 0;
	self.resist_rockets = self.resist_cells = 0;
	
	self.th_stand = invsword_stand;		// Standing upright
	self.th_walk = invsword_walk;		// There is no walk
	self.th_run = invsword_run;			// Running
	self.th_melee = invsword_atk1;		// Sword attack
	self.th_pain = invsword_pain;		// No pain, just sound
	self.th_die = invsword_die;			// fall to floor
	
	self.classtype = CT_MONINVSWORD;
	self.classtype = CT_MONKNIGHT;
	self.classmove = MON_MOVEWALK;
	monster_start();	
};

