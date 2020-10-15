/*==============================================================================
 Large mammoth of steel (model/animation by Benoit Stordeur)
 * QC was created for Bal's Hypnagogia project

  Interesting QC traits
  * Multiple attack versions (slow/fast linked to skill level)
  * Starts with a blue shield and waits for trigger event
  * Multiple models to get around 256 frame limits
  * Everything runs through a single loop for sound/particle effects
  * Has special tilt function to make firing projectiles feel better
  * New melee hazard (fire) attack using flame sprites and particles
  * Partial checks are done around pillars for better sight checks
  * Phase 2 rockets are using new seeking system (more fair steering)
  * Phase 3 laser attack has tracking and ricochet abilities
 
  Assets required to get this monster working in AD
    (model's in 'progs' and wav's in 'sound' sub directories)
  * mon_mammoth.mdl (Phase 1 and 2 model)
  * mon_mammoth_glow.mdl (Blue Shield Phase 1/2 only)
  * mon_mammothb.mdl (Phase 3 model)
  * mon_mammothd.mdl (Final broken piece)
  * gib_mammoth1.mdl (Front light panel)
  * gib_mammoth2.mdl (Corner chunk 1)
  * gib_mammoth3.mdl (Arm piece)
  * gib_mammoth4.mdl (Front light panel)
  * gib_mammoth5.mdl (Arm piece)
  * gib_mammoth6.mdl (Back panel)
  * gib_mammoth7.mdl (Feet jet)
  * gib_mammoth8.mdl (Grenade panel)
  * gib_mammoth9.mdl (Corner chunk 2)
  * gib_mammoth10.mdl (Back fan)

==============================================================================*/

//-----------------------------------------------------------------------
// MODEL 1 - body is complete, strong rocket/cell resistance
//-----------------------------------------------------------------------
// (000) Blank
$frame blank1

// (001-050) Wakeup sequence
$frame wake1 wake2 wake3 wake4 wake5 wake6 wake7 wake8
$frame wake9 wake10 wake11 wake12 wake13 wake14 wake15 wake16
$frame wake17 wake18 wake19 wake20 wake21 wake22 wake23 wake24
$frame wake25 wake26 wake27 wake28 wake29 wake30 wake31 wake32
$frame wake33 wake34 wake35 wake36 wake37 wake38 wake39 wake40
$frame wake41 wake42 wake43 wake44 wake45 wake46 wake47 wake48
$frame wake49 wake50

// (051-070) Phase 1 - Laser A
$frame laserA1 laserA2 laserA3 laserA4 laserA5 laserA6 laserA7 laserA8
$frame laserA9 laserA10 laserA11 laserA12 laserA13 laserA14 laserA15 laserA16
$frame laserA17 laserA18 laserA19 laserA20

// (071-090) Phase 1 - Laser B
$frame laserB1 laserB2 laserB3 laserB4 laserB5 laserB6 laserB7 laserB8
$frame laserB9 laserB10 laserB11 laserB12 laserB13 laserB14 laserB15 laserB16
$frame laserB17 laserB18 laserB19 laserB20

// (091-110) Phase 1 - Floor Dump
$frame dumpA1 dumpA2 dumpA3 dumpA4 dumpA5 dumpA6 dumpA7 dumpA8
$frame dumpA9 dumpA10 dumpA11 dumpA12 dumpA13 dumpA14 dumpA15 dumpA16
$frame dumpA17 dumpA18 dumpA19 dumpA20

// (111-130) Phase 1 - Walk/Run
$frame runA1 runA2 runA3 runA4 runA5 runA6 runA7 runA8
$frame runA9 runA10 runA11 runA12 runA13 runA14 runA15 runA16
$frame runA17 runA18 runA19 runA20

// (131-140) Phase 1 - Pain
$frame painA1 painA2 painA3 painA4 painA5 painA6 painA7 painA8
$frame painA9 painA10

// (141-160) Phase 1 - Switch to Phase 2 (rocket attack)
$frame switch1 switch2 switch3 switch4 switch5 switch6 switch7 switch8
$frame switch9 switch10 switch11 switch12 switch13 switch14 switch15 switch16
$frame switch17 switch18 switch19 switch20

// (161-180) Phase 2 - Floor Dump
$frame dumpB1 dumpB2 dumpB3 dumpB4 dumpB5 dumpB6 dumpB7 dumpB8
$frame dumpB9 dumpB10 dumpB11 dumpB12 dumpB13 dumpB14 dumpB15 dumpB16
$frame dumpB17 dumpB18 dumpB19 dumpB20

// (181-200) Phase 2 - Rocket A
$frame rocketA1 rocketA2 rocketA3 rocketA4 rocketA5 rocketA6 rocketA7 rocketA8
$frame rocketA9 rocketA10 rocketA11 rocketA12 rocketA13 rocketA14 rocketA15 rocketA16
$frame rocketA17 rocketA18 rocketA19 rocketA20

// (201-220) Phase 2 - Rocket B
$frame rocketB1 rocketB2 rocketB3 rocketB4 rocketB5 rocketB6 rocketB7 rocketB8
$frame rocketB9 rocketB10 rocketB11 rocketB12 rocketB13 rocketB14 rocketB15 rocketB16
$frame rocketB17 rocketB18 rocketB19 rocketB20

// (221-240) Phase 2 - Walk/Run
$frame runB1 runB2 runB3 runB4 runB5 runB6 runB7 runB8
$frame runB9 runB10 runB11 runB12 runB13 runB14 runB15 runB16
$frame runB17 runB18 runB19 runB20

// (241-255) Phase 2 - Swap over to Phase 3
$frame swapA1 swapA2 swapA3 swapA4 swapA5 swapA6 swapA7 swapA8
$frame swapA9 swapA10 swapA11 swapA12 swapA13 swapA14 swapA15

//-----------------------------------------------------------------------
// MODEL 2 - body is broken, use blank2 as offset to subtract
//-----------------------------------------------------------------------
// (000) Blank
$frame blank2

// (001-020) Phase 3 - Swap over to Phase 3
$frame swapB1 swapB2 swapB3 swapB4 swapB5 swapB6 swapB7 swapB8
$frame swapB9 swapB10 swapB11 swapB12 swapB13 swapB14 swapB15 swapB16
$frame swapB17 swapB18 swapB19 swapB20

// (021-040) Phase 3 - Walk/Run
$frame runC1 runC2 runC3 runC4 runC5 runC6 runC7 runC8
$frame runC9 runC10 runC11 runC12 runC13 runC14 runC15 runC16
$frame runC17 runC18 runC19 runC20

// (041-070) Phase 3 - Front Arc A
$frame coreA1 coreA2 coreA3 coreA4 coreA5 coreA6 coreA7 coreA8
$frame coreA9 coreA10 coreA11 coreA12 coreA13 coreA14 coreA15 coreA16
$frame coreA17 coreA18 coreA19 coreA20 coreA21 coreA22 coreA23 coreA24
$frame coreA25 coreA26 coreA27 coreA28 coreA29 coreA30

// (071-090) Phase 3 - Floor Dump
$frame dumpC1 dumpC2 dumpC3 dumpC4 dumpC5 dumpC6 dumpC7 dumpC8
$frame dumpC9 dumpC10 dumpC11 dumpC12 dumpC13 dumpC14 dumpC15 dumpC16
$frame dumpC17 dumpC18 dumpC19 dumpC20

// (091-100) Phase 3 - Pain
$frame painC1 painC2 painC3 painC4 painC5 painC6 painC7 painC8
$frame painC9 painC10

// (101-120) Phase 3 - Grenade A
$frame grenadeA1 grenadeA2 grenadeA3 grenadeA4 grenadeA5 grenadeA6 grenadeA7 grenadeA8
$frame grenadeA9 grenadeA10 grenadeA11 grenadeA12 grenadeA13 grenadeA14 grenadeA15 grenadeA16
$frame grenadeA17 grenadeA18 grenadeA19 grenadeA20

// (121-150) Phase 3 - Front Arc B
$frame coreB1 coreB2 coreB3 coreB4 coreB5 coreB6 coreB7 coreB8
$frame coreB9 coreB10 coreB11 coreB12 coreB13 coreB14 coreB15 coreB16
$frame coreB17 coreB18 coreB19 coreB20 coreB21 coreB22 coreB23 coreB24
$frame coreB25 coreB26 coreB27 coreB28 coreB29 coreB30

// (151-170) Phase 3 - Grenade B
$frame grenadeB1 grenadeB2 grenadeB3 grenadeB4 grenadeB5 grenadeB6 grenadeB7 grenadeB8
$frame grenadeB9 grenadeB10 grenadeB11 grenadeB12 grenadeB13 grenadeB14 grenadeB15 grenadeB16
$frame grenadeB17 grenadeB18 grenadeB19 grenadeB20

//-----------------------------------------------------------------------
// Constant variables for phases, animations and weapon types
//-----------------------------------------------------------------------

// Style
float MM_PHASE0 = 0;		// Phase 0 - Locked
float MM_PHASE1 = 1;		// Phase 1 - Lasers
float MM_PHASE2 = 2;		// Phase 2 - Rockets
float MM_PHASE3 = 3;		// Phase 3 - Lasers + Grenades
float MM_PHASE4 = 4;		// Phase 4 - Death

// State
float MM_LOCKED = 0;		// Start position
float MM_STAND = 5;			// Bobbing up/down
float MM_WALK = 10;			// Walk and run are combined
float MM_RUN = 11;

float MM_ATTACKDUMP = 15;	// Phase 1/2/3 Plasma/Fire dump (MELEE)

float MM_ATTACKLASER1 = 20;	// Phase 1 Laser attack 1
float MM_ATTACKLASER2 = 21;	// Phase 1 Laser attack 2

float MM_ATTACKROCK1 = 25;	// Phase 2 Rocket attack 1
float MM_ATTACKROCK2 = 26;	// Phase 2 Rocket attack 2

float MM_ATTACKCORE1 = 30;	// Phase 3 Laser Arc L>R
float MM_ATTACKCORE2 = 31;	// Phase 3 Laser Arc R>L

float MM_ATTACKGREN1 = 35;	// Phase 3 Grenade attack 1
float MM_ATTACKGREN2 = 36;	// Phase 3 Grenade attack 2

float MM_PHASE1_2 = 40;		// Transition Phase 1 > 2
float MM_PHASE2_3 = 41;		// Transition Phase 2 > 3

float MM_PAIN = 45;			// Pain end of Phase 1/2
float MM_DEATH = 50;		// Pain end of Phase 3 (death)

// Size of each animation block
float MM_ANIMBLOCK = 20;
float MM_PAINBLOCK = 10;
float MM_COREBLOCK = 30;
float MM_WAKEBLOCK = 50;

// Maximum body tilt angle
float MM_ATTACKANGLE = 35;

// Generic weapon types
float MM_PROJLASER = 1;		// Red enforcer laser
float MM_PROJROCK = 2;		// Heat seeking rockets
float MM_PROJGREN = 3;		// Typical ogre grenades
float MM_PROJCORE = 4;		// Burst of enforcer lasers

// Particle stuff on feet
float MM_FEETANGLE = 18;
float MM_FEETHORZ = 24;
float MM_FEETVERT = -12;

// Explosion body locations
float MM_EXPL_LEFT = 1;
float MM_EXPL_RIGHT= 2;
float MM_EXPL_MIDL = 3;
float MM_EXPL_MIDC = 4;
float MM_EXPL_MIDR = 5;

