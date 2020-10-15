/*======================================================================
 TRIGGER FUNCTIONS
======================================================================*/
float TRIG_SPAWNBUBBLES = 2;	// Produce bubbles
float TRIG_SECRETNOMSG = 2;		// No default message
float TRIG_TELEPLAYER = 1;		// Player only
float TRIG_TELESILENT = 2;		// No teleport sound
float TRIG_TELEALWAYSON = 4;	// Trigger teleports starts on
float TRIG_TELEINSTANT = 8;		// Trigger instant teleport
float TRIG_TELEPROJECTILE = 16;	// Allow projectiles to use teleportors
float TRIG_NOTELESOUNDFX = 32;	// No teleport sound + FX
float TRIG_HURTMONSTER = 4;		// Only hurt monsters
float TRIG_HURTFALLING = 32;	// Only hurt if player falling
float TRIG_PUSHONCE = 1;		// Switch off after one use
float TRIG_PUSHSILENT = 2;		// No wind sound for player
float TRIG_PUSHNOMONSTER = 4;	// Monsters cannot use this push trigger
float TRIG_CONVMONSTER = 2;		// Conveyor moving monsters
float TRIG_CONVITEM = 4;		// Conveyor moving items
float TRIG_CONVPUSHABLE = 8;	// Conveyor moving pushables
float TRIG_LADDERVELOCITY = 4;	// Enable velocity ladder system
float TRIG_LADDERFTESKIN = 8;	// Enable FTE skin ladder system
float TRIG_CMAPNOPAUSE = 1;		// Change level, no info screen, next map
float TRIG_CMAPRESETINV = 2;	// Reset inventory (shotgun+25shells)
float TRIG_CMAPSECSPAWN = 4;	// Spawn at the second spawn point
float TRIG_TAKEARTID = 2;		// Take artifacts, ID set
float TRIG_TAKEARTAD = 4;		// Take artifacts, AD set
float TRIG_TAKEARTVANIA = 8;	// Take artifacts, Vania set
float TRIG_TAKEARTALL = 14;		// All artifacts (2+4+8)
float TRIG_MONJUMPFLY = 2;		// Will affect flying units
float TRIG_MONJUMPSWIM = 4;		// Will affect swimming units
float TRIG_TSOUNDWGEO = 4;		// World Geometry interaction
float TRIG_TSOUNDDRAIN = 8;		// Drain effect when disabled
float TRIG_GRAVITYSERVER = 2;	// Change the server gravity
float TRIG_GRAVITYPLAYONLY = 4;	// Only work with the player
float TRIG_GRAVITYMONONLY = 8;	// Only work with monsters
float TRIG_GRAVITYRESET = 16;	// Reset entities to default gravity
float TRIG_VELPLAYER = 1;		// Player only trigger
float TRIG_VELMONSTER = 2;		// Monster only trigger
float TRIG_VELGRENADE = 4;		// Grenade projectile only trigger
float TRIG_VELROCKET = 8;		// Rocket projectile only trigger
float TRIG_VELEXCEPTION = 15;	// All exceptions merged together
float TRIG_VOIDNOCLIENT = 1;	// Clients will suffer no damage
float TRIG_VOIDNOMONSTER = 2;	// Monsters will be immune to the void
float TRIG_VOIDNOAMMO = 4;		// Ammo projectiles will pass through
float TRIG_VOIDNOGG = 8;		// Minion eggs will ignore the void
float TRIG_VOIDNOTEMP = 16;		// Temporary entities will exist longer
float TRIG_VOIDNOITEM = 32;		// All items will carry on as before

//----------------------------------------------------------------------
// If a dead body has touched a trigger, setup removal
//----------------------------------------------------------------------
float(entity body_ent, float body_death) trigger_check_body =
{
	if (body_ent.flags & FL_MONSTER && body_ent.deadflag == DEAD_DEAD) {
		body_ent.deadflag = body_death;
		body_ent.touchedvoid = TRUE;
		return TRUE;
	}
	return FALSE;
};

//----------------------------------------------------------------------
// Setup default dmg and dmgskill entity keys (used for hurt/teleport)
//----------------------------------------------------------------------
void(float dmgdef) trigger_dmgsetup =
{
	// Check for errors and setup default
	if (self.dmg < 0) self.dmg = 0;
	else if (self.dmg == 0) self.dmg = dmgdef;
	
	// Check for skill damage errors
	if (self.dmgskill_x < 0) self.dmgskill_x = 0;	// Skill 0
	if (self.dmgskill_y < 0) self.dmgskill_y = 0;	// Skill 1
	if (self.dmgskill_z < 0) self.dmgskill_z = 0;	// Skill 2+3
	
	// If no skill damage setup, use dmg default
	if (CheckZeroVector(self.dmgskill)) {
		self.dmgskill_x = self.dmgskill_y = self.dmgskill_z = self.dmg;
	}
};

//----------------------------------------------------------------------
float() trigger_dmgquery =
{
	// Return damage based on current skill level
	// Expects the dmgskill entity key to be setup beforehand
	if (skill == SKILL_EASY) return self.dmgskill_x;
	else if (skill == SKILL_NORMAL) return self.dmgskill_y;
	else return self.dmgskill_z;
};

//----------------------------------------------------------------------
// Setup/Spawn/Remove bubbles inside a trigger volume
//----------------------------------------------------------------------
void() trigger_setup_bubbles =
{
	// Quake compilers can add the style key to any entity connected
	// to dynamic lights, this is usually 32-64 in value and should
	// not interfere, but never use style > 32 for any values
	if (self.style == 1) self.mdl = "progs/s_bubble_grey.spr";
	else if (self.style == 2) self.mdl = "progs/s_bubble_brnd1.spr";
	else if (self.style == 4) self.mdl = "progs/s_bubble_grn1.spr";
	else if (self.style == 5) self.mdl = "progs/s_bubble_red1.spr";
	else if (self.style == 6) self.mdl = "progs/s_bubble_brnd2.spr";
	else if (self.style == 7) self.mdl = "progs/s_bubble_pinkyel.spr";
	else if (self.style == 8) self.mdl = "progs/s_bubble_brnl1.spr";
	else if (self.style == 9) self.mdl = "progs/s_bubble_purp1.spr";
	else if (self.style == 10) self.mdl = "progs/s_bubble_purp2.spr";
	else if (self.style == 11) self.mdl = "progs/s_bubble_brnl2.spr";
	else if (self.style == 12) self.mdl = "progs/s_bubble_grn2.spr";
	else if (self.style == 13) self.mdl = "progs/s_bubble_yellow.spr";
	else if (self.style == 14) self.mdl = "progs/s_bubble_blue2.spr";
	else if (self.style == 15) self.mdl = "progs/s_bubble_red2.spr";
	else self.mdl = "progs/s_bubble_blue1.spr";
	precache_model(self.mdl);
	
	// Setup defaults for healing bubbles
	self.waitmin = self.bubble_count = 0;		// Reset counters
	if (!self.count) self.count = 5;			// max active bubbles
	if (!self.height) self.height = self.size_z;
	if (self.height < 64) self.height = 64;		// min top of volume
	self.oldorigin = bmodel_origin(self);
	self.oldorigin_z = self.mins_z;
	self.t_width = (self.size_x/2);
	self.t_length = (self.size_y/2);
	// Default spawn rate for bubbles
	if (self.yaw_speed <= 0) self.yaw_speed = 0.5;
};

//----------------------------------------------------------------------
void() trigger_remove_bubble =
{
	if (other == self.owner) return;			// Touching self, do nothing
	if (other.solid == SOLID_TRIGGER) return;	// trigger field, do nothing

	self.touch = SUB_Null;
	if (self.owner.bubble_count > 0) 
		self.owner.bubble_count = self.owner.bubble_count - 1;
	remove(self);
};

//----------------------------------------------------------------------
void() trigger_update_bubble =
{
	// The size of the trigger is the default height for the bubbles
	// to raise up, or The height can be specified as a value

	self.lefty = fabs(self.origin_z - self.owner.oldorigin_z);
	if (self.lefty > self.owner.height) { 
		trigger_remove_bubble(); 
	}
	else {
		// Wobble on the X / Y axis as the bubble raises up
		self.velocity_x = self.velocity_y = 0;
		if (random() < 0.5) self.velocity_x = self.velocity_x + crandom()*4;
		else self.velocity_y = self.velocity_y + crandom()*4;
		// Make the bubble raise faster by random amounts
		self.velocity_z = self.velocity_z + random();
		// Keep updating bubble, 15 updates is the limit
		self.nextthink = time + 0.5 + random()*0.5;
		if (self.count < 15) self.count = self.count + 1;
		else trigger_remove_bubble();
	}
};

//----------------------------------------------------------------------
void() trigger_spawn_bubbles =
{
	local entity bubble;
	
	if (self.estate & ESTATE_BLOCK) return;
	if ( !(self.spawnflags & TRIG_SPAWNBUBBLES) ) return;

	if (self.bubble_count < self.count) {
		self.bubble_count = self.bubble_count + 1;

		bubble = spawn();
		bubble.owner = self;
		bubble.classname = "misc_bubble";
		bubble.classtype = CT_BUBBLE;
		bubble.classgroup = CG_TEMPENT;
		bubble.movetype = MOVETYPE_NOCLIP;
		bubble.solid = SOLID_TRIGGER;
		setmodel(bubble, self.mdl);
		bubble.frame = rint(random() * 3);		// Light/dark colours
		setsize (bubble, VEC_ORIGIN, VEC_ORIGIN);
		bubble.origin_x = self.oldorigin_x + crandom()*self.t_width;
		bubble.origin_y = self.oldorigin_y + crandom()*self.t_length;
		bubble.origin_z = self.oldorigin_z;
		setorigin(bubble, bubble.origin);
		bubble.velocity = vecrand(0,5,TRUE);
		bubble.velocity_z = 10 + random()*15;
		bubble.count = rint(random()*4);

		bubble.nextthink = time + 0.5 + random()*0.5;
		bubble.think = trigger_update_bubble;
		bubble.touch = trigger_remove_bubble;
	}

	// Keep spawning bubbles until told not too!
	self.think = trigger_spawn_bubbles;
	self.nextthink = time + self.yaw_speed + random()*self.yaw_speed;
};

//======================================================================
/*QUAKED trigger_multiple (0.5 0 0.5) ? NOTOUCH x DEVMODE x MODCHECK MONSTERS STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Variable sized bmodel that uses multiple times
------- KEYS --------
targetname : trigger entity (works with entity state system)
target  : trigger all these targets
health  : Can be damaged instead of touched
wait    : time between re-triggering
delay   : delay before firing (after being triggered)
count   : >0 = number of time can fire before switching off
angle   : Facing Direction for trigger to work, use "360" for angle 0.
sounds  : 1=Secret,2=talk(def),3=switch,4=silent,5=custom,6=secret2
noise   : custom sound to play when triggered
message : message to display when triggered
-------- SPAWNFLAGS --------
NOTOUCH : can only be triggered via other entities
DEVMODE  : Will only trigger if developer mode active
MODCHECK : Will remove this entity if THIS mod is active
MONSTER  : can be touched/triggered by monsters
STARTOFF : Requires trigger to activate
------- NOTES --------
Variable sized bmodel that uses multiple times

======================================================================*/
void() trigger_multiple =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors
	if (check_bmodel_notouch()) return;	// NO touch + NO targetname!
	if (check_bmodel_modver()) return;	// Check mod version correct
	trigger_bmodel_sounds();			// Precache any sounds

	self.classtype = CT_TRIGMULTI;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();

	if (!self.wait) self.wait = 0.2;
	
	// Setup Entity State functionality
	trigger_bmodel_setup();
};

//======================================================================
/*QUAKED trigger_once (0.5 0 0.5) ? NOTOUCH x DEVMODE INVIEW MODCHECK MONSTER STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Variable sized bmodel that uses once
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target  : trigger all these targets
health  : Can be damaged instead of touched
wait    : Always -1
delay : delay before firing (after being triggered)
angle   : Facing Direction for trigger to work, use "360" for angle 0.
sounds  : 1=Secret,2=talk(def),3=switch,4=silent,5=custom,6=secret2
noise   : custom sound to play when triggered
message : message to display when triggered
t_length : Inview distance (less than) to activate trigger
-------- SPAWNFLAGS --------
NOTOUCH  : can only be triggered via other entities
DEVMODE  : Will only trigger if developer mode active
INVIEW   : Player has to be infront and look at trigger (>30 & <60)
MODCHECK : Will remove this entity if THIS mod is active
MONSTER  : can be touched/triggered by monsters
STARTOFF : Requires trigger to activate
-------- NOTES --------
Variable sized bmodel that uses once

======================================================================*/
void() trigger_once =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors
	if (check_bmodel_notouch()) return;	// NO touch + NO targetname!
	if (check_bmodel_modver()) return;	// Check mod version correct
	trigger_bmodel_sounds();			// Precache any sounds

	self.classtype = CT_TRIGONCE;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();

	self.wait = -1;

	// Inview triggers need to start delayed, high cpu functions
	if (self.spawnflags & TRIG_INVIEW) {
		self.spawnflags = self.spawnflags | ENT_STARTOFF;
		// Cannot have inview triggers touched by monsters
		self.spawnflags = self.spawnflags - (self.spawnflags & TRIG_MONSTERS);
	}

	// Setup Entity State functionality
	trigger_bmodel_setup();
};

//======================================================================
/*QUAKED trigger_secret (.5 0 .5) ? NOTOUCH NOMSG x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Update map secret counter
------- KEYS --------
targetname : trigger entity (works with entity state system)
target  : name of target(s) to trigger
health  : Can be damaged instead of touched
wait    : Always -1
angle   : Facing Direction for trigger to work, use 360 for angle 0.
sounds  : 1=Secret(def),2=talk,3=switch,4=silent,5=custom,6=secret2
noise   : custom sound to play when triggered
message : message to display when triggered
-------- SPAWNFLAGS --------
NOTOUCH : can only be triggered via other entities
NOMSG   : Remove/Block any trigger secret message
STARTOFF : Requires trigger to activate
------- NOTES --------
Update map secret counter

======================================================================*/
void() trigger_secret =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors
	if (check_bmodel_notouch()) return;	// NO touch + NO targetname!

	if (self.sounds == 0) self.sounds = 1;
	trigger_bmodel_sounds();				// Precache any sounds

	self.classtype = CT_TRIGSECRET;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();

	self.wait = -1;							// Trigger ONCE
	self.oldorigin = bmodel_origin(self);	// Save XYZ location

	self.count = 1;		// Add 1 secret
	total_secrets = total_secrets + self.count;
	if (!self.message) self.message = "You found a secret area!";
	if (self.spawnflags & TRIG_SECRETNOMSG) self.message = "";

	// Cannot have secret triggers touched by monsters
	self.spawnflags = self.spawnflags - (self.spawnflags & TRIG_MONSTERS);

	// Setup Entity State functionality
	trigger_bmodel_setup();
};

//======================================================================
/*QUAKED trigger_teleport (0.5 0 0.5) ? PLAYER_ONLY SILENT STARTON INSTANT PROJECTILES NOTELEFX STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Teleport player/monsters to target location
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target  : Points to info_teleport_destination entity
target2 : Can be used to fire additional targets
wait    : -1 = teleport only triggers once (def=0)
wait2   : -1 = target2 only fires once (def=-1)
angle   : Facing Direction for trigger to work, use "360" for angle 0.
speed   : forward momentum speed after teleporting (def=300)
volume  : teleporter hum sound volume (def=0.5)
noise   : custom sound to play when active (must be looped, def=hum1.wav)
waitmin : the length of the custom sound (def=3.622 for hum1.wav)
waitmin2: Time between teleport sound/fx (def=0.2s) being played
waitmin3: Alpha value for debug lvl showing triggers ingame (def=0.75)
dmg     : damage from using the teleport trigger (def=0)
dmgskill: damage based on skill level X=Easy, Y=Normal, Z=Hard/NM (def=0,0,0)
debuglvl: shows extra info 1=impact markers, 2=impact arrows, 3=console text
telefixangle    : 1 = Fixed angle direction for instant teleporters
no_trackondeath : 1 = Homing projectiles don't stop tracking (def=0 off)
-------- SPAWNFLAGS --------
PLAYER_ONLY : Can only be used by players (nothing else)
SILENT      : No teleporter ambient sound regardless of state
STARTON     : Will start active regardless of targetname setting
INSTANT     : Instantly teleport (no adjustment to teleport velocity)
PROJECTILES : Allow projectiles to use regular/instant teleporters 
NOTELEFX    : No player sound + FX when teleporting entities
STARTOFF    : Starts off and waits for trigger
-------- NOTES --------
Teleport player or monsters to target location (fixed or variable)
if targetname is setup, the teleporter requires a trigger to activate
This entity cannot be damaged and is always touchable once activated
Can be switched on/off using entity state system (including tele hum sound)

======================================================================*/
void() trigger_teleport_sound =
{
	// Has the original bmodel trigger been deleted!?!
	if (!self.owner) {
		// Clear sound channel with silence (full volume)
		sound (self, CHAN_VOICE, SOUND_EMPTY, 1, ATTN_NORM);
		return;
	}
	// Has the trigger been hidden/removed?
	if (self.owner.attack_finished > time) return;
	
	// The Quake sound system is really basic and dumb! :)
	// Originally the sound of the teleporter was setup as an ambientsound,
	// which always play, loop and cannot be turned off!
	//
	// Normal sounds are ONLY active when the player is in the same portal!
	// This is probably an optimization (engine) thing to save time 
	// constantly checking attenuation levels
	//
	// The teleporter sound is manually looped because of portal problems
	// and that the trigger can be turned on / off.
	// The waitmin parameter has to match the length of the sound, otherwise
	// the looping will literally sound odd

	// Keep checking for any updates
	self.nextthink = time + 0.1;
	self.think = trigger_teleport_sound;

	// Has the trigger changed state recently?
	if (self.owner.estate != self.estate) {
		// Update sound emitter estate
		self.estate = self.owner.estate;
		
		// If teleport off or disabled, do nothing
		if (self.estate & ESTATE_BLOCK) {
			// Clear sound channel with silence (full volume)
			sound (self, CHAN_VOICE, SOUND_EMPTY, 1, ATTN_NORM);
			self.fly_sound = LARGE_TIMER;
		}
		// trigger has been switched on, reset sound
		else self.fly_sound = 0;
	}
	
	// Play the sound if loop has finished or been reset
	if (self.fly_sound < time ) {
		self.fly_sound = time + self.owner.waitmin;
		sound (self, CHAN_VOICE, self.owner.noise, self.owner.volume, ATTN_STATIC);
	}
};

