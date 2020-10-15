//======================================================================
// To determine if an entity is still active this function generates
// an unique number that can be checked/shared between linked entities
//----------------------------------------------------------------------
void(entity targ) gen_unique_no = 
{
	// Check if target entity has an unique number already
	if (targ.entno_unique == 0) 
		targ.entno_unique = rint(random()*1000) * rint(random()*1000);
};

//======================================================================
// Most of the monsters have an attack_offset setup to spawn their
// proejctiles in the right location relative to their gun model
// This function expects the makevectors has been done already
// makevectors (self.angles); <--- if missing, vector will be rubbish!
//----------------------------------------------------------------------
vector(vector attack_dir) attack_vector =
{
	local vector retvec;
	retvec = v_forward * attack_dir_x;
	retvec = retvec + (v_right * attack_dir_y);
	retvec = retvec + (v_up * attack_dir_z);
	return retvec;
};

//----------------------------------------------------------------------
// Check vectors for zero content (extremely useful)
//----------------------------------------------------------------------
float(vector check_vec) CheckZeroVector =
{
	if (check_vec_x == 0 && check_vec_y == 0 && check_vec_z == 0)
		return TRUE;
	else return FALSE;
};

//----------------------------------------------------------------------
// Make sure vector range is positive and integers only (Z exception)
//----------------------------------------------------------------------
vector(vector mrange) CheckRangeVector =
{
	local vector retvec;
	retvec_x = rint(fabs(mrange_x));
	retvec_y = rint(fabs(mrange_y));
	retvec_z = rint(mrange_z);
	return retvec;
};

//----------------------------------------------------------------------
// Calculate the bounding box volume from bbmin/bbmax keys
//----------------------------------------------------------------------
vector(entity targ) bbox_volume =
{
	local vector retvec;
	retvec_x = fabs(targ.bbmins_x) + fabs(targ.bbmaxs_x);
	retvec_y = fabs(targ.bbmins_y) + fabs(targ.bbmaxs_y);
	retvec_z = fabs(targ.bbmins_z) + fabs(targ.bbmaxs_z);
	return retvec;
};

//----------------------------------------------------------------------
// Bmodels have a 0,0,0 origin key, need to calculate from mins/maxs
// This function will return the true origin using mins/max vectors
//----------------------------------------------------------------------
vector(entity bmodel_ent) bmodel_origin =
{
	local vector vdiff, vorigin;

	// Calculate the middle point of the mins/maxs size vectors
	// Changed /2 operation to *0.5 instead (ad1.7p2)
	vdiff_x = (bmodel_ent.maxs_x - bmodel_ent.mins_x) * 0.5;
	vdiff_y = (bmodel_ent.maxs_y - bmodel_ent.mins_y) * 0.5;
	vdiff_z = (bmodel_ent.maxs_z - bmodel_ent.mins_z) * 0.5;

	// The mins vector is an absolute value of where the Bmodel is located
	// Add mins vector to middle point to get true origin
	// When bmodel do move they also update their origin co-ordinates
	// So any additional movement needs to be added as well
	// This means that bmodels can be tracked by movement functions
	vorigin = bmodel_ent.origin + bmodel_ent.mins + vdiff;
	
	// Return origin
	return vorigin;
};

//----------------------------------------------------------------------
// This is version is using the bbmin/bbmax entity keys instead
// Useful if the entity is hidden and want to know origin
vector(entity bmodel_ent) bmodel_bborigin =
{
	local vector vdiff, vorigin;
	vdiff_x = (bmodel_ent.bbmaxs_x - bmodel_ent.bbmins_x) * 0.5;
	vdiff_y = (bmodel_ent.bbmaxs_y - bmodel_ent.bbmins_y) * 0.5;
	vdiff_z = (bmodel_ent.bbmaxs_z - bmodel_ent.bbmins_z) * 0.5;
	vorigin = bmodel_ent.origin + bmodel_ent.bbmins + vdiff;
	return vorigin;
};