//======================================================================
// Global functions
//======================================================================
// Special streamlined player find function
//----------------------------------------------------------------------
float() mammoth_FindTarget =
{
	local entity client;
	
	// Get the obvious exception(s) done first
	if (self.health < 1) return FALSE;
	if (intermission_running > 0) return FALSE;
	if (cinematic_running > 0) return FALSE;

	// Find a client in current PVS
	client = checkclient ();
	
	// Go through all the exception(s)
	if (!client) return FALSE;
	if (!(client.flags & FL_CLIENT)) return FALSE;
	if (client.flags & FL_NOTARGET) return FALSE;
	if (client.items & IT_INVISIBILITY) return FALSE;
	
	// Check range and visibility of player
	enemy_vis = visible(client);
	if (!enemy_vis) return FALSE;
	if (!infront(client)) return FALSE;

	// Finally found something
	self.enemy = client;
	self.oldorigin = self.origin;		// Save origin
	self.goalentity = self.enemy;		// Focus on enemy
	// Setup turning angle towards new enemy
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);

	// Locked, boss cannot attack or run
	if (self.state == MM_LOCKED) return FALSE;

	// We have a winner!
	return TRUE;	
};

//----------------------------------------------------------------------
// Setup wave HP and trigger boundaries
//----------------------------------------------------------------------
void() mammoth_WaveSetupHP =
{
	// Is there anymore boss waves left?
	if (self.bosswave >= self.bosswavetotal) {
		// Only one wave left (death is final trigger)
		self.health = self.bosswaveqty;
		self.bosswavetrig = -1000;
	}
	else {
		// Multiple waves are still left (reset hp+trigger)
		// Always reset HP to stop high DPS weapons trashing waves boundaries
		self.health = ((self.bosswavetotal - self.bosswave) + 1) * self.bosswaveqty;
		// The wave trigger is always one wave lower
		self.bosswavetrig = self.health - self.bosswaveqty;
	}
	// Debug messages for wave and health
	dprint("\b[BOSS]\b Wave ("); dprint(ftos(self.bosswave));
	dprint(" / "); dprint(ftos(self.bosswavetotal));
	dprint(") HP ("); dprint(ftos(self.health));
	dprint(") Trig ("); dprint(ftos(self.bosswavetrig));
	dprint(")\n");
};

//----------------------------------------------------------------------
// Check if HP has reached next boss wave trigger event
//----------------------------------------------------------------------
float() mammoth_WaveCheck =
{
	// Check for boss wave boundary event
	if (self.health > 1 && self.health < self.bosswavetrig) {
		// Check for wave boundary triggers
		self.noise = "";
		if (self.bosswave == 1) self.noise = self.noise1;
		else if(self.bosswave == 2) self.noise = self.noise2;
		else if(self.bosswave == 3) self.noise = self.noise3;
		else if(self.bosswave == 4) self.noise = self.noise4;
		else if(self.bosswave == 5) self.noise = self.noise5;
		
		// Is there any trigger for the wave boundary?
		if (self.noise != "") trigger_strs(self.noise, self);

		// Update Boss wave parameters (next wave!)
		self.bosswave = self.bosswave + 1;
		mammoth_WaveSetupHP();
		return TRUE;
	}
	return FALSE;
};

//======================================================================
// Mammoth BLUE Shield setup and maintainence functions
//======================================================================
void() mammoth_shieldon =
{
	self.takedamage = DAMAGE_YES;	// Grenades bounce off
	self.bouncegrenade = TRUE;		// Warning to other monsters
	self.reflectnails = TRUE;		// Reflect nail projectiles
	self.reflectlightning = TRUE;	// Reflect lightning strikes
	self.reflectplasma = TRUE;		// Reflect plasma projectiles
	self.reflectaxe = TRUE;			// Reflect axe damage
	// Visually show resistance and reduce damage taken
	self.resist_shells = self.resist_nails = 1;
	self.resist_rockets = self.resist_cells = 1;
	sound (self, CHAN_FEET, "mammoth/shield_on.wav", 1, ATTN_NORM);
};

//----------------------------------------------------------------------
void() mammoth_shieldoff =
{
	self.takedamage = DAMAGE_AIM;	// Grenades can make contact
	self.bouncegrenade = FALSE;		// Reset to default
	self.reflectnails = FALSE;		// Allow nail projectiles
	self.reflectlightning = TRUE;	// Reflect lightning strikes
	self.reflectplasma = TRUE;		// Reflect plasma projectiles
	self.reflectaxe = TRUE;			// Reflect axe damage
	self.resist_shells = self.resist_nails = 0;
	// Phase 3 has lower resistance, outer shell broken
	if (self.style == MM_PHASE3)
		{ self.resist_rockets = self.resist_cells = 0.5; }
	else { self.resist_rockets = self.resist_cells = 0.75; }
	sound (self, CHAN_FEET, "mammoth/shield_off.wav", 1, ATTN_NORM);
};

//----------------------------------------------------------------------
void() mammothshield_finished = { if (self.attachment) self.attachment.estate = ESTATE_OFF;};
void() mammothshield_disable = { if (self.attachment) self.attachment.estate = ESTATE_DISABLE;};
void() mammothshield_enable = { if (self.attachment) self.attachment.estate = ESTATE_ON;};
void() mammothshield_switchoff = {
	// Only use particles for wakeup phase
	if (self.part_emitter) misc_particle_off(self.part_emitter);
	self.model = ""; setmodel(self, self.model);
};

//----------------------------------------------------------------------
void() mammothshield_update =
{
	// Shield no longer needed, no more thinking either!
	if (self.estate == ESTATE_OFF) { mammothshield_switchoff(); return;	}
	// Wake up phase has particles, spawn emitter
	if (!self.part_emitter) {
		// Setup particle emitter for wakeup phase
		self.part_active = PARTICLE_STYLE_FFIELD;
		self.spr_frame = PARTICLE_BURST_BLUE;
		self.part_vol = '32 32 16';		// Bounding box volume
		self.part_limit = 50;			// Medium amount of particles
		self.part_life = 4;				// Longer lifetime
		self.part_ofs = '0 0 80';		// Top of mammoth body
		self.part_vel = '0 0 4';		// Move upwards ... gradually
		self.part_emitter = spawn_pemitter(self, self, self.part_active, PARTICLE_START_ON);
	}

	// Shield temporarily disabled (wakeup/phase 1+2), still thinking ...
	if (self.estate == ESTATE_DISABLE) mammothshield_switchoff();
	// Setup model, sync to owner/source and randomize alpha
	else if (self.estate == ESTATE_ON) { 
		// Check if model is active
		if (self.model == "") {
			self.model = self.owner.weaponglow;
			setmodel(self, self.model);
			setsize(self,VEC_ORIGIN, VEC_ORIGIN);
		}
		// Keep in sync with the owner
		setorigin(self, self.owner.origin);
		self.angles = self.owner.angles;
		self.frame = self.owner.frame;
		// Randomize the alpha value
		if (self.owner.state == MM_PAIN) self.alpha = random()*0.8;
		else self.alpha = 0.7 + random()*0.3;
		if (self.alpha < 0.5) self.alpha = 0.01;
	}
	// Keep ticking and checking entity states
	self.think = mammothshield_update;
	self.nextthink = time + 0.1;
};

//----------------------------------------------------------------------
void() mammothshield_setup = 
{
	// Has the shield been defined already?
	if (self.attachment) return;
	
	// Create the shield
	self.attachment = spawn();
	self.attachment.owner = self;
	self.attachment.classtype = CT_ATTACHMENT;
	self.attachment.model = "";
	self.attachment.origin = self.origin;
	self.attachment.estate = ESTATE_DISABLE;

	// No movement and reset model frame/skin
	self.attachment.solid = SOLID_NOT;
	self.attachment.movetype = MOVETYPE_NOCLIP;
	self.attachment.velocity = '0 0 0';
	self.attachment.frame = 0;
	self.attachment.skin = 0;

	// Start the shield
	self.attachment.think = mammothshield_update;
	self.attachment.nextthink = time + 0.1;
}

//======================================================================
// Creates a debug marker for testing firing positions
//======================================================================
entity() mammoth_devmarker =
{
	local entity targ;
	targ = spawn();
	targ.movetype = MOVETYPE_NONE;
	targ.solid = SOLID_NOT;
	setmodel(targ, MODEL_BROKEN);
	setorigin(targ, self.origin);
	setsize (targ, VEC_ORIGIN, VEC_ORIGIN);
	return targ;
};

//----------------------------------------------------------------------
void(float genqty) mammoth_genericgibs =
{
	// Generic metal chunk
	self.gibtype = GIBTYPE_METAL;
	self.gib5mdl = "progs/gib_metal1.mdl";
	ThrowGib(15, genqty + rint(random()*genqty));	
};

//----------------------------------------------------------------------
void() mammoth_uniquegibs =
{
	// Phase 2 gib models
	if (self.state == MM_PHASE2_3) {
		self.gib1mdl = "progs/gib_mammoth1.mdl";	// Front light panel
		self.gib2mdl = "progs/gib_mammoth2.mdl";	// Corner chunk 1
		self.gib3mdl = "progs/gib_mammoth3.mdl";	// Arm piece
		self.gib4mdl = "progs/gib_mammoth4.mdl";	// Front light panel
		self.gib5mdl = "progs/gib_mammoth5.mdl";	// Arm piece
		ThrowGib(12, 2);						// Extra corners
		ThrowGib(13, 1); ThrowGib(15, 1);		// two arms
	}
	// Phase 3 gib models
	else if (self.state == MM_DEATH) {
		self.gib1mdl = "progs/gib_mammoth6.mdl";	// Back panel
		self.gib2mdl = "progs/gib_mammoth7.mdl";	// Feet jet
		self.gib3mdl = "progs/gib_mammoth8.mdl";	// Grenade panel
		self.gib4mdl = "progs/gib_mammoth9.mdl";	// Corner chunk 2
		self.gib5mdl = "progs/gib_mammoth10.mdl";	// Back Fan
		ThrowGib(12, 2);						// three feet
		ThrowGib(13, 1); ThrowGib(14, 3);		// grenade panel + corners
	}
	// Throw unique gibs
	ThrowGib(11, 1); ThrowGib(12, 1);
	ThrowGib(13, 1); ThrowGib(14, 1);
	ThrowGib(15, 1);
};

//----------------------------------------------------------------------
// Puff Puff of downward sprite smoke for QS/Fitz clients ONLY
// This is a duplicate of SpawnExplosion in ai_explosion.qc
// The spawnExp function has a DP alternative which is not needed
//----------------------------------------------------------------------
void() mammoth_smoke_think =
{
	self.frame = self.frame + 1;
	if (self.frame > self.count) SUB_Remove();
	else self.nextthink = time + self.speed;
};

//----------------------------------------------------------------------
void(vector smorg, vector smdir) mammoth_spritesmoke =
{
	// Have particles been enabled via serverflags?
	if (query_configflag(SVR_PARTICLES) != SVR_PARTICLES) return;
	// This is designed for QS/Fitz engines (no extensions)
	if (ext_dppart) return;
	
	newmis = spawn();
	newmis.classgroup = CG_TEMPENT;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_NOT;
	setorigin(newmis, smorg);
	setmodel(newmis, SBURST_SMOKE);
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	
	newmis.alpha = 0.85;		// Slightly transparent
	newmis.effects = 32;		// Additive blending
	newmis.count = 6;			// Total frames
	newmis.speed = 0.05;		// Frame speed
	newmis.velocity = smdir;	// Move downward

	newmis.think = mammoth_smoke_think;
	newmis.nextthink = time + newmis.speed;
};

