/*======================================================================
 Player/client debug info functions
======================================================================*/
entity ammocontrol;			// Stats controller

// Ammo controller phases
float AC_PHASE0 = 0;		// Ready to start
float AC_PHASE1 = 1;		// Weapon stats
float AC_PHASE2 = 2;		// Ammo stats
float AC_PHASE3 = 3;		// Weapon stats
float AC_PHASE4 = 4;		// Armour + HP stats
float AC_PHASE5 = 5;		// Final stats table

float AC_AMMOQTY = 0;		// Sub total
float AC_SMALLBOX = 1;		// Total small ammo boxes
float AC_LARGEBOX = 2;		// Total large ammo boxes
float AC_RESPAWN = 3;		// Total from respawning boxes
float AC_BACKPACK = 4;		// Total from backpacks
float AC_WEAPON = 5;		// Total from weapon pickups
float AC_MONSTER = 6;		// Total from monsters
float AC_WORLDSPN = 7;		// Duplicate + Capped worldspawn
float AC_SHOTSTART = 8;		// Shotgun start weapon detection
float AC_AMMOFINAL = 9;		// Final total (0+4+5+6+7)

float MAX_AMMOARRAY = 10;	// Total of S+N+R+C sets
float MAX_WPNDISP = 25;		// Limit of Weapon display
float MAX_AMMODISP = 400;	// Limit of Ammo display
float NOHP_MONARRAY = 0;	// Health for special monsters (boss or >9999)

float MAX_MONCOUNT = 400;	// limit of monster display (display_monsleft)
float MAX_MONARRAY = 50;	// Size of monster array (display_monsqty)

//----------------------------------------------------------------------
// Define all arrays for Ammo and Monster Stats
// 0=Total found, 1=Small box, 2=Large box
// 3=Worldspawn, 4=Player, 5=Backpacks, 6=Monsters
// 7=Final (0+3+4+5+6)
//----------------------------------------------------------------------
float shellqty[MAX_AMMOARRAY], nailqty[MAX_AMMOARRAY];
float rockqty[MAX_AMMOARRAY], cellqty[MAX_AMMOARRAY];
// Totals for weapon, ammo, and monsters
float as_wpnqty, as_ammoqty, as_monqty, as_monlist;
float as_armgrnqty, as_armyelqty, as_armredqty, as_armhpqty;
float as_hp15qty, as_hp25qty, as_hp100qty, as_hpqty;
float as_backgrnqty, as_backyelqty, as_backredqty; 
float as_hpsec, as_backarmqty, as_backarmsec, as_hpfinal;
float as_nightonly, as_cooponly, as_backammo;
float as_monzombie, as_mondelay, as_monnocount;
float as_artsuit, as_artpent, as_artinv, as_artquad;
float as_finalammo, as_zombiehp, as_finalmonhp; 

// Forward compiler references
void() ammostats_phase1;
void() ammostats_phase2;
void() ammostats_phase3;
void() ammostats_phase4;
void() ammostats_phase5;

//----------------------------------------------------------------------
void(entity targ, float ammoqty, string zero10, string zero100, string zero1000, string zero10000, string zero100000) zerofill_number =
{
	// Cap number based on strings
	if (ammoqty > 99999 && zero100000 == "") ammoqty = 99999;
	if (ammoqty > 9999 && zero10000 == "") ammoqty = 9999;
	if (ammoqty > 999 && zero1000 == "") ammoqty = 999;
	if (ammoqty > 99 && zero100 == "") ammoqty = 99;
	// Zero fill based on strings existing
	if (ammoqty < 100000 && zero100000 != "") sprint(targ, zero100000);
	if (ammoqty < 10000 && zero10000 != "") sprint(targ, zero10000);
	if (ammoqty < 1000 && zero1000 != "") sprint(targ, zero1000);
	if (ammoqty < 100 && zero100 != "") sprint(targ, zero100);
	if (ammoqty < 10 && zero10 != "") sprint(targ, zero10);
	sprint(targ, ftos(ammoqty));	
};

//======================================================================
void() display_ammostats =
{
	local float statloop;
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only

	// flush keyboard buffer
	self.impulse = 0;
	// Has the ammo controller been spawned yet?
	if (!ammocontrol) ammocontrol = spawn();
	// What state is the controller in?
	if (ammocontrol.state == AC_PHASE0) {
		// Reset global array values
		statloop = 0;
		while(statloop < MAX_AMMOARRAY) {
			shellqty[statloop] = nailqty[statloop] = 0;
			rockqty[statloop] = cellqty[statloop] = 0;
			statloop = statloop + 1;
		}

		// The world ammo quantities can be over max holdable values
		// But these values are given to the player on spawn and capped!
		// There is no point using any of the excess qty for the stats
		if (world.ammo_shells > AMMO_MAXSHELLS) shellqty[AC_WORLDSPN] = AMMO_MAXSHELLS;
		else shellqty[AC_WORLDSPN] = world.ammo_shells;
		if (world.ammo_nails > AMMO_MAXNAILS) nailqty[AC_WORLDSPN] = AMMO_MAXNAILS;
		else nailqty[AC_WORLDSPN] = world.ammo_nails;
		if (world.ammo_rockets > AMMO_MAXROCKETS) rockqty[AC_WORLDSPN] = AMMO_MAXROCKETS;
		else rockqty[AC_WORLDSPN] = world.ammo_rockets;
		if (world.ammo_cells > AMMO_MAXCELLS) cellqty[AC_WORLDSPN] = AMMO_MAXCELLS;
		else cellqty[AC_WORLDSPN] = world.ammo_cells;
		
		// Self/owner should be player
		ammocontrol.owner = self;
		// next stage of stats
		ammocontrol.state = AC_PHASE1;
		ammocontrol.think = ammostats_phase1;
		ammocontrol.nextthink = time + 0.1;
	}
};

