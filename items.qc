//======================================================================
// ITEM FUNCTIONS
//======================================================================
/* Moved to defscustom.qc
float ITEM_RESPAWN = 16;	// Item will respawn
float ITEM_FLOATING = 32;	// Spawn floating
float ITEM_NOEFFECTS = 128;	// Disable particles and effects

float H_ROTTEN = 1;			// Rotten
float H_MEGA = 2;			// Mega Health
float A_LARGE = 1;			// Used by ammo boxes
float A_LID = 2;			// Display Lid

float BACKPACK_SHELLS = 1;
float BACKPACK_NAILS = 2;
float BACKPACK_ROCKETS = 4;
float BACKPACK_CELLS = 8;
float BACKPACK_GRNTYPE = 1;
float BACKPACK_YELTYPE = 2;
float BACKPACK_REDTYPE = 4;*/

float AIRTANK_SILENT = 8;	// No sound with airtank

float SKIN_BASE = 0;		// Green ammo boxes and square health packs
float SKIN_MEDIEVAL = 1;	// Wood ammo boxes and red health flasks

float ITEM_CKEY1 = 1;	// Arcane Key 1
float ITEM_CKEY2 = 2;	// Arcane Key 2
float ITEM_CKEY3 = 4;	// Arcane Key 3
float ITEM_CKEY4 = 8;	// Arcane Key 4

// Used for weapons only
string WEAPON_PICKUP = "weapons/pkup.wav";
// Used for ammo, custom items and backpacks
string AMMO_PICKUP = "weapons/lock4.wav";

// Various bounding boxes for items
// vector	VEC_ORID_MIN = '0 0 0';
// vector	VEC_ORID_MAX = '32 32 56';
vector	VEC_HEAL_MIN = '-16 -16 0';
vector	VEC_HEAL_MAX = '16 16 56';
vector	VEC_WPNS_MIN = '-16 -16 0';
vector	VEC_WPNS_MAX = '16 16 56';
vector	VEC_AMMO_MIN = '-16 -16 0';
vector	VEC_AMMO_MAX = '16 16 56';
vector	VEC_KEYS_MIN = '-16 -16 -24';
vector	VEC_KEYS_MAX = '16 16 32';
vector	VEC_POWR_MIN = '-16 -16 -24';
vector	VEC_POWR_MAX = '16 16 32';

// Default respawn timers for items
float RESPAWN_HEALTH = 20;			// 15,25,100+
float RESPAWN_ARMOR = 20;			// Green, Yellow, Red
float RESPAWN_WEAPON = 30;			// SG -> LG
float RESPAWN_AMMO = 30;			// Shells,Nails,Rockets,Cells
float RESPAWN_KEY = 60;				// Gold,Silver,Custom
float RESPAWN_RUNE = 60;			// Sigil/runes
float RESPAWN_ARTIFACT1 = 60;		// Quad + Suit
float RESPAWN_ARTIFACT2 = 300;		// Pent + Invisibilty
float RESPAWN_BACKPACK = 30;		// Random Ammo Drop
float RESPAWN_COOP = 5;				// Default timer for coop

float RESPAWN_PARTICLES = 32;		// Particle burst for ring/center
float RESPAWN_EXPTIME = 1;			// Particles burst lifetime
float RESPAWN_EXPRADIUS = 12;		// Particle ring radius

float MODEL_ANIM_SPEED = 3;
float MODEL_ANIM_RANGE = 3;

//----------------------------------------------------------------------
// Some items have pickup conditions which prevent targets
// from firing when coop mode is active, show console warning
//----------------------------------------------------------------------
void() item_coopcheck =
{
	// coop active?
	if (coop <= 0) return;
	// Coop checks for prog list done elsewhere
	if (self.progspawnlist) return;
	// Check for any target(s) on coop sensitive items?
	if (self.target != "" || self.target2 != "") {
		dprint("\b[Coop]\b (");
		dprint(self.classname);
		dprint(") unreliable target(s) in coop!\n");
	}
};

//----------------------------------------------------------------------
// Setup skin parameter for ammo and health items
//----------------------------------------------------------------------
// world.worldtype			Model style				Skin
// 0 = default (Medieval)	wood / flasks			1
// 1 = runic / metal		wood / flasks			1
// 2 = base					green / square packs	0
//
// skin_override			Model style				Skin
// 0 = default				-						-
// 1 = base					green / square packs	0
// 2 = Medieval				wood / flasks			1
//----------------------------------------------------------------------
float(entity targ) item_skintype =
{
	// Go through medieval exceptions based on table above
	if (world.worldtype == 0 && !targ.skin_override) return SKIN_MEDIEVAL;
	else if (world.worldtype == 1 && !targ.skin_override) return SKIN_MEDIEVAL;
	else if (targ.skin_override == 2) return SKIN_MEDIEVAL;
	else return SKIN_BASE;
};

//----------------------------------------------------------------------
// Check floor under item and animated skin for new BASE health boxes
//----------------------------------------------------------------------
void() item_thinkloop =
{
	// Check for entity states
	if (self.estate & ESTATE_BLOCK) return;
	// Has the item been turned off?
	if (self.attack_finished > time) return;
	// Has the item removal timer been reached?
	if (self.item_expired > 0 && self.item_expired < time) remove(self);
	
	if (self.item_skinanim > 0) {
		self.item_skincycle = self.item_skincycle + 1;
		if (self.item_skincycle > MODEL_ANIM_SPEED) {
			self.item_skincycle = 0;
			self.item_skinanim_no = self.item_skinanim_no + 1;
			if (self.item_skinanim_no > MODEL_ANIM_RANGE) {
				self.item_skinanim_no = 0;
			}
		}
		// Update skin
		self.skin = self.item_skinanim_no;
	}

	// Check floor below item (global function)
	if (self.item_flrcheck > 0) {
		ent_floorcheck(self, self.item_flrcheck);
		// Record any movement for respawn function
		self.oldorigin = self.origin;
	}

	// Keep checking
	self.think = item_thinkloop;
	self.nextthink = time + 0.1;
};

void() item_estate_setup;
//----------------------------------------------------------------------
void() item_reset =
{
	// Reset trigger_once conditions
	self.attack_finished = 0;
	if (!self.estate_on) item_estate_setup();
	self.estate_on();
};

//----------------------------------------------------------------------
void() item_debugcustomdl =
{
	if (self.mdl != "") {
		dprint("\b[ITEMS]\b "); dprint(self.classname);
		dprint(" with Custom mdl ("); dprint(self.mdl);
		dprint(")\n");
		spawn_marker(self.origin+'0 0 32', SPNMARK_GREEN);
	}
};

//----------------------------------------------------------------------
void() item_finished =
{
	// Check for coop respawn options
	// This system can easily be abused by switching coop on/off
	// But its better the respawns are added, rather than not
	if (coop > 0) {
		if (self.classgroup == CG_WEAPON) {
			// This is just crazy back to front logic!
			// The id default is respawning weapons for coop
			// Which means coop_weapons is FALSE when TRUE!!!
			if (coop_weapons == FALSE && self.respawn_time > 0) {
				// make sure weapon respawn timer is lower for coop
				if (self.respawn_time > RESPAWN_COOP) self.respawn_time = RESPAWN_COOP;
				self.spawnflags = self.spawnflags | ITEM_RESPAWN;
			}
		}
		else if (self.classgroup == CG_HEALTH) {
			if (coop_health == TRUE && self.respawn_time > 0)
				self.spawnflags = self.spawnflags | ITEM_RESPAWN;
		}
		else if (self.classgroup == CG_AMMOITEM) {
			if (coop_ammoboxes == TRUE && self.respawn_time > 0)
				self.spawnflags = self.spawnflags | ITEM_RESPAWN;
		}
		else if (self.classgroup == CG_ARTIFACT) {
			if (coop_powerups == TRUE && self.respawn_time > 0)
				self.spawnflags = self.spawnflags | ITEM_RESPAWN;
		}
	}

	self.attack_finished = LARGE_TIMER;
	if (!self.estate_off) item_estate_setup();
	self.estate_off();
};

//----------------------------------------------------------------------
void() item_respawn =
{
	// Classic quake re-spawn sound
	sound (self, CHAN_VOICE, SOUND_RESPAWN, 1, ATTN_NORM);

	// Are particles enabled?
	if (query_configflag(SVR_PARTICLES)) {
		// Switch off any respawn emitter
		if (self.respawn_part.classtype == CT_PARTICLEEMIT)
			misc_particle_off(self.respawn_part);

		if (self.respawn_style & PARTICLE_BURST_RING) 
			particle_ring(self.origin + self.respawn_ofs, '0 0 4', '4 4 16', RESPAWN_EXPRADIUS, RESPAWN_PARTICLES, RESPAWN_EXPTIME, self.respawn_style ); 
		else if (self.respawn_style & PARTICLE_BURST_CENTER)
			particle_explode(self.origin + self.respawn_ofs, RESPAWN_PARTICLES*2, RESPAWN_EXPTIME, self.respawn_style, self.respawn_style); 
	}

	self.alpha = 1;
	self.estate_reset();
};

//----------------------------------------------------------------------
// Re-direction for map hacks (not used normally)
//----------------------------------------------------------------------
void() SUB_regen = {
//	self.model = self.mdl;
//	self.solid = SOLID_TRIGGER;
	sound (self, CHAN_VOICE, SOUND_RESPAWN, 1, ATTN_NORM);
//	setorigin (self, self.origin);
	item_reset();
};

//----------------------------------------------------------------------
void() alphafade_item_respawn =
{
	if (self.waitmin > time) {
		self.speed = 1 - ((self.waitmin - time) / self.respawn_time);
		self.alpha = 0.1 + ((self.speed*0.4)*random());

		// If respawn effect active, modify total particles
		if (self.respawn_part.part_style == PARTICLE_STYLE_RESPAWN) {
			self.respawn_part.part_limit = rint(RESPAWN_PARTICLES * self.speed);
		}
		self.think = alphafade_item_respawn;
		self.nextthink = time + 0.1;
	}
	else item_respawn();
};

//----------------------------------------------------------------------
void() start_item_respawn =
{
	// Is the item being respawned at the moment?
	if (self.waitmin > time) return;
	// Is the item setup to instantly respawn?
	if (self.respawn_trig == TRUE && self.spawnflags & ITEM_RESPAWN) {
		// Check for any respawn quantity counts
		if (self.respawn_count > 0) {
			self.respawn_count = self.respawn_count - 1;
			if (self.respawn_count == 0) 
				self.spawnflags = self.spawnflags - (self.spawnflags & ITEM_RESPAWN);
		}
		// Instantly spawn item
		item_respawn();
	}
	else {
		// deathmatch 2 is the silly old rules
		if (deathmatch == 1 || self.spawnflags & ITEM_RESPAWN) {
			setmodel(self,self.mdl);
			setsize (self, self.bbmins, self.bbmaxs);
			self.waitmin = time + self.respawn_time;
			self.alpha = 0.1;

			// Check for any respawn quantity counts
			if (self.respawn_count > 0) {
				self.respawn_count = self.respawn_count - 1;
				if (self.respawn_count == 0) 
					self.spawnflags = self.spawnflags - (self.spawnflags & ITEM_RESPAWN);
			}
			
			// Are particles enabled?
			if (query_configflag(SVR_PARTICLES)) {
				// Switch off any particle emitters
				if (self.part_emitter) misc_particle_off(self.part_emitter);
				// Is there any need for respawn effect?
				if (self.respawn_effect) {
					// If emitter does not exist? create one, else switch on
					if (self.respawn_part.classtype == CT_PARTICLEEMIT)
						misc_particle_on(self.respawn_part);
					else self.respawn_part = spawn_pemitter(self, self, PARTICLE_STYLE_RESPAWN, PARTICLE_START_ON);
				}
			}
			// Switch on gradual alpha fade
			alphafade_item_respawn();
		}
	}
};

//----------------------------------------------------------------------
void() check_item_respawn =
{
	// Respawn feature is waiting for trigger
	if (!self.respawn_trig) start_item_respawn();
};

//----------------------------------------------------------------------
void() item_use =
{
	// Check for any trigger respawn conditions first
	// Respawn spawnflag, trigger condition and not trigger once
	if (self.spawnflags & ITEM_RESPAWN && self.respawn_trig &&
		self.estate == ESTATE_OFF) start_item_respawn();
	else {
		// usual trigger blocks, OFF, DISABLE and trigger_ONCE
		if (self.estate & ESTATE_BLOCK) return;
		if (self.attack_finished > time) return;

		// Was item setup to be floating?
		if(self.spawnflags & ITEM_FLOATING){
			// Removed checkbottom check, it often fails and leaves
			// items floating in midair when they should fall
			// if (!checkbottom(self)) - left for comment only
			// A quick toss of the item
			self.movetype = MOVETYPE_TOSS;	
			self.origin_z = self.origin_z + 4;
			self.flags = self.flags - (self.flags & FL_ONGROUND);
		}
	}
};

//----------------------------------------------------------------------
void() item_touch =
{
	if (self.touchedvoid) {entity_hide(self); return;}
	if (self.estate & ESTATE_BLOCK) return;
	
	if ( !(other.flags & FL_CLIENT) ) return;
	if ( other.health < 1 ) return;
	if ( other.flags & FL_NOTARGET && map_notargetblock == 0) return;
	if (self.attack_finished > time) return;
	
	self.touch2();	// defined by item function
};

//----------------------------------------------------------------------
void() item_restore =
{
	// Ammo boxes can have special animation frames or lids!
	if (self.classgroup == CG_AMMOITEM) {
		// Any LID (shells/spikes) defined?
		if (self.spawnflags & A_LID && self.attachment) {
			// Setup LID attachment entity (match angles/origin)
			self.attachment.solid = SOLID_NOT;
			self.attachment.movetype = self.movetype;
			setmodel(self.attachment, self.headmdl);
			// Give the lid the same bbox setup so it can move
			setsize (self.attachment, self.mins, self.maxs);
			// Start lid off the ground and remove ground flag
			// This will let the lid naturally settle on the surface
			setorigin(self.attachment, self.origin + '0 0 1');
			self.attachment.flags = self.attachment.flags - (self.attachment.flags & FL_ONGROUND);
			// Match angle and stored frame setup from ammo box
			self.attachment.angles = self.angles;
			
			// lid frame options -1/0=random, 1-7=exact
			// Always generate a new lid position for respawning items
			if (self.frame_box <= 0) self.attachment.frame = rint(1 + random()*6);
			else if (self.frame_box > 7) self.frame_box = 1;
			if (self.frame_box > 0) self.attachment.frame = self.frame_box;
			
			// LID has different skins for shells and spikes
			if (self.classtype == CT_AMMOSHELLS) self.attachment.skin = self.skin;
			else self.attachment.skin = 2 + self.skin;
		}
		// Any special frames (rockets/plasma) defined?
		else if (self.frame_override) {
			// frame options -1=random 0=nothing, 1-7=exact
			// Always generate a new frame number for respawning items
			if (self.frame_box == -1) self.frame = rint(1 + random()*6);
			else if (self.frame_box > 7) self.frame_box = 1;
			if (self.frame_box > 0) self.frame = self.frame_box;
		}
	}
	
	// Setup animated textures for old style ID health boxes
	// Check floor under item for any changes
	if (self.item_flrcheck > 0 || self.item_skinanim > 0) {
		self.nextthink = time + random()*0.5;
		self.think = item_thinkloop;
	}
};

//----------------------------------------------------------------------
void() item_delay =
{
	if (self.touchedvoid) {entity_hide(self); return;}
	if (self.estate == ESTATE_DISABLE) return;
	
	// Reset use function and any touch/skin triggers
	self.estate_use = item_use;
	self.touch = item_touch;
	self.attack_finished = 0;
	self.estate = ESTATE_ON;
	// Setup enough parameters to test drop to floor
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	setmodel(self,self.mdl);
	setsize (self, self.bbmins, self.bbmaxs);
	setorigin(self, self.oldorigin);
	self.velocity = '0 0 0';
	
	// Check if item is floating? = does not interact with world
	if(self.spawnflags & ITEM_FLOATING) {
		// Cannot check the floor of an item if its floating!?!
		if (self.item_flrcheck > 0) self.item_flrcheck = 0;
	}
	else {
		// Finalize item location (check drop to floor)
		// Need this movetype for items to move with bmodels
		self.movetype = MOVETYPE_TOSS;	
		self.velocity = '0 0 0';
		self.origin_z = self.origin_z + 6;
		// ID originally used a droptofloor test for space check
		// Tried a pointcontents check but it can allows things
		// to fall through the floor and just keep going
		//if (pointcontents(self.origin) == CONTENT_SOLID) {
		if (!droptofloor()) {
			dprint ("\n\b[Item]\b "); dprint (self.classname);
			dprint (" stuck at ("); dprint (vtos(self.origin)); dprint (")\n");
			spawn_marker(self.origin, SPNMARK_YELLOW);
			// The item is stuck, might still be useful to the player
			// Originally the item was removed which is not super useful
			// The mapper should see the console warning and yellow marker
			// Changed to check for origin in solid instead
			if (pointcontents(self.origin) == CONTENT_SOLID) {
				remove(self); return;
			}
		} 
	}

	// Toss velocity is designed for breakable objects to spawn items
	// Will add forward/up velocity to an item so it does not get stuck
	// Has to happen after the droptofloor otherwise position is wrong
	if (self.item_tossvel > 0) {
		// Make sure item can fly/move
		self.movetype = MOVETYPE_TOSS;	
		self.velocity = '0 0 0';
		// Must remove onground flag otherwise velocity does nothing
		self.flags = self.flags - (self.flags & FL_ONGROUND);
		// Push the item in the angle direction
		makevectors(self.angles);
		self.velocity = v_forward * self.item_tossvel;
		// Push the item upward to make it travel
		self.velocity_z = self.velocity_z + self.item_tossvel;
	}

	// If check floor under item enabled, workout distance check
	// The bottom of the bounding box + 16 for large step
	if (self.item_flrcheck > 0) {
		self.item_flrcheck = fabs(self.mins_z) + 16;
	}
	
	// Spawn particle emitter if particles active and not blocked
	if (query_configflag(SVR_PARTICLES) == SVR_PARTICLES) {
		if (!(self.spawnflags & ITEM_NOEFFECTS) && self.part_active > 0) {
			self.part_emitter = spawn_pemitter(self, self, self.part_active, PARTICLE_START_ON);
		}
	}
	
	// Finally setup entity ready for use
	self.oldorigin = self.origin;
	
	// Remove the START OFF functionality
	if (self.spawnflags & ENT_STARTOFF) {
		self.spawnflags = self.spawnflags - ENT_STARTOFF;
		// Check for respawn effect?
		if (self.spawnflags & ITEM_RESPAWN) start_item_respawn();
		else item_restore();
	}
	else item_restore();
};