//----------------------------------------------------------------------
// Jets effects uses new particle systems (stream and DPsmoke)
// rnd_smoke allows for extra smoke to be created for start sequence
//----------------------------------------------------------------------
void(float start_angle, float curr_angle, float rnd_smoke) mammoth_jet =
{
	local vector feetangle, feetvec, feetdest;

	feetangle = '0 0 0';
	// Calculate the angle position of each jet
	feetangle_y = self.angles_y + start_angle + (curr_angle * MM_FEETANGLE);
	// Use v_forward/v_right/v_up to create vector offset
	makevectors (feetangle);
	feetvec = self.origin + (v_forward * MM_FEETHORZ) + (v_up * MM_FEETVERT);
	// Setup particles drifting outward and down (really far down)
	feetdest = feetvec + (v_forward * MM_FEETHORZ) + ((v_up * MM_FEETVERT)*4);
	particle_stream(feetvec, feetdest, random()*2, 0.5+random(), 1+random(), 6, PARTICLE_BURST_YELLOW);
	// Smoke can be intense on FPS, don't do it every frame
	if (random() < rnd_smoke) {
		// Push smoke downward
		feetdest = feetdest + ((v_up * MM_FEETVERT) * 2); 
		particle_DPsmoke(feetvec, feetdest, 1, 3, 2, 7 );
		// Special sprite version for QS/Fitz engines
		feetdest = v_forward + (-v_up * (200 + random() * 100));
		mammoth_spritesmoke(feetvec+(-v_up * 10), feetdest);
	}
};

//----------------------------------------------------------------------
// Create particles and smoke (DP/QSS/FTE engines only) from jets
//----------------------------------------------------------------------
void(float jet_frame, float smoke_override) mammoth_jeteffects =
{
	// Gen effect for every jet
	mammoth_jet(self.meleeoffset_x, jet_frame, smoke_override);
	mammoth_jet(self.meleeoffset_y, jet_frame, smoke_override);
	mammoth_jet(self.meleeoffset_z, jet_frame, smoke_override);
};

//----------------------------------------------------------------------
// Play random light click sounds for front of mammoth
// chance = TRUE for loud click sound
// volume = TRUE for maximum volume
//----------------------------------------------------------------------
void(float litchance, float litvolume) mammoth_frontlight =
{
	if (litchance <= 0) litchance =  random();
	if (litchance < 0.2) self.noise = "mammoth/front_light3.wav";
	else if (litchance < 0.7) self.noise = "mammoth/front_light2.wav";
	else self.noise = "mammoth/front_light1.wav";
	
	if (litvolume <= 0) litvolume = 0.25 + (random() * 0.65);
	if (litvolume > 1) litvolume = 1;
	sound (self, CHAN_AUTO, self.noise, litvolume, ATTN_FEET);
};

//----------------------------------------------------------------------
// Random strikes of lightning outward from origin
//----------------------------------------------------------------------
void(vector offset) mammoth_lightning =
{
	local vector startvec, randvec, finishvec;
	
	// Middle of the chest
	randvec = vecrand(0,16,TRUE);
	startvec = self.origin + offset + randvec;
	randvec = vecrand(0,50,TRUE);
	// Try to make sure its always up
	randvec_z = randvec_z + random()*25;
	finishvec = normalize(randvec);
	traceline(startvec, startvec + finishvec * 600, FALSE, self);
		
	// Create lightning bolt
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, startvec_x);
	WriteCoord (MSG_BROADCAST, startvec_y);
	WriteCoord (MSG_BROADCAST, startvec_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);

	// Play some arching lightning sounds
	if (random() < 0.5) sound (self, CHAN_BODY, "mammoth/elec_arch1.wav", 1, ATTN_NORM);
	else sound (self, CHAN_BODY, "mammoth/elec_arch2.wav", 1, ATTN_NORM);
};

//----------------------------------------------------------------------
// Plasma bolt firing in random direction
//----------------------------------------------------------------------
void(vector offset) mammoth_plasmabolt =
{
	local vector org, randvec, dir;

	makevectors(self.angles);
	randvec = vecrand(0,16,TRUE);
	org = self.origin + attack_vector(offset) + randvec;
	randvec = vecrand(0,50,TRUE);
	dir = normalize(randvec);
	self.attack_speed = SPEED_MAMMOTHLAZ + (random() * SPEED_MAMMOTHLAZSKILL);
	launch_plasma(org, dir, CT_MONMAMMOTH, self.attack_speed);
};

//----------------------------------------------------------------------
// Explosions, Sparks and Smoke
// EXPL_TYPE   : 1=LEFT, 2=RIGHT, 3=MID_LEFT, 4=MID_CENTER, 5=MID_RIGHT
// EXPL_HIGH   : Extra vertical offset
// EXPL_SIZE   : 0 = Medium, 1 = Big (+ spark/smoke)
// EXPL_SILENT : 0 = no change, 1 = silent
//----------------------------------------------------------------------
void(float expl_type, float expl_high, float expl_size, float expl_silent) mammoth_explosions =
{
	local vector expl_org, expl_vec;
	local string expl_wav;
	
	if (expl_type == MM_EXPL_LEFT) expl_vec = '30 38 0';
	else if (expl_type == MM_EXPL_RIGHT) expl_vec = '30 -38 0';
	else if (expl_type == MM_EXPL_MIDL) expl_vec = '28 16 0';
	else if (expl_type == MM_EXPL_MIDC) expl_vec = '28 0 0';
	else if (expl_type == MM_EXPL_MIDR) expl_vec = '28 -16 0';

	expl_vec_y = expl_vec_y + (crandom() * 8);
	expl_vec_z = expl_vec_z + expl_high + (crandom() * 8);
	expl_org = self.origin + attack_vector(expl_vec);
	
	if (expl_size == 1) expl_wav = "mammoth/explode_major.wav";
	else expl_wav = "mammoth/explode_minor.wav";
	if (expl_silent) expl_wav = "";

	if (expl_size == 1) {	
		SpawnExplosion(EXPLODE_BIG, expl_org, expl_wav);
		SpawnProjectileSmoke(expl_org, 150, 50, 150);
		if (random() < 0.7) 
			particle_dust(expl_org, 10+random()*10, 16, PARTICLE_BURST_YELLOW);
	}
	else SpawnExplosion(EXPLODE_MED, expl_org, expl_wav);
};

//----------------------------------------------------------------------
// Work out ideal tilt angle towards enemy and check for rotation locks
// This is like ai_face, but it works on two axis (Up/down and left/right)
// startblock, endblock are the animation frame sections to gradually tilt
// Return values = self.attack_angle, self.finalangle
//----------------------------------------------------------------------
/* DEBUG STUFF (not required anymore) 
if (!self.tno1) self.tno1 = mammoth_devmarker();
	dprint("WF ("); dprint(ftos(self.walkframe));
	dprint(") % ("); dprint(ftos(self.lip));
	dprint(") Org ("); dprint(ftos(self.pos2_x));
	dprint(") AA ("); dprint(ftos(self.attack_angle));
	dprint(") New ("); dprint(ftos(self.pos3_x));
	dprint(")\n");
	self.finalangle = mathlib_vectorotateY('30 38 40', self.attack_angle);
	setorigin(self.tno1, self.origin + attack_vector(self.finalangle)); */
//----------------------------------------------------------------------
void(float startblock, float endblock) mammoth_tiltbody =
{
	local vector idealvec, idealang;
	local float bodytilt, startperc, endperc;
	
	// Find perfect angle (from mammoth to enemy)
	// Create directional vector and convert to angles
	idealvec = SUB_orgEnemyTarget() - self.origin;
	idealang = vectoangles(idealvec);
	// only interested in up/down and left/right axis/angles
	// The z axis will twist the body (rarely used)
	idealang_z = 0;

	// Is the enemy below or above the mammoth?
	if (idealang_x > 180) {
		// Restrict rotation angle (BELOW)
		if (idealang_x < (360 - MM_ATTACKANGLE))
			idealang_x = 360 - MM_ATTACKANGLE;
		// Create ideal angle +/- around 0 degree
		self.attack_angle = 360 - idealang_x;
	}
	else {
		// Restrict rotation angle (ABOVE)
		if (idealang_x > MM_ATTACKANGLE) 
			idealang_x = MM_ATTACKANGLE;
		// Create ideal angle +/- around 0 degree
		self.attack_angle = 0 - idealang_x;
	}

	// Create YAW only angles as baseline for gradual tilt setup
	self.finalangle = '0 0 0';
	self.finalangle_y = idealang_y;
	// Setup forward/right/up projection vectors (used later)
	makevectors (self.finalangle);
	
	// Work out gradual tilt percentage based on frames available
	startperc = 1 / (startblock + 1);
	endperc = 1 / (MM_ANIMBLOCK - endblock);
	
	// Check for start/end parts of the animation block that can
	// be used for a gradual change of the final tilt
	if (self.walkframe < startblock) {
		bodytilt = (self.walkframe + 1) * startperc;
		self.finalangle_x = bodytilt * self.attack_angle;
	}
	// End of animation block (no more tilt)
	else if (self.walkframe >= MM_ANIMBLOCK) self.finalangle_x = 0;
	// Gradually fade tilt back to normal angle
	else if (self.walkframe > endblock) {
		bodytilt = (MM_ANIMBLOCK - self.walkframe) * endperc;
		self.finalangle_x = bodytilt * self.attack_angle;
	}
	// 100% look/tilt at enemy (ready for projectiles)
	else self.finalangle_x = -self.attack_angle;
	
	// Update model YAW/angles
	self.ideal_yaw = self.finalangle_y;
	ChangeYaw ();
	self.angles = self.finalangle;
	self.fixangle = TRUE;
};

//----------------------------------------------------------------------
// Check the tether system
//----------------------------------------------------------------------
float() mammoth_CheckTether =
{
	local float currentdist;
	
	currentdist = vlen(self.origin - self.movelast.origin);
	// Check the most obvious first, inside tether range?
	if (currentdist < self.tetherrange) return FALSE;
	else {
		// If player or tether close to each other?
		if (infront(self.movelast) && infront(SUB_entEnemyTarget()) )
			return FALSE;
		// Stop moving around
		else return TRUE;
	}
};
	
//----------------------------------------------------------------------
// Mammoth game play logic
//----------------------------------------------------------------------
void() mammothCheckAttack = 
{
	local vector armorg, eorg;
	
	// Check for boss wave trigger events
	if (mammoth_WaveCheck() == TRUE) return;

	//----------------------------------------------------------------------
	// setup enemytarget if one is not active
	//----------------------------------------------------------------------
	if (self.enemy.classtype != CT_ENEMYTARGET) {
		if (SUB_setupEnemyTarget(self.enemy, self.height, MONAI_ABOVETIMER)) {
			self.enemy = self.enemytarget;
		}
	}

	//----------------------------------------------------------------------
	// Melee attack (Dumping fire on to player/floor)
	// this has always got to be available, no cooldown
	//----------------------------------------------------------------------
	// Flatten distance checks, the mammoth is constantly flying
	self.enemydist = range_distance(SUB_entEnemyTarget(), TRUE);
	// Any sprite space left for hazard projectiles? (def=14 frames)
	// There is no skill difference with the fire/dump attack
	if (HazardProjectile_CheckLimit(self, self.proj_attqty_z)) {
		if (self.enemydist < MONAI_MELEEMAMMOTH) {
			self.attack_state = AS_MELEE;
			return;
		}
	}
	
	//----------------------------------------------------------------------
	// Mammoth is a very wide and needs more visibility checks,
	// especially for the arms during phase 1 & 2.
	// Phase 3 = central attacks, front and top only
	//----------------------------------------------------------------------
	self.attack_sidedeny = FALSE;
	if (!enemy_vis) {
		// Work out enemy origin + vertical offset
		eorg = self.enemy.origin + self.enemy.view_ofs;
		makevectors(self.angles);
		
		// Phase 3 has no arms, use left/right side of body instead
		if (self.style == MM_PHASE3) armorg = self.origin + attack_vector('30 24 46');
		else armorg = self.origin + attack_vector('30 38 46');

		traceline (armorg, eorg, TRUE, self);
		if (trace_fraction == 1) enemy_vis = TRUE;
		else {
			// first arm was blocked, try second instead
			if (self.style == MM_PHASE3) armorg = self.origin + attack_vector('30 -24 46');
			else armorg = self.origin + attack_vector('30 -38 46');

			traceline (armorg, eorg, TRUE, self);
			if (trace_fraction == 1) enemy_vis = TRUE;
		}
		// Partly blocked, so use agressive attack instead
		if (enemy_vis) self.attack_sidedeny = TRUE;
	}
	
	//----------------------------------------------------------------------
	// Range attacks (Laser, Rockets, Arc and Grenades)
	//----------------------------------------------------------------------
	// Range attack if cooldown has finished and can see enemy
	if (self.attack_finished < time && enemy_vis) {
		// Is the enemy close enough for attack?
		// If the mammoth at maximum tether range, keep firing!
		if (mammoth_CheckTether() || self.enemydist < MONAI_RANGEMAMMOTH) {
			SUB_AttackFinished(2 + random());
			self.attack_state = AS_MISSILE;
			return;
		}
	}

	//----------------------------------------------------------------------
	// Maintain distance (strafe)
	//----------------------------------------------------------------------
	// Don't strafe if at max tether range
	if (mammoth_CheckTether()) return;
	if (enemy_range >= RANGE_MID || !enemy_vis) {
		if (self.attack_state != AS_STRAIGHT) self.attack_state = AS_STRAIGHT;
	}
	else self.attack_state = AS_SLIDING;
};

