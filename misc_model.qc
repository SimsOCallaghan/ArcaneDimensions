//======================================================================
/*QUAKED misc_model (1 .5 .25) (-16 -16 -16) (16 16 16) x COLLISION MOVEMENT DROPFLOOR x STATIC STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
MDL files that can be setup with specific frame/skin and animate groups
-------- KEYS --------
targetname  : toggle state (use trigger ent for exact state)
mdl         : specify model to load, full path (progs/candle.mdl)
angle       : facing angle of model (-1 = random position)
angles      : 'pitch yaw roll' up/down, angle, tilt left/right 
ideal_yaw   : = 1 Setup model with random Y axis rotation
frame       : exact frame number (Quoth entity compatibility)
skin        : exact skin number (Quoth entity compatibility)
mangle      : 'pitch yaw roll' override (Quoth entity compatibility)
view_ofs    : Extra offset for origin (ideal for light origin issues)
delay       : Spawning delay for models on func movers (works once)
sounds      : TRIGGER 1=Secret, 2=talk, 3=switch, 4=silent, 5=custom, 6=secret2
noise       : Custom sound to play with animation TRIGGER
locksounds  : TOGGLE 1=laser, 2=power, 4=silent, 5=custom
noise1      : Custom sound to play when animation TOGGLE ON
noise2      : Custom sound to play when animation TOGGLE OFF
volume      : Volume for all custom sounds played (def=1, range=0-1)
lip         : Frame/skin animation direction -2=random, -1=back, 1=forward(def)
state       : Automatic start of frame/skin animations (0=ON, -1/1=OFF)
speed       : Override for frame/skin animation speed (def=0.1s)
pos1        : FRAME basic and range parameters
               X=0, Y=0, Z=exact frame number
               X->Y, Z=0 Randomly pick a frame from the X,Y range
               X->Y, Z=-1 Animate between the X,Y range
pos2        : SKIN basic and range parameters
               X=0, Y=0, Z=exact skin number
               X->Y, Z=0 Randomly pick a skin from the X,Y range
               X->Y, Z=-1 Animate between the X,Y range
framestart  : FRAME Starting point, 0=def, X=-1 Random, X=0+ Exact
frameloop   : FRAME type, 0=Constant, 1+=Range+stop, -1=Toggle, -2=Trigger+wait
skinstart   : SKIN Starting point, 0=def, X=-1 Random, X=0+ Exact
skinloop    : SKIN type, 0=Constant, 1+=Range+stop, -1=Toggle, -2=Trigger+wait
rotateloop  : ROTATE type, 0=Constant, 1+=Range+stop, -1=Toggle, -2=Trigger+wait
rotateangles: ROTATE axis (XYZ) changing (+/-) angles over time
alphastart  : ALPHA fade IN time for misc_model (1=Fade in over 1s)
bbmins      : Model bounding box override (use with collision/dropfloor)
bbmaxs      : Model bounding box override
target      : Path_corner entities to start moving towards on spawn
faceangle   : Turn model towards path_corner as it moves around (def=0)
yaw_speed   : Turning speed of model towards path_corners (def=15)
movespeed   : Movement speed of model towards path_corners (def=50)
normalangle : 1=Turn the model towards the normal plane direction
-------- SPAWNFLAGS --------
COLLISION   : model bbox collision enabled
MOVEMENT    : model can be moved around like an item
DROPFLOOR   : Will drop to the floor below (terrain alignment)
STATIC      : Turn entity into static upon spawn (frame 0)
STARTOFF    : Always Starts off and waits for trigger
-------- NOTES --------
MDL files that can be setup with specific frame/skin and animate groups

======================================================================*/
float MISC_COLLISION = 2;		// misc_model has collision enabled
float MISC_MOVEMENT = 4;		// misc_model can be moved around
float MISC_DROPTOFLOOR = 8;		// misc_model will drop to floor
float MISC_MDLSETUP = 4096;		// misc_model setup (first time)

float MMLOOP_CONSTANT = 0;		// Animation/Skin/Rotation setup
float MMLOOP_TOGGLE = -1;
float MMLOOP_TRIGGER = -2;