//======================================================================
// Vector randomizer, used mostly for avelocity setups
// Used all over the place; monsters, weapons and gibs!
// 
//----------------------------------------------------------------------
vector(float base, float rndmix, float plusminus) vecrand =
{
	local vector vecmix;
	if (plusminus) {
		vecmix_x = base + crandom() * rndmix; 
		vecmix_y = base + crandom() * rndmix; 
		vecmix_z = base + crandom() * rndmix; 
	}
	else {
		vecmix_x = base + random() * rndmix; 
		vecmix_y = base + random() * rndmix; 
		vecmix_z = base + random() * rndmix; 
	}
	return vecmix;
};

//======================================================================
// Trigger/use all entities that match the supplied targetname
// self is switched around so target use function works correctly
//
//----------------------------------------------------------------------
void(string target_strs, entity activator_ent) trigger_strs =
{
	local entity tself, tother, tactivator, ent_list;

	// Some entities constantly use this function (<0.1s trigger)
	// This is just an entity key to block the debug info
	if (activator_ent.nodebuginfo == FALSE) {
		dprint("\b[STR_TRIG]\b Str ("); dprint(target_strs);
		dprint(") Activator ("); dprint(activator_ent.classname);
		if (target_strs == "") dprint(") - ERROR!!\n");
		else dprint(")\n");
	}

	// Prevent this function from triggering everything by
	// checking if the target_str is empty (empty = world)
	if (target_strs != "") {
		// Store self/other for later
		tself = self;
		tother = other;
		tactivator = activator;
		if (activator_ent.flags & FL_CLIENT) activator = activator_ent;
	
		// Build initial list from world
		ent_list = find(world, targetname, target_strs);
		// Cycle through list
		while(ent_list) {
			// Setup self/other ready for trigger/use function
			self = ent_list;
			other = tself;
			if (self.use) {
				self.activate = activator_ent;		// Link activator
				self.use();							// Fire use function
			}
			// Find next trigger from intial list (not world)
			ent_list = find(ent_list, targetname, target_strs);
		}
		// Restore self/other from previous temp storage
		self = tself;
		other = tother;
		if (activator_ent.flags & FL_CLIENT) activator = tactivator;
	}
};

//======================================================================
// Trigger/use the entity supplied and activator
// self is switched around so target use function works correctly
//
//----------------------------------------------------------------------
void(entity target_ent, entity activator_ent) trigger_ent =
{
	local entity tself, tother, tactivator;

	// Some entities constantly use this function (<0.1s trigger)
	// This is just an entity key to block the debug info
	if (activator_ent.nodebuginfo == FALSE) {
		dprint("\b[ENT_TRIG]\b Ent ("); dprint(ftos(target_ent.classtype));
		dprint(") Activator ("); dprint(activator_ent.classname);
		if (!target_ent) dprint(") - ERROR!!\n");
		else dprint(")\n");
	}

	if (target_ent && target_ent.use) {
		// Save self/other for later
		tself = self;
		tother = other;
		tactivator = activator;
		if (activator_ent.flags & FL_CLIENT) activator = activator_ent;
		
		// Switch around self/other for USE function
		self = target_ent;
		other = tself;
		
		// Use trigger
		if (self.use) {
			self.activate = activator_ent;		// Link activator
			self.use();							// Fire use function
		}
			
		// Restore self/other from previous temp storage
		self = tself;
		other = tother;
		if (activator_ent.flags & FL_CLIENT) activator = tactivator;
	}
};

