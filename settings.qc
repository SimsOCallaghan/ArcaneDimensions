/*======================================================================
 MOD CUSTOM SETTINGS
======================================================================*/
void() toggleautoaim;		// Toggle auto aim
void() toggleprojsize;		// Toggle player projectile size
void() togglezaware;		// Toggle Z aware monsters
void() togglefootstep;		// Toggle footstep sound (player/monster)
void() toggleliquiddmg;		// Toggle Monster Liquid damage
void() toggleshotgunproj;	// Toggle Shotgun Projectiles
void() toggleshotguncase;	// Toggle Shotgun Casing
void() toggletrackmissile;	// Toggle tracking missiles on death
void() toggleupgradeaxe;	// Toggle Axe Upgrade (inventory only)
void() toggleupgradehook;	// Toggle Grapple Hook (inventory only)
void() toggleupgradessg;	// Toggle Shotgun Upgrade (inventory only)
void() toggleupgradelg;		// Toggle Lightning Upgrade (inventory only)
void() togglepixels;		// Toggle Texture modes

void() togglecoopartifacts;	// Toggle COOP can drop artifacts
void() togglecoopammoboxes;	// Toggle COOP ammo boxes to respawn
void() togglecoopweapons;	// Toggle COOP weapons to respawn
void() togglecoophealth;	// Toggle COOP health packs to respawn
void() togglecooppowerups;	// Toggle COOP powerups to respawn

void() toggleweather;		// Toggle weather systems
float() query_weathersystem;// Query weather system console vars
void(float hpshift) togglehpmax; // Toggle Health Max levels
void() toggledevhelpers;	// Toggle dev helpers (mark/arrows)
void() togglebodyremoval;	// Toggle monster body fade/removal
void() togglenotargetblock;	// Toggle notarget block on items
void() togglenomwheelskip;	// Toggle no mouse wheel skip

void() showbits_configflag;	// Display exact values of flag
void() display_configflag;	// Display config flag
void() display_playinfo;	// Display Player information
void() display_version;		// Display MOD information
void() display_mapvar;		// Display Map Variables
void() display_customkeys;	// Display Custom Key inventory
void() CycleThroughHuds;	// Cycle through different custom HUDS
void() CycleParticleDebug;	// Cycle particle debug messages

void(float sigil_bit) givesigil;	// Gives runes
void(float key_bit) givekey;		// Gives Silver/Gold key

void() CycleWeaponCommand;			// Mouse wheel stuff
void() CycleWeaponReverseCommand;	// Mouse wheel stuff
void() CheatCommand;				// Classic impulse 9

void() LavaShieldCheat;		// Can go for a swim in lava
void() AirTankCheat;		// Underwater breathing only
void() BlastBeltCheat;		// Splash/Direct damage reduction
void() JumpBootsCheat;		// Double/Triple/Quad jumping
void() SharpshooterCheat;	// Reduces shotgun spread patterns
void() NailPiercerCheat;	// Turns nail guns into gib machines
void() EnvSuitCheat;		// Water/Slime/Lava resistance
void() PentagramCheat;		// Takes no damage, loses armour!
void() InvisibleCheat;		// Can sneak around like notarget
void() QuadDamageCheat;		// 4 x damage modifier

void() StartIntermissionCamera;
float() impulse_playeronly;

// Advanced debug client info
void() display_secrets;		// Display a list of secret locations
void() display_secretlocs;	// Display secret locations
void() display_monsleft;	// Display a list of monsters left
void() display_monsqty;		// Display a table of monster type/qty
void() display_ammostats;	// Display a list of ammo stats

// Randomizer info and settings
void() display_randomizer;	// Display current random seed
void() display_randflags;	// Display current settings
void() display_randupgrade;	// Display weapon upgrades
void() reset_randomizer;	// Reset seed for randomizer

/*======================================================================
 Show MOD name and version
======================================================================*/
void() display_version =
{
	if (impulse_playeronly()) return;		// Player only
	
	self.impulse = 0;
	sprint(self,"\b[INFO]\b Arcane Dimensions V");
	lftos(self, mod_version, 1, 2, BUFFER_SPRINT);
	if (mod_patch > 0) {
		sprint(self, " Patch ");
		sprint(self, ftos(rint(mod_patch)));
	}
	if (mod_beta > 0) {
		sprint(self, " (Beta");
		sprint(self, ftos(rint(mod_beta)));
		sprint(self, ")");
	}
	sprint(self, " \n");
};

/*======================================================================
 Prints origin and mangle to console screen
 Useful for creating good locations for intermission camera's
 ** Been replaced with viewpos and setview console commands **
======================================================================*/
void() display_playinfo =
{
	if (impulse_playeronly()) return;		// Player only
	
	self.impulse = 0;
	sprint(self,"\b[INFO]\b Org ("); sprint(self,vtos(self.origin));
	sprint(self,") Ang ("); sprint(self,vtos(self.v_angle));
	sprint(self,")\n");
};


/*======================================================================
 Prints which custom keys the player has in their inventory
======================================================================*/
void() display_customkeys =
{
	local string ckey_str1, ckey_str2, ckey_str3, ckey_str4;
	local float ckey_count;
	
	if (impulse_playeronly()) return;		// Player only

	self.impulse = 0;	
	// Check for any custom keys in player inventory
	if (self.moditems & IT_CKEYALL) {
		// Always reset key count
		ckey_count = 0;
		
		if (self.moditems & IT_CKEY1) {
			ckey_str1 = self.ckeyname1;
			ckey_count = ckey_count + 1;
		}
		if (self.moditems & IT_CKEY2) {
			if (ckey_count == 1) ckey_str2 = self.ckeyname2;
			else ckey_str1 = self.ckeyname2;
			ckey_count = ckey_count + 1;
		}
		if (self.moditems & IT_CKEY3) {
			if (ckey_count == 2) ckey_str3 = self.ckeyname3;
			else if (ckey_count == 1) ckey_str2 = self.ckeyname3;
			else ckey_str1 = self.ckeyname3;
			ckey_count = ckey_count + 1;
		}
		if (self.moditems & IT_CKEY4) {
			if (ckey_count == 3) ckey_str4 = self.ckeyname4;
			else if (ckey_count == 2) ckey_str3 = self.ckeyname4;
			else if (ckey_count == 1) ckey_str2 = self.ckeyname4;
			else ckey_str1 = self.ckeyname4;
			ckey_count = ckey_count + 1;
		}
		
		// if 4 keys are present, then squash the last two key names together
		// The maximum amount of strings that centerprint can handle is 7
		// A bit of shame, because only needed one more string!
		if (ckey_count == 4)
			centerprint7 (self, "-[ \bArcane Key Inventory\b ]-\nYou have the following\n\n", ckey_str1, "\n", ckey_str2, "\n", ckey_str3, ckey_str4);
		else
			// Space out title and keys (does not print key 4)
			centerprint7 (self, "-[ \bArcane Key Inventory\b ]-\nYou have the following\n\n", ckey_str1, "\n", ckey_str2, "\n", ckey_str3, "\n");
	}
	else 
		// Should always say the state of the inventory
		centerprint(self, "-[ \bArcane Key Inventory\b ]-\n\nIs Empty!\n"); 
};

