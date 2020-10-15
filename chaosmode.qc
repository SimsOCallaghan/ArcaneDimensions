//======================================================================
// Entity Randomizer or Chaos mode or "Markie Madness Mode" !?!
// * Ideal for twitch playthrough challenges and sharing setups
// * Big thank you to Markie for feedback and suggestions
//=====================================================================

vector		magicseed;		// bitshift formula (default = '13 -17 5')
float		randomorg;		// Origin random seed for level
float		randomseed[6];	// Random seed for monster, items etc
float		randomflags;	// Random flags for options
float		randomprev[16];	// Previous random selection
float		randomammo;		// Quantity of ammo packs upgraded
float		randomcache;	// Have all random sounds been cached
float		savegamechaos;	// Chaos settings for savegame
float		savegameseed;	// Random seed for savegame

float RND_SEEDMONSTER = 0;	// Monster random number seed set
float RND_SEEDAMMO = 1;     // Ammo random number seed set
float RND_SEEDHEALTH = 2;	// Health random number seed set
float RND_SEEDARMOUR = 3;	// Armour random number seed set
float RND_SEEDARTIFACT = 4;	// Artifact random number seed set
float RND_SEEDMAX = 5;		// Maximum amount of seeds maintained
float RND_OFFSET = 35;		// Offset to increase through random range
float RND_FRAMECOUNT = 35;	// Frame count check for Chaos mode
float RND_LOWMASK = 65535;	// 1-15 bits for lower bit mask
float RND_16BIT = 65536;	// 16th bit to chop floats into ints
float RND_RANGEMAX = 8388607; // 23bits = Largest number can be created
float RND_MAGICA = 13;		// Bitshift forumla for generating new seeds
float RND_MAGICB = -17;		// Algorithm "xor" from p. 4 of Marsaglia, "Xorshift RNGs"
float RND_MAGICC = 5;
float RND_RETMAX = 100;		// Returns numbers between 0-99
float RND_DUPOFFSET = 90;	// Offset to show a range selection was duplicated
float RND_MIDDLE = 50;		// Default chance used for testing
float RND_NEGATIVE = 0.33;	// Negative item pickup effect
float RND_POSITIVE = 0.66;	// Positive item pickup effect
float RND_LOW = 33;			// Low chance used of random condition
float RND_HIGH = 66;		// High chance used of random condition
float RND_BBOX1 = 1;		// ID1 bounding box 1 - humanoid
float RND_BBOX2 = 2;		// ID1 bounding box 2 - ogre/sham

.float		randomized;		// Entity has been randomized!?!
.float		randomupg;		// Entity random upgrades chance
.float		randompoison;	// Entity random poison chance
.float		randomindex;	// Entity 'randomprev' array index
.float		randombbox;		// Entity bounding box type
.string		randomclass;	// Original start on spawn classname
.void()		th_randfunc;	// Final random function to call

// Shadowaxe in id1 maps
// Monsters gibbed 5=Easy, 9=Normal, 13=Hard+
float RND_FRAGAXE = 5;		// Quantity to collect to get SA
.float		randomgibs;		// Total monster gibs caused by player
// Widowmaker / Plasmagun in id1 maps (These values start with EASY)
// Large Shells 3=Easy, 4=Normal, 5=Hard+
// Large Cells  1=Easy, 2=Normal, 3=Hard+
float RND_FRAGSHELL = 3;	// Quantity to collect to get WM
float RND_FRAGCELL = 1;		// Quantity to collect to get PG
float RND_MAXAMMOUP = 5;	// Maximum amount to upgrade
.float		randomshells;	// Total large shells picked up
.float		randomcells;	// Total large cells picked up

//----------------------------------------------------------------------
// scratch3 bit values
// 1       Turn ON randonmizer (family selection)
// 2       Turn ON randomizer (bbox selection)

// 16      Turn OFF health reset for spawning monster
// 32      Turn OFF Health Pack Item monster replacement
// 64      Turn OFF posion monster selection process
// 128     Turn OFF ability to quickload/load on skill 4

// 4096    Turn OFF seed reset on NEW level
// 8192    Turn OFF seed reset on CHANGE level
// 16384   Turn OFF seed reset on DEATH

// Level 1 = 1 (family + fixed HP) [1]
// Level 2 = 17 (family + variable HP) [1 + 16]
// Level 3 = 2 (bbox + fixed HP) [2]
// Level 4 = 18 (bbox + variable HP) [2 + 16]
// Level 5 = 666 (Markie mode) [2 + 8 + 16 + 128 + 512]

float RND_FAMILYSPAWN = 1;
float RND_BBOXSPAWN = 2;
float RND_MARKIEMODE = 8;
float RND_DISABLE = 15;

// Additional spawn options
float RND_NORESETHP = 16;
float RND_NOHEALTHPACK = 32;
float RND_NOPOISON = 64;
float RND_NOQUICKLOAD = 128;

// 256, 512, 1024, 2048 (Empty)
float RND_PARTOF666 = 512;

float RND_NORESETNEWLVL = 4096;
float RND_NORESETCHLVL = 8192;
float RND_NORESETDEATH = 16384;
//float RND_xxx = 32768;

// Internal bit values ONLY
float RND_ACTIVERESET = 65536;
float RND_ACTIVECHLVL = 131072;
float RND_ACTIVEDEATH = 262144;
float RND_SYNCRESTART = 524288;

//----------------------------------------------------------------------
float HP_MONDOG = 25;
float HP_MONFISH = 25;
float HP_MONARMY = 30;

float HP_MONZOMBIE = 60;
float HP_MONKNIGHT = 75;
float HP_MONENFORCER = 80;
float HP_MONWIZARD = 80;
float HP_MONTARBABY = 80;

float HP_MONOGRE = 200;
float HP_MONHELLK = 250;

float HP_MONDEMON1 = 300;
float HP_MONSHALRATH = 400;
float HP_MONSHAMBLER = 600;

//----------------------------------------------------------------------
// compiler forward references
void() monster_fish;
void() monster_eel;

void() monster_dog;
void() monster_spider;
void() monster_voreling;
void() monster_scorpion;

void() monster_army;
void() monster_army_rocket;
void() monster_army_grenade;
void() monster_jim;
void() monster_army_plasma;

void() monster_zombie;
void() monster_zombiek;
void() monster_boil;
void() monster_mummy;

void() monster_knight;
void() monster_death_guard;
void() monster_dcrossbow;
void() monster_dguard;

void() monster_enforcer;
void() monster_defender;
void() monster_eliminator;
void() monster_centurion;
void() monster_deflector;

void() monster_wizard;
void() monster_gaunt;
void() monster_gargoyle;
void() monster_wraith;

void() monster_tarbaby;
void() monster_sentinel;
void() monster_fumigator;
void() monster_pyro;

void() monster_ogre;
void() monster_hogre;
void() monster_hogremac;
void() monster_hogreham;

void() monster_dknight;
void() monster_death_lord;
void() monster_dfury;
void() monster_dprince;

void() monster_demon1;
void() monster_drole;
void() monster_minotaur;
void() monster_golem;

void() monster_shalrath;
void() monster_skullwiz;
void() monster_dsergeant;

void() monster_shambler;
void() monster_boglord;
void() monster_nour;
void() monster_justice;

void() item_health;
void() item_armor1;
void() item_armor2;
void() item_armorInv;
void() item_backpack_armour;
void() item_artifact_invisibility;
void() item_artifact_envirosuit;
void() item_artifact_super_damage;
void() item_artifact_invulnerability;

void() rnd_bboxspawns;
void() rnd_familyspawns;
void() rnd_displaydebug;
float() rnd_upgwpnmax_shadowaxe;
float() rnd_upgwpnmax_widowmaker;
float() rnd_upgwpnmax_plasmagun;
void(float hpvalue) rnd_resethealth;
void() rnd_resetspawnflags;
void() rnd_resetzombieflags;
void(float rndperc) rnd_addpoison;
void(vector rndvec, float prevind) rnd_prevnumber;
float(float seedstart) srandom;

//----------------------------------------------------------------------
string RND_SURPRISEPOS = "misc/secret.wav";		// Classic ID secret
string RND_SURPRISENEG = "misc/secret3.wav";	// New Mfortress secret

void() rnd_cachesounds = {
	if (randomcache) return;
	randomcache = TRUE;
	// Positive random surprise
	precache_sound(RND_SURPRISEPOS);
	// Negative random surprise
	precache_sound(RND_SURPRISENEG);
};
void(entity targ, string soundtype) rnd_playsurprise = {
	if (randomcache <= 0) return;
	sound(targ, CHAN_AUTO, soundtype, 1, ATTN_NORM);
};

//----------------------------------------------------------------------
float(float rseed) rnd_checkseedrange = {
	local float ret_val;
	// Cannot have zero or negative
	if (rseed <= 0) ret_val = 1;
	// Wrap around on random seed range
	else if (rseed > RND_RANGEMAX)
		ret_val = rseed - RND_RANGEMAX;
	// Range all good!
	else ret_val = rseed;
	// Always return Integer
	return floor(ret_val);
};

//----------------------------------------------------------------------
// Used INTERNALLY to the randomizer function
//----------------------------------------------------------------------
void(float newval) set_randflags =
{
	cvar_set("scratch3", ftos(newval));
};

//----------------------------------------------------------------------
// Used INTERNALLY to the randomizer function
//----------------------------------------------------------------------
void() disable_randflags =
{
	randomflags = cvar("scratch3");
	// Remove all gameplay mode bits (1-8)
	randomflags = randomflags - (randomflags & RND_DISABLE);
	cvar_set("scratch3", ftos(randomflags));
};

//----------------------------------------------------------------------
// Used INTERNALLY to the randomizer function
//----------------------------------------------------------------------
float() check_randflags =
{
	randomflags = cvar("scratch3");
	if (randomflags & RND_FAMILYSPAWN) return TRUE;
	else if (randomflags & RND_BBOXSPAWN) return TRUE;
	else return FALSE;
};
float(float customflags) check_customflags =
{
	if (customflags & RND_FAMILYSPAWN) return TRUE;
	else if (customflags & RND_BBOXSPAWN) return TRUE;
	else return FALSE;
};

//----------------------------------------------------------------------
// Used INTERNALLY to clean chaos flag of internal bit values
//----------------------------------------------------------------------
float(float cleanflags) clean_randflags =
{
	local float ret_val;
	ret_val = cleanflags;
	// Remove internal bitflags
	ret_val = ret_val - (ret_val & RND_ACTIVERESET);
	ret_val = ret_val - (ret_val & RND_ACTIVECHLVL);
	ret_val = ret_val - (ret_val & RND_ACTIVEDEATH);
	ret_val = ret_val - (ret_val & RND_SYNCRESTART);
	return ret_val;
};

//----------------------------------------------------------------------
// Used EXTERNALLY to read the correct value of scratch3
//----------------------------------------------------------------------
float() read_randflags =
{
	local float ret_val;
	ret_val = clean_randflags(cvar("scratch3"));
	return ret_val;
};