//----------------------------------------------------------------------
// _use is main path for the closet monster setup where the trigger is fired
// and then anything touching the trigger 0.2s later is teleported
// This forces all touch triggers in a map to check what they are touching!
//----------------------------------------------------------------------
void() trigger_teleport_use =
{
	local entity teledest_ent;
	
	// Custom destination request
	if (other.teledest > 0) {
		// Finds the FIRST teleporter target in entity list
		teledest_ent = find (world, targetname, self.target);
		while(teledest_ent) {
			// Found a teleporter destination match?
			if (teledest_ent.teledest == other.teledest) {
				self.goalentity = teledest_ent;
				// Stop searching entity list
				teledest_ent = world;
			}
			// Keep search in destination entity list
			else teledest_ent = find(teledest_ent, targetname, self.target);
		}
	}
	
	// Deal with START OFF functionality first
	if (self.spawnflags & ENT_STARTOFF) {
		// Remove start off flag and switch on entity
		self.spawnflags = self.spawnflags - ENT_STARTOFF;
		self.estate_on();
		return;
	}
	// Block entity state DISABLE
	if (self.estate & ESTATE_DISABLE) return;
	// Original AD behaviour; use/trigger = switch on teleport
	if (self.estate & ESTATE_OFF) self.estate_on();

	// Force retouch is really hard on the engine because EVERY trigger
	// in the map is re-checked for any touching objects
	force_retouch = 2;
	self.nextthink = time + 0.2;
	self.think = SUB_Null;
};

//----------------------------------------------------------------------
void() trigger_teleport_on =
{
	// Only switches teleport on, does not force retouch
	// Need to trigger/use teleporter to get closet monster behaviour
	self.estate = ESTATE_ON;
	self.state = STATE_ON;
};

//----------------------------------------------------------------------
void() trigger_teleport_off =
{
	self.estate = ESTATE_OFF;
	self.state = STATE_OFF;
};

//----------------------------------------------------------------------
void() trigger_teleport_debug =
{
	// Exceptions
	if (self.estate & ESTATE_BLOCK) return;		// Entity state blocked
	if (self.debuglvl < 1) return;				// Check for debug mode
	if (!self.goalentity) return;				// Always need target
	if (self.alpha) return;						// Alpha set already
	
	// Reveal trigger surface
	self.alpha = self.waitmin3;
	setmodel (self, self.mdl);
	setsize(self, self.bbmins, self.bbmaxs);
	// Reveal destination surface, check for bmodel setup
	if (self.goalentity.bsporigin) {
		self.goalentity.alpha = self.waitmin3;
		setmodel (self.goalentity, self.goalentity.mdl);
		setsize(self.goalentity, self.goalentity.bbmins, self.goalentity.bbmaxs);
	}
};

//----------------------------------------------------------------------
void() trigger_teleport_touch =
{
	if (self.estate & ESTATE_BLOCK) return;		// Entity off/disabled?
	// Use to block ent_startoff, but estate_block takes care of it
	if (self.attack_finished > time) return;	// Trigger once?
	if (self.state == STATE_OFF) return;		// Waiting for trigger?
	if (!self.goalentity) return;				// Always need target

	// Is the teleporter designed for players only?
	if (self.spawnflags & TRIG_TELEPLAYER && !(other.flags & FL_CLIENT)) return;
	// only teleport living creatures and monsters (mostly)
	if (other.health < 1 || other.solid != SOLID_SLIDEBOX) {
		// Let projectiles work with teleporters
		if (!(self.spawnflags & TRIG_TELEPROJECTILE)) return;
	}

	// Did the trigger have an angle key setup?
	if (!CheckZeroVector(self.movedir)) {
		// Projectiles (no health) are based on velocity
		if (!other.health) self.pos1 = vectoangles(other.velocity);
		// Player/Monster can use angles field instead
		else self.pos1 = other.angles;
		makevectors (self.pos1);
		// Create a dot product of angles vector
		self.ideal_yaw = self.movedir * v_forward;
		// Is angle behind target angle (180 degree arc)
		if (self.ideal_yaw < 0) return;
	}
	
	// New AD feature, fire targets on teleporter destination
	if (self.goalentity.target != "") {
		trigger_strs(self.goalentity.target, other);	// Fire all targets
		if (self.wait2 < 0) self.goalentity.target = "";// only work once
	}

	//------------------------------------------------------------------
	// Fire all targets on trigger teleporter entity (ID code)
	// not sure why? the target *should* be pointing at info_destination
	// Mapper could use killtarget or message strings instead
	// Can use target2 for additional triggers on teleport (new feature)
	SUB_UseTargets ();

	//------------------------------------------------------------------
	// POS1 = touching entity origin (starting point)
	// POS2 = destination origin (can be bmodel or point entity)
	// POS3 = Spawn effect for destination (v_forward*32)
	
	self.pos1 = other.origin;
	if (self.goalentity.bsporigin) self.pos2 = self.goalentity.oldorigin;
	else self.pos2 = self.goalentity.origin;

	// Save for later (debuglvl)
	self.dest0 = vectormod(other.angles);

	//------------------------------------------------------------------
	// I was under the impression that makevector/vectoangles was a loop.
	// This is not the case and the QC commands are not obvious about it
	// 
	// makevectors + v_angle + bsp + spr all pitch (X) one way
	// vectoangles + mdl pitch (X) the other way - thanks spike for info
	//
	// makevectors (self.angles);
	// self.velocity = v_forward * self.speed;
	// self.finalangle = vectoangles(self.velocity);
	//
	// self.angles should equal self.finalangle, but they do not!
	// The result of vectoangles will be reversed on the X axis
	// 
	// This has implications for when trying to create angles or direction
	// vectors for teleporter destination entities. Ideally the best
	// solution is that the destination entity has a target because that is
	// easier to create a direction vector from. Using angles to create
	// the direction vector will have the reverse X axis problem.
	//
	//------------------------------------------------------------------
	// Instant teleporter behave differently depending on what is being
	// teleported through them.
	// Entities with player or monster flags, will only be affected
	// by Y axis to prevent model distortion.
	// Anything else (projectiles mostly) will be allowed to rotate
	// on any XYZ axis because they do not need to be upright for
	// collision and movement reasons.
	//
	//------------------------------------------------------------------
	if (self.spawnflags & TRIG_TELEINSTANT) {
		// Check for any angle update (stored in mangle)
		if (!CheckZeroVector(self.goalentity.mangle)) {
			//--------------------------------------------------------------
			// TYPE 1 Instant teleport - Player / Monster (Y axis ONLY)
			//--------------------------------------------------------------
			if (other.flags & FL_CLIENT || other.flags & FL_MONSTER) {
				// Work out XYZ difference between touch point and trigger origin
				// The difference is a relative co-ordinates around 0,0,0
				self.pos4 = self.oldorigin - self.pos1;
				self.dest1 = vectormod(self.goalentity.mangle);
				// Rotate destination offset around 0,0,0 (Y axis angle only)
				// Uses Z axis for rot function because its a vector, not an angles
				self.pos5 = mathlib_vectorotateZ(self.pos4, self.dest1_y);
				// Update destination origin with XYZ rotation offset
				self.pos2 = self.pos2 - self.pos5;
				// Only update the Y axis (leave XZ intact)
				other.angles_y = anglemod(other.angles_y + self.dest1_y);
				
				// Must create facing angle before any fixangle updates
				// This will maintain existing speed with teleportation
				makevectors(other.angles);
				self.t_length = vlen(other.velocity);
				other.velocity = v_forward * self.t_length;

				// Setup special player/client teleport/angle fields
				if (other.flags & FL_CLIENT) {
					other.fixangle = 1;					// turn this way immediately
					other.teleport_time = time + 0.7;	// Special state for engine
					// The player has two angle fields, model and camera
					// Fixangle will reset the v_angle (camera) on teleport
					// The up/down angle needs to be same on both entity keys
					other.v_angle_y = other.angles_y;
					other.v_angle_z = 0;			// Stop any camera twisting
					other.angles = other.v_angle;	// sync model/cam angles
				}
			}
			else {
				//--------------------------------------------------------------
				// TYPE 2 Instant teleport - projectiles (XY axis)
				// X = up/down, Y = left/right, Z = twisting (no used)
				//--------------------------------------------------------------
				// Method 2 - Use new math rotation functionality
				// The difference is a relative co-ordinates around 0,0,0
				self.pos4 = self.oldorigin - self.pos1;
				self.dest1 = vectormod(self.goalentity.mangle);
				// Twist (Z) angle not required, reset to zero
				self.dest1_z = 0;
				// Rotate destination offset around 0,0,0
				// First rotation is Y angle (left/right), Z vector consistent
				// Second rotation is X angle (up/down), Y vector consistent
				self.pos5 = mathlib_vectorotateZ(self.pos4, self.dest1_y);
				self.pos6 = mathlib_vectorotateY(self.pos5, self.dest1_x);
				// Update destination origin with rotation offset
				self.pos2 = self.pos2 - self.pos6;
				
				/* Method 1 - Use QC vector/angle functionality
				// Create directional vector from origin to touch point
				self.pos4 = self.oldorigin - other.origin;
				// Calculate length of vector between origin + touch point
				self.t_length = vlen(self.pos4);
				// Convert directional vector to angles
				self.pos5 = vectoangles(self.pos4);
				// Make sure destination exit angle is within range
				self.dest1 = vectormod(self.goalentity.mangle);
				// Rotate directional angle by destination angle/mangle
				self.pos6 = vectormod(self.pos5 + self.dest1);
				// Create directional vectors to find exit point
				makevectors (self.pos6);
				self.pos2 = self.pos2 + (v_forward * self.t_length); */

				// Reset angles to consistent exit direction
				if (self.telefixangle) other.angles = self.dest1;
				// Calculate angle offset based on destination angle
				else other.angles = vectormod(other.angles + self.dest1);
				
				// Creating Velocity from angles will reverse X axis
				// Only reverse X axis if destination X axis not used
				self.pos5 = other.angles;
				if (self.dest1_x == 0) self.pos5_x = -self.pos5_x;
				// re-create velocity from new angles
				makevectors(self.pos5);
				self.t_length = vlen(other.velocity);
				other.velocity = v_forward * self.t_length;
			}
		}
		else {
			// Touch offset = difference between touch and actual origin
			self.pos4 = self.oldorigin - self.pos1;
			// project XYZ difference from source to target triggers
			self.pos2 = self.pos2 - self.pos4;
		}
	}
	//------------------------------------------------------------------
	// DEFAULT TELEPORTER - Reset velocity, point ent target
	//------------------------------------------------------------------
	else {
		// Turn entity towards facing angle of destination
		other.angles = vectormod(self.goalentity.mangle);
		makevectors(other.angles);

		// Setup client teleport fields
		if (other.flags & FL_CLIENT) {
			other.fixangle = 1;					// turn this way immediately
			other.teleport_time = time + 0.7;	// Special state for engine
			// Default speed movement or override (AD only)
			other.velocity = v_forward * self.speed;
		}
		// Setup monster teleport fields
		// Stationary monsters (closets) should NOT be moving!
		else if (other.flags & FL_MONSTER && vlen(other.velocity)!=0) {
			other.velocity = v_forward * self.speed;
		}
		// Projectiles should be affected by speed override
		else if (self.spawnflags & TRIG_TELEPROJECTILE) {
			// Destination teleport entities are adjusted upward by view_ofs
			// Move destination origin back down to correct position
			// Default for most entities is '0 0 0', otherwise its '0 0 27'
			self.pos2 = self.pos2 - self.goalentity.view_ofs;

			// Check for target entity (angletarget) direction vector
			if (!CheckZeroVector(self.goalentity.movedir))
				other.velocity = self.goalentity.movedir * self.speed;
			// Use default velocity vector
			else other.velocity = v_forward * self.speed;

			// This a stupid bullshit hack to get around the problem
			// with up/down angles being back to front for models
			// One day I will come back and fix this stupid hack!?!
			if (self.goalentity.mangle_x == 90 || self.goalentity.mangle_x == 270)
				other.angles_x = -other.angles_x;
			
		}
		// This is usually used for gibs
		else if (!other.health) {
			// Add a little forward momentum to teleporting entity
			other.velocity = (v_forward * other.velocity_x) + (v_forward * other.velocity_y);
		}
	}
	//------------------------------------------------------------------
	// Show extra dev/debug modes (1=markers, 2=arrows, 3=console text)
	//------------------------------------------------------------------
	if (self.debuglvl > 0) {
		// Turn the teleport triggers visable ingame
		trigger_teleport_debug();
		
		// Spawn diamond markers for impact/exit
		if (self.debuglvl == 1) {
			spawn_marker(self.pos1, SPNMARK_YELLOW);
			spawn_marker(self.pos2, SPNMARK_BLUE);
		}
		// Spawn model arrows for impact/exit
		else if (self.debuglvl >= 2) {
			makevectors(self.dest0);
			// Project source angle backwards to create space for arrow
			self.pos5 = -v_forward * 32;
			spawn_arrow(self.pos1 + self.pos5, self.dest0, SPNMARK_YELLOW);
			// Spawn exit arrow using velocity (actual direction)
			self.pos6 = vectoangles(other.velocity);
			spawn_arrow(self.pos2, self.pos6, SPNMARK_YELLOW);
		}
		// Show original, new and destination angles
		if (self.debuglvl > 2) {
			dprint("Org ("); dprint(vtos(self.dest0));
			dprint(") New ("); dprint(vtos(other.angles));
			dprint(") Dest ("); dprint(vtos(self.goalentity.mangle));
			dprint(")\n");
		}
	}

	//------------------------------------------------------------------
	// Functionality for ALL original/instant teleporters
	//------------------------------------------------------------------
	// Update projectiles
	if (self.spawnflags & TRIG_TELEPROJECTILE && !other.health) {
		// Owner changed to remove impact exception
		other.owner = self;
		// Tracking (homing) projectiles need to stop steering
		if (other.classgroup == CG_PROJROCKETS && !self.no_trackondeath) 
			other.no_trackondeath = NEGATIVE;
	}

	// The destination teleport effect is infront so its seen
	makevectors(other.angles);
	self.pos3 = self.pos2 + (32 * v_forward);

	//------------------------------------------------------------------
	// Generate spawn telporter sound + gfx
	//------------------------------------------------------------------
	if (!(self.spawnflags & TRIG_NOTELESOUNDFX) && self.telefxtimer < time) {
		// slowdown sound + fx (default = 0.2s)
		self.telefxtimer = time + self.waitmin2;
		// create teleport effect at source
		spawn_tfog (self.pos1);
		// create teleport effect infront of destination
		spawn_tfog (self.pos3);
	}

	//------------------------------------------------------------------
	// Kill anything at teleporter destination
	spawn_tdeath(self.pos2, other);
	// Move to new location
	other.origin = self.pos2;
	setorigin (other, other.origin);
	
	// Telporting entities need ground flag removed
	other.flags = other.flags - (other.flags & FL_ONGROUND);

	// Work out any teleport damage, based on skill level
	self.dmg = trigger_dmgquery();
	if (self.dmg > 0) T_Damage (other, self, self, self.dmg, DAMARMOR);

	// Check for a trigger_once condition
	if (self.wait < 0) {
		self.attack_finished = LARGE_TIMER;
		self.estate_off();
	}
};