//----------------------------------------------------------------------
// PHASE 1 : WEAPON stats
//----------------------------------------------------------------------
void() ammostats_phase1 =
{
	local float as_shadaxe, as_windowmaker, as_plasmagun;
	local entity entlist;
	//----------------------------------------------------------------
	// List of all WEAPON pickups in the map
	//----------------------------------------------------------------
	as_wpnqty = as_shadaxe = as_plasmagun = as_windowmaker = 0;
	as_artsuit = as_artpent = as_artinv = as_artquad = 0;

	//                    1234567890123456789012345678901234567890
	sprint(self.owner, "\b[--  Ammo and Monster Statistics  --]\b\n"); 
	sprint(self.owner,   "--------------------------------------\n");
	sprint(self.owner, "\bNo Type Ammo Weapon Name\b\n");
	//                    xx xxxx  xxx x---------------------x
	// Start from beginning of entity list, world!
	entlist = nextent(world);
	// Keep looping through entity list
	while (entlist) {
		//----------------------------------------------------------------
		// Only interested in weapon pickups
		if (entlist.flags & FL_ITEM && entlist.classgroup == CG_WEAPON) {
			as_wpnqty = as_wpnqty + 1;

			if (entlist.classtype == CT_SHOTGUN || entlist.classtype == CT_SUPER_SHOTGUN 
				|| entlist.classtype == CT_UPGRADE_SSG) {
				shellqty[AC_WEAPON] = shellqty[AC_WEAPON] + entlist.aflag;
				shellqty[AC_SHOTSTART] = TRUE;
				// Reached display limit?
				if (as_wpnqty <= MAX_WPNDISP) {
					zerofill_number(self.owner, as_wpnqty, "0", "", "", "", "");
					sprint(self.owner, " SHEL  ");
					zerofill_number(self.owner, entlist.aflag, "0", " ", "", "", "");
					// Display weapon name
					sprint(self.owner, " "); sprint(self.owner, entlist.netname);
					sprint(self.owner, "\n");
					// Check for zombie damage alternative
					if (entlist.classtype == CT_UPGRADE_SSG) as_windowmaker = TRUE;
				}
			}
			else if (entlist.classtype == CT_NAILGUN || entlist.classtype == CT_SUPER_NAILGUN) {
				nailqty[AC_WEAPON] = nailqty[AC_WEAPON] + entlist.aflag;
				nailqty[AC_SHOTSTART] = TRUE;
				// Reached display limit?
				if (as_wpnqty <= MAX_WPNDISP) {
					zerofill_number(self.owner, as_wpnqty, "0", "", "", "", "");
					sprint(self.owner, " NAIL  ");
					zerofill_number(self.owner, entlist.aflag, "0", " ", "", "", "");
					// Display weapon name
					sprint(self.owner, " "); sprint(self.owner, entlist.netname);
					sprint(self.owner, "\n");
				}
			}
			else if (entlist.classtype == CT_GRENADE_LAUNCHER || entlist.classtype == CT_ROCKET_LAUNCHER) {
				rockqty[AC_WEAPON] = rockqty[AC_WEAPON] + entlist.aflag;
				rockqty[AC_SHOTSTART] = TRUE;
				// Reached display limit?
				if (as_wpnqty <= MAX_WPNDISP) {
					zerofill_number(self.owner, as_wpnqty, "0", "", "", "", "");
					sprint(self.owner, " ROCK  ");
					zerofill_number(self.owner, entlist.aflag, "0", " ", "", "", "");
					// Display weapon name
					sprint(self.owner, " "); sprint(self.owner, entlist.netname);
					sprint(self.owner, "\n");
				}
			}
			else if (entlist.classtype == CT_LIGHTNING || entlist.classtype == CT_UPGRADE_LG) {
				cellqty[AC_WEAPON] = cellqty[AC_WEAPON] + entlist.aflag;
				cellqty[AC_SHOTSTART] = TRUE;
				// Reached display limit?
				if (as_wpnqty <= MAX_WPNDISP) {
					zerofill_number(self.owner, as_wpnqty, "0", "", "", "", "");
					sprint(self.owner, " CELL  ");
					zerofill_number(self.owner, entlist.aflag, "0", " ", "", "", "");
					// Display weapon name
					sprint(self.owner, " "); sprint(self.owner, entlist.netname);
					sprint(self.owner, "\n");
					// Check for zombie damage alternative
					if (entlist.classtype == CT_UPGRADE_LG) as_plasmagun = TRUE;
				}
			}
			// Report the shadow axe (no ammo interest)
			else if (entlist.classtype == CT_UPGRADE_AXE && as_wpnqty <= MAX_WPNDISP) {
				zerofill_number(self.owner, as_wpnqty, "0", "", "", "", "");
				sprint(self.owner, "   --   -- Shadow Axe\n");
				// Alternative way to deal with zombies
				as_shadaxe = TRUE;
			}
			else {
				// unknown weapon type
				if (as_wpnqty <= MAX_WPNDISP) 
					zerofill_number(self.owner, as_wpnqty, "0", "", "", "", "");
					sprint(self.owner, "   --   -- Unknown Weapon\n");
			}
		}
	
		//----------------------------------------------------------------
		// Only interested in artifact items
		if (entlist.flags & FL_ITEM && entlist.classgroup == CG_ARTIFACT) {	
			if (entlist.classtype == CT_ARTSUIT)
				as_artsuit = as_artsuit + 1;
			else if (entlist.classtype == CT_ARTPENT)
				as_artpent = as_artpent + 1;
			else if (entlist.classtype == CT_ARTINVS)
				as_artinv = as_artinv + 1;
			else if (entlist.classtype == CT_ARTQUAD)
				as_artquad = as_artquad + 1;
		}

		// Keep search through ALL of the entity list
		entlist = nextent(entlist);
	}
	// Any ITEM weapons found?
	if (as_wpnqty == 0) sprint(self.owner, "NO weapon pickups found!\n");
	// Warn mappers that the weapon display was limited
	// Cannot display too many items, will hit memory issues
	if (as_wpnqty > MAX_WPNDISP) {
		sprint(self.owner, " * Found ("); sprint(self.owner, ftos(as_wpnqty));
		sprint(self.owner, ") showing ("); sprint(self.owner, ftos(MAX_WPNDISP));
		sprint(self.owner, ") only!\n");
	}
	if (as_shadaxe || as_plasmagun || as_windowmaker)
		sprint(self.owner, " * Alt weapons exist to kill zombies!\n");

	// next stage of stats
	ammocontrol.state = AC_PHASE2;
	ammocontrol.think = ammostats_phase2;
	ammocontrol.nextthink = time + 0.1;
};

