/*======================================================================
 Three basic types of behaviour is Quake, stand, walk and run
======================================================================*/

//----------------------------------------------------------------------
// ai_stand
//----------------------------------------------------------------------
void() ai_stand =
{
	self.lastorigin = self.origin;		// Save for cinematic interpolation
	if (self.health < 1) return;		// Health < 0, no more standing
	monster_liquid_check();				// Check for liquid damage
	check_tethertimer();				// Check for tethering system
	if (FindTarget ()) return;			// Found a player?
	// Double check there is a goalentity, no pause and no turret
	if (self.goalentity && time > self.pausetime && self.movespeed >= 0) {
		// Make sure AI is turning towards new path corner direction
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		ChangeYaw ();
		self.th_walk ();
	}
	else {
		// Only test ground walking monsters (no fly/swim/static)
		// Check global map variable first (default = off)
		if (map_bodyflrcheck == TRUE && self.classmove == MON_MOVEWALK) 
			ent_floorcheck(self, FLOOR_TRACE_MONSTER);
	}
};

//----------------------------------------------------------------------
// ai_walk
//----------------------------------------------------------------------
void(float dist) ai_walk =
{
	local vector vertdiff;
	
	if (self.health < 1) return;		// Health < 0, no more walking
	// Turret monsters don't walk, they stand around
	if (self.movespeed < 0) { self.th_stand(); return; }
	monster_liquid_check();				// Check for liquid damage
	movedist = dist;
	if (FindTarget ()) return;			// Found a player?
	
	// Allow for flying units to move up/down between path corners
	if (self.classmove == MON_MOVEFLY) {
		// Allow for some Z axis tolerance
		if (fabs(self.origin_z - self.goalentity.origin_z) > MON_ZTOL) {
			if (self.move_elev == 0) self.move_elev = MON_ZMOVEMENT;
			if (self.origin_z < self.goalentity.origin_z) 
				self.origin_z = self.origin_z + self.move_elev;
			else self.origin_z = self.origin_z - self.move_elev;

			vertdiff = '0 0 0';
			vertdiff_x = fabs(self.goalentity.origin_x - self.origin_x);
			vertdiff_y = fabs(self.goalentity.origin_y - self.origin_y);
			// Are the path corners stacked on top of each other?
			if (vertdiff_x < MON_ZTOL && vertdiff_y < MON_ZTOL) dist = 0;
		}
	}
	
	// Move to goal (code function)
	movetogoal (dist);
};

//----------------------------------------------------------------------
// ai_run
//----------------------------------------------------------------------
void(float dist) ai_run =
{
	if (self.health < 1) return;	// Health < 0, no more running
	monster_liquid_check();			// Check for liquid damage
	movedist = dist;

	// Is the enemy dead or no longer taking damage?
	if (SUB_healthEnemyTarget() < 1 || SUB_takedEnemyTarget() == DAMAGE_NO || self.enemyexit) {
		// Reset any exit conditions
		self.enemyexit = FALSE;
		// Remove any enemy target entity tracking
		SUB_switchEnemyTarget();
		// Reset enemy and target system
		self.enemy = self.goalentity = self.movetarget = world;
			
		// Is the old enemy still alive and can it be damaged?
		if (self.oldenemy.health > 0 && self.oldenemy.takedamage > 0) {
			self.enemy = self.oldenemy;
			HuntTarget ();
		}
		else {
			// Was this a passive monster before combat?
			if (self.passive_mode == TRUE) {
				// Return to passive monster state (reset)
				self.passive_state = MON_PASSIVESTATE_RESET;
				check_passivestate_system(self);
			}
			else {
				// Monster busy with something else?
				if (self.target != "") 
					self.movetarget = find(world, targetname, self.target);
				// Check for path corners (patrols) and return to stand/walk
				if (self.movetarget.classtype == CT_PATHCORNER) {
					self.goalentity = self.movetarget;
					self.think = self.th_walk;
				}
				else self.think = self.th_stand;
			}
			// Exit run function
			return;
		}
	}
	
	// Wake up any monsters in visual range
	self.show_hostile = time + 1;

	// check visibility of enemy
	enemy_vis = visible(SUB_entEnemyTarget());
	if (enemy_vis) {
		// Used to wake up other enemies
		self.search_time = time + 5;
		// The last time the enemy was in sight
		self.enemylastseen = time;
	}

	//----------------------------------------------------------------------
	// look for other coop players
	if (coop && self.search_time < time) {
		if (FindTarget ()) return;
	}

	// Calculate if goal/enemy is infront, the range and direction
	enemy_infront = infront(SUB_entEnemyTarget());
	enemy_range = range(SUB_entEnemyTarget());
	enemy_yaw = vectoyaw(SUB_orgEnemyTarget() - self.origin);
	self.enemydist = range_distance(SUB_entEnemyTarget(), FALSE);

	//----------------------------------------------------------------------
	// Check for temporary turret mode via trigger_monsterturret
	//----------------------------------------------------------------------
	if (self.turretactive.classtype == CT_TRIGMONTURRET && enemy_vis && self.th_missile) {
		if (self.turrettimer < time) {
			// Is there a chance to pause?
			if (random() < self.turretactive.count) 
				self.turrettimer = time + 1 + random()*2;

			self.attack_state = AS_TURRET;
			ai_run_missile ();
			return;
		}
	}
	
	//----------------------------------------------------------------------
	// Check if tether system is active
	//----------------------------------------------------------------------
	if (check_tethersystem() && self.health > 0) {
		self.tetherlock = TRUE;
		if (self.th_tether) self.think = self.th_tether;
		return;
	}

	//----------------------------------------------------------------------
	// Check for the passive state system (reset/timer etc)
	//----------------------------------------------------------------------
	if (check_passivestate_system(self)) return;
	
	//----------------------------------------------------------------------
	// Check if blocked by breakables
	CheckBlockedBreakable();
	
	//----------------------------------------------------------------------
	if (self.attack_state == AS_MISSILE) {
		ai_run_missile (); return;
	}
	else if (self.attack_state == AS_JUMP) {
		ai_run_jump (); return;
	}
	else if (self.attack_state == AS_MELEE) {
		ai_run_melee (); return;
	}
	//----------------------------------------------------------------------
	// This has to go after range/melee attack state checks
	// otherwise the AI will not do anything
	// These checks are for the next frame, not this one
	// Exception : wizards need to strafe quickly
	//----------------------------------------------------------------------
	// Some monsters don't have distance checks, like wizards
	// All monsters have checkattack defined, no need for ifs and buts!
	if (self.enemymaxdist || self.enemydist < MON_MAX_RANGE) 
		self.th_checkattack ();

	//----------------------------------------------------------------------
	if (self.attack_state == AS_SLIDING) {
		ai_run_slide (dist); return;
	}
	else if (self.attack_state == AS_SIDESTEP) {
		ai_run_sidestep (dist); return;
	}
	else if (self.attack_state == AS_BACKWARD) {
		ai_run_backward (dist); return;
	}

	// head straight towards the enemy
	// unless of course I am a turret!
	movetogoal (dist);
};
