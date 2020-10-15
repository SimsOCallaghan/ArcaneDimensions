/*======================================================================
 TARGET FUNCTIONS
 
 Trigger_relay and trigger_count are not triggers, they don't have
 any touch functionality and don't even set/use any of the activator
 system used by most trigger/func entities.
 
 These entities are essentially targets that reply on input from other
 targets (use) and then use their targets (conditionally). They should
 be re-classifed as target_relay and target_count, but it is too late now
 for such a change, the opportunity has long gone!
 
======================================================================*/
float TRIG_COUNTNOMESSAGE = 1;	// Prevents all count messages
float TRIG_COUNTEXACTNO = 16;	// Display exact count number
float TRIG_COUNTSTARTDIS = 32;	// Count starts in disabled state

float TRIG_RANDOMTARGET = 2;	// Randomly trigger target/target2
float TRIG_TOGGLETARGET = 4;	// Toggle between target/target2
float TRIG_REPEATTARGET = 8;	// Repeat firing targets (wait+delay)
float TRIG_RELAYSTARTDIS = 32;	// trigger_delay starts disabled
float TRIG_EXPLODENOEFF = 2;	// No old particle effect
float TRIG_EXPLODEDUST = 4;		// Exploding projectile dust
float TRIG_MONKILLDFUNC = 16;	// Kill monsters via death function
float TRIG_MONKILLGIB = 32;		// Kill monsters and gib them 

float TRIG_ENGFITZ = 1;			// Fitz engine
float TRIG_ENGDP = 2;			// DP engine
float TRIG_ENGFTE = 4;			// FTE/QSS engine
float TRIG_ENGRAIN = 16;		// Check for rain effects
float TRIG_ENGSNOW = 32;		// Check for snow effects

float TRIG_RELAYSW1 = 1;		// State 1 = OFF
float TRIG_RELAYSW2 = 2;		// State 2 = ON

//======================================================================
/*QUAKED trigger_relay (0.5 0 0.5) (-8 -8 -8) (8 8 8) x RANDOM TOGGLE REPEAT x STARTDIS x x Not_Easy Not_Normal Not_Hard
Triggers target(s) with custom sounds and messages
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target  : targets to trigger when relay is activated
target2 : secondary targets to trigger when activated
wait    : -1 = will only fire targets once
delay   : delay before firing (after being triggered)
cnt     : random amount of time to add to delay
waitmin : % random chance between target/target2
state   : toggle/repeat starting cycle = 1 (def) or 2
sounds  : 1=Secret,2=talk(def),3=switch,4=silent,5=custom,6=secret2
noise   : custom sound to play when triggered
volume  : Volume for all custom sounds played (def=1, range=0-1)
message : message to display when triggered
-------- SPAWNFLAGS --------
RANDOM : Will randomly select between target/target2
TOGGLE : Will toggle between the target/target2
REPEAT : Will keep re-triggering targets (fire targetname to stop/start)
         endstate : Final state when re-trigger stops
		 state ON trigger event = target
         state ON time = wait + (delay x random())
         state ON custom sound = noise1
		 state OFF trigger event = target2
         state OFF time = wait2 + (delay2 x random())
		 state OFF custom sound = noise2
STARTDIS : Will start disabled, will req trigger_entitystate_on to enable
-------- NOTES --------
This fixed size trigger cannot be touched, it can only be fired by other events.  
Can contain killtargets, targets, delays, and messages.

======================================================================*/
void() trigger_relay_fire = 
{
	// Entity state off or triggered once?
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;

	// Keep toggling between target/target2
	// Uses trigger_strs function instead of SUB_UseTargets
	// the original targets need to be stored elsewhere (noise3/4)
	if (self.spawnflags & TRIG_REPEATTARGET) {
		// Still active?
		if (!self.lefty) {
			// Is the current state the final position?
			if (self.endstate > 0 && self.state != self.endstate) {
				self.state = self.endstate;
				if (self.state == TRIG_RELAYSW1) {
					sound (self, CHAN_BODY, self.noise1, self.volume, ATTN_NORM);
					self.target = self.noise3;
				}
				else {
					sound (self, CHAN_BODY, self.noise2, self.volume, ATTN_NORM);
					self.target = self.noise4;
				}
				// Fire final state position
				if (self.target != "") trigger_strs(self.target, self);
			}
			
			// Stop re-trigger functionality
			self.think = SUB_Null;
			return;
		}
		
		// Setup repeat wait/delay timers and play trigger state sounds
		// The noise1/noise2 are setup with empty sounds if not defined
		if (self.state == TRIG_RELAYSW1) {
			self.nextthink = time + self.wait + (random() * self.delay);
			sound (self, CHAN_BODY, self.noise1, self.volume, ATTN_NORM);
		}
		else {
			self.nextthink = time + self.wait2 + (random() * self.delay2);
			sound (self, CHAN_BODY, self.noise2, self.volume, ATTN_NORM);
		}
		// Keep on looping
		self.think = trigger_relay_fire;
	}
	else {
		// Setup to trigger once?
		if (self.wait < 0) self.attack_finished = time + LARGE_TIMER;
		// Play any trigger sounds
		if (self.noise != "") 
			sound (self, CHAN_VOICE, self.noise, self.volume, ATTN_NORM);
	}
	
	// Randomly pick between target/target2
	// SUB_UseTargets will fire both target strings if found
	// the random choices need to be stored elsewhere (noise3/4)
	if (self.spawnflags & TRIG_RANDOMTARGET) {
		if (random() < self.waitmin) self.target = self.noise3;
		else self.target = self.noise4;
	}
	// Toggle target between target/target2
	// SUB_UseTargets will fire both target strings if found
	// the random choices need to be stored elsewhere (noise3/4)
	else if (self.spawnflags & TRIG_TOGGLETARGET) {
		if (self.state == TRIG_RELAYSW1) {
			self.target = self.noise3; 
			self.state = TRIG_RELAYSW2;
		}
		else {
			self.target = self.noise4; 
			self.state =TRIG_RELAYSW1;
		}
	}
	
	// Repeat has different trigger because of wait/delay fields
	if (self.spawnflags & TRIG_REPEATTARGET) {
		// Use trigger string(s) instead of Sub_use
		if (self.target != "") trigger_strs(self.target, self);
	}
	else {
		// One thing to note about trigger_relay is that it does not change the
		// activator global variable to the entity that used this trigger last
		// This is handy for client test triggers (like trigger_secret)
		SUB_UseTargets();
	}
};

//----------------------------------------------------------------------
void() trigger_relay_use =
{
	// Repeat functionality? - Toggle state
	if (self.spawnflags & TRIG_REPEATTARGET) {
		if (self.lefty) self.lefty = FALSE;
		else self.lefty = TRUE;
	}
	// Trigger relay main routine
	trigger_relay_fire();
};