//----------------------------------------------------------------------
// PHASE 2 : AMMO boxes + BACKPACK stats
//----------------------------------------------------------------------
void() ammostats_phase2 =
{
	local float mixedval;
	local entity entlist;
	//----------------------------------------------------------------
	// List of all AMMO pickups in the map
	//----------------------------------------------------------------
	as_wpnqty = as_backammo = 0;
	//                    1234567890123456789012345678901234567890
	sprint(self.owner,   "--------------------------------------\n");
	sprint(self.owner, "\b No Type  Qty L X R Ammo Name\b\n");
	//                    xxx xxxxx xxx x x x x---------------------x
	// Start from beginning of entity list, world!
	entlist = nextent(world);
	// Keep looping through entity list
	while (entlist) {
		// Only interested in ammo items
		if (entlist.flags & FL_ITEM && entlist.classgroup == CG_AMMOITEM) {
			if (entlist.classtype == CT_AMMOSHELLS) {
				// Update ammo stats
				as_ammoqty = as_ammoqty + 1;
				shellqty[AC_AMMOQTY] = shellqty[AC_AMMOQTY] + entlist.aflag;
				if (entlist.spawnflags & A_LARGE) shellqty[AC_LARGEBOX] = shellqty[AC_LARGEBOX] + 1;
				else shellqty[AC_SMALLBOX] = shellqty[AC_SMALLBOX] + 1;
				if (entlist.spawnflags & ITEM_RESPAWN || entlist.use == SUB_regen)
					shellqty[AC_RESPAWN] = shellqty[AC_RESPAWN] + entlist.aflag;
				
				// Reached display limit?
				if (as_ammoqty <= MAX_AMMODISP) {
					zerofill_number(self.owner, as_ammoqty, "0", "0", "", "", "");
					sprint(self.owner, " SHELL ");
					zerofill_number(self.owner, entlist.aflag, "0", " ", "", "", "");
					// Size of ammo
					if (entlist.spawnflags & A_LARGE) sprint(self.owner, " Y");
					else sprint(self.owner, " -");
					// Extra lid attachment
					if (entlist.spawnflags & A_LID) sprint(self.owner, " Y");
					else sprint(self.owner, " -");
					// Respawn option
					if (entlist.spawnflags & ITEM_RESPAWN) sprint(self.owner, " Y ");
					else sprint(self.owner, " - ");
					// Display ammo name
					sprint(self.owner, entlist.netname);
					sprint(self.owner, "\n");
				}
			}
			else if (entlist.classtype == CT_AMMONAILS) {
				// Update ammo stats
				as_ammoqty = as_ammoqty + 1;
				nailqty[AC_AMMOQTY] = nailqty[AC_AMMOQTY] + entlist.aflag;
				if (entlist.spawnflags & A_LARGE) nailqty[AC_LARGEBOX] = nailqty[AC_LARGEBOX] + 1;
				else nailqty[AC_SMALLBOX] = nailqty[AC_SMALLBOX] + 1;
				if (entlist.spawnflags & ITEM_RESPAWN || entlist.use == SUB_regen)
					nailqty[AC_RESPAWN] = nailqty[AC_RESPAWN] + entlist.aflag;
				
				// Reached display limit?
				if (as_ammoqty <= MAX_AMMODISP) {
					zerofill_number(self.owner, as_ammoqty, "0", "0", "", "", "");
					sprint(self.owner, " NAIL  ");
					zerofill_number(self.owner, entlist.aflag, "0", " ", "", "", "");
					// Size of ammo
					if (entlist.spawnflags & A_LARGE) sprint(self.owner, " Y");
					else sprint(self.owner, " -");
					// Extra lid attachment
					if (entlist.spawnflags & A_LID) sprint(self.owner, " Y");
					else sprint(self.owner, " -");
					// Respawn option
					if (entlist.spawnflags & ITEM_RESPAWN) sprint(self.owner, " Y ");
					else sprint(self.owner, " - ");
					// Display ammo name
					sprint(self.owner, entlist.netname);
					sprint(self.owner, "\n");
				}
			}
			else if (entlist.classtype == CT_AMMOROCKETS) {
				// Update ammo stats
				as_ammoqty = as_ammoqty + 1;
				rockqty[AC_AMMOQTY] = rockqty[AC_AMMOQTY] + entlist.aflag;
				if (entlist.spawnflags & A_LARGE) rockqty[AC_LARGEBOX] = rockqty[AC_LARGEBOX] + 1;
				else rockqty[AC_SMALLBOX] = rockqty[AC_SMALLBOX] + 1;
				if (entlist.spawnflags & ITEM_RESPAWN || entlist.use == SUB_regen)
					rockqty[AC_RESPAWN] = rockqty[AC_RESPAWN] + entlist.aflag;
				
				// Reached display limit?
				if (as_ammoqty <= MAX_AMMODISP) {
					zerofill_number(self.owner, as_ammoqty, "0", "0", "", "", "");
					sprint(self.owner, " ROCKT ");
					zerofill_number(self.owner, entlist.aflag, "0", " ", "", "", "");
					// Size of ammo
					if (entlist.spawnflags & A_LARGE) sprint(self.owner, " Y");
					else sprint(self.owner, " -");
					// Extra frame setup
					if (entlist.frame_box != 0) sprint(self.owner, " Y");
					else sprint(self.owner, " -");
					// Respawn option
					if (entlist.spawnflags & ITEM_RESPAWN) sprint(self.owner, " Y ");
					else sprint(self.owner, " - ");
					// Display ammo name
					sprint(self.owner, entlist.netname);
					sprint(self.owner, "\n");
				}
			}
			else if (entlist.classtype == CT_AMMOCELLS) {
				// Update ammo stats
				as_ammoqty = as_ammoqty + 1;
				cellqty[AC_AMMOQTY] = cellqty[AC_AMMOQTY] + entlist.aflag;
				if (entlist.spawnflags & A_LARGE) cellqty[AC_LARGEBOX] = cellqty[AC_LARGEBOX] + 1;
				else cellqty[AC_SMALLBOX] = cellqty[AC_SMALLBOX] + 1;
				if (entlist.spawnflags & ITEM_RESPAWN || entlist.use == SUB_regen)
					cellqty[AC_RESPAWN] = cellqty[AC_RESPAWN] + entlist.aflag;
				
				// Reached display limit?
				if (as_ammoqty <= MAX_AMMODISP) {
					zerofill_number(self.owner, as_ammoqty, "0", "0", "", "", "");
					sprint(self.owner, " CELL  ");
					zerofill_number(self.owner, entlist.aflag, "0", " ", "", "", "");
					// Size of ammo
					if (entlist.spawnflags & A_LARGE) sprint(self.owner, " Y");
					else sprint(self.owner, " -");
					// Extra frame setup
					if (entlist.frame_box != 0) sprint(self.owner, " Y");
					else sprint(self.owner, " -");
					// Respawn option
					if (entlist.spawnflags & ITEM_RESPAWN) sprint(self.owner, " Y ");
					else sprint(self.owner, " - ");
					// Display ammo name
					sprint(self.owner, entlist.netname);
					sprint(self.owner, "\n");
				}
			}
			// Fixed ammo setup? (count set = random)
			else if (entlist.classtype == CT_AMMOITEMPACK && entlist.count == 0) {
				// Reset counters
				mixedval = 0;
				// Check for any ammo in backpack?
				if (entlist.ammo_shells > 0) mixedval = mixedval + 1;
				if (entlist.ammo_nails > 0) mixedval = mixedval + 1;
				if (entlist.ammo_rockets > 0) mixedval = mixedval + 1;
				if (entlist.ammo_cells > 0) mixedval = mixedval + 1;
				// Ammo found?
				if (mixedval > 0) {
					// Update ammo stats
					as_ammoqty = as_ammoqty + 1;
					as_backammo = TRUE;
					// Record backpack ammo separately
					shellqty[AC_BACKPACK]= shellqty[AC_BACKPACK]+ entlist.ammo_shells;
					nailqty[AC_BACKPACK] = nailqty[AC_BACKPACK] + entlist.ammo_nails;
					rockqty[AC_BACKPACK] = rockqty[AC_BACKPACK] + entlist.ammo_rockets;
					cellqty[AC_BACKPACK] = cellqty[AC_BACKPACK] + entlist.ammo_cells;

					// Reached display limit?
					if (as_ammoqty <= MAX_AMMODISP) {
						zerofill_number(self.owner, as_ammoqty, "0", "0", "", "", "");
						sprint(self.owner, " BACKP S=");
						zerofill_number(self.owner, entlist.ammo_shells, "0", "0", "", "", "");
						sprint(self.owner, " N=");
						zerofill_number(self.owner, entlist.ammo_nails, "0", "0", "", "", "");
						sprint(self.owner, " R=");
						zerofill_number(self.owner, entlist.ammo_rockets, "0", "0", "", "", "");
						sprint(self.owner, " C=");
						zerofill_number(self.owner, entlist.ammo_cells, "0", "0", "", "", "");
						sprint(self.owner, "\n");	
					}
				}
			}
		}
		// Keep search through ALL of the entity list
		entlist = nextent(entlist);
	}
	// ERROR = AMMO items found?
	if (as_ammoqty == 0) {
		sprint(self.owner, "--------------------------------------\n");
		sprint(self.owner, "\b[ERROR]\b No Ammo ITEMS found!\n");
		sprint(self.owner, " * Cannot create Ammo & Monster Stats!\n\n");
		ammocontrol.state = AC_PHASE0;
		return;
	}
	// Warn mappers that the ammo display was limited
	// Cannot display too many items, will hit memory issues
	if (as_ammoqty > MAX_AMMODISP) {
		sprint(self.owner, " * Found ("); sprint(self.owner, ftos(as_ammoqty));
		sprint(self.owner, ") showing ("); sprint(self.owner, ftos(MAX_AMMODISP));
		sprint(self.owner, ") only\n");
	}
	// next stage of stats
	ammocontrol.state = AC_PHASE3;
	ammocontrol.think = ammostats_phase3;
	ammocontrol.nextthink = time + 0.1;
};

//----------------------------------------------------------------------
// Display MONSTER Summary for the map
//----------------------------------------------------------------------
void(entity targ) ammostats_monsummary =
{
	//              1234567890123456789012345678901234567890
	sprint(targ,   "======================================\n");
	sprint(targ, "\bMonstrs Qty NoC Dly +NM +CO Zomb    HP\b\n");
	//              Total  xxxx xxx xxx xxx xxx xxx xxxxxx

	sprint(targ, "Total   ");
	zerofill_number(targ, as_monqty, " ", " ", "", "", "");
	sprint(targ, " "); 
	zerofill_number(targ, as_monnocount, " ", " ", "", "", "");
	sprint(targ, " "); 
	zerofill_number(targ, as_mondelay, " ", " ", "", "", "");
	sprint(targ, " "); 
	zerofill_number(targ, as_nightonly, " ", " ", "", "", "");
	sprint(targ, " "); 
	zerofill_number(targ, as_cooponly, " ", " ", "", "", "");
	sprint(targ, " "); 
	zerofill_number(targ, as_monzombie, " ", " ", "", "", "");
	sprint(targ, " "); 
	zerofill_number(targ, as_finalmonhp, "0", "0", " ", " ", " ");
	sprint(targ, "\n"); 
};

//----------------------------------------------------------------
// Display ARTIFACT Summary for the map
//----------------------------------------------------------------
void(entity targ) ammostats_artsummary =
{
	local float artqty;
	//              1234567890123456789012345678901234567890
	sprint(targ,   "--------------------------------------\n");
	sprint(targ, "\bArtifact Suit  Pent  InvR  Quad  Total\b\n");
	//              Totals   xxxx  xxxx  xxxx  xxxx   xxxx

	artqty = as_artsuit + as_artpent + as_artinv + as_artquad;
	sprint(targ, "Totals   ");
	zerofill_number(targ, as_artsuit, " ", " ", " ", "", "");
	sprint(targ, "  "); 
	zerofill_number(targ, as_artpent, " ", " ", " ", "", "");
	sprint(targ, "  "); 
	zerofill_number(targ, as_artinv, " ", " ", " ", "", "");
	sprint(targ, "  "); 
	zerofill_number(targ, as_artquad, " ", " ", " ", "", "");
	sprint(targ, "   "); 
	zerofill_number(targ, artqty, " ", " ", " ", "", "");
	sprint(targ, "\n"); 
};

