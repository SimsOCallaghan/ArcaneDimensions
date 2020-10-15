/*======================================================================
 SUB FUNCTIONS
======================================================================*/
void() SUB_Null = {};
void() SUB_Remove = {remove(self);};
void(entity inflictor, entity attacker, float damage) SUB_Null_pain = {};

void() SUB_CalcMoveDone;
void() SUB_CalcAngleMoveDone;

// subs_soc.qc
vector(vector attack_dir) attack_vector;
float(vector check_vec) CheckZeroVector;
vector(entity bmodel_ent) bmodel_origin;
void(vector marker_org, float marker_type) spawn_marker;
void(float hud_item) update_hud_totals;

//----------------------------------------------------------------------
// Some entities have directional parameters (angles -> movedir)
// This function searches for an angletarget entity (useful for tracking)
// Always finds the first target key (will fail if multiple targets)
//----------------------------------------------------------------------
void(entity targ, float return_target) TargetMovedir =
{
	local entity angle_dest;
	local vector targ_origin, angle_dest_origin;
	
	// Exit if no angletarget defined
	if (targ.angletarget == "") return;
	
	// Find angle target entity
	angle_dest = find(world, targetname, targ.angletarget);
	if (angle_dest) {
		// Check for Bmodel origin for targ/angle_dest
		if (targ.bsporigin) targ_origin = bmodel_origin(targ);
		else targ_origin = targ.origin;
		if (angle_dest.bsporigin) angle_dest_origin = bmodel_origin(angle_dest);
		else angle_dest_origin = angle_dest.origin;
		
		// Calculate facing angle towards target
		self.movedir = normalize(angle_dest_origin - targ_origin);
		
		// Return variables for calling function (def=FALSE)
		if (return_target) {
			self.movetarget = angle_dest;	// Target entity
			self.dest1 = angle_dest_origin;	// Target origin
		}
	}
};

//----------------------------------------------------------------------
void() TargetMovedirReturn = { TargetMovedir(self, TRUE); };

//----------------------------------------------------------------------
// QuakeEd only writes a single float for angles (bad idea), 
// so up and down are just constant angles.
//----------------------------------------------------------------------
void() SetMovedir =
{
	if (self.angles == '0 -1 0') self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0') self.movedir = '0 0 -1';
	else {
		makevectors (self.angles);
		self.movedir = v_forward;
	}
	// Bmodels need angles key reset otherwise twisted on spawn
	self.angles = '0 0 0';
};

/*======================================================================
InitTrigger
======================================================================*/
void() InitTrigger =
{
	// trigger angles are used for one-way touches.  An angle of 0 is assumed
	// to mean no restrictions, so use a yaw of 360 instead.
	if (!CheckZeroVector(self.angles)) SetMovedir();
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	self.mdl = self.model;		// Save model for later
	setmodel (self, self.mdl);	// set size and link into world
	self.bbmins = self.mins;	// Save bmodel bounds for later
	self.bbmaxs = self.maxs;
	self.bsporigin = TRUE;		// bmodel origin 0,0,0
	self.modelindex = 0;
	self.model = "";			// hide bmodel surface
};

/*======================================================================
SUB_CalcMove

calculate self.velocity and self.nextthink to reach dest from
self.origin traveling at speed
======================================================================*/
void() SUB_FacingAngle_Tick =
{
	// Decrease move/face time
	self.faceangle_time = self.faceangle_time - self.faceangle_div;
	// Is the movetime over? on to tidy up function
	if (self.faceangle_time <= 0) SUB_CalcMoveDone();
	else {
		// Adjust angles slowly to match final angle
		self.angles = self.angles + self.faceangle_inc;
		// The 'moving time' does not always divide perfectly
		// Allow for final remainder to be last division
		if (self.faceangle_time < self.faceangle_div)
			self.nextthink = time + self.faceangle_time;
		else self.nextthink = time + self.faceangle_div;
		// Keep ticking through this function
		self.think = SUB_FacingAngle_Tick;
	}
};