/*======================================================================
 Cycle through all custom HUDs using scratch1 cvar
======================================================================*/
void() CycleThroughHuds =
{
	local float hudact;
	if (impulse_playeronly()) return;		// Player only
	// Is the CSQC functionality enabled/disabled?
	// This entity key is updated (on client) by CSQC when active
	// spike has broken this check in qss dev builds :(
	if (self.ext_csqc == FALSE) {
		sprint(self, "[IMPULSE] Custom HUDS not supported!\n");
		return;
	}
	// Have the HUDs been disabled on purpose?
	if (cvar("cl_nocsqc") == 1 || cvar("scratch1") < 0) {
		sprint(self, "[IMPULSE] Custom HUDS are disabled!\n");
		return;
	}
	// Reset input buffer
	self.impulse = 0;	
	// Read current custom hud
	hudact = cvar("scratch1");
	// Move forward 1 hud and check range
	hudact = hudact + 1;
	if (hudact > 9) hudact = 0;
	cvar_set("scratch1", ftos(hudact));
	// Let the player know what hud is active
	if (hudact == 1) centerprint(self, "1 = Inventory Around middle\n");
	else if (hudact == 2) centerprint(self, "2 = Inventory on Screen Sides\n");
	else if (hudact == 3) centerprint(self, "3 = Blank\n");
	else if (hudact == 4) centerprint(self, "4 = Classic Doom Inspired!\n");
	else if (hudact == 5) centerprint(self, "5 = Quake Champions Inspired!\n");
	else if (hudact == 6) centerprint(self, "6 = Extra Wide Single Bar\n");
	else if (hudact == 7) centerprint(self, "7 = Clustered Around Crosshair\n");
	else if (hudact == 8) centerprint(self, "8 = Blank\n");
	else if (hudact == 9) centerprint(self, "9 = Blank\n");
	else centerprint(self, "0 = Classic Quake HUD!\n");
};

/*======================================================================
 Standard error reporting
======================================================================*/
float() impulse_playeronly =
{
	if (!(self.flags & FL_CLIENT)) {
		// Message goes to console, no client available!
		dprint("[Impulse ");
		dprint(ftos(self.impulse));
		dprint("] only works for \bThe Player!\b\n");
		return TRUE;
	}
	else return FALSE;
};

//----------------------------------------------------------------------
float() impulse_devonlymode =
{
	if (developer == FALSE) {
		sprint(self, "[Impulse ");
		sprint(self, ftos(self.impulse));
		sprint(self, "] only works in \bDeveloper\b mode!\n");
		return TRUE;
	}
	else return FALSE;
};

//----------------------------------------------------------------------
void() impulse_notvalid =
{
	if (!(self.flags & FL_CLIENT)) return;
	if (self.impulse > 0) {
		sprint(self, "[Impulse ");
		sprint(self, ftos(self.impulse));
		sprint(self, "] does not work at the moment!\n");
		self.impulse = 0;
	}
};

//----------------------------------------------------------------------
float() impulse_activecameras =
{
	// no console feedback
	if (intermission_running > 0) {
		sprint(self, "[Impulse ");
		sprint(self, ftos(self.impulse));
		sprint(self, "] cannot work, \bIntermission\b active!\n");
		return TRUE;
	}
	else if (cinematic_running > 0) {
		sprint(self, "[Impulse ");
		sprint(self, ftos(self.impulse));
		sprint(self, "] cannot work, \bCinematic\b active!\n");
		return TRUE;
	}
	else return FALSE;
};

//----------------------------------------------------------------------
float() impulse_dmcoopmode =
{
	if (deathmatch > 0 || coop > 0) {
		sprint(self, "[Impulse ");
		sprint(self, ftos(self.impulse));
		sprint(self, "] does not work in \bDM\b or \bCoop\b mode!\n");
		return TRUE;
	}
	else return FALSE;
};

//----------------------------------------------------------------------
float() impulse_cooponlymode =
{
	if (coop == FALSE) {
		sprint(self, "[Impulse ");
		sprint(self, ftos(self.impulse));
		sprint(self, "] only works in \bCoop\b mode!\n");
		return TRUE;
	}
	else return FALSE;
};

//----------------------------------------------------------------------
float() impulse_skill03only =
{
	if (skill < 0 || skill > SKILL_NIGHTMARE) {
		sprint(self, "[Impulse ");
		sprint(self, ftos(self.impulse));
		sprint(self, "] skill lvl out of range!\n");
		return TRUE;
	}
	else return FALSE;
};

/*======================================================================
 ImpulseCommands
======================================================================*/
void() ImpulseCommands =
{
	if (self.impulse >= 1 && self.impulse <= 8) W_ChangeWeapon (self);
	else if (self.impulse == 10) CycleWeaponCommand();
	else if (self.impulse == 12) CycleWeaponReverseCommand();

	// Only these MOD options can be changed via the console
	else if (self.impulse == 100) toggleautoaim();		// Toggle auto aim
	else if (self.impulse == 105) toggleprojsize();		// Toggle player proj size
	else if (self.impulse == 110) togglezaware();		// Toggle Z aware monsters
	else if (self.impulse == 115) togglepixels();		// Toggle texture modes
	else if (self.impulse == 120) togglefootstep();		// Toggle footstep sound
	else if (self.impulse == 125) toggleliquiddmg();	// Toggle liquid damage
	else if (self.impulse == 130) toggleshotgunproj();	// Toggle SG Projectile
	else if (self.impulse == 135) toggleshotguncase();	// Toggle SG Casing
	else if (self.impulse == 137) toggletrackmissile();	// Toggle tracking missiles on death
	else if (self.impulse == 140) display_version();	// Display MOD config flag
	else if (self.impulse == 142) display_playinfo();	// Display Player information
	else if (self.impulse == 145) StartIntermissionCamera();

	else if (self.impulse == 150) togglecoopartifacts();// Toggle COOP can drop artifacts
	else if (self.impulse == 152) togglecoopweapons();	// Toggle COOP weapons to respawn
	else if (self.impulse == 154) togglecoophealth();	// Toggle COOP health to respawn
	else if (self.impulse == 156) togglecoopammoboxes();// Toggle COOP ammo boxes to respawn
	else if (self.impulse == 158) togglecooppowerups();	// Toggle COOP powerups to respawn

	else if (self.impulse == 160) toggleweather();		// Toggle Weather Systems
	else if (self.impulse == 162) togglehpmax(0.25);	// Toggle HP Max 0.25/0.5/0.75/1.0
	else if (self.impulse == 164) togglehpmax(0.50);	// Toggle HP Max between 0.5/1.0
	else if (self.impulse == 166) togglenotargetblock();// Toggle notarget block on items
	else if (self.impulse == 168) togglenomwheelskip(); // Toggle no mouse wheel skip
	else if (self.impulse == 170) togglebodyremoval();	// Toggle monster body fade/removal
	else if (self.impulse == 175) display_customkeys();	// Display Custom Key inventory
	else if (self.impulse == 178) CycleThroughHuds();	// Cycle through different custom HUDS

	else if (self.impulse == 180) display_secrets();	// Display a list of secret locations
	else if (self.impulse == 182) display_secretlocs();	// Display secret locations
	else if (self.impulse == 184) display_monsleft();	// Display a list of monsters left
	else if (self.impulse == 185) display_monsqty();	// Display a table of monster type/qty
	else if (self.impulse == 186) display_ammostats();	// Display a list of Ammo Stats

	else if (self.impulse == 190) display_randomizer();	// Display current random seed
	else if (self.impulse == 192) display_randflags();	// Display current settings
	else if (self.impulse == 194) display_randupgrade();// Display weapon upgrades
	else if (self.impulse == 196) reset_randomizer();	// Reset seed for Chaos system
	
	// Only works developer only)
	else if (self.impulse == 200) toggleupgradeaxe();	// Toggle Axe Upgrade
	else if (self.impulse == 202) toggleupgradehook();	// Toggle GrappleHook Upgrade
	else if (self.impulse == 205) toggleupgradessg();	// Toggle Shotgun Upgrade
	else if (self.impulse == 210) toggleupgradelg();	// Toggle Lightning Upgrade
	else if (self.impulse == 220) display_configflag();	// Display MOD config flag
	else if (self.impulse == 222) showbits_configflag();// Show exact values of flag
	else if (self.impulse == 225) display_mapvar();		// Display all map variables
	else if (self.impulse == 230) toggledevhelpers();	// Toggle Dev Helpers (mark/arrow)
	else if (self.impulse == 235) CycleParticleDebug();	// Cycle particle debug

	else if (self.impulse == 240) givesigil(SVR_RUNE_ALL);	// Give all sigils to player
	else if (self.impulse == 241) givesigil(SVR_RUNE_KEY1);	// Give various sigil to player
	else if (self.impulse == 242) givesigil(SVR_RUNE_KEY2);	// Will be reset on map load
	else if (self.impulse == 243) givesigil(SVR_RUNE_KEY3);	// Mainly used for testing
	else if (self.impulse == 244) givesigil(SVR_RUNE_KEY4);

	else if (self.impulse == 245) givekey(IT_KEY1 + IT_KEY2);	// Both

	// The classic all weapons+ammo cheat (should be developer=1)
	else if (self.impulse == 9) CheatCommand();
	// All artifact cheat commands
	else if (self.impulse == 246) LavaShieldCheat();
	else if (self.impulse == 247) AirTankCheat();
	else if (self.impulse == 248) BlastBeltCheat();
	else if (self.impulse == 249) JumpBootsCheat();
	else if (self.impulse == 250) SharpshooterCheat();
	else if (self.impulse == 251) NailPiercerCheat();
	else if (self.impulse == 252) EnvSuitCheat();
	else if (self.impulse == 253) PentagramCheat();
	else if (self.impulse == 254) InvisibleCheat();
	else if (self.impulse == 255) QuadDamageCheat();

	self.impulse = 0;
};