//----------------------------------------------------------------------
void() trigger_teleport_setup =
{
	// Finds the FIRST teleporter target in entity list
	self.goalentity = find (world, targetname, self.target);
	if (!self.goalentity) {
		dprint("\b[TRIG_TELEPORT]\b Cannot find target\n");
		spawn_marker(self.oldorigin, SPNMARK_YELLOW);
		entity_hide(self);
		return;
	}
	// Check teleport destination entities are correct types
	// This is not a critical error condition, no need to stop
	// Display warning and spawn marker for deverloper mode
	if (self.spawnflags & TRIG_TELEINSTANT) {
		if (self.goalentity.classtype != CT_MISCTELINSTANT) {
			dprint("\b[TRIG_TELEPORT]\b Wrong Entity (");
			dprint(self.goalentity.classname); dprint(")\n");
			spawn_marker(self.oldorigin, SPNMARK_YELLOW);
		}
	}
	else {
		// Default teleporter requires correct dest entity
		if (self.goalentity.classtype != CT_MISCTELEPORT) {
			dprint("\b[TRIG_TELEPORT]\b Wrong Entity (");
			dprint(self.goalentity.classname); dprint(")\n");
			spawn_marker(self.oldorigin, SPNMARK_YELLOW);
		}
	}

	// Update trigger surface for debug info
	trigger_teleport_debug();
};

//----------------------------------------------------------------------
void() trigger_teleport =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_TRIGTELEPORT;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();

	// True origin used for errors and debug info
	self.oldorigin = bmodel_origin(self);
	
	// Always pre-cache telporter teleporter sound
	if (self.noise == "") self.noise = "ambience/hum1.wav";
	precache_sound (self.noise);
	trigger_bmodel_volume(0.5);

	// This is a critical error - teleporter going nowhere!?!
	if (self.target == "") {
		dprint("\b[TRIG_TELEPORT]\b Missing target\n");
		spawn_marker(self.oldorigin, SPNMARK_YELLOW);
		remove(self);
		return;
	}

	// Spawnflag 1 is used for something else (notouch duplicate)
	// No trigger damage functionality and always touchable!
	self.spawnflags = self.spawnflags | TRIG_ALWAYTOUCH | TRIG_NODAMAGE;
	if (self.speed <= 0) self.speed = 300;
	if (self.waitmin2 <= 0) self.waitmin2 = 0.2;
	if (self.waitmin3 <= 0) self.waitmin3 = 0.75;
	// Secondary trigger (target2) default=only works once!
	if (self.wait2 <= 0) self.wait2 = -1;

	// The length of the custom sound cannot be < 0.1s
	// The default of 3.622 is for hum1.wav
	if (self.waitmin <= 0.1) self.waitmin = 3.622;
	// Setup any teleport damage (def=0) parameters
	trigger_dmgsetup(0);

	// Trigger teleporters cannot be turned off (model hidden) because
	// they are used for monster closets which are always active
	self.touch = trigger_teleport_touch;
	self.solid = SOLID_TRIGGER;
	setsize (self, self.bbmins, self.bbmaxs);

	// Setup Entity State functionality
	self.estate_on = trigger_teleport_on;
	self.estate_off = trigger_teleport_off;
	self.estate_use = trigger_teleport_use;
	self.use = entity_state_use;
	
	// Damn annoying that the targetname is being used like this because
	// there could have been a better way to do this type of functionality
	// == "" teleporter works fine (starts on)
	// != "" teleporter requires trigger activation
	if (self.spawnflags & TRIG_TELEALWAYSON) self.estate_on();
	else if (self.spawnflags & ENT_STARTOFF) self.estate_off();
	else if (self.targetname != "") self.estate_off();
	else self.estate_on();
	
	// Setup independent sound emitter for teleporter state
	if ( !(self.spawnflags & TRIG_TELESILENT) ) {
		self.attachment = spawn();
		self.attachment.owner = self;
		// Always start by checking estate values
		self.attachment.estate = -1;
		self.attachment.movetype = MOVETYPE_NONE;
		self.attachment.solid = SOLID_NOT;
		setorigin(self.attachment, self.oldorigin);
		// Show debug marker, for testing only
		//setmodel(self.attachment, MODEL_BROKEN);
		self.attachment.nextthink = time + 1;
		self.attachment.think = trigger_teleport_sound;
	}
	
	// Make sure teleport target(s) exist
	self.think = trigger_teleport_setup;
	self.nextthink = time + 0.1;
};

//======================================================================
/*QUAKED trigger_changelevel (0.5 0 0.5) ? NO_INTERMIS RESETINV x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Finish current map, show intermission screen and loads next
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target     : name of target(s) to trigger before intermission
map        : The name of next map (e.g. e1m1) default=same map
startspawn2: Special unique number (1-7) which must match info_player_start2
mapvar_update : Map Variable range to trigger on use (start, finish, value)
-------- SPAWNFLAGS --------
NO_INTERMIS : No Intermission screen 
RESETINV    : Reset player inventory to default (Shotgun+Shells)
STARTOFF    : Starts off and waits for trigger
-------- NOTES --------
Finish current map, show intermission screen and loads next
This entity cannot be damaged and is always touchable once activated

 ======================================================================*/
void() trigger_changelevel_finish =
{
	intermission_running = 1;
	
	// enforce a wait time before allowing changelevel
	if (deathmatch) intermission_exittime = time + 5;
	else intermission_exittime = time + 2;

	WriteByte (MSG_ALL, SVC_CDTRACK);		// Update CD track
	WriteByte (MSG_ALL, SVC_UPDATESTAT);	// Update stats, total kills etc
	WriteByte (MSG_ALL, SVC_UPDATESTAT);	// Update twice?
	StartIntermissionCamera();				// Setup intermission camera(s)
	WriteByte (MSG_ALL, SVC_INTERMISSION);	// Start intermission (lock movement)
};

//----------------------------------------------------------------------
void() trigger_changelevel_fire =
{
	if (self.attack_finished > time) return;
	if ( !(self.bmodel_act.flags & FL_CLIENT) ) return;
	if ( self.bmodel_act.health < 1 ) return;

	self.attack_finished = LARGE_TIMER;

	// Remove all powerup/debuff effects
	ResetPowerSystem(self.bmodel_act,0,FALSE);
	ResetDebuffSystem(self.bmodel_act);
	
	// Check for map variables on exit
	if (!CheckZeroVector(self.mapvar_update))
		mapvar_range(self.mapvar_update);
	
	// LEVEL CHANGE = Reset randomizer seed
	rnd_ResetRandomSeed(RND_NORESETCHLVL);
	
	// Reset player inventory back to ID default (shotgun+25shells)
	if (self.spawnflags & TRIG_CMAPRESETINV) {
		dprint("\b[CHANGELVL]\b Resetting client inventory!\n"); 
		self.bmodel_act.health = HEAL_PLAYMAX;
		self.bmodel_act.armortype = self.bmodel_act.armorvalue = 0;
		self.bmodel_act.ammo_shells = DEF_SHELLS;
		self.bmodel_act.ammo_nails = self.bmodel_act.ammo_rockets = self.bmodel_act.ammo_cells = 0;
		self.bmodel_act.items = IT_SHOTGUN | IT_AXE;
		self.bmodel_act.moditems = 0;
		self.bmodel_act.weapon = IT_SHOTGUN;
	}
	
	// Some crazy DM parameters to prevent teleport exit
	if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start"))) {
		T_Damage (self.bmodel_act, self, self, MEGADEATH, NOARMOR); return;
	}
	// More crazy DM stuff
	if (coop || deathmatch) {
		bprint (self.bmodel_act.netname);
		bprint (" exited the level\n");
	}

	// is there a special info_player_start2 location setup?
	// This will also reset any values back to zero (default)
	if (self.startspawn2 < 1 && self.startspawn2 > 7) self.startspawn2 = 0;
	update_configflag(SVR_SPAWN_BIT1, floor( (self.startspawn2 & 1) / 1) );
	update_configflag(SVR_SPAWN_BIT2, floor( (self.startspawn2 & 2) / 2) );
	update_configflag(SVR_SPAWN_BIT3, floor( (self.startspawn2 & 4) / 4) );
		
	// Map hack for ad_tears map, secret exit does not go back to start map
	if (world.model == "maps/ad_tears.bsp") self.map = "start";
	// *change* if map key not defined, reload current map again
	if (self.map) nextmap = self.map;
	SUB_UseTargets ();

	// If no intermission, go straight to next map
	if ( (self.spawnflags & TRIG_CMAPNOPAUSE) && (deathmatch == 0) ) {
		GotoNextMap();
		return;
	}
	
	// we can't move people right now, because touch functions are called
	// in the middle of C movement code, so set a think time to do it
	self.think = trigger_changelevel_finish;
	self.nextthink = time + 0.1;
};

//----------------------------------------------------------------------
void() trigger_changelevel_setup =
{
	// If map not defined, use current mapname instead
	if (!self.map) self.map = mapname;
};

//----------------------------------------------------------------------
// Re-direction for map hacks (not used normally)
//----------------------------------------------------------------------
void() changelevel_touch = { trigger_changelevel_fire();};

//----------------------------------------------------------------------
void() trigger_changelevel =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_TRIGLEVEL;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();

	// Spawnflag 1 is used for something else (notouch duplicate)
	// No trigger damage functionality and always touchable!
	self.spawnflags = self.spawnflags | TRIG_ALWAYTOUCH | TRIG_NODAMAGE;
	// Cannot have change level triggers touched by monsters
	self.spawnflags = self.spawnflags - (self.spawnflags & TRIG_MONSTERS);
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_fire = trigger_changelevel_fire;
	trigger_bmodel_setup();
	
	// Wait for everything to spawn before checking map name
	self.think = trigger_changelevel_setup;
	self.nextthink = time + 1;
};

//======================================================================
/*QUAKED trigger_setskill (0.5 0 0.5) ? NOTOUCH x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Sets player skill level (via console)
-------- KEYS --------
targetname : trigger entity (works with entity state system)
health  : Can be damaged instead of touched
wait    : time between re-triggering (def=0.2s, -1=once)
angle   : Facing Direction for trigger to work, use "360" for angle 0.
message : Skill Level - 0 = easy, 1 = normal, 2 = hard, 3 = nightmare
-------- SPAWNFLAGS --------
NOTOUCH  : can only be triggered via other entities
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
Sets player skill level (via console)

======================================================================*/
void() trigger_setskill_fire =
{
	if (self.attack_finished > time) return;

	// There is no client check for the skill level change so that
	// the use functionality can work from trigger chains
	cvar_set ("skill", self.message);

	// Is the trigger repeatable?
	if (self.wait > 0) {
		self.attack_finished = time + self.wait;
		self.nextthink = self.attack_finished;
		self.think = self.estate_on;
	}
	// block trigger and turn off (trigger_once)
	else {
		self.attack_finished = LARGE_TIMER;
		self.estate_off();
	}
};

//----------------------------------------------------------------------
void() trigger_setskill =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors
	if (check_bmodel_notouch()) return;	// NO touch + NO targetname!

	self.classtype = CT_TRIGSKILLS;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();

	if (!self.wait) self.wait = 1;
	if (self.message == "") self.message = "0";

	// Cannot have skill triggers touched by monsters
	self.spawnflags = self.spawnflags - (self.spawnflags & TRIG_MONSTERS);

	// Setup Entity State functionality
	self.estate_fire = trigger_setskill_fire;
	trigger_bmodel_setup();
};

//======================================================================
/*QUAKED trigger_rune (0.5 0 0.5) ? E1 E2 E3 E4 x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
A Trigger that fires once if the player has certain runes
-------- KEYS --------
targetname : trigger entity (works with entity state system)
health  : Can be damaged instead of touched
angle   : Facing Direction for trigger to work, use "360" for angle 0.
target  : trigger to fire if player has MIXTURE of runes
noise1  : trigger to fire if player has rune 1
noise2  : trigger to fire if player has rune 2
noise3  : trigger to fire if player has rune 3
noise4  : trigger to fire if player has rune 4
wait    : = -1 Only trigger once if the player has runes
-------- SPAWNFLAGS --------
E1 : Episode 1
E2 : Episode 2
E3 : Episode 3
E4 : Episode 4
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
There are two ways this trigger can be used, a single check for multiple
runes using target key OR individual triggers for runes using noise 1-4 keys
This trigger is designed to work once when rune conditions are met

======================================================================*/
void() trigger_rune_fire =
{
	// This is after bmodel _use, _killed and _touch, so any reference
	// to the trigger activator has to go through 'bmodel_act'
	// Is the trigger blocked? (trigger_once)
	if (self.attack_finished > time) return;
	// Stop the trigger constantly firing
	self.attack_finished = time + self.waitmin;

	// Check for single rune trigger
	if (self.target) {
		if (query_configflag(SVR_RUNE_ALL) & self.customkey == self.customkey) {
			trigger_strs(self.target, self.bmodel_act);
			if (self.wait < 0) self.attack_finished = LARGE_TIMER;
		}
	}
	else {
		// Check for multiple rune triggers
		if (query_configflag(self.customkey & SVR_RUNE_KEY1) == SVR_RUNE_KEY1 && self.noise1 != "") {
			trigger_strs(self.noise1, self.bmodel_act);
			if (self.wait < 0) self.attack_finished = LARGE_TIMER;
		}
		if (query_configflag(self.customkey & SVR_RUNE_KEY2) == SVR_RUNE_KEY2 && self.noise2 != "") {
			trigger_strs(self.noise2, self.bmodel_act);
			if (self.wait < 0) self.attack_finished = LARGE_TIMER;
		}
		if (query_configflag(self.customkey & SVR_RUNE_KEY3) == SVR_RUNE_KEY3 && self.noise3 != "") {
			trigger_strs(self.noise3, self.bmodel_act);
			if (self.wait < 0) self.attack_finished = LARGE_TIMER;
		}
		if (query_configflag(self.customkey & SVR_RUNE_KEY4) == SVR_RUNE_KEY4 && self.noise4 != "") {
			trigger_strs(self.noise4, self.bmodel_act);
			if (self.wait < 0) self.attack_finished = LARGE_TIMER;
		}
	}

	// The attack_finished is set by the RUNE condition being TRUE
	// The trigger is designed to be trigger_once (no need to check wait)
	// The trigger needs to meet a rune condition before switching off
	if (self.attack_finished == LARGE_TIMER) self.estate_off();
};

//----------------------------------------------------------------------
void() trigger_rune =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_TRIGRUNES;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();

	if (self.waitmin <=0) self.waitmin = 1;

	// Spawnflag 1 is used for something else (notouch duplicate)
	self.spawnflags = self.spawnflags | TRIG_ALWAYTOUCH;
	// Cannot have rune triggers touched by monsters
	self.spawnflags = self.spawnflags - (self.spawnflags & TRIG_MONSTERS);
	// Calculate the rune key selection
	self.customkey = self.spawnflags & SVR_RUNE_ALL;
	
	// Cannot do anything with the trigger if no runes are selected
	if (self.customkey == 0) {
		dprint("\b[TRIG_RUNE]\b No runes setup!\n");
		self.oldorigin = bmodel_origin(self);
		spawn_marker(self.oldorigin, SPNMARK_YELLOW);
		remove(self);
		return;		
	}

	// Setup Entity State functionality
	self.estate_fire = trigger_rune_fire;
	trigger_bmodel_setup();
};

//======================================================================
/*QUAKED trigger_push (0.5 0 0.5) ? PUSH_ONCE SILENT NOMONSTER x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Push the Player and Grenades!
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target : target entity for custom direction
angle  : direction of push (-2 is down, -1 up)
angles : Pitch Yaw Roll (up/down, angle, tilt left/right)
speed  : Speed of push direction (def=1000)
-------- SPAWNFLAGS --------
PUSH_ONCE : trigger_once functionality
SILENT    : No wind sound for player
NOMONSTER : Monsters cannot be pushed by this trigger
STARTOFF  : Starts off and waits for trigger
-------- NOTES --------
Push the Player, player/ogre grenades and minion eggs!
This entity cannot be damaged and is always touchable once activated

======================================================================*/
void() trigger_push_fire =
{
	// This is after bmodel _use, _killed and _touch, so any reference
	// to the trigger activator has to go through 'bmodel_act'
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;
	// Check for any dead monster bodies (no exceptions)
	if (trigger_check_body(self.bmodel_act,DEAD_EXPLODE)) return;
	// Check for no monster exception
	if (self.spawnflags & TRIG_PUSHNOMONSTER && self.bmodel_act.flags & FL_MONSTER) return;

	// If custom push direction setup, calculate new facing angle
	if (self.target != "") {
		self.angletarget = self.target;
		TargetMovedir(self, FALSE);
	}
	
	// Cool feature is that it will push grenades!
	// Added player, ogre and minion eggs to the catch
	if (self.bmodel_act.classtype == CT_PROJ_GL || 
		self.bmodel_act.classtype == CT_PROJ_GLMON ||
		self.bmodel_act.classtype == CT_PROJ_MEGG)
		self.bmodel_act.velocity = self.speed * self.movedir * 10;
	// Standard push for all bmodel_act living entities
	else if (self.bmodel_act.health > 0) {
		self.bmodel_act.velocity = self.speed * self.movedir * 10;
		// Play wind sound for the player
		if (self.bmodel_act.classtype == CT_PLAYER) {
			if (self.bmodel_act.fly_sound < time) {
				self.bmodel_act.fly_sound = time + 1.5;
				sound (self.bmodel_act, CHAN_AUTO, self.noise, self.volume, ATTN_NORM);
			}
		}
	}
	
	// Setup to trigger push once?
	if (self.wait < 0) {
		self.attack_finished = LARGE_TIMER;
		self.estate_off();
	}
};

