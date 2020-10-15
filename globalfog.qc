/*======================================================================
 GLOBAL FADING FOG SYSTEM

 * Original idea from Honey mod by CZG
 * Written from scratch as Honey implementation is weird
 * Created special long float function for better accuracy
 * Fog functionality has to be active before controller can be setup
 * Creates a special entity (controller) to work in background
 * Controller is setup from client.qc / PlayerPostThink function
 * Added r_skyfog version as well (supported in most engines)
 
======================================================================*/

//----------------------------------------------------------------------
// (Long Float TO String) Format and print a number to the console
// - str_player : needs to be a client for various buffer commands
// - buffer : BUFFER_STUFFCMD, BUFFER_SPRINT, BUFFER_DPRINT
void(entity str_player, float str_num, float topbit, float botbit, float buffer) lftos =
{
	local float str_counter, str_pow, str_result, str_remain, str_first;
	
	str_counter = topbit;		// Upper number length
	str_pow = mathlib_powbit(topbit,10);// Setup initial base 10 power for checking
	str_remain = FALSE;			// Decimal point been done yet
	str_first = FALSE;			// First non-zero digit printed

	// Deal with negative state first
	if (str_num < 0) {
		if (buffer & BUFFER_STUFFCMD) stuffcmd(str_player, "-");
		else if (buffer & BUFFER_SPRINT) sprint(str_player, "-");
		else if (buffer & BUFFER_DPRINT) dprint("-");
	}
	// Get rid of negative state
	str_num = fabs(str_num);
	
	// If number larger than fixed length?
	if (str_num > str_pow)
		str_num = str_num - (floor(str_num / str_pow) * str_pow);
		// New system, not used for this function
		// str_num = mathlib_truncate(str_num, topbit, botbit);

	// Loop through upper part of number
	while(str_counter > 0) {
		// Move down one pow digit
		str_pow = str_pow / 10;

		// Divide number by pow to get divider
		// Floor can produce rounding errors (fix it with 0.01)
		str_result = floor((str_num / str_pow)+0.01);
		// New system, not used for this function
		// str_result = mathlib_divisible(str_num, str_pow);
		
		// Result must be 0-9 digits
		if (str_result > 9) str_result = 9;
		if (str_result < 1) str_result = 0;
		
		// Fill front of number with spaces
		if (str_counter > 1 && str_result == 0 && str_first == FALSE) {
			// Print space to buffer type
			if (buffer & BUFFER_STUFFCMD) stuffcmd(str_player, " ");
			else if (buffer & BUFFER_SPRINT) sprint(str_player, " ");
			else if (buffer & BUFFER_DPRINT) dprint(" ");
		}
		// Display a number
		else if (str_result > 0 || str_first) {
			str_first = TRUE;
			// Print digit to buffer type
			if (buffer & BUFFER_STUFFCMD) stuffcmd(str_player, ftos(str_result));
			else if (buffer & BUFFER_SPRINT) sprint(str_player, ftos(str_result));
			else if (buffer & BUFFER_DPRINT) dprint(ftos(str_result));
		}
		
		// remove top part of number, decrease str length counter
		str_num = str_num - (str_result * str_pow);
		str_counter = str_counter - 1;
	}
	
	// Any decimal place?
	if (botbit <= 0) {
		// Check for zero value
		if (!str_first) {
			if (buffer & BUFFER_STUFFCMD) stuffcmd(str_player, "0");
			else if (buffer & BUFFER_SPRINT) sprint(str_player, "0");
			else if (buffer & BUFFER_DPRINT) dprint("0");
		}
		return;
	}
	
	// Is there any remainder?
	if (str_counter < 1) {
		// Print decimal point to buffer type
		if (!str_first) {
			str_first = TRUE;
			if (buffer & BUFFER_STUFFCMD) stuffcmd(str_player, "0.");
			else if (buffer & BUFFER_SPRINT) sprint(str_player, "0.");
			else if (buffer & BUFFER_DPRINT) dprint("0.");
		}
		else {
			if (buffer & BUFFER_STUFFCMD) stuffcmd(str_player, ".");
			else if (buffer & BUFFER_SPRINT) sprint(str_player, ".");
			else if (buffer & BUFFER_DPRINT) dprint(".");
		}
		if (botbit <1) botbit=1;
		str_counter = botbit;
		while (botbit > 0) { 
			str_num = str_num * 10; 
			botbit = botbit -1;
		}
		str_pow = mathlib_powbit(str_counter,10);
	}

	// Loop through lower part of number
	while(str_counter > 0) {
		// Move down one pow digit
		str_pow = str_pow / 10;

		// Divide number by pow to get divider
		// Floor can produce rounding errors (fix it with 0.01)
		str_result = floor((str_num / str_pow)+0.01);
		// New system, not used for this function
		// str_result = mathlib_divisible(str_num, str_pow);

		// Result must be 0-9 digits
		if (str_result > 9) str_result = 9;
		if (str_result < 1) str_result = 0;

		if (str_result > 0 || str_first) {
			str_first = TRUE;
			// Print digit to buffer type
			if (buffer & BUFFER_STUFFCMD) stuffcmd(str_player, ftos(str_result));
			else if (buffer & BUFFER_SPRINT) sprint(str_player, ftos(str_result));
			else if (buffer & BUFFER_DPRINT) dprint(ftos(str_result));
		}
		
		// remove top part of number, decrease str length counter
		str_num = str_num - (str_result * str_pow);
		str_counter = str_counter - 1;
	}
};