//----------------------------------------------------------------------
void() item_on =
{
	self.estate = ESTATE_ON;
	self.movetype = MOVETYPE_NONE;

	// Restore any effect flags settings (various dlight glows)
	if (self.savedeffects > 0) self.effects = self.savedeffects;
	
	// Check for delayed/trigger_once functionality?
	if (self.spawnflags & ENT_STARTOFF || self.attack_finished > time)
		self.solid = SOLID_NOT;
	else {
		// Restore movement, solid and model parameters
		if(self.spawnflags & ITEM_FLOATING) self.movetype = MOVETYPE_NONE;
		else self.movetype = MOVETYPE_TOSS;
		self.solid = SOLID_TRIGGER;
		setmodel(self,self.mdl);
		setsize (self, self.bbmins, self.bbmaxs);
		self.velocity = '0 0 0';
		// Restore particle emitter
		if (self.part_emitter) misc_particle_on(self.part_emitter);
		// Setup touch/damage/bounding box functionality
		self.think = SUB_Null;
		item_restore();
	}
};

//----------------------------------------------------------------------
void() item_off = 
{
	self.estate = ESTATE_OFF;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel(self,"");
	self.effects = 0;
	setsize(self, VEC_ORIGIN, VEC_ORIGIN);
	// If item was setup to float then it will be trigger item
	// Don't reset origin as it might have fallen somewhere better
	if( !(self.spawnflags & ITEM_FLOATING) ) setorigin(self, self.oldorigin);
	
	if (self.attachment) {
		setmodel(self.attachment,"");
		setsize(self.attachment, VEC_ORIGIN, VEC_ORIGIN);
	}
};

//----------------------------------------------------------------------
void() item_estate_setup =
{
	// check for map hacks (redirects to item_delay)
	if (self.use == SUB_regen) self.use = SUB_regen;
	// Setup Entity State functionality
	else if (self.targetname != "") self.use = entity_state_use;
	self.estate_on = item_on;
	self.estate_off = item_off;
	self.estate_use = item_delay;
	self.estate_reset = item_reset;
};

//----------------------------------------------------------------------
void() item_start =
{
	self.oldorigin = self.origin;		// Save origin
	self.movetype = MOVETYPE_NONE;		// Static item, no movement
	self.flags = self.flags | FL_ITEM;

	// Warning if effects flag is active before spawning
	if (self.effects) {
		dprint("\b[ITEM]\b Effects flag active\n");
		self.savedeffects = self.effects;
	}
	// Reset effects flag because some engines will show effects
	// This is especially obvious for delay spawned items
	self.effects = 0;
	
	// If respawn timer negative then wait for a trigger
	if (self.respawn_time < 0) self.respawn_trig = TRUE;
	// Respawn times < 1 break sound and particle spawners
	if (self.respawn_time > 0 && self.respawn_time < 1) self.respawn_time = 1;
	// Cannot start with a negative number for counting down
	if (self.respawn_count < 0) self.respawn_count = 1;

	// Override default item pickup sound with silence?
	// It would have been good to offer the other sounds (1-6)
	// on all items, but there is a good chance that a mapper
	// has left a rogue sounds key on some item somewhere!
	if (self.sounds == 4) self.noise = SOUND_EMPTY;

	// Check if item is part of a progression spawner list
	// Hide all progression items, only required for caching
	if (self.progspawnlist) item_proglist_setup(self);
	else {
		// Check for spawning conditions (nightmare, coop)
		if (check_nightmare() == TRUE) return;
		if (check_coop() == TRUE) return;
	
		// Setup Entity State functionality
		item_estate_setup();

		if (self.spawnflags & ENT_STARTOFF) self.estate_off();
		else {
			// delay drop to floor to make sure all doors have been spawned
			// spread think times so they don't all happen at same time
			self.nextthink = time + 0.1 + random()*0.5;
			self.think = self.estate_use;
		}
	}
};

//======================================================================
// HEALTH FLASK/BOX
//======================================================================
float(entity hpplayer, entity hpitem) health_pickupcondition =
{
	// Simple test first, player dead?
	if (hpplayer.health <= 0) return TRUE;
	
	// Mega Health pickups are awkward because the player can keep
	// picking them up, unless they are at max HP already!
	if (hpitem.classtype == CT_HEALMEGA) {
		if (hpplayer.health >= hpplayer.mega_health) return TRUE;
	}
	// Regular Health pack can be wasteful with amount
	else if (hpplayer.health >= hpplayer.max_health) return TRUE;
	// Health Pack good to use!
	return FALSE;
};

//----------------------------------------------------------------------
// targ - entity to receive healing
// t_healamount - the quanity to heal entity with
// ignore - whether to ignore max health amount
// returns FALSE if cannot heal entity by healamount
// returns TRUE if healamount applied
//
float (entity targ, float t_healamount, float ignore) T_Heal =
{
	if (targ.health <= 0) return FALSE;
	if ((!ignore) && (targ.health >= other.max_health)) return FALSE;
	t_healamount = ceil(t_healamount);
	
	targ.health = targ.health + t_healamount;
	if ((!ignore) && (targ.health >= other.max_health))
		targ.health = other.max_health;
		
	if (targ.health > targ.mega_health) targ.health = targ.mega_health;
	return TRUE;
};

//----------------------------------------------------------------------
void() health_touch =
{
	local string s;

	// Megahealth?  Ignore max_health...
	if (self.classtype == CT_HEALMEGA) {
		if (other.health >= other.mega_health) return;
		if (!T_Heal(other, self.healamount, 1)) return;
	}
	else { 
		if (!T_Heal(other, self.healamount, 0)) return;
	}
		
	// Check for randomizer megahealth
	health_touchrandomizer();

	// Healing the player negates some debuffs
	ResetDebuffBurning(other);
	ResetDebuffPoisoned(other);

	sprint(other, "You receive ");
	s = ftos(self.healamount);
	sprint(other, s);
	sprint(other, " health\n");
	if (self.noise != SOUND_EMPTY) 
		sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	activator = other;
	SUB_UseTargets();

	// Megahealth = rot down the player's super health
	// Moved functionality to debuff (rotting) system
	// Rotting_Qty is set to zero (default) on item spawn
	if (self.classtype == CT_HEALMEGA) RotDeBuff(other, self.rotting_qty);

	// Quick exit, no need for following stuff
	if (self.progspawnlist) return;

	item_finished();
	check_item_respawn();
};	

//----------------------------------------------------------------------
/*QUAKED item_health (0.3 0.3 1) (-16 -16 0) (16 16 32) ROTTEN MEGA x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/health_25.mdl"); }
15, 25 or 100 Health
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
angle         : = -1 Random rotation everytime spawned (default)
skin_override : Override world type 1=Base Green, 2=Medieval Wood
healamount    : Override heal quantity for pickup (def=15/25/100)
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
ROTTEN   : 15 health
MEGA     : MegaHealth +100 health, rot down to 100
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Health box gives 15, 25 or 100 points depending on spawnflags.
*/
//----------------------------------------------------------------------
void() item_health =
{
	// Check for any random monster setups
	if (health_checkrandomizer() == TRUE) return;
	
	if (self.spawnflags & H_ROTTEN) {
		// worldtype 0 = medieval, 1 = metal, 2 = base
		if (item_skintype(self) == SKIN_MEDIEVAL) {
			// New Medieval style red flask
			self.mdl = MODEL_HEAL15;
			self.respawn_style = PARTICLE_BURST_RED + PARTICLE_BURST_RING;
		}
		else {
			// Original ID pickup model
			self.mdl = MODEL_HEAL15B;
			self.respawn_style = PARTICLE_BURST_WHITE + PARTICLE_BURST_RING;
		}
		self.noise = SOUND_HEAL15;
		if (self.healamount < 1) self.healamount = HEAL_ROT;
		self.classtype = CT_HEALROT;
		self.respawn_effect = TRUE;
		self.respawn_ofs = '0 0 16';
	}
	else if (self.spawnflags & H_MEGA) {
		if (item_skintype(self) == SKIN_MEDIEVAL) {
		// New Medieval style red flask
			self.mdl = MODEL_HEAL100;
			self.respawn_style = PARTICLE_BURST_RED + PARTICLE_BURST_RING;
		}
		else {
			// Original ID pickup model
			self.mdl = MODEL_HEAL100B;
			self.respawn_style = PARTICLE_BURST_WHITE + PARTICLE_BURST_RING;
			self.item_skinanim = TRUE;
		}
		self.noise = SOUND_HEAL100;
		if (self.healamount < 1) self.healamount = HEAL_MEGA;
		self.classtype = CT_HEALMEGA;
		self.part_active = PARTICLE_STYLE_MEGAH;
		self.respawn_effect = TRUE;
		self.respawn_ofs = '0 0 28';
		// Use default rotting value
		self.rotting_qty = 0;
	}
	else {
		if (item_skintype(self) == SKIN_MEDIEVAL) {
			// New Medieval style red flask
			self.mdl = MODEL_HEAL25;
			self.respawn_style = PARTICLE_BURST_RED + PARTICLE_BURST_RING;
			self.respawn_ofs = '0 0 24';
		}
		else {
			// Original ID pickup model
			self.mdl = MODEL_HEAL25B;
			self.respawn_style = PARTICLE_BURST_WHITE + PARTICLE_BURST_RING;
			self.respawn_ofs = '0 0 16';
			self.item_skinanim = TRUE;
		}
		self.noise = SOUND_HEAL25;
		if (self.healamount < 1) self.healamount = HEAL_NORM;
		self.classtype = CT_HEALNORM;
		self.respawn_effect = TRUE;
	}

	precache_model(self.mdl);
	precache_sound(self.noise);

	// Query console variable 'temp1' for model upgrade option.
	// Cannot use global vars because they don't exist at this point
	// Move the new centered ammo models to match old ammo origin
	// The default is to move all ammo items to suit original id maps
	if (query_configflag(SVR_ITEMOFFSET) == FALSE) {
		self.oldorigin = self.origin + '16 16 0';
		setorigin(self, self.oldorigin);
	}

	// An old worldspawn key (not used anymore)
	// This is backward compatibility with this key
	// Will force all items to have an angle
	if (world.no_item_rotate && self.angles_y == 0) self.angles_y = 360;	
	
	// Setting the angle key in the editor to UP/DOWN/0 = random rotation	
	if (self.angles_y <= 0) self.angles_y = rint(random()*359);

	self.touch2 = health_touch;
	self.classgroup = CG_HEALTH;
	self.bbmins = VEC_HEAL_MIN;
	self.bbmaxs = VEC_HEAL_MAX;
	if (self.respawn_time == 0) self.respawn_time = RESPAWN_HEALTH;

	// Check for coop errors
	item_coopcheck();
	item_start ();
};

//----------------------------------------------------------------------
/*QUAKED item_healthvial (0.3 0.3 1) (-8 -8 0) (8 8 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/health_5.mdl"); }
Health item giving 2-5 points
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
angle         : = -1 Random rotation everytime spawned (default)
healamount    : Override heal quantity for pickup (def=2+random*3)
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN   : Can respawn after being picked up
FLOAT     : No drop to floor test
STARTOFF  : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Health item giving 5 points
*/
//----------------------------------------------------------------------
void() item_healthvial =
{
	self.classtype = CT_HEALVIAL;
	self.respawn_effect = TRUE;
	self.respawn_ofs = '0 0 20';

	self.mdl = MODEL_HEAL5;
	//if (self.healamount < 1) self.healamount = HEAL_GEM;
	if (self.healamount < 1) self.healamount = rint(2 + (random() * 3));
	self.noise = SOUND_HEAL05;

	precache_model(self.mdl);
	precache_sound(self.noise);
	self.respawn_style = PARTICLE_BURST_RED + PARTICLE_BURST_CENTER;

	self.touch2 = health_touch;
	self.classgroup = CG_HEALTH;
	self.bbmins = '-8 -8 0';
	self.bbmaxs = '8 8 32';
	if (self.respawn_time == 0) self.respawn_time = RESPAWN_HEALTH;

	// Check for coop errors
	item_coopcheck();
	item_start ();
};

// Used to be called a gem, renamed to vial
void() item_healthgem = { item_healthvial(); }

//======================================================================
// armor_touch
//======================================================================
float(entity armplayer, entity armitem) armor_pickupcondition =
{
	local float arm1, arm2;
	
	arm1 = armplayer.armortype * armplayer.armorvalue;
	arm2 = armitem.armortype * armitem.armorvalue;
	
	if (arm1 >= arm2) return TRUE;
	else return FALSE;
};

//----------------------------------------------------------------------
void() armor_touch =
{
	// Cannot pickup armour if wearing something better!
	if (armor_pickupcondition(other, self)) return;

	// Check for randomizer pickup conditions
	armour_touchrandomizer();
	
	other.armortype = self.armortype;
	other.armorvalue = self.armorvalue;
	other.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + self.items;

	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other, "\n");
	if (self.noise != SOUND_EMPTY) 
		sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	activator = other;
	SUB_UseTargets();

	// Quick exit, no need for following stuff
	if (self.progspawnlist) return;
	
	item_finished();
	check_item_respawn();
};

//----------------------------------------------------------------------
void() item_armor_setup =
{
	self.classgroup = CG_ARMOR;
	self.part_active = PARTICLE_STYLE_ARMOR;
	self.touch2 = armor_touch;
	self.bbmins = '-16 -16 0';
	self.bbmaxs = '16 16 56';
	if (self.respawn_time == 0) self.respawn_time = RESPAWN_ARMOR;
	self.noise = "items/armor1.wav";

	// Check for coop errors
	item_coopcheck();
	item_start ();
};

//======================================================================
/*QUAKED item_armor1 (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/armour.mdl"); }
Green Armour with 100 points of protection
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
armortype     : Override Percentage armor reduction (GRN=0.3,YEL=0.6,RED=0.8)
armorvalue    : Override Quantity armor to pickup (GRN=100,YEL=150,RED=200)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Green Armour with 100 points of protection

======================================================================*/
void() item_armor1 =
{
	// Check for any random setups
	if (armour_checkrandomizer() == TRUE) return;
	
	// Check for custom model setup?
	item_debugcustomdl();
	// Setup default model
	if (self.mdl == "") { self.mdl = "progs/armour.mdl"; self.skin = 0; }
	precache_model (self.mdl);

	self.classtype = CT_ARMOR1;
	self.items = IT_ARMOR1;
	if (self.netname == "") self.netname = "Green Armour";
	if (self.armortype <= 0) self.armortype = ARMOR_GRN_TYPE;
	if (self.armorvalue <= 0) self.armorvalue = ARMOR_GRN_VALUE;
	self.respawn_effect = TRUE;
	self.respawn_style = PARTICLE_BURST_GREEN + PARTICLE_BURST_RING;
	self.respawn_ofs = '0 0 24';
	item_armor_setup();
};

//======================================================================
/*QUAKED item_armor2 (0 0.5 0.8) (-16 -16 0) (16 16 56) x BLUESKIN x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/armour.mdl"); }
Yellow Armour with 150 points of protection
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
armortype     : Override Percentage armor reduction (GRN=0.3,YEL=0.6,RED=0.8)
armorvalue    : Override Quantity armor to pickup (GRN=100,YEL=150,RED=200)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
BLUESKIN : Display a blue skin instead
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Yellow Armour with 150 points of protection

======================================================================*/
void() item_armor2 =
{
	// Check for any random setups
	if (armour_checkrandomizer() == TRUE) return;
	
	// Check for custom model setup?
	item_debugcustomdl();
	// Setup default model
	if (self.mdl == "") self.mdl = "progs/armour.mdl";
	precache_model (self.mdl);
	
	self.classtype = CT_ARMOR2;
	self.items = IT_ARMOR2;
	if (self.armortype <= 0) self.armortype = ARMOR_YEL_TYPE;
	if (self.armorvalue <= 0) self.armorvalue = ARMOR_YEL_VALUE;
	self.respawn_effect = TRUE;
	self.respawn_ofs = '0 0 24';

	// Setup alternative colour
	if (self.spawnflags & ARMOR_BLUE) {
		if (self.netname == "") self.netname = "Blue Armour";
		self.respawn_style = PARTICLE_BURST_BLUE + PARTICLE_BURST_RING;
		self.skin = 3;
	}
	else {
		if (self.netname == "") self.netname = "Yellow Armour";
		self.respawn_style = PARTICLE_BURST_YELLOW + PARTICLE_BURST_RING;
		self.skin = 1;
	}
	
	item_armor_setup();
};

//======================================================================
/*QUAKED item_armorInv (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/armour.mdl"); }
Red Armour with 200 points of protection
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
armortype     : Override Percentage armor reduction (GRN=0.3,YEL=0.6,RED=0.8)
armorvalue    : Override Quantity armor to pickup (GRN=100,YEL=150,RED=200)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Red Armour with 200 points of protection

======================================================================*/
void() item_armorInv =
{
	// Check for any random setups
	if (armour_checkrandomizer() == TRUE) return;
	
	// Check for custom model setup?
	item_debugcustomdl();
	// Setup default model
	if (self.mdl == "") { self.mdl = "progs/armour.mdl"; self.skin = 2; }
	precache_model (self.mdl);

	self.classtype = CT_ARMORINV;
	self.items = IT_ARMOR3;
	if (self.netname == "") self.netname = "Red Armour";
	if (self.armortype <= 0) self.armortype = ARMOR_RED_TYPE;
	if (self.armorvalue <= 0) self.armorvalue = ARMOR_RED_VALUE;
	self.respawn_effect = TRUE;
	self.respawn_style = PARTICLE_BURST_RED + PARTICLE_BURST_RING;
	self.respawn_ofs = '0 0 24';
	item_armor_setup();
};

