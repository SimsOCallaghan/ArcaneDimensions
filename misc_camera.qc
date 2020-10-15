//======================================================================
// Cinematic Camera System
//======================================================================
// Camera spawnflags
float CINECAM_FUNC_PLAYER = 1;	// Setup fake player model
float CINECAM_FUNC_SKIPABLE = 2;// Allow cinematic to be skipable
float CINECAM_FUNC_FADEOUT = 4;	// Fade OUT pevious camera
float CINECAM_FUNC_FADEIN = 8;	// Fade IN next camera
float CINECAM_FUNC_FIXEDANGLE = 16;	// First camera defines fixed angle
float CINECAM_FUNC_ENDCAMERA = 32;	// Fade in/out only, no org/ang

// v_cshift min/max values
float CINECAM_MINSHIFT = 0;		// Minimun value for density
float CINECAM_MAXSHIFT = 255;	// Maximm value for density 
float CINECAM_FADEUP = 1;		// Fading directions
float CINECAM_FADEDOWN = 2;

// Camera Controller loop/tick speed
float CINECAM_CONTIME = 0.05;	// Controller tick rate (speed)

// Camera System states
float CINECAM_OFF = 0;			// Waiting for a camera

float CINECAM_STARTUP = 4;		// Save client info and start sequence
float CINECAM_FADEOUT = 6;		// Start fading out current view
float CINECAM_NEXTCAM = 8;		// Switch camera and focus
float CINECAM_FADEIN = 10;		// Start fading in current camera

float CINECAM_MESSAGE = 14;		// Show messages and setup timers
float CINECAM_WAIT = 16;		// Waiting player input
float CINECAM_EXIT = 20;		// Back to player position
float CINECAM_FADE = 25;		// Fade in or out camera

// Camera Sequence number
float CINECAM_SEQ_FIRST = 1;	// Starting with the player camera
float CINECAM_SEQ_ACTIVE = 2;	// Camera sequence now active
float CINECAM_SEQ_LAST = 4;		// Going back to player camera

// Camera Skip conditions
float CINECAM_SKIP_OFF = 0;		// No skip function available
float CINECAM_SKIP_ACTIVE = 1;	// Waiting for buttons (fire/jump)
float CINECAM_SKIP_DONE = 2;	// Cinematic finished, exit Asasp

float CINECAM_FIXANGLE_OFF = 0;		// Always reset camera angle
float CINECAM_FIXANGLE_ACTIVE = 1;	// Read first angle only
float CINECAM_FIXANGLE_DONE = 2;	// First angle read and done

/*======================================================================
Cinematic camera control functions

camera_controller_cshift	- Updates console with new cshift parameters
camera_tracking_finish		- Finish camera tracking movement 
camera_controller_think		- Main cinematic controller loop
camera_controller_setup		- Setup controller, movement and fakeplay ents
misc_camera_use				- Trigger function for camera's
misc_camera_colcheck		- Way to validate RGB background colours
misc_camera					- Spawning function for camera system

======================================================================*/
void(entity targ, vector cs_col, float cs_den) camera_controller_cshift = 
{
	stuffcmd(targ, "v_cshift ");
	stuffcmd(targ, ftos(rint(cs_col_x))); stuffcmd(targ, " ");
	stuffcmd(targ, ftos(rint(cs_col_y))); stuffcmd(targ, " ");
	stuffcmd(targ, ftos(rint(cs_col_z))); stuffcmd(targ, " ");
	stuffcmd(targ, ftos(rint(cs_den))); stuffcmd(targ, "\n");	
};

//----------------------------------------------------------------------
void() camera_tracking_finish =
{
	self.attack_finished = 0;
	self.velocity = '0 0 0';
};

//----------------------------------------------------------------------
void(entity targ) camera_reset_buttons = 
{ 
	if (targ.flags & FL_CLIENT) {
		targ.button0 = targ.button1 = targ.button2 = 0;
	}
};

//----------------------------------------------------------------------
float(entity targ) camera_check_buttons =
{
	// Check client + buttons
	if (targ.flags & FL_CLIENT) {
		if (targ.button0 || targ.button1 || targ.button2) return TRUE;
	}
	// Default
	return FALSE;
};

//----------------------------------------------------------------------
void(entity targ) camera_check_skip =
{
	// Is cinematic skip function enabled?
	if (cam_exit == CINECAM_SKIP_ACTIVE) {
		// Check for exit condition buttons (fire/jump)
		if (camera_check_buttons(targ)) {
			// Don't need buttons anymore
			camera_reset_buttons(targ);
			// Start to exit cinematic ASAP
			cam_exit = CINECAM_SKIP_DONE;
		}
	}
};

//----------------------------------------------------------------------
float(float cam_angle1, float cam_angle2) camera_check_anglezero =
{
	// Smallest / Largest camera angle
	local float cam_anglesmall, cam_anglelarge;
	// Camera small/large angle distance and wrap distance
	local float cam_angledist, cam_anglewrap;
	
	// Guard against interpolating across the 360<->0 discontinuity
	cam_anglelarge = mathlib_max(cam_angle1, cam_angle2);
	cam_anglesmall = mathlib_min(cam_angle1, cam_angle2);

	// This is the distance between the yaws if we don't cross 360.
	cam_angledist = cam_anglelarge - cam_anglesmall;
	// This is the distance if we do cross 360. i.e. "359" and "1" would
	// have an angle_wrap of "2" and direct_dist of "358".
	cam_anglewrap = (360 - cam_anglelarge) + cam_anglesmall;

	// Is it shorter to cross the 360<->0 boundary?
	if (cam_anglewrap < cam_angledist) return TRUE;
	else return FALSE;
};