//----------------------------------------------------------------------
// Used EXTERNALLY via impulse commands to show current seed
//----------------------------------------------------------------------
void() displaycenter_randomseed =
{
	// Need a client for centerprint messages
	if (!(self.flags & FL_CLIENT)) return;
	// Is the randomizer active?
	if (check_randflags() == TRUE) {
		if (randomorg <= 0) centerprint(self, "Random Seed ( Not Set )");
		else centerprint3(self, "Random Seed (", ftos(randomorg), ")");
	}
	else centerprint(self, "Chaos System not active!\n");
};
void() warning_chaosmode =
{
	// Need a client for sprint messages
	if (!(self.flags & FL_CLIENT)) return;
	// Is the randomizer active?
	if (check_randflags() == TRUE) {
		sprint(self, "\n\bChaos\b mode ("); sprint(self, ftos(randomflags));
		sprint(self, ") is \benabled\b, be warned!\n");
		sprint(self, "Random Seed ("); sprint(self, ftos(randomorg));
		sprint(self, ") is active!\n\n");
	}
};

//----------------------------------------------------------------------
// Used EXTERNALLY via impulse commands to show seed stats
//----------------------------------------------------------------------
void() displaydebug_randflags =
{
	// Need a client for sprint messages
	if (!(self.flags & FL_CLIENT)) return;
	// Is the randomizer active?
	if (check_randflags() == FALSE) {
		centerprint(self, "Chaos System not active!\n");
		return;
	}
	sprint(self, "\n[-- \bChaos\b Mode (");
	sprint(self, ftos(randomflags));
	sprint(self, ") current settings --]\n");
	sprint(self,   "------------------------------------------\n");
	sprint(self, "Origin Seed  (");
	if (randomorg <= 0) sprint(self, "\bEmpty\b");
	else sprint(self, ftos(randomorg));
	sprint(self, ") Saved Seed (");
	if (cvar("scratch2") <= 0) sprint(self, "\bEmpty\b");
	else sprint(self, ftos(cvar("scratch2")));
	sprint(self, ")\n");
	
	sprint(self, "Monster Seed (");
	if (randomseed[RND_SEEDMONSTER] <= 0) sprint(self, "\bEmpty\b");
	else sprint(self, ftos(randomseed[RND_SEEDMONSTER]));
	sprint(self, ") Ammo Seed  ("); 
	if (randomseed[RND_SEEDAMMO] <= 0) sprint(self, "\bEmpty\b");
	else sprint(self, ftos(randomseed[RND_SEEDAMMO]));
	sprint(self, ")\nHealth Seed  ("); 
	if (randomseed[RND_SEEDHEALTH] <= 0) sprint(self, "\bEmpty\b");
	else sprint(self, ftos(randomseed[RND_SEEDHEALTH]));
	sprint(self, ") Armor Seed (");
	if (randomseed[RND_SEEDARMOUR] <= 0) sprint(self, "\bEmpty\b");
	else sprint(self, ftos(randomseed[RND_SEEDARMOUR]));
	sprint(self, ")\nArtifct Seed ("); 
	if (randomseed[RND_SEEDARTIFACT] <= 0) sprint(self, "\bEmpty\b");
	else sprint(self, ftos(randomseed[RND_SEEDARTIFACT]));
	sprint(self, ") Priv Keys (");
	sprint(self, ftos(magicseed_x)); sprint(self, " ");
	sprint(self, ftos(magicseed_y)); sprint(self, " ");
	sprint(self, ftos(magicseed_z));
	sprint(self, ")\n\n");
	
	sprint(self, "Monster Spawn type (");
	if (randomflags & RND_FAMILYSPAWN) sprint(self, "Family Groups");
	else if (randomflags & RND_BBOXSPAWN) sprint(self, "\bBounding Box\b");
	else sprint(self, "\bNothing Set!!\b");
	sprint(self, ")\n");
	
	sprint(self, "Random Seed Reset  (");
	// Level reset overrides change level and death resets
	if (randomflags & RND_NORESETNEWLVL) sprint(self, "\b-NewLvl -ChLvl -Death\b");
	else {
		sprint(self, "+NewLvl");
		if (randomflags & RND_NORESETCHLVL) sprint(self, " \b-ChLvl\b");
		else sprint(self, " +ChLvl");
		if (randomflags & RND_NORESETDEATH) sprint(self, " \b-Death\b");
		else sprint(self, " +Death");
	}
	
	sprint(self, ")\n");
	sprint(self, "Monster HP Reset   (");
	if (randomflags & RND_NORESETHP) sprint(self, "\bDisabled\b");
	else sprint(self, "Enabled");
	sprint(self, ")\n");
	sprint(self, "Monster Health Itm (");
	if (randomflags & RND_NOHEALTHPACK) sprint(self, "\bDisabled\b");
	else sprint(self, "Enabled");
	sprint(self, ")\n");
	sprint(self, "Skill 4 Quickload  (");
	if (randomflags & RND_NOQUICKLOAD) sprint(self, "\bDisabled\b");
	else sprint(self, "Enabled");
	sprint(self, ")\n");
	sprint(self, "Poisonous Monsters (");
	if (randomflags & RND_NOPOISON) sprint(self, "\bDisabled\b");
	else sprint(self, "Enabled");
	sprint(self, ")\n");
	sprint(self,   "------------------------------------------\n");
};

//----------------------------------------------------------------------
// Used EXTERNALLY via impulse commands to show weapon upgrades
//----------------------------------------------------------------------
void() displaydebug_weaponupgrades =
{
	local float wpnupg, shellfound, shellmax, cellfound, cellmax;
	local entity entlist;
	
	// Need a client for sprint messages
	if (!(self.flags & FL_CLIENT)) return;
	// Is the randomizer active?
	if (check_randflags() == FALSE) {
		centerprint(self, "Chaos System not active!\n");
		return;
	}
	
	// Find all Large shells in the map
	shellfound = shellmax = 0;
	entlist = find(world, classname, "item_shells");
	while(entlist) {
		// Found large ammo?
		if (entlist.spawnflags & A_LARGE) {
			shellmax = shellmax + 1;
			// Has the ammo been picked up yet?
			// This will have issues with spawn delay
			if (entlist.estate == ESTATE_OFF)
				shellfound = shellfound + 1;
		}
		// Keep searching within subset list
		entlist = find(entlist, classname, "item_shells");
	}
	// Find all Large cells in the map
	cellfound = cellmax = 0;
	entlist = find(world, classname, "item_cells");
	while(entlist) {
		// Found large ammo?
		if (entlist.spawnflags & A_LARGE) {
			cellmax = cellmax + 1;
			// Has the ammo been picked up yet?
			// This will have issues with spawn delay
			if (entlist.estate == ESTATE_OFF)
				cellfound = cellfound + 1;
		}
		// Keep searching within subset list
		entlist = find(entlist, classname, "item_cells");
	}
	entlist = find(world, classname, "item_plasma");
	while(entlist) {
		// Found large ammo?
		if (entlist.spawnflags & A_LARGE) {
			cellmax = cellmax + 1;
			// Has the ammo been picked up yet?
			// This will have issues with spawn delay
			if (entlist.estate == ESTATE_OFF)
				cellfound = cellfound + 1;
		}
		// Keep searching within subset list
		entlist = find(entlist, classname, "item_cells");
	}
		
	sprint(self, "\n[-- \bChaos\b Mode (");
	sprint(self, ftos(randomflags));
	sprint(self, ") weapon upgrades --]\n");
	sprint(self, "------------------------------------------\n");
	sprint(self, "Weapon     Inv  Found Qty   Map Qty\n");
	//            Shadow Axe  x    xx / xx    -- / --
	//            Widowmaker  x    xx / xx    xx / xx
	//            Plasma Gun  x    xx / xx    xx / xx
	//------------------------------------------------------------------
	sprint(self, "Shadow Axe  ");
	if (self.moditems & IT_UPGRADE_AXE) sprint(self, "Y");
	else sprint(self,"N");
	sprint(self, "    ");
	lftos(self,self.randomgibs,2,0,BUFFER_SPRINT);
	sprint(self, " / ");
	wpnupg = rnd_upgwpnmax_shadowaxe();
	lftos(self,wpnupg,2,0,BUFFER_SPRINT);
	sprint(self, "    -- / --\n");

	//------------------------------------------------------------------
	sprint(self, "Widowmaker  ");
	if (self.moditems & IT_UPGRADE_SSG) sprint(self, "Y");
	else sprint(self,"N");
	sprint(self, "    ");
	lftos(self,self.randomshells,2,0,BUFFER_SPRINT);
	sprint(self, " / ");
	wpnupg = rnd_upgwpnmax_widowmaker();
	lftos(self,wpnupg,2,0,BUFFER_SPRINT);
	sprint(self, "    ");
	lftos(self,shellfound,2,0,BUFFER_SPRINT);
	sprint(self, " / ");
	lftos(self,shellmax,2,0,BUFFER_SPRINT);
	sprint(self, "\n");

	//------------------------------------------------------------------
	sprint(self, "Plasma Gun  ");
	if (self.moditems & IT_UPGRADE_LG) sprint(self, "Y");
	else sprint(self,"N");
	sprint(self, "    ");
	lftos(self,self.randomcells,2,0,BUFFER_SPRINT);
	sprint(self, " / ");
	wpnupg = rnd_upgwpnmax_plasmagun();
	lftos(self,wpnupg,2,0,BUFFER_SPRINT);
	sprint(self, "    ");
	lftos(self,cellfound,2,0,BUFFER_SPRINT);
	sprint(self, " / ");
	lftos(self,cellmax,2,0,BUFFER_SPRINT);
	sprint(self, "\n");

	sprint(self, "------------------------------------------\n");
	sprint(self, "Ammo        Qty L E Location\n");
	//            item_shells  xx x x xxx xxx xxx
	
	// Find all shells (small/large) in map
	entlist = find(world, classname, "item_shells");
	while(entlist) {
		sprint(self, "Item_shells  ");
		lftos(self,entlist.aflag,2,0,BUFFER_SPRINT);
		sprint(self, " ");
		if (entlist.spawnflags & A_LARGE) sprint(self,"Y");
		else sprint(self,"N");
		sprint(self, " ");
		if (entlist.estate == ESTATE_OFF) sprint(self,"Y");
		else sprint(self,"N");
		sprint(self, " ");
		sprint(self,vtos(entlist.origin));
		sprint(self,"\n");
		// Keep searching within subset list
		entlist = find(entlist, classname, "item_shells");
	}
	// Find all cells (small/large) in map
	entlist = find(world, classname, "item_cells");
	while(entlist) {
		sprint(self, "Item_cells   ");
		lftos(self,entlist.aflag,2,0,BUFFER_SPRINT);
		sprint(self, " ");
		if (entlist.spawnflags & A_LARGE) sprint(self,"Y");
		else sprint(self,"N");
		sprint(self, " ");
		if (entlist.estate == ESTATE_OFF) sprint(self,"Y");
		else sprint(self,"N");
		sprint(self, " ");
		sprint(self,vtos(entlist.origin));
		sprint(self,"\n");
		// Keep searching within subset list
		entlist = find(entlist, classname, "item_cells");
	}
	// Find all plasma (small/large) in map
	entlist = find(world, classname, "item_plasma");
	while(entlist) {
		sprint(self, "Item_plasma  ");
		lftos(self,entlist.aflag,2,0,BUFFER_SPRINT);
		sprint(self, " ");
		if (entlist.spawnflags & A_LARGE) sprint(self,"Y");
		else sprint(self,"N");
		sprint(self, " ");
		if (entlist.estate == ESTATE_OFF) sprint(self,"Y");
		else sprint(self,"N");
		sprint(self, " ");
		sprint(self,vtos(entlist.origin));
		sprint(self,"\n");
		// Keep searching within subset list
		entlist = find(entlist, classname, "item_plasma");
	}
};

