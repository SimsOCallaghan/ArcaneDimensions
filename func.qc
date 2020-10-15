/*======================================================================
BMODELS FUNCTIONS

func_wall        Solid switchable wall/objects
func_togglewall  Solid invisible switchable wall/object
func_illusionary Fake switchable walls
func_episodegate Solid block that disappears when got special runes
func_bossgate    Solid block that disappears when all runes found
func_laser       Solid barrier with particle effects
func_skill       Switch skill level
func_bob         Floating architecture (misc_bob=model version)

======================================================================*/

float FUNC_AFRAME = 2;			// Start with A frame (animated textures)
float FUNC_MODCHECK = 16;		// Will remove this entity if THIS mod is active

float FUNC_TWALLOFF = 1;		// Starts off and waits for trigger

float FUNC_LASERSOLID = 2;		// Func bmodel blocks on all sides
float FUNC_LASERNODMG = 4;		// Func bmodel does no touch damage

float FUNC_SKILLSTARTOPEN = 1;	// Reverse setup for lighting issues
float FUNC_SKILLCHAOSMODE = 2;	// Check for chaos setup instead of skill
float FUNC_SKILLSTARTDIS = 32;	// Pillar starts in disabled state

float BOB_COLLISION = 2;		// Collision for misc_bob
float BOB_NONSOLID = 4;			// Non solid for func_bob

float FUNC_FADEUP = 1;			// Fading up from 0 -> 1 (default)
float FUNC_FADEDN = -1;			// Fading down from 1 -> 0
float FUNC_FADEFULL = 1;		// Maximum Alpha
float FUNC_FADEZERO = 0.01;		// Minimum Alpha

//----------------------------------------------------------------------
// Fade functionality for func_wall and func_illusionary
//----------------------------------------------------------------------
void() func_bmodelfade_think =
{
	// How much time has passed? (using ltime because bmodel)
	self.waitmin2 = time - self.ltime;
	// Work out alpha = (total_time - time_passed) / total_time
	self.waitmin3 = (self.waitmin - self.waitmin2)/self.waitmin;
	// Fading Downward? Reverse alpha (1->0)
	// Have to add 0.01 because the engine treats 0 as 1 alpha
	if (self.lip == FUNC_FADEUP) self.waitmin3 = (1 - self.waitmin3) + 0.01;
	// Detect alpha start between 0 and 1
	if (self.alphadiff < 1) {
		// Check for fading direction
		if (self.lip == FUNC_FADEDN) self.alpha = self.waitmin3 * self.alphadiff;
		else self.alpha = self.alphastart + (self.waitmin3 * self.alphadiff);
	}
	// Default full fade from 0->1 and 1->0
	else self.alpha = self.waitmin3;
	
	// Check for alpha exit conditions
    if (self.alpha > FUNC_FADEFULL) {
		self.alpha = FUNC_FADEFULL;
		// Switch func_wall back to being solid again
		if (self.classtype == CT_FUNCWALL) {
			self.movetype = MOVETYPE_PUSH;
			self.solid = SOLID_BSP;
			setmodel (self, self.mdl);
		}
	}
	// hide entity, no longer required anymore
    else if (self.alpha < FUNC_FADEZERO) entity_hide(self);
	else {
		// Keep looping through alpha values
		self.think = func_bmodelfade_think;
		self.nextthink = time + FADEMODEL_TIME;
	}
};

//----------------------------------------------------------------------
void() func_bmodelfade_use = 
{
	// Deal with STARTOFF functionality first
	if (self.spawnflags & ENT_STARTOFF) self.estate_on();
	else {
		// Block USE functionality if state wrong
		if (self.estate & ESTATE_BLOCK) return;
		
		// Only fade this once!
		if (self.wait < 0) return;
		self.wait = -1;

		// Switch func_wall to illusionary ready for fade
		if (self.classtype == CT_FUNCWALL) {
			self.movetype = MOVETYPE_NONE;
			self.solid = SOLID_NOT;
			setmodel (self, self.mdl);
		}

		// Setup alpha before fading
		self.alpha = self.alphastart;
		// Check for any fading delay?
		if (self.delay > 0) {
			self.think = func_bmodelfade_think;
			self.nextthink = time + self.delay;
			self.ltime = self.nextthink;
		}
		else {
			self.ltime = time;
			func_bmodelfade_think();
		}
	}
};

//----------------------------------------------------------------------
float() func_bmodelfade_setup =
{
	// Is this bmodel suppose to fade on use?
	if (self.alphastart > 0) {
		// Total fade time (in seconds)
		if (self.waitmin <= 0) self.waitmin = 1;
		// Alpha direction -1=Down(1<-0), 1=Up(0->1), Def=1
		if (self.lip >= 0) self.lip = FUNC_FADEUP;
		else self.lip = FUNC_FADEDN;
		// Make sure no negative delay
		if (self.delay <= 0) self.delay = 0;
		// Only fade this once
		self.wait = 0;
		
		// Make sure alphastart is within range
		if (self.alphastart < FUNC_FADEZERO) self.alphastart = FUNC_FADEZERO;
		if (self.alphastart > FUNC_FADEFULL) self.alphastart = FUNC_FADEFULL;
		// Setup alpha starting position, engine treats 0 as 1
		self.alpha = self.alphastart;
		
		// How much is left of the alpha range to fade?
		if (self.lip == FUNC_FADEUP) self.alphadiff = 1 - self.alphastart;
		else self.alphadiff = self.alphastart;
		
		// Technically this should test for 0 fade difference, however
		// < 0.1 is stupid amount to fade and pointless to setup!
		if (self.alphadiff < 0.1) {
			dprint("\b[BMODEL_FADE]\b Fade diff (<0.1) too small!\n");
			self.alphastart = 0;
			return FALSE;
		}
		// Alpha fade ready
		else return TRUE;
	}
	// Carry on as before
	else return FALSE;
};