//======================================================================
// Different projectile attacks
//----------------------------------------------------------------------
void(vector offset, float side) mammoth_laser =
{
	local vector org, dir, vec;
	local float sideoff;

	if (!self.enemy) return;
	if (self.health < 1) return;
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, SOUND_LASER_FIRE, 1, ATTN_NORM);

	// Make sure boss is tilted at the enemy
	makevectors (self.angles);
	// Use new rotated offset for start position
	org = self.origin + attack_vector(offset);
	// Add side offset so its not exact aiming, looks more natural
	if (side < 0) {
		// Remember side offsets for left/right
		if (self.attack_offset_x <= 0) {
			sideoff = side * (3 + random() + random());
			self.attack_offset_x = sideoff;
		}
		else sideoff = self.attack_offset_x;
	}
	else {
		// Remember side offsets for left/right
		if (self.attack_offset_y <= 0) {
			sideoff = side * (3 + random() + random());
			self.attack_offset_y = sideoff;
		}
		else sideoff = self.attack_offset_y;
	}
	dir = SUB_orgEnemyTarget() + (v_up * 12) + (v_right * sideoff);
	vec = normalize(dir - org);

	// Variable laser speed
	self.attack_speed = SPEED_MAMMOTHLAZ + (skill * SPEED_MAMMOTHLAZSKILL);

	// Velocity tracking ("Bal : tracking is brutal af")
	if (self.attack_rage) {
		// The tracking system starts with predicting enemy movement
		// by using the enemy velocity. This tracking can get better
		// over time by using the previous enemy location.
		// The first tracking point is often the weakest and easiest
		// to avoid because it has no velocity history.
		//
		// There are two types : single shot or refined shots
		// The refined tracking should only be used for NIGHTMARE skill
		// because it can feel unfair and relentless at times!
		// The single shot is perfect for HARD skill as its a challenge.
		//
		// Attack 1 is 4 shots over a long period of time (12 frames)
		//          and would be extra hard if refined tracking
		// Attack 2 is 8 burst shots and would suit refined tracking
		//          because its designed for hard/nm skill
	
		// Reset the tracking system if EASY/NORMAL/HARD skill or Attack 1
		if (skill <= SKILL_HARD || self.state == MM_ATTACKLASER1) 
			self.attack_sidestep = self.walkframe;
		// Is this the first prediction point for tracking?
		if (self.walkframe == self.attack_sidestep)
			self.attack_track = SUB_Tracking(SUB_orgEnemyTarget(), offset, SUB_entEnemyTarget(), self.attack_speed);
		else
			// Keep refining the velocity tracking over multiple frames
			self.attack_track = SUB_Tracking(self.attack_track, offset, SUB_entEnemyTarget(), self.attack_speed);
		// Update projectile direction
		vec = normalize(self.attack_track - org);
	}
	// Projectile away!
	launch_projectile(org, vec, CT_PROJ_LASER, self.attack_speed);
};

//----------------------------------------------------------------------
void(vector offset, float side) mammoth_rocket =
{
	local vector org, dir, vec;
	local float sideoff;
	
	if (!self.enemy) return;
	if (self.health < 1) return;
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "mammoth/rocket_fire.wav", 1, ATTN_NORM);	

	// Maximum speed, initial speed set in Launch_Missile
	self.attack_speed = SPEED_MAMMOTHROCK + (skill * SPEED_MAMMOTHROCKSKILL);

	// Make sure boss is tilted at the enemy
	makevectors (self.angles);
	// Use new rotated offset for start position
	org = self.origin + attack_vector(offset);
	// Add side offset so its not exact aiming, looks more natural
	if (side < 0) {
		// Remember side offsets for left/right
		if (self.attack_offset_x <= 0) {
			sideoff = side * (3 + random() + random());
			self.attack_offset_x = sideoff;
		}
		else sideoff = self.attack_offset_x;
	}
	else {
		// Remember side offsets for left/right
		if (self.attack_offset_y <= 0) {
			sideoff = side * (3 + random() + random());
			self.attack_offset_y = sideoff;
		}
		else sideoff = self.attack_offset_y;
	}
	dir = SUB_orgEnemyTarget() + (v_right * sideoff);
	vec = normalize(dir - org);

	Launch_Missile (org, vec, '0 0 0', CT_PROJ_MAMMOTH, self.attack_speed);
};

//----------------------------------------------------------------------
void(vector offset, float side) mammoth_grenade =
{
	local vector org, eorg, torg, ang, dir, avel;
	local float enemy_vlen, targetang;

	if (!self.enemy) return;
	if (self.health < 1) return;
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);
	
	// A bit of randomness to projectile speed +/- 16
	self.attack_speed = SPEED_PLAYGRENADE + (crandom()*32);

	// need boss facing angle for firing direction
	makevectors (self.angles);
	// Use new rotated offset for start position
	org = self.origin + attack_vector(offset);
	eorg = SUB_orgEnemyTarget();
	// Projectile enemy origin infront based on facing direction
	enemy_vlen = vlen(eorg - self.origin);
	torg = self.origin + (v_forward * enemy_vlen);
	// Target origin is the same as enemy Z axis + some randomness
	torg_z = eorg_z + (crandom()*16);
	// Pick sides for grenades to stop central point of attack
	torg = torg + (v_right * (side * 8));
	// Work out elevation angle to hit target origin
	targetang = SUB_Elevation(ELEV_DEFAULT, self.origin, torg, self.attack_speed);
	ang = vectoangles(torg - org);
	ang_x = -targetang;	// Negative = upwards angle 
	makevectors (ang);
	// Final direction to fire grenade
	dir = v_forward * self.attack_speed;
	
	// Typically this function would use the MonsterFireGrenade function
	// The Mammoth is not firing grenades to be precise, its suppression fire
	// So the angle/arc is predicted based on facing angles of Mammoth
	avel = vecrand(100,200,FALSE);
	Launch_Grenade(org, dir, avel, CT_PROJ_GLMON);
};


//----------------------------------------------------------------------
void(vector offset) mammoth_coreattack =
{
	local vector org, dir, vec;

	if (!self.enemy) return;
	if (self.health < 1) return;
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, SOUND_LASER_FIRE, 1, ATTN_NORM);

	// Make sure boss is tilted at the enemy
	makevectors (self.angles);
	// Use new rotated offset for start position
	org = self.origin + attack_vector(offset);
	dir = SUB_orgEnemyTarget();
	vec = normalize(dir - org);

	// Variable laser speed
	self.attack_speed = SPEED_MAMMOTHLAZ + (skill * SPEED_MAMMOTHLAZSKILL);

	// Velocity tracking
	if (skill >= SKILL_HARD) {
		// Reset the tracking system if EASY/NORMAL/HARD skill
		if (skill <= SKILL_HARD) self.attack_sidestep = self.walkframe;
		// Is this the first prediction point for tracking?
		if (self.walkframe == self.attack_sidestep)
			self.attack_track = SUB_Tracking(SUB_orgEnemyTarget(), offset, SUB_entEnemyTarget(), self.attack_speed);
		else
			// Keep refining the velocity tracking over multiple frames
			self.attack_track = SUB_Tracking(self.attack_track, offset, SUB_entEnemyTarget(), self.attack_speed);
		// Update projectile direction
		vec = normalize(self.attack_track - org);
	}
	// Track that player!
	launch_projectile(org, vec, CT_PROJ_RICLASER, self.attack_speed);
};

//----------------------------------------------------------------------
void() mammoth_jetdump =
{
	local vector org, torg, dir, ang;
	local float targetang;

	if (!self.enemy) return;
	if (self.health < 1) return;
	
	// Start flames at jet/feet
	makevectors (self.angles);	
	org = self.origin + attack_vector('0 0 -24');

	// Workout target origin (self.enemy)
	torg = SUB_orgEnemyTarget();
	// Allow for medium target area
	torg_x = torg_x + (crandom() * 64);
	torg_y = torg_y + (crandom() * 64);
	targetang = SUB_Elevation(ELEV_DEFAULT, org, torg, SPEED_FLAME);
	// Work out angle
	ang = vectoangles(torg - org);
	ang_x = -targetang;	// Negative = upwards angle 
	makevectors (ang);
	// fire flames in arc pattern (offset)
	dir = ( (v_forward * (1 + random()*0.5)) + (v_right * (crandom()*0.1)) ) * SPEED_FLAME;
	// Fire that flame!
	// target, origin, v_forward, colour, size, lifetime, speed
	Launch_Flame (self, org, dir, FLAME_RED, -1, -1, SPEED_FLAME);
};

//----------------------------------------------------------------------
void(float fireqty) mammoth_jetexplosion =
{
	local vector torg, dir, ang;
	local float targetang, fire_loop, fire_time;

	// Is the fire explosion disabled?
	if (fireqty <= 0) return;

	fire_loop = fireqty;
	while (fire_loop > 0) {
		fire_loop = fire_loop - 1;
		ang = '0 0 0';
		// Pick random angle around orgin
		ang_y = rint(random()*360);
		makevectors (ang);
		// Random distance = 50 + random() * 50
		torg = self.origin + (v_forward * (10 + (random() * 10)));
		torg_z = torg_z + (random() * 16);
		targetang = SUB_Elevation(ELEV_DEFAULT, self.origin, torg, SPEED_FLAME);
		// Work out angle
		ang = vectoangles(torg - self.origin);
		ang_x = -targetang;	// Negative = upwards angle 
		makevectors (ang);
		// fire flames in arc pattern (offset)
		dir = ( (v_forward * (0.5 + random() * 0.5)) ) * SPEED_FLAME;
		// Random fire time
		fire_time = 8 + (random()*8);
		// Fire that flame!
		// target, origin, v_forward, colour, size, lifetime, speed
		Launch_Flame (self, self.origin, dir, FLAME_RED, -1, fire_time, SPEED_FLAME);
	}
};

