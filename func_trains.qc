//======================================================================
// Train FUNCTIONS
//======================================================================
float TRAIN_STARTON = 1;
float TRAIN_NONSOLID = 2;
float TRAIN_MODEL = 4;
float TRAIN_TOUCH = 8;
float TRAIN_REVERSE = 32;

//======================================================================
/*QUAKED func_train (0 .5 .8) ? STARTON NONSOLID MODEL TOUCH x REVERSE STARTOFF x
Bmodel platform moving around entity chain
-------- KEYS --------
targetname : = "" start moving straight away != "" wait for trigger
target : Name of first path_corner to start at (instant move)
mdl    : Specify a model for MODEL mode only (progs/object.mdl)
speed  : moving speed (def=100)
dmg    : block damage (def=2)
sounds : 0=Silent, 1=Ratchet Metal, 5=custom 11=base plat 12=med plat
noise  : custom sound - stopped
noise1 : custom sound - moving (looping)
volume : Volume for all custom sounds played (def=1, range=0-1)
_dirt       : -1 = will be excluded from dirtmapping
_minlight   : Minimum light level for any surface of the brush model
_mincolor   : Minimum light color for any surface (def='1 1 1' RGB)
_shadow     : Will cast shadows on other models and itself
_shadowself : Will cast shadows on itself
-------- SPAWNFLAGS --------
STARTON  : Start moving straight away if targetname is used
NONSOLID : No collision or blocking functionality (uses bmodel)
MODEL    : Model with no collision (use mdl key, def=empty model)
TOUCH    : Nonsolid or model trains have touch damage (dmg)
REVERSE  : Start going backward through path_corner chain
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
The target's origin specifies the min point of the train at each corner. 
The train spawns at the first target it is pointing at. 
Use a chain of path_corners to specify which direction to travel

======================================================================*/
void() func_train_stop =
{
	// Play stop sound and switch state OFF
	if ( self.sounds > 0 && self.noise != "" ) 
		sound (self, CHAN_VOICE, self.noise, self.volume, ATTN_NORM);
	self.velocity = self.avelocity = '0 0 0';
	self.state = STATE_OFF;
};

//----------------------------------------------------------------------
vector(entity targ) func_train_origin =
{
	local vector org;
	if (self.bsporigin) org = targ.origin - self.mins;
	else org = targ.origin;
	return org;
};

//----------------------------------------------------------------------
void() func_train_pause =
{
	// Block entity state OFF, DISABLE reqs stop sound and trigger event
	if (self.estate == ESTATE_OFF) return;
	
	// Reset velocity and rotation (stationary object)
	self.velocity = '0 0 0';
	// Make sure model starts with correct angle for corner
	if (self.faceangle > 0) self.angles = self.finalangle;
	
	// Copy CURRENT path corner wait/delay setup
	self.wait = self.movetarget.wait;
	self.delay = self.movetarget.delay;	
	
	// Fire any event targets on path_corner
	if (self.movetarget.corner_event) 
		trigger_strs(self.movetarget.corner_event, self);

	// Deadend logic, setup ready for backwards route
	// Check for any path corner instant switch direction logic
	if (self.movetarget.spawnflags & PATHC_DEADEND || 
		self.movetarget.spawnflags & PATHC_REVERSE) {
			self.direction = 1 - self.direction;
	}

	// func_trains that are nonsolid need to reset ltime
	// otherwise they will never pause at path_corner
	if (!self.bsporigin) self.ltime = time;

	// If the train has been disabled, stop and make sound
	// Need to check wait logic at arriving path_corner and not before
	// Some ID maps used wait = -1 and some did path corner stacking
	if (self.state == STATE_OFF || self.wait < 0) func_train_stop();
	
	// nopause spawnflag ALWAYS overrides any wait state
	else if (self.movetarget.spawnflags & PATHC_NOPAUSE) self.estate_fire();
	else {
		// Is wait setup to pause the train?
		if (self.wait > 0 ) {
			self.nextthink = self.ltime + self.wait + (self.delay * random());
			// Play stop sound if setup
			if ( self.sounds > 0 ) sound (self, CHAN_VOICE, self.noise, self.volume, ATTN_NORM);
			// Stop any movement or rotation
			self.velocity = self.avelocity = '0 0 0';
		}
		// ID logic - 1 frame pause at each path_corner
		// This is a default in the ID (plats.qc, line 242) code!
		// Hence why there is a NOPAUSE option on path corners
		else self.nextthink = self.ltime + 0.1;

		// Keep going to next path corner
		self.think = self.estate_fire;
	}
};