//======================================================================
// Check if the entity has solid surface below 
// There is no entity type checks, can be any entity in theory!
// First check is checkbottom for complete bounding box coverage
// Second check is trace down to find floor surface below
// Typical trace down distance is 128 units with 24 unit difference
//
// Uses for this function:-
// ai_states.qc - ai_stand
// monsters.qc  - monster_deadbody_check
// ai_gibs.qc   - CheckFloorGib
// items.qc     - item_thinkloop
//
//----------------------------------------------------------------------
void(entity source, float floor_dist) ent_floorcheck =
{
	local vector trace_pos1;
	local float trace_dist;
	
	// if (!checkbottom(source)) = disabled
	//  too expensive, 5 traces (4 corners + center) and liquid check

	// Tracedown directly from origin for floor check
	trace_pos1 = source.origin;
	trace_pos1_z = trace_pos1_z - FLOOR_TRACE_DIST;
	traceline (source.origin, trace_pos1, TRUE, source);
	
	// Work out distance from origin to floor
	trace_dist = source.origin_z - trace_endpos_z;
	
	// Check if the floor is too far away? (usually 24 units)
	if (trace_dist > floor_dist && source.flags & FL_ONGROUND) {
		// Move entity up and do a trace/fall down (256 units max)
		source.oldorigin = source.origin;
		source.origin_z = source.origin_z + 1;
		droptofloor();
		if (source.oldorigin != source.origin) {
			// lift entity upward and remove onground flag
			source.flags = source.flags - (source.flags & FL_ONGROUND);
			source.velocity_z = 10 + 10*random();
			// Check for any attachment (lids) for ammo
			if (source.classgroup == CG_AMMOITEM && source.attachment) {
				// sync flag/velocity so lid falls correctly
				source.attachment.flags = source.attachment.flags - (source.attachment.flags & FL_ONGROUND);
				source.attachment.velocity = source.velocity;
			}
		}
		// Move item back to original pos before droptofloor
		setorigin(source, source.oldorigin);
	}
};

//======================================================================
// Check for contact with sky brushes
// - Use pointcontent() for Typical/Enhanced Quake engines
// - Use new FTE string functions and surface check for Darkplaces engine
//
//----------------------------------------------------------------------
float(vector targ_origin) check_skycontent =
{
	local float surfnum;
	local string texturename;

	// projectile owner exeception (bad FPS for large maps)
	if (self.owner.proj_noskycheck == TRUE) return FALSE;

	// Does the engine supports extended surface checks?
	// This functionality can be bad for FPS with large maps
	// 2 ways to disabled this, worldspawn key or individually
	else if (ext_dpsurf) {
		surfnum = getsurfacenearpoint(world, targ_origin);
		if (surfnum >= 0) {
			texturename = getsurfacetexture(world, surfnum);
			if (strncasecmp(texturename, "SKY", 3) == 0) return TRUE;
		}
	}
	else {
		// Original method for checking sky content (Fitz engines)
		if (pointcontents(targ_origin) == CONTENT_SKY) return TRUE;
	}
	return FALSE;
};

//----------------------------------------------------------------------
float(vector bborg, float bbx, float bby, float bbz) check_skyvector =
{
	local vector skyorg;
	skyorg_x = bborg_x + bbx;
	skyorg_y = bborg_y + bby;
	skyorg_z = bborg_z + bbz;
	if (check_skycontent(skyorg) == TRUE) return TRUE;
	else return FALSE;
};

//----------------------------------------------------------------------
// This function was about testing volume projectiles against sky brushes
// Unfortunately on advanced engines (DP/FTE/QSS) it can trash frame rate
// This is especially apparent on very large maps
// Function disabled - it was a bad idea, left as a reminder
//----------------------------------------------------------------------
/*float(entity targ) check_skyvolume = 
{
	// Negative Z corners
	if (check_skyvector(targ.origin, -targ.size_x, -targ.size_y, -targ.size_z)) return TRUE;
	if (check_skyvector(targ.origin,  targ.size_x, -targ.size_y, -targ.size_z)) return TRUE;
	if (check_skyvector(targ.origin, -targ.size_x,  targ.size_y, -targ.size_z)) return TRUE;
	if (check_skyvector(targ.origin,  targ.size_x,  targ.size_y, -targ.size_z)) return TRUE;
	
	// Positive Z corners
	if (check_skyvector(targ.origin, -targ.size_x, -targ.size_y, targ.size_z)) return TRUE;
	if (check_skyvector(targ.origin,  targ.size_x, -targ.size_y, targ.size_z)) return TRUE;
	if (check_skyvector(targ.origin, -targ.size_x,  targ.size_y, targ.size_z)) return TRUE;
	if (check_skyvector(targ.origin,  targ.size_x,  targ.size_y, targ.size_z)) return TRUE;
	
	// No contact!
	return FALSE;
};*/

