/*==============================================================================
Chthon
==============================================================================*/
$cd id1/models/Chthon
$origin 0 0 -15
$base base
$skin skin
$scale 5

$frame rise1 rise2 rise3 rise4 rise5 rise6 rise7 rise8 rise9 rise10
$frame rise11 rise12 rise13 rise14 rise15 rise16 rise17 

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8
$frame walk9 walk10 walk11 walk12 walk13 walk14 walk15
$frame walk16 walk17 walk18 walk19 walk20 walk21 walk22
$frame walk23 walk24 walk25 walk26 walk27 walk28 walk29 walk30 walk31

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9

$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8
$frame attack9 attack10 attack11 attack12 attack13 attack14 attack15
$frame attack16 attack17 attack18 attack19 attack20 attack21 attack22
$frame attack23

$frame shocka1 shocka2 shocka3 shocka4 shocka5 shocka6 shocka7 shocka8
$frame shocka9 shocka10 

$frame shockb1 shockb2 shockb3 shockb4 shockb5 shockb6

$frame shockc1 shockc2 shockc3 shockc4 shockc5 shockc6 shockc7 shockc8 
$frame shockc9 shockc10

entity	le1, le2;
float	lightning_end;

//===========================================================================
void() boss_tracking =
{
	// Find a player
	if (!self.enemy) {
		self.enemy = find(world, classname, "player");
		if (!self.enemy) self.enemy = world;
	}
	
	// Check for any no combat conditions
	if (self.enemy.flags & FL_NOTARGET) self.enemy = world;
	else if (self.enemy.items & IT_INVISIBILITY) self.enemy = world;
	else if (intermission_running > 0) self.enemy = world;
	else if (self.enemy.health < 1) self.enemy = world;
	if (self.enemy) self.th_missile();
};

//----------------------------------------------------------------------
void() boss_idle1	=[	$walk1, boss_idle2 ] {boss_tracking();};
void() boss_idle2	=[	$walk2, boss_idle3 ] {};
void() boss_idle3	=[	$walk3, boss_idle4 ] {};
void() boss_idle4	=[	$walk4, boss_idle5 ] {};
void() boss_idle5	=[	$walk5, boss_idle6 ] {};
void() boss_idle6	=[	$walk6, boss_idle7 ] {};
void() boss_idle7	=[	$walk7, boss_idle8 ] {};
void() boss_idle8	=[	$walk8, boss_idle9 ] {};
void() boss_idle9	=[	$walk9, boss_idle10 ] {};
void() boss_idle10	=[	$walk10, boss_idle11 ] {boss_tracking();};
void() boss_idle11	=[	$walk11, boss_idle12 ] {};
void() boss_idle12	=[	$walk12, boss_idle13 ] {};
void() boss_idle13	=[	$walk13, boss_idle14 ] {};
void() boss_idle14	=[	$walk14, boss_idle15 ] {};
void() boss_idle15	=[	$walk15, boss_idle16 ] {};
void() boss_idle16	=[	$walk16, boss_idle17 ] {};
void() boss_idle17	=[	$walk17, boss_idle18 ] {};
void() boss_idle18	=[	$walk18, boss_idle19 ] {};
void() boss_idle19	=[	$walk19, boss_idle20 ] {};
void() boss_idle20	=[	$walk20, boss_idle21 ] {};
void() boss_idle21	=[	$walk21, boss_idle22 ] {boss_tracking();};
void() boss_idle22	=[	$walk22, boss_idle23 ] {};
void() boss_idle23	=[	$walk23, boss_idle24 ] {};
void() boss_idle24	=[	$walk24, boss_idle25 ] {};
void() boss_idle25	=[	$walk25, boss_idle26 ] {};
void() boss_idle26	=[	$walk26, boss_idle27 ] {};
void() boss_idle27	=[	$walk27, boss_idle28 ] {};
void() boss_idle28	=[	$walk28, boss_idle29 ] {};
void() boss_idle29	=[	$walk29, boss_idle30 ] {};
void() boss_idle30	=[	$walk30, boss_idle31 ] {};
void() boss_idle31	=[	$walk31, boss_idle1 ] {boss_tracking();};

