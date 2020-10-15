/*======================================================================
 ITEM PROGRESSION SYSTEM
 
 * All spawn markers have the same item to pickup
 * The list determines the order the players gets items
 * Can only work with ITEM class types (no monsters etc)
 * The entity state system does not work with this system
 * Can have multiple progression lists in the same map
 * Extensive error and info checking reported to console
 * Works very closely with item touch2 functions
 
======================================================================*/
 
float PROG_NOTELEFX = 32;	// No teleport FX at spawn marker
 
//======================================================================
/*QUAKED item_progspawn (1 .8 .2) (-16 -16 0) (16 16 56) x x x x x NOTELEFX x x NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
Spawn location for progression list
-------- KEYS --------
targetname : Must exist and be the same for all markers in same list
target  : Must point to the first item in the progresion list
target2 : targets to fire when the spawn marker is used
message : message to display when triggered
-------- SPAWNFLAGS --------
NOTELEFX    : No tele FX effect when changing item at spawn marker
-------- NOTES --------
Spawn location for progression list

======================================================================*/
void(entity targ) item_proglist_setup =
{
	if (!(targ.flags & FL_ITEM)) return;// Only works with items

	targ.touch = targ.think = SUB_Null;	// No more thinking/animation
	targ.nextthink = -1;				// Never fire think
	targ.effects = 0;					// reset effects
	targ.modelindex = 0;				// Make sure no model
	setmodel (targ, "");				// invisible
	setsize (targ, VEC_ORIGIN, VEC_ORIGIN);	// No size, no impact
	targ.movetype = MOVETYPE_NONE;		// Stationary
	targ.solid = SOLID_NOT;				// no world interaction
	targ.estate = ESTATE_OFF;			// Entity state off
	targ.takedamage = DAMAGE_NO;		// No pain/death triggers
	targ.velocity = targ.avelocity = '0 0 0';	// Frozen inplace
};

//----------------------------------------------------------------------
void() item_progspawn_animateskin = 
{
	// Spawn marker turned off?
	if (self.state == STATE_OFF) return;
	// Skin animation disabled
	if (self.item_skinanim == FALSE) return;
	
	// Increase animation skin number, check range
	self.item_skinanim_no = self.item_skinanim_no + 1;
	if (self.item_skinanim_no > MODEL_ANIM_RANGE) {
		self.item_skinanim_no = 0;
	}
	// Update skin
	self.skin = self.item_skinanim_no;

	// Keep looping (slower than usual think timer)
	self.think = item_progspawn_animateskin;
	self.nextthink = time + (MODEL_ANIM_SPEED * 0.1);
};

//----------------------------------------------------------------------
void(vector org) item_progspawn_fx =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TELEPORT);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
};

//----------------------------------------------------------------------
void(entity targ) item_progspawn_off =
{
	targ.movetype = MOVETYPE_NONE;
	targ.solid = SOLID_NOT;
	setmodel (targ, "");
	setsize (targ, VEC_ORIGIN, VEC_ORIGIN);
	// Turn off any ammo lids
	if (targ.attachment) {
		setmodel(targ.attachment,"");
		setsize(targ.attachment, VEC_ORIGIN, VEC_ORIGIN);
	}
	// Turn off spawn marker and skin animation
	targ.state = STATE_OFF;
	targ.item_skinanim = FALSE;
	
	// Are particles enabled?
	if (query_configflag(SVR_PARTICLES) && targ.part_emitter)
		// Always switch particle emitter off
		misc_particle_off(targ.part_emitter);
};