//----------------------------------------------------------------------
float(float baxis_start, float baxis_control, float baxis_end, float baxis_time) bezier_axis =
{
	local float baxis_1, baxis_2, baxis_3, baxis_return;
	
	// Work out bezier curve position 
	baxis_1 = ((1 - baxis_time) * (1 - baxis_time)) * baxis_start;
	baxis_2 = ((2 * baxis_time) * (1 - baxis_time)) * baxis_control;
	baxis_3 = (baxis_time * baxis_time) * baxis_end;
	// Add up parts and return result
	baxis_return = baxis_1 + baxis_2 + baxis_3;
	return baxis_return;
};

//----------------------------------------------------------------------
vector(vector bez_start, vector bez_control, vector bez_end, float bez_timemax, float bez_timeleft) bezier_curve =
{
	local vector bez_result;
	local float bez_time;
	
	// Normalize (0-1) the time value 
	bez_time = bez_timeleft / bez_timemax;
	// Make sure time is within normalized range (0-1)
	if (bez_time <= 0) bez_time = 0;
	if (bez_time >= 1) bez_time = 1;

	// Work out each vector (XYZ) axis
	bez_result_x = bezier_axis(bez_start_x, bez_control_x, bez_end_x, bez_time);
	bez_result_y = bezier_axis(bez_start_y, bez_control_y, bez_end_y, bez_time);
	bez_result_z = bezier_axis(bez_start_z, bez_control_z, bez_end_z, bez_time);
	
	return bez_result;
};

//----------------------------------------------------------------------
// Bezier curve debug system (developer = 1 only)
// Display the curve with yellow diamonds
//----------------------------------------------------------------------
void() misc_camera_bezier_debug =
{
	// Block debug info regardless (help reduce ents)
	if (self.nodebuginfo == TRUE) return;
	
	// Find the bezier curve CONTROL point
	self.attachment2 = find(world, targetname, self.controltarget);
	// Find the bezier curve END point
	self.attachment3 = find(world, targetname, self.target);

	// Display debug markers for start/control/end locations
	spawn_marker(self.origin, SPNMARK_RED);
	spawn_marker(self.attachment2.origin, SPNMARK_GREEN);
	spawn_marker(self.attachment3.origin, SPNMARK_RED);
	
	// Loop through 10 points on each bezier curve
	self.cnt = 0.1;
	while (self.cnt < 1) {
		// Work out bezier curve vector position
		self.finalangle = bezier_curve(self.origin, self.attachment2.origin, self.attachment3.origin, 1, self.cnt);
		// Spawn debug marker (yellow is wrong colour!)
		spawn_marker(self.finalangle, SPNMARK_YELLOW);
		self.cnt = self.cnt + 0.1;
	}
};

