/*======================================================================
 MOD CUSTOM SETTINGS
======================================================================*/
void() toggleautoaim;		// Toggle auto aim
void() togglezaware;		// Toggle Z aware monsters
void() togglefootstep;		// Toggle footstep sound (player/monster)
void() toggleliquiddmg;		// Toggle Monster Liquid damage
void() toggleshotgunproj;	// Toggle SG Proj/casing
void() toggleupgradeaxe;	// Toggle Axe Upgrade (inventory only)
void() toggleupgradessg;	// Toggle Shotgun Upgrade (inventory only)
void() toggleupgradelg;		// Toggle Lightning Upgrade (inventory only)
void() togglepixels;		// Toggle Texture modes

void() display_configflag;	// Display config flag
void() display_playinfo;	// Display Player information
void() display_version;		// Display MOD information
void() toggleaipath;		// Toggle AI path extra info
void() CycleParticleDebug;	// Cycle particle debug messages

void(float sigil_bit) givesigil;	// Testing only
void(float key_bit) givekey;		// Testing only

void() CycleWeaponCommand;
void() CycleWeaponReverseCommand;
void() CheatCommand;
void() SharpshooterCheat;
void() NailPiercerCheat;
void() EnvSuitCheat;
void() PentagramCheat;
void() InvisibleCheat;
void() QuadDamageCheat;