/*======================================================================
 The MOD can be customizied from three different source:
 quake.rc < worldspawn < impulse commands (top priority)
 
 The serverflags is the ONLY variable that is passed between MAP loads
 and that variable is not available straightaway! Once the worldspawn
 is loaded (first thing to happen) the serverflags is still empty
 and the functions have to cope with it 'out of sync' until later.
 
 after worldspawn is loaded, the combination of the quake.rc (TEMP1)
 is merged with the keys on worldspawn and all spawning functions
 use the configflags until it can be sync'd with serverflags.
 
 The configflags is setup to be temporary so that any previous value
 from a quickload does not interfere with it.
 
======================================================================*/
// Assume that serverflags not setup yet, merge worldspawn with configflag
// Once serverflags available, then sync everything together
void(float regbitflag, float worldvalue) update_worldspawn =
{
	// Is the bit value TRUE?
	if (worldvalue > 0) configflag = configflag | regbitflag;
	// Only take about a bit value from configflag if bit value is present
	else if (worldvalue < 0) {
		if (configflag & regbitflag) configflag = configflag - regbitflag;
	}
};

//----------------------------------------------------------------------
// The worldspawn key values always override the quake.rc values and
// should be merged with the console variable when loading a map
// serverflags is not available before spawn functions
void() sycn_worldspawn =
{
	// Check console variables defined in quake.rc file
	if (cvar("saved1") > 0) update_worldspawn(SVR_SPRPARTON, TRUE);
	if (cvar("saved2") > 0) update_worldspawn(SVR_FOOTSTEP, TRUE);
	if (cvar("saved3") > 0) update_worldspawn(SVR_SHOTGCASE, TRUE);
	if (cvar("saved4") > 0) update_worldspawn(SVR_SHOTGPROJ, TRUE);
	if (cvar("scratch4") > 0) cvar_set("skill", ftos(SKILL_EVIL));
	
	// Check for worldspawn settings
	update_worldspawn(SVR_ITEMOFFSET, self.no_item_offset);
	update_worldspawn(SVR_UPDAXE, self.upgrade_axe);
	update_worldspawn(SVR_UPDGHOOK, self.upgrade_ghook);
	update_worldspawn(SVR_UPDSSG, self.upgrade_ssg);
	update_worldspawn(SVR_UPDLG, self.upgrade_lg);
	update_worldspawn(SVR_ZAWARE, self.no_zaware);
	update_worldspawn(SVR_LIQDAM, self.no_liquiddmg);
};

//----------------------------------------------------------------------
// Reset the serverflag to console + worldspawn settings
// This only needs to be done when loading a new map or changelevel
// quickload cannot run this function it will damage inventory
void() sync_serverflags =
{
	local float checkflag;
	
	if (serverflags & SVR_LIVE) {
		dprint("\b[SERVERFLAG]\b MAP LOAD reset/sync\n");
		// Take 1-8 runes, 9-16 worldspawn merge, 17-23 mod/console options
		checkflag = (serverflags & SVR_RUNEFLAG) + (temp1flag & SVR_WORLDFLAG) + (configflag & SVR_HIGHFLAG);
		// Update the serverflags ready for future updates
		serverflags =  configflag = checkflag;	
	}
};

//----------------------------------------------------------------------
// Update configflag and if the serverflags is active, update that as well!
void(float regbitflag, float regbitvalue) update_configflag =
{
	// Is the bit value TRUE?
	if (regbitvalue == TRUE) {
		configflag = configflag | regbitflag;
		if (serverflags & SVR_LIVE) serverflags = serverflags | regbitflag;
	}
	// If the bit value FALSE
	else {
		configflag = configflag - (configflag & regbitflag);
		if (serverflags & SVR_LIVE) {
			serverflags = serverflags - (serverflags & regbitflag);
		}
	}
		
	// Only the top 8 bits of TEMP1 flag can be updated
	// Some options should not be changed easily, causes problems
	if (regbitflag & SVR_HIGHFLAG) {
		// Re-fresh the console variable 
		dprint("\b[TEMP1]\b Changing ("); dprint(ftos(regbitflag));
		dprint(")\n");
		temp1flag = cvar("temp1");
		if (regbitvalue > 0) temp1flag = temp1flag | regbitflag;
		else temp1flag = temp1flag - (temp1flag & regbitflag);
		// Write any changes to the console variable (TEMP1)
		cvar_set("temp1", ftos(temp1flag));
	}		
};

//----------------------------------------------------------------------
float(float regbitflag) query_configflag =
{
	// Return bitflag value so multiple bits can be tested together
	return (configflag & regbitflag);
};

//----------------------------------------------------------------------
float(float regbitflag) query_temp1flag =
{
	// Return bitflag value so multiple bits can be tested together
	return (temp1flag & regbitflag);
};

//----------------------------------------------------------------------
void() showbits_configflag =
{
	local float loopcnt, bitcnt;
	
	dprint("\n\b[CONFIG]\b Configflag (");
	dprint(ftos(configflag)); dprint(")\n");
	dprint("--------------------------------------\n");
	dprint("\bBitflag V Description\b\n");
	//        4194304 x x-------------------x 
	loopcnt = 0;
	while (loopcnt < 23) {
		if (loopcnt == 0) bitcnt = 1;
		else bitcnt = mathlib_powbit(loopcnt,2);
		lftos(self, bitcnt, 7, 0, BUFFER_DPRINT);
		if (configflag & bitcnt) dprint(" 1 ");
		else dprint(" 0 ");
		if (loopcnt == 0) dprint("Rune 1\n");
		else if (loopcnt == 1) dprint("Rune 2\n");
		else if (loopcnt == 2) dprint("Rune 3\n");
		else if (loopcnt == 3) dprint("Rune 4\n");
		else if (loopcnt == 4) dprint("Spawn bit 1\n");
		else if (loopcnt == 5) dprint("Spawn bit 2\n");
		else if (loopcnt == 6) dprint("Spawn bit 3\n");
		else if (loopcnt == 7) dprint("Serverflag has active data\n\n");
		else if (loopcnt == 8) dprint("Ammo/HP item are offset\n");
		else if (loopcnt == 9) dprint("Always use sprite particles\n");
		else if (loopcnt == 10) dprint("Turn ON particle system\n");
		else if (loopcnt == 11) dprint("Turn OFF Dev helpers\n\n");
		else if (loopcnt == 12) dprint("Shadow Axe\n");
		else if (loopcnt == 13) dprint("Widowmaker\n");
		else if (loopcnt == 14) dprint("Plasma Gun\n");
		else if (loopcnt == 15) dprint("Grapple Hook\n\n");
		else if (loopcnt == 16) dprint("--\n");
		else if (loopcnt == 17) dprint("Shotgun projectiles\n");
		else if (loopcnt == 18) dprint("Shotgun casings\n");
		else if (loopcnt == 19) dprint("Z aware monsters\n");
		else if (loopcnt == 20) dprint("Enemy/player footsteps\n");
		else if (loopcnt == 21) dprint("MWheel NG/SNG Skip\n");
		else if (loopcnt == 22) dprint("Monster Liquid damage\n");
		else if (loopcnt == 23) dprint("--\n");
		loopcnt = loopcnt + 1;
	}
	dprint("-----------------------------------\n");
};

