/*======================================================================
 Player/client Grapple Hook
 
 Rogue Grapple Implementation - Jan'97 by ZOID
  * Only given to player with teamplay 4+ and deathmatch 1 game modes
  * Has a proper hook (animated) and v_weapon model for the player
  * Special beam code (TE_BEAM) for chain between player and hook
  * Slow firing speed of grapple (800 velocity, less than nail/rockets)
  * When grapple hits a surface, is pulled towards hook at 1000 velocity
  * HUD is updated (extra icons) when grapple gun is selected
  * Press/fire to launch the grapple forward for 2s (limits range)
  * Hold fire to push the player forward, only once grapple hooked
  * Can hang from any surface (including sky) for indefinite time
  * Should not work on sky surfaces, uses old pointcontents check
  * Once attached to wall can switch and fire weapons without falling
  * No extra player movement when attached to wall, perfectly still
  * Will do 10dmg when hitting an object/surface (player/button)
  
 Speed runner Implementation - Jul '97 by Perecli Manole AKA Bort
  * This is HEAVILY based on the rogue version, its not 100% original
  * No special mode required to access the hook, available all the time
  * Uses voreball model for hook and NO v_weapon model for the player
  * Generates the chain via a series of models (can stretch with frames)
  * When the grapple hits a surface, the player is dragged in an arc
  * Designed to be a swinging mechanic rather than direct movement
  * Has no extra HUD support or v_model to show item is available
  * Designed to work with other weapons out at the same time (Alt mode)
  * Once at the grapple point, the player is bounced around a lot
  * Press/fire to launch the grapple forward for 2s (limits range)
  * Hold fire to push the player forward, only once grapple hooked
  * Can hang from any surface (including sky) for indefinite time
  * Should not work on sky surfaces, uses old pointcontents check
  * Allows for double tap to fire/release of the grapple point
 
 AD Implementation - Jul 2020 Mostly based on Rogue version
 
======================================================================*/

float GH_PROJOPEN = 0;			// Projectile Hook claws pulled back
float GH_PROJFLYING = 1;		// Projectile Hook claws midway
float GH_PROJCLOSED = 2;		// Projectile Hook claws in deep

float GHC_MAXSPEED = 2000;		// Maximum projectile travel speed
string GHC_SEARCHSTR = "MAGNET";// Special string to find func_grapple hooks
float GH_FUNCBLOCK = 1;			// Grapple hook has been blocked
float GH_FUNCUSED = 2;			// Func_grapplehook has been used

float GHC_TIMEOUT = 0.7;		// Weapon timeout from hitting player/monster
float GHC_TIMERESET = 0.2;		// Minimum amount of time before can use again
float GHC_TIMEMISFIRE = 0.3;	// Misfire sound re-play timer

float GHC_DEBUGMARKS = 40;		// Total amount of debug info markers
float GHC_DEBUGAFTER = 8;		// Ammount to show after releasing grapple hook
float GHC_DEBUGSTART = SPNMARK_WHITE;	// Start of debug marker chain
float GHC_DEBUGCHAIN = SPNMARK_GREEN;	// On chain movement towards grapple
float GHC_DEBUGCLOSE = SPNMARK_BLUE;	// Really close to grapple point
float GHC_DEBUGLETGO = SPNMARK_PURPLE;	// After release from grapple chain
float GHC_DEBUGTIMER = 0.05;	// Timer to slowdown displaying markers

float GHC_HOOKSTYLE = 0;		// Default grapple hook style
float GHC_HOOKEARLY = 0;		// Minimum distance to start pulling player
float GHC_MAXDIST = 1200;		// Max distance to travel before attachment
float GHC_HOOKSPEED = 2000;		// Forward momentum of hook (rocket spd+)
float GHC_PULLSPEED = 600;		// Forward momentum on chain (pulling forward)
float GHC_MINDIST = 100;		// Minimum distance to slowdown velocity
float GHC_MINBEAM = 50;			// Minimum distance to stop drawing beam
float GHC_SIDEANGLE = 20;		// Minimum side angle to check for

float GHC_DMGPLAYER = 4;		// Impact damage against other players
float GHC_DMGMONSTER = 8;		// Impack damage to ALL monsters
float GHC_DMGWORLD = 8;			// Impact damage to world/func entities

vector GHC_LINECHAIN = '16 0 32';		// Forward/Right/Up movement on chain
vector GHC_JUMPCHAIN = '200 0 200';		// Forward/Right/Up jump off chain
vector GHC_BOOSTCHAIN = '300 300 200';	// Forward/Right/Up movement boost
vector GNC_MOVEMONS = '150 0 200';		// Forward/Right/Up monster PUSH

float FUNC_GHOOKBLOCK = 2;		// bmodel blocks grapple hook
float FUNC_GHOOKSOLID = 4;		// bmodel blocks player/projectiles
float FUNC_GHOOKDISPLAY = 16;	// bmodel is visible when enabled
float FUNC_GHOOKALPHA = 32;		// bmodel surface is alpha flickering

// Forward compiler references
void() GrappleHook_Touch;
void(vector org, vector dir, float part_qty) func_ghook_impact;
void(entity targ, entity cltarg, float trigtype) func_ghook_trigger;
void(float switchbbox) func_ghook_bbox;
float() func_ghook_count;

//====================================================================
void() GrappleHook_Distance = 
{
	if (!self.hookent) return;
	self.gh_hookdist = vlen(self.hookent.origin - self.origin);
};

//--------------------------------------------------------------------
void() GrappleHook_MisFire =
{
	// Misfire of weapon
	if (self.gh_misfire < time) {
		sound (self, CHAN_WEAPON, SOUND_MISFIRE, 1, ATTN_NORM);
		self.gh_misfire = time + GHC_TIMEMISFIRE;
	}
};

//====================================================================
// Draw chain using the TE_BEAM system from rogue
//====================================================================
void(entity beamhook, entity targ) GrappleHook_Beam =
{
	// Draw a line (beam.mdl) from hook to player
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_BEAM);
	WriteEntity (MSG_BROADCAST, beamhook);
	WriteCoord (MSG_BROADCAST, beamhook.origin_x);
	WriteCoord (MSG_BROADCAST, beamhook.origin_y);
	WriteCoord (MSG_BROADCAST, beamhook.origin_z);
	// Offset from player origin (firing position)
	WriteCoord (MSG_BROADCAST, targ.origin_x + beamhook.meleeoffset_x);
	WriteCoord (MSG_BROADCAST, targ.origin_y + beamhook.meleeoffset_y);
	WriteCoord (MSG_BROADCAST, targ.origin_z + beamhook.meleeoffset_z);
};

