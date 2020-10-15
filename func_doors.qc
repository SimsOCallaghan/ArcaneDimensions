//======================================================================
// STANDARD DOOR FUNCTIONS
//======================================================================
float DOOR_START_OPEN = 1;		// Work the opposite way around
float DOOR_SPAWN_TRIGGER = 2;	// Spawn open trigger regardless of targetname
float DOOR_DONT_LINK = 4;		// never link this door with anything
float DOOR_GOLD_KEY = 8;		// Gold Key
float DOOR_SILVER_KEY = 16;		// Silver Key
float DOOR_TOGGLE = 32;			// Need trigger to open AND close

//======================================================================
/*QUAKED func_door (0 .5 .8) ? STARTOPEN SPAWNTRIG DONTLINK GOLD SILVER TOGGLE STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Door (bmodel) with two states
-------- KEYS --------
targetname : = "" door automatically opens, != "" requires trigger to open
if using entity state system set SPAWN_TRIG spawnflags to fix this problem
target   : name of target(s) to trigger at the start opening sequence
angle    : determines the opening direction, use "360" for angle 0
angletarget : Entity (path_corner) to move towards (custom direction)
speed    : movement speed (def=100)
yaw_speed: return movement speed (def=speed)
wait     : wait before returning (def=3, -1 = never return)
lip      : lip remaining at end of move. (def=8)
height   : Exact distance to move (works like func_plat and uses angles)
midstart : Start in 2nd position and wait for trigger, then work as spawned
health   : Can be damaged instead of touched
dmg      : damage to inflict when blocked. (def=2)
message  : centerprint message when touched (removed when opened)
sounds   : 0=silent 1=stone 2=base 3=chain 4=metal 5=custom 11=base plat 12=med plat
locksounds : 0=talk 1=med1 2=med2 3=med3 13=trigger 14=silent 16=secret 21=base1 22=base2 23=base3 24=base4
noise    : custom sound - door locked sound (targetname+message)
noise1   : custom sound - Moving/Open door (looping)
noise2   : custom sound - Stop/Close door 
noise3   : custom sound - Silver/Gold key try lock
noise4   : custom sound - Silver/Gold key OPEN
volume   : Volume for all custom sounds played (def=1, range=0-1)
persistentkey : Key required for this door is never removed from player
customkey: custom key required to open door (1-4 supported values)
message2 : custom key message (You need the custom key)
bbmins   : custom size for generated trigger (def='-60 -60 -8')
bbmaxs   : custom size for generated trigger (def='60 60 8')
_dirt       : -1 = will be excluded from dirtmapping
_minlight   : Minimum light level for any surface of the brush model
_mincolor   : Minimum light color for any surface (def='1 1 1' RGB)
_shadow     : Will cast shadows on other models and itself
_shadowself : Will cast shadows on itself
-------- SPAWNFLAGS --------
STARTOPEN : door opens in reverse state (moved to dest at spawn)
SPAWNTRIG : Will spawn trigger around door even if targetname SETUP
DONTLINK  : Touching doors will not link into a single entity
GOLD      : Requires gold key to open
SILVER    : Requires silver key to open
TOGGLE    : Door waits for trigger between states (if wait=-1 cannot be blocked)
STARTOFF  : Starts off and waits for trigger
-------- NOTES --------
Door (bmodel) with two states

======================================================================*/

// Check for overlapping bound boxes
float (entity e1, entity e2) EntitiesTouching =
{
	if (e1.mins_x > e2.maxs_x) return FALSE;
	if (e1.mins_y > e2.maxs_y) return FALSE;
	if (e1.mins_z > e2.maxs_z) return FALSE;
	if (e1.maxs_x < e2.mins_x) return FALSE;
	if (e1.maxs_y < e2.mins_y) return FALSE;
	if (e1.maxs_z < e2.mins_z) return FALSE;
	return TRUE;
};

//----------------------------------------------------------------------
void() func_door_trigger_touch =
{
	if (self.owner.estate == ESTATE_BLOCK) return;
	if (self.owner.spawnflags & ENT_STARTOFF) return;
	if (other.health < 1) return;
	if (other.classtype == CT_FUNCBREAK) return;
	if (other.flags & FL_ITEM) return;
	if (time < self.attack_finished) return;
	self.attack_finished = time + 1;

	// Switch to parent (self) of trigger
	activator = other;
	self = self.owner;
	
	self.estate_use();	// func_door_use
};