//----------------------------------------------------------------------
// This is essentially a QC version of ChangeYaw() function
// Can cope with any axis as its take all parameters
//----------------------------------------------------------------------
float(float curr_ang, float ideal_ang, float turn_speed) misc_model_turning =
{
	local float move_ang, ret_ang;
	
	// Current/ideal as integers are easier to compare
	// Having fine detailed angles leads to jittering
	// Also make sure angle 0 = 360 (stops wrong turns)
	curr_ang = rint(curr_ang);
	if (curr_ang == 0) curr_ang = 360;
	ideal_ang = rint(ideal_ang);
	if (ideal_ang == 0) ideal_ang = 360;
	
	// Any change required? (very precise, 1 degree angle)
	if (curr_ang == ideal_ang) return curr_ang;
	// Find out angle difference (can be positive/negative)
	move_ang = ideal_ang - curr_ang;
	
	// Find out quickest angle movement (clockwise/counter)
	// Differences greater than 180 are turning the wrong way
	if (ideal_ang > curr_ang) {
		if (move_ang >= 180) move_ang = move_ang - 360; }
	else {
		if (move_ang <= -180) move_ang = move_ang + 360; }
	
	// Make sure the turning angle is not instant turning speed
	// Find out the turning speed and direction (+/-)
	if (move_ang > 0) {
		if (move_ang > turn_speed) move_ang = turn_speed; }
	else {
		if (move_ang < -turn_speed) move_ang = -turn_speed; }

	// Add turning speed to current angles (+range check)
	ret_ang = anglemod(curr_ang + move_ang);
	return (ret_ang);
};

//----------------------------------------------------------------------
void() misc_model_findtarget =
{
	// Any target (path_corner) defined?
	if (self.target != "") {
		// Find the entity in world
		self.goalentity = find(world, targetname, self.target);
		// only works with path corner entities! - Reset
		if (self.goalentity.classtype != CT_PATHCORNER) self.target = "";
		else {
			// Directional vector (finishing point)
			self.dest1 = self.goalentity.origin - self.origin;
			// Convert direction to facing angle + clamp 0-360
			self.finalangle = vectormod(vectoangles(self.dest1));
			// Total (map) distance to travel
			self.t_length = vlen(self.dest1);
			// Movement (map) distance per animation tick frame (count)
			self.t_width = self.movespeed * self.speed;
			// Maximum vector distance to travel
			self.dest2 = (normalize(self.dest1) * self.t_length);
			// divide total distance by tick frame timing
			self.dest3 = self.dest2 / (self.t_length / self.t_width);
			// Movement counter (>t_length = end of movemnt)
			self.count = 0;
			
		}
	}
	// Something wrong, reset target/goalentity
	if (self.target == "") self.goalentity = world;
};

//----------------------------------------------------------------------
void() misc_model_movetarget = 
{
	// Has the model reached the path_corner?
	if (self.count >= self.t_length) {
		// Suppress any console errors
		self.nodebuginfo = TRUE;
		// Check for any corner events?
		trigger_strs(self.goalentity.corner_event, self);
		// Check for any speed change
		if (self.goalentity.corner_speed > 0)
			self.movespeed = self.goalentity.corner_speed;
		// Check for pause at path corner
		if (self.goalentity.wait < 0) self.corner_pause = TRUE;
		else self.corner_pause = FALSE;
		// Setup next target (if it exists)
		self.target = self.goalentity.target;
		// Find next target (has exit condition)
		misc_model_findtarget();
	}
	else {
		// Still moving, don't turn off function loop
		self.state = STATE_ON;
		// Increase distance counter
		self.count = self.count + self.t_width;
		// Add distance segment for next point
		self.origin = self.origin + self.dest3;
		// Jump/move to next origin spot on path
		setorigin(self, self.origin);
		// Find if model is turning towards target?
		if (self.faceangle > 0) {
			// Z axis = pitch (twisting) ignore this for models
			// Y axis = classic angle/yaw
			// X axis = roll (up/down) for climbing towards path corners
			self.angles_y = misc_model_turning(self.angles_y, self.finalangle_y, self.yaw_speed);
			self.angles_x = misc_model_turning(self.angles_x, self.finalangle_x, self.yaw_speed);
		}
	}
};