//----------------------------------------------------------------------
void(float fireqty) mammoth_firewreck =
{
	local vector org;
	local float fire_loop, fire_time;

	fire_loop = fireqty;
	while (fire_loop > 0) {
		fire_loop = fire_loop - 1;
		org = self.origin + ('24 24 0' * crandom()) + ('0 0 8' * random());
		// Random fire time
		fire_time = 16 + (random()*8);
		// Create dead body flames
		// target, origin, v_forward, colour, size, lifetime, speed
		Launch_Flame (self, org, '0 0 0', FLAME_RED, -1, fire_time, 0);
	}
};

//----------------------------------------------------------------------
// Mammoth has multiple projectile types (general function)
//----------------------------------------------------------------------
void(float proj_type, vector body_offset, float robotside) mammoth_fireprojectile =
{
	local vector bodyorg;

	// This is where the attack orgin vector is rotated into position
	// based on the attack_angled defined before in the tilt function
	// Grenade attack does not use body tilt function
	if (proj_type == MM_PROJGREN) bodyorg = body_offset;
	// Rotate the projectile firing position around the body origin
	// Makevectors (forward/right/up) has to be set beforehand!
	else bodyorg = mathlib_vectorotateY(body_offset, self.attack_angle);
	
	// Pick which type of projectile is being fired
	if (proj_type == MM_PROJLASER) mammoth_laser(bodyorg, robotside);
	else if (proj_type == MM_PROJROCK) mammoth_rocket(bodyorg, robotside);
	else if (proj_type == MM_PROJGREN) mammoth_grenade(bodyorg, robotside);
	else if (proj_type == MM_PROJCORE) mammoth_coreattack(bodyorg);
};