//======================================================================
// Main loop for cinematic controller (all states)
//======================================================================
void() camera_controller_think =
{
	self.think = camera_controller_think;
	self.nextthink = time + CINECAM_CONTIME;

	//---------------------------------------------------------------------
	// Check first if camera/client are setup
	//---------------------------------------------------------------------
	if (cam_active == CINECAM_SETUP) {
		// Check there is a camera to focus on
		if (cam_focus.classtype != CT_MISCCAM) cam_active = CINECAM_OFF;
		else if (!(cam_client.flags & FL_CLIENT)) cam_active = CINECAM_OFF;
		else cam_active = CINECAM_STARTUP;
	}
	
	//---------------------------------------------------------------------
	// Save player details and start cinematic system
	//---------------------------------------------------------------------
	if (cam_active == CINECAM_STARTUP) {
		// Cinematic time!
		cinematic_running = TRUE;
		cam_locked = FALSE;		// No angle update
		cam_movement = FALSE;	// No movement tracking
		cam_fakeplay = FALSE;	// The invisible man
		cam_angle = '0 0 0';	// Reset angles
		cam_lastanglevalid = FALSE;	// Reset angle smoothing
		
		// Reset player location markers
		self.attachment = self.attachment2 = world;
		
		// Check for fake player model on first camera in chain
		if (cam_focus.spawnflags & CINECAM_FUNC_PLAYER) {
			// fake player model active
			cam_fakeplay = TRUE;
			// Check for special player location entity
			if (cam_focus.modeltarget != "") {
				self.attachment = find(world, targetname, cam_focus.modeltarget);
				// Found the target entity?
				if (self.attachment) {
					// Spawn a dev marker (can be blocked)
					if (developer > 0 && !self.nodebuginfo) 
						spawn_marker(self.attachment.origin, SPNMARK_RED);
					// Info_teleport_destination are fined tuned for trig_teleport
					if (self.attachment.classtype == CT_MISCTELEPORT) {
						self.attachment.origin = self.attachment.origin - '0 0 27';
						self.attachment.angles = self.attachment.mangle;
					}
				}
			}
		}

		// Check for any special returning position for the player
		if (cam_focus.returntarget != "") {
			self.attachment2 = find(world, targetname, cam_focus.returntarget);
			// Found the target entity?
			if (self.attachment2) {
				// Spawn a dev marker (can be blocked)
				if (developer > 0 && !self.nodebuginfo) 
					spawn_marker(self.attachment2.origin, SPNMARK_RED);
				// Info_teleport_destination are fined tuned for trig_teleport
				if (self.attachment2.classtype == CT_MISCTELEPORT) {
					self.attachment2.origin = self.attachment2.origin - '0 0 27';
					self.attachment2.angles = self.attachment2.mangle;
				}
			}
		}
		
		// Check for any exit/finished cinematic trigger(s)
		if (cam_focus.deathtarget == "") self.deathtarget = "";
		else self.deathtarget = cam_focus.deathtarget;

		// Check for cinematic skip functionality
		if (cam_focus.spawnflags & CINECAM_FUNC_SKIPABLE)
			cam_exit = CINECAM_SKIP_ACTIVE;		// Chck for button inputs
		else cam_exit = CINECAM_SKIP_OFF;		// No skip function

		// Check for constant fixed angles on all cameras
		if (cam_focus.spawnflags & CINECAM_FUNC_FIXEDANGLE) 
			cam_fixangle = CINECAM_FIXANGLE_ACTIVE;	// Read first camera
		else cam_fixangle = CINECAM_FIXANGLE_OFF;	// Reset everytime

		// Save the current HUD settings for later
		cam_hudsize = cvar("viewsize");
		cam_crosshair = cvar("crosshair");
		
		// Save player parameters
		self.pos4 = cam_client.origin;			// Model/entity location
		self.pos5 = cam_client.view_ofs;		// Origin offset
		self.pos6 = cam_client.velocity;		// Movement (Not used)
		self.finalangle = cam_client.angles;	// Model angle
		self.finaldest = cam_client.v_angle;	// Viewing angle
		self.weapon = cam_client.weapon;		// Current weapon
		self.currentammo = cam_client.currentammo;
		self.weaponmodel = cam_client.weaponmodel;
		self.weaponframe = cam_client.weaponframe;

		// Stop player falling/interacting with world
		cam_client.takedamage = DAMAGE_NO;
		cam_client.solid = SOLID_NOT;
		cam_client.movetype = MOVETYPE_NONE;
		setsize(cam_client, VEC_ORIGIN, VEC_ORIGIN);
		// Stop any further movement (will translate to cinematics)
		cam_client.velocity = cam_client.avelocity = '0 0 0';
		
		// Fade out of first camera (player)
		cam_sequence = CINECAM_SEQ_FIRST;
		// Skip the fade out from player camera for spawning players
		if (cam_startup) cam_active = CINECAM_NEXTCAM;
		// Start with fading out current player camera
		else cam_active = CINECAM_FADEOUT;
	}

	//---------------------------------------------------------------------
	// Sort out wait timers, centerprint messages and sounds
	//---------------------------------------------------------------------
	if (cam_active == CINECAM_MESSAGE) {
		// Is cinematic skip done?
		if (cam_exit != CINECAM_SKIP_DONE) {
			// Check for any wait parameters (-1=wait for trigger)
			if (cam_focus.wait < 0) self.attack_finished = -1;
			else if (cam_focus.wait == 0) self.attack_finished = 0;
			else self.attack_finished = time + cam_focus.wait;
			
			// Center print message to display?
			if (cam_focus.message) {
				centerprint(cam_client, cam_focus.message);
				// Default talk sound (using sounds entity key)
				sound (cam_client, CHAN_VOICE, cam_focus.noise, 1, ATTN_NORM);
			}
		}
		// Wait for player input or timer
		self.pain_finished = FALSE;
		cam_active = CINECAM_WAIT;
	}

	//---------------------------------------------------------------------
	// Wait for timer or player input
	//---------------------------------------------------------------------
	if (cam_active == CINECAM_WAIT) {
		// Is cinematic skip in progress?
		if (cam_exit == CINECAM_SKIP_DONE) {
			// Exit as quick as possible (no fading)
			cam_active = CINECAM_NEXTCAM;
			cam_sequence = CINECAM_SEQ_LAST;
		}
		else {
			// Waiting for a key press (jump/fire/use)
			// This has to be done before camera_check_skip
			// Otherwise the button values are reset
			if (self.attack_finished == -1) {
				// Any buttons pressed? (fire/jump)
				if (camera_check_buttons(cam_client)) {
					camera_reset_buttons(cam_client);
					self.pain_finished = TRUE;
				}
			}
			// Has the wait timer expired?
			else if (self.attack_finished < time) self.pain_finished = TRUE;
			// Check for skip functionality
			else camera_check_skip(cam_client);
		
			// Time to exit current camera?
			if (self.pain_finished) {
				// fade out current camera view angle
				cam_active = CINECAM_FADEOUT;
				self.pain_finished = FALSE;
				
				// Is there another camera?
				if (cam_focus.target == "") {
					// End of sequence, back to player
					cam_sequence = CINECAM_SEQ_LAST;
				}
				else {
					// search for target camera
					self.enemy = find(world, targetname, cam_focus.target);
					// Found a misc camera?
					if (self.enemy.classtype == CT_MISCCAM) {
						self.enemy.movetarget3 = cam_focus;
						cam_focus = self.enemy;
					}
					// Next target is not a camera!?!
					else cam_sequence = CINECAM_SEQ_LAST;
				}
			}
		}
	}

	//---------------------------------------------------------------------
	// Fade OUT camera (player if first camera)
	//---------------------------------------------------------------------
	if (cam_active == CINECAM_FADEOUT) {
		// Check if fade out is active (spawnflags)
		if (cam_focus.spawnflags & CINECAM_FUNC_FADEOUT) {
			// Start fading player view out to solid colour
			// Work out cshift density steps
			self.lip = CINECAM_MAXSHIFT / (cam_focus.waitmin / CINECAM_CONTIME);
			cam_colour = cam_focus.pos1;		// Fade In background
			self.count = CINECAM_MINSHIFT;		// Initial density
			self.cnt = CINECAM_FADEUP;			// Fade direction
			self.state = CINECAM_NEXTCAM;		// Next function
			cam_active = CINECAM_FADE;			// Start fade process
		}
		else cam_active = CINECAM_NEXTCAM;
	}
	
	//---------------------------------------------------------------------
	// Switch to next camera (player if last camera)
	//---------------------------------------------------------------------
	if (cam_active == CINECAM_NEXTCAM) {
		// If fading IN active, update background colour before switch
		if (cam_focus.spawnflags & CINECAM_FUNC_FADEIN)
			camera_controller_cshift(cam_client, cam_focus.pos1, CINECAM_MAXSHIFT);

		// Check for end of camera chain functionality
		if (cam_focus.spawnflags & CINECAM_FUNC_ENDCAMERA)
			cam_sequence = CINECAM_SEQ_LAST;
		
		// Check for last camera (back to player)
		if (cam_sequence == CINECAM_SEQ_LAST) {
			// Restore hud (saved in startup section)
			cvar_set("viewsize", ftos(cam_hudsize));
			cvar_set("crosshair", ftos(cam_crosshair));
			
			// Hide fake player entity
			cam_player.state = FALSE;
			setmodel(cam_player, MODEL_EMPTY);
			setsize(cam_player, VEC_ORIGIN, VEC_ORIGIN);
			cam_player.frame = 0;

			// Restore player core parameters
			setmodel (cam_client, MODEL_PLAYER);
			modelindex_player = cam_client.modelindex;
			setsize (cam_client, cam_client.bbmins, cam_client.bbmaxs);
			cam_client.solid = SOLID_SLIDEBOX;
			cam_client.movetype = MOVETYPE_WALK;
		
			// Check for return location entity
			if (self.attachment2) {
				// Read target entity (often has angle key)
				self.dest2 = self.attachment2.origin;
				self.dest3 = self.attachment2.angles;
			}
			else {
				// read origin/angles from player
				self.dest2 = self.pos4;
				self.dest3 = self.finaldest;
			}

			// Restore player origin/ofset parameters
			setorigin(cam_client, self.dest2);
			cam_client.view_ofs = self.pos5;
			// Do not restore the player with velocity as it can lead
			// to some unexpected deaths and chance of being stuck
			// Better to zero velocity so that the player can adjust
			cam_client.velocity = cam_client.avelocity = '0 0 0';
			// Restore weapon/ammo HUD stuff
			cam_client.weapon = self.weapon;
			cam_client.currentammo = self.currentammo;
			cam_client.weaponmodel = self.weaponmodel;
			cam_client.weaponframe = self.weaponframe;

			// Update player angles
			cam_angle = self.dest3;
			cam_client.angles = cam_client.v_angle = cam_angle;
			cam_client.angles_z = 0;	// No drunk camera angles
			cam_client.fixangle = TRUE;
			
			// Let the player move around before the fade has finished
			// Otherwise it will feel like the controls are broken
			cam_locked = FALSE;
			cam_movement = FALSE;
			cam_bezier = FALSE;
		}
		else {
			// Switch to Next cinematic camera
			setorigin(cam_client, cam_focus.origin);
			cam_client.view_ofs = cam_focus.view_ofs;

			// Setup Camera angle blend fraction
			if (cam_focus.angleblend <= 0 || cam_focus.angleblend >= 1) 
				cam_focus.angleblend = CINECAM_ANGLEBLEND;
			
			// Lock player viewing angle (done via PlayerPreThink)
			// Stops the player moving the cursor/head around
			cam_locked = TRUE;
			
			// Movement of Camera (Bezier)
			if (cam_focus.controltarget != "") {
				// search for Control Point entity (info_target)
				self.enemy = find(world, targetname, cam_focus.controltarget);
				// Need to know next camera location for bezier maths
				self.oldenemy = find(world, targetname, cam_focus.target);
				
				// Found a control AND next camera entity?
				// Must find both of these because of the math formula
				if (self.enemy && self.oldenemy) {
					// Show movement tracking entity
					if (developer > 0) {
						// Use the yellow diamond model
						setmodel(cam_track, MODEL_BROKEN);
						setsize(cam_track, VEC_ORIGIN, VEC_ORIGIN);
					}

					// Reset movement origin to starting position
					cam_track.origin = cam_focus.origin;
					
					// Is the time or movement is too small?
					if (cam_focus.waitmin3 <= 0.1 || self.enemy.origin == cam_focus.origin) {
						// Move directly to movement location
						setorigin(cam_client, cam_focus.origin);
						cam_movement = FALSE;
					}
					else {
						// Setup camera tracking entity to start at client
						setorigin(cam_track, cam_focus.origin);
						cam_track.angles = cam_focus.angles;
						// Keep track of bezier curve start/control/end
						cam_track.pos4 = cam_focus.origin;
						cam_track.pos5 = self.enemy.origin;
						cam_track.pos6 = self.oldenemy.origin;
						cam_track.wait = cam_focus.waitmin3;
						cam_track.velocity = '0 0 0';
						
						// The exact position of where the camera should be on
						// the bezier curve can be calculated. Just need to move
						// the origin instead of relying on velocity movement
						cam_track.attack_finished = time + cam_track.wait;
						cam_track.think = camera_tracking_finish;
						cam_track.nextthink = time + cam_track.wait;
						
						// Allow for updates (done via PlayerPreThink)
						cam_movement = TRUE;
						cam_bezier = TRUE;
					}
				}
			}
			// Movement of Camera (Linear)
			else if (cam_focus.sighttarget != "") {
				// search for target entity (info_target)
				self.enemy = find(world, targetname, cam_focus.sighttarget);
				
				// Found a target?
				if (self.enemy) {
					// Show movement tracking entity
					if (developer > 0) {
						// Use the yellow diamond model
						setmodel(cam_track, MODEL_BROKEN);
						setsize(cam_track, VEC_ORIGIN, VEC_ORIGIN);
					}

					// Is the time or movement is too small?
					if (cam_focus.waitmin3 <= 0.1 || self.enemy.origin == cam_focus.origin) {
						// Move directly to movement location
						setorigin(cam_client, cam_focus.origin);
						cam_movement = FALSE;
					}
					else {
						// Setup camera tracking entity to start at client
						setorigin(cam_track, cam_focus.origin);
						cam_track.angles = cam_focus.angles;
						// Keep track of direction target entity
						cam_track.enemy = self.enemy;
						
						// Find out vector difference between two points
						cam_track.pos1 = cam_track.enemy.origin - cam_focus.origin;
						// velocity = vector difference * traveltime (waitmin3)
						cam_track.velocity = cam_track.pos1 * (1 / cam_focus.waitmin3);
						
						// Setup switch off functionality
						// The camera tracking entity is set to noclip movetype
						// which means the velocity needs to be stopped otherwise
						// the entity will just keep moving forward
						cam_track.attack_finished = time + cam_focus.waitmin3;
						cam_track.think = camera_tracking_finish;
						cam_track.nextthink = time + cam_focus.waitmin3;
						
						// Allow for updates (done via PlayerPreThink)
						cam_movement = TRUE;
						cam_bezier = FALSE;
					}
				}
			}
			
			// Has the camera angletarget been setup?
			if (cam_fixangle != CINECAM_FIXANGLE_DONE) {
				// Only update angles once per camera chain
				if (cam_fixangle == CINECAM_FIXANGLE_ACTIVE)
					cam_fixangle = CINECAM_FIXANGLE_DONE;
				
				// Check for any special angle target setup?
				if (cam_focus.angletarget != "") {
					// Find angle target of camera and return results
					// movetarget = angletarget entity
					// dest1 = angletarget.origin
					// movedir = vector movement direction
					TargetMovedir(cam_focus, TRUE);
					// Angle target found?
					if (self.movetarget) {
						// Convert direction vector to angles
						cam_focus.angles = vectoangles(self.movedir);
						// Spawn a debug arrow if devmode (only once)
						if (!cam_focus.cam_debugarrow && !self.nodebuginfo) {
							spawn_arrow(cam_focus.origin, cam_focus.angles, 3);
							cam_focus.cam_debugarrow = TRUE;
						}
						// Got to reverse the pitch angle because 
						// v_angle is upside down (special carmack code)
						cam_focus.angles_x = -cam_focus.angles_x;
					}
					// Cannot have a focalpoint if no angletarget
					else cam_focus.focalpoint = 0;

				}
				
				// Update camera from existing angles key
				cam_angle = cam_focus.angles;
			}
			
			// First camera? Hide player and HUD
			if (cam_sequence == CINECAM_SEQ_FIRST) {
				cam_sequence = CINECAM_SEQ_ACTIVE;	// Move forward in seq
				cvar_set("viewsize", "120");		// Hide HUD
				cvar_set("crosshair", "0");			// No crosshair
				// This is SUPER important, the entity has to have a model!
				// If this is blank, the engine will not update the entity
				// when moving around by the cinematic system
				setmodel(cam_client, MODEL_EMPTY);	// Empty model
				cam_client.frame = 0;				// reset frame
				cam_client.weaponmodel = "";		// Remove weapon
				cam_client.weaponframe = 0;
				
				// Create fake player model for cinematics
				if (cam_fakeplay) {
					// Check for fake player location
					if (self.attachment) {
						// Read target entity (often has angle key)
						self.dest2 = self.attachment.origin;
						self.dest3 = self.attachment.angles;
					}
					else {
						// read origin/angles from player
						self.dest2 = self.pos4;
						self.dest3 = self.finalangle;
					}
					
					cam_player.solid = SOLID_NOT;
					cam_player.movetype = MOVETYPE_NONE;
					setorigin(cam_player, self.dest2);
					setmodel(cam_player, MODEL_PLAYER);
					setsize(cam_player, VEC_ORIGIN, VEC_ORIGIN);
					cam_player.angles = self.dest3;
					cam_player.fixangle = TRUE;
					// Setup animation loop
					cam_player.state = TRUE;
					cam_player.walkframe = cam_player.frame = 12;
					cam_player.think = cam_player.th_altstand;
					cam_player.nextthink = time + 0.1;
				}
			}
		}
		
		// Check for any trigger events when viewing the camera
		// The screen can be solid background colour at this point
		// Anything could be spawned and would not be seen!
		// If the mapper wants stuff to trigger once, its best to
		// use wait = -1 on trigger_relays instead.
		//
		// Must use cam_seq check because can have single cam setup
		// Otherwise the triggers will be fired twice (camera exit)
		//
		if (cam_sequence != CINECAM_SEQ_LAST && cam_focus.target2 != "")
			trigger_strs(cam_focus.target2, cam_client);
		
		// Fade IN function
		cam_active = CINECAM_FADEIN;
	}
		
	//---------------------------------------------------------------------
	// Fade IN camera (player if last camera)
	//---------------------------------------------------------------------
	if (cam_active == CINECAM_FADEIN) {
		// Check if fade IN is active (spawnflags)
		if (cam_focus.spawnflags & CINECAM_FUNC_FADEIN) {
			// Start fading player view out to solid colour
			// Work out cshift density steps
			self.lip = CINECAM_MAXSHIFT / (cam_focus.waitmin2 / CINECAM_CONTIME);
			cam_colour = cam_focus.pos2;	// Fade In background
			self.count = CINECAM_MAXSHIFT;	// Initial density
			self.cnt = CINECAM_FADEDOWN;	// Fade direction
			// Check for exit condition from cinematic system
			if (cam_sequence == CINECAM_SEQ_LAST) self.state = CINECAM_EXIT;
			else self.state = CINECAM_MESSAGE;	// Next function
			cam_active = CINECAM_FADE;		// Start fade process
		}
		// Skip over fade IN
		else {
			// Reset cshift, otherwise screen could be background colour
			camera_controller_cshift(cam_client, cam_focus.pos2, CINECAM_MINSHIFT);
			
			// Last camera in sequence?
			if (cam_sequence == CINECAM_SEQ_LAST) cam_active = CINECAM_EXIT; 
			else cam_active = CINECAM_MESSAGE;
		}
	}

	//---------------------------------------------------------------------
	// Exit and back to previous player position
	//---------------------------------------------------------------------
	if (cam_active == CINECAM_EXIT) {
		// Let player be damaged again
		cam_client.takedamage = DAMAGE_AIM;
		// Clear keys so no esc/jump/shoot functions are triggered
		camera_reset_buttons(cam_client);
		// Make sure no weapon frame for 0.1s after cinematic
		cam_client.attack_finished = time + 0.1;
		// Restore air timer (>3s viewing camera and will get gasp sounds)
		cam_client.air_finished = time + WATER_AIR;
		// Remove onground flag to make sure engine resets properly
		cam_client.flags = cam_client.flags - (cam_client.flags & FL_ONGROUND);
		// Finally switch off cinematic system
		cinematic_running = FALSE;
		cam_active = CINECAM_OFF;
		
		// Check for any exit/finished cinematic triggers
		if (self.deathtarget != "")
			trigger_strs(self.deathtarget, cam_client);

		// Make sure player animation restarts
		cam_client.think = player_stand1;
		cam_client.nextthink = time + 0.1;
	}
	
	//---------------------------------------------------------------------
	// Main fade in/out loop for active camera
	//---------------------------------------------------------------------
	if (cam_active == CINECAM_FADE) {
		// Check for skip function
		camera_check_skip(cam_client);
		
		// Is cinematic skip done?
		if (cam_exit == CINECAM_SKIP_DONE) {
			// Setup max/min values to trigger end of fade
			if (self.cnt == CINECAM_FADEUP) self.count = CINECAM_MAXSHIFT;
			else self.count = CINECAM_MINSHIFT;
		}
		// Increase/Decrease the screen density
		if (self.cnt == CINECAM_FADEUP) self.count = self.count + self.lip;
		else self.count = self.count - self.lip;
		
		// Check for min/max values (exit condition)
		if (self.count >= CINECAM_MAXSHIFT) {
			self.count = CINECAM_MAXSHIFT;
			cam_active = self.state;
		}
		else if (self.count <= CINECAM_MINSHIFT) {
			self.count = CINECAM_MINSHIFT;
			cam_active = self.state;
		}

		// Update v_cshift
		camera_controller_cshift(cam_client, cam_colour, self.count);
	}
};