//----------------------------------------------------------------------
entity(vector fmins, vector fmaxs) func_door_spawn_field =
{
	local entity trigger;
	local vector t1, t2;

	// Create trigger entity and link to parent (self)
	trigger = spawn();
	trigger.classtype = CT_FUNCDOORTRIG;
	trigger.bsporigin = TRUE;
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.owner = self;
	trigger.touch = func_door_trigger_touch;

	t1 = fmins;
	t2 = fmaxs;
	// Extend the X/Y size of the trigger +/- 60 units
	// Allow for custom sizes defined with bbmins/bbmaxs
	// Return the trigger entity to the previous function
	setsize (trigger, t1 + self.bbmins, t2 + self.bbmaxs);
	return (trigger);
};

//----------------------------------------------------------------------
void() func_door_angletarget =
{
	// Use sub function and return movetarget/dest1 values
	TargetMovedir(self, TRUE);
	// Need to use original spawn location because block functionality
	// will have the func_door in between state positions (origin)
	self.dest2 = self.oldorigin;
	
	// Check for height plat movement system instead
	if (self.height) {
		// Convert self dest2 to func_train corner bottom left offset)
		self.dest2 = self.dest2 - (self.size*0.5);
		// re-calculate the movedir (bec of self origin is different)
		// dest1 should be setup in TargetMovedir function
		self.movedir = normalize(self.dest1 - self.dest2);
		// Simple movement along vector length (no lip changes)
		// Not easy to predict in the editor because its the long side
		// of a trangle (other corners are func_door/angletarget)
		self.pos2 = self.pos1 + (self.movedir * self.height);
	}
	else {
		// Work out destination (using func_train bottom left offset)
		self.pos2 = self.pos1 + (self.dest1 - self.dest2) + (self.size*0.5);
	}		
};

//----------------------------------------------------------------------
void() func_door_final_setup =
{
	// Any angletarget entity key defined?
	if (self.angletarget != "") {
		// Upate second position based on angletarget
		func_door_angletarget();
		
		// Mid start requires second position
		if (self.midstart > 0) {
			setorigin (self, self.pos2);
			self.state = STATE_TOP;
		}
	}
	// Switch off the entity once setup has finished
	if (self.spawnflags & ENT_STARTOFF) self.estate_off();
};

//----------------------------------------------------------------------
// Link touching func_door entities
//----------------------------------------------------------------------
void() func_door_link =
{
	local entity linkdoor, master;
	local vector cmins, cmaxs;
	local float loopcondition;

	self.think = func_door_final_setup;
	self.nextthink = self.ltime + 0.1;

	// Door linking exceptions (self.enemy = already linked)
	if (self.enemy) return;

	// Setup bounding box for first door (master)
	cmins = self.mins; cmaxs = self.maxs;

	// lets give the do/while a proper exit condition
	loopcondition = TRUE;
	
	// Really important step, defining the master door
	master = self;
	linkdoor = self;
	
	while (loopcondition) 
	{
		// Always point all doors in the list to the master door
		// which is setup outside of the do/while loop
		self.owner = master;

		// Make sure all linked doors have the same health/targetname/message
		if (self.health) master.health = self.health;
		if (self.targetname != "") master.targetname = self.targetname;
		if (self.message != "") master.message = self.message;

		// For some reason the original ID code renamed doors and secret doors
		// to the same classname string and then created a list of both together
		// Not sure why anyone would want the two door types linked and it is
		// certainly not in any of the original ID maps.
		// Feature disabled - causes no end of state problems
		linkdoor = find (linkdoor, classname, self.classname);
		
		// reached end of list?
		if (!linkdoor) {
			self.enemy = master;	// make the chain a loop
			loopcondition = FALSE;

			// no more doors left to search, switch to the master door
			// It is always defined as the .owner field
			self = self.owner;
			
			// This is the conditions for a door getting automatic open trigger
			// Door CANNOT be damaged (shoot trigger) and NO key item required
			if (self.health == 0 && self.items == 0) {
				// Damn annoying that the targetname is being used like this because
				// there could have been a better way to do this type of functionality
				// == "" door has special trigger around to open door
				// != "" door requires trigger event to open
				if (self.targetname == "") 
					self.spawnflags = self.spawnflags | DOOR_SPAWN_TRIGGER; 
				
				if (self.spawnflags & DOOR_SPAWN_TRIGGER)
					self.owner.trigger_field = func_door_spawn_field(cmins, cmaxs);
			}
		}
		else {
			// Check if the bounding boxes are touching
			if (EntitiesTouching(self,linkdoor)) {
				// The .enemy field should be empty, otherwise its linked already
				// which is a bad situation because the chains will be corrupt
				// This will break the lots of later functions on
				// Solution - ignore the crosslink entity and carry on
				if (linkdoor.enemy) {
					// Exception: No link doors are setup to be linked to themselves!
					if ( !(linkdoor.spawnflags & DOOR_DONT_LINK)) { 
						dprint("\b[CROSSLINK]\b really bad situation, must fix!\n");
						dprint("-----------------------------------------------\n");
						eprint(linkdoor.enemy); 
						dprint("-----------------------------------------------\n\n");
					}
				}
				else {
					// Setup the next entity (linkdoor) in the list (self.enemy)
					// and move self forward to the new entity (linkdoor)
					self.enemy = linkdoor;
					self = linkdoor;

					// Expand touch trigger to include new door
					if (linkdoor.mins_x < cmins_x) cmins_x = linkdoor.mins_x;
					if (linkdoor.mins_y < cmins_y) cmins_y = linkdoor.mins_y;
					if (linkdoor.mins_z < cmins_z) cmins_z = linkdoor.mins_z;
					if (linkdoor.maxs_x > cmaxs_x) cmaxs_x = linkdoor.maxs_x;
					if (linkdoor.maxs_y > cmaxs_y) cmaxs_y = linkdoor.maxs_y;
					if (linkdoor.maxs_z > cmaxs_z) cmaxs_z = linkdoor.maxs_z;
				}
			}
		}
	}
};