//----------------------------------------------------------------------
// Map hack reference
void() trigger_push_touch = { self.bmodel_act = other; trigger_push_fire(); }

//----------------------------------------------------------------------
void() trigger_push =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_TRIGPUSH;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();

	if (!self.speed) self.speed = 1000;

	// Spawnflag 1 is used for something else (notouch duplicate)
	// No trigger damage functionality and always touchable!
	self.spawnflags = self.spawnflags | TRIG_ALWAYTOUCH | TRIG_NODAMAGE;

	// Setup default wind sound if no custom sound found
	// else if silent trigger, use misc/empty sound
	if ( !(self.spawnflags & TRIG_PUSHSILENT) && self.noise == "")
		self.noise = "ambience/windfly.wav";
	if (self.noise == "") self.noise = SOUND_EMPTY;
	precache_sound (self.noise);
	trigger_bmodel_volume(1);
	
	if (self.spawnflags & TRIG_PUSHONCE) self.wait = -1;

	// Setup Entity State functionality
	self.estate_fire = trigger_push_fire;
	self.touch = trigger_bmodel_anytouch;
	trigger_bmodel_setup();
};

//----------------------------------------------------------------------
// Removed - No map used the feature
//----------------------------------------------------------------------
void() trigger_conveyor = { remove(self); };

/*======================================================================
 Player ladder (originally from Rubicon2 codebase by JohnFitz)
 - This is a very simple system, jump to attach to the ladder brush
 - move up down via jumpping (hook in preplayer code)
 - Added multiple climbing sounds (works with player footsound state)
 - Modified to have on/off/toggle state via triggers
 - Downsides to system, there is no abilty to go down a ladder
 
 Added two other ladder systems
 * VELOCITY is from extra4 mod and work similar to Quoth mod
 - Push forward to move up, sideways to strafe and down to climb down
 * FTESKIN is hardcoded into FTE/QSS engines
 - Works very similar to velocity system, push forward to climb
======================================================================*/
/*QUAKED trigger_ladder (.5 .5 .5) ? x x VELOCITY FTESKIN x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Invisible brush based ladder
-------- KEYS --------
targetname : trigger entity (works with entity state system)
angle      : direction player must be facing to climb ladder (required)
waitmin    : time between climb sound (def = depends on sound type)
speed      : velocity speed to climb ladder (def=160)
sounds     : 1=metal, 2=wood, 3=rope, 4=silent, 5=custom (def=wood)
noise1-4   : custom sounds to play when climbing ladder
yaw_speed  : VELOCITY only - Movement distance for sound trigger
distance   : VELOCITY only - Amount of velocity to push towards ladder (stickyness)
lip        : VELOCITY only - Change the step amount at the top of the ladder
height     : VELOCITY only - Default velocity upward if not doing anything on ladder
pos1       : VELOCITY only - Speed adjustment for X=strafe, Y=up and Z=down movement
pos2       : VELOCITY only - X=Strafe velocity, Y=Up/Down angle, Z=MIN velocity for up/down
-------- SPAWNFLAGS --------
VELOCITY : Will use the VELOCITY ladder system instead
FTESKIN  : Will use the FTE/SKIN ladder system instead
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
Invisible brush based ladder
This entity cannot be damaged and is always touchable once activated

======================================================================*/
void() trigger_ladder_fire =
{
	local vector vel;
	float fvel, srv_upspeed, ladpos, ladspd;

	// Ladders ONLY work with players because of client.qc (PlayerPreThink)
	if (self.estate & ESTATE_BLOCK) return;
	if ( !(self.bmodel_act.flags & FL_CLIENT) ) return;
	if ( self.bmodel_act.health < 1 ) return;

	// Don't stick underwater, or in the middle of a waterjump
	if (self.bmodel_act.waterlevel > 1) return;
	if (self.bmodel_act.flags & FL_WATERJUMP) return;
	
	// Is Ladder functionality blocked? (timer set in client)
	if (self.bmodel_act.blockladder > time) return;

	// Keep track of ladder trigger for sound fx
	self.bmodel_act.entladder = self;

	//----------------------------------------------------------------------
	// Velocity Ladder code was originally by Frank Condello (extra4 mod)
	// Modified by Redfield and then streamlined and bugfixed by me (simonoc)
	// Fixed - Unstuck issues and top of ladder bumping the player off
	// Added - Jump ability to exit ladder anytime and footstep sound fx
	// Added - Ability to override any of the parameters for the system
	//
	// Update the client with code in PlayerPreThink.client.qc
	// Setup which ladder system is active and link back
	if (self.spawnflags & TRIG_LADDERVELOCITY) {
		// ERROR CHECK : Can the player grab the ladder?
		makevectors (self.bmodel_act.angles);
		// Compare ladder facing angle (180 degree freedom)
		if ( (v_forward*self.movedir)< -0.5 ) return;

		// Player feet position
		ladpos = self.bmodel_act.origin_z + self.bmodel_act.mins_z;
		// Check if player is standing on top of the ladder
		if (ladpos > self.absmax_z-self.lip) return;
			
		//------------------------------------------------------------------
		// Allow jump to exit ladder trigger
		self.bmodel_act.onladder = LADDER_VEL;
		// Stop all vertical movement
		self.bmodel_act.velocity_z = 0;
		
		// Check for strafing on ladder (initial vel def=25, speed org=0.5)
		if (v_right*self.bmodel_act.velocity > self.pos2_x) {
			self.bmodel_act.velocity = v_right*self.pos1_x;
			return;
		}
		// Check for strafing on ladder (initial vel def=25, speed org=0.5)
		else if (v_right*self.bmodel_act.velocity < -self.pos2_x) {
			self.bmodel_act.velocity = -v_right*self.pos1_x;
			return;
		}
			
		// Get the player's forward speed	
		fvel = v_forward * self.bmodel_act.velocity;
		vel = '0 0 0';// Our new velocity

		// Up (facing up/forward, angle def=15)
		if (self.bmodel_act.v_angle_x <= self.pos2_y && fvel>0 ) {
			// Cannot go upward if onground flag active
			self.bmodel_act.flags = self.bmodel_act.flags - (self.bmodel_act.flags & FL_ONGROUND);
			
			// Go faster when facing up (speed def=6)
			vel_z = fabs(self.bmodel_act.v_angle_x)*self.pos1_y;
			// Minimum velocity (only facing up, def vel=90)
			if (vel_z < self.pos2_z) vel_z = self.pos2_z;
		}
		// Up (facing down, angle def=15)
		else if ( self.bmodel_act.v_angle_x >= self.pos2_y && fvel<0 ) {
			// Cannot go upward if onground flag active
			self.bmodel_act.flags = self.bmodel_act.flags - (self.bmodel_act.flags & FL_ONGROUND);
			
			// Go slower when facing down (speed def=4)
			vel_z = self.bmodel_act.v_angle_x*self.pos1_z;
		}
		// Down (facing up/forward, angle def=15)
		else if (self.bmodel_act.v_angle_x <= self.pos2_y && fvel<0 ) {
			// Push the player TOWARDS the ladder to stop falling off
			vel = vel + self.movedir*self.distance;

			// Go faster when facing up (speed was org=-5, changed to -6)
			vel_z = fabs(self.bmodel_act.v_angle_x)*-self.pos1_y;
			// Minimum velocity (only facing up, org vel=-80)
			if (vel_z > -self.pos2_z) vel_z = -self.pos2_z;
		}
		// Down (facing down, angle def=15)
		else if ( self.bmodel_act.v_angle_x >= self.pos2_y && fvel>0 ) {	
			// Push the player TOWARDS the ladder to stop falling off
			vel = vel - self.movedir*self.distance;

			// Go slower when facing down (speed def=-4)
			vel_z = self.bmodel_act.v_angle_x*-self.pos1_z;
		}
		else {
			// Minimum velocity
			if (vel_z < self.height) vel_z = self.height;
		}
		
		// Cap vertical movement to the server limits
		srv_upspeed = cvar("cl_upspeed");
		// Check for upper limit
		if (vel_z > srv_upspeed) vel_z = srv_upspeed;
		// Check for lower limit using -1 reversal technique
		else if (vel_z < -1*srv_upspeed) vel_z = -1*srv_upspeed;
		
		// Replace player velocity
		self.bmodel_act.velocity = vel;

		// Is the player at the bottom or top of the ladder bmodel?
		// reset distance travelled to prevent sound loop
		ladpos = self.bmodel_act.origin_z + self.bmodel_act.maxs_z + 8;
		if (ladpos >= self.absmax_z) self.bmodel_act.distladder = 0;
		ladpos = (self.bmodel_act.origin_z + self.bmodel_act.mins_z) - 8;
		if (ladpos <= self.absmin_z) self.bmodel_act.distladder = 0;
		
		// Work out distance travelled (vlen) on ladder
		ladspd = vlen(self.bmodel_act.origin - self.bmodel_act.orgladder);
		self.bmodel_act.distladder = self.bmodel_act.distladder + ladspd;
		// Is it time to play a ladder sound?
		if (self.bmodel_act.distladder > self.yaw_speed) {
			// Play sound and reset counter
			Client_LadderSounds(self.bmodel_act);
			self.bmodel_act.distladder = 0;
		}
		// Save new origin for next ladder cycle
		self.bmodel_act.orgladder = self.bmodel_act.origin;
		
	}
	// Default = ladder jump (to climb) system
	else self.bmodel_act.onladder = LADDER_JUMP;
};

//----------------------------------------------------------------------
void() trigger_ladder =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_TRIGLADDER;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();
	
	// Show facing angle
	if (developer > 0) {
		// Move origin back away from ladder
		self.oldorigin = bmodel_origin(self) - (self.movedir*40);
		// Convert movedir back into an angle
		self.finalangle = vectoangles(self.movedir);
		// Show debug arrow
		spawn_arrow(self.oldorigin, self.finalangle, 0);
	}

	// Default = wood
	if (!self.sounds) self.sounds = 2;
	if (self.sounds == 1) {				// Metal
		if(!self.waitmin) self.waitmin = 0.45;
		self.noise1 = "player/ladmetal1.wav";
		self.noise2 = "player/ladmetal2.wav";
		self.noise3 = "player/ladmetal3.wav";
		self.noise4 = "player/ladmetal4.wav";
	}
	else if (self.sounds == 2) {		// Wood
		if(!self.waitmin) self.waitmin = 0.4;
		self.noise1 = "player/ladwood1.wav";
		self.noise2 = "player/ladwood2.wav";
		self.noise3 = "player/ladwood3.wav";
		self.noise4 = "player/ladwood4.wav";
	}
	else if (self.sounds == 3) {		// Old Rope
		if(!self.waitmin) self.waitmin = 0.7;
		self.noise1 = "player/ladrope1.wav";
		self.noise2 = "player/ladrope2.wav";
		self.noise3 = "player/ladrope3.wav";
		self.noise4 = "player/ladrope4.wav";
	}
	else {
		// Custom or empty
		if (!self.waitmin) self.waitmin = 0.5;
		if (self.noise1 == "") self.noise1 = SOUND_EMPTY;
		if (self.noise2 == "") self.noise2 = SOUND_EMPTY;
		if (self.noise3 == "") self.noise3 = SOUND_EMPTY;
		if (self.noise4 == "") self.noise4 = SOUND_EMPTY;
	}
	precache_sound(self.noise1);
	precache_sound(self.noise2);
	precache_sound(self.noise3);
	precache_sound(self.noise4);
	trigger_bmodel_volume(1);
	
	// Velocity reset for upward movement (AD jump ladder system)
	if (self.speed <= 0) self.speed = 160;

	// No trigger damage functionality and always touchable!
	self.spawnflags = self.spawnflags | TRIG_ALWAYTOUCH | TRIG_NODAMAGE;
	// Cannot have ladder triggers touched by monsters
	self.spawnflags = self.spawnflags - (self.spawnflags & TRIG_MONSTERS);
	
	// Check for new velocity ladder system
	if (self.spawnflags & TRIG_LADDERVELOCITY) {
		// Movement distance for sound trigger
		if (self.yaw_speed <= 0) self.yaw_speed = 60;
		// Amount of velocity to push towards ladder (stickyness)
		if (self.distance <= 0) self.distance = 0.35;
		// Change the step amount at the top of the ladder
		if (self.lip <= 0) self.lip = 8;
		// Default velocity upward if not doing anything on ladder
		if (self.height <= 0) self.height = 11.2; 
		// Speed adjustment for X=strafe, Y=up and Z=down movement
		if (CheckZeroVector(self.pos1)) self.pos1 = '2.5 6 4';
		// X=Strafe velocity, Y=Up/Down angle, Z=MIN velocity for up/down
		if (CheckZeroVector(self.pos2)) self.pos2 = '25 15 90';
		// Can't have both velocity + fteskin systems active once
		self.spawnflags = self.spawnflags - (self.spawnflags & TRIG_LADDERFTESKIN);
	}
	// Enable FTE Skin/Ladder system (reqs FTE engine)
	else if (self.spawnflags & TRIG_LADDERFTESKIN) {
		self.spawnflags = self.spawnflags - (self.spawnflags & TRIG_LADDERVELOCITY);
		self.skin = -16;
	}
	
	// Setup Entity State functionality
	self.estate_fire = trigger_ladder_fire;
	trigger_bmodel_setup();
};

//======================================================================
/*QUAKED trigger_fallspeed (.5 .5 .5) ? NOTOUCH x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Change the player velocity speed checks for fall damage
------- KEYS --------
targetname     : trigger entity (works with entity state system)
target         : trigger all these targets when activated
jump_height    : The player jump height (def=270) initial boast from standing still
fall_speedlow  : Fall Speed for any checks (def=-300) must be negative no.
fall_speedhigh : Fall Speed for damage check (def=-650) must be negative no.
fall_speeddebug: Display players fall velocity to console (1=ON, -1=OFF)
fall_dmg       : Fall damage for player (def=5, -1=no dmg/sound)
fall_dmgwater  : Fall damage into water (>0 for dmg/sound, -1=no dmg/sound)
wait           : -1=will only fire targets once (switches off)
sounds         : 1=Secret,2=talk,3=switch,4=silent,6=secret2
noise          : custom sound to play when triggered
message        : message to display when triggered
-------- SPAWNFLAGS --------
NOTOUCH  : can only be triggered via other entities
STARTOFF : Requires trigger to activate
------- NOTES --------
Change the player velocity speed checks for fall damage

======================================================================*/
void() player_fallspeed_reset =
{
	map_jumpheight = DEF_JUMPHEIGHT;
	map_fallspeedlow = DEF_FALLSPEEDLOW;
	map_fallspeedhigh = DEF_FALLSPEEDHIGH;
	map_falldmg = DEF_FALLDMG;
	map_falldmgwater = DEF_FALLDMGWATER;
	map_fallspeeddebug = FALSE;
};

//----------------------------------------------------------------------
void() player_fallspeed_setup =
{
	//----------------------------------------------------------------------
	// Check for any custom player jump height settings
	if (self.jump_height > 0) map_jumpheight = self.jump_height;
	
	//----------------------------------------------------------------------
	// Low speed cannot be positive
	if (self.fall_speedlow > 0)
		dprint("\b[WORLD]\b LOW Player Fall Speed must be negative\n");
	// Check for any custom fall damage for the player
	else if (self.fall_speedlow < 0) map_fallspeedlow = self.fall_speedlow;

	// High speed cannot be positive
	if (self.fall_speedhigh > 0)
		dprint("\b[WORLD]\b HIGH Player Fall Speed must be negative\n");
	// Check for any custom fall damage for the player
	else if (self.fall_speedhigh < 0) {
		// Check high value is less than low value (both are negative no's)
		if (self.fall_speedhigh < self.fall_speedlow) 
			map_fallspeedhigh = self.fall_speedhigh;
		else 
			dprint("\b[WORLD]\b Player Fall Speed HIGH must be less than LOW\n");
	}
	
	//----------------------------------------------------------------------
	// Allow for zero fall damage, use negative values
	if (self.fall_dmg < 0) map_falldmg = 0;
	else if (self.fall_dmg > 0) map_falldmg = self.fall_dmg;
	// Allow for damage when falling into water bodies
	if (self.fall_dmgwater < 0) map_falldmgwater = 0;
	else if (self.fall_dmgwater > 0) map_falldmgwater = self.fall_dmgwater;
	
	//----------------------------------------------------------------------
	// Enable player velocity debug mode (developer = 1 required)
	if (self.fall_speeddebug < 0) map_fallspeeddebug = 0;
	else if (self.fall_speeddebug > 0) map_fallspeeddebug = TRUE;
};