//======================================================================
/*QUAKED func_wall (0 .5 .8) ? x AFRAME x x MODCHECK STATIC STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
A SOLID bmodel with toggled animated texture
-------- KEYS --------
targetname  : trigger entity (works with entity state system)
alphastart  : Alpha Fade bmodel (range 0.01-1.00) = Starting value
waitmin     : Alpha Fade Time (def=1s) of bmodel (even if partial)
lip         : Alpha Fade Direction -1=Down(1->0), 1=Up(0->1), Def=UP
delay       : Alpha Fade delay to start of fading (def=0)
_dirt       : -1 = will be excluded from dirtmapping
_minlight   : Minimum light level for any surface of the brush model
_mincolor   : Minimum light color for any surface (def='1 1 1' RGB)
_shadow     : Will cast shadows on other models and itself
_shadowself : Will cast shadows on itself
-------- SPAWNFLAGS --------
AFRAME   : Start with the A frame animated texture
MODCHECK : Will remove this entity if THIS mod is active
STATIC : Turn entity into static upon spawn (frame 0)
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
A SOLID bmodel with toggled animated texture

======================================================================*/
void() func_wall_use = 
{
	// Deal with STARTOFF functionality first
	if (self.spawnflags & ENT_STARTOFF) self.estate_on();
	else {
		// Block USE functionality if state wrong
		if (self.estate & ESTATE_BLOCK) return;
		// toggle alternate textures
		self.frame = 1 - self.frame;
	}
};

//----------------------------------------------------------------------
void() func_wall_on = 
{
	// No longer need this spawnflag, remove it
	self.spawnflags = self.spawnflags - (self.spawnflags & ENT_STARTOFF);

	// Check for spawning conditions (nightmare, coop)
	// Needs to exist after entity has been added to work for BSPorigin
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	self.estate = ESTATE_ON;

	// Start func_wall like func_illusionary
	if (self.alphastart > 0 && self.alphastart < 1) {
		self.movetype = MOVETYPE_NONE;
		self.solid = SOLID_NOT;
	}
	else {
		// Standard solid bmodel setup
		self.movetype = MOVETYPE_PUSH;
		self.solid = SOLID_BSP;
	}
	// Make model is linked properly
	setmodel (self, self.mdl);
	
	switch_shadow_on();
};

//----------------------------------------------------------------------
void() func_wall_off = 
{
	self.estate = ESTATE_OFF;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, "");

	switch_shadow_off();
};

//----------------------------------------------------------------------
void() func_wall_aframe = { };

//----------------------------------------------------------------------
void() func_wall =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_FUNCWALL;
	self.bsporigin = TRUE;
	self.angles = '0 0 0';
	self.mdl = self.model;
	if (self.spawnflags & FUNC_AFRAME) self.frame = 1;
	if (self.spawnflags & FUNC_MODCHECK) { remove(self); return; }
	
	// Check for static entity option first
	if (self.spawnflags & ENT_SPNSTATIC) {
		self.movetype = MOVETYPE_PUSH;
		self.solid = SOLID_BSP;
		setmodel (self, self.mdl);
		makestatic(self);
	}
	else {
		// Setup Entity State functionality
		if (self.targetname != "") self.use = entity_state_use;
		self.estate_on = func_wall_on;
		self.estate_off = func_wall_off;
		if (func_bmodelfade_setup()) self.estate_use = func_bmodelfade_use;
		else self.estate_use = func_wall_use;
		self.estate_aframe = func_wall_aframe;
		if (self.spawnflags & ENT_STARTOFF) self.estate_off();
		else self.estate_on();
	}
};

//======================================================================
/*QUAKED func_illusionary (0 .5 .8) ? x AFRAME x x x STATIC STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
A NON SOLID bmodel with texture toggle
-------- KEYS --------
targetname  : trigger entity (works with entity state system)
targetname  : trigger entity (works with entity state system)
alphastart  : Alpha Fade bmodel (range 0.01-1.00) = Starting value
waitmin     : Alpha Fade Time (def=1s) of bmodel (even if partial)
lip         : Alpha Fade Direction -1=Down(1->0), 1=Up(0->1), Def=UP
delay       : Alpha Fade delay to start of fading (def=0)
_dirt       : -1 = will be excluded from dirtmapping
_minlight   : Minimum light level for any surface of the brush model
_mincolor   : Minimum light color for any surface (def='1 1 1' RGB)
_shadow     : Will cast shadows on other models and itself
_shadowself : Will cast shadows on itself
-------- SPAWNFLAGS --------
AFRAME : Start with the A frame animated texture
STATIC : Turn entity into static upon spawn (frame 0)
STARTOFF : Requires trigger to activate
-------- NOTES --------
A NON SOLID bmodel with texture toggle

======================================================================*/
void() func_illusionary_on = 
{
	// No longer need this spawnflag, remove it
	self.spawnflags = self.spawnflags - (self.spawnflags & ENT_STARTOFF);

	// Check for spawning conditions (nightmare, coop)
	// Needs to exist after entity has been added to work for BSPorigin
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;
	
	self.estate = ESTATE_ON;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, self.mdl);

	switch_shadow_on();
};

//----------------------------------------------------------------------
void() func_illusionary_aframe = { };

//----------------------------------------------------------------------
void() func_illusionary =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_FUNCILLUSIONARY;
	self.bsporigin = TRUE;
	self.angles = '0 0 0';
	self.mdl = self.model;
	if (self.spawnflags & FUNC_AFRAME) self.frame = 1;

	// Check for static entity option first
	if (self.spawnflags & ENT_SPNSTATIC) {
		self.movetype = MOVETYPE_NONE;
		self.solid = SOLID_NOT;
		setmodel (self, self.mdl);
		makestatic(self);
	}
	else {
		// Setup Entity State functionality
		if (self.targetname != "") self.use = entity_state_use;
		self.estate_on = func_illusionary_on;
		self.estate_off = func_wall_off;
		self.estate_aframe = func_illusionary_aframe;

		if (func_bmodelfade_setup()) self.estate_use = func_bmodelfade_use;
		else self.estate_use = func_wall_use;

		if (self.spawnflags & ENT_STARTOFF) self.estate_off();
		else self.estate_on();
	}
};