//----------------------------------------------------------------------
void(entity targ, entity spnlist) item_progspawn_on =
{
	targ.movetype = MOVETYPE_NONE;
	targ.solid = SOLID_TRIGGER;
	targ.skin = targ.frame = 0;
	setmodel (targ, spnlist.mdl);
	setsize (targ, spnlist.bbmins, spnlist.bbmaxs);
	setorigin (targ, targ.oldorigin);
	targ.velocity = '0 0 0';
	targ.angles = '0 0 0';
	targ.state = STATE_ON;
	targ.estate = ESTATE_ON;

	// Keys, Runes and Artifacts are setup -24 map units lower
	// Shift the models back up by adding a double negative
	if (spnlist.bbmins_z < 0) targ.origin_z = targ.oldorigin_z - spnlist.bbmins_z;
	
	// Update particle emitter style
	targ.part_active = spnlist.part_active;
	targ.respawn_style = spnlist.respawn_style;
	targ.respawn_ofs = spnlist.respawn_ofs;

	// Some particle styles read item inventory
	targ.items = spnlist.items;
	targ.moditems = spnlist.moditems;
	
	// Are particles enabled? (quake.rc option)
	if (query_configflag(SVR_PARTICLES) == SVR_PARTICLES) {
		// Is item particle effects blocked?
		if (spnlist.spawnflags & ITEM_NOEFFECTS && targ.part_emitter)
			misc_particle_off(targ.part_emitter);
		// Is the particle style defined?
		else if (targ.part_active < 1 && targ.part_emitter)
			misc_particle_off(targ.part_emitter);
		// Can't do anything if no particle style
		else if (targ.part_active > 0) {
			// Has the particle emitter been created?
			if (!targ.part_emitter)
				targ.part_emitter = spawn_pemitter(targ, targ, targ.part_active, PARTICLE_START_ON);
			else {
				// Make sure the particle style is updated
				targ.part_emitter.part_style = targ.part_active;
				misc_particle_style(targ.part_emitter);
				misc_particle_on(targ.part_emitter);
			}
		}
	}
	
	// Setup special lid and frame poses for ammo boxes only
	if (spnlist.classgroup == CG_AMMOITEM) {
		// Setup random rotation or fixed angle (defined on item)
		if (spnlist.angles_y < 1) targ.angles_y = rint(random()*359);
		else targ.angles = spnlist.angles;
		
		// Setup extra frames for rockets/plasma
		if (spnlist.frame_override) {
			// frame options -1=random 0=nothing, 1-7=exact
			// Always generate a new frame number for respawning items
			if (spnlist.frame_box == -1) targ.frame = rint(1 + random()*6);
			else if (spnlist.frame_box > 7) spnlist.frame_box = 1;
			if (spnlist.frame_box > 0) targ.frame = spnlist.frame_box;
			// Turn off any ammo lids
			if (targ.attachment) {
				setmodel(targ.attachment,"");
				setsize(targ.attachment, VEC_ORIGIN, VEC_ORIGIN);
			}
		}
		// Setup lid attachment
		else if (spnlist.spawnflags & A_LID && spnlist.headmdl != "") {
			if (!targ.attachment) {
				targ.attachment = spawn();
				targ.attachment.owner = targ;
			}
			// Setup LID attachment entity (match angles/origin)
			targ.attachment.solid = SOLID_NOT;
			targ.attachment.movetype = targ.movetype;
			setmodel(targ.attachment, spnlist.headmdl);
			// Give the lid the same bbox setup so it can move
			setsize (targ.attachment, targ.mins, targ.maxs);
			// Start lid off the ground and remove ground flag
			// This will let the lid naturally settle on the surface
			setorigin(targ.attachment, targ.origin + '0 0 1');
			targ.attachment.flags = targ.attachment.flags - (targ.attachment.flags & FL_ONGROUND);
			// Match angle and stored frame setup from ammo box
			targ.attachment.angles = targ.angles;
			
			// lid frame options 0=random, 1-7=exact
			// Always generate a new lid position for respawning items
			if (spnlist.frame_box == 0) targ.attachment.frame = rint(1 + random()*6);
			else if (spnlist.frame_box > 7) spnlist.frame_box = 1;
			if (spnlist.frame_box > 0) targ.attachment.frame = spnlist.frame_box;
			
			// LID has different skins for shells and spikes
			if (targ.classtype == CT_AMMOSHELLS) targ.attachment.skin = targ.skin;
			else targ.attachment.skin = 2 + targ.skin;
		}
	}
	
	// Skin Exceptions and Animations
	if (spnlist.classgroup == CG_ARMOR) targ.skin = spnlist.skin;
	else if (spnlist.classgroup == CG_KEY) targ.skin = spnlist.skin;
	else if (spnlist.classtype == CT_AMMOITEMPACK) targ.skin = spnlist.exactskin;
	else if (spnlist.classgroup == CG_HEALTH && spnlist.item_skinanim) {
		targ.item_skinanim = spnlist.item_skinanim;
		targ.item_skinanim_no = 0;
		targ.think = item_progspawn_animateskin;
		targ.nextthink = time + 0.1;
	}
};