//----------------------------------------------------------------------
void() misc_model_loop =
{
	// Block off/disabled entity states
	if (self.estate & ESTATE_BLOCK) return;

	// Update FRAMES
	if (self.pos1_z == NEGATIVE && self.waitmin != 0) {
		// Update frame
		self.frame = self.framestart;
		// Move forward/backward
		self.framestart = self.framestart + self.lip;
		if (self.lip > 0 && self.framestart > self.pos1_y) 
			self.framestart = self.pos1_x;
		else if (self.lip < 0 && self.framestart < self.pos1_x) 
			self.framestart = self.pos1_y;
		// Double Check for out of bounds
		if (self.framestart < self.pos1_x || self.framestart > self.pos1_y)
			self.framestart = self.pos1_x;
	}
	
	// Update SKINS
	if (self.pos2_z == NEGATIVE && self.waitmin2 != 0) {
		// Update frame
		self.skin = self.skinstart;
		// Move forward/backward
		self.skinstart = self.skinstart + self.lip;
		if (self.lip > 0 && self.skinstart > self.pos2_y) 
			self.skinstart = self.pos2_x;
		else if (self.lip < 0 && self.skinstart < self.pos2_x) 
			self.skinstart = self.pos2_y;
		// Double Check for out of bounds
		if (self.skinstart < self.pos2_x || self.skinstart > self.pos2_y)
			self.skinstart = self.pos2_x;
	}
	
	// Update rotation
	if (!CheckZeroVector(self.rotateangles) && self.waitmin3 != 0) {
		self.angles = self.angles + self.rotateangles;
		self.angles = vectormod(self.angles);
	}
	
	// Decrease (RANGE+TRIGGER) counters for frame/skin animations
	if (self.waitmin > 0) self.waitmin = self.waitmin - 1;
	if (self.waitmin2 > 0) self.waitmin2 = self.waitmin2 - 1;
	if (self.waitmin3 > 0) self.waitmin3 = self.waitmin3 - 1;

	// Check if frame, skin & rotation have finished counting down?
	if (self.waitmin == 0 && self.waitmin2 == 0 && self.waitmin3 == 0) 
		self.state = STATE_OFF;

	// Check for any movement
	if (self.target != "" && self.corner_pause == FALSE) {
		// First time movement? goalentity = world
		if (!self.goalentity) misc_model_findtarget();
		// Everything ready, keep moving
		else misc_model_movetarget();
		// Paused at path_corner? no, keep moving!
		if (self.corner_pause == FALSE) self.state = STATE_ON;
	}
		
	// Keep looping (using frame setup)
	if (self.state == STATE_ON) {
		self.think = misc_model_loop;
		self.nextthink = time + self.speed;
	}
};