//----------------------------------------------------------------------
// Make value is not below or above limits and or negative!
//----------------------------------------------------------------------
float(float fogrange) fog_check_range =
{
	if (fogrange < 0.01) return 0.01;
	if (fogrange > 1) return 1;
	return fabs(fogrange);
};

//======================================================================
// Main fog functions
//======================================================================
void(entity client) change_fog  =
{
	if (!fog_control) return;
	
	// Update fog parameters to console buffer
	stuffcmd(client, "\n\n\nfog ");
	// Fog density can be in the range of 0-99
	lftos(client, fog_control.fog_currden, 2,3, BUFFER_STUFFCMD);

	// I use to have a direct fix for DP/FTE engines with fog density
	// being wrong, but it seems DP (latest build) is completely broken
	// with AD and it feels pointless to keep trying to fix engine visuals.
	// So this QC hack is now removed and the fog setup is as the mapper
	// intended with no QC modification.
	// if (ext_dpfog) lftos(client, fog_control.fog_currden+0.05, 1,3, BUFFER_STUFFCMD); 
	// else lftos(client, fog_control.fog_currden, 1,3, BUFFER_STUFFCMD);
	
	stuffcmd(client, " "); 
	lftos(client, fog_control.fog_currcol_x, 1,3, BUFFER_STUFFCMD); 
	stuffcmd(client, " "); 
	lftos(client, fog_control.fog_currcol_y, 1,3, BUFFER_STUFFCMD); 
	stuffcmd(client, " "); 
	lftos(client, fog_control.fog_currcol_z, 1,3, BUFFER_STUFFCMD); 
	// Extra fog parameters for DarkPlaces extended engines
	if (ext_dpfog) {
		stuffcmd(client, " ");
		stuffcmd(client, fog_control.fog_dpextra);
	}
	stuffcmd(client, "\n");
};