//----------------------------------------------------------------------
float() generate_randomseed =
{
	local float rndcount, rndloop, flip_val, ret_val;
	// Generate see with 4 random numbers combined
	// The downside is the extreme values (low/high) are very rare
	rndcount = floor(1+ (random() * 3));
	for (rndloop=rndcount, ret_val=0;rndloop > 0;rndloop--) {
		ret_val = floor(ret_val + (random() * (RND_RANGEMAX/rndcount)));
	}
	// Random chance to flip the range
	if (random() < 0.5 ) {
		// Shift seed to opposite range half
		flip_val = RND_RANGEMAX/2;
		if (ret_val < flip_val) ret_val = ret_val + flip_val;
		ret_val = ret_val - flip_val;
	}
	// Check for any range errors
	ret_val = rnd_checkseedrange(ret_val);
	// Final result
	return ret_val;
};

//----------------------------------------------------------------------
void() setup_randomseed =
{
	local float i, rndoffset;
	// Cache random reward sounds
	rnd_cachesounds();
	
	// At this point (framecount=0) ALL QC variables are blank
	// This is even the case with quickload/loading a savegame!
	// Also the parm1-16 variables are blank (do get updated eventually)
	// The only way to remember settings is via console variables
	//
	// Scratch2 stores the last random seed number generated
	// If the seed exists, then it will be used instead of a new one.
	// The problem is once the engine closes down, the seed is gone!
	//
	// To fix the problem of console variables losing their values,
	// they are stored in global variables included with savefiles.
	// When a savefile is loaded, the console variables are reset.
	
	// Make sure randomflags is current
	randomflags = cvar("scratch3");
	// Any seed setup?
	if (randomorg <= 0) {
		// Read current random seed
		randomorg = cvar("scratch2");
		// Cannot have a zero or negative seed
		if (randomorg <= 0) randomorg = generate_randomseed();
		// Save the seed to prevent quick/loadgame issues
		cvar_set("scratch2", ftos(randomorg));

		// Monster seed always starts with the origin seed
		randomseed[RND_SEEDMONSTER] = rnd_checkseedrange(randomorg);
		
		// Loop through all the other random seed numbers
		// Creating them at different offsets within complete range
		for(i=0;i<RND_SEEDMAX;i++) {
			rndoffset = (RND_RANGEMAX/16)*(i+1);
			// Keep secondary seeds in sync with large offset
			if (randomorg > RND_RANGEMAX/2)
				randomseed[i] = randomorg - rndoffset;
			else randomseed[i] = randomorg + rndoffset;
			// Double check that seed within range (++floor command)
			randomseed[i] = rnd_checkseedrange(randomseed[i]);
		}
		
		// Display new Seed to console
		dprint("\b[RND_SETUP]\b New Seed ("); dprint(ftos(randomorg));
		dprint(") Offset ("); dprint(ftos(RND_OFFSET)); dprint(")\n");
	}
	// To keep the savegame files in sync with current settings
	// Save a backup copy of scratch 2 / 3 console variables
	if (savegamechaos == 0) {
		// Sync save game values to current (spawn)
		savegamechaos = randomflags;
		savegameseed = randomorg;
	}
};

//----------------------------------------------------------------------
float(float seedno) fetch_randomnumber = {
	local float ret_val;
	// Randomly pick another type
	ret_val = srandom(randomseed[seedno]);
	// Update randomseed with offset (predictable amount)
	randomseed[seedno] = randomseed[seedno] + RND_OFFSET;
	// Make sure new seed is within range
	randomseed[seedno] = rnd_checkseedrange(randomseed[seedno]);
	// return random number
	return ret_val;
};

//----------------------------------------------------------------------
void(float seedno) rnd_generateseeds = 
{
	// Save original classname for debug stats
	self.randomclass = self.classname;
	// Always create all random numbers
	self.randomized = fetch_randomnumber(seedno);
	self.randomupg = fetch_randomnumber(seedno);
	self.randompoison = fetch_randomnumber(seedno);
};

//=====================================================================
// IMPORTANT - This function is called on FRAME 0!
// Randomizes all ID1 monsters with a full AD line up
// Called from all ID1 monster .qc files
//----------------------------------------------------------------------
float() monster_checkrandomizer = 
{
	// Is the randomizer system active?
	if (check_randflags() == FALSE) return FALSE;
	// Has the entity already been randomized?
	if (self.randomized != 0) return FALSE;
	// This can only happen on frame 0
	if (framecount > 0) return FALSE;
	// No deathmatch support
	if (deathmatch > 0) return FALSE;
	
	// Make sure random seed is setup
	setup_randomseed();
	// Pick which type of randomizer (def=bbox)
	if (randomflags & RND_FAMILYSPAWN) rnd_familyspawns();
	else if (randomflags & RND_BBOXSPAWN) rnd_bboxspawns();
	else {
		// Turn off system and warn on console
		disable_randflags();
		dprint("\b[RND_SETUP]\b System disabled, missing spawn type!\n");
		return FALSE;
	}
	
	//------------------------------------------------------------------
	// Randomizer function setup?
	if (self.randomized > 0 && self.th_randfunc) {
		// Re-direct to random function and finish
		self.th_randfunc();
		return TRUE;
	}
	else return FALSE;
};

//=====================================================================
// IMPORTANT - This function is called on FRAME 0!
// Check for monsters spawning instead of Health Packs
// Called from items.qc / item_health
//----------------------------------------------------------------------
float() health_checkrandomizer =
{
	// Is the randomizer system active?
	if (check_randflags() == FALSE) return FALSE;
	// Has the entity already been randomized?
	if (self.randomized != 0) return FALSE;
	// This can only happen on frame 0
	if (framecount > 0) return FALSE;
	// No deathmatch support
	if (deathmatch > 0) return FALSE;
	
	// Make sure random seed is setup
	setup_randomseed();
	// Monster surprise for rotten HPs
	if (self.spawnflags & H_ROTTEN) {
		// is the feature Blocked?
		if (randomflags & RND_NOHEALTHPACK) return FALSE;
		// Generate complete set of numbers
		rnd_generateseeds(RND_SEEDHEALTH);
		// Switch HP for monster?
		if (self.randomized < RND_LOW) {
			// Reset spawnflags (wrong type setup)
			self.spawnflags = 1;	// Ambush
			// Items origin is -24 lower than usual
			self.origin = self.origin + '0 0 32';
			// ID health packs are placed by corner not center origin
			// Need to move the origin to middle of item for monster
			// Detect AD config flag just incase is a proper AD map!
			if (query_configflag(SVR_ITEMOFFSET) == FALSE) {
				self.origin = self.origin + '16 16 0';
			}
			// Drop armour shards (created on monster death)
			self.healamount = HEAL_ROT;
			// Random facing direction
			self.angles_y = floor(rint(random()*359));
			// Tarbaby or Boil!
			//if (self.randomupg > 0) {
			if (self.randomupg > RND_LOW) {
				self.classname = "monster_tarbaby";
				self.th_randfunc = monster_tarbaby;
				if (self.randomupg < RND_LOW)
					self.spawnflags = self.spawnflags | MON_TARBYLESSJUMP;
				rnd_addpoison(FALSE);
				if (self.poisonous) self.exactskin = floor(2+(random()*4));
			}
			else {
				self.classname = "monster_boil";
				self.th_randfunc = monster_boil;
			}
		}
		// Show console info
		rnd_displaydebug();
	}
	// Precache extra files for later
	else if (self.spawnflags & H_MEGA) {
		precache_sound ((self.noise1 = SOUND_ARTSUIT1));
		precache_sound ((self.noise2 = SOUND_ARTSUIT2));
	}
	//------------------------------------------------------------------
	// Randomizer function setup?
	if (self.randomized > 0 && self.th_randfunc) {
		// Re-direct to random function and finish
		self.th_randfunc();
		return TRUE;
	}
	else return FALSE;
};

//=====================================================================
// IMPORTANT - This function is called on FRAME 0!
// Convert small ammo packs to large for shotgun/plasma fragments
// Called from items.qc / item_shells, item_cells, item_plasma
//----------------------------------------------------------------------
float() ammo_checkrandomizer =
{
	// Is the randomizer system active?
	if (check_randflags() == FALSE) return FALSE;
	// Has the entity already been randomized?
	if (self.randomized != 0) return FALSE;
	// This can only happen on frame 0
	if (framecount > 0) return FALSE;
	// No deathmatch support
	if (deathmatch > 0) return FALSE;
	// Reached upgrade limit?
	if (randomammo >= RND_MAXAMMOUP) return FALSE;
	
	// Make sure random seed is setup
	setup_randomseed();
	// Find small ammo box for upgrade
	if (self.classname == "item_shells" && !(self.spawnflags & A_LARGE)) {
		// Generate complete set of numbers
		rnd_generateseeds(RND_SEEDAMMO);
		if (self.randomized < RND_LOW) {
			randomammo = randomammo + 1;
			self.spawnflags = self.spawnflags | A_LARGE;
		}
		// Show console info
		rnd_displaydebug();
	}
	// Find small ammo box for upgrade
	else if (self.classname == "item_cells" && !(self.spawnflags & A_LARGE)) {
		// Generate complete set of numbers
		rnd_generateseeds(RND_SEEDAMMO);
		if (self.randomized < RND_HIGH) {
			randomammo = randomammo + 1;
			self.spawnflags = self.spawnflags | A_LARGE;
		}
		// Show console info
		rnd_displaydebug();
	}
	// Find small ammo box for upgrade
	else if (self.classname == "item_plasma" && !(self.spawnflags & A_LARGE)) {
		// Generate complete set of numbers
		rnd_generateseeds(RND_SEEDAMMO);
		if (self.randomized < RND_HIGH) {
			randomammo = randomammo + 1;
			self.spawnflags = self.spawnflags | A_LARGE;
		}
		// Show console info
		rnd_displaydebug();
	}
	//------------------------------------------------------------------
	// Entity does not change classname, no need to block spawn
	return FALSE;
};