//----------------------------------------------------------------------
void() misc_model_use = 
{
	local float trigsound;

	// Allow trigger to activate/turn on spawndelay misc model
	if (self.spawnflags & (MISC_STARTOFF | ENT_STARTOFF)) {
		self.spawnflags = self.spawnflags - (self.spawnflags & MISC_STARTOFF);
		self.spawnflags = self.spawnflags - (self.spawnflags & ENT_STARTOFF);
		entity_state_on();
		return;
	}
	// Block off/disabled entity states
	if (self.estate & ESTATE_BLOCK) return;
	trigsound = FALSE;
	
	// No movement pause (ready to move)
	self.corner_pause = FALSE;

		// FRAME animation loops setup?
	if (self.pos1_z == NEGATIVE) {
		// Toggle cannot switch off animation state because other types
		// (frame/skin/rotate) maybe active and animating
		if (self.frameloop == MMLOOP_TOGGLE) {
			if (self.state == STATE_ON) {
				// TOGGLE OFF frame loop ONLY!
				self.waitmin = 0;
				// Play OFF sound
				if (self.noise2 != "") 
					sound (self, CHAN_VOICE, self.noise2, self.volume, ATTN_NORM);
			}
			else {
				// TOGGLE ON
				self.state = STATE_ON;	// Animation active
				self.waitmin = -1;		// Constant loop
				// Play ON sound
				if (self.noise1 != "") 
					sound (self, CHAN_VOICE, self.noise1, self.volume, ATTN_NORM);
			}
		}
		// Always switch ON animation
		else if (self.frameloop == MMLOOP_CONSTANT) {
			self.state = STATE_ON;	// Animation active
			self.waitmin = -1;		// Constant loop
		}
		// Animation for ONE time and stop
		else if (self.frameloop == MMLOOP_TRIGGER) {
			trigsound = TRUE;		// Check for trigger sound
			self.state = STATE_ON;	// Animation active
			self.waitmin = 1;		// Loop once
		}
		// Animation for fixed amount of time (cycles)
		else if (self.frameloop >= 1) {
			trigsound = TRUE;				// Check for trigger sound
			self.state = STATE_ON;			// Animation active
			self.waitmin = self.frameloop;	// Loop fixed amount
		}
	}
	// SKIN animation loops setup?
	if (self.pos2_z == NEGATIVE) {
		// Toggle cannot switch off animation state because other types
		// (frame/skin/rotate) maybe active and animating
		if (self.skinloop == MMLOOP_TOGGLE) {
			if (self.state == STATE_ON) {
				// TOGGLE OFF skin loop ONLY!
				self.waitmin2 = 0;
				// Play OFF sound
				if (self.noise2 != "") 
					sound (self, CHAN_VOICE, self.noise2, self.volume, ATTN_NORM);
			}
			else {
				// TOGGLE ON
				self.state = STATE_ON;	// Animation active
				self.waitmin2 = -1;		// Constant loop
				// Play ON sound
				if (self.noise1 != "") 
					sound (self, CHAN_VOICE, self.noise1, self.volume, ATTN_NORM);
			}
		}
		// Only switch on for constant if inactive
		else if (self.skinloop == MMLOOP_CONSTANT) {
			self.state = STATE_ON;	// Animation active
			self.waitmin2 = -1;		// Constant loop
		}
		// Animation for ONE time and stop
		else if (self.skinloop == MMLOOP_TRIGGER) {
			trigsound = TRUE;		// Check for trigger sound
			self.state = STATE_ON;	// Animation active
			self.waitmin2 = 1;		// Loop once
		}
		// Animation for fixed amount of time (cycles)
		else if (self.skinloop >= 1) {
			trigsound = TRUE;				// Check for trigger sound
			self.state = STATE_ON;			// Animation active
			self.waitmin2 = self.skinloop;	// Loop fixed amount
		}
	}
	else {
		// Check for new skin numbers and only change if needed
		if (self.pos2_z > 0 && self.skin != self.pos2_z) 
			self.skin = self.pos2_z;
	}
	// ROTATION animation loops setup
	if (!CheckZeroVector(self.rotateangles)) {
		// Toggle cannot switch off animation state because other types
		// (frame/skin/rotate) maybe active and animating
		if (self.rotateloop == MMLOOP_TOGGLE) {
			if (self.state == STATE_ON) {
				// TOGGLE OFF rotation loop ONLY!
				self.waitmin3 = 0;
				// Play OFF sound
				if (self.noise2 != "") 
					sound (self, CHAN_VOICE, self.noise2, self.volume, ATTN_NORM);
			}
			else {
				// TOGGLE ON
				self.state = STATE_ON;	// Animation active
				self.waitmin3 = -1;		// Constant loop
				// Play ON sound
				if (self.noise1 != "") 
					sound (self, CHAN_VOICE, self.noise1, self.volume, ATTN_NORM);
			}
		}
		// Only switch on for constant if inactive
		else if (self.rotateloop == MMLOOP_CONSTANT) {
			self.state = STATE_ON;	// Animation active
			self.waitmin3 = -1;		// Constant loop
		}
		// Animation for ONE time and stop
		else if (self.rotateloop == MMLOOP_TRIGGER) {
			trigsound = TRUE;		// Check for trigger sound
			self.state = STATE_ON;	// Animation active
			self.waitmin3 = 1;		// Loop once
		}
		// Animation for fixed amount of time (cycles)
		else if (self.rotateloop >= 1) {
			trigsound = TRUE;				// Check for trigger sound
			self.state = STATE_ON;			// Animation active
			self.waitmin3 = self.rotateloop;// Loop fixed amount
		}
	}

	// Any movement required for loop? If active, ignore retry
	if (self.yaw_speed > 0 && self.state == STATE_OFF)
		self.state = STATE_ON;
	
	// Check for TRIGGER sound
	if (trigsound == TRUE && self.noise != "") 
		sound (self, CHAN_VOICE, self.noise, self.volume, ATTN_NORM);

	// Are there any animation loops setup?
	if (self.state == STATE_ON) misc_model_loop();
};

//----------------------------------------------------------------------
void() misc_model_fade =
{
	// Keep increasing alpha
    self.owner.alpha = (time - self.owner.ltime) / self.alphastart;
	// Check for exit conditions
    if (self.owner.alpha > 1) self.owner.alpha = 1;
	// Keep looking, really fast!
    else self.nextthink = time + FADEMODEL_TIME;
};