//----------------------------------------------------------------------
// Main fog controller loop
//----------------------------------------------------------------------
void() fog_controller_think =
{
	// Has there been a change detected?
	if (self.state == STATE_SETUP) {
		// If fog fade time too low, instantly switch
		if (self.fog_difftime <= FADEFOG_TIME) {
			self.state = STATE_OFF;
			self.fog_currden = self.fog_targden;
			self.fog_currcol = self.fog_targcol;
			change_fog(self.owner);
		}
		else {
			// Setup gradual fade of fog over time
			self.state = STATE_ON;
			// divide the fade time into segments (minimum 0.05)
			// Multiple the time by segments so diff is correct
			// Time segements less than 0.05 does not work v well
			self.fog_steptime = self.fog_difftime / FADEFOG_TIME;
			self.fog_difftime = self.fog_steptime * FADEFOG_TIME;
			
			// Work out fade directions for density/colour
			self.fog_diffden = self.fog_targden - self.fog_currden;
			self.fog_diffcol = self.fog_targcol - self.fog_currcol;

			// Debug info only
			/*----------------------------------------------------------------------
			dprint("Curr ("); 
			lftos(self.owner, self.fog_currden, 1,3, BUFFER_DPRINT); dprint(")(");
			lftos(self.owner, self.fog_currcol_x, 1,3, BUFFER_DPRINT); dprint(" ");
			lftos(self.owner, self.fog_currcol_y, 1,3, BUFFER_DPRINT); dprint(" ");
			lftos(self.owner, self.fog_currcol_z, 1,3, BUFFER_DPRINT); dprint(")\n");
			dprint("Targ ("); 
			lftos(self.owner, self.fog_targden, 1,3, BUFFER_DPRINT); dprint(")(");
			lftos(self.owner, self.fog_targcol_x, 1,3, BUFFER_DPRINT); dprint(" ");
			lftos(self.owner, self.fog_targcol_y, 1,3, BUFFER_DPRINT); dprint(" ");
			lftos(self.owner, self.fog_targcol_z, 1,3, BUFFER_DPRINT); dprint(")\n");
			dprint("Diff ("); 
			lftos(self.owner, self.fog_diffden, 1,3, BUFFER_DPRINT); dprint(")(");
			lftos(self.owner, self.fog_diffcol_x, 1,3, BUFFER_DPRINT); dprint(" ");
			lftos(self.owner, self.fog_diffcol_y, 1,3, BUFFER_DPRINT); dprint(" ");
			lftos(self.owner, self.fog_diffcol_z, 1,3, BUFFER_DPRINT); dprint(")\n");
			//----------------------------------------------------------------------*/

			// Work out step ammount to fade smoothly over time
			self.fog_diffden = self.fog_diffden / self.fog_steptime;
			self.fog_diffcol_x = self.fog_diffcol_x / self.fog_steptime;
			self.fog_diffcol_y = self.fog_diffcol_y / self.fog_steptime;
			self.fog_diffcol_z = self.fog_diffcol_z / self.fog_steptime;
		}
	}
	// Is the fog fade over? Finite amount of steps
	else if (self.fog_steptime < 0 && self.state != STATE_OFF) {
		self.state = STATE_OFF;
		self.fog_currden = self.fog_targden;
		self.fog_currcol = self.fog_targcol;

		// Density and colour should be capped at 1, but it seems
		// density can go much higher and is needed to make it solid
		// Removed the upper cap check - AD 1.7 Patch 2
		//self.fog_currden = fog_check_range(self.fog_currden);
		if (self.fog_currden < 0) self.fog_currden = 0;
		if (self.fog_currden > 99) self.fog_currden = 99;
		// Check density and colour values are within range
		self.fog_currcol_x = fog_check_range(self.fog_currcol_x);
		self.fog_currcol_y = fog_check_range(self.fog_currcol_y);
		self.fog_currcol_z = fog_check_range(self.fog_currcol_z);
		
		change_fog(self.owner);
	}
	// If the fade is active, keep adding steps
	else if (self.state == STATE_ON) {
		self.fog_steptime = self.fog_steptime - 1;
		self.fog_currden = self.fog_currden + self.fog_diffden;
		self.fog_currcol = self.fog_currcol + self.fog_diffcol;
		change_fog(self.owner);
	}

	// Keep on looping around using min time step
	self.think = fog_controller_think;
	self.nextthink = time + FADEFOG_TIME;
};