//====================================================================
// Hide Captain Hook! ( Expecting TARG = HOOK )
//====================================================================
void(entity targ) GrappleHook_Reset = 
{
	// Double check this is a hook entity
	if (targ.classtype != CT_GHOOKPROJ) return;
	
	// Updates to CLIENT only
	targ.owner.gh_onhook = FALSE;
	targ.owner.gh_hookout = FALSE;
	targ.owner.gh_pullchain = FALSE;
	if (targ.owner.gh_blockhook < time)
		targ.owner.gh_blockhook = time + GHC_TIMERESET;
	targ.owner.gh_debugafter = GHC_DEBUGAFTER;

	// Updates to HOOK only
	setmodel(targ, "");
	setsize(targ, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(targ, targ.owner.origin);
	targ.movetype = MOVETYPE_NONE;
	targ.solid = SOLID_NOT;
	targ.frame = GH_PROJOPEN; targ.skin = 0;
	targ.velocity = targ.avelocity = 0;
	// Always reset flags, otherwise grapple might have onfloor set
	targ.flags = 0; targ.effects = 0;
	targ.attack_finished = 0;
};

//--------------------------------------------------------------------
void() GrappleHook_ResetNoParm = { GrappleHook_Reset(self); };

//====================================================================
// Generate debug diamond chain
// SPNMARK_YELLOW, SPNMARK_BLUE, SPNMARK_GREEN,
// SPNMARK_RED, SPNMARK_PURPLE, SPNMARK_WHITE
//====================================================================
void() GrappleHook_DebugCreate =
{
	local entity hook_prev, hook_first, hookdiam;
	local float debugloop;
	
	// Exceptions
	if (query_configflag(SVR_DEVHELPER)) return;
	if (developer == 0) return;
	if (self.gh_debugmove < 1) return;
	if (self.hookchain) return;
	
	debugloop = 0;
	hookdiam = hook_first = hook_prev = world;
	
	while (debugloop < self.gh_debugmove) {
		// Create debug diamond (based on spawn_marker function)
		hookdiam = spawn();
		hookdiam.classtype = CT_DEVMARKER;
		hookdiam.movetype = MOVETYPE_NONE;
		hookdiam.solid = SOLID_NOT;
		setmodel(hookdiam, MODEL_BROKEN);
		// Initally setup the diamonds around the player origin
		setorigin(hookdiam, self.origin + vecrand(8,8,TRUE));
		setsize (hookdiam, VEC_ORIGIN, VEC_ORIGIN);
		hookdiam.skin = SPNMARK_RED;	// Just setup
		hookdiam.frame = 0;
		hookdiam.count = debugloop;		// Sanity check for debug
		// If DP engine active remove particle shadow
		if (engine == ENG_DPEXT) hookdiam.effects = hookdiam.effects + EF_NOSHADOW;

		// Save first entity for later (closing loop)
		if (hook_first == world) hook_first = hookdiam;
		// First time setup of previous entity (points to self)
		if (hook_prev == world) hook_prev = hookdiam;
		// Setup previous entity (first time = self)
		hook_prev.hookchain = hookdiam;
		// Advance the previous entity forward  to current
		hook_prev = hookdiam;
		
		// Keep on looping
		debugloop = debugloop + 1;
	}
	// Close the loop and setup pointer for client
	hookdiam.hookchain = hook_first;
	self.hookchain = hook_first;
};

//--------------------------------------------------------------------
void(float markskin) GrappleHook_DebugUpdate =
{
	// Exceptions
	if (query_configflag(SVR_DEVHELPER)) return;
	if (developer == 0) return;
	if (!self.hookchain) return;
	
	// Check skin range first and then update skin number
	if (markskin < SPNMARK_YELLOW) markskin = SPNMARK_YELLOW;
	if (markskin > SPNMARK_WHITE) markskin = SPNMARK_WHITE;
	self.hookchain.skin = markskin;
	// Place diamond ( self = client )
	setorigin(self.hookchain, self.origin);
	// Move along entity chain to next diamond
	self.hookchain = self.hookchain.hookchain;
};

//====================================================================
// DISPLAY hook parameters in developer console table
//====================================================================
void() GrappleHook_Display =
{
	local float trigtotal;
	// Has the hook been setup yet?
	if (!self.hookent) return;

	// Read override paramters from world FIRST, constants second
	dprint("\n\b  [-- Grapple Hook Statistics --]\b\n"); 
	dprint(    "-----------------------------------\n");
	dprint(  "\bT Description   Value   Def  Time\b\n");
	//          x xxxxxxxxxxxxx xxxxx xxxxx xx.xx
	//             Description   Value
	//-------------------------------------------------------------------------
	if (self.gh_hookstyle == GHC_HOOKSTYLE) dprint("D Move Style    ");
	else dprint("W Move Style    ");
	if (self.gh_hookstyle == GNC_HOOKLINE) dprint(" LINE");
	else if (self.gh_hookstyle == GNC_HOOKBOOST) dprint("BOOST");
	else if (self.gh_hookstyle == GNC_HOOKTRICK) dprint("TRICK");
	if (GHC_HOOKSTYLE == GNC_HOOKLINE) dprint("  LINE\n");
	else if (GHC_HOOKSTYLE == GNC_HOOKBOOST) dprint(" BOOST\n");
	else if (GHC_HOOKSTYLE == GNC_HOOKTRICK) dprint(" TRICK\n");

	// This is an important change, needs to be high up in table
	if (self.gh_funchookonly == TRUE) dprint("W Func GH Only    YES    --\n");	
	//-------------------------------------------------------------------------
	if (self.gh_hookearly == GHC_HOOKEARLY) dprint("D Early Pull    ");
	else dprint("W Early Pull    ");
	lftos(self, self.gh_hookearly, 5, 0, BUFFER_DPRINT); dprint(" "); 
	lftos(self, GHC_HOOKEARLY, 5, 0, BUFFER_DPRINT); dprint("\n");

	//-------------------------------------------------------------------------
	// Time (secs) limit = max distance (map units) / max speed (velocity)
	if (self.hookent.gh_maxdist == GHC_MAXDIST) dprint("D Max Distance  ");
	else dprint("W Max Distance  ");
	lftos(self, self.hookent.gh_maxdist, 5, 0, BUFFER_DPRINT); dprint(" "); 
	lftos(self, GHC_MAXDIST, 5, 0, BUFFER_DPRINT); dprint("\n");

	//-------------------------------------------------------------------------
	if (self.hookent.gh_hookspeed == GHC_HOOKSPEED) dprint("D Hook Speed    ");
	else dprint("W Hook Speed    ");
	lftos(self, self.hookent.gh_hookspeed, 5, 0, BUFFER_DPRINT); dprint(" "); 
	lftos(self, GHC_HOOKSPEED, 5, 0, BUFFER_DPRINT); dprint(" "); 

	self.hookent.gh_timetravel = self.hookent.gh_maxdist / self.hookent.gh_hookspeed;
	lftos(self, self.hookent.gh_timetravel, 2, 2, BUFFER_DPRINT); dprint("\n");

	if (self.hookent.gh_pullspeed == GHC_PULLSPEED) dprint("D Pull Speed    ");
	else dprint("W Pull Speed    ");
	lftos(self, self.hookent.gh_pullspeed, 5, 0, BUFFER_DPRINT); dprint(" "); 
	lftos(self, GHC_PULLSPEED, 5, 0, BUFFER_DPRINT); dprint("\n");

	//-------------------------------------------------------------------------
	if (self.hookent.gh_mindist == GHC_MINDIST) dprint("D Min Distance  ");
	else dprint("W Min Distance  ");
	lftos(self, self.hookent.gh_mindist, 5, 0, BUFFER_DPRINT); dprint(" "); 
	lftos(self, GHC_MINDIST, 5, 0, BUFFER_DPRINT); dprint("\n");

	// Minimum distance to stop drawing beam
	if (self.hookent.gh_minbeam == GHC_MINBEAM) dprint("D Min Beam      ");
	else dprint("W Min Beam      ");
	lftos(self, self.hookent.gh_minbeam, 5, 0, BUFFER_DPRINT); dprint(" "); 
	lftos(self, GHC_MINBEAM, 5, 0, BUFFER_DPRINT); dprint("\n");

	//-------------------------------------------------------------------------
	// Player/Monster/World entity damage
	if (self.hookent.gh_dmg_x == GHC_DMGPLAYER) dprint("D Player Dmg    ");
	else dprint("W Player Dmg    ");
	lftos(self, self.hookent.gh_dmg_x, 5, 0, BUFFER_DPRINT); dprint(" "); 
	lftos(self, GHC_DMGPLAYER, 5, 0, BUFFER_DPRINT); dprint("\n");
	
	if (self.hookent.gh_dmg_y == GHC_DMGMONSTER) dprint("D Monster Dmg   ");
	else dprint("W Monster Dmg   ");
	lftos(self, self.hookent.gh_dmg_y, 5, 0, BUFFER_DPRINT); dprint(" "); 
	lftos(self, GHC_DMGMONSTER, 5, 0, BUFFER_DPRINT); dprint("\n");
	
	if (self.hookent.gh_dmg_z == GHC_DMGWORLD) dprint("D World Dmg     ");
	else dprint("W World Dmg     ");
	lftos(self, self.hookent.gh_dmg_z, 5, 0, BUFFER_DPRINT); dprint(" "); 
	lftos(self, GHC_DMGWORLD, 5, 0, BUFFER_DPRINT); dprint("\n");

	//-------------------------------------------------------------------------
	dprint("- Func Hooks    "); trigtotal = func_ghook_count();
	lftos(self, trigtotal, 5, 0, BUFFER_DPRINT); dprint("     -\n"); 
	dprint("- Debug Markers ");
	lftos(self, self.gh_debugmove, 5, 0, BUFFER_DPRINT); dprint("     -\n"); 

	//-------------------------------------------------------------------------
	// Speed of movement on the chain (forward/right/up)
	if (self.hookent.gh_linechain == GHC_LINECHAIN) dprint("D Linear chain  ");
	else dprint("W Linear chain  ");
	dprint(vtos(self.hookent.gh_linechain));dprint("\n");
	
	// Speed of movement jumping off the chain (forward/right/up)
	if (self.hookent.gh_jumpchain == GHC_JUMPCHAIN) dprint("D Jump chain    ");
	else dprint("W Jump chain    ");
	dprint(vtos(self.hookent.gh_jumpchain)); dprint("\n");
	
	// Boost to movement during pulling of the chain (forward/right/up)
	if (self.hookent.gh_boostchain == GHC_BOOSTCHAIN) dprint("D Boost chain   ");
	else dprint("W Boost chain   ");
	dprint(vtos(self.hookent.gh_boostchain)); dprint("\n");
	
	// Knockback of hook against monsters
	if (self.hookent.gh_movemonster == GNC_MOVEMONS) dprint("D Move monster  ");
	else dprint("W Move monster  ");
	dprint(vtos(self.hookent.gh_movemonster)); dprint("\n");

	dprint("-----------------------------------\n");
};

//====================================================================
// Setup client hoot entity and world/constant defaults
//====================================================================
void() GrappleHook_Setup =
{
	self.hookent = spawn();
	// make sure connected back to owner
	self.hookent.owner = self;
	self.hookent.classname = "ghookproj";
	self.hookent.classtype = CT_GHOOKPROJ;
	self.hookent.mdl = MODEL_PROJ_GHOOK;
	// End point of beam on player
	self.hookent.meleeoffset = '0 0 8';

	//-------------------------------------------------------------------------
	if (world.gh_hookstyle == GNC_HOOKBOOST) self.gh_hookstyle = GNC_HOOKBOOST;
	else if (world.gh_hookstyle == GNC_HOOKTRICK) self.gh_hookstyle = GNC_HOOKTRICK;
	else self.gh_hookstyle = GHC_HOOKSTYLE;

	if (world.gh_hookearly > 0) self.gh_hookearly = world.gh_hookearly;
	else self.gh_hookearly = GHC_HOOKEARLY;
	// Check for range errors
	if (self.gh_hookearly < 0) self.gh_hookearly = 0;
	else if (self.gh_hookearly > GHC_MAXSPEED) self.gh_hookearly = GHC_MAXSPEED;

	if (world.gh_funchookonly > 0) self.gh_funchookonly = TRUE;
	else self.gh_funchookonly = FALSE;
	
	//-------------------------------------------------------------------------
	if (world.gh_maxdist > 0) self.hookent.gh_maxdist = world.gh_maxdist;
	else self.hookent.gh_maxdist = GHC_MAXDIST;

	if (world.gh_hookspeed > 0) self.hookent.gh_hookspeed = world.gh_hookspeed;
	else self.hookent.gh_hookspeed = GHC_HOOKSPEED;
	// Check for range errors
	if (self.hookent.gh_hookspeed < 0) self.hookent.gh_hookspeed = 0;
	else if (self.hookent.gh_hookspeed > GHC_MAXSPEED) self.hookent.gh_hookspeed = GHC_MAXSPEED;

	// Time (secs) limit = max distance (map units) / max speed (velocity)
	self.hookent.gh_timetravel = self.hookent.gh_maxdist / self.hookent.gh_hookspeed;

	//-------------------------------------------------------------------------
	if (world.gh_pullspeed > 0) self.hookent.gh_pullspeed = world.gh_pullspeed;
	else self.hookent.gh_pullspeed = GHC_PULLSPEED;
	// Check for range errors
	if (self.hookent.gh_pullspeed < 0) self.hookent.gh_pullspeed = 0;
	else if (self.hookent.gh_pullspeed > GHC_MAXSPEED) self.hookent.gh_pullspeed = GHC_MAXSPEED;

	//-------------------------------------------------------------------------
	if (world.gh_mindist > 0) self.hookent.gh_mindist = world.gh_mindist;
	else self.hookent.gh_mindist = GHC_MINDIST;
	// Check for range errors
	if (self.hookent.gh_mindist > self.hookent.gh_pullspeed) 
		self.hookent.gh_mindist = self.hookent.gh_pullspeed;

	// Minimum distance to stop drawing beam
	if (world.gh_minbeam > 0) self.hookent.gh_minbeam = world.gh_minbeam;
	else self.hookent.gh_minbeam = GHC_MINBEAM;
	// Check for range errors
	if (self.hookent.gh_minbeam < 20) self.hookent.gh_minbeam = 20;

	//-------------------------------------------------------------------------
	// Player/Monster/World entity damage
	if (world.gh_dmg_x > 0) self.hookent.gh_dmg_x = world.gh_dmg_x;
	else self.hookent.gh_dmg_x = GHC_DMGPLAYER;
	if (self.hookent.gh_dmg_x < 0) self.hookent.gh_dmg_x = 0;

	if (world.gh_dmg_y > 0) self.hookent.gh_dmg_y = world.gh_dmg_y;
	else self.hookent.gh_dmg_y = GHC_DMGMONSTER;
	if (self.hookent.gh_dmg_y < 0) self.hookent.gh_dmg_y = 0;
	
	if (world.gh_dmg_z > 0) self.hookent.gh_dmg_z = world.gh_dmg_z;
	else self.hookent.gh_dmg_z = GHC_DMGWORLD;
	if (self.hookent.gh_dmg_z < 0) self.hookent.gh_dmg_z = 0;

	//-------------------------------------------------------------------------
	if (world.gh_debugmove > 0) self.gh_debugmove = world.gh_debugmove;
	else if (world.gh_debugmove < 0) self.gh_debugmove = GHC_DEBUGMARKS;
	else self.gh_debugmove = 0;		// Default = OFF
	// Check for range errors
	if (self.gh_debugmove > GHC_DEBUGMARKS) self.gh_debugmove = GHC_DEBUGMARKS;
	
	//-------------------------------------------------------------------------
	// Speed of movement on the chain (forward/right/up)
	if (!CheckZeroVector(world.hookent.gh_linechain)) 
		self.hookent.gh_linechain = world.hookent.gh_linechain;
	else self.hookent.gh_linechain = GHC_LINECHAIN;
	
	// Speed of movement jumping off the chain (forward/right/up)
	if (!CheckZeroVector(world.hookent.gh_jumpchain)) 
		self.hookent.gh_jumpchain = world.hookent.gh_jumpchain;
	else self.hookent.gh_jumpchain = GHC_JUMPCHAIN;
	
	// Boost to movement during pulling of the chain (forward/right/up)
	if (!CheckZeroVector(world.hookent.gh_boostchain)) 
		self.hookent.gh_boostchain = world.hookent.gh_boostchain;
	else self.hookent.gh_boostchain = GHC_BOOSTCHAIN;
	
	// Knockback of hook against monsters
	if (!CheckZeroVector(world.hookent.gh_movemonster)) 
		self.hookent.gh_movemonster = world.hookent.gh_movemonster;
	else self.hookent.gh_movemonster = GNC_MOVEMONS;
};

//====================================================================
// Maintain/Update Hook when attached to something
//====================================================================
void() GrappleHook_Thinking = 
{
	// Attached surface has been disabled or switched off?
	if (self.enemy != world && self.enemy.estate & ESTATE_BLOCK) {
		GrappleHook_Reset(self); return; }
	
	// Atached to something that can moving?
	if (self.enemy.solid == SOLID_SLIDEBOX) {
		self.velocity = '0 0 0';
		setorigin(self, self.enemy.origin + self.enemy.mins +
			self.enemy.size * 0.5);
	}
	// Match the velocity of the moving object
	else self.velocity = self.enemy.velocity;

	// Think faster to keep up with moving entities
	self.think = GrappleHook_Thinking;
	self.nextthink = time + 0.05;
};

//====================================================================
// (SELF = HOOKENT) Surface tests for Hook touching
//====================================================================
void() GrappleHook_Touch =
{
	local vector pushmonster;
	
	if (check_skycontent(self.origin)) { GrappleHook_Reset(self); return; }
	if (other == self.owner) return;			// Touching self, do nothing
	if (other.solid == SOLID_TRIGGER) return;	// trigger field, do nothing
	// Attach to something valid, stop touching
	if (self.attack_finished > time) return;
	
	// Stop touching me, I have touched something!
	self.attack_finished = time + LARGE_TIMER;
	self.touch = SUB_Null;
	// no world interaction
	self.solid = SOLID_NOT;
	// Stop grapple hook moving anymore
	self.velocity = self.avelocity = '0 0 0';

	// Hit anything that bleeds?
	//----------------------------------------------------------------
	if (other.classtype == CT_PLAYER) {
		// Block grapple hook from firing again
		self.owner.gh_blockhook = time + GHC_TIMEOUT;
		
		// Coop exceptions to damage
		if (coop == FALSE) {
			// sound of axe hitting flesh (player)
			sound (self.owner, CHAN_WEAPON, SOUND_AXE_FLESH, 1, ATTN_NORM);
			// Unique damage from grapple hook to PLAYER
			T_Damage (other, self, self.owner, self.gh_dmg_x, DAMARMOR);
			spawn_touchblood (self, other, self.gh_dmg_x);
		}
		// No attachment to players
		GrappleHook_Reset(self); return;
	}
	//----------------------------------------------------------------
	else if (other.flags & FL_MONSTER) {
		// Block grapple hook from firing again
		self.owner.gh_blockhook = time + GHC_TIMEOUT;

		// Ignore BOSS or dead enemies or things immune to damage
		if (other.bossflag == TRUE || other.health < 1 || !other.takedamage) { 
			GrappleHook_Reset(self); return;
		}
		
		// Spawn some particle effects on impact
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);

		// Monster made of Stone?
		if (other.classgroup == CG_STONE) {
			// sound of axe hitting stone
			sound (self, CHAN_WEAPON, SOUND_AXE_STONE, 1, ATTN_NORM);
			// Stone too heavy to do damage or move
			GrappleHook_Reset(self); return;
		}
		
		// sound of axe hitting flesh (monster)
		sound (self, CHAN_WEAPON, SOUND_AXE_FLESH, 1, ATTN_NORM);
		// Unique damage from grapple hook to MONSTERS
		T_Damage (other, self, self.owner, self.gh_dmg_y, DAMARMOR);
		spawn_touchblood (self, other, self.gh_dmg_x*2);
		
		// Check if monster can be moved?
		if (other.attack_state == AS_TURRET || other.movespeed < 0
			|| other.tetherlock == TRUE) {
			GrappleHook_Reset(self); return;
		}

		// Can only MOVE monsters that walk on the ground
		if (other.classmove == MON_MOVEWALK) {
			// Create facing angles of grapple hook
			makevectors(self.angles);
			// Debug arrow to show impact direction
			//spawn_arrow(self.origin, self.angles,0);
			
			// MOVE monster based on grapple facing angle (+randomness)
			pushmonster = self.gh_movemonster * (1 + (random()*0.2));
			other.velocity = attack_vector(pushmonster);
			// Need to remove ground flag, otherwise no velocity movement
			other.flags = other.flags - (other.flags & FL_ONGROUND);
		}
		// No attachment to monsters
		GrappleHook_Reset(self); return;	
	}
	//----------------------------------------------------------------
	// WORLD or FUNC bmodels (majority of impacts)
	//----------------------------------------------------------------
	else {
		// sound of axe hitting stone
		sound (self, CHAN_WEAPON, SOUND_AXE_STONE, 1, ATTN_NORM);
		// Can impact surface be damaged?
		if (other.takedamage) {
			// func bmodels (doors/breakables etc)
			T_Damage (other, self, self.owner, self.gh_dmg_z, DAMARMOR);
		}
		// Spawn some particle effects on impact
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}
	
	//----------------------------------------------------------------
	// Time for owner (client) to start flying
	self.owner.gh_onhook = TRUE;
	self.owner.flags = self.owner.flags - (self.owner.flags & FL_ONGROUND);
	
	// Keep track of start/finish locations of chain
	// Used to work out Boost % for movement arc
	self.dest1 = self.owner.origin;
	self.dest2 = self.origin;
	
	// Remember attachment (for movement tracking)
	self.enemy = other;
	// switch grapple to anchored position
	self.frame = GH_PROJCLOSED;
	// Keep tracking the attachment (velocity/position)
	self.think = GrappleHook_Thinking;
	self.nextthink = time + 0.05;
};