//----------------------------------------------------------------------
void() item_progspawn_touch =
{
	local entity oself;
	
	// ----------------------------------------------------------------
	// SELF  = spawn marker (only works once)
	// OTHER = always player (lots of checks at beginning)
	// SELF.OWNER = List Controller
	// SELF.OWNER.STATE = off means its finished or broken
	// SELF.OWNER.TARGET = Targetname of NEXT item in list
	// SELF.OWNER.MOVETARGET = Entity of NEXT item
	// SELF.OWNER.TARGET2 = Targetname of all spawn marker(s)	
	// ----------------------------------------------------------------
	
	// Duplicate of item_touch functionality
	if (self.touchedvoid) {entity_hide(self); return;}
	// Various player checks
	if ( !(other.flags & FL_CLIENT) ) return;
	if ( other.health < 1 ) return;
	if ( other.flags & FL_NOTARGET ) return;
	
	// Has been used ONCE already or disabled?
	if (self.state == STATE_OFF) return;
	// Is the progression list controller active?
	if (self.owner.state == STATE_OFF) return;

	// PICKUP CONDITIONS
	// ----------------------------------------------------------------
	if (self.owner.movetarget.classgroup == CG_HEALTH) {
		if (health_pickupcondition(other, self.owner.movetarget)) return;		
	}
	else if (self.owner.movetarget.classgroup == CG_ARMOR) {
		if (armor_pickupcondition(other, self.owner.movetarget)) return;		
	}
	else if (self.owner.movetarget.classgroup == CG_AMMOITEM) {
		if (ammo_pickupcondition(other, self.owner.movetarget)) return;
	}
	else if (self.owner.movetarget.classgroup == CG_KEY) {
		if (key_pickupcondition(other, self.owner.movetarget)) return;
	}
	else if (self.owner.movetarget.classgroup == CG_RUNE) {
		if (sigil_pickupcondition(self.owner.movetarget)) return;
	}
	
	// Spawn markers only work ONCE, switch it off
	item_progspawn_off(self);
	// Fire any targets/messages on the spawn marker
	if (self.target2 != "") trigger_strs(self.target2, other);
	if (self.message != "") centerprint (other, self.message);
	
	// ITEM FUNCTIONALITY
	// ----------------------------------------------------------------
	// Need to switch around self (item) otherwise the item touch
	// functions won't work. The .other should still be a player
	if (self.owner.movetarget.touch2) {
		oself = self; self = self.owner.movetarget;
		self.touch2();
		self = oself;
	}

	// PROGRESSION LIST (All error checking done in controller setup)
	// ----------------------------------------------------------------
	// Reached the end of the list?
	if (self.owner.movetarget.target == "") self.owner.state = STATE_OFF;
	else {
		// Find next entity in progression list
		self.goalentity = find(world, targetname, self.owner.movetarget.target);
		// Entity not found? -> end of list condition
		if (!self.goalentity) self.owner.state = STATE_OFF;
		else self.owner.movetarget = self.goalentity;
	}

	// SPAWN MARKERS
	// ----------------------------------------------------------------
	self.goalentity = find(world, targetname, self.owner.target2);
	while (self.goalentity) {
		// End of list? reset all markers to off
		if (self.owner.state == STATE_OFF) item_progspawn_off(self.goalentity);
		// List is active, check which spawn markers are active
		else if (self.goalentity.state == STATE_ON) {
			// Show teleporter particle effect?
			if (!(self.goalentity.spawnflags & PROG_NOTELEFX)) 
				item_progspawn_fx(self.goalentity.origin);
			// Switch marker to new item
			item_progspawn_on(self.goalentity, self.owner.movetarget);
		}
		// default = Spawn marked off/disabled
		else item_progspawn_off(self.goalentity);
			
		// Find next spawn marker in list
		self.goalentity = find(self.goalentity, targetname, self.owner.target2);
	}
};

