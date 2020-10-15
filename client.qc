/*======================================================================
 CLIENT FUNCTIONS
======================================================================*/
// Vanilla Quake Inventory reset combined flag
// IT_SUPERHEALTH, IT_KEY1, IT_KEY2 
// IT_INVISIBILITY, IT_INVULNERABILITY, IT_SUIT, IT_QUAD
float IT_ITEMRESET = 8323072;		// 65536++
float IT_MODRESET = 8380416;		// 8192++
float ALL_WEAPONS = 255;
float NO_WEAPONS = 4351;			// 1-128 + 4096

// client_camera.qc
void() SetupIntermissionCamera;
void() CycleIntermissionCamera;

// client_debuff.qc AND client_power.qc
void() ClientDeBuff;
void() ClientPowerups;
void(entity targ, float powtimer, float novania) ResetPowerSystem;
void(entity targ) ResetDebuffSystem;

// client_advinfo.qc
void() CheckSecretCamera;

// player.qc
void(entity inflictor, entity attacker, float damage) player_pain;
void() player_death;
void() player_stand1;

// triggers.qc
void() trigger_changelevel_finish;
void() trigger_cdtrack_change;
void(entity targ) trigger_skybox_change;

// misc_camera.qc
float(float cam_angle1, float cam_angle2) camera_check_anglezero;
float(float baxis_start, float baxis_control, float baxis_end, float baxis_time) bezier_axis;
vector(vector bez_start, vector bez_control, vector bez_end, float bez_timemax, float bez_timeleft) bezier_curve;
void() misc_camera_filewrite;

/*======================================================================
 USED : Load (map command) NEW MAP or NEW GAME
 * This is a function called via the engine for new games
 * Resets all parm data back to default values, followed by Decode
 * Cannot use any self keys in this functions, its called by engine
   BEFORE any client setup or insertion into the map!
======================================================================*/
void() SetNewParms =
{
	dprint("\b[CLIENT]\b SetNewParms\n");

	// Brand new game/map, reset start position settings
	update_configflag(SVR_SPAWN_BIT1, FALSE);
	update_configflag(SVR_SPAWN_BIT2, FALSE);
	update_configflag(SVR_SPAWN_BIT3, FALSE);
	fog_active = FALSE;
	skyfog_active = FALSE;
	
	parm1 = IT_SHOTGUN | IT_AXE;	// Default ID weapon start
	// Check for Evil NM+ skill level (Lower HP max)
	if (Client_QueryEvilmode()) parm2 = HEAL_EVILMAX;
	else parm2 = HEAL_PLAYMAX;		// Starting Health (def=100)
	parm3 = 0;  parm9 = 0;			// Armourtype and value
	parm4 = 25;	parm5 = 0;			// Ammo qty (shell/nail/rocket/cells)
	parm6 = 0;	parm7 = 0;
	parm8 = IT_SHOTGUN;				// Current selected weapon (shotgun)
	parm10 = 0;						// AD MOD items
	
	// Update new player inventory based on config flag (quake.rc file)
	if (query_configflag(SVR_UPDAXE)) {
		parm1 = parm1 | IT_AXE;
		parm10 = parm10 | IT_UPGRADE_AXE;
		// Shadow axe and grapple do not exist together
		parm10 = parm10 - (parm10 & IT_UPGRADE_GHOOK);
		parm8 = IT_AXE;
	}
	if (query_configflag(SVR_UPDGHOOK)) {
		parm1 = parm1 | IT_AXE;
		parm10 = parm10 | IT_UPGRADE_GHOOK;
		// Shadow axe and grapple do not exist together
		parm10 = parm10 - (parm10 & IT_UPGRADE_AXE);
		parm8 = IT_AXE;
	}
	if (query_configflag(SVR_UPDSSG)) {
		parm1 = parm1 | IT_SUPER_SHOTGUN;
		parm10 = parm10 | IT_UPGRADE_SSG;
		parm8 = IT_SUPER_SHOTGUN;
	}
	if (query_configflag(SVR_UPDLG)) {
		parm1 = parm1 | IT_LIGHTNING;
		parm10 = parm10 | IT_UPGRADE_LG;
		parm8 = IT_LIGHTNING;
	}
	
	// Skill 4 always starts with Shadow Axe!
	if (Client_QueryEvilmode()) { 
		parm1 = parm1 | IT_AXE;
		parm10 = parm10 | IT_UPGRADE_AXE;
		// Shadow axe and grapple do not exist together
		parm10 = parm10 - (parm10 & IT_UPGRADE_GHOOK);
		parm8 = IT_AXE;
	}
	// If a map wants NO axe start, then its likely been designed for it!
	// World entity is readable at this point. The No Axe start is also a
	// NO WEAPONS at all !?! (including any from previous map)
	else if (world.no_axestart == TRUE) { 
		parm1 = parm8 = 0;
	}
	
	// Are map variables live?
	if (mapvar_cvar) dprint("\b[CLIENT]\b LIVE Map Variables Detected\n");
	else {
		dprint("\b[CLIENT]\b RESETTING Map Variables\n");
		// Reset map variables ready for use
		parm11 = parm12 = parm13 = parm14 = parm15 = parm16 = 0;
		mapvar_reset();
	}
};

/*======================================================================
// USED : trigger CHANGE LEVEL
// Stores a copy of the parm data ready for death/level reset
======================================================================*/
void() SetChangeParms =
{
	dprint("\n\b[CLIENT]\b SetChangeParms\n");
	// If player dead, do not update level parameters
	if (self.health < 1) { SetNewParms (); return;	}

	// remove temporary items (keys and powerups)
	self.items = self.items - (self.items & IT_ITEMRESET);
	parm1 = self.items;
	self.moditems = self.moditems - (self.moditems & IT_MODRESET);
	parm10 = self.moditems;
	dprint("\b[CLIENT]\b MOD weapons ("); dprint(ftos(parm10)); dprint(")\n");
	
	// Make sure player HP is within Max range and not less 50%
	Client_CheckMaxHP(self, TRUE);
	// Save HP max
	parm2 = self.health;

	parm3 = self.armorvalue;
	parm9 = self.armortype * 100;

	// Always make sure the player has 25 shells
	if (self.ammo_shells < DEF_SHELLS) parm4 = DEF_SHELLS;
	else parm4 = self.ammo_shells;
	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;

	if (self.items & NO_WEAPONS) parm8 = 0;
	else parm8 = self.weapon;
	
	dprint("\b[CLIENT]\b SAVING Map Variables\n");
	// Save map variables (22 bits per parm, 132 total)
	parm11 = mapvar[0]; parm12 = mapvar[1]; parm13 = mapvar[2];
	parm14 = mapvar[3]; parm15 = mapvar[4]; parm16 = mapvar[5];
};