//----------------------------------------------------------------------
// Check point content for SOLID or SKY problems
//----------------------------------------------------------------------
float(vector pc_org) entity_pcontent =
{
	local float pcontent;
	pcontent = pointcontents(pc_org);
	if (pcontent == CONTENT_SOLID) return TRUE;
	if (check_skycontent(pc_org)) return TRUE;
	return FALSE;
}

//======================================================================
// Updates totals on the HUD (checks for client to exist)
// - Specify which total to update using constant
// - Uses MSG_ONE because it is more reliable across many clients
// - Other client updates (SVC_KILLEDMONSTER, SVC_FOUNDSECRET)
// 
//----------------------------------------------------------------------
void(float hud_item) update_hud_totals =
{
	// Has the client player been setup yet?
	if (client_ent && client_ent.flags & FL_CLIENT) {

		// Update total secrets
		if (hud_item & HUD_SECRETS) {
			msg_entity = client_ent;
			WriteByte (MSG_ONE, SVC_UPDATESTAT);
			WriteByte (MSG_ONE, STAT_TOTALSECRETS);
			WriteLong (MSG_ONE, total_secrets); 
		}
		// Update total monsters
		if (hud_item & HUD_MONSTERS) {
			msg_entity = client_ent;
			WriteByte (MSG_ONE, SVC_UPDATESTAT);
			WriteByte (MSG_ONE, STAT_TOTALMONSTERS);
			WriteLong (MSG_ONE, total_monsters); 
		}
	}
};

//======================================================================
// Reduce any entity down to a non-interactive empty marker
//
//----------------------------------------------------------------------
void(entity targ) entity_stop =
{
	if (targ == world) return;			// Targ is wrong
	targ.use = targ.touch = SUB_Null;	// No more touchy
	targ.think = SUB_Null;				// No more thinking/animation
	targ.nextthink = -1;				// Never fire think
	targ.estate = ESTATE_OFF;			// Entity state off
	targ.takedamage = DAMAGE_NO;		// No pain/death triggers
	targ.height = 0;					// Model fade functionality
	targ.movetype = MOVETYPE_NONE;		// Stationary
	targ.solid = SOLID_NOT;				// no world interaction
	setsize (targ, VEC_ORIGIN, VEC_ORIGIN);		// No size, no impact
	targ.velocity = targ.avelocity = '0 0 0';	// Frozen velocity
	targ.spawnflags = targ.effects = 0;			// reset flags
	targ.waitmin = time + LARGE_TIMER;			// Block touch function
	targ.attack_finished = time + LARGE_TIMER;	// Block all functions
};

//----------------------------------------------------------------------
void(entity targ) entity_hide =
{
	if (targ == world) return;			// Targ is wrong
	entity_stop(targ);					// No world interaction
	targ.modelindex = 0;				// Make sure no model
	setmodel (targ, "");				// invisible
};

//----------------------------------------------------------------------
void(entity targ, float removetime) entity_remove =
{
	if (targ == world) return;			// Targ is wrong
	entity_hide(targ);					// Prepare entity for removal
	targ.think = SUB_Remove;			// Remove entity gradually
	targ.nextthink = time + removetime;
};

//======================================================================
// Show where broken monster/items are located (developer only)
// SPNMARK_YELLOW, SPNMARK_BLUE, SPNMARK_GREEN,
// SPNMARK_RED, SPNMARK_PURPLE, SPNMARK_WHITE
//----------------------------------------------------------------------
void(vector marker_org, float marker_type) spawn_marker =
{
	local entity marker;
	
	// Exceptions
	if (query_configflag(SVR_DEVHELPER)) return;
	if (developer == 0) return;

	// Dev Marker
	marker = spawn();
	marker.classtype = CT_DEVMARKER;
	marker.movetype = MOVETYPE_NONE;
	marker.solid = SOLID_NOT;
	setmodel(marker, MODEL_BROKEN);
	setorigin(marker, marker_org);
	setsize (marker, VEC_ORIGIN, VEC_ORIGIN);
	// Setup marker type (skin colour)
	// YELLOW = error, BLUE = delay, GREEN = nocount, RED = nightmare
	marker.skin = marker_type;
	marker.frame = 0;
	// If DP engine active remove particle shadow
	if (engine == ENG_DPEXT) marker.effects = marker.effects + EF_NOSHADOW;
};