//======================================================================
// Deathmatch Weapon Rules
//======================================================================
float(float w) DM_RankForWeapon =
{
	if (w == IT_LIGHTNING) return 1;
	if (w == IT_ROCKET_LAUNCHER) return 2;
	if (w == IT_SUPER_NAILGUN) return 3;
	if (w == IT_GRENADE_LAUNCHER) return 4;
	if (w == IT_SUPER_SHOTGUN) return 5;
	if (w == IT_NAILGUN) return 6;
	return 7;	// Axe
};

//----------------------------------------------------------------------
void(float old, float new) DM_Weapon =
{
	local float oldrank, newrank;

// change self.weapon if desired
	oldrank = DM_RankForWeapon (self.weapon);
	newrank = DM_RankForWeapon (new);
	if ( newrank < oldrank ) self.weapon = new;
};

//----------------------------------------------------------------------
void(entity targ) bound_other_ammo =
{
	if (targ.ammo_shells > AMMO_MAXSHELLS) targ.ammo_shells = AMMO_MAXSHELLS;
	if (targ.ammo_nails > AMMO_MAXNAILS) targ.ammo_nails = AMMO_MAXNAILS;
	if (targ.ammo_rockets > AMMO_MAXROCKETS) targ.ammo_rockets = AMMO_MAXROCKETS;		
	if (targ.ammo_cells > AMMO_MAXCELLS) targ.ammo_cells = AMMO_MAXCELLS;		
};

//----------------------------------------------------------------------
void() weapon_touch =
{
	local float pickupweapon, pickupmodweapon, pickupammo, moditem;

	// Reset all weapon pickup items
	pickupweapon = pickupmodweapon = IT_NOWEAPON;
	moditem = FALSE;

	//----------------------------------------------------------------------
	if (self.classtype == CT_UPGRADE_AXE) {
		// Cannot have Shadow Axe AND Grapple Hook
		if (other.moditems & IT_UPGRADE_GHOOK) {
			sprint (other, "Removing Grapple Hook!\n");
			other.moditems = other.moditems - (other.moditems & IT_UPGRADE_GHOOK);
		}
		pickupweapon = IT_AXE;
		pickupmodweapon = IT_UPGRADE_AXE;
		// Deathmatch players cannot constantly pickup weapons
		if (deathmatch > 0 && other.moditems & pickupweapon) return;
		// Update serverflag and highlight as MOD weapon
		update_configflag(SVR_UPDAXE, TRUE);
		moditem = TRUE;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_UPGRADE_GHOOK) {
		// Cannot have Shadow Axe AND Grapple Hook
		if (other.moditems & IT_UPGRADE_AXE) {
			sprint (other, "Removing Shadow Axe!\n");
			other.moditems = other.moditems - (other.moditems & IT_UPGRADE_AXE);
			update_configflag(SVR_UPDAXE, FALSE);
		}
		pickupweapon = IT_AXE;
		pickupmodweapon = IT_UPGRADE_GHOOK;
		// Deathmatch players cannot constantly pickup weapons
		if (deathmatch > 0 && other.moditems & pickupweapon) return;
		moditem = TRUE;
		// Check for fall damage override
		if (self.fall_dmg != 0) {
			if (self.fall_dmg < 0) map_falldmg= 0;
			else map_falldmg = self.fall_dmg;
		}
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_AXE) {
		pickupweapon = IT_AXE;
		pickupmodweapon = IT_NOWEAPON;
		pickupammo = 0;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_SHOTGUN) {
		pickupweapon = IT_SHOTGUN;
		pickupmodweapon = IT_NOWEAPON;
		// Deathmatch players cannot constantly pickup weapons
		if (deathmatch > 0 && other.items & pickupweapon) return;
		// Coop players can use weapon spawns as ammo dispensers
		if (coop > 0 && other.items & pickupweapon) {
			if (other.ammo_shells > AMMO_MAXSHELLS*0.5) pickupammo = 0;
			else pickupammo = self.aflag;
		}
		else pickupammo = self.aflag;
		other.ammo_shells = other.ammo_shells + pickupammo;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_UPGRADE_SSG) {
		pickupweapon = IT_SUPER_SHOTGUN;
		pickupmodweapon = IT_UPGRADE_SSG;
		// Deathmatch players cannot constantly pickup weapons
		if (deathmatch > 0 && other.moditems & pickupweapon) return;
		// Coop players can use weapon spawns as ammo dispensers
		if (coop > 0 && other.moditems & pickupweapon) {
			if (other.ammo_shells > AMMO_MAXSHELLS*0.5) pickupammo = 0;
			else pickupammo = self.aflag;
		}
		else pickupammo = self.aflag;
		other.ammo_shells = other.ammo_shells + pickupammo;
		// Update serverflag and highlight as MOD weapon
		update_configflag(SVR_UPDSSG, TRUE);
		moditem = TRUE;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_SUPER_SHOTGUN) {
		pickupweapon = IT_SUPER_SHOTGUN;
		pickupmodweapon = IT_NOWEAPON;
		// Deathmatch players cannot constantly pickup weapons
		if (deathmatch > 0 && other.items & pickupweapon) return;
		// Coop players can use weapon spawns as ammo dispensers
		if (coop > 0 && other.items & pickupweapon) {
			if (other.ammo_shells > AMMO_MAXSHELLS*0.5) pickupammo = 0;
			else pickupammo = self.aflag;
		}
		else pickupammo = self.aflag;
		other.ammo_shells = other.ammo_shells + pickupammo;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_NAILGUN) {
		pickupweapon = IT_NAILGUN;
		pickupmodweapon = IT_NOWEAPON;
		// Deathmatch players cannot constantly pickup weapons
		if (deathmatch > 0 && other.items & pickupweapon) return;
		// Coop players can use weapon spawns as ammo dispensers
		if (coop > 0 && other.items & pickupweapon) {
			if (other.ammo_nails > AMMO_MAXNAILS*0.5) pickupammo = 0;
			else pickupammo = self.aflag;
		}
		else pickupammo = self.aflag;
		other.ammo_nails = other.ammo_nails + pickupammo;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_SUPER_NAILGUN) {
		pickupweapon = IT_SUPER_NAILGUN;
		pickupmodweapon = IT_NOWEAPON;
		// Deathmatch players cannot constantly pickup weapons
		if (deathmatch > 0 && other.items & pickupweapon) return;
		// Coop players can use weapon spawns as ammo dispensers
		if (coop > 0 && other.items & pickupweapon) {
			if (other.ammo_nails > AMMO_MAXNAILS*0.5) pickupammo = 0;
			else pickupammo = self.aflag;
		}
		else pickupammo = self.aflag;
		other.ammo_nails = other.ammo_nails + pickupammo;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_GRENADE_LAUNCHER) {
		pickupweapon = IT_GRENADE_LAUNCHER;
		pickupmodweapon = IT_NOWEAPON;
		// Deathmatch players cannot constantly pickup weapons
		if (deathmatch > 0 && other.items & pickupweapon) return;
		// Coop players can use weapon spawns as ammo dispensers
		if (coop > 0 && other.items & pickupweapon) {
			if (other.ammo_rockets > AMMO_MAXROCKETS*0.5) pickupammo = 0;
			else pickupammo = self.aflag;
		}
		else pickupammo = self.aflag;
		other.ammo_rockets = other.ammo_rockets + pickupammo;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_ROCKET_LAUNCHER) {
		pickupweapon = IT_ROCKET_LAUNCHER;
		pickupmodweapon = IT_NOWEAPON;
		// Deathmatch players cannot constantly pickup weapons
		if (deathmatch > 0 && other.items & pickupweapon) return;
		// Coop players can use weapon spawns as ammo dispensers
		if (coop > 0 && other.items & pickupweapon) {
			if (other.ammo_rockets > AMMO_MAXROCKETS*0.5) pickupammo = 0;
			else pickupammo = self.aflag;
		}
		else pickupammo = self.aflag;
		other.ammo_rockets = other.ammo_rockets + pickupammo;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_UPGRADE_LG) {
		pickupweapon = IT_LIGHTNING;
		pickupmodweapon = IT_UPGRADE_LG;
		// Deathmatch players cannot constantly pickup weapons
		if (deathmatch > 0 && other.moditems & pickupweapon) return;
		// Coop players can use weapon spawns as ammo dispensers
		if (coop > 0 && other.moditems & pickupweapon) {
			if (other.ammo_cells > AMMO_MAXCELLS*0.5) pickupammo = 0;
			else pickupammo = self.aflag;
		}
		else pickupammo = self.aflag;
		other.ammo_cells = other.ammo_cells + pickupammo;
		// Update serverflag and highlight as MOD weapon
		update_configflag(SVR_UPDLG, TRUE);
		moditem = TRUE;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_LIGHTNING) {
		pickupweapon = IT_LIGHTNING;
		pickupmodweapon = IT_NOWEAPON;
		// Deathmatch players cannot constantly pickup weapons
		if (deathmatch > 0 && other.items & pickupweapon) return;
		// Coop players can use weapon spawns as ammo dispensers
		if (coop > 0 && other.items & pickupweapon) {
			if (other.ammo_cells > AMMO_MAXCELLS*0.5) pickupammo = 0;
			else pickupammo = self.aflag;
		}
		else pickupammo = self.aflag;
		other.ammo_cells = other.ammo_cells + pickupammo;
	}
	//----------------------------------------------------------------------
	else return;
	
	// Keep track of ammo used
	self.aused = self.aused + self.aflag;

	if (self.classtype == CT_UPGRADE_AXE && other.moditems & IT_UPGRADE_AXE)
		sprint (other, "You got another axe to grind\n");
	else if (self.classtype == CT_UPGRADE_GHOOK && other.moditems & IT_UPGRADE_GHOOK)
		sprint (other, "You got a brand new left hook\n");
	else if (self.classtype == CT_SUPER_SHOTGUN && other.moditems & IT_UPGRADE_SSG)
		sprint (other, "You got a handful of Shells\n");
	else if (self.classtype == CT_UPGRADE_SSG && other.moditems & IT_UPGRADE_SSG)
		sprint (other, "You got triple barrel boomstick\n");
	else if (self.classtype == CT_LIGHTNING && other.moditems & IT_UPGRADE_LG)
		sprint (other, "You got some AAA batteries\n");
	else if (self.classtype == CT_UPGRADE_LG && other.moditems & IT_UPGRADE_LG)
		sprint (other, "You got another burst of plasma\n");
	else {
		sprint (other, "You got the ");
		sprint (other, self.netname);
		sprint (other, "\n");
	}
	// weapon touch sound
	if (self.noise != SOUND_EMPTY) 
		sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	// Make sure no ammo is over limits
	bound_other_ammo (other);
	
	// Stop the player switching to weapons already got
	if (deathmatch > 0) {
		// Check for new shadow axe, grapplehook and SG and skip weapon switch
		if (moditem && pickupmodweapon == IT_UPGRADE_AXE && other.moditems & pickupweapon) pickupweapon = FALSE;
		else if (moditem && pickupmodweapon == IT_UPGRADE_GHOOK && other.moditems & pickupweapon) pickupweapon = FALSE;
		else if (pickupweapon == IT_SHOTGUN && other.items & pickupweapon) pickupweapon = FALSE;
		// Stop switching to a lower tier weapon (DM Rules)
		// if (DM_RankForWeapon(other.weapon) < DM_RankForWeapon(new)) new = FALSE;
	}
	
	// Skip any weapon switch if no new weapon
	if (pickupweapon != FALSE) {
		// change to the weapon and add to inventory
		other.items = other.items | pickupweapon;
		if (moditem) other.moditems = other.moditems | pickupmodweapon;
		
		// Check for best weapon (DM only) and switch to it!
		if (deathmatch) DM_Weapon (other.weapon, pickupweapon);
		else other.weapon = pickupweapon;
		W_SetCurrentAmmo(other);
	}

	// Fire any targets and display messages
	activator = other;
	SUB_UseTargets();

	// Quick exit, no need for following stuff
	if (self.progspawnlist) return;
	
	// hide item and check for respawn
	item_finished();
	check_item_respawn();
	
	// Triggers events work once in co-op
	if (coop > 0) { self.target = ""; self.target2 = ""; }
};

//======================================================================
//	WEAPONS
//======================================================================
void() weapon_start =
{
	self.classgroup = CG_WEAPON;
	self.touch2 = weapon_touch;
	self.bbmins = VEC_WPNS_MIN;
	self.bbmaxs = VEC_WPNS_MAX;
	if (self.respawn_time == 0) self.respawn_time = RESPAWN_WEAPON;
	self.noise = WEAPON_PICKUP;
	self.aused = 0;
	
	item_start ();
};

//======================================================================
/*QUAKED weapon_upgrade_axe (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_shadaxe.mdl"); }
Shadow Axe, extra dmg and gib zombies
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Shadow Axe, extra dmg and gib zombies

======================================================================*/
void() weapon_upgrade_axe =
{
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") { self.mdl = MODEL_GWEAP_UPAXE; self.skin = 4; }
	precache_model (self.mdl);
	self.weapon = IT_UPGRADE_AXE;
	self.classtype = CT_UPGRADE_AXE;
	if (self.netname == "") self.netname = "Shadow Axe";
	if (self.upgrade_axe != 0) self.upgrade_axe = FALSE;
	
	self.aflag = 0;
	weapon_start();
};

//======================================================================
/*QUAKED weapon_grapplehook (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_ghook.mdl"); }
Grapple Hook, damage and flying!
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Grapple Hook, damage and flying!

======================================================================*/
void() weapon_upgrade_ghook =
{
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = MODEL_GWEAP_GHOOK;
	precache_model (self.mdl);
	self.weapon = IT_UPGRADE_GHOOK;
	self.classtype = CT_UPGRADE_GHOOK;
	if (self.netname == "") self.netname = "Grapple Hook";
	if (self.upgrade_ghook != 0) self.upgrade_ghook = FALSE;
	// Default is not fall damage with grapple
	if (self.fall_dmg == 0) self.fall_dmg = -1;
	
	self.aflag = 0;
	weapon_start();
};

//======================================================================
/*QUAKED weapon_upgrade_ssg (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_shot3.mdl"); }
The Widowmaker Shotgun, extra dmg, triple shot
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
aflag         : Override ammo quantity for pickup (def=5)
netname       : Override name of pickup (def=Widowmaker Shotgun)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
The Widowmaker Shotgun, extra dmg, triple shot

======================================================================*/
void() weapon_upgrade_ssg =
{
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = MODEL_GWEAP_UPSSG;
	precache_model (self.mdl);
	self.weapon = IT_UPGRADE_SSG;
	self.classtype = CT_UPGRADE_SSG;
	if (self.netname == "") self.netname = "Widowmaker Shotgun";
	if (self.upgrade_ssg != 0) self.upgrade_ssg = FALSE;
	
	// Allow for mapper override on weapon ammo start
	if (self.aflag == 0) self.aflag = AMMO_SHELLS_WPN;
	else if (self.aflag < 0) self.aflag = 0;
	weapon_start();
};

//======================================================================
/*QUAKED weapon_upgrade_lg (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_plasma.mdl"); }
The Plasma Gun, direct & splashdamage
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
aflag         : Override ammo quantity for pickup (def=15)
netname       : Override name of pickup (def=Plasma Gun)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
The Plasma Gun, direct & splashdamage

======================================================================*/
void() weapon_upgrade_lg =
{
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = MODEL_GWEAP_UPLG;
	precache_model (self.mdl);
	self.weapon = IT_UPGRADE_LG;
	self.classtype = CT_UPGRADE_LG;
	if (self.netname == "") self.netname = "Plasma Gun";
	if (self.upgrade_lg != 0) self.upgrade_lg = FALSE;
	
	// Allow for mapper override on weapon ammo start
	if (self.aflag == 0) self.aflag = AMMO_CELLS_WPN;
	else if (self.aflag < 0) self.aflag = 0;
	weapon_start();
};

//======================================================================
/*QUAKED weapon_axe (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_axe.mdl"); }
Quake Axe
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
aflag         : Override ammo quantity for pickup (def=5)
netname       : Override name of pickup (def=Sawn-off Shotgun)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Quake Axe

======================================================================*/
void() weapon_axe =
{
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = MODEL_GWEAP_AXE;
	precache_model (self.mdl);
	self.weapon = IT_AXE;
	self.classtype = CT_AXE;
	if (self.netname == "") self.netname = "Quake Axe";
	
	self.aflag = 0;
	weapon_start();
};

//======================================================================
/*QUAKED weapon_shotgun (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_shotgun.mdl"); }
Single barrel Shotgun
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
aflag         : Override ammo quantity for pickup (def=5)
netname       : Override name of pickup (def=Sawn-off Shotgun)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Single barrel Shotgun

======================================================================*/
void() weapon_shotgun =
{
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = MODEL_GWEAP_SG;
	precache_model (self.mdl);
	self.weapon = IT_SHOTGUN;
	self.classtype = CT_SHOTGUN;
	if (self.netname == "") self.netname = "Sawn-off Shotgun";
	
	// Allow for mapper override on weapon ammo start
	if (self.aflag == 0) self.aflag = AMMO_SHELLS_WPN;
	else if (self.aflag < 0) self.aflag = 0;
	weapon_start();
};

