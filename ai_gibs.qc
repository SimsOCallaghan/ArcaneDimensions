/*======================================================================
 AI GIB FUNCTIONS
======================================================================*/
.float		gibondeath;			// true/false always gib on death
.float		bodyfadeaway;		// Time in seconds before body/head fades away

.string		gib1mdl;			// Gib 1 unique weapon/body part
.string		gib2mdl;			// Gib 2 unique weapon/body part
.string		gib3mdl;			// Gib 3 unique weapon/body part
.string		gib4mdl;			// Gib 4 unique weapon/body part
.string		gib5mdl;			// Gib 5 unique weapon/body part
.float		gib1skin;			// Special gib model unique skin no
.float		gib2skin;			// Special gib model unique skin no
.float		gib3skin;			// Special gib model unique skin no
.float		gib1frame;			// Frame range to randomly pick from
.float		gib2frame;			// Frame range to randomly pick from
.float		gib3frame;			// Frame range to randomly pick from
.float		gib1sound;			// Gib 1 - impact sound type
.float		gib2sound;			// Gib 2 - impact sound type
.float		gib3sound;			// Gib 3 - impact sound type
.float		gibtype;			// What type of gibs (blood, stone, etc)
.float		blockudeath;		// ID udeath.wav sounds human, block it for non-humanoids

float GIB_IMPACT_LIGHT = 0;		// Light fleshy impact (default)
float GIB_IMPACT_HEAVY = 1;		// Heavy fleshy impact
float GIB_IMPACT_METALA = 2;	// Short metal impact
float GIB_IMPACT_METALB = 4;	// Long metal impact
float GIB_IMPACT_CHAIN = 8;		// Blue metal flail
float GIB_IMPACT_WOOD = 16;		// Heavy crossbow/chainsaw
float GIB_IMPACT_STONE = 32;	// Light stones dropping
float GIB_IMPACT_STONE2 = 64;	// Dropping pebbles
float GIB_IMPACT_STONE3 = 128;	// Dropping pebbles

float GIBTYPE_BLOOD = 0;		// Blood (default)
float GIBTYPE_STONE = 1;		// Stone
float GIBTYPE_POISON = 2;		// Poisoned

float MON_BCOLOR_RED = 68;		// Red index colour
float MON_BCOLOR_GREEN = 52;	// Green index
float MON_BCOLOR_YELLOW = 192;	// Bright yellow, not gold
float MON_BCOLOR_WHITE = 4;		// Grey/white

string GIB_SOUND_HEAVY = "gibs/gibheavy1.wav";
string GIB_SOUND_HEAVY2 = "gibs/gibheavy2.wav";
string GIB_SOUND_METALA = "gibs/gibmetala.wav";
string GIB_SOUND_METALB = "gibs/gibmetalb.wav";
string GIB_SOUND_CHAIN = "gibs/gibchain.wav";
string GIB_SOUND_WOOD = "gibs/gibwood.wav";
string GIB_SOUND_UDEATH = "player/udeath.wav";

string GIB1_BLOOD = "progs/gib_1.mdl";
string GIB2_BLOOD = "progs/gib_2.mdl";
string GIB3_BLOOD = "progs/gib_3.mdl";
string GIB4_BLOOD = "progs/gib_4.mdl";
string GIB5_BLOOD = "progs/gib_5.mdl";

string GIB1_STONE = "progs/gib_s1.mdl";
string GIB2_STONE = "progs/gib_s2.mdl";
string GIB3_STONE = "progs/gib_s3.mdl";
string GIB4_STONE = "progs/gib_s4.mdl";
string GIB5_STONE = "progs/gib_s5.mdl";

string GIB1_POISON = "progs/gib_p1.mdl";
string GIB2_POISON = "progs/gib_p2.mdl";
string GIB3_POISON = "progs/gib_p3.mdl";
string GIB4_POISON = "progs/gib_p4.mdl";
string GIB5_POISON = "progs/gib_p5.mdl";

string GIB1_SOUND = "gibs/gib1.wav";
string GIB3_SOUND = "gibs/gib3.wav";
string GIB5_SOUND = "gibs/gib5.wav";
string GIBHIT1_SOUND = "gibs/gibhit1.wav";
string GIBHIT2_SOUND = "gibs/gibhit2.wav";
string GIBHIT3_SOUND = "gibs/gibhit3.wav";
string GIBHIT4_SOUND = "gibs/gibhit4.wav";
string GIBHIT5_SOUND = "gibs/gibhit5.wav";
string GIBHIT1_STONESOUND = "gibs/gibstone1.wav";
string GIBHIT3_STONESOUND = "gibs/gibstone3.wav";
string GIBHIT5_STONESOUND = "gibs/gibstone5.wav";

