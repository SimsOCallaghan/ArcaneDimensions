/*======================================================================
 LIGHT ENTITIES (used by compiler)
======================================================================*/
float LIGHT_STARTOFF = 1;
float LIGHT_NOSOUND = 2;
float LIGHT_QUOTHNOSTAT = 2;
float LIGHT_NOSTATIC = 4;
float LIGHT_FLAMEOFF = 2;
float LIGHT_CANDLESHADOW = 8;
float LIGHT_SWITCHFADE = 16;
float LIGHT_NOEFFECTS = 128;

.string	lighttarget;
// To help reduce signon buffer size, allow for light entities
// to be delay spawned (especially light models like candles)
// Cannot use target key because compiler uses it for light styles
.string customstyle_string;
// Only 32 switchable lights are allowed per map. The compiler
// re-uses the style key to keep track of the switchable lights
// which means they cannot have light style strings by default
.float customstyle_remap;
// Rather than defined a new light style string, this entity key
// allows for a light style to be a mirror/copy of another style
.float customstyle_update;
// Determines how the customstyle is updated with trigger function
// =0 always update, =1 no update, =2 only update if estate/light on

// Protected default light styles
float LIGHT_IDSTYLE = 12;
float LIGHT_COMPILERSTYLE = 32;
float LIGHT_MAXLIGHTSTYLE = 64;
// Possible extended BSP2 standard ... who knows!
float LIGHT_BSP2LIGHTSTYLE = 256;
// The array is setup from world.qc before anything loads
string light_style_str[LIGHT_MAXLIGHTSTYLE];

//----------------------------------------------------------------------
// Allow the compile to change the starting point for target lights
//----------------------------------------------------------------------
void() light_style_boundary =
{
	// Check worldspawn key for starting point of target lights
	if (world.compilerstyle_start == 0) mapstyle_start = LIGHT_COMPILERSTYLE;
	else mapstyle_start = world.compilerstyle_start;
	// Make sure it does not overwrite default (0-11) ID styles
	if (mapstyle_start < LIGHT_IDSTYLE) mapstyle_start = LIGHT_IDSTYLE;
};

//----------------------------------------------------------------------
// Setup all vanilla light styles into a small array (16 strings)
// These light styles can be referenced later for switchable lights
// Originally was setup in world.qc file (not saved strings)
//----------------------------------------------------------------------
void() light_style_setuparray =
{
	local float loopint;
	
	// 0 normal
	light_style_str[0] = "m";
	// 1 FLICKER (first variety)
	light_style_str[1] = "mmnmmommommnonmmonqnmmo";
	// 2 SLOW STRONG PULSE
	light_style_str[2] = "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba";
	// 3 CANDLE (first variety)
	light_style_str[3] = "mmmmmaaaaammmmmaaaaaabcdefgabcdefg";
	// 4 FAST STROBE
	light_style_str[4] = "mamamamamama";
	// 5 GENTLE PULSE 1
	light_style_str[5] = "jklmnopqrstuvwxyzyxwvutsrqponmlkj";
	// 6 FLICKER (second variety)
	light_style_str[6] = "nmonqnmomnmomomno";
	// 7 CANDLE (second variety)
	light_style_str[7] = "mmmaaaabcdefgmmmmaaaammmaamm";
	// 8 CANDLE (third variety)
	light_style_str[8] = "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa";
	// 9 SLOW STROBE (fourth variety)
	light_style_str[9] = "aaaaaaaazzzzzzzz";
	// 10 FLUORESCENT FLICKER
	light_style_str[10] = "mmamammmmammamamaaamammma";
	// 11 SLOW PULSE NOT FADE TO BLACK
	light_style_str[11] = "abcdefghijklmnopqrrqponmlkjihgfedcba";
	
	//----------------------------------------------------------------------
	// Setup default ("m") for all the custom map styles (12-63)
	loopint = LIGHT_IDSTYLE;
	while (loopint < LIGHT_MAXLIGHTSTYLE) {
		light_style_str[loopint] = "m";
		loopint = loopint + 1;
	}

	//----------------------------------------------------------------------
	// Setup vanilla + custom light style table (def=0-31)
	loopint = 0;
	while (loopint < mapstyle_start) {
		lightstyle(loopint, light_style_str[loopint]);
		loopint = loopint + 1;
	}
	
	//----------------------------------------------------------------------
	// styles 32-62 are assigned by the light program for switchable lights
	// 63 testing? No idea why this is done like this, maybe for savefile?
	//lightstyle(63, "a");
};

//----------------------------------------------------------------------
void() play_light_sound = 
{
	if (!self.owner) return;
	if (self.owner.estate & ESTATE_BLOCK) return;
	
	self.think = play_light_sound;
	self.nextthink = time + self.owner.waitmin;
	sound (self, CHAN_VOICE, self.owner.noise, self.owner.volume, ATTN_STATIC);
};

//----------------------------------------------------------------------
void() setup_light_sound = 
{
	if (!self.volume) self.volume = 0.5;
	if ( !(self.spawnflags & LIGHT_NOSOUND) && self.noise != "" ) {
		if (self.targetname) {
			self.attachment = spawn();
			self.attachment.owner = self;
			setorigin(self.attachment, self.origin);
			self.attachment.nextthink = time + 1;
			self.attachment.think = play_light_sound;
		}
		else {
			ambientsound (self.origin, self.noise, self.volume, ATTN_QUIET);
		}
	}
};

//----------------------------------------------------------------------
void() setup_light_static =
{
	// Default = static, check for exception spawnflag
	if (self.spawnflags & LIGHT_NOSTATIC) return;
	// Setup any models that are defined
	if (self.mdl) setmodel (self, self.mdl);
	// Cannot have static entities and particle emitters!
	if (self.part_emitter && self.part_static == FALSE) return;
	// Goodbye entity, no longer interactive with QC
	makestatic (self);
};

