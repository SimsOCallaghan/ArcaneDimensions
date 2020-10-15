/*======================================================================
 Tarbaby, spawn, blue blob! (mostly annoying ... troll monster)
========================================================================*/

$frame walk1 walk2 walk3 walk4  walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16 walk17 walk18 walk19
$frame walk20 walk21 walk22 walk23 walk24 walk25

$frame run1 run2 run3 run4 run5 run6  run7 run8 run9 run10 run11 run12 run13
$frame run14 run15 run16 run17 run18 run19 run20 run21 run22 run23
$frame run24 run25

$frame jump1 jump2 jump3 jump4 jump5 jump6

$frame fly1 fly2 fly3 fly4

$frame exp

// Return to death explosion
void() tbaby_finaldeath;

//======================================================================
// A small looped idle animation using walk
//======================================================================
void() tbaby_standframe =
{
	// Return to explosive death
	if (self.deadflag > DEAD_NO) { tbaby_finaldeath(); return; }
	
	// Keep looping
	if (self.walkframe == 4 || self.walkframe == 7)
		self.nextthink = 0.1 + random()*0.3;
	else self.nextthink = time + 0.1;
	self.think = tbaby_standframe;
	
	// Reverse the stand idle frames (0,1,2,3,4,3,2,1)
	if (self.walkframe < 5) self.frame = $walk1 + self.walkframe;
	else self.frame = $walk1 + (7-self.walkframe);
	self.walkframe = self.walkframe + 1;
	
	// Keep looping
	if (self.walkframe >= 8) self.walkframe = 0;
	ai_stand();
}
//----------------------------------------------------------------------
void() tbaby_stand1 = { self.walkframe = 0; tbaby_standframe(); }
// Can't find where this is being used, probably an old idea in id code
void() tbaby_hang1 =[$walk1, tbaby_hang1] {ai_stand();};

//======================================================================
// The classic slow turning/walk animation
//======================================================================
void() tbaby_walkframe =
{
	// Return to explosive death
	if (self.deadflag > DEAD_NO) { tbaby_finaldeath(); return; }
	
	// Keep looping
	self.nextthink = time + 0.1;
	self.think = tbaby_walkframe;
	// The famous tarbaby wakeup sound!
	if (self.walkframe == 0) monster_idle_sound();
	// Keep moving forward in animation
	self.frame = $walk1 + self.walkframe;
	self.walkframe = self.walkframe + 1;
	// Odd way to do walking
	if (self.walkframe < 11) ai_turn();
	else ai_walk(2);
	// Keep looking
	if (self.walkframe >= 25) self.walkframe = 0;
};
//----------------------------------------------------------------------
void() tbaby_walk1 = { self.walkframe = 0; tbaby_walkframe(); }

//======================================================================
// Running like a snail!
//======================================================================
void() tbaby_runframe = 
{
	// Return to explosive death
	if (self.deadflag > DEAD_NO) { tbaby_finaldeath(); return; }
	
	// Keep looping
	self.nextthink = time + 0.1;
	self.think = tbaby_runframe;
	// Keep moving forward in animation
	self.frame = $run1 + self.walkframe;
	self.walkframe = self.walkframe + 1;
	// Turns as much as moving forward!
	if (self.walkframe < 11) ai_face();
	else ai_run(2);
	// Keep looping
	if (self.walkframe >= 25) self.walkframe = 0;
};
//----------------------------------------------------------------------
void() tbaby_run1 = { self.walkframe = 0; tbaby_runframe(); }