//----------------------------------------------------------------------
void(vector marker_org, vector marker_ang, float marker_type) spawn_arrow =
{
	local entity marker;
	
	// Exceptions
	if (query_configflag(SVR_DEVHELPER)) return;
	if (developer == 0) return;

	// Dev Marker
	marker = spawn();
	marker.classtype = CT_DEVMARKER;
	marker.movetype = MOVETYPE_NONE;
	marker.solid = SOLID_NOT;
	setmodel(marker, MODEL_CORNER1);
	setorigin(marker, marker_org);
	setsize (marker, VEC_ORIGIN, VEC_ORIGIN);
	marker.angles = marker_ang;
	// Setup marker type (skin colour)
	// YELLOW = 0, DARK GREEN = 1, GREEN = 2, WHITE = 3, RED = 4
	marker.skin = marker_type;
	marker.frame = 0;
	marker.alpha = 0.5 + random()*0.5;
	// If DP engine active remove particle shadow
	if (engine == ENG_DPEXT) marker.effects = marker.effects + EF_NOSHADOW;
};

//----------------------------------------------------------------------
entity(vector spawn_org) spawn_devmarker =
{
	local entity spawn_ent;
	
	spawn_ent = spawn();
	spawn_ent.classtype = CT_DEVMARKER;
	spawn_ent.movetype = MOVETYPE_NONE;
	spawn_ent.solid = SOLID_NOT;
	setmodel(spawn_ent, MODEL_BROKEN);
	setorigin(spawn_ent, spawn_org);
	setsize (spawn_ent, VEC_ORIGIN, VEC_ORIGIN);
	return spawn_ent;
};

//----------------------------------------------------------------------
// This is designed for delay spawn monsters ONLY!
// It will certainly do crazy things if not used correctly
//----------------------------------------------------------------------
void(entity targ) monster_devmarker =
{
	// Exceptions
	if (query_configflag(SVR_DEVHELPER)) return;
	if (developer == 0) return;

	targ.movetype = MOVETYPE_NONE;
	targ.solid = SOLID_NOT;
	setmodel(targ, MODEL_BROKEN);
	if (targ.nomonstercount == 1) targ.skin = SPNMARK_GREEN;
	else if (targ.delaymonstercount == 1) targ.skin = SPNMARK_GREEN;
	else targ.skin = SPNMARK_BLUE;
	targ.frame = 0;	
};

//----------------------------------------------------------------------
// Check for SKILL spawning conditions (frame 0 check ONLY)
// Returns FALSE = do nothing  TRUE = inhibit spawning
//----------------------------------------------------------------------
float() check_nightmare =
{
	// Check for nightmare skill only spawning
	if (self.nightmare == TRUE) {
		// Double check the coop console variable, not setup till frame 1+
		// Use a nosave variable to prevent constant cvar command checking
		if (skill_cvar != TRUE) { skill = cvar("skill"); skill_cvar = TRUE; }
		if (skill >= SKILL_NIGHTMARE) return FALSE;
		else {
			// Check for BSP entities has origin is different
			if (self.bsporigin) spawn_marker(bmodel_origin(self), SPNMARK_RED);
			else spawn_marker(self.origin, SPNMARK_RED);
			// Hide entity instead of removing it
			// Because of possible active touch functions
			entity_hide(self);
			return TRUE;
		}
	}
	return FALSE;
};