//----------------------------------------------------------------------
// Phase 4 - Door CLOSED
//----------------------------------------------------------------------
void() func_door_hit_bottom =
{
	// Always reset midstart flag (its not longer needed)
	if (self.midstart) self.midstart = FALSE;
	if (self.estate == ESTATE_OFF) return;
	sound (self, CHAN_VOICE, self.noise1, self.volume, ATTN_NORM);
	self.state = STATE_BOTTOM;
	self.frame = 1 - self.frame;	//switch textures
};

//----------------------------------------------------------------------
// Phase 3 - Door closing
//----------------------------------------------------------------------
void() func_door_go_down =
{
	if (self.estate == ESTATE_OFF) return;

	if (self.max_health) {
		self.takedamage = DAMAGE_YES;
		self.health = self.max_health;
	}
	self.state = STATE_DOWN;
	sound (self, CHAN_VOICE, self.noise2, self.volume, ATTN_NORM);
	// Add - return speed can now be different, 
	// yaw_speed = speed if nothing defined
	SUB_CalcMove (self.pos1, self.yaw_speed, func_door_hit_bottom);
};

//----------------------------------------------------------------------
// Phase 2 - Door OPEN
//----------------------------------------------------------------------
void() func_door_hit_top =
{
	if (self.estate == ESTATE_OFF) return;
	sound (self, CHAN_VOICE, self.noise1, self.volume, ATTN_NORM);
	self.state = STATE_TOP;
	// don't come down automatically
	if (self.spawnflags & DOOR_TOGGLE) return;
	self.think = func_door_go_down;
	self.nextthink = self.ltime + self.wait;
};

//----------------------------------------------------------------------
// Phase 1 - Door opening
//----------------------------------------------------------------------
void() func_door_go_up =
{
	if (self.estate == ESTATE_OFF) return;
	if (self.state == STATE_UP) return;		// already going up

	if (self.state == STATE_TOP) {			// reset top wait time
		self.nextthink = self.ltime + self.wait;
		return;
	}

	//------------------------------------------------------------------
	// Check for custom movement using angletarget (entity target)
	if (self.angletarget != "") func_door_angletarget();
	
	sound (self, CHAN_VOICE, self.noise2, self.volume, ATTN_NORM);
	self.state = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, func_door_hit_top);

	SUB_UseTargets();
	self.frame = 1 - self.frame;	//switch textures
};