//====================================================================
// (SELF = CLIENT) Generate hook entity and setup default parameters
//====================================================================
void() W_FireGrapple = 
{
	local vector org, dest, dir, dirangles;
	local float dist;
	
	// Double check client only and alive!
	if (!(self.flags & FL_CLIENT)) return;
	if (self.health < 1) return;
	if (self.gh_hookout == TRUE) return;
	if (self.gh_blockhook > time) return;
	
	// Does the hook entity exist? (should be a once only thing)
	if (!self.hookent) { 
		// Create hook entity and show stats
		GrappleHook_Setup();
		GrappleHook_Display();
		// Create debug diamond chain
		GrappleHook_DebugCreate();
	}
	
	//----------------------------------------------------------------
	// Double check final destination is something solid
	// Use facing camera direction of client as trace vector
	makevectors(self.v_angle);
	org = self.origin + attack_vector(self.hookent.meleeoffset);
	// Use maximum travel distance + a little extra over limit
	dest = org + (v_forward * (self.hookent.gh_maxdist+128));
	// Switch ON bounding boxes of ALL func grapple points in the map!?!
	// * func_grapplehook should work infront of sky brushes
	// * Switching on/off bbox is probably going to have some weird affect
	//   during combat or when there are tons of entities around. :(
	// * Ideally the traceline should find trigger brushes, but it does not!
	//   Traceline really works with bounding boxes and they cannot be on
	//   all the time because they would block everything.
	// * The perfect solution would be triggers because they are ignored
	//   by so many systems, but they are reactive and use touch systems.
	// * The grapple points need to work instantly so that the destination
	//   point can be adjusted before firing the grapple.
	func_ghook_bbox(TRUE);	
	// Trace can be blocked by any bbox entity (nomonsters=FALSE)
	traceline(org, dest, FALSE, self);
	// Switch OFF bounding box of ALL func grapple points
	// only needed them enabled for the traceline function
	func_ghook_bbox(FALSE);
	
	// Work out distance of traceline (first entity contact)
	dist = vlen(trace_endpos - org);
	// Hit any sky textures OR gone beyond maximum distance?
	if (check_skycontent(trace_endpos) || dist > self.hookent.gh_maxdist) {
		// Misfire of weapon and return
		GrappleHook_MisFire();
		return;
	}

	//----------------------------------------------------------------
	// Check for any func grapple hooks (were switched on for collision)
	// Will setup correct (dest) destination for next trace function
	if (trace_ent.classtype == CT_FUNCHOOK) {
		// Is the func ghook blocking?
		if (trace_ent.spawnflags & FUNC_GHOOKBLOCK) {
			// Spawn impact particles on surface back towards client
			func_ghook_impact(trace_endpos, -v_forward, 1);
			// Check for any BLOCKED sound/message
			func_ghook_trigger(trace_ent, self, GH_FUNCBLOCK);
			// Misfire of weapon and return
			GrappleHook_MisFire();
			return;
		}

		// Check for any USED sound/message
		func_ghook_trigger(trace_ent, self, GH_FUNCUSED);
		// Using a grapple hook point
		self.gh_funchook = TRUE;
		// Override origin (setup by func_grapplehook)
		dest = trace_ent.oldorigin;
		dirangles = vectoangles(dest - self.origin);
		// vectoangles has reversed X axis, correct it
		dirangles_x = -dirangles_x;
		makevectors(dirangles);
		// Finally worked out new direction to fire grapple
		dir = v_forward * self.hookent.gh_hookspeed;
	}
	else {
		if (self.gh_funchookonly == TRUE) {
			// Spawn impact particles on surface back towards client
			func_ghook_impact(trace_endpos, -v_forward, 1);
			// Check for any BLOCKED sound/message
			func_ghook_trigger(trace_ent, self, GH_FUNCBLOCK);
			// Misfire of weapon and return
			GrappleHook_MisFire();
			return;
		}
		
		// Default = fire in camera facing direction of client
		self.gh_funchook = FALSE;
		makevectors(self.v_angle);
		dest = org + (v_forward * self.hookent.gh_maxdist);
		dir = v_forward * self.hookent.gh_hookspeed;
		dirangles = vectoangles(v_forward);
	}
		
	//----------------------------------------------------------------
	// dest1 and dest2 are used to work out inverse percentages of
	// distance travelled along grapple hook final path.
	// Will be properly updated once the grapple hook hits something!
	// Don't be blocked by anything (nomonsters=TRUE)
	traceline(org, dest, TRUE, self);
	self.hookent.dest1 = self.origin;
	self.hookent.dest2 = trace_endpos;

	//----------------------------------------------------------------
	// Grapple hit any monsters? Don't pull towards them
	if (trace_ent.flags & FL_MONSTER) self.gh_hookearly = FALSE;
	
	//----------------------------------------------------------------
	// Setup client defaults
	self.gh_hookout = TRUE;				// Grapple is firing
	self.gh_onhook = FALSE;				// Still firing forward
	self.gh_pullchain = TRUE;			// Pull on client system
	self.hookent.pain_finished = -1;	// First marker active
	
	// Player vmodel kickback
	self.punchangle_x = -2;
	// Fire sound of weapon (grapple hook) with variable volume
	self.hookent.volume = 0.5 + (random() * 0.5);
	sound (self, CHAN_WEAPON, SOUND_GHOOKFIRE, self.hookent.volume, ATTN_NORM);
	
	// Small impact against monsters. This type of movetype makes it very
	// hard to hit monsters with the grapple hook.
	//self.hookent.movetype = MOVETYPE_FLY;
	
	// Large projectile impact against monsters (easier to hit)
	self.hookent.movetype = MOVETYPE_FLYMISSILE;
	self.hookent.solid = SOLID_BBOX;
	// Restore model/bbox
	setmodel(self.hookent, self.hookent.mdl);
	setsize (self.hookent, VEC_ORIGIN, VEC_ORIGIN);
	self.hookent.frame = GH_PROJFLYING;
	
	// Move the hook into initial position
	// velocity/angles defined earlier with sky test
	setorigin(self.hookent, org);
	self.hookent.velocity = dir;
	self.hookent.angles = dirangles;
	self.hookent.flags = 0;
	
	// Setup touch functionality (impact)
	self.hookent.touch = GrappleHook_Touch;
	// Limit grapple hook range by time travelled
	self.hookent.nextthink = time + self.hookent.gh_timetravel;
	self.hookent.think = GrappleHook_ResetNoParm;
};