void() monster_death_postcheck;
void(entity gibent) DPP_blood_trail;	// Extra blood DP particles

/*======================================================================
 precache_stonegibs, precache_poisongibs
  Only load extra gibs when there is a monster requiring them
  There are separate gib models because of particle trail colours
  These functions have to be called from monster spawn functions
  The gib system tests for the global variables defined below
  If the extra gibs are not active then default blood vers are used
======================================================================*/
void() precache_stonegibs =
{
	gibstone = TRUE;
	precache_model (GIB1_STONE);			// New gib - arm/leg
	precache_model (GIB2_STONE);			// New gib - body
	precache_model (GIB3_STONE);			// New gib - slice
	precache_model (GIB4_STONE);			// New gib - small chunk/ball
	precache_model (GIB5_STONE);			// New gib - large chunk/ball
};

//----------------------------------------------------------------------
void() precache_poisongibs =
{
	gibpoison = TRUE;
	precache_model (GIB1_POISON);			// New gib - arm/leg
	precache_model (GIB2_POISON);			// New gib - body
	precache_model (GIB3_POISON);			// New gib - slice
	precache_model (GIB4_POISON);			// New gib - small chunk/ball
	precache_model (GIB5_POISON);			// New gib - large chunk/ball
};

/*======================================================================
 DirectionForDamage
  Takes the angle between self and enemy and projects backwards
======================================================================*/
vector(float gibforce) DirectionForDamage =
{
	local vector gvel;

	if (self.max_health == MON_GIBFOUNTAIN) {
		gvel_x = crandom()*100;
		gvel_y = crandom()*100;
		gvel_z = 100 + (100 * random());
		return gvel;
	}
	else if (self.max_health == MON_XYGIBVELOCITY) {
		// Back to front vector so gib will travel away from enemy
		gvel = vectoangles(self.origin - self.enemy.origin);
		makevectors(gvel);
		gvel = v_forward * (50 + (100 * random()));
		gvel = gvel + (v_right * (200 * crandom()));
		gvel_z = 100 + (100 * random());
	}
	else if (self.max_health == MON_NOGIBVELOCITY) {
		// Back to front vector so gib will travel away from enemy
		gvel = vectoangles(self.origin - self.enemy.origin);
		makevectors(gvel);
		gvel = v_forward * (50 + (100 * random()));
		gvel = gvel + (v_right * (100 * crandom()));
		gvel_z = 30;
	}
	else {
		// Back to front vector so gib will travel away from enemy
		gvel = vectoangles(self.origin - self.enemy.origin);
		makevectors(gvel);
		gvel = v_forward * (50 + (100 * random()));
		gvel = gvel + (v_right * (100 * crandom()));
		gvel_z = 100 + (100 * random());
	}

	if (gibforce > -50) gvel = gvel * 1.25;
	return gvel;
};
//----------------------------------------------------------------------
void() ThrowHead =
{
	setmodel (self, self.headmdl);
	self.frame = 0;
	self.nextthink = -1;
	self.movetype = MOVETYPE_BOUNCE;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	// Hide the entity if it hits void, don't remove it
	self.classgroup = CG_MISCENT;
	self.view_ofs = '0 0 8';
	setsize (self, '-16 -16 0', '16 16 32');
	
	self.velocity_x = 50 * crandom();
	self.velocity_y = 50 * crandom();
	self.velocity_z = 200 + 100 * random();

	self.avelocity = '0 0 0';
	self.avelocity_y = 200 + random() * 200;
	self.angles_y = self.ideal_yaw = random() * 360;

	//----------------------------------------------------------------------
	// Check for water content, adjust for water friction
	if (pointcontents(gibitem.oldorigin) == CONTENT_WATER) {
		gibitem.gravity = 0.25;
		gibitem.velocity_z = 50 + 50 * random();
	}

	self.flags = self.flags - (self.flags & FL_ONGROUND);
	monster_death_postcheck();
};

//----------------------------------------------------------------------
void() RemoveGib =
{
	self.think = model_fade;
	self.nextthink = time + 0.1;
	self.ltime = self.nextthink;
};