//----------------------------------------------------------------------
void() setup_vanilla_nostatic =
{
	// Setup particle static flag
	if (self.spawnflags & LIGHT_NOSTATIC) self.part_static = FALSE;
	else if (self.targetname != "") self.part_static = FALSE;
	else self.part_static = TRUE;	
};

//----------------------------------------------------------------------
void() setup_quoth_nostatic =
{
	// Need to change around spawnflags; 2 -> 4 bitflags
	if (self.spawnflags & LIGHT_QUOTHNOSTAT) {
		self.spawnflags = self.spawnflags - (self.spawnflags & LIGHT_QUOTHNOSTAT);
		self.spawnflags = self.spawnflags | LIGHT_NOSTATIC;
	}
};

//----------------------------------------------------------------------
void(float pe_style) setup_light_particle =
{
	if (self.spawnflags & LIGHT_NOEFFECTS) return;
	// Spawn particle emitter if particles active and not blocked
	if (query_configflag(SVR_PARTICLES) == SVR_PARTICLES ) {
		self.part_active = pe_style;
		if (self.spawnflags & LIGHT_STARTOFF) self.lip = PARTICLE_START_OFF;
		else self.lip = PARTICLE_START_ON;
		self.part_emitter = spawn_pemitter(self, self, self.part_active, self.lip);
	}
};

//----------------------------------------------------------------------
void() light_part_emitter_on =
{
	if (self.part_emitter) {
		if (ext_dppart && self.part_emitter.state == STATE_OFF)
			pointparticles(particleeffectnum(DPP_BURSTFLAME), self.origin, '0 0 0', 1);
		misc_particle_on(self.part_emitter);
	}
	if (self.attachment) {
		self.attachment.think = play_light_sound;
		self.attachment.nextthink = time + 0.1;
	}
};

//----------------------------------------------------------------------
void() light_on =
{
	self.estate = ESTATE_ON;
	// Setup any models, like torches etc
	if (self.mdl) setmodel (self, self.mdl);
	
	// Light style defined?
	if (self.style > 0)
		// Update light style (use array to get the latest)
		lightstyle(self.style, light_style_str[self.style]);

	// Switch on particle emitters
	light_part_emitter_on();
};

//----------------------------------------------------------------------
void() light_off =
{
	self.estate = ESTATE_OFF;
	if (self.mdl) {
		self.modelindex = 0;
		self.model = "";
	}
	// Switch off light style
	lightstyle(self.style, "a");
	// Stop any sounds
	if (self.attachment) 
		sound (self.attachment, CHAN_VOICE, SOUND_EMPTY, 1, ATTN_STATIC);
};

//----------------------------------------------------------------------
void() light_customstyle_finish =
{
	// Check for style errors above compiler light boundary
	// Only for lights with style range issues + customstyles remap/string
	if (self.style >= mapstyle_start && self.targetname == "") {
		// The light entity is using a style number in the compiler
		// generated (they always have targetname) target light zone.
		// If this issue is left, weird things will start happening
		// to lightstyles, highlight error to mapper.
		spawn_marker(self.origin, SPNMARK_YELLOW);
		dprint("\b[LIGHT]\b style ("); dprint(ftos(self.style));
		dprint(") cannot be used, error!\n");
		remove(self);
		return;
	}
	// Style has to be different to re-map
	if (self.customstyle_remap > 0 && self.customstyle_remap == self.style) {
		spawn_marker(self.origin, SPNMARK_YELLOW);
		dprint("\b[LIGHT]\b remap and style are the same!\n");
		remove(self);
		return;
	}

	// Any re-map custom style lights defined?
	if (self.customstyle_remap > 0 && self.style > 0) {
		// Copy string from array
		self.customstyle_string = light_style_str[self.customstyle_remap];
		// Show debug info for custom lightstyle remaps
		dprint("\b[LIGHT]\b ("); dprint(self.classname);
		dprint(") style ("); dprint(ftos(self.style));
		dprint(") remap ("); dprint(ftos(self.customstyle_remap));
		dprint(")\n");
	}

	// Any custom style light string defined?
	// No style check, so that 0 (default, whole map) can be changed
	if (self.customstyle_string != "") {
		// Save the light style to the array
		light_style_str[self.style] = self.customstyle_string;
		// Define new light style to the engine
		lightstyle(self.style, self.customstyle_string);
		// Only show debug info for new custom lightstyles not remaps
		if (self.customstyle_remap == 0) {
			dprint("\b[LIGHT]\b ("); dprint(self.classname);
			dprint(") style ("); dprint(ftos(self.style));
			dprint(") string ("); dprint(self.customstyle_string);
			dprint(")\n");
		}
	}
	
	// Is this a switchable light?
	if (self.targetname != "") {
		// For reference later by other functions
		// self.classgroup = CG_LIGHTS;
		// Setup Entity State functionality
		self.use = entity_state_use;
		if (!self.estate_on) self.estate_on = light_on;
		if (!self.estate_off) self.estate_off = light_off;
		if (self.spawnflags & LIGHT_STARTOFF) self.estate_off();
		else self.estate_on();
	}
	else {
		// No more world interaction required (no targetname)
		// Either remove light or make it static (model exists)
		if (self.classtype == CT_LIGHT) remove(self);
		else if (self.classtype == CT_LIGHTSTATIC) setup_light_static();
	}
};