//====================================================================
// (SELF = CLIENT) Constantly run from client.qc (PlayerPreThink)
// Most conditions run through this function because its run so
// fast/often and will be the most responsive
//====================================================================
void() GrappleHook_Client = 
{
	local vector playervec, chainvec, chainnorm, newvel;
	local vector boostforvec, boostupvec, boostsidevec;
	local float chainlen, boostlen, fixedlen, boostperc, rightang;
	local float f1, f2;
	
	// Have grapple hook?
	if (!(self.moditems & IT_UPGRADE_GHOOK)) return;
	// No hook has been setup yet?
	if (self.hookent.classtype != CT_GHOOKPROJ) return;
	// Dead? Hook should be defined at this point
	if (self.health < 1) { GrappleHook_Reset(self.hookent); return;}
	// Switching away from grapple hook resets hook
	if (self.weapon != IT_AXE) { GrappleHook_Reset(self.hookent); return; }

	// Always calculate distance
	GrappleHook_Distance();

	// Draw debug markers showing movement style
	if(self.gh_debugmove > 0 && self.hookent.pain_finished < time) {
		// Is hook active OR after release/jump markers active?
		if (self.gh_hookout == TRUE || self.gh_debugafter > 0) {
			// pain_finished needs to be tested here because of -1 reset
			// Display the different marker colours (start/main/finish)
			if (self.hookent.pain_finished < 0) GrappleHook_DebugUpdate(GHC_DEBUGSTART);
			else if (self.gh_debugafter > 0) GrappleHook_DebugUpdate(GHC_DEBUGLETGO);
			else if (self.gh_hookdist <= self.hookent.gh_mindist) GrappleHook_DebugUpdate(GHC_DEBUGCLOSE);
			else GrappleHook_DebugUpdate(GHC_DEBUGCHAIN);
			// Slow down updates (this function is PlayerPreThink timing)
			self.hookent.pain_finished = time + GHC_DEBUGTIMER;
			// Count down the after release markers
			if (self.gh_debugafter > 0) self.gh_debugafter = self.gh_debugafter - 1;
		}
	}

	//----------------------------------------------------------------
	// Jump off grapple hook while attached
	if ( (self.gh_onhook == TRUE && self.button2) ||
		 (self.gh_onhook == FALSE && self.gh_hookearly > 0 && self.button2) ) {
		makevectors(self.angles);
		self.velocity = self.velocity + attack_vector(self.hookent.gh_jumpchain);
		// Clear button as jump is happening
		self.button2 = 0;
		// Make sure jump sound happens (can repeat)
		sound (self, CHAN_BODY, SOUND_PLAYER_JUMP, 1, ATTN_NORM);
		// Block grapple hook for a small time
		self.gh_blockhook = time + GHC_TIMEOUT;
		// Make sure jumpboot cycle is reset correctly
		if (self.moditems & IT_ARTJUMPBOOTS) self.jumpboots_onground = TRUE;
		GrappleHook_Reset(self.hookent); return;
	}
	
	// Beyond here requires hook to be out!
	if (self.gh_hookout == FALSE) return; 
	
	//----------------------------------------------------------------
	// Grapple hook still travelling? Client is not on chain at this point
	if ( (self.gh_onhook == FALSE && self.gh_hookearly == FALSE) ||
		 (self.gh_onhook == FALSE && self.gh_hookearly > 0 && self.gh_hookdist < self.gh_hookearly) ) {
		// Draw beam (models) to the hook
		GrappleHook_Beam(self.hookent, self);
		return;
	}
	
	//----------------------------------------------------------------
	// Hook is attached to something and client pulling?
	if (self.gh_onhook == TRUE) {
		// Trick mode stops pulling once left button released
		if (!self.button0 && self.gh_hookstyle == GNC_HOOKTRICK) {
			// Trick version not setup correctly yet
			GrappleHook_Reset(self.hookent);
			return;
			//self.gh_pullchain = FALSE;
			//self.gh_hookfixed = self.gh_hookdist;
		}
		// Drop the hook if the player has lets go of the FIRE button
		// OR used a teleporter OR just jumped out of water
		else if (!self.button0 || self.teleport_time > time) {
			GrappleHook_Reset(self.hookent);
			return;
		}
	}

	//----------------------------------------------------------------
	// Pull client towards HOOK point
	//----------------------------------------------------------------
	if (self.gh_pullchain == TRUE) {
		//----------------------------------------------------------------
		// LINE mode active?
		if (self.gh_hookstyle == GNC_HOOKLINE) {
			// Setup directional vectors
			makevectors(self.v_angle);
			// Player origin + small up/forward LINEAR adjustment
			playervec = self.origin + attack_vector(self.hookent.gh_linechain);
			// Create straight line vector from player(+boost) to hook
			chainvec = self.hookent.origin - playervec;
			// Find out vector length
			chainlen = vlen(chainvec);
			// Normalize for speed multiplier
			chainnorm = normalize(chainvec);

			// Too close to hook?
			if (chainlen <= self.hookent.gh_mindist) {
				// If using a func_grapplehook let client swing around
				if (self.gh_funchook == TRUE) newvel = self.velocity;
				// DEFAULT = slow down client velocity
				else newvel = chainnorm * (chainlen * (self.hookent.gh_mindist*0.1));
			}
			// DEFAULT = full LINEAR speed
			else newvel = chainnorm * self.hookent.gh_pullspeed;

			// Update player velocity/speed
			self.velocity = newvel;
		}
		//----------------------------------------------------------------
		// BOOST mode active?
		else if (self.gh_hookstyle == GNC_HOOKBOOST) {
			// Find out how far through the path the client is
			// Total length, cient progress and % through boost
			chainlen = vlen(self.hookent.dest1 - self.hookent.dest2);
			boostlen = vlen(self.hookent.dest1 - self.origin);
			chainnorm = normalize(self.hookent.origin - self.origin);
			boostperc = boostlen / chainlen;
			
			// Use model angles instead of camera (v_angle) angles!
			// If the camera is looking up it will be included into the
			// directional vector, model angles always faces forward.
			// ** Need to detect if player is looking up/down
			makevectors(self.angles);
			// Calc forward/up movement adjustment using vector length %
			// Vector adjustment is Forward : 1>-0 and UP : 0->1
			// This pushes the player forward at first and then eventually
			// boosts the player upward closer to the hook
			boostforvec = v_forward * ( (1-boostperc) * self.hookent.gh_boostchain_x);
			boostupvec = v_up * (boostperc * self.hookent.gh_boostchain_z);
			// If the player is looking down, then reverse the UP boost
			if (self.v_angle_x > 0) boostupvec = -boostupvec;
			// Create velocity boast (looking forward only)
			newvel = chainnorm * self.hookent.gh_pullspeed;

			// Find out which way the player is facing
			rightang = targangle(self, self.hookent, 180, FALSE);
			// 20 degree turn left or right?
			if (rightang < (180-GHC_SIDEANGLE) || rightang > (180+GHC_SIDEANGLE) ) {
				boostsidevec = v_right * ((1-boostperc) * self.hookent.gh_boostchain_y);
				// 0-180 =right side, 180-360 = left side
				if (rightang > 180) boostsidevec = -boostsidevec;	// reversed
				// slow down forward momentum (* 0.5 - 1.0)
				newvel = chainnorm * (self.hookent.gh_pullspeed * (0.25 + (boostperc*0.75)));
			}
			// No sideway movement
			else boostsidevec = '0 0 0';

			// Too close to hook?
			if (self.gh_hookdist <= self.hookent.gh_mindist) {
				// If using a func_grapplehook let client swing around
				if (self.gh_funchook == TRUE) newvel = self.velocity;
				// DEFAULT = slow down client velocity
				else newvel = newvel + boostupvec*0.5;
			}
			// DEFAULT = extra forward/up boost
			else newvel = newvel + boostforvec + boostupvec + boostsidevec;

			// Update player velocity/speed
			self.velocity = newvel;
		}
		//----------------------------------------------------------------
		// TRICK mode active?
		else if (self.gh_hookstyle == GNC_HOOKTRICK) {
			chainvec = self.hookent.origin - self.origin;
			chainlen = vlen(chainvec);
			chainnorm = normalize(chainvec);
			fixedlen = chainlen;
			
			// if player's location is beyond the chain's reach
			if (chainlen == fixedlen) {		
				// determine player's velocity component of chain vector
				playervec = chainvec * ((self.velocity * chainvec) / (chainvec * chainvec));
				// restrainment default force 
				f2 = (chainlen - fixedlen) * 5;
				// if player's velocity heading is away from the hook
				if ((self.velocity * chainvec) < 0) {
					// if chain has streched for 25 units
					if (chainlen > fixedlen + 25) {
						// remove player's velocity component moving away from hook
						self.velocity = self.velocity - playervec; 
					}
					f1 = f2;
				}
				else { // if player's velocity heading is towards the hook
					if (vlen(playervec) < f2) f1 = f2 - vlen(playervec);
					else f1 = 0;
				}
			}
			else f1 = 0;

			// No distance changes
			self.velocity = self.velocity + normalize(chainvec) * f1;
		}
	}
	
	//----------------------------------------------------------------
	// Draw beam (models) to the hook
	if (self.gh_hookdist > self.hookent.gh_minbeam)
		GrappleHook_Beam(self.hookent, self);
};