//----------------------------------------------------------------------
// PHASE 3 : Count MONSTERS and display summary table
//----------------------------------------------------------------------
void() ammostats_phase3 =
{
	local entity entlist;
	//----------------------------------------------------------------
	// FIND all MONSTERS in the map
	//----------------------------------------------------------------
	as_monqty = as_monlist = as_finalmonhp = as_zombiehp = 0;
	as_nightonly = as_cooponly = 0;
	as_monzombie = as_mondelay = as_monnocount = 0;
	
	// Start from beginning of entity list, world!
	entlist = nextent(world);
	// Keep looping through entity list
	while (entlist) {
		// Only interested in monsters
		if (entlist.flags & FL_MONSTER) {
			// Spawn exceptions
			if (entlist.nightmare == TRUE)
				as_nightonly = as_nightonly + 1;
			if (entlist.cooponly == TRUE)
				as_cooponly = as_cooponly + 1;
			
			// Is the monster designed for nightmare skill only?
			if (entlist.nightmare && skill != SKILL_NIGHTMARE) {
				// Easier to do nothing
			}
			// Is the monster designed for coop only?
			else if (entlist.cooponly && coop == FALSE) {
				// Easier to do nothing
			}
			else {
				// Total monsters in map might be different to HUD
				// Exceptions = nomonstercount, delaymonstercount
				as_monqty = as_monqty + 1;
				
				// Include any backpack ammo drops
				shellqty[AC_MONSTER]= shellqty[AC_MONSTER]+ entlist.ammo_shells;
				nailqty[AC_MONSTER] = nailqty[AC_MONSTER] + entlist.ammo_nails;
				rockqty[AC_MONSTER] = rockqty[AC_MONSTER] + entlist.ammo_rockets;
				cellqty[AC_MONSTER] = cellqty[AC_MONSTER] + entlist.ammo_cells;
				
				// Keep track of zombie's, they need rockets!
				if (entlist.classgroup == CG_ZOMBIE) {
					// Exception = crucified zombies
					if (!(entlist.spawnflags & MON_CRUCIFIED)) {
						as_monzombie = as_monzombie + 1;
						as_zombiehp = as_zombiehp + entlist.max_health;
					}
				}
				// Keep track of spawn delay monsters
				if (entlist.spawnflags & MON_SPAWN_DELAY)
					as_mondelay = as_mondelay + 1;
				// Keep track of monsters with no count
				if (entlist.nomonstercount > 0 || entlist.delaymonstercount > 0)
					as_monnocount = as_monnocount + 1;
				// Keep track of all monster HP, exclude negative + boss
				if (entlist.max_health > 0 && !entlist.bossflag) {
					// Some monsters reset HP later
					if (entlist.reset_health > 0) 
						as_finalmonhp = as_finalmonhp + entlist.reset_health;
					// Anything over 9999 is a special setup (don't include it)
					else if (entlist.max_health < 9999) {
						as_finalmonhp = as_finalmonhp + entlist.max_health;	
					}
				}
			}
		}
		// Keep search through ALL of the entity list
		entlist = nextent(entlist);
	} 

	// ERROR = No MONSTERS found?
	if (as_monqty == 0) {
		sprint(self.owner, "--------------------------------------\n");
		sprint(self.owner, "\b[ERROR]\b Missing any MONSTERS!\n");
		sprint(self.owner, " * Cannot create Ammo & Monster Stats!\n\n");
		ammocontrol.state = AC_PHASE0;
		return;
	}
		
	// Display Summary stuff for the map
	ammostats_monsummary(self.owner);
	ammostats_artsummary(self.owner);

	// next stage of stats
	ammocontrol.state = AC_PHASE4;
	ammocontrol.think = ammostats_phase4;
	ammocontrol.nextthink = time + 0.1;
};
	
//----------------------------------------------------------------------
// PHASE 4 : Count ARMOUR and HEALTH packs
//----------------------------------------------------------------------
void() ammostats_phase4 =
{
	local entity entlist;
	//----------------------------------------------------------------
	// FIND all armour/health packs
	//----------------------------------------------------------------
	as_armgrnqty = as_armyelqty = as_armredqty = as_armhpqty = 0;
	as_hp15qty = as_hp25qty = as_hp100qty = as_hpqty = as_hpsec = 0;
	as_backgrnqty = as_backyelqty = as_backredqty = 0;
	as_backarmqty = as_backarmsec = as_hpfinal = 0;
	
	// Start from beginning of entity list, world!
	entlist = nextent(world);
	// Keep looping through entity list
	while (entlist) {
		// Interested in health items
		if (entlist.flags & FL_ITEM && entlist.classgroup == CG_HEALTH) {
			as_hpqty = as_hpqty + entlist.healamount;
			if (entlist.classtype == CT_HEALROT)
				as_hp15qty = as_hp15qty + 1;
			else if (entlist.classtype == CT_HEALNORM)
				as_hp25qty = as_hp25qty + 1;
			else if (entlist.classtype == CT_HEALMEGA)
				as_hp100qty = as_hp100qty + 1;
		}
		// Interested in armour items
		if (entlist.flags & FL_ITEM && entlist.classgroup == CG_ARMOR) {
			as_armhpqty = as_armhpqty + entlist.armorvalue;
			if (entlist.classtype == CT_ARMOR1)
				as_armgrnqty = as_armgrnqty + 1;
			else if (entlist.classtype == CT_ARMOR2)
				as_armyelqty = as_armyelqty + 1;
			else if (entlist.classtype == CT_ARMORINV)
				as_armredqty = as_armredqty + 1;
		}		
		// Interested in backpack (armour) items
		if (entlist.flags & FL_ITEM && entlist.classtype == CT_ARMORITEMPACK) {
			if (entlist.armorvalue > 0) {
				as_backarmqty = as_backarmqty + entlist.armorvalue;
				if (entlist.armortype == ARMOR_GRN_TYPE || entlist.armortype == 0)
					as_backgrnqty = as_backgrnqty + 1;
				else if (entlist.armortype == ARMOR_YEL_TYPE)
					as_backyelqty = as_backyelqty + 1;
				else if (entlist.armortype == ARMOR_RED_TYPE)
					as_backredqty = as_backredqty + 1;
				// Exclude YA / RA from pickups
				if (entlist.armortype != ARMOR_YEL_TYPE && entlist.armortype != ARMOR_RED_TYPE)
					as_backarmsec = as_backarmsec + entlist.armorvalue;
			}
		}
		// Keep search through ALL of the entity list
		entlist = nextent(entlist);
	}
	
	// Calculate Health Points with NO SECRETS (usually MH or RED)
	as_hpsec = (as_hp15qty*HEAL_ROT) + (as_hp25qty*HEAL_NORM);
	as_hpsec = as_hpsec + (as_armgrnqty*ARMOR_GRN_VALUE) + (as_armyelqty*ARMOR_YEL_VALUE);
	as_hpfinal = as_hpsec + as_backarmsec;
	
	//              1234567890123456789012345678901234567890
	sprint(self.owner,   "--------------------------------------\n");
	sprint(self.owner, "\bHEALTH  15 25 MH GA YA RA Total  -MHRA\b\n");
	//                    Pickup  xx xx xx xx xx xx xxxxx  xxxxx
	//                    BackPck          xx xx xx xxxxx  xxxxx
	sprint(self.owner, "Pickup  ");
	zerofill_number(self.owner, as_hp15qty, " ", "", "", "", "");
	sprint(self.owner, " "); 
	zerofill_number(self.owner, as_hp25qty, " ", "", "", "", "");
	sprint(self.owner, " "); 
	zerofill_number(self.owner, as_hp100qty, " ", "", "", "", "");
	sprint(self.owner, " "); 
	zerofill_number(self.owner, as_armgrnqty, " ", "", "", "", "");
	sprint(self.owner, " "); 
	zerofill_number(self.owner, as_armyelqty, " ", "", "", "", "");
	sprint(self.owner, " "); 
	zerofill_number(self.owner, as_armredqty, " ", "", "", "", "");
	sprint(self.owner, " "); 
	zerofill_number(self.owner, as_hpqty+as_armhpqty, "0", " ", " ", " ", "");
	sprint(self.owner, "  "); 
	zerofill_number(self.owner, as_hpsec, "0", " ", " ", " ", "");
	sprint(self.owner, "\n");

	// Any armour backpacks in map?
	if (as_backarmqty > 0) {
		sprint(self.owner, "BackPck          ");
		zerofill_number(self.owner, as_backgrnqty, " ", "", "", "", "");
		sprint(self.owner, " "); 
		zerofill_number(self.owner, as_backyelqty, " ", "", "", "", "");
		sprint(self.owner, " "); 
		zerofill_number(self.owner, as_backredqty, " ", "", "", "", "");
		sprint(self.owner, " "); 
		zerofill_number(self.owner, as_backarmqty, "0", " ", " ", " ", "");
		sprint(self.owner, "  "); 
		zerofill_number(self.owner, as_backarmsec, "0", " ", " ", " ", "");
		sprint(self.owner, "\n");
	}
	
	// next stage of stats
	ammocontrol.state = AC_PHASE5;
	ammocontrol.think = ammostats_phase5;
	ammocontrol.nextthink = time + 0.1;
};