//----------------------------------------------------------------------
void() light_customstyle_start =
{
	// Need to check style and remap values are within range FIRST
	// Will be serious crash because its an index for fixed size array
	if (self.style < 0 || self.style >= LIGHT_MAXLIGHTSTYLE) {
		spawn_marker(self.origin, SPNMARK_YELLOW);
		dprint("\b[LIGHT]\b light style ("); dprint(ftos(self.style));
		dprint(") out of range!\n");
		remove(self);
		return;
	}
	else if (self.customstyle_remap < 0 || self.customstyle_remap >= LIGHT_MAXLIGHTSTYLE) {
		spawn_marker(self.origin, SPNMARK_YELLOW);
		dprint("\b[LIGHT]\b remap style ("); dprint(ftos(self.customstyle_remap));
		dprint(") out of range!\n");
		remove(self);
		return;
	}

	// All custom lightstyle strings must happen FIRST, so that
	// the array is setup with all the correct strings for remaps
	// Needs slight delay to make sure array has defaults setup
	// No style key check so that style 0 (whole map) can be changed
	if (self.customstyle_string != "") {
		// string has priority over remap
		self.customstyle_remap = 0;
		self.think = light_customstyle_finish;
		self.nextthink = time + 0.1;
	}
	// Re-map lightstyles MUST happen after custom lightstyle strings
	// These lights will have problems being static because of timing
	// Static lights need to be converted early to work properly
	else if (self.customstyle_remap > 0 && self.style > 0) {
		// Will be redefined later
		self.customstyle_string = "";
		self.think = light_customstyle_finish;
		self.nextthink = time + 0.3;
	}
	// Finally switchable lights with styles defined by the compiler
	// These are not removeable or static because of interaction
	// Will need entity state setup and 'use' functionality
	else if (self.targetname != "") light_customstyle_finish();
	else {
		// DEFAULT = No world interaction because no targetname
		// Either remove light or make it static (model exists)
		// This should be happening at spawntime + 0.0
		if (self.classtype == CT_LIGHT) remove(self);
		else if (self.classtype == CT_LIGHTSTATIC) setup_light_static();
	}
};

//======================================================================
/*QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) LIGHTOFF x x x x x x x
Non-displayed light
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
light : sets brightness, 300 is default
style : 0 = normal
        1 = flicker (first variety)
        2 = slow strong pulse
        3 = candle (first variety)
        4 = fast strobe
        5 = gentle pulse
        6 = flicker (second variety)
        7 = candle (second variety)
        8 = candle (third variety)
        9 = slow strobe
       10 = flourescent flicker
       11 = slow pulse, not fading to black
styles 01-63 can be custom in map (use customstyle_string)
styles 32-63 are assigned by the light program for switchable lights

customstyle_remap  : Re-use another light style (0-63)
customstyle_string : light value string made up of "a-z" letters

_color : Light color - R/G/B (def='1 1 1')
wait   : Fade distance multiplier (def=1)
delay  : Attenuation 0=Linear, 1=inverse, 2=Squared, 3=NoFalloff, 4=Minlight, 5=Good Ambient
mangle : Spotlight direction
angle  : Spotlight cone angle (def=40)

_dirt       : Dirt map (override)
_dirtscale  : Dirt scale (override)
_deviance   : Deviance
_samples    : No. of Deviance lights (def=16)
_surface    : Surface light texture name
_surface_offset : Surface light offset (def=2)
_softangle  : Spotlight soft angle (def=0)
_anglescale : Light angle scale (def=0.5)
-------- SPAWNFLAGS --------
LIGHTOFF : Starts off and waits for trigger
-------- NOTES --------
Non-displayed light. If targeted, it will toggle between on or off

======================================================================*/
void() light =
{
	// If any model defined, cache it
	if (self.mdl != "") precache_model (self.mdl);
	self.classtype = CT_LIGHT;
	// Check for any custom light styles
	light_customstyle_start();
};

//======================================================================
/*QUAKED light_fluoro (0 1 0) (-8 -8 -8) (8 8 8) LIGHTOFF NO_SOUND x x x x x x
Non-displayed light. Makes steady fluorescent humming sound
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
light      : sets brightness, 300 is default
_color     : Light color - R/G/B (def='1 1 1')
wait       : Fade distance multiplier (def=1)
delay      : Attenuation 0=Linear, 1=inverse, 2=Squared, 3=NoFalloff, 4=Minlight, 5=Good Ambient
mangle     : Spotlight direction
angle      : Spotlight cone angle (def=40)

_dirt      : Dirt map (override)
_dirtscale : Dirt scale (override)
_deviance  : Deviance
_samples   : No. of Deviance lights (def=16)
_surface   : Surface light texture name
_surface_offset : Surface light offset (def=2)
_softangle : Spotlight soft angle (def=0)
_anglescale: Light angle scale (def=0.5)
-------- SPAWNFLAGS --------
LIGHTOFF   : Starts off and waits for trigger
NO_SOUND   : No ambient sound
-------- NOTES --------
Non-displayed light. Makes steady fluorescent humming sound

======================================================================*/
void() light_fluoro =
{
	// Allow for custom sound
	if (self.noise == "") self.noise = "ambience/fl_hum1.wav";
	precache_sound (self.noise);

	// Default = static entity, check done in static function
	self.classtype = CT_LIGHTSTATIC;
	// Check for any custom light styles
	light_customstyle_start();
	setup_vanilla_nostatic();
	// Setup ambient sound/noise
	setup_light_sound();
};