//======================================================================
/*QUAKED func_grapplehook (0.5 0 0.5) ? x BLOCK SOLID x DISPLAY ALPHA STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
Variable sized bmodel that interacts with grapple gun
------- KEYS --------
targetname  : trigger entity (works with entity state system)
target      : target(s) to fire when grapple hook touches
target2     : override bmodel origin for hook point
alpha       : alpha value will vary +/- 20% (def=0.5, req=alpha spnflag)
sounds      : 1=Secret,2=talk,3=switch,4=silent,5=custom,6=secret2
noise       : custom sound to play when USED by grapple hook
message     : message to display when USED by grapple hook
dmg         : damage done when TOUCHED every 0.1s (def=0, add=solid spnflag)
noise1      : custom sound to play when TOUCHED for damaged
waitmin     : >0 = custom TOUCH sound repeat delay (def=1)
noise2      : custom sound to play when BLOCKED by grapple hook
message2    : message to display when BLOCKED by grapple hook
wait        : -1 = sound / msg once, >0 = sound / msg repeat delay (def=1)
_dirt       : -1 = will be excluded from dirtmapping
_minlight   : Minimum light level for any surface of the brush model
_mincolor   : Minimum light color for any surface (def='1 1 1' RGB)
_shadow     : Will cast shadows on other models and itself
_shadowself : Will cast shadows on itself
-------- SPAWNFLAGS --------
BLOCK    : Blocks grapple hook from starting to pull player
SOLID    : Blocks player/projectiles (like a func_wall)
DISPLAY  : Show bmodel surface when active
ALPHA    : bmodel surface is alpha flickering
STARTOFF : Requires trigger to activate
------- NOTES --------
Variable sized bmodel that interacts with grapple gun

======================================================================*/
void(vector org, vector dir, float part_qty) func_ghook_impact =
{
	local float loop_count, part_col;
	loop_count = 0; part_col = 4;
	// Loop through particle count creating bursts of particles
	while(loop_count < 4) {
		particle (org, dir, part_col + rint(random()*7), part_qty);
		loop_count = loop_count + 1;
	}	
};