//----------------------------------------------------------------------
void() misc_model_loopreset = 
{
	// Reset animation loop counters
	self.waitmin = self.waitmin2 = self.waitmin3 = 0;
};

//----------------------------------------------------------------------
void() misc_model_on =
{
	local float checkanim;
	
	// Highlight movement models with dev diamond above model
	if (self.spawnflags & MISC_MOVEMENT) 
		spawn_marker(self.origin+'0 0 16', 3);
	
	// Check if there is any spawn/on delay setup
	// Useful for delay spawning models on to platform/doors
	if (self.delay > 0) {
		// Feed back into this function
		self.think = misc_model_on;
		self.nextthink = time + self.delay;
		// The delay only works once
		self.delay = 0;
		return;
	}
	
	// Setup any ALPHA fade in functionality
	if (self.alphastart >= 1 && self.attachment) {
		self.alpha = 0.01;		// Starting value (can't be zero)
		self.attachment.think = misc_model_fade;
		self.attachment.nextthink = time + 0.01;
		self.attachment.alphastart = self.alphastart;
		self.ltime = time;		// Setup local timer
		self.alphastart = 0;	// Only ONCE
	}
	
	// Enable model
	self.estate = ESTATE_ON;
	setmodel (self, self.mdl);
	
	// Restore model/size and check if collision needed
	if (self.spawnflags & MISC_COLLISION) {
		self.solid = SOLID_BBOX;
		// Check for any bounding box override (check min only)
		if (CheckZeroVector(self.bbmins)) {
			// Use model default size
			setsize (self, self.mins , self.maxs);
		}
		// Override defaults with custom sizes
		else setsize (self, self.bbmins , self.bbmaxs);
	}
	else setsize (self, VEC_ORIGIN, VEC_ORIGIN);
	// Move model to exact location (allow for offset)
	setorigin(self, self.oldorigin + self.view_ofs);

	// Is the model on a mover (func object)
	if (self.spawnflags & MISC_MOVEMENT) {
		// Turn misc model into an item (can work with plats/doors)
		self.movetype = MOVETYPE_TOSS;
		self.solid = SOLID_TRIGGER;
		setsize (self, VEC_ORIGIN, VEC_ORIGIN);
		self.velocity = '0 0 0';
		// Make sure the misc model starts on the ground
		self.origin_z = self.origin_z + 6;
		if (!droptofloor()) {
			dprint ("\n\b[Model]\b "); dprint (self.mdl);
			dprint (" stuck at ("); dprint (vtos(self.origin)); dprint (")\n");
			spawn_marker(self.origin, SPNMARK_YELLOW);
			remove(self);
			return;
		} 
		// Make sure no touch function is active
		self.touch = SUB_Null;
		// Save original for later on/off functions
		self.oldorigin = self.origin;
	}

	// Reset loop counters
	misc_model_loopreset();
	checkanim = FALSE;

	// First time setup to cope with precise ANIMATION setup ON/OFF
	if (self.spawnflags & MISC_MDLSETUP) {
		// Remove the setup spawnflags, used only once
		self.spawnflags = self.spawnflags - (self.spawnflags & MISC_MDLSETUP);
		if (self.state == STATE_ON) {
			checkanim = TRUE;
			// TOGGLE requires opposite starting state to start ON
			if (self.frameloop == MMLOOP_TOGGLE) self.state = STATE_OFF;
			else if (self.skinloop == MMLOOP_TOGGLE) self.state = STATE_OFF;
			else if (self.rotateloop == MMLOOP_TOGGLE) self.state = STATE_OFF;
		}
	}
	// DEFAULT Check animations if they exist (aflag)
	else if (self.aflag == TRUE) checkanim = TRUE;
	// If movement setup (target) start model loop
	if (self.yaw_speed > 0) checkanim = TRUE;

	// Are there any animation loops TO setup?
	if (checkanim == TRUE) misc_model_use();
	else {
		// Exact frame/skin numbers (check for negatives)
		if (self.pos1_z < 0) self.frame = self.pos1_x;
		else self.frame = self.pos1_z;
		if (self.pos2_z < 0) self.skin = self.pos2_x;
		else self.skin = self.pos2_z;
	}
};