//=====================================================================
// IMPORTANT - This function is called on FRAME 0!
// Check for different spawning options for armour
// Called from items.qc / various armour spawn routines
//------------------------------------------------------------------
float() armour_checkrandomizer =
{
	// Is the randomizer system active?
	if (check_randflags() == FALSE) return FALSE;
	// Has the entity already been randomized?
	if (self.randomized != 0) return FALSE;
	// This can only happen on frame 0
	if (framecount > 0) return FALSE;
	// No deathmatch support
	if (deathmatch > 0) return FALSE;

	// Make sure random seed is setup
	setup_randomseed();
	// Random changes to armour
	if (self.classname == "item_armor1") {
		// Generate complete set of numbers
		rnd_generateseeds(RND_SEEDARMOUR);
		rnd_resetspawnflags();
		// Check for <33=negative and >66=positive
		if (self.randomized < RND_LOW) {
			self.classname = "item_backpack_armour";
			self.th_randfunc = item_backpack_armour;
			if (random() < 0.5) self.spawnflags = self.spawnflags | BACKPACK_YELTYPE;
			else self.spawnflags = self.spawnflags | BACKPACK_REDTYPE;
		}
		else if (self.randomized > RND_HIGH) {
			self.classname = "item_armor2";
			self.th_randfunc = item_armor2;
		}
		// Show console info
		rnd_displaydebug();
	}
	else if (self.classname == "item_armor2") {
		// Generate complete set of numbers
		rnd_generateseeds(RND_SEEDARMOUR);
		rnd_resetspawnflags();
		// Check for <33=negative and >66=positive
		if (self.randomized < RND_LOW) {
			self.classname = "item_armor1";
			self.th_randfunc = item_armor1;			
		}
		else if (self.randomized > RND_HIGH) {
			self.classname = "item_armorInv";
			self.th_randfunc = item_armorInv;
		}
		// Show console info
		rnd_displaydebug();
	}	
	// Precache extra files for later
	else if (self.classname == "item_armorInv") {
		precache_sound ((self.noise1 = SOUND_ARTBLASTBELT1));
		precache_sound ((self.noise2 = SOUND_ARTBLASTBELT2));
		precache_sound ((self.noise3 = SOUND_ARTBLASTBELT3));
	}
	//------------------------------------------------------------------
	// Randomizer function setup?
	if (self.randomized > 0 && self.th_randfunc) {
		// Re-direct to random function and finish
		self.th_randfunc();
		return TRUE;
	}
	else return FALSE;
};

//=====================================================================
// IMPORTANT - This function is called on FRAME 0!
// Check for different spawning options for artifact/powerups
// Called from items.qc / various artifact spawn routines
//----------------------------------------------------------------------
float() artifact_checkrandomizer =
{
	// Is the randomizer system active?
	if (check_randflags() == FALSE) return FALSE;
	// Has the entity already been randomized?
	if (self.randomized != 0) return FALSE;
	// This can only happen on frame 0
	if (framecount > 0) return FALSE;
	// No deathmatch support
	if (deathmatch > 0) return FALSE;
	
	// Make sure random seed is setup
	setup_randomseed();
	// Random changes to artifacts
	if (self.classname == "item_artifact_invisibility") {
		// Generate complete set of numbers
		rnd_generateseeds(RND_SEEDARTIFACT);
		rnd_resetspawnflags();
		// Check for <33=negative and >66=positive
		if (self.randomized < RND_LOW) {
			// Its hard to find a more negative item than InvRing!?!
			self.classname = "item_health";
			self.th_randfunc = item_health;			
			self.spawnflags = H_MEGA;
			// Powerup origin is -24 lower than Health Packs
			self.origin = self.origin + '0 0 24';
			// ID health packs are placed by corner not center origin
			// Move origin backward because it was originally a powerup
			if (query_configflag(SVR_ITEMOFFSET) == FALSE) {
				self.origin = self.origin + '-16 -16 0';
			}
		}
		else if (self.randomized > RND_HIGH) {
			self.classname = "item_artifact_super_damage";
			self.th_randfunc = item_artifact_super_damage;
		}
		// Show console info
		rnd_displaydebug();
	}
	else if (self.classname == "item_artifact_envirosuit") {
		// Generate complete set of numbers
		rnd_generateseeds(RND_SEEDARTIFACT);
		rnd_resetspawnflags();
		// Check for <33=negative and >66=positive
		if (self.randomized < RND_LOW) {
			self.classname = "item_health";
			self.th_randfunc = item_health;
			self.spawnflags = H_MEGA;
			// Powerup origin is -24 lower than Health Packs
			self.origin = self.origin + '0 0 24';
			// ID health packs are placed by corner not center origin
			// Move origin backward because it was originally a powerup
			if (query_configflag(SVR_ITEMOFFSET) == FALSE) {
				self.origin = self.origin + '-16 -16 0';
			}
		}
		else if (self.randomized > RND_HIGH) {
			self.classname = "item_artifact_invulnerability";
			self.th_randfunc = item_artifact_invulnerability;
		}
		// DEFAULT = Env Suit
		else {
			// Precache jump boots for combo pickup reward
			precache_sound (SOUND_ARTJUMPBOOTS1);
			// sounds 3a-3c are used in client.qc (lines 915+)
			precache_sound (SOUND_ARTJUMPBOOTS2);
			precache_sound (SOUND_ARTJUMPBOOTS3A);	// First jump
			precache_sound (SOUND_ARTJUMPBOOTS3B);	// Second
			precache_sound (SOUND_ARTJUMPBOOTS3C);	// No more			
		}
		// Show console info
		rnd_displaydebug();
	}
	else if (self.classname == "item_artifact_invulnerability") {
		// Precache lava shield for combo pickup reward
		precache_sound (SOUND_ARTLSHIELD1);
		precache_sound (SOUND_ARTLSHIELD2);
		precache_sound (SOUND_ARTLSHIELD3);
	}
	else if (self.classname == "item_artifact_super_damage") {
		// Precache blast belt for combo pickup reward
		precache_sound (SOUND_ARTBLASTBELT1);
		precache_sound (SOUND_ARTBLASTBELT2);
		precache_sound (SOUND_ARTBLASTBELT3);
	}

	//------------------------------------------------------------------
	// Randomizer function setup?
	if (self.randomized > 0 && self.th_randfunc) {
		// Re-direct to random function and finish
		self.th_randfunc();
		return TRUE;
	}
	else return FALSE;
};

//==================================================================
// Monster group/family setups
//------------------------------------------------------------------
void() rnd_dogfamily =
{
	// Store family ranges in a vector
	local vector randomrange;
	self.randomindex = 0;
	randomrange = '10 30 70';
	rnd_prevnumber(randomrange,self.randomindex);
	// PICK MONSTER ------------------------------------------------
	if (self.randomized < randomrange_x) {
		self.classname = "monster_scorpion";
		self.th_randfunc = monster_scorpion;
		if (self.randompoison < RND_MIDDLE)
			self.spawnflags = self.spawnflags | MON_SCORPION_STINGER;
	}
	else if (self.randomized < randomrange_y) {
		self.classname = "monster_voreling";
		self.th_randfunc = monster_voreling;
		if (self.randompoison < RND_MIDDLE)
			self.spawnflags = self.spawnflags | MON_VORELING_LARGE;
	}
	else if (self.randomized < randomrange_z) {
		self.classname = "monster_spider";
		self.th_randfunc = monster_spider;
		if (self.randompoison < RND_MIDDLE)
			self.spawnflags = self.spawnflags | MON_SPIDER_LARGE;
	}
	else {
		self.classname = "monster_dog";
		self.th_randfunc = monster_dog;
		rnd_addpoison(FALSE);
	}
};

//------------------------------------------------------------------
void() rnd_fishfamily =
{
	// Store family ranges in a vector
	local vector randomrange;
	self.randomindex = 1;
	randomrange = '10 20 60';
	rnd_prevnumber(randomrange,self.randomindex);
	// PICK MONSTER ------------------------------------------------
	if (self.randomized < randomrange_x) {
		self.classname = "monster_tarbaby";
		self.th_randfunc = monster_tarbaby;
		self.spawnflags = self.spawnflags | MON_TARBYLESSJUMP;
	}
	// The dead can't drown!
	else if (self.randomized < randomrange_y) {
		self.classname = "monster_zombie";
		self.th_randfunc = monster_zombie;
		rnd_resetzombieflags();
	}
	else if (self.randomized < randomrange_z) {
		self.classname = "monster_eel";
		self.th_randfunc = monster_eel;
		self.spawnflags = self.spawnflags | MON_LIQUIDBLOCK;
	}
	else {
		self.classname = "monster_fish";
		self.th_randfunc = monster_fish;
		rnd_addpoison(FALSE);
	}
};

//------------------------------------------------------------------
void() rnd_armyfamily =
{
	// Store family ranges in a vector
	local vector randomrange;
	self.randomindex = 2;
	randomrange = '10 50 70';
	rnd_prevnumber(randomrange,self.randomindex);
	// PICK MONSTER ------------------------------------------------
	if (self.randomized < randomrange_x) {
		self.classname = "monster_army_plasma";
		self.th_randfunc = monster_army_plasma;
	}
	else if (self.randomized < randomrange_y) {
		if (self.randompoison < RND_MIDDLE) {
		self.classname = "monster_army_grenade";
		self.th_randfunc = monster_army_grenade;
		}
		else {
			self.classname = "monster_jim";
			self.th_randfunc = monster_jim;
		}
	}
	else if (self.randomized < randomrange_z) {
		if (self.randompoison > RND_LOW) {
		self.classname = "monster_army_rocket";
		self.th_randfunc = monster_army_rocket;
		}
		else {
			self.classname = "monster_jim";
			self.th_randfunc = monster_jim;
			self.spawnflags = self.spawnflags | MON_JIM_ROCKET;
		}
	}
	else {
		self.classname = "monster_army";
		self.th_randfunc = monster_army;
		rnd_addpoison(FALSE);
	}
};

//------------------------------------------------------------------
void() rnd_zombiefamily =
{
	// Store family ranges in a vector
	local vector randomrange;
	self.randomindex = 3;
	randomrange = '10 40 70';
	rnd_prevnumber(randomrange,self.randomindex);
	// PICK MONSTER ------------------------------------------------
	if (self.randomized < randomrange_x) {
		self.classname = "monster_tarbaby";
		self.th_randfunc = monster_tarbaby;
		self.spawnflags = self.spawnflags | MON_TARBYLESSJUMP;
		self.poisonous = TRUE;
		self.exactskin = floor(2+(random()*4));
	}
	else if (self.randomized < randomrange_y) {
		self.classname = "monster_boil";
		self.th_randfunc = monster_boil;
	}
	else if (self.randomized < randomrange_z) {
		self.classname = "monster_zombiek";
		self.th_randfunc = monster_zombiek;
		rnd_addpoison(FALSE);
	}
	else {
		if (self.randompoison < RND_MIDDLE) {
			self.classname = "monster_zombie";
			self.th_randfunc = monster_zombie;
			rnd_resetzombieflags();
		}
		else {
			self.classname = "monster_mummy";
			self.th_randfunc = monster_mummy;
		}
	}
};