//----------------------------------------------------------------------
void(float movetime) SUB_FacingAngle_Setup =
{
	local vector facediff;
	local float divtime;
	
	// Convert angle difference to 0-360 scale
	facediff = vectormod(self.finalangle - self.angles);
	// Check for 0/360 boundary and reverse difference
	if (facediff_x > 180) facediff_x = facediff_x - 360;
	if (facediff_y > 180) facediff_y = facediff_y - 360;
	if (facediff_z > 180) facediff_z = facediff_z - 360;
	
	// Tick rate of 0.05 is 20fps, the engine will struggle with <0.02
	if (self.faceangle_div < 0.02) self.faceangle_div = 0.05;
	divtime = movetime / self.faceangle_div;
	self.faceangle_inc = facediff / divtime;
	
	self.faceangle_time = movetime;
	// Nothing has moved yet, so wait a bit
	self.nextthink = time + self.faceangle_div;
	self.think = SUB_FacingAngle_Tick;
};

//----------------------------------------------------------------------
void(vector tdest, float tspeed, void() func) SUB_CalcMove =
{
	local vector vdestdelta;
	local float len, traveltime;

	if (!tspeed) tspeed = 40;			// Create default speed if none specified
	self.think1 = func;					// Finished moving function
	self.finaldest = tdest;				// Final origin (Overwrite existing values)
	self.think = SUB_CalcMoveDone;		// Tidy up function

	vdestdelta = tdest - self.origin;	// set destdelta to the vector needed to move
	len = vlen (vdestdelta);			// calculate length of vector
	traveltime = len / tspeed;			// divide by speed to get time to reach dest

	// Check if faceangle is active on a func bmodel mover?
	if (self.faceangle > 0 && self.bsporigin > 0) self.faceangle = FALSE;
	
	// If move distance or time too small, snap to final location
	if (traveltime < 0.1 || tdest == self.origin) {
		if (self.faceangle > 0) self.angles = self.finalangle;
		self.velocity = '0 0 0';
		if (self.bsporigin > 0) self.nextthink = self.ltime + 0.1;
		else self.nextthink = time + 0.1;
		return;
	}
	
	// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = vdestdelta * (1/traveltime);	// qcc won't take vec/float
	if (self.bsporigin > 0) self.nextthink = self.ltime + traveltime;
	else self.nextthink = time + traveltime;
	
	// Check for any facing angle functionality
	if (self.faceangle > 0) SUB_FacingAngle_Setup(traveltime);
};

/*======================================================================
After moving, set origin to exact final destination
======================================================================*/
void()  SUB_CalcMoveDone =
{
	self.velocity = '0 0 0';
	setorigin(self, self.finaldest);
	self.nextthink = -1;
	if (self.think1) self.think1();
};

//----------------------------------------------------------------------
// Not used anywhere
//----------------------------------------------------------------------
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt =
{
	local entity	stemp;
	stemp = self;
	self = ent;

	SUB_CalcMove (tdest, tspeed, func);
	self = stemp;
};

/*======================================================================
SUB_CalcMoveEntity

calculate self.velocity and self.nextthink to reach dest from
self.origin traveling at speed
======================================================================*/
void() SUB_MoveEntityDone =
{
	self.movetype = self.classmove;
	SUB_CalcMoveDone();
};

//----------------------------------------------------------------------
void(vector tdest, float tspeed, void() func) SUB_CalcMoveEntity =
{
	local vector	vdestdelta;
	local float		traveltime;

	if (!tspeed) tspeed = 4;			// Create default travel time if none specified
	self.classmove = self.movetype;		// save previous movetype
	self.movetype = MOVETYPE_FLY;		// Allow entity to move smoothly
	self.think1 = func;					// Store final function
	self.finaldest = tdest;				// Store final destination
	
	vdestdelta = tdest - self.origin;	// set destdelta to the vector needed to move
	traveltime = 1 / tspeed;					// Work out percentage travel velocity
	self.velocity = vdestdelta * traveltime;	// Calc time travel fraction

	self.nextthink = time + tspeed;
	self.think = SUB_MoveEntityDone;
};

/*======================================================================
SUB_CalcAngleMove

calculate self.avelocity and self.nextthink to reach destangle from
self.angles rotating 

The calling function should make sure self.think is valid
======================================================================*/
void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove =
{
local vector	destdelta;
local float		len, traveltime;

	if (!tspeed)  dprint("[SUB_CALC_ANGLE] No speed is defined!");
		
	// set destdelta to the vector needed to move
	destdelta = destangle - self.angles;
	
	// calculate length of vector
	len = vlen (destdelta);
	
	// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

	// scale the destdelta vector by the time spent traveling to get velocity
	self.avelocity = destdelta * (1 / traveltime);
	
	self.think1 = func;
	self.finalangle = destangle;
	self.think = SUB_CalcAngleMoveDone;
};