//----------------------------------------------------------------------
// Once global variables are available (client/server is setup)
// Sync the serverflag with the configflag
//----------------------------------------------------------------------
void() sync_configflag =
{
	local float checkflag;
	
	// At this point the live data is all over the place and needs to be merged
	// The serverflag can contain (rune keys and console options) if quickload
	// and the configflag contains default + worldspawn keys
	if (serverflags & SVR_LIVE) {
		dprint("\b[SERVERFLAG]\b LIVE data detected\n");
		// Take 1-16 runes & spawn options, 17-23 mod/console options
		checkflag = (serverflags & SVR_LOWFLAG) + (configflag & SVR_HIGHFLAG);

		// Make sure all flags are in sync with each other
		configflag = serverflags = checkflag | SVR_LIVE;
	}
	else {
		dprint("\b[SERVERFLAG]\b new game detected\n");
		// Update the serverflags ready for future updates
		serverflags =  configflag | SVR_LIVE;	
	}
};

//----------------------------------------------------------------------
void() display_configflag =
{
	// No warning message, called from client.qc
	if (developer == FALSE) return;

	dprint("\n\b[CONFIG]\b MOD Settings ("); 
	if (configflag & SVR_LIVE) dprint(ftos(configflag-SVR_LIVE));
	else dprint(ftos(configflag));
	if (configflag & SVR_LIVE) dprint(") L\n");
	else dprint(")\n");
	dprint("--------------------------------------\n");

	// Particle system
	if (query_configflag(SVR_PARTICLES)) dprint("+ Particle System enabled\n");
	else dprint("- Particle System disabled\n");
	if (query_configflag(SVR_SPRPARTON) || world.sprite_particles == TRUE) 
		dprint("* Sprite/Dot particles ONLY\n");
	if (query_weathersystem() == TRUE) dprint("+ Weather System enabled\n");
	else dprint("- Weather System disabled\n");
	
	// Advanced engines active?
	if (ext_active) {
		// Check for CSQC disabled console variable?
		if (cvar("cl_nocsqc") == 1) dprint("- Client Server QC HUD disabled\n");
		else if (self.ext_csqc > 0) dprint("+ Client Server QC HUD enabled\n");
	}
	// Default = CSQC not supported
	else dprint("* Server side engine HUD active\n");

	// Check for scratch1-4 variables
	if (cvar("scratch1") > 0) {
		dprint("+ Scratch1 CSQC Hud ("); 
		dprint(ftos(cvar("scratch1")));
		dprint(") active\n");
	}
	if (cvar("scratch2") > 0) {
		dprint("+ Scratch2 Seed (");
		dprint(ftos(cvar("scratch2")));
		dprint(") active\n");
	}
	if (cvar("scratch3") > 0) {
		dprint("+ Scratch3 Chaos mode (");
		dprint(ftos(cvar("scratch3")));
		dprint(") active\n");
	}
	if (cvar("scratch4") > 0) dprint("+ Scratch4 Skill 4 (EVIL) enabled\n");
	if (cvar("saved1") > 0) dprint("- Saved1 Sprite Particles enabled\n");
	if (cvar("saved2") > 0) dprint("- Saved2 Enemy/player footsteps off\n");
	if (cvar("saved3") > 0) dprint("- Saved3 Shotgun casings disabled\n");
	if (cvar("saved4") > 0) dprint("- Saved4 Shotgun Projectiles disabled\n");
	
	// All new MOD weapons
	if (world.upgrade_axe < 0) dprint("W Axe Upg Removed on Worldspawn\n");
	else if (world.upgrade_axe > 0) dprint("W Axe Upg Added on Worldspawn\n");
	else if (query_temp1flag(SVR_UPDAXE)) dprint("* Axe Upgrade in quake.rc\n");
	else if (query_configflag(SVR_UPDAXE)) dprint("+ Axe Upgrade from inventory\n");
	else dprint("- NO Axe upgrade detected\n");

	if (world.upgrade_ghook < 0) dprint("W GHook Removed on Worldspawn\n");
	else if (world.upgrade_ghook > 0) dprint("W GHook Added on Worldspawn\n");
	else dprint("- NO Grapple Hook detected\n");

	if (world.upgrade_ssg < 0) dprint("W SSG Upg Removed on Worldspawn\n");
	else if (world.upgrade_ssg > 0) dprint("W SSG Upg Added on Worldspawn\n");
	else if (query_temp1flag(SVR_UPDSSG)) dprint("* SSG Upgrade in quake.rc\n");
	else if (query_configflag(SVR_UPDSSG)) dprint("+ SSG Upgrade from inventory\n");
	else dprint("- NO SSG upgrade detected\n");

	if (world.upgrade_lg < 0) dprint("W LG Upg Removed on Worldspawn\n");
	else if (world.upgrade_lg > 0) dprint("W LG Upg Added on Worldspawn\n");
	else if (query_temp1flag(SVR_UPDLG)) dprint("* LG Upgrade in quake.rc\n");
	else if (query_configflag(SVR_UPDLG)) dprint("+ LG Upgrade from inventory\n");
	else dprint("- NO LG upgrade detected\n");

	// New Shotgun bullet projectile/casing system
	if (world.no_sgprojectile > 0) dprint("W SG Projs Disabled on worldspawn\n");
	else if (query_configflag(SVR_SHOTGPROJ)) dprint("- Shotgun hitscan system\n");
	else dprint("+ Shotgun projectiles system\n");
	if (world.no_sgcasing > 0) dprint("W SG Casing Disabled on worldspawn\n");
	else if (query_configflag(SVR_SHOTGCASE)) dprint("- Shotgun casing disabled\n");
	else dprint("+ Shotgun casing enabled\n");
	if (playerprojsize == 0) dprint("+ Large Projectile Collision\n");
	else dprint("- Small Projectile Collision\n");
	if (!CheckZeroVector(world.plasmagun_dmg)) {
		dprint("+ Plasma gun damage ("); dprint(ftos(rint(map_plasmagundmg_x)));
		dprint(" "); dprint(ftos(rint(map_plasmagundmg_y)));
		dprint(" "); dprint(ftos(rint(map_plasmagundmg_z)));
		dprint(")\n");
	}
	if (!CheckZeroVector(world.player_health)) {
		dprint("+ Player Max HP ("); dprint(ftos(rint(world.player_health_x)));
		dprint(" "); dprint(ftos(rint(world.player_health_y)));
		dprint(") Skill ("); dprint(ftos(rint(world.player_health_z)));
		dprint(")\n");
	}
	if (!CheckZeroVector(world.bleeding_dmg)) {
		dprint("+ Bleeding %/HoT/Pause ("); 
		lftos(self, world.bleeding_dmg_x, 1, 2, BUFFER_DPRINT);
		dprint(" "); dprint(ftos(world.bleeding_dmg_y));
		dprint(" "); dprint(ftos(world.bleeding_dmg_z));
		dprint(")\n");
	}

	// Items updates; origin points and random rotation
	if (query_configflag(SVR_ITEMOFFSET)) dprint("+ All items use center origin\n");
	else dprint("- All items use corner origin\n");
	dprint("+ All items are randomly rotated\n");

	// General MOD settings
	if (autoaim_cvar >= 1) dprint("+ Player weapon autoaim disabled\n");
	else dprint("- Player weapon autoaim enabled\n");
	if (query_configflag(SVR_ZAWARE)) dprint("- Z Aware Monster combat disabled\n");
	else dprint("+ Z Aware Monster combat enabled\n");
	if (query_configflag(SVR_FOOTSTEP)) dprint("- footstep sounds disabled\n");
	else dprint("+ footstep sounds enabled\n");
	if (query_configflag(SVR_LIQDAM)) dprint("- monster liquid damage disabled\n");
	else dprint("+ monster liquid damage enabled\n");
	if (query_configflag(SVR_DEVHELPER)) dprint("- Dev helpers (mark/arrow) disabled\n");
	else dprint("+ Dev helpers (mark/arrow) enabled\n");
	if (query_configflag(SVR_MWHEELSKIP)) dprint("- MWheel ng/sng skip disabled\n");
	else dprint("+ MWheel ng/sng skip enabled\n");
	
	// Body fade/floor checks
	if (map_bodyfadeaway > 0) dprint("+ Monster dead body fade away\n");
	else dprint("- No fade away for monster bodies\n");
	if (map_bodyflrcheck > 0) dprint("+ Monster dead body check floor\n");
	else dprint("- No floor checks for monster bodies\n");

	// All monster passive state mode
	if (map_passivestate > 0) dprint("+ All monsters start in passive mode\n");

	// Arcane Key Inventory suppressed
	if (world.ckeyhint == TRUE) dprint("- Arcane Key Inventory Msg disabled\n");
	else dprint("+ Arcane Key Inventory Msg enabled\n");
	
	// Show Homing Missile on death system
	if (map_notrackondeath == TRUE) dprint("+ No missile tracking on death\n");
	else dprint("- Missile tracking uses default\n");

	// Show Hazard damage if defaults been changed
	if (!CheckZeroVector(world.hazard_dmg)) {
		dprint("+ Hazard dmg Wa ("); dprint(ftos(map_hazarddmg_x));
		dprint(") Sl ("); dprint(ftos(map_hazarddmg_y));
		dprint(") La ("); dprint(ftos(map_hazarddmg_z));
		dprint(")\n");
	}
	
	// Player jump height changes
	if (map_jumpheight != DEF_JUMPHEIGHT) {
		dprint("+ Player jump height (");
		dprint(ftos(map_jumpheight)); dprint(")\n");
	}

	// Player fall damage modifiers
	if (world.fall_speedlow) {
		dprint("+ Player Fall Speed Low ("); 
		dprint(ftos(map_fallspeedlow)); dprint(")\n");
	}
	if (world.fall_speedhigh) {
		dprint("+ Player Fall Speed High ("); 
		dprint(ftos(map_fallspeedhigh)); dprint(")\n");
	}
	if (world.fall_dmg) {
		dprint("+ Player Fall Damage ("); 
		dprint(ftos(map_falldmg)); dprint(")\n");
	}
	if (world.fall_dmgwater) {
		dprint("+ Player Fall Water Damage ("); 
		dprint(ftos(map_falldmgwater)); dprint(")\n");
	}
	
	// Visual settings - fog / wateralpha / gravity
	// AD 1.8 removed SVR_NOFOGCMDS (winquake idea)
	if (fog_active && fog_control) {
		dprint("+ Gfog ("); 
		lftos(self, fog_control.fog_currden, 2,3, BUFFER_DPRINT); dprint(")(");
		lftos(self, fog_control.fog_currcol_x, 1,3, BUFFER_DPRINT); dprint(" ");
		lftos(self, fog_control.fog_currcol_y, 1,3, BUFFER_DPRINT); dprint(" ");
		lftos(self, fog_control.fog_currcol_z, 1,3, BUFFER_DPRINT); dprint(")\n");
	}
	else dprint("* Global fog default not defined\n");
	
	if (skyfog_active && skyfog_control) {
		dprint("+ Skyfog density changed ("); 
		lftos(self, skyfog_control.skyfog_currden, 1,3, BUFFER_DPRINT); 
		dprint(")\n");
	}
	else dprint("* Sky fog default not defined\n");
	
	if (liquid_alpha != 1) { 
		dprint("+ Water Alpha has changed ("); 
		lftos(self, liquid_alpha, 0,3, BUFFER_DPRINT); dprint(")\n");
	}
	if (map_gravity != DEF_GRAVITY) { 
		dprint("+ Map gravity has changed ("); 
		dprint(ftos(map_gravity)); dprint(")\n");
	}

	// Always show compiler lightstyle boundary start point
	dprint("+ Lightstyle compiler lights at ("); 
	dprint(ftos(mapstyle_start)); dprint(")\n");
	
	// DP compatible visual settings
	if (engine == ENG_DPEXT) {
		dprint("+ DP features ( ");
		// Show all active features
		if (ext_dpfog) dprint("FOG ");
		if (ext_dpsurf) dprint("SURF ");
		if (ext_dprain) dprint("RAIN ");
		if (ext_dpsnow) dprint("SNOW ");
		dprint(")\n");
	}
	// FTE only features
	if (engine == ENG_DPEXT && ext_fteskin) {
		dprint("+ FTE features ( ");
		// Show all active features
		if (ext_fteskin) dprint("SKIN/LADDER ");
		dprint(")\n");
	}

	// Show the coop respawn options
	if (coop > 0) {
		if (coop_weapons == FALSE) dprint("+ COOP weapons respawn TRUE\n");
		else dprint("- COOP weapons respawn FALSE\n");
		if (coop_ammoboxes == FALSE) dprint("- COOP ammo boxes respawn FALSE\n");
		else dprint("+ COOP ammo boxes respawn TRUE\n");
		if (coop_health == FALSE) dprint("- COOP health packs respawn FALSE\n");
		else dprint("+ COOP health packs respawn TRUE\n");
		if (coop_powerups == FALSE) dprint("- COOP powerups respawn FALSE\n");
		else dprint("+ COOP powerups respawn TRUE\n");
	}
	
	dprint("--------------------------------------\n");
};