//======================================================================
// When the fake player is displayed via the camera system
// This function keeps the model animated like the real player
//----------------------------------------------------------------------
void() camera_player_animate =
{
	// Stop animating if disabled
	if (!self.state) return;
	self.walkframe = self.walkframe + 1;
	if (self.walkframe > 16) self.walkframe = 12;
	self.frame = self.walkframe;
	self.think = camera_player_animate;
	self.nextthink = time + 0.1;
};

//----------------------------------------------------------------------
// Check if the camera controller entity is setup and running
//----------------------------------------------------------------------
void() camera_controller_setup = 
{
	// Does controller exist?
	if (!cam_control) {
		// Default state is off
		cam_active = CINECAM_OFF;
		
		// The Controller
		cam_control = spawn();					// Create an entity
		cam_control.owner = self;				// Link back to client
		cam_control.classtype = CT_CONTROL;
		cam_control.solid = SOLID_NOT;			// No world interaction
		cam_control.movetype = MOVETYPE_NONE;	// Static item, no movement
		setorigin(cam_control, '0 0 0');
		setmodel(cam_control, MODEL_EMPTY);
		setsize(cam_control, VEC_ORIGIN, VEC_ORIGIN);

		// Setup Fake Player Model
		// The player entity is moved around between camera's
		// For cinematics that require the player this placeholder
		// entity will create the illusion of the player
		cam_player = spawn();
		cam_player.state = FALSE;
		cam_player.solid = SOLID_NOT;
		cam_player.movetype = MOVETYPE_NONE;
		setorigin(cam_player, cam_control.origin);
		setmodel(cam_player, MODEL_EMPTY);
		setsize(cam_player, VEC_ORIGIN, VEC_ORIGIN);
		cam_player.angles = '0 0 0';
		cam_player.view_ofs = '0 0 0';
		cam_player.th_altstand = camera_player_animate;

		// Setup Camera Tracking entity
		// To prevent the player moving the camera while the cinematic
		// is active, a simple entity does the camera movement and
		// the player entity mirrors this origin instead
		cam_track = spawn();
		cam_track.owner = cam_control;
		cam_track.classtype = CT_CONTROL;
		cam_track.solid = SOLID_NOT;
		cam_track.movetype = MOVETYPE_FLY;
		setorigin(cam_track, '0 0 0');
		setmodel(cam_track, MODEL_EMPTY);
		setsize(cam_track, VEC_ORIGIN, VEC_ORIGIN);
		cam_track.velocity = '0 0 0';

		// Setup controller into loop
		cam_control.think = camera_controller_think;
		cam_control.nextthink = time + CINECAM_CONTIME;
	}
};