//===========================================================================
void(vector orgofs) boss_missile =
{
	local vector offang, org, vec, dir, mdest, avel;
	local float projlen;

	// No enemy, player dead or intermission?
	if (!self.enemy || self.enemy.health < 1 || intermission_running > 0) {
		self.th_stand();
		return;
	}
	
	sound (self, CHAN_WEAPON, "boss1/throw.wav", 1, ATTN_NORM);
	offang = vectoangles (self.enemy.origin - self.origin);	
	makevectors (offang);

	org = self.origin + orgofs_x*v_forward + orgofs_y*v_right + orgofs_z*'0 0 1';
	
	// Skill level adjustment (easy=250, normal=300, hard=350, nm=400)
	self.attack_speed = SPEED_LAVABALL + (skill*SPEED_LAVASKILL);
	
	// Lead the missile on hard mode (This formula is not perfect) 
	// There are plenty of missiles that go in strange directions, 
	// especially if the player strafes a lot from side to side.
	if (skill > SKILL_NORMAL) {
		projlen = vlen(self.enemy.origin - org) / self.attack_speed;
		vec = self.enemy.velocity;
		vec_z = 0;
		mdest = self.enemy.origin + projlen * vec;		
	}
	else mdest = self.enemy.origin;
	
	dir = normalize (mdest - org);
	avel = vecrand(100,200,FALSE);
	Launch_Missile (org, dir, avel, CT_PROJ_LAVA, self.attack_speed);
};

//----------------------------------------------------------------------
void() boss_face =
{
	// Find a player
	if (!self.enemy) {
		self.enemy = find(world, classname, "player");
		if (!self.enemy) self.enemy = world;
	}
	
	// Check for any no combat conditions
	if (self.enemy.flags & FL_NOTARGET) self.enemy = world;
	else if (self.enemy.items & IT_INVISIBILITY) self.enemy = world;
	else if (intermission_running > 0) self.enemy = world;
	else if (self.enemy.health < 1) self.enemy = world;
	if (self.enemy) ai_face();
};

//----------------------------------------------------------------------
void() boss_missile1	=[	$attack1, boss_missile2 ] {boss_face();};
void() boss_missile2	=[	$attack2, boss_missile3 ] {boss_face();};
void() boss_missile3	=[	$attack3, boss_missile4 ] {boss_face();};
void() boss_missile4	=[	$attack4, boss_missile5 ] {boss_face();};
void() boss_missile5	=[	$attack5, boss_missile6 ] {boss_face();};
void() boss_missile6	=[	$attack6, boss_missile7 ] {boss_face();};
void() boss_missile7	=[	$attack7, boss_missile8 ] {boss_face();};
void() boss_missile8	=[	$attack8, boss_missile9 ] {boss_face();};
void() boss_missile9	=[	$attack9, boss_missile10 ] {boss_missile('100 100 200');};
void() boss_missile10	=[	$attack10, boss_missile11 ] {boss_face();};
void() boss_missile11	=[	$attack11, boss_missile12 ] {boss_face();};
void() boss_missile12	=[	$attack12, boss_missile13 ] {boss_face();};
void() boss_missile13	=[	$attack13, boss_missile14 ] {boss_face();};
void() boss_missile14	=[	$attack14, boss_missile15 ] {boss_face();};
void() boss_missile15	=[	$attack15, boss_missile16 ] {boss_face();};
void() boss_missile16	=[	$attack16, boss_missile17 ] {boss_face();};
void() boss_missile17	=[	$attack17, boss_missile18 ] {boss_face();};
void() boss_missile18	=[	$attack18, boss_missile19 ] {boss_face();};
void() boss_missile19	=[	$attack19, boss_missile20 ] {boss_face();};
void() boss_missile20	=[	$attack20, boss_missile21 ] {boss_missile('100 -100 200');};
void() boss_missile21	=[	$attack21, boss_missile22 ] {boss_face();};
void() boss_missile22	=[	$attack22, boss_missile23 ] {boss_face();};
void() boss_missile23	=[	$attack23, boss_missile1 ] {boss_face();};

//----------------------------------------------------------------------
void() boss_rise1	=[	$rise1, boss_rise2 ] {
	sound (self, CHAN_WEAPON, "boss1/out1.wav", 1, ATTN_NORM);};