//----------------------------------------------------------------------
void() func_door_fire =
{
	local entity oself, starte;
	
	if (self.estate == ESTATE_BLOCK) return;
	if (self.owner != self) dprint ("\b[door_fire]\b self.owner != self\n");

	// Save for later (linked doors)
	oself = starte = self;

	// Check for mid start setup (waiting at pos2)
	if (self.midstart > 0) {
		// trigger all paired doors
		do {
			// Don't keep re-triggering midstart doors
			// Let the door reset back to pos1 (start position)
			if (self.state != STATE_DOWN) func_door_go_down ();
			self = self.enemy;
			// Prevent endless world loops
			if (self == world) self = starte;
		} while ( self != starte );
		self = oself;
		return;
	}
	
	// Check for exact state requests
	if (other.classtype == CT_TRIGDOORSTATE) {
		if (other.state == 0) {
			// Is the door closing (DOWN) or closed (BOTTOM)?
			if (self.state == STATE_DOWN || self.state == STATE_BOTTOM) return;
		}
		else {
			// Is the door opening (UP) or open (TOP)?
			if (self.state == STATE_UP || self.state == STATE_TOP) return;
		}
	}

	// play use key sound
	if (self.items) sound (self, CHAN_VOICE, self.noise4, self.volume, ATTN_NORM);

	self.message = string_null;		// no more message

	if (self.spawnflags & DOOR_TOGGLE) {
		if (self.state == STATE_UP || self.state == STATE_TOP) {
			starte = self; // Reset
			do {
				func_door_go_down ();
				self = self.enemy;
				// Prevent endless world loops
				if (self == world) self = starte;
			} while ( self != starte );
			self = oself;
			return;
		}
	}
	
	starte = self; // Reset
	// trigger all paired doors
	do {
		func_door_go_up ();
		self = self.enemy;
		// Prevent endless world loops
		if (self == world) self = starte;
	} while ( self != starte );
	self = oself;
};

//----------------------------------------------------------------------
void() func_door_use =
{
	local entity oself;

	// Deal with STARTOFF functionality first
	if (self.spawnflags & ENT_STARTOFF) self.estate_on();
	else {
		// Block USE functionality if state wrong
		if (self.estate & ESTATE_BLOCK) return;
		// Door messages are for touch functionality ONLY
		self.message = string_null;			
		self.owner.message = string_null;	
		self.enemy.message = string_null;
		// Switch to master door
		oself = self;
		self = self.owner;
		func_door_fire ();
		self = oself;
	}
};

//----------------------------------------------------------------------
void() func_door_killed =
{
	local entity oself;
	if (self.estate & ESTATE_BLOCK) return;
	
	oself = self;
	self = self.owner;
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;	// wil be reset upon return
	func_door_use ();
	self = oself;
};

//----------------------------------------------------------------------
// Only used for keys and messages
//----------------------------------------------------------------------
void() func_door_touch =
{
	if (self.estate & ESTATE_BLOCK) return;
	if ( !(other.flags & FL_CLIENT) ) return;
	if (self.owner.attack_finished > time) return;

	// Block touch trigger for 2 seconds
	self.owner.attack_finished = time + 2;

	// Does the door require any keys?
	if (self.items == 0) {
		// Any touch message to display?
		if (self.owner.message != "") {
			centerprint (other, self.owner.message);
			// Use custom lock sound (default = talktalk)
			sound (other, CHAN_VOICE, self.noise, self.volume, ATTN_NORM);
		}
	}
	// Check door for keys (silver/gold/custom)
	else {
		// Is this a custom locked door?
		if (self.moditems > 0) {
			if ( (self.moditems & other.moditems) != self.moditems ) {
				// Tell the player that a custom key is required
				// Use the message2 string instead of message1
				centerprint (other, self.message2);
				// Check for locksounds override
				if (self.locksounds > 0)
					sound (self, CHAN_VOICE, self.noise, self.volume, ATTN_NORM);
				// Default lock sound (based on worldspawn)
				else sound (self, CHAN_VOICE, self.noise3, self.volume, ATTN_NORM);
				return;
			}
			else {
				if (self.persistentkey == TRUE) 
					sprint(other, "You keep the key after use!\n");
				else {
					// Remove custom key from player/client
					other.moditems = other.moditems - self.moditems;
					// Tell the player that the custom key has been removed
					// Use the key item netname to reference the custom key
					// These netnames are updated when picking up the key
					sprint(other, "You used the ");
					if (self.moditems & IT_CKEY1 && other.ckeyname1 != "") sprint(other, other.ckeyname1);
					else if (self.moditems & IT_CKEY2 && other.ckeyname2 != "") sprint(other, other.ckeyname2);
					else if (self.moditems & IT_CKEY3 && other.ckeyname3 != "") sprint(other, other.ckeyname3);
					else if (self.moditems & IT_CKEY4 && other.ckeyname4 != "") sprint(other, other.ckeyname4);
					sprint(other, "\n");
				}
			}
		}
		else {
			// Does the player have the correct key? (silver/gold)
			if ( (self.items & other.items) != self.items ) {
				if (self.owner.items == IT_KEY1) {
					if (self.message2 != "") centerprint (other, self.message2);
					else if (self.worldtype == 1) centerprint (other, "You need the silver runekey");
					else if (self.worldtype == 2) centerprint (other, "You need the silver keycard");
					else centerprint (other, "You need the silver key");
				}
				else {
					if (self.message2 != "") centerprint (other, self.message2);
					else if (self.worldtype == 1) centerprint (other, "You need the gold runekey");
					else if (self.worldtype == 2) centerprint (other, "You need the gold keycard");
					else centerprint (other, "You need the gold key");
				}
				// Check for locksounds override
				if (self.locksounds > 0)
					sound (self, CHAN_VOICE, self.noise, self.volume, ATTN_NORM);
				// Default lock sound for silver/gold keys
				else sound (self, CHAN_VOICE, self.noise3, self.volume, ATTN_NORM);
				return;
			}
			else {
				if (self.persistentkey == TRUE) 
					sprint(other, "You keep the key after use!\n");
				else {
					// Tell the player that the key has been removed
					sprint(other, "You used the ");
					if (other.items & IT_KEY1) sprint(other, "Silver key\n");
					else sprint(other, "Gold key\n");
					// Take key from player inventory
					other.items = other.items - self.items;
				}
			}
		}

		// Turn off touch function		
		self.touch = SUB_Null;
		// turn off touch on pair/master door
		if (self.enemy) self.enemy.touch = SUB_Null;
		func_door_use ();
	}
};