//----------------------------------------------------------------------
// Check for COOP spawning conditions (frame 0 check ONLY)
// Returns FALSE = do nothing  TRUE = inhibit spawning
//----------------------------------------------------------------------
float() check_coop =
{
	// Check for coop only spawning conditions
	if (self.cooponly == TRUE || self.cooponly == NEGATIVE) {
		// Double check the coop console variable, not setup till frame 1+
		// Use a nosave variable to prevent constant cvar command checking
		if (coop_cvar != TRUE) { coop = cvar("coop"); coop_cvar = TRUE; }
		
		// Only one condition will let a cooponly item spawn
		// cooponly =  1  coop = 0 inhibit = TRUE
		// cooponly =  1  coop = 1 inhibit = FALSE
		// cooponly = -1  coop = 0 inhibit = FALSE (fixed)
		// cooponly = -1  coop = 1 inhibit = TRUE
		if (self.cooponly == TRUE && coop == TRUE) return FALSE;
		// Added 1.7 Patch 2 (cooponly negative logic was wrong)
		else if (self.cooponly == NEGATIVE && coop == FALSE) return FALSE;
		else {
			// Check for BSP entities has origin is different
			if (self.bsporigin) spawn_marker(bmodel_origin(self), SPNMARK_PURPLE);
			else spawn_marker(self.origin, SPNMARK_PURPLE);
			// Hide entity instead of removing it
			// Because of possible active touch functions
			entity_hide(self);
			return TRUE;
		}
	}
	return FALSE;
};

//======================================================================
// Clear all trigger strings
//
//----------------------------------------------------------------------
void (entity targ) clear_trigstrs =
{
	if (targ.target != "") targ.target = string_null;
	if (targ.target2 != "") targ.target2 = string_null;
	if (targ.killtarget != "") targ.killtarget = string_null;
};

//======================================================================
// model_fade : Gradually fade out a model over time 
// * Optionally entity removal if height = 0
//
//----------------------------------------------------------------------
void() model_fade =
{
    self.alpha = 1 - ((time - self.ltime) / 1);

    if (self.alpha > 1) self.alpha = 1;
    else if (self.alpha <= 0) {
        self.alpha = 0;
		self.modelindex = 0;	// Make sure no model
        self.model = "";
        // Remove model by default
        if (self.height == 0) {
			self.think = SUB_Remove;
			self.nextthink = time + 1;
 		}
        return;
    }

    self.nextthink = time + FADEMODEL_TIME;
};

/*======================================================================
 skill_chanceattack
  Calculate chance to attack player based on skill level and distance
  The standard ID range formula
	(enemy_range == RANGE_MELEE) chance = 0.9
	(enemy_range == RANGE_NEAR) chance = 0.4
	(enemy_range == RANGE_MID) chance = 0.05
	else chance = 0;
	The problem with this formula is that the chance factor is not gradual
	and will spike in chance when close to range boundaries
	Also this formula has no skill modifiers leading to limited gameplay rules
  
======================================================================*/
float() SUB_ChanceAttack =
{
	local float chrange, chskill, chance;
	
	chrange = chskill = 0;					// taniwha patch
	
	// Upper and lower limits of range have fixed chance rates
	if (self.enemydist > MON_MAX_RANGE) chance =  0.05;
	else if (self.enemydist < MON_RANGE_MELEE) chance = 0.95;
	else {
		// Random chance of range attack based on player distance
		chrange = ((MON_MAX_RANGE - self.enemydist) / MON_STEPRANGE) / 10;
		
		// Skill modifier to chance (Easy -0.2 Norm -0.1, Hard 0, Night 0.1)
		chskill = ((skill-SKILL_HARD)*0.1);
		chance = chrange + chskill;
		
		// There Should always be a chance to HIT or MISS
		if (chance > 0.95) chance = 0.95;
		else if (chance < 0.05) chance = 0.05;
	}
	
	// Return result and finish debug information line
	if (random() < chance) return TRUE;
	else return FALSE;
};

/*======================================================================
 skill_subattack
  Calculate attack_finished time based on skill level
======================================================================*/
float (float min_time, float ranbase_time) SUB_SkillAttack =
{
	local float ran_time, sub_time;
	
	// Easy = min + random(base + 1.5)    Normal = min + random(base + 1.0)
	// Hard = min + random(base + 0.5)    Nightm = min + random(base + 0.0)
	ran_time = ranbase_time + ((SKILL_NIGHTMARE - skill) * 0.5);
	sub_time = min_time + (ran_time * random());
	
	return sub_time;
};