//======================================================================
/*QUAKED func_togglewall (0 .5 .8) ? STARTOFF x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
A func_wall that can be toggled on and off
Originally from hip_part.qc by Hipnotic (Quake expansion pack 1)
-------- KEYS --------
targetname  : trigger entity (works with entity state system)
noise       : Switched OFF sound (def=misc/laseroff.wav)
noise1      : Switched ON sound (def=misc/laseron.wav)
noise2      : Touch damage sound (weapons/laser_hit.wav)
wait        : wait between damage (def=0.5)
dmg         : Contact damage (def=0)
_dirt       : -1 = will be excluded from dirtmapping
_minlight   : Minimum light level for any surface of the brush model
_mincolor   : Minimum light color for any surface (def='1 1 1' RGB)
_shadow     : Will cast shadows on other models and itself
_shadowself : Will cast shadows on itself
-------- SPAWNFLAGS --------
STARTOFF  : Starts off and waits for trigger
-------- NOTES --------
A func_wall that can be toggled on and off

======================================================================*/
void() func_togglewall_touch =
{
	// Block USE functionality if state wrong
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;
	if (other.takedamage == DAMAGE_NO) return;

	self.attack_finished = (time + self.wait);
	sound(other, CHAN_ITEM, self.noise2, self.volume, ATTN_NORM);
	if (self.dmg > 0) T_Damage(other, self, self, self.dmg, DAMARMOR);
};

//----------------------------------------------------------------------
void() func_togglewall_use = 
{
	// Block DISABLE functionality if state wrong
	if (self.estate & ESTATE_DISABLE) return;
	// Toggle the model/sound
	if (self.estate == ESTATE_ON) self.estate_off();
	else self.estate_on();
};

//----------------------------------------------------------------------
void() func_togglewall_on = 
{
	// No longer need this spawnflag, remove it
	self.spawnflags = self.spawnflags - (self.spawnflags & ENT_STARTOFF);

	self.estate = ESTATE_ON;
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.mdl);
	// Make bmodel surface invisible
	self.model = string_null;
	sound(self, CHAN_VOICE, self.noise1, self.volume, ATTN_NORM);
};

//----------------------------------------------------------------------
void() func_togglewall_off = 
{
	self.estate = ESTATE_OFF;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, "");
	sound(self, CHAN_VOICE, self.noise, self.volume, ATTN_NORM);
};

//----------------------------------------------------------------------
void() func_togglewall =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	if (self.noise == "") self.noise = "misc/laseroff.wav";
	if (self.noise1 == "") self.noise1 = "misc/laseron.wav";
	if (self.noise2 == "") self.noise2 = "weapons/laser_hit.wav";
	precache_sound(self.noise);
	precache_sound(self.noise1);
	precache_sound(self.noise2);
	trigger_bmodel_volume(1);
	
	self.classtype = CT_FUNCTOGWALL;
	self.bsporigin = TRUE;
	self.angles = '0 0 0';
	self.mdl = self.model;

	// Various Defaults
	if (self.wait <= 0) self.wait = 0.5;
	if (self.dmg <= 0) self.dmg = 0;
	if (!self.alpha) self.alpha = 0.5;	// Wall always transparent
	self.height = self.alpha;			// Used for think function

	// Add bmodel to world
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.mdl);

	// Shift the 'start off' to the correct spawnflag
	if (self.spawnflags & FUNC_TWALLOFF) 
		self.spawnflags = self.spawnflags | ENT_STARTOFF;

	// Check for spawning conditions (nightmare, coop)
	// Needs to exist after entity has been added to work for BSPorigin
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	// Touchy feely time!
	self.touch = func_togglewall_touch;
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_on = func_togglewall_on;
	self.estate_off = func_togglewall_off;
	self.estate_use = func_togglewall_use;
	if (self.spawnflags & ENT_STARTOFF) self.estate_off();
	else self.estate_on();
};

//======================================================================
/*QUAKED func_episodegate (0 .5 .8) ? E1 E2 E3 E4 x x x x Not_Easy Not_Normal Not_Hard Not_DM
SOLID bmodel when player has SELECTED rune(s)
-------- KEYS --------
targetname : trigger entity (works with entity state system)
_dirt       : -1 = will be excluded from dirtmapping
_minlight   : Minimum light level for any surface of the brush model
_mincolor   : Minimum light color for any surface (def='1 1 1' RGB)
_shadow     : Will cast shadows on other models and itself
_shadowself : Will cast shadows on itself
-------- SPAWNFLAGS --------
E1 : Episode 1
E2 : Episode 2
E3 : Episode 3
E4 : Episode 4
-------- NOTES --------
SOLID bmodel when player has SELECTED rune(s)

======================================================================*/
void() func_episodegate_touch =
{
	// Block USE functionality if state wrong
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;
	if (!(other.flags & FL_CLIENT)) return;

	// Got a message to display with bmodel on?
	if (self.message != "") {
		centerprint(other, self.message);
		// Uses default talktalk sound
		sound (other, CHAN_AUTO, self.noise, 1, ATTN_NORM);
		// Slowdown touch functionality
		self.attack_finished = time + 2;
	}
};

//----------------------------------------------------------------------
void() func_episodegate_use =
{
	// The RUNE condition has to be active 
	if (query_configflag(self.customkey) == self.customkey) {
		self.estate_on();
		// Can be touched for message/sound
		self.touch = func_episodegate_touch;
	}
	// No longer required
	else self.estate_off();
};