//----------------------------------------------------------------------
void() misc_model_off =
{
	// Turn off model/world interaction
	self.estate = ESTATE_OFF;				// Switch off entity
	self.state = STATE_OFF;					// Switch off animations
	misc_model_loopreset();					// Reset loop counter
	self.model = string_null;				// hide bmodel surface
	self.movetype = MOVETYPE_NONE;			// Create baseline
	self.solid = SOLID_NOT;
	self.nextthink = 0;
	// Remove the setup spawnflags, used only once
	self.spawnflags = self.spawnflags - (self.spawnflags & MISC_MDLSETUP);
};

//----------------------------------------------------------------------
float(float minrange, float maxrange, float checker) misc_model_CheckRange =
{
	local float retrange;
	
	// Obvious parameter errors
	if (minrange == maxrange) return minrange;
	if (maxrange < minrange) return maxrange;
	// Double check the FRAME is within the specified range
	if (checker < minrange) retrange = minrange;
	else if (checker > maxrange) retrange = maxrange;
	// No change, within range
	else retrange = checker;
	// Final_Final_Final result!
	return retrange;
};

//----------------------------------------------------------------------
float(float minrange, float maxrange) misc_model_RandomRange =
{
	local float fullrange, retrange;
	
	// Obvious parameter errors
	if (minrange == maxrange) return minrange;
	if (maxrange < minrange) return maxrange;
	// Create range first and then add to minimum
	fullrange = maxrange - minrange;
	retrange = minrange + (random() * fullrange);
	// Make sure no fractions or negative numbers
	retrange = rint(fabs(retrange));
	// Double check within the specified range
	if (retrange < minrange) retrange = minrange;
	else if (retrange > maxrange) retrange = maxrange;
	// Thats all folks!
	return retrange;
};

//----------------------------------------------------------------------
void() misc_model =
{
	// Is the model defined using the noise key?
	if (!self.mdl) {
		dprint("\b[MISCMDL]\b Missing model to load\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}

	// TRIGGER sound setup + volume (def=custom sound)
	if (self.sounds == 0) self.sounds = 5;
	trigger_bmodel_sounds();
	
	// TOGGLE sound setup
	if (self.locksounds == 1) {
		self.noise1 = "misc/laseron.wav";
		self.noise2 = "misc/laseroff.wav";
	}
	else if (self.locksounds == 2) {
		self.noise1 = "ambience/power_on.wav";
		self.noise2 = "ambience/power_off.wav";
	}
	if (self.noise1 != "") precache_sound(self.noise1);
	if (self.noise2 != "") precache_sound(self.noise2);
	
	precache_model (self.mdl);
	self.classtype = CT_MISCMODEL;
	self.classgroup = CG_MISCENT;
	self.solid = SOLID_NOT;				// No world interaction
	self.movetype = MOVETYPE_NONE;		// Static item, no movement
	self.oldorigin = self.origin;		// Store for later

	// Default entity states
	self.estate = ESTATE_OFF;
	// Change default model state (def=on)
	if (self.state == 0) self.state = STATE_ON;
	else self.state = STATE_OFF;
	
	// ---------------------------------------------------------
	// Check for any skin/frame values (Quoth compatibility)
	if (self.frame > 0) { self.pos1 = '0 0 0'; self.pos1_z = self.frame; }
	if (self.skin > 0) { self.pos2 = '0 0 0'; self.pos2_z = self.skin; }

	// Check for a mangle override (Quoth compatibility)
	if (!CheckZeroVector(self.mangle))
		self.angles = self.mangle;
	
	// Random Rotation : UP/DOWN angle or use the ideal_yaw key
	if (self.angles_y < 0 || self.ideal_yaw > 0) 
		self.angles_y = rint(random()*360);
	// Save angles (mangle not used)
	self.mangle = self.angles;

	// MAP/CODE HACK Terrible way to fix this map
	// If wrong engine then delete the misc_model detail)
	if (world.model == "maps/ad_sepulcher.bsp") { 
		// Running on DP engine?
		if (engine == ENG_DPEXT && ext_ftepart == FALSE)
		{ remove(self); return; }
		// Running on Fitz (QS/MarkV) engines?
		if (engine == ENG_FITZ) { remove(self); return; }
	}
	
	// Check for static entity option first
	if (self.spawnflags & ENT_SPNSTATIC) { 
		setmodel (self, self.mdl);
		// Exact frame/skin numbers (check for negatives)
		if (self.pos1_z < 0) self.frame = self.pos1_x;
		else self.frame = self.pos1_z;
		if (self.pos2_z < 0) self.frame = self.pos2_x;
		else self.skin = self.pos2_z;
		// Goodbye entity!
		makestatic(self);
		return;
	}

	// ---------------------------------------------------------
	// No animation loops defined
	self.aflag = FALSE;
	// Has a FRAME range been defined?
	if (self.pos1_x != self.pos1_y) {
		// ---------------------------------------------------------
		// Make sure the range is the right way around
		// X has to be the lowest number of the two (X/Y)
		if (self.pos1_x > self.pos1_y) {
			self.frame_box = self.pos1_x;
			self.pos1_x = self.pos1_y;
			self.pos1_y = self.frame_box;
		}
		// ---------------------------------------------------------
		// Static FRAME range AND random pick
		if (self.pos1_z == 0) {
			// Double check lower limit is not negative
			if (self.pos1_x < 0) self.pos1_x = 0;
			// Find random range number
			self.pos1_z = misc_model_RandomRange(self.pos1_x, self.pos1_y);
		}
		// ---------------------------------------------------------
		// Animated FRAME range
		else {
			// Always set this, only -1/0 are valid values
			self.pos1_z = NEGATIVE;
			self.aflag = TRUE;
			
			// Default is start at beginning of range
			if (self.framestart == 0) self.framestart = self.pos1_x;
			// Random starting position
			else if (self.framestart < 0)
				self.framestart = misc_model_RandomRange(self.pos1_x, self.pos1_y);
			// Exact starting position
			else self.framestart = misc_model_CheckRange(self.pos1_x, self.pos1_y, self.framestart);
		}
	}
	else {
		// If no exact FRAME bas specified, reset FRAME to default = 0
		if (self.pos1_z < 1) self.pos1 = '0 0 0';
	}
		
	// Has a SKIN range been defined?
	if (self.pos2_x != self.pos2_y) {
		// ---------------------------------------------------------
		// Make sure the range is the right way around
		// X has to be the lowest number of the two (X/Y)
		if (self.pos2_x > self.pos2_y) {
			self.frame_box = self.pos2_x;
			self.pos2_x = self.pos2_y;
			self.pos2_y = self.frame_box;
		}
		// ---------------------------------------------------------
		// Static SKIN range AND random pick
		if (self.pos2_z == 0) {
			// Double check lower limit is not negative
			if (self.pos2_x < 0) self.pos2_x = 0;
			// Find random range number + range checks
			self.pos2_z = misc_model_RandomRange(self.pos2_x, self.pos2_y);
		}
		// ---------------------------------------------------------
		// Animated SKIN range
		else {
			// Always set this, only -1/0 are valid values
			self.pos2_z = NEGATIVE;
			self.aflag = TRUE;

			// Default is start at beginning of range
			if (self.skinstart == 0) self.skinstart = self.pos2_x;
			// Random starting position
			else if (self.skinstart < 0)
				self.skinstart = misc_model_RandomRange(self.pos2_x, self.pos2_y);
			// Exact starting position
			else self.skinstart = misc_model_CheckRange(self.pos2_x, self.pos2_y, self.skinstart);
		}
	}
	else {
		// If no exact SKIN bas specified, reset SKIN to default = 0
		if (self.pos2_z < 1) self.pos2 = '0 0 0';
	}

	// Any rotation angle setup?
	if (!CheckZeroVector(self.rotateangles)) self.aflag = TRUE;
	
	// Setup DEFAULT animation direction, speed and status
	if (self.aflag == TRUE) {
		// Setup default animation speed (def=0.1)
		if (self.speed < 0.05) self.speed = 0.1;
		// Check for animation diection errors
		if (self.lip <= -2) self.lip = -2;			// Randomly pick
		else if (self.lip >= 0) self.lip = TRUE;	// Def = forward (1)
		// Randomly pick direction
		if (self.lip == -2) {
			if (random() < 0.5) self.lip = NEGATIVE;
			else self.lip = TRUE;
		}
		// Special first time run setup for frame/skin/rotate loops
		self.spawnflags = self.spawnflags | MISC_MDLSETUP;
		// Check animation looping types are valid
		// 0=Constant, 1+=Range+Stop, -1=Toggle, -2=Trigger+Wait
		if (self.frameloop < -2) self.frameloop = MMLOOP_CONSTANT;
		else self.frameloop = rint(self.frameloop);
		if (self.skinloop < -2) self.skinloop = MMLOOP_CONSTANT;
		else self.skinloop = rint(self.skinloop);
		if (self.rotateloop < -2) self.rotateloop = MMLOOP_CONSTANT;
		else self.rotateloop = rint(self.rotateloop);
		
		// Setup first frame/skin position
		self.frame = self.framestart;
		self.skin = self.skinstart;
	}
	
	// Check for any path_corner movement?
	if (self.target != "") {
		// Setup turning/move speed defaults
		if (self.yaw_speed < 1) self.yaw_speed = 15;
		if (self.movespeed < 1) self.movespeed = 50;
		// cannot start moving on first frame, entity list not setup
		// Wait 1 frame before searching for path_corner target
		self.delay = 0.1;
		// Setup default animation speed (def=0.1)
		if (self.speed < 0.05) self.speed = 0.1;
		// Cannot have movement + static for path_corner targets
		self.spawnflags = self.spawnflags - (self.spawnflags & MISC_MOVEMENT);
		self.spawnflags = self.spawnflags - (self.spawnflags & ENT_SPNSTATIC);
	}
	// no movement checks
	else self.yaw_speed = 0;
	
	// Cannot have movement AND static at the same time!
	if (self.spawnflags & MISC_MOVEMENT) {
		self.spawnflags = self.spawnflags - (self.spawnflags & ENT_SPNSTATIC);
		// make sure any func movers have spawned beforehand
		if (self.delay <= 0) self.delay = 0.2;
	}
	
	// Check for drop to floor functionality
	if (self.spawnflags & MISC_DROPTOFLOOR) {
		// Turn misc model into an item so it can fall down
		self.movetype = MOVETYPE_TOSS;
		self.solid = SOLID_BBOX;
		setmodel(self, self.mdl);
		// Check for any bounding box override (check min only)
		if (CheckZeroVector(self.bbmins)) {
			// Don't use model default, its usually broken or wrong
			// Use a zero size so the model origin drops perfectly
			setsize (self, VEC_ORIGIN, VEC_ORIGIN);
		}
		// Override defaults with custom sizes
		else setsize (self, self.bbmins , self.bbmaxs);
		// Make sure no onspawn velocity
		self.velocity = '0 0 0';
		// Default surface normal is flat so check for default modifier
		if (CheckZeroVector(self.facevector)) self.facevector = '-90 0 0';
		// Trace a line downward to get the surface normal
		traceline(self.origin, self.origin-'0 0 1024', FALSE, self);

		// Drop the model to the ground
		self.origin_z = self.origin_z + 6;
		droptofloor();
		// Save original for later on/off functions
		self.oldorigin = self.origin;
		// Normal plane facing angle required?
		if (self.normalangle > 0) {
			// trace_plane_normal is always facing outward from ground surface
			// If turned into a model angle at this point it would be facing up!
			// Convert the trace plane normal into a facing angle
			self.finalangle = vectoangles(trace_plane_normal);
			// Take previous Yaw angle (could be random rotation)
			// Add 180 because v_up is opposite to regular angle stuff
			self.finalangle_z = anglemod(self.angles_y+180);
			// Flip X axis because its Quake C! ;)
			self.finalangle_x = -self.finalangle_x;
			// Turn into a v_forward/v_right/r_up vector set
			// v_forward is the original trace_plane_normal angle upward
			// v_right/v_up are on the norm surface, but 90 degrees apart
			makevectors(self.finalangle);
			self.angles = vectoangles(v_up);
		}
	}
	
	// Setup any ALPHA fade in functionality
	if (self.alphastart >= 1) {
		self.attachment = spawn();
		self.attachment.owner = self;
		self.attachment.origin = self.origin;
		// Starting value (can't be zero)
		self.alpha = 0.01;
	}
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	if (self.aflag == TRUE) self.estate_use = misc_model_use;
	self.estate_on = misc_model_on;
	self.estate_off = misc_model_off;
	if (self.spawnflags & (MISC_STARTOFF | ENT_STARTOFF)) entity_state_off();
	else entity_state_on();
};

//----------------------------------------------------------------------
// Allows GTK editors to work with Q1 assets easier
void() misc_gtkmodel = { misc_model(); };
// Quoth re-direct old custom model system to AD
void() mapobject_custom = { self.mdl = self.model; misc_model(); };