//----------------------------------------------------------------------
void() TouchGib =
{
	if (check_skycontent(self.origin)) {entity_remove(self, 0.1); return;}
	if (self.touchedvoid) return;				// Marked for removal
	if (self.waitmin > time) return;			// Touch function disabled
	if (other == self.owner) return;			// Ignore original monster
	if (other.classgroup == CG_TEMPENT) return;	// Ignore other temp entities
	if (other.solid == SOLID_TRIGGER) return;	// Ignore trigger fields

	self.touch = SUB_Null;				// no more touching
	self.waitmin = time + LARGE_TIMER;	// skip this function in the future
	self.solid = SOLID_NOT;				// Turn off world interaction
	
	// Check weapon flag for unique sound types (default 0 = fleshy)
	if (self.weapon & GIB_IMPACT_HEAVY) sound(self, CHAN_VOICE, GIB_SOUND_HEAVY, 1, ATTN_GIB);
	else if (self.weapon & GIB_IMPACT_METALA) sound(self, CHAN_VOICE, GIB_SOUND_METALA, 1, ATTN_NORM);
	else if (self.weapon & GIB_IMPACT_METALB) sound(self, CHAN_VOICE, GIB_SOUND_METALB, 1, ATTN_NORM);
	else if (self.weapon & GIB_IMPACT_CHAIN) sound(self, CHAN_VOICE, GIB_SOUND_CHAIN, 1, ATTN_NORM);
	else if (self.weapon & GIB_IMPACT_WOOD) sound(self, CHAN_VOICE, GIB_SOUND_WOOD, 1, ATTN_NORM);
	else {	
		if (self.gibtype == GIBTYPE_STONE) {
			self.lip = random() * 3;
			if (self.lip < 1) sound(self, CHAN_VOICE, GIBHIT1_STONESOUND, 1, ATTN_GIB);
			else if (self.lip < 2) sound(self, CHAN_VOICE, GIBHIT3_STONESOUND, 1, ATTN_GIB);
			else sound(self, CHAN_VOICE, GIBHIT5_STONESOUND, 1, ATTN_GIB);
		}
		else {
			self.lip = random() * 5;
			if (self.lip < 1) sound(self, CHAN_VOICE, GIBHIT1_SOUND, 1, ATTN_GIB);
			else if (self.lip < 2) sound(self, CHAN_VOICE, GIBHIT2_SOUND, 1, ATTN_GIB);
			else if (self.lip < 3) sound(self, CHAN_VOICE, GIBHIT3_SOUND, 1, ATTN_GIB);
			else if (self.lip < 4) sound(self, CHAN_VOICE, GIBHIT4_SOUND, 1, ATTN_GIB);
			else sound(self, CHAN_VOICE, GIBHIT5_SOUND, 1, ATTN_GIB);
		}
	}
};