//======================================================================
/*QUAKED light_fluorospark (0 1 0) (-8 -8 -8) (8 8 8) x NO_SOUND x x x x x x
Non-displayed light. Makes sparking, broken fluorescent sound
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
light      : sets brightness, 300 is default
_color     : Light color - R/G/B (def='1 1 1')
wait       : Fade distance multiplier (def=1)
delay      : Attenuation 0=Linear, 1=inverse, 2=Squared, 3=NoFalloff, 4=Minlight, 5=Good Ambient
mangle     : Spotlight direction
angle      : Spotlight cone angle (def=40)

_dirt      : Dirt map (override)
_dirtscale : Dirt scale (override)
_deviance  : Deviance
_samples   : No. of Deviance lights (def=16)
_surface   : Surface light texture name
_surface_offset : Surface light offset (def=2)
_softangle : Spotlight soft angle (def=0)
_anglescale: Light angle scale (def=0.5)
-------- SPAWNFLAGS --------
NO_SOUND   : No ambient sound
-------- NOTES --------
Non-displayed light. Makes sparking, broken fluorescent sound

======================================================================*/
void() light_fluorospark =
{
	// Allow for custom sound
	if (self.noise == "") self.noise = "ambience/buzz1.wav";
	precache_sound (self.noise);

	// Wait for worldspawn to be read correctly
	if (!self.style) self.style = 10;
	// Default = static entity, check done in static function
	self.classtype = CT_LIGHTSTATIC;
	setup_vanilla_nostatic();
	// Check for any custom light styles
	light_customstyle_start();

	// Setup ambient sound/noise
	setup_light_sound();
};

//======================================================================
/*QUAKED light_globe (0 1 0) (-8 -8 -8) (8 8 8) LIGHTOFF x NO_STATIC x x x X x
{ model(":progs/s_light.spr"); }
Sphere globe light (sprite)
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
light      : sets brightness, 300 is default
_color     : Light color - R/G/B (def='1 1 1')
wait       : Fade distance multiplier (def=1)
delay      : Attenuation 0=Linear, 1=inverse, 2=Squared, 3=NoFalloff, 4=Minlight, 5=Good Ambient
mangle     : Spotlight direction
angle      : Spotlight cone angle (def=40)

_dirt      : Dirt map (override)
_dirtscale : Dirt scale (override)
_deviance  : Deviance
_samples   : No. of Deviance lights (def=16)
_surface   : Surface light texture name
_surface_offset : Surface light offset (def=2)
_softangle : Spotlight soft angle (def=0)
_anglescale: Light angle scale (def=0.5)
-------- SPAWNFLAGS --------
LIGHTOFF   : Starts off and waits for trigger
NO_STATIC  : Will not turn into static entity
-------- NOTES --------
Sphere globe light (sprite)

======================================================================*/
void() light_globe =
{
	self.mdl = "progs/s_light.spr";
	precache_model (self.mdl);
	setmodel (self, self.mdl);
	setsize (self, VEC_ORIGIN, VEC_ORIGIN);

	// Default = static entity, check done in static function
	self.classtype = CT_LIGHTSTATIC;
	setup_vanilla_nostatic();
	// Check for any custom light styles
	light_customstyle_start();
};

//======================================================================
/*QUAKED light_torch_small_walltorch (0 .5 0) (-10 -10 -20) (10 10 20) LIGHTOFF NO_SOUND NO_STATIC x x x x NOPARTICLES
{ model(":progs/flame.mdl"); }
Short wall torch
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
light      : sets brightness, 300 is default
_color     : Light color - R/G/B (def='1 1 1')
wait       : Fade distance multiplier (def=1)
delay      : Attenuation 0=Linear, 1=inverse, 2=Squared, 3=NoFalloff, 4=Minlight, 5=Good Ambient
mangle     : Spotlight direction
angle      : Spotlight cone angle (def=40)

_dirt      : Dirt map (override)
_dirtscale : Dirt scale (override)
_deviance  : Deviance
_samples   : No. of Deviance lights (def=16)
_surface   : Surface light texture name
_surface_offset : Surface light offset (def=2)
_softangle : Spotlight soft angle (def=0)
_anglescale: Light angle scale (def=0.5)
-------- SPAWNFLAGS --------
LIGHTOFF   : Starts off and waits for trigger
NO_SOUND   : No ambient sound
NO_STATIC  : Will not turn into static entity
NOPARTICLES: No particle or effects active
-------- NOTES --------
Short wall torch

======================================================================*/
void() light_torch_on =
{
	self.frame = 0;
	self.estate = ESTATE_ON;
	// Light style defined? (use array to get the latest)
	if (self.style > 0) lightstyle(self.style, light_style_str[self.style]);

	light_part_emitter_on();
};

//----------------------------------------------------------------------
void() light_torch_off =
{
	self.frame = 1;
	self.estate = ESTATE_OFF;
	lightstyle(self.style, "a");
	if (self.attachment) 
		sound (self.attachment, CHAN_VOICE, SOUND_EMPTY, 1, ATTN_STATIC);
};

//----------------------------------------------------------------------
void() light_torch_small_walltorch =
{
	// Allow for custom models
	if (self.mdl == "") self.mdl = "progs/flame.mdl";
	precache_model (self.mdl);
	// Allow for custom sounds
	if (self.noise == "") self.noise = "ambience/fire1.wav";
	precache_sound (self.noise);
	// Default for fire1 sound
	if (!self.waitmin) self.waitmin = 2.165;

	setmodel (self, self.mdl);
	setsize (self, VEC_ORIGIN, VEC_ORIGIN);
	// Setting the angle key in the editor to UP/DOWN = random rotation	
	if (self.angles_y < 0) self.angles_y = rint(random()*359);

	// Default = static entity, check done in static function
	self.classtype = CT_LIGHTSTATIC;

	setup_vanilla_nostatic();
	setup_light_sound();
	setup_light_particle(PARTICLE_STYLE_FLAMET);

	// Custom estate on/off functions
	self.estate_on = light_torch_on;
	self.estate_off = light_torch_off;

	// Check for any custom light styles
	light_customstyle_start();
};