/*======================================================================
After rotating, set angle to exact final angle
======================================================================*/
void() SUB_CalcAngleMoveDone =
{
	self.angles = self.finalangle;
	self.avelocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1();
};

//----------------------------------------------------------------------
// Not used anywhere
//----------------------------------------------------------------------
void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt =
{
	local entity		stemp;
	stemp = self;
	self = ent;
	SUB_CalcAngleMove (destangle, tspeed, func);
	self = stemp;
};

//----------------------------------------------------------------------
void() DelayThink =
{
	activator = self.enemy;
	SUB_UseTargets ();
	remove(self);
};

/*======================================================================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any self.message to the activator.

Removes all entities with a targetname that match self.killtarget,
and removes them, so some events can remove other triggers.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function

======================================================================*/
void() SUB_UseTargets =
{
	local entity t, stemp, otemp, act;

	//----------------------------------------------------------------------
	// Check for recursive loops!?!
	//----------------------------------------------------------------------
	if (self.targetname != "") {
		if (self.targetname == self.target || self.targetname == self.target2) {
			dprint("\n----------------------------------------\n");
			dprint("\b[USE_TARGET]\b target == targetname, really bad!!!\n");
			dprint(self.classname);
			dprint(" ("); dprint(self.targetname); dprint(") at "); 
			if (self.bsporigin) dprint(vtos(bmodel_origin(self)));
			else dprint(vtos(self.origin));
			dprint("\ntarg ("); dprint(self.target);
			dprint(") targ2 ("); dprint(self.target2);
			dprint(") kill ("); dprint(self.killtarget);
			dprint(")\n----------------------------------------\n");
			return;
		}
	}
	//----------------------------------------------------------------------
	// check for a delay
	//----------------------------------------------------------------------
	if (self.delay) {
	// create a temp object to fire at a later time
		t = spawn();
		t.classname = "DelayedUse";
		t.classtype = CT_TRIGRELAYDELAY;
		t.owner = self;
		t.nextthink = time + self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		t.target2 = self.target2;
		t.noise = self.noise;
		return;
	}
	
	//----------------------------------------------------------------------
	// Check if previous delay has been disabled
	// Unfortunately start off = OFF state and not easy to check for
	// because some entities use that spawnflag bit for other things!
	//----------------------------------------------------------------------
	if (self.classtype == CT_TRIGRELAYDELAY) {
		if (self.owner.estate & ESTATE_DISABLE) return;
	}
	
	//----------------------------------------------------------------------
	// print any messages
	//----------------------------------------------------------------------
	if (activator.flags & FL_CLIENT && self.message != "") {
		if (coop > 0) {
			// Write message to all clients
			msg_entity = self;
			WriteByte (MSG_ALL, SVC_CENTERPRINT);
			WriteString (MSG_ALL, self.message);
		}
		// Write message to single client
		else centerprint (activator, self.message);
		// Default noise = classic beep beep sound
		if (self.noise == "") 
			sound (activator, CHAN_VOICE, SOUND_TALK, 1, ATTN_NORM);
	}

	//----------------------------------------------------------------------
	// kill targets
	// I really do hate this function because there is hardly any checks
	// on entities being removed, added a player check for sanity!
	//----------------------------------------------------------------------
	if (self.killtarget != "") {
		t = find (world, targetname, self.killtarget);
		while(t) {
			// Check for activate monsters? Tidy up kill counter
			if (t.flags & FL_MONSTER && t.health > 0) {
				// If a monster marked with no monster count dies
				// update HUD totals to reflect death properly
				if (t.nomonstercount) {
					total_monsters = total_monsters + 1;
					update_hud_totals(HUD_MONSTERS);
				}	
				// Update global monster death totals
				killed_monsters = killed_monsters + 1;
				WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
			}
			// Added extra check to prevent player client removal!?!
			if (!(t.flags & FL_CLIENT)) {
				// Try to minimize the entity chain damage, check for
				// entity attachments and delete them as well!
				if (t.attachment) remove(t.attachment);
				if (t.attachment2) remove(t.attachment2);
				if (t.attachment3) remove(t.attachment3);
				// Make sure any unique ent number is reset
				if (t.entno_unique > 0) t.entno_unique = 0;
				// Remove entity from chain list
				remove (t);
			}
			// Find the next killtarget
			t = find (t, targetname, self.killtarget);
		} 
	}
	//----------------------------------------------------------------------
	// fire targets
	//----------------------------------------------------------------------
	if (self.target != "") {

		act = activator;	// ID Code - Never switch around, not sure why it is here?
		t = find (world, targetname, self.target);
		stemp = self; otemp = other;		// Store self/other
		while(t) {
			if (t.use != SUB_Null) {
				if (t.use) {
					self = t; other = stemp;		// Switch self/other
					self.activate = stemp;			// used by the breakable system
					self.use ();					// fire trigger
					self = stemp; other = otemp;	// restore self/other
					activator = act;		// ID code - Never changed, why restore it?
				}
			}
			// Are there anymore targets left in the list?
			t = find (t, targetname, self.target);
		} 
	}
	//----------------------------------------------------------------------
	if (self.target2 != "") {
		act = activator;	// ID Code - Never switch around, not sure why it is here?
		t = find (world, targetname, self.target2);
		stemp = self; otemp = other;		// Store self/other
		while(t) {
			if (t.use != SUB_Null) {
				if (t.use) {
					self = t; other = stemp;// Switch self/other
					self.activate = stemp;	// used mostly by the breakable system
					self.use ();			// fire trigger
					self = stemp; other = otemp;	// restore self/other
					activator = act;		// ID code - Never changed, why restore it?
				}
			}
			t = find (t, targetname, self.target2);
		} 
	}
};