//----------------------------------------------------------------------
void() func_train_next =
{
	// Block entity state OFF, DISABLE needs to stop properly
	if (self.estate & ESTATE_DISABLE) func_train_stop();
	else if (self.estate & ESTATE_OFF) return;
	else if (self.state == STATE_OFF) return;

	//----------------------------------------------------------------------
	// I suppose this is where the train logic goes off the rails!
	// Two types of routing logic exists, random or exact path choices
	//
	// Only do extra logic routing if alternative route exists
	//----------------------------------------------------------------------
	if ( self.movetarget.spawnflags & PATHC_TARGET2) {
		//----------------------------------------------------------------------
		// Exact logic paths ALWAYS overriding any choice or defaults
		// This will even send a train back the way it came if selected
		// This route logic mode will always change direction flow
		//----------------------------------------------------------------------
		if (self.movetarget.spawnflags & PATHC_EXACT) {
			if (self.movetarget.state == STATE_ROUTE2) {
				// Alternative forward route
				self.goalentity = self.movetarget.movetarget2;
				self.direction = 0;
			}
			else if (self.movetarget.state == STATE_ROUTE3) {
				// Backward route
				self.goalentity = self.movetarget.movetarget3;
				self.direction = 1;
			}
			else {
				// Default forward route
				self.goalentity = self.movetarget.movetarget;
				self.direction = 0;
			}
		}
		//----------------------------------------------------------------------
		// Random logic paths behave differently based on current direction
		// FORWARD  : randomly pick between two forward routes, ignore back route
		// BACKWARD : ignore last travelled route and randomly pick from two remaining
		//----------------------------------------------------------------------
		else {
			// direction : forward = 0, backward = 1
			if (self.direction) {
				// Setup default route following backward flow
				self.goalentity = self.movetarget.movetarget3;
				// random chance to pick another route?
				if (random() < 0.5) {
					// Switch direction to forward and pick fresh route
					self.direction = 0;
					if (self.movelast == self.movetarget.movetarget)
						self.goalentity = self.movetarget.movetarget2;
					else if (self.movelast == self.movetarget.movetarget2)
						self.goalentity = self.movetarget.movetarget;
				}
			}
			else {
				// Randomly pick from two forward routes, easy logic
				self.goalentity = self.movetarget.movetarget;
				if (random() < 0.5) self.goalentity = self.movetarget.movetarget2;
			}
		}	
	}
	//----------------------------------------------------------------------
	// Standard path corner, one forward, one backward route
	// Check if the route entities exist first
	// path corners can take a while to be fully setup
	//----------------------------------------------------------------------
	else {
		// Backward route
		if (self.direction) {
			// Spawnflag setup when path_corner has found a link
			if (self.movetarget.spawnflags & PATHC_BACKLINK) 
				self.goalentity = self.movetarget.movetarget3;
			else {
				// Slowly search world entity list for backlink target
				self.oldenemy = find (world, target, self.movetarget.targetname);
				while(self.oldenemy) {
					if (self.oldenemy.classtype == CT_PATHCORNER) {
						self.goalentity = self.oldenemy;
						self.oldenemy = world;
					}
					else self.oldenemy = find(self.oldenemy, target, self.movetarget.targetname);
				}
			}
		}
		// Forward route
		else {
			// Spawnflag setup when path_corner has found a link
			if (self.movetarget.spawnflags & PATHC_TARGET1) 
				self.goalentity = self.movetarget.movetarget;
			else {
				// Slowly search world entity list for forward target
				self.oldenemy = find (world, targetname, self.movetarget.target);
				while(self.oldenemy) {
					if (self.oldenemy.classtype == CT_PATHCORNER) {
						self.goalentity = self.oldenemy;
						self.oldenemy = world;
					}
					else self.oldenemy = find(self.oldenemy, targetname, self.movetarget.target);
				}
			}
		}
	}
	
	//----------------------------------------------------------------------
	// This is the last check before moving towards the next corner
	// If no route entity has been found then stop and do nothing
	// If route found, setup final details and move towards next corner
	//----------------------------------------------------------------------
	if (!self.goalentity) func_train_stop();
	else {
		// Play moving sound if active (sounds = 1 or 5)
		if ( self.sounds > 0 && self.noise1 != "") sound (self, CHAN_VOICE, self.noise1, self.volume, ATTN_NORM);
		// Work out NEXT path_corner origin
		self.finaldest = func_train_origin(self.goalentity);
		// Check if CURRENT path_corner for a different speed
		if (self.movetarget.speed > 0) self.distance = self.movetarget.speed;
		else self.distance = self.speed;

		// Move forward to next target
		self.movelast = self.movetarget;
		self.movetarget = self.goalentity;
		
		// Horrible hack for sawblades to make sure avelocity
		// matches direction of path_corners 
		if (self.classtype == CT_SAWBLADE) {
			// Workout movement direction between path corners
			self.movedir = normalize(self.movetarget.origin - self.movelast.origin);
			// Only interested in 1/0/-1 values
			self.movedir_x = rint(self.movedir_x);
			self.movedir_y = rint(self.movedir_y);
			self.movedir_z = rint(self.movedir_z);
			// Check for any positive values?
			if (self.movedir_x > 0 || self.movedir_y > 0 || self.movedir_z > 0)
				self.avelocity = -self.v_angle;
			else self.avelocity = self.v_angle;
		}
		
		// func_trains that are nonsolid need to reset ltime
		// otherwise they will instantly warp to next corner
		if (!self.bsporigin) self.ltime = time;
		
		// Work out the final facing angle for next corner
		// Need to go +2 into the path corner chain
		if (self.faceangle > 0) {
			// Reset face target first
			self.facetarget = world;
			// This only copes with forward/backward routes and
			// does nothing if using alternative routing (target2)
			// Check for backward routing first
			if (self.direction) {
				// Spawnflag setup when path_corner has found a link
				if (self.movetarget.spawnflags & PATHC_BACKLINK) 
					self.facetarget = self.movetarget.movetarget3;
				else {
					// Slowly search world entity list for backlink target
					self.oldenemy = find (world, target, self.movetarget.targetname);
					while(self.oldenemy) {
						if (self.oldenemy.classtype == CT_PATHCORNER) {
							self.facetarget = self.oldenemy;
							self.oldenemy = world;
						}
						// Keep searching in list for path corner
						else self.oldenemy = find(self.oldenemy, target, self.movetarget.targetname);
					}
				}
			}
			// Forward route
			else {
				// Spawnflag setup when path_corner has found a link
				if (self.movetarget.spawnflags & PATHC_TARGET1) 
					self.facetarget = self.movetarget.movetarget;
				else {
					// Slowly search world entity list for forward target
					self.oldenemy = find (world, targetname, self.movetarget.target);
					while(self.oldenemy) {
						if (self.oldenemy.classtype == CT_PATHCORNER) {
							self.facetarget = self.oldenemy;
							self.oldenemy = world;
						}
						// Keep searching in list for path corner
						else self.oldenemy = find(self.oldenemy, targetname, self.movetarget.target);
					}
				}
			}
			
			// Found +2 path corner?
			if (self.facetarget) {
				// Find facing angle between next and nextnext :P
				self.facevector = self.facetarget.origin - self.movetarget.origin;
				self.finalangle = vectoangles(self.facevector);
			}
			else {
				// This is not a good situation and will probably end up
				// with a weird angle because there is no end point
				self.facevector = self.movetarget.origin - self.origin;
				self.finalangle = vectoangles(self.facevector);
			}
		}
			
		// Is the next path_corner an instant move?
		if (self.movetarget.spawnflags & PATHC_INSTANT) {
			// Train entity has stopped moving
			setorigin (self, self.finaldest);
			func_train_pause();
		}
		else {
			// Finally workout movement (finaldest) and speed (distance)
			SUB_CalcMove (self.finaldest, self.distance, func_train_pause);
		}
	}
};