//======================================================================
/*QUAKED light_flame_large_yellow (0 1 0) (-8 -8 -8) (8 8 8) LIGHTOFF NO_SOUND NO_STATIC x x x x NOPARTICLES
{ model(":progs/flame2.mdl"); }
Large yellow flame
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
light      : sets brightness, 300 is default
_color     : Light color - R/G/B (def='1 1 1')
wait       : Fade distance multiplier (def=1)
delay      : Attenuation 0=Linear, 1=inverse, 2=Squared, 3=NoFalloff, 4=Minlight, 5=Good Ambient
mangle     : Spotlight direction
angle      : Spotlight cone angle (def=40)

_dirt      : Dirt map (override)
_dirtscale : Dirt scale (override)
_deviance  : Deviance
_samples   : No. of Deviance lights (def=16)
_surface   : Surface light texture name
_surface_offset : Surface light offset (def=2)
_softangle : Spotlight soft angle (def=0)
_anglescale: Light angle scale (def=0.5)
-------- SPAWNFLAGS --------
LIGHTOFF   : Starts off and waits for trigger
NO_SOUND   : No ambient sound
NO_STATIC  : Will not turn into static entity
NOPARTICLES: No particle or effects active
-------- NOTES --------
Large yellow flame

======================================================================*/
void() light_flame_large_yellow =
{
	// Allow for custom models
	if (self.mdl == "") self.mdl = "progs/flame2.mdl";
	precache_model (self.mdl);
	// Allow for custom sounds
	if (self.noise == "") self.noise = "ambience/fire1.wav";
	precache_sound (self.noise);
	// The default length of the ambient fire1 sound
	if (!self.waitmin) self.waitmin = 2.165;
	
	// If DP engine active remove model shadow
	if (engine == ENG_DPEXT) self.effects = self.effects + EF_NOSHADOW;

	setmodel (self, self.mdl);
	setsize (self, VEC_ORIGIN, VEC_ORIGIN);
	self.frame = 1;			// Switch to frame group 2 (larger flame)
	if (!self.alpha) self.alpha = 0.8;
	// Setting the angle key in the editor to UP/DOWN = random rotation	
	if (self.angles_y <= 0) self.angles_y = rint(random()*359);

	// Default = static entity, check done in static function
	self.classtype = CT_LIGHTSTATIC;
	
 	setup_vanilla_nostatic();
	setup_light_sound();
	setup_light_particle(PARTICLE_STYLE_FLAMEL);
	
	// Check for any custom light styles
	light_customstyle_start();
};

//======================================================================
/*QUAKED light_flame_small_yellow (0 1 0) (-8 -8 -8) (8 8 8) LIGHTOFF NO_SOUND NO_STATIC x x x x NOPARTICLES
{ model(":progs/flame2.mdl"); }
Small yellow flames
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
light      : sets brightness, 300 is default
_color     : Light color - R/G/B (def='1 1 1')
wait       : Fade distance multiplier (def=1)
delay      : Attenuation 0=Linear, 1=inverse, 2=Squared, 3=NoFalloff, 4=Minlight, 5=Good Ambient
mangle     : Spotlight direction
angle      : Spotlight cone angle (def=40)

_dirt      : Dirt map (override)
_dirtscale : Dirt scale (override)
_deviance  : Deviance
_samples   : No. of Deviance lights (def=16)
_surface   : Surface light texture name
_surface_offset : Surface light offset (def=2)
_softangle : Spotlight soft angle (def=0)
_anglescale: Light angle scale (def=0.5)
-------- SPAWNFLAGS --------
LIGHTOFF   : Starts off and waits for trigger
NO_SOUND   : No ambient sound
NO_STATIC  : Will not turn into static entity
NOPARTICLES: No particle or effects active
-------- NOTES --------
Small yellow flames.

======================================================================*/
void() light_flame_small_yellow =
{
	// Allow for custom models
	if (self.mdl == "") self.mdl = "progs/flame2.mdl";
	precache_model (self.mdl);
	// Allow for custom sounds
	if (self.noise == "") self.noise = "ambience/fire1.wav";
	precache_sound (self.noise);
	// The default length of the ambient fire1 sound
	if (!self.waitmin) self.waitmin = 2.165;

	// If DP engine active remove candle model shadow
	if (engine == ENG_DPEXT) self.effects = self.effects + EF_NOSHADOW;

	setmodel (self, self.mdl);
	setsize (self, VEC_ORIGIN, VEC_ORIGIN);
	if (!self.alpha) self.alpha = 0.8;
	// Setting the angle key in the editor to UP/DOWN = random rotation	
	if (self.angles_y <= 0) self.angles_y = rint(random()*359);

	// Default = static entity, check done in static function
	self.classtype = CT_LIGHTSTATIC;

	setup_vanilla_nostatic();
	setup_light_sound();
	self.part_active = PARTICLE_STYLE_FLAMES;
	setup_light_particle(PARTICLE_STYLE_FLAMES);

	// Check for any custom light styles
	light_customstyle_start();
};
//Duplicate (small yellow flame)
void() light_flame_small_white = { light_flame_small_yellow(); };