//----------------------------------------------------------------------
void() item_proglist_controller_setup =
{
	local float error_ekey, error_flag, error_targ, error_spawn;
	local float exit_targ, respawn_spnflag, float_spnflag, coop_warning;
	
	// Setup counters for total list items and spawn markers
	self.waitmin = self.waitmin2 = 0;
	// Setup all error conditions
	error_ekey = error_flag = error_targ = error_spawn = FALSE;
	exit_targ = coop_warning = respawn_spnflag = float_spnflag = FALSE;

	// All these error checks are done on the controller so that
	// they only happen once, otherwise all spawn markers would
	// generate them to the console! (too much spam)
	//
	// CHECK progression list for errors
	self.sighttarget = self.target;
	self.goalentity = find(world, targetname, self.sighttarget);
	dprint("\b[-- Progression List Info --]\b\n"); 
	dprint("--------------------------------------\n");
	dprint("No Ekey Item Targ Class\n");
	while (self.goalentity) {
		// Increase counter and setup next target string
		self.waitmin = self.waitmin + 1;
		self.sighttarget = self.goalentity.target;
		
		// Zero pad list numbers (alignment reasons)
		if (self.waitmin < 9) dprint("0");
		dprint(ftos(self.waitmin));
		// All entities in list have to marked with new entity key
		if (self.goalentity.progspawnlist) dprint(" Yes ");
		else { dprint(" No  "); error_ekey = TRUE; }
		// All entities in list have to be ITEM class
		if (self.goalentity.flags & FL_ITEM) dprint(" Yes ");
		else { dprint(" No  "); error_flag = TRUE; }
		// Some entities don't work well with prog lists + coop
		if (self.goalentity.classgroup == CG_KEY) coop_warning = TRUE;
		// Don't need respawn or float spawnflags
		if (self.goalentity.spawnflags & ITEM_RESPAWN) respawn_spnflag = TRUE;
		if (self.goalentity.spawnflags & ITEM_FLOATING) float_spnflag = TRUE;
		
		// FATAL ERROR: Empty target strings when used with the
		// FIND command will return player entity instead of world!
		if (self.goalentity.target != "") dprint(" Yes ");
		else { dprint(" END "); exit_targ = TRUE; }
		// Finally show item class type (good for multiple lists)
		dprint(" "); dprint(self.goalentity.classname);
		dprint("\n");
		
		// Any FATAL exit conditions found yet?
		if (exit_targ) self.goalentity = world;
		else {
			// Find next entity in prog list
			self.goalentity = find(world, targetname, self.sighttarget);
			// Check for 2nd entity target being setup wrong
			if (self.waitmin == 1 && !self.goalentity) error_targ = TRUE;
		}
		
	}
	// Close table
	dprint("--------------------------------------\n");

	// CHECK spawn markers for errors
	self.goalentity = find(world, targetname, self.target2);
	while (self.goalentity) {
		// Count spawn markers
		self.waitmin2 = self.waitmin2 + 1;
		// All spawn markers need to be same entity type
		if (self.goalentity.classtype != CT_PROGSPAWN)
			error_spawn = TRUE;
		// Find next spawn marker
		self.goalentity = find(self.goalentity, targetname, self.target2);
	}
	
	// ERROR check if entity key is defined on all of list?
	if (error_ekey) {
		dprint("\b[PROG_LIST]\b missing progspawnlist key!\n");
		spawn_marker(self.movetarget.origin, SPNMARK_YELLOW);
		self.state = STATE_OFF;
	}
	// ERROR check if prog list contains wrong entity types?
	if (error_flag) {
		dprint("\b[PROG_LIST]\b wrong entity type!\n");
		spawn_marker(self.movetarget.origin, SPNMARK_YELLOW);
		self.state = STATE_OFF;
	}
	// ERROR check if progression list ONLY has 1 item
	if (self.waitmin == 1) {
		dprint("\b[PROG_LIST]\b Only 1 item in list!\n");
		spawn_marker(self.movetarget.origin, SPNMARK_YELLOW);
		self.state = STATE_OFF;
	}
	// ERROR check if 2nd item in list actually exists?
	if (self.waitmin == 1 && error_targ) {
		dprint("\b[PROG_LIST]\b 2nd list item missing!\n");
		spawn_marker(self.movetarget.origin, SPNMARK_YELLOW);
		self.state = STATE_OFF;
	}
	// WARNINGS if extra spawnflags are used on items
	if (respawn_spnflag)
		dprint("\b[PROG_LIST]\b RESPAWN spawnflag ignored!\n");
	
	// ERROR check if spawn markers contain wrong entity types?
	if (error_spawn) {
		dprint("\b[PROG_SPN]\b wrong entity type!\n");
		spawn_marker(self.movetarget.origin, SPNMARK_YELLOW);
		self.state = STATE_OFF;
	}
	// ERROR check if list & spawn totals match up?
	if (self.waitmin != self.waitmin2) {
		dprint("\b[TOTAL]\b List ("); dprint(ftos(self.waitmin));
		dprint(") Spn ("); dprint(ftos(self.waitmin2));
		dprint(") Dont match!\n");
		spawn_marker(self.movetarget.origin, SPNMARK_YELLOW);
		self.state = STATE_OFF;
	}

	// Any errors occured? - Close table
	if (self.state == STATE_OFF)
		dprint("--------------------------------------\n\n");
	else {
		// FINALLY Setup all spawn markers
		self.goalentity = find(world, targetname, self.target2);
		while (self.goalentity) {
			// Create touch functionality
			self.goalentity.touch = item_progspawn_touch;
			// Copy over first item in list to spawn marker
			item_progspawn_on(self.goalentity, self.movetarget);
			// Setup link back to controller
			self.goalentity.owner = self;
			// Find next spawn marker
			self.goalentity = find(self.goalentity, targetname, self.target2);
		}
		
		// Display progression list setup information
		dprint("\bTOTALS\b List ("); dprint(ftos(self.waitmin));
		dprint(") Spawns ("); dprint(ftos(self.waitmin2));
		dprint(")\n\n");
	}
};