//----------------------------------------------------------------------
void() func_door_on =
{
	// Stop re-triggering ON state
	if (self.estate == ESTATE_ON) return;

	// No longer need this spawnflag, remove it
	self.spawnflags = self.spawnflags - (self.spawnflags & ENT_STARTOFF);
	
	self.estate = ESTATE_ON;
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.mdl);
	self.velocity = '0 0 0';
	self.frame = self.frame_override;	// Reset to default
	
	// Reset Door position if NOT key or working once
	if (self.items == 0 && self.wait != -1) {
		setorigin(self, self.pos1);
		self.state = STATE_BOTTOM;
		self.think = SUB_Null;
	}
	// reset health and damage trigger
	if (self.max_health > 0) {
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
	}
};

//----------------------------------------------------------------------
void() func_door_off =
{
	// Stop re-triggering OFF state
	if (self.estate == ESTATE_OFF) return;

	self.estate = ESTATE_OFF;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, "");
	self.velocity = '0 0 0';
	self.takedamage = DAMAGE_NO;
	self.think = SUB_Null;

	// Stop all movement sounds
	sound (self, CHAN_VOICE, SOUND_EMPTY, self.volume, ATTN_NORM);
	
	// Reset Door position if NOT key or working once
	if (self.items == 0 && self.wait != -1) {
		setorigin(self, self.pos2);
		self.state = STATE_BOTTOM;
	}
};

//----------------------------------------------------------------------
void() func_door_disable =
{
	// Block damage function and show alternative texture
	self.takedamage = DAMAGE_NO;
	self.frame = 1 - self.frame_override;	// Turn off alt textures
};

//----------------------------------------------------------------------
void() func_door_reset =
{
	// If the door is still OFF then leave it
	if (self.spawnflags & ENT_STARTOFF) return;
	
	// Restore key functionality
	if (self.items > 0 ) {
		self.touch = func_door_touch;
		// switch on master door as well
		if (self.enemy) self.enemy.touch = func_door_touch;
	}

	// reset to original position
	setorigin(self, self.pos1);
	self.state = STATE_BOTTOM;
	self.attack_finished = 0;
	self.frame = self.frame_override;	// Reset Alt textures
	// Always reset midstart flag (position is wrong)
	if (self.midstart) self.midstart = FALSE;
	
	// Restore door to ON state
	self.estate = ESTATE_OFF;
	self.estate_on();
	self.think = SUB_Null;
};

//----------------------------------------------------------------------
void() func_door_blocked =
{
	// Always reset midstart flag (its no longer needed)
	if (self.midstart) self.midstart = FALSE;
	// Do the block damage
	T_Damage (other, self, self, self.dmg, DAMARMOR);
	// if a door has a negative wait, it would never come back if blocked,
	// so let it just squash the object to death real fast
	if (self.wait != -1) {
		if (self.state == STATE_DOWN) func_door_go_up ();
		else func_door_go_down ();
	}
};