//======================================================================
/*QUAKED light_postlight (0 .5 0) (-8 -8 -32) (8 8 16) LIGHTOFF NOTSTATIC x x x x x x
{ model(":progs/misc_lightpost.mdl"); }
light post (from Quoth)
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
light      : sets brightness, 300 is default
_color     : Light color - R/G/B (def='1 1 1')
wait       : Fade distance multiplier (def=1)
delay      : Attenuation 0=Linear, 1=inverse, 2=Squared, 3=NoFalloff, 4=Minlight, 5=Good Ambient
mangle     : Spotlight direction
angle      : Spotlight cone angle (def=40)

_dirt      : Dirt map (override)
_dirtscale : Dirt scale (override)
_deviance  : Deviance
_samples   : No. of Deviance lights (def=16)
_surface   : Surface light texture name
_surface_offset : Surface light offset (def=2)
_softangle : Spotlight soft angle (def=0)
_anglescale: Light angle scale (def=0.5)
-------- SPAWNFLAGS --------
LIGHTOFF   : Starts off and waits for trigger
NOTSTATIC  : Not static entity (useful for switchable lights)
-------- NOTES --------
light post (from Quoth)

======================================================================*/
void() light_postlight =
{
	self.mdl = "progs/misc_lightpost.mdl";
	precache_model (self.mdl);

	// Default = static entity, check done in static function
	self.classtype = CT_LIGHTSTATIC;
	setup_quoth_nostatic();
	setup_vanilla_nostatic();
	// Check for any custom light styles
	light_customstyle_start();
};

//======================================================================
/*QUAKED light_tubelight (0 .5 0) (-8 -8 -32) (8 8 16) LIGHTOFF NOTSTATIC x x x x x x
{ model(":progs/misc_lighttube.mdl"); }
light Tube (from Quoth)
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
light      : sets brightness, 300 is default
_color     : Light color - R/G/B (def='1 1 1')
wait       : Fade distance multiplier (def=1)
delay      : Attenuation 0=Linear, 1=inverse, 2=Squared, 3=NoFalloff, 4=Minlight, 5=Good Ambient
mangle     : Spotlight direction
angle      : Spotlight cone angle (def=40)

_dirt      : Dirt map (override)
_dirtscale : Dirt scale (override)
_deviance  : Deviance
_samples   : No. of Deviance lights (def=16)
_surface   : Surface light texture name
_surface_offset : Surface light offset (def=2)
_softangle : Spotlight soft angle (def=0)
_anglescale: Light angle scale (def=0.5)
-------- SPAWNFLAGS --------
LIGHTOFF   : Starts off and waits for trigger
NOTSTATIC  : Not static entity (useful for switchable lights)
-------- NOTES --------
light Tube (from Quoth)
======================================================================*/
void() light_tubelight =
{
	self.mdl = "progs/misc_lighttube.mdl";
	precache_model (self.mdl);

	// Default = static entity, check done in static function
	self.classtype = CT_LIGHTSTATIC;
	setup_quoth_nostatic();
	setup_vanilla_nostatic();
	// Check for any custom light styles
	light_customstyle_start();
};

//======================================================================
/*QUAKED light_flame_pyre (0 .5 0) (-32 -32 -8) (32 32 56) LIGHTOFF NOSTATIC x x x x x NOPARTICLES
{ model(":progs/misc_flame_big.mdl"); }
Flame Pyre (from Quoth)
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
light      : sets brightness, 300 is default
_color     : Light color - R/G/B (def='1 1 1')
wait       : Fade distance multiplier (def=1)
delay      : Attenuation 0=Linear, 1=inverse, 2=Squared, 3=NoFalloff, 4=Minlight, 5=Good Ambient
mangle     : Spotlight direction
angle      : Spotlight cone angle (def=40)

_dirt      : Dirt map (override)
_dirtscale : Dirt scale (override)
_deviance  : Deviance
_samples   : No. of Deviance lights (def=16)
_surface   : Surface light texture name
_surface_offset : Surface light offset (def=2)
_softangle : Spotlight soft angle (def=0)
_anglescale: Light angle scale (def=0.5)
-------- SPAWNFLAGS --------
LIGHTOFF   : Starts off and waits for trigger
NOTSTATIC  : Not static entity (useful for switchable lights)
NOPARTICLES: No particle or effects active
-------- NOTES --------
Flame Pyre (from Quoth)

======================================================================*/
void() light_flame_pyre =
{
	self.mdl = "progs/misc_flame_big.mdl";
	precache_model (self.mdl);

	// Default = static entity, check done in static function
	self.classtype = CT_LIGHTSTATIC;
	setup_quoth_nostatic();
	setup_vanilla_nostatic();
	setup_light_sound();
	setup_light_particle(PARTICLE_STYLE_FLAMEL);

	// Check for any custom light styles
	light_customstyle_start();
};

//======================================================================
/*QUAKED light_flame_brazier_short (0 .5 0) (-8 -8 -16) (8 8 8) LIGHTOFF NOTSTATIC x x x x x NOPARTICLES
{ model(":progs/misc_brazshrt.mdl"); }
Short brazier (from Quoth)
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
light      : sets brightness, 300 is default
skin       : 0=knave(def), 1=rust, 2=redbrick, 3=copper, 4=altar, 5=wizmet
_color     : Light color - R/G/B (def='1 1 1')
wait       : Fade distance multiplier (def=1)
delay      : Attenuation 0=Linear, 1=inverse, 2=Squared, 3=NoFalloff, 4=Minlight, 5=Good Ambient
mangle     : Spotlight direction
angle      : Spotlight cone angle (def=40)

_dirt      : Dirt map (override)
_dirtscale : Dirt scale (override)
_deviance  : Deviance
_samples   : No. of Deviance lights (def=16)
_surface   : Surface light texture name
_surface_offset : Surface light offset (def=2)
_softangle : Spotlight soft angle (def=0)
_anglescale: Light angle scale (def=0.5)
-------- SPAWNFLAGS --------
LIGHTOFF   : Starts off and waits for trigger
NOTSTATIC  : Not static entity (useful for switchable lights)
NOPARTICLES: No particle or effects active
-------- NOTES --------
Short brazier (from Quoth)

======================================================================*/
void() light_flame_brazier_short =
{
	self.mdl = "progs/misc_brazshrt.mdl";
	precache_model (self.mdl);

	// Default = static entity, check done in static function
	self.classtype = CT_LIGHTSTATIC;
	setup_quoth_nostatic();
	setup_vanilla_nostatic();
	setup_light_sound();
	setup_light_particle(PARTICLE_STYLE_FLAMES);

	// Check for any custom light styles
	light_customstyle_start();
};