/*======================================================================
 Show MOD name and version
======================================================================*/
void() display_version =
{
	// Default return conditions (must be player)
	if ( !(self.flags & FL_CLIENT) ) return;
	
	self.impulse = 0;
	sprint(self,"\b[INFO]\b Arcane Dimensions (Arcadim) MOD v1.42P2\n");
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
	else if (self.impulse == 110) togglezaware();		// Toggle Z aware monsters
	else if (self.impulse == 115) togglepixels();		// Toggle texture modes
	else if (self.impulse == 120) togglefootstep();		// Toggle footstep sound
	else if (self.impulse == 125) toggleliquiddmg();	// Toggle liquid damage
	else if (self.impulse == 130) toggleshotgunproj();	// Toggle SG Proj/casing
	else if (self.impulse == 140) display_version();	// Display MOD config flag

	// Only works developer only)
	else if (self.impulse == 200) toggleupgradeaxe();	// Toggle Axe Upgrade
	else if (self.impulse == 205) toggleupgradessg();	// Toggle Shotgun Upgrade
	else if (self.impulse == 210) toggleupgradelg();	// Toggle Lightning Upgrade
	else if (self.impulse == 220) display_configflag();	// Display MOD config flag
	else if (self.impulse == 225) display_playinfo();	// Display Player information
	else if (self.impulse == 230) toggleaipath();		// Display AI path extra info
	else if (self.impulse == 235) CycleParticleDebug();	// Cycle particle debug

	else if (self.impulse == 240) givesigil(SVR_RUNE_ALL);	// Give all sigils to player
	else if (self.impulse == 241) givesigil(SVR_RUNE_KEY1);	// Give various sigil to player
	else if (self.impulse == 242) givesigil(SVR_RUNE_KEY2);	// Will be reset on map load
	else if (self.impulse == 243) givesigil(SVR_RUNE_KEY3);	// Mainly used for testing
	else if (self.impulse == 244) givesigil(SVR_RUNE_KEY4);

	else if (self.impulse == 245) givekey(IT_KEY1 + IT_KEY2);	// Both

	// Legacy cheat commands, should be developer 1 only ...
	else if (self.impulse == 9) CheatCommand();
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
	update_worldspawn(SVR_ITEMOFFSET, self.no_item_offset);
	update_worldspawn(SVR_ITEMROTATE, self.no_item_rotate);
	update_worldspawn(SVR_UPDAXE, self.upgrade_axe);
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
	if (developer == 0) return;

	dprint("\n\b[CONFIG]\b MOD Settings ("); 
	if (configflag & SVR_LIVE) dprint(ftos(configflag-SVR_LIVE));
	else dprint(ftos(configflag));
	if (configflag & SVR_LIVE) dprint(") L\n");
	else dprint(")\n");
	dprint("--------------------------------------\n");
	// Particle system
	if (query_configflag(SVR_PARTICLES)) dprint("+ Particle System enabled\n");
	else dprint("- Particle System disabled\n");
	// All new MOD weapons
	if (world.upgrade_axe < 0) dprint("W Axe Upg Remove on Worldspawn\n");
	else if (world.upgrade_axe > 0) dprint("W Axe Upg Added on Worldspawn\n");
	else if (query_temp1flag(SVR_UPDAXE)) dprint("* Axe Upgrade in quake.rc\n");
	else if (query_configflag(SVR_UPDAXE)) dprint("+ Axe Upgrade from inventory\n");
	else dprint("- NO Axe upgrade detected\n");

	if (world.upgrade_ssg < 0) dprint("W SSG Upg Remove on Worldspawn\n");
	else if (world.upgrade_ssg > 0) dprint("W SSG Upg Added on Worldspawn\n");
	else if (query_temp1flag(SVR_UPDSSG)) dprint("* SSG Upgrade in quake.rc\n");
	else if (query_configflag(SVR_UPDSSG)) dprint("+ SSG Upgrade from inventory\n");
	else dprint("- NO SSG upgrade detected\n");

	if (world.upgrade_lg < 0) dprint("W LG Upg Remove on Worldspawn\n");
	else if (world.upgrade_lg > 0) dprint("W LG Upg Added on Worldspawn\n");
	else if (query_temp1flag(SVR_UPDLG)) dprint("* LG Upgrade in quake.rc\n");
	else if (query_configflag(SVR_UPDLG)) dprint("+ LG Upgrade from inventory\n");
	else dprint("- NO LG upgrade detected\n");

	// New bullet projectile system
	if (query_configflag(SVR_PROJSHOTG)) dprint("- SG/SSG hitscan enabled\n");
	else dprint("+ SG/SSG projectiles enabled\n");

	// Items updates; origin points and random rotation
	if (query_configflag(SVR_ITEMOFFSET)) dprint("+ All items use center origin\n");
	else dprint("- All items use corner origin\n");
	if (query_configflag(SVR_ITEMROTATE)) dprint("- All items use entity angle key\n");
	else dprint("+ All items are randomly rotated\n");

	// General MOD settings
	if (query_configflag(SVR_AUTOAIM)) dprint("- Player weapon autoaim enabled\n");
	else dprint("+ Player weapon autoaim disabled\n");
	if (query_configflag(SVR_ZAWARE)) dprint("- Z Aware Monster combat disabled\n");
	else dprint("+ Z Aware Monster combat enabled\n");
	if (query_configflag(SVR_FOOTSTEP)) dprint("- footstep sounds disabled\n");
	else dprint("+ footstep sounds enabled\n");
	if (query_configflag(SVR_LIQDAM)) dprint("- monster liquid damage off\n");
	else dprint("+ monster liquid damage on\n");
	if (query_configflag(SVR_AIPATH)) dprint("- Path Corner Arrows disabled\n");
	else dprint("+ Path Corner Arrows enabled\n");

	// Mod fog / wateralpha settings
	if (query_configflag(SVR_NOFOGCMDS)) dprint("- Global fog system disabled\n");
	else if (fog_active && fog_control) {
		dprint("+ Gfog ("); 
		lftos(self, fog_control.fog_currden, 1,3, BUFFER_DPRINT); dprint(")(");
		lftos(self, fog_control.fog_currcol_x, 1,3, BUFFER_DPRINT); dprint(" ");
		lftos(self, fog_control.fog_currcol_y, 1,3, BUFFER_DPRINT); dprint(" ");
		lftos(self, fog_control.fog_currcol_z, 1,3, BUFFER_DPRINT); dprint(")\n");
	}
	else dprint("* Global fog default not defined\n");
	if (liquid_alpha != 1) { 
		dprint("+ Water Alpha has changed ("); 
		lftos(self, liquid_alpha, 0,3, BUFFER_DPRINT); dprint(")\n");
	}
	if (map_gravity != DEF_GRAVITY) { 
		dprint("+ Map gravity has changed ("); 
		dprint(ftos(map_gravity)); dprint(")\n");
	}
	dprint("--------------------------------------\n");
};