//------------------------------------------------------------------
void() rnd_knightfamily =
{
	// Store family ranges in a vector
	local vector randomrange;
	self.randomindex = 4;
	randomrange = '10 40 70';
	rnd_prevnumber(randomrange,self.randomindex);
	// PICK MONSTER ------------------------------------------------
	if (self.randomized < randomrange_x) {
		self.classname = "monster_death_guard";
		self.th_randfunc = monster_death_guard;
	}
	else if (self.randomized < randomrange_y) {
		self.classname = "monster_dcrossbow";
		self.th_randfunc = monster_dcrossbow;
		if (self.randomupg < RND_LOW)
			self.spawnflags = self.spawnflags | MON_DCROSSSNIPER;
		rnd_addpoison(FALSE);
	}
	else if (self.randomized < randomrange_z) {
		self.classname = "monster_dguard";
		self.th_randfunc = monster_dguard;
		rnd_addpoison(FALSE);
	}
	else {
		self.classname = "monster_knight";
		self.th_randfunc = monster_knight;
		// Make sure no trigger events on statue knights
		if (self.randompoison < RND_LOW) {
			// make sure spawnflags are reset
			rnd_resetspawnflags();
			// Make sure the knight is NOT frozen, just stone skin
			self.spawnflags = self.spawnflags | MON_STATUE | MON_NOTFROZEN;
		}
		else {
			rnd_addpoison(FALSE);
			// If not poisonous, randomize skin
			if (!self.poisonous) self.exactskin = -1;
		}
	}
};

//------------------------------------------------------------------
void() rnd_enforcerfamily =
{
	// Store family ranges in a vector
	local vector randomrange;
	self.randomindex = 5;
	randomrange = '5 40 60';
	rnd_prevnumber(randomrange,self.randomindex);
	// PICK MONSTER ------------------------------------------------
	if (self.randomized < randomrange_x) {
		self.classname = "monster_deflector";
		self.th_randfunc = monster_deflector;
		if (self.randompoison < RND_LOW)
			self.spawnflags = self.spawnflags | MON_DEFLECTOR_PLASMA;
	}
	else if (self.randomized < randomrange_y) {
		self.classname = "monster_eliminator";
		self.th_randfunc = monster_eliminator;
	}
	else if (self.randomized < randomrange_z) {
		if (self.randompoison < RND_LOW) {
			self.classname = "monster_centurion";
			self.th_randfunc = monster_centurion;
		}
		else {
			self.classname = "monster_defender";
			self.th_randfunc = monster_defender;
		}
	}
	else {
		if (self.randompoison < RND_LOW) {
			self.classname = "monster_pyro";
			self.th_randfunc = monster_pyro;
		}
		else {
			self.classname = "monster_enforcer";
			self.th_randfunc = monster_enforcer;
			rnd_addpoison(FALSE);
		}
	}
};

//------------------------------------------------------------------
void() rnd_wizardfamily =
{
	// Store family ranges in a vector
	local vector randomrange;
	self.randomindex = 6;
	randomrange = '5 40 70';
	rnd_prevnumber(randomrange,self.randomindex);
	// PICK MONSTER ------------------------------------------------
	if (self.randomized < randomrange_x) {
		self.classname = "monster_wraith";
		self.th_randfunc = monster_wraith;
	}
	else if (self.randomized < randomrange_y)  {
		self.classname = "monster_gargoyle";
		self.th_randfunc = monster_gargoyle;
		rnd_addpoison(FALSE);
	}
	else if (self.randomized < randomrange_z) {
		self.classname = "monster_gaunt";
		self.th_randfunc = monster_gaunt;
		rnd_addpoison(FALSE);
	}
	else {
		self.classname = "monster_wizard";
		self.th_randfunc = monster_wizard;
		if (self.randomupg < RND_LOW)
			self.spawnflags = self.spawnflags | MON_WIZARD_ABOVE;
		rnd_addpoison(FALSE);
	}
};

//------------------------------------------------------------------
void() rnd_tarbabyfamily =
{
	// Store family ranges in a vector
	local vector randomrange;
	self.randomindex = 7;
	randomrange = '10 30 50';
	rnd_prevnumber(randomrange,self.randomindex);
	// PICK MONSTER ------------------------------------------------
	if (self.randomized < randomrange_x) {
		self.classname = "monster_fumigator";
		self.th_randfunc = monster_fumigator;
	}
	else if (self.randomized < randomrange_y) {
		self.classname = "monster_sentinel";
		self.th_randfunc = monster_sentinel;
		rnd_addpoison(FALSE);
	}
	else if (self.randomized < randomrange_z) {
		self.classname = "monster_boil";
		self.th_randfunc = monster_boil;
	}
	else {
		self.classname = "monster_tarbaby";
		self.th_randfunc = monster_tarbaby;
		if (self.randomupg < RND_LOW)
			self.spawnflags = self.spawnflags | MON_TARBYLESSJUMP;
		rnd_addpoison(FALSE);
		if (self.poisonous) self.exactskin = floor(2+(random()*4));
	}
};

//------------------------------------------------------------------
void() rnd_ogrefamily =
{
	// Store family ranges in a vector
	local vector randomrange;
	self.randomindex = 8;
	randomrange = '30 60 80';
	rnd_prevnumber(randomrange,self.randomindex);
	// Backup bounding box is ogre/shambler size
	self.idmins = VEC_HULL2_MIN;
	self.idmaxs = VEC_HULL2_MAX;
	
	// PICK MONSTER ------------------------------------------------
	if (self.randomized < randomrange_x) {
		self.classname = "monster_hogreham";
		self.th_randfunc = monster_hogreham;
		if (self.randompoison < RND_MIDDLE)
			self.spawnflags = self.spawnflags | MON_HOGRE_METAL;
	}
	else if (self.randomized < randomrange_y) {
		self.classname = "monster_hogremac";
		self.th_randfunc = monster_hogremac;
		if (self.randompoison < RND_MIDDLE)
			self.spawnflags = self.spawnflags | MON_HOGRE_METAL;
	}
	else if (self.randomized < randomrange_z) {
		self.classname = "monster_hogre";
		self.th_randfunc = monster_hogre;
		if (self.randompoison < RND_MIDDLE)
			self.spawnflags = self.spawnflags | MON_HOGRE_METAL;
	}
	else {
		self.classname = "monster_ogre";
		self.th_randfunc = monster_ogre;
		if (self.randompoison < RND_MIDDLE)
			self.spawnflags = self.spawnflags | MON_OGRE_GREEN;
		else
			self.spawnflags = self.spawnflags | MON_OGRE_NAIL;
	}
};

//------------------------------------------------------------------
void() rnd_hknightfamily =
{
	// Store family ranges in a vector
	local vector randomrange;
	self.randomindex = 9;
	randomrange = '10 30 70';
	rnd_prevnumber(randomrange,self.randomindex);
	// PICK MONSTER ------------------------------------------------
	if (self.randomized < randomrange_x) {
		self.classname = "monster_dprince";
		self.th_randfunc = monster_dprince;
		// Default (1200) too high for hknight
		if (self.randompoison > RND_LOW)
			self.spawnflags = self.spawnflags | MON_DPRINCE_FIRE;
	}
	else if (self.randomized < randomrange_y) {
		self.classname = "monster_death_lord";
		self.th_randfunc = monster_death_lord;
	}
	else if (self.randomized > randomrange_z) {
		self.classname = "monster_dfury";
		self.th_randfunc = monster_dfury;
		if (self.randomupg < RND_LOW) self.jump_flag = -1;
		rnd_addpoison(FALSE);
	}
	else {
		self.classname = "monster_dknight";
		self.th_randfunc = monster_dknight;
		rnd_addpoison(RND_LOW);
		if (!self.poisonous && self.randomupg > RND_LOW)
			self.exactskin = 1;		// Red skin
	}
};

//------------------------------------------------------------------
void() rnd_demonfamily =
{
	// Store family ranges in a vector
	local vector randomrange;
	self.randomindex = 10;
	randomrange = '10 30 60';
	rnd_prevnumber(randomrange,self.randomindex);
	// Backup bounding box is ogre/shambler size
	self.idmins = VEC_HULL2_MIN;
	self.idmaxs = VEC_HULL2_MAX;
	// PICK MONSTER ------------------------------------------------
	if (self.randomized < randomrange_x) {
		self.classname = "monster_golem";
		self.th_randfunc = monster_golem;
	}
	else if (self.randomized < randomrange_y) {
		self.classname = "monster_minotaur";
		self.th_randfunc = monster_minotaur;
	}
	else if (self.randomized < randomrange_z) {
		self.classname = "monster_drole";
		self.th_randfunc = monster_drole;
	}
	else {
		self.classname = "monster_demon1";
		self.th_randfunc = monster_demon1;
		rnd_addpoison(RND_LOW);
	}
};

//------------------------------------------------------------------
void() rnd_shalrathfamily =
{
	// Store family ranges in a vector
	local vector randomrange;
	self.randomindex = 11;
	randomrange = '30 70 100';
	rnd_prevnumber(randomrange,self.randomindex);
	// PICK MONSTER ------------------------------------------------
	if (self.randomized < randomrange_x) {
		self.classname = "monster_skullwiz";
		self.th_randfunc = monster_skullwiz;
		self.spawnflags = self.spawnflags | MON_SKULLWIZ_GUARDIAN;
	}
	else if (self.randomized < randomrange_y) {
		self.classname = "monster_dsergeant";
		self.th_randfunc = monster_dsergeant;
		rnd_addpoison(RND_LOW);
	}
	else {
		self.classname = "monster_shalrath";
		self.th_randfunc = monster_shalrath;
		rnd_addpoison(RND_LOW);
	}
};

//------------------------------------------------------------------
void() rnd_shamblerfamily =
{
	// Store family ranges in a vector
	local vector randomrange;
	self.randomindex = 12;
	randomrange = '30 60 70';
	rnd_prevnumber(randomrange,self.randomindex);
	// Backup bounding box is ogre/shambler size
	self.idmins = VEC_HULL2_MIN;
	self.idmaxs = VEC_HULL2_MAX;
	// PICK MONSTER ------------------------------------------------
	if (self.randomized < randomrange_x) {
		self.classname = "monster_boglord";
		self.th_randfunc = monster_boglord;
		// Default (1200) too high for shambler
		if (self.health <= 1) self.health = 900;
	}
	else if (self.randomized < randomrange_y) {
		self.classname = "monster_justice";
		self.th_randfunc = monster_justice;
		self.exactskin = floor(random()*2);
	}
	else if (self.randomized < randomrange_z) {
		self.classname = "monster_nour";
		self.th_randfunc = monster_nour;
		// Default (1200) too high for shambler
		if (self.health <= 1) self.health = 800;
		// Aggressive spit attack
		self.attack_chance = 0.7;
	}
	else {
		self.classname = "monster_shambler";
		self.th_randfunc = monster_shambler;
		if (self.randompoison < RND_LOW)
			self.attack_sniper = TRUE;
	}
};