//----------------------------------------------------------------------
void() func_door =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	// Setup all empty/silent sound files first
	if (self.noise1 == "") self.noise1 = SOUND_EMPTY;
	if (self.noise2 == "") self.noise2 = SOUND_EMPTY;

	// noise1 : Moving/Open door (looping)
	// noise2 : Stop/Close door 
	if (self.sounds == 1) {
		self.noise1 = "doors/drclos4.wav";
		self.noise2 = "doors/doormv1.wav";
	}
	else if (self.sounds == 2) {
		self.noise1 = "doors/hydro2.wav";
		self.noise2 = "doors/hydro1.wav";
	}
	else if (self.sounds == 3) {
		self.noise1 = "doors/stndr2.wav";
		self.noise2 = "doors/stndr1.wav";
	}
	else if (self.sounds == 4) {
		self.noise1 = "doors/ddoor2.wav";
		self.noise2 = "doors/ddoor1.wav";
	}
	// Sounds from func_plat (base sounds)
	else if (self.sounds == 11) {
		self.noise1 = "plats/plat2.wav";
		self.noise2 = "plats/plat1.wav";
	}
	// Sounds from func_plat (base sounds)
	else if (self.sounds == 12) {
		self.noise1 = "plats/medplat2.wav";
		self.noise2 = "plats/medplat1.wav";
	}

	// Check for any self worldtype override
	if (!self.worldtype) self.worldtype = world.worldtype;
	
	// Allow for custom sounds by checking noise3/4 string content first
	// Locked door sounds (silver, gold and custom keys)
	if (self.noise3 == "") {
		if (self.worldtype == 1) self.noise3 = "doors/runetry.wav";
		else if (self.worldtype == 2) self.noise3 = "doors/basetry.wav";
		else self.noise3 = "doors/medtry.wav";
	}
	if (self.noise4 == "") {
		if (self.worldtype == 1) self.noise4 = "doors/runeuse.wav";
		else if (self.worldtype == 2) self.noise4 = "doors/baseuse.wav";
		else self.noise4 = "doors/meduse.wav";
	}		

	// locked sound (targetname + message)
	if (self.noise == "") self.noise = SOUND_TALK;
	if (self.locksounds == 1) self.noise = "doors/rattle1.wav";
	else if (self.locksounds == 2) self.noise = "doors/rattle2.wav";
	else if (self.locksounds == 3) self.noise = "doors/rattle6.wav";
	else if (self.locksounds == 13) self.noise = "misc/trigger1.wav";
	else if (self.locksounds == 14) self.noise = SOUND_EMPTY; 
	else if (self.locksounds == 16) self.noise = "misc/secret3.wav";
	else if (self.locksounds == 21) self.noise = "doors/rattle_tech1.wav";
	else if (self.locksounds == 22) self.noise = "doors/rattle_tech2.wav";
	else if (self.locksounds == 23) self.noise = "doors/rattle_tech3.wav";
	else if (self.locksounds == 24) self.noise = "doors/rattle_tech4.wav";

	//Pre-cache all sounds
	precache_sound (self.noise);
	precache_sound (self.noise1);
	precache_sound (self.noise2);
	precache_sound (self.noise3);
	precache_sound (self.noise4);
	trigger_bmodel_volume(1);

	// Setup classtype and flag as BSP origin
	self.classtype = CT_FUNCDOOR;
	self.classgroup = CG_FUNCMOVER;
	self.bsporigin = TRUE;
	self.mdl = self.model;
	// Set angle/movedir and reset angles
	SetMovedir ();

	if (self.speed <=0) self.speed = 100;
	// Second movement speed can be different, yaw_speed
	if (self.yaw_speed <=0) self.yaw_speed = self.speed;
	if (!self.wait) self.wait = 3;
	if (!self.lip) self.lip = 8;
	if (!self.dmg) self.dmg = 2;
	self.state = STATE_BOTTOM;
	self.attack_finished = 0;
	
	// Default/Setup alternative texture frame
	if (!self.frame_override) self.frame_override = 0;
	self.frame = self.frame_override;

	//----------------------------------------------------------------------
	// Is the door locked via special keys (silver/gold)
	// Make sure any rogue entity keys are removed
	self.items = self.moditems = 0;
	if (self.spawnflags & DOOR_SILVER_KEY) self.items = IT_KEY1;
	else if (self.spawnflags & DOOR_GOLD_KEY) self.items = IT_KEY2;
	// Check for custom key requirement (only supports 1-4 types)
	else if (self.customkey > 0) {
		self.items = IT_KEY1 | IT_KEY2;
		if (self.message2 == "") self.message2 = "You need the custom key";
		if (self.customkey == 1) self.moditems = IT_CKEY1;
		else if (self.customkey == 2) self.moditems = IT_CKEY2;
		else if (self.customkey == 3) self.moditems = IT_CKEY3;
		else if (self.customkey == 4) self.moditems = IT_CKEY4;
		else {
			dprint("\b[FUNC_DOOR]\b Custom key value not supported\n");
			self.moditems = self.items = 0;
		}	
	}

	// key doors ONLY work once and have touch function
	if (self.items > 0) { 
		self.wait = -1;		// Work once
		self.health = 0;	// no shoot/damage
	}

	//----------------------------------------------------------------------
	// Add bmodel to world and work out movement positions
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setmodel (self, self.mdl);
	setorigin (self, self.origin);	
	setsize (self, self.mins , self.maxs);
	self.pos1 = self.origin;
	self.oldorigin = bmodel_origin(self);
	
	// Check for spawning conditions (nightmare, coop)
	// Needs to exist after entity has been added to work for BSPorigin
	if (check_nightmare() == TRUE) { entity_hide(self); return; }
	if (check_coop() == TRUE) { entity_hide(self); return; }

	// Only need to touch doors if require keys or centerprint messages
	if (self.items > 0 || self.message != "") self.touch = func_door_touch;
	self.blocked = func_door_blocked;

	// Check for QC created trigger bounding box override
	if (CheckZeroVector(self.bbmins)) self.bbmins = '-60 -60 -8';
	if (CheckZeroVector(self.bbmaxs)) self.bbmaxs = '60 60 8';
	
	//----------------------------------------------------------------------
	// Start open reverses pos1+2 which will screw up angletarget location
	// Disable this feature, reverse lifts can be setup easily if needed
	if (self.angletarget != "" && self.spawnflags & DOOR_START_OPEN) {
		dprint("\b[FUNC_DOOR]\b angletarget + start open not supported!\n");
		spawn_marker(self.oldorigin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	
	//----------------------------------------------------------------------
	// Check if height is defined? (used by func_plat)
	// Much easier system to setup, instead of voodoo lip magic!
	if (self.height > 0) self.pos2 = self.pos1 + (self.movedir*self.height);
	else {
		// Default movement system = move direction * (size - lip)
		self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);
	}

	//----------------------------------------------------------------------
	// DOOR_START_OPEN is design for an entity to be lit in the closed position
	// but spawn in the open position, also reversed door functions
	if (self.spawnflags & DOOR_START_OPEN) {
		setorigin (self, self.pos2);
		self.pos2 = self.pos1;
		self.pos1 = self.origin;
	}

	// Only enable damage trigger (die) if health set
	if (self.health) {
		self.max_health = self.health;
		self.takedamage = DAMAGE_YES;
		self.th_die = func_door_killed;
	}

	//----------------------------------------------------------------------
	// MIDSTART is designed for doors pretending to be func_plats
	// The door is moved to the 2nd position and paused until trigger
	// Once triggered the func_door will resume movement and go back
	// to the first position and work as a regular elevator/door!
	if (self.midstart > 0) {
		// If cannot be triggered without a targetname
		if (self.targetname == "") {
			dprint("\b[FUNC_DOOR]\b targetname required for midstart!\n");
			spawn_marker(self.oldorigin, SPNMARK_YELLOW);
			remove(self);
			return;
		}

		// Have to wait for angletarget ent to spawn
		if (self.angletarget == "") {
			// Move func_door into second position
			setorigin (self, self.pos2);
			self.state = STATE_TOP;
		}
	}
	
	//----------------------------------------------------------------------
	// Setup Entity State functionality
	// The 'USE' wrapper has to be setup, because after
	// the doors are linked they will all have targetnames!
	self.use = entity_state_use;
	self.estate_on = func_door_on;
	self.estate_off = func_door_off;
	self.estate_use = func_door_use;
	self.estate_disable = func_door_disable;
	self.estate_reset = func_door_reset;
	
	// Check for any (mapper) entity state setups (OFF/DISABLE)
	// Need targetname defined (can't active bmodel otherwise)
	// Not an ideal way to do this because estate values could change
	if (self.targetname != "" && self.estate > 0) {
		if (self.estate == ESTATE_OFF) 
			self.spawnflags = self.spawnflags | ENT_STARTOFF;
		// Unfortunately there is no start disabled functionality
		//if (self.estate == ESTATE_DISABLE)
	}
	// Default state
	else self.estate = ESTATE_ON;
	
	//----------------------------------------------------------------------
	// Light/Shadow switchable system, setup defaults
	if (self.switchshadstyle > 0) {
		dprint("\n[DOOR] Light style (");
		dprint(ftos(self.switchshadstyle));
		dprint(")\n\n");
		lightstyle(self.switchshadstyle, "a");
	}
	//----------------------------------------------------------------------
	// Doors cannot be linked until all bmodels have spawned and
	// bounding box sizes established, check for exceptions first
	if (self.spawnflags & DOOR_DONT_LINK) { 
		self.owner = self.enemy = self;
		
		// Need spawn delay if using angletarget (target not ready)
		if (self.angletarget != "") {
			// Check for any final setup conditions
			self.think = func_door_final_setup;
			self.nextthink = self.ltime + 0.1;
		}
		// Original setup, no delay on spawn
		else func_door_final_setup();
	}
	else {
		self.think = func_door_link;
		self.nextthink = self.ltime + 0.1;
	} 
};