/*======================================================================
 Prints origin and mangle to console screen
 Useful for creating good locations for intermission camera's
======================================================================*/
void() display_playinfo =
{
	// Default return conditions (must be player)
	if ( !(self.flags & FL_CLIENT) ) return;
	if (developer == 0) {
		sprint(self,"\b[IMPULSE]\b Only works in developer mode!\n");
		return;
	}
	
	self.impulse = 0;
	sprint(self,"\b[INFO]\b Org ("); sprint(self,vtos(self.origin));
	sprint(self,") Ang ("); sprint(self,vtos(self.v_angle));
	sprint(self,")\n");
};

/*======================================================================
 Give the player various sigils (serverflag)
 Give the player silver/gold keys
======================================================================*/
void(float sigil_bit) givesigil =
{
	if (developer == 0) {
		sprint(self,"\b[IMPULSE]\b Only works in developer mode!\n");
		return;
	}

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
	if (developer == 0) {
		sprint(self,"\b[IMPULSE]\b Only works in developer mode!\n");
		return;
	}

	dprint("\b[KEYS]\b Inventory updated ("); 
	dprint(ftos(key_bit)); dprint(")\n");
	if (key_bit & IT_KEY1) self.items = self.items | IT_KEY1;
	if (key_bit & IT_KEY2) self.items = self.items | IT_KEY2;
};

/*======================================================================
 TOGGLE auto aim feature (default OFF)
======================================================================*/
void() updateautoaim =
{
	if (query_configflag(SVR_AUTOAIM)) cvar_set("sv_aim", "0.93");
	else cvar_set("sv_aim", "1.00");
};

//----------------------------------------------------------------------
void() toggleautoaim =
{
	// Default return conditions (must be player)
	if ( !(self.flags & FL_CLIENT) ) return;
	
	self.impulse = 0;
	
	// Toggle the state of the console variable using the server flag
	if (query_configflag(SVR_AUTOAIM)) update_configflag(SVR_AUTOAIM,FALSE);
	else update_configflag(SVR_AUTOAIM,TRUE);
	
	updateautoaim();
	sprint(self, "\b[Impulse]\b Auto aim state ("); 
	if (query_configflag(SVR_AUTOAIM)) sprint(self, "ON)\n");
	else sprint(self, "OFF)\n");
};

/*======================================================================
 TOGGLE Z aware monsters (default ON)
======================================================================*/
void() togglezaware =
{	
	// Default return conditions (must be player)
	if ( !(self.flags & FL_CLIENT) ) return;
	
	self.impulse = 0;
	
	// Toggle the state of the console variable using the server flag
	if (query_configflag(SVR_ZAWARE)) update_configflag(SVR_ZAWARE, FALSE);
	else update_configflag(SVR_ZAWARE, TRUE);

	sprint(self, "\b[Impulse]\b Z Aware Monsters ("); 
	if (query_configflag(SVR_ZAWARE)) sprint(self, "Disabled)\n");
	else sprint(self, "Enabled)\n");
};

/*======================================================================
 TOGGLE footsteps (default ON)
======================================================================*/
void() togglefootstep =
{
	// Default return conditions (must be player)
	if ( !(self.flags & FL_CLIENT) ) return;
	
	self.impulse = 0;
	
	// Toggle the state of the console variable using the server flag
	if (query_configflag(SVR_FOOTSTEP)) update_configflag(SVR_FOOTSTEP, FALSE);
	else update_configflag(SVR_FOOTSTEP, TRUE);
	
	sprint(self, "\b[Impulse]\b footsteps ("); 
	if (query_configflag(SVR_FOOTSTEP)) sprint(self, "OFF)\n");
	else sprint(self, "ON)\n");
};

/*======================================================================
 TOGGLE Liquid Damage (default ON)
======================================================================*/
void() toggleliquiddmg =
{
	// Default return conditions (must be player)
	if ( !(self.flags & FL_CLIENT) ) return;
	
	self.impulse = 0;
	
	// Toggle the state of the console variable using the server flag
	if (query_configflag(SVR_LIQDAM)) update_configflag(SVR_LIQDAM, FALSE);
	else update_configflag(SVR_LIQDAM, TRUE);
	
	sprint(self, "\b[Impulse]\b Monster Liquid Damage ("); 
	if (query_configflag(SVR_LIQDAM)) sprint(self, "OFF)\n");
	else sprint(self, "ON)\n");
};