//==================================================================
// BOUNDING BOX spawning system
//------------------------------------------------------------------
void() rnd_bboxspawns =
{
	// Humanoid Scale bounding box
	//------------------------------------------------------------------
	if (self.classname == "monster_enforcer") {
		self.randombbox = RND_BBOX1;
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONENFORCER);
		rnd_resetspawnflags();
	}
	else if (self.classname == "monster_zombie") {
		self.randombbox = RND_BBOX1;
		// Can't do much with crucified zombies!
		if (self.spawnflags & MON_ZOMCRUCIFIED) return FALSE;
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONZOMBIE);
		rnd_resetzombieflags();
	}
	else if (self.classname == "monster_tarbaby") {
		self.randombbox = RND_BBOX1;
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONTARBABY);
		rnd_resetspawnflags();
	}
	else if (self.classname == "monster_knight") {
		self.randombbox = RND_BBOX1;
		// Can't do much with stone knights!
		if (self.spawnflags & MON_STATUE) return FALSE;
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONKNIGHT);
		rnd_resetspawnflags();
	}
	else if (self.classname == "monster_hell_knight") {
		self.randombbox = RND_BBOX1;
		// Can't do much with stone knights!
		if (self.spawnflags & MON_STATUE) return FALSE;
		// Don't touch pointy knights!
		if (self.spawnflags & MON_POINT_KNIGHT) return FALSE;
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONHELLK);
		rnd_resetspawnflags();
	}
	// Medium/Large monsters with giant bounding boxes
	//------------------------------------------------------------------
	else if (self.classname == "monster_dog") {
		self.randombbox = RND_BBOX2;
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONDOG);
		rnd_resetspawnflags();
	}
	else if (self.classname == "monster_ogre") {
		self.randombbox = RND_BBOX2;
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONOGRE);
		rnd_resetspawnflags();
	}
	else if (self.classname == "monster_demon1") {
		self.randombbox = RND_BBOX2;
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONDEMON1);
		rnd_resetspawnflags();
	}
	else if (self.classname == "monster_shalrath") {
		self.randombbox = RND_BBOX2;
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONSHALRATH);
		rnd_resetspawnflags();
	}
	else if (self.classname == "monster_shambler") {
		self.randombbox = RND_BBOX2;
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONSHAMBLER);
		rnd_resetspawnflags();
	}
	// Flying monster(s)
	//------------------------------------------------------------------
	else if (self.classname == "monster_wizard") {
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONWIZARD);
		rnd_resetspawnflags();
		rnd_generateseeds(RND_SEEDMONSTER);
		rnd_wizardfamily();
	}
	// Swimming monster(s)
	//------------------------------------------------------------------
	else if (self.classname == "monster_fish") {
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONFISH);
		rnd_resetspawnflags();
		rnd_generateseeds(RND_SEEDMONSTER);
		rnd_fishfamily();
	}
	// Most starting maps in episodes are full of army grunts
	// Only randomize them within their family group (easier start)
	//------------------------------------------------------------------
	else if (self.classname == "monster_army") {
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONARMY);
		rnd_resetspawnflags();
		rnd_generateseeds(RND_SEEDMONSTER);
		rnd_armyfamily();
	}
	//------------------------------------------------------------------
	// ID1 essentially had 2 bounding box sizes
	// Monsters MINS-------  MAXS---- HULL
	// Army     -16 -16 -24, 16 16 40  1
	// Zombie   -16 -16 -24, 16 16 40  1
	// Knight   -16 -16 -24, 16 16 40  1
	// Enforcer -16 -16 -24, 16 16 40  1
	// Tarbaby  -16 -16 -24, 16 16 40  1
	// H Knight -16 -16 -24, 16 16 40  1
	// Dog      -32 -32 -24, 32 32 40   2
	// Ogre     -32 -32 -24, 32 32 64   2
	// Demon1   -32 -32 -24, 32 32 64   2
	// Shalrath -32 -32 -24, 32 32 64   2
	// Shambler -32 -32 -24, 32 32 64   2
	// Fish     -16 -16 -24, 16 16 24  *SWIM*
	// Wizard   -16 -16 -24, 16 16 40  *FLY*

	// Size 1 = -16 -16 -24, 16 16 40
	//------------------------------------------------------------------
	if (self.randombbox == RND_BBOX1) {
		rnd_generateseeds(RND_SEEDMONSTER);

		// 10=Army 20=Enforcer 15=Zombie 20=Tarbaby 20=Knight 15=HKnight
		// 0-10    10-30       30-45     45-65      65-85     85-100
		if (self.randomupg < 10) rnd_armyfamily();
		else if (self.randomupg < 30) rnd_enforcerfamily();
		else if (self.randomupg < 45) rnd_zombiefamily();
		else if (self.randomupg < 65) rnd_tarbabyfamily();
		else if (self.randomupg < 85) rnd_knightfamily();
		else rnd_hknightfamily();
	}
	// Size 2 = -32 -32 -24, 32 32 64
	//------------------------------------------------------------------
	else if (self.randombbox == RND_BBOX2) {
		rnd_generateseeds(RND_SEEDMONSTER);

		// 20=Dog 20=Ogre 20=Demon1 15=Shalrath 15=Shambler
		// 0-20   20-40   40-60     70-85       85-100
		if (self.randomupg < 20) rnd_dogfamily();
		else if (self.randomupg < 40) rnd_ogrefamily();
		else if (self.randomupg < 70) rnd_demonfamily();
		else if (self.randomupg < 85) rnd_shalrathfamily();
		else rnd_shamblerfamily();
	}
	// Show console info
	rnd_displaydebug();
};

//==================================================================
// FAMILY spawning system
//------------------------------------------------------------------
void() rnd_familyspawns =
{
	if (self.classname == "monster_dog") {
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONDOG);
		rnd_resetspawnflags();
		rnd_generateseeds(RND_SEEDMONSTER);
		rnd_dogfamily();
	}
	//------------------------------------------------------------------
	else if (self.classname == "monster_fish") {
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONFISH);
		rnd_resetspawnflags();
		rnd_generateseeds(RND_SEEDMONSTER);
		rnd_fishfamily();
	}
	//------------------------------------------------------------------
	else if (self.classname == "monster_army") {
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONARMY);
		rnd_resetspawnflags();
		rnd_generateseeds(RND_SEEDMONSTER);
		rnd_armyfamily();
	}
	//------------------------------------------------------------------
	else if (self.classname == "monster_zombie") {
		// Can't do much with crucified zombies!
		if (self.spawnflags & MON_ZOMCRUCIFIED) return FALSE;
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONZOMBIE);
		rnd_resetzombieflags();
		rnd_generateseeds(RND_SEEDMONSTER);
		rnd_zombiefamily();
	}
	//------------------------------------------------------------------
	else if (self.classname == "monster_knight") {
		// Can't do much with stone knights!
		if (self.spawnflags & MON_STATUE) return FALSE;
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONKNIGHT);
		rnd_resetspawnflags();
		rnd_generateseeds(RND_SEEDMONSTER);
		rnd_knightfamily();
	}
	//------------------------------------------------------------------
	else if (self.classname == "monster_enforcer") {
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONENFORCER);
		rnd_resetspawnflags();
		rnd_generateseeds(RND_SEEDMONSTER);
		rnd_enforcerfamily();
	}
	//------------------------------------------------------------------
	else if (self.classname == "monster_wizard") {
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONWIZARD);
		rnd_resetspawnflags();
		rnd_generateseeds(RND_SEEDMONSTER);
		rnd_wizardfamily();
	}
	//------------------------------------------------------------------
	else if (self.classname == "monster_tarbaby") {
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONTARBABY);
		rnd_resetspawnflags();
		rnd_generateseeds(RND_SEEDMONSTER);
		rnd_tarbabyfamily();
	}
	//------------------------------------------------------------------
	else if (self.classname == "monster_ogre") {
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONOGRE);
		rnd_resetspawnflags();
		rnd_generateseeds(RND_SEEDMONSTER);
		rnd_ogrefamily();
	}
	//------------------------------------------------------------------
	else if (self.classname == "monster_hell_knight") {
		// Can't do much with stone knights!
		if (self.spawnflags & MON_STATUE) return FALSE;
		// Don't touch pointy knights!
		if (self.spawnflags & MON_POINT_KNIGHT) return FALSE;
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONHELLK);
		rnd_resetspawnflags();
		rnd_generateseeds(RND_SEEDMONSTER);
		rnd_hknightfamily();
	}
	//------------------------------------------------------------------
	else if (self.classname == "monster_demon1") {
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONDEMON1);
		rnd_resetspawnflags();
		rnd_generateseeds(RND_SEEDMONSTER);
		rnd_demonfamily();
	}
	//------------------------------------------------------------------
	else if (self.classname == "monster_shalrath") {
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONSHALRATH);
		rnd_resetspawnflags();
		rnd_generateseeds(RND_SEEDMONSTER);
		rnd_shalrathfamily();
	}
	//------------------------------------------------------------------
	else if (self.classname == "monster_shambler") {
		// Reset HP and spawnflags
		rnd_resethealth(HP_MONSHAMBLER);
		rnd_resetspawnflags();
		rnd_generateseeds(RND_SEEDMONSTER);
		rnd_shamblerfamily();
	}
	// Show console info
	rnd_displaydebug();
};

//=====================================================================
// IMPORTANT - This function is called only when monsters gib
// Check for shadow axe fragments
// Called from ai_gibs.qc / monster_check_gib
//----------------------------------------------------------------------
void() monster_gibrandomizer =
{
	local float wpnupg;
	// Check for randomizer system
	if (check_randflags() == FALSE) return;
	if (!(self.activate.flags & FL_CLIENT)) return;
	// Got the Shadow Axe already?
	if (self.activate.moditems & IT_UPGRADE_AXE) return;
	
	// Update counter on player (every client has own counter)
	self.activate.randomgibs = self.activate.randomgibs + 1;

	// Default shotgun fragments (5=Easy, 9=Normal, 13=Hard+)
	wpnupg = rnd_upgwpnmax_shadowaxe();		
	// Still collecting?
	if (self.activate.randomgibs < wpnupg)
		sprint(self.activate, "You found an Axe Fragment\n");
	// Finally got to the magic amount!
	else if (self.activate.randomgibs == wpnupg) {
		self.activate.items = self.activate.items | IT_AXE;
		self.activate.moditems = self.activate.moditems | IT_UPGRADE_AXE;
		rnd_playsurprise(self.activate, RND_SURPRISEPOS);
		centerprint(self.activate,"You got the Shadow Axe!!!\n");
		stuffcmd (self.activate, "bf\n");
		self.activate.weapon = IT_AXE;
		W_SetCurrentAmmo(self.activate);
	}
};