//======================================================================
/*QUAKED misc_camera (1 0.5 0.5) (-16 -16 -16) (16 16 16) PLAYER SKIPABLE FADEOUT FADEIN FIXEDANGLE ENDCAMERA x x Not_Easy Not_Normal Not_Hard Not_DM
In game cinematic camera (Does not work in coop/dm mode)
-------- KEYS --------
targetname   : Camera name for linking into target chains
target       : Points to the next camera in a chain/sequence
angletarget  : Direction the camera will face (use info_target)
angles       : Direction the camera will face (Pitch Yaw Roll setup)
focalpoint   : Always focus the camera on angletarget (=1 enabled)
angleblend   : Blend between current/last camera angles (def=0.03 range=0-1)
target2      : Additional target(s) to trigger when camera VIEWED
deathtarget  : Additional target(s) to trigger when cinematic FINISHED
modeltarget  : Location of fake player mdl (use info_camera_destination)
returntarget : Location of returning player (use info_camera_destination)
pos1         : Camera starting BACKGROUND colour (R/G/B)
pos2         : Camara finishing BACKGROUND colour (R/G/B)
waitmin      : Fade OUT previous camera, time (def=1s, minimum=0.1s)
waitmin2     : Fade IN this camera, time (def=1s, minimum=0.1s)
waitmin3     : Speed at which camera moves towards sighttarget
sighttarget  : Position the camera will travel towards (use info_target)
controltarget: Bezier Curve control point (has angletarget defaults)
wait         : Time to wait while showing camera (-1 = wait for key)
message      : message to centerprint when camera is viewed
message2     : message to centerprint to client if coop is active
sounds       : 1=Secret,2=talk(def),3=switch,4=silent,5=custom,6=secret2
noise        : custom sound to play when messaged is centerprinted
nodebuginfo  : All debug info displayed via developer=1 is blocked
-------- SPAWNFLAGS --------
PLAYER       : Show the player model when starting cinematics
SKIPABLE     : Allow the cinematic to be skipped (exit after fade)
FADEOUT      : Fade OUT previous camera (time = waitmin)
FADEIN       : Fade IN this camera (time = waitmin2)
FIXEDANGLE   : All cameras in a chain will use the first camera angle
ENDCAMERA	 : Only the fade in/out work, the origin/angle are ignored
-------- NOTES --------
In game cinematic camera will fade/move based on times in seconds.
The first fade (out) is from previous camera to background colour.
The second fade (in) is to current camera view. The linear movement
will start at the same time as the fade in process.
Start -> Fade Out(waitmin1) -> Fade In(waitmin2) / Movement (waitmin3)
Once 'Fade in' has finshed then the pause timer (wait) starts.
Waitmin3 = Waitmin2 + Wait (Sync everything to finish together)
To sync the final camera to a player start, finish 22 map units above
angles = up/down, angle, tilt left/right 'pitch roll yaw'
up/left = negative value, down/right = positive value
deathtarget, modeltarget & returntarget have to be defined on first camera
Be aware that coop is not supported, so be careful of trigger events
and decide on a coop "not working" message2.

======================================================================*/
void() misc_camera_use = 
{
	// Cannot use camera's during intermission
	if (intermission_running > 0) return;
	// Stop if cinematic running already
	if (cinematic_running > 0) return;
	
	// Find client first
	self.enemy = world;
	if (other.flags & FL_CLIENT) self.enemy = other;
	else if (activator.flags & FL_CLIENT) self.enemy = activator;
	
	// No player available or is dead?
	if (!self.enemy) return;
	if (self.enemy.health < 1) return;

	// Cinematics don't work with COOP, let the players know
	// There is a default message, but really this is something
	// the mapper should (override) setup on the first camera
	if (coop > 0) {
		centerprint(self.enemy, self.message2);
		// Default talk sound (using sounds entity key)
		sound (self.enemy, CHAN_VOICE, self.noise, 1, ATTN_NORM);
		return;
	}

	// Start camera controller
	cam_focus = self;
	cam_client = self.enemy;
	cam_active = CINECAM_SETUP;
};