/*======================================================================
 SUB_AttackFinished
	in nightmare mode, all attack_finished times become 0
	some monsters refire twice automatically (using .cnt variable)
	Change nightmare to be less range spam and better time scaling
======================================================================*/
void(float normal) SUB_AttackFinished =
{
	local float nightadj;	// Easier to work out percentage
	self.cnt = 0;			// reset checkfire counter
	
	// Nightmare skill attacks are faster (turret like) and with
	// hitscan enemies this can easily overwhelm targets locking
	// them into damage/pain function loops. This can especially be
	// be bad if a large enough enemy group is involved!
	// Changed - NM behaviour for boss fights is default
	//
	if (skill == SKILL_NIGHTMARE && self.enemy.bossflag == FALSE) {
		// Nightmare mode is just endless range attacks!
		// I never thought this was a good way to end skill levels
		// Changed nightmare mode to 50-75% decrease in time
		// Exceptions to nightmare mode (minion spawning) - 75-100% time
		nightadj = 0.5 + (random()*0.25);
		if (self.minion_active) nightadj = nightadj + 0.25;
		// The original ID shamblers were lightning turrets on Nightmare
		// Shamblers don't scale with skill levels in AD because
		// they don't have projectiles, so they need a switch instead
		// On Nightmare skill Shamblers go from 2-4s to 1s!
		// Instead of 2-4s, NM is 0.6-1.2s, Average 1.2s +2 frames
		if (self.classtype == CT_MONSHAM) nightadj = 0.4;
		self.attack_finished = time + (normal*nightadj);
	}
	// Easy, Nornal and Hard skill all pass through, no change
	else self.attack_finished = time + normal;
	//dprint("Time ("); dprint(ftos(time));
	//dprint(") AF ("); dprint(ftos(normal));
	//dprint(") Dif ("); dprint(ftos(self.attack_finished - time));
	//dprint(") Att ("); dprint(ftos(self.attack_finished));
	//dprint(")\n");
};

//----------------------------------------------------------------------
// Used by soliders and enforcers (special double fire mode)
//----------------------------------------------------------------------
void (void() thinkst) SUB_CheckRefire =
{
	if (skill != SKILL_NIGHTMARE) return;
	if (self.cnt == 1) return;
	if (!visible (self.enemy)) return;
	self.cnt = 1;
	self.think = thinkst;
};

//----------------------------------------------------------------------
// Not used anywhere in QC
//----------------------------------------------------------------------
/*float() SUB_CountTargets =
{
	local entity t;
	local float i;
	
	i = 0;
	if (self.target != "") {
		t = world;
		do	{
			t = find(t, targetname, self.target);
			if (!t) break;
			i = i + 1;
		} while ( 1 );
	}
	return i;
};*/