void() boss_rise2	=[	$rise2, boss_rise3 ] {
	sound (self, CHAN_VOICE, "boss1/sight1.wav", 1, ATTN_NORM);};
void() boss_rise3	=[	$rise3, boss_rise4 ] {};
void() boss_rise4	=[	$rise4, boss_rise5 ] {};
void() boss_rise5	=[	$rise5, boss_rise6 ] {};
void() boss_rise6	=[	$rise6, boss_rise7 ] {};
void() boss_rise7	=[	$rise7, boss_rise8 ] {};
void() boss_rise8	=[	$rise8, boss_rise9 ] {};
void() boss_rise9	=[	$rise9, boss_rise10 ] {};
void() boss_rise10	=[	$rise10, boss_rise11 ] {};
void() boss_rise11	=[	$rise11, boss_rise12 ] {};
void() boss_rise12	=[	$rise12, boss_rise13 ] {};
void() boss_rise13	=[	$rise13, boss_rise14 ] {};
void() boss_rise14	=[	$rise14, boss_rise15 ] {};
void() boss_rise15	=[	$rise15, boss_rise16 ] {};
void() boss_rise16	=[	$rise16, boss_rise17 ] {};
void() boss_rise17	=[	$rise17, boss_missile1 ] {};

//----------------------------------------------------------------------
void() boss_awake =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.takedamage = DAMAGE_NO;
	self.velocity = '0 0 0';
	self.flags = FL_MONSTER;	// Reset flag (no user settings)

	// Some map hacks use this function as an entry point
	// Double check model/bounding box is setup correctly
	if (self.mdl == "") {
		self.mdl = "progs/mon_boss.mdl";
		self.bbmins = '-128 -128 -24';
		self.bbmaxs = '128 128 256';
	}
	setmodel(self, self.mdl);					// Setup model
	setsize (self, self.bbmins, self.bbmaxs);	// Restore BB size

	if (skill == SKILL_EASY) self.health = 1;
	else self.health = 3;
	self.enemy = activator;

	// DP particle spark and smoke effect to Chthon, originally done by Seven
	if (ext_dppart) self.traileffectnum = particleeffectnum("TR_BOSSCHTHON");
	
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LAVASPLASH);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	self.yaw_speed = 20;
	boss_rise1 ();
};

//===========================================================================
void() boss_shocka1 =[	$shocka1, boss_shocka2 ] {};
void() boss_shocka2 =[	$shocka2, boss_shocka3 ] {};
void() boss_shocka3 =[	$shocka3, boss_shocka4 ] {};
void() boss_shocka4 =[	$shocka4, boss_shocka5 ] {};
void() boss_shocka5 =[	$shocka5, boss_shocka6 ] {};
void() boss_shocka6 =[	$shocka6, boss_shocka7 ] {};
void() boss_shocka7 =[	$shocka7, boss_shocka8 ] {};
void() boss_shocka8 =[	$shocka8, boss_shocka9 ] {};
void() boss_shocka9 =[	$shocka9, boss_shocka10 ] {};
void() boss_shocka10 =[	$shocka10, boss_missile1 ] {};

//----------------------------------------------------------------------
void() boss_shockb1 =[	$shockb1, boss_shockb2 ] {};
void() boss_shockb2 =[	$shockb2, boss_shockb3 ] {};
void() boss_shockb3 =[	$shockb3, boss_shockb4 ] {};
void() boss_shockb4 =[	$shockb4, boss_shockb5 ] {};
void() boss_shockb5 =[	$shockb5, boss_shockb6 ] {};
void() boss_shockb6 =[	$shockb6, boss_shockb7 ] {};
void() boss_shockb7 =[	$shockb1, boss_shockb8 ] {};
void() boss_shockb8 =[	$shockb2, boss_shockb9 ] {};
void() boss_shockb9 =[	$shockb3, boss_shockb10 ] {};
void() boss_shockb10 =[	$shockb4, boss_missile1 ] {};

