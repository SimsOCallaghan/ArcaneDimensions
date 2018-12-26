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
float TRIG_RANDOMTARGET = 2;	// Randomly trigger target/target2

/*======================================================================
/*QUAKED trigger_relay (0.5 0 0.5) (-8 -8 -8) (8 8 8) x RANDOM x x x x x x Not_Easy Not_Normal Not_Hard
Triggers target(s) with custom sounds and messages
-------- KEYS --------
targetname : trigger entity
target  : targets to trigger when relay is activated
target2 : secondary targets to trigger when activated
upgrade_ssg : = 1 will only trigger if shotgun upgrade active on server
upgrade_axe : = 1 will only trigger if axe upgrade active on server
upgrade_lg  : = 1 will only trigger if lightning gun upgrade active on server
wait    : -1 = will only fire targets once
delay   : delay before firing (after being triggered)
cnt     : random amount of time to add to delay
waitmin : % random chance between target/target2
sounds  : -1=Silent,1=Secret,2=talk(def),3=switch,4=secret2,5=custom
noise   : custom sound to play when triggered
message : message to display when triggered
-------- SPAWNFLAGS --------
RANDOM : Will randomly select between target/target2
-------- NOTES --------
This fixed size trigger cannot be touched, it can only be fired by other events.  
Can contain killtargets, targets, delays, and messages.

======================================================================*/
void() trigger_relay_use =
{
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;
	
	//----------------------------------------------------------------------
	// The Shotgun and Axe upgrades can make maps too easy, allow for
	// triggers to not fire if the key is TRUE and inventory empty
	//----------------------------------------------------------------------
	if ( other.flags & FL_CLIENT ) {
		if (self.upgrade_axe && !(other.moditems & IT_UPGRADE_AXE)) return;
		if (self.upgrade_ssg && !(other.moditems & IT_UPGRADE_SSG) ) return;
		if (self.upgrade_lg && !(other.moditems & IT_UPGRADE_LG) ) return;
	}

	// Setup to trigger once?
	if (self.wait < 0) self.attack_finished = LARGE_TIMER;
	if (self.noise != "") sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	// Randomly pick between target/target2
	// SUB_UseTargets will fire both target strings if found
	// the random choices need to be stored elsewhere (noise3/4)
	if (self.spawnflags & TRIG_RANDOMTARGET) {
		if (random() < self.waitmin) self.target = self.noise3;
		else self.target = self.noise4;
	}
	
	// One thing to note about trigger_relay is that it does not change the
	// activator global variable to the entity that used this trigger last
	// This is handy for client test triggers (like trigger_secret)
	SUB_UseTargets();
};

//----------------------------------------------------------------------
void() trigger_relay =
{
	trigger_bmodel_sounds();			// Precache any sounds
	self.classtype = CT_TRIGRELAY;
	if (self.delay <= 0) self.delay = 0;
	if (self.cnt > 0) self.delay = self.delay + random()*self.cnt;
	
	// Setup random trigger selection strings and random %
	// No checks are done on the target/target so that they can
	// be blank and the mapper can randomly select an empty trigger
	// only check = The random % has got to exist between 0-1
	if (self.spawnflags & TRIG_RANDOMTARGET) {
		if (self.waitmin <=0 || self.waitmin >= 1) self.waitmin = 0.5;
		self.noise3 = self.noise4 = "";		// Initialize strings
		self.noise3 = self.target;			// Copy over strings
		self.noise4 = self.target2;
		self.target = self.target2 = "";	// Remove originals
	}

	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trigger_relay_use;
	self.estate = ESTATE_ON;
};

/*======================================================================
/*QUAKED trigger_counter (0.5 0 0.1) (-8 -8 -8) (8 8 8) NOMESSAGE x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
A counter which triggers target(s) when complete
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target  : trigger target(s) when complete
message2: message to display when complete (ignores NOMESSAGE spawnflag)
count   : number of triggers needed to fire own target, (def=2)
delay   : time delay to fire final trigger event
sounds  : 0=silent,1=Secret,2=talk,3=switch,5=custom,6=secret2
noise   : custom sound to play when complete
-------- SPAWNFLAGS --------
NOMESSAGE : disables count display
STARTOFF : Requires trigger to activate
-------- NOTES --------
A counter which triggers target(s) when complete

======================================================================*/
void() trigger_counter_reset =
{
	// Reset counter to initial (spawning) value
	self.count = self.height;
};

//----------------------------------------------------------------------
void() trigger_counter_use =
{
	if (self.estate & ESTATE_BLOCK) return;
	self.count = self.count - 1;
	if (self.count < 0) return;
		
	// Count down messages for trigger
	if (self.count > 0) {
		if (activator.flags & FL_CLIENT && !(self.spawnflags & TRIG_COUNTNOMESSAGE) ) {
			if (self.count >= 4) centerprint (activator, "There are more to go...");
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
void() trigger_counter =
{
	trigger_bmodel_sounds();			// Precache any sounds
	if (!self.count) self.count = 2;	// default count
	self.height = self.count;			// Save for later, reset
	self.classtype = CT_TRIGCOUNT;

	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_reset = trigger_counter_reset;
	self.estate = ESTATE_ON;

	// The delay function is not switched off, its activate to use
	if (self.spawnflags & ENT_STARTOFF) self.estate_use = trigger_counter_delay;
	else self.estate_use = trigger_counter_use;
};

/*======================================================================
QUAKED trigger_monstermovespeed (0.5 0 0.5) (-8 -8 -16) (8 8 16) x
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
	if (self.target == "") {
		dprint("\b[MON_MOVESPEED]\b No target set, removing\n");
		remove(self);
	}
	
	// make sure state has the correct values
	if (self.state < -1 || self.state > 1) self.state = 0;

	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trigger_monstermovespeed_use;
	self.estate = ESTATE_ON;
};

/*======================================================================
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
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trigger_itemrespawnupd_use;
	self.estate = ESTATE_ON;
};

/*======================================================================
/*QUAKED trigger_monsterkill (0.5 0 0.5) (-8 -8 -16) (8 8 16) x
Remove monster(s) from the map
-------- KEYS --------
targetname : Name of this trigger entity
target  : Name of monster(s) to remove/stop
-------- SPAWNFLAGS --------
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
		// only work with monsters, can't be dead, dying or negative health!
		if (self.enemy.flags & FL_MONSTER && self.enemy.health > 0 && !self.enemy.deadflag) {
			self.enemy.deadflag = DEAD_DEAD;
			self.enemy.enemy = world;
			self.enemy.health = self.enemy.gibhealth;

			// Update kill counter if no exceptions!
			if (!self.enemy.nomonstercount) {
				killed_monsters = killed_monsters + 1;
				WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
			}

			// Stop all animation think functions
			self.enemy.think = SUB_Null;
			self.enemy.nextthink = time + LARGE_TIMER;
			// Finally stop and hide all models
			// Should not remove monster, it might have dependancies
			entity_hide(self.enemy);
			// Double check for any attachments
			if (self.enemy.attachment) entity_hide(self.enemy.attachment);
			if (self.enemy.attachment2) entity_hide(self.enemy.attachment2);
			if (self.enemy.attachment3) entity_hide(self.enemy.attachment3);
		}
		// Are there anymore targets left in the list?
		self.enemy = find (self.enemy, targetname, self.target);
	} 
};

//----------------------------------------------------------------------
void() trigger_monsterkill =
{
	self.classtype = CT_TRIGMONKILL;
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_use = trigger_monsterkill_use;
	self.estate = ESTATE_ON;
};