//----------------------------------------------------------------------
void() func_train_resume =
{
	local float pc_dist;
	
	// Final destionation not setup correctly, move on
	if (self.goalentity.classtype != CT_PATHCORNER) self.estate_fire();
	
	pc_dist = fabs(vlen(self.finaldest - self.origin));
	if (pc_dist > 0) {
		// Play moving sound if active (sounds = 1 or 5)
		if ( self.sounds > 0) sound (self, CHAN_VOICE, self.noise1, self.volume, ATTN_NORM);
		// Setup sawblades to keep spinning
		if (self.classtype == CT_SAWBLADE) {
			if (self.movedir_x > 0 || self.movedir_y > 0 || self.movedir_z > 0)
				self.avelocity = -self.v_angle;
			else self.avelocity = self.v_angle;
		}
		// Double check distance is setup correctly
		if (self.distance < 1) self.distance = self.speed;
		if (!self.bsporigin) self.ltime = time;
		SUB_CalcMove (self.finaldest, self.distance, func_train_pause);
	}
	// Too close to final destination, just move on
	else self.estate_fire();
};

//----------------------------------------------------------------------
void() func_train_use =
{
	// Block entity state OFF + DISABLE
	if (self.estate & ESTATE_BLOCK) return;
	// Can't go anywhere without first path corner
	if (!self.movestart) return;

	// Original ID logic - No toggle, a triggered train stays ON
	// Stop any re-trigger events from reset movement
	if (self.state == STATE_OFF) {
		self.state = STATE_ON;
		self.estate_fire();
	}
};