//======================================================================
// C E N T R A L   L O O P  ( all animation blocks )
//
//======================================================================
void() mammoth_frame =
{
	// Death phase, no HP checks, smoke or droning sound
	if (self.style != MM_PHASE4) {
		// This condition should never be fired
		if (self.health < 1) return;
	
		// Spew particles and smoke
		mammoth_jeteffects(self.walkframe, 0.25);
	
		// Update the drone sound
		if (self.waitmin3 < time) {
			self.waitmin3 = time + 1.3;
			// Play on auto channel so it overlaps with existing sound
			sound (self, CHAN_AUTO, "mammoth/idledrone2.wav", self.volume, ATTN_NORM);
		}
	}

	// Keep looping
	self.nextthink = time + 0.1;
	self.think = mammoth_frame;

	// Check for boss wave trigger events
	if (mammoth_WaveCheck() == TRUE) {self.th_summon(); return;}
	
	//----------------------------------------------------------------------
	// Beginning of annimation block
	if (self.walkframe == 0) monster_idle_sound();

	// Check for any front light sound triggers
	if (self.state == MM_STAND || self.state == MM_WALK || self.state == MM_RUN) {
		if (self.walkframe == 5 || self.walkframe == 8 || self.walkframe == 12)
			mammoth_frontlight(FALSE, FALSE);
		
		// Different stand/walk/run animation sets depending on phase
		if (self.style == MM_PHASE1) self.frame = $runA1 + self.walkframe;
		else if (self.style == MM_PHASE2) self.frame = $runB1 + self.walkframe;
		else if (self.style == MM_PHASE3) self.frame = ($runC1 + self.walkframe) - $blank2;
		else dprint("\b[MAMMOTH]\b Movement phase not detected!\n");
		self.walkframe = self.walkframe + 1;
	}
	
	//----------------------------------------------------------------------
	if (self.state == MM_STAND) {
		// Standing idle has gentle bobbing up and down
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_FLY;

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
			self.attack_finished = time + 0.3;
		}
		
		// Keep looking for a player
		if (mammoth_FindTarget ()) FoundTarget();
	}
	// Everything except stand is step movement (no velocity)
	// Might as well have a stand 'else if' to fix this
	else {
		// Movement is steps, not velocity
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_STEP;
		self.velocity = '0 0 0';
	}
	
	//----------------------------------------------------------------------
	if (self.state == MM_WALK || self.state == MM_RUN) {
		// What type of movement/functionality
		if (self.state == MM_WALK) {
			// Check tether point before moving
			if (mammoth_CheckTether()) { ai_walk(0); ai_face(); }
			else ai_walk(6);
		}
		else {
			// Check tether point before moving
			if (mammoth_CheckTether()) { ai_run(0); ai_face(); }
			else ai_run(6);
		}
	}
	//----------------------------------------------------------------------
	// SWITCH OVER : Change animations for phases 1>2 and 2>3
	//----------------------------------------------------------------------
	else if (self.state == MM_PHASE1_2) {
		// Check for any front light sound triggers
		if (self.walkframe == 5 || self.walkframe == 7 || self.walkframe == 10)
			mammoth_frontlight(TRUE, FALSE);

		// Start arm movement, switch all lights on and finish arms
		if (self.walkframe == 0)
			sound (self, CHAN_BODY, "mammoth/arms_start.wav", 1, ATTN_NORM);
		else if (self.walkframe == 14) mammoth_frontlight(TRUE, TRUE);
		else if (self.walkframe == 15)
			sound (self, CHAN_BODY, "mammoth/arms_finish.wav", 1, ATTN_NORM);

		ai_face();
		self.frame = $switch1 + self.walkframe;
		self.walkframe = self.walkframe + 1;		

		// End of switch over from P1 > P2
		if (self.walkframe >= MM_ANIMBLOCK) {
			self.state = MM_RUN;
			self.style = MM_PHASE2;
			self.walkframe = 0;
			// Default resistance
			mammoth_shieldoff();		// Default resistance
			mammothshield_disable();	// Disable blue shield
		}
	}
	//----------------------------------------------------------------------
	else if (self.state == MM_PHASE2_3) {
		// Keep looking at the player
		ai_face();
		
		// Random lightning and plasma shots
		if (random() < 0.5) mammoth_lightning('0 0 32');

		// all vectors are from projectile attacks
		makevectors(self.angles);

		// Explosions Pre-change over
		if (self.walkframe == 0) {
			// gib velocity override
			self.gibdir = MON_GIBFOUNTAIN;
			// Start chain explosion on left arm + small on right arm
			mammoth_explosions(MM_EXPL_LEFT, 40, 0, FALSE);
			mammoth_explosions(MM_EXPL_RIGHT, 52, 1, FALSE);
		}
		else if (self.walkframe == 1) {
			// Finish chain explosion on left arm + small central
			mammoth_explosions(MM_EXPL_LEFT, 48, 1, FALSE);
			mammoth_explosions(MM_EXPL_MIDC, 24, 0, FALSE);
		}
		else if (self.walkframe == 2) {
			// Start chain explosion on right arm
			mammoth_explosions(MM_EXPL_RIGHT, 40, 0, FALSE);
		}
		else if (self.walkframe == 3) {
			// Finish chain explosion on right arm + small central
			mammoth_explosions(MM_EXPL_RIGHT, 48, 1, FALSE);
			mammoth_explosions(MM_EXPL_MIDL, 24, 0, FALSE);
		}
		else if (self.walkframe == 4) {
			// Start chain explosion in middle area
			mammoth_explosions(MM_EXPL_MIDC, 48, 0, FALSE);
		}
		else if (self.walkframe == 5) {
			// Finish chain explosion in middle area + small central
			mammoth_explosions(MM_EXPL_MIDC, 64, 1, FALSE);
			mammoth_explosions(MM_EXPL_MIDR, 32, 0, FALSE);
		}
		else if (self.walkframe == 6) {
			// Single central explosion
			mammoth_explosions(MM_EXPL_MIDR, 48, 0, FALSE);
		}
		else if (self.walkframe == 7) {
			// Start chain explosion on right arm
			mammoth_explosions(MM_EXPL_RIGHT, 40, 0, FALSE);
		}
		else if (self.walkframe == 8) {
			// Spawn metal gibs
			mammoth_genericgibs(3);
			// Finish chain explosion on right arm + small central
			mammoth_explosions(MM_EXPL_RIGHT, 48, 1, FALSE);
			mammoth_explosions(MM_EXPL_MIDL, 32, 0, FALSE);
		}
		else if (self.walkframe == 9) {
			// Start chain explosion on left arm
			mammoth_explosions(MM_EXPL_LEFT, 40, 0, FALSE);
		}	
		else if (self.walkframe == 10) {
			// Spawn generic + unique gibs
			mammoth_genericgibs(6);
			mammoth_uniquegibs();
			// Finish chain explosion on left arm + small central
			mammoth_explosions(MM_EXPL_LEFT, 50, 1, FALSE);
			mammoth_explosions(MM_EXPL_MIDR, 48, 0, FALSE);
			setmodel(self, self.mdl2);					// SWITCH model
			setsize (self, self.bbmins, self.bbmaxs);	// Restore BB size
			// Smaller jet flame explosion
			mammoth_jetexplosion(self.attack_expflame*0.5);
		}
		else if (self.walkframe == 11) {
			// no more blue shield, its all gone
			mammothshield_finished();
			// Spawn metal gibs
			mammoth_genericgibs(3);
			// Finish central explosions
			mammoth_explosions(MM_EXPL_MIDR, 72, 0, FALSE);
			mammoth_explosions(MM_EXPL_MIDL, 48, 1, FALSE);
		}
		
		// Use correct animation offset for model
		if (self.walkframe >= 10) 
			self.frame = ($swapB1 + self.walkframe) - $blank2;
		else self.frame = $swapA1 + self.walkframe;
		// Keep on going
		self.walkframe = self.walkframe + 1;

		// End of switch over from P2 > P3
		if (self.walkframe >= MM_ANIMBLOCK) {
			self.state = MM_RUN;
			self.style = MM_PHASE3;
			self.walkframe = 0;
			mammoth_shieldoff();	// Phase 3 resistance setup
		}
	}
	//----------------------------------------------------------------------
	// MELEE COMBAT
	//----------------------------------------------------------------------
	else if (self.state == MM_ATTACKDUMP) {
		// No front lights for phase 3
		if (self.style != MM_PHASE3) {
			// Check for any front light sound triggers
			if (self.walkframe == 5  || self.walkframe == 7 ||
				self.walkframe == 9 || self.walkframe == 11) {
				mammoth_frontlight(FALSE, FALSE);
			}
		}
		// Player facing
		ai_face();
		
		// Wind up sound for attack
		if (self.walkframe == 0) {
			sound (self, CHAN_BODY, "mammoth/flame_attack.wav", 1, ATTN_NORM);
		}
		// Start the dump! (first/last 3 frames do nothing)
		else if (self.walkframe >= 3 && self.walkframe <= 16) {
			// Setup short/long firing sounds
			if (self.walkframe < 16)
				// Small 
				sound (self, CHAN_WEAPON, "mammoth/flame_fire.wav", 1, ATTN_NORM);	
			else 
				// Giant explosion at the end of the sequence
				sound (self, CHAN_WEAPON, "mammoth/flame_explode.wav", 1, ATTN_NORM);
			
			// Keep on dumpin! (14 frames)
			mammoth_jetdump();
		}

		// Update frame based on phase
		if (self.style == MM_PHASE1) self.frame = $dumpA1 + self.walkframe;
		else if (self.style == MM_PHASE2) self.frame = $dumpB1 + self.walkframe;
		else self.frame = ($dumpC1 + self.walkframe) - $blank2;
		// Keep moving forward
		self.walkframe = self.walkframe + 1;
		// End of animation block?
		if (self.walkframe >= MM_ANIMBLOCK) self.state = MM_RUN;
	}
	//----------------------------------------------------------------------
	// PHASE 1 COMBAT
	//----------------------------------------------------------------------
	else if (self.state == MM_ATTACKLASER1) {
		// Check for any front light sound triggers
		if (self.walkframe == 4  || self.walkframe == 7 ||
			self.walkframe == 12 || self.walkframe == 15)
			mammoth_frontlight(FALSE, FALSE);

		// Work out tilt angle and check for locks
		mammoth_tiltbody(4, 15);

		// Enable velocity tracking for hard/nm skill
		if (skill >= SKILL_HARD) {
			self.attack_rage = TRUE;
			self.attack_sidestep = 4;
		}
		else self.attack_rage = FALSE;
		
		// Which laser to fire?
		if (self.walkframe == 4) mammoth_fireprojectile( MM_PROJLASER, '30 38 40', 1);
		else if (self.walkframe == 7) mammoth_fireprojectile( MM_PROJLASER, '30 38 52', 1);
		else if (self.walkframe == 12) mammoth_fireprojectile( MM_PROJLASER, '30 -38 40', -1);
		else if (self.walkframe == 15) mammoth_fireprojectile( MM_PROJLASER, '30 -38 52', -1);

		// Update frame
		self.frame = $laserA1 + self.walkframe;
		self.walkframe = self.walkframe + 1;
		// End of animation block?
		if (self.walkframe >= MM_ANIMBLOCK) {
			self.angles_x = 0;
			self.state = MM_RUN;
		}
	}
	else if (self.state == MM_ATTACKLASER2) {
		// Check for any front light sound triggers
		if (self.walkframe > 6 && self.walkframe < 13)
			mammoth_frontlight(FALSE, FALSE);

		// Work out tilt angle and check for locks
		mammoth_tiltbody(6, 15);
			
		// Enable velocity tracking for hard/nm skill
		if (skill >= SKILL_HARD) {
			self.attack_rage = TRUE;
			self.attack_sidestep = 7;
		}
		else self.attack_rage = FALSE;

		// 8 shot burst mode
		if (self.walkframe == 7) mammoth_fireprojectile( MM_PROJLASER, '33 38 52', 1);
		else if (self.walkframe == 8) mammoth_fireprojectile( MM_PROJLASER, '33 -38 52', -1);
		else if (self.walkframe == 9) mammoth_fireprojectile( MM_PROJLASER, '33 38 40', 1);
		else if (self.walkframe == 10) mammoth_fireprojectile( MM_PROJLASER, '33 -38 40', -1);
		else if (self.walkframe == 11) mammoth_fireprojectile( MM_PROJLASER, '33 38 52', 1);
		else if (self.walkframe == 12) mammoth_fireprojectile( MM_PROJLASER, '33 -38 52', -1);
		else if (self.walkframe == 13) mammoth_fireprojectile( MM_PROJLASER, '33 38 40', 1);
		else if (self.walkframe == 14) mammoth_fireprojectile( MM_PROJLASER, '33 -38 40', -1);

		// Update frame
		self.frame = $laserB1 + self.walkframe;
		self.walkframe = self.walkframe + 1;
		// End of animation block?
		if (self.walkframe >= MM_ANIMBLOCK) {
			self.angles_x = 0;
			self.state = MM_RUN;
		}
	}
	//----------------------------------------------------------------------
	// PHASE 2 COMBAT
	//----------------------------------------------------------------------
	else if (self.state == MM_ATTACKROCK1) {
		// Check for any front light sound triggers
		if (self.walkframe == 3  || self.walkframe == 5 ||
			self.walkframe == 13 || self.walkframe == 15)
			mammoth_frontlight(FALSE, FALSE);

		// Work out tilt angle and check for locks
		mammoth_tiltbody(3, 15);
			
		// Which rocket to fire?
		if (self.walkframe == 2) sound (self, CHAN_WEAPON, "mammoth/rocket_load.wav", 1, ATTN_NORM);
		else if (self.walkframe == 3) mammoth_fireprojectile( MM_PROJROCK, '28 40 36', 1);
		else if (self.walkframe == 5) mammoth_fireprojectile( MM_PROJROCK, '28 42 54', 1);
		else if (self.walkframe == 13) mammoth_fireprojectile( MM_PROJROCK, '28 -40 36', -1);
		else if (self.walkframe == 15) mammoth_fireprojectile( MM_PROJROCK, '26 -40 54', -1);

		// Update frame
		self.frame = $rocketA1 + self.walkframe;
		self.walkframe = self.walkframe + 1;
		// End of animation block?
		if (self.walkframe >= MM_ANIMBLOCK) self.state = MM_RUN;
	}
	else if (self.state == MM_ATTACKROCK2) {
		// Check for any front light sound triggers
		if (self.walkframe >= 4  && self.walkframe <= 8 ||
			self.walkframe >= 11 && self.walkframe <= 15)
			mammoth_frontlight(FALSE, FALSE);

		// Work out tilt angle and check for locks
		mammoth_tiltbody(8, 15);
			
		// Which rocket to fire?
		if (self.walkframe == 3) sound (self, CHAN_WEAPON, "mammoth/rocket_load.wav", 1, ATTN_NORM);
		else if (self.walkframe == 11) mammoth_fireprojectile( MM_PROJROCK, '14 48 56', 1);
		else if (self.walkframe == 12) mammoth_fireprojectile( MM_PROJROCK, '14 -48 56', -1);
		else if (self.walkframe == 13) mammoth_fireprojectile( MM_PROJROCK, '20 48 38', 1);
		else if (self.walkframe == 14) mammoth_fireprojectile( MM_PROJROCK, '20 -48 38', -1);

		// Update frame
		self.frame = $rocketB1 + self.walkframe;
		self.walkframe = self.walkframe + 1;
		// End of animation block?
		if (self.walkframe >= MM_ANIMBLOCK) self.state = MM_RUN;
	}
	//----------------------------------------------------------------------
	// PHASE 3 COMBAT
	//----------------------------------------------------------------------
	else if (self.state == MM_ATTACKCORE1 || self.state == MM_ATTACKCORE2) {
		// Wind up sound for attack
		if (self.walkframe == 0) 
			sound (self, CHAN_BODY, "mammoth/core_attack.wav", 1, ATTN_NORM);

		// Work out tilt angle and check for locks
		mammoth_tiltbody(5, 25);

		// Fire projectiles from center +/- Y offset
		self.finalangle = '30 0 56';
		if (self.state == MM_ATTACKCORE1) {
			// Shorter attack
			self.attack_frame = 8;
			self.attack_count = 12;
			self.attack_lifetime = self.attack_frame + self.attack_count;
			self.frame_box = ($coreA1 + self.walkframe) - $blank2;
		}
		else {
			// Long attack
			self.attack_frame = 6;
			self.attack_count = 16;
			self.attack_lifetime = self.attack_frame + self.attack_count;
			self.frame_box = ($coreB1 + self.walkframe) - $blank2;
		}
			
		// Check for projectile burst mode
		if (self.walkframe >= self.attack_frame && self.walkframe <= self.attack_lifetime) {
			// Create Y offset for projectiles to sweep along
			self.finalangle_y = (self.walkframe - self.attack_frame) - (self.attack_count * 0.5);
			// Attack 2 goes the opposite direction
			if (self.state == MM_ATTACKCORE2) self.finalangle_y = -self.finalangle_y;
			// Launch projectile + velocity tracking
			mammoth_fireprojectile( MM_PROJCORE, self.finalangle, 0 );
		}

		// Update frame
		self.frame = self.frame_box;
		self.walkframe = self.walkframe + 1;
		// End of animation block?
		if (self.walkframe >= MM_COREBLOCK) {
			self.state = MM_RUN;
			self.walkframe = 0;
		}
	}
	else if (self.state == MM_ATTACKGREN1) {
		// There is no tilt function for grenade attack
		// Keep turning towards the player
		ai_face();
		
		if (self.walkframe == 2) sound (self, CHAN_WEAPON, "mammoth/grenade_load.wav", 1, ATTN_NORM);
		else if (self.walkframe == 6) mammoth_fireprojectile( MM_PROJGREN, '30 12 88', 1);
		else if (self.walkframe == 9) mammoth_fireprojectile( MM_PROJGREN, '30 -12 88', -1);
		else if (self.walkframe == 13) mammoth_fireprojectile( MM_PROJGREN, '32 15 84', 1);
		else if (self.walkframe == 15) mammoth_fireprojectile( MM_PROJGREN, '30 -19 85', -1);

		// Update frame
		self.frame = ($grenadeA1 + self.walkframe) - $blank2;
		self.walkframe = self.walkframe + 1;
		// End of animation block?
		if (self.walkframe >= MM_ANIMBLOCK) self.state = MM_RUN;
	}
	else if (self.state == MM_ATTACKGREN2) {
		// There is no tilt function for grenade attack
		// Keep turning towards player until ready to fire
		if (self.walkframe <= 6) ai_face();
		
		if (self.walkframe == 2) sound (self, CHAN_WEAPON, "mammoth/grenade_load.wav", 1, ATTN_NORM);
		else if (self.walkframe == 6) {
			// Save central angle point
			self.attack_angle = self.angles_y;
			// Swing to the left
			self.ideal_yaw = self.attack_angle - 30;
			mammoth_fireprojectile( MM_PROJGREN, '28 10 88', 1);
			mammoth_fireprojectile( MM_PROJGREN, '28 -10 84', -1); }
		else if (self.walkframe >= 7 && self.walkframe <= 8) ChangeYaw();
		else if (self.walkframe == 9) {
			// Swing back to central point
			self.ideal_yaw = self.attack_angle;
			mammoth_fireprojectile( MM_PROJGREN, '28 16 88', 1);
			mammoth_fireprojectile( MM_PROJGREN, '28 -10 88', -1); }
		else if (self.walkframe >= 10 && self.walkframe <= 11) ChangeYaw();
		else if (self.walkframe == 12) {
			// Swing to right
			self.ideal_yaw = self.attack_angle + 30;
			mammoth_fireprojectile( MM_PROJGREN, '28 16 84', 1);
			mammoth_fireprojectile( MM_PROJGREN, '28 -16 88', -1); }
		else if (self.walkframe >= 13 && self.walkframe <= 14) ChangeYaw();
		else if (self.walkframe == 15) {
			// Swing back to the central point
			self.ideal_yaw = self.attack_angle;
			mammoth_fireprojectile( MM_PROJGREN, '28 10 84', 1);
			mammoth_fireprojectile( MM_PROJGREN, '28 -16 84', -1); }

		// Update frame
		self.frame = ($grenadeB1 + self.walkframe) - $blank2;
		self.walkframe = self.walkframe + 1;
		// End of animation block?
		if (self.walkframe >= MM_ANIMBLOCK) self.state = MM_RUN;
	}
	//----------------------------------------------------------------------
	// PAIN and DEATH functionality
	//----------------------------------------------------------------------
	if (self.state == MM_PAIN) {
		// Check for any front light sound triggers
		if (self.walkframe == 1  || self.walkframe == 4 ||
			self.walkframe == 5 || self.walkframe == 9) {
			mammoth_frontlight(FALSE, FALSE);
		}
		
		if (random() < 0.5) self.angles_x = random()*8;
		
		// Random lightning and plasma shots
		// Phase 1 = 0.4, 2 = 0.5, 3 = 0.6, 4 = 0.7, 5 = 0.8, 6 = 0.9
		self.attack_frame = 0.3 + (self.attack_count * 0.1); 
		if (random() < self.attack_frame) mammoth_lightning('0 0 32');
		else if ( random() < 0.4) mammoth_plasmabolt('0 0 32');
		
		// Random explosions on body (Phase 3 = no arms)
		if (self.walkframe == 2 && random() < 0.4)
			mammoth_explosions(MM_EXPL_MIDL, 32, 0, FALSE);
		if (self.walkframe == 3 && random() < self.attack_frame)
			mammoth_explosions(MM_EXPL_MIDL, 48, 1, FALSE);
		if (self.walkframe == 5 && random() < 0.4)
			mammoth_explosions(MM_EXPL_MIDR, 56, 0, FALSE);
		if (self.walkframe == 6 && random() < self.attack_frame)
			mammoth_explosions(MM_EXPL_MIDR, 32, 1, FALSE);
		if (self.walkframe == 8 && random() < 0.4)
			mammoth_explosions(MM_EXPL_MIDC, 16, 0, FALSE);
		if (self.walkframe == 9 && random() < self.attack_frame)
			mammoth_explosions(MM_EXPL_MIDC, 48, 1, FALSE);

		// Update frame based on phase
		if (self.style == MM_PHASE3) 
			self.frame = ($painC1 + self.walkframe) - $blank2;
		else self.frame = $painA1 + self.walkframe;
		// Keep on loopin!
		self.walkframe = self.walkframe + 1;
		
		// End of animation block?
		if (self.walkframe >= MM_PAINBLOCK) {
			// Reset animation and tilt angle
			self.walkframe = self.angles_x = 0;
			// Reduce loop counter (allow for multiple pain sets)
			self.attack_count = self.attack_count - 1;
			// Is it time to exit this animation yet?
			if (self.attack_count <= 0) {
				// Which phase to switch to next?
				if (self.style == MM_PHASE1) self.state = MM_PHASE1_2;
				else if (self.style == MM_PHASE2) self.state = MM_PHASE2_3;
				// The final phase of pain is death!
				else self.state = MM_DEATH;
			}
		}
	}
	//----------------------------------------------------------------------
	if (self.state == MM_DEATH) {
		// Final body fireworks!
		mammoth_explosions(MM_EXPL_MIDL, 48, 1, FALSE);
		mammoth_explosions(MM_EXPL_MIDR, 32, 1, FALSE);
		mammoth_explosions(MM_EXPL_MIDC, 0, 0, FALSE);
		mammoth_explosions(MM_EXPL_MIDC, 80, 1, FALSE);
		
		// Stop functionality, there is a dead body model
		entity_stop (self);
		// Make sure gibs go flying up
		self.gibdir = MON_GIBEXPLOSION;
		self.health = -100; self.max_health = 0;
		// Dead body model
		setmodel(self, self.headmdl);
		self.frame = 0;

		// Make sure there is collision
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_NONE;
		self.bbmaxs = '32 32 24';
		setsize(self, self.bbmins, self.bbmaxs);

		// Spawn all generic/unique gibs
		mammoth_genericgibs(12);
		mammoth_uniquegibs();
		// Giant jet flame explosion + dead body flames
		mammoth_jetexplosion(self.attack_expflame);
		mammoth_firewreck(6);
		
		// Lots of random chunks
		self.pos1 = self.origin + '0 0 80';
		SpawnProjectileSmoke(self.pos1, 64, 450, 100);
		SpawnProjectileSmoke(self.pos1, 96, 500, 100);
		SpawnProjectileSmoke(self.pos1, 64, 450, 100);
		SpawnProjectileSmoke(self.pos1, 96, 400, 100);

		// Final Yellow explosion
		self.pos1 = self.origin + '0 0 64';
		if (ext_dppart) te_explosion2(self.pos1, 192, 8);
		else {
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_EXPLOSION2);
			WriteCoord (MSG_BROADCAST, self.pos1_x);
			WriteCoord (MSG_BROADCAST, self.pos1_y);
			WriteCoord (MSG_BROADCAST, self.pos1_z);
			WriteByte (MSG_BROADCAST, 192);
			WriteByte (MSG_BROADCAST, 8);
		}
	}
	
	//----------------------------------------------------------------------
	// Cycle animation set? (exception = core attacks (30+ frames)
	if (self.state != MM_ATTACKCORE1 && self.state != MM_ATTACKCORE2) {
		if (self.walkframe >= MM_ANIMBLOCK) self.walkframe = 0;
	}
};