/*======================================================================
 Give the player various sigils (serverflag)
 Give the player silver/gold keys
======================================================================*/
void(float sigil_bit) givesigil =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only

	dprint("\b[SIGIL]\b Server updated ("); 
	dprint(ftos(sigil_bit)); dprint(")\n");
	if (sigil_bit & SVR_RUNE_KEY1) update_configflag(SVR_RUNE_KEY1,TRUE);
	if (sigil_bit & SVR_RUNE_KEY2) update_configflag(SVR_RUNE_KEY2,TRUE);
	if (sigil_bit & SVR_RUNE_KEY3) update_configflag(SVR_RUNE_KEY3,TRUE);
	if (sigil_bit & SVR_RUNE_KEY4) update_configflag(SVR_RUNE_KEY4,TRUE);
};

//----------------------------------------------------------------------
void(float key_bit) givekey =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only

	dprint("\b[KEYS]\b Inventory updated ("); 
	dprint(ftos(key_bit)); dprint(")\n");
	if (key_bit & IT_KEY1) self.items = self.items | IT_KEY1;
	if (key_bit & IT_KEY2) self.items = self.items | IT_KEY2;
};

/*======================================================================
 TOGGLE MOD features
======================================================================*/
void() toggleautoaim =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	
	self.impulse = 0;	
	// Toggle the state of the console variable
	if (autoaim_cvar >= 1) autoaim_cvar = 0.93;
	else autoaim_cvar = 1;
	cvar_set("sv_aim", ftos(autoaim_cvar));
	
	sprint(self, "\b[Impulse]\b Auto aim state ("); 
	if (autoaim_cvar < 1) sprint(self, "ON)\n");
	else sprint(self, "OFF)\n");
};

//----------------------------------------------------------------------
void() toggleprojsize = 
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	
	self.impulse = 0;	
	// Toggle the state of the global variable
	if (playerprojsize == 1) playerprojsize = 0;
	else playerprojsize = 1;
	
	sprint(self, "\b[Impulse]\b Player proj size ("); 
	if (playerprojsize == 1) sprint(self, "SMALL)\n");
	else sprint(self, "LARGE)\n");
};