//----------------------------------------------------------------------
void() trigger_fallspeed_fire =
{
	// Is the trigger turned off or disabled?
	if (self.estate & ESTATE_BLOCK) return;
	// Is the trigger blocked? (trigger_once)
	if (self.attack_finished > time) return;

	// All value checks are done in function
	// Updates all map values directly
	player_fallspeed_setup();

	// Check for any trigger events (noise/delay etc)
	// Play the sound ON the activator and display message
	if (self.message != "" && activator.flags & FL_CLIENT) 
		centerprint (activator, self.message);
	if (self.noise != "") 
		sound (activator, CHAN_VOICE, self.noise, self.volume, ATTN_NORM);
	if (self.target != "") 
		trigger_strs(self.target, activator);
	
	// Is the trigger repeatable?
	if (self.wait < 0) {
		// block trigger and turn off (trigger_once)
		self.attack_finished = LARGE_TIMER;
		self.estate_off();
	}
	// Delay trigger event
	else self.attack_finished = time + self.wait;
};

//----------------------------------------------------------------------
void() trigger_fallspeed =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors
	if (check_bmodel_notouch()) return;	// NO touch + NO targetname!

	trigger_bmodel_sounds();			// Precache any sounds

	self.classtype = CR_TRIGFALLSPEED;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_fire = trigger_fallspeed_fire;
	trigger_bmodel_setup();
};

//======================================================================
/*QUAKED trigger_maxhp (.5 .5 .5) ? NOTOUCH x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Change the player maximum hp and maximum mega values
------- KEYS --------
targetname  : trigger entity (works with entity state system)
target      : trigger all these targets when activated
max_health  : Maximum Health for ALL the player / client
mega_health : Maximum Health for picking up the mega health item
count       : Skill level (0=ALL, 1=EASY, 2=NORMAL, 4=HARD, 8=NM, 15=ALL)
wait        : -1=will only fire targets once (switches off)
sounds      : 1=Secret,2=talk,3=switch,4=silent,6=secret2
noise       : custom sound to play when triggered
message     : message to display when triggered
-------- SPAWNFLAGS --------
NOTOUCH  : can only be triggered via other entities
STARTOFF : Requires trigger to activate
------- NOTES --------
Change the player maximum hp and maximum mega values

======================================================================*/
void() trigger_maxhp_fire =
{
	local entity playent;
	
	// Is the trigger turned off or disabled?
	if (self.estate & ESTATE_BLOCK) return;
	// Is the trigger blocked? (trigger_once)
	if (self.attack_finished > time) return;

	// Only trigger if skill levels match
	self.waitmin = FALSE;
	
	// Find first client
	playent = find(world, classname, "player");
	while (playent) {
		// 1 = EASY, 2 = NORMAL, 4 = HARD, 8 = NIGHTMARE, 15 = ALL
		if ( (self.count & HP_EASY && skill == SKILL_EASY) ||
			 (self.count & HP_NORMAL && skill == SKILL_NORMAL) ||
			 (self.count & HP_HARD && skill == SKILL_HARD) ||
			 (self.count & HP_NIGHTMARE && skill >= SKILL_NIGHTMARE) ) {
			// Skill level
			self.waitmin = TRUE;
			// Double check max is not negative or zero
			if (self.max_health > 0) playent.max_health = self.max_health;
			if (self.mega_health > 0) playent.mega_health = self.mega_health;
			// Cap health with new/current maximum
			if (playent.health > playent.max_health) {
				// Tiny damage to trigger client animation/sound
				T_Damage(playent, world, world, 1, NOARMOR);
				playent.health = playent.max_health;
			}
		}
		
		// Find more (coop) player/clients
		playent = find(playent, classname, "player");
	}	

	// No skill condition found, exit
	if (self.waitmin == FALSE) return;
	
	// Check for any trigger events (noise/delay etc)
	// Play the sound ON the activator and display message
	if (self.message != "" && activator.flags & FL_CLIENT) 
		centerprint (activator, self.message);
	if (self.noise != "") 
		sound (activator, CHAN_VOICE, self.noise, self.volume, ATTN_NORM);
	if (self.target != "") 
		trigger_strs(self.target, activator);
	
	// Is the trigger repeatable?
	if (self.wait < 0) {
		// block trigger and turn off (trigger_once)
		self.attack_finished = LARGE_TIMER;
		self.estate_off();
	}
	// Delay trigger event
	else self.attack_finished = time + self.wait;
};

//----------------------------------------------------------------------
void() trigger_maxhp =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors
	if (check_bmodel_notouch()) return;	// NO touch + NO targetname!

	trigger_bmodel_sounds();			// Precache any sounds

	self.classtype = CR_TRIGMAXHP;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();
	
	// Check limits
	if (self.max_health <= 0) self.max_health = 0;
	if (self.mega_health <= 0) self.mega_health = 0;
	if (self.count <= 0) self.count = 15;
	
	// This trigger cannot be damaged (no health checks)
	self.spawnflags = self.spawnflags | TRIG_NODAMAGE;
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_fire = trigger_maxhp_fire;
	trigger_bmodel_setup();
};

//======================================================================
/*QUAKED trigger_gravity (.5 .5 .5) ? NOTOUCH SERVER PLAYER MONSTER RESET x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Change entity/entities/player or server (world) gravity
------- KEYS --------
targetname : trigger entity (works with entity state system)
target   : Group of entities to affect with gravity update
target2  : fire event(s) everytime gravity is changed
waitmin2 : Minimum time between re-triggering fire events
noise2   : Sound to play everytime gravity is changed
waitmin  : Minimum time between re-triggering sound
count    : Gravity value (server=0-1000 (def=800) entity=0-1, can be negative)
wait     : (def) -1 = will only fire targets once
-------- SPAWNFLAGS --------
NOTOUCH  : can only be triggered via other entities
SERVER   : Changes server gravity instead of entity gravity
PLAYER   : Player(s) only can touch this trigger
MONSTER  : Monster(s) only can touch this trigger
RESET    : Reset any entity to default gravity (does not affect server)
STARTOFF : Requires trigger to activate
------- NOTES --------
Change entity/entities/player or server (world) gravity

======================================================================*/
float(entity gcheck) trigger_gravity_exceptions =
{
	// Is the gravity touch entity a monster?
	if (self.spawnflags & TRIG_GRAVITYMONONLY &&
		!(gcheck.flags & FL_MONSTER)) return FALSE;
		
	// Is the gravity touch entity a player?
	if (self.spawnflags & TRIG_GRAVITYPLAYONLY &&
		!(gcheck.flags & FL_CLIENT)) return FALSE;

	// Carry on with logic
	return TRUE;
};

//----------------------------------------------------------------------
void() trigger_gravity_fire =
{
	local entity ent_list;
	
	// Is the trigger turned off or disabled?
	if (self.estate & ESTATE_BLOCK) return;
	// Exclude owner and/or triggers
	if (other == self.owner) return;
	if (other.solid == SOLID_TRIGGER) return;
	// Is the trigger blocked? (trigger_once)
	if (self.attack_finished > time) return;
	// Cannot set gravity on the world (its readonly and will crash)
	if (other.classtype == CT_WORLD) return;
	
	// Keep track of trigger firing
	self.lip = FALSE;
	
	// Check for any world/map gravity change first
	if (self.spawnflags & TRIG_GRAVITYSERVER) {
		// Find out the current gravity setting
		self.height = cvar("sv_gravity");
		// Check if gravity is different? (Stop constant trigger spam)
		if (self.height != self.count) {
			// Work through exceptions first
			if (trigger_gravity_exceptions(other)) {
				// all CVAR_SERVERINFO console commands are reported
				// to all clients as a way to prevent admin cheating!!!
				// There is no way to turn this off or make it silent :(
				// The engine code is quiet explicit about what it does :-
				// SV_BroadcastPrintf (""%s" changed to "%s"\n", var->name, var->string);
				// Reporting this to the console is fine, but printing
				// it at the top of the main screen is just lame!
				//
				// So I have a hack ...
				// Issue 4 line feeds after the cvar command! :P
				// This will clear the main screen buffer (usually 4 lines)
				// and keep the message only on the console (for reference)
				//
				cvar_set("sv_gravity", ftos(self.count));
				// Find the client to stuff the line feeds
				if (other.flags & FL_CLIENT)
					sprint(other, "\n\n\n\n\n");
				// Not every trigger will be the client, find another
				else if (client_ent.flags & FL_CLIENT)
					sprint(client_ent, "\n\n\n\n\n");
				// Update globally stored gravity setting
				map_gravity = self.count;
				// Gravity changed (test for target/sound)
				self.lip = TRUE;
			}
		}
	}
	// Entity gravity
	else {
		// Check for multiple targets?
		if (self.target != "") {
			// Build initial list from world
			ent_list = find(world, targetname, self.target);
			// Cycle through list
			while(ent_list) {
				// Work through exceptions first
				if (trigger_gravity_exceptions(ent_list)) {
					// Found player?
					if (ent_list.flags & FL_CLIENT) {
						// Are they on a ladder? - store gravity for later
						if (ent_list.onladder) ent_list.oldgravity = self.count;
						// Update gravity and backup version
						else ent_list.oldgravity = ent_list.gravity = self.count;
					}
					else {
						// Reset entity gravity key
						ent_list.gravity = self.count;
					}
					// Gravity changed (test for target/sound)
					self.lip = TRUE;
				}
				// Find next ent from intial list (not world)
				ent_list = find(ent_list, targetname, self.target);
			}
		}
		// One target (other)
		else {
			// Work through exceptions first
			if (trigger_gravity_exceptions(other)) {
				// Does entity gravity need to change?
				if (other.gravity != self.count) {
					if (!self.nodebuginfo) {
						dprint("Entity ("); dprint(other.classname);
						dprint(") Grav Old ("); dprint(ftos(other.gravity));
					}
					
					// Found player?
					if (other.flags & FL_CLIENT) {
						// Are they on a ladder? - store gravity for later
						if (other.onladder) other.oldgravity = self.count;
						// Update gravity and backup version
						else other.oldgravity = other.gravity = self.count;
					}
					else {
						// Reset entity gravity key
						other.gravity = self.count;
					}
					if (!self.nodebuginfo) {
						dprint(") = New ("); dprint(ftos(other.gravity));
						dprint(")\n");
					}
					// Gravity changed (test for target/sound)
					self.lip = TRUE;
				}
			}
		}
	}
	
	// Only fire target2/noise2 if gravity changes
	if (self.lip) {
		// Check for any trigger events and re-trigger timer
		if (self.target2 != "" && self.pain_finished < time) {
			self.pain_finished = time + self.waitmin2;
			trigger_strs(self.target2, other);
		}	
		
		// Check for any sound events and re-trigger timer
		if (self.noise2 != "" && self.lefty < time) {
			self.lefty = time + self.waitmin;
			sound (activator, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
		}
	}
	
	// Is the trigger repeatable?
	if (self.wait < 0) {
		// block trigger and turn off (trigger_once)
		self.attack_finished = LARGE_TIMER;
		self.estate_off();
	}
};

//----------------------------------------------------------------------
void() trigger_gravity =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors
	if (check_bmodel_notouch()) return;	// NO touch + NO targetname!
	
	self.classtype = CT_TRIGGRAVITY;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();
	
	// Check for any sound wav file cache
	if (self.noise2 != "") precache_sound(self.noise2);
	// Reset all re-trigger timers (noise2/target2/wait once)
	self.lefty = self.pain_finished = self.attack_finished = 0;

	// Setup entity only reset option
	// The reset options exists because if an entity has the gravity
	// key set it will override the server gravity.
	if (self.spawnflags & TRIG_GRAVITYRESET) {
		// Remove any server spawnflag, this is entity only
		self.spawnflags = self.spawnflags - (self.spawnflags & TRIG_GRAVITYSERVER);
		// Default entity gravity is always 1
		self.count = 1;
	}
	
	// This trigger can work fine with any monsters and does support
	// special trigger events via spawnflags for them (monsters)
	// Only exception is player only triggers
	if (self.spawnflags & TRIG_GRAVITYPLAYONLY)
		self.spawnflags = self.spawnflags - (self.spawnflags & TRIG_MONSTERS);
	// Default is to let trigger work with monsters
	else self.spawnflags = self.spawnflags | TRIG_MONSTERS;
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_fire = trigger_gravity_fire;
	trigger_bmodel_setup();
};

//======================================================================
/*QUAKED trigger_velocity (0.5 0 0.5) ? PLAYER MONSTER GRENADE ROCKET x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Check for projectile / player velocity!
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target    : fire event(s) everytime trigger conditions successful
target2   : fire event(s) everytime trigger exceptions fail
angle     : Facing Direction for trigger to work, use "360" for angle 0
ideal_yaw : Facing angle sensitivity (def=0.3, range = 0 - 1)
speed     : Minimum velocity speed to trigger (def=500)
waitmin   : (def=1s) Time between target/message working again
waitmin2  : (def=1s) Time between target2/message2 working again
wait      : -1 = Only fire the trigger functionality once
delay     : -1 = No spawn delay, 0 (def=1s), +0 = spawn delay
message   : display message everytime trigger conditions successful
message2  : display message everytime trigger exceptions fail
dmg_take  : Grenades will explode on impact of this trigger
-------- SPAWNFLAGS --------
PLAYER    : Player only trigger
MONSTER   : Monster only trigger
GRENADE   : Grenade projectile only trigger
ROCKET    : Rocket projectile only trigger
STARTOFF  : Starts off and waits for trigger
-------- NOTES --------
Check for projectile / player velocity!
This entity cannot be damaged and is always touchable

======================================================================*/
void() trigger_velocity_fire =
{
	// This is after bmodel _use, _killed and _touch, so any reference
	// to the trigger activator has to go through 'bmodel_act'
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;
	
	// Check spawnflag exceptions; player/monster/grenade/rocket
	// All the exceptions need to be checked together (OR logic)
	// They can fine tune exactly what the trigger will work with
	if (self.spawnflags & TRIG_VELEXCEPTION) {
		self.state = FALSE;
		if (self.spawnflags & TRIG_VELPLAYER && self.bmodel_act.flags & FL_CLIENT) self.state = TRUE;
		if (self.spawnflags & TRIG_VELMONSTER && self.bmodel_act.flags & FL_MONSTER) self.state = TRUE;
		if (self.spawnflags & TRIG_VELGRENADE && self.bmodel_act.classgroup == CG_PROJGRENADES) self.state = TRUE;
		if (self.spawnflags & TRIG_VELROCKET && self.bmodel_act.classgroup == CG_PROJROCKETS) self.state = TRUE;
		if (self.state == FALSE) {
			// touch triggers can re-trigger a lot, need to throttle response
			if (self.pain_finished < time) {
				self.pain_finished = time + self.waitmin2;
				// Centerprint messages require a client
				if (self.message2 != "") {
					self.enemy = world;
					// Try to find client; other, owner or client_ent
					if (self.bmodel_act.flags & FL_CLIENT) self.enemy = self.bmodel_act;
					else if (self.bmodel_act.owner.flags & FL_CLIENT) self.enemy = self.bmodel_act.owner;
					else self.enemy = client_ent;
					// Got a client? show message to all clients
					if (!self.enemy) dprint("\b[TRIG_VEL]\b No client for centerprint!");
					else centerprint(self.enemy, self.message2);
				}
				// Fire targets if exceptions have failed
				if (self.target2 != "") 
					trigger_strs(self.target2, self.bmodel_act);
			}
			// Exceptions failed
			return;
		}
	}

	// Check for any target entity tracking
	TargetMovedir(self, FALSE);
	
	// Did the trigger have an angle key setup?
	if (CheckZeroVector(self.movedir) == FALSE) {
		// Work out projectile angle using velocity
		self.pos4 = vectoangles(self.bmodel_act.velocity);
		makevectors (self.pos4);
		// Save v_forward (directional vector) for later
		self.pos5 = v_forward;

		// Work out trigger brush angle using movedir (angle)
		self.pos6 = vectoangles(self.movedir);
		makevectors (self.pos6);
		
		// Spawn debug vector angle markers (throttle to 0.5s intervals)
		if (self.attack_timer < time) {
			self.attack_timer = time + 0.5;
			spawn_arrow(self.bmodel_act.origin, self.pos4, 0);
			spawn_arrow(self.bmodel_act.origin, self.pos6, 4);
		}
		
		// Dot product (cos) between angle vectors
		self.lip = v_forward * self.pos5;
		// Use the same logic from the AI infront function
		// 1= perfect angle, 0 or less = 90+ angle difference
		// Default angle tolerance is 0.3 (ideal_yaw entity key)
		// This is about 60 degree's either side of trigger angle
		if (self.lip < self.ideal_yaw) return;
	}
	
	// Find out entity speed
	self.pos1 = self.bmodel_act.origin;
	self.pos2 = self.bmodel_act.velocity;
	// Add velocity to origin to create future position
	// Use vector length function to calc distance
	self.pos3 = self.pos1 + self.pos2;
	self.t_length = vlen(self.pos3 - self.pos1);
	
	// Dev Show velocity/speed of touching projectile
	//dprint("Velocity ("); dprint(ftos(self.t_length));
	//dprint(") Speed ("); dprint(ftos(self.speed));
	//dprint(")\n");
	
	// Check velocity/speed and fire targets
	if (self.t_length > self.speed) {
		// Centerprint messages require a client
		if (self.message != "") {
			self.enemy = world;
			// Try to find client; other, owner or client_ent
			if (self.bmodel_act.flags & FL_CLIENT) self.enemy = self.bmodel_act;
			else if (self.bmodel_act.owner.flags & FL_CLIENT) self.enemy = self.bmodel_act.owner;
			else self.enemy = client_ent;
			// Got a client? show message to all clients
			if (!self.enemy) dprint("\b[TRIG_VEL]\b No client for centerprint!");
			else centerprint(self.enemy, self.message);
		}
		// Fire target(s) if trigger successful
		if (self.target != "") trigger_strs(self.target, self.bmodel_act);

		// Grenades will keep bounding after hitting the trigger
		// Allow mappers to override this behaviour (entity key)
		// Make any grenades explode on contact (no bounce)
		if (self.spawnflags & TRIG_VELGRENADE && self.bmodel_act.classgroup == CG_PROJGRENADES && self.dmg_take) {
			self.bmodel_act.think = Explode_Grenade;
			self.bmodel_act.nextthink = time;
		}
		
		// Setup trigger to only work once?
		if (self.wait < 0) {
			self.attack_finished = LARGE_TIMER;
			self.estate_off();
		}
		// Slow down re-trigger events
		else self.attack_finished = time + self.waitmin;
	}
};