//----------------------------------------------------------------------
// Only used to find out vector locations (dev only)
//----------------------------------------------------------------------
void() mammoth_framecheck = {
	//setmodel(self, self.mdl);
	setmodel(self, self.mdl2);
	setsize (self, self.bbmins, self.bbmaxs);
	setorigin(self, self.origin+'0 0 64');
	self.use = SUB_Null;
	self.think = SUB_Null;
	self.nextthink = LARGE_TIMER;
	makevectors (self.angles);
		
	self.finaldest = self.origin + attack_vector('28 -16 84');
	if (!self.tno1) self.tno1 = mammoth_devmarker();
	setorigin(self.tno1, self.finaldest);
	self.frame = 168;
};

//======================================================================
// Different monster states
//----------------------------------------------------------------------
void() mammoth_stand = {
	self.walkframe = 0;		// Reset animation block
	self.angles_x = 0;		// Turn off any tilt angle
	self.state = MM_STAND;	// Change animation state
	mammoth_frame();		// Back to main loop
};
void() mammoth_walk = { 
	self.walkframe = 0;		// Reset animation block
	self.angles_x = 0;		// Turn off any tilt angle
	self.state = MM_WALK;	// Change animation state
	mammoth_frame();		// Back to main loop
};
void() mammoth_run = { 
	self.walkframe = 0;		// Reset animation block
	self.angles_x = 0;		// Turn off any tilt angle
	self.state = MM_RUN;	// Change animation state
	mammoth_frame();		// Back to main loop
};

void() mammoth_dump = {
	self.walkframe = 0;				// Reset animation block
	self.angles_x = 0;				// Turn off any tilt angle
	self.pain_finished = time + 2;	// No pain interruption
	self.state = MM_ATTACKDUMP;		// Change animation state
	mammoth_frame();				// Back to main loop
};

//----------------------------------------------------------------------
void() mammoth_range = {
	self.walkframe = 0;				// Reset animation block
	self.angles_x = 0;				// Turn off any tilt angle
	self.attack_offset = '0 0 0';	// Reset random arm side offset
	self.pain_finished = time + 2;	// no pain interruptions
	
	// Pick range attack based on phase (1-3)
	if (self.style == MM_PHASE1) {
		// If weapons partly blocked, use 2nd more aggressive attack
		// Otherwise setup chance based on skill level instead
		if (self.attack_sidedeny) self.attack_chance = -1;
		else self.attack_chance = 0.9 - (skill * 0.3);
		if (random() > self.attack_chance)
			self.state = MM_ATTACKLASER2;
		else self.state = MM_ATTACKLASER1;
		// Reset aggressive mode
		self.attack_sidedeny = FALSE;
	}
	else if (self.style == MM_PHASE2) {
		// If weapons partly blocked, use 2nd more aggressive attack
		// Otherwise setup chance based on skill level instead
		if (self.attack_sidedeny) self.attack_chance = -1;
		else self.attack_chance = 0.8 - (skill * 0.2);
		if (random() > self.attack_chance)
			self.state = MM_ATTACKROCK2;
		else self.state = MM_ATTACKROCK1;
		// Reset aggressive mode
		self.attack_sidedeny = FALSE;
	}
	else if (self.style == MM_PHASE3) {
		// If weapons partly blocked, use grenade suppresion mode
		// Otherwise setup chance based on skill level instead
		if (self.attack_sidedeny) self.state = MM_ATTACKGREN2;
		else {
			// How close is the player?
			self.enemydist = range_distance(SUB_entEnemyTarget(), FALSE);
			// Is player is too close? ALWAYS use lasers
			if (self.enemydist < MONAI_COREMAMMOTH) self.attack_chance = 0;
			// Is the player is too far away? ALWAYS use grenades
			else if (self.enemydist > MONAI_GRENMAMMOTH) self.attack_chance = 1;
			// Otherwise 50/50 split between lasers/grenades
			else self.attack_chance = 0.5;
			// Pick primary attack type
			if (random() > self.attack_chance) {
				// Core attack
				self.attack_chance = 0.9 - (skill * 0.3);
				if (random() > self.attack_chance)
					self.state = MM_ATTACKCORE2;
				else self.state = MM_ATTACKCORE1;
			}
			else {
				// Grenade attack
				self.attack_chance = 0.8 - (skill * 0.2);
				if (random() > self.attack_chance)
					self.state = MM_ATTACKGREN2;
				else self.state = MM_ATTACKGREN1;
			}
		}
		// Reset aggressive mode
		self.attack_sidedeny = FALSE;
	}
	mammoth_frame();		// Back to main loop
};	
	
//----------------------------------------------------------------------
void() mammoth_phaseswitch = {
	// Check for half phase transitions
	if (self.bosswave == 2 || self.bosswave == 4) return;
	// Check for the final phase = death
	if (self.bosswave == 6) return;
	
	self.walkframe = 0;		// Reset animation block
	self.angles_x = 0;		// Turn off any tilt angle
	// Move on to pain animation and then transistion phase
	if (self.bosswave == 3 || self.bosswave == 5) {
		mammoth_shieldon();		// Default resistance
		mammothshield_enable();	// Blue shield on
		self.state = MM_PAIN; self.attack_count = self.style + 1;
	}
	// If all else fails, go back to running
	else self.state = MM_RUN;
	mammoth_frame();		// Back to main loop
};

//======================================================================
void(entity inflictor, entity attacker, float damage) mammoth_pain =
{
	// Check for boss wave trigger events
	if (mammoth_WaveCheck() == TRUE) {self.th_summon(); return;}

	// Check all pain conditions and set up what to do next
	monster_pain_check(attacker, damage);

	// Any pain animation/sound required?
	if (self.pain_check > 0)
		sound (self, CHAN_VOICE, self.pain_sound, 1, ATTN_NORM);
	// There is no pain animation for the mammoth!
};

//======================================================================
void() mammoth_die =
{
	self.deadflag = DEAD_DEAD;	// Mammoth kicks the bucket
	self.effects = 0;			// Remove effects on death
	self.style = MM_PHASE4;		// Used to stop motor drone sound
	self.attack_count = 6;		// Repeat pain 6 times
	self.walkframe = 0;		// Reset animation block
	self.angles_x = 0;		// Turn off any tilt angle
	mammoth_shieldon();		// Default resistance

	// Check for final trigger event
	if(self.noise6 != "") trigger_strs(self.noise6, self);
	// Machine winding down sound (6s)
	sound (self, CHAN_VOICE, self.death_sound, 1, ATTN_NORM);
	// Final animation (pain,pain and more pain)
	self.state = MM_PAIN; 
	mammoth_frame();	
};

//======================================================================
// Long animation sequence where front lights come on and the arms
// are extended outward ready to fire
//----------------------------------------------------------------------
void() mammoth_wakeframe =
{
	// Keep looping
	self.nextthink = time + 0.1;
	self.think = mammoth_wakeframe;
	
	// Spew lots particles and smoke as boss lifts off ground
	if (self.walkframe > 31) mammoth_jeteffects(self.walkframe - 31, 0.25);
	// Start with lots of smoke (override active)
	else if (self.walkframe > 5) mammoth_jeteffects(0, 1);
	
	// Play all the start up sequence special sounds
	if (self.walkframe == 4)
		sound (self, CHAN_VOICE, "mammoth/wake_start.wav", 1, ATTN_NORM);
	else if (self.walkframe == 30)
		sound (self, CHAN_BODY, "mammoth/arms_start.wav", 1, ATTN_NORM);
	else if (self.walkframe == 40)
		sound (self, CHAN_BODY, "mammoth/arms_finish.wav", 1, ATTN_NORM);

	// Front click sounds
	if (self.walkframe == 1 || self.walkframe == 4 || self.walkframe == 7)
		mammoth_frontlight(TRUE, FALSE);
	
	// Setup drone (jet feet) sound
	if (self.walkframe == 8 || self.walkframe == 22 || self.walkframe == 36)
		sound (self, CHAN_AUTO, "mammoth/idledrone2.wav", self.volume, ATTN_NORM);
	
	// Keep moveing the animation frame forward
	self.frame = $wake1 + self.walkframe;
	self.walkframe = self.walkframe + 1;
	// Wait for sound/animation to start
	if (self.walkframe > 4) {
		// Gently push the mammoth off the ground (use animation block total)
		self.velocity_z = (MM_WAKEBLOCK - self.walkframe) * 0.5;
	}

	// Time to fight?
	if (self.walkframe >= MM_WAKEBLOCK) {
		mammothshield_disable();	// Blue shield off
		mammoth_shieldoff();		// Default resistance

		// New phase and switch over function
		self.style = MM_PHASE1;
		self.th_summon = mammoth_phaseswitch;

		// Restore all think functions
		self.th_stand = mammoth_stand;
		self.th_walk = mammoth_walk;
		self.th_run = mammoth_run;
		self.th_melee = mammoth_dump;
		self.th_missile = mammoth_range;
		self.th_pain = mammoth_pain;
		self.th_die = mammoth_die;

		// Go through stand to acquire a target
		self.think = self.th_stand;
	}
};