//----------------------------------------------------------------------
void() togglezaware =
{	
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	
	self.impulse = 0;	
	// Toggle the state of the console variable using the server flag
	if (query_configflag(SVR_ZAWARE)) update_configflag(SVR_ZAWARE, FALSE);
	else update_configflag(SVR_ZAWARE, TRUE);

	sprint(self, "\b[Impulse]\b Z Aware Monsters ("); 
	if (query_configflag(SVR_ZAWARE)) sprint(self, "Disabled)\n");
	else sprint(self, "Enabled)\n");
};

//----------------------------------------------------------------------
void() togglepixels =
{	
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	
	self.impulse = 0;	
	sprint(self, "\b[SETTINGS]\b texture filtering ("); 
	if (pixelmode == TRUE) {
		pixelmode = FALSE;
		stuffcmd(self, "\ngl_texturemode GL_LINEAR_MIPMAP_LINEAR\n");
		sprint(self, "blurry)\n");
	}
	else {
		pixelmode = TRUE;
		stuffcmd(self, "\ngl_texturemode GL_NEAREST_MIPMAP_LINEAR\n");
		sprint(self, "crispy)\n");
	}
};

//----------------------------------------------------------------------
void() togglefootstep =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	
	self.impulse = 0;
	// Toggle the state of the console variable using the server flag
	if (query_configflag(SVR_FOOTSTEP)) update_configflag(SVR_FOOTSTEP, FALSE);
	else update_configflag(SVR_FOOTSTEP, TRUE);
	
	sprint(self, "\b[Impulse]\b footsteps ("); 
	if (query_configflag(SVR_FOOTSTEP)) sprint(self, "OFF)\n");
	else sprint(self, "ON)\n");
};

//----------------------------------------------------------------------
void() toggleliquiddmg =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	
	self.impulse = 0;
	// Toggle the state of the console variable using the server flag
	if (query_configflag(SVR_LIQDAM)) update_configflag(SVR_LIQDAM, FALSE);
	else update_configflag(SVR_LIQDAM, TRUE);
	
	sprint(self, "\b[Impulse]\b Monster Liquid Damage ("); 
	if (query_configflag(SVR_LIQDAM)) sprint(self, "OFF)\n");
	else sprint(self, "ON)\n");
};

//----------------------------------------------------------------------
void() toggleshotgunproj =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	
	self.impulse = 0;
	// Toggle the state of the console variable using the server flag
	if (query_configflag(SVR_SHOTGPROJ)) update_configflag(SVR_SHOTGPROJ, FALSE);
	else update_configflag(SVR_SHOTGPROJ, TRUE);
	
	sprint(self, "\b[Impulse]\b Shotgun Projectiles ("); 
	if (query_configflag(SVR_SHOTGPROJ)) sprint(self, "OFF)\n");
	else sprint(self, "ON)\n");
};

//----------------------------------------------------------------------
void() toggleshotguncase =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	
	self.impulse = 0;
	// Toggle the state of the console variable using the server flag
	if (query_configflag(SVR_SHOTGCASE)) update_configflag(SVR_SHOTGCASE, FALSE);
	else update_configflag(SVR_SHOTGCASE, TRUE);
	
	sprint(self, "\b[Impulse]\b Shotgun Casing ("); 
	if (query_configflag(SVR_SHOTGCASE)) sprint(self, "OFF)\n");
	else sprint(self, "ON)\n");
};

//----------------------------------------------------------------------
void() togglenomwheelskip =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only

	self.impulse = 0;
	// Toggle the state of the console variable using the server flag
	if (query_configflag(SVR_MWHEELSKIP)) update_configflag(SVR_MWHEELSKIP, FALSE);
	else update_configflag(SVR_MWHEELSKIP, TRUE);
	
	sprint(self, "\b[Impulse]\b Mouse Wheel NG/SNG skip ("); 
	if (query_configflag(SVR_MWHEELSKIP)) sprint(self, "OFF)\n");
	else sprint(self, "ON)\n");
};

//----------------------------------------------------------------------
void() toggletrackmissile = 
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	
	self.impulse = 0;
	// Toggle the state of the console variable using the server flag
	if (map_notrackondeath == TRUE) map_notrackondeath = FALSE;
	else map_notrackondeath = TRUE;
	
	sprint(self, "\b[Impulse]\b Tracking Missiles ("); 
	if (map_notrackondeath == FALSE) sprint(self, "OFF)\n");
	else sprint(self, "ON)\n");
};

//----------------------------------------------------------------------
void() togglecoopartifacts =
{	
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_cooponlymode()) return;		// Coop only
	
	self.impulse = 0;
	sprint(self, "\b[SETTINGS]\b COOP Drop Artifacts ("); 
	if (coop_artifacts == TRUE) {
		coop_artifacts = FALSE;
		sprint(self, "OFF)\n");
	}
	else {
		coop_artifacts = TRUE;
		sprint(self, "ON)\n");
	}
};

//----------------------------------------------------------------------
void() togglecoopweapons =
{	
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_cooponlymode()) return;		// Coop only
	
	self.impulse = 0;
	sprint(self, "\b[SETTINGS]\b COOP Weapons Respawn ("); 
	if (coop_weapons == TRUE) {
		coop_weapons = FALSE;
		sprint(self, "ON)\n");
	}
	else {
		coop_weapons = TRUE;
		sprint(self, "OFF)\n");
	}
};

//----------------------------------------------------------------------
void() togglecoopammoboxes =
{	
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_cooponlymode()) return;		// Coop only
	
	self.impulse = 0;
	sprint(self, "\b[SETTINGS]\b COOP Ammo Boxes Respawn ("); 
	if (coop_ammoboxes == TRUE) {
		coop_ammoboxes = FALSE;
		sprint(self, "OFF)\n");
	}
	else {
		coop_ammoboxes = TRUE;
		sprint(self, "ON)\n");
	}
};

//----------------------------------------------------------------------
void() togglecoophealth =
{	
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_cooponlymode()) return;		// Coop only
	
	self.impulse = 0;
	sprint(self, "\b[SETTINGS]\b COOP Health Packs Respawn ("); 
	if (coop_health == TRUE) {
		coop_health = FALSE;
		sprint(self, "OFF)\n");
	}
	else {
		coop_health = TRUE;
		sprint(self, "ON)\n");
	}
};

//----------------------------------------------------------------------
void() togglecooppowerups =
{	
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_cooponlymode()) return;		// Coop only
	
	self.impulse = 0;
	sprint(self, "\b[SETTINGS]\b COOP Powerups Respawn ("); 
	if (coop_powerups == TRUE) {
		coop_powerups = FALSE;
		sprint(self, "OFF)\n");
	}
	else {
		coop_powerups = TRUE;
		sprint(self, "ON)\n");
	}
};

//----------------------------------------------------------------------
float() query_weathersystem =
{
	// No advanced engine active
	if (!ext_active) return FALSE;
	// No rain/show particle extensions
	if (!ext_dprain || !ext_dpsnow) return FALSE;
	// Finally check weather sys variable (unreliable)
	return weathersys;
};