//======================================================================
// The crazy jump functionality of spawns!
//======================================================================
void()	Tar_JumpTouch =
{
	local float ldmg;
	// Return to explosive death
	if (self.deadflag > DEAD_NO) { tbaby_finaldeath(); return; }
	ai_jumpbreakable(20);			// Damage any breakables

	if (other.takedamage && other.classname != self.classname) {
		if ( vlen(self.velocity) > 400 ) {
			ldmg = 10 + 10*random();
			// Can only poison the player
			if (other.flags & FL_CLIENT && self.poisonous) {
				// Check if player is posioned already?
				if (other.poisoned) T_Damage (other, self, self, ldmg * 0.25, DAMARMOR);
				// Make sure player is posioned
				else PoisonDeBuff(other);
			}
			// Everything else gets the usual tarbaby thump!
			else T_Damage (other, self, self, ldmg, DAMARMOR);
			sound (self, CHAN_WEAPON, "blob/hit1.wav", 1, ATTN_NORM);
		}
	}
	else sound (self, CHAN_WEAPON, "blob/land1.wav", 1, ATTN_NORM);

	// Is the tarbaby floating in the air?
	if (!checkbottom(self)) {
		// Is the tarbaby standing on something?		
		if (self.flags & FL_ONGROUND) {	
			self.touch = SUB_Null;
			self.think = self.th_run;
			self.movetype = MOVETYPE_STEP;
			self.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	if (self.spawnflags & MON_TARBYLESSJUMP) {
		// RRP - Ijed (reduce constant jumping around like id version)
		// Skill percentage Easy 0% = never jump, Nightmare 60% = good chance
		if (random() > skill / 5) self.think =  self.th_run;
		else self.think = self.th_jump;
	}
	// Original ID behaviour, constantly jump around like crazy
	else self.think = self.th_jump;
	self.nextthink = time + 0.1;
};

//----------------------------------------------------------------------
void() tbaby_fly1 =[$fly1, tbaby_fly2] {};
void() tbaby_fly2 =[$fly2, tbaby_fly3] {};
void() tbaby_fly3 =[$fly3, tbaby_fly4] {};
void() tbaby_fly4 =[$fly4, tbaby_fly1] { 
	self.cnt = self.cnt + 1;
	if (self.cnt == 4) self.th_jumpexit();
};

//----------------------------------------------------------------------
void() tbaby_jump1 =[$jump1, tbaby_jump2] {ai_face();};
void() tbaby_jump2 =[$jump2, tbaby_jump3] {ai_face();};
void() tbaby_jump3 =[$jump3, tbaby_jump4] {ai_face();};
void() tbaby_jump4 =[$jump4, tbaby_jump5] {ai_face();};
void() tbaby_jump5 =[$jump5, tbaby_jump6]
{	
	self.movetype = MOVETYPE_BOUNCE;
	self.touch = Tar_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 600 + '0 0 200';
	self.velocity_z = self.velocity_z + random()*150;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.cnt = 0;
};
void() tbaby_jump6 =[$jump6, tbaby_fly1] {};

//======================================================================
// There is no pain animation, just the chance of pain sounds
//======================================================================
void(entity inflictor, entity attacker, float damage) tbaby_pain =
{
	// Return to explosive death
	if (self.deadflag > DEAD_NO) { tbaby_finaldeath(); return; }
	// Check all pain conditions and set up what to do next
	monster_pain_check(attacker, damage);

	// Any pain animation/sound required?
	if (self.pain_check > 0) {
		sound (self, CHAN_VOICE, self.pain_sound, 1, ATTN_NORM);
	}
};

//======================================================================
// Death of the Tarbaby!
//======================================================================
void() tbaby_finished = { 
	// Can drop health packs! - randomizer
	if (self.healamount > 0) DropHealthpack();
	// Hide monster
	entity_hide(self);
};
//----------------------------------------------------------------------
// The final insult, exploding death!
//----------------------------------------------------------------------
void() tbaby_explode =
{
	self.deadflag = DEAD_FINISHED;
	// Tarbabies explode when they die
	T_RadiusDamage (self, self, self.death_dmg, world, DAMAGEALL);

	sound (self, CHAN_BODY, self.death_sound, 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TAREXPLOSION);	// Hard coded explosion
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	
	// Sprite explosion for Fitz engines
	// Check for DP particle system as visuals is done with TE_TAREXPLOSION
	if (!ext_dppart) SpawnExplosion(EXPLODE_SMALL, self.origin, SOUND_REXP3);
	else sound(self, CHAN_WEAPON, SOUND_REXP3, 1, ATTN_NORM);
	
	// Hide monster
	tbaby_finished();
};
//----------------------------------------------------------------------
// Waiting 1 frame to explode!
//----------------------------------------------------------------------
void() tbaby_die1 =
{ 
	self.deadflag = DEAD_EXPLODE;
	self.takedamage = DAMAGE_NO;
	self.frame = $exp;
	self.think = tbaby_explode;
	self.nextthink = time + 0.1;
};

//----------------------------------------------------------------------
// The tarbaby has 1 frame delay before exploding and it can cause
// problems with all the functions. This is to make sure everything
// returns to the part of the death journey of the spawn!
//----------------------------------------------------------------------
void() tbaby_finaldeath =
{
	// Check death states
	if (self.deadflag == DEAD_DEAD) tbaby_die1();
	else if (self.deadflag == DEAD_EXPLODE) tbaby_explode();
	// Finally Remove die
	else tbaby_finished();
};

//----------------------------------------------------------------------
// Classic death function
//----------------------------------------------------------------------
void() tbaby_die =
{
	// Pre-check routine to tidy up extra entities
	monster_death_precheck();
	// Start death explosion
	tbaby_finaldeath();
};

//======================================================================
//QUAKED monster_tarbaby (1 0 0) (-16 -16 -24) (16 16 24) Ambush x Lessjump
//======================================================================
void() monster_tarbaby =
{
	// Check for any random monster setups
	if (monster_checkrandomizer() == TRUE) return;
	// Check all spawn exceptions (monsters.qc)
	if (monster_checkspawn() == TRUE) return;

	self.mdl = "progs/mon_tarbaby.mdl";
	self.headmdl = string_null;
	precache_model (self.mdl);

	self.idle_sound = "blob/sight1.wav";
	precache_sound (self.idle_sound);
	self.sight_sound = self.idle_sound;
	self.pain_sound = self.idle_sound;

	self.death_sound = "blob/death1.wav";
	precache_sound (self.death_sound);
	
	precache_sound ("blob/hit1.wav");
	precache_sound ("blob/land1.wav");
	
	// The randomizer drops health packs on death
	if (self.healamount > 0) CacheHealthpacks();
	
	self.solid = SOLID_NOT;				// No interaction with world
	self.movetype = MOVETYPE_NONE;		// Static item, no movement
	if (self.bboxtype < 1) self.bboxtype = BBOX_TALL;
	if (self.health < 1) self.health = HP_MONTARBABY;
	self.gibhealth = MON_NEVERGIB;		// Cannot be gibbed by weapons
	self.gibbed = FALSE;
	self.pain_flinch = 20;
	self.deathstring = " was slimed by a Spawn\n";
	
	// Allow for extra functionality (death damage and poison)
	if (self.death_dmg < 1) self.death_dmg = DAMAGE_TARBABY;
	if (self.poisonous < 1) self.poisonous = FALSE;
	else { self.poisonous = TRUE; self.exactskin = 2; }

	// Always reset Ammo Resistance to be consistent
	self.resist_shells = self.resist_nails = 0;
	self.resist_rockets = self.resist_cells = 0;

	self.th_checkattack = SpawnCheckAttack;
	self.th_stand = tbaby_stand1;
	self.th_walk = tbaby_walk1;
	self.th_run = tbaby_run1;
	self.th_jump = tbaby_jump1;
	self.th_jumpexit = tbaby_jump5;
	self.th_melee = tbaby_jump1;
	self.th_pain = tbaby_pain;
	self.th_die = tbaby_die;
	
	self.classtype = CT_MONSPAWN;
	self.classgroup = CG_SPAWN;
	self.classmove = MON_MOVEWALK;
	
	// Delay spawn randomized tarbabies a couple of frame
	// To avoid telefrags issues of bad placement of HP packs
	if (self.randomized > 0) {
		self.nextthink = time + 0.1 + (random()*0.2);
		self.think = monster_start;
	}
	else monster_start();
};