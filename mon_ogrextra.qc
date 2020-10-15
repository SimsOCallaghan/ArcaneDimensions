//======================================================================
// From the crazy mind of Madfox, comes fishing ogre!?!
//======================================================================
float OGREFISH_FISHY = 0;
float OGREFISH_FISHING = 19;
float OGREFISH_CATCH = 79;
float ANIMATION_OGREFLAP = 18;
float ANIMATION_OGREFISH = 59;
float ANIMATION_OGRECATCH = 25;

//----------------------------------------------------------------------
// Special idle animation - Flappy the fish waggles tail
//----------------------------------------------------------------------
void() ogre_flappyfish =
{
	// If dead, no more updates
	if (self.health < 1) return;

	self.nextthink = time + 0.1;
	self.frame = OGREFISH_FISHY + self.walkframe;

	// Check for special frame conditions
	if (self.walkframe == 0)
		sound (self, CHAN_VOICE, "ogre/ogrefish_flappy.wav", 1, ATTN_NORM);
	
	// Move frame forward, check for conditions
	self.walkframe = self.walkframe + 1;
	if (self.walkframe > ANIMATION_OGREFLAP) {
		self.walkframe = 0;
		self.think = self.th_altstand;
	}
	else self.think = ogre_flappyfish;
};

//----------------------------------------------------------------------
// Special idle animation - Ogre finally catches something!
//----------------------------------------------------------------------
void() ogre_catchfish =
{
	// If dead, no more updates
	if (self.health < 1) return;

	self.nextthink = time + 0.1;
	self.frame = OGREFISH_CATCH + self.walkframe;

	// Check for special frame conditions
	if (self.walkframe == 6)
		sound (self, CHAN_VOICE, "ogre/ogrefish_out.wav", 1, ATTN_NORM);
	if (self.walkframe == 24)
		sound (self, CHAN_VOICE, "ogre/ogrefish_in.wav", 1, ATTN_NORM);
	
	// Move frame forward, check for conditions
	self.walkframe = self.walkframe + 1;
	if (self.walkframe > ANIMATION_OGRECATCH) {
		self.walkframe = 0;
		self.think = self.th_altstand;
	}
	else self.think = ogre_catchfish;
};

//----------------------------------------------------------------------
void() ogre_fishing =
{
	// If dead, no more updates
	if (self.health < 1) return;

	self.idlebusy = FALSE;
	self.nextthink = time + 0.1;
	self.frame = OGREFISH_FISHING + self.walkframe;

	// Check for fishing idle animations
	if (self.walkframe == 0) {
		self.lip = random();
		// Finally caught a fish?
		if (self.lip < 0.1) {
			self.think = ogre_catchfish;
			self.idlebusy = TRUE;
		}
		// Flappy the fish gasping for air
		else if (self.lip < 0.2) {
			self.think = ogre_flappyfish;
			self.idlebusy = TRUE;
		}
		// Classic ogre idle + water
		else if (self.lip < 0.3) 
			sound (self, CHAN_VOICE, "ogre/ogrefish_idle.wav", 1, ATTN_NORM);
	}
	
	// Ghost version updates alpha and spawns particles
	if (self.spawnflags & MON_GHOST_ONLY) {
		// Is ogre setup invisible?
		if (self.alpha < 1) {
			// Wait for the ogre to get into position
			if (self.respawn_time < time) {
				// exponential fade in model alpha 
				self.alpha = self.alpha + self.lefty;
				self.lefty = self.lefty + self.lefty;
				if (self.alpha >= 1) self.alpha = 1;
			}
		}
		else {
			// Model is all screwed up, with loads of extra surfaces
			// cannot do alpha sparkle because of back surface problem
			//self.alpha = 0.5 + (0.1*random());
			self.pos1 = '0 0 0';
			self.pos1_x = crandom()*16;
			self.pos1_y = crandom()*16;
			self.pos1_z = crandom()*24;
			if (random() < 0.5) 
				particle_explode(self.origin+self.pos1, 2, 1, PARTICLE_BURST_WHITE, PARTICLE_BURST_LOSTUP);
		}
	}

	if (self.idlebusy == FALSE) {
		// Move frame forward, check for conditions
		self.walkframe = self.walkframe + 1;
		if (self.walkframe > ANIMATION_OGREFISH) self.walkframe = 0;
		self.think = ogre_fishing;
	}
};

//----------------------------------------------------------------------
void(entity inf, entity att, float dam) ogre_fishpain = {ogre_fishwakeup();};
void() ogre_fishdie = {};

//----------------------------------------------------------------------
void() ogre_fishsetup =
{
	// Setup ghost version (no pain or death)
	if (self.spawnflags & MON_GHOST_ONLY) {
		self.respawn_time = time + 0.3;	// Wait to get into position
		self.lefty = 0.01;				// Exponential increase
		self.solid = SOLID_NOT;			// No interaction with world
		self.movetype = MOVETYPE_NONE;	// Static item, no movement
		self.takedamage = DAMAGE_NO;
		self.noradiusdmg = TRUE;
		self.gibhealth = MON_NEVERGIB;
		self.health = LARGE_TIMER;
		self.use = SUB_Null;
	}
	else {
		// Take direct damage only and grenades bounce!
		self.takedamage = DAMAGE_YES;
		self.noradiusdmg = TRUE;
		self.health = MEGADEATH;
		self.use = ogre_fishwakeup;
		
		// Create a temporary entity to fill up space behind ogre
		// Prevent anthing getting in the way when ogre wakes up
		if (!self.attachment) {
			self.attachment = spawn();
			setmodel(self.attachment, MODEL_EMPTY);
			setorigin(self.attachment, self.origin);
			setsize (self.attachment, self.bbmins, self.bbmaxs);
			self.attachment.solid = SOLID_BBOX;
			self.attachment.movetype = MOVETYPE_STEP;
		}
	}
	
	setmodel(self, self.weaponglow);	// Setup fishing model pose
	self.pos1 = self.origin;			// Save current origin for later
	if (self.spawnflags & MON_GHOST_ONLY) self.skin = 2;
	
	// Move ogre into fishing animation position
	makevectors(self.angles);
	self.pos2 = self.origin + attack_vector('36 0 -24');
	setorigin(self, self.pos2);
	// Got to reset bounding box after model change
	setsize (self, self.bbmins, self.bbmaxs);
	self.walkframe = 0;
	ogre_fishing();
};