/*======================================================================
 TOGGLE AI path extra info (default ON)
======================================================================*/
void() toggleaipath =
{
	// Default return conditions (must be player)
	if ( !(self.flags & FL_CLIENT) ) return;
	
	self.impulse = 0;
	
	// Toggle the state of the console variable using the server flag
	if (query_configflag(SVR_AIPATH)) update_configflag(SVR_AIPATH, FALSE);
	else update_configflag(SVR_AIPATH, TRUE);
	
	sprint(self, "\b[Impulse]\b Path Corner Arrows ("); 
	if (query_configflag(SVR_AIPATH)) sprint(self, "OFF)\n");
	else sprint(self, "ON)\n");
	sprint(self, "Reload / Quickload map to see changes!\n");
};

/*======================================================================
 Toggle through particle debug messages
======================================================================*/
void() CycleParticleDebug =
{
	// Default return conditions (must be player)
	if ( !(self.flags & FL_CLIENT) ) return;
	
	self.impulse = 0;
	
	part_debug = part_debug + 1;
	if (part_debug > PARTICLE_DEBUGMAX) part_debug = 0;

	sprint(self, "\b[Impulse]\b Particle debug level (");
	sprint(self, ftos(part_debug));
	sprint(self, ")\n");
};

/*======================================================================
 TOGGLE SG Proj/casing (default OFF)
======================================================================*/
void() toggleshotgunproj =
{
	// Default return conditions (must be player)
	if ( !(self.flags & FL_CLIENT) ) return;
	
	self.impulse = 0;
	// Toggle the state of the console variable using the server flag
	if (query_configflag(SVR_PROJSHOTG)) update_configflag(SVR_PROJSHOTG, FALSE);
	else update_configflag(SVR_PROJSHOTG, TRUE);
	
	sprint(self, "\b[Impulse]\b Shotgun Projectiles ("); 
	if (query_configflag(SVR_PROJSHOTG)) sprint(self, "OFF)\n");
	else sprint(self, "ON)\n");
};

/*======================================================================
 TOGGLE Axe Upgrade
======================================================================*/
void() toggleupgradeaxe =
{
	// Default return conditions (must be player and developer)
	if ( !(self.flags & FL_CLIENT) ) return;
	if (developer == 0) {
		sprint(self,"\b[IMPULSE]\b Only works in developer mode!\n");
		return;
	}
	
	self.impulse = 0;
	if (self.moditems & IT_UPGRADE_AXE) {
		dprint("\b[Impulse]\b Shadow Axe Removed\n"); 
		self.moditems = self.moditems - IT_UPGRADE_AXE;
	}
	else {
		dprint("\b[Impulse]\b Shadow Axe Added\n"); 
		self.moditems = self.moditems | IT_UPGRADE_AXE;
	}
		
	if (self.weapon == IT_AXE) W_SetCurrentAmmo(self);
};

/*======================================================================
 TOGGLE Super Shotgun Upgrade
======================================================================*/
void() toggleupgradessg =
{
	// Default return conditions (must be player and developer)
	if ( !(self.flags & FL_CLIENT) ) return;
	if (developer == 0) {
		sprint(self,"\b[IMPULSE]\b Only works in developer mode!\n");
		return;
	}
	
	self.impulse = 0;
	if (self.moditems & IT_UPGRADE_SSG) {
		dprint("\b[Impulse]\b Widowmaker Shotgun Removed\n"); 
		self.moditems = self.moditems - IT_UPGRADE_SSG;
	}
	else {
		dprint("\b[Impulse]\b Widowmaker Shotgun Added\n"); 
		self.moditems = self.moditems | IT_UPGRADE_SSG;
	}
		
	// make sure player VIEW model is up to date
	if (self.weapon == IT_SUPER_SHOTGUN) W_SetCurrentAmmo(self);
};

/*======================================================================
 TOGGLE Lightning Gun Upgrade
======================================================================*/
void() toggleupgradelg =
{
	// Default return conditions (must be player and developer)
	if ( !(self.flags & FL_CLIENT) ) return;
	if (developer == 0) {
		sprint(self,"\b[IMPULSE]\b Only works in developer mode!\n");
		return;
	}
	
	self.impulse = 0;
	if (self.moditems & IT_UPGRADE_LG) {
		dprint("\b[Impulse]\b Plasma Gun Removed\n"); 
		self.moditems = self.moditems - IT_UPGRADE_LG;
	}
	else {
		dprint("\b[Impulse]\b Plasma Gun Added\n"); 
		self.moditems = self.moditems | IT_UPGRADE_LG;
	}
		
	// make sure player VIEW model is up to date
	if (self.weapon == IT_LIGHTNING) W_SetCurrentAmmo(self);
};