//----------------------------------------------------------------------
void() boss_shockc1 =[	$shockc1, boss_shockc2 ] {};
void() boss_shockc2 =[	$shockc2, boss_shockc3 ] {};
void() boss_shockc3 =[	$shockc3, boss_shockc4 ] {};
void() boss_shockc4 =[	$shockc4, boss_shockc5 ] {};
void() boss_shockc5 =[	$shockc5, boss_shockc6 ] {};
void() boss_shockc6 =[	$shockc6, boss_shockc7 ] {};
void() boss_shockc7 =[	$shockc7, boss_shockc8 ] {};
void() boss_shockc8 =[	$shockc8, boss_shockc9 ] {};
void() boss_shockc9 =[	$shockc9, boss_shockc10 ] {};
void() boss_shockc10 =[	$shockc10, boss_death1 ] {};

//----------------------------------------------------------------------
void() lightning_fire =
{
	local vector p1, p2;
	
	if (time >= lightning_end) {	// done here, put the terminals back up
		self = le1;
		func_door_go_down ();
		self = le2;
		func_door_go_down ();
		return;
	}
	
	p1 = (le1.mins + le1.maxs) * 0.5;
	p1_z = le1.absmin_z - 16;
	
	p2 = (le2.mins + le2.maxs) * 0.5;
	p2_z = le2.absmin_z - 16;
	
	// compensate for length of bolt
	p2 = p2 - normalize(p2-p1)*100;

	self.nextthink = time + 0.1;
	self.think = lightning_fire;

	WriteByte (MSG_ALL, SVC_TEMPENTITY);
	WriteByte (MSG_ALL, TE_LIGHTNING3);
	WriteEntity (MSG_ALL, world);
	WriteCoord (MSG_ALL, p1_x);
	WriteCoord (MSG_ALL, p1_y);
	WriteCoord (MSG_ALL, p1_z);
	WriteCoord (MSG_ALL, p2_x);
	WriteCoord (MSG_ALL, p2_y);
	WriteCoord (MSG_ALL, p2_z);
};

//----------------------------------------------------------------------
void() lightning_use =
{
	if (lightning_end >= time + 1) return;

	le1 = find( world, target, "lightning");
	le2 = find( le1, target, "lightning");
	if (!le1 || !le2) {
		dprint ("\b[BOSS]\b missing lightning targets\n");
		return;
	}
	
	// Check for lightning block alignment
	if (
	 (le1.state != STATE_TOP && le1.state != STATE_BOTTOM)
	|| (le2.state != STATE_TOP && le2.state != STATE_BOTTOM)
	|| (le1.state != le2.state) )
	{ return; }

	// don't let the electrodes go back up until the bolt is done
	le1.nextthink = -1;
	le2.nextthink = -1;
	lightning_end = time + 1;

	sound (self, CHAN_VOICE, "misc/power.wav", 1, ATTN_NORM);
	lightning_fire ();		

	// advance the boss pain if down
	self = find (world, classname, "monster_boss");
	if (!self) return;
	self.enemy = activator;
	if (le1.state == STATE_TOP && self.health > 0) {
		sound (self, CHAN_VOICE, "boss1/pain.wav", 1, ATTN_NORM);
		self.health = self.health - 1;
		if (self.health >= 2) boss_shocka1();
		else if (self.health == 1) boss_shockb1();
		else if (self.health == 0) boss_shockc1();
	}	
};

//===========================================================================
void() boss_death1 = [$death1, boss_death2] {
sound (self, CHAN_VOICE, "boss1/death.wav", 1, ATTN_NORM);};
void() boss_death2 = [$death2, boss_death3] {};
void() boss_death3 = [$death3, boss_death4] {};
void() boss_death4 = [$death4, boss_death5] {};
void() boss_death5 = [$death5, boss_death6] {};
void() boss_death6 = [$death6, boss_death7] {};
void() boss_death7 = [$death7, boss_death8] {};
void() boss_death8 = [$death8, boss_death9] {};
void() boss_death9 = [$death9, boss_death10] {
	sound (self, CHAN_BODY, "boss1/out1.wav", 1, ATTN_NORM);
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LAVASPLASH);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
};
// This is a popular entry point for map hacking
// Be careful removing or changing this function name
void() boss_death10 = [$death9, boss_death10] {
	killed_monsters = killed_monsters + 1;
	WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
	SUB_UseTargets ();
	remove (self);
};

