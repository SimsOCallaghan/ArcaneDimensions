/*======================================================================
 SOUND functions
======================================================================*/
float SOUND_PLAYONCE = 2;		// When triggered plays once

//----------------------------------------------------------------------
void() ambient_sound_setup =
{
	if (self.volume > 1) self.volume = 1;
	ambientsound (self.origin, self.noise, self.volume, ATTN_STATIC);
};

/*============================================================================
/*QUAKED ambient_custom_loop (0.3 0.1 0.6) (-16 -16 -8) (16 16 8) x
Custom ambient (must be looped) sound, CANNOT toggle/switch state
-------- KEYS --------
volume : volume of sound (default 1, capped at 1)
noise : custom sound to play (looped)
-------- SPAWNFLAGS --------
-------- NOTES --------
Custom ambient (must be looped) sound, CANNOT toggle/switch state
============================================================================*/
void() ambient_custom_loop =
{
	// Check for sound file
	if (self.noise == "") {
		dprint("\b[AMB_CUSTOM_LOOP]\b Missing sound file\n");
		spawn_marker(self.origin);
		remove(self);
		return;
	}
	
	precache_sound (self.noise);
	if (self.volume <= 0) self.volume = 1;
	ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_comp_hum =
{
	self.noise = "ambience/comp1.wav";
	precache_sound (self.noise);
	self.volume = 1;
	ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_drip =
{
	self.noise = "ambience/drip1.wav";
	precache_sound (self.noise);
	self.volume = 0.5;
	ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_drone =
{
	self.noise = "ambience/drone6.wav";
	precache_sound (self.noise);
	self.volume = 0.5;
	ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_flouro_buzz =
{
	self.noise = "ambience/buzz1.wav";
	precache_sound (self.noise);
	self.volume = 1;
	ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_light_buzz =
{
	self.noise = "ambience/fl_hum1.wav";
	precache_sound (self.noise);
	self.volume = 0.5;
	ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_suck_wind =
{
	self.noise = "ambience/suck1.wav";
	precache_sound (self.noise);
	self.volume = 1;
	ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_swamp1 =
{
	self.noise = "ambience/swamp1.wav";
	precache_sound (self.noise);
	self.volume = 0.5;
	ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_swamp2 =
{
	self.noise = "ambience/swamp2.wav";
	precache_sound (self.noise);
	self.volume = 0.5;
	ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_thunder =
{
	self.noise = "ambience/thunder1.wav";
	precache_sound (self.noise);
	self.volume = 0.5;
	ambient_sound_setup();
};

//======================================================================
/*QUAKED ambient_custom_sound (0.5 0.1 0.8) (-16 -16 -8) (16 16 8) x PLAYONCE x x x x STARTOFF x
Play a sound on a periodic basis
-------- KEYS --------
targetname : trigger entity (works with entity state system)
volume  : volume of sound (default 1, capped at 1)
noise   : path to the sound to play (ambience/windgust1.wav)
wait    : random time between sounds (default 20, =-1 no random element)
delay   : minimum time between sounds (default 2)
waitmin : Starting time (waitmin + random() x waitmin, =-1 no delay)
impulse : channel on which to play sound (0-7) (0 automatic is default)
speed   : attenuation -1=no attenuation, 1=normal (default), 2=idle, 3=static, 4=quiet
-------- SPAWNFLAGS --------
PLAYONCE : When triggered plays once
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
Play a sound on a periodic basis
*/
//======================================================================
void() ambient_custom_stop =
{
	// Block USE functionality if state wrong
	if (self.estate & ESTATE_BLOCK) return;

	self.state = STATE_OFF;
	// Check for OFF sound, else play silence to clear sound
	if (self.noise1) sound (self, self.impulse, self.noise1, self.volume, self.speed);
	else sound (self, self.impulse, SOUND_EMPTY, self.volume, self.speed);
	
	// lunaran
	// clear think so ambient_custom_play doesn't turn the speaker back on later
	self.think = ambient_custom_stop;
	self.nextthink = 0;
	// lunaran
};

//----------------------------------------------------------------------
void() ambient_custom_play =
{
	// Block USE functionality if state wrong
	if (self.estate & ESTATE_BLOCK) return;

	self.state = STATE_ON;
	sound (self, self.impulse, self.noise, self.volume, self.speed);
	
	// Keep playing sound?
	// If sound is setup to play once, don't turn off sound before finished
	// Let the sound play out and switch off ambient sound entity
	if (self.spawnflags & SOUND_PLAYONCE) self.estate = ESTATE_OFF;
	else {
		self.nextthink = time + self.delay + random()*self.wait;
		self.think = ambient_custom_play;
	}
};

//----------------------------------------------------------------------
void() ambient_custom_use =
{
	// Deal with STARTOFF functionality first
	if (self.spawnflags & ENT_STARTOFF) {
		// Remove spawnflag and switch ON entity
		self.spawnflags = self.spawnflags - ENT_STARTOFF;
		self.estate_on();
	}
	else {
		// Block USE functionality if state wrong
		if (self.estate & ESTATE_BLOCK) return;

		// Toggle state of ambient sound to start/stop
		if (self.state == STATE_OFF) ambient_custom_play();
		else ambient_custom_stop();
	}
};

//----------------------------------------------------------------------
void() ambient_custom_on =
{
	self.estate = ESTATE_ON;
	ambient_custom_play();
};

//----------------------------------------------------------------------
void() ambient_custom_off =
{
	self.estate = ESTATE_OFF;
	ambient_custom_stop();
};

//----------------------------------------------------------------------
void() ambient_custom_disable =
{
	self.state = STATE_OFF;
	sound (self, self.impulse, SOUND_EMPTY, self.volume, self.speed);
};

//----------------------------------------------------------------------
void() ambient_custom_sound =
{
	// Check for sound file
	if (self.noise == "") {
		dprint("\b[AMBIENT_SOUND]\b Missing sound file at ");
		dprint(vtos(self.origin)); dprint("\n");
		spawn_marker(self.origin);
		remove(self);
		return;
	}
	precache_sound (self.noise);
	
	// Is there an OFF sound defined (used for toggle sounds)
	if (self.noise1 != "") precache_sound (self.noise1);
	
	self.classtype = CT_SOUNDEMITTER;
	if (self.volume <= 0 || self.volume > 1) self.volume = 1;
	
	// lunaran
	if (self.wait == 0) self.wait = 20;
	if (self.wait < 0) self.wait = 0;	// lunaran
	// lunaran
	
	if (self.delay <= 0) self.delay = 2;
	if (self.waitmin == 0) self.waitmin = 4;
	if (self.impulse <= 0) self.impulse = 1;

	// attenuation -1=no attenuation, 1=normal (default), 2=idle, 3=static, 4=quiet	
	if (self.speed < 0) self.speed = ATTN_NONE;
	else if (self.speed == 2) self.speed = ATTN_IDLE;
	else if (self.speed == 3) self.speed = ATTN_STATIC;
	else if (self.speed == 4) self.speed = ATTN_QUIET;
	else self.speed = ATTN_NORM;
		
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_on = ambient_custom_on;
	self.estate_off = ambient_custom_off;
	self.estate_use = ambient_custom_use;
	self.estate_disable = ambient_custom_disable;
	if (self.spawnflags & ENT_STARTOFF) self.estate_off();
	else {
		if (self.waitmin > 0) {
			self.nextthink = time + self.waitmin + random()*self.waitmin;
			self.think = self.estate_on;
		}
		else self.estate_on();
	}
};