//----------------------------------------------------------------------
void(float gf_den, vector gf_col, float gf_time) fade_fog =
{
	// No controller active?
	if (!fog_control) return;

	// Fog density can be higher than 1, check larger range
	if (gf_den < 0) gf_den = 0;
	if (gf_den > 99) gf_den = 99;
	//gf_den = fog_check_range(gf_den);
	// Check colour values are within range
	gf_col_x = fog_check_range(gf_col_x);
	gf_col_y = fog_check_range(gf_col_y);
	gf_col_z = fog_check_range(gf_col_z);
		
	// Setup fog controller with new fog values
	fog_control.fog_targden = gf_den;
	fog_control.fog_targcol = gf_col;
	fog_control.fog_difftime = gf_time;

	// Force fog controller to calculate difference
	fog_control.state = STATE_SETUP;
};

//----------------------------------------------------------------------
// Setup the fog controller entity (called from client if defined)
//----------------------------------------------------------------------
void() setup_fog_controller =
{
	if (!fog_control) {
		// Start off with the fog controller disabled
		// if the worldspawn setup correctly then enable
		// the controller and allow fog changes
		fog_active = FALSE;
		
		fog_control = spawn();
		fog_control.owner = self;				// Link back to client
		fog_control.classtype = CT_CONTROL;
		fog_control.solid = SOLID_NOT;			// No world interaction
		fog_control.movetype = MOVETYPE_NONE;	// Static item, no movement
		setorigin(fog_control, '0 0 0');
		setsize(fog_control, VEC_ORIGIN, VEC_ORIGIN);
		
		if (world.fog_density <= 0) {
			fog_active = FALSE;						// out of sync
			fog_control.fog_currden = DEF_FOGDEN;	// Bad default
			fog_control.fog_targden = DEF_FOGDEN;	// Target
		}
		else {
			fog_active = TRUE;					// engine and QC insync
			fog_control.fog_currden = world.fog_density;
			fog_control.fog_targden = world.fog_density;
		}
		fog_control.fog_diffden = 0;			// Difference

		if (CheckZeroVector(world.fog_colour)) {
			fog_active = FALSE;						// out of sync
			fog_control.fog_currcol = DEF_FOGCOL;	// Bad Default
			fog_control.fog_targcol = DEF_FOGCOL;	// Target
		}
		else {
			fog_active = TRUE;					// engine and QC insync
			fog_control.fog_currcol = world.fog_colour;
			fog_control.fog_targcol = world.fog_colour;
		}
		fog_control.fog_diffcol = '0 0 0';		// Difference

		// Bat shit crazy DP extra fog parameters that no other engine uses
		// dpextra = alpha mindist maxdist top fadedepth (def=1 0 8192 1024 32)
		if (world.fog_dpextra == "") fog_control.fog_dpextra = DEF_FOGEXT;
		else fog_control.fog_dpextra = world.fog_dpextra;

		// This is a horrible hack, it should not be here
		// This parameter should be in the map file worldspawn
		//if (world.model == "maps/ad_end.bsp") 
		//	fog_control.fog_dpextra = "1 0 2048 8192 32";
		
		fog_control.state = STATE_OFF;	// Not fading atm
		fog_control.fog_difftime = 0;	// fading fog time (seconds)
		fog_control.fog_steptime = 0;	// How many steps to fade

		// Setup think process to monitor for fog changes
		// If this entity already exists, then its thinking!
		fog_control.think = fog_controller_think;
		fog_control.nextthink = time + FADEFOG_TIME;
		
		if (fog_active) change_fog(self);
	}
};

//======================================================================
// Main sky fog functions
//======================================================================
void(entity client) change_skyfog  =
{
	if (!skyfog_control) return;
	
	// Update fog parameters to console buffer
	stuffcmd(client, "\n\n\nr_skyfog ");
	// Fog density should be in the range of 0-1
	lftos(client, skyfog_control.skyfog_currden, 1,3, BUFFER_STUFFCMD);
	stuffcmd(client, "\n");
};