//=====================================================================
// IMPORTANT - This function is called only on item pickup
// Check for weapon fragments (shotgun/plasma)
// Called from items.qc / ammo_touch
//----------------------------------------------------------------------
void() ammo_touchrandomizer =
{
	local float wpnupg;
	// Check for randomizer system
	if (check_randflags() == FALSE) return;
	// Check for player
	if (!(other.flags & FL_CLIENT)) return;
	// Check for large ammo box
	if (!(self.spawnflags & A_LARGE)) return;

	// Check for shells for Widowmaker
	if (self.classtype == CT_AMMOSHELLS) {
		// Got the Widowmaker already?
		if (other.moditems & IT_UPGRADE_SSG) return;
		other.randomshells = other.randomshells + 1;
		
		// Default shotgun fragments (3=Easy, 4=Normal, 5=Hard+)
		wpnupg = rnd_upgwpnmax_widowmaker();		
		// Still collecting?
		if (other.randomshells < wpnupg)
			sprint(other, "You found a Shotgun Fragment\n");
		// Finally got to the magic amount!
		else if (other.randomshells == wpnupg) {
			other.items = other.items | IT_SUPER_SHOTGUN;
			other.moditems = other.moditems | IT_UPGRADE_SSG;
			rnd_playsurprise(other, RND_SURPRISEPOS);
			centerprint(other,"You got the Widowmaker Shotgun!!!\n");
			stuffcmd (other, "bf\n");
			other.weapon = IT_SUPER_SHOTGUN;
			W_SetCurrentAmmo(other);
		}
	}
	else if (self.classtype == CT_AMMOCELLS) {
		// Got the Plasma Gun already?
		if (other.moditems & IT_UPGRADE_LG) return;
		other.randomcells = other.randomcells + 1;

		// Default cell fragments (1=Easy, 2=Normal, 3=Hard+)
		wpnupg = rnd_upgwpnmax_plasmagun();
		// Still collecting?
		if (other.randomcells < wpnupg)
			sprint(other, "You found a Plasma Fragment\n");
		// Finally got to the magic amount!
		else if (other.randomcells == wpnupg) {
			other.items = other.items | IT_LIGHTNING;
			other.moditems = other.moditems | IT_UPGRADE_LG;
			rnd_playsurprise(other, RND_SURPRISEPOS);
			centerprint(other,"You got the Plasma Gun!!!\n");
			stuffcmd (other, "bf\n");
			other.weapon = IT_LIGHTNING;
			W_SetCurrentAmmo(other);
		}
	}
};

//=====================================================================
// IMPORTANT - This function is called only on item pickup
// Check for positive/negative buff Megahealth
// Called from items.qc / health_touch
//----------------------------------------------------------------------
void() health_touchrandomizer =
{
	// Check for randomizer system
	if (check_randflags() == FALSE) return;
	// Check for player
	if (!(other.flags & FL_CLIENT)) return;
	
	if (self.classtype == CT_HEALMEGA) {
		self.randomized = random();
		// Check for <33=negative and >66=positive
		if (self.randomized < RND_NEGATIVE) {
			sprint (other, "You got a mouldy MegaHealth!\n");
			// Default is 1 per second
			self.rotting_qty = 5;
			rnd_playsurprise(other, RND_SURPRISENEG);
		}
		else if (self.randomized > RND_POSITIVE) {
			other.rad_time = 1;
			other.radsuit_finished = time + POWERUP_TIMER;
			other.items = other.items | IT_SUIT;
			sprint (other, "You got the Environment Suit\n");
			stuffcmd (other, "bf\n");
			centerprint(other,"You also found the Environment Suit!\n");
			rnd_playsurprise(other, RND_SURPRISEPOS);
		}
	}
};

//=====================================================================
// IMPORTANT - This function is called only on item pickup
// Check for positive/negative buff Red Armour
// Called from items.qc / armor_touch
//----------------------------------------------------------------------
void() armour_touchrandomizer =
{
	// Check for randomizer system
	if (check_randflags() == FALSE) return;
	// Check for player
	if (!(other.flags & FL_CLIENT)) return;
	
	if (self.classtype == CT_ARMORINV) {
		self.randomized = random();
		// Check for <33=negative and >66=positive
		if (self.randomized < RND_NEGATIVE) {
			self.armorvalue = 125 + (random()*50);
			self.netname = "used red armour";
			rnd_playsurprise(other, RND_SURPRISENEG);
		}
		else if (self.randomized > RND_POSITIVE) {
			other.blastbelt_time = 1;
			other.blastbelt_volume = 1;
			other.blastbelt_finished = time + POWERUP_TIMER;
			other.moditems = other.moditems | IT_ARTBLASTBELT;
			sprint (other, "You got the Blast Belt\n");
			stuffcmd (other, "bf\n");
			centerprint(other,"You also found the Blast Belt!\n");
			rnd_playsurprise(other, RND_SURPRISEPOS);
		}
	}
};

//=====================================================================
// IMPORTANT - This function is called only on item pickup
// Check for positive buff on artifacts (no negative)
// Pent=+lava shield, Quad=+blast belt, EnvSuit=+jump boots
// Called from items.qc / artifact_touch
//----------------------------------------------------------------------
void() artifact_touchrandomizer =
{
	// Check for randomizer system
	if (check_randflags() == FALSE) return;
	// Check for player
	if (!(other.flags & FL_CLIENT)) return;
	
	if (self.classtype == CT_ARTPENT) {
		self.randomized = random();
		// Check for >66=positive only
		if (self.randomized > RND_POSITIVE) {
			other.lavashield_time = 1;
			other.lavashield_volume = 1;
			// Got to match original powerup on time
			other.lavashield_finished = time + self.cnt;
			other.moditems = other.moditems | IT_ARTLAVASHIELD;
			sprint (other, "You got the Aegis of Chthon\n");
			stuffcmd (other, "bf\n");
			centerprint(other,"You also found Aegis of Chthon!\n");
			rnd_playsurprise(other, RND_SURPRISEPOS);
		}
	}
	else if (self.classtype == CT_ARTQUAD) {
		self.randomized = random();
		// Check for >66=positive only
		if (self.randomized > RND_POSITIVE) {
			other.blastbelt_time = 1;
			other.blastbelt_volume = 1;
			// Got to match original powerup on time
			other.blastbelt_finished = time + self.cnt;
			other.moditems = other.moditems | IT_ARTBLASTBELT;
			sprint (other, "You got the Blast Belt\n");
			stuffcmd (other, "bf\n");
			centerprint(other,"You also found the Blast Belt!\n");
			rnd_playsurprise(other, RND_SURPRISEPOS);
		}
	}
	else if (self.classtype == CT_ARTSUIT) {
		self.randomized = random();
		// Check for >66=positive only
		if (self.randomized > RND_POSITIVE) {
			other.jumpboots_time = 1;
			other.jumpboots_airlvl = 0;
			other.jumpboots_airmax = 1;
			other.jumpboots_height = ART_JUMPHEIGHT;
			other.jumpboots_forward = 0;
			// Got to match original powerup on time
			other.jumpboots_finished = time + self.cnt;
			other.moditems = other.moditems | IT_ARTJUMPBOOTS;
			sprint (other, "You got the Jump Boots\n");
			stuffcmd (other, "bf\n");
			centerprint(other,"You also found the Jump Boots!\n");
			rnd_playsurprise(other, RND_SURPRISEPOS);
		}
	}
};

//=====================================================================
// All randomizer functions (minimal checks)
//----------------------------------------------------------------------
float() rnd_upgwpnmax_shadowaxe =
{
	local float ret_val;
	// Default Shadow Axe fragments (5=Easy, 9=Normal, 13=Hard+)
	if (skill == SKILL_EASY) ret_val = RND_FRAGAXE;
	else if (skill == SKILL_NORMAL) ret_val = RND_FRAGAXE+4;
	else ret_val = RND_FRAGAXE+8;
	// Make sure final amount is not negative or zero
	if (ret_val < 1) ret_val = 1;
	return ret_val;
};

//----------------------------------------------------------------------
float() rnd_upgwpnmax_widowmaker =
{
	local float ret_val;
	// Default WidowMaker fragments (3=Easy, 4=Normal, 5=Hard+)
	if (skill == SKILL_EASY) ret_val = RND_FRAGSHELL;
	else if (skill == SKILL_NORMAL) ret_val = RND_FRAGSHELL+1;
	else ret_val = RND_FRAGSHELL+2;
	// Make sure final amount is not negative or zero
	if (ret_val < 1) ret_val = 1;
	return ret_val;
};

//----------------------------------------------------------------------
float() rnd_upgwpnmax_plasmagun =
{
	local float ret_val;
	// Default PlasmaGun fragments (1=Easy, 2=Normal, 3=Hard+)
	if (skill == SKILL_EASY) ret_val = RND_FRAGCELL;
	else if (skill == SKILL_NORMAL) ret_val = RND_FRAGCELL+1;
	else ret_val = RND_FRAGCELL+2;
	// Make sure final amount is not negative or zero
	if (ret_val < 1) ret_val = 1;
	return ret_val;
};

//----------------------------------------------------------------------
void() rnd_displaydebug = 
{
	dprint("\bRnd\b "); 
	lftos(self,self.randomized,2,0,BUFFER_DPRINT);
	dprint(" \bU\b "); 
	lftos(self,self.randomupg,2,0,BUFFER_DPRINT);
	dprint(" \bP\b "); 
	lftos(self,self.randompoison,2,0,BUFFER_DPRINT);
	dprint(" \bIn\b "); 
	lftos(self,randomprev[self.randomindex], 2,0,BUFFER_DPRINT);
	dprint(" \bPo\b "); dprint(ftos(self.poisonous));
	if (self.health > 0) {
		dprint(" \bHP\b "); dprint(ftos(self.health));
	}
	dprint(" -"); dprint(self.randomclass);
	dprint(" ... ");
	if (self.classname == "item_shells" || self.classname == "item_cells" ||
		self.classname == "item_plasma") {
		dprint("box size (");
		if (self.spawnflags & A_LARGE) dprint("LARGE)");
		else dprint("SMALL)");
	}
	else dprint(self.classname);
	dprint("\n");
};

//----------------------------------------------------------------------
float(vector rndvec, float rndno) rnd_fetchrange =
{
	// Find out random number range 
	if (rndno < rndvec_x) return 1;
	else if (rndno < rndvec_y) return 2;
	else if (rndno < rndvec_z) return 3;
	else return 4;
};