/*======================================================================
 ChooseTurn 
 - can't find any reference to this in the QC
======================================================================*/
/*void(vector dest3) ChooseTurn =
{
	local vector	dir, newdir;
	
	dir = self.origin - dest3;

	newdir_x = trace_plane_normal_y;
	newdir_y = 0 - trace_plane_normal_x;
	newdir_z = 0;
	
	if (dir * newdir > 0) {
		dir_x = 0 - trace_plane_normal_y;
		dir_y = trace_plane_normal_x;
	}
	else {
		dir_x = trace_plane_normal_y;
		dir_y = 0 - trace_plane_normal_x;
	}

	dir_z = 0;
	self.ideal_yaw = vectoyaw(dir);	
};*/

/*======================================================================
 SPAWN_TFOG and SPAWN_TDEATH
 
 These functions were originally in triggers.qc, but are used all
 over the place by monsters, items and players. Subs seems a better
 home for these generic functions.

 ======================================================================*/
void() play_teleport =
{
	self.lip = random() * 5;
	if (self.lip < 1) self.noise = "misc/r_tele1.wav";
	else if (self.lip < 2) self.noise = "misc/r_tele2.wav";
	else if (self.lip < 3) self.noise = "misc/r_tele3.wav";
	else if (self.lip < 4) self.noise = "misc/r_tele4.wav";
	else self.noise = "misc/r_tele5.wav";

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.nextthink = time + 2;	// Allow time for the sound to finish
	self.think = SUB_Remove;	// tidy up function
};

//----------------------------------------------------------------------
void(vector org) spawn_tfog =
{
	local entity spawneffect;
	
	spawneffect = spawn ();
	spawneffect.origin = org;
	spawneffect.nextthink = time + 0.2;
	spawneffect.think = play_teleport;

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TELEPORT);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
};

//----------------------------------------------------------------------
void() tdeath_touch =
{
	// Cannot telefrag yourself!?!
	if (other == self.owner) return;
	// Touch trigger has expired
	if (self.attack_finished < time) return;
	
	// Check if found a breakable than cannot be broken
	if (ai_foundbreakable(self, other, FALSE)) return;
		
	// A boss cannot be telefragged (except shub)
	// Telefrag entity trying to telefrag boss instead!?!
	if (other.bossflag == TRUE) {
		if (other.classtype == CT_MONIDSHUB) {
			// AD 1.8 for some reason this damage was setup wrong
			// Originally damaging self.owner, which is the spawner!
			// This should match the last T_Damage below
			T_Damage (other, self, self, MEGADEATH, NOARMOR);
			return;
		}
		else {
			// Cannot telefrag a boss!!! kill spawner instead
			dprint("[TELEFRAG] Entity ("); dprint(self.owner.classname);
			dprint(") cannot kill boss!\n");
			T_Damage (self.owner, self, self, MEGADEATH, NOARMOR);
			// Stop this trigger working
			self.attack_finished = 0;
			return;
		}
	}

	// frag anyone who teleports in on top of an invincible player
	if (other.flags & FL_CLIENT) {
		if (other.invincible_finished > time) self.classname = "teledeath2";
		// Force the owner (monster) to explode/die
		if ( !(self.owner.flags & FL_CLIENT) ) {
			T_Damage (self.owner, self, self, MEGADEATH, NOARMOR);
			return;
		}
	}

	// Sudden death incoming ...
	// This is damage/attacking any touching entity
	if (other.health) T_Damage (other, self, self, MEGADEATH, NOARMOR);
};

//----------------------------------------------------------------------
void(vector org, entity death_owner) spawn_tdeath =
{
	local entity death;

	death = spawn();
	death.classname = "teledeath";
	// Spawning monster (used for exceptions)
	death.owner = death_owner;
	death.movetype = MOVETYPE_NONE;
	death.solid = SOLID_TRIGGER;
	death.angles = '0 0 0';
	// Make sure the bbox is outside (+1 size) of the spawners bounding box
	setsize (death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
	setorigin (death, org);
	death.touch = tdeath_touch;
	// Don't keep the trigger around for long
	death.nextthink = time + 0.2;
	// Block timer on touch function
	death.attack_finished = time + 0.3;
	death.think = SUB_Remove;
	
	// This is extremely costly on the engine because it re-checks
	// every trigger in the map to see if it is touching something
	force_retouch = 2;
};