//----------------------------------------------------------------------
void() func_episodegate_aframe = { };

//----------------------------------------------------------------------
void() func_episodegate =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_FUNCEPISODEGATE;
	self.bsporigin = TRUE;
	self.angles = '0 0 0';
	self.mdl = self.model;

	// Touch sound when bmodel is ON
	if (self.noise == "") self.noise = SOUND_TALK;
	precache_sound(self.noise);
	
	// Check for spawning conditions (nightmare, coop)
	// Needs to exist after entity has been added to work for BSPorigin
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	// Remove any extra spawnkey stuff like skill restrictions
	self.customkey = self.spawnflags & SVR_RUNE_ALL;
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_on = func_wall_on;
	self.estate_off = func_wall_off;
	self.estate_use = func_episodegate_use;
	self.estate_aframe = func_episodegate_aframe;
	if (self.spawnflags & ENT_STARTOFF) self.estate_off();
	else {
		// Wait 1 frame before checking for rune keys
		self.think = func_episodegate_use;
		self.nextthink = time + 0.1;
	}
};

//======================================================================
/*QUAKED func_bossgate (0 .5 .8) ? x x x x x x x x Not_Easy Not_Normal Not_Hard Not_DM
A NON SOLID bmodel when player has ALL runes
-------- KEYS --------
targetname : trigger entity (works with entity state system)
_dirt       : -1 = will be excluded from dirtmapping
_minlight   : Minimum light level for any surface of the brush model
_mincolor   : Minimum light color for any surface (def='1 1 1' RGB)
_shadow     : Will cast shadows on other models and itself
_shadowself : Will cast shadows on itself
-------- SPAWNFLAGS --------
-------- NOTES --------
A NON SOLID bmodel when player has ALL runes

======================================================================*/
void() func_bossgate_use =
{
	// The RUNE condition has to be active 
	if (query_configflag(SVR_RUNE_ALL) == SVR_RUNE_ALL) self.estate_off();
	else self.estate_on();
};

//----------------------------------------------------------------------
void() func_bossgate_aframe = { };

//----------------------------------------------------------------------
void() func_bossgate =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_FUNCBOSSGATE;
	self.bsporigin = TRUE;
	self.angles = '0 0 0';
	self.mdl = self.model;

	// Check for spawning conditions (nightmare, coop)
	// Needs to exist after entity has been added to work for BSPorigin
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_on = func_wall_on;
	self.estate_off = func_wall_off;
	self.estate_use = func_bossgate_use;
	self.estate_aframe = func_bossgate_aframe;
	if (self.spawnflags & ENT_STARTOFF) self.estate_off();
	else {
		// Wait 1 frame before checking for rune keys
		self.think = func_bossgate_use;
		self.nextthink = time + 0.1;
	}
};

/*======================================================================
 BModel laser (originally from Rubicon2 codebase by JohnFitz)
 - Extended code to have different states and toggle function
 - Added custom/silent sounds for lasers on/off
 - Added on/off message once function
 - Added collision and nodmg spawnflags */

//======================================================================
/*QUAKED func_laser (0 .5 .8) ? x SOLID NODMG x x x STARTOFF x
A togglable laser, hurts to touch, can be used to block players
-------- KEYS --------
targetname  : trigger entity (works with entity state system)
message     : message to display when switched ON
message2    : message to display when switched OFF
wait        : -1 = will display the switching state messages only once
dmg         : damage to do on touch. default 1 per 0.1s
alpha       : alpha value will vary +/- 20% (def=0.5)
sounds      : 1=laser, 2=power, 4=silent, 5=custom
noise1      : Custom trigger sound to play when switched ON
noise2      : Custom trigger sound to play when switched OFF
volume      : Volume for all custom sounds played (def=1, range=0-1)
spr_frame   : 1=Yellow, 2=Green, 4=Red, 8=Blue, 16=Purple, 32=Fire, 64=White
angle       : Direction of particles to move (def=-2 down)
part_limit  : Maximum active quantity of particles (def=25)
part_life   : Lifetime of particle (def=2s)
part_velrand: Random movement of particles (def='4 4 4')
part_vol    : Size of area to spawn particles in (def=bmodel)
wakeup_dist : Distance to wakeup particle emitter (def=768)
spawn_base  : Minimum time frame to spawn particles (def=0.1s)
spawn_rand  : Random time amount to add to spawning times (def=0.1s)
_dirt       : -1 = will be excluded from dirtmapping
_minlight   : Minimum light level for any surface of the brush model
_mincolor   : Minimum light color for any surface (def='1 1 1' RGB)
_shadow     : Will cast shadows on other models and itself
_shadowself : Will cast shadows on itself
-------- SPAWNFLAGS --------
SOLID    : Will block anything
NODMG    : Touch damage disabled
STARTOFF : Requires trigger to activate
-------- NOTES --------
A togglable laser, hurts to touch, can be used to block players

======================================================================*/
void() func_laser_touch =
{
	if (self.estate & ESTATE_BLOCK) return;
	if (self.spawnflags & FUNC_LASERNODMG) return;
	if (other.takedamage == DAMAGE_NO) return;
	if (self.attack_finished < time) {
		T_Damage (other, self, self, self.dmg, DAMARMOR);
		self.attack_finished = time + 0.1;
	}
};

//----------------------------------------------------------------------
void() func_laser_think =
{
	if (self.estate == ESTATE_BLOCK) return;
	// Change the density of the alpha to make laser beam flicker
	self.alpha = self.height*0.8 + (self.alpha * (random()*0.4));
	// Solid type SOLID_BSP has to use local timer (ltime)
	if (self.spawnflags & FUNC_LASERSOLID) self.nextthink = self.ltime + 0.05;
	else self.nextthink = time + 0.05;
};