//----------------------------------------------------------------------
void() toggleweather =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only

	// Enhanced engines enabled?
	if (!ext_active) {
		sprint(self,"\b[Impulse]\b Engine does not support weather.\n");
		return;
	}
	// Rain / Snow particle extensions active?
	if (!ext_dprain || !ext_dpsnow) {
		sprint(self,"\b[Impulse]\b Weather particles not available.\n");
		return;
	}
	
	self.impulse = 0;
	// This flag can get out of sync with engine because there is no way
	// to query the engine if the weather particles are enabled/disabled
	// Just have to assume they are active by default!
	if (weathersys == TRUE) weathersys = FALSE;
	else weathersys = TRUE;

	sprint(self, "\b[Impulse]\b Particle weather system ("); 
	if (weathersys == FALSE) sprint(self, "OFF)\n");
	else sprint(self, "ON)\n");
	
	// FTE/QSS only supports one console command for weather
	// Engine does not remember setting and resets it
	if (checkextension("FTE_SV_POINTPARTICLES"))
		if (weathersys == TRUE) stuffcmd(self, "\nr_part_rain 1\n");
		else stuffcmd(self, "\nr_part_rain 0\n");
	else {
		// DP engine remembers rain/snow weather settings
		// DP has separate commands for weather types
		if (weathersys == TRUE) {
			// Weather enabled
			stuffcmd(self, "\ncl_particles_rain 1\n");
			stuffcmd(self, "\ncl_particles_snow 1\n");
		}
		else {
			// Weather disabled
			stuffcmd(self, "\ncl_particles_rain 0\n");
			stuffcmd(self, "\ncl_particles_snow 0\n");
		}
	}	
};

//----------------------------------------------------------------------
void() togglebodyremoval =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only

	self.impulse = 0;
	// Toggle body removal/fade system timer
	// default = time + 10 + random() * 5
	if (map_bodyfadeaway > 0) map_bodyfadeaway = 0;
	else map_bodyfadeaway = 5;
	
	sprint(self, "\b[Impulse]\b Monster body removal ("); 
	if (map_bodyfadeaway > 0) sprint(self, "ON)\n");
	else sprint(self, "OFF)\n");
};

//----------------------------------------------------------------------
void() togglenotargetblock =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only

	self.impulse = 0;
	// Toggle notarget block on items
	map_notargetblock =  1 - map_notargetblock;
	
	sprint(self, "\b[Impulse]\b notarget item block ("); 
	if (map_notargetblock > 0) sprint(self, "OFF)\n");
	else sprint(self, "ON)\n");
};

//----------------------------------------------------------------------
void() display_randomizer =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only

	self.impulse = 0;
	// All error checks and messages done in function
	displaycenter_randomseed();
};

//----------------------------------------------------------------------
void() display_randflags =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only

	self.impulse = 0;
	// All error checks and messages done in function
	displaydebug_randflags();
};

//----------------------------------------------------------------------
void() display_randupgrade =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only

	self.impulse = 0;
	// All error checks and messages done in function
	displaydebug_weaponupgrades();
};

//----------------------------------------------------------------------
void() reset_randomizer =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only

	self.impulse = 0;
	// All error checks and messages done in function
	rnd_ResetRandomSeed(RND_ACTIVERESET);
};

/*======================================================================
 Require DEVELOPER mode to be active
======================================================================*/
//----------------------------------------------------------------------
void(float hpshift) togglehpmax =
{
	local entity playent;
	
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only
	if (impulse_skill03only()) return;		// skill 0-3 only
	
	self.impulse = 0;
	
	// Setup default
	if (self.tog_health <= 0) self.tog_health = 1;

	// Update visuals
	sprint(self, "\b[Impulse]\b Max HP/Mega ("); 
	sprint(self, ftos(HEAL_PLAYMAX * self.tog_health));
	// Update toggle health values + check for errors
	self.tog_health = self.tog_health - hpshift;
	if (self.tog_health <= 0) self.tog_health = 1;
	// Update visuals
	sprint(self, ") - ("); 
	sprint(self, ftos(HEAL_PLAYMAX * self.tog_health));
	sprint(self, ")\n");
	
	// Find first client
	playent = find(world, classname, "player");
	while (playent) {
		playent.tog_health = self.tog_health;
		// Have to work from default constants
		playent.max_health = HEAL_PLAYMAX * playent.tog_health;
		playent.mega_health = HEAL_MEGAMAX * playent.tog_health;
		// Double check max is not negative or zero
		if (playent.max_health <= 0) playent.max_health = HEAL_PLAYMAX;
		if (playent.mega_health <= 0) playent.mega_health = HEAL_MEGAMAX;
		// Cap health with new/current maximum
		if (playent.health > playent.max_health) {
			// Tiny damage to trigger client animation/sound
			T_Damage(playent, world, world, 1, NOARMOR);
			playent.health = playent.max_health;	
		}			
		// Find more (coop) player/clients
		playent = find(playent, classname, "player");
	}	
};

//----------------------------------------------------------------------
void() toggleupgradeaxe =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only
	if (impulse_skill03only()) return;		// skill 0-3 only
	
	self.impulse = 0;
	if (self.moditems & IT_UPGRADE_AXE) {
		dprint("\b[Impulse]\b Shadow Axe Removed\n"); 
		self.moditems = self.moditems - IT_UPGRADE_AXE;
		update_configflag(SVR_UPDAXE, FALSE);
	}
	else {
		// Cannot have Shadow Axe AND Grapple Hook
		if (self.moditems & IT_UPGRADE_GHOOK) {
			dprint ("\b[Impulse]\b Removing Grapple Hook!\n");
			self.moditems = self.moditems - (self.moditems & IT_UPGRADE_GHOOK);
			update_configflag(SVR_UPDGHOOK, FALSE);
		}
		dprint("\b[Impulse]\b Shadow Axe Added\n"); 
		self.moditems = self.moditems | IT_UPGRADE_AXE;
		update_configflag(SVR_UPDAXE, TRUE);
		// Switch to new weapon
		self.weapon = IT_AXE;
	}
		
	if (self.weapon == IT_AXE) W_SetCurrentAmmo(self);
};

// Forward compiler reference
void() GrappleHook_Setup;
void() GrappleHook_Display;
//----------------------------------------------------------------------
void() toggleupgradehook =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only
	if (impulse_skill03only()) return;		// skill 0-3 only
	
	self.impulse = 0;
	// Does the hook entity exist?
	if (!self.hookent) GrappleHook_Setup();
	
	// Have grapple hook already?
	if (self.moditems & IT_UPGRADE_GHOOK) {
		if (self.gh_hookstyle == GNC_HOOKLINE) {
			self.gh_hookstyle = GNC_HOOKBOOST;
			dprint("\b[Impulse]\b BOOST Grapple Hook Style\n"); 
		}
		// Trick version not implemented, cycle around instead
		/*else if (self.gh_hookstyle == GNC_HOOKBOOST) {
			self.gh_hookstyle = GNC_HOOKTRICK;
			dprint("\b[Impulse]\b TRICK Grapple Hook Style\n"); 
		} */
		else {
			dprint("\b[Impulse]\b Grapple Hook Removed!\n"); 
			self.moditems = self.moditems - IT_UPGRADE_GHOOK;
			update_configflag(SVR_UPDGHOOK, FALSE);
		}
	}
	else {
		// Cannot have Shadow Axe AND Grapple Hook
		if (self.moditems & IT_UPGRADE_AXE) {
			dprint("\b[Impulse]\b Removing Shadow Axe!\n");
			self.moditems = self.moditems - (self.moditems & IT_UPGRADE_AXE);
			update_configflag(SVR_UPDAXE, FALSE);
		}
		dprint("\b[Impulse]\b LINE Grapple Hook Added\n"); 
		self.moditems = self.moditems | IT_UPGRADE_GHOOK;
		self.gh_hookstyle = GNC_HOOKLINE;
		update_configflag(SVR_UPDGHOOK, TRUE);
		// Switch to new weapon
		self.weapon = IT_AXE;
	}
		
	// Display Hook stats and update v_model
	GrappleHook_Display();
	W_SetCurrentAmmo(self);
};

//----------------------------------------------------------------------
void() toggleupgradessg =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only
	if (impulse_skill03only()) return;		// skill 0-3 only
	
	self.impulse = 0;
	if (self.moditems & IT_UPGRADE_SSG) {
		dprint("\b[Impulse]\b Widowmaker Shotgun Removed\n"); 
		self.moditems = self.moditems - IT_UPGRADE_SSG;
	}
	else {
		dprint("\b[Impulse]\b Widowmaker Shotgun Added\n"); 
		self.moditems = self.moditems | IT_UPGRADE_SSG;
		// Switch to new weapon
		self.weapon = IT_SUPER_SHOTGUN;
	}
		
	// make sure player VIEW model is up to date
	W_SetCurrentAmmo(self);
};