//----------------------------------------------------------------------
void() trigger_velocity_setup =
{
	// Setup Entity State functionality
	self.estate_fire = trigger_velocity_fire;
	// No extra conditions on the touch function
	self.touch = trigger_bmodel_anytouch;
	self.delay = 0;	// Reset delay variable
	trigger_bmodel_setup();
};

//----------------------------------------------------------------------
void() trigger_velocity =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_TRIGVELOCITY;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();

	// Spawnflag 1 is used for something else (notouch duplicate)
	// No trigger damage functionality and always touchable!
	self.spawnflags = self.spawnflags | TRIG_ALWAYTOUCH | TRIG_NODAMAGE;

	// Default entity key parameters
	if (self.waitmin <= 0) self.waitmin = 1;
	if (self.waitmin2 <= 0) self.waitmin2 = 1;
	if (!self.speed) self.speed = 500;
	if (self.ideal_yaw <= 0) self.ideal_yaw = 0.3;
	if (self.ideal_yaw > 1) self.ideal_yaw = 1;
	if (self.delay == 0) self.delay = 1;
	
	// This trigger is highly sensitive to touch functionality
	// Delay spawn/setup so that everything else can settle
	if (self.delay > 0) {
		self.think = trigger_velocity_setup;
		self.nextthink = time + self.delay;
	}
	// No delay specified by mapper
	else trigger_velocity_setup();
};

//======================================================================
/*QUAKED trigger_takeartifact (0.5 0 0.5) ? NOTOUCH ID AD VANIA x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Variable sized bmodel used to take powerups from the player
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target   : trigger all these targets
angle    : Facing Direction for trigger to work, use "360" for angle 0.
sounds   : 1=Secret,2=talk,3=switch,4=silent(def),5=custom,6=secret2
noise    : custom sound to play when triggered
message  : message to display when triggered
waitmin  : Override timer for powerup, anything below value is ignored (def=0)
waitmin2 : Slow down timer for trigger working again (def=0.1s)
waitmin3 : Slow down timer for sound playing (def=1s)
wait     : -1 = trigger once functionality (def=0)
-------- SPAWNFLAGS --------
NOTOUCH  : can only be triggered via other entities
ID       : Take only = Suit/InvRing/Quad/Pentagram
AD       : Take only = SharpShooter/Nail Piercer
VANIA    : Take only = Lavashield/Airtank/Blastbelt/Jumpboots
STARTOFF : Requires trigger to activate
-------- NOTES --------
Variable sized bmodel used to take powerups from the player

======================================================================*/
void() trigger_takeartifact_fire =
{
	local float inv_artifact;
	
	// Is the trigger blocked? (trigger_once)
	if (self.attack_finished > time) return;
	// Activator can only be the player
	if (!(self.bmodel_act.flags & FL_CLIENT)) return;
	if (self.bmodel_act.health < 1) return;
	
	inv_artifact = FALSE;
	// Turn off Suit/InvRing/Quad/Pentagram artifacts ONLY
	if (self.spawnflags & TRIG_TAKEARTID) {
		if ((self.bmodel_act.items & IT_INVISIBILITY) ||
			(self.bmodel_act.items & IT_INVULNERABILITY) ||
			(self.bmodel_act.items & IT_SUIT) ||
			(self.bmodel_act.items & IT_QUAD)) {
			inv_artifact = TRUE;
			ResetPowerInvRing(self.bmodel_act, self.waitmin);
			ResetPowerPent(self.bmodel_act, self.waitmin);
			ResetPowerEnvSuit(self.bmodel_act, self.waitmin);
			ResetPowerQuad(self.bmodel_act, self.waitmin);
		}
	}
	// Turn off SharpShooter/Nail Piercer artifacts ONLY
	if (self.spawnflags & TRIG_TAKEARTAD) {
		if ((self.bmodel_act.moditems & IT_ARTSHARP) ||
			(self.bmodel_act.moditems & IT_ARTPIERCE)) {
			inv_artifact = TRUE;
			ResetPowerSharp(self.bmodel_act, self.waitmin);
			ResetPowerPiercer(self.bmodel_act, self.waitmin);
		}
	}
	// Turn off Lavashield/Airtank/Blastbelt/Jumpboots artifacts ONLY
	if (self.spawnflags & TRIG_TAKEARTVANIA) {
		if ((self.bmodel_act.moditems & IT_ARTLAVASHIELD) ||
			(self.bmodel_act.moditems & IT_ARTAIRTANK) ||
			(self.bmodel_act.moditems & IT_ARTBLASTBELT) ||
			(self.bmodel_act.moditems & IT_ARTJUMPBOOTS)) {
			inv_artifact = TRUE;
			ResetPowerLavaShield(self.bmodel_act, self.waitmin);
			ResetPowerAirTank(self.bmodel_act, self.waitmin);
			ResetPowerBlastbelt(self.bmodel_act, self.waitmin);
			ResetPowerJumpBoots(self.bmodel_act, self.waitmin);
		}
	}
	
	// Found any active artifacts?
	if (inv_artifact) {
		// Extra triggers (target/targe2), message + sound
		activator = self.bmodel_act;
		SUB_UseTargets();
		
		// Play the sound ON the activator
		if (self.distance < time && self.noise != "") {
			// setup slow down timer
			self.distance = time + self.waitmin3;
			sound (activator, CHAN_VOICE, self.noise, self.volume, ATTN_NORM);
		}

		// Setup trigger to only work once?
		if (self.wait < 0) {
			self.attack_finished = LARGE_TIMER;
			self.estate_off();
		}
		// Slow down re-trigger timing
		else self.attack_finished = time + self.waitmin2;
	}
};

//----------------------------------------------------------------------
void() trigger_takeartifact =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors
	if (check_bmodel_notouch()) return;	// NO touch + NO targetname!
	
	self.classtype = CT_TRIGTAKEART;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();
	
	if (self.sounds <= 0) self.sounds = 4;	// Default = silence
	trigger_bmodel_sounds();				// Precache any sounds

	// check power timeout is not negative
	if (self.waitmin <= 0) self.waitmin = 0;
	// slowdown timer for re-triggering
	if (self.waitmin2 < 0.1) self.waitmin2 = 0.1;
	// slowdown timer for sounds
	if (self.waitmin3 < 0.1) self.waitmin3 = 1;
	
	// Check for remove all functionality (default)
	if (!(self.spawnflags & TRIG_TAKEARTALL))
		self.spawnflags = self.spawnflags | TRIG_TAKEARTALL;
	
	// Cannot have trigger touched by monsters
	self.spawnflags = self.spawnflags - (self.spawnflags & TRIG_MONSTERS);
	// No trigger damage functionality!
	self.spawnflags = self.spawnflags | TRIG_NODAMAGE;

	// Setup Entity State functionality
	self.estate_fire = trigger_takeartifact_fire;
	trigger_bmodel_setup();
};

//======================================================================
/*QUAKED trigger_giveitems (0.5 0 0.5) ? NOTOUCH x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Variable sized bmodel used to give items to player
The target items only work if delay spawned spawnflag is set
The pickup sound can be turned off by adding sounds=4 to item
The target items will not respawn or work more than once
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target  : Trigger items (only) to give to the player
target2 : Trigger other type of entities (relays, estate etc)
wait    : -1 = Always fire targets once (cannot be reset)
angle   : Facing Direction for trigger to work, use "360" for angle 0.
sounds  : 1=Secret,2=talk(def),3=switch,4=silent,5=custom,6=secret2
noise   : custom sound to play when triggered
message : message to display when triggered
-------- SPAWNFLAGS --------
NOTOUCH  : can only be triggered via other entities
STARTOFF : Requires trigger to activate
-------- NOTES --------
Variable sized bmodel used to give items to activator
The target items only work if delay spawned spawnflag is set
The pickup sound can be turned off by adding sounds=4 to item
The target items will not respawn or work more than once

======================================================================*/
void() trigger_giveitem_fire =
{
	local entity stemp;

	// Is the trigger blocked? (trigger_once)
	if (self.attack_finished > time) return;
	// Activator can only be the player
	if (!(self.bmodel_act.flags & FL_CLIENT)) return;
	if (self.bmodel_act.health < 1) return;
	if (self.target == "") return;

	// Save for later and reset activator
	stemp = self; activator = self.bmodel_act;

	// Play the sound ON the activator and display message
	if (self.noise != "") sound (activator, CHAN_VOICE, self.noise, self.volume, ATTN_NORM);
	if (self.message != "") centerprint (activator, self.message);
	
	// Search entity list for targets
	self.enemy = find (world, targetname, self.target);
	
	while(self.enemy) {
		// This only works with items
		if (self.enemy.flags & FL_ITEM) {
			// Only works with items that start off
			if (self.enemy.spawnflags & ENT_STARTOFF) {
				if (self.enemy.touch2 != SUB_Null) {
					// Switch to item for touch function
					other = self.bmodel_act;
					activator = self.bmodel_act;
					self = self.enemy; 
					// make sure items never respawn and silent pickup
					self.spawnflags = self.spawnflags - (self.spawnflags & ITEM_RESPAWN);
					self.respawn_time = -1;
					self.respawn_trig = FALSE;
					// item should always be floating (no drop to floor functions)
					self.spawnflags = self.spawnflags | ITEM_FLOATING;
					// give trigger sound overrides all items
					if (stemp.sounds != 4) self.noise = SOUND_EMPTY;
					// Use original touch function
					self.touch2 ();
					self = stemp;
					
				}
			}
		}
		// Are there anymore targets left in the list?
		self.enemy = find (self.enemy, targetname, self.target);
	}
	
	// Target is used for giving items only
	// Check if target2 for other entity types
	if (self.target2 != "")
		trigger_strs(self.target2, self.bmodel_act);
	
	// always TRIGGER_ONCE functionality
	self.attack_finished = LARGE_TIMER;
};

//----------------------------------------------------------------------
void() trigger_giveitems =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors
	if (check_bmodel_notouch()) return;	// NO touch + NO targetname!
	
	self.classtype = CT_TRIGGIVEITEM;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();
	
	if (self.sounds == 0) self.sounds = 4;	// Default = silence
	trigger_bmodel_sounds();				// Precache any sounds

	// Always trigger once functionality
	self.wait = -1;
	
	// Cannot have trigger touched by monsters
	self.spawnflags = self.spawnflags - (self.spawnflags & TRIG_MONSTERS);
	// No trigger damage functionality!
	self.spawnflags = self.spawnflags | TRIG_NODAMAGE;

	// Setup Entity State functionality
	self.estate_fire = trigger_giveitem_fire;
	trigger_bmodel_setup();
};

//======================================================================
/*QUAKED trigger_fog (.5 .5 .5) ? NOTOUCH x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Trigger change global fog to new value over time
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target  : name of target(s) to trigger
speed   : time (secs) to fade from current to new (-1 = instant, 2s = default)
wait    : time between re-triggering (def=2s, -1=once)
angle   : Facing Direction for trigger to work, use "360" for angle 0.
fog_density : new fog density (def=0.1, -1=debug mode, -2=debug+ mode)
fog_colour  : new fog colours (def=0.1 0.1 0.1)
-------- SPAWNFLAGS --------
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
Trigger change global fog to new value over time

======================================================================*/
void() trigger_fog_fire =
{
	// This is after bmodel _use, _killed and _touch, so any reference
	// to the trigger activator has to go through 'bmodel_act'
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;
	// AD 1.8 removed SVR_NOFOGCMDS (winquake idea)
	
	// Print dev message if worldspawn not setup correctly
	// First fog blend will be weird otherwise
	if (!fog_active) {
		if (self.pain_finished < time) {
			dprint("\b[FOG]\b Missing density + colour on worldspawn!\n");
			dprint("\b[FOG]\b First fog blend requires worldspawn setup\n");
		}
		self.pain_finished = time + 1;
	}	
	
	// Crazy test option, random fog!
	if (self.lefty > 0) {
		// Extra test mode (-2) for fog density 1-10
		if (self.lefty == 2) self.fog_density = random()*10;
		// Default test mode (-1) for fog density 0-1
		else self.fog_density = random();
		self.fog_colour_x = random();
		self.fog_colour_y = random();
		self.fog_colour_z = random();
		self.speed = 1 + random()*4;
		// Show values on console
		if (developer > 0) {
			dprint("[FOG] DRGB ("); 
			lftos(self.owner, self.fog_density, 2,3, BUFFER_DPRINT); dprint(")(");
			lftos(self.owner, self.fog_colour_x, 1,3, BUFFER_DPRINT); dprint(" ");
			lftos(self.owner, self.fog_colour_y, 1,3, BUFFER_DPRINT); dprint(" ");
			lftos(self.owner, self.fog_colour_z, 1,3, BUFFER_DPRINT); dprint(")\n");
		}
	}
	
	// Update global fog controller
	fade_fog(self.fog_density, self.fog_colour, self.speed);
	SUB_UseTargets();
	
	// Is the trigger repeatable?
	if (self.wait > 0) {
		if (self.wait < self.speed) self.wait = self.speed + 0.1;
		self.attack_finished = time + self.wait;
		self.nextthink = self.attack_finished;
		self.think = self.estate_on;
	}
	// block trigger and turn off (trigger_once)
	else {
		self.attack_finished = LARGE_TIMER;
		self.estate_off();
	}
};

//----------------------------------------------------------------------
void() trigger_fog_waitforcontrol =
{
	if (fog_control && fog_active) {
		// Setup Entity State functionality
		self.estate_fire = trigger_fog_fire;
		trigger_bmodel_setup();
	}
	else {
		self.think = trigger_fog_waitforcontrol;
		self.nextthink = time + 0.1 + random();
	}
};

//----------------------------------------------------------------------
void() trigger_fog =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors
	if (check_bmodel_notouch()) return;	// NO touch + NO targetname!
	
	self.classtype = CT_TRIGFOG;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();

	// A fade time < minimum fade time = instant change
	if (self.speed == 0) self.speed = 2;
	if (self.speed < FADEFOG_TIME) self.speed = FADEFOG_TIME;
	if (self.wait == 0) self.wait = 2;
	self.attack_finished = 0;
	
	// Cannot have trigger touched by monsters
	self.spawnflags = self.spawnflags - (self.spawnflags & TRIG_MONSTERS);

	// Check for debug test mode (random density/colour)
	if (self.fog_density == -10) self.lefty = 1;		// Density 0-1
	else if (self.fog_density == -20) self.lefty = 2;	// Density 0-10
	else self.lefty = 0;
	
	// Default density/colour
	if (self.fog_density < 0) self.fog_density = 0;
	else if (self.fog_density == 0) self.fog_density = DEF_FOGDEN;
	// Check for fog colour 0,0,0 (black) option
	if (self.fog_colour_x < 0 || self.fog_colour_y < 0 || self.fog_colour_z < 0)
		self.fog_colour = '0 0 0';
	// Default colour (0.1 0.1 0.1)
	else if (CheckZeroVector(self.fog_colour)) self.fog_colour = DEF_FOGCOL;

	trigger_fog_waitforcontrol();
};