//----------------------------------------------------------------------
float() func_ghook_count = 
{
	local float hookcount;
	local entity funcent;
	hookcount = 0;
	// Search for any func grapple hook magnets
	funcent = find(world, gh_searchstr, GHC_SEARCHSTR);
	// Found any?
	while (funcent) {
		// Make sure its the right entity type
		if (funcent.classtype == CT_FUNCHOOK)
			hookcount = hookcount + 1;
		// Keep searching through smaller list
		funcent = find(funcent, gh_searchstr, GHC_SEARCHSTR);
	}
	return hookcount;
};

//----------------------------------------------------------------------
void(float switchbbox) func_ghook_bbox =
{
	local entity funcent;
	// Search for any func grapple hook magnets
	funcent = find(world, gh_searchstr, GHC_SEARCHSTR);
	// Found any?
	while (funcent) {
		// Make sure its the right entity type
		if (funcent.classtype == CT_FUNCHOOK) {
			// Is the entity enabled?
			if (funcent.estate & ESTATE_ON) {
				// Is the func entity solid already?
				if (!(funcent.spawnflags & FUNC_GHOOKSOLID)) {
					// Switch on or off the bbox
					if (switchbbox) {
						funcent.solid = SOLID_BBOX;
						setsize (funcent, funcent.bbmins, funcent.bbmaxs);
					}
					else {
						funcent.solid = SOLID_NOT;
						if (!(funcent.spawnflags & FUNC_GHOOKDISPLAY))
							setsize (funcent, VEC_ORIGIN, VEC_ORIGIN);
					}
				}
			}
		}
		// Keep searching through smaller list
		funcent = find(funcent, gh_searchstr, GHC_SEARCHSTR);
	}
};