//----------------------------------------------------------------------
void() func_train_touch =
{
	// Train can still hurt if touched, except when OFF = not visible
	if (self.estate & ESTATE_OFF) return;
	if (other.health < 1 || other.takedamage == DAMAGE_NO) return;
	if (time < self.attack_finished) return;

	self.attack_finished = time + 0.5;
	// Instant death for monsters
	if (other.flags & FL_MONSTER) 
		T_Damage (other, self, self, other.max_health + 100, DAMARMOR);
	else 
		// Small damage but can be lethal because of how often touch runs
		T_Damage (other, self, self, self.dmg, DAMARMOR);

	// Blood and gore at object location not train
	SpawnMeatSpray ( other, other, 250);
};

//----------------------------------------------------------------------
void() func_train_startcorner =
{
	// Find first corner (after spawning)
	if (!self.movestart) self.movestart = find(world, targetname, self.target);
	
	// Has the first path corner been found?
	if (self.movestart) {
		// Move to first path corner (instantly)
		self.finaldest = func_train_origin(self.movestart);
		setorigin (self, self.finaldest);
		self.movetarget = self.movestart;
		
		// Setup last path corner location based on direction
		if (self.direction) self.movelast = self.movestart.movetarget;
		else self.movelast = self.movestart.movetarget3;
		// Double check movelast is valid, if not reset
		if (!self.movelast) self.movelast = self.movestart;

		// Fire any event targets on path_corner
		if (self.movetarget.corner_event) 
			trigger_strs(self.movetarget.corner_event, self);
	}
	// Cannot find first corner (bad situation)
	// Go back to spawn location!
	else {
		setorigin (self, self.dest0);
		self.movetarget = self.movelast = self;
	}
};

//----------------------------------------------------------------------
void() func_train_bmodel_on = 
{
	// Stop re-triggering ON state
	if (self.estate == ESTATE_ON) return;

	// Setup train in different collision/visual states
	if (self.spawnflags & TRAIN_NONSOLID) {
		self.movetype = MOVETYPE_PUSH;			// Bmodel interaction
		self.solid = SOLID_TRIGGER;				// No blocking collision
	}
	// Useful for targetting systems
	else if (self.spawnflags & TRAIN_MODEL) {
		self.movetype = MOVETYPE_NOCLIP;		// Free movement
		if (self.spawnflags & TRAIN_TOUCH)		// Check for touch damage
			self.solid = SOLID_TRIGGER;
		else self.solid = SOLID_NOT;			// No world interaction
	}
	else {
		// default state - push/collision
		self.movetype = MOVETYPE_PUSH;			// Bmodel interaction
		self.solid = SOLID_BSP;					// blocking collision
	}	
		
	self.estate = ESTATE_ON;					// Switch on entity
	self.state = STATE_ON;						// Start train functions
	setmodel (self, self.mdl);					// Show bmodel/model
	setsize (self, self.mins , self.maxs);		// Use defined size above
	sound (self, CHAN_VOICE, SOUND_EMPTY, 1, ATTN_NORM);	// Stop any sound
	self.velocity = self.avelocity = '0 0 0';	// reset velocity/rotation
};

//----------------------------------------------------------------------
void() func_train_on = 
{
	func_train_bmodel_on();
	self.estate_fire();
}
	