/*======================================================================
 QUAKED monster_boss (1 0 0) (-128 -128 -24) (128 128 256)
======================================================================*/
void() monster_boss =
{
	if (deathmatch) { remove(self); return; }

	self.mdl = "progs/mon_boss.mdl";
	precache_model (self.mdl);
	precache_model (MODEL_PROJ_LAVA);

	precache_sound ("weapons/rocket1i.wav");
	precache_sound ("boss1/out1.wav");
	precache_sound ("misc/power.wav");
	precache_sound ("boss1/throw.wav");
	precache_sound ("boss1/pain.wav");
	precache_sound ("boss1/death.wav");

	self.sight_sound = "boss1/sight1.wav";
	precache_sound (self.sight_sound);

	self.solid = SOLID_NOT;				// No interaction with world
	self.movetype = MOVETYPE_NONE;		// Static item, no movement
	self.bbmins = '-128 -128 -24';		// has own entity setup
	self.bbmaxs = '128 128 256';
	self.health = 3;
	self.takedamage = DAMAGE_NO;
	self.classtype = CT_MONBOSS;
	self.classgroup = CG_BOSS;

	// Always reset Ammo Resistance to be consistent
	self.resist_shells = self.resist_nails = 0;
	self.resist_rockets = self.resist_cells = 0;

	self.th_stand = boss_idle1;
	self.th_walk = boss_idle1;
	self.th_run = boss_idle1;
	self.th_missile = boss_missile1;
	
	total_monsters = total_monsters + 1;
	self.use = boss_awake;
};

/*======================================================================
/*QUAKED event_lightning (0 1 1) (-16 -16 -16) (16 16 16) x
Just for boss level. Used for killing Cthon.
-------- KEYS --------
-------- SPAWNFLAGS --------
-------- NOTES --------
Just for boss level. Used for killing Cthon.
======================================================================*/
void() event_lightning =
{
	self.use = lightning_use;
};

/*======================================================================
/*QUAKED misc_teleporttrain (0 0.5 0.8) (-8 -8 -8) (8 8 8) x
This is used for the final boss ONLY
Flying ball needed to teleport kill Shub-Niggurath
-------- KEYS --------
-------- SPAWNFLAGS --------
-------- NOTES --------
This is used for the final boss ONLY
Flying ball needed to teleport kill Shub-Niggurath
Originallu used bmodel train functions, setup to work like
the shalrath homing missile

======================================================================*/
void() teleporttrain_next;
void() teleporttrain_target =
{
	local vector dir;

	if (self.target != "") {
		// Find next target entity
		self.enemy = find (world, targetname, self.target);
		if (self.enemy) {
			// Work out distance and angle to turn towards
			dir = normalize(self.enemy.origin - self.origin);
			self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
			self.velocity = dir * self.speed;
	
			// Shift target to next target in the entity chain
			self.target = self.enemy.target;
			self.nextthink = time + 0.1;
			self.think = teleporttrain_next;
			return;
		}
	}
	// No target or entity to follow, full stop
	self.velocity = '0 0 0';
	self.enemy = world;
};

//----------------------------------------------------------------------
void() teleporttrain_next =
{
	if (!self.enemy) return;

	// Work out how close to the next target (self.enemy)		
	self.t_length = vlen(self.enemy.origin - self.origin);
	if (self.t_length < 64) teleporttrain_target();
	else {
		// Keep checking
		self.nextthink = time + 0.1;
		self.think = teleporttrain_next;
	}		
};

//----------------------------------------------------------------------
void() misc_teleporttrain =
{	
	self.mdl = "progs/teleport.mdl";
	precache_model (self.mdl);

	self.solid = SOLID_TRIGGER;
	// Push movetype cannot rotate, fly can
	//	self.movetype = MOVETYPE_PUSH;
	self.movetype = MOVETYPE_FLY;
	self.use = teleporttrain_target;
	self.avelocity = vecrand(50,250,FALSE);

	setmodel (self, self.mdl);
	setsize (self, VEC_ORIGIN , VEC_ORIGIN);

	if (!self.speed) self.speed = 100;
	if (self.target == "") {
		spawn_marker(self.origin);
		remove(self);
	}
};