//----------------------------------------------------------------------
float(float cc_value) misc_camera_colrange =
{
	// Make sure cshift colours are in range (0-255)
	if (cc_value < 0) return 0;
	else if (cc_value > CINECAM_MAXSHIFT) return CINECAM_MAXSHIFT;
	else return cc_value;
};

//----------------------------------------------------------------------
void(vector cc_check) misc_camera_colcheck =
{
	// Make sure RBG colour ranges are correct
	cc_check_x = misc_camera_colrange(cc_check_x);
	cc_check_y = misc_camera_colrange(cc_check_y);
	cc_check_z = misc_camera_colrange(cc_check_z);
};

//----------------------------------------------------------------------
void() misc_camera =
{
	// Cinematics will not work in DM mode
	if (deathmatch) { remove(self); return; }
	
	// Setup up class and movetypes
	self.classtype = CT_MISCCAM;
	self.estate = ESTATE_ON;
	setsize (self, VEC_ORIGIN, VEC_ORIGIN);
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel(self, MODEL_EMPTY);
	self.owner = self;

	// Precache any sounds for centerprint
	if (self.sounds < 1) self.sounds = 2;	// DEF=talktalk
	trigger_bmodel_sounds();
	
	// Cannot have a fade IN/OUT timer less than 0.1s
	// The fade IN/OUT function is done via spawnflags
	if (self.waitmin < 0.1) self.waitmin = 1;
	if (self.waitmin2 < 0.1) self.waitmin2 = 1;
	// Check colour fade parameters are in range
	misc_camera_colcheck(self.pos1);
	misc_camera_colcheck(self.pos2);
	// Time to move (linear) towards sighttarget, no angle change
	if (self.waitmin3 < 0.1) self.waitmin3 = 2;
	// Default warning for cinematics and COOP mode
	if (self.message2 == "") self.message2 = "Cinematics don't work in COOP!\n";

	// Found bezier curve setup
	if (self.controltarget != "") {
		// If no angle target setup, use next camera
		if (self.angletarget == "") {
			self.angletarget = self.target;
			// Focus on next camera instead
			self.focalpoint = TRUE;
		}
	}
	
	// Cannot have a focalpoint if no angletarget is defined
	if (self.angletarget == "" && self.focalpoint) {
		dprint("\b[MISC_CAM]\b No focalpoint entity defined!\n");
		self.focalpoint = 0; 
	}
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.use = misc_camera_use;
	
	// Create camera controller
	camera_controller_setup();
	
	// Check for bezier debug mode (display curves)
	// Can block debug info (start/control/end/arrows)
	if (self.controltarget != "" && !self.nodebuginfo) {
		self.think = misc_camera_bezier_debug;
		self.nextthink = time + 0.2;
	}
};

