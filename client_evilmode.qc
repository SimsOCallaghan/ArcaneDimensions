/*======================================================================
 CLIENT EVIL (skill 4) MODE FUNCTIONS
======================================================================*/

void() Client_SetEvilFlag = { cvar_set("scratch4", "1"); };
void() Client_ClearEvilFlag = { cvar_set("scratch4", "0"); };
void() Client_SetEvilSkill = { cvar_set("skill", ftos(SKILL_EVIL)); skill = SKILL_EVIL; };

//----------------------------------------------------------------------
// The engine constantly changes skill to 0-3 only
// Read console variable and set evil skill again
//----------------------------------------------------------------------
void() Client_SyncEvilmode = 
{
	// Console variable set?
	if (cvar("scratch4") > 0) {
		dprint("\b[SKILL4]\b Re-sync skill to scratch4 cvar\n");	
		Client_SetEvilSkill();
		// Force a re-sync in PlayerPreThink
		oskill = -1;
	}
};

//----------------------------------------------------------------------
// This is designed to catch quickload/load games
// Detect changes with oskill that are written to savefiles
//----------------------------------------------------------------------
void() Client_SyncPrevEvilmode =
{
	// Quickload skill check?
	if (oskill >= SKILL_EVIL) {
		dprint("\b[SKILL4]\b Detecting Quickload functions\n");
		// Set evil and skill cvar's
		Client_SetEvilFlag();
		Client_SetEvilSkill();
		// Force a re-sync in PlayerPreThink
		oskill = -1;
	}
};

//----------------------------------------------------------------------
// Basic check for EVIL mode (cvar + skill)
//----------------------------------------------------------------------
float() Client_QueryEvilmode =
{
	if (cvar("scratch4") > 0 || skill >= SKILL_EVIL) return TRUE;
	else return FALSE;
};

//----------------------------------------------------------------------
float() Client_QueryEvilskill =
{
	if (skill >= SKILL_EVIL) return TRUE;
	else return FALSE;
};

//----------------------------------------------------------------------
// Check HP for max limit and minimum (50%) balance for new games
//----------------------------------------------------------------------
void(entity targ, float hpminimum) Client_CheckMaxHP =
{
	// Make sure current HP is not over limit
	if (targ.health > targ.max_health) targ.health = targ.max_health;
	if (hpminimum && targ.health < (targ.max_health/2)) 
		targ.health = targ.max_health/2;
};

//----------------------------------------------------------------------
// Evil mode should always have a shadow axe (default)
//----------------------------------------------------------------------
void(entity targ) Client_CheckEvilInv = 
{
	// Evil skill active?
	if (Client_QueryEvilmode()) {
		// Make sure player always starts with shadow axe!?!
		if (!(targ.moditems & IT_UPGRADE_AXE)) {
			targ.items = targ.items | IT_AXE;
			// Add shadow axe to extra inventory
			targ.moditems = targ.moditems | IT_UPGRADE_AXE;
			// Cannot have grapple hook at the same time
			targ.moditems = targ.moditems - (targ.moditems & IT_UPGRADE_GHOOK);
			// Switch weapons and focus on Shadow Axe
			targ.weapon = IT_AXE;
			W_SetCurrentAmmo(targ);
		}
	}
};

//----------------------------------------------------------------------
// Setup HP/Mega limits for Evil skill and add Shadow Axe!
//----------------------------------------------------------------------
void() Client_SetupEvilmode =
{
	dprint("\b[SKILL4]\b EvilMode Enabled!\n");
	// Set Evil skill flag
	Client_SetEvilFlag();
	self.max_health = HEAL_EVILMAX;
	self.mega_health = HEAL_PLAYMAX;
	// Current HP over limit?
	Client_CheckMaxHP(self, FALSE);
	Client_CheckEvilInv(self);
};

//----------------------------------------------------------------------
// Reset HP/Mega back to skill 0-3 and check worldspawn for overrides
// prevskill is for players who switch skills to gain ShadowAxe!
//----------------------------------------------------------------------
void(float prevskill) Client_ResetEvilmode =
{
	dprint("\b[SKILL4]\b EvilMode Disabled!\n");
	// Clear Evil skill flag
	Client_ClearEvilFlag();
	// Check worldspawn for any previous default?
	if (world.player_health_z <= 0) {
		self.max_health = HEAL_PLAYMAX;
		self.mega_health = HEAL_MEGAMAX;
	}
	else {
		// Are there any skill level restriction?
		// 1 = EASY, 2 = NORMAL, 4 = HARD, 8 = NIGHTMARE, 15 = ALL
		if ( (world.player_health_z & HP_EASY && skill == SKILL_EASY) ||
			 (world.player_health_z & HP_NORMAL && skill == SKILL_NORMAL) ||
			 (world.player_health_z & HP_HARD && skill == SKILL_HARD) ||
			 (world.player_health_z & HP_NIGHTMARE && skill >= SKILL_NIGHTMARE) ) {
			// Double check max is not negative or zero
			if (world.player_health_x <= 0) self.max_health = HEAL_PLAYMAX;
			else self.max_health = world.player_health_x;
			if (world.player_health_y <= 0) self.mega_health = HEAL_MEGAMAX;
			else self.mega_health = world.player_health_y;
		}
	}
	// Current HP over limit?
	Client_CheckMaxHP(self, FALSE);
	// Switching skill levels has consequences
	if (prevskill >= SKILL_EVIL) { 
		// Shadow axe is removed and quake axe restored
		if (self.moditems & IT_UPGRADE_AXE) {
			sprint(self, "Shadow Axe removed!\n");
			sprint(self, "You feel your power fading!\n");
			stuffcmd(self, "bf\n");
			self.moditems = self.moditems - (self.moditems & IT_UPGRADE_AXE);
			self.items = self.items | IT_AXE;
			self.weapon = IT_AXE;
			W_SetCurrentAmmo(self);
		}
	}
};

//----------------------------------------------------------------------
// Show a random EVIL console/topleft message on start of map
//----------------------------------------------------------------------
void() Client_DispEvilmsg =
{
	local float rndmsg;
	// Just some funny EVIL messages
	rndmsg = floor(random()*10);
	// Draw a line on the console and pick and a random message
	sprint(self,"\<\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\>\n");
	//                                 1234567890123456789012345678901234567890
		 if (rndmsg < 1) sprint(self, "  -- Could you be \bEVIL\b incarnate? --");
	else if (rndmsg < 2) sprint(self, " -- Hear \bEVIL\b, speak \bEVIL\b, do \bEVIL\b! --");
	else if (rndmsg < 3) sprint(self, " - What is your bidding \bEVIL\b Acolyte? -");
	else if (rndmsg < 4) sprint(self, "  -- Embrace the \bEVIL\b within you! --");
	else if (rndmsg < 5) sprint(self, " -- Cut them down with \bEVIL\b intent! --");
	else if (rndmsg < 6) sprint(self, " -- \bChaos\b and \bEVIL\b are just divine! --");
	else if (rndmsg < 7) sprint(self, "-- Have you become an \bEVIL\b Believer? --");
	else if (rndmsg < 8) sprint(self, " -- \bEVIL\b deeds create great needs! --");
	else if (rndmsg < 9) sprint(self, " - After eons of time \bEVIL\b is alive! -");
					else sprint(self, "- \bEVIL\b hands find righteous purpose! -");
	sprint(self,"\n\n");
	stuffcmd(self, "bf\n");
};