//======================================================================
/*QUAKED trigger_doorstate (0.5 0 0.5) (-8 -8 -16) (8 8 16) x x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard
Trigger func_door(s) to exact state (open/close)
-------- KEYS --------
targetname : trigger this entity
target  : ALL target(s) must be func_door entities with toggle spawnflag!
state   : 0 or 1 func_door state (0=closed, 1=open)
wait    : -1 = will only fire targets once
-------- SPAWNFLAGS --------
STARTOFF : Requires trigger to activate
-------- NOTES --------
Trigger func_door(s) to exact state (open/close)

======================================================================*/
void() trigger_doorstate_use =
{
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;

	// Fire target(s)
	trigger_strs(self.target, self);
	
	// Setup to trigger once?
	if (self.wait < 0) self.attack_finished = LARGE_TIMER;	
};

//----------------------------------------------------------------------
void() trigger_doorstate_delay =
{
	if (self.estate & ESTATE_BLOCK) return;

	// Remove the trigger delay function
	if (self.spawnflags & ENT_STARTOFF)
		self.spawnflags = self.spawnflags - ENT_STARTOFF;
	
	// Re-route use function to actual counter
	self.estate_use = trigger_counter_use;
};

//----------------------------------------------------------------------
void() trigger_doorstate_setup =
{
	// entity check condition
	self.lefty = FALSE;
	
	// Search for func_door targets
	self.enemy = find(world, targetname, self.target);
	// Found any yet?
	while (self.enemy) {
		// Found a func_door?
		if (self.enemy.classtype == CT_FUNCDOOR) {
			// All func_door(s) require toggle spawnflag enabled
			if (self.enemy.spawnflags & DOOR_TOGGLE) self.lefty = TRUE;
			else {
				dprint("\b[TRIG_DOORSTATE]\b ");
				dprint(self.enemy.targetname);
				dprint(" missing toggle spawnflag!\n");
			}
		}
		// The whole list needs to be door entities
		else {
			dprint("\b[TRIG_DOORSTATE]\b Target ("); dprint(self.target);
			dprint(") ("); dprint(self.enemy.classname);
			dprint(") Wrong!\n");
			self.lefty = FALSE;
		}
		
		// Keep looping through the find list
		self.enemy = find(self.enemy, targetname, self.target);
	}
	
	// Found any errors with setup?
	if (self.lefty == FALSE) {
		spawn_marker(self.oldorigin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	
	// Finally setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	// The delay function is not switched off, its activate to use
	if (self.spawnflags & ENT_STARTOFF) self.estate_use = trigger_doorstate_delay;
	else self.estate_use = trigger_doorstate_use;
};

//----------------------------------------------------------------------
void() trigger_doorstate =
{
	self.classtype = CT_TRIGDOORSTATE;
	if (self.state < 0 || self.state > 1) self.state = 0;
	self.delay = self.sounds = 0;
	self.message = self.noise = "";
	self.nodebuginfo = TRUE;
	
	// This entity is called a lot from pressure plate entities
	// so it really needs to be setup right before use!
	// No target = hard error and warning message
	if (self.target == "") {
		dprint("\b[TRIG_DOORSTATE]\b Missing target!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	
	// Check for firing conditions (nightmare, coop)
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;
	
	// Double check targets are right type
	self.think = trigger_doorstate_setup;
	self.nextthink = time + 0.2;
};