//----------------------------------------------------------------------
void() func_laser_on =
{
	// No longer need this spawnflag, remove it
	self.spawnflags = self.spawnflags - (self.spawnflags & ENT_STARTOFF);

	// Switch laser to active
	self.estate = ESTATE_ON;

	// Only play the ON sound and display message when not spawning
	if (self.waitmin == TRUE) {
		// Play sound on extra emitter if sounds been defined
		if (self.sound_emitter && self.noise1 != "")
			sound (self.sound_emitter, CHAN_VOICE, self.noise1, self.volume, ATTN_NORM);
		if (activator.flags & FL_CLIENT && self.message != "")
			centerprint(activator,self.message);
		if (self.wait == TRUE) self.message = "";
	}
	else self.waitmin = TRUE;
	
	// Got to set solid/movetype before model
	// Otherwise trigger state does not register properly
	if (self.spawnflags & FUNC_LASERSOLID) {
		self.solid = SOLID_BSP;
		self.movetype = MOVETYPE_PUSH;
		self.ltime = time;
	}
	else {
		self.solid = SOLID_TRIGGER;
		self.movetype = MOVETYPE_NONE;
	}

	// Add bmodel back to world (visually)
	setmodel (self, self.mdl);

	// Check for spawning conditions (nightmare, coop)
	// Needs to exist after entity has been added to work for BSPorigin
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	// Switch ON any particle emitter
	if (self.part_emitter) misc_particle_on(self.part_emitter);
	
	// Reset touch and laser blink effect
	self.touch = func_laser_touch;
	self.think = func_laser_think;
	self.nextthink = time + 0.1;
};

//----------------------------------------------------------------------
void() func_laser_off =
{
	// Switch laser to active
	self.estate = ESTATE_OFF;

	// Only play the OFF sound and display message when not spawning
	if (self.waitmin == TRUE) {
		// Play sound on extra emitter if sounds been defined
		if (self.sound_emitter && self.noise2 != "")
			sound (self.sound_emitter, CHAN_VOICE, self.noise2, self.volume, ATTN_NORM);
		if (activator.flags & FL_CLIENT && self.message2 != "")
			centerprint(activator,self.message2);
		if (self.wait == TRUE) self.message2 = "";
	}
	else self.waitmin = TRUE;

	// Switch OFF any particle emitter
	if (self.part_emitter) misc_particle_off(self.part_emitter);
	
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel(self, "");
};

//----------------------------------------------------------------------
void() func_laser =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_FUNCLASER;		// Classtype
	self.mdl = self.model;				// Save for later (on function)
	if (self.spr_frame > 0 && CheckZeroVector(self.angles)) 
		self.angles = '0 -2 0';
	InitTrigger();						// Add to work and initialize

	if (!self.alpha) self.alpha = 0.5;	// Lasers always transparent
	self.height = self.alpha;			// Used for think function
	if (!self.dmg) self.dmg = 1;		// Default tickle
	if (self.wait < 0) self.wait = TRUE;// Display message once?
	else self.wait = FALSE;
	self.waitmin = FALSE;				// Spawning no message check
	trigger_bmodel_volume(1);

	// Pre-cache sounds and setup sound emitter
	if (self.sounds > 0 && self.sounds < 3) {
		if (self.sounds == 1) {
			self.noise1 = "misc/laseron.wav";
			self.noise2 = "misc/laseroff.wav";
		}
		else if (self.sounds == 2) {
			self.noise1 = "ambience/power_on.wav";
			self.noise2 = "ambience/power_off.wav";
		}
		precache_sound(self.noise1);
		precache_sound(self.noise2);

		// Setup sound emitter where bmodel is correctly located
		self.sound_emitter = spawn();
		self.sound_emitter.origin = bmodel_origin(self);
		setorigin(self.sound_emitter, self.sound_emitter.origin);
		self.sound_emitter.classtype = CT_SOUNDEMITTER;	
	}
	
	// Check for particles emitter type
	if (self.spr_frame > 0) {
		self.part_active = PARTICLE_STYLE_FFIELD;
		// Volume/direction need to be set early, just in case
		// the entity starts off and then it has no volume!
		self.part_vol = self.size * 0.5;
		self.part_vel = self.movedir * 4;
		if (self.spawnflags & ENT_STARTOFF) self.lip = PARTICLE_START_OFF;
		else self.lip = PARTICLE_START_ON;
		self.part_emitter = spawn_pemitter(self, self, self.part_active, self.lip);
	}
		
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_on = func_laser_on;
	self.estate_off = func_laser_off;
	
	if (self.spawnflags & ENT_STARTOFF) entity_state_off();
	else entity_state_on();
};