//----------------------------------------------------------------------
// PHASE 5 : Finally display data tables
//----------------------------------------------------------------------
void() ammostats_phase5 =
{
	local float subtwbm, subtsml, subtlrg, totalrock;
	local float hpmon_ammo_ratio, hparm_hpmon_ratio;
	local float nozombammo, nozombmonhp, nobackammo, shotgunstart;
	local float nobackshell, nobacknail, nobackrock, nobackcell;
	//----------------------------------------------------------------
	// Final table 
	//----------------------------------------------------------------
	//                    1234567890123456789012345678901234567890
	sprint(self.owner,   "--------------------------------------\n");
	sprint(self.owner, "\bSource        Shell  Nail  Rock   Cell\b\n");
	//                    x-----------x  xxxx  xxxx  xxxx   xxxx

	// Current ammo quantity in player inventory (not included in stats)
	if (self.owner.ammo_shells != 25) {
		sprint(self.owner, "Player Inv     "); 
		zerofill_number(self.owner, self.owner.ammo_shells, " ", " ", " ", "", "");
		sprint(self.owner, "  "); zerofill_number(self.owner, self.owner.ammo_nails, " ", " ", " ", "", "");
		sprint(self.owner, "  "); zerofill_number(self.owner, self.owner.ammo_rockets, " ", " ", " ", "", "");
		sprint(self.owner, "   "); zerofill_number(self.owner, self.owner.ammo_cells, " ", " ", " ", "", "");
		sprint(self.owner, "\n");
	}
	// All ammo item pickups
	sprint(self.owner, "Ammo Boxes     "); 
	zerofill_number(self.owner, shellqty[AC_AMMOQTY], " ", " ", " ", "", "");
	sprint(self.owner, "  "); zerofill_number(self.owner, nailqty[AC_AMMOQTY], " ", " ", " ", "", "");
	sprint(self.owner, "  "); zerofill_number(self.owner, rockqty[AC_AMMOQTY], " ", " ", " ", "", "");
	sprint(self.owner, "   "); zerofill_number(self.owner, cellqty[AC_AMMOQTY], " ", " ", " ", "", "");
	sprint(self.owner,"\n");
	// All ammo item pickups
	subtwbm = shellqty[AC_RESPAWN] + nailqty[AC_RESPAWN] + rockqty[AC_RESPAWN] + cellqty[AC_RESPAWN];
	if (subtwbm > 0) {
		sprint(self.owner, "Respawn Ammo   "); 
		zerofill_number(self.owner, shellqty[AC_RESPAWN], " ", " ", " ", "", "");
		sprint(self.owner, "  "); zerofill_number(self.owner, nailqty[AC_RESPAWN], " ", " ", " ", "", "");
		sprint(self.owner, "  "); zerofill_number(self.owner, rockqty[AC_RESPAWN], " ", " ", " ", "", "");
		sprint(self.owner, "   "); zerofill_number(self.owner, cellqty[AC_RESPAWN], " ", " ", " ", "", "");
		sprint(self.owner,"\n");
	}
	// All ammo from weapons
	sprint(self.owner, "Weapon Pickups "); 
	zerofill_number(self.owner, shellqty[AC_WEAPON], " ", " ", " ", "", "");
	sprint(self.owner, "  "); zerofill_number(self.owner, nailqty[AC_WEAPON], " ", " ", " ", "", "");
	sprint(self.owner, "  "); zerofill_number(self.owner, rockqty[AC_WEAPON], " ", " ", " ", "", "");
	sprint(self.owner, "   "); zerofill_number(self.owner, cellqty[AC_WEAPON], " ", " ", " ", "", "");
	sprint(self.owner,"\n");
	
	// AD only feature; Change start ammo for player
	subtwbm = world.ammo_shells + world.ammo_nails + world.ammo_rockets + world.ammo_cells;
	if (subtwbm > 0) {
		sprint(self.owner, "Worldspawn     "); 
		zerofill_number(self.owner, world.ammo_shells, " ", " ", " ", "", "");
		sprint(self.owner, "  "); zerofill_number(self.owner, world.ammo_nails, " ", " ", " ", "", "");
		sprint(self.owner, "  "); zerofill_number(self.owner, world.ammo_rockets, " ", " ", " ", "", "");
		sprint(self.owner, "   "); zerofill_number(self.owner, world.ammo_cells, " ", " ", " ", "", "");
		sprint(self.owner, "\n");
	}
	// All ammo from backpacks
	if (as_backammo == TRUE) {
		sprint(self.owner, "Backpacks      "); 
		zerofill_number(self.owner, shellqty[AC_BACKPACK], " ", " ", " ", "", "");
		sprint(self.owner, "  "); zerofill_number(self.owner, nailqty[AC_BACKPACK], " ", " ", " ", "", "");
		sprint(self.owner, "  "); zerofill_number(self.owner, rockqty[AC_BACKPACK], " ", " ", " ", "", "");
		sprint(self.owner, "   "); zerofill_number(self.owner, cellqty[AC_BACKPACK], " ", " ", " ", "", "");
		sprint(self.owner,"\n");
	}
	// All ammo from monsters
	sprint(self.owner, "Monster Drops  "); 
	zerofill_number(self.owner, shellqty[AC_MONSTER], " ", " ", " ", "", "");
	sprint(self.owner, "  "); zerofill_number(self.owner, nailqty[AC_MONSTER], " ", " ", " ", "", "");
	sprint(self.owner, "  "); zerofill_number(self.owner, rockqty[AC_MONSTER], " ", " ", " ", "", "");
	sprint(self.owner, "   "); zerofill_number(self.owner, cellqty[AC_MONSTER], " ", " ", " ", "", "");
	sprint(self.owner,"\n");
	//sprint(self.owner, " * World qty capped, player excluded\n");
	
	totalrock = rockqty[AC_AMMOQTY] + rockqty[AC_BACKPACK] + rockqty[AC_WORLDSPN] + rockqty[AC_WEAPON] + rockqty[AC_MONSTER];
	if (totalrock < as_monzombie)
		sprint(self.owner, " * Rocket quantity less than zombies!\n");
	
	// List of all ammo stats
	sprint(self.owner,   "--------------------------------------\n");
	sprint(self.owner, "\bAmmo   Sml Lrg  Qty Wpn WBM Dmg  Total\b\n");
	//                    xxxxxx xxx xxx xxxx xxx xxx xxx  xxxxxx
	//                    Total  xxx xxx                   xxxxxx
	
	subtwbm = shellqty[AC_WORLDSPN] + shellqty[AC_BACKPACK] + shellqty[AC_MONSTER];
	shellqty[AC_AMMOFINAL] = ( shellqty[AC_AMMOQTY] + shellqty[AC_WEAPON] + subtwbm ) * DAMAGE_SHELL;
	as_finalammo = shellqty[AC_AMMOFINAL];
	sprint(self.owner, "Shell  "); zerofill_number(self.owner, shellqty[AC_SMALLBOX], " ", " ", "", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, shellqty[AC_LARGEBOX], " ", " ", "", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, shellqty[AC_AMMOQTY], " ", " ", " ", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, shellqty[AC_WEAPON], " ", " ", "", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, subtwbm, " ", " ", "", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, DAMAGE_SHELL, " ", " ", "", "", "");
	sprint(self.owner, "  "); zerofill_number(self.owner, shellqty[AC_AMMOFINAL], "0", "0", "0", " ", "");
	sprint(self.owner, " \n");

	subtwbm = nailqty[AC_WORLDSPN] + nailqty[AC_BACKPACK] + nailqty[AC_MONSTER];
	nailqty[AC_AMMOFINAL] = (nailqty[AC_AMMOQTY] + nailqty[AC_WEAPON] + subtwbm) * DAMAGE_NGSPIKE;
	as_finalammo = as_finalammo + nailqty[AC_AMMOFINAL];
	sprint(self.owner, "Nail   "); zerofill_number(self.owner, nailqty[AC_SMALLBOX], " ", " ", "", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, nailqty[AC_LARGEBOX], " ", " ", "", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, nailqty[AC_AMMOQTY], " ", " ", " ", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, nailqty[AC_WEAPON], " ", " ", "", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, subtwbm, " ", " ", "", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, DAMAGE_NGSPIKE, " ", " ", "", "", "");
	sprint(self.owner, "  "); zerofill_number(self.owner, nailqty[AC_AMMOFINAL], "0", "0", "0", " ", "");
	sprint(self.owner, " \n");

	subtwbm = rockqty[AC_WORLDSPN] + rockqty[AC_BACKPACK] + rockqty[AC_MONSTER];
	rockqty[AC_AMMOFINAL] = (rockqty[AC_AMMOQTY] + rockqty[AC_WEAPON] + subtwbm) * DAMAGE_PLAYGRENADE;
	as_finalammo = as_finalammo + rockqty[AC_AMMOFINAL];
	sprint(self.owner, "Rocket "); zerofill_number(self.owner, rockqty[AC_SMALLBOX], " ", " ", "", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, rockqty[AC_LARGEBOX], " ", " ", "", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, rockqty[AC_AMMOQTY], " ", " ", " ", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, rockqty[AC_WEAPON], " ", " ", "", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, subtwbm, " ", " ", "", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, DAMAGE_PLAYGRENADE, " ", " ", "", "", "");
	sprint(self.owner, "  "); zerofill_number(self.owner, rockqty[AC_AMMOFINAL], "0", "0", "0", " ", "");
	sprint(self.owner, " \n");

	subtwbm = cellqty[AC_WORLDSPN] + cellqty[AC_BACKPACK] + cellqty[AC_MONSTER];
	cellqty[AC_AMMOFINAL] = (cellqty[AC_AMMOQTY] + cellqty[AC_WEAPON] + subtwbm) * DAMAGE_LGPLAYER;
	as_finalammo = as_finalammo + cellqty[AC_AMMOFINAL];
	sprint(self.owner, "Cell   "); zerofill_number(self.owner, cellqty[AC_SMALLBOX], " ", " ", "", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, cellqty[AC_LARGEBOX], " ", " ", "", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, cellqty[AC_AMMOQTY], " ", " ", " ", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, cellqty[AC_WEAPON], " ", " ", "", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, subtwbm, " ", " ", "", "", "");
	sprint(self.owner, " "); zerofill_number(self.owner, DAMAGE_LGPLAYER, " ", " ", "", "", "");
	sprint(self.owner, "  "); zerofill_number(self.owner, cellqty[AC_AMMOFINAL], "0", "0", "0", " ", "");
	sprint(self.owner, " \n");

	subtsml = shellqty[AC_SMALLBOX] + nailqty[AC_SMALLBOX] + rockqty[AC_SMALLBOX] + cellqty[AC_SMALLBOX];
	subtlrg = shellqty[AC_LARGEBOX] + nailqty[AC_LARGEBOX] + rockqty[AC_LARGEBOX] + cellqty[AC_LARGEBOX];
	
	sprint(self.owner, "Total  "); 
	zerofill_number(self.owner, subtsml, " ", " ", "", "", "");
	sprint(self.owner, " "); 
	zerofill_number(self.owner, subtlrg, " ", " ", "", "", "");
	sprint(self.owner, "                  ");
	zerofill_number(self.owner, as_finalammo, "0", " ", " ", " ", " ");
	sprint(self.owner, " \n");
	
	//----------------------------------------------------------------
	// Display FINAL Stats for the map
	//----------------------------------------------------------------
	// How much ammo there is in the map compared to monster HP
	// Positive ratio means MORE THAN ENOUGH ammo to deal with monsters
	// Negative ratio means NOT ENOUGH ammo to deal with  all monsters
	//                    1234567890123456789012345678901234567890
	sprint(self.owner,   "======================================\n");
	sprint(self.owner, "\bSkill (\b"); sprint(self.owner, ftos(skill));
	sprint(self.owner, "\b)    HPvMo  MonHP   Ammo Ratio\b\n");
	//                    Skill (x)    HPvMo  MonHP   Ammo Ratio
	//                    All Monsters xx.xx xxxxxx xxxxxx xx.xx
	//                    No Zombies   xx.xx xxxxxx xxxxxx xx.xx
	//                    No Backpacks xx.xx xxxxxx xxxxxx xx.xx
	//                    Shotgun Strt xx.xx xxxxxx xxxxxx xx.xx

	// Standard ratio (no accounting for explosives)
	hpmon_ammo_ratio = as_finalammo / as_finalmonhp;
	hparm_hpmon_ratio = (as_hpfinal / as_finalmonhp)*1000;
	sprint(self.owner, "All Monsters ");
	lftos(self.owner, hparm_hpmon_ratio, 2, 2, BUFFER_SPRINT);
	sprint(self.owner, " "); 
	zerofill_number(self.owner, as_finalmonhp, "0", " ", " ", " ", " ");
	sprint(self.owner, " "); 
	zerofill_number(self.owner, as_finalammo, "0", " ", " ", " ", " ");
	sprint(self.owner, " ");
	lftos(self.owner, hpmon_ammo_ratio, 2, 2, BUFFER_SPRINT);
	sprint(self.owner, "\n"); 

	// Zombie ratio (need explosives to be destroyed)
	// Skip this condition if no zombies on map!
	if (as_monzombie > 0) {
		nozombmonhp = as_finalmonhp-as_zombiehp;
		nozombammo = as_finalammo - (as_monzombie * DAMAGE_PLAYGRENADE);
		hpmon_ammo_ratio = nozombammo / nozombmonhp;
		hparm_hpmon_ratio = (as_hpfinal / nozombmonhp)*1000;
		sprint(self.owner, "No Zombies   ");
		lftos(self.owner, hparm_hpmon_ratio, 2, 2, BUFFER_SPRINT);
		sprint(self.owner, " "); 
		zerofill_number(self.owner, nozombmonhp, "0", " ", " ", " ", " ");
		sprint(self.owner, " "); 
		zerofill_number(self.owner, nozombammo, "0", " ", " ", " ", " ");
		sprint(self.owner, " ");
		lftos(self.owner, hpmon_ammo_ratio, 2, 2, BUFFER_SPRINT);
		sprint(self.owner, "\n"); 
	}

	// No backpack option, often given as secret items
	// Detect any backpacks (as_backammo) and subtract ammo
	if (as_backammo == TRUE) {
		nobackshell = shellqty[AC_BACKPACK] * DAMAGE_SHELL;
		nobacknail = nailqty[AC_BACKPACK] * DAMAGE_NGSPIKE;
		nobackrock = rockqty[AC_BACKPACK] * DAMAGE_PLAYGRENADE;
		nobackcell = cellqty[AC_BACKPACK] * DAMAGE_LGPLAYER;
		nobackammo = nobackshell + nobacknail + nobackrock + nobackcell;
		hpmon_ammo_ratio = (as_finalammo - nobackammo) / as_finalmonhp;
		hparm_hpmon_ratio = (as_hpfinal / as_finalmonhp)*1000;
		sprint(self.owner, "No Backpacks ");
		lftos(self.owner, hparm_hpmon_ratio, 2, 2, BUFFER_SPRINT);
		sprint(self.owner, " "); 
		zerofill_number(self.owner, as_finalmonhp, "0", " ", " ", " ", " ");
		sprint(self.owner, " "); 
		zerofill_number(self.owner, as_finalammo - nobackammo, "0", " ", " ", " ", " ");
		sprint(self.owner, " ");
		lftos(self.owner, hpmon_ammo_ratio, 2, 2, BUFFER_SPRINT);
		sprint(self.owner, "\n"); 
	}
		
	// Check for Shotgun Start (Have ammo, but missing gun)
	shotgunstart = FALSE;
	// Shotguns + shell ammo
	if (shellqty[AC_SHOTSTART] == FALSE && shellqty[AC_AMMOFINAL] > 0)
		shotgunstart = TRUE;
	// Nailguns + nail ammo
	if (nailqty[AC_SHOTSTART] == FALSE && nailqty[AC_AMMOFINAL] > 0)
		shotgunstart = TRUE;
	// Grenade and rocket launcher + rocket ammo
	if (rockqty[AC_SHOTSTART] == FALSE && rockqty[AC_AMMOFINAL] > 0)
		shotgunstart = TRUE;
	// Lightning and plasma gun + cell ammo
	if (cellqty[AC_SHOTSTART] == FALSE && rockqty[AC_AMMOFINAL] > 0)
		shotgunstart = TRUE;
		
	// Any ammo + weapon missing?
	if (shotgunstart == TRUE) {
		as_finalammo = 0;
		if (shellqty[AC_SHOTSTART] == TRUE)
			as_finalammo = as_finalammo + shellqty[AC_AMMOFINAL];
		if (nailqty[AC_SHOTSTART] == TRUE)
			as_finalammo = as_finalammo + nailqty[AC_AMMOFINAL];
		if (rockqty[AC_SHOTSTART] == TRUE)
			as_finalammo = as_finalammo + rockqty[AC_AMMOFINAL];
		if (cellqty[AC_SHOTSTART] == TRUE)
			as_finalammo = as_finalammo + cellqty[AC_AMMOFINAL];
		
		hpmon_ammo_ratio = as_finalammo / as_finalmonhp;
		hparm_hpmon_ratio = (as_hpfinal / as_finalmonhp)*1000;
		sprint(self.owner, "Shotgun Strt ");
		lftos(self.owner, hparm_hpmon_ratio, 2, 2, BUFFER_SPRINT);
		sprint(self.owner, " "); 
		zerofill_number(self.owner, as_finalmonhp, "0", " ", " ", " ", " ");
		sprint(self.owner, " "); 
		zerofill_number(self.owner, as_finalammo, "0", " ", " ", " ", " ");
		sprint(self.owner, " ");
		lftos(self.owner, hpmon_ammo_ratio, 2, 2, BUFFER_SPRINT);
		sprint(self.owner, "\n");
	}
		
	// Last stage
	ammocontrol.state = AC_PHASE0;
};
	
