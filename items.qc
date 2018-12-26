/*======================================================================
 ITEM FUNCTIONS
======================================================================*/
float ITEM_RESPAWN = 16;	// Item will respawn
float ITEM_FLOATING = 32;	// Spawn floating
float ITEM_NOEFFECTS = 128;	// Disable particles and effects

float H_ROTTEN = 1;		// Rotten
float H_MEGA = 2;		// Mega Health

float A_LARGE = 1;		// Used by ammo boxes
float A_LID = 2;		// Display Lid

float ITEM_CKEY1 = 1;	// Custom Key 1
float ITEM_CKEY2 = 2;	// Custom Key 2
float ITEM_CKEY3 = 4;	// Custom Key 3
float ITEM_CKEY4 = 8;	// Custom Key 4

float BACKPACK_SHELLS = 1;
float BACKPACK_NAILS = 2;
float BACKPACK_ROCKETS = 4;
float BACKPACK_CELLS = 8;

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

float RESPAWN_PARTICLES = 32;		// Particle burst for ring/center
float RESPAWN_EXPTIME = 1;			// Particles burst lifetime
float RESPAWN_EXPRADIUS = 12;		// Particle ring radius

//----------------------------------------------------------------------
// Animated skin for new BASE health boxes
//----------------------------------------------------------------------
float MODEL_ANIM_SPEED = 0.3;

void()	healthx_0 = [0, healthx_1] {self.skin = 0; self.nextthink = time + MODEL_ANIM_SPEED;
if (self.attack_finished > time) self.think = SUB_Null;};
void()	healthx_1 = [0, healthx_2] {self.skin = 1; self.nextthink = time + MODEL_ANIM_SPEED;
if (self.attack_finished > time) self.think = SUB_Null;};
void()	healthx_2 = [0, healthx_3] {self.skin = 2; self.nextthink = time + MODEL_ANIM_SPEED;
if (self.attack_finished > time) self.think = SUB_Null;};
void()	healthx_3 = [0, healthx_0] {self.skin = 3; self.nextthink = time + MODEL_ANIM_SPEED;
if (self.attack_finished > time) self.think = SUB_Null;};

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
void() item_finished =
{
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
	// Is the item setup to instantly respawn? (time = -1)
	if (self.respawn_time < 1) item_respawn();
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
					self.spawnflags = self.spawnflags - ITEM_RESPAWN;
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
	if ( other.flags & FL_NOTARGET ) return;
	if (self.attack_finished > time) return;
	
	self.touch2();	// defined by item function
};

//----------------------------------------------------------------------
void() item_restore =
{
	// Ammo boxes can have special animation frames or lids!
	if (self.classgroup == CG_AMMOITEM) {
		// Has frame_box been setup yet?
		if (self.frame_box < 1) self.frame_box = rint(1 + random()*6);
		else if (self.frame_box > 7) self.frame_box = 1;

		// Any LID (shells/spikes) defined?
		if (self.spawnflags & A_LID && self.attachment) {
			// Setup LID attachment entity (match angles/origin)
			setmodel(self.attachment, self.headmdl);
			setsize (self.attachment, VEC_ORIGIN, VEC_ORIGIN);
			setorigin(self.attachment, self.origin);
			self.attachment.angles = self.angles;
			self.attachment.frame = self.frame_box;
			
			// LID has different skins for shells and spikes
			if (self.classtype == CT_AMMOSHELLS) self.attachment.skin = self.skin;
			else self.attachment.skin = 2 + self.skin;
		}
		// Any special frames (rockets/plasma) defined?
		else if (self.frame_override) self.frame = self.frame_box;
	}
	
	// Setup animated textures for old style ID health boxes
	if (self.classtype == CT_HEALNORM || self.classtype == CT_HEALMEGA) {
		if (self.skin_override || world.worldtype == 2) {
			self.nextthink = time + random()*0.5;
			self.think = healthx_0;
		}
	}
};

//----------------------------------------------------------------------
void() item_delay =
{
	if (self.touchedvoid) {entity_hide(self); return;}
	if (self.estate == ESTATE_DISABLE) return;
	
	// Remove the START OFF functionality
	if (self.spawnflags & ENT_STARTOFF) 
		self.spawnflags = self.spawnflags - ENT_STARTOFF;

	//----------------------------------------------------------------------
	// Check for Axe / Shotgun / LG upgrade monster spawn exceptions?
	if (self.upgrade_axe || self.upgrade_ssg || self.upgrade_lg) {
		// Has ANY player (server test not individual) 
		// picked up the relevant upgrade weapons?
		if (self.upgrade_axe && !query_configflag(SVR_UPDAXE) ) return;
		if (self.upgrade_ssg && !query_configflag(SVR_UPDSSG) ) return;
		if (self.upgrade_lg && !query_configflag(SVR_UPDLG) ) return;
	}

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
		
	// Finalize item location (check drop to floor)
	if( !(self.spawnflags & ITEM_FLOATING) ) {
		self.movetype = MOVETYPE_TOSS;	
		self.origin_z = self.origin_z + 6;
		droptofloor();
		if (pointcontents(self.origin) == CONTENT_SOLID) {
			dprint ("\n\b[Item]\b "); dprint (self.classname);
			dprint (" stuck at ("); dprint (vtos(self.origin)); dprint (")\n");
			spawn_marker(self.origin);
			remove(self);
			return;
		} 
	}

	// Spawn particle emitter if particles active and not blocked
	if (query_configflag(SVR_PARTICLES) == SVR_PARTICLES) {
		if (!(self.spawnflags & ITEM_NOEFFECTS) && self.part_active > 0) 
			self.part_emitter = spawn_pemitter(self, self, self.part_active, PARTICLE_START_ON);
	}
	
	// Finally setup entity ready for use
	self.oldorigin = self.origin;
	item_restore();
};