//======================================================================
/*QUAKED func_skill (0 .5 .8) ? STARTOPEN CHAOS x x STARTDIS STARTOFF x
A bmodel that changes texture based on current skill/chaos level
Will keep checking until triggered (based on door QC code)
-------- KEYS --------
targetname  : trigger entity (works with entity state system)
style       : Skill Level - 0 = easy, 1 = normal, 2 = hard, 3 = nightmare
message2    : Override message to display when bmodel is touched/damaged
target      : Particle emitters to switch on/off
target2     : target(s) to fire when touched/damaged
wait        : =-1 cannot be touched or damaged (visual only)
health      : Can be damaged instead of touched (def=touch)
angle       : movement direction for trigger event
speed       : movement speed (100 default)
lip         : lip remaining at end of move (def=8)
waitmin     : Chaos mode touch slowdown timer (def=1s)
noise1      : Custom sound - Stop moving (doors/drclos4.wav)
noise2      : Custom sound - Start/Loop moving (doors/stndr1.wav)
noise3      : Custom sound - Touching (plats/medplat2.wav)
volume      : Volume for all custom sounds played (def=1, range=0-1)
_dirt       : -1 = will be excluded from dirtmapping
_minlight   : Minimum light level for any surface of the brush model
_mincolor   : Minimum light color for any surface (def='1 1 1' RGB)
_shadow     : Will cast shadows on other models and itself
_shadowself : Will cast shadows on itself
-------- SPAWNFLAGS --------
STARTOPEN : bmodel works in reverse state (moved to dest at spawn)
CHAOSMODE : special setup for the random chaos mode (waitmin=touch delay)
STARTDIS  : Starts disabled and waits for trigger
STARTOFF  : Starts off and waits for trigger
-------- NOTES --------
Visual skill/chaos selection/update function

======================================================================*/
void() func_pillar_particles = 
{
	// Any particle emitter targetnames?
	if (self.target != "") {
		// Find first one in world
		self.enemy = find(world,targetname,self.target);
		while (self.enemy) {
			// Found a particle emitter?
			if (self.enemy.classtype == CT_PARTICLEEMIT) {
				// pillar status?  0= +0 (on) 1= +A (off)
				if (self.frame == 0) misc_particle_on(self.enemy);
				else misc_particle_off(self.enemy);
			}
			// Keep searching for more targets in chain
			self.enemy = find(self.enemy,targetname,self.target);
		}
	}
};

//----------------------------------------------------------------------
void() func_chaos_check = 
{
	// If blocked by entity state system do nothing
	if (self.estate & ESTATE_BLOCK) return;
	if (!(self.spawnflags & FUNC_SKILLCHAOSMODE)) return;

	// Read console variable
	self.randomized = read_randflags();
	// Has the console variable been changed?
	if (self.lefty != self.randomized) {
		// Update current flag (lefty)
		self.lefty = self.randomized;
		// Is Chaos mode active?
		if (self.style == self.randomized) self.frame = 0;	// +0 frame (on)
		else self.frame = 1;					// A frame (off)

		// Update all particle emitters
		func_pillar_particles();
	}
	// Keep thinking/checking
	self.nextthink = time + 0.1;
	self.think = func_chaos_check;
};

//----------------------------------------------------------------------
void() func_chaos_touch =
{
	// If blocked by entity state system do nothing
	if (self.estate & ESTATE_BLOCK) return;
	if (self.spawnflags & ENT_STARTOFF) return;
	if ( !(other.flags & FL_CLIENT) ) return;
	if ( other.health < 1 ) return;
	// Chaos mode only
	if (!(self.spawnflags & FUNC_SKILLCHAOSMODE)) return;
	// Slowdown touch functionality
	if (self.pausetime > time) return;

	// Slowdown touch functionality
	self.pausetime = time + self.waitmin;

	// Read chaos mode flag (scratch3)
	self.randomized = read_randflags();
	// Switch chaos mode on/off
	if (self.randomized == self.style) {
		disable_randflags();
	}
	else {
		set_randflags(self.style);
		if (self.message2 != "") centerprint(other, self.message2);
		else centerprint(other,"Chaos mode has been enabled!\n");
		stuffcmd (other, "bf\n");
	}
	
	// Force quick update
	func_chaos_check();
	
	// Any other targets to fire when touch/damaged
	if (self.target2 != "") trigger_strs(self.target2, other);
	// Play touch sound regardless of chaos change
	sound (self, CHAN_VOICE, self.noise3, self.volume, ATTN_NORM);
};

//----------------------------------------------------------------------
void() func_skill_check =
{
	// If blocked by entity state system do nothing
	if (self.estate & ESTATE_BLOCK) return;
	if (self.spawnflags & FUNC_SKILLCHAOSMODE) return;

	// Has the skill level been changed?
	if (self.lefty != skill) {
		// Stop this entity constantly changing
		self.lefty = skill;
		// Is the current skill level active?
		if (self.style == skill) self.frame = 0;	// +0 frame (on)
		else self.frame = 1;						// A frame (off)									// Blank texture (off)
		// Update any particle emitters
		func_pillar_particles();
	}
	// Keep thinking/checking
	self.nextthink = time + 0.1;
	self.think = func_skill_check;
};

//----------------------------------------------------------------------
void() func_skill_touch =
{
	// If blocked by entity state system do nothing
	if (self.estate & ESTATE_BLOCK) return;
	if (self.spawnflags & ENT_STARTOFF) return;
	if ( !(other.flags & FL_CLIENT) ) return;
	if ( other.health < 1 ) return;
	if (self.spawnflags & FUNC_SKILLCHAOSMODE) return;

	// If skill level is changing, say so on console
	if (skill != self.style) {
		if (self.message2 != "") sprint(other, self.message2);
		else {
			sprint(other,"Skill level ");
			if (self.style == SKILL_EASY) sprint(other,"EASY");
			else if (self.style == SKILL_NORMAL) sprint(other,"NORMAL");
			else if (self.style == SKILL_HARD) sprint(other,"HARD");
			else if (self.style == SKILL_NIGHTMARE) sprint(other,"NIGHTMARE");
			else sprint(other,"EVIL");
			sprint(other," has been selected!");
		}
		sprint(other,"\n");
		stuffcmd (other, "bf\n");
		
		// Change skill level
		cvar_set ("skill", ftos(self.style));
		skill = self.style;
		// Make sure skill sets extra variable
		if (skill == SKILL_EVIL) cvar_set("scratch4", "1");
		else cvar_set("scratch4", "0");
		
		// Force quick update
		func_skill_check();
		
		// Any other targets to fire when touch/damaged
		if (self.target2 != "") trigger_strs(self.target2, other);
	}		
	
	// Play touch sound regardless of skill change
	if (self.pausetime < time) {
		sound (self, CHAN_VOICE, self.noise3, self.volume, ATTN_NORM);
		self.pausetime = time + 1;	// No constant sound
	}	
};