//======================================================================
/*QUAKED weapon_supershotgun (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_shot.mdl"); }
Super Shotgun
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
aflag         : Override ammo quantity for pickup (def=5)
netname       : Override name of pickup (def=Double-barrelled Shotgun)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Super Shotgun

======================================================================*/
void() weapon_supershotgun =
{
	// Switch out Super Shotgun for Widowmaker for last ID map
	if (world.model == "maps/end.bsp") {
		self.classname = "weapon_upgrade_ssg";
		weapon_upgrade_ssg();
		return;
	}
	
	// Quake.rc feature to replace all SSG with WM instead
	// Query console variable 'temp1' for model upgrade option.
	// Cannot use global vars because they don't exist at this point
	if (query_configflag(SVR_UPDSSG)) { weapon_upgrade_ssg(); return; }

	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = MODEL_GWEAP_SSG;
	precache_model (self.mdl);
	precache_model (MODEL_GWEAP_UPSSG);	// Widowmaker (pre-cache)
	self.weapon = IT_SUPER_SHOTGUN;
	self.classtype = CT_SUPER_SHOTGUN;
	if (self.netname == "") self.netname = "Double-barrelled Shotgun";
	
	// Allow for mapper override on weapon ammo start
	if (self.aflag == 0) self.aflag = AMMO_SHELLS_WPN;
	else if (self.aflag < 0) self.aflag = 0;
	weapon_start();
};

//======================================================================
/*QUAKED weapon_nailgun (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_nail.mdl"); }
Perforator (Nailgun)
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
aflag         : Override ammo quantity for pickup (def=30)
netname       : Override name of pickup (def=Nailgun)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Perforator (Nailgun)

======================================================================*/
void() weapon_nailgun =
{
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = MODEL_GWEAP_NG;
	precache_model (self.mdl);
	self.weapon = IT_NAILGUN;
	self.classtype = CT_NAILGUN;
	if (self.netname == "") self.netname = "Nailgun";
	
	// Allow for mapper override on weapon ammo start
	if (self.aflag == 0) self.aflag = AMMO_NAILS_WPN;
	else if (self.aflag < 0) self.aflag = 0;
	weapon_start();
};

//======================================================================
/*QUAKED weapon_supernailgun (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_nail2.mdl"); }
Super Perforator (Super Nailgun)
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
aflag         : Override ammo quantity for pickup (def=30)
netname       : Override name of pickup (def=Super Nailgun)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Super Perforator (Super Nailgun)

======================================================================*/
void() weapon_supernailgun =
{
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = MODEL_GWEAP_SNG;
	precache_model (self.mdl);
	self.weapon = IT_SUPER_NAILGUN;
	self.classtype = CT_SUPER_NAILGUN;
	if (self.netname == "") self.netname = "Super Nailgun";
	
	// Allow for mapper override on weapon ammo start
	if (self.aflag == 0) self.aflag = AMMO_NAILS_WPN;
	else if (self.aflag < 0) self.aflag = 0;
	weapon_start();
};

//======================================================================
/*QUAKED weapon_grenadelauncher (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_rock.mdl"); }
Grenade Launcher
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
aflag         : Override ammo quantity for pickup (def=5)
netname       : Override name of pickup (def=Grenade Launcher)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Grenade Launcher

======================================================================*/
void() weapon_grenadelauncher =
{
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = MODEL_GWEAP_GL;
	precache_model (self.mdl);
	self.weapon = IT_GRENADE_LAUNCHER;
	self.classtype = CT_GRENADE_LAUNCHER;
	if (self.netname == "") self.netname = "Grenade Launcher";
	
	// Allow for mapper override on weapon ammo start
	if (self.aflag == 0) self.aflag = AMMO_ROCKETS_WPN;
	else if (self.aflag < 0) self.aflag = 0;
	weapon_start();
};

//======================================================================
/*QUAKED weapon_rocketlauncher (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_rock2.mdl"); }
Rocket Launcher
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
aflag         : Override ammo quantity for pickup (def=5)
netname       : Override name of pickup (def=Rocket Launcher)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Rocket Launcher

======================================================================*/
void() weapon_rocketlauncher =
{
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = MODEL_GWEAP_RL;
	precache_model (self.mdl);
	self.weapon = IT_ROCKET_LAUNCHER;
	self.classtype = CT_ROCKET_LAUNCHER;
	if (self.netname == "") self.netname = "Rocket Launcher";
	
	// Allow for mapper override on weapon ammo start
	if (self.aflag == 0) self.aflag = AMMO_ROCKETS_WPN;
	else if (self.aflag < 0) self.aflag = 0;
	weapon_start();
};

//======================================================================
/*QUAKED weapon_lightning (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_light.mdl"); }
Thunderbolt Cannon
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
aflag         : Override ammo quantity for pickup (def=15)
netname       : Override name of pickup (def=Thunderbolt)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig  : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Thunderbolt Cannon

======================================================================*/
void() weapon_lightning =
{
	// Switch out Lightning Gun for Plasma for last ID map
	if (world.model == "maps/end.bsp") {
		self.classname = "weapon_upgrade_lg";
		weapon_upgrade_lg();
		return;
	}
	
	// Query console variable 'temp1' for model upgrade option.
	// Cannot use global vars because they don't exist at this point
	if (query_configflag(SVR_UPDLG)) { weapon_upgrade_lg(); return; }

	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = MODEL_GWEAP_LG;
	precache_model (self.mdl);
	self.weapon = IT_LIGHTNING;
	self.classtype = CT_LIGHTNING;
	if (self.netname == "") self.netname = "Thunderbolt";
	
	// Allow for mapper override on weapon ammo start
	if (self.aflag < 1) self.aflag = AMMO_CELLS_WPN;
	else if (self.aflag < 0) self.aflag = 0;
	weapon_start();
};

//======================================================================
// AMMO
//======================================================================
float(entity ammoplayer, entity ammoitem) ammo_pickupcondition =
{
	// Check if the player can pickup anymore ammo
	if (ammoitem.classtype == CT_AMMOSHELLS) {
		if (ammoplayer.ammo_shells >= AMMO_MAXSHELLS) return TRUE;
		else return FALSE;
	}
	else if (ammoitem.classtype == CT_AMMONAILS) {
		if (ammoplayer.ammo_nails >= AMMO_MAXNAILS) return TRUE;
		else return FALSE;
	}
	else if (ammoitem.classtype == CT_AMMOROCKETS) {
		if (ammoplayer.ammo_rockets >= AMMO_MAXROCKETS) return TRUE;
		else return FALSE;
	}
	else if (ammoitem.classtype == CT_AMMOCELLS) {
		if (ammoplayer.ammo_cells >= AMMO_MAXCELLS) return TRUE;
		else return FALSE;
	}
	else return FALSE;
};

//----------------------------------------------------------------------
void() ammo_touch =
{
	local float best;

	// Check ammo limits first
	if (ammo_pickupcondition(other,self)) return;
	
	//----------------------------------------------------------------------
	if (self.classtype == CT_AMMOSHELLS)
		other.ammo_shells = other.ammo_shells + self.aflag;
	else if (self.classtype == CT_AMMONAILS)
		other.ammo_nails = other.ammo_nails + self.aflag;
	else if (self.classtype == CT_AMMOROCKETS)
		other.ammo_rockets = other.ammo_rockets + self.aflag;
	else if (self.classtype == CT_AMMOCELLS)
		other.ammo_cells = other.ammo_cells + self.aflag;
	
	// Keep track of ammo used
	self.aused = self.aused + self.aflag;

	// Check/cap ammo limits
	bound_other_ammo (other);
	
	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other, "\n");
	if (self.noise != SOUND_EMPTY) 
		sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	// Check for randomizer pickup conditions
	ammo_touchrandomizer();
	
	// if the player was using his best weapon, 
	// change up to the new one if better		
	best = W_BestWeapon(other);

	// change to a better weapon if appropriate
	if ( other.weapon == best ) {
		other.weapon = W_BestWeapon(other);
		W_SetCurrentAmmo (other);
	}

	// if changed current ammo, update it
	W_SetCurrentAmmo(other);

	activator = other;
	SUB_UseTargets();

	// Quick exit, no need for following stuff
	if (self.progspawnlist) return;
	
	// hide item and check for respawn
	item_finished();
	check_item_respawn();	
};

//======================================================================
//	Setup all Ammo with global parameters
//======================================================================
void() item_ammo_setup =
{
	self.frame = 0;
	self.touch2 = ammo_touch;
	self.classgroup = CG_AMMOITEM;
	self.bbmins = VEC_AMMO_MIN;
	self.bbmaxs = VEC_AMMO_MAX;
	if (self.respawn_time == 0) self.respawn_time = RESPAWN_AMMO;
	self.noise = AMMO_PICKUP;
	self.aused = 0;
	
	// Items that spawn from pots with toss velocity
	// should not have any lid options (remove them)
	if (self.item_tossvel > 0) 
		self.spawnflags = self.spawnflags - (self.spawnflags & A_LID);

	// Query console variable 'temp1' for model upgrade option.
	// Cannot use global vars because they don't exist at this point
	// Move the new centered ammo models to match old ammo origin
	// The default is to move all ammo items to suit original id maps
	if (!query_configflag(SVR_ITEMOFFSET)) {
		self.oldorigin = self.origin + '16 16 0';
		setorigin(self, self.oldorigin);
	}

	// Setup the skin parameter for ammo boxes
	self.skin = item_skintype(self);

	// An old worldspawn key (not used anymore)
	// This is backward compatibility with this key
	// Will force all items to have an angle
	if (world.no_item_rotate && self.angles_y == 0) self.angles_y = 360;	
	
	// Setting the angle key in the editor to UP/DOWN = random rotation	
	if (self.angles_y <= 0) self.angles_y = rint(random()*359);

	// Setup lid attachment entity (defined in item setup)
	if (self.spawnflags & A_LID) {
		self.attachment = spawn();
		self.attachment.owner = self;
		setorigin(self.attachment, self.origin);
		self.attachment.solid = SOLID_NOT;
		self.attachment.movetype = MOVETYPE_NONE;
	}
		
	// Check for coop errors
	item_coopcheck();
	item_start ();
};

//======================================================================
// ** Old id version with origin at corner **
//QUAKED item_shells (0 .5 .8) (0 0 0) (32 32 32) BIG

/*QUAKED item_shells (0 .5 .8) (-16 -16 0) (16 16 32) BIG LID x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/ammo_shells0.mdl"); }
20 or 40 Shells
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
frame_box     : special animation frame number for LID (1-7)
skin_override : Override world type 1=Base Green, 2=Medieval Wood
aflag         : Override ammo quantity for pickup (def=20/40)
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
BIG      : Double Ammo and different model
LID      : Extra LID model positioned with box
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
20 or 40 Shells for the Shotgun (SG), SuperShotgun (SSG) and Upgrade

======================================================================*/
void() item_shells =
{
	// Check for any random monster setups
	if (ammo_checkrandomizer() == TRUE) return;
	
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.spawnflags & A_LARGE) {
		if (self.mdl == "") self.mdl = "progs/ammo_shells1.mdl";
		if (self.headmdl == "") self.headmdl = "progs/ammo_lidlarge.mdl";
		if (self.aflag < 1) self.aflag = AMMO_SHELLS_LGR;
	}
	else {
		if (self.mdl == "") self.mdl = "progs/ammo_shells0.mdl";
		if (self.headmdl == "") self.headmdl = "progs/ammo_lidsmall.mdl";
		if (self.aflag < 1) self.aflag = AMMO_SHELLS_SML;
	}
	
	precache_model (self.mdl);
	precache_model (self.headmdl);
	self.classtype = CT_AMMOSHELLS;
	if (self.netname == "") self.netname = "box of shells";
	self.respawn_style = PARTICLE_BURST_YELLOW + PARTICLE_BURST_RING;
	self.respawn_ofs = '0 0 24';
	self.respawn_effect = TRUE;
	self.frame_override = FALSE;
	
	// Randomly pick between having a lid or not
	if (self.frame_box == -1) {
		// Add spawnflag so lid is spawned correctly
		if (random() < 0.5) self.spawnflags = self.spawnflags | A_LID;
		self.frame_box = 0;
	}
	// Item progression list ammo cannot have lids!
	if (self.progspawnlist > 0) 
		self.spawnflags = self.spawnflags - (self.spawnflags & A_LID);
	
	item_ammo_setup();
};

//======================================================================
// ** Old id version with origin at corner **
//QUAKED item_spikes (0 .5 .8) (0 0 0) (32 32 32) BIG

/*QUAKED item_spikes (0 .5 .8) (-16 -16 0) (16 16 32) BIG LID x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/ammo_nails0.mdl"); }
25 or 50 Spikes
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
frame_box     : special animation frame number for LID (1-7)
skin_override : Override world type 1=Base Green, 2=Medieval Wood
aflag         : Override ammo quantity for pickup (def=25/50)
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
BIG      : Double Ammo and different model
LID      : Extra LID model positioned with box
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
25 or 50 Spikes for the Perforator (NG) and Super Perforator (SNG)

======================================================================*/
void() item_spikes =
{
	// Check for any random monster setups
	if (ammo_checkrandomizer() == TRUE) return;
	
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.spawnflags & A_LARGE) {
		if (self.mdl == "") self.mdl = "progs/ammo_nails1.mdl";
		if (self.headmdl == "") self.headmdl = "progs/ammo_lidlarge.mdl";
		if (self.aflag < 1) self.aflag = AMMO_NAILS_LGR;
	}
	else {
		if (self.mdl == "") self.mdl = "progs/ammo_nails0.mdl";
		if (self.headmdl == "") self.headmdl = "progs/ammo_lidsmall.mdl";
		if (self.aflag < 1) self.aflag = AMMO_NAILS_SML;
	}
	
	precache_model (self.mdl);
	precache_model (self.headmdl);
	self.classtype = CT_AMMONAILS;
	if (self.netname == "") self.netname = "box of nails";
	self.respawn_style = PARTICLE_BURST_WHITE + PARTICLE_BURST_RING;
	self.respawn_ofs = '0 0 24';
	self.respawn_effect = TRUE;
	self.frame_override = FALSE;

	// Randomly pick between having a lid or not
	if (self.frame_box == -1) {
		// Add spawnflag so lid is spawned correctly
		if (random() < 0.5) self.spawnflags = self.spawnflags | A_LID;
		self.frame_box = 0;
	}
	// Item progression list ammo cannot have lids!
	if (self.progspawnlist > 0) 
		self.spawnflags = self.spawnflags - (self.spawnflags & A_LID);
	
	item_ammo_setup();
};

//======================================================================
// ** Old id version with origin at corner **
//QUAKED item_rockets (0 .5 .8) (0 0 0) (32 32 32) BIG

/*QUAKED item_rockets (0 .5 .8) (-16 -16 0) (16 16 32) BIG x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/ammo_rockets0.mdl"); }
5 or 10 Rockets
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
frame_box     : special animation frame number for box of ammo (1-7)
skin_override : Override world type 1=Base Green, 2=Medieval Wood
aflag         : Override ammo quantity for pickup (def=5/10)
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
BIG      : Double Ammo and different model
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
5 or 10 Rockets for the Grenade (GL) or Rocket Launcher (RL)

======================================================================*/
void() item_rockets =
{
	// Check for any random monster setups
	if (ammo_checkrandomizer() == TRUE) return;
	
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.spawnflags & A_LARGE) {
		if (self.mdl == "") self.mdl = "progs/ammo_rockets1.mdl";
		if (self.aflag < 1) self.aflag = AMMO_ROCKETS_LGR;
	}
	else {
		if (self.mdl == "") self.mdl = "progs/ammo_rockets0.mdl";
		if (self.aflag < 1) self.aflag = AMMO_ROCKETS_SML;
	}
	
	precache_model (self.mdl);
	self.classtype = CT_AMMOROCKETS;
	if (self.netname == "") self.netname = "box of rockets";
	self.spawnflags = self.spawnflags - (self.spawnflags & A_LID);
	self.respawn_style = PARTICLE_BURST_WHITE + PARTICLE_BURST_RING;
	self.respawn_ofs = '0 0 24';
	self.respawn_effect = TRUE;
	self.frame_override = TRUE;
	item_ammo_setup();
};

//======================================================================
// ** Old id version with origin at corner **
//QUAKED item_cells (0 .5 .8) (0 0 0) (32 32 32) BIG

/*QUAKED item_cells (0 .5 .8) (-16 -16 0) (16 16 32) BIG x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/ammo_battery0.mdl"); }
6 or 12 Medieval Battery
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
skin_override : Override world type 1=Base Green, 2=Medieval Wood
aflag         : Override ammo quantity for pickup (def=6/12)
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
BIG      : Double Ammo and different model
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
6 or 12 Medieval Battery (cells) for the Thunderbolt (LG)

======================================================================*/
void() item_cells =
{
	// Check for any random monster setups
	if (ammo_checkrandomizer() == TRUE) return;
	
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.spawnflags & A_LARGE) {
		if (self.mdl == "") self.mdl = "progs/ammo_battery1.mdl";
		if (self.aflag < 1) self.aflag = AMMO_CELLS_LGR;
	}
	else {
		if (self.mdl == "") self.mdl = "progs/ammo_battery0.mdl";
		if (self.aflag < 1) self.aflag = AMMO_CELLS_SML;
	}
	
	precache_model (self.mdl);
	self.classtype = CT_AMMOCELLS;
	if (self.netname == "") self.netname = "battery";
	self.spawnflags = self.spawnflags - (self.spawnflags & A_LID);
	self.respawn_style = PARTICLE_BURST_GREEN + PARTICLE_BURST_RING;
	self.respawn_ofs = '0 0 24';
	self.respawn_effect = TRUE;
	self.frame_override = FALSE;
	item_ammo_setup();
};

//======================================================================
/*QUAKED item_plasma (0 .5 .8) (-16 -16 0) (16 16 32) BIG x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/ammo_cells0.mdl"); }
6 or 12 Cells
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
frame_box     : special animation frame number for box of ammo (1-7)
skin_override : Override world type 1=Base Green, 2=Medieval Wood
aflag         : Override ammo quantity for pickup (def=6/12)
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
BIG      : Double Ammo and different model
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
6 or 12 Cells for the Thunderbolt (LG)

======================================================================*/
void() item_plasma =
{
	// Check for any random monster setups
	if (ammo_checkrandomizer() == TRUE) return;
	
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.spawnflags & A_LARGE) {
		// It seems AD_DM5 has rogue MDL keys that crash the engine
		// Have to add this hack to fix the map, not a good solution
		if (world.model == "maps/ad_dm5.bsp") self.mdl = "progs/ammo_cells1.mdl";
		else if (self.mdl == "") self.mdl = "progs/ammo_cells1.mdl";
		if (self.aflag < 1) self.aflag = AMMO_CELLS_LGR;
	}
	else {
		if (world.model == "maps/ad_dm5.bsp") self.mdl = "progs/ammo_cells0.mdl";
		else if (self.mdl == "") self.mdl = "progs/ammo_cells0.mdl";
		if (self.aflag < 1) self.aflag = AMMO_CELLS_SML;
	}
	
	precache_model (self.mdl);
	self.classtype = CT_AMMOCELLS;
	if (self.netname == "") self.netname = "box of cells";
	self.spawnflags = self.spawnflags - (self.spawnflags & A_LID);
	self.respawn_style = PARTICLE_BURST_BLUE + PARTICLE_BURST_RING;
	self.respawn_ofs = '0 0 24';
	self.respawn_effect = TRUE;
	self.frame_override = TRUE;
	item_ammo_setup();
};