//----------------------------------------------------------------------
void(entity targ, entity cltarg, float trigtype) func_ghook_trigger =
{
	// Double check target entity type
	if (targ.classtype != CT_FUNCHOOK) return;
	// Check for wait/delay timer on sound/msg
	if (targ.attack_finished > time) return;
	// messages need a client
	if (!(cltarg.flags & FL_CLIENT)) return;
	
	// USE condition?
	if (trigtype == GH_FUNCUSED) {
		if (targ.noise != "" && targ.sound_emitter)
			sound(targ.sound_emitter, CHAN_VOICE, targ.noise, targ.volume, ATTN_NORM);
		if (targ.message != "") centerprint(cltarg, targ.message);
	}
	// BLOCKED condition?
	else if (trigtype == GH_FUNCBLOCK) {
		if (targ.noise2 != "" && targ.sound_emitter)
			sound(targ.sound_emitter, CHAN_VOICE, targ.noise2, targ.volume, ATTN_NORM);
		if (targ.message2 != "") centerprint(cltarg, targ.message2);
	}
	// No condition found
	else return;
	
	// Check for any repeat functionality (single timer)
	if (targ.wait < 0) targ.attack_finished = LARGE_TIMER;
	else targ.attack_finished = time + targ.wait;
};

//----------------------------------------------------------------------
void() func_ghook_touch =
{
	if (self.estate & ESTATE_BLOCK) return;
	if (other.takedamage == DAMAGE_NO) return;
	if (self.pain_finished < time) {
		// Play sound, do damage and setup timers!
		if (self.noise1 != "" && self.invincible_finished < time && self.sound_emitter) {
			sound(self.sound_emitter, CHAN_VOICE, self.noise1, self.volume, ATTN_NORM);
			self.invincible_finished = time + self.waitmin;
		}
		T_Damage (other, self, self, self.dmg, DAMARMOR);
		self.pain_finished = time + 0.1;
	}
};