/*======================================================================
 SUB_Tracking
 Progressively tracks the origin of enemies making attacks more accurate
  * Original code by Necros (http://shoresofnis.com/)
======================================================================*/
vector(vector iorg, vector org_offset, entity targ, float zspeed) SUB_Tracking =
{
	local vector vec, org;
	local float diff;

	// Allow for source origin to be fine tuned (directional)
	makevectors (self.angles);
	org = self.origin + attack_vector(org_offset);

	diff = vlen(iorg - org) / zspeed;		// Workout difference
	vec = targ.velocity;
	if (targ.flags & FL_MONSTER) vec_z = 0;	// Flatten Z axis for monsters
	else vec_z = vec_z * 0.2;				// Aim for headshot with players

	iorg = targ.origin + diff * vec;		// Refine target origin
	return iorg;
};

/*======================================================================
 SUB_Elevation
  Calculates the Elevation for Z Aware monsters
  * Original code by Preach (https://tomeofpreach.wordpress.com/)
  * Added support for variable origin locations and proj speeds
  * Added support for distance scaling linked to skill levels
======================================================================*/
float(float theta, vector sorg, vector mdest, float zspeed) SUB_Elevation =
{
	local float a, b, c; 	//constants in the equation to be solved
	local vector ofs; 		//displacement we wish the projectile to travel
	local float y, z; 		//horizontal and vertical components of ofs
	local float tan_theta; 	//trig values of the angle theta
	local vector vec, eorg;
	local float dist, sperc;

	// Place projectile destination at player head level
	if (self.classtype == CT_MONSPIDER) mdest = mdest + ELEV_SPID_OFS;
	else mdest = mdest + ELEV_VIEW_OFS;

	// Work out vector distance between source and destination
	// Normalize the distance and create a percentage of that
	// This is a skill based calculation so the aiming gets better
	// The grenade is aimed infront of target so that it bounces
	// No check for vertical difference so it bad going up height!
	// Zombie, poison spiders zaware calculation is fine, exception!
	if (self.classgroup != CG_ZOMBIE && self.classtype != CT_MONSPIDER
		&& self.classtype != CT_MONBOGLORD) {
		vec = mdest - sorg;
		dist = vlen(vec);
		vec = normalize(vec);
		sperc = 0.45 + skill*0.15;
		eorg = sorg + (vec * (dist*sperc));
		ofs = eorg - sorg;
	}
	else ofs = mdest - sorg;
		
	//calculate how far we are firing
	//	ofs = mdest - sorg;
	z = ofs_z;
	ofs_z = 0;
	y = vlen(ofs);
 
	// Map gravity is a global variable defined in world.qc
	//find the coefficients of the quadratic in tan(theta)
	a = 0.5 * map_gravity * y * y / (zspeed * zspeed);
	b = -y;
	c = a + z;
 
	//check if the destination is too far to reach
	if(b*b < 4*a*c) return ELEV_DEFAULT;

	//calculate the tan value of the given theta
	tan_theta = mathlib_tan(theta);

	//reuse ang to create the improved firing direction
	theta = mathlib_atan2(a*tan_theta*tan_theta - c, 2*a*tan_theta + b);

	//constrain the values to stop anything too mad happening
	while(theta > 90) theta = theta - 180;
	return theta;
};

/*======================================================================
 SUB_Elevat (Alternative version, not used anymore, left for reference)
  Calculates the Elevation for Z Aware monsters
  * Original formula WIKI with QC help from ericw
======================================================================*/
/*float(vector source, vector targ, float zspeed) SUB_Elevat =
{
	local float g;				// Gravity
	local float targx, targy;	// Sub parts of distance
	local float v2, v4;			// speed*speed & speed*speed*speed*speed
	local vector dist;			// Distance to travel	
	local float ang, theta;
	
	g = map_gravity;			// default 800
	dist = targ - source;		// vector distance
	targy = dist_z;				// Up direction
	dist_z = 0;
	targx = vlen(dist);			// X,Y direction

	v2 = zspeed * zspeed;
	v4 = v2 * v2;
	
	// First part of equation
	ang = v4 - (g * ( (g * targx * targx) + (2 * targy * v2) ) );
	// Cap elevation angle at default value
	//if(ang < 0) return ELEV_DEFAULT;

	// Second section of equation
	theta = mathlib_atan2 ((v2 - mathlib_sqrt(ang)) / (g * targx),1);
	return theta;
}; */