//----------------------------------------------------------------------
void() trigger_relay_off =
{
	self.estate = ESTATE_OFF;
	self.lefty = FALSE;
	// Switch off any running sounds
	sound (self, CHAN_VOICE, SOUND_EMPTY, 1, ATTN_NORM);
	sound (self, CHAN_BODY, SOUND_EMPTY, 1, ATTN_NORM);
};

//----------------------------------------------------------------------
void() trigger_relay_reset =
{
	self.estate = ESTATE_ON;
	self.state = TRIG_RELAYSW1;
	self.attack_finished = 0;
	self.lefty = FALSE;
};

//----------------------------------------------------------------------
void() trigger_relay =
{
	self.classtype = CT_TRIGRELAY;		// Class type
	self.classgroup = CG_TARGETS;

	// Check for firing conditions (nightmare, coop)
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	if (self.targetname == "" && !(self.spawnflags & TRIG_REPEATTARGET)) {
		dprint("\b[TRIG_RELAY]\b targetname missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}

	// Setup and precache any sounds + volume
	trigger_bmodel_sounds();
	
	// Setup toggle/repeat cycle state (check for override)
	if (self.state == TRIG_RELAYSW2) self.state = TRIG_RELAYSW2;
	else self.state = TRIG_RELAYSW1;
	// Check the endstate exists and within range of state
	if (self.endstate < TRIG_RELAYSW1) self.endstate = 0;
	if (self.endstate > TRIG_RELAYSW2) self.endstate = TRIG_RELAYSW2;

	// Setup entity defaults
	if (self.delay <= 0) self.delay = 0;
	// Add a random to delay (used on regular relay entities)
	if (self.cnt > 0) self.delay = self.delay + random()*self.cnt;
	
	// Setup default (blank) repeat on/off functionality sounds
	if (self.spawnflags & TRIG_REPEATTARGET) {
		// Is repeat functionality active (def=off)
		self.lefty = FALSE;
		// Turn off extra debug info
		self.nodebuginfo = TRUE;
		// Make sure sound files have default sound before precache
		if (self.noise1 == "") self.noise1 = SOUND_EMPTY;
		if (self.noise2 == "") self.noise2 = SOUND_EMPTY;
		precache_sound (self.noise1);
		precache_sound (self.noise2);

		// Can't have wait=-1 option, remove it
		if (self.wait < 0) self.wait = 0;
		// Duplicate wait/delay stuff if empty
		if (self.wait2 <= 0) self.wait2 = self.wait;
		if (self.delay2 <= 0) self.delay2 = self.delay;

		// remove random spawnflags and re-use toggle functions
		self.spawnflags = self.spawnflags - (self.spawnflags & TRIG_RANDOMTARGET);
		self.spawnflags = self.spawnflags | TRIG_TOGGLETARGET;
	}

	// Setup random trigger selection strings and random %
	// No checks are done on the target/target so that they can
	// be blank and the mapper can randomly select an empty trigger
	// only check = The random % has got to exist between 0-1
	//
	// The toggle trigger function uses the same noise string setup
	// Might as well use the random trigger setup functionality
	//
	if (self.spawnflags & TRIG_RANDOMTARGET || self.spawnflags & TRIG_TOGGLETARGET) {
		// Check range of random and setup chance value
		if (self.waitmin <= 0 || self.waitmin >= 1) self.waitmin = 0.5;
		// Reset target/target2 storage
		self.noise3 = self.noise4 = "";
		// Copy over target/target2 if not empty
		if (self.target != "") self.noise3 = self.target;
		if (self.target2 != "") self.noise4 = self.target2;
		// make sure second target is not empty, dupilicate first
		else self.noise4 = self.noise3;
		// Reset target/target2 fields
		self.target = self.target2 = "";
	}

	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trigger_relay_use;
	self.estate_off = trigger_relay_off;
	self.estate_reset = trigger_relay_reset;
	
	// Setup intial entity state (can start disabled)
	if (self.spawnflags & TRIG_RELAYSTARTDIS) self.estate = ESTATE_DISABLE;
	else if (self.spawnflags & TRIG_REPEATTARGET && self.targetname == "")
		self.estate_use();
	else self.estate = ESTATE_ON;
};

//======================================================================
/*QUAKED trigger_counter (0.5 0 0.1) (-8 -8 -8) (8 8 8) NOMESSAGE x x x EXACTNO STARTDIS STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
A counter which triggers target(s) when complete
-------- KEYS --------
targetname  : trigger entity (works with entity state system)
target      : trigger target(s) when complete
startmsg    : message to display before counting begins (use wait for pause time)
message     : message to display when complete (displayed when firing target)
message2    : message to display when complete (ignores NOMESSAGE spawnflag)
counttarget : misc_targetnumber updated with current counter number
lip         : 1=display counter goes up from zero, -1=counts down to zero
count     : number of triggers needed to fire own target, (def=2)
delay     : time delay to fire final trigger event
sounds    : 0=silent,1=Secret,2=talk,3=switch,5=custom,6=secret2
noise     : custom sound to play when complete
wait      : time to pause before starting to count (def=2s)
-------- SPAWNFLAGS --------
NOMESSAGE : disables count display
EXACTNO   : display exact number when counting down
STARTDIS  : Starts disabled and waits for trigger
STARTOFF  : Requires trigger to activate
-------- NOTES --------
A counter which triggers target(s) when complete

======================================================================*/
void() trigger_counter_updateno =
{
	local entity tdfind, tself, tother;
	if (self.counttarget == "") return;
	
	if (self.lip >= 0) self.targetnumber = self.height - self.count;
	else self.targetnumber = self.count;
	
	tdfind = find(world, targetname, self.counttarget);
	if (tdfind.classtype == CT_TARGETNUMBER) {
		tself = self; tother = other;
		self = tdfind; other = tself;
		self.use();
		self = tself; other = tother;
	}
};

//----------------------------------------------------------------------
void() trigger_counter_reset =
{
	// Reset counter to initial (spawning) value
	self.count = self.height;
};

//----------------------------------------------------------------------
void() trigger_counter_use =
{
	if (self.estate & ESTATE_BLOCK) return;
	
	// Check for any pre-count messages
	if (self.startmsg != "") {
		centerprint (activator, self.startmsg);
		self.startmsg = "";
		self.nextthink = time + self.wait;
		self.think = self.estate_use;
		return;
	}
	
	// Count down the trigger
	self.count = self.count - 1;
	if (self.count < 0) return;
	
	// Update misc_targetnumber entity
	trigger_counter_updateno();
		
	// Count down messages for trigger
	if (self.count > 0) {
		if (activator.flags & FL_CLIENT && !(self.spawnflags & TRIG_COUNTNOMESSAGE) ) {
			if (self.count >= 4) {
				if (self.spawnflags & TRIG_COUNTEXACTNO)
					centerprint3 (activator, "Only ", ftos(self.count), " more to go...");
				else centerprint (activator, "There are more to go...");
			}
			else if (self.count == 3) centerprint (activator, "Only 3 more to go...");
			else if (self.count == 2) centerprint (activator, "Only 2 more to go...");
			else centerprint (activator, "Only 1 more to go...");
		}
		return;
	}
	
	// Reach zero on counter, time to trigger counter target
	if (activator.flags & FL_CLIENT) {
		if (self.message2 != "") centerprint(activator, self.message2);
		else if ( !(self.spawnflags & TRIG_COUNTNOMESSAGE) )
			centerprint(activator, "Sequence completed!");
	}	
	
	// If sound defined, play sound
	if (self.noise != "") sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	// This is a big problem with the trigger_counter entity, it does not update
	// the activator global variable and does not wake up enemies correctly.
	// If a trigger_count is targetting monsters then they will not get angry
	// at the player, the count has to target a _once or _multi trigger instead.
	self.enemy = activator;
	SUB_UseTargets();
};

//----------------------------------------------------------------------
void() trigger_counter_delay =
{
	if (self.estate & ESTATE_BLOCK) return;

	// Remove the trigger delay function
	if (self.spawnflags & ENT_STARTOFF)
		self.spawnflags = self.spawnflags - ENT_STARTOFF;
	
	// Re-route use function to actual counter
	self.estate_use = trigger_counter_use;
};

//----------------------------------------------------------------------
void() trigger_counter_setup =
{
	// Update misc_targetnumber entity
	trigger_counter_updateno();
};

//----------------------------------------------------------------------
void() trigger_counter =
{
	self.classtype = CT_TRIGCOUNT;
	self.classgroup = CG_TARGETS;

	// Check for firing conditions (nightmare, coop)
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	if (self.targetname == "") {
		dprint("\b[COUNTER]\b targetname missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}

	trigger_bmodel_sounds();			// Precache any sounds
	if (!self.count) self.count = 2;	// default count
	self.height = self.count;			// Save for later, reset
	if (self.wait <= 0) self.wait = 2;	// Default pre-message time

	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_reset = trigger_counter_reset;
	if (!self.estate) self.estate = ESTATE_ON;
	// Check for disable state (need trigger_entityon to work again)
	if (self.spawnflags & TRIG_COUNTSTARTDIS) self.estate = ESTATE_DISABLE;

	// The delay function is not switched off, its activate to use
	if (self.spawnflags & ENT_STARTOFF) self.estate_use = trigger_counter_delay;
	else self.estate_use = trigger_counter_use;

	// Update any number counters
	self.think = trigger_counter_setup;
	self.nextthink = time + 0.5 + random();
};

//======================================================================
/*QUAKED trigger_timer (0.5 0 0.1) (-8 -8 -8) (8 8 8) x x x x x STARTDIS STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
A timer with three (gold/siver/bronze) event triggers
-------- KEYS --------
targetname  : trigger entity (works with entity state system)
spawndelay  : Setup time before entity can be used (def=0.5, min=0.1)
delay       : time delay BEFORE firing final result (def=1s)
wait        : time delay PAUSE before starting timer (def=0s)
timertarget : misc_targetnumber updated between start/finish
startmsg    : Start of timer centerprint message
message     : Stop of timer centerprint message
target   : timer value 1 - trigger target(s) (Must Exist)
waitmin  : timer value 1 - TIME to trigger event
noise    : timer value 1 - misc_targetnumber targetname (optional)
target2  : timer value 2 - trigger target(s)
waitmin2 : timer value 2 - must be greater TIME than waitmin
noise2   : timer value 2 - misc_targetnumber targetname (optional)
target3  : timer value 3 - trigger target(s)
waitmin3 : timer value 3 - must be greater TIME that waitmin2
noise3   : timer value 3 - misc_targetnumber targetname (optional)
-------- SPAWNFLAGS --------
STARTDIS : Starts disabled and waits for trigger
STARTOFF : Requires trigger to activate
-------- NOTES --------
A timer with three (gold/siver/bronze) event triggers

======================================================================*/
void(float tvalue, string tdstr) trigger_timer_updateno =
{
	local entity tdfind, tself, tother;
	if (tdstr == "") return;
	
	self.targetnumber = tvalue;
	tdfind = find(world, targetname, tdstr);
	if (tdfind.classtype == CT_TARGETNUMBER) {
		tself = self; tother = other;
		self = tdfind; other = tself;
		self.use();
		self = tself; other = tother;
	}
};

//----------------------------------------------------------------------
void() trigger_timer_think =
{
	// Has timer been switched off or disabled
	if (self.estate & ESTATE_BLOCK) return;
	if (self.state == STATE_OFF) return;
	
	self.attack_finished = time - self.count;
	trigger_timer_updateno(self.attack_finished, self.timertarget);
	self.think = trigger_timer_think;
	self.nextthink = time + 0.1;
};

//----------------------------------------------------------------------
void() trigger_timer_use =
{
	// Cannot trigger this entity too early
	if (self.meleetimer > time) { self.meleeattack = TRUE; return; }
	// Block off/disable states
	if (self.estate & ESTATE_BLOCK) return;

	if (self.state == STATE_OFF) {
		self.state = STATE_ON;
		// Setup beginning of timer (used later)
		self.count = time;
		// Reset timer
		self.attack_finished = 0;
		// Check activator is a player? worse case is client spawn
		if (activator.flags & FL_CLIENT) self.owner = activator;
		else self.owner = client_ent;
		// Check for any start message
		if (self.startmsg != "" ) centerprint(self.owner, self.startmsg);
		// Start timer (visual update only)
		if (self.timertarget != "") trigger_timer_think();
	}
	else {
		self.state = STATE_OFF;
		// Final time
		self.attack_finished = time - self.count;
		// Make sure final time score is updated
		trigger_timer_updateno(self.attack_finished, self.timertarget);
		// Check activator is a player? worse case is client spawn
		if (activator.flags & FL_CLIENT) self.owner = activator;
		else self.owner = client_ent;
		// Check for any finish message
		if (self.message != "") centerprint(self.owner, self.message);
		// Work out which event (gold/silver/bronze) to trigger
		if (self.waitmin > 0 && self.attack_finished <= self.waitmin) 
			trigger_strs(self.target, self.owner);
		else if (self.waitmin2 > 0 && self.attack_finished <= self.waitmin2)
			trigger_strs(self.target2, self.owner);
		else if (self.waitmin3 > 0 && self.attack_finished <= self.waitmin3)
			trigger_strs(self.target3, self.owner);
	}
};

//----------------------------------------------------------------------
void() trigger_timer_delay =
{
	if (self.estate & ESTATE_BLOCK) return;

	// Remove the trigger delay function
	if (self.spawnflags & ENT_STARTOFF)
		self.spawnflags = self.spawnflags - ENT_STARTOFF;
	
	// Re-route use function to actual timer
	self.estate_use = trigger_timer_use;
};

//----------------------------------------------------------------------
void() trigger_timer_off = 
{
	self.estate = ESTATE_OFF;
	// Make sure timer is off
	self.state = STATE_OFF;
	trigger_timer_updateno(0, self.timertarget);
};

//----------------------------------------------------------------------
void() trigger_timer_on = 
{
	self.estate = ESTATE_ON;
	// Reset timer
	self.state = STATE_OFF;
	trigger_timer_updateno(0, self.timertarget);
};

//----------------------------------------------------------------------
void() trigger_timer_setup =
{
	// no longer need setup timer
	self.meleetimer = 0;
	// Setup any model number fields
	trigger_timer_updateno(self.waitmin, self.noise);
	trigger_timer_updateno(self.waitmin2, self.noise2);
	trigger_timer_updateno(self.waitmin3, self.noise3);
	// Waiting for setup to finish, start trigger event
	if (self.meleeattack == TRUE) trigger_timer_use();
};

//----------------------------------------------------------------------
void() trigger_timer =
{
	self.classtype = CT_TRIGTIMER;
	self.classgroup = CG_TARGETS;

	// Check for firing conditions (nightmare, coop)
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	// Can this entity can be triggered?
	if (self.targetname == "") {
		dprint("\b[TIMER]\b targetname missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	// Can the first target be triggered?
	if (self.target == "") {
		dprint("\b[TIMER]\b 1st event not defined!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	
	// Setup event timers (defaults)
	if (self.waitmin <= 0) self.waitmin = 1;
	
	// check timers are in the right order
	if ((self.waitmin2 > 0 && self.waitmin2 <= self.waitmin) ||
		(self.waitmin3 > 0 && self.waitmin3 <= self.waitmin) ||
		(self.waitmin3 > 0 && self.waitmin3 <= self.waitmin2) ) {
		dprint("\b[TIMER]\b Event times out of sync!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	
	// Timer starts off by default
	self.state = STATE_OFF;
	// Ignore any trigger_str errors
	self.nodebuginfo = TRUE;
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	
	// Check for disable state (need trigger_entityon to work again)
	if (self.spawnflags & TRIG_COUNTSTARTDIS) self.estate = ESTATE_DISABLE;
	else if (self.spawnflags & ENT_STARTOFF) self.estate = ESTATE_OFF;
	else self.estate = ESTATE_ON;

	// The delay function is not switched off, its activate to use
	if (self.spawnflags & ENT_STARTOFF) self.estate_use = trigger_timer_delay;
	else self.estate_use = trigger_timer_use;
	self.estate_on = trigger_timer_on;
	self.estate_off = trigger_timer_off;
	self.estate_reset = trigger_timer_on;
	
	// Update any number counters
	if (self.spawndelay < 0.1) self.spawndelay = 0.5;
	self.meleetimer = time + self.spawndelay;
	self.think = trigger_timer_setup;
	self.nextthink = self.meleetimer;
};

//======================================================================
/*QUAKED trigger_engine (0 0 1) (-8 -8 -16) (8 8 16) FITZ DP FTE x RAIN SNOW x x
Triggers target(s) when certain engine active
-------- KEYS --------
targetname : trigger entity
target  : targets to trigger when relay is activated
wait    : -1 = will only fire targets once
delay   : delay before firing (after being triggered)
cnt     : random amount of time to add to delay
-------- SPAWNFLAGS --------
FITZ : Only trigger for Fitz engines (default type)
DP   : Only trigger for DP engine
FTE  : Only trigger for FTE/QSS engines
RAIN : Check for rain effect being active
SNOW : Check for snow effect being active
-------- NOTES --------
Triggers target(s) when certain engine active

======================================================================*/
void() trigger_engine_fire =
{
	// Parameter to check at of tests
	self.aflag = FALSE;
	
	// Check each engine type for conditions
	// This trigger will not reset the activator
	// Should be done with one of the targets instead
	if (self.spawnflags & TRIG_ENGFITZ && engine == ENG_FITZ) self.aflag = TRUE;
	else if (self.spawnflags & TRIG_ENGDP && engine == ENG_DPEXT) self.aflag = TRUE;
	// Extra check for FTE/QSS (they support DP particles)
	else if (self.spawnflags & TRIG_ENGFTE && engine == ENG_DPEXT) {
		if (checkextension("FTE_SV_POINTPARTICLES")) self.aflag = TRUE;
	}

	if (self.aflag == TRUE) {
		// Check for engine weather effects
		if (self.spawnflags & TRIG_ENGRAIN && !ext_dprain) self.aflag = FALSE;
		if (self.spawnflags & TRIG_ENGSNOW && !ext_dpsnow) self.aflag = FALSE;
		// Check for weather being disabled
		if (self.spawnflags & (TRIG_ENGRAIN | TRIG_ENGSNOW)) {
			if (query_weathersystem() == FALSE) self.aflag = FALSE;
		}
	
		// If engine and/or weather active, fire targets!
		if (self.aflag == TRUE) {
			// Setup trigger to only work once?
			if (self.wait < 0) {
				self.attack_finished = LARGE_TIMER;
				self.estate = ESTATE_OFF;
			}
			// Slow down re-trigger events
			else self.attack_finished = time + self.waitmin;

			// Check if target string exists
			if (self.target != "") trigger_strs(self.target, self.bmodel_act);
		}

	}
};

//----------------------------------------------------------------------
void() trigger_engine_use =
{
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;

	// Check for any trigger delay?
	if (self.delay > 0) {
		self.think = trigger_engine_fire;
		self.nextthink = time + self.delay;
	}
	else trigger_engine_fire();
};		

//----------------------------------------------------------------------
void() trigger_engine =
{
	self.classtype = CR_TRIGENG;
	self.classgroup = CG_TARGETS;

	// Check for firing conditions (nightmare, coop)
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	if (self.targetname == "") {
		dprint("\b[TRIG_ENG]\b targetname missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}

	// Default entity key parameters
	if (self.waitmin <= 0) self.waitmin = 1;

	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trigger_engine_use;
	self.estate = ESTATE_ON;
};

//======================================================================
/*QUAKED trigger_playerparticles (0 0.75 0.75) (-8 -8 -8) (8 8 8) x x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Attach a particle emitter to the player (FTE/QSS engines only)
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target  : targets to trigger when entity is activated
noise   : Name of particle in CFG file (eg 'fte_weather.ent_playerrain')
mangle  : Orientation of the particle emitter (up = '90 0 0')
state   : Set the particle emitter to exact value (1=ON, -1=OFF)
wait    : -1 = will only trigger once
-------- SPAWNFLAGS --------
-------- NOTES --------
Attach a particle emitter to the player (FTE/QSS engines only)

======================================================================*/
void() trigger_playerparticles_use = 
{
	if (self.estate & ESTATE_BLOCK) return;
	if ( !(other.flags & FL_CLIENT) ) return;
	if (self.attack_finished > time) return;
	// This only works with FTE
	if (!ext_ftepart) return;

	// Store player/client for later
	self.enemy = other;
	
	// Check if the entity attachment is active
	if (!self.enemy.entattachment) {
		self.enemy.entattachment = spawn();
		// Link back to trigger entity
		self.enemy.entattachment.owner = self;
		self.enemy.entattachment.solid = SOLID_NOT;
		self.enemy.entattachment.movetype = MOVETYPE_NOCLIP;
		
		// Setup empty model for protocol problems
		self.enemy.entattachment.mdl = MODEL_EMPTY;
		setmodel(self.enemy.entattachment, self.enemy.entattachment.mdl);
		setorigin(self.enemy.entattachment, self.enemy.origin);
		setsize(self.enemy.entattachment, VEC_ORIGIN, VEC_ORIGIN);
	}
	
	// Toggle the entity attachment
	if (self.state == TRUE || self.enemy.entactive == FALSE) {
		self.enemy.entactive = TRUE;
		// Setup angle / particle for emitter
		self.enemy.entattachment.angles = self.mangle;
		self.enemy.entattachment.noise = self.noise;
		// example - '90 0 0', "fte_weather.ent_playerrain"
		self.enemy.entattachment.emiteffectnum = particleeffectnum(self.noise);
	}
	else {
		// Disable attachment
		self.enemy.entactive = FALSE;
		// Turn off particle emitter
		self.entattachment.emiteffectnum = particleeffectnum("");
	}
	
	// Check if target string exists
	if (self.target != "") trigger_strs(self.target, self.enemy);

	// Setup trigger to only work once?
	if (self.wait < 0) {
		self.attack_finished = LARGE_TIMER;
		self.estate_off();
	}
};

//----------------------------------------------------------------------
void() trigger_playerparticles_off =
{
	self.estate = ESTATE_OFF;
	// Only work if FTE/QSS engine
	if (!ext_ftepart) return;
	// Check for any player particles setup?
	if (self.enemy.flags & FL_CLIENT) {
		self.enemy.entactive = FALSE;
		// Check for the particle attachment?
		if (self.enemy.entattachment) 
			self.enemy.entattachment.emiteffectnum = particleeffectnum("");
	}
};

//----------------------------------------------------------------------
void() trigger_playerparticles =
{
	self.classtype = CT_TRIGPLAYPART;
	self.classgroup = CG_TARGETS;

	// Only work if FTE/QSS engine
	if (!ext_ftepart) return;
	// Check for firing conditions (nightmare, coop)
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	if (self.targetname == "") {
		dprint("\b[TRIG_PLAYPART]\b targetname missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}

	// Cannot work without particle setup
	if (self.noise == "") {
		spawn_marker(self.origin, SPNMARK_YELLOW);
		dprint("\b[TRIG_PLAYPART]\b particle name missing!\n");
		remove(self);
		return;
	}

	// Cache the particle effect, have to check for FTE/QSS engine first
	// This works very much like precache_model and precache_sound
	// No feedback from engine to know if this works or not
	if (checkextension("FTE_SV_POINTPARTICLES"))
		particleeffectnum(self.noise);
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trigger_playerparticles_use;
	self.estate_off = trigger_playerparticles_off;
	self.estate = ESTATE_ON;
};

//======================================================================
/*QUAKED trigger_lightstyle (0 0.75 0.75) (-8 -8 -8) (8 8 8) x x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Change lightstyle, must specify a style/target and remap/string
-------- KEYS --------
targetname : trigger entity (works with entity state system)
style   : Light style number to affect (can be 0 = whole map)
target  : target a switchable light, instead of using style key
target2 : targets to trigger when entity is activated
wait    : -1 = will only trigger once
customstyle_remap  : Re-use another light style (1-63)
customstyle_string : light value string made up of "a-z" letters
customstyle_update : =0 always, =1 no, =2 only if estate/light on
-------- SPAWNFLAGS --------
-------- NOTES --------
Change lightstyle, must specify a style/target and remap/string

======================================================================*/
void() trigger_lightstyle_use =
{
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;

	// Any re-map functionality defined?
	if (self.customstyle_remap > 0 && self.style > 0) {
		// Copy string from lightstyle array
		self.customstyle_string = light_style_str[self.customstyle_remap];
		// Show debug info of remap lightstyle change
		dprint("\b[TRIG_LS]\b remap ("); dprint(ftos(self.customstyle_remap));
		dprint(") string ("); dprint(self.customstyle_string);
		dprint(")\n");
	}

	// Any custom light string defined?
	if (self.customstyle_string != "") {
		// Update the string to the lightstyle array
		light_style_str[self.style] = self.customstyle_string;
		// Check for the light style override update to the engine
		// customstyle_update : =0 always, =1 no, =2 only if estate/light on
		if (self.customstyle_update == 0 || (self.customstyle_update == 2 && self.enemy.estate == ESTATE_ON)) 
			lightstyle(self.style, self.customstyle_string);
		// Show debug info of lightstyle string change
		dprint("\b[TRIG_LS]\b style ("); dprint(ftos(self.style));
		dprint(") string ("); dprint(self.customstyle_string);
		dprint(")\n");
	}
	
	// Check if target string exists
	if (self.target2 != "") trigger_strs(self.target2, other);
	
	// Setup trigger to only work once?
	if (self.wait < 0) {
		self.attack_finished = LARGE_TIMER;
		self.estate_off();
	}
};

//----------------------------------------------------------------------
void() trigger_lightstyle_setup =
{
	// Need to check style and remap values are within range FIRST
	// Will be serious crash because its an index for fixed size array
	if (self.style < 0 || self.style >= LIGHT_MAXLIGHTSTYLE) {
		spawn_marker(self.origin, SPNMARK_YELLOW);
		dprint("\b[TRIG_LS]\b light style ("); dprint(ftos(self.style));
		dprint(") out of range!\n");
		remove(self);
		return;
	}
	else if (self.customstyle_remap < 0 || self.customstyle_remap >= LIGHT_MAXLIGHTSTYLE) {
		spawn_marker(self.origin, SPNMARK_YELLOW);
		dprint("\b[TRIG_LS]\b remap style ("); dprint(ftos(self.customstyle_remap));
		dprint(") out of range!\n");
		remove(self);
		return;
	}

	// Check if the target is valid?
	if (self.target != "") {
		// Find the target (should be spawned by now)
		self.enemy = find(world, targetname, self.target);
		// Is target valid entity?
		if (self.enemy) {
			// Is this a switchable light and style within range?
			if (self.enemy.targetname != "" && self.enemy.style >= 0 && 
				self.enemy.style < LIGHT_MAXLIGHTSTYLE ) {
				self.style = self.enemy.style;
			}
			else {
				dprint("\b[TRIG_LS]\b target not valid switch light!\n");
				self.enemy = world;
			}
		}
		else dprint("\b[TRIG_LS]\b invalid target entity!\n");
	}
	// No target light defined
	else self.enemy = world;

	// Style has to be different to re-map
	if (self.customstyle_remap > 0 && self.customstyle_remap == self.style) {
		spawn_marker(self.origin, SPNMARK_YELLOW);
		dprint("\b[TRIG_LS]\b remap and style are the same!\n");
		remove(self);
		return;
	}
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trigger_lightstyle_use;
	self.estate = ESTATE_ON;
};

//----------------------------------------------------------------------
void() trigger_lightstyle =
{
	self.classtype = CT_TRIGLIGHTSTYLE;
	self.classgroup = CG_TARGETS;
	
	// Check for firing conditions (nightmare, coop)
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	if (self.targetname == "") {
		dprint("\b[TRIG_LS]\b targetname missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}

	// Custom remap or string are required
	if (self.customstyle_remap < 1 && self.customstyle_string == "") {
		spawn_marker(self.origin, SPNMARK_YELLOW);
		dprint("\b[TRIG_LS]\b remap or string missing!\n");
		remove(self);
		return;
	}
	
	// Wait for everything to be setup; target/lightstyles
	self.think = trigger_lightstyle_setup;
	self.nextthink = time + 0.5;
};

//======================================================================
/*QUAKED trigger_clientmsg (0.5 0.5 0) (-8 -8 -16) (8 8 16) x
Centerprints a message to all clients
-------- KEYS --------
targetname : trigger entity
message : Text to center print
sounds  : 1=Secret,2=talk,3=switch,4=silent(def),5=custom,6=secret2
noise   : custom sound to play when triggered
-------- SPAWNFLAGS --------
-------- NOTES --------
Centerprints a message to all clients

======================================================================*/
void() trigger_clientmsg_use =
{
	if (self.estate & ESTATE_BLOCK) return;
	
	// Write message to all clients
	msg_entity = self;
	WriteByte (MSG_ALL, SVC_CENTERPRINT);
	WriteString (MSG_ALL, self.message);

	// If any sounds defined play them at entity source
	if (self.noise != "") sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
};

//----------------------------------------------------------------------
void() trigger_clientmsg =
{
	self.classtype = CT_TRIGCLMSG;
	self.classgroup = CG_TARGETS;

	// Check for firing conditions (nightmare, coop)
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	if (self.targetname == "") {
		dprint("\b[TRIG_MSG]\b targetname missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	
	// Default = the sound of silence!
	if (self.sounds == 0) self.sounds = 4;
	trigger_bmodel_sounds();
	
	// Setup default message
	if (self.message == "") self.message = "Default Trigger Message!\n";

	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trigger_clientmsg_use;
	self.estate = ESTATE_ON;
};

//======================================================================
/*QUAKED trigger_cdtrack (0.8 0.5 0) (-8 -8 -16) (8 8 16) x
Change CD track for all clients
-------- KEYS --------
targetname : trigger entity
count      : CD track number (eg. 0-x)
-------- SPAWNFLAGS --------
-------- NOTES --------
Change CD track for all clients

======================================================================*/
void() trigger_cdtrack_change =
{
	// Write CD track to all clients
	msg_entity = self;
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, trig_cdtrack);
	WriteByte (MSG_ALL, trig_cdtrack);
};

//----------------------------------------------------------------------
void() trigger_cdtrack_use =
{
	// Check for entity state system block
	if (self.estate & ESTATE_BLOCK) return;
	
	// Make sure CD track change in savefile
	trig_cdtrack = self.count;

	// Write message to all clients
	trigger_cdtrack_change();
};

//----------------------------------------------------------------------
void() trigger_cdtrack =
{
	self.classtype = CT_TRIGCDTRACK;
	self.classgroup = CG_TARGETS;

	// Check for firing conditions (nightmare, coop)
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	if (self.targetname == "") {
		dprint("\b[TRIG_CD]\b targetname missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}

	// Make sure specified cd track is integer number
	self.count = fabs(rint(self.count));

	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trigger_cdtrack_use;
	self.estate = ESTATE_ON;
};

//======================================================================
/*QUAKED trigger_skybox (0.9 0.9 0.9) (-8 -8 -16) (8 8 16) x
Load/Change Skybox for all clients
-------- KEYS --------
targetname : trigger entity
message : Skybox name (eg moonrise_)
-------- SPAWNFLAGS --------
-------- NOTES --------
Load/Change Skybox for all clients

======================================================================*/
void(entity targ) trigger_skybox_change =
{
	// Write skybox change to all clients
	// console command has to be lowercase
	stuffcmd(targ, "sky ");
	stuffcmd(targ, trig_skybox);
	stuffcmd(targ, "\n");
};

//----------------------------------------------------------------------
void() trigger_skybox_use =
{
	// Check for entity state system block
	if (self.estate & ESTATE_BLOCK) return;
	
	// Check for client trigger first
	if (activator.classtype == CT_PLAYER) self.enemy = activator;
	
	// Find a player for the stuff command
	if (!self.enemy) {
		self.enemy = find(world,targetname,"player");
		if (self.enemy.classtype != CT_PLAYER) return;
	}
	
	// Write skybox name to all clients
	trig_skybox = self.message;
	trigger_skybox_change(self.enemy);	
};

//----------------------------------------------------------------------
void() trigger_skybox =
{
	self.classtype = CT_TRIGSKYBOX;
	self.classgroup = CG_TARGETS;

	// Check for firing conditions (nightmare, coop)
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	if (self.targetname == "") {
		dprint("\b[TRIG_SKYBOX]\b targetname missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	
	if (self.message == "") self.message = "Sky";

	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trigger_skybox_use;
	self.estate = ESTATE_ON;
};
//======================================================================
/*QUAKED trigger_itemrespawnupd (0.5 0 0.5) (-8 -8 -16) (8 8 16) x x x x RESPAWN x x x
Change the state of respawn flag on items
-------- KEYS --------
targetname : trigger entity
target  : this points to the item to affect
-------- SPAWNFLAGS --------
RESPAWN : Value of respawn flag to copy to item
-------- NOTES --------
Change the state of respawn flag on items
Useful for switching off respawning items after arena fight is over

======================================================================*/
void() trigger_itemrespawnupd_use =
{
	if (self.estate & ESTATE_BLOCK) return;

	// Loop around target(s) and update respawn flag
	self.enemy = find (world, targetname, self.target);
	while(self.enemy) {
		// only work with active items
		if (self.enemy.flags & FL_ITEM) {
			if (self.spawnflags & ITEM_RESPAWN) {
				self.enemy.spawnflags = self.enemy.spawnflags | ITEM_RESPAWN;
			}
			else {
				// Remove respawn flag (even if missing)
				self.enemy.spawnflags = self.enemy.spawnflags - (self.enemy.spawnflags & ITEM_RESPAWN);
			}
		}
		// Are there anymore targets left in the list?
		self.enemy = find (self.enemy, targetname, self.target);
	} 
};

//----------------------------------------------------------------------
void() trigger_itemrespawnupd =
{
	self.classtype = CT_TRIGITEMFLAG;
	self.classgroup = CG_TARGETS;

	// Check for firing conditions (nightmare, coop)
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	if (self.targetname == "") {
		dprint("\b[ITEM_RESPN]\b targetname missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	
	if (self.target == "") {
		dprint("\b[ITEM_RESPN]\b target missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trigger_itemrespawnupd_use;
	self.estate = ESTATE_ON;
};

//======================================================================
/*QUAKED trigger_monstermovespeed (0.5 0 0.5) (-8 -8 -16) (8 8 16) x
Toggle the monster move speed state
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target  : this points to the monster(s) to affect
state   : -1 = No movement, 0 = Toggle, 1 = Free movement
wait    : -1 = trigger once only
-------- SPAWNFLAGS --------
-------- NOTES --------
Toggle the monster move speed state

======================================================================*/
void() trigger_monstermovespeed_use =
{
	if (self.estate & ESTATE_BLOCK) return;

	// Loop around target(s) and update move speed
	self.enemy = find (world, targetname, self.target);
	while(self.enemy) {
		// only work with living monsters (ignore rest)
		if (self.enemy.flags & FL_MONSTER && self.enemy.health > 0) {
			// Is the state a toggle or exact update?
			if (self.state == 0) {
				if (self.enemy.movespeed < 1) self.enemy.movespeed = 1;
				else self.enemy.movespeed = -1;
			}
			// Exact value update
			else self.enemy.movespeed = self.state;
		}
		// Are there anymore targets left in the list?
		self.enemy = find (self.enemy, targetname, self.target);
	} 
	
	// Trigger once functionality?
	if (self.wait < 0) self.estate = ESTATE_OFF;
};

//----------------------------------------------------------------------
void() trigger_monstermovespeed =
{
	self.classtype = CT_TRIGMONMOVE;
	self.classgroup = CG_TARGETS;

	// Check for firing conditions (nightmare, coop)
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	if (self.targetname == "") {
		dprint("\b[MON_MOVESPD]\b targetname missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	
	if (self.target == "") {
		dprint("\b[MON_MOVESPD]\b target missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	
	// make sure state has the correct values
	if (self.state < -1 || self.state > 1) self.state = 0;

	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trigger_monstermovespeed_use;
	self.estate = ESTATE_ON;
};

//======================================================================
/*QUAKED trigger_monsterkill (0.5 0 0.5) (-8 -8 -16) (8 8 16) x x x x DEATH GIB x x
Remove monster(s) from the map
-------- KEYS --------
targetname : Name of this trigger entity
target  : Name of monster(s) to remove/stop
-------- SPAWNFLAGS --------
DEATH : kill monsters via death function
GIB   : Gib monsters via death function
-------- NOTES --------
Remove monster(s) from the map

======================================================================*/
void() trigger_monsterkill_use =
{
	if (self.estate & ESTATE_BLOCK) return;
	// This only works once!
	self.use = SUB_Null;

	// Loop around target(s) and remove the game
	self.enemy = find (world, targetname, self.target);
	while(self.enemy) {
		// There are always exceptions to the use of the monster flag
		// Point Hell knights don't use monster flag to prevent damage!
		if (self.enemy.spawnflags & MON_POINT_KNIGHT && self.enemy.health > 0) 
			self.enemy.flags = self.enemy.flags | FL_MONSTER;
		
		if (self.enemy.bossflag) {
			dprint("\b[MON_KILL]\b Not designed to work on bosses!\n");
			spawn_marker(self.origin, SPNMARK_YELLOW);
		}
		
		// only work with monsters, can't be dead, dying or negative health!
		if (self.enemy.flags & FL_MONSTER && self.enemy.health > 0 && !self.enemy.deadflag) {
			// Check if death function is required for monster
			// Also double check they have a death function setup!
			if (self.spawnflags & TRIG_MONKILLDFUNC && self.enemy.th_die) {
				// Quick way to make something gib, switch on the flag for it!
				if (self.spawnflags & TRIG_MONKILLGIB) self.enemy.gibondeath = TRUE;
				// Make sure monster can take damage
				self.enemy.takedamage = DAMAGE_YES;
				// Always do enough damage to kill the monster
				// Can be a problem for ammo resistant
				T_Damage (self.enemy, self, self, self.enemy.health+1, NOARMOR);
			}
			else {
				self.enemy.deadflag = DEAD_DEAD;
				self.enemy.enemy = world;
				self.enemy.health = self.enemy.gibhealth;

				// If a monster marked with no monster count dies
				// update HUD totals to reflect death properly
				if (self.enemy.nomonstercount) {
					total_monsters = total_monsters + 1;
					update_hud_totals(HUD_MONSTERS);
				}	
				// Update global monster death totals
				killed_monsters = killed_monsters + 1;
				WriteByte (MSG_ALL, SVC_KILLEDMONSTER);

				// Stop all animation think functions
				self.enemy.think = SUB_Null;
				self.enemy.nextthink = time + LARGE_TIMER;
				// Finally stop and hide all models
				// Should not remove monster, it might have dependancies
				entity_hide(self.enemy);
				entity_remove(self.enemy.attachment, 0.1);
				entity_remove(self.enemy.attachment2, 0.1);
				entity_remove(self.enemy.attachment3, 0.1);
			}
		}
		// Are there anymore targets left in the list?
		self.enemy = find (self.enemy, targetname, self.target);
	} 
};

//----------------------------------------------------------------------
void() trigger_monsterkill =
{
	self.classtype = CT_TRIGMONKILL;
	self.classgroup = CG_TARGETS;

	// Check for firing conditions (nightmare, coop)
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;
	
	if (self.targetname == "") {
		dprint("\b[MON_KILL]\b targetname missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	
	if (self.target == "") {
		dprint("\b[MON_KILL]\b target missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	
	// The gib function goes through the death function
	if (self.spawnflags & TRIG_MONKILLGIB)
		self.spawnflags = self.spawnflags | TRIG_MONKILLDFUNC;
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trigger_monsterkill_use;
	self.estate = ESTATE_ON;
};

//======================================================================
/*QUAKED trigger_monsterattack (0.5 0 0.5) (-8 -8 -16) (8 8 16) x
Force a monster to attack a certain target
-------- KEYS --------
targetname : Name of this trigger entity
target  : Name of monster to affect
target2 : Name of entity to attack
-------- SPAWNFLAGS --------
-------- NOTES --------
Force a monster to attack a certain target

======================================================================*/
void() trigger_monsterattack_use =
{
	if (self.estate & ESTATE_BLOCK) return;

	// Find target monster first and see if alive?
	self.enemy = find (world, targetname, self.target);
	// only work with monsters, can't be dead, dying or negative health!
	if (self.enemy.flags & FL_MONSTER && self.enemy.health > 0) {
		self.oldenemy = find(world, targetname, self.target2);
		// Check if attacking target is alive and can be damaged?
		if (self.oldenemy.health > 0 && self.oldenemy.takedamage != DAMAGE_NO) {
			// Setup monster to attack new target (use damage function)
			T_Damage (self.enemy, self.oldenemy, self.oldenemy, 1, NOARMOR);
		}
	} 
};

//----------------------------------------------------------------------
void() trigger_monsterattack =
{
	self.classtype = CT_TRIGMONATT;
	self.classgroup = CG_TARGETS;

	// Check for firing conditions (nightmare, coop)
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	if (self.targetname == "") {
		dprint("\b[MON_ATTACK]\b targetname missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	
	if (self.target == "") {
		dprint("\b[MON_ATTACK]\b target missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trigger_monsterattack_use;
	self.estate = ESTATE_ON;
};

//======================================================================
// General purpose sprite+particle explosion
// Entity is fired once (default)
//======================================================================
/*QUAKED trigger_explode (.8 .5 .5) (-4 -4 -4) (4 4 4) x EXPLODENOEFF DUST
Triggered entity producing damage + sprite explosion
-------- KEYS --------
targetname : trigger entity (works with entity state system)
dmg    : explosive radius damage (def=40, -1=no damage)
delay  : time delay to explosion (def=0s)
noise  : string name for explosion sound (def=weapons/r_exp3b.wav)
wait   : re-trigger explosions (def=-1 trigger once)
style  : 0=Explosion, 1=Plasma, 2=Poison, 3=Electric, 4=Burst (Smoke/Flame/Poison)
height : 0=Small, 1=Medium, 2=Large, -1=Random
count  : Random amount of dust particles to spawn (1-x)
pos1   : Base dust velocity (X=Forward, Y=Right, Z=Up)
pos2   : Random dust velocity (X=Forward, Y=Right, Z=Up)
-------- SPAWNFLAGS --------
EXPLODENOEFF : no old school particle explosion
DUST : Dust particle explosion (use angle for direction)
-------- NOTES --------
Triggered entity producing damage + sprite explosion

=============================================================================*/
void() trig_explode_fire =
{
	// Dust particles are empty models with rocket smoke trails
	if (self.spawnflags & TRIG_EXPLODEDUST) {
		// Setup direction of projectile
		makevectors(self.angles);
		// Always spawn at least 1 dust particle
		self.lip = 1 + rint(random() * self.count);
		while (self.lip > 0) {
			// Keep spawning temporary entities
			newmis = spawn();
			newmis.classgroup = CG_TEMPENT;
			newmis.movetype = MOVETYPE_TOSS;
			newmis.solid = SOLID_NOT;
			setmodel(newmis, MODEL_PROJ_SMOKE);
			
			// Randomize the origin of the particles
			self.oldorigin = self.origin + (v_right*(crandom()*self.pos1_y));
			setorigin(newmis, self.oldorigin);
			setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
			
			// Use pos1+pos2 vector (calculated from angles)
			self.pos3_x = self.pos1_x + ( random() * self.pos2_x );
			self.pos3_y = crandom() * (self.pos1_y + ( random() * self.pos2_y ));
			self.pos3_z = self.pos1_z + ( random() * self.pos2_z );
			newmis.velocity = (v_forward*self.pos3_x) + (v_right*self.pos3_y) + (v_up*self.pos3_z);
			
			// Setup removal and keep counting
			newmis.nextthink = time + 1 + random()*3;
			newmis.think = SUB_Remove;
			self.lip = self.lip - 1;
		}
		// No damage or sprites needed
		return;
	}
	
	// create any explosive radius damage	
	if (self.dmg > 0) T_RadiusDamage (self, self, self.dmg, self, DAMAGEALL);

	// Check for old particle effect
	if ( !(self.spawnflags & TRIG_EXPLODENOEFF) ) {
		// classic ID explosion
		if (self.style == 0) {
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_EXPLOSION);
			WriteCoord (MSG_BROADCAST, self.origin_x);
			WriteCoord (MSG_BROADCAST, self.origin_y);
			WriteCoord (MSG_BROADCAST, self.origin_z);
		}
		// New Rogue extension - Blue
		else if (self.style == 1) {
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_EXPLOSION2);
			WriteCoord (MSG_BROADCAST, self.origin_x);
			WriteCoord (MSG_BROADCAST, self.origin_y);
			WriteCoord (MSG_BROADCAST, self.origin_z);
			WriteByte (MSG_BROADCAST, 39);	// Blue 32 + 7
			WriteByte (MSG_BROADCAST, 8);	// Colour range
		}
		// New Rogue extension - Green
		else if (self.style == 2) {
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_EXPLOSION2);
			WriteCoord (MSG_BROADCAST, self.origin_x);
			WriteCoord (MSG_BROADCAST, self.origin_y);
			WriteCoord (MSG_BROADCAST, self.origin_z);
			WriteByte (MSG_BROADCAST, 55);	// Green 48 + 7
			WriteByte (MSG_BROADCAST, 8);	// Colour range
		}
	}

	// Check for randomly sized explosion type
	if (self.height == -1) self.lip = rint(0.5+ random() * 2.5);
	else self.lip = rint(self.height);
	// Work out explosion type offset
	self.lip = self.lip + rint(self.style) * 10;
	
	// Use global function (Fitz/DP aware)
	SpawnExplosion(self.lip, self.origin, self.noise);
};

//----------------------------------------------------------------------
void() trig_explode_use =
{
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;
	
	// Check for Trigger once setting
	if (self.wait < 0) self.attack_finished = LARGE_TIMER;
	
	// Check for explosion delay or straight away blow up
	if (self.delay > 0) {
		self.nextthink = time + self.delay;
		self.think = trig_explode_fire;
	}
	else trig_explode_fire();
};

//----------------------------------------------------------------------
void() trigger_explode =
{
	// Default settings
	self.classtype = CT_TRIGEXPLODE;
	self.classgroup = CG_TARGETS;

	// Check for firing conditions (nightmare, coop)
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	if (self.targetname == "") {
		dprint("\b[TRIG_EXP]\b targetname missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}

	if (self.dmg >= 0) self.dmg = DAMAGE_MONROCKET;
	if (self.wait == 0) self.wait = -1;
	if (self.height == 0 || self.height > 3) self.height = 1;
	if (self.style < 0 || self.style > 4) self.style = 0;
	self.attack_finished = 0;
	
	if (self.noise == "") {
		if (self.style == 3) self.noise = SOUND_PLASMA_HIT;
		else if (self.style == 4) self.noise = SOUND_RESIST_ROCKET;
		else self.noise = SOUND_REXP3;		// Default
	}
	precache_sound (self.noise);

	// Precache smoke particles and set default movement
	if (self.spawnflags & TRIG_EXPLODEDUST) {
		precache_model(MODEL_PROJ_SMOKE);
		if (CheckZeroVector(self.angles)) self.angles_y = 360;
		if (CheckZeroVector(self.pos1)) self.pos1 = '100 25 100';
		if (CheckZeroVector(self.pos2)) self.pos2 = '100 25 100'; 
	}		
	
	// Burst Sprites are NOT precached in world.qc
	if (self.style == 4) {
		// Check for random selection
		if (self.height == -1) {
			precache_model(SBURST_SMOKE);
			precache_model(SBURST_FLAME);
			precache_model(SBURST_POISON);
		}
		else if (self.height == 1) precache_model(SBURST_SMOKE);
		else if (self.height == 2) precache_model(SBURST_FLAME);
		else precache_model(SBURST_POISON);
	}

	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trig_explode_use;
	self.estate = ESTATE_ON;
};