//----------------------------------------------------------------------
void() func_skill_killed =
{
	other = damage_attacker;		// The attacker
	self.health = self.max_health;	// Reset health to original value
	// All other exceptions are in the touch function
	self.touch2();
};

//----------------------------------------------------------------------
void() func_skill_on =
{
	// Remove any start off / disable spawnflags
	self.spawnflags = self.spawnflags - (self.spawnflags & ENT_STARTOFF);
	self.spawnflags = self.spawnflags - (self.spawnflags & FUNC_SKILLSTARTDIS);
	
	self.estate = ESTATE_ON;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setmodel (self, self.mdl);
	// Check/Update state
	self.th_wakeup();
};

//----------------------------------------------------------------------
void() func_skill_finishmove =
{
	// Stop sound, ON and particles!
	sound (self, CHAN_VOICE, self.noise1, self.volume, ATTN_NORM);
	// Need to reset local entity time, otherwise timer is broken
	// it because of the SUB_CalcMove function changes it
	self.ltime = time;
	self.estate_on();
};

//----------------------------------------------------------------------
void() func_skill_startmove =
{
	// Trigger once functionality
	self.estate_use = SUB_Null;
	// Remove any start off / disable spawnflags
	self.spawnflags = self.spawnflags - (self.spawnflags & ENT_STARTOFF);
	self.spawnflags = self.spawnflags - (self.spawnflags & FUNC_SKILLSTARTDIS);
	// Play movement sound and move pillar into place
	sound (self, CHAN_VOICE, self.noise2, self.volume, ATTN_NORM);
	SUB_CalcMove (self.pos2, self.speed, func_skill_finishmove);
};

//----------------------------------------------------------------------
void() func_skill_disable =
{
	self.estate = ESTATE_DISABLE;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setmodel (self, self.mdl);
	// Off texture (+A)
	self.frame = 1;
	// Frame used to determine particle state
	func_pillar_particles();
};

//----------------------------------------------------------------------
void() func_skill_off =
{
	self.estate = ESTATE_OFF;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, "");
	// Off texture (+A)
	self.frame = 1;
	// Frame used to determine particle state
	func_pillar_particles();
};

//----------------------------------------------------------------------
void() func_skill =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	// Setup default sounds if no custom sounds exist
	if (self.noise1 == "") self.noise1 = "doors/drclos4.wav";
	if (self.noise2 == "") self.noise2 = "doors/stndr1.wav";
	if (self.noise3 == "") self.noise3 = "plats/medplat2.wav";

	//Pre-cache all sounds
	precache_sound(self.noise1);	// stop sound (big clunk sound)
	precache_sound(self.noise2);	// moving sound (door moving)
	precache_sound(self.noise3);	// Touch sound
	trigger_bmodel_volume(1);
	
	self.bsporigin = TRUE;			// Bmodel (0,0,0 origin)
	self.mdl = self.model;
	SetMovedir ();
	
	if (self.speed <= 0) self.speed = 100;	// Default movement speed
	if (self.lip <= 0) self.lip = 8;		// End movement distance
	if (self.waitmin <= 0) self.waitmin = 1;// Touch timeout for chaos

	//----------------------------------------------------------------------
	// New random chaos mode
	if (self.spawnflags & FUNC_SKILLCHAOSMODE) {
		self.classtype = CT_FUNCCHAOS;
		self.touch2 = func_chaos_touch;
		self.th_wakeup = func_chaos_check;
		// Reset default/override for chaos system
		if (self.style <= 0) self.style = 0;
		// Read randomizer (scratch3) flag
		self.lefty = check_randflags();
		if (self.lefty == FALSE) self.frame = 1;	// +A (off)
		else self.frame = 0;						// +0 (on)
	}
	else {
		self.classtype = CT_FUNCSKILL;	// Type
		self.touch2 = func_skill_touch;
		self.th_wakeup = func_skill_check;
		// Check for negative skill values? skill 4+ = Evil Mode
		if (self.style < SKILL_EASY) self.style = SKILL_EASY;
		self.lefty = cvar("skill");			// Read current setting
		if (self.style != self.lefty) self.frame = 1;	// +A (off)
		else self.frame = 0;							// +0 (on)
	}
	// Always check first time
	self.lefty = -1;
	
	//----------------------------------------------------------------------
	// Add bmodel to world and work out movement positions
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setmodel (self, self.mdl);
	setorigin (self, self.origin);	
	setsize (self, self.mins , self.maxs);
	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);
	
	// Check for spawning conditions (coop, no NM check)
	// Needs to exist after entity has been added to work for BSPorigin
	if (check_coop() == TRUE) return;

	//----------------------------------------------------------------------
	// FUNC_SKILL_START_OPEN is design is hide a skill pillar
	// until it is triggered (nightmare skill)
	if (self.spawnflags & FUNC_SKILLSTARTOPEN) {
		setorigin (self, self.pos2);
		self.pos2 = self.pos1;
		self.pos1 = self.origin;
		// Start open always starts disabled
		self.spawnflags = self.spawnflags | FUNC_SKILLSTARTDIS;
		// Wait for trigger to start moving into place
		self.use = func_skill_startmove;
	}
	// Default trigger/use (Turn on)
	else self.use = func_skill_on;
		
	// Setup Entity State functionality
	self.estate_on = func_skill_on;
	self.estate_off = func_skill_off;
	self.estate_disable = func_skill_disable;

	// Check for notouch+damage, damage only or touch only
	// The visual only version has to be checked first
	if (self.wait < 0) {
		self.health = self.max_health = 0;
		self.th_die = SUB_Null;
		self.takedamage = DAMAGE_NO;
		self.touch = SUB_Null;
	}
	else if (self.health != 0) {
		self.health = self.max_health = 1;
		self.th_die = func_skill_killed;
		self.takedamage = DAMAGE_YES;
		self.touch = SUB_Null;
	}
	else {
		self.health = self.max_health = 0;
		self.th_die = SUB_Null;
		self.takedamage = DAMAGE_NO;
		self.touch = self.touch2;
	}

	// Wait for particle emitter entities to spawn
	self.nextthink = time + 0.1 + random()*0.2;
	if (self.spawnflags & FUNC_SKILLSTARTDIS) self.think = self.estate_disable;
	else if (self.spawnflags & ENT_STARTOFF) self.think = self.estate_off;
	else self.think = self.estate_on;
};

//======================================================================
/*QUAKED func_bob (0 .5 .8) ? x x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
A SOLID bmodel that gently moves back and forth
-------- KEYS --------
targetname : trigger entity (works with entity state system)
angle    : direction movement, use "360" for angle 0
height   : direction intensity (def=4)
count    : direction cycle timer (def=2s, minimum=1s)
waitmin  : Speed up scale (def=1) 1+=non linear
waitmin2 : Slow down scale (def=0.75)
delay    : Starting time delay (def=0, -1=random)
_dirt       : -1 = will be excluded from dirtmapping
_minlight   : Minimum light level for any surface of the brush model
_mincolor   : Minimum light color for any surface (def='1 1 1' RGB)
_shadow     : Will cast shadows on other models and itself
_shadowself : Will cast shadows on itself
-------- SPAWNFLAGS --------
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
A SOLID bmodel that gently moves back and forth

======================================================================*/
void() func_bob_use =
{
	// Deal with STARTOFF functionality first
	if (self.spawnflags & ENT_STARTOFF) self.estate_on();
	else {
		// Toggle state (switch on or disable)
		if (self.estate & ESTATE_BLOCK) self.estate = ESTATE_ON;
		else self.estate = ESTATE_DISABLE;
	}
};

//----------------------------------------------------------------------
void() func_bob_timer =
{
	// Keep ticking in background, use local timer (faster)
	self.think = func_bob_timer;
	if (self.bsporigin) self.nextthink = self.ltime + 0.1;
	else self.nextthink = time + 0.1;
	
	// Do nothing if entity state is off
	if (self.estate & ESTATE_OFF) return;

	// Has the cycle completed?
	if (self.attack_timer < time) {
		// Don't reset bmodel if disabled
		if (self.estate & ESTATE_DISABLE) {
			self.attack_timer = LARGE_TIMER;
			self.lefty = -1;
		}
		else {
			// Setup bob cycle and half way point for slowdown
			self.attack_timer = time + self.count;
			self.distance = time + (self.count * 0.5);
			// Flip direction of bmodel bob
			self.lefty = 1 - self.lefty;
			if (self.lefty < 1) self.t_length = self.height;
			else self.t_length = -self.height;
		}
		// Always reset velocity and flags
		self.velocity = '0 0 0';
		self.flags = 0;
	}
	
	// Is the direction set?
	// This is a block condition to prevent the bmodel moving
	if (self.lefty != -1) {
		// Slow down velocity (gradually)
		if (self.distance < time) 
			self.velocity = self.velocity * self.waitmin2;
		else {
			// Speed up velocity (linear/exponentially)
			self.t_length = self.t_length * self.waitmin;
			self.velocity = self.velocity + (self.movedir * self.t_length);
		}
	}
};

//----------------------------------------------------------------------
void() func_bob_on = 
{
	// No longer need this spawnflag, remove it
	self.spawnflags = self.spawnflags - (self.spawnflags & ENT_STARTOFF);

	self.estate = ESTATE_ON;
	if (self.bsporigin) {
		// Check for solid spawnflag
		if (self.spawnflags & BOB_NONSOLID) {
			self.movetype = MOVETYPE_PUSH;
			//self.movetype = MOVETYPE_NOCLIP;
			self.solid = SOLID_NOT;
		}
		else {
			self.movetype = MOVETYPE_PUSH;
			self.solid = SOLID_BSP;
		}
	}
	else {
		self.movetype = MOVETYPE_FLY;
		if (self.spawnflags & BOB_COLLISION) self.solid = SOLID_BBOX;
		else self.solid = SOLID_NOT;
		self.flags = 0;	// Reset any onground flags
	}
	setmodel (self, self.mdl);
	setsize (self, self.mins , self.maxs);

	// Check for spawning conditions (nightmare, coop)
	// Needs to exist after entity has been added to work for BSPorigin
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;
};

//----------------------------------------------------------------------
void() func_bob_off = 
{
	self.estate = ESTATE_OFF;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, "");
	self.velocity = '0 0 0';
};

//----------------------------------------------------------------------
void() func_bob =
{
	self.classtype = CT_FUNCBOB;
	// Using a custom model?
	if (self.mdl == "") {
		self.bsporigin = TRUE;
		self.mdl = self.model;
	}
	else {
		self.bsporigin = FALSE;
		self.modelindex = 0;
		self.model = "";
	}
	
	SetMovedir ();
	self.movedir = normalize(self.movedir);
	
	if (self.height <=0) self.height = 8;	// Direction intensity
	if (self.count <1) self.count = 2;		// Direction switch timer
	if (self.waitmin <=0) self.waitmin = 1;			// Speed up
	if (self.waitmin2 <=0) self.waitmin2 = 0.75;	// Slow down
	if (self.delay < 0) self.delay = random() + random() + random();
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_on = func_bob_on;
	self.estate_off = func_bob_off;
	if (self.spawnflags & ENT_STARTOFF) self.estate_off();
	else self.estate_on();

	self.think = func_bob_timer;
	self.nextthink = time + 0.1 + self.delay;
};

//----------------------------------------------------------------------
void() misc_bob =
{
	if (self.mdl == "") self.mdl = MODEL_BROKEN;
	precache_model(self.mdl);
	
	func_bob();
};