//======================================================================
// ThrowGib was originally in player.qc (moved here, used by monsters more often
// Spawns a gib model and throws it up into the air to bounce around
//======================================================================
void(float gib_no, float gib_qty) ThrowGib =
{	
	while (gib_qty > 0) {
		gibitem = spawn();
		gibitem.owner = self;
		gibitem.classtype = CT_TEMPGIB;
		gibitem.classgroup = CG_TEMPENT;
		if (self.gibtype) gibitem.gibtype = self.gibtype;
		
		if (ext_dppart) DPP_blood_trail(gibitem);
		
		// Arm/leg joint (small)
		if (gib_no == 1) {
			if (self.gibtype == GIBTYPE_STONE && gibstone) gibitem.mdl = GIB1_STONE;
			else if (self.gibtype == GIBTYPE_POISON && gibpoison) gibitem.mdl = GIB1_POISON;
			else gibitem.mdl = GIB1_BLOOD;
		}
		// Torso (large lump)
		else if (gib_no == 2) {
			if (self.gibtype == GIBTYPE_STONE && gibstone) gibitem.mdl = GIB2_STONE;
			else if (self.gibtype == GIBTYPE_POISON && gibpoison) gibitem.mdl = GIB2_POISON;
			else gibitem.mdl = GIB2_BLOOD;
		}
		// Slice (large and wedge like)
		else if (gib_no == 3) {
			if (self.gibtype == GIBTYPE_STONE && gibstone) gibitem.mdl = GIB3_STONE;
			else if (self.gibtype == GIBTYPE_POISON && gibpoison) gibitem.mdl = GIB3_POISON;
			else gibitem.mdl = GIB3_BLOOD;
		}
		// Blob (small and round)
		else if (gib_no == 4) {
			if (self.gibtype == GIBTYPE_STONE && gibstone) gibitem.mdl = GIB4_STONE;
			else if (self.gibtype == GIBTYPE_POISON && gibpoison) gibitem.mdl = GIB4_POISON;
			else gibitem.mdl = GIB4_BLOOD;
		}
		// Blob (large and round)
		else if (gib_no == 5) {
			if (self.gibtype == GIBTYPE_STONE && gibstone) gibitem.mdl = GIB5_STONE;
			else if (self.gibtype == GIBTYPE_POISON && gibpoison) gibitem.mdl = GIB5_POISON;
			else gibitem.mdl = GIB5_BLOOD;
		}
		else if (gib_no == 11) {
			gibitem.mdl = self.gib1mdl;			// Custom model
			gibitem.weapon = self.gib1sound;
			if (self.gib1skin > 0) gibitem.skin = self.gib1skin;
			if (self.gib1frame) gibitem.frame = rint(random()*self.gib1frame);
		}
		else if (gib_no == 12) {
			gibitem.mdl = self.gib2mdl;			// Custom model
			gibitem.weapon = self.gib2sound;
			if (self.gib2skin > 0) gibitem.skin = self.gib2skin;
			if (self.gib2frame) gibitem.frame = rint(random()*self.gib2frame);
		}
		else if (gib_no == 13) {
			gibitem.mdl = self.gib3mdl;			// Custom model
			gibitem.weapon = self.gib3sound;
			if (self.gib3skin > 0) gibitem.skin = self.gib3skin;
			if (self.gib3frame) gibitem.frame = rint(random()*self.gib3frame);
		}
		
		setmodel (gibitem, gibitem.mdl);
		if (gib_no < 10) gibitem.frame = rint(random()*9);		// 10 frames of different pose/sizes
	
		setsize (gibitem, VEC_ORIGIN, VEC_ORIGIN);
		gibitem.movetype = MOVETYPE_BOUNCE;
		gibitem.solid = SOLID_BBOX;
		
		//----------------------------------------------------------------------
		// Spawn gib inside of owner model volume instead of from a single point
		gibitem.oldorigin_x = self.absmin_x + random()*(self.maxs_x - self.mins_x);
		gibitem.oldorigin_y = self.absmin_y + random()*(self.maxs_y - self.mins_y);	
		gibitem.oldorigin_z = 16 + (random()*12) + self.origin_z;
		setorigin(gibitem, gibitem.oldorigin);
	
		//----------------------------------------------------------------------
		// NEW Directional gib velocity with modifier
		gibitem.velocity = DirectionForDamage(self.health);
		gibitem.angles_y = gibitem.ideal_yaw = random() * 360;
		if (gib_no < 10) {
			gibitem.avelocity = vecrand(100,200,FALSE);
		}
		else gibitem.avelocity = crandom() * '0 300 0';

		//----------------------------------------------------------------------
		// Check for water content, adjust for water friction
		if (pointcontents(gibitem.oldorigin) == CONTENT_WATER) {
			gibitem.gravity = 0.35;
			gibitem.velocity_z = 0;
		}
	
		gibitem.touch = TouchGib;
		gibitem.nextthink = time + 10 + random()*10;
		gibitem.think = RemoveGib;
		gib_qty = gib_qty - 1;
	}
};