//----------------------------------------------------------------------
void() func_ghook_think =
{
	if (self.estate == ESTATE_BLOCK) return;
	// Change the density of the alpha to make bmodel surface flicker
	self.alpha = self.height*0.8 + (self.alpha * (random()*0.4));
	// Solid type SOLID_BSP has to use local timer (ltime)
	if (self.spawnflags & FUNC_GHOOKSOLID) self.nextthink = self.ltime + 0.05;
	else self.nextthink = time + 0.05;
};

//----------------------------------------------------------------------
void() func_ghook_setup = 
{
	// Check for spawning conditions (nightmare, coop)
	// Needs to exist after entity has been added to work for BSPorigin
	if (check_nightmare() == TRUE) return;
	if (check_coop() == TRUE) return;

	// Find any targets
	if (self.target2 != "") 
		self.movetarget = find(world, targetname, self.target2);
	// Use self if could not find any target
	if (!self.movetarget) self.movetarget = self;
	// Ignore (self) func hook entity, already know origin
	if (self.movetarget.classtype != CT_FUNCHOOK) {
		// Find origin (check for bmodel/mdl entity)
		if (self.movetarget.bsporigin)
			self.oldorigin = bmodel_origin(self.movetarget);
		else self.oldorigin = self.movetarget.origin;
	}
	// bmodel surface is alpha flickering
	if (self.spawnflags & FUNC_GHOOKALPHA) {
		self.think = func_ghook_think;
		self.nextthink = time + 0.1;
	}
}

//----------------------------------------------------------------------
void() func_ghook_on =
{
	// No longer need this spawnflag, remove it
	self.spawnflags = self.spawnflags - (self.spawnflags & ENT_STARTOFF);
	// Switch ON
	self.estate = ESTATE_ON;
	
	// Is the bmodel solid? - reqs unique move/solid type
	// push/bsp lets the player stand on it without sliding
	if (self.spawnflags & FUNC_GHOOKSOLID) {
		self.movetype = MOVETYPE_PUSH;
		self.solid = SOLID_BSP;
	}
	else {
		// DEFAULT = not solid to anything but grapple
		self.movetype = MOVETYPE_NONE;
		self.solid = SOLID_NOT;
	}
	// Is the bmodel visable? Show model etc
	if (self.spawnflags & FUNC_GHOOKDISPLAY) {
		// Show bmodel
		setmodel (self, self.mdl);
		// Define bounding box for solid
		if (self.spawnflags & FUNC_GHOOKSOLID) 
			setsize (self, self.bbmins, self.bbmaxs);
		
		// Alpha flickering automatically adds display
		// Can't have alpha without display!
		if (self.spawnflags & FUNC_GHOOKALPHA) {
			self.think = func_ghook_think;
			self.nextthink = time + 0.1;
			// setup local time for solid types
			self.ltime = time;
		}
	}
};

//----------------------------------------------------------------------
void() func_ghook_off =
{
	// Switch OFF
	self.estate = ESTATE_OFF;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, "");
};

//----------------------------------------------------------------------
void() func_grapplehook =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors

	self.classtype = CT_FUNCHOOK;
	self.gh_searchstr = GHC_SEARCHSTR;
	self.bsporigin = TRUE;		// bmodel origin 0,0,0

	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	self.mdl = self.model;		// Save model for later
	setmodel (self, self.mdl);	// set size and link into world
	self.bbmins = self.mins;	// Save bmodel bounds for later
	self.bbmaxs = self.maxs;
	self.modelindex = 0;
	self.model = "";			// hide bmodel surface

	// Find out the bmodel origin
	setsize (self, self.bbmins, self.bbmaxs);
	self.oldorigin = bmodel_origin(self);

	self.takedamage = DAMAGE_NO;
	if (self.wait == 0) self.wait = 1;
	if (self.waitmin <= 0) self.waitmin = 1;
	
	// Precache sounds/noise setup
	trigger_bmodel_sounds();
	trigger_bmodel_volume(1);
	// Double check ALL sounds need caching (Use/Touch/Block)
	if (self.noise != "") precache_sound(self.noise);
	if (self.noise1 != "") precache_sound(self.noise1);
	if (self.noise2 != "") precache_sound(self.noise2);
	
	if (self.noise != "" || self.noise1 != "" || self.noise2 != "") {
		// Setup sound emitter where bmodel is correctly located
		self.sound_emitter = spawn();
		setorigin(self.sound_emitter, self.oldorigin);
		self.sound_emitter.classtype = CT_SOUNDEMITTER;
	}

	// bmodel surface is alpha flickering
	if (self.spawnflags & FUNC_GHOOKALPHA) {
		if (!self.alpha) self.alpha = 0.5;	// Default transparent
		self.height = self.alpha;			// Used for think function
		// The surface has to be visible for alpha to work
		self.spawnflags = self.spawnflags | FUNC_GHOOKDISPLAY;
	}
	if (self.dmg > 0) {
		self.touch = func_ghook_touch;
		// The surface has to be solid for touch to work
		self.spawnflags = self.spawnflags | FUNC_GHOOKSOLID;
	}

	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_on = func_ghook_on;
	self.estate_off = func_ghook_off;

	if (self.spawnflags & ENT_STARTOFF) entity_state_off();
	else entity_state_on();	

	// Setup any targets
	self.think = func_ghook_setup;
	self.nextthink = time + 0.2 + (random()*0.3);
};