//----------------------------------------------------------------------
void() item_on =
{
	self.estate = ESTATE_ON;
	self.movetype = MOVETYPE_NONE;

	// Check for delayed/trigger_once functionality?
	if (self.spawnflags & ENT_STARTOFF || self.attack_finished > time)
		self.solid = SOLID_NOT;
	else {
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
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
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

	// Cannot have multiple upgrade restrictions on items
	remove_duplicate_upgrades();
	
	// Check for Axe / Shotgun item exceptions?
	if (self.upgrade_axe || self.upgrade_ssg) {
		if ( !(self.spawnflags & ENT_STARTOFF) ) {
			dprint("\b[ITEM]\b need spawn delay for axe/shotgun\n");
			spawn_marker(self.origin);
			remove(self);
			return;
		}
	}

	// If respawn timer negative then wait for a trigger
	if (self.respawn_time < 0) self.respawn_trig = TRUE;
	if (self.respawn_count < 0) self.respawn_count = 1;
	
	// Setup Entity State functionality
	item_estate_setup();

	if (self.spawnflags & ENT_STARTOFF) self.estate_off();
	else {
		// delay drop to floor to make sure all doors have been spawned
		// spread think times so they don't all happen at same time
		self.nextthink = time + 0.1 + random()*0.5;
		self.think = self.estate_use;
	}
};

/*======================================================================
 HEALTH FLASK/BOX
 
 targ - entity to receive healing
 t_healamount - the quanity to heal entity with
 ignore - whether to ignore max health amount
 returns FALSE if cannot heal entity by healamount
 returns TRUE if healamount applied
======================================================================*/
float (entity targ, float t_healamount, float ignore) T_Heal =
{
	if (targ.health <= 0) return FALSE;
	if ((!ignore) && (targ.health >= other.max_health)) return FALSE;
	t_healamount = ceil(t_healamount);

	targ.health = targ.health + t_healamount;
	if ((!ignore) && (targ.health >= other.max_health))
		targ.health = other.max_health;
		
	if (targ.health > HEAL_MEGAMAX) targ.health = HEAL_MEGAMAX;
	
	// Healing the player negates some debuffs
	ResetDebuffBurning(targ);
	ResetDebuffPoisoned(targ);
	return TRUE;
};

//----------------------------------------------------------------------
void() item_megahealth_rot =
{
	// Check for maximum health limit
	if (self.owner.health > self.owner.max_health) {
		self.owner.health = self.owner.health - 1;
		self.nextthink = time + 1;
	}
	else {
		// it is possible for a player to die and respawn between rots
		// Double check player has megahealth before removing it
		if (self.owner.items & IT_SUPERHEALTH)
			self.owner.items = self.owner.items - IT_SUPERHEALTH;
		
		// Check to see if item can respawn
		self.alpha = 0.1;
		check_item_respawn();
	}
};

//----------------------------------------------------------------------
void() health_touch =
{
	local string s;

	// Megahealth?  Ignore max_health...
	if (self.classtype == CT_HEALMEGA) {
		if (other.health >= HEAL_MEGAMAX) return;
		if (!T_Heal(other, self.healamount, 1)) return;
	}
	else { 
		if (!T_Heal(other, self.healamount, 0)) return;
	}
	
	sprint(other, "You receive ");
	s = ftos(self.healamount);
	sprint(other, s);
	sprint(other, " health\n");
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	item_finished();

	// Megahealth = rot down the player's super health
	// Need to wait for megahealth to finish before respawn
	if (self.classtype == CT_HEALMEGA) {
		other.items = other.items | IT_SUPERHEALTH;
		self.nextthink = time + 5;
		self.think = item_megahealth_rot;
		self.owner = other;
	}
	else check_item_respawn();
	
	activator = other;
	SUB_UseTargets();
};	

/*======================================================================
/*QUAKED item_health (0.3 0.3 1) (-16 -16 0) (16 16 32) ROTTEN MEGA x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/health_25.mdl"); }
15, 25 or 100 Health
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
angle         : = -1 Random rotation everytime spawned (default)
skin_override : Override world type 1=Base Green, 2=Medieval Wood
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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

======================================================================*/
void() item_health =
{	
	if (self.spawnflags & H_ROTTEN) {
		if (world.worldtype < 2 && !self.skin_override) {
			// New Medieval style red flask
			self.mdl = "progs/health_15.mdl";
			self.respawn_style = PARTICLE_BURST_RED + PARTICLE_BURST_RING;
		}
		else {
			// Original ID pickup model
			self.mdl = "progs/health_15b.mdl";
			self.respawn_style = PARTICLE_BURST_WHITE + PARTICLE_BURST_RING;
		}
		self.noise = SOUND_HEAL15;
		self.healamount = HEAL_ROT;
		self.classtype = CT_HEALROT;
		self.respawn_effect = TRUE;
		self.respawn_ofs = '0 0 16';
	}
	else if (self.spawnflags & H_MEGA) {
		if (world.worldtype < 2 && !self.skin_override) {
			// New Medieval style red flask
			self.mdl = "progs/health_100.mdl";
			self.respawn_style = PARTICLE_BURST_RED + PARTICLE_BURST_RING;
		}
		else {
			// Original ID pickup model
			self.mdl = "progs/health_100b.mdl";
			self.respawn_style = PARTICLE_BURST_WHITE + PARTICLE_BURST_RING;
		}
		self.noise = SOUND_HEAL100;
		self.healamount = HEAL_MEGA;
		self.classtype = CT_HEALMEGA;
		self.part_active = PARTICLE_STYLE_MEGAH;
		self.respawn_effect = TRUE;
		self.respawn_ofs = '0 0 28';
	}
	else {
		if (world.worldtype < 2 && !self.skin_override)
		{
			// New Medieval style red flask
			self.mdl = "progs/health_25.mdl";
			self.respawn_style = PARTICLE_BURST_RED + PARTICLE_BURST_RING;
			self.respawn_ofs = '0 0 24';
		}
		else {
			// Original ID pickup model
			self.mdl = "progs/health_25b.mdl";
			self.respawn_style = PARTICLE_BURST_WHITE + PARTICLE_BURST_RING;
			self.respawn_ofs = '0 0 16';
		}
		self.noise = SOUND_HEAL25;
		self.healamount = HEAL_NORM;
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

	// Setting the angle key in the editor to UP/DOWN = random rotation	
	if (self.angles_y < 0 || (self.angles_y == 0 && query_configflag(SVR_ITEMROTATE) == FALSE) ) 
		self.angles_y = rint(random()*359);

	self.touch2 = health_touch;
	self.classgroup = CG_HEALTH;
	self.bbmins = VEC_HEAL_MIN;
	self.bbmaxs = VEC_HEAL_MAX;
	if (self.respawn_time == 0) self.respawn_time = RESPAWN_HEALTH;
	item_start ();
};

//======================================================================
// armor_touch
//======================================================================
void() armor_touch =
{
	if (other.armortype*other.armorvalue >= self.armortype*self.armorvalue) return;
		
	other.armortype = self.armortype;
	other.armorvalue = self.armorvalue;
	other.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + self.items;

	sprint(other, "You got armor\n");
	sound(other, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	item_finished();
	check_item_respawn();

	activator = other;
	SUB_UseTargets();
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

	item_start ();
};

/*======================================================================
/*QUAKED item_armor1 (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/armour.mdl"); }
Green Armour with 100 points of protection
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	self.mdl = "progs/armour.mdl";
	precache_model (self.mdl);
	self.skin = 0;
	self.classtype = CT_ARMOR1;
	self.items = IT_ARMOR1;
	self.armortype = ARMOR_GRN_TYPE;
	self.armorvalue = ARMOR_GRN_VALUE;
	self.respawn_effect = TRUE;
	self.respawn_style = PARTICLE_BURST_GREEN + PARTICLE_BURST_RING;
	self.respawn_ofs = '0 0 24';
	item_armor_setup();
};

/*======================================================================
/*QUAKED item_armor2 (0 0.5 0.8) (-16 -16 0) (16 16 56) x BLUESKIN x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/armour.mdl"); }
Yellow Armour with 150 points of protection
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	self.mdl = "progs/armour.mdl";
	precache_model (self.mdl);
	self.classtype = CT_ARMOR2;
	self.items = IT_ARMOR2;
	self.armortype = ARMOR_YEL_TYPE;
	self.armorvalue = ARMOR_YEL_VALUE;
	self.respawn_effect = TRUE;
	self.respawn_ofs = '0 0 24';

	// Setup alternative colour
	if (self.spawnflags & ARMOR_BLUE) {
		self.respawn_style = PARTICLE_BURST_BLUE + PARTICLE_BURST_RING;
		self.skin = 3;
	}
	else {
		self.respawn_style = PARTICLE_BURST_YELLOW + PARTICLE_BURST_RING;
		self.skin = 1;
	}
	
	item_armor_setup();
};

/*======================================================================
/*QUAKED item_armorInv (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/armour.mdl"); }
Red Armour with 200 points of protection
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	self.mdl = "progs/armour.mdl";
	precache_model (self.mdl);
	self.skin = 2;
	self.classtype = CT_ARMORINV;
	self.items = IT_ARMOR3;
	self.armortype = ARMOR_RED_TYPE;
	self.armorvalue = ARMOR_RED_VALUE;
	self.respawn_effect = TRUE;
	self.respawn_style = PARTICLE_BURST_RED + PARTICLE_BURST_RING;
	self.respawn_ofs = '0 0 24';
	item_armor_setup();
};

/*======================================================================
 Deathmatch Weapon Rules
======================================================================*/
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
	local float best, new, old;
	local float leave, moditem;

	// if the player was using his best weapon
	// change up to the new one if better		
	best = W_BestWeapon(other);

	// Deathmatch/coop switch
	if (deathmatch == 2 || coop) leave = TRUE;
	else leave = FALSE;
	
	//----------------------------------------------------------------------
	if (self.classtype == CT_UPGRADE_AXE) {
		if (leave && (other.moditems & IT_UPGRADE_AXE) ) return;
		update_configflag(SVR_UPDAXE, TRUE);
		moditem = TRUE;
		new = IT_UPGRADE_AXE;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_SHOTGUN) {
		if (leave && (other.items & IT_SHOTGUN) ) return;
		new = IT_SHOTGUN;
		other.ammo_shells = other.ammo_shells + AMMO_SHELLS_WPN;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_UPGRADE_SSG) {
		if (leave && (other.moditems & IT_UPGRADE_SSG) ) return;
		update_configflag(SVR_UPDSSG, TRUE);
		moditem = TRUE;
		new = IT_UPGRADE_SSG;
		other.ammo_shells = other.ammo_shells + AMMO_SHELLS_WPN;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_SUPER_SHOTGUN) {
		if (leave && (other.items & IT_SUPER_SHOTGUN) ) return;
		new = IT_SUPER_SHOTGUN;
		other.ammo_shells = other.ammo_shells + AMMO_SHELLS_WPN;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_NAILGUN) {
		if (leave && (other.items & IT_NAILGUN) ) return;
		new = IT_NAILGUN;
		other.ammo_nails = other.ammo_nails + AMMO_NAILS_WPN;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_SUPER_NAILGUN) {
		if (leave && (other.items & IT_SUPER_NAILGUN) ) return;
		new = IT_SUPER_NAILGUN;
		other.ammo_nails = other.ammo_nails + AMMO_NAILS_WPN;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_GRENADE_LAUNCHER) {
		if (leave && (other.items & IT_GRENADE_LAUNCHER) ) return;
		new = IT_GRENADE_LAUNCHER;
		other.ammo_rockets = other.ammo_rockets + AMMO_ROCKETS_WPN;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_ROCKET_LAUNCHER) {
		if (leave && (other.items & IT_ROCKET_LAUNCHER) ) return;
		new = IT_ROCKET_LAUNCHER;
		other.ammo_rockets = other.ammo_rockets + AMMO_ROCKETS_WPN;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_UPGRADE_LG) {
		if (leave && (other.moditems & IT_UPGRADE_LG) ) return;
		update_configflag(SVR_UPDLG, TRUE);
		moditem = TRUE;
		new = IT_UPGRADE_LG;
		other.ammo_cells = other.ammo_cells + AMMO_CELLS_WPN;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_LIGHTNING) {
		if (leave && (other.items & IT_LIGHTNING) ) return;
		new = IT_LIGHTNING;
		other.ammo_cells = other.ammo_cells + AMMO_CELLS_WPN;
	}
	//----------------------------------------------------------------------
	else return;

	if (self.classtype == CT_UPGRADE_AXE && other.moditems & IT_UPGRADE_AXE)
		sprint (other, "You got another axe to grind\n");
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
	sound (other, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	// Make sure no ammo is over limits
	bound_other_ammo (other);
	
	// Stop the player switching to weapons already got
	if (!deathmatch) {
		// Check for new shadow axe and SG and skip weapon switch
		if (moditem && new == IT_UPGRADE_AXE && other.moditems & new) new = FALSE;
		else if (new == IT_SHOTGUN && other.items & new) new = FALSE;
		// Stop switching to a lower tier weapon (DM Rules)
		// if (DM_RankForWeapon(other.weapon) < DM_RankForWeapon(new)) new = FALSE;
	}
	
	// Skip any weapon switch if no new weapon
	if (new != FALSE) {
		// change to the weapon and add to inventory
		old = other.items;
		other.items = other.items | new;
		if (moditem) other.moditems = other.moditems | new;
		
		// Check for best weapon (DM only) and switch to it!
		if (deathmatch) DM_Weapon (old, new);
		else other.weapon = new;
		W_SetCurrentAmmo(other);
	}

	// If co-op active, exit
	if (leave == TRUE) {
		// Make sure any targets on the weapon are fired for co-op
		// This is basically a run once check using state as a flag
		// Ideally no weapon should use important target triggers!
		// Code idea from Bengt Jardrup
		if (self.state == FALSE) {
			self.state = TRUE;
			activator = other;
			SUB_UseTargets ();
		}
		return;
	}

	// hide item and check for respawn
	item_finished();
	check_item_respawn();
	
	activator = other;
	SUB_UseTargets();
};

/*======================================================================
	WEAPONS
======================================================================*/
void() weapon_start =
{
	self.classgroup = CG_WEAPON;
	self.touch2 = weapon_touch;
	self.bbmins = VEC_WPNS_MIN;
	self.bbmaxs = VEC_WPNS_MAX;
	if (self.respawn_time == 0) self.respawn_time = RESPAWN_WEAPON;
	item_start ();
};

/*======================================================================
/*QUAKED weapon_upgrade_axe (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_shadaxe.mdl"); }
Shadow Axe, extra dmg and gib zombies
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	self.mdl = MODEL_GWEAP_UPAXE;
	precache_model (self.mdl);
	self.weapon = IT_UPGRADE_AXE;
	self.skin = 4;
	self.classtype = CT_UPGRADE_AXE;
	self.netname = "Shadow Axe";
	if (self.upgrade_axe != 0) self.upgrade_axe = FALSE;
	weapon_start();
};

/*======================================================================
/*QUAKED weapon_upgrade_ssg (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_shot3.mdl"); }
The Widowmaker Shotgun, extra dmg, triple shot
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	self.mdl = MODEL_GWEAP_UPSSG;
	precache_model (self.mdl);
	self.weapon = IT_UPGRADE_SSG;
	self.classtype = CT_UPGRADE_SSG;
	self.netname = "Widowmaker Shotgun";
	if (self.upgrade_ssg != 0) self.upgrade_ssg = FALSE;
	weapon_start();
};

/*======================================================================
/*QUAKED weapon_upgrade_lg (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_plasma.mdl"); }
The Plasma Gun, direct & splashdamage
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	self.mdl = MODEL_GWEAP_UPLG;
	precache_model (self.mdl);
	self.weapon = IT_UPGRADE_LG;
	self.classtype = CT_UPGRADE_LG;
	self.netname = "Plasma Gun";
	if (self.upgrade_lg != 0) self.upgrade_lg = FALSE;
	weapon_start();
};

/*======================================================================
/*QUAKED weapon_shotgun (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_shotgun.mdl"); }
Single barrel Shotgun
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	self.mdl = MODEL_GWEAP_SG;
	precache_model (self.mdl);
	self.weapon = IT_SHOTGUN;
	self.classtype = CT_SHOTGUN;
	self.netname = "Sawn-off Shotgun";
	weapon_start();
};

/*======================================================================
/*QUAKED weapon_supershotgun (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_shot.mdl"); }
Super Shotgun
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	// Query console variable 'temp1' for model upgrade option.
	// Cannot use global vars because they don't exist at this point
	if (query_configflag(SVR_UPDSSG)) { weapon_upgrade_ssg(); return; }

	self.mdl = MODEL_GWEAP_SSG;
	precache_model (self.mdl);
	precache_model (MODEL_GWEAP_UPSSG);	// New Shotgun (pre-cache)
	self.weapon = IT_SUPER_SHOTGUN;
	self.classtype = CT_SUPER_SHOTGUN;
	self.netname = "Double-barrelled Shotgun";
	weapon_start();
};

/*======================================================================
/*QUAKED weapon_nailgun (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_nail.mdl"); }
Perforator (Nailgun)
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	self.mdl = MODEL_GWEAP_NG;
	precache_model (self.mdl);
	self.weapon = IT_NAILGUN;
	self.classtype = CT_NAILGUN;
	self.netname = "Nailgun";
	weapon_start();
};

/*======================================================================
/*QUAKED weapon_supernailgun (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_nail2.mdl"); }
Super Perforator (Super Nailgun)
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	self.mdl = MODEL_GWEAP_SNG;
	precache_model (self.mdl);
	self.weapon = IT_SUPER_NAILGUN;
	self.classtype = CT_SUPER_NAILGUN;
	self.netname = "Super Nailgun";
	weapon_start();
};

/*======================================================================
/*QUAKED weapon_grenadelauncher (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_rock.mdl"); }
Grenade Launcher
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	self.mdl = MODEL_GWEAP_GL;
	precache_model (self.mdl);
	self.weapon = IT_GRENADE_LAUNCHER;
	self.classtype = CT_GRENADE_LAUNCHER;
	self.netname = "Grenade Launcher";
	weapon_start();
};

/*======================================================================
/*QUAKED weapon_rocketlauncher (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_rock2.mdl"); }
Rocket Launcher
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	self.mdl = MODEL_GWEAP_RL;
	precache_model (self.mdl);
	self.weapon = IT_ROCKET_LAUNCHER;
	self.classtype = CT_ROCKET_LAUNCHER;
	self.netname = "Rocket Launcher";
	weapon_start();
};

/*======================================================================
/*QUAKED weapon_lightning (0 0.5 0.8) (-16 -16 0) (16 16 56) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/g_light.mdl"); }
Thunderbolt Cannon
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	// Query console variable 'temp1' for model upgrade option.
	// Cannot use global vars because they don't exist at this point
	if (query_configflag(SVR_UPDLG)) { weapon_upgrade_lg(); return; }

	self.mdl = MODEL_GWEAP_LG;
	precache_model (self.mdl);
	self.weapon = IT_LIGHTNING;
	self.classtype = CT_LIGHTNING;
	self.netname = "Thunderbolt";
	weapon_start();
};

/*======================================================================
 AMMO
======================================================================*/
void() ammo_touch =
{
	local float best;

	// if the player was using his best weapon, 
	// change up to the new one if better		
	best = W_BestWeapon(other);

	//----------------------------------------------------------------------
	if (self.classtype == CT_AMMOSHELLS) {
		if (other.ammo_shells >= AMMO_MAXSHELLS) return;
		other.ammo_shells = other.ammo_shells + self.aflag;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_AMMONAILS) {
		if (other.ammo_nails >= AMMO_MAXNAILS) return;
		other.ammo_nails = other.ammo_nails + self.aflag;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_AMMOROCKETS) {
		if (other.ammo_rockets >= AMMO_MAXROCKETS) return;
		other.ammo_rockets = other.ammo_rockets + self.aflag;
	}
	//----------------------------------------------------------------------
	else if (self.classtype == CT_AMMOCELLS) {
		if (other.ammo_cells >= AMMO_MAXCELLS) return;
		other.ammo_cells = other.ammo_cells + self.aflag;
	}

	// Check/cap ammo limits
	bound_other_ammo (other);
	
	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other, "\n");
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	// change to a better weapon if appropriate
	if ( other.weapon == best ) {
		other.weapon = W_BestWeapon(other);
		W_SetCurrentAmmo (other);
	}

	// if changed current ammo, update it
	W_SetCurrentAmmo(other);

	// hide item and check for respawn
	item_finished();
	check_item_respawn();
	
	activator = other;
	SUB_UseTargets();
};

/*======================================================================
	Setup all Ammo with global parameters
======================================================================*/
void() item_ammo_setup =
{
	self.frame = 0;
	self.touch2 = ammo_touch;
	self.classgroup = CG_AMMOITEM;
	self.bbmins = VEC_AMMO_MIN;
	self.bbmaxs = VEC_AMMO_MAX;
	if (self.respawn_time == 0) self.respawn_time = RESPAWN_AMMO;

	// Query console variable 'temp1' for model upgrade option.
	// Cannot use global vars because they don't exist at this point
	// Move the new centered ammo models to match old ammo origin
	// The default is to move all ammo items to suit original id maps
	if (!query_configflag(SVR_ITEMOFFSET)) {
		self.oldorigin = self.origin + '16 16 0';
		setorigin(self, self.oldorigin);
	}

	// Override the world theme skin type
	if (self.skin_override > 0 && self.skin_override < 3)
		self.skin = self.skin_override - 1;
	// Switch to medieval (wood) skin for medieval/metal theme maps
	else if (world.worldtype < 2) self.skin = 1;

	// Setting the angle key in the editor to UP/DOWN = random rotation	
	if (self.angles_y < 0 || (self.angles_y == 0 && !query_configflag(SVR_ITEMROTATE)) ) 
		self.angles_y = rint(random()*359);

	// Setup lid attachment entity (defined in item setup)
	if (self.spawnflags & A_LID) {
		self.attachment = spawn();
		self.attachment.owner = self;
		setorigin(self.attachment, self.origin);
		self.attachment.solid = SOLID_NOT;
		self.attachment.movetype = MOVETYPE_NONE;
	}		

	item_start ();
};

/*======================================================================
/*QUAKED item_shells (0 .5 .8) (0 0 0) (32 32 32) BIG

/*QUAKED item_shells (0 .5 .8) (-16 -16 0) (16 16 32) BIG LID x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/ammo_shells0.mdl"); }
20 or 40 Shells
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
frame_box     : special animation frame number for LID (1-7)
skin_override : Override world type 1=Base Green, 2=Medieval Wood
aflag         : Ammo quantity override
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	if (self.spawnflags & A_LARGE) {
		self.mdl = "progs/ammo_shells1.mdl";
		self.headmdl = "progs/ammo_lidlarge.mdl";
		if (self.aflag < 1) self.aflag = AMMO_SHELLS_LGR;
	}
	else {
		self.mdl = "progs/ammo_shells0.mdl";
		self.headmdl = "progs/ammo_lidsmall.mdl";
		if (self.aflag < 1) self.aflag = AMMO_SHELLS_SML;
	}
	
	precache_model (self.mdl);
	precache_model (self.headmdl);
	self.classtype = CT_AMMOSHELLS;
	self.netname = "box of shells";
	self.respawn_style = PARTICLE_BURST_YELLOW + PARTICLE_BURST_RING;
	self.respawn_ofs = '0 0 24';
	self.respawn_effect = TRUE;
	item_ammo_setup();
};

/*======================================================================
/*QUAKED item_spikes (0 .5 .8) (0 0 0) (32 32 32) BIG

/*QUAKED item_spikes (0 .5 .8) (-16 -16 0) (16 16 32) BIG LID x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/ammo_nails0.mdl"); }
25 or 50 Spikes
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
frame_box     : special animation frame number for LID (1-7)
skin_override : Override world type 1=Base Green, 2=Medieval Wood
aflag         : Ammo quantity override
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	if (self.spawnflags & A_LARGE) {
		self.mdl = "progs/ammo_nails1.mdl";
		self.headmdl = "progs/ammo_lidlarge.mdl";
		if (self.aflag < 1) self.aflag = AMMO_NAILS_LGR;
	}
	else {
		self.mdl = "progs/ammo_nails0.mdl";
		self.headmdl = "progs/ammo_lidsmall.mdl";
		if (self.aflag < 1) self.aflag = AMMO_NAILS_SML;
	}
	
	precache_model (self.mdl);
	precache_model (self.headmdl);
	self.classtype = CT_AMMONAILS;
	self.netname = "box of nails";
	self.respawn_style = PARTICLE_BURST_WHITE + PARTICLE_BURST_RING;
	self.respawn_ofs = '0 0 24';
	self.respawn_effect = TRUE;
	item_ammo_setup();
};

/*======================================================================
/*QUAKED item_rockets (0 .5 .8) (0 0 0) (32 32 32) BIG

/*QUAKED item_rockets (0 .5 .8) (-16 -16 0) (16 16 32) BIG x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/ammo_rockets0.mdl"); }
5 or 10 Rockets
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
frame_box     : special animation frame number for box of ammo (1-7)
skin_override : Override world type 1=Base Green, 2=Medieval Wood
aflag         : Ammo quantity override
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	if (self.spawnflags & A_LARGE) {
		self.mdl = "progs/ammo_rockets1.mdl";
		if (self.aflag < 1) self.aflag = AMMO_ROCKETS_LGR;
	}
	else {
		self.mdl = "progs/ammo_rockets0.mdl";
		if (self.aflag < 1) self.aflag = AMMO_ROCKETS_SML;
	}
	
	precache_model (self.mdl);
	self.classtype = CT_AMMOROCKETS;
	self.netname = "box of rockets";
	if (self.spawnflags & A_LID) self.spawnflags = self.spawnflags - A_LID;
	self.frame_override = TRUE;
	self.respawn_style = PARTICLE_BURST_WHITE + PARTICLE_BURST_RING;
	self.respawn_ofs = '0 0 24';
	self.respawn_effect = TRUE;
	item_ammo_setup();
};

/*======================================================================
/*QUAKED item_cells (0 .5 .8) (0 0 0) (32 32 32) BIG

/*QUAKED item_cells (0 .5 .8) (-16 -16 0) (16 16 32) BIG x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/ammo_battery0.mdl"); }
6 or 12 Medieval Battery
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
skin_override : Override world type 1=Base Green, 2=Medieval Wood
aflag         : Ammo quantity override
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	if (self.spawnflags & A_LARGE) {
		self.mdl = "progs/ammo_battery1.mdl";
		if (self.aflag < 1) self.aflag = AMMO_CELLS_LGR;
	}
	else {
		self.mdl = "progs/ammo_battery0.mdl";
		if (self.aflag < 1) self.aflag = AMMO_CELLS_SML;
	}
	
	precache_model (self.mdl);
	self.classtype = CT_AMMOCELLS;
	self.netname = "battery";
	if (self.spawnflags & A_LID) self.spawnflags = self.spawnflags - A_LID;
	self.respawn_style = PARTICLE_BURST_GREEN + PARTICLE_BURST_RING;
	self.respawn_ofs = '0 0 24';
	self.respawn_effect = TRUE;
	item_ammo_setup();
};

/*======================================================================
/*QUAKED item_plasma (0 .5 .8) (0 0 0) (32 32 32) BIG

/*QUAKED item_plasma (0 .5 .8) (-16 -16 0) (16 16 32) BIG x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/ammo_cells0.mdl"); }
6 or 12 Cells
-------- KEYS --------
targetname    : toggle state (use trigger ent for exact state)
frame_box     : special animation frame number for box of ammo (1-7)
skin_override : Override world type 1=Base Green, 2=Medieval Wood
aflag         : Ammo quantity override
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	if (self.spawnflags & A_LARGE) {
		self.mdl = "progs/ammo_cells1.mdl";
		if (self.aflag < 1) self.aflag = AMMO_CELLS_LGR;
	}
	else {
		self.mdl = "progs/ammo_cells0.mdl";
		if (self.aflag < 1) self.aflag = AMMO_CELLS_SML;
	}
	
	precache_model (self.mdl);
	self.classtype = CT_AMMOCELLS;
	self.netname = "box of cells";
	if (self.spawnflags & A_LID) self.spawnflags = self.spawnflags - A_LID;
	self.frame_override = TRUE;
	self.respawn_style = PARTICLE_BURST_BLUE + PARTICLE_BURST_RING;
	self.respawn_ofs = '0 0 24';
	self.respawn_effect = TRUE;
	item_ammo_setup();
};

/*======================================================================
 KEYS (Silver, Gold and Custom)
======================================================================*/
void() key_touch =
{
	// Check if the player has the custom key already?
	if (self.classtype == CT_CUSTOMKEY) {
		if (other.moditems & self.moditems) return;
	}
	else {
		// Check if the player has the silver/gold key already?
		if ( other.items & self.items ) return;
	}

	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");
	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	// Add key to player inventory (items / customkey)
	if (self.moditems > 0) {
		other.moditems = other.moditems | self.moditems;
		// Store the key netname on the player/client for door ref later
		if (self.moditems & IT_CKEY1) other.ckeyname1 = self.netname;
		else if (self.moditems & IT_CKEY2) other.ckeyname2 = self.netname;
		else if (self.moditems & IT_CKEY3) other.ckeyname3 = self.netname;
		else other.ckeyname4 = self.netname;
	}
	// Add silver/gold key to player inventory
	else other.items = other.items | self.items;

	// Do not remove/respawn keys in co-op
	if (!coop) {
		item_finished();
		check_item_respawn();
	}		

	activator = other;
	SUB_UseTargets();
};

//----------------------------------------------------------------------
void() key_setup =
{
	if (self.noise == "") {
		if (world.worldtype == 1) self.noise = "misc/runekey.wav";
		else if (world.worldtype == 2) self.noise = "misc/basekey.wav";
		else self.noise = "misc/medkey.wav";
	}
	precache_sound (self.noise);

	self.touch2 = key_touch;
	self.classgroup = CG_KEY;
	self.bbmins = VEC_KEYS_MIN;
	self.bbmaxs = VEC_KEYS_MAX;
	if (self.respawn_time == 0) self.respawn_time = RESPAWN_KEY;
	item_start();
};

/*======================================================================
/*QUAKED item_key1 (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/key_silver.mdl"); }
SILVER key, changes based on worldtype on worldspawn
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	if (world.worldtype == 0) {
		self.mdl = "progs/key_medieval.mdl";	// progs/w_s_key.mdl
		self.netname = "silver key";
	}
	else if (world.worldtype == 1) {
		self.mdl = "progs/key_runic.mdl";	// progs/m_s_key.mdl
		self.netname = "silver runekey";
	}
	else if (world.worldtype == 2) {
		self.mdl = "progs/key_base.mdl";	// progs/b_s_key.mdl
		self.netname = "silver keycard";
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

/*======================================================================
/*QUAKED item_key2 (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/key_gold.mdl"); }
GOLD key, changes based on worldtype on worldspawn
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	if (world.worldtype == 0) {
		self.mdl = "progs/key_medieval.mdl";	// progs/w_g_key.mdl
		self.netname = "gold key";
	}
	if (world.worldtype == 1) {
		self.mdl = "progs/key_runic.mdl";	// progs/m_g_key.mdl
		self.netname = "gold runekey";
	}
	if (world.worldtype == 2) {
		self.mdl = "progs/key_base.mdl";	// progs/b_g_key.mdl
		self.netname = "gold keycard";
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

/*======================================================================
/*QUAKED item_keyx (0 .5 .8) (-16 -16 -24) (16 16 32) CKEY1 CKEY2 CKEY3 CKEY4 RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/key_medieval.mdl"); }
Custom key
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
mdl          : model name to load/display (progs/model.mdl)
netname      : XXX Part of pickup string "You got the XXX"
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
Ckey1 : Custom Key type 1
Ckey2 : Custom Key type 2
Ckey3 : Custom Key type 3
Ckey4 : Custom Key type 4
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Custom key

======================================================================*/
void() item_keyx =
{
	// Can't have a custom key without a custom model!?!
	if (self.mdl == "") {
		dprint("\b[CUSTOM KEY]\b Missing model\n");
		spawn_marker(self.origin);
		remove(self);
		return;
	}
	precache_model (self.mdl);	

	// Setup custom key reference number (must exist)
	if (self.spawnflags & ITEM_CKEY2) self.moditems = IT_CKEY2;
	else if (self.spawnflags & ITEM_CKEY3) self.moditems = IT_CKEY3;
	else if (self.spawnflags & ITEM_CKEY4) self.moditems = IT_CKEY4;
	else self.moditems = IT_CKEY1;
		
	self.classtype = CT_CUSTOMKEY;
	if (self.netname == "") self.netname = "custom key";
	self.items = IT_KEY1 | IT_KEY2;
	key_setup();
};

/*======================================================================
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
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
respawn_time : time to wait before respawning (=-1 instant)
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
	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
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
		// Do not remove/respawn in co-op
		if (!coop) {
			item_finished();
			check_item_respawn();
		}
	}		

	activator = other;
	SUB_UseTargets();
};

//----------------------------------------------------------------------
void() item_custom =
{
	if (self.mdl == "") self.mdl = MODEL_BROKEN;
	if (self.noise == "") self.noise = "weapons/lock4.wav";
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
	if (self.angles_y == 0 && query_configflag(SVR_ITEMROTATE) == FALSE ) 
		self.angles_y = rint(random()*359);

	// Setup different skin options
	if (self.exactskin > 0) self.skin = self.exactskin;
	else if (self.randomskin > 1) self.skin = rint(random()*(self.randomskin-1));
	if (self.skin < 0) self.skin = 0;	// Double check no negatives
	
	self.touch2 = item_custom_touch;
	if (self.pos1 != '0 0 0') self.bbmins = self.pos1;
	else self.bbmins = VEC_KEYS_MIN;
	if (self.pos2 != '0 0 0') self.bbmaxs = self.pos2;
	else self.bbmaxs = VEC_KEYS_MAX;
	item_start();
};

/*======================================================================
/*QUAKED item_sigil (0 0.5 0.8) (-16 -16 -24) (16 16 32) Ep1 Ep2 Ep3 Ep4 RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/key_rune1.mdl"); }
End of episode sigil / rune
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
void() sigil_touch =
{
	if (query_configflag(self.customkey)) return;
	
	centerprint (other, "You got the rune!");
	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	// Add rune to server! not player
	update_configflag(self.customkey, TRUE);

	// DP has special effect for sigil being picked up
	if (ext_dppart) pointparticles(particleeffectnum(DPP_SIGILPICKUP), self.origin, '0 0 0', 1);
	
	// hide item and check for respawn
	item_finished();
	check_item_respawn();
	
	// This odd classname assignment does nothing, old code
	//self.classname = string_null;
	
	activator = other;
	SUB_UseTargets();
};

//----------------------------------------------------------------------
void() item_sigil =
{
	if (!self.spawnflags) {
		dprint("\b[SIGIL]\b No Rune type selected!?!\n");
		spawn_marker(self.origin);
		return;		
	}

	// Based on what spawn key is selected, update model/spawnflag
	// This will make sure only one rune is selected at once
	// Also allow for the spawnflags to have other parameters
	if (self.spawnflags & SVR_RUNE_KEY1) {
		self.mdl = "progs/key_rune1.mdl";
		self.customkey = SVR_RUNE_KEY1;
	}
	else if (self.spawnflags & SVR_RUNE_KEY2) {
		self.mdl = "progs/key_rune2.mdl";
		self.customkey = SVR_RUNE_KEY2;
	}
	else if (self.spawnflags & SVR_RUNE_KEY3) {
		self.mdl = "progs/key_rune3.mdl";
		self.customkey = SVR_RUNE_KEY3;
	}
	else if (self.spawnflags & SVR_RUNE_KEY4) {
		self.mdl = "progs/key_rune4.mdl";
		self.customkey = SVR_RUNE_KEY4;
	}
	
	precache_model (self.mdl);
	if (self.noise == "") self.noise = "misc/runekey.wav";
	precache_sound (self.noise);

	self.touch2 = sigil_touch;
	self.classtype = CT_RUNEKEY;
	self.classgroup = CG_RUNE;
	self.part_active = PARTICLE_STYLE_SIGIL;
	self.bbmins = VEC_KEYS_MIN;
	self.bbmaxs = VEC_KEYS_MAX;
	if (self.respawn_time == 0) self.respawn_time = RESPAWN_RUNE;
	self.respawn_style = PARTICLE_BURST_PURPLE + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 16';
	
	item_start();
};

/*======================================================================
/*QUAKED item_artifact_tomeofpower (0 .5 .8) (-16 -16 -24) (16 16 32) x x x x x FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/key_tome.mdl"); }
Custom event trigger
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
target       : trigger targets to fire when item touched
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
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
	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	// This is a trigger once condition (regardless of coop)
	item_finished();

	activator = other;
	SUB_UseTargets();
};

//----------------------------------------------------------------------
void() item_artifact_tomeofpower =
{
	self.mdl = "progs/artifact_tome.mdl";
	precache_model (self.mdl);	
	if (self.noise == "") self.noise = "misc/medkey.wav";
	precache_sound (self.noise);

	self.classtype = CT_ARTTOME;
	self.classgroup = CG_ARTIFACT;
	self.moditems = IT_ARTTOME;
	self.netname = "Tome of Power";

	self.touch2 = tomeofpower_touch;
	self.bbmins = VEC_POWR_MIN;
	self.bbmaxs = VEC_POWR_MAX;
	self.part_active = PARTICLE_STYLE_TOMEOFP;
	item_start();
};

/*======================================================================
 ARTIFACTS (suit, pent, invis, quad)
======================================================================*/
void() artifact_touch =
{
	//----------------------------------------------------------------------
	// Existing artifacts
	//----------------------------------------------------------------------
	if (self.classtype == CT_ARTSUIT) {
		other.rad_time = TRUE;
		other.radsuit_finished = time + self.cnt;
		ResetDebuffBurning(other);
		ResetDebuffPoisoned(other);
	}
	else if (self.classtype == CT_ARTPENT) {
		other.invincible_time = TRUE;
		other.invincible_finished = time + self.cnt;
		ResetDebuffSystem(other);
	}
	else if (self.classtype == CT_ARTINVS) {
		other.invisible_time = TRUE;
		other.invisible_finished = time + self.cnt;
	}
	else if (self.classtype == CT_ARTQUAD) {
		other.super_time = TRUE;
		other.super_damage_finished = time + self.cnt;
	}
	else if (self.classtype == CT_ARTSHARP) {
		other.sharpshoot_time = TRUE;
		other.sharpshoot_finished = time + self.cnt;
	}
	else if (self.classtype == CT_ARTPIERCE) {
		other.nailpiercer_time = TRUE;
		other.nailpiercer_finished = time + self.cnt;
	}
	else return;

	//----------------------------------------------------------------------
	// Pickup sound and initial screen flash
	//----------------------------------------------------------------------
	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");
	sound (other, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	// Update player item flags (regular + mod)
	other.items = other.items | self.items;
	other.moditems = other.moditems | self.moditems;

	// hide item and check for respawn
	item_finished();
	check_item_respawn();
	
	activator = other;
	SUB_UseTargets();
};

/*======================================================================
	setup all artifacts with similiar configurations
======================================================================*/
void() artifact_setup =
{
	self.touch2 = artifact_touch;
	self.classgroup = CG_ARTIFACT;
	self.bbmins = VEC_POWR_MIN;
	self.bbmaxs = VEC_POWR_MAX;
	
	// Allow for custom artifact timer
	if (self.cnt < 1) self.cnt = POWERUP_TIMER;

	// Setup artifact default respawn timers
	if (self.respawn_time == 0) {
		if (self.classtype == CT_ARTPENT || self.classtype == CT_ARTINVS ||
			self.classtype == CT_ARTSHARP || self.classtype == CT_ARTPIERCE )
			self.respawn_time = RESPAWN_ARTIFACT2;
		else self.respawn_time = RESPAWN_ARTIFACT1;
	}	

	item_start ();
};

/*======================================================================
/*QUAKED item_artifact_envirosuit (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/suit.mdl"); }
Player takes no damage from water or slime for 30 seconds
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
-------- SPAWNFLAGS --------
RESPAWN  : Can respawn after being picked up
FLOAT    : No drop to floor test
STARTOFF : Starts off and waits for trigger
NOEFFECTS : No particle or effects active
-------- NOTES --------
Player takes no damage from water or slime for 30 seconds
Immume from Wraith Healing Debuff but take small damage instead

======================================================================*/
void() item_artifact_envirosuit =
{
	// cshifts 0,255,0,20
	self.mdl = "progs/suit.mdl";
	precache_model (self.mdl);
	self.noise = SOUND_ARTSUIT1;
	self.noise1 = SOUND_ARTSUIT2;
	precache_sound (self.noise);
	precache_sound (self.noise1);
	self.netname = "Biosuit";
	self.items = IT_SUIT;
	self.classtype = CT_ARTSUIT;
	self.part_active = PARTICLE_STYLE_SUIT;
	self.respawn_style = PARTICLE_BURST_GREEN + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 28';
	artifact_setup();
};

/*======================================================================
/*QUAKED item_artifact_invulnerability (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/artifact_pent.mdl"); }
Player is invulnerable for 30 seconds
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
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
	// cshifts 255,255,0,30
	self.mdl = "progs/artifact_pent.mdl";	// Originally - progs/invulner.mdl
	precache_model (self.mdl);
	self.noise = SOUND_ARTPENT1;
	self.noise1 = SOUND_ARTPENT2;
	self.noise2 = SOUND_ARTPENT3;
	precache_sound (self.noise);
	precache_sound (self.noise1);
	precache_sound (self.noise2);
	self.netname = "Pentagram of Protection";
	self.items = IT_INVULNERABILITY;
	self.classtype = CT_ARTPENT;
	self.part_active = PARTICLE_STYLE_PENT;
	self.respawn_style = PARTICLE_BURST_RED + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 16';
	artifact_setup();
};

/*======================================================================
/*QUAKED item_artifact_invisibility (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/artifact_invis.mdl"); }
Player is invisible for 30 seconds
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
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
	// cshifts 100,100,100,100
	self.mdl = "progs/artifact_invis.mdl";	// Originally - progs/invisibl.mdl
	precache_model (self.mdl);
	self.noise = SOUND_ARTINV1;
	self.noise1 = SOUND_ARTINV2;
	self.noise2 = SOUND_ARTINV3;
	precache_sound (self.noise);
	precache_sound (self.noise1);
	precache_sound (self.noise2);
	self.netname = "Ring of Shadows";
	self.items = IT_INVISIBILITY;
	self.classtype = CT_ARTINVS;
	self.part_active = PARTICLE_STYLE_SRING;
	self.respawn_style = PARTICLE_BURST_YELLOW + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 6';
	artifact_setup();
};

/*======================================================================
/*QUAKED item_artifact_super_damage (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/artifact_quad.mdl"); }
The next attack from the player will do 4x damage
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
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
	// cshifts 0,0,255,30
	self.mdl = "progs/artifact_quad.mdl";	// Originally - progs/quaddama.mdl
	precache_model (self.mdl);
	self.noise = SOUND_ARTQUAD1;
	self.noise1 = SOUND_ARTQUAD2;
	self.noise2 = SOUND_ARTQUAD3;
	precache_sound (self.noise);
	precache_sound (self.noise1);
	precache_sound (self.noise2);
	self.netname = "Quad Damage";
	self.items = IT_QUAD;
	self.classtype = CT_ARTQUAD;
	self.part_active = PARTICLE_STYLE_QUAD;
	self.respawn_style = PARTICLE_BURST_BLUE + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 16';
	artifact_setup();
};

/*======================================================================
/*QUAKED item_artifact_sharp_shooter (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/artifact_sharp.mdl"); }
Reduces the bullet spread of all Shotguns
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
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
	self.mdl = "progs/artifact_sharp.mdl";
	precache_model (self.mdl);
	self.noise = SOUND_ARTSHARP1;
	self.noise1 = SOUND_ARTSHARP2;
	self.noise2 = SOUND_ARTSHARP3;
	precache_sound (self.noise);
	precache_sound (self.noise1);
	precache_sound (self.noise2);
	self.netname = "Sharp Shooter";
	self.items = IT_QUAD;
	self.moditems = IT_ARTSHARP;
	self.classtype = CT_ARTSHARP;
	self.part_active = PARTICLE_STYLE_SHARP;
	self.respawn_style = PARTICLE_BURST_PURPLE + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 16';
	artifact_setup();
};

/*======================================================================
/*QUAKED item_artifact_nail_piercer (0 0.5 0.8) (-16 -16 -24) (16 16 32) x x x x RESPAWN FLOAT STARTOFF NOEFFECTS NOT_EASY NOT_NORMAL NOT_HARD NOT_DM
{ model(":progs/artifact_piercer.mdl"); }
All nail attacks will travel through monsters
-------- KEYS --------
targetname   : toggle state (use trigger ent for exact state)
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
respawn_count : Total amount of times to respawn (counts down to zero)
respawn_trig : = 1 Wait for trigger before respawning
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
	self.mdl = "progs/artifact_piercer.mdl";
	precache_model (self.mdl);
	self.noise = SOUND_ARTNAILP1;
	self.noise1 = SOUND_ARTNAILP2;
	self.noise2 = SOUND_ARTNAILP3;
	precache_sound (self.noise);
	precache_sound (self.noise1);
	precache_sound (self.noise2);
	self.netname = "Nail Piercer";
	self.items = IT_QUAD;
	self.moditems = IT_ARTPIERCE;
	self.classtype = CT_ARTPIERCE;
	self.part_active = PARTICLE_STYLE_PIERCE;
	self.respawn_style = PARTICLE_BURST_PURPLE + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 16';
	artifact_setup();
};

/*======================================================================
PLAYER BACKPACKS
======================================================================*/
void() BackpackTouch =
{
	local string s;
	local float best, old, new;
	local float acount;
	
	acount = 0;
	sprint (other, "You get ");

	if (self.items) {
		if ((other.items & self.items) == 0) {
			acount = 1;
			sprint (other, "the ");
			sprint (other, self.netname);
		}
	}

	// if the player was using his best weapon
	// change up to the new one if better		
	best = W_BestWeapon(other);

	// Calculate random amounts of ammo
	if (self.count > 0) {
		if (self.spawnflags & BACKPACK_SHELLS) self.ammo_shells = rint(1 + random()*self.count);
		if (self.spawnflags & BACKPACK_NAILS) self.ammo_nails = rint(1 + random()*self.count);
		if (self.spawnflags & BACKPACK_ROCKETS) self.ammo_rockets = rint(1 + random()*self.count);
		if (self.spawnflags & BACKPACK_CELLS) self.ammo_cells = rint(1 + random()*self.count);
		if (self.armortype == 1) self.armorvalue = rint(1 + random()*self.count);
	}
	// Give ammo to player
	other.ammo_shells = other.ammo_shells + self.ammo_shells;
	other.ammo_nails = other.ammo_nails + self.ammo_nails;
	other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
	other.ammo_cells = other.ammo_cells + self.ammo_cells;

	// Check for any armor to give to the player
	// Allow for armor shards to go over green/yellow/red limits
	if (self.armorvalue > 0) {
		other.armorvalue = other.armorvalue + self.armorvalue;
		// Does the player have any armor already?
		if (other.armortype == 0 ) {
			// No armor present, give green with armor shards
			other.armortype = ARMOR_GRN_TYPE;
			other.items = other.items | IT_ARMOR1;
		}
	}	
	
	new = self.items;
	if (!new) new = other.weapon;
	old = other.items;
	other.items = other.items | new;
	
	bound_other_ammo (other);

	if (self.ammo_shells > 0) {
		if (acount) sprint(other, ", ");
		acount = 1;
		s = ftos(self.ammo_shells);
		sprint (other, s);
		sprint (other, " shells");
	}
	if (self.ammo_nails > 0) {
		if (acount) sprint(other, ", ");
		acount = 1;
		s = ftos(self.ammo_nails);
		sprint (other, s);
		sprint (other, " nails");
	}
	if (self.ammo_rockets > 0) {
		if (acount) sprint(other, ", ");
		acount = 1;
		s = ftos(self.ammo_rockets);
		sprint (other, s);
		sprint (other, " rockets");
	}
	if (self.ammo_cells > 0) {
		if (acount) sprint(other, ", ");
		acount = 1;
		s = ftos(self.ammo_cells);
		sprint (other, s);
		sprint (other, " cells");
	}
	if (self.armorvalue > 0) {
		if (acount) sprint(other, ", ");
		acount = 1;
		s = ftos(self.armorvalue);
		sprint (other, s);
		sprint (other, " armor shards");
	}
	
	sprint (other, "\n");
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	// change to the weapon
	if (!deathmatch) self.weapon = new;
	else DM_Weapon (old, new);
	W_SetCurrentAmmo (other);
	
	// Random ammo backpacks are actual items
	if (self.classtype == CT_AMMORANDOM) {
		// hide item and check for respawn
		item_finished();
		check_item_respawn();
	}
	// Temporary backpack
	else remove(self);
};

/*======================================================================
 DropBackpack
======================================================================*/
void() DropBackpack =
{
	local entity item;

	if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells))
		return;	// nothing in it

	item = spawn();
	item.classtype = CT_AMMOPACK;
	item.classgroup = CG_AMMOITEM;
	item.origin = self.origin - '0 0 20';
	
	item.items = self.weapon;
	if (item.items == IT_AXE) item.netname = "Axe";
	else if (item.items == IT_SHOTGUN) item.netname = "Shotgun";
	else if (item.items == IT_SUPER_SHOTGUN) item.netname = "Double-barrelled Shotgun";
	else if (item.items == IT_NAILGUN) item.netname = "Nailgun";
	else if (item.items == IT_SUPER_NAILGUN) item.netname = "Super Nailgun";
	else if (item.items == IT_GRENADE_LAUNCHER) item.netname = "Grenade Launcher";
	else if (item.items == IT_ROCKET_LAUNCHER) item.netname = "Rocket Launcher";
	else if (item.items == IT_LIGHTNING) item.netname = "Thunderbolt";
	else item.netname = "";

	// Pyro Enforcers drop armor shards instead!!!
	if (self.classtype == CT_MONPYRO) 
		item.armorvalue = rint(1 + random() * self.ammo_shells);
	else {
		// Everything else drops ammo
		item.ammo_shells = self.ammo_shells;
		item.ammo_nails = self.ammo_nails;
		item.ammo_rockets = self.ammo_rockets;
		item.ammo_cells = self.ammo_cells;
	}
		
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
	
	// 1=green, 2=blue, 3=red, 4=golden, 5=swampy, 6=white, 7=flesh
	// green=shells, blue=cells, red=rockets
	if (self.classtype == CT_MONDEFENDER) item.skin = 1;
	else if (self.classtype == CT_MONARMYGRENADE) item.skin = 1;
	else if (self.classtype == CT_MONARMYPLASMA) item.skin = 2;
	else if (self.classtype == CT_MONELIMATOR) item.skin = 2;
	else if (self.classtype == CT_MONCENTURION) item.skin = 2;
	else if (self.classtype == CT_MONARMYROCKET) item.skin = 3;
	else if (self.classtype == CT_MONPYRO) item.skin = 4;
	else if (self.classtype == CT_MONENFORCER) item.skin = 7;
	
	item.nextthink = time + 120;	// remove after 2 minutes
	item.think = SUB_Remove;
};

/*======================================================================
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
upgrade_ssg  : = 1 will only spawn if shotgun upgrade active on server
upgrade_axe  : = 1 will only spawn if axe upgrade active on server
upgrade_lg   : = 1 will only spawn if lightning gun upgrade active on server
message       : centerprint message when item is picked up
respawn_time  : time to wait before respawning (=-1 instant)
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
	else self.armortype = 0;

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
		spawn_marker(self.origin);
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

	self.classtype = CT_AMMORANDOM;
	self.classgroup = CG_AMMOITEM;
	self.bbmins = '-16 -16 -12';
	self.bbmaxs = '16 16 32';
	self.part_active = PARTICLE_STYLE_BACKPACK;
	if (self.respawn_time == 0) self.respawn_time = RESPAWN_BACKPACK;
	self.respawn_style = PARTICLE_BURST_WHITE + PARTICLE_BURST_CENTER;
	self.respawn_ofs = '0 0 12';
	self.touch2 = BackpackTouch;

	// Double checking all the different ammo combinations can be
	// time consuming, delay spawn the backpack instead
	self.think = item_backpack_setup;
	self.nextthink = time + 0.1 + random();
};