//======================================================================
/*QUAKED light_flame_brazier_tall (0 .5 0) (-8 -8 -64) (8 8 8) LIGHTOFF NOTSTATIC x x x x x NOPARTICLES
{ model(":progs/misc_braztall.mdl"); }
Long brazier (from Quoth)
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
light      : sets brightness, 300 is default
skin       : 0=knave(def), 1=rust, 2=redbrick, 3=copper, 4=altar, 5=wizmet
_color     : Light color - R/G/B (def='1 1 1')
wait       : Fade distance multiplier (def=1)
delay      : Attenuation 0=Linear, 1=inverse, 2=Squared, 3=NoFalloff, 4=Minlight, 5=Good Ambient
mangle     : Spotlight direction
angle      : Spotlight cone angle (def=40)

_dirt      : Dirt map (override)
_dirtscale : Dirt scale (override)
_deviance  : Deviance
_samples   : No. of Deviance lights (def=16)
_surface   : Surface light texture name
_surface_offset : Surface light offset (def=2)
_softangle : Spotlight soft angle (def=0)
_anglescale: Light angle scale (def=0.5)
-------- SPAWNFLAGS --------
LIGHTOFF   : Starts off and waits for trigger
NOTSTATIC  : Not static entity (useful for switchable lights)
NOPARTICLES: No particle or effects active
-------- NOTES --------
Long brazier (from Quoth)

======================================================================*/
void() light_flame_brazier_tall =
{
	self.mdl = "progs/misc_braztall.mdl";
	precache_model (self.mdl);

	// Default = static entity, check done in static function
	self.classtype = CT_LIGHTSTATIC;
	setup_quoth_nostatic();
	setup_vanilla_nostatic();
	setup_light_sound();
	setup_light_particle(PARTICLE_STYLE_FLAMES);

	// Check for any custom light styles
	light_customstyle_start();
};

//======================================================================
/*QUAKED light_torch_long_walltorch (0 .5 0) (-8 -8 -48) (8 8 80) LIGHTOFF NOTSTATIC x x x x x NOPARTICLES
{ model(":progs/misc_longtrch.mdl"); }
Long wall torch (from Quoth)
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
light      : sets brightness, 300 is default
skin       : 0=knave(def), 1=rust, 2=redbrick, 3=copper, 4=altar, 5=wizmet
_color     : Light color - R/G/B (def='1 1 1')
wait       : Fade distance multiplier (def=1)
delay      : Attenuation 0=Linear, 1=inverse, 2=Squared, 3=NoFalloff, 4=Minlight, 5=Good Ambient
mangle     : Spotlight direction
angle      : Spotlight cone angle (def=40)

_dirt      : Dirt map (override)
_dirtscale : Dirt scale (override)
_deviance  : Deviance
_samples   : No. of Deviance lights (def=16)
_surface   : Surface light texture name
_surface_offset : Surface light offset (def=2)
_softangle : Spotlight soft angle (def=0)
_anglescale: Light angle scale (def=0.5)
-------- SPAWNFLAGS --------
LIGHTOFF   : Starts off and waits for trigger
NOTSTATIC  : Not static entity (useful for switchable lights)
NOPARTICLES: No particle or effects active
-------- NOTES --------
Long wall torch (from Quoth)

======================================================================*/
void() light_torch_long_walltorch =
{
	self.mdl = "progs/misc_longtrch.mdl";
	precache_model (self.mdl);

	// Default = static entity, check done in static function
	self.classtype = CT_LIGHTSTATIC;
	setup_quoth_nostatic();
	setup_vanilla_nostatic();
	setup_light_sound();
	setup_light_particle(PARTICLE_STYLE_FLAMES);

	// Check for any custom light styles
	light_customstyle_start();
};

//======================================================================
/*QUAKED light_fixture1 (0 .5 0) (-10 -10 -20) (10 10 20) LIGHTOFF NOTSTATIC x x x x x x
{ model(":progs/misc_fixture1.mdl"); }
light Fixture (from Rubicon)
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
light      : sets brightness, 300 is default
fixangle   : angle the model should be facing; set it to face away from the wall
_color     : Light color - R/G/B (def='1 1 1')
wait       : Fade distance multiplier (def=1)
delay      : Attenuation 0=Linear, 1=inverse, 2=Squared, 3=NoFalloff, 4=Minlight, 5=Good Ambient
mangle     : Spotlight direction
angle      : Spotlight cone angle (def=40)

_dirt      : Dirt map (override)
_dirtscale : Dirt scale (override)
_deviance  : Deviance
_samples   : No. of Deviance lights (def=16)
_surface   : Surface light texture name
_surface_offset : Surface light offset (def=2)
_softangle : Spotlight soft angle (def=0)
_anglescale: Light angle scale (def=0.5)
-------- SPAWNFLAGS --------
LIGHTOFF   : Starts off and waits for trigger
NOTSTATIC  : Not static entity (useful for switchable lights)
-------- NOTES --------
light Fixture (from Rubicon)

======================================================================*/
void() light_fixture1 =
{
	self.mdl = "progs/misc_fixture1.mdl";
	precache_model (self.mdl);
	self.angles_y = self.fixangle;

	// Default = static entity, check done in static function
	self.classtype = CT_LIGHTSTATIC;
	setup_quoth_nostatic();
	setup_vanilla_nostatic();
	// Check for any custom light styles
	light_customstyle_start();
};