//----------------------------------------------------------------------
void() func_train_off = 
{
	// Stop re-triggering OFF state
	if (self.estate == ESTATE_OFF) return;

	self.estate = ESTATE_OFF;			// Switch off entity
	self.state = STATE_OFF;				// Stop train functions
	self.movetype = MOVETYPE_NONE;		// Switch off movement
	self.solid = SOLID_NOT;				// No world interaction
	setmodel (self, "");				// Remove any bmodel/model
	sound (self, CHAN_VOICE, SOUND_EMPTY, 1, ATTN_NORM);	// Stop any sound
	setorigin(self, self.finaldest);	// Instantly move to final destionation
	self.velocity = self.avelocity = '0 0 0';	// reset velocity/rotation
	self.think = SUB_Null;				// Stop any future thinking
};

//----------------------------------------------------------------------
void() func_train_disable =
{
	// Wait for entity to finish what it was doing
	self.state = STATE_OFF;
};

//----------------------------------------------------------------------
void() func_train_reset = 
{
	// If the train is still STARTING OFF? then leave it
	if (self.spawnflags & ENT_STARTOFF) return;
	
	func_train_startcorner();	// Reset train back to first corner
	self.estate = ESTATE_OFF;	// Switch off entity (make sure on func works)
	self.state = STATE_OFF;		// Stop train functions
	self.estate_on();			// Switch train back on (reset location)
	self.think = SUB_Null;		// Stop any future thinking
};

//----------------------------------------------------------------------
void() func_train_blocked =
{
	// This is constant crushing or instant death collision
	if (time < self.attack_finished) return;
	self.attack_finished = time + 0.5;
	T_Damage (other, self, self, self.dmg, DAMARMOR);
};

//----------------------------------------------------------------------
void() func_train_setup =
{
	// Deal with START OFF functionality first
	if (self.spawnflags & ENT_STARTOFF) func_train_bmodel_on();
	// No longer need this spawnflag, remove it
	self.spawnflags = self.spawnflags - (self.spawnflags & ENT_STARTOFF);
	
	self.estate_on = func_train_on;		// Reset train on function
	self.estate_use = func_train_use;	// Switch ON train only, no toggle
	self.estate_fire = func_train_next;	// Move train to next path corner
	self.state = STATE_OFF;				// Train is OFF, waiting

	// Check for any touch damage trigger (nonsolid + model only)
	if (self.solid == SOLID_TRIGGER && self.spawnflags & TRAIN_TOUCH) 
		self.touch = func_train_touch;
	
	// Find the first train corner (target)
	func_train_startcorner();
	// Does the first path corner exist?
	if (self.movestart) {
		// no trigger name? = start immediately
		// Extra spawnflag to bypass original ID train logic
		if (self.targetname == "" || self.spawnflags & TRAIN_STARTON) {
			self.nextthink = self.ltime + 0.1;
			self.think = self.estate_use;
		}
	}
};