//======================================================================
// Display monsters left alive in map
//======================================================================
void() display_monsleft =
{
	local float entcount, montotal, monalive, mondead;
	local entity entlist;
	
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only

	// flush keyboard buffer
	self.impulse = 0;
	// Reset counters
	entcount = montotal = monalive = mondead = 0;

	sprint(self, "\b[-- Monsters Alive and Kicking --]\b\n"); 
	sprint(self, "--------------------------------------\n");
	sprint(self, " No   HP D Classname + XYZ location\n");
	//            xxx xxxx x x------------------------------x
	// Start from beginning of entity list, world!
	entlist = nextent(world);

	// Keep looping through entity list
	while (entlist) {
		// Found another entity
		entcount = entcount + 1;
		// Only interested in monsters (regular + boss)
		if (entlist.flags & FL_MONSTER || entlist.bossflag) {
			// Keep counting up monsters
			montotal = montotal + 1;
			
			if (entlist.health > 0) {
				monalive = monalive + 1;
				if (monalive <= MAX_MONCOUNT) {
					// Update console display
					zerofill_number(self, monalive, "0", "0", "", "", "");
					sprint(self, " ");
					zerofill_number(self, entlist.health, " ", " ", " ", "", "");
					// Check for monster spawn delay (flag)
					if (entlist.spawnflags & MON_SPAWN_DELAY) sprint(self, " Y ");
					else sprint(self, " - ");
					// Print monster class and position
					sprint(self, entlist.classname); sprint(self, " ");
					sprint(self, vtos(entlist.origin)); sprint(self, "\n");
				}
				// Only report the first xxx monsters
				// Otherwise will get SZ_GETSPACE : OVERFLOW error
				if (monalive == (MAX_MONCOUNT+1)) {
					sprint(self, " * Can only list ");
					sprint(self, ftos(MAX_MONCOUNT));
					sprint(self, "monsters!\n");
				}
			}
			// Monster found is dead
			else mondead = mondead + 1;			
		}		
		// Keep search through ALL of the entity list
		entlist = nextent(entlist);
	}
	sprint(self, "--------------------------------------\n");
	sprint(self, "Monster Total ("); sprint(self, ftos(montotal));
	sprint(self, ") Alive ("); sprint(self, ftos(monalive));
	sprint(self, ") Dead ("); sprint(self, ftos(mondead));
	sprint(self, ")\n");
	sprint(self, "Player location "); sprint(self, vtos(self.origin));
	sprint(self, "\n\n");
};