//----------------------------------------------------------------------
// Make sure random number is within 1-99 range
// Cannot have a zero value, its used to test setup or not!
//----------------------------------------------------------------------
float(float rndno) rnd_validaterange = 
{
	local float ret_val;
	ret_val = floor(rndno);
	while (ret_val >= RND_RETMAX) { 
		ret_val = ret_val - RND_RETMAX;
	}
	if (ret_val < 1) ret_val = 1;
	return ret_val;
};

//----------------------------------------------------------------------
void(vector rndvec, float prevind) rnd_prevnumber =
{
	local float rndgroup;
	
	// Find out the new random number range 
	rndgroup = rnd_fetchrange(rndvec, self.randomized);
	// Check for range marker from last time
	if (randomprev[prevind] > RND_DUPOFFSET) 
		randomprev[prevind] = randomprev[prevind] - RND_DUPOFFSET;
	
	// Are the current and previous the same range?
	if (randomprev[prevind] == rndgroup) {
		// Reverse random number to get opposite result
		self.randomized = self.randomized + RND_MIDDLE;
		// Make sure number is withing 1-99 range
		self.randomized = rnd_validaterange(self.randomized);
		// Highlight range with marker (+90)
		rndgroup = RND_DUPOFFSET + rnd_fetchrange(rndvec, self.randomized);
	}
	// Save new group range for next time
	randomprev[prevind] = rndgroup;
};

//----------------------------------------------------------------------
void(float hpvalue) rnd_resethealth = {
	// Fix HP to prevent map unbalance! haha :P
	if (randomflags & RND_NORESETHP) return;
	else self.health = hpvalue;
};

//----------------------------------------------------------------------
void() rnd_resetspawnflags = {
	// Remove any specific spawnflags
	self.spawnflags = self.spawnflags - (self.spawnflags & 2);
	self.spawnflags = self.spawnflags - (self.spawnflags & 4);
};
void() rnd_resetzombieflags = {
	// Remove any specific spawnflags
	self.spawnflags = self.spawnflags - (self.spawnflags & 1);
	self.spawnflags = self.spawnflags - (self.spawnflags & 2);
	self.spawnflags = self.spawnflags - (self.spawnflags & 4);
};

//----------------------------------------------------------------------
void(float rndperc) rnd_addpoison =
{
	// Check for any exceptions
	if (randomflags & RND_NOPOISON) return;
	// Default percentage chance
	if (rndperc == 0) rndperc = RND_MIDDLE;
	// Check for poison?
	if (self.randompoison < rndperc) self.poisonous = TRUE;
};

//----------------------------------------------------------------------
// Blocking quickload
//----------------------------------------------------------------------
float() rnd_CheckNoQuickLoad =
{
	dprint("\b[RND_LOAD]\b Checking load exceptions!\n");
	// Is randomizer active in savegame data!?!
	if (check_customflags(savegamechaos) == FALSE) return FALSE;
	// Skill 4 only restricted
	if (skill < SKILL_EVIL) return FALSE;
	// Quickload exception on savegame data!?!
	if (!(savegamechaos & RND_NOQUICKLOAD)) return FALSE;
	// Evil should not live again!
	return TRUE;
};

//----------------------------------------------------------------------
// This function is about trying to detect savegame data and
// correct the current setup (scratch2/3 are not saved)
//----------------------------------------------------------------------
float() rnd_CheckSaveGameReboot =
{
	local float currentseed, cleanflags, cleansavegame;
	// No deathmatch support
	if (deathmatch > 0) return FALSE;

	// Read Chaos console variables
	randomflags = cvar("scratch3");
	currentseed = cvar("scratch2");

	// Remove all internal bitflags
	cleanflags = clean_randflags(randomflags);
	cleansavegame = clean_randflags(savegamechaos);
	
	// DEFAULT = system off or legacy savegame files
	if (cleanflags == 0 && cleansavegame == 0) {
		// Nothing to do, pass through functionality
		dprint("\b[RND_SYNC]\b Chaos Mode Disabled!\n");
		return FALSE;
	}
	// SAVEGAME requires Chaos system and CURRENT is wrong!
	else if (cleanflags == 0 && cleansavegame > 0) {
		// Highlight where Chaos mode enabled
		dprint("\b[RND_SYNC]\b Chaos Mode (");
		dprint(ftos(cleanflags)); dprint(") Save (");
		dprint(ftos(cleansavegame)); dprint(") Wrong!\n");
		// Savegame was using Chaos system
		// Reset current spawn setup and restart!
		cvar_set("scratch3", ftos(cleansavegame));
		cvar_set("scratch2", ftos(savegameseed));
		dprint("\b[RND_SYNC]\b Force Restart command!\n");
		// Do restart in PlayerPreThink function
		return TRUE;
	}
	// CURRENT setup is active and SAVEGAME is wrong!
	else if (cleanflags > 0 && cleansavegame == 0) {
		// Highlight where Chaos mode enabled
		dprint("\b[RND_SYNC]\b Chaos Mode (");
		dprint(ftos(cleanflags)); dprint(") Save (");
		dprint(ftos(cleansavegame)); dprint(") Wrong!\n");
		// Current spawn setup is using Chaos system
		// Make sure savegame is using the same values
		savegamechaos = cleanflags;
		savegameseed = currentseed;
		return FALSE;
	}
	else {
		// SAVEGAME and CURRENT setup are perfect match!
		dprint("\b[RND_SYNC]\b Chaos (");
		dprint(ftos(randomflags)); dprint(") Save (");
		dprint(ftos(savegamechaos)); dprint(")\n");
		dprint("\b[RND_SYNC]\b Seed (");
		dprint(ftos(currentseed)); dprint(") Save (");
		dprint(ftos(savegameseed)); 
		
		// Random seeds are perfect match!
		if (currentseed == savegameseed) {
			dprint(")\n");
			return FALSE;
		}
		else {
			dprint(") Wrong!\n");
			// This is a tricky situation ...
			// Is the CURRENT seed right or the SAVEGAME seed!
			// If SAVEGAME seed right, then restart required
			// Going with SAVEGAME is the priority!
			cvar_set("scratch2", ftos(savegameseed));
			dprint("\b[RND_SYNC]\b Force Restart command!\n");
			// Do restart in PlayerPreThink function
			return TRUE;
		}
	}
};

//----------------------------------------------------------------------
// Simplifed version of mathlib_bitshift
//----------------------------------------------------------------------
float (float number, float exp) simple_bitshift =
{
	local float digit, ret_val;
	
	digit = fabs(exp);
	ret_val = number;
	
	while (digit > 0) {
		if (ret_val <= 0) break;
		if (exp > 0) ret_val = floor(ret_val * 2);
		else ret_val = floor(ret_val / 2);
		digit = digit - 1;
	}
	return ret_val;
};

//----------------------------------------------------------------------
// Random number generator using a seed system
// Originally written by spike, I removed the foo!
//----------------------------------------------------------------------
vector(vector seedvec, float bitshift) magicshift = 
{
	// Shift Left (LOW) bits
	if (bitshift > 0) {
		while (bitshift --> 0) {
			seedvec_y = (seedvec_y*2)&0xfffe;
			//carry the high bit of the low word to the high word
			seedvec_y |= (seedvec_x/0x8000)&1;
			seedvec_x = (seedvec_x*2)&0xfffe;
		}
	}
	// Shift Right (HIGH) bits
	else {
		bitshift *= -1;
		while (bitshift --> 0) {
			seedvec_x = (seedvec_x/2)&0x7fff;
			//carry the lower bit of the high word to the low word
			seedvec_x |= (seedvec_y&1)*0x8000;
			seedvec_y = (seedvec_y/2)&0x7fff;
		}
	}
	return seedvec;
};

//----------------------------------------------------------------------
float(float seedstart) srandom =
{
	local float ret_val;
	local vector seedval;
	
	// Cannot have negative or zero seeds
	if (seedstart <= 0) seedstart = 1;
	// Check within maximum range
	if (seedstart > RND_RANGEMAX) seedstart = RND_RANGEMAX;
	// Convert random seed to two halves (16+8)
	seedval_x = seedstart & RND_LOWMASK;
	// Is there a top half to the original number
	if (seedstart < RND_16BIT) seedval_y = 0;
	// Shift bits downward (top 8 bits only)
	else seedval_y = simple_bitshift(seedstart, -16);
	
	// Setup bitshift magic numbers (default are 13, -17, 5)
	// Algorithm "xor" from p. 4 of Marsaglia, "Xorshift RNGs"
	if (magicseed_x <= 0) magicseed_x = RND_MAGICA;
	if (magicseed_y <= 0) magicseed_y = RND_MAGICB;
	if (magicseed_z <= 0) magicseed_z = RND_MAGICC;
	
	// Do three bitshifts (using magic numbers)
	seedval ^= magicshift(seedval, rint(magicseed_x));
	seedval ^= magicshift(seedval, rint(magicseed_y));
	seedval ^= magicshift(seedval, rint(magicseed_z));
	
	// Convert number down to 0-1 range (huge decimal point)
	ret_val = (seedval_y / RND_16BIT) + (seedval_x / (RND_16BIT*RND_16BIT));
	// Shift the bits upward to get better random number range
	// Only interested in 5/6 digit number, remove less than 0 part
	ret_val = floor(ret_val*100000);
	// Convert number to consistent range of 0-99
	ret_val = rnd_validaterange(ret_val);
	return ret_val;
};

//----------------------------------------------------------------------
// RESET original seed (mapload, ondeath, changelevel)
//----------------------------------------------------------------------
void(float entrypoint) rnd_ResetRandomSeed =
{
	// No deathmatch support
	if (deathmatch > 0) return;	
	// Randomizer flag (options)
	// Also updates randomflags variable
	if (check_randflags() == FALSE) return;
	
	// PRIORITY 1 = Manual Reset
	// settings.qc / reset_randomizer
	if (entrypoint & RND_ACTIVERESET) {
		// Force random seed to generate
		cvar_set("scratch2", "0");
		if (self.flags & FL_CLIENT)
			sprint (self, "\b[RND_RESET]\b Level Seed reset!\n");
		else dprint ("\b[RND_RESET]\b Level Seed reset!\n");
	}
	// PRIORITY 2 = Change level?
	// triggers.qc / trigger_changelevel_fire
	else if (entrypoint & RND_NORESETCHLVL) {
		// Check for ondeath exception?
		if (!(randomflags & RND_NORESETCHLVL)) {
			// Force random seed to generate
			cvar_set("scratch2", "0");
			dprint ("\b[RND_DEATH]\b Level Seed reset!\n");
		}
		else dprint ("\b[RND_CHGLVL]\b Level Seed not changed!\n");
	}
	// PRIORITY 3 = Player Death?
	// client.qc / ClientRespawn
	else if (entrypoint & RND_NORESETDEATH) {
		// Check for ondeath exception?
		if (!(randomflags & RND_NORESETDEATH)) {
			// Force random seed to generate
			cvar_set("scratch2", "0");
			dprint ("\b[RND_DEATH]\b Level Seed reset!\n");
		}
		else dprint ("\b[RND_DEATH]\b Level Seed not changed!\n");
	}
};