//======================================================================
/*QUAKED trigger_skyfog (.5 .5 .5) ? NOTOUCH x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Trigger change global sky fog to new value over time
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target  : name of target(s) to trigger
speed   : time (secs) to fade from current to new (-1 = instant, 2s = default)
wait    : time between re-triggering (def=2s, -1=once)
angle   : Facing Direction for trigger to work, use "360" for angle 0.
skyfog_density : new sky fog density (def=0.5, -1=debug mode)
-------- SPAWNFLAGS --------
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
Trigger change global sky fog to new value over time

======================================================================*/
void() trigger_skyfog_fire =
{
	// This is after bmodel _use, _killed and _touch, so any reference
	// to the trigger activator has to go through 'bmodel_act'
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;
	// AD 1.8 removed SVR_NOFOGCMDS (winquake idea)
	
	// Print dev message if worldspawn not setup correctly
	// First sky fog blend will be weird otherwise
	if (!skyfog_active) {
		if (self.pain_finished < time) {
			dprint("\b[SKYFOG]\b Missing density on worldspawn!\n");
			dprint("\b[SKYFOG]\b First fog blend requires worldspawn setup\n");
		}
		self.pain_finished = time + 1;
	}	
	
	// Crazy test option, random sky fog!
	if (self.lefty > 0) {
		// Default test mode (-1) for fog density 0-1
		self.skyfog_density = random();
		self.speed = 1 + random();
		// Show values on console
		if (developer > 0) {
			dprint("[SKYFOG] Density ("); 
			lftos(self.owner, self.skyfog_density, 1,3, BUFFER_DPRINT); dprint(")\n");
		}
	}
	
	// Update global sky fog controller
	fade_skyfog(self.skyfog_density, self.speed);
	SUB_UseTargets();
	
	// Is the trigger repeatable?
	if (self.wait > 0) {
		if (self.wait < self.speed) self.wait = self.speed + 0.1;
		self.attack_finished = time + self.wait;
		self.nextthink = self.attack_finished;
		self.think = self.estate_on;
	}
	// block trigger and turn off (trigger_once)
	else {
		self.attack_finished = LARGE_TIMER;
		self.estate_off();
	}
};

//----------------------------------------------------------------------
void() trigger_skyfog_waitforcontrol =
{
	if (skyfog_control && skyfog_active) {
		// Setup Entity State functionality
		self.estate_fire = trigger_skyfog_fire;
		trigger_bmodel_setup();
	}
	else {
		self.think = trigger_skyfog_waitforcontrol;
		self.nextthink = time + 0.1 + random();
	}
};

//----------------------------------------------------------------------
void() trigger_skyfog =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors
	if (check_bmodel_notouch()) return;	// NO touch + NO targetname!

	self.classtype = CT_TRIGSKYFOG;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();

	// A fade time < minimum fade time = instant change
	if (self.speed == 0) self.speed = 2;
	if (self.speed < FADEFOG_TIME) self.speed = FADEFOG_TIME;
	if (self.wait == 0) self.wait = 2;
	self.attack_finished = 0;
	
	// Cannot have sky fog triggers touched by monsters
	self.spawnflags = self.spawnflags - (self.spawnflags & TRIG_MONSTERS);

	// Check for debug test mode (random density)
	if (self.skyfog_density == -10) self.lefty = 1;	// Density 0-1
	else self.lefty = 0;
	
	// Default density
	if (self.skyfog_density < 0) self.skyfog_density = 0;
	else if (self.skyfog_density == 0) self.skyfog_density = DEF_SKYFOGDEN;

	trigger_skyfog_waitforcontrol();
};

//======================================================================
/*QUAKED trigger_monsternojump (.5 .5 .5) ? x x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Stop monsters from using jump attack
-------- KEYS --------
targetname : trigger entity (works with entity state system)
wait   : -1 = trigger_once functionality
delay  : time to delay jump attack by (def=0.5s)
waitmin: Re-trigger timer to stop touch flooding (def=0.1s)
noise1 : specify classname that CAN use this trigger (noise1=monster_dog)
-------- SPAWNFLAGS --------
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
Stop monsters from using jump attack

======================================================================*/
void() trigger_monsternojump_fire =
{
	// This is after bmodel _use, _killed and _touch, so any reference
	// to the trigger activator has to go through 'bmodel_act'
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;
	
	// Block non-monsters
	if (!(self.bmodel_act.flags & FL_MONSTER)) return;

	// Is there any classname exception setup?
	if (self.noise1 != "") {
		if (self.bmodel_act.classname != self.noise1) return;
	}
	
	// Check for any extra triggers, fire them once!
	if (self.target != "") {
		trigger_strs(self.target, activator);
		self.target = "";
	}
	
	// Update jump flag to block jump attacks
	self.bmodel_act.jump_flag = time + self.delay;
	// Restrict the trigger to 0.1s re-triggering
	self.attack_finished = time + self.waitmin;

	// Setup to trigger push once?
	if (self.wait < 0) {
		self.attack_finished = LARGE_TIMER;
		self.estate_off();
	}
};

//----------------------------------------------------------------------
void() trigger_monsternojump =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_TRIGNOJUMP;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();
		
	if (!self.delay) self.delay = 0.5;
	if (!self.waitmin) self.waitmin = 0.1;

	// No trigger damage functionality and always touchable!
	self.spawnflags = self.spawnflags | TRIG_ALWAYTOUCH | TRIG_NODAMAGE;
	
	// Setup Entity State functionality
	self.estate_fire = trigger_monsternojump_fire;
	self.touch = trigger_bmodel_anytouch;
	trigger_bmodel_setup();
};

//----------------------------------------------------------------------
// Re-direct because it was renamed to be more consistent
void() trigger_nomonjump = { trigger_monsternojump(); };

//======================================================================
/*QUAKED trigger_monsterdrop (0 .5 .5) (-8 -8 -8) (8 8 8) x x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Drop monster(s) to floor
-------- KEYS --------
targetname : trigger entity (works with entity state system)
wait   : -1 = trigger_once functionality
height : the speed thrown upwards (def 50)
-------- SPAWNFLAGS --------
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
Drop monster(s) to floor
======================================================================*/

void() trigger_monsterdrop_use =
{
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;
	if (self.target == "") return;
	
	// Build initial list from world
	self.oldenemy = find(world, targetname, self.target);
	while (self.oldenemy) {
		// only works with monsters
		if (self.oldenemy.flags & FL_MONSTER) {
			// Double check for swim/fly types
			if (!(self.oldenemy.flags & (FL_FLY || FL_SWIM))) {
				// Got to be onground already
				if (self.oldenemy.flags & FL_ONGROUND) {
					// Set monster in motion
					self.oldenemy.flags = self.oldenemy.flags - FL_ONGROUND;
					self.oldenemy.velocity_z = self.height;
				}
			}
		}
		// Find next monster in list
		self.oldenemy = find(self.oldenemy, targetname, self.target);
	}
	// Setup to trigger once functionality?
	if (self.wait < 0) {
		self.attack_finished = LARGE_TIMER;
		self.estate_off();
	}
};

//----------------------------------------------------------------------
void() trigger_monsterdrop =
{
	self.classtype = CT_TRIGMONDROP;
	self.classgroup = CG_TARGETS;

	// Check for firing conditions (nightmare, coop)
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	if (!self.height) self.height = 50;
		
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trigger_monsterdrop_use;
	self.estate = ESTATE_ON;
};

//======================================================================
/*QUAKED trigger_monsterjump (.5 .5 .5) ? x FLYING SWIMMING x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Push monsters in a certain direction
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target     : target entity for custom direction
target2    : targets to fire when the trigger is used
wait       : -1 = trigger_once functionality
angle      : direction of push (-2 is down, -1 up)
angletarget: targeting entity used for custom direction
mangle     : facing direction for activating the trigger
speed      : the speed thrown forward (def 200)
height     : the speed thrown upwards (def 200)
noise1     : specify classname that CAN use this trigger (noise1=monster_dog)
-------- SPAWNFLAGS --------
FLYING   : Will affect flying monsters
SWIMMING  : Will affect swimming monsters
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
Push monsters in a certain direction
This entity cannot be damaged and is always touchable once activated

======================================================================*/
void() trigger_monsterjump_fire =
{
	// This is after bmodel _use, _killed and _touch, so any reference
	// to the trigger activator has to go through 'bmodel_act'
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;
	
	// Cannot move spawning statues
	if (self.bmodel_act.spawnstatue) return;
	// Check monster is not jumping already
	if (self.bmodel_act.jump_flag > time) return;
	// Cannot make dead bodies jump
	if (self.bmodel_act.bodyonflr == MON_ONFLR) return;
	// entity excluded from using monster jump triggers
	if (self.bmodel_act.ignore_monjump > 0) return;
	
	// Did the trigger have an angle key setup?
	if (!CheckZeroVector(self.movedir2)) {
		makevectors (self.bmodel_act.angles);
		if (v_forward * self.movedir2 < 0) return;		
	}
	
	// Block non-monsters and fly/swim if spawnflag not set
	if (!(self.bmodel_act.flags & FL_MONSTER)) return;
	if (!(self.spawnflags & TRIG_MONJUMPFLY) && self.bmodel_act.flags & FL_FLY) return;
	if (!(self.spawnflags & TRIG_MONJUMPSWIM) && self.bmodel_act.flags & FL_SWIM) return;

	// Is there any classname exception setup?
	if (self.noise1 != "") {
		if (self.bmodel_act.classname != self.noise1) return;
		// extra special condition for enraged drole's
		if (self.bmodel_act.classtype == CT_MONDROLE && !self.bmodel_act.attack_rage) return;
	}
	
	// Check for any triggers, fire them once!
	if (self.target != "") {
		trigger_strs(self.target, activator);
		self.target = "";
	}
	// Check for any additional targets (no activator set)
	if (self.target2 != "") trigger_strs(self.target2, activator);
	
	// Flying/Swimming monsters only need a push in the right direction
	if (self.bmodel_act.flags & FL_FLY || self.bmodel_act.flags & FL_SWIM) {
		self.bmodel_act.velocity = self.movedir * self.speed;
	}
	else {
		// set XY even if not on ground, so the jump will clear lips
		self.bmodel_act.velocity_x = self.movedir_x * self.speed;
		self.bmodel_act.velocity_y = self.movedir_y * self.speed;
		// If monster on the ground, lift them up	
		if (self.bmodel_act.flags & FL_ONGROUND ) {
			self.bmodel_act.flags = self.bmodel_act.flags - FL_ONGROUND;
			self.bmodel_act.velocity_z = self.height;
		}
	}

	// Setup to trigger push once?
	if (self.wait < 0) {
		self.attack_finished = LARGE_TIMER;
		self.estate_off();
	}
};

//----------------------------------------------------------------------
void() trigger_monsterjump =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_TRIGMONJUMP;
	self.classgroup = CG_TRIGGERS;
	
	// Check for a facing angle (used later in fire function)
	if (!CheckZeroVector(self.mangle)) {
		makevectors (self.mangle);
		self.movedir2 = v_forward;
	}
	// Default setup (not used)
	else self.movedir2 = '0 0 0';
	// Default jump angle is 360, needs to be set BEFORE InitTrigger
	if (self.angles_y == 0) self.angles_y = 360;
	InitTrigger ();

	if (!self.speed) self.speed = 200;
	if (!self.height) self.height = 200;

	// No trigger damage functionality and always touchable!
	self.spawnflags = self.spawnflags | TRIG_ALWAYTOUCH | TRIG_NODAMAGE;
	
	// Setup Entity State functionality
	self.estate_fire = trigger_monsterjump_fire;
	self.touch = trigger_bmodel_anytouch;
	trigger_bmodel_setup();

	// If target is setup, calculate new facing angle
	if (self.target != "") {
		self.angletarget = self.target;
		self.nextthink = time + 1 + random();
		self.think = TargetMovedirReturn;
	}
};

//----------------------------------------------------------------------
void() trigger_drolejump =
{
	self.noise1 = "monster_drole";
	trigger_monsterjump();
};

//======================================================================
/*QUAKED trigger_monsterturret (0.5 0.3 0) ? x x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Temporarily turn a monster into a turret
-------- KEYS --------
targetname : trigger entity (works with entity state system)
wait   : -1 = Only trigger a monster turret function once
count  : random chance to pause; constant = -1, def = 0.25, range = 0 - 1
noise1 : only works with this type of monster (monster_ogre)
-------- SPAWNFLAGS --------
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
Temporarily turn a monster into a turret
This entity cannot be damaged and is always touchable once activated

======================================================================*/
void() trigger_monsterturret_fire =
{
	// This is after bmodel _use, _killed and _touch, so any reference
	// to the trigger activator has to go through 'bmodel_act'

	local entity tself;
	
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;	// trigger_once functionality
	if (!(self.bmodel_act.flags & FL_MONSTER)) return;	// ONLY Monsters!
	if (self.bmodel_act.health < 1) return;		// Dead things cannot be turrets!
	if (self.bmodel_act.movespeed < 0) return;	// Already a turret!?!
	if (!self.bmodel_act.enemy) return;			// This is a combat node only
	if (self.bmodel_act.turretactive) return;	// Already using a turret position
	if (!self.bmodel_act.th_missile) return;	// Only works if got range attack
	if (self.noise1 != "") { if (self.noise1 != self.bmodel_act.classname) return; }

	// Switch to monster
	tself = self;
	self = self.bmodel_act; other = tself;
	//  check enemy visibility and direction
	if (visible(self.enemy) && infront(self.enemy)) {
		// Link the monster to the turret (used by ai_run)
		self.turretactive = other;
	}

	self = tself;
	// Setup to trigger push once?
	if (self.wait < 0) {
		self.attack_finished = LARGE_TIMER;
		self.estate_off();
	}
};

//----------------------------------------------------------------------
void() trigger_monsterturret =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_TRIGMONTURRET;
	self.classgroup = CG_TRIGGERS;
	if (self.angles_y == 0) self.angles_y = 360;
	InitTrigger ();

	if (self.count < 0) self.count = -1;
	else if (self.count == 0 || self.count > 1) self.count = 0.25;
	
	// No trigger damage functionality and always touchable!
	self.spawnflags = self.spawnflags | TRIG_ALWAYTOUCH | TRIG_NODAMAGE;
	
	// Setup Entity State functionality
	self.estate_fire = trigger_monsterturret_fire;
	self.touch = trigger_bmodel_anytouch;
	trigger_bmodel_setup();
};

//======================================================================
/*QUAKED trigger_hurt (.5 .5 .5) ? x BUBBLES MONSTER_ONLY x MODCHECK FALLING STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Will hurt any touching entity
-------- KEYS --------
targetname : trigger entity (works with entity state system)
dmg     : damage from contact with trigger (def=5)
dmgskill: damage based on skill level X=Easy, Y=Normal, Z=Hard/NM (def=0,0,0)
wait    : time between pain contact (def=1s)
angle   : Facing Direction for trigger to work, use "360" for angle 0.
speed   : used by falling spawnflag for velocity check (def=300)
height  : Maximum travel distance up for bubbles (default trigger size)
count   : total amount of active bubbles at once (default 5)
style   : 1-15 (grey,brown1,blue1,green1,red1,brown2,pinkyel,brown3,purp1,purp2,brown4,green2,yellow,blue2,red2)
-------- SPAWNFLAGS --------
BUBBLES  : Spawn bubbles within trigger volume when active
MONSTER_ONLY : Will only affect monsters
MODCHECK : Will remove this entity if THIS mod is active
FALLING  : Only hurts if the player is falling (speed=velocity)
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
Will hurt any touching entity that can take damage
This entity cannot be damaged and is always touchable once activated

======================================================================*/
void() trigger_hurt_fire =
{
	// This is after bmodel _use, _killed and _touch, so any reference
	// to the trigger activator has to go through 'bmodel_act'
	if (self.attack_finished > time) return;
	if (self.bmodel_act.takedamage == DAMAGE_NO) return;
	if (self.spawnflags & TRIG_HURTMONSTER && !(self.bmodel_act.flags & FL_MONSTER)) return;
	// Check for falling damage conditions (player + flying + speeding)
	if (self.spawnflags & TRIG_HURTFALLING) {
		// Only affects players and monsters
		if (!(self.bmodel_act.flags & FL_MONSTER) &&
			!(self.bmodel_act.flags & FL_CLIENT)) return;
		if (self.bmodel_act.flags & FL_ONGROUND) return;
		// Can't kill something dead already!
		if (self.bmodel_act.health < 1) return;
		if (fabs(self.bmodel_act.velocity_z) < self.speed) return;
	}
	
	// Check for any dead monster bodies (no exceptions)
	if (trigger_check_body(self.bmodel_act,DEAD_EXPLODE)) return;

	// Check for godmode players taking screenshots!
	if (self.bmodel_act.flags & FL_CLIENT && self.bmodel_act.flags & FL_GODMODE) return;
	
	// Block touch function based on wait time
	self.attack_finished = time + self.wait;
	// Work out damage based on skill level
	self.dmg = trigger_dmgquery();
	// Do the damage (using armour/pent resistance)
	T_Damage (self.bmodel_act, self, self, self.dmg, DAMARMOR);
};

//----------------------------------------------------------------------
void() trigger_hurt_on =
{
	self.estate = ESTATE_ON;
	self.solid = SOLID_TRIGGER;
	// Restore bounding box (dev testing visual thing)
	setsize (self, self.bbmins, self.bbmaxs);
	// Spawn bubbles inside volume brush
	trigger_spawn_bubbles();
};

//----------------------------------------------------------------------
void() trigger_hurt =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors
	if (check_bmodel_modver()) return;	// Check mod version correct

	self.classtype = CT_TRIGHURT;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();

	trigger_dmgsetup(5);	// Setup default dmg
	if (self.wait <= 0) self.wait = 1;

	// Setup bubble model/counter/volume
	if (self.spawnflags & TRIG_SPAWNBUBBLES) trigger_setup_bubbles();
	
	// Setup default falling damage speed
	if (self.spawnflags & TRIG_HURTFALLING && self.speed < 1) self.speed = 300;

	// No trigger damage functionality and always touchable!
	self.spawnflags = self.spawnflags | TRIG_ALWAYTOUCH | TRIG_NODAMAGE;

	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_on = trigger_hurt_on;
	self.estate_off = trigger_bmodel_off;
	self.estate_disable = trigger_bmodel_disable;
	if (self.dmg > 0) {
		self.estate_fire = trigger_hurt_fire;
		self.touch = trigger_bmodel_anytouch;
	}

	// Switch on OR off?
	if (self.spawnflags & ENT_STARTOFF) self.estate_off();
	else self.estate_on();
};