//----------------------------------------------------------------------
void() monster_ogre_fishing =
{
	// Check all spawn exceptions (monsters.qc)
	if (monster_checkspawn() == TRUE) return;
		
	// Precache basic ogre models and sounds
	monster_ogre_precache();

	// Extra fishing ogre precache stuff
	self.weaponglow = "progs/mon_ogrefish.mdl";
	precache_model (self.weaponglow);
	precache_sound ("ogre/ogrefish_out.wav");
	precache_sound ("ogre/ogrefish_in.wav");
	precache_sound ("ogre/ogrefish_idle.wav");
	precache_sound ("ogre/ogrefish_flappy.wav");

	self.solid = SOLID_NOT;			// No interaction with world
	self.movetype = MOVETYPE_NONE;	// Static item, no movement
	if (self.bboxtype < 1) self.bboxtype = BBOX_WIDE;
	self.gibhealth = -80;
	self.gibbed = FALSE;
	self.pain_flinch = 1;			// Pain is the wakeup trigger
	self.pain_longanim = FALSE;		// Cannot be chopped with shadow axe
	self.steptype = FS_TYPESLOW;	// Small sounding feet
	self.no_zaware = FALSE;			// Fishing ogre has perfect aim!
	self.bouncegrenade = TRUE;		// Grenades bounce off!
	self.meleerange = MONAI_MELEEOGRE;	// Chainsaw range
	self.exactskin = 0;				// Skin defined by spawnflag
	self.noinfighting = TRUE;		// No infighting
	self.pain_ignore = TRUE;		// Will not wake up from monsters
	self.movespeed = 0;				// This is not a turret
	self.frame = OGREFISH_FISHING;	// Start in fishing frame
	self.deathstring = " was reeled in by a Fishing Ogre\n";

	// Remove spawnflag options not needed for this monster
	self.lip = 0;
	// Ghost version has unique skin, cannot have green version as well
	if (self.spawnflags & MON_GHOST_ONLY) self.lip = self.lip | MON_GHOST_ONLY;
	else if (self.spawnflags & MON_OGRE_GREEN) self.lip = self.lip | MON_OGRE_GREEN;
	// Classic check for fx/spawn options
	if (self.spawnflags & MON_SPAWN_NOGFX) self.lip = self.lip | MON_SPAWN_NOGFX;
	if (self.spawnflags & MON_SPAWN_DELAY) self.lip = self.lip | MON_SPAWN_DELAY;
	self.spawnflags = self.lip;
	
	// Special event monster has unique HP setup
	if (self.spawnflags & MON_OGRE_GREEN) {
		// Tons of rockets
		if (self.ammo_rockets < 0) self.ammo_rockets = 0;
		else if (self.ammo_rockets == 0) self.ammo_rockets = 6;
		self.health = 350;		// Much stronger
		self.skin = 1;			// Green (Rogue) skin
	}
	else {
		// More rockets than fish!
		if (self.ammo_rockets < 0) self.ammo_rockets = 0;
		else if (self.ammo_rockets == 0) self.ammo_rockets = 4;
		self.health = 150;		// Lower HP than regular
	}

	// Fishing ogre can never uses nails, grenades only
	self.spawnflags = self.spawnflags - (self.spawnflags & MON_OGRE_NAIL);
	
	// Always reset Ammo Resistance to be consistent
	self.resist_shells = self.resist_nails = 0;
	self.resist_rockets = 1;	// Rocket resistance
	self.resist_cells = 0;

	self.th_checkattack = OgreCheckAttack;
	self.th_stand = self.th_walk = self.th_run = ogre_fishsetup;
	self.th_altstand = ogre_fishing;
	// Setup ghost version (no pain or death)
	if (self.spawnflags & MON_GHOST_ONLY) {
		self.th_pain = SUB_Null_pain;
		self.th_die = SUB_Null;
		self.headmdl = "";
	}
	else {
		self.th_pain = ogre_fishpain;
		self.th_die = ogre_fishdie;
	}

	self.classtype = CT_MONOGREFISH;
	self.classgroup = CG_OGRE;			// One big happy ogre family!
	self.classmove = MON_MOVEWALK;

	monster_start();
}

//----------------------------------------------------------------------
void() monster_ogre_fishing_ghost =
{
	// Special spawnflag (code only)
	self.spawnflags = self.spawnflags | MON_GHOST_ONLY;
	// Always no monster count
	self.nomonstercount = TRUE;
	// Start model invisible (to prevent snapping)
	self.alpha = 0.01;
	monster_ogre_fishing();
};