//----------------------------------------------------------------------
void() item_proglist_controller = 
{
	// The first item in the progression list is unique, this
	// would be the perfect location for the controller.
	// Has it been setup yet?
	if (!self.movetarget.progspawncont) {
		self.movetarget.progspawncont = spawn();
		self.movetarget.progspawncont.classtype = CT_CONTROL;
		self.movetarget.progspawncont.classgroup = CG_PROGRESSION;
		self.movetarget.progspawncont.solid = SOLID_NOT;
		self.movetarget.progspawncont.movetype = MOVETYPE_NONE;
		setorigin(self.movetarget.progspawncont, self.movetarget.origin+'0 0 32');
		setsize(self.movetarget.progspawncont, VEC_ORIGIN, VEC_ORIGIN);
		// Always have a link to first item, as it can change
		self.movetarget.progspawncont.owner = self.movetarget;
		
		// TARGET (string)  = targetname of first item in list
		// MOVETARGET (ent) = entity pointer to start of list
		// TARGET2 (string) = spawn markers (never changes)
		
		// Start of the progression list
		self.movetarget.progspawncont.target = self.target;
		self.movetarget.progspawncont.movetarget = self.movetarget;
		// All Spawn marker(s) should be same name
		self.movetarget.progspawncont.target2 = self.targetname;
		
		// Start controller in ON state (errors switch it off)
		self.movetarget.progspawncont.state = STATE_ON;

		// Allow for all entities to spawn and link
		self.movetarget.progspawncont.nextthink = time + 0.5;
		self.movetarget.progspawncont.think = item_proglist_controller_setup;	
	}
};

//----------------------------------------------------------------------
void() item_progspawn_setup =
{
	// Cannot use this spawn if targetname missing
	if (self.targetname == "") {
		dprint("\b[PROG_SPN]\b targetname is missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		entity_hide(self);
		return;
	}
	// Target has to point to first item in list!
	if (self.target == "") {
		dprint("\b[PROG_SPN]\b target is missing!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		entity_hide(self);
		return;
	}	
	// Find target entity (Does entity actually exist!)
	self.movetarget = find(world, targetname, self.target);
	if (!self.movetarget) {
		dprint("\b[PROG_SPN]\b missing target entity!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		entity_hide(self);
		return;
	}
	// Spawn location ready for items
	self.state = STATE_ON;
	// Setup and enable controller entity
	item_proglist_controller();
};

//----------------------------------------------------------------------
void() item_progspawn =
{
	self.classtype = CT_PROGSPAWN;
	self.classgroup = CG_PROGRESSION;

	// No world interaction or movement
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	self.bbmins = self.bbmaxs = VEC_ORIGIN;
	setsize(self, self.bbmins, self.bbmaxs);
	self.oldorigin = self.origin;
	
	// reset all values to zero (used later)
	self.angles = '0 0 0';
	self.skin = self.frame = 0;
	self.velocity = self.avelocity = '0 0 0';
	self.state = STATE_OFF;
	
	// Allow time for everything to spawn
	self.nextthink = time + 0.1 + (random()*0.4);
	self.think = item_progspawn_setup;	
};