//======================================================================
// KEYS (Silver, Gold and Custom)
//======================================================================
void() key_touchbindmsg =
{ 
	sound (self.enemy, CHAN_VOICE, SOUND_TALK, 1, ATTN_NORM);
	centerprint(self.enemy, "Press 'i' Key to open Inventory\nTo see what \bArcane keys\b you have!\n");
};

//----------------------------------------------------------------------
float(entity keyplayer, entity keyitem) key_pickupcondition =
{
	// Check if the player has the custom key already?
	if (keyitem.classtype == CT_CUSTOMKEY) {
		if (keyplayer.moditems & keyitem.moditems) return TRUE;
		else return FALSE;
	}
	// Check if the player has the silver/gold key already?
	if ( keyplayer.items & keyitem.items ) return TRUE;
	else return FALSE;
};

void(float tvalue, string tdstr) trigger_timer_updateno;
//----------------------------------------------------------------------
void() key_touch =
{
	// Check if player has the key already
	if (key_pickupcondition(other, self)) return;
	
	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");
	if (self.noise != SOUND_EMPTY) 
		sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	// Add key to player inventory (items / customkey)
	if (self.moditems > 0) {
		other.moditems = other.moditems | self.moditems;
		// Store the key netname on the player/client for door ref later
		// Skin number is used by the ClientServerQC AD HUD
		// Sanity range check are done in the HUD, just in case!
		if (self.moditems & IT_CKEY1) {
			other.ckeyname1 = self.netname;
			other.ckeyskin1 = self.ckeyhudskin;
		}
		else if (self.moditems & IT_CKEY2) {
			other.ckeyname2 = self.netname;
			other.ckeyskin2 = self.ckeyhudskin;
		}
		else if (self.moditems & IT_CKEY3) {
			other.ckeyname3 = self.netname;
			other.ckeyskin3 = self.ckeyhudskin;
		}
		else {
			other.ckeyname4 = self.netname;
			other.ckeyskin4 = self.ckeyhudskin;
		}
	}
	// Add silver/gold key to player inventory
	else other.items = other.items | self.items;

	// Setup respawn for co-op
	if (coop > 0 && self.respawn_time > 0) {
		self.respawn_time = RESPAWN_COOP;
		self.spawnflags = self.spawnflags | ITEM_RESPAWN;
	}

	activator = other;
	SUB_UseTargets();

	// Quick exit, no need for following stuff
	if (self.progspawnlist) return;
	
	// hide item and check for respawn
	item_finished();
	check_item_respawn();

	// Triggers events work once in co-op
	if (coop > 0) self.target = "";
	
	// Warn player about new key binding for inventory (first time only)
	if (self.moditems > 0 && other.ckeyhint == FALSE) {
		self.enemy = other;		// Store for later
		// Check if custom key message is suppressed?
		if (self.ckeyhint == TRUE) other.ckeyhint = TRUE;
		else {
			other.ckeyhint = TRUE;	// Only works once
			self.think = key_touchbindmsg;
			self.nextthink = time + 3;
		}
	}
};

//----------------------------------------------------------------------
void() key_setup =
{
	if (self.noise == "") {
		if (self.worldtype == 1) self.noise = "misc/runekey.wav";
		else if (self.worldtype == 2) self.noise = "misc/basekey.wav";
		else self.noise = "misc/medkey.wav";
	}
	precache_sound (self.noise);

	self.touch2 = key_touch;
	self.classgroup = CG_KEY;
	self.bbmins = VEC_KEYS_MIN;
	self.bbmaxs = VEC_KEYS_MAX;
	if (self.respawn_time == 0) self.respawn_time = RESPAWN_KEY;

	// Check for coop errors
	item_coopcheck();	
	item_start();
};

//======================================================================
/*QUAKED item_key1 (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/key_silver.mdl"); }
SILVER key, changes based on worldtype on worldspawn
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
worldtype     : Override model type (1=runic, 2=base, 3=medieval)
netname       : Override name of pickup (def=silver runekey/keycard/key)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
SILVER key, changes based on worldtype on worldspawn

======================================================================*/
void() item_key1 =
{
	// Check for any self worldtype override
	if (!self.worldtype) self.worldtype = world.worldtype;
	
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.worldtype == 1) {
		if (self.mdl == "") self.mdl = "progs/key_runic.mdl";	// progs/m_s_key.mdl
		if (self.netname == "") self.netname = "silver runekey";
	}
	else if (self.worldtype == 2) {
		if (self.mdl == "") self.mdl = "progs/key_base.mdl";	// progs/b_s_key.mdl
		if (self.netname == "") self.netname = "silver keycard";
	}
	else {
		if (self.mdl == "") self.mdl = "progs/key_medieval.mdl";	// progs/w_s_key.mdl
		if (self.netname == "") self.netname = "silver key";
	}
	
	precache_model (self.mdl);
	self.skin = 2;
	self.items = IT_KEY1;
	self.classtype = CT_SILVERKEY;
	self.part_active = PARTICLE_STYLE_KEYSILVER;
	self.respawn_style = PARTICLE_BURST_BLUE + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 20';
	key_setup();
};

//======================================================================
/*QUAKED item_key2 (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/key_gold.mdl"); }
GOLD key, changes based on worldtype on worldspawn
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
worldtype     : Override model type (1=runic, 2=base, 3=medieval)
netname       : Override name of pickup (def=gold runekey/keycard/key)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
GOLD key, changes based on worldtype on worldspawn

======================================================================*/
void() item_key2 =
{
	// Check for any self worldtype override
	if (!self.worldtype) self.worldtype = world.worldtype;
	
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.worldtype == 1) {
		if (self.mdl == "") self.mdl = "progs/key_runic.mdl";	// progs/m_g_key.mdl
		if (self.netname == "") self.netname = "gold runekey";
	}
	else if (self.worldtype == 2) {
		if (self.mdl == "") self.mdl = "progs/key_base.mdl";	// progs/b_g_key.mdl
		if (self.netname == "") self.netname = "gold keycard";
	}
	else {
		if (self.mdl == "") self.mdl = "progs/key_medieval.mdl";	// progs/w_g_key.mdl
		if (self.netname == "") self.netname = "gold key";
	}
	
	precache_model (self.mdl);
	self.skin = 6;
	self.items = IT_KEY2;
	self.classtype = CT_GOLDKEY;
	self.part_active = PARTICLE_STYLE_KEYGOLD;
	self.respawn_style = PARTICLE_BURST_YELLOW + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 20';
	key_setup();
};