//----------------------------------------------------------------------
// Main sky fog controller loop
//----------------------------------------------------------------------
void() skyfog_controller_think =
{
	// Has there been a change detected?
	if (self.state == STATE_SETUP) {
		// If sky fog fade time too low, instantly switch
		if (self.skyfog_difftime <= FADEFOG_TIME) {
			self.state = STATE_OFF;
			self.skyfog_currden = self.skyfog_targden;
			change_skyfog(self.owner);
		}
		else {
			// Setup gradual fade of sky fog over time
			self.state = STATE_ON;
			// divide the fade time into segments (minimum 0.05)
			// Multiple the time by segments so diff is correct
			// Time segements less than 0.05 does not work v well
			self.skyfog_steptime = self.skyfog_difftime / FADEFOG_TIME;
			self.skyfog_difftime = self.skyfog_steptime * FADEFOG_TIME;
			
			// Work out fade directions for density
			self.skyfog_diffden = self.skyfog_targden - self.skyfog_currden;

			// Work out step ammount to fade smoothly over time
			self.skyfog_diffden = self.skyfog_diffden / self.skyfog_steptime;
		}
	}
	// Is the fog fade over? Finite amount of steps
	else if (self.skyfog_steptime < 0 && self.state != STATE_OFF) {
		self.state = STATE_OFF;
		self.skyfog_currden = self.skyfog_targden;

		// Density should be capped at 1
		self.skyfog_currden = fog_check_range(self.skyfog_currden);
		
		change_skyfog(self.owner);
	}
	// If the fade is active, keep adding steps
	else if (self.state == STATE_ON) {
		self.skyfog_steptime = self.skyfog_steptime - 1;
		self.skyfog_currden = self.skyfog_currden + self.skyfog_diffden;
		change_skyfog(self.owner);
	}

	// Keep on looping around using min time step
	self.think = skyfog_controller_think;
	self.nextthink = time + FADEFOG_TIME;
};

//----------------------------------------------------------------------
void(float gf_den, float gf_time) fade_skyfog =
{
	// No controller active?
	if (!skyfog_control) return;

	// Check Sky Fog density is range 0 - 1
	gf_den = fog_check_range(gf_den);
		
	// Setup sky fog controller with new fog values
	skyfog_control.skyfog_targden = gf_den;
	skyfog_control.skyfog_difftime = gf_time;

	// Force sky fog controller to calculate difference
	skyfog_control.state = STATE_SETUP;
};

//----------------------------------------------------------------------
// Setup the sky fog controller entity
//----------------------------------------------------------------------
void() setup_skyfog_controller =
{
	if (!skyfog_control) {
		// Start off with the sky fog controller disabled
		// if the worldspawn setup correctly then enable
		// the controller and allow fog changes
		skyfog_active = FALSE;
		
		skyfog_control = spawn();
		skyfog_control.owner = self;				// Link back to client
		skyfog_control.classtype = CT_CONTROL;
		skyfog_control.solid = SOLID_NOT;			// No world interaction
		skyfog_control.movetype = MOVETYPE_NONE;	// Static item, no movement
		setorigin(skyfog_control, '0 0 0');
		setsize(skyfog_control, VEC_ORIGIN, VEC_ORIGIN);
		
		if (world.skyfog_density <= 0) {
			skyfog_active = FALSE;						// out of sync
			skyfog_control.skyfog_currden = DEF_SKYFOGDEN;	// Bad default
			skyfog_control.skyfog_targden = DEF_SKYFOGDEN;	// Target
		}
		else {
			skyfog_active = TRUE;					// engine and QC insync
			skyfog_control.skyfog_currden = world.skyfog_density;
			skyfog_control.skyfog_targden = world.skyfog_density;
		}
		skyfog_control.skyfog_diffden = 0;			// Difference

		skyfog_control.state = STATE_OFF;	// Not fading atm
		skyfog_control.skyfog_difftime = 0;	// fading sky fog time (seconds)
		skyfog_control.skyfog_steptime = 0;	// How many steps to fade

		// Setup think process to monitor for sky fog changes
		// If this entity already exists, then its thinking!
		skyfog_control.think = skyfog_controller_think;
		skyfog_control.nextthink = time + FADEFOG_TIME;
		
		if (skyfog_active) change_skyfog(self);
	}
};