//======================================================================
/*QUAKED trigger_heal (.5 .5 .5) ? x BUBBLES x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Heals any player who touches this trigger
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target  : trigger once when players stands in trigger (start cycle)
target2 : trigger once when healing expires (finish cycle)
wait    : time between healing (default 1s)
healamount : amount to heal each time touched (default 10)
max_health : total amount to heal (default 50, -1=no limit)
sounds  : 1=heal_15, 2=heal_25, 3=heal_100, 4=respawn, 5=custom (default 1)
noise   : Custom sound for healing
lip     : All messages are silent to the player (heal/expire) 1=block heal 2=block all
message : centerprints when players stands in trigger
message2 : centerprints when healing function has expired
height  : Maximum travel distance up for bubbles (default trigger size)
count   : total amount of active bubbles at once (default 5)
style   : 1-15 (grey,brown1,blue1,green1,red1,brown2,pinkyel,brown3,purp1,purp2,brown4,green2,yellow,blue2,red2)
yaw_speed : spawning rate (def=0.5) for bubbles (speed + random() x speed)
-------- SPAWNFLAGS --------
BUBBLES  : Spawn bubbles within trigger volume when active
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
Heals any player who touches this trigger, can be triggered on/off and produces 
bubbles within the bounding box of the trigger when spawnflag enabled

======================================================================*/
void() trigger_heal_touch =
{
	if (self.estate & ESTATE_BLOCK) return;		// Function off/disabled
	if (self.attack_finished > time) return;	// Touch blocked (temporary)
	if ( !(other.flags & FL_CLIENT) ) return;	// Only works with clients
	if (other.health < 1 ) return;				// Cannot heal, target is dead
	if (self.health < 1) return;				// Run out of health
	
	// Do not constantly check healing, use wait
	self.attack_finished = time + self.wait;

	// Can the pool heal the player?
	if (!T_Heal(other, self.healamount, 0)) return;

	// Healing sound		
	sound (other, CHAN_BODY, self.noise, self.volume, ATTN_NORM);
	// Has the pool run out of health?
	if (self.max_health > 0) self.health = self.health - self.healamount;
		
	// Has the healing trigger expired?
	if (self.health < 1) {
		// Only block message lip=1 healing 2=all messages
		if (self.lip < 2) centerprint (other, self.message2);
		// Fire any targets once (finish of healing cycle)
		if (self.target2 != "") {trigger_strs(self.target2, other);self.target2 = "";}
		// Switch off healing trigger
		entity_state_off();
	}
	else {
		// Fire any targets once (start of healing cycle)
		if (self.target != "") {trigger_strs(self.target, other);self.target = "";}
		// Display healing message (check for lip block)
		if (!self.lip) centerprint (other, self.message);
	}
};	

//----------------------------------------------------------------------
void() trigger_heal_on =
{
	if (self.health > 0) {
		self.estate = ESTATE_ON;
		self.solid = SOLID_TRIGGER;
		// Restore bounding box (dev testing visual thing)
		setsize (self, self.bbmins, self.bbmaxs);
		// Spawn bubbles inside volume brush
		trigger_spawn_bubbles();
	}
};

//----------------------------------------------------------------------
void() trigger_heal_reset =
{
	if (self.max_health > 0) {
		// Reset health, targets and switch on entity 
		self.health = self.max_health;
		if (self.noise1 != "") self.target = self.noise1;
		if (self.noise2 != "") self.target2 = self.noise2;
		self.estate_on();
	}
};

//----------------------------------------------------------------------
void() trigger_heal =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_TRIGHEAL;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();

	// Setup default healing sound
	if (self.sounds == 2) self.noise = SOUND_HEAL25;
	else if (self.sounds == 3) self.noise = SOUND_HEAL100;
	else if (self.sounds == 4) self.noise = SOUND_RESPAWN;
	else if (self.sounds == 5 && self.noise == "") self.noise = SOUND_HEAL15;
	else self.noise = SOUND_HEAL15;
	precache_sound(self.noise);
	trigger_bmodel_volume(1);

	// Setup bubble model/counter/volume
	if (self.spawnflags & TRIG_SPAWNBUBBLES) trigger_setup_bubbles();

	if (!self.wait) self.wait = 1;					// Default trigger time
	if (self.healamount < 1) self.healamount = 10;	// Quantity to heal each touch trigger
	if (!self.max_health) self.max_health = 50;		// Default max healing
	// Cannot have healamount large than max, need to cap healamount
	if (self.max_health > 0 && self.max_health < self.healamount) 
		self.healamount = self.max_health;

	if (self.max_health < 0) self.health = 100;		// max < 0 = Infinite healing
	else self.health = self.max_health;				// Reset total ready
		
	if (!self.message) self.message = "You feel the effects of the healing pool";
	if (!self.message2) self.message2 = "The Healing Pool has expired!";
	
	// Save any trigger names for reset events	
	if (self.target != "" ) self.noise1 = self.target;
	if (self.target2 != "" ) self.noise2 = self.target2;

	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_on = trigger_heal_on;
	self.estate_off = trigger_bmodel_off;
	self.estate_disable = trigger_bmodel_disable;
	self.estate_reset = trigger_heal_reset;
	self.touch = trigger_heal_touch;

	// Switch on OR off?
	if (self.spawnflags & ENT_STARTOFF) self.estate_off();
	else self.estate_on();
};

//======================================================================
/*QUAKED trigger_touchsound (.5 .5 .5) ? x x WORLDGEO DRAIN x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Plays sounds when touched by the player
------- KEYS --------
targetname : trigger entity (works with entity state system)
sounds     : 1=Water (def) 2=Slime 3=Lava 4=silent 5=custom
noise      : Custom trigger touch sound
noise1     : Custom trigger exit sound
noise2     : Custom draining sound
speed      : Time (def=1.5s) to drain liquid
yaw_speed  : Vertical drain speed (def=0.05)
water_alpha: Alpha value for liquid (override worldspawn)
-------- SPAWNFLAGS --------
WORLDGEO : Will draw bmodel (not just a trigger)
DRAIN    : Drain effect when trigger_disabled
STARTOFF : Requires trigger to activate
------- NOTES --------
Plays sounds when touched by the player

======================================================================*/
void() trigger_tsound_touch =
{
	if (self.estate & ESTATE_BLOCK) return;		// Function off/disabled
	if (self.attack_finished > time) return;	// Touch blocked (temporary)
	if ( !(other.flags & FL_CLIENT) ) return;	// Only works with clients
	if (other.health < 1 ) return;				// other is dead

	if (other.touchedliquid < time)
		sound (other, CHAN_BODY, self.noise, self.volume, ATTN_NORM);
	other.touchedliquid = time + 0.1;
	other.touchedsound = self.noise1;
	self.attack_finished = time + 0.05;
};

//----------------------------------------------------------------------
void() trigger_tsound_on =
{
	// No longer need this spawnflag, remove it
	self.spawnflags = self.spawnflags - (self.spawnflags & ENT_STARTOFF);
	
	self.estate = ESTATE_ON;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	self.origin = self.oldorigin;
	self.alpha = self.water_alpha;
	if (self.spawnflags & TRIG_TSOUNDWGEO) setmodel (self, self.mdl);
};

//----------------------------------------------------------------------
void() trigger_tsound_fade =
{
	// Take draining time and divide by time passed
    self.lip = self.speed - ((time - self.ltime) / self.speed);
	// Start at current alpha value and move towards 0
	self.alpha = self.lip * (self.water_alpha / self.speed);
	// Slowly sink into the ground as alpha fading
	self.origin_z = self.origin_z - (self.speed * self.yaw_speed);
	// Exit condition
    if (self.alpha <= 0) {
        self.alpha = 0.01;
		self.modelindex = 0;		// Make sure no model
		self.model = "";
		self.estate = ESTATE_OFF;
        return;
    }
	// Keep on loop (using minimum QS time segment)
    self.nextthink = time + FADEMODEL_TIME;
};

//----------------------------------------------------------------------
void() trigger_tsound_drain =
{ sound(self, CHAN_AUTO, self.owner.noise2, self.owner.volume, ATTN_NORM); };

//----------------------------------------------------------------------
void() trigger_tsound_disable =
{
	if (self.estate & ESTATE_BLOCK) return;
	self.solid = SOLID_NOT;
	self.estate = ESTATE_DISABLE;
	
	if (self.spawnflags & TRIG_TSOUNDDRAIN) {
		// Allow for bmodel timer to alpha correctly
		self.ltime = time;
		// Gradually fade and lower bmodel
		self.think = trigger_tsound_fade;
		self.nextthink = time + FADEMODEL_TIME;
		// Start playing draining sound
		self.sound_emitter.think = trigger_tsound_drain;
		self.sound_emitter.nextthink = time + self.super_time;
	}
};

//----------------------------------------------------------------------
void() trigger_tsound_syncalpha =
{
	// Allow for trigger to override global water alpha
	if (self.water_alpha > 0) self.alpha = self.water_alpha;
	else if (liquid_alpha > 0) self.alpha = liquid_alpha;
	else self.alpha = 1;
	// Save this value for later
	self.water_alpha = self.alpha;
	if (!(self.spawnflags & ENT_STARTOFF)) self.estate_on();
};

//----------------------------------------------------------------------
void() trigger_touchsound =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_TRIGTSOUND;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();
	
	if (!self.speed) self.speed = 1.5;
	if (!self.yaw_speed) self.yaw_speed = 0.05;
	if (self.super_time < 0.1) self.super_time = 0.1;
	self.attack_finished = 0;
	// Restored later for ON function
	self.oldorigin = self.origin;

	// Default sounds (water)
	if (self.sounds < 1) self.sounds = 1;
	
	// Precache all sounds
	if (self.sounds == 1) {
		if (self.noise == "") self.noise = "player/inh2o.wav";
		if (self.noise1 == "") self.noise1 = "misc/outwater.wav";
	}
	else if (self.sounds == 2) {
		if (self.noise == "") self.noise = "player/slimbrn2.wav";
		if (self.noise1 == "") self.noise1 = "misc/outwater.wav";
	}
	else if (self.sounds == 3) {
		if (self.noise == "") self.noise = "player/inlava.wav";
		if (self.noise1 == "") self.noise1 = "misc/outwater.wav";
	}
	// make sure there is always a sound (empty) defined
	if (self.noise == "") self.noise = SOUND_EMPTY;
	if (self.noise1 == "") self.noise1 = SOUND_EMPTY;

	precache_sound(self.noise);
	precache_sound(self.noise1);	
	trigger_bmodel_volume(1);
	
	if (self.spawnflags & TRIG_TSOUNDDRAIN) {
		if (self.noise2 == "") self.noise2 = "ambience/liquid_drain.wav";
		precache_sound(self.noise2);
		// Create an entity to play drain sound
		// bmodel origins are at 0,0,0 so never play properly
		self.sound_emitter = spawn();
		self.sound_emitter.owner = self;
		self.sound_emitter.origin = bmodel_origin(self) + '0 0 32';
		self.sound_emitter.solid = SOLID_NOT;
		self.sound_emitter.movetype = MOVETYPE_NONE;
		setmodel(self.sound_emitter, MODEL_EMPTY);
		setorigin(self.sound_emitter, self.sound_emitter.origin);
	}
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_on = trigger_tsound_on;
	self.estate_off = trigger_bmodel_off;
	self.estate_disable = trigger_tsound_disable;
	self.touch = trigger_tsound_touch;

	// Switch off?
	if (self.spawnflags & ENT_STARTOFF) self.estate_off();
	
	// Sync the water alpha console variable
	self.think = trigger_tsound_syncalpha;
	self.nextthink = time + 0.1 + random();
};

//======================================================================
/*QUAKED trigger_void (.5 .5 .5) ? NO_CLIENT NO_MONSTER NO_AMMO NO_EGG NO_TEMP NO_ITEM STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Garbage collector for bottom of skyboxes
------- KEYS --------
targetname : trigger entity (works with entity state system)
-------- SPAWNFLAGS --------
NO_CLIENT  : Ignore clients (anything flagged as a client)
NO_MONSTER : Ignore monsters (anything flagged as a monster)
NO_AMMO    : Ignore ammo types (all ammo projectile types)
NO_EGG     : Ignore minion eggs (affects shalrath, wraiths)
NO_TEMP    : Ignore temporary ents (gibs, sparks, smoke)
NO_ITEM    : Ignore items (weapons,armor,keys,runes,powerups)
STARTOFF : Requires trigger to activate
------- NOTES --------
Garbage collector for bottom of skyboxes
======================================================================*/
void() trigger_void_touch =
{
	// Exception, entity state and particles!
	if (self.estate & ESTATE_BLOCK) return;
	if (other.classtype == CT_PARTICLE) return;

	// Hazard projectiles MUST update counters (no exceptions)
	if (other.classgroup == CG_PROJHAZARD) {
		HazardProjectile_Finished(other); return; }
	
	// Check for any dead monster bodies (no exceptions)
	if (trigger_check_body(other,DEAD_REMOVE)) return;
	
	// Process spawnflag exceptions
	if (self.spawnflags & TRIG_VOIDNOCLIENT && other.flags & FL_CLIENT) return;
	if (self.spawnflags & TRIG_VOIDNOMONSTER && other.flags & FL_MONSTER) return;
	if (self.spawnflags & TRIG_VOIDNOAMMO) {
		if (other.classgroup == CG_PROJALL) return;
		else if (other.classgroup == CG_PROJSHELLS) return;
		else if (other.classgroup == CG_PROJNAILS) return;
		else if (other.classgroup == CG_PROJROCKETS) return; // Rocket+Homing
		else if (other.classgroup == CG_PROJGRENADES) return;
		else if (other.classgroup == CG_PROJCELLS) return;
	}
	if (self.spawnflags & TRIG_VOIDNOGG && other.classgroup == CG_MINIONEGG) return;
	if (self.spawnflags & TRIG_VOIDNOTEMP && other.classgroup == CG_TEMPENT) return;
	if (self.spawnflags & TRIG_VOIDNOITEM) {
		if (other.classgroup == CG_WEAPON) return;
		else if (other.classgroup == CG_AMMOITEM) return;
		else if (other.classgroup == CG_ARMOR) return;
		else if (other.classgroup == CG_KEY) return;
		else if (other.classgroup == CG_RUNE) return;
		else if (other.classgroup == CG_ARTIFACT) return;
	}
	
	// flag touching entity, so other functions will ignore it
	other.touchedvoid = TRUE;
	
	// Let monsters and clients die through their own functions
	if (other.flags & FL_CLIENT || other.flags & FL_MONSTER)
		T_Damage (other, self, self, other.health+8, NOARMOR);
	else {
		// Remove all ammo projectiles on contact
		// Hide other items types (may have particles active)
		if (other.classgroup == CG_PROJALL) entity_remove(other,0.1);
		else if (other.classgroup == CG_PROJSHELLS) entity_remove(other,0.1);
		else if (other.classgroup == CG_PROJNAILS) entity_remove(other,0.1);
		else if (other.classgroup == CG_PROJROCKETS) entity_remove(other,0.1);
		else if (other.classgroup == CG_PROJGRENADES) entity_remove(other,0.1);
		else if (other.classgroup == CG_PROJCELLS) entity_remove(other,0.1);
		else if (other.classgroup == CG_MINIONEGG) entity_remove(other,0.1);
		else if (other.classgroup == CG_TEMPENT) entity_remove(other,0.1);
		else if (other.classgroup == CG_WEAPON) entity_hide(other);
		else if (other.classgroup == CG_AMMOITEM) {
			entity_hide(other);
			// Hide any shell/nail lids
			if (other.attachment) entity_hide(other.attachment);
		}
		else if (other.classgroup == CG_ARMOR) entity_hide(other);
		else if (other.classgroup == CG_KEY) entity_hide(other);
		else if (other.classgroup == CG_RUNE) entity_hide(other);
		else if (other.classgroup == CG_ARTIFACT) entity_hide(other);
		else if (other.classgroup == CG_MISCENT) entity_hide(other);
		else if (other.classgroup == CG_BREAKABLE) entity_hide(other);
	}
};

//----------------------------------------------------------------------
void() trigger_void =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_TRIGVOID;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();
	// Activate trigger (always ON)
	setsize (self, self.bbmins, self.bbmaxs);

	// Setup Entity State functionality
	// This does not work via typical trigger bmodel paths
	// This trigger is special, needs to work straight away
	// There is only a toggle/on/off state function
	if (self.targetname != "") self.use = entity_state_use;
	self.touch = trigger_void_touch;
	if (self.spawnflags & ENT_STARTOFF) self.estate = ESTATE_OFF;
	else self.estate = ESTATE_ON;
};