//======================================================================
// Explode monster into a shower of gibs (throw head as well)
//======================================================================
void() monster_ThrowGib =
{
	self.gibbed = TRUE;		// Monster has offical gone to pieces ;)

	//----------------------------------------------------------------------
	// New set of gib sounds - gib1, gib3, gib5
	// FIXME - Sadly the source for these files is UT :(
	// Zombies have special gib sound because they always go that way!
	//----------------------------------------------------------------------
	if (self.classgroup == CG_ZOMBIE)
		sound (self, CHAN_VOICE, "zombie/z_gib.wav", 1, ATTN_NORM);
	else {
		self.lip = random() * 4;
		if (self.lip < 1) sound (self, CHAN_VOICE, GIB1_SOUND, 1, ATTN_NORM);
		else if (self.lip < 2) sound (self, CHAN_VOICE, GIB3_SOUND, 1, ATTN_NORM);
		else {
			// Is the monster humanoid? (udeath is the original id gib sound)
			if (self.blockudeath) sound (self, CHAN_VOICE, GIB5_SOUND, 1, ATTN_NORM);
			else sound (self, CHAN_VOICE, GIB_SOUND_UDEATH, 1, ATTN_NORM);
		}
	}
		
	//----------------------------------------------------------------------
	// If any special gib models defined, throw them
	//----------------------------------------------------------------------
	if (self.gib1mdl != "") ThrowGib(11, 1);
	if (self.gib2mdl != "") ThrowGib(12, 1);
	if (self.gib3mdl != "") ThrowGib(13, 1);

	//----------------------------------------------------------------------
	// Work through each monster type (default = humanoid)
	// GIB 1 - arm/leg (small)
	// GIB 2 - torso (large)
	// GIB 3 - slice (medium)
	// GIB 4 - blob (small)
	// GIB 5 - blob (medium)
	//----------------------------------------------------------------------
	if (self.classtype == CT_MONDEMON) { 
		ThrowGib(4, 1 + rint(random()*2));
		ThrowGib(5, 3 + rint(random()*2));
	}
	else if (self.classtype == CT_MONDROLE) { 
		ThrowGib(4, 2 + rint(random()*2));
		ThrowGib(5, 4 + rint(random()*2));
	}
	else if (self.classtype == 	CT_MONDOG) {
		ThrowGib(4, 1 + rint(random()*3));
		ThrowGib(5, 1 + rint(random()*2));
	}
	else if (self.classtype == CT_MONWRAITH) {
		ThrowGib(4, 3 + rint(random()*2));
	}
	else if (self.classtype == CT_MONSHAL) {
		ThrowGib(4, 2 + rint(random()*4));
		ThrowGib(5, 2 + rint(random()*2));
	}
	else if (self.classtype == CT_MONGOLEM) {
		ThrowGib(11, 4 + rint(random()*2));
		ThrowGib(12, 8 + rint(random()*2));
	}
	else if (self.classtype == CT_MONSCORPION) {
		ThrowGib(4, 2 + rint(random()*4));
		ThrowGib(5, 2 + rint(random()*2));
	}
	// Includes brown/green spiders and vorelings
	else if (self.classgroup == CG_SPIDER) {
		ThrowGib(4, rint(random()*3));
		ThrowGib(11, rint(random()*2));
	}
	else if (self.classtype == CT_MONFISH) {
		ThrowGib(4, 1 + rint(random()*3));
	}
	else if (self.classgroup == CG_ZOMBIE) {
		ThrowGib(4, 3 + rint(random()*2));
	}
	// Includes vanilla and new hunter ogres
	else if (self.classgroup == CG_OGRE) {
		ThrowGib(4, 1 + rint(random()*3));
		ThrowGib(5, 2 + rint(random()*2));
	}
	else if (self.classgroup == CG_DCAPTAIN) {
		ThrowGib(3, 1);
		ThrowGib(4, 2 + rint(random()*4));
	}
	else if (self.classtype == CT_MONGARGOYLE) {
		ThrowGib(4, 2 + rint(random()*3));
		ThrowGib(5, 1 + rint(random()*2));
	}
	else if (self.classtype == CT_MONGAUNT) {
		ThrowGib(4, 3 + rint(random()*2));
		ThrowGib(5, 2 + rint(random()*2));
	}
	else if (self.classtype == CT_MONWIZARD) {
		ThrowGib(4, 1 + rint(random()*3));
	}
	else if (self.classtype == 	CT_MONSHAM) {
		ThrowGib(3, 1);
		ThrowGib(4, 2 + rint(random()*4));
		ThrowGib(5, 2 + rint(random()*4));
	}
	else if (self.classtype == 	CT_MONMINOTAUR) {
		ThrowGib(3, 1);
		ThrowGib(4, 2 + rint(random()*4));
		ThrowGib(5, 2 + rint(random()*4));
	}
	// Default humanoid explosion
	else {
		if (random()<0.5) ThrowGib(2, 2);
		else ThrowGib(3, 1);
		ThrowGib(4, 2 + rint(random()*4));
	}				

	//----------------------------------------------------------------------
	// If head model defined, switch body for head and throw it
	// Throw head last because all previous gibs rely on the origin
	//----------------------------------------------------------------------
	if (self.headmdl != "") {
		// If monster set for low velocity, hide head and throw extra gibs
		if (self.max_health == MON_NOGIBVELOCITY) {
			ThrowGib(4, rint(random()*4));
			entity_hide (self);
		}
		// Standard gib death, throw head upwards
		else ThrowHead ();
	}
	// No head defined, hide monster
	else entity_hide (self);
};

//======================================================================
// Check health for gib condition
//======================================================================
void() monster_check_gib =
{
	// There are always exceptions to the every rule!
	// Spawns=Explode, Wraith=Explode, Jim=Explode
	// SkullWiz=Fade away, Lost Souls=Explode
	if (self.gibhealth == MON_NEVERGIB) return;
	if (self.touchedvoid) { entity_hide(self); return; }

	// Can only gib a monster once!
	if (self.gibbed) return;
	if ( self.health < (self.gibhealth + 1) || self.gibondeath)
		monster_ThrowGib();
};