//======================================================================
// Display quantity of different monster types
//======================================================================
void() display_monsqty =
{
	// Monster Array of quantity/hp differences
	local entity asmonent[MAX_MONARRAY];
	local float asmonqty[MAX_MONARRAY], asmonhp[MAX_MONARRAY];

	local float monloop, monfound, monarrayfull, subtmonhp;
	local entity entlist;
	
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only

	// flush keyboard buffer
	self.impulse = 0;

	//----------------------------------------------------------------
	// FIND all MONSTERS in the map
	//----------------------------------------------------------------
	as_monqty = as_monlist = as_finalmonhp = 0;
	as_nightonly = as_cooponly = as_backammo = 0;
	as_monzombie = as_zombiehp = as_mondelay = as_monnocount = 0;
	monarrayfull = FALSE;
	
	// Start from beginning of entity list, world!
	entlist = nextent(world);
	// Keep looping through entity list
	while (entlist) {
		// Only interested in monsters
		if (entlist.flags & FL_MONSTER) {
			// Spawn exceptions
			if (entlist.nightmare == TRUE)
				as_nightonly = as_nightonly + 1;
			if (entlist.cooponly == TRUE)
				as_cooponly = as_cooponly + 1;
			
			// Is the monster designed for nightmare skill only?
			if (entlist.nightmare && skill != SKILL_NIGHTMARE) {
				// Easier to do nothing
			}
			// Is the monster designed for coop only?
			else if (entlist.cooponly && coop == FALSE) {
				// Easier to do nothing
			}
			else {
				// Total monsters in map might be different to HUD
				// Exceptions = nomonstercount, delaymonstercount
				as_monqty = as_monqty + 1;
				
				// Include any backpack ammo drops
				shellqty[AC_MONSTER]= shellqty[AC_MONSTER]+ entlist.ammo_shells;
				nailqty[AC_MONSTER] = nailqty[AC_MONSTER] + entlist.ammo_nails;
				rockqty[AC_MONSTER] = rockqty[AC_MONSTER] + entlist.ammo_rockets;
				cellqty[AC_MONSTER] = cellqty[AC_MONSTER] + entlist.ammo_cells;
				
				// Keep track of zombie's, they need rockets!
				if (entlist.classgroup == CG_ZOMBIE) {
					// Exception = crucified zombies
					if (!(entlist.spawnflags & MON_CRUCIFIED)) {
						as_monzombie = as_monzombie + 1;
						as_zombiehp = as_zombiehp + entlist.max_health;
					}
				}
				// Keep track of spawn delay monsters
				if (entlist.spawnflags & MON_SPAWN_DELAY)
					as_mondelay = as_mondelay + 1;
				// Keep track of monsters with no count
				if (entlist.nomonstercount > 0 || entlist.delaymonstercount > 0)
					as_monnocount = as_monnocount + 1;
				// Keep track of all monster HP, exclude negative + boss
				if (entlist.max_health > 0 && !entlist.bossflag) {
					// Some monsters reset HP later
					if (entlist.reset_health > 0) 
						as_finalmonhp = as_finalmonhp + entlist.reset_health;
					// Anything over 9999 is a special setup (don't include it)
					else if (entlist.max_health < 9999) {
						as_finalmonhp = as_finalmonhp + entlist.max_health;	
					}
				}
				
				// ------------------------------------------------------
				// Is this the FIRST monster in the LIST?
				if (as_monlist == 0) {
					// Add first monster to front of list
					asmonent[as_monlist] = entlist;
					asmonqty[as_monlist] = 1;
					if (entlist.bossflag) asmonhp[as_monlist] = NOHP_MONARRAY;
					else asmonhp[as_monlist] = entlist.max_health;
					// First entry in list
					as_monlist = 1;
				}
				// --------------------------------------------------
				// Search through monster LIST for possible match
				else {
					monloop = 0;
					monfound = FALSE;
					// Loop through list
					while (monloop < as_monlist) {
						// Found monster in list?
						// This condition will always setup boss monsters
						// in separate table entries (HP reset to zero)
						if (entlist.classtype == asmonent[monloop].classtype
							&& entlist.max_health == asmonhp[monloop]) {
							// Found monster, update quantity and exit
							asmonqty[monloop] = asmonqty[monloop] + 1;
							monfound = TRUE;
						}
						// Keep looping through list
						monloop = monloop + 1;
					}

					// --------------------------------------------------
					// Was the new monster found in the LIST?
					if (monfound == FALSE) {
						// only add monsters if array is large enough
						if (as_monlist < MAX_MONARRAY) {						
							// Add monster to list
							asmonent[as_monlist] = entlist;
							asmonqty[as_monlist] = 1;
							if (entlist.bossflag) asmonhp[as_monlist] = NOHP_MONARRAY;
							else asmonhp[as_monlist] = entlist.max_health;
							// Increase list counter
							as_monlist = as_monlist + 1;
						}
						// Reach limit of array
						else monarrayfull = TRUE;
					}
				}
			}
		}
		// Keep search through ALL of the entity list
		entlist = nextent(entlist);
	} 

	// ERROR = No MONSTERS found?
	if (as_monqty == 0) {
		sprint(self, "--------------------------------------\n");
		sprint(self, "\b[ERROR]\b Missing any MONSTERS!\n");
		sprint(self, " * Cannot create Monster Stats!\n\n");
		return;
	}
		
	//----------------------------------------------------------------
	// Display MONSTER ARRAY for the map
	//----------------------------------------------------------------
	monloop = 0;
	sprint(self, "\b[-- Advanced Monsters Statistics --]\b\n"); 
	sprint(self, "--------------------------------------\n");
	sprint(self, "\bNo  Qty   HP  Total Classname\b\n");
	//              xx xxxx xxxx xxxxxx x---------------------x
	// Loop through list
	while (monloop < as_monlist) {
		zerofill_number(self, monloop+1, "0", "", "", "", "");
		sprint(self, " ");
		
		// Check for any special cases (reset_health)
		if (asmonent[monloop].reset_health > 0) {
			asmonhp[monloop] = asmonent[monloop].reset_health;
		}
		// Display monster quantity, individual HP and subtotal
		if (asmonent[monloop].bossflag == FALSE) {
			zerofill_number(self, asmonqty[monloop], "0", " ", " ", "", "");
			sprint(self, " "); 
			zerofill_number(self, asmonhp[monloop], "0", " ", " ", "", "");
			sprint(self, " "); 
			subtmonhp = asmonhp[monloop] * asmonqty[monloop];
			zerofill_number(self, subtmonhp, "0", " ", " ", " ", " ");
		}
		// BOSS monsters are usually a special setup
		// They might as well be zero HP for this table
		else {
			zerofill_number(self, asmonqty[monloop], "0", " ", " ", "", "");
			sprint(self, " "); 
			zerofill_number(self, 0, " ", " ", " ", "", "");
			sprint(self, " "); 
			zerofill_number(self, 0, " ", " ", " ", " ", " ");
		}
		// Display monster name
		sprint(self, " ");
		sprint(self, asmonent[monloop].classname);
		sprint(self, "\n");
		// Keep looping through list
		monloop = monloop + 1;
	}
	// Is monster array is full?
	if (monarrayfull == TRUE) {
		sprint(self, " * Monster Array table is incomplete\n");
	}

	// Display Summary stuff for the map
	ammostats_monsummary(self);
};