/*======================================================================
 USED : Load NEW MAP or trigger CHANGE LEVEL
 Not used when loading a saved file or quickload
======================================================================*/
void() DecodeWorldParms =
{
	local float parm_items;
	parm_items = parm1;

	dprint("\b[CLIENT]\b Decode Worldspawn Inv Parms\n");
	//----------------------------------------------------------------------
	// Show developer feedback on player inventory update
	// no axe start is no weapons at all !?!
	if (world.no_axestart) dprint("\b[CLIENT]\b No Axe start detected\n");
	if (world.give_weapons) {
		dprint("\b[CLIENT]\b Weapon Give ( ");
		if (world.give_weapons & IT_SHOTGUN) dprint("SG ");
		if (world.give_weapons & IT_SUPER_SHOTGUN) dprint("SSG ");
		if (world.give_weapons & IT_NAILGUN) dprint("NG ");
		if (world.give_weapons & IT_SUPER_NAILGUN) dprint("SNG ");
		if (world.give_weapons & IT_GRENADE_LAUNCHER) dprint("GL ");
		if (world.give_weapons & IT_ROCKET_LAUNCHER) dprint("RL ");
		if (world.give_weapons & IT_LIGHTNING) dprint("LG ");
		dprint(")\n");
	}
	if (world.take_weapons) {
		dprint("\b[CLIENT]\b Weapon Take ( ");
		if (world.take_weapons & IT_SHOTGUN) dprint("SG ");
		if (world.take_weapons & IT_SUPER_SHOTGUN) dprint("SSG ");
		if (world.take_weapons & IT_NAILGUN) dprint("NG ");
		if (world.take_weapons & IT_SUPER_NAILGUN) dprint("SNG ");
		if (world.take_weapons & IT_GRENADE_LAUNCHER) dprint("GL ");
		if (world.take_weapons & IT_ROCKET_LAUNCHER) dprint("RL ");
		if (world.take_weapons & IT_LIGHTNING) dprint("LG ");
		dprint(")\n");
	}
	
	//----------------------------------------------------------------------
	// Check for no axe/weapons start
	// Skill 4 always starts with Shadow Axe!
	if (world.no_axestart == TRUE && Client_QueryEvilmode() == FALSE) {
		// Remove all weapons, a no axe start is nothing!
		parm_items = parm_items - (parm_items & NO_WEAPONS);
		// Remove all AD upgrades
		parm10 = parm10 - (parm10 & IT_UPGRADE_AXE);
		parm10 = parm10 - (parm10 & IT_UPGRADE_SSG);
		parm10 = parm10 - (parm10 & IT_UPGRADE_LG);
		parm10 = parm10 - (parm10 & IT_UPGRADE_GHOOK);
	}
	else {
		//----------------------------------------------------------------------
		// Adding weapons to existing inventory
		if (world.give_weapons) {
			parm_items = parm_items | (world.give_weapons & ALL_WEAPONS);		
		}
		//----------------------------------------------------------------------
		// Player always has the axe, it cannot be removed!
		if (world.take_weapons > 0) {
			if (world.take_weapons & IT_SHOTGUN && parm_items & IT_SHOTGUN) 
				parm_items = parm_items - IT_SHOTGUN; 
			if (world.take_weapons & IT_SUPER_SHOTGUN && parm_items & IT_SUPER_SHOTGUN) {
				parm_items = parm_items - IT_SUPER_SHOTGUN;
				// Player cannot have upgrades without base item
				parm10 = parm10 - (parm10 & IT_UPGRADE_SSG);
			}
			if (world.take_weapons & IT_NAILGUN && parm_items & IT_NAILGUN) 
				parm_items = parm_items - IT_NAILGUN; 
			if (world.take_weapons & IT_SUPER_NAILGUN && parm_items & IT_SUPER_NAILGUN) 
				parm_items = parm_items - IT_SUPER_NAILGUN; 
			if (world.take_weapons & IT_GRENADE_LAUNCHER && parm_items & IT_GRENADE_LAUNCHER) 
				parm_items = parm_items - IT_GRENADE_LAUNCHER; 
			if (world.take_weapons & IT_ROCKET_LAUNCHER && parm_items & IT_ROCKET_LAUNCHER) 
				parm_items = parm_items - IT_ROCKET_LAUNCHER; 
			if (world.take_weapons & IT_LIGHTNING && parm_items & IT_LIGHTNING) {
				parm_items = parm_items - IT_LIGHTNING; 
				// Player cannot have upgrades without base item
				parm10 = parm10 - (parm10 & IT_UPGRADE_LG);
			}
		}
	}
	
	// Store result back to global variable
	parm1 = parm_items;
	
	// Check for Evil NM+ skill? (No changes allowed)
	if (Client_QueryEvilmode() == FALSE) {
		//----------------------------------------------------------------------
		// Update player health (RESET / MINimum value)
		if (world.reset_health > 0 && world.reset_health <= HEAL_PLAYMAX) {
			dprint("\b[CLIENT]\b Reset Health ("); dprint(ftos(parm2)); dprint(") To (");
			parm2 = world.reset_health;
			dprint(ftos(parm2)); dprint(")\n");	
		}
		else if (world.max_health > 0 && parm2 < world.max_health) {
			dprint("\b[CLIENT]\b Min Health ("); dprint(ftos(parm2)); dprint(") To (");
			if (parm2 < world.max_health) parm2 = world.max_health;
			dprint(ftos(parm2)); dprint(")\n");	
		}
		// Make sure RESET / MIN health does not exceed MAX health
		if (parm2 > self.max_health && self.max_health > 0) {
			dprint("\b[CLIENT]\b Max Health ("); dprint(ftos(parm2)); dprint(") To (");
			parm2 = self.max_health;
			dprint(ftos(parm2)); dprint(")\n");	
		}
	}
	
	//----------------------------------------------------------------------
	// Update the inventory ammo quantities
	// currentammo = 1 to reset the inventory to worldspawn values
	// currentammo = 0 to use the worldspawn values as a minimum quantity
	if (world.ammo_shells || (world.currentammo && parm4 > 0)) {
		dprint("\b[CLIENT]\b Ammo Shells ("); dprint(ftos(parm4)); dprint(") To (");
		if (world.currentammo) parm4 = world.ammo_shells;
		else if (parm4 < world.ammo_shells) parm4 = world.ammo_shells;
		if (parm4 > AMMO_MAXSHELLS) parm4 = AMMO_MAXSHELLS;
		else if (parm4 < 0) parm4 = 0;
		dprint(ftos(parm4)); dprint(")\n");	
	}
	if (world.ammo_nails || (world.currentammo && parm5 > 0)) {
		dprint("\b[CLIENT]\b Ammo Spikes ("); dprint(ftos(parm5)); dprint(") To (");
		if (world.currentammo) parm5 = world.ammo_nails;
		else if (parm5 < world.ammo_nails) parm5 = world.ammo_nails;
		if (parm5 > AMMO_MAXNAILS) parm5 = AMMO_MAXNAILS;
		else if (parm5 < 0) parm5 = 0;
		dprint(ftos(parm5)); dprint(")\n");	
	}
	if (world.ammo_rockets || (world.currentammo && parm6 > 0)) {
		dprint("\b[CLIENT]\b Ammo Rockets ("); dprint(ftos(parm6)); dprint(") To (");
		if (world.currentammo) parm6 = world.ammo_rockets;
		else if (parm6 < world.ammo_rockets) parm6 = world.ammo_rockets;
		if (parm6 > AMMO_MAXROCKETS) parm6 = AMMO_MAXROCKETS;
		else if (parm6 < 0) parm6 = 0;
		dprint(ftos(parm6)); dprint(")\n");	
	}
	if (world.ammo_cells || (world.currentammo && parm7 > 0)) {
		dprint("\b[CLIENT]\b Ammo Cells ("); dprint(ftos(parm7)); dprint(") To (");
		if (world.currentammo) parm7 = world.ammo_cells;
		else if (parm7 < world.ammo_cells) parm7 = world.ammo_cells;
		if (parm7 > AMMO_MAXROCKETS) parm7 = AMMO_MAXROCKETS;
		else if (parm7 < 0) parm7 = 0;
		dprint(ftos(parm7)); dprint(")\n");	
	}

	//----------------------------------------------------------------------
	// Update player armour type and quantity
	if (world.armortype > 0) {
		// Remove any previous armour types from the HUD
		parm1 = parm1 - (parm1 & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
		// Setup any armour quantity first, limit check with armour type
		if (world.armorvalue > 0) parm3 = world.armorvalue;

		// Work through the different armour types, resetting armour quantity
		if (world.armortype == 1) {
			parm1 = parm1 | IT_ARMOR1;	
			parm9 = ARMOR_GRN_TYPE * 100;
			if (!world.armorvalue || parm3 > ARMOR_GRN_VALUE) parm3 = ARMOR_GRN_VALUE;
			dprint("\b[CLIENT]\b Green Armor ("); dprint(ftos(parm3)); dprint(")\n");
		}
		else if (world.armortype == 2) {
			parm1 = parm1 | IT_ARMOR2;	
			parm9 = ARMOR_YEL_TYPE * 100;
			if (!world.armorvalue || parm3 > ARMOR_YEL_VALUE) parm3 = ARMOR_YEL_VALUE;
			dprint("\b[CLIENT]\b Yellow Armor ("); dprint(ftos(parm3)); dprint(")\n");
		}
		else if (world.armortype == 3) {
			parm1 = parm1 | IT_ARMOR3;	
			parm9 = ARMOR_RED_TYPE * 100;
			if (!world.armorvalue || parm3 > ARMOR_RED_VALUE) parm3 = ARMOR_RED_VALUE;
			dprint("\b[CLIENT]\b Red Armor ("); dprint(ftos(parm3)); dprint(")\n");
		}
		// Default is no armour
		else parm3 = 0;
	}			
};

/*======================================================================
 USED : Load NEW MAP or trigger CHANGE LEVEL
 Double check the player inventory matches the server/config flags
 Check worldspawn for add/removal of upgrade items
======================================================================*/
void() SyncModInventory =
{
	//----------------------------------------------------------------------
	// Shadow Axe
	//----------------------------------------------------------------------
	// Skill 4 has shadow axe, cannot be changed!
	if (Client_QueryEvilmode() == FALSE) {
		// Check worldspawn for upgrade_axe first, add/deny inventory
		if (world.upgrade_axe < 0) {
			dprint("\b[MODINV]\b Worldspawn removing Axe Upgrade\n");
			parm10 = parm10 - (parm10 & IT_UPGRADE_AXE);
			update_configflag(SVR_UPDAXE, FALSE);
		}
		else if (world.upgrade_axe > 0) {
			dprint("\b[MODINV]\b Worldspawn adding Axe Upgrade\n");
			parm10 = parm10 | IT_UPGRADE_AXE;
			parm1 = parm1 | IT_AXE;
			update_configflag(SVR_UPDAXE, TRUE);
			// Cannot have Shadow Axe AND Grapple Hook
			if (parm10 & IT_UPGRADE_GHOOK) {
				dprint ("\b[MODINV]\b Removing Grapple Hook!\n");
				parm10 = parm10 - (parm10 & IT_UPGRADE_GHOOK);
				update_configflag(SVR_UPDGHOOK, FALSE);
			}
		}
		// Finally syncing the player inventory to serverflags
		else if (parm10 & IT_UPGRADE_AXE) {
			dprint("\b[MODINV]\b Inventory adding Axe Upgrade\n");
			update_configflag(SVR_UPDAXE, TRUE);
		}
	}
	
	//----------------------------------------------------------------------
	// Grapple Hook
	//----------------------------------------------------------------------
	// Skill 4 has shadow axe, cannot have grapple hook!
	if (Client_QueryEvilmode() == FALSE) {
		// Check worldspawn for upgrade_ghook first, add/deny inventory
		if (world.upgrade_ghook < 0) {
			dprint("\b[MODINV]\b Worldspawn removing Grapple Hook\n");
			// FIXME : removing the grapple hook without adding back the axe
			// is a dangerous situation because both use the same (axe) slot
			parm10 = parm10 - (parm10 & IT_UPGRADE_GHOOK);
			update_configflag(SVR_UPDGHOOK, FALSE);
		}
		else if (world.upgrade_ghook > 0) {
			dprint("\b[MODINV]\b Worldspawn adding Grapple Hook\n");
			parm10 = parm10 | IT_UPGRADE_GHOOK;
			parm1 = parm1 | IT_AXE;
			update_configflag(SVR_UPDGHOOK, TRUE);
			// Cannot have Shadow Axe AND Grapple Hook
			if (parm10 & IT_UPGRADE_AXE) {
				dprint ("\b[MODINV]\b Removing Shadow Axe!\n");
				parm10 = parm10 - (parm10 & IT_UPGRADE_AXE);
				update_configflag(SVR_UPDAXE, FALSE);
			}
		}
		// Finally syncing the player inventory to serverflags
		else if (parm10 & IT_UPGRADE_GHOOK) {
			dprint("\b[MODINV]\b Inventory adding Grapple Hook\n");
			update_configflag(SVR_UPDGHOOK, TRUE);
		}
	}

	//----------------------------------------------------------------------
	// Widowmaker Shotgun
	//----------------------------------------------------------------------
	// Check worldspawn for upgrade_ssg first, add/deny inventory
	if (world.upgrade_ssg < 0) {
		dprint("\b[MODINV]\b Worldspawn removing SSG Upgrade\n");
		parm10 = parm10 - (parm10 & IT_UPGRADE_SSG);
		update_configflag(SVR_UPDSSG, FALSE);
	}
	else if (world.upgrade_ssg > 0) {
		dprint("\b[MODINV]\b Worldspawn adding SSG Upgrade\n");
		parm10 = parm10 | IT_UPGRADE_SSG;
		parm1 = parm1 | IT_SUPER_SHOTGUN;
		update_configflag(SVR_UPDSSG, TRUE);
	}
	// Syncing the player inventory to serverflags
	else if (parm10 & IT_UPGRADE_SSG) {
		dprint("\b[MODINV]\b Inventory adding SSG Upgrade\n");
		update_configflag(SVR_UPDSSG, TRUE);
	}

	//----------------------------------------------------------------------
	// Projectile Shotgun
	//----------------------------------------------------------------------
	// Check for worldspawn feature to turn off projectiles + casing
	if (world.no_sgprojectile > 0) 
		update_configflag(SVR_SHOTGPROJ, TRUE);
	if (world.no_sgcasing > 0)
		update_configflag(SVR_SHOTGCASE, TRUE);

	//----------------------------------------------------------------------
	// Plasma Gun
	//----------------------------------------------------------------------
	// Check worldspawn for upgrade_lg first, add/deny inventory
	if (world.upgrade_lg < 0) {
		dprint("\b[MODINV]\b Worldspawn removing LG Upgrade\n");
		parm10 = parm10 - (parm10 & IT_UPGRADE_LG);
		update_configflag(SVR_UPDLG, FALSE);
	}
	else if (world.upgrade_lg > 0) {
		dprint("\b[MODINV]\b Worldspawn adding LG Upgrade\n");
		parm10 = parm10 | IT_UPGRADE_LG;
		parm1 = parm1 | IT_LIGHTNING;
		update_configflag(SVR_UPDLG, TRUE);
	}
	// Finally syncing the player inventory to serverflags
	else if (parm10 & IT_UPGRADE_LG) {
		dprint("\b[MODINV]\b Inventory adding LG Upgrade\n");
		update_configflag(SVR_UPDLG, TRUE);
	}
};

/*======================================================================
 USED : Load NEW MAP or trigger CHANGE LEVEL
 Not used when loading a saved file or quickload
======================================================================*/
void() DecodeLevelParms =
{
	dprint("\b[CLIENT]\b Decode (Level) Parms\n");
	// Map Variables are active (do not reset)
	mapvar_cvar = TRUE;
	// Found any runes? going back to start map? reset inventory
	if (serverflags & SVR_RUNE_ALL) {
		// take away all stuff on starting new episode
		if (world.model == "maps/start.bsp") SetNewParms ();
	}
	
	// Most Quake Engines resets the skill level to 0-3 only
	// Make sure skill level/console variable are updated on load
	Client_SyncPrevEvilmode();

	DecodeWorldParms();		// Decode worldspawn client inv updates
	sync_serverflags();		// update/sync serverflags to worldspawn
	SyncModInventory();		// update/sync mod inventory items

	// Read all current params into client variables
	self.items = parm1;
	self.health = parm2;
	// Always make sure the HP read from parm2 is within range!
	// Parm2 is re-used when map restart command is issued
	Client_CheckMaxHP(self, FALSE);

	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	
	// Double check there is weapons in the inventory
	if (self.items & NO_WEAPONS) self.weapon = 0;
	else self.weapon = parm8;
	
	self.armortype = parm9 * 0.01;
	self.armorvalue = parm3;

	self.moditems = parm10;
	// The AD inventory is reset with parm10 (could lose Shadow axe)
	// Check for evil skill and add shadow axe + make current weapon!
	Client_CheckEvilInv(self);
	
	dprint("\b[CLIENT]\b Reading Map Variables\n");
	// Read/Setup map variables (22 bits per parm, 132 total)
	mapvar[0] = parm11; mapvar[1] = parm12; mapvar[2] = parm13;
	mapvar[3] = parm14; mapvar[4] = parm15; mapvar[5] = parm16;
	
	// Check for any worldspawn map variable settings
	if (CheckZeroVector(world.mapvar_update) == FALSE)
		mapvar_range(world.mapvar_update);
};

//----------------------------------------------------------------------
void() GotoNextMap =
{
	// if samelevel is set, stay on same level
	if (cvar("samelevel")) changelevel (mapname);
	else changelevel (nextmap);
};

/*======================================================================
 NextLevel (DM ONLY)
 - A special function designed for MP only, will cycle around
   the first map of each episode until someone quits
   gives the player runes as well to tell which to load
======================================================================*/
void() NextLevel =
{
	local entity o;

	if (mapname == "start") {
		if (!cvar("registered")) mapname = "e1m1";
		else if (query_configflag(SVR_RUNE_KEY1) == FALSE) {
			mapname = "e1m1";
			update_configflag(SVR_RUNE_KEY1, TRUE);
		}
		else if (query_configflag(SVR_RUNE_KEY2) == FALSE) {
			mapname = "e2m1";
			update_configflag(SVR_RUNE_KEY1, TRUE);
		}
		else if (query_configflag(SVR_RUNE_KEY3) == FALSE) {
			mapname = "e3m1";
			update_configflag(SVR_RUNE_KEY1, TRUE);
		}
		else if (query_configflag(SVR_RUNE_KEY4) == FALSE) {
			mapname = "e4m1";
			update_configflag(SVR_RUNE_KEY1, FALSE);
			update_configflag(SVR_RUNE_KEY2, FALSE);
			update_configflag(SVR_RUNE_KEY3, FALSE);
		}

		o = spawn();
		o.map = mapname;
	}
	else {
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");

		// go back to start if no trigger_changelevel
		if (!o) {
			mapname = "start";
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;
	gameover = TRUE;
	
	if (o.nextthink < time) {
		o.think = trigger_changelevel_finish;
		o.nextthink = time + 0.1;
	}
};

/*======================================================================
 CheckRules (DM ONLY)
 - Check death timers (time/frag limits)
   and decide if to load a new map or not
======================================================================*/
void() CheckRules =
{
	local float timelimit, fraglimit;

	if (deathmatch == 0) return;	// Playing SP?
	if (gameover) return;			// someone else quit the game already
		
	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");
	
	if (timelimit && time >= timelimit) NextLevel();
	else if (fraglimit && self.frags >= fraglimit) NextLevel();
};

//----------------------------------------------------------------------
void() SetupSpawnCoopLocations =
{
	local entity cooploc, prevloc;
	
	// The first spawn for coop is always the SP start location
	cooploc = find (world, classname, "info_player_coop");
	prevloc = world;
	
	// Any coop spawns exist?
	if (cooploc) {
		// Create a list
		while(cooploc) {
			// first spawn in chain? setup first and previous spawns
			if (!prevloc) { 
				coop_ent = cooploc; 
				coop_ent.count = 0;
			}
			else prevloc.owner = cooploc;

			// Save current spawn location to previous ready for loop
			prevloc = cooploc;
			coop_ent.count = coop_ent.count + 1;
				
			cooploc = find(cooploc, classname, "info_player_coop");
		}
		// Close the chain
		prevloc.owner = coop_ent;
		dprint("\b[COOP]\b Spawn locations found (");
		dprint(ftos(coop_ent.count)); dprint(")\n");
	}
	else {
		// No coop spawns, use start location
		dprint("\b[COOP]\b Spawn locations Missing!\n");
		coop_ent = find (world, classname, "info_player_start");
		// no start location, WTF!?!
		if (!coop_ent) coop_ent = client_ent;
		coop_ent.owner = coop_ent;
	}
};

//----------------------------------------------------------------------
// Find a location for the player to spawn at
//----------------------------------------------------------------------
entity() SelectSpawnPoint =
{
	local entity spot, thing;
	local float  pcount, start2, runeactive;
	
	// Always use a player start as default position
	if (!lastspawn) lastspawn = find (world, classname, "info_player_start");

	// Test this first because its such a restrictive set of condition
	if (developer > 0 && coop == 0 && deathmatch == 0) {
		spot = find( world, classname, "info_player_startdev");
		if (spot) {
			dprint ("\b[CLIENT_SPAWN]\b Developer only start!\n");
			return spot;
		}
	}
	
	// Cycle through list of info_player_coop location
	if (coop > 0) {
		// Check for coop spawn list
		if (!coop_ent) return lastspawn;
		// If first entry of coop list start player then its broken
		else if (coop_ent.classtype == CT_SPAWNSP) return lastspawn;
		else {
			// Setup coop list if last location isstart player
			if (lastspawn.classtype == CT_SPAWNSP) lastspawn = coop_ent;
			// Move forward in coop spawn location list
			lastspawn = lastspawn.owner;
			// Check if spawn location is active?
			if (lastspawn.estate & ESTATE_BLOCK) {
				pcount = coop_ent.count;
				while(pcount > 0) {
					lastspawn = lastspawn.owner;
					if (lastspawn.estate == ESTATE_ON) pcount = -1;
					else pcount = pcount - 1;
				}
			}
			// Double check if spawn location free?
			if (lastspawn.estate & ESTATE_BLOCK) {
				// Default back to player start if not available
				lastspawn = find (world, classname, "info_player_start");
			}
			return lastspawn;
		}
	}
	// choose a info_player_deathmatch point
	else if (deathmatch > 0) {
		spot = lastspawn;
		while (1) {
			spot = find(spot, classname, "info_player_deathmatch");
			if (spot == world) spot = find (world, classname, "info_player_start");
			if (spot != world) {
				if (spot == lastspawn) return lastspawn;
				pcount = 0;
				thing = findradius(spot.origin, 32);
				while(thing) {
					if (thing.flags & FL_CLIENT) pcount = pcount + 1;
					thing = thing.chain;
				}
				if (pcount == 0) {
					lastspawn = spot;
					return spot;
				}
			}
		}
	}

	// Check for any info_player_start2 special spawn locations
	if (query_configflag(SVR_SPAWN_BIT1) > 0) start2 = 1;
	else start2 = 0;
	if (query_configflag(SVR_SPAWN_BIT2) > 0) start2 = start2 + 2;
	if (query_configflag(SVR_SPAWN_BIT3) > 0) start2 = start2 + 4;
	if (start2 > 0) dprint("\b[CLIENT]\b Unique Info_Player_Start2 Active\n");
	
	// Check for any runes active
	runeactive = query_configflag(SVR_RUNE_ALL);
	
	// have a rune or new spawnflag option?
	if ( runeactive > 0 || start2 > 0 ) {
		// Find second spawn locations (can have several)
		spot = find (world, classname, "info_player_start2");
		while (spot) {
			// Check for rune only start 2 setup
			if (runeactive > 0 && spot.startspawn2 == 0)
				return spot;
			// Check for special spawn2 location
			else if (spot.startspawn2 == start2)
				return spot;
			// Keep searching for start2 positions
			spot = find(spot, classname, "info_player_start2");
		}
	}
	
	// Last chance to find a spawn location before giving up!
	spot = find (world, classname, "info_player_start");
	if (!spot) dprint ("\b[CLIENT_SPAWN]\b missing info_player_start!\n");
	
	return spot;
};

//----------------------------------------------------------------------
// PutClientInServer - called each time a player is spawned
//----------------------------------------------------------------------
void() PutClientInServer =
{
	local entity spot;

	dprint("\b[CLIENT]\b PutClientInServer\n");
	client_ent = self;
	self.classname = "player";
	self.classtype = CT_PLAYER;
	self.classgroup = CG_PLAYERS;
	self.flags = FL_CLIENT;
	// This entity can never be switched off
	self.estate = ESTATE_ON;
	self.estate_off = SUB_Null;

	// Reset intermission/cinematic stuff
	intermission_running = cinematic_running = 0;
	
	// Check for Evil NM+ skill level (Lower HP max)
	if (Client_QueryEvilmode()) Client_SetupEvilmode();
	// Update health/mega max and leave weapons alone
	else Client_ResetEvilmode(-1);

	// Setup entity chains for coop, dm and intermission
	SetupSpawnCoopLocations();
	SetupIntermissionCamera();

	// Find a spawn location in the map
	spot = SelectSpawnPoint ();
	// Fire any targets on spawn location
	if (spot.target) self.target2 = spot.target;
	else self.target2 = "";
	// Copy over any cinematic camera start sequences
	if (spot.cameratarget) self.cameratarget = spot.cameratarget;

	self.headmdl = MODEL_PLAYER_HEAD;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.classmove = MON_MOVEWALK;
	self.show_hostile = 0;
	self.gibhealth = -40;
	self.gibbed = FALSE;
	self.air_finished = time + WATER_AIR;
	self.dmg = WATER_DAMAGE;
	self.effects = 0;
	self.steplast = 1;
	self.jump_flag = 0;
	self.oldgravity = 0;				// Reset gravity effects
	
	self.steptype = FS_TYPEMEDIUM;		// Standard feet sounds
	self.suppressCenterPrint = FALSE;	// No centerprint active

	// Check if Arcane Key Inventory message is blocked/suppressed
	if (world.ckeyhint == TRUE) self.ckeyhint = TRUE;
	
	ResetPowerSystem(self,0,FALSE);		// Remove powerup effects (not vania)
	ResetDebuffSystem(self);			// Reset/initialize debuff system

	self.enemy = world;
	DecodeLevelParms ();
	// Evil Mode should always start with the AXe!
	if (Client_QueryEvilmode()) self.weapon = IT_AXE;
	else self.weapon = W_BestWeapon (self);	// Pick best weapon from inventory
	W_SetCurrentAmmo (self);			// Update hud icons and v_model

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = player_death;
	
	self.deadflag = DEAD_NO;			// The player is alive!
	self.pausetime = 0;					// make sure player has 0 velocity when spawning

	update_hud_totals(HUD_MONSTERS);	// Make screen total is correct
	update_hud_totals(HUD_SECRETS);		// Update monsters and secrets

	// Reset randomizer counters
	self.randomshells = self.randomcells = 0;
	
	//	spot = SelectSpawnPoint ();
	self.origin = spot.origin + '0 0 1';
	if (spot.mangle) self.angles = spot.mangle;
	else self.angles = spot.angles;
	self.v_angle = self.angles;
	self.fixangle = TRUE;				// turn this way immediately

	// oh, this is a hack!
	setmodel (self, MODEL_PLAYER_EYES);
	modelindex_eyes = self.modelindex;

	setmodel (self, MODEL_PLAYER);
	modelindex_player = self.modelindex;

	self.bbmins = VEC_HULLSHORT_MIN;	// -16 -16 -24, 16 16 32
	self.bbmaxs = VEC_HULLSHORT_MAX;
	setsize (self, self.bbmins, self.bbmaxs);
	// Where the feet are! 22 units below!
	self.view_ofs = '0 0 22';
	player_stand1 ();

	// Check for cinematic system startup (NO COOP!!!)
	if (self.cameratarget != "" && coop == 0) {
		// Find first camera
		self.enemy = find(world, targetname, self.cameratarget);
		if (self.enemy.classtype == CT_MISCCAM) {
			cam_focus = self.enemy;			// Camera
			cam_client = self;				// Player
			cam_startup = TRUE;				// Special start
			cam_active = CINECAM_SETUP;		// Lets begin!
		}
	}
	// Default
	else {
		// gib anything in the way
		if (deathmatch || coop) {
			makevectors(self.angles);
			spawn_tfog (self.origin + v_forward*20);
		}
		// Teleport effect + sound
		spawn_tdeath (self.origin, self);
	}	
};

// Forward compiler links
void() PlayerJump;
void() WaterMove;
void() CheckWaterJump;
void() ClientDeath;

//----------------------------------------------------------------------
void(entity targ) Client_LadderSounds =
{
	local float rndsound;
	if (query_configflag(SVR_FOOTSTEP) == TRUE) return;
	if (targ.entladder.sounds == 4) return;
	
	rndsound = random();
	if (rndsound < 0.25 && targ.entladder.noise1) 
		sound (targ, CHAN_BODY, targ.entladder.noise1, 1, ATTN_NORM);
	else if (rndsound < 0.5 && targ.entladder.noise2) 
		sound (targ, CHAN_BODY, targ.entladder.noise2, 1, ATTN_NORM);
	else if (rndsound < 0.75 && targ.entladder.noise3) 
		sound (targ, CHAN_BODY, targ.entladder.noise3, 1, ATTN_NORM);
	else if (targ.entladder.noise4) 
		sound (targ, CHAN_BODY, targ.entladder.noise4, 1, ATTN_NORM);
};

//----------------------------------------------------------------------
// PlayerPreThink - Called every frame before physics are run
//----------------------------------------------------------------------
void() PlayerPreThink =
{
	//----------------------------------------------------------------------
	// This is just a fucked up messy situation ...
	// The savegame data is not live until after frame 0 has finished
	// The only variable read from a savegame early is skill level!
	// So instead of detecting Chaos mode changes at frame 0 and fixing them
	// have to wait for savegame data to be live and client/server stable
	// This function also detects savegames (framecount>0)
	if (chaoscount <= 2) {
		// Increase counter early because of return later
		chaoscount = chaoscount + 1;
		// Save games don't usually start at framecount 0
		if (framecount > RND_FRAMECOUNT) {
			// Catch quickload (read 'oskill') and reset skill level
			Client_SyncPrevEvilmode();

			// Detect skill 4 + Chaos savegame!
			// Cannot kill player here, client is not properly setup
			if (rnd_CheckNoQuickLoad()) {
				dprint("\b[RND_SYNC]\b FC ("); dprint(ftos(framecount));
				dprint(") Skill 4 death detected!\n");
				// Stop this function and wait for postclient
				chaoscount = 10;
				// Make sure death happens in PostClient check
				framecount = framecount + RND_FRAMECOUNT;
			}
			else {
				// Save game found, highlight on dev console
				dprint("\b[RND_SYNC]\b FC ("); dprint(ftos(framecount));
				dprint(") Save Game Found!\n");
			}
		}
		// Wait for frame1 to validate current/savegame chaos setup
		// The Restart command cannot be done on frame 0
		// It will break the client/server setup sequence
		if (chaoscount == 2) {
			// Returns true if restart required
			if (rnd_CheckSaveGameReboot()) {
				// Works better if restart here instead of above function
				// Cannot use map or changelevel command because of savegame
				localcmd ("restart\n");
				// Block any pre/post functions
				prethink = postthink = TRUE;
				// Finish PlayerPreThink function
				return;
			}
		}
	}
	
	//----------------------------------------------------------------------
	// Once the map has loaded (frame>0) set loadflag (never saved)
	if (prethink == FALSE) {
		prethink = TRUE;			// prethink flag complete
		postthink = FALSE;			// postthink flag reset
		sync_configflag();			// Setup and sync serverflag
		// Some clients load faster, prevent player gasping for air
		self.air_finished = time + WATER_AIR;

		// Double check which engine is active?
		// A DP/FTE Quickload could be happening and the
		// Particle system needs to cope with the change
		ext_active = cvar("pr_checkextension");
		if (!ext_active) {
			// Revert to default = Fitz engine setup
			engine = ENG_FITZ;
			ext_dppart = ext_dpfog = ext_dpsurf = FALSE;
			ext_dprain = ext_dpsnow = FALSE;
		}
		
		// Check for trigger CD track/Skybox change
		// Load/Quickload does not keep track of these changes
		// Use a new global variable instead
		if (trig_cdtrack > 0) trigger_cdtrack_change();
		if (trig_skybox != "") trigger_skybox_change(self);
		
		// Check for server gravity changes
		if (map_gravity != DEF_GRAVITY) {
			cvar_set("sv_gravity", ftos(map_gravity));
		}		
	}

	//----------------------------------------------------------------------
	// If Intermission system active check for button0-2 keys
	if (intermission_running > 0) { impulse_notvalid(); CycleIntermissionCamera(); return; }
	// If secret location camera active check for button0-2 keys
	if (secloc_running > 0) { impulse_notvalid(); CheckSecretCamera(); return; }
	// Update particle emitter origin attached to the player
	// Cinematic camera uses player and this should be before it
	if (self.entactive && self.entattachment) 
		setorigin(self.entattachment, self.origin);
	// If cinematic camera system active
	if (cinematic_running > 0) { impulse_notvalid(); return; }

	//----------------------------------------------------------------------
	// Skill 4 - Detect ANY skill changes (player console)
	//----------------------------------------------------------------------
	if (skill != oskill) {
		// Check if Evil skill enabled? (check skill NOT cvar)
		if (Client_QueryEvilskill()) {
			// Reset HP + Max/Mega and give Shadow Axe
			Client_SetupEvilmode();
			Client_DispEvilmsg();
		}
		// Reset HP/Max (check worldspawn for override)
		else Client_ResetEvilmode(oskill);
		// Sync old and new skill variables
		oskill = skill;
	}
	
	//----------------------------------------------------------------------
	makevectors (self.v_angle);	
	CheckRules ();
	WaterMove ();
	
	// Hacky way to make the player move out of water
	if (self.waterlevel == 2) CheckWaterJump ();
	// Start dying process
	if (self.deadflag >= DEAD_DEAD) {
		ClientDeath ();
		return;
	}
	// dying, so do nothing
	if (self.deadflag == DEAD_DYING) return;

	//----------------------------------------------------------------------
	// The jump boots can be setup to work a limited amount of uses before
	// having to be reset by landing on the ground.
	// The starting (1st jump) sequence for the boots is always with a jump,
	// but the player can fall off ledges without jumping.
	// Unfortunately Quake does not let the player jump if falling, but
	// the jump boots should override this behaviour.
	// The engine will reset the fl_onground flag when the player falls
	// off a ledge and this flag is used to determine the starting sequence
	// for the jump boots.
	// This check is outside of the jump function so that the jump
	// boots can always be reset regardless if jump starts the sequence.
	//----------------------------------------------------------------------
	if (self.moditems & IT_ARTJUMPBOOTS && self.flags & FL_ONGROUND) 
		self.jumpboots_onground = TRUE;
	
	// Check Grapple Hook (release/beam/jump)
	GrappleHook_Client();

	//----------------------------------------------------------------------
	// Rubicon Ladder Code - johnfitz
	// Modified by me to support diff climb sounds and on/off/toggle states
	//----------------------------------------------------------------------
	if (self.onladder == LADDER_JUMP) {
		// Reset ladder touch function
		self.onladder = LADDER_NONE;
		if (ext_fteskin && self.entladder.skin == -16) {
			// Only do the ladder sound if the player is moving (X/Y)
			if (self.timeladder < time && self.velocity_x != 0 && self.velocity_y != 0) {
				// Reset timer for next sound to play
				self.timeladder = time + self.entladder.waitmin;
				// Check for any sounds and query if footsteps are active
				Client_LadderSounds(self);
			}
		}
		// Is jump key being pressed?
		else if (self.button2) {
			// Reset velocity upwards and all sideways movement
			// so that the player stays on the ladder and climbs
			// straight up with very little sidways movement
			self.velocity = '0 0 0';
			self.velocity_z = self.entladder.speed;
			self.gravity = 0.0000001;

			if (self.timeladder < time) {
				// Reset timer for next sound to play
				self.timeladder = time + self.entladder.waitmin;
				// Check for any sounds and query if footsteps are active
				Client_LadderSounds(self);
			}
		}
		else {
			// Jump key released, stay floating on the ladder
			self.flags = self.flags | FL_JUMPRELEASED;
			self.velocity = 0.9 * self.velocity;
			self.velocity_z = 0;
		}
	}
	else if (self.onladder == LADDER_VEL) {
		// Is jump key being pressed?
		if (self.button2) {
			self.blockladder = time + 0.1;
			self.flags = self.flags - FL_ONGROUND;
			PlayerJump ();
		}
		else self.flags = self.flags | FL_JUMPRELEASED;
		// Reset ladder touch function
		self.onladder = LADDER_NONE;
	}
	else {
		// Reset any ladder gravity settings
		if (self.oldgravity > 0) self.gravity = self.oldgravity;
		else self.gravity = 1;

		// Original jump conditions
		if (self.button2) PlayerJump ();
		else self.flags = self.flags | FL_JUMPRELEASED;
	}
	
	//----------------------------------------------------------------------
	// When the player/client starts in the map they don't want any velocity	
	if (time < self.pausetime) self.velocity = '0 0 0';
};
	
//----------------------------------------------------------------------
// PlayerPostThink - Called every frame after physics are run
//----------------------------------------------------------------------
void() PlayerPostThink =
{
	if (prethink == TRUE && postthink == FALSE) {
		// Check for the player? 
		// - first couple of frames the player is not setup correctly
		if (self.flags & FL_CLIENT) {
			postthink = TRUE;			// postthink flag complete
			mapvar_cvar = TRUE;			// Map Variable are live

			// Cannot load skill 4 + Chaos save games!
			// Only kill the player once the client/server is setup
			// This also catches the savegame resetting Chaos mode
			if (rnd_CheckNoQuickLoad() && framecount > RND_FRAMECOUNT) {
				// Classic death message
				self.deathtype = "loadingevil";
				centerprint(self,"Cannot resurrect EVIL mode!?!\n");
				T_Damage(self, world, world, MEGADEATH, NOARMOR);
				return;
			}

			// Reset any screen cshift parameters, eng often leaves them
			if (!self.cshift_upd) self.cshift_time = -1;
			
			// Check worldspawn water alpha parameters?
			// liquid alpha is used by the monster visible system
			if (world.water_alpha) {
				liquid_alpha = world.water_alpha;
				stuffcmd(self, "\nr_wateralpha ");
				lftos(self, liquid_alpha ,1,3, BUFFER_STUFFCMD);
				stuffcmd(self, "\n");
				dprint("\b[CLIENT]\b Water Alpha (");
				lftos(self, liquid_alpha ,1,3, BUFFER_DPRINT);
				dprint(")\n");
				
			}
			else liquid_alpha = cvar("r_wateralpha");	

			// Check engine for actual autoaim setting
			// Always reset with newgame and quickload
			autoaim_cvar = cvar("sv_aim");
			
			// AD 1.8 removed SVR_NOFOGCMDS (winquake idea)
			// Create fog controller and/or update engine fog
			if (fog_active) change_fog(self);
			else setup_fog_controller();
			// Sky fog is a different system (only density)
			if (skyfog_active) change_skyfog(self);
			else setup_skyfog_controller();
			
			// Update console with MOD settings
			//showbits_configflag();
			display_configflag();
			display_version();	
			
			// Warn about chaos mode
			warning_chaosmode();
		}
	}

	// Special systems that pause the QC/Game
	if (intermission_running > 0) return;
	if (secloc_running > 0) return;
	if (cinematic_running > 0) {
		// The focalpoint system is about tracking an entity while the camera
		// is stationary or moving and updating the player viewing angle.
		// The current (2019) community client engines default protocol's are
		// 15 or 666, which unfortunately do not support smooth angle updates.
		// The ideal solution is protocol 999 with higher FP resolution,
		// but this has to be set before the map is loaded and manually
		// via the console which is not user friendly.
		//
		// The updates to player angle/origin were tested in both pre/post
		// QC functions and no difference in visuals could be detected
		// Some engines (QSS/FTE/DP) cope with angle updates better than
		// others (Fitz/QS/MakV) and using protocol 999 certainly helps
		//
		if (cam_client == self && cam_locked) {
			// Camera tracking system?
			if (cam_movement) {
				// Finished moving the tracking entity?
				if (cam_track.attack_finished < time) {
					// Don't reset origin if at 0,0,0 (usually error)
					if (!CheckZeroVector(cam_track.enemy.origin))
						setorigin(self, cam_track.enemy.origin);
					cam_movement = FALSE;
				}
				// Update camera (player) origin
				else {
					// Bezier Curve movement
					if (cam_bezier) {
						cam_track.delay = cam_track.wait - (cam_track.attack_finished - time);
						cam_track.origin = bezier_curve(cam_track.pos4, cam_track.pos5, cam_track.pos6, cam_track.wait, cam_track.delay);
						// Don't reset origin if at 0,0,0 (usually error)
						if (!CheckZeroVector(cam_track.origin))
							setorigin(self, cam_track.origin);
					}
					// Linear movement
					else {
						// Don't reset origin if at 0,0,0 (usually error)
						if (!CheckZeroVector(cam_track.origin))
							setorigin(self, cam_track.origin);
					}
				}
			}

			// Does the camera have to focus on angletarget?
			// validation of angletarget done in misc_cam function
			if (cam_focus.focalpoint > 0) {
				// Move camera angletarget to player(camera) entity
				// Targetmovedir function uses (self) for comparision
				self.angletarget = cam_focus.angletarget;
				// Update movedir, movetarget and dest1
				TargetMovedir(self, TRUE);
				
				// Convert direction vector to angles
				// This function returns integers! (engine code bug)
				cam_newangle = vectoangles(self.movedir);

				//---------------------------------------------------------------------
				// Camera Angle Smoothing V2 by Eric Wasylishen
				//---------------------------------------------------------------------
				// Initialize last angle (snap to the initial angle)
				if (!cam_lastanglevalid) {
					cam_lastanglevalid = TRUE;
					cam_lastangle = cam_newangle;
				}

				// Clamp angles to 0-360
				cam_newangle = vectormod(cam_newangle);
				cam_lastangle = vectormod(cam_lastangle);

				// Need to check every axis (XYZ) for 0 boundary issues
				// function stored in misc_camera.qc (only used for camera's)
				if (camera_check_anglezero(cam_newangle_x, cam_lastangle_x)) {
					// To avoid breaking the interpolation,
					// shift the larger number so it's negative
					if (cam_newangle_x > cam_lastangle_x) cam_newangle_x -= 360;
					else cam_lastangle_x -= 360;
				}
				if (camera_check_anglezero(cam_newangle_y, cam_lastangle_y)) {
					if (cam_newangle_y > cam_lastangle_y) cam_newangle_y -= 360;
					else cam_lastangle_y -= 360;
				}
				if (camera_check_anglezero(cam_newangle_z, cam_lastangle_z)) {
					if (cam_newangle_z > cam_lastangle_z) cam_newangle_z -= 360;
					else cam_lastangle_z -= 360;
				}
				// Blend the last frame's angle with the target.
				// This controls how much of the target is mixed in, closer to 0 is slower.
				cam_focus.angleblend = CINECAM_ANGLEBLEND;
				cam_angle = (cam_newangle * cam_focus.angleblend) + (cam_lastangle * (1 - cam_focus.angleblend));
				// Clamp angles to 0-360
				cam_angle = vectormod(cam_angle);

				// Store history of cam_angle for next frame's smoothing
				cam_lastangle = cam_angle;
				//---------------------------------------------------------------------
				// End of Camera Angle smoothing
				//---------------------------------------------------------------------
				
				// Got to reverse the pitch angle because the player angles
				// and v_angle are upside down (special carmack code)
				cam_angle_x = -cam_angle_x;
				self.angles = self.v_angle = cam_angle;
			}
			else {
				// Update the player model/view angles
				self.angles = self.v_angle = cam_angle;
				// Reduce drunk camera effect
				self.angles_z = 0;
			}
			// Force engine to update immediately
			self.fixangle = TRUE;			
		}
		return;
	}
	
	if (self.deadflag) return;

	// Any spawn targets to update?
	if (self.target2 != "") { 
		trigger_strs(self.target2, self); self.target2 = "";
	}
	// Impulse commands and Quad updates
	W_WeaponFrame ();

	// Show the player fall speed/velocity to the console
	// Useful for showing what map unit heights affect damage values
	if (map_fallspeeddebug == TRUE && developer == 1 && self.jump_flag != 0) {
		dprint(ftos(self.jump_flag)); dprint(" ");
	}
	
	// Is the player sliding on top of an entity? (not on ground)
	// Need postthink check bec player starts at 0,0,0 floating :P
	if (self.velocity_z == 0 && !(self.flags & FL_ONGROUND) && postthink) {
		// Block players who jump and then noclip around!?!
		if (self.jumptimer < time && self.movetype != MOVETYPE_NOCLIP ) {
			// Slow down function, its running pre/post timing
			self.jumptimer = time + 0.1;
			// Create a really small radius list, this is expensive!
			self.jumptouch = findradius(self.origin, 96);
			while (self.jumptouch) {
				// Found a breakable model?
				if (self.jumptouch.classtype == CT_FUNCBREAKMDL) {
					// Check for nodamage spawnflag exception!
					if (self.jumptouch.spawnflags & BREAK_NOSHOOT) {
						// Slow down console message
						self.jumptimer = time + 2;
						dprint("[SLIDING] Unbreakable obj at ");
						dprint(vtos(self.jumptouch.origin));
						dprint("\n");
					}
					else {
						// From the player origin down to the feet is 22 (def) units
						// The breakable bbox edge (maxs) should be below feet
						if ( (self.jumptouch.origin_z + self.jumptouch.bbmaxs_z) < self.origin_z-self.view_ofs_z &&
							vlen(self.jumptouch.origin - self.origin) <= 64) {
							// Spawn a debug marker to show affected breakables
							//spawn_marker(self.jumptouch.origin + self.jumptouch.bbmaxs, 0);
							// Squash the contents (monsters) of this breakable
							self.jumptouch.jumpsquash = TRUE;
							// Force trigger break object! (no debug info)
							self.jumptouch.nodebuginfo = TRUE;
							trigger_ent(self.jumptouch, self);
						}
					}
				}
				// Keep cycling through radius list
				self.jumptouch = self.jumptouch.chain;
			}
		}
	}
	
	// check to see if player landed and play landing sound	
	// land.wav  = light huh sound (floor impact and no damage)
	// land2.wav = heavy huh sound and nasty bone crunching sound
	if ((self.jump_flag < map_fallspeedlow) && (self.flags & FL_ONGROUND) && (self.health > 0)) {
		// Landed deep (waist high) in water
		if (self.watertype == CONTENT_WATER) {
			// Player hits water surface
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
			// Check if damage can be applied after hitting water surface
			// Cannot check jump flag velocity because player hit water
			if (map_falldmgwater > 0) {
				T_Damage (self, world, world, map_falldmgwater, DAMARMOR);
				// Play on different channel so it does not conflict
				sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
				self.deathtype = "falling";
			}
		}
		else if (self.jump_flag < map_fallspeedhigh) {
			if (map_falldmg > 0) {
				T_Damage (self, world, world, map_falldmg, DAMARMOR);
				sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
				self.deathtype = "falling";
			}
			else sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
		}
		else
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);

		self.jump_flag = 0;
	}

	// Check for any fake water exit sounds
	if (self.touchedliquid < time && self.touchedsound != "") {
		sound (self, CHAN_BODY, self.touchedsound, 1, ATTN_NORM);
		self.touchedsound = "";
	}

	// If flying through the air, store player Z velocity in jump flag
	// This is a negative number because the player is falling downward
	if (!(self.flags & FL_ONGROUND)) self.jump_flag = self.velocity_z;
	// The jump flag should be reset if the player is on the ground
	// It is only used by the player (client) in this function
	// the jump flag is used by jumping monsters (different entity type)
	else self.jump_flag = 0;

	// Check for any player powerups and debuffs updates
	ClientPowerups ();
	ClientDeBuff ();
};

//----------------------------------------------------------------------
void() PlayerJump =
{
	if (self.flags & FL_WATERJUMP) return;

	if (self.waterlevel >= 2) {
		if (self.watertype == CONTENT_WATER) self.velocity_z = 100;
		else if (self.watertype == CONTENT_SLIME) self.velocity_z = 80;
		else self.velocity_z = 50;

		// play swiming sound
		if (self.swim_flag < time) {
			self.swim_flag = time + 1;
			if (random() < 0.5) sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			else sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}
		return;
	}

	//----------------------------------------------------------------------
	// The jump boots idea by Jose Carlos Rodriguez (JCR) from modjam1
	// This code was originally by JCR and modified by me to fit AD layout
	// Switched over all the variables to constants and entity options
	// Does the player have the jump boot powerup?
	//----------------------------------------------------------------------
	if (self.moditems & IT_ARTJUMPBOOTS) {
		// On the ground and starting to jump upward
		// Reset jump counter and start sequence
		if(self.flags & FL_ONGROUND) {
			// Stop constant re-jump, got to press key again
			if (!(self.flags & FL_JUMPRELEASED)) return;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			// Clear button as jump is happening
			self.button2 = 0;
			// Reset 'out of jump power' sound
			self.jumpboots_sound = FALSE;
			// Reset onground and jump boots ground flags, not needed anymore
			self.flags = self.flags - (self.flags & FL_ONGROUND);
			self.jumpboots_onground = FALSE;
			// Reset maximum amount of air jumps (for level 1-4 item)
			self.jumpboots_airlvl = self.jumpboots_airmax;
			// Combination sound of original jump + jump boots
			sound (self, CHAN_BODY, SOUND_ARTJUMPBOOTS3A, 1, ATTN_NORM);
			// Jumps boots don't really work until in the air
			// Start with original jump height
			self.velocity_z = self.velocity_z + map_jumpheight;
		}
		// Still in the air (no ground contact)
		// Allow for infinite jumps (airmax = -1)
		// Check for more jumps (1-4) and reset velocity
		// Allow for players falling of ledges (jumpboots_onground)
		else {	
			if(self.jumpboots_airmax == -1 || self.jumpboots_airlvl >= 1 || self.jumpboots_onground) {
				// Stop constant re-jump, got to press key again
				if (!(self.flags & FL_JUMPRELEASED)) return;
				self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
				// Clear button as jump is happening
				self.button2 = 0;
				// Reset 'out of jump power' sound
				self.jumpboots_sound = time + 0.4;
				// If the player is falling, allow for air jumps and reset level
				if (self.jumpboots_onground) self.jumpboots_airlvl = self.jumpboots_airmax;
				self.jumpboots_onground = FALSE;
				// Count down on maximum jump level
				self.jumpboots_airlvl = self.jumpboots_airlvl - 1;
				// Whoosh, more power
				sound (self, CHAN_BODY, SOUND_ARTJUMPBOOTS3B, 1, ATTN_NORM);
				// Add jump boot height, different from basic jump
				self.velocity_z = self.jumpboots_height;
			}
			// No more power!
			else {
				// played sound already?
				if (self.jumpboots_sound < time) {
					// Don't play the sound constantly
					self.jumpboots_sound = time + 0.2;
					// clickty click
					sound (self, CHAN_BODY, SOUND_ARTJUMPBOOTS3C, 1, ATTN_NORM);
				}
			}
		}
		
		// Is there any additional forward motion?
		if (self.jumpboots_forward > 0) {
			// Work out what speed the player is going forward
			// Flatten vectors by removing Z element
			self.pos1 = self.origin;
			self.pos2 = self.velocity;
			self.pos1_z = self.pos2_z = 0;
			// Add velocity to origin to create future position
			// Use vector length function to calc distance
			self.pos3 = self.pos1 + self.pos2;
			self.t_length = vlen(self.pos3 - self.pos1);
			// Check for min/max velocity first
			if (self.t_length < self.jumpboots_forward) {
				// Use the forward/right/up vector system
				makevectors (self.v_angle);
				// Normalize the result because its a multiplier
				self.finalangle = normalize(v_forward);
				// Never increase the forward velocity beyond limit
				// Otherwise the velocity could grow too fast
				self.velocity = self.velocity + (self.finalangle * (self.jumpboots_forward - self.t_length));
			}
		}
	}
	//----------------------------------------------------------------------
	// Velocity ladder jump logic
	// Can't block onground or jumprelease flag conditions
	// Jump direction should be v_angle and not just up!
	//----------------------------------------------------------------------
	else if (self.onladder == LADDER_VEL) {
		// Very precise order for this, Jumprelease and then onground
		self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
		self.flags = self.flags - FL_ONGROUND;	// don't stairwalk
		self.button2 = 0;
		
		// player jumping sound
		sound (self, CHAN_BODY, SOUND_PLAYER_JUMP, 1, ATTN_NORM);
		makevectors(self.v_angle);
		self.velocity = v_forward * (map_jumpheight*1);
	}
	//----------------------------------------------------------------------
	// Original ID1 jump logic
	//----------------------------------------------------------------------
	else {
		if (!(self.flags & FL_ONGROUND)) return;
		if (!(self.flags & FL_JUMPRELEASED)) return;	// don't pogo stick

		// Very precise order for this, Jumprelease and then onground
		self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
		self.flags = self.flags - FL_ONGROUND;	// don't stairwalk
		self.button2 = 0;
		
		// player jumping sound
		sound (self, CHAN_BODY, SOUND_PLAYER_JUMP, 1, ATTN_NORM);
		self.velocity_z = self.velocity_z + map_jumpheight;
	}
};

//----------------------------------------------------------------------
// Deals with water, slime and lava
//----------------------------------------------------------------------
void() WaterMove =
{
	//dprint (ftos(self.waterlevel));
	// Fix noclip water gasping bug by giving air to the player
	if (self.movetype == MOVETYPE_NOCLIP) {
		if (self.air_finished < time + 2) self.air_finished = time + 2; 
		return;
	}
	if (self.health < 0) return;

	if (self.waterlevel != 3) {
		if (self.air_finished < time)
			sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		else if (self.air_finished < time + (WATER_AIR-3))
			sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
		self.air_finished = time + WATER_AIR;
		self.dmg = map_hazarddmg_x;
	}
	else if (self.air_finished < time) {	// drown!
		if (self.pain_finished < time) {
			// Keep increasing drowning damage
			self.dmg = self.dmg + map_hazarddmg_x;
			// Cap the drowning damage if it gets too high
			if (self.dmg > 15) self.dmg = 10;
			T_Damage (self, world, world, self.dmg, DAMARMOR);
			self.pain_finished = time + 1;
		}
	}
	
	if (!self.waterlevel) {
		if (self.flags & FL_INWATER) {	
			// play leave water sound
			sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}

	if (self.watertype == CONTENT_LAVA) {
		// Check for lava shield and play reminder it exists
		if (self.moditems & IT_ARTLAVASHIELD) PlayLavaShieldSound(self);
		else {
			// Check for lava damage timer
			if (self.dmgtime < time) {
				// Unknown feature : env suit gives lava protection
				if (self.radsuit_finished > time) self.dmgtime = time + 1;
				else self.dmgtime = time + 0.2;
				// Lava damage is crazy high the deeper you go
				T_Damage (self, world, world, map_hazarddmg_z*self.waterlevel, DAMARMOR);
			}
		}
	}
	else if (self.watertype == CONTENT_SLIME) {	// do damage
		if (self.dmgtime < time && self.radsuit_finished < time) {
			self.dmgtime = time + 1;
			T_Damage (self, world, world, map_hazarddmg_y*self.waterlevel, DAMARMOR);
		}
	}
	
	if ( !(self.flags & FL_INWATER) ) {	 // player enter water sound
		if (self.watertype == CONTENT_LAVA)
			sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_SLIME)
			sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}
	
	if (! (self.flags & FL_WATERJUMP) )
		self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;
};

//----------------------------------------------------------------------
void() CheckWaterJump =
{
	local vector start, end;

	// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8; 
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	
	if (trace_fraction < 1) {	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1) {	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net
			return;
		}
	}
};

/*======================================================================
 CLIENT GAME EDGE FUNCTIONS
======================================================================*/
// This function cannot be move, ref an exact frame in players model
void() set_suicide_frame;		// In player.qc

//----------------------------------------------------------------------
void() ClientRespawn =
{
	// CLIENT DIED = Reset randomizer seed
	rnd_ResetRandomSeed(RND_NORESETDEATH);
	
	if (coop) {
		CopyToBodyQue (self);	// make a copy of the dead body for appearances sake
		setspawnparms (self);	// get the spawn parms as they were at level start
		PutClientInServer ();	// respawn
	}
	else if (deathmatch) {
		CopyToBodyQue (self);	// make a copy of the dead body for appearances sake
		SetNewParms ();			// set default spawn parms
		PutClientInServer ();	// respawn
	}
	// Its the infamous restart command debacle of 1996!
	else localcmd ("restart\n");
};

//----------------------------------------------------------------------
void() ClientDeath =
{
	local float forward;

	if ((self.flags & FL_ONGROUND)) {
		forward = vlen (self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else	
			self.velocity = forward * normalize(self.velocity);
	}

	// wait for all buttons released
	if (self.deadflag == DEAD_DEAD) {
		if (self.button2 || self.button1 || self.button0) return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}

	// wait for any button down
	if (!self.button2 && !self.button1 && !self.button0) return;
	self.button0 = self.button1 = self.button2 = 0;
	ClientRespawn();
};

//----------------------------------------------------------------------
// Player entered the suicide command
//----------------------------------------------------------------------
void() ClientKill =
{
	bprint (self.netname);
	bprint (" suicides\n");
	set_suicide_frame ();
	self.modelindex = modelindex_player;
	self.frags = self.frags - 2;	// extra penalty
	ClientRespawn ();
};

//----------------------------------------------------------------------
// Called when a player connects to a server
//----------------------------------------------------------------------
void() ClientConnect =
{
	bprint (self.netname);
	bprint (" entered the game\n");
	
	// a client connecting during an intermission can cause problems
	if (intermission_running > 0) GotoNextMap ();
};

//----------------------------------------------------------------------
// Called when a player disconnects from a server
//----------------------------------------------------------------------
void() ClientDisconnect =
{
	if (gameover) return;
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving

	// let everyone else know
	bprint (self.netname);
	bprint (" left the game with ");
	bprint (ftos(self.frags));
	bprint (" frags\n");
	sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
	set_suicide_frame ();
};

//----------------------------------------------------------------------
// Called when a player dies, deals with all death messages
//----------------------------------------------------------------------
void(entity targ, entity attacker) ClientObituary =
{
	local	float rnum;
	local	string clientstring, clientstring2;
	rnum = random();

	if (targ.flags & FL_CLIENT) {
		if (attacker.classname == "teledeath") {
			bprint (targ.netname);
			bprint (" was telefragged by ");
			bprint (attacker.owner.netname);
			bprint ("\n");

			attacker.owner.frags = attacker.owner.frags + 1;
			return;
		}

		if (attacker.classname == "teledeath2") {
			bprint ("Satan's power deflects ");
			bprint (targ.netname);
			bprint ("'s telefrag\n");

			targ.frags = targ.frags - 1;
			return;
		}

		if (attacker.flags & FL_CLIENT) {
			if (targ == attacker) {
				// killed self
				attacker.frags = attacker.frags - 1;
				bprint (targ.netname);
				
				if (targ.weapon == 64 && targ.waterlevel > 1) {
					bprint (" discharges into the water.\n");
					return;
				}
				if (targ.weapon == IT_GRENADE_LAUNCHER) 
					bprint (" tries to put the pin back in\n");
				else
					bprint (" becomes bored with life\n");
				return;
			}
			else if ( (teamplay == 2) && (targ.team > 0)&&(targ.team == attacker.team) ) {
				if (rnum < 0.25) clientstring = " mows down a teammate\n";
				else if (rnum < 0.50) clientstring = " checks his glasses\n";
				else if (rnum < 0.75) clientstring = " gets a frag for the other team\n";
				else clientstring = " loses another friend\n";
				bprint (attacker.netname);
				bprint (clientstring);
				attacker.frags = attacker.frags - 1;
				return;
			}
			else {
				attacker.frags = attacker.frags + 1;

				rnum = attacker.weapon;
				if (rnum == IT_AXE) {
					clientstring = " was ax-murdered by ";
					clientstring2 = "\n";
				}
				if (rnum == IT_SHOTGUN) {
					clientstring = " chewed on ";
					clientstring2 = "'s boomstick\n";
				}
				if (rnum == IT_SUPER_SHOTGUN) {
					clientstring = " ate 2 loads of ";
					clientstring2 = "'s buckshot\n";
				}
				if (rnum == IT_NAILGUN) {
					clientstring = " was nailed by ";
					clientstring2 = "\n";
				}
				if (rnum == IT_SUPER_NAILGUN) {
					clientstring = " was punctured by ";
					clientstring2 = "\n";
				}
				if (rnum == IT_GRENADE_LAUNCHER) {
					clientstring = " eats ";
					clientstring2 = "'s pineapple\n";
					if (targ.health < -40) {
						clientstring = " was gibbed by ";
						clientstring2 = "'s grenade\n";
					}
				}
				if (rnum == IT_ROCKET_LAUNCHER) {
					clientstring = " rides ";
					clientstring2 = "'s rocket\n";
					if (targ.health < -40) {
						clientstring = " was gibbed by ";
						clientstring2 = "'s rocket\n" ;
					}
				}
				if (rnum == IT_LIGHTNING) {
					clientstring = " accepts ";
					if (attacker.waterlevel > 1) clientstring2 = "'s discharge\n";
					else clientstring2 = "'s shaft\n";
				}
				bprint (targ.netname);
				bprint (clientstring);
				bprint (attacker.netname);
				bprint (clientstring2);
			}
			return;
		}
		else {
			targ.frags = targ.frags - 1;
			bprint (targ.netname);

			//-----------------------------------------------------------------
			// All the monster death messages are now defined in the monster QC
			// It is much easier to remember to add these with creating the
			// QC for each new monster than find/edit them here!
			//-----------------------------------------------------------------
				
			// Check for boss or monster flags
			if (attacker.bossflag > 0 || attacker.flags & FL_MONSTER) {
				if (attacker.deathstring != "") bprint (attacker.deathstring);
				else bprint(" was killed by Quake!\n");
				return;
			}

			// tricks and traps
			if (attacker.solid == SOLID_BSP && attacker != world) bprint (" was squished\n");
			else if (attacker.classtype == CT_EXPLO_BOX) bprint (" blew up\n");
			else if (attacker.classtype == CT_SPIKESHOOTER) bprint (" did not stick around\n");
			else if (attacker.classtype == CT_GRENADESHOOTER) bprint (" was pineappled\n");
			else if (attacker.classtype == CT_ROCKETSHOOTER) bprint (" was blasted\n");
			else if (attacker.classtype == CT_LIGHTSHOOTER) bprint (" was struck down\n");
			else if (attacker.classtype == CT_GASSHOOTER) bprint (" was burnt to a crisp\n");
			else if (attacker.classtype == CT_PENDULUM) bprint (" was cleaved in two\n");
			else if (attacker.classtype == CT_SAWBLADE) bprint (" was sliced to pieces\n");
			else if (attacker.classtype == CT_FIREBALL) bprint (" ate a lavaball\n");
			else if (attacker.classtype == CT_TRIGLEVEL) bprint (" tried to leave\n");

			// in-water deaths
			else if (targ.watertype == -3) {
				if (random() < 0.5) bprint (" sleeps with the fishes\n");
				else bprint (" sucks it down\n");
			}
			else if (targ.watertype == -4) {
				if (random() < 0.5) bprint (" gulped a load of slime\n");
				else bprint (" can't exist on slime alone\n");
			}
			else if (targ.watertype == -5) {
				if (targ.health < -15) bprint (" burst into flames\n");
				else if (random() < 0.5) bprint (" turned into hot slag\n");
				else bprint (" visits the Volcano God\n");
			}

			// Debuff deaths
			else if (targ.burning) bprint (" was burnt to a crisp\n");
			else if (targ.poisoned) bprint (" was poisoned\n");
			else if (targ.bleeding) bprint (" bled to death\n");

			// Special blocking of evil skill savegames
			else if(targ.deathtype == "loadingevil") {
				targ.deathtype = string_null;
				bprint (" is too EVIL to live again!\n");
			}
			
			// fell to their death?
			else if (targ.deathtype == "falling") {
				targ.deathtype = string_null;
				bprint (" fell to his death\n");
			}
			else if (targ.touchedvoid) {
				targ.deathtype = string_null;
				bprint (" touched the void\n");
			}
			else 
				// hell if I know; he's just dead!!!
				bprint (" is dead Jim!\n");
		}
	}
};