//======================================================================
/*QUAKED item_keyx (0 .5 .8) (-16 -16 -24) (16 16 32) CKEY1 CKEY2 CKEY3 CKEY4 RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/key_medieval.mdl"); }
Custom key
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
mdl           : model name to load/display (progs/model.mdl)
netname       : XXX Part of pickup string "You got the XXX"
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig  : = 1 Wait for trigger before respawning
message2      : particle emitter types = KEYSILVER, KEYGOLD, KEYRED, KEYGREEN, KEYPURPLE, KEYWHITE
ckeyhint      : 1 = Arcane key Inventory message blocked (no msg to player)
-------- SPAWNFLAGS --------
Ckey1 : Custom Key type 1
Ckey2 : Custom Key type 2
Ckey3 : Custom Key type 3
Ckey4 : Custom Key type 4
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS: No particle or effects active
-------- NOTES --------
Custom key

======================================================================*/
void() item_keyx =
{
	// Check for any self worldtype override
	if (!self.worldtype) self.worldtype = world.worldtype;
	
	// Can't have a custom key without a custom model!?!
	if (self.mdl == "") {
		dprint("\b[CUSTOM KEY]\b Missing model\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	precache_model (self.mdl);	

	// HUD skin priority (ckeyhudskin > exactskin > skin)
	if (self.exactskin > 0) self.skin = self.exactskin;
	if (self.skin <= 0) self.skin = 0;
	if (self.ckeyhudskin == 0) self.ckeyhudskin = self.skin;

	// Setup custom key reference number (must exist)
	if (self.spawnflags & ITEM_CKEY1) {
		self.moditems = IT_CKEY1;
		if (self.netname == "") self.netname = "Arcane Key 1";
		self.ckeyskin1 = self.ckeyhudskin;
	}
	else if (self.spawnflags & ITEM_CKEY2) {
		self.moditems = IT_CKEY2;
		if (self.netname == "") self.netname = "Arcane Key 2";
	}
	else if (self.spawnflags & ITEM_CKEY3) {
		self.moditems = IT_CKEY3;
		if (self.netname == "") self.netname = "Arcane Key 3";
	}
	else if (self.spawnflags & ITEM_CKEY4) {
		self.moditems = IT_CKEY4;
		if (self.netname == "") self.netname = "Arcane Key 4";
	}
	else {
		dprint("\b[CUSTOM KEY]\b Missing spawnflag key number!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
		
	self.classtype = CT_CUSTOMKEY;
	self.items = IT_KEY1 | IT_KEY2;

	// Check for any AD defined particle effects
	if (self.message2 == "KEYGOLD") self.part_active = PARTICLE_STYLE_KEYGOLD;
	else if (self.message2 == "KEYSILVER") self.part_active = PARTICLE_STYLE_KEYSILVER;
	else if (self.message2 == "KEYRED") self.part_active = PARTICLE_STYLE_KEYRED;
	else if (self.message2 == "KEYGREEN") self.part_active = PARTICLE_STYLE_KEYGREEN;
	else if (self.message2 == "KEYPURPLE") self.part_active = PARTICLE_STYLE_KEYPURPLE;
	else if (self.message2 == "KEYWHITE") self.part_active = PARTICLE_STYLE_KEYWHITE;
	else self.part_active = 0;
	
	// Default respawn parameters, clear message2 just in case
	self.respawn_style = PARTICLE_BURST_WHITE + PARTICLE_BURST_CENTER;
	if (!self.respawn_ofs) self.respawn_ofs = '0 0 20';
	self.message2 = "";
	
	key_setup();
};

//======================================================================
/*QUAKED item_custom (0 .5 .8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/key_base.mdl"); }
Custom Pickup Item
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
mdl          : model name to load/display (progs/model.mdl)
netname      : XXX Part of pickup string "You got the XXX"
noise1       : Custom pickup sound (def=weapons/lock4.wav)
pos1         : Pickup bounding box minimum (def=-16 -16 -24)
pos2         : Pickup bounding box maximum (def=16 16 32)
bodyfadeaway : Model will fade away on pickup
respawn_time : time to wait before respawning (1-x seconds, default varies)
respawn_count: Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
part_active   : = 1 Enable particle burst on pickup
part_ofs      : Particle Origin Offset (def='0 0 0')
part_tcount   : Particle Quantity (def=20)
part_life     : Particle Life Time (def=2s)
part_style    : 1=yellow, 2=green, 3=red, 4=blue, 5=purple, 6=fire, 7=white
part_movetype : 2=center, 3=up, 4=shockwave, 5=skull, 6=lost, 7=minotaur
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Custom Pickup Item

======================================================================*/
void() item_custom_touch =
{
	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");
	if (self.noise != SOUND_EMPTY) 
		sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	activator = other;
	SUB_UseTargets();

	// Quick exit, no need for following stuff
	if (self.progspawnlist) return;

	// Check for a particle pickup burst (can be blocked)
	if (self.part_style > 0 && !(self.spawnflags & ITEM_NOEFFECTS)) 
		misc_particle_burst_use();
	
	// Once only, fade away function
	if (self.bodyfadeaway == TRUE) {
		self.use = self.touch = SUB_Null;
		self.think = model_fade;
		self.nextthink = time + 0.1;
		self.ltime = self.nextthink;
		self.wait = self.delay = 0;
	}
	else {
		// This code is broken and should NOT endlessly respawn for coop
		// 1.8 code removed this option and it is now back to default
		// Do not remove/respawn in co-op
		//if (!coop) {
		item_finished();
		check_item_respawn();
		//}
	}		
};

//----------------------------------------------------------------------
void() item_custom =
{
	if (self.mdl == "") self.mdl = MODEL_BROKEN;
	if (self.noise == "") self.noise = AMMO_PICKUP;
	precache_model (self.mdl);	
	precache_sound (self.noise);

	self.classtype = CT_CUSTOMITEM;
	// Essentially this item is used like a key
	// pickup, collect and trigger an event
	self.classgroup = CG_KEY;
	if (self.netname == "") self.netname = "Custom Item";
	if (self.respawn_time == 0) self.respawn_time = RESPAWN_KEY;

	// Check for a particle burst setup
	if (self.part_active == TRUE) misc_particle_burst_setup();
	self.part_active = 0;	// Must clear this afterward

	// Setup random rotation, will be ignored if spinning model
	if (self.angles_y <= 0) self.angles_y = rint(random()*359);

	// Setup different skin options
	if (self.exactskin > 0) self.skin = self.exactskin;
	else if (self.randomskin > 1) self.skin = rint(random()*(self.randomskin-1));
	if (self.skin < 0) self.skin = 0;	// Double check no negatives
	
	self.touch2 = item_custom_touch;
	if (CheckZeroVector(self.pos1)) self.bbmins = VEC_KEYS_MIN;
	else self.bbmins = self.pos1;
	if (CheckZeroVector(self.pos2)) self.bbmaxs = VEC_KEYS_MAX;
	else self.bbmaxs = self.pos2;
	
	item_start();
};

//======================================================================
/*QUAKED item_sigil (0 0.5 0.8) (-16 -16 -24) (16 16 32) Ep1 Ep2 Ep3 Ep4 RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/key_rune1.mdl"); }
End of episode sigil / rune
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
EP1 : Episode 1 Rune
EP2 : Episode 2 Rune
EP3 : Episode 3 Rune
EP4 : Episode 4 Rune
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
End of episode sigil.  If the player is in possession of a sigil, then the next time 
the player changes levels, all func_episodegate entities for that episode will appear.  
This is used to block access to slipgates that lead to episodes that the player has 
already completed.  If the player is in possession of the item_sigil for all four 
episodes, then the func_bossgate entity will NOT appear.  This is used to grant 
access to the final boss once the player has completed all episodes.

======================================================================*/
float(entity sigilitem) sigil_pickupcondition =
{
	if (query_configflag(sigilitem.customkey)) return TRUE;
	else return FALSE;
};

// ----------------------------------------------------------------
void() sigil_touch =
{
	if (sigil_pickupcondition(self)) return;
	
	centerprint3( other, "You got ", self.netname, "!");
	//centerprint (other, "You got the rune!");
	if (self.noise != SOUND_EMPTY) 
		sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	// Add rune to server! not player
	update_configflag(self.customkey, TRUE);

	// DP has special effect for sigil being picked up
	if (ext_dppart) pointparticles(particleeffectnum(DPP_SIGILPICKUP), self.origin, '0 0 0', 1);
	
	// This odd classname assignment does nothing, old code
	// - It may have been used to hide runes from find commands
	//self.classname = string_null;
	
	activator = other;
	SUB_UseTargets();

	// Quick exit, no need for following stuff
	if (self.progspawnlist) return;

	// hide item and check for respawn
	item_finished();
	check_item_respawn();	
};

//----------------------------------------------------------------------
void() item_sigil =
{
	if (!self.spawnflags) {
		dprint("\b[SIGIL]\b No Rune type selected!?!\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		return;		
	}

	// Check for custom model setup?
	item_debugcustomdl();
	// Based on what spawn key is selected, update model/spawnflag
	// This will make sure only one rune is selected at once
	// Also allow for the spawnflags to have other parameters
	if (self.spawnflags & SVR_RUNE_KEY1) {
		if (self.mdl == "") self.mdl = "progs/key_rune1.mdl";
		self.customkey = SVR_RUNE_KEY1;
	}
	else if (self.spawnflags & SVR_RUNE_KEY2) {
		if (self.mdl == "") self.mdl = "progs/key_rune2.mdl";
		self.customkey = SVR_RUNE_KEY2;
	}
	else if (self.spawnflags & SVR_RUNE_KEY3) {
		if (self.mdl == "") self.mdl = "progs/key_rune3.mdl";
		self.customkey = SVR_RUNE_KEY3;
	}
	else if (self.spawnflags & SVR_RUNE_KEY4) {
		if (self.mdl == "") self.mdl = "progs/key_rune4.mdl";
		self.customkey = SVR_RUNE_KEY4;
	}
	
	precache_model (self.mdl);
	if (self.noise == "") self.noise = "misc/runekey.wav";
	precache_sound (self.noise);

	self.touch2 = sigil_touch;
	self.classtype = CT_RUNEKEY;
	self.classgroup = CG_RUNE;
	if (self.netname == "") self.netname = "The Rune";
	self.part_active = PARTICLE_STYLE_SIGIL;
	self.bbmins = VEC_KEYS_MIN;
	self.bbmaxs = VEC_KEYS_MAX;
	if (self.respawn_time == 0) self.respawn_time = RESPAWN_RUNE;
	self.respawn_style = PARTICLE_BURST_PURPLE + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 16';
	
	// Check for coop errors
	item_coopcheck();	
	item_start();
};

//======================================================================
/*QUAKED item_artifact_tomeofpower (0 .5 .8) (-16 -16 -24) (16 16 32) x x x x x FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/key_tome.mdl"); }
Custom event trigger
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
target       : trigger targets to fire when item touched
mdl           : Override the model used (def=progs/artifact_tome.mdl)
netname       : Override name of pickup (def=Tome of Power)
message      : centerprint message when item is picked up
noise        : Custom pickup sound
-------- SPAWNFLAGS --------
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Custom event trigger

======================================================================*/
void() tomeofpower_touch =
{
	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");
	if (self.noise != SOUND_EMPTY) 
		sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	activator = other;
	SUB_UseTargets();

	// Quick exit, no need for following stuff
	if (self.progspawnlist) return;

	// This is a trigger once condition (regardless of coop)
	item_finished();
};

//----------------------------------------------------------------------
void() item_artifact_tomeofpower =
{
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = "progs/artifact_tome.mdl";
	precache_model (self.mdl);	
	if (self.noise == "") self.noise = "misc/medkey.wav";
	precache_sound (self.noise);

	self.classtype = CT_ARTTOME;
	self.classgroup = CG_ARTIFACT;
	// Holding this item in an inventory does nothing
	// Re-using the bitflag for something else
	self.moditems = 0;
	if (self.netname == "") self.netname = "Tome of Power";

	self.touch2 = tomeofpower_touch;
	self.bbmins = VEC_POWR_MIN;
	self.bbmaxs = VEC_POWR_MAX;
	self.part_active = PARTICLE_STYLE_TOMEOFP;
	item_start();
};

//======================================================================
// ARTIFACTS
// Environment Suit, Pentagram of Protection, Ring of Shadows, Quad,
// Sharpshooter, Nailpiercer, Air Tank, Jump Boots, Blast Belt.
//======================================================================
void() artifact_touch =
{
	//----------------------------------------------------------------------
	// Existing artifacts
	//----------------------------------------------------------------------
	if (self.classtype == CT_ARTINVS) {
		other.invisible_time = 1;
		if (self.cnt < 0) other.invisible_finished = POWERUP_VANIA;
		else other.invisible_finished = time + self.cnt;
		
		other.invisible_sound = time + 1;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_ARTPENT) {
		other.invincible_time = 1;
		if (self.cnt < 0) other.invincible_finished = POWERUP_VANIA;
		else other.invincible_finished = time + self.cnt;
		
		ResetDebuffSystem(other);
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_ARTSUIT) {
		other.rad_time = 1;
		if (self.cnt < 0) other.radsuit_finished = POWERUP_VANIA;
		else other.radsuit_finished = time + self.cnt;
		
		ResetDebuffBurning(other);
		ResetDebuffPoisoned(other);
		// The airtank and envsuit don't share HUD icons and can
		// exist together for different map styles
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_ARTQUAD) {
		// Cannot have QUAD if got Nail Piercer or Sharpshooter
		// They have the Quad effects and share the hud with Quad
		if (other.moditems & IT_ARTPIERCE) return;
		if (other.moditems & IT_ARTSHARP) return;
		
		other.super_time = 1;
		if (self.cnt < 0) other.super_damage_finished = POWERUP_VANIA;
		else other.super_damage_finished = time + self.cnt;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_ARTSHARP) {
		// Cannot have the Nail Piercer if got the Sharpshooter
		// They have the Quad effects and share the hud
		if (other.moditems & IT_ARTPIERCE) return;
		if (other.items & IT_QUAD) return;

		other.sharpshoot_time = 1;
		if (self.cnt < 0) other.sharpshoot_finished = POWERUP_VANIA;
		else other.sharpshoot_finished = time + self.cnt;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_ARTPIERCE) {
		// Cannot have the Sharpshooter if got the Nail Piercer
		// They have the Quad effects and share the hud
		if (other.moditems & IT_ARTSHARP) return;
		if (other.items & IT_QUAD) return;

		other.nailpiercer_time = 1;
		if (self.cnt < 0) other.nailpiercer_finished = POWERUP_VANIA;
		else other.nailpiercer_finished = time + self.cnt;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_ARTAIRTANK) {
		other.airtank_time = 1;
		if (self.cnt < 0) other.airtank_finished = POWERUP_VANIA;
		else other.airtank_finished = time + self.cnt;
		
		other.airtank_sound = time + 2;
		// Check for suit override on breathing sound
		if (self.spawnflags & AIRTANK_SILENT) other.airtank_silent = TRUE;
		else other.airtank_silent = FALSE;
		// Volume range modifier (0-1)
		other.airtank_volume = self.volume;
		other.airtank_outwater = self.distance;

		ResetDebuffPoisoned(other);
		// The airtank and envsuit don't share HUD icons and can
		// exist together for different map styles
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_ARTLAVASHIELD) {
		other.lavashield_time = 1;
		// Volume range modifier (0-1)
		other.lavashield_volume = self.volume;
		if (self.cnt < 0) other.lavashield_finished = POWERUP_VANIA;
		else other.lavashield_finished = time + self.cnt;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_ARTBLASTBELT) {
		other.blastbelt_time = 1;
		// Volume range modifier (0-1)
		other.blastbelt_volume = self.volume;
		if (self.cnt < 0) other.blastbelt_finished = POWERUP_VANIA;
		else other.blastbelt_finished = time + self.cnt;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_ARTJUMPBOOTS) {
		other.jumpboots_time = 1;
		if (self.cnt < 0) other.jumpboots_finished = POWERUP_VANIA;
		else other.jumpboots_finished = time + self.cnt;
		
		other.jumpboots_airlvl = 0;
		// Check if jump max is endless, additive or exact
		if (self.count < 0) other.jumpboots_airmax = -1;
		else if (self.count > 0) other.jumpboots_airmax = self.count;
		else other.jumpboots_airmax = other.jumpboots_airmax + 1;
		// Make sure the max never goes too high
		if (other.jumpboots_airmax > ART_JUMPBOOTS_AIRMAX)
			other.jumpboots_airmax = ART_JUMPBOOTS_AIRMAX;
		if (self.height > 0) other.jumpboots_height = self.height;
		else other.jumpboots_height = ART_JUMPHEIGHT;
		if (self.distance > 0) other.jumpboots_forward = self.distance;
		else other.jumpboots_forward = 0;
	}
	//----------------------------------------------------------------------
	else return;

	//----------------------------------------------------------------------
	// Pickup sound and initial screen flash
	//----------------------------------------------------------------------
	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");
	if (self.noise != SOUND_EMPTY) 
		// Originally played on chan_voice, can be overwritten easily
		sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	// Update player item flags (regular + mod)
	other.items = other.items | self.items;
	other.moditems = other.moditems | self.moditems;

	activator = other;
	SUB_UseTargets();

	// Check for randomizer pickup conditions
	artifact_touchrandomizer();
	
	// Quick exit, no need for following stuff
	if (self.progspawnlist) return;

	// hide item and check for respawn
	item_finished();
	check_item_respawn();	
};

//======================================================================
//	setup all artifacts with similiar configurations
//======================================================================
void() artifact_setup =
{
	self.touch2 = artifact_touch;
	self.classgroup = CG_ARTIFACT;
	self.bbmins = VEC_POWR_MIN;
	self.bbmaxs = VEC_POWR_MAX;
	
	// Allow for custom artifact timer
	if (self.cnt < 0) self.cnt = POWERUP_VANIA;
	// Setup minimum/default timer
	else if (self.cnt == 0) self.cnt = POWERUP_TIMER;
	
	// Setup skin override
	if (self.exactskin < 1) self.exactskin = 0;
	self.skin = self.exactskin;

	// Setup artifact default respawn timers
	if (self.respawn_time == 0) {
		if (self.classtype == CT_ARTPENT || self.classtype == CT_ARTINVS)
			self.respawn_time = RESPAWN_ARTIFACT2;
		else self.respawn_time = RESPAWN_ARTIFACT1;
	}	

	item_start ();
};

//======================================================================
/*QUAKED item_artifact_envirosuit (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/artifact_envsuit.mdl"); }
Player takes no damage from water or slime for 30 seconds
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
exactskin     : 0=Original, 1=Green, 2=Brown, 3=Aqua, 4=Blue
mdl           : Override the model used (def=progs/artifact_envsuit.mdl)
netname       : Override name of pickup (def=Environment Suit)
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig  : = 1 Wait for trigger before respawning
noise         : Custom pickup sound for powerup
cnt           : Duration override of artifact (default = 30s)
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Player takes no damage from water or slime for 30 seconds
Immume to Fire Attack, but take small damage instead

======================================================================*/
void() item_artifact_envirosuit =
{
	// Check for any random setups
	if (artifact_checkrandomizer() == TRUE) return;

	// Check for custom model setup?
	item_debugcustomdl();
	// cshifts 0,255,0,20
	// Original id model = progs/suit.mdl
	if (self.mdl == "") self.mdl = "progs/artifact_envsuit.mdl";
	precache_model (self.mdl);
	if (self.noise == "") self.noise = SOUND_ARTSUIT1;
	self.noise2 = SOUND_EMPTY;		// not used (activation sound)
	precache_sound (self.noise);
	precache_sound ((self.noise1 = SOUND_ARTSUIT2));
	precache_sound (self.noise2);
	if (self.netname == "") self.netname = "Environment Suit";
	self.items = IT_SUIT;
	self.classtype = CT_ARTSUIT;
	self.part_active = PARTICLE_STYLE_SUIT;
	self.respawn_style = PARTICLE_BURST_GREEN + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 28';
	artifact_setup();
};

//======================================================================
/*QUAKED item_artifact_invisibility (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/artifact_invis.mdl"); }
Player is invisible for 30 seconds
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
mdl           : Override the model used (def=progs/artifact_invis.mdl)
netname       : Override name of pickup (def=Ring of Shadows)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig  : = 1 Wait for trigger before respawning
noise         : Custom pickup sound for powerup
cnt           : Duration override of artifact (default = 30s)
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Player is invisible for 30 seconds

======================================================================*/
void() item_artifact_invisibility =
{
	// Check for any random setups
	if (artifact_checkrandomizer() == TRUE) return;

	// Check for custom model setup?
	item_debugcustomdl();
	// cshifts 100,100,100,100
	// Original id model = progs/invisibl.mdl
	if (self.mdl == "") self.mdl = "progs/artifact_invis.mdl";
	precache_model (self.mdl);
	if (self.noise == "") self.noise = SOUND_ARTINV1;
	precache_sound (self.noise);
	precache_sound ((self.noise1 = SOUND_ARTINV2));
	precache_sound ((self.noise2 = SOUND_ARTINV3));
	if (self.netname == "") self.netname = "Ring of Shadows";
	self.items = IT_INVISIBILITY;
	self.classtype = CT_ARTINVS;
	self.part_active = PARTICLE_STYLE_SRING;
	self.respawn_style = PARTICLE_BURST_YELLOW + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 6';
	artifact_setup();
};

//======================================================================
/*QUAKED item_artifact_invulnerability (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/artifact_pent.mdl"); }
Player is invulnerable for 30 seconds
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
mdl           : Override the model used (def=progs/artifact_pent.mdl)
netname       : Override name of pickup (def=Pentagram of Protection)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig  : = 1 Wait for trigger before respawning
noise         : Custom pickup sound for powerup
cnt           : Duration override of artifact (default = 30s)
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Player is invulnerable for 30 seconds
Immume from Wraith Healing Debuff

======================================================================*/
void() item_artifact_invulnerability =
{
	// Check for custom model setup?
	item_debugcustomdl();
	// cshifts 255,255,0,30
	// Original id model = progs/invulner.mdl
	if (self.mdl == "") self.mdl = "progs/artifact_pent.mdl";
	precache_model (self.mdl);
	if (self.noise == "") self.noise = SOUND_ARTPENT1;
	precache_sound (self.noise);
	precache_sound ((self.noise1 = SOUND_ARTPENT2));
	precache_sound ((self.noise2 = SOUND_ARTPENT3));
	if (self.netname == "") self.netname = "Pentagram of Protection";
	self.items = IT_INVULNERABILITY;
	self.classtype = CT_ARTPENT;
	self.part_active = PARTICLE_STYLE_PENT;
	self.respawn_style = PARTICLE_BURST_RED + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 16';
	artifact_setup();
};

//======================================================================
/*QUAKED item_artifact_super_damage (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/artifact_quad.mdl"); }
The next attack from the player will do 4x damage
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
mdl           : Override the model used (def=progs/artifact_quad.mdl)
netname       : Override name of pickup (def=Quad Damage)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig  : = 1 Wait for trigger before respawning
noise         : Custom pickup sound for powerup
cnt           : Duration override of artifact (default = 30s)
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
The next attack from the player will do 4x damage

======================================================================*/
void() item_artifact_super_damage =
{
	// Check for custom model setup?
	item_debugcustomdl();
	// cshifts 0,0,255,30
	// Original id model = progs/quaddama.mdl
	if (self.mdl == "") self.mdl = "progs/artifact_quad.mdl";
	precache_model (self.mdl);
	if (self.noise == "") self.noise = SOUND_ARTQUAD1;
	precache_sound (self.noise);
	precache_sound ((self.noise1 = SOUND_ARTQUAD2));
	precache_sound ((self.noise2 = SOUND_ARTQUAD3));
	if (self.netname == "") self.netname = "Quad Damage";
	self.items = IT_QUAD;
	self.classtype = CT_ARTQUAD;
	self.part_active = PARTICLE_STYLE_QUAD;
	self.respawn_style = PARTICLE_BURST_BLUE + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 16';
	artifact_setup();
};

//======================================================================
/*QUAKED item_artifact_sharp_shooter (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/artifact_sharp.mdl"); }
Reduces the bullet spread of all Shotguns
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
mdl           : Override the model used (def=progs/artifact_sharp.mdl)
netname       : Override name of pickup (def=Sharp Shooter)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig  : = 1 Wait for trigger before respawning
noise         : Custom pickup sound for powerup
cnt           : Duration override of artifact (default = 30s)
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Reduces the bullet spread of all Shotguns

======================================================================*/
void() item_artifact_sharp_shooter =
{
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = "progs/artifact_sharp.mdl";
	precache_model (self.mdl);
	if (self.noise == "") self.noise = SOUND_ARTSHARP1;
	precache_sound (self.noise);
	precache_sound ((self.noise1 = SOUND_ARTSHARP2));
	precache_sound ((self.noise2 = SOUND_ARTSHARP3));
	if (self.netname == "") self.netname = "Sharp Shooter";
	self.items = IT_QUAD;
	self.moditems = IT_ARTSHARP;
	self.classtype = CT_ARTSHARP;
	self.part_active = PARTICLE_STYLE_SHARP;
	self.respawn_style = PARTICLE_BURST_PURPLE + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 16';
	artifact_setup();
};

//======================================================================
/*QUAKED item_artifact_nail_piercer (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/artifact_piercer.mdl"); }
All nail attacks will travel through monsters
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
mdl           : Override the model used (def=progs/artifact_piercer.mdl)
netname       : Override name of pickup (def=Nail Piercer)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig  : = 1 Wait for trigger before respawning
noise         : Custom pickup sound for powerup
cnt           : Duration override of artifact (default = 30s)
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
All nail attacks will travel through monsters

======================================================================*/
void() item_artifact_nail_piercer =
{
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = "progs/artifact_piercer.mdl";
	precache_model (self.mdl);
	if (self.noise == "") self.noise = SOUND_ARTNAILP1;
	precache_sound (self.noise);
	precache_sound ((self.noise1 = SOUND_ARTNAILP2));
	precache_sound ((self.noise2 = SOUND_ARTNAILP3));
	if (self.netname == "") self.netname = "Nail Piercer";
	self.items = IT_QUAD;
	self.moditems = IT_ARTPIERCE;
	self.classtype = CT_ARTPIERCE;
	self.part_active = PARTICLE_STYLE_PIERCE;
	self.respawn_style = PARTICLE_BURST_PURPLE + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 16';
	artifact_setup();
};

//======================================================================
/*QUAKED item_artifact_airtank (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x SILENT RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/artifact_airtank.mdl"); }
Player takes no damage from being in water
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
exactskin     : 0=Original, 1=Green, 2=Brown, 3=Aqua, 4=Blue
message       : centerprint message when item is picked up
mdl           : Override the model used (def=progs/artifact_airtank.mdl)
netname       : Override name of pickup (def=Wet Suit)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig  : = 1 Wait for trigger before respawning
noise         : Custom pickup sound for powerup
distance      : Breathing sound of water (def 1=off)
volume        : Maximum range for volume (def=1, no sound=-1)
cnt           : override duration of artifact (def=infinite)
-------- SPAWNFLAGS --------
SILENT   : No breathing sound when airtank active
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS: No particle or effects active
-------- NOTES --------
Primary   : Player takes no damage from being in water
Secondary : Reduces Poisonous debuff by 50% and can surive LG/PG firing underwater

======================================================================*/
void() item_artifact_airtank =
{
	// Check for custom model setup?
	item_debugcustomdl();
	// cshifts 0,255,0,20
	if (self.mdl == "") self.mdl = "progs/artifact_airtank.mdl";
	precache_model (self.mdl);
	if (self.noise == "") self.noise = SOUND_ARTAIRTANK1;
	precache_sound (self.noise);
	precache_sound ((self.noise1 = SOUND_ARTAIRTANK2));
	precache_sound ((self.noise2 = SOUND_ARTAIRTANK3));
	precache_sound ((self.noise3 = SOUND_ARTAIRTANK3B));
	if (self.netname == "") self.netname = "Air Tank";
	self.items = 0;
	self.moditems = IT_ARTAIRTANK;
	self.classtype = CT_ARTAIRTANK;
	self.part_active = PARTICLE_STYLE_AIRTANK;
	self.respawn_style = PARTICLE_BURST_BLUE + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 20';
	// New default = Breathing sound out of water off
	if (self.distance < 0) self.distance = 0;
	else self.distance = 1;
	
	// Default = Infinite vania item
	if (self.cnt <= 0) self.cnt = POWERUP_VANIA;
	// Default volume = 1
	if (self.volume < 0) self.volume = 0;
	else if (self.volume < 0.1) self.volume = 1;
	
	artifact_setup();
};

//----------------------------------------------------------------------
// Redirect/Fix for Sepulcher/Swampy maps having old 1.7 item
void() item_artifact_wetsuit = { 
	// Old wetsuit had lots of skin setups
	self.exactskin = self.skin = 0; 
	item_artifact_airtank();
};

//======================================================================
/*QUAKED item_artifact_lavashield (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/artifact_lavashield.mdl"); }
Player takes no HP/armour damage from lava
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
mdl           : Override the model used (def=progs/artifact_lavashield.mdl)
netname       : Override name of pickup (def=Aegis of Chthon)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig  : = 1 Wait for trigger before respawning
noise         : Custom pickup sound for powerup
volume        : Maximum range for volume (def=1, no sound=-1)
cnt           : override duration of artifact (def=infinite)
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS: No particle or effects active
-------- NOTES --------
Primary   : Player takes no HP/armour damage from lava
Secondary : Flame and lava attack damage is reduced (Chthon, Drole, Gargoyle, Quoth Dguard)

======================================================================*/
void() item_artifact_lavashield =
{
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = "progs/artifact_lavashield.mdl";
	precache_model (self.mdl);
	if (self.noise == "") self.noise = SOUND_ARTLSHIELD1;
	precache_sound (self.noise);
	precache_sound ((self.noise1 = SOUND_ARTLSHIELD2));
	precache_sound ((self.noise2 = SOUND_ARTLSHIELD3));
	if (self.netname == "") self.netname = "Aegis of Chthon";
	self.items = 0;
	self.moditems = IT_ARTLAVASHIELD;
	self.classtype = CT_ARTLAVASHIELD;
	self.part_active = PARTICLE_STYLE_LAVASHIELD;
	self.respawn_style = PARTICLE_BURST_RED + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 16';

	// Default = Infinite vania item
	if (self.cnt <= 0) self.cnt = POWERUP_VANIA;
	// Default volume = 1
	if (self.volume < 0) self.volume = 0;
	else if (self.volume < 0.1) self.volume = 1;

	artifact_setup();
};

//======================================================================
/*QUAKED item_artifact_blastbelt (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/artifact_blastbelt.mdl"); }
Player does not take splash damage, but take direct damage
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
mdl           : Override the model used (def=progs/artifact_blastbelt.mdl)
netname       : Override name of pickup (def=Blast Belt)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig  : = 1 Wait for trigger before respawning
noise         : Custom pickup sound for powerup
volume        : Maximum range for volume (def=1, no sound=-1)
cnt           : override duration of artifact (def=infinite)
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Primary   : Player does not take splash damage, but take direct damage
Secondary : Immune to floor impact attacks (hammer ogre, golems etc)

======================================================================*/
void() item_artifact_blastbelt =
{
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = "progs/artifact_blastbelt.mdl";
	precache_model (self.mdl);
	if (self.noise == "") self.noise = SOUND_ARTBLASTBELT1;
	precache_sound (self.noise);
	precache_sound ((self.noise1 = SOUND_ARTBLASTBELT2));
	precache_sound ((self.noise2 = SOUND_ARTBLASTBELT3));
	if (self.netname == "") self.netname = "Blast Belt";
	self.items = 0;
	self.moditems = IT_ARTBLASTBELT;
	self.classtype = CT_ARTBLASTBELT;
	
	self.respawn_ofs = '0 0 8';
	self.part_active = PARTICLE_STYLE_BLASTBELT;
	self.respawn_style = PARTICLE_BURST_BLUE + PARTICLE_BURST_CENTER;

	// Default = Infinite vania item
	if (self.cnt <= 0) self.cnt = POWERUP_VANIA;
	// Default volume = 1
	if (self.volume < 0) self.volume = 0;
	else if (self.volume < 0.1) self.volume = 1;
	
	artifact_setup();
};

//======================================================================
/*QUAKED item_artifact_jumpboots (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/artifact_jumpboots.mdl"); }
Player can do (1-4) extra jumps
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
mdl           : Override the model used (def=progs/artifact_jumpboots.mdl)
netname       : Override name of pickup (def=Jump Boots 1+)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig  : = 1 Wait for trigger before respawning
noise         : Custom pickup sound for powerup
count         : Power level override (0=def, 1-4=exact level, -1=endless)
height        : 2nd+ player jump height upward (def=320)
distance      : Minimum forward momentum (def=0, recommend=320)
volume        : Maximum range for volume (def=1, no sound=-1)
cnt           : override duration of artifact (def=infinite)
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Primary   : Player can do (1-4) extra jumps
Secondary : Can jump while falling off ledges or midair

======================================================================*/
void() item_artifact_jumpboots =
{
	// Check for custom model setup?
	item_debugcustomdl();
	if (self.mdl == "") self.mdl = "progs/artifact_jumpboots.mdl";
	precache_model (self.mdl);
	if (self.noise == "") self.noise  = SOUND_ARTJUMPBOOTS1;
	precache_sound (self.noise);
	// sounds 3a-3c are used in client.qc (lines 915+)
	precache_sound ((self.noise1 = SOUND_ARTJUMPBOOTS2));
	precache_sound ((self.noise2 = SOUND_ARTJUMPBOOTS3A));	// First jump
	precache_sound ((self.noise3 = SOUND_ARTJUMPBOOTS3B));	// Second
	precache_sound ((self.noise4 = SOUND_ARTJUMPBOOTS3C));	// No more
	
	self.items = 0;
	self.moditems = IT_ARTJUMPBOOTS;
	self.classtype = CT_ARTJUMPBOOTS;
	self.part_active = PARTICLE_STYLE_JUMPBOOTS;
	self.respawn_style = PARTICLE_BURST_YELLOW + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 10';

	// Make sure count is within range 1-4
	if (self.count < -1 || self.count > ART_JUMPBOOTS_AIRMAX) self.count = 1;	
	// Setup more descriptive pickup names
	if (self.count == 2) self.netname = "Jump Boots +2";
	else if (self.count == 3) self.netname = "Jump Boots +3";
	else if (self.count == 4) self.netname = "Jump Boots +4";
	// Default name (count == 1)
	else self.netname = "Jump Boots";

	// Default = Infinite vania item
	if (self.cnt <= 0) self.cnt = POWERUP_VANIA;
	// Default volume = 1
	if (self.volume < 0) self.volume = 0;
	else if (self.volume < 0.1) self.volume = 1;
	
	artifact_setup();
};

//======================================================================
// ITEM BACKPACKS
// * Dropped from monsters and players
// * Can be setup as an item with random ammo/armour
// * Will monitor ground below so can fall further
//
//======================================================================
float(entity backent, string backtext1, string backtext2, float backcomma) BackpackText =
{
	if (backcomma > 0) sprint (backent, ", ");
	if (backtext1 != "") sprint (backent, backtext1);
	if (backtext2 != "") sprint (backent, backtext2);
	return 1;
};

//----------------------------------------------------------------------
void() BackpackTouch =
{
	local string s;
	local float pickupweapon, acount;
	
	acount = 0;
	sprint (other, "You get ");

	//----------------------------------------------------------------------
	// A Coop player can pickup all of the weapons
	// dropped by previous player (go through list)
	//----------------------------------------------------------------------
	if (coop > 0) {
		if (self.moditems & IT_UPGRADE_AXE && !(other.moditems & IT_UPGRADE_AXE)) {
			pickupweapon = IT_UPGRADE_AXE;
			other.items = other.items | pickupweapon;
			acount = BackpackText(other, "ShadowAxe", "", acount);
			other.moditems = other.moditems | pickupweapon;
			update_configflag(SVR_UPDAXE, TRUE);
		}
		
		if (self.items & IT_SHOTGUN && !(other.items & IT_SHOTGUN)) {
			pickupweapon = IT_SHOTGUN;
			other.items = other.items | pickupweapon;
			acount = BackpackText(other, "SG", "", acount);
		}
		
		if (self.moditems & IT_UPGRADE_SSG && !(other.moditems & IT_UPGRADE_SSG)) {
			pickupweapon = IT_UPGRADE_SSG;
			other.items = other.items | pickupweapon;
			acount = BackpackText(other, "WidowMaker", "", acount);
			other.moditems = other.moditems | pickupweapon;
			update_configflag(SVR_UPDSSG, TRUE);
		}
		else if (self.items & IT_SUPER_SHOTGUN && !(other.items & IT_SUPER_SHOTGUN)) {
			pickupweapon = IT_SUPER_SHOTGUN;
			other.items = other.items | pickupweapon;
			acount = BackpackText(other, "SSG", "", acount);
		}
		
		if (self.items & IT_NAILGUN && !(other.items & IT_NAILGUN)) {
			pickupweapon = IT_NAILGUN;
			other.items = other.items | pickupweapon;
			acount = BackpackText(other, "NG", "", acount);
		}
		if (self.items & IT_SUPER_NAILGUN && !(other.items & IT_SUPER_NAILGUN)) {
			pickupweapon = IT_SUPER_NAILGUN;
			other.items = other.items | pickupweapon;
			acount = BackpackText(other, "SNG", "", acount);
		}
		if (self.items & IT_GRENADE_LAUNCHER && !(other.items & IT_GRENADE_LAUNCHER)) {
			pickupweapon = IT_GRENADE_LAUNCHER;
			other.items = other.items | pickupweapon;
			acount = BackpackText(other, "GL", "", acount);
		}
		if (self.items & IT_ROCKET_LAUNCHER && !(other.items & IT_ROCKET_LAUNCHER)) {
			pickupweapon = IT_ROCKET_LAUNCHER;
			other.items = other.items | pickupweapon;
			acount = BackpackText(other, "RL", "", acount);
		}
		
		if (self.moditems & IT_UPGRADE_LG && !(other.moditems & IT_UPGRADE_LG)) {
			pickupweapon = IT_UPGRADE_LG;
			other.items = other.items | pickupweapon;
			acount = BackpackText(other, "PlasmaGun", "", acount);
			other.moditems = other.moditems | pickupweapon;
			update_configflag(SVR_UPDLG, TRUE);
		}
		else if (self.items & IT_LIGHTNING && !(other.items & IT_LIGHTNING)) {
			pickupweapon = IT_LIGHTNING;
			other.items = other.items | pickupweapon;
			acount = BackpackText(other, "LG", "", acount);
		}
	}
	// DM backpacks have only one weapon
	else {
		// Setup name of weapon first
		if (self.items & IT_LIGHTNING && self.moditems & IT_UPGRADE_LG)
			self.netname = "Plasma Gun";
		else if (self.items & IT_LIGHTNING) self.netname = "Thunderbolt";
		else if (self.items & IT_ROCKET_LAUNCHER) self.netname = "Rocket Launcher";
		else if (self.items & IT_GRENADE_LAUNCHER) self.netname = "Grenade Launcher";
		else if (self.items & IT_SUPER_NAILGUN) self.netname = "Super Nailgun";
		else if (self.items & IT_NAILGUN) self.netname = "Nailgun";
		else if (self.items & IT_SUPER_SHOTGUN && self.moditems & IT_UPGRADE_SSG) 
			self.netname = "Widow Maker Shotgun";
		else if (self.items & IT_SUPER_SHOTGUN) self.netname = "Double-barrelled Shotgun";
		else if (self.items & IT_SHOTGUN) self.netname = "Shotgun";
		else if (self.items & IT_AXE && self.moditems & IT_UPGRADE_AXE) 
			self.netname = "Shadow Axe";
		else if (self.items & IT_AXE) self.netname = "Axe";
		else self.netname = "";
		
		// Check if the player has the weapon already?
		if ((other.items & self.items) == 0 && self.netname != "") {
			other.items = other.items | self.items;
			other.moditems = other.moditems | self.moditems;
			acount = BackpackText(other, "the", self.netname, acount);
		}
	}

	//----------------------------------------------------------------------
	// Calculate random amounts of ammo
	//----------------------------------------------------------------------
	if (self.count > 0) {
		if (self.spawnflags & BACKPACK_SHELLS) self.ammo_shells = rint(1 + random()*self.count);
		if (self.spawnflags & BACKPACK_NAILS) self.ammo_nails = rint(1 + random()*self.count);
		if (self.spawnflags & BACKPACK_ROCKETS) self.ammo_rockets = rint(1 + random()*self.count);
		if (self.spawnflags & BACKPACK_CELLS) self.ammo_cells = rint(1 + random()*self.count);
		if (self.armortype == 1) self.armorvalue = rint(1 + random()*self.count);
	}

	//----------------------------------------------------------------------
	// Give ammo to player
	//----------------------------------------------------------------------
	if (self.ammo_shells > 0) {
		other.ammo_shells = other.ammo_shells + self.ammo_shells;
		other.items = other.items | IT_SHELLS;
		s = ftos(self.ammo_shells);
		acount = BackpackText(other, s, " shells", acount);
	}
	if (self.ammo_nails > 0) {
		other.ammo_nails = other.ammo_nails + self.ammo_nails;
		other.items = other.items | IT_NAILS;
		s = ftos(self.ammo_nails);
		acount = BackpackText(other, s, " nails", acount);
	}
	if (self.ammo_rockets > 0) {
		other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
		other.items = other.items | IT_ROCKETS;
		s = ftos(self.ammo_rockets);
		acount = BackpackText(other, s, " rockets", acount);
	}
	if (self.ammo_cells > 0) {
		other.ammo_cells = other.ammo_cells + self.ammo_cells;
		other.items = other.items | IT_CELLS;
		s = ftos(self.ammo_cells);
		acount = BackpackText(other, s, " cells", acount);
	}
	
	//----------------------------------------------------------------------
	// Check for armor in backpack
	//----------------------------------------------------------------------
	if (self.armorvalue > 0 && deathmatch == 0) {
		// For coop backpacks can be dropped from players
		// These can contain huge amounts of armour and needed
		// to be treated as upgrade/replace, not the shard system
		if (coop > 0 && self.items & IT_ALLARMOR) {
			if (other.armortype*other.armorvalue < self.armortype*self.armorvalue) {
				other.armortype = self.armortype;
				other.armorvalue = self.armorvalue;
				other.items = other.items - (other.items & IT_ALLARMOR);
				other.items = other.items + (self.items & IT_ALLARMOR);
				acount = BackpackText(other, "armor upgraded", "", acount);
			}
		}
		else {
			// For Singleplayer backpack items can contain shards
			// Shards add to the armour value and can go above limit
			// If no armour present (add a green jacket)
			other.armorvalue = other.armorvalue + self.armorvalue;

			// Yellow armour upgrade
			// Only update armour type if green armour present
			if (self.armortype == ARMOR_YEL_TYPE) {
				if (other.items & IT_ARMOR1 || other.armortype == 0) {
					other.items = other.items - (other.items & IT_ARMOR1);
					other.items = other.items | IT_ARMOR2;
					other.armortype = ARMOR_YEL_TYPE;
				}
			}
			// Red armour upgrade
			// Remove previous armour type (hud display flag)
			else if (self.armortype == ARMOR_RED_TYPE) {
				other.items = other.items - (other.items & IT_ARMOR1);
				other.items = other.items - (other.items & IT_ARMOR2);
				other.items = other.items | IT_ARMOR3;
				other.armortype = ARMOR_RED_TYPE;
			}
			// Does the player have any armor already?
			else if (other.armortype == 0 ) {
				// No armor present, give green with armor shards
				other.items = other.items | IT_ARMOR1;
				other.armortype = ARMOR_GRN_TYPE;
			}
			
			if (self.armorvalue > 0) {
				s = ftos(self.armorvalue);
				acount = BackpackText(other, s, " armor shards", acount);
			}
		}
	}
	
	//----------------------------------------------------------------------
	// Check for Silver/Gold/Custom keys if coop active
	//----------------------------------------------------------------------
	if (coop > 0) {
		if (self.items & IT_KEY1) {
			other.items = other.items | IT_KEY1;
			acount = BackpackText(other, "Silver Key", "", acount);
		}
		if (self.items & IT_KEY2) {
			other.items = other.items | IT_KEY2;
			acount = BackpackText(other, "Gold Key", "", acount);
		}
		if (self.moditems & IT_CKEY1) {
			other.moditems = other.moditems | IT_CKEY1;
			other.ckeyname1 = self.ckeyname1;
			acount = BackpackText(other, self.ckeyname1, "", acount);
		}
		if (self.moditems & IT_CKEY2) {
			other.moditems = other.moditems | IT_CKEY2;
			other.ckeyname2 = self.ckeyname2;
			acount = BackpackText(other, self.ckeyname2, "", acount);
		}
		if (self.moditems & IT_CKEY3) {
			other.moditems = other.moditems | IT_CKEY3;
			other.ckeyname3 = self.ckeyname3;
			acount = BackpackText(other, self.ckeyname3, "", acount);
		}
		if (self.moditems & IT_CKEY4) {
			other.moditems = other.moditems | IT_CKEY4;
			other.ckeyname4 = self.ckeyname4;
			acount = BackpackText(other, self.ckeyname4, "", acount);
		}
	}

	//----------------------------------------------------------------------
	// Check for Powerups if coop active
	//----------------------------------------------------------------------
	if (coop > 0) {
		if (self.items & IT_INVISIBILITY) {
			other.items = other.items | IT_INVISIBILITY;
			acount = BackpackText(other, "InvRing", "", acount);
			other.invisible_finished = self.invisible_finished;
			other.invisible_time = self.invisible_time;
			other.invisible_sound = self.invisible_sound;
		}
		if (self.items & IT_SUIT) {
			other.items = other.items | IT_SUIT;
			acount = BackpackText(other, "EnvSuit", "", acount);
			other.radsuit_finished = self.radsuit_finished;
			other.rad_time = self.rad_time;
		}
		if (self.items & IT_QUAD) {
			other.items = other.items | IT_QUAD;
			acount = BackpackText(other, "QuadDam", "", acount);
			other.super_damage_finished = self.super_damage_finished;
			other.super_time = self.super_time;
			other.super_sound = self.super_sound;
		}
		if (self.moditems & IT_ARTSHARP) {
			other.moditems = other.moditems | IT_ARTSHARP;
			acount = BackpackText(other, "ShpShoot", "", acount);
			other.sharpshoot_finished = self.sharpshoot_finished;
			other.sharpshoot_time = self.sharpshoot_time;
			other.sharpshooter_sound = self.sharpshooter_sound;
		}
		if (self.moditems & IT_ARTPIERCE) {
			other.moditems = other.moditems | IT_ARTPIERCE;
			acount = BackpackText(other, "Piercer", "", acount);
			other.nailpiercer_finished = self.nailpiercer_finished;
			other.nailpiercer_time = self.nailpiercer_time;
			other.nailpiercer_sound = self.nailpiercer_sound;
		}		
		if (self.moditems & IT_ARTAIRTANK) {
			other.moditems = other.moditems | IT_ARTAIRTANK;
			acount = BackpackText(other, "AirTank", "", acount);
			other.airtank_finished = self.airtank_finished;
			other.airtank_time = self.airtank_time;
			other.airtank_sound = self.airtank_sound;
		}
		if (self.moditems & IT_ARTJUMPBOOTS) {
			other.moditems = other.moditems | IT_ARTJUMPBOOTS;
			acount = BackpackText(other, "JumpBoots", "", acount);
			other.jumpboots_finished = self.jumpboots_finished;
			other.jumpboots_time = self.jumpboots_time;
			other.jumpboots_airlvl = self.jumpboots_airlvl;
			other.jumpboots_airmax = self.jumpboots_airmax;
		}
	}

	sprint (other, " from a backpack\n");
	if (self.noise != SOUND_EMPTY) 
		sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	// Check ammo limts, change to best weapon and set ammo type
	bound_other_ammo (other);
	if (deathmatch) other.weapon = W_BestWeapon(other);
	W_SetCurrentAmmo (other);
	
	// Quick exit, no need for following stuff
	if (self.progspawnlist) return;

	// Random ammo backpacks are actual items
	if (self.classtype == CT_AMMOITEMPACK) {
		// hide item and check for respawn
		item_finished();
		check_item_respawn();
	}
	// Temporary backpack
	else remove(self);
};

//----------------------------------------------------------------------
void() DropBackpack =
{
	local entity item;

	//----------------------------------------------------------------------
	// Check for player because of other items
	if (self.classtype != CT_PLAYER) {
		if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells))
			return;	// nothing in it
	}

	item = spawn();
	item.classtype = CT_AMMODROPPACK;
	item.classgroup = CG_AMMOITEM;
	item.classname = "item_backpack";
	item.origin = self.origin - '0 0 20';
	// No way to cache something different without adding to world.qc
	// Default quake sound for backpacks dropped from monsters
	item.noise = AMMO_PICKUP;
	
	//----------------------------------------------------------------------
	// Pyro Enforcers drop armor shards instead!!!
	//----------------------------------------------------------------------
	if (self.classtype == CT_MONPYRO || self.classtype == CT_MONFUMIGATOR) 
		item.armorvalue = floor(1 + (random() * self.ammo_shells));
	else {
		// Everything else drops ammo
		item.ammo_shells = self.ammo_shells;
		item.ammo_nails = self.ammo_nails;
		item.ammo_rockets = self.ammo_rockets;
		item.ammo_cells = self.ammo_cells;
	}

	//----------------------------------------------------------------------
	// Reset backpack inventory before any test
	item.items = item.moditems = item.customkey = 0;

	//----------------------------------------------------------------------
	// If player dropping backpack check for extra stuff
	if (self.classtype == CT_PLAYER) {
		// Copy over items for coop players to pickup
		if (coop > 0) {
			// Copy all items + keys
			item.items = self.items;
			item.moditems = self.moditems;
			item.customkey = self.customkey;
			// Copy current armour type + value
			item.armortype = self.armortype;
			item.armorvalue = self.armorvalue;
			
			// Copy over custom key netnames
			if (self.moditems & IT_CKEY1) item.ckeyname1 = self.ckeyname1;
			if (self.moditems & IT_CKEY2) item.ckeyname2 = self.ckeyname2;
			if (self.moditems & IT_CKEY3) item.ckeyname3 = self.ckeyname3;
			if (self.moditems & IT_CKEY4) item.ckeyname4 = self.ckeyname4;
			
			//----------------------------------------------------------------------
			// Copy over any powerup timers
			// Cannot die with invulnerability so not checked!
			if (coop_artifacts == TRUE) {
				if (self.items & IT_INVISIBILITY) {
					item.invisible_finished = self.invisible_finished;
					item.invisible_time = self.invisible_time;
					item.invisible_sound = self.invisible_sound;
				}
				if (self.items & IT_SUIT) {
					item.radsuit_finished = self.radsuit_finished;
					item.rad_time = self.rad_time;
				}
				if (self.items & IT_QUAD) {
					item.super_damage_finished = self.super_damage_finished;
					item.super_time = self.super_time;
					item.super_sound = self.super_sound;
				}
				if (self.moditems & IT_ARTSHARP) {
					item.sharpshoot_finished = self.sharpshoot_finished;
					item.sharpshoot_time = self.sharpshoot_time;
					item.sharpshooter_sound = self.sharpshooter_sound;
				}
				if (self.moditems & IT_ARTPIERCE) {
					item.nailpiercer_finished = self.nailpiercer_finished;
					item.nailpiercer_time = self.nailpiercer_time;
					item.nailpiercer_sound = self.nailpiercer_sound;
				}
				if (self.moditems & IT_ARTAIRTANK) {
					item.airtank_finished = self.airtank_finished;
					item.airtank_time = self.airtank_time;
					item.airtank_sound = self.airtank_sound;
				}
				if (self.moditems & IT_ARTJUMPBOOTS) {
					item.jumpboots_finished = self.jumpboots_finished;
					item.jumpboots_time = self.jumpboots_time;
					item.jumpboots_airlvl = self.jumpboots_airlvl;
					item.jumpboots_airmax = self.jumpboots_airmax;
				}
			}
		}
		//----------------------------------------------------------------------
		// Default is DM only, current weapon only
		else {
			// Check for any special MOD weapons
			if (self.weapon == IT_AXE && self.moditems & IT_UPGRADE_AXE) 
				item.moditems = IT_UPGRADE_AXE;
			else if (self.weapon == IT_SUPER_SHOTGUN && self.moditems & IT_UPGRADE_SSG) 
				item.moditems = IT_UPGRADE_SSG;
			else if (self.weapon == IT_LIGHTNING && self.moditems & IT_UPGRADE_LG) 
				item.moditems = IT_UPGRADE_LG;
			// Copy over current weapon ONLY to backpack
			item.items = self.weapon;
		}
	}
	
	// Give the backpack some random toss!
	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);
	
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel (item, MODEL_BACKPACK);
	setsize (item, '-16 -16 0', '16 16 56');
	item.touch = item_touch;
	item.touch2 = BackpackTouch;
	
	//----------------------------------------------------------------------
	// 1=green, 2=blue, 3=red, 4=golden, 5=swampy, 6=white, 7=flesh
	// green=shells, blue=cells, red=rockets
	//----------------------------------------------------------------------
	if (self.classtype == CT_MONDEFENDER) item.skin = 1;
	else if (self.classtype == CT_MONARMYGRENADE) item.skin = 1;
	else if (self.classtype == CT_MONARMYPLASMA) item.skin = 2;
	else if (self.classtype == CT_MONELIMATOR) item.skin = 2;
	else if (self.classtype == CT_MONCENTURION) item.skin = 2;
	else if (self.classtype == CT_MONARMYROCKET) item.skin = 3;
	else if (self.classtype == CT_MONPYRO) item.skin = 4;
	else if (self.classtype == CT_MONFUMIGATOR) item.skin = 5;
	else if (self.classtype == CT_MONENFORCER) item.skin = 7;
	
	// Default = remove after 2 minutes, stay if coop active
	if (coop == 0) item.item_expired = time + 120;
	else item.item_expired = 0;
	
	item.item_flrcheck = fabs(item.mins_z) + 16;
	item.think = item_thinkloop;		// Check floor
	item.nextthink = time + 0.3;		// Let backpack drop first
};

//======================================================================
/*QUAKED item_backpack (0 .5 .8) (-16 -16 0) (16 16 56) SHELLS NAILS ROCKETS CELLS RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/w_backpack.mdl"); }
Backpack with random/exact amount of ammo
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
count        : random amount of ammo to give (works with spawnflags)
ammo_shells  : exact amount of shells
ammo_nails   : exact amount of spikes
ammo_rockets : exact amount of rockets
ammo_cells   : exact amount of cells
armorvalue   : armor shards (gives green armor if none present)
armortype    : 1 = random amount of armor shards (uses count)
exactskin    : 0=Original, 1=green, 2=blue, 3=red, 4=yellow, 5=swamp, 6=white, 7=pale
noise         : pickup sound (def=items/backpack_ammo.wav)
respawn_time  : time to wait before respawning (1-x seconds, default varies)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
SHELLS  : ammo for SG / SSG / RG
NAILS   : ammo for NG / SNG
ROCKETS : ammo for GL / RL
CELLS   : ammo for LG
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Backpack with random/exact amount of ammo
Cannot be used to drop weapons or armour!

======================================================================*/
void() item_backpack_setup =
{
	// Empty netname for backpack routine
	self.netname = "";
	self.origin = self.origin + '0 0 12';
	
	// reset frame, weapon and armour type, but not value
	self.frame = self.weapon = self.items = 0;
	self.frame_override = self.frame_box = 0;
	
	// Make sure the ammo/armor quantites are NOT negative!
	if (self.ammo_shells < 0) self.ammo_shells = 0;
	if (self.ammo_nails < 0) self.ammo_nails = 0;
	if (self.ammo_rockets < 0) self.ammo_rockets = 0;
	if (self.ammo_cells < 0) self.ammo_cells = 0;
	if (self.armorvalue < 0) self.armorvalue = 0;

	// Check if exact skin is within range
	if(self.exactskin < 0 || self.exactskin > 7) self.exactskin = 0;
	self.skin = self.exactskin;
	
	// Check for random ammo setup (uses spawnflags)
	if (self.spawnflags & BACKPACK_SHELLS) self.ammo_shells = -1;
	if (self.spawnflags & BACKPACK_NAILS) self.ammo_nails = -1;
	if (self.spawnflags & BACKPACK_ROCKETS) self.ammo_rockets = -1;
	if (self.spawnflags & BACKPACK_CELLS) self.ammo_cells = -1;
	if (self.armortype == 1) self.armorvalue = -1;

	// setup random quantity (default = 5)
	if (self.ammo_shells < 0 || self.ammo_nails < 0 ||
		self.ammo_rockets < 0 || self.ammo_cells < 0 ||
		self.armorvalue < 0) {
		if (!self.count) self.count = 5;
	}
	// No random ammo required, reset count
	else self.count = 0;

	// Check backpack has ammo to pickup
	if (self.ammo_shells == 0 && self.ammo_nails == 0 &&
		self.ammo_rockets == 0 && self.ammo_cells == 0 &&
		self.armorvalue == 0) {
		dprint("\b[BACKPACK]\b is empty, removing\n");
		spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}
	
	item_start ();
};

//----------------------------------------------------------------------
void() item_backpack =
{
	self.mdl = MODEL_BACKPACK;
	precache_model (self.mdl);
	
	if (self.noise == "") self.noise = "items/backpack_ammo.wav";
	precache_sound(self.noise);

	self.flags = FL_ITEM;
	if (self.classtype <= 0) self.classtype = CT_AMMOITEMPACK;
	self.classgroup = CG_AMMOITEM;
	self.bbmins = '-16 -16 -12';
	self.bbmaxs = '16 16 32';
	self.part_active = PARTICLE_STYLE_BACKPACK;
	if (self.respawn_time == 0) self.respawn_time = RESPAWN_BACKPACK;
	self.respawn_ofs = '0 0 12';
	self.touch2 = BackpackTouch;
	
	// Match particle effect to skin colour
	if (self.exactskin == 1) self.respawn_style = PARTICLE_BURST_GREEN;
	else if (self.exactskin == 2) self.respawn_style = PARTICLE_BURST_BLUE;
	else if (self.exactskin == 3) self.respawn_style = PARTICLE_BURST_RED;
	else if (self.exactskin == 4) self.respawn_style = PARTICLE_BURST_YELLOW;
	else if (self.exactskin == 5) self.respawn_style = PARTICLE_BURST_GREEN;
	else self.respawn_style = PARTICLE_BURST_WHITE;
	self.respawn_style = self.respawn_style | PARTICLE_BURST_CENTER;
	
	// Double checking all the different ammo combinations can be
	// time consuming, delay spawn the backpack instead
	self.think = item_backpack_setup;
	self.nextthink = time + 0.1 + random();
};

//----------------------------------------------------------------------
void() item_backpack_armour =
{
	if (self.noise == "") self.noise = "items/backpack_armour.wav";
	precache_sound(self.noise);
	self.classtype = CT_ARMORITEMPACK;

	// Default armour amount is 15
	// Check for different armour types
	if (self.spawnflags & BACKPACK_GRNTYPE) {
		self.armortype = ARMOR_GRN_TYPE; self.exactskin = 1;
		if (self.armorvalue < 1) self.armorvalue = BACKARMGRN;
	}
	else if (self.spawnflags & BACKPACK_YELTYPE) {
		self.armortype = ARMOR_YEL_TYPE; self.exactskin = 4;
		if (self.armorvalue < 1) self.armorvalue = BACKARMYEL;
	}
	else if (self.spawnflags & BACKPACK_REDTYPE) {
		self.armortype = ARMOR_RED_TYPE; self.exactskin = 3;
		if (self.armorvalue < 1) self.armorvalue = BACKARMRED;
	}
	// default = shards, no armour type
	else {
		self.armortype = 0; self.exactskin = 4;
		if (self.armorvalue < 1) self.armorvalue = BACKARMGRN;
	}
	
	// make sure all ammo is removed from backpack
	if (self.spawnflags & BACKPACK_SHELLS) self.spawnflags = self.spawnflags - BACKPACK_SHELLS;
	if (self.spawnflags & BACKPACK_NAILS) self.spawnflags = self.spawnflags - BACKPACK_NAILS;
	if (self.spawnflags & BACKPACK_ROCKETS) self.spawnflags = self.spawnflags - BACKPACK_ROCKETS;
	if (self.spawnflags & BACKPACK_CELLS) self.spawnflags = self.spawnflags - BACKPACK_CELLS;

	// Feed back into backpack function
	item_backpack();
};

//----------------------------------------------------------------------
void() DropHealthpack =
{
	local entity item;
	// No cache no drops!
	if (healthcache <= 0) return;
	
	item = spawn();
	item.classgroup = CG_HEALTH;
	item.classname = "item_health";
	item.origin = self.origin - '0 0 20';
	item.skin_override = FALSE;

	// Check for regular Health Pack
	if (self.healamount == HEAL_NORM) {
		item.classtype = CT_HEALNORM;
		// Randomize the health pack, defaults are boring!
		item.healamount = floor((HEAL_NORM/2) + (random()* HEAL_NORM/2));
		item.noise = SOUND_HEAL25;
		// Pick new medieval version or original
		if (item_skintype(item) == SKIN_MEDIEVAL)
			item.mdl = "progs/health_25.mdl";
		else item.mdl = "progs/health_25b.mdl";
	}
	/* Check for megahealth! - This is crazy!
	else if (self.healamount == HEAL_MEGA) {
		item.classtype = CT_HEALMEGA;
		item.healamount = HEAL_MEGA;
		item.noise = SOUND_HEAL100;
		// Pick new medieval version or original
		if (item_skintype(item) == SKIN_MEDIEVAL)
			item.mdl = "progs/health_100.mdl";
		else item.mdl = "progs/health_100b.mdl";
	} */
	// Default = rotten Health Pack
	else {
		item.classtype = CT_HEALROT;
		// Randomize the health pack, defaults are boring!
		item.healamount = floor((HEAL_ROT/2) + (random()* HEAL_ROT/2));
		item.noise = SOUND_HEAL15;
		// Pick new medieval version or original
		if (item_skintype(item) == SKIN_MEDIEVAL)
			item.mdl = "progs/health_15.mdl";
		else item.mdl = "progs/health_15b.mdl";
	}
	
	// Give the backpack some random toss!
	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);
	
	// Setup item correctly
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	
	setmodel (item, item.mdl);
	item.bbmins = VEC_HEAL_MIN;
	item.bbmaxs = VEC_HEAL_MAX;
	setsize(item, item.bbmins, item.bbmaxs);
	item.touch = item_touch;
	item.touch2 = health_touch;
	// Once only
	item.respawn_time = 0;
	// Random rotation
	item.angles_y = rint(random()*359);
	
	// Default = remove after 2 minutes, stay if coop active
	if (coop == 0) item.item_expired = time + 120;
	else item.item_expired = 0;
	
	item.item_flrcheck = fabs(item.mins_z) + 16;
	item.think = item_thinkloop;		// Check floor
	item.nextthink = time + 0.3;		// Let item drop first
};

//----------------------------------------------------------------------
void() CacheHealthpacks =
{
	if (healthcache) return;
	healthcache = TRUE;
	// Rotten Health pack
	precache_model(MODEL_HEAL15);
	precache_model(MODEL_HEAL15B);
	precache_sound(SOUND_HEAL15);
	// Regular Health Pack
	precache_model(MODEL_HEAL25);
	precache_model(MODEL_HEAL25B);
	precache_sound(SOUND_HEAL25);
	// Mega Health Pack
	//precache_model(MODEL_HEAL100);
	//precache_model(MODEL_HEAL100B);
	//precache_sound(SOUND_HEAL100);
};

//======================================================================
// Re-direct items from Quoth
// Allows for Quoth maps to be loaded into AD (not 100% compatible)
// 
//======================================================================
// Quoth Hammer requests to Shadow Axe!
void() weapon_hammer = { weapon_upgrade_axe(); };

// Quoth Plasma Gun requests to LG Upgrade!
void() weapon_plasmagun = { weapon_upgrade_lg(); };

// Quoth coop holdable weapon (removed on spawn)
void() weapon_bomb = { remove(self); }

// Trinity (3x nail damage) requests to Nail Piecer!
void() item_artifact_trinity = { item_artifact_nail_piercer(); };

// Cross of Deflection requests to Blast Belt!
void() item_artifact_cross = { item_artifact_blastbelt(); };