//======================================================================
// Find and display secret locations
//======================================================================
void() display_secrets =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (secloc_running) {
		sprint(self, "[Impulse ");
		sprint(self, ftos(self.impulse));
		sprint(self, "] cannot work, \bSecret Cam\b active!\n");
		return;
	}

	// flush keyboard buffer
	self.impulse = 0;
	// Spawn secret trigger camera entity
	if (!secloc_cam) secloc_cam = spawn();
	secloc_cam.count = 0;

	sprint(self, "\n--------------------------------------\n");
	sprint(self, "List of secret locations:\n\n");
	
	// Search entity list for secrets
	secloc_cam.enemy = find(world, classname, "trigger_secret");
	// If no secrets exist, tell player and exit
	if (!secloc_cam.enemy) { sprint(self, "No secrets found!\n"); return; }

	// Keep looping through triggers
	while (secloc_cam.enemy) {
		// Found a secret!
		secloc_cam.count = secloc_cam.count + 1;
		secloc_cam.enemy.cnt = secloc_cam.count;
		// Update console display
		sprint(self, "(");
		// make sure table is aligned by zero filling
		if (secloc_cam.enemy.cnt < 10) sprint(self, "0");
		// display secret no + XYZ origin location
		sprint(self, ftos(secloc_cam.enemy.cnt)); 
		sprint(self, ") = ");
		sprint(self, vtos(secloc_cam.enemy.oldorigin)); 
		if (CheckZeroVector(secloc_cam.enemy.oldorigin)) sprint(self, " [Err]");
		if (secloc_cam.enemy.estate & ESTATE_OFF) sprint(self, " [Off]");
		else if (secloc_cam.enemy.estate & ESTATE_DISABLE) sprint(self, "[Disabled]");
		sprint(self, "\n");
		
		// Keep search for more secrets
		secloc_cam.enemy = find(secloc_cam.enemy, classname, "trigger_secret");
	}
	sprint(self, "--------------------------------------\n");
	sprint(self, "Total secrets found ("); 
	sprint(self, ftos(secloc_cam.count));
	sprint(self, ")\n\n");
};

//----------------------------------------------------------------------
void() FinishSecretCamera =
{
	// Restore player core parameters (NO save)
	setmodel (self, MODEL_PLAYER);
	modelindex_player = self.modelindex;
	setsize (self, self.bbmins, self.bbmaxs);
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.takedamage = DAMAGE_AIM;
	// Don't restore any velocity, wierd stuff will happen
	self.velocity = self.avelocity = '0 0 0';

	// Restore STORED player parameters
	self.flags = secloc_cam.flags;
	setorigin(self, secloc_cam.origin);
	self.view_ofs = secloc_cam.view_ofs;
	self.angles = secloc_cam.angles;
	self.v_angle = secloc_cam.v_angle;
	self.fixangle = TRUE;
	// Block player movement after camera exit
	self.teleport_time = time + 0.2;

	// Restore STORED weapon/ammo
	self.weapon = secloc_cam.weapon;
	self.currentammo = secloc_cam.currentammo;
	self.weaponmodel = secloc_cam.weaponmodel;
	self.weaponframe = secloc_cam.weaponframe;
	
	// Clear secret camera settings
	secloc_cam.flags = 0;
	secloc_cam.view_ofs = '0 0 0';
	secloc_cam.angles = secloc_cam.v_angle = '0 0 0';
	secloc_cam.weaponmodel = string_null;
	secloc_cam.weaponframe = 0;
	
	// Restore pre/post player functions
	secloc_running = FALSE;	
	// flush keyboard buffers
	self.impulse = 0;
	self.button0 = self.button1 = self.button2 = 0;
};

//----------------------------------------------------------------------
void() SaveSecretCamera =
{
	// Block pre/post player functions
	secloc_running = TRUE;	

	// SAVE player parameters
	secloc_cam.flags = self.flags;
	secloc_cam.origin = self.origin;
	secloc_cam.view_ofs = self.view_ofs;
	secloc_cam.angles = self.angles;
	secloc_cam.v_angle = self.v_angle;
	secloc_cam.weapon = self.weapon;
	secloc_cam.currentammo = self.currentammo;
	secloc_cam.weaponmodel = self.weaponmodel;
	secloc_cam.weaponframe = self.weaponframe;	
};

//----------------------------------------------------------------------
void() NextSecretCamera =
{
	if (!secloc_cam.enemy) { FinishSecretCamera(); return; }
	
	// Find next secret location
	secloc_cam.count = secloc_cam.count + 1;
	secloc_cam.enemy.cnt = secloc_cam.count;
	// Centerprint message about secret number found
	if (secloc_cam.enemy.estate & ESTATE_BLOCK)
		centerprint_msg3(self, "Secret (", ftos(secloc_cam.enemy.cnt), ") Disabled\n");
	else
		centerprint_msg3(self, "Secret (", ftos(secloc_cam.enemy.cnt), ")\n");
	setorigin(self, secloc_cam.enemy.oldorigin);

	// Keep search for more secrets
	secloc_cam.enemy = find(secloc_cam.enemy, classname, "trigger_secret");
};

//----------------------------------------------------------------------
void() CheckSecretCamera =
{
	if (impulse_playeronly()) return;		// Player only
	if (!secloc_running) return;
	if (self.waitmin > time) return;		// delay input
	
	// check for jump button to exit
	if (self.button1 || self.button2) {
		// Time to exit
		FinishSecretCamera();
	}
	// check for attack button to switch cameras
	else if (self.button0) {
		self.button0 = self.button1 = self.button2 = 0;
		self.waitmin = time + 0.5;
		// Next secret
		NextSecretCamera();
	}
};

//----------------------------------------------------------------------
void() display_secretlocs =
{
	if (impulse_activecameras()) return;	// Are cameras active
	if (impulse_playeronly()) return;		// Player only
	if (secloc_running) return;

	// flush keyboard buffer
	self.impulse = 0;
	// Spawn secret trigger camera entity
	if (!secloc_cam) secloc_cam = spawn();
	secloc_cam.count = 0;
	
	// Search entity list for secrets
	secloc_cam.enemy = find(world, classname, "trigger_secret");
	// If no secrets exist, tell player and exit
	if (!secloc_cam.enemy) { sprint(self, "No secrets found!\n"); return; }

	// Save player parameters
	SaveSecretCamera();

	// Switch on notarget so monsters don't attack player
	// Add god mode to prevent any damage
	self.flags = self.flags + (FL_NOTARGET || FL_GODMODE);
	self.flags = self.flags - (self.flags & FL_ONGROUND);		
		
	// reset player model to nothing and no world interaction
	self.view_ofs = self.velocity = self.avelocity = '0 0 0';
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;		// no more movement
	self.takedamage = DAMAGE_NO;		// no more damage
	setmodel(self, MODEL_EMPTY);		// Hide player model
	setsize(self, VEC_ORIGIN, VEC_ORIGIN);
	self.weaponmodel = string_null;		// No vmodel updates
	self.frame = self.weaponframe = 0;	// reset all frames
	
	// Display first camera
	NextSecretCamera();
};