//----------------------------------------------------------------------
void() toggleupgradelg =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only
	if (impulse_skill03only()) return;		// skill 0-3 only
	
	self.impulse = 0;
	if (self.moditems & IT_UPGRADE_LG) {
		dprint("\b[Impulse]\b Plasma Gun Removed\n"); 
		self.moditems = self.moditems - IT_UPGRADE_LG;
	}
	else {
		dprint("\b[Impulse]\b Plasma Gun Added\n"); 
		self.moditems = self.moditems | IT_UPGRADE_LG;
		// Switch to new weapon
		self.weapon = IT_LIGHTNING;
	}
		
	// make sure player VIEW model is up to date
	W_SetCurrentAmmo(self);
};

//----------------------------------------------------------------------
void() toggledevhelpers =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only

	self.impulse = 0;

	// Toggle the state of the console variable using the server flag
	if (query_configflag(SVR_DEVHELPER)) update_configflag(SVR_DEVHELPER, FALSE);
	else update_configflag(SVR_DEVHELPER, TRUE);
	
	sprint(self, "\b[Impulse]\b Dev Helpers are ("); 
	if (query_configflag(SVR_DEVHELPER)) sprint(self, "OFF)\n");
	else sprint(self, "ON)\n");
};

//----------------------------------------------------------------------
void() CycleParticleDebug =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only
	
	self.impulse = 0;
	
	part_debug = part_debug + 1;
	if (part_debug > PARTICLE_DEBUGMAX) part_debug = 0;

	sprint(self, "\b[Impulse]\b Particle debug level (");
	sprint(self, ftos(part_debug));
	sprint(self, ")\n");
};


/*======================================================================
 IMPULSE 9
 Gives the player certain weapons and ammo (CHEAT COMMAND)
======================================================================*/
void() CheatCommand =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_dmcoopmode()) return;		// No Dm/Coop mode
	if (impulse_skill03only()) return;		// skill 0-3 only
	
	// Should be a dev only command, but everyone knows about it!	
	dprint("\b[Impulse 9]\b Weapon Cheat Command\n");
	dprint("- Use Impulse 245 to get silver/gold keys!\n");
	self.impulse = 0;
	self.ammo_rockets = 75;
	self.ammo_nails = 150;
	self.ammo_shells = 150;
	self.ammo_cells = 150;
	self.items = self.items | IT_AXE | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN |
				IT_SUPER_NAILGUN | IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER | IT_LIGHTNING;
	self.items = self.items | IT_ARMOR1;
	self.weapon = IT_LIGHTNING;
	W_SetCurrentAmmo (self);
};

/*======================================================================
 Artifact IMPULSE commands
======================================================================*/
void() AirTankCheat =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only
	if (impulse_dmcoopmode()) return;		// No Dm/Coop mode
	if (impulse_skill03only()) return;		// skill 0-3 only

	self.impulse = 0;
	dprint("\b[Impulse 247]\b Air Tank Cheat\n");
	self.airtank_time = 1;
	self.airtank_finished = POWERUP_VANIA;	// Infinite
	self.moditems = self.moditems | IT_ARTAIRTANK;
};

//----------------------------------------------------------------------
void() LavaShieldCheat =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only
	if (impulse_dmcoopmode()) return;		// No Dm/Coop mode
	if (impulse_skill03only()) return;		// skill 0-3 only

	self.impulse = 0;
	dprint("\b[Impulse 246]\b Lava Shield Cheat\n");
	self.lavashield_time = 1;
	self.lavashield_finished = POWERUP_VANIA;	// Infinite
	self.moditems = self.moditems | IT_ARTLAVASHIELD;
};

//----------------------------------------------------------------------
void() BlastBeltCheat =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only
	if (impulse_dmcoopmode()) return;		// No Dm/Coop mode
	if (impulse_skill03only()) return;		// skill 0-3 only

	self.impulse = 0;
	dprint("\b[Impulse 248]\b Blast Belt Cheat\n");
	self.blastbelt_time = 1;
	self.blastbelt_finished = POWERUP_VANIA;	// Infinite
	self.moditems = self.moditems | IT_ARTBLASTBELT;
};

//----------------------------------------------------------------------
void() JumpBootsCheat =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only
	if (impulse_dmcoopmode()) return;		// No Dm/Coop mode
	if (impulse_skill03only()) return;		// skill 0-3 only

	self.impulse = 0;
	dprint("\b[Impulse 249]\b Endless Jump Boots Cheat\n");
	self.jumpboots_time = 1;
	self.jumpboots_airmax = -1;			// Endless jumping
	self.jumpboots_height = ART_JUMPHEIGHT;
	self.jumpboots_forward = 0;
	self.jumpboots_finished = POWERUP_VANIA;	// Infinite
	self.moditems = self.moditems | IT_ARTJUMPBOOTS;
};

//----------------------------------------------------------------------
void() SharpshooterCheat =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only
	if (impulse_dmcoopmode()) return;		// No Dm/Coop mode
	if (impulse_skill03only()) return;		// skill 0-3 only

	self.impulse = 0;
	dprint("\b[Impulse 250]\b Sharp Shooter Cheat\n");
	self.sharpshoot_time = 1;
	self.sharpshoot_finished = time + POWERUP_TIMER;
	self.items = self.items | IT_QUAD;
	self.moditems = self.moditems | IT_ARTSHARP;
};

//----------------------------------------------------------------------
void() NailPiercerCheat =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only
	if (impulse_dmcoopmode()) return;		// No Dm/Coop mode
	if (impulse_skill03only()) return;		// skill 0-3 only

	self.impulse = 0;
	dprint("\b[Impulse 251]\b Nail Piercer Cheat\n");
	self.nailpiercer_time = 1;
	self.nailpiercer_finished = time + POWERUP_TIMER;
	self.items = self.items | IT_QUAD;
	self.moditems = self.moditems | IT_ARTPIERCE;
};

//----------------------------------------------------------------------
void() EnvSuitCheat =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only
	if (impulse_dmcoopmode()) return;		// No Dm/Coop mode
	if (impulse_skill03only()) return;		// skill 0-3 only

	self.impulse = 0;
	dprint("\b[Impulse 252]\b Environmental Suit Cheat\n");
	self.rad_time = 1;
	self.radsuit_finished = time + POWERUP_TIMER;
	self.items = self.items | IT_SUIT;
};

//----------------------------------------------------------------------
void() PentagramCheat =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only
	if (impulse_dmcoopmode()) return;		// No Dm/Coop mode
	if (impulse_skill03only()) return;		// skill 0-3 only

	self.impulse = 0;
	dprint("\b[Impulse 253]\b Pentagram of Protection Cheat\n");
	self.invincible_time = 1;
	self.invincible_finished = time + POWERUP_TIMER;
	self.items = self.items | IT_INVULNERABILITY;
};

//----------------------------------------------------------------------
void() InvisibleCheat =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only
	if (impulse_dmcoopmode()) return;		// No Dm/Coop mode
	if (impulse_skill03only()) return;		// skill 0-3 only

	self.impulse = 0;
	dprint("\b[Impulse 254]\b Ring of Shadows Cheat\n");
	self.invisible_time = 1;
	self.invisible_finished = time + POWERUP_TIMER;
	self.items = self.items | IT_INVISIBILITY;
};

//----------------------------------------------------------------------
void() QuadDamageCheat =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (impulse_devonlymode()) return;		// Dev mode only
	if (impulse_dmcoopmode()) return;		// No Dm/Coop mode
	if (impulse_skill03only()) return;		// skill 0-3 only
	
	self.impulse = 0;
	dprint("\b[Impulse 255]\b Quad Damage Cheat\n");
	self.super_time = 1;
	self.super_damage_finished = time + POWERUP_TIMER;
	self.items = self.items | IT_QUAD;
};