//----------------------------------------------------------------------
void() func_train =
{
	// 0 = No sound, 1 = train, 5 = custom
	if (self.sounds == 0) {
		self.noise = SOUND_EMPTY;
		self.noise1 = SOUND_EMPTY;
	}
	else if (self.sounds == 1) {
		self.noise = ("plats/train2.wav");
		self.noise1 = ("plats/train1.wav");
	}
	// Sounds from func_plat (base sounds)
	else if (self.sounds == 11) {
		self.noise = "plats/plat2.wav";
		self.noise1 = "plats/plat1.wav";
	}
	// Sounds from func_plat (base sounds)
	else if (self.sounds == 12) {
		self.noise = "plats/medplat2.wav";
		self.noise1 = "plats/medplat1.wav";
	}
	else {
		if (self.noise == "") self.noise = SOUND_EMPTY;
		if (self.noise1 == "") self.noise1 = SOUND_EMPTY;
	}
	precache_sound (self.noise);
	precache_sound (self.noise1);
	trigger_bmodel_volume(1);
	
	self.classtype = CT_FUNCTRAIN;
	self.classgroup = CG_FUNCMOVER;
	self.state = STATE_OFF;
	self.angles = '0 0 0';

	if (self.speed < 1) self.speed = 100;
	if (!self.dmg) self.dmg = 2;

	// Cannot have nonsolid and nodraw together, they are different entity types
	// nonsolid = bmodel with no collision, nodraw = point entity with empty model
	if (self.spawnflags & TRAIN_NONSOLID && self.spawnflags & TRAIN_MODEL) {
		dprint("\b[FUNC_TRAIN]\b Cannot be bmodel AND model!\n");
		self.spawnflags = self.spawnflags - TRAIN_MODEL;
	}
	
	// There are two types of func_trains (bmodel or point entities)
	// Setup train collision / block damage
	if ( self.spawnflags & TRAIN_MODEL ) {
		setmodel (self, self.model);			// Setup bmodel for origin
		self.dest0 = bmodel_origin(self);		// Calculate reset location
		self.finaldest = self.dest0;			// Save reset location
		setmodel(self, "");						// no longer need bmodel
		setorigin(self, self.finaldest);		// Move entity to world origin
		if (self.mdl) precache_model(self.mdl);	// Any custom model defined?
		else self.mdl = MODEL_BROKEN;			// Use default empty model
		self.bsporigin = FALSE;					// Not bmodel anymore
		if (self.faceangle < 0) self.faceangle = TRUE;	// fix errors
	}
	else {
		self.mdl = self.model;					// Save bmodel for later
		self.bsporigin = TRUE;					// bmodel origin active
		self.finaldest = self.dest0 = '0 0 0';	// reset/current origin
		self.blocked = func_train_blocked;		// bmodel collision/block
		self.faceangle = FALSE;					// Does not work with bmodels
	}

	// In Quake vanilla progs the func_train entity has no spawnflags
	// so in AD I decided to add loads for extra functionality!
	// ID1 map exceptions
	// E2M7 : func_train crusher after pipes (spnflg=33)
	//        Crusher starts on spawn, kills ogre
	// E3M3 : func_train crushers in giant lava room (spnflg=1)
	//        Crushers start on, can hear them early
	// E3M6 : func_trains for moving platforms (spnflg=1)
	//        Has no targetname, so its not important
	if (world.model == "maps/e2m7.bsp") self.spawnflags = 0;
	else if (world.model == "maps/e3m3.bsp") self.spawnflags = 0;
	
	// * The train default is to start stationary when targetname active
	// * When a train is spawn delayed and triggered on (via estate triggers)
	//   it will not start moving because its waiting for another trigger event
	// * The current solution is to use double triggers with a 0.1s delay
	//   so that the train is switched on and then starts moving (via use)
	// * Another solution is to allow the start_on spawnflag to exist with
	//   with the delay spawn (off) function for extra functionality
	// * Added developer warning if both spawnflag values are set
	// * This was changed to fix problems with delay spawning functionality
	//
	if (self.spawnflags & TRAIN_STARTON && self.spawnflags & ENT_STARTOFF) {
		dprint("\b[FUNC_TRAIN]\b Start on + off both active!\n");
		//self.spawnflags = self.spawnflags - ENT_STARTOFF;
	}

	// Setup train direction (switchable via path corners)
	if (self.spawnflags & TRAIN_REVERSE) self.direction = 1;
	else self.direction = 0;
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_on = func_train_bmodel_on;
	self.estate_off = func_train_off;
	self.estate_reset = func_train_reset;
	self.estate_disable = func_train_disable;
	
	// Check for a target field, to teleport/move towards?
	// This really should be an error and removed instead
	// But someone might use a func_train as a world object
	// Best to give a developer warning as well
	if (self.target == "") {
		dprint("\b[FUNC_TRAIN]\b going nowhere without target!\n");
		self.estate_on();
		return;
	}
	
	if (self.spawnflags & ENT_STARTOFF) {
		// A func_train needs to be setup first before any being useable
		// The use/on estate redirects should point at setup until complete
		// The setup function will detect spawn delay and fix the model
		// Once setup is complete, the use/on functions will be reset
		self.estate_use = func_train_setup;
		self.estate_on = func_train_setup;
		// Switch train OFF and wait for trigger/estate
		self.estate_off();
	}
	else {
		// A func_train needs to be setup first before any being useable
		// The use/on estate redirects should point at setup until complete
		self.estate_use = func_train_setup;
		self.estate_on = func_train_setup;
		// Switch train ON to catch anything (droptofloor)
		func_train_bmodel_on();
		
		// The setup function has to run on the second frame (think delay)
		// to allow for all the targets (path_corners) to be setup correctly
		self.ltime = time;
		self.nextthink = self.ltime + 0.1;
		self.think = func_train_setup;
	}
};

//----------------------------------------------------------------------
// Re-direction for map hacks (not used normally)
//----------------------------------------------------------------------
void() train_wait = {};