/*======================================================================
 Write a config/text file
 
 * generates file in the DATA subdirectory under MOD folder
 * Uses currently loaded map file with _cam extension added
 * requires the FRIK file system extensions (advanced engine only)
 * requires advanced FTE string commands (included in QSS/DP as well)
 
 // Example use of sprintf
 string = sprintf("\"%s\" \"%s\"\n", entityfieldname(entno), getentityfieldstring(entno, self));

======================================================================*/
void(float filehandle, string entkey, string entval) misc_camera_str =
{
	local string expstr;
	if (entval == "") return;
	expstr = strcat("\"", entkey, "\" \"", entval, "\"\n");
	fputs(filehandle, expstr);
};

//----------------------------------------------------------------------
void(float filehandle, string entkey, float entval) misc_camera_float =
{
	if (entval == 0) return;
	misc_camera_str(filehandle, entkey, ftos(entval));
};

//----------------------------------------------------------------------
void(float filehandle, string entkey, vector entval) misc_camera_vec =
{
	local string expstr;
	if (CheckZeroVector(entval) == TRUE) return;
	expstr = strcat(ftos(entval_x), " ", ftos(entval_y), " ", ftos(entval_z));
	misc_camera_str(filehandle, entkey, expstr);
};

//----------------------------------------------------------------------
void() misc_camera_filewrite =
{
	local string camfile;
	local entity cament;
	local float camfilelen, charpos, camfh;

	// Check for advanced engine support
	if (!ext_active) return;		// Check for advanced engines
	if (!ext_frikfile) return;		// Check for Frik file system
	if (!ext_ftestrings) return;	// Check for advanced string functions
	//if (!ext_sprintf) return;		// Check for C code sprintf exposure
	if (world.model == "") return;	// Check for map name
	
	// Find out current map name
	camfile = world.model;
	camfilelen = strlen(camfile);
	// Search at beginning for directory prefix
	charpos = strstrofs(camfile, "/", 0);
	// Any prefix detected? (Cut directory)
	if (charpos > 0) camfile = substring(camfile, charpos+1, camfilelen);

	// Search for .bsp extension
	camfilelen = strlen(camfile);
	charpos = strstrofs(camfile, ".", 0);
	// Any model (.bsp) extensions? (Cut it!)
	if (charpos > 0) camfile = substring(camfile, 0, charpos);

	// Add new file extension and file type
	camfile = strcat(camfile, "_cam.txt");
	// Open new (overwrite) file ready for export
	camfh = fopen(camfile, FILE_WRITE);

	// Search for any misc_camera entities
	cament = find(world, classname, "misc_camera");
	while(cament) {
		// Open entity definition
		fputs(camfh, "{\n");
		// Write all relevant fields to file
		misc_camera_str(camfh, "classname", cament.classname);
		misc_camera_vec(camfh, "origin", cament.origin);
		misc_camera_float(camfh, "spawnflags", cament.spawnflags);
		misc_camera_str(camfh, "targetname", cament.targetname);
		misc_camera_str(camfh, "target", cament.target);
		misc_camera_str(camfh, "angletarget", cament.angletarget);
		misc_camera_vec(camfh, "angles", cament.angles);
		misc_camera_float(camfh, "focalpoint", cament.focalpoint);
		misc_camera_float(camfh, "angleblend", cament.angleblend);
		misc_camera_str(camfh, "target2", cament.target2);
		misc_camera_str(camfh, "deathtarget", cament.deathtarget);
		misc_camera_str(camfh, "modeltarget", cament.modeltarget);
		misc_camera_str(camfh, "returntarget", cament.returntarget);
		misc_camera_vec(camfh, "pos1", cament.pos1);
		misc_camera_vec(camfh, "pos2", cament.pos2);
		misc_camera_float(camfh, "waitmin", cament.waitmin);
		misc_camera_float(camfh, "waitmin2", cament.waitmin2);
		misc_camera_float(camfh, "waitmin3", cament.waitmin3);
		misc_camera_str(camfh, "sighttarget", cament.sighttarget);
		misc_camera_str(camfh, "controltarget", cament.controltarget);
		misc_camera_float(camfh, "wait", cament.wait);
		misc_camera_str(camfh, "message", cament.message);
		misc_camera_str(camfh, "message2", cament.message2);
		misc_camera_float(camfh, "sounds", cament.sounds);
		misc_camera_str(camfh, "noise", cament.noise);
		misc_camera_float(camfh, "nodebuginfo", cament.nodebuginfo);
		
		// Extra fields that could be generated
		misc_camera_float(camfh, "classtype", cament.classtype);
		misc_camera_float(camfh, "estate", cament.estate);
		misc_camera_str(camfh, "model", cament.model);
		misc_camera_vec(camfh, "absmin", cament.absmin);
		misc_camera_vec(camfh, "absmax", cament.absmax);
		misc_camera_vec(camfh, "mins", cament.mins);
		misc_camera_vec(camfh, "maxs", cament.maxs);
		misc_camera_vec(camfh, "size", cament.size);
		misc_camera_str(camfh, "noise", cament.noise);
		misc_camera_float(camfh, "volume", cament.volume);
		// This is a void() not a string
		//misc_camera_str(camfh, "use", cament.use);
		
		// Close entity definition
		fputs(camfh, "}\n");
		// Next camera entity
		cament = find(cament, classname, "misc_camera");
	}
	
	// Close file
	fclose(camfh);
};