/*======================================================================
 TOGGLE texture pixel mode (linear = blurry, nearest = crispy)
======================================================================*/
void() togglepixels =
{	
	// Default return conditions (must be player)
	if ( !(self.flags & FL_CLIENT) ) return;
	
	self.impulse = 0;
	sprint(self, "\b[SETTINGS]\b texture filtering ("); 
	if (pixelmode == 1) {
		pixelmode = 0;
		stuffcmd(self, "\ngl_texturemode GL_LINEAR_MIPMAP_LINEAR\n");
		sprint(self, "blurry)\n");
	}
	else {
		pixelmode = 1;
		stuffcmd(self, "\ngl_texturemode GL_NEAREST_MIPMAP_LINEAR\n");
		sprint(self, "crispy)\n");
	}
};

/*======================================================================
 IMPULSE 9
 Gives the player certain weapons and ammo (CHEAT COMMAND)
======================================================================*/
void() CheatCommand =
{
	if (intermission_running) return;		// intermission or finale
	if (deathmatch || coop) return;

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
 IMPULSE 250
======================================================================*/
void() SharpshooterCheat =
{
	if (intermission_running) return;		// intermission or finale
	if (deathmatch || coop) return;

	dprint("\b[Impulse 250]\b Sharp Shooter Cheat\n");
	self.impulse = 0;
	self.sharpshoot_time = 1;
	self.sharpshoot_finished = time + POWERUP_TIMER;
	self.items = self.items | IT_QUAD;
	self.moditems = self.moditems | IT_ARTSHARP;
};

/*======================================================================
 IMPULSE 251
======================================================================*/
void() NailPiercerCheat =
{
	if (intermission_running) return;		// intermission or finale
	if (deathmatch || coop) return;

	dprint("\b[Impulse 251]\b Nail Piercer Cheat\n");
	self.impulse = 0;
	self.nailpiercer_time = 1;
	self.nailpiercer_finished = time + POWERUP_TIMER;
	self.items = self.items | IT_QUAD;
	self.moditems = self.moditems | IT_ARTPIERCE;
};

/*======================================================================
 IMPULSE 252
======================================================================*/
void() EnvSuitCheat =
{
	if (intermission_running) return;		// intermission or finale
	if (deathmatch || coop) return;

	dprint("\b[Impulse 252]\b Environmental Suit Cheat\n");
	self.impulse = 0;
	self.rad_time = 1;
	self.radsuit_finished = time + POWERUP_TIMER;
	self.items = self.items | IT_SUIT;
};

/*======================================================================
 IMPULSE 253
======================================================================*/
void() PentagramCheat =
{
	if (intermission_running) return;		// intermission or finale
	if (deathmatch || coop) return;

	dprint("\b[Impulse 253]\b Pentagram of Protection Cheat\n");
	self.impulse = 0;
	self.invincible_time = 1;
	self.invincible_finished = time + POWERUP_TIMER;
	self.items = self.items | IT_INVULNERABILITY;
};

/*======================================================================
 IMPULSE 254
======================================================================*/
void() InvisibleCheat =
{
	if (intermission_running) return;		// intermission or finale
	if (deathmatch || coop) return;

	dprint("\b[Impulse 254]\b Ring of Shadows Cheat\n");
	self.impulse = 0;
	self.invisible_time = 1;
	self.invisible_finished = time + POWERUP_TIMER;
	self.items = self.items | IT_INVISIBILITY;
};

/*======================================================================
 IMPULSE 255
======================================================================*/
void() QuadDamageCheat =
{
	if (intermission_running) return;		// intermission or finale
	if (deathmatch || coop) return;

	dprint("\b[Impulse 255]\b Quad Damage Cheat\n");
	self.impulse = 0;
	self.super_time = 1;
	self.super_damage_finished = time + POWERUP_TIMER;
	self.items = self.items | IT_QUAD;
};