//======================================================================
/*QUAKED light_candle (0 1 0) (-4 -4 -16) (4 4 16) LIGHTOFF FLAMEOFF x SHADOWS x STATIC x x
{ model(":progs/misc_candle1.mdl"); }
Wide variety of Candles (from Rogue Software)
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
angle      : 0=random angle, 1-360=specific
height     : size of candle 1=short, 2=medium, 3=regular, -1=random
t_width    : width of candle 1=regular, 2=fat, 3=thin, -1=random
lip        : Moves model down to ground plane (default = 16)
light      : sets brightness, 300 is default
_color     : Light color - R/G/B (def='1 1 1')
wait       : Fade distance multiplier (def=1)
delay      : Attenuation 0=Linear, 1=inverse, 2=Squared, 3=NoFalloff, 4=Minlight, 5=Good Ambient
mangle     : Spotlight direction
angle      : Spotlight cone angle (def=40)

_dirt      : Dirt map (override)
_dirtscale : Dirt scale (override)
_deviance  : Deviance
_samples   : No. of Deviance lights (def=16)
_surface   : Surface light texture name
_surface_offset : Surface light offset (def=2)
_softangle : Spotlight soft angle (def=0)
_anglescale: Light angle scale (def=0.5)
-------- SPAWNFLAGS --------
LIGHTOFF   : Starts off and waits for trigger
FLAMEOFF   : The candle is displayed off (no flame)
SHADOWS    : Turn on shadows in DP engine
STATIC     : Turn entity into static upon spawn (frame 0)
-------- NOTES --------
Wide variety of Candles (from Rogue Software)

======================================================================*/
void() light_candle_on =
{
	self.estate = ESTATE_ON;
	self.frame = 1 + (self.t_width-1)*2;
	// Light style defined? (use array to get the latest)
	if (self.style > 0) lightstyle(self.style, light_style_str[self.style]);
};

//----------------------------------------------------------------------
void() light_candle_off =
{
	self.estate = ESTATE_OFF;
	self.frame = (self.t_width-1)*2;
	lightstyle(self.style, "a");
};

//----------------------------------------------------------------------
void() light_candle_setup =
{
	// Setup model and no world interaction
	setmodel (self, self.mdl);
	setsize (self, VEC_ORIGIN, VEC_ORIGIN);

	// If DP engine active remove candle model shadow
	if (engine == ENG_DPEXT && !(self.spawnflags & LIGHT_CANDLESHADOW)) 
		self.effects = self.effects + EF_NOSHADOW;

	// Setting the angle key in the editor to UP/DOWN = random rotation	
	if (self.angles_y <= 0) self.angles_y = rint(random()*359);
	
	// Setup light
	if (self.spawnflags & LIGHT_FLAMEOFF) {
		self.estate = ESTATE_OFF;
		self.frame = (self.t_width-1)*2;
	}

	// Check for static option (default is now static if no target)
	if (self.spawnflags & ENT_SPNSTATIC) makestatic(self);
	else {
		// Custom estate on/off functions
		self.estate_on = light_candle_on;
		self.estate_off = light_candle_off;
		// Check for any custom light styles
		light_customstyle_start();
	}
};

//----------------------------------------------------------------------
void() light_candle =
{
	// Cannot have randomly selected models for prechache
	// Quickload will re-run all spawn functions and try to select
	// a different candle model which is not precached
	precache_model ("progs/misc_candle1.mdl");
	precache_model ("progs/misc_candle2.mdl");
	precache_model ("progs/misc_candle3.mdl");

	// Check for size 1=small, 2=medium, 3=regular (def), -1=random
	if (self.height < 0) self.height = 1 + rint(random()*2);
	if (self.height == 1) self.mdl = "progs/misc_candle1.mdl";
	else if (self.height == 2) self.mdl = "progs/misc_candle2.mdl";
	else self.mdl = "progs/misc_candle3.mdl";
	
	// Check for width 1=regular (def), 2=fat, 3=thin, -1=random
	// The models are split up into three groups of off/on
	if (self.t_width < 0) self.t_width = 1 + rint(random()*2);
	else if (self.t_width == 0 || self.t_width > 3) self.t_width = 1;

	self.modelindex = 0;
	self.model = string_null;				// hide bmodel surface
	self.frame = 1 + (self.t_width-1)*2;	// Def = on state
	self.movetype = MOVETYPE_NONE;			// Create baseline
	self.solid = SOLID_NOT;
	self.nextthink = 0;

	// The model should not be setup flush to floor because it is a light
	// source and will look really odd, setup entity 16 units above floor
	// and the "lip" key will move it back down again
	if (!self.lip) self.lip = 16;
	self.origin_z = self.origin_z - self.lip;

	// Check for static entity option first
	if (self.spawnflags & ENT_SPNSTATIC) light_candle_setup();
	else {
		// Check for spawn delay on model (signon buffer issues)
		// Code left so light_candles can be switched on/off
		if (self.lighttarget != "" && !self.style) {
			self.targetname = self.lighttarget;
			// Use the entity state system for max compatibility
			self.estate = ESTATE_OFF;
			self.use = entity_state_use;
			self.estate_on = light_candle_setup;
		}
		else light_candle_setup();
	}
};