//----------------------------------------------------------------------
void() mammoth_wakeup = { 
	// Allow wake up to fly up gradually
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_FLY;
	self.flags = FL_MONSTER;		// Reset flag (no user settings)
	self.flags = self.flags | FL_FLY;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	// Reset animation frame
	self.walkframe = 0; 
	mammoth_wakeframe();
};
void() mammoth_locked1 = [ $wake1, mammoth_locked1 ] {};

//======================================================================
void() mammoth_start =
{
	self.flags = FL_MONSTER;		// Reset flag (no user settings)
	self.state = MM_LOCKED;			// Starting position
	self.style = MM_PHASE0;			// Current boss phase
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel(self, self.mdl);					// Setup model
	setsize (self, self.bbmins, self.bbmaxs);	// Restore BB size
	setorigin(self, self.origin);

	self.yaw_speed = 20;			// Average yaw rotation
	self.velocity = '0 0 0';		// Make sure stationary
	self.deadflag = DEAD_NO;		// used to stop death re-triggering
	self.liquidbase = self.liquidcheck = 0;		// Used for liquid content damage
	self.dmgcombined = self.dmgtimeframe = 0;	// combined damage over 0.1s
	self.pain_longanim = FALSE;		// No axe advantage
	
	self.gibhealth = -1000;			// Special death sequence
	self.pain_finished = self.attack_finished = 0;
	
	mammoth_shieldon();				// Locked resistance

	// Setup boss waves and overall health
	self.bosswave = 1;
	self.bosswavetotal = 6;
	self.bosswaveqty = 500;
	self.max_health = self.bosswavetotal * self.bosswaveqty;
	// Setup boss wave HP + trigger event
	mammoth_WaveSetupHP();

	// Check there is space for mammoth to spawn
	self.origin_z = self.origin_z + 1;
	droptofloor();
	if (!walkmove(0,0)) {
		// this condition should be a map spawn event only
		dprint ("\b[STUCK]\b "); dprint (self.classname);
		dprint (" at "); dprint (vtos(self.origin));
		dprint ("\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
	}

	// Check if defined tether target exists
	if (self.tethertarget != "") {
		// Find tether target entit
		self.movelast = find( world, targetname, self.tethertarget);
		// If does not exist, reset and generate one
		if (!self.movelast) self.tethertarget = "";
	}
	
	// Any custom tether target defined?
	if (self.tethertarget == "") {
		// Tether point, save for later
		self.movelast = spawn();
		self.movelast.owner = self;
		self.movelast.targetname = "mammoth_pole1";
		self.tethertarget = self.movelast.targetname;
		self.movelast.classtype = CT_TETHERENT;
		self.movelast.movetype = MOVETYPE_NONE;
		self.movelast.solid = SOLID_NOT;
		self.movelast.origin = self.origin;
		setsize (self.movelast, VEC_ORIGIN, VEC_ORIGIN);
	}
	// Debug marker (only developer = 1)
	spawn_marker(self.movelast.origin, SPNMARK_RED);
	
	// Setup blue shield glow
	mammothshield_setup();
	mammothshield_enable();
	
	// Default tether range (override for different room sizes)
	if (!self.tetherrange) self.tetherrange = MONAI_MAXMAMMOTH;
	if (self.tetherrange <= 64) self.tetherrange = 64;

	// Wait for trigger event to get off the floor
	self.think = mammoth_locked1;
	self.nextthink = time + 0.1;
	self.use = mammoth_wakeup;
	// Freeze mammoth in certain frame
	//mammoth_framecheck();
};

//======================================================================
/*QUAKED monster_mammoth (1 0 0) (-32 -32 -24) (32 32 96)
======================================================================*/
void() monster_mammoth =
{
	// Check all spawn exceptions (monsters.qc)
	if (monster_checkspawn() == TRUE) return;
	
	self.mdl = "progs/mon_mammoth.mdl";			// Mammoth Phase 1+2
	self.mdl2 = "progs/mon_mammothb.mdl";		// Mammoth Phase 3
	self.weaponglow = "progs/mon_mammoth_glow.mdl";	// Blue shield
	self.headmdl = "progs/mon_mammothd.mdl";		// Final dead chunk
	precache_model (self.mdl);
	precache_model (self.mdl2);
	precache_model (self.weaponglow);
	precache_model (self.headmdl);

	// Phase 2 gib models
	precache_model ("progs/gib_mammoth1.mdl");	// Front light panel
	precache_model ("progs/gib_mammoth2.mdl");	// Corner chunk 1
	precache_model ("progs/gib_mammoth3.mdl");	// Arm piece
	precache_model ("progs/gib_mammoth4.mdl");	// Front light panel
	precache_model ("progs/gib_mammoth5.mdl");	// Arm piece
	// Phase 3 gib models
	precache_model ("progs/gib_mammoth6.mdl");	// Back panel
	precache_model ("progs/gib_mammoth7.mdl");	// Feet jet
	precache_model ("progs/gib_mammoth8.mdl");	// Grenade panel
	precache_model ("progs/gib_mammoth9.mdl");	// Corner chunk 2
	precache_model ("progs/gib_mammoth10.mdl");	// Back Fan
	precache_model ("progs/gib_metal1.mdl");	// Generic metal chunk
	self.gibtype = GIBTYPE_METAL;				// All metal
	self.gibdir = MON_GIBFOUNTAIN;				// Velocity override

	// Robot talktalk
	self.idle_sound = "mammoth/idle1.wav";
	precache_sound (self.idle_sound);

	// Constant drone sound (background)
	precache_sound ("mammoth/idledrone2.wav");
	// Wake sequence
	precache_sound ("mammoth/wake_start.wav");
	// Arms movement/update
	precache_sound ("mammoth/arms_start.wav");
	precache_sound ("mammoth/arms_finish.wav");
	// Front lights on/off
	precache_sound ("mammoth/front_light1.wav");
	precache_sound ("mammoth/front_light2.wav");
	precache_sound ("mammoth/front_light3.wav");
	
	// Attacks - Lasers, Rockets and Grenades
	precache_model (MODEL_PROJ_LASER);
	precache_sound (SOUND_LASER_FIRE);
	precache_sound (SOUND_LASER_HIT);
	precache_sound (SOUND_LASER_RIC);
	precache_model (MODEL_PROJ_ROCKET);
	// Extra load/fire sounds (from Quoth MOD)
	precache_sound ("mammoth/rocket_load.wav");
	precache_sound ("mammoth/rocket_fire.wav");
	precache_sound ("mammoth/rocket_hit.wav");
	// Load flame sprites / sounds
	PreCache_Flame();
	precache_sound ("mammoth/flame_attack.wav");
	precache_sound ("mammoth/flame_fire.wav");
	precache_sound ("mammoth/flame_explode.wav");
	// Core sounds
	precache_sound ("mammoth/core_attack.wav");
	// Grenade sounds
	precache_sound ("mammoth/grenade_load.wav");
	precache_sound ("mammoth/grenade_fire.wav");

	// Pain, death and gibs!
	self.pain_sound = "mammoth/pain1.wav";
	precache_sound (self.pain_sound);
	self.death_sound = "mammoth/death1.wav";
	precache_sound (self.death_sound);
	precache_sound ("mammoth/explode_minor.wav");
	precache_sound ("mammoth/explode_major.wav");
	precache_sound ("mammoth/elec_arch1.wav");
	precache_sound ("mammoth/elec_arch2.wav");
	// Fired from boss between phases
	precache_model (MODEL_PROJ_PLASMA);
	// Mechanic on/off sounds for blue shield
	precache_sound ("mammoth/shield_on.wav");
	precache_sound ("mammoth/shield_off.wav");
	
	// Wakeup sound
	self.sight_sound = "mammoth/sight1.wav";
	precache_sound (self.sight_sound);
	
	self.solid = SOLID_NOT;			// No interaction with world
	self.movetype = MOVETYPE_NONE;	// Static item, no movement
	self.bbmins = '-32 -32 -24';	// Special Size
	self.bbmaxs = '32 32 96';
	self.bboxtype = BBOX_CUSTOM;
	self.flags = FL_MONSTER;		// Reset flag (no user settings)
	self.bossflag = TRUE;			// Boss flag (like FL_MONSTER)
	self.poisonous = FALSE;			// Robots are not poisonous
	self.deathstring = " was obliterated by the Mammoth\n";
	
	self.health = self.max_health = MEGADEATH;
	self.pain_finished = time + LARGE_TIMER;
	self.takedamage = DAMAGE_NO;
	
	self.gibhealth = MON_NEVERGIB;	// Special explosion death
	self.gibbed = FALSE;
	self.pain_flinch = 400;			// Really low chance of pain
	self.pain_longanim = FALSE;		// No long pain animation
	self.infightextra = 16;			// Extremely high infighting damage
	self.steptype = FS_FLYING;		// Ninja robot feet (jets)
	self.blockudeath = TRUE;		// No humanoid death sound
	self.no_liquiddmg = TRUE;		// Immune to slime/lava
	self.meleeoffset = '70 180 290';// Jet feet circular positions
	self.attack_offset = '0 0 0';	// Side (left/right) fire offset
	self.attack_explosive = TRUE;	// Rockets = Phase 2, Grenades = Phase 3
	if (!self.attack_expflame) self.attack_expflame = 24;

	// Setup default Proj Count = Base (X) * (Skill * Y) Maximum = Z
	if (CheckZeroVector(self.proj_attqty)) self.proj_attqty = '0 0 14';
	self.part_exitpuff = self.part_exitsound = TRUE;

	if (!self.height) self.height = 64; // Custom attack height (min = 32)
	if (self.height < 32) self.height = 32;

	if (!self.volume) self.volume = 1;	// Drone volume (+range checks)
	if (self.volume < 0) self.volume = 0;
	if (self.volume > 1) self.volume = 1;
	
	// Check passive system for exceptions
	setup_passivestate_boss(self);

	// default = No think functions
	self.th_checkattack = mammothCheckAttack;
	self.th_stand = self.th_walk = self.th_run = SUB_Null;
	self.th_melee = self.th_missile = self.th_summon = SUB_Null;
	self.th_die = SUB_Null;
	self.th_pain = SUB_Null_pain;

	self.classtype = CT_MONMAMMOTH;
	self.classgroup = CG_ROBOT;
	self.classmove = MON_MOVEFLY;

	// No targetname = no trigger!
	if (self.targetname == "") {
		dprint("\b[MAMMOTH_BOSS]\b Missing trigger name!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		return;
	}

	total_monsters = total_monsters + 1;
	self.think = mammoth_start;
	self.nextthink = time + 0.1;
};
