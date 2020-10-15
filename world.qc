//======================================================================
// GLOBAL STUFF
//======================================================================
entity	lastspawn;					// client.qc (SelectSpawnPoint)

void() InitBodyQue;
void() light_style_boundary;
void() light_style_setuparray;
void() pendulum_setuparray;
void() mapvar_setuparray;
void() player_fallspeed_reset;
void() player_fallspeed_setup;
void() Client_SyncEvilmode;

//----------------------------------------------------------------------
void() main =
{
	dprint ("\b[MAIN]\b function started ...\n");
	
	//----------------------------------------------------------------------
	// these are just commands for the prog compiler to copy these files
	//----------------------------------------------------------------------
	precache_file ("progs.dat");
	precache_file ("gfx.wad");
	precache_file ("quake.rc");
	precache_file ("default.cfg");

	precache_file ("end1.bin");
	precache_file2 ("end2.bin");

	//precache_file ("demo1.dem");
	//precache_file ("demo2.dem");
	//precache_file ("demo3.dem");

	//----------------------------------------------------------------------
	// these are all of the lumps from the cached.ls files
	//----------------------------------------------------------------------
	precache_file ("gfx/palette.lmp");
	precache_file ("gfx/colormap.lmp");

	precache_file2 ("gfx/pop.lmp");

	precache_file ("gfx/complete.lmp");
	precache_file ("gfx/inter.lmp");

	precache_file ("gfx/ranking.lmp");
	precache_file ("gfx/vidmodes.lmp");
	precache_file ("gfx/finale.lmp");
	precache_file ("gfx/conback.lmp");
	precache_file ("gfx/qplaque.lmp");

	precache_file ("gfx/menudot1.lmp");
	precache_file ("gfx/menudot2.lmp");
	precache_file ("gfx/menudot3.lmp");
	precache_file ("gfx/menudot4.lmp");
	precache_file ("gfx/menudot5.lmp");
	precache_file ("gfx/menudot6.lmp");

	precache_file ("gfx/menuplyr.lmp");
	precache_file ("gfx/bigbox.lmp");
	precache_file ("gfx/dim_modm.lmp");
	precache_file ("gfx/dim_drct.lmp");
	precache_file ("gfx/dim_ipx.lmp");
	precache_file ("gfx/dim_tcp.lmp");
	precache_file ("gfx/dim_mult.lmp");
	precache_file ("gfx/mainmenu.lmp");
	
	precache_file ("gfx/box_tl.lmp");
	precache_file ("gfx/box_tm.lmp");
	precache_file ("gfx/box_tr.lmp");
	
	precache_file ("gfx/box_ml.lmp");
	precache_file ("gfx/box_mm.lmp");
	precache_file ("gfx/box_mm2.lmp");
	precache_file ("gfx/box_mr.lmp");
	
	precache_file ("gfx/box_bl.lmp");
	precache_file ("gfx/box_bm.lmp");
	precache_file ("gfx/box_br.lmp");
	
	precache_file ("gfx/sp_menu.lmp");
	precache_file ("gfx/ttl_sgl.lmp");
	precache_file ("gfx/ttl_main.lmp");
	precache_file ("gfx/ttl_cstm.lmp");
	
	precache_file ("gfx/mp_menu.lmp");
	
	precache_file ("gfx/netmen1.lmp");
	precache_file ("gfx/netmen2.lmp");
	precache_file ("gfx/netmen3.lmp");
	precache_file ("gfx/netmen4.lmp");
	precache_file ("gfx/netmen5.lmp");
	
	precache_file ("gfx/sell.lmp");
	
	precache_file ("gfx/help0.lmp");
	precache_file ("gfx/help1.lmp");
	precache_file ("gfx/help2.lmp");
	precache_file ("gfx/help3.lmp");
	precache_file ("gfx/help4.lmp");
	precache_file ("gfx/help5.lmp");

	precache_file ("gfx/pause.lmp");
	precache_file ("gfx/loading.lmp");

	precache_file ("gfx/p_option.lmp");
	precache_file ("gfx/p_load.lmp");
	precache_file ("gfx/p_save.lmp");
	precache_file ("gfx/p_multi.lmp");

	//----------------------------------------------------------------------
	// sounds loaded by C code
	//----------------------------------------------------------------------
	precache_sound ("misc/menu1.wav");
	precache_sound ("misc/menu2.wav");
	precache_sound ("misc/menu3.wav");

	precache_sound ("ambience/water1.wav");
	precache_sound ("ambience/wind2.wav");

	//----------------------------------------------------------------------
	// shareware
	//----------------------------------------------------------------------
	precache_file ("maps/start.bsp");

	/* Not really relevant anymore, can always add back later
	precache_file ("maps/e1m1.bsp");
	precache_file ("maps/e1m2.bsp");
	precache_file ("maps/e1m3.bsp");
	precache_file ("maps/e1m4.bsp");
	precache_file ("maps/e1m5.bsp");
	precache_file ("maps/e1m6.bsp");
	precache_file ("maps/e1m7.bsp");
	precache_file ("maps/e1m8.bsp");
	*/

	//----------------------------------------------------------------------
	// registered
	//----------------------------------------------------------------------
	precache_file2 ("gfx/pop.lmp");

	/* Not really relevant anymore, can always add back later
	precache_file2 ("maps/e2m1.bsp");
	precache_file2 ("maps/e2m2.bsp");
	precache_file2 ("maps/e2m3.bsp");
	precache_file2 ("maps/e2m4.bsp");
	precache_file2 ("maps/e2m5.bsp");
	precache_file2 ("maps/e2m6.bsp");
	precache_file2 ("maps/e2m7.bsp");

	precache_file2 ("maps/e3m1.bsp");
	precache_file2 ("maps/e3m2.bsp");
	precache_file2 ("maps/e3m3.bsp");
	precache_file2 ("maps/e3m4.bsp");
	precache_file2 ("maps/e3m5.bsp");
	precache_file2 ("maps/e3m6.bsp");
	precache_file2 ("maps/e3m7.bsp");

	precache_file2 ("maps/e4m1.bsp");
	precache_file2 ("maps/e4m2.bsp");
	precache_file2 ("maps/e4m3.bsp");
	precache_file2 ("maps/e4m4.bsp");
	precache_file2 ("maps/e4m5.bsp");
	precache_file2 ("maps/e4m6.bsp");
	precache_file2 ("maps/e4m7.bsp");
	precache_file2 ("maps/e4m8.bsp");

	precache_file2 ("maps/end.bsp");

	precache_file2 ("maps/dm1.bsp");
	precache_file2 ("maps/dm2.bsp");
	precache_file2 ("maps/dm3.bsp");
	precache_file2 ("maps/dm4.bsp");
	precache_file2 ("maps/dm5.bsp");
	precache_file2 ("maps/dm6.bsp");
	*/
};

//======================================================================
/*QUAKED worldspawn (0 0 0) ? x
Unique entity in every map (read only in QC)
-------- KEYS --------
worldtype   : World type 0 = medieval, 1 = metal, 2 = base
wad         : list of Wad Files used by compiler (; for separation)
sounds      : CD Music track to play (4-11, 12+ custom tracks)
message     : Title of map

light       : Ambient light level (eg 5) 
sky         : 6 sided cube for sky brushes (night_)
_range      : Scales brightness range of all lights (useful for dirt)
_dist       : Scales the fade distance of all lights by a factor of n
_anglescale : Scaling factor for how much influence the angle of incidence
_gamma      : Adjust brightness of final lightmap

_sunlight          : Brightness of SUN (eg 100)
_sunlight_color    : Red/Green/Blue (0.78 0.86 1.00)
_sunlight_mangle   : Angle of sunlight (eg 0 -90 0)
_sun_mangle        : Duplicate version of sunlight_mangle
_sunlight_penumbra : Penumbra width, in degrees, of sunlight
_sunlight_dirt     : 1 = enables dirt mapping on sun

// Ambient bounce light (multiple suns in a dome)
_sunlight2       : Second SUN (eg 100)
_sunlight2_color : Red/Green/Blue (0.78 0.86 1.00)
_sunlight2_dirt  : 1 = enables dirt mapping on sun 2
_sunlight3       : Third SUN! (ask MFX)

_dirt          : 1 = enables dirtmapping (ambient occlusion) on all lights
_dirtmode      : Choose between ordered (def=0) and randomized (1)
_dirtscale     : Scale factor used in dirt calculations, def=1
_dirtgain      : Exponent used in dirt calculation, def=1
_dirtdepth     : Maximum depth of occlusion checking, def=128
_minlight_dirt : 1 enables dirtmapping (ambient occlusion) on minlight
compilerstyle_start : starting point for target lights (set by compiler)

gravity        : gravity of map (default = 800)
fog            : console command (Den/R/G/B - '0.05 0.3 0.3 0.3')
fog_density    : Trigger fog starting density (default = 0.1)
fog_colour     : Trigger fog starting colour (default = 0.1 0.1 0.1)
fog_dpextra    : extra DP fog parameters, default - '1 0 8192 1024 32'
skyfog_density : Trigger skyfog starting density (default = 0.5)
water_alpha    : Water Alpha, default - 1.00
particlemax    : Amount of ACTIVE particles per map
playerweather  : Name of weather effect active above player

passive_state     : All monsters are setup in a passive state 1=ON
no_item_offset    : All ammo/heal items use central point rotation
no_item_rotate    : Not used anymore (keep for legacy reasons)
no_zaware         : Switch OFF zaware monster attacks
no_sgprojectile   : Switches OFF ALL shotgun projectiles
no_sgcasing       : Switches OFF ALL shotgun casings
no_liquiddmg      : Switch OFF liquid (slime/lava) monster damage
no_trackondeath   : Homing missiles stop tracking when monster dead (1=active)
hazard_dmg        : Hazard damage override for map (water=2/slime=4/lava=10)
knight_defskin    : Default skin (0-3) type for new knight model
bodyflrcheck      : All monster dead body check floor for gravity
bodyfadeaway      : All monster dead bodies fade away
sprite_particles  : Switch all custom particles to sprites (builtin excluded)
no_bigprojectiles : Switches OFF large player projectiles size
no_surfacecheck   : Stops surface checks for sky brushes (Very large maps only)
mapvar_update     : Update map variables (Range X->Y=Z)
ckeyhint          : Arcane key Inventory message 1=SUPPRESS (no msg to player)

jump_height     : Player jump height (def=270) initial boast from standing still
fall_speedlow   : Fall speed for any checks (def=-300) must be negative no.
fall_speedhigh  : Fall speed for damage checks (def=-650) must be negative no.
fall_speeddebug : Display players fall velocity to console (1=ON, -1=OFF)
fall_dmg        : Fall damage for player (def=5, -1=no dmg/sound)
fall_dmgwater   : Fall damage into water (>0 for dmg/sound, -1=no dmg/sound)

upgrade_axe     : Upgrade Axe -1=remove on spawn, 1=enable
upgrade_ghook   : Upgrade Grapple Hook -1=remove on spawn, 1=enable
upgrade_ssg     : Upgrade Super Shotgun -1=remove on spawn, 1=enable
upgrade_lg      : Upgrade Lightning Gun -1=remove on spawn, 1=enable

give_weapons    : Bit flag for which weapons to give to the player
take_weapons    : 1=SG, 2=SSG, 4=NG, 8=SNG, 16=GL, 32=RL, 64=LG (excludes Axe)
max_health      : Update player health if below this value
reset_health    : Reset player health to this value (1-100)
player_health   : Max/Mega/Skill (1=Easy,2=Normal,4=Hard,8=NM,15=All)
bleeding_dmg    : Percentage reduction / HoT Qty / Initial pause
currentammo     : =1 reset inventory, =0 minimum values
ammo_shells     : Setup starting shell quanity (reset/minimum)
ammo_nails      : Setup starting nails quanity (reset/minimum)
ammo_rockets    : Setup starting rockets quanity (reset/minimum)
ammo_cells      : Setup starting cells quanity (reset/minimum)
armortype       : Armour type to start with 1=Green, 2=Yellow, 3=Red
armorvalue      : Quantity of armour to reset player (100/150/200)
plasmagun_dmg   : Plasma gun damage override (def=45 0 20)

gh_hookstyle    : Swing=0 / linear=1 movement of hook/client
gh_debugmove    : Show debug entities for grapple movement (-1=def qty)
gh_funchookonly : Only works with func grapple hook points
gh_hookearly    : Chain pulling start before hook attached
gh_maxdist      : Maximum distance grapple hook can travel
gh_hookspeed    : Forward momentum of hook (rocket spd+)
gh_pullspeed    : Forward momentum on chain (pulling forward)
gh_mindist      : Minimum distance to slowdown velocity
gh_minbeam      : Minimum distance to stop drawing beam
gh_dmg          : Damage to Player/Monsters/World (def=4 8 8)
gh_linechain    : Linear movement while on the chain
gh_jumpchain    : Jump movement to jumping off the chain
gh_boostchain   : Boost movement during swing/pull chain
gh_movemonster  : Monster movement when impacted by chain

======================================================================*/
void() worldspawn =
{
	dprint ("\b[WORLDSPAWN]\b function started ...\n");
	lastspawn = world;
	InitBodyQue ();
	developer = cvar("developer");
	self.classtype = CT_WORLD;
	
	//----------------------------------------------------------------------
	// MOD version, patch and optional beta number
	//----------------------------------------------------------------------
	mod_version = 1.80;
	mod_patch = 1;
	mod_beta = 0;

	// ID map E3M3 has worldspawn angles set, WTF!?!
	if (self.angles_y != 0) self.angles = '0 0 0';

	// Engine resets skill 0-3, change it back
	Client_SyncEvilmode();
	
	//----------------------------------------------------------------------
	// these sounds MUST be the first precache_sounds
	//----------------------------------------------------------------------
	precache_sound ("weapons/r_exp3.wav");		// Hardcoded Explosion (null)
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");		// Rocket launcher!?!
	//	precache_sound ("weapons/guncock.wav");	// player shotgun (not used anymore)
	precache_sound ("weapons/sg1.wav");			// Original SG (reduced hiss/noise)	
	precache_sound ("weapons/sg2.wav");			// New SG (with shell casing)
	precache_sound ("weapons/ric1.wav");		// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");		// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");		// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");		// super spikes
	precache_sound ("weapons/tink1.wav");		// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");		// grenade launcher
	precache_sound ("weapons/gl_loadshort.wav");// MONSTER grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	//	precache_sound ("weapons/shotgn2.wav");	// super shotgun (not used anymore)
	precache_sound ("weapons/ssg1.wav");		// Original SSG (reduced hiss/noise)
	precache_sound ("weapons/ssg2.wav");		// Projectile shells or Shotgun upgrade
	precache_sound (SOUND_PLASMA_LOAD);			// plasma load (eliminator)
	precache_sound (SOUND_PLASMA_FIRE);			// Player PG (eliminator)
	precache_sound (SOUND_PLASMA_HIT);			// New fire/impact sounds
	precache_sound (SOUND_MISFIRE);				// Weapon jams/noammo/broken

	//----------------------------------------------------------------------
	precache_sound (SOUND_REXP3);				// Original explosion
	precache_sound (SOUND_RESIST_ROCKET);		// Resist Rockets
	
	//----------------------------------------------------------------------
	// sounds used from C physics code
	precache_sound ("demon/dland2.wav");		// landing thud
	precache_sound ("misc/h2ohit1.wav");		// landing splash

	//----------------------------------------------------------------------
	// Always precaches player sounds
	precache_sound (SOUND_RESPAWN);				// item respawn sound
	precache_sound (SOUND_PLAYER_JUMP);			// player jump
	precache_sound ("player/land.wav");			// player landing
	precache_sound ("player/land2.wav");		// player hurt landing
	precache_sound ("player/drown1.wav");		// drowning pain
	precache_sound ("player/drown2.wav");		// drowning pain
	precache_sound ("player/gasp1.wav");		// gasping for air
	precache_sound ("player/gasp2.wav");		// taking breath
	precache_sound ("player/h2odeath.wav");		// drowning death

	precache_sound (SOUND_EMPTY);				// Empty sound
	precache_sound (SOUND_TALK);				// talk message/trigger
	precache_sound ("player/teledth1.wav");		// telefrag
	precache_sound ("misc/r_tele1.wav");		// teleport sounds
	precache_sound ("misc/r_tele2.wav");
	precache_sound ("misc/r_tele3.wav");
	precache_sound ("misc/r_tele4.wav");
	precache_sound ("misc/r_tele5.wav");
	precache_sound ("weapons/lock4.wav");		// ammo pick up
	precache_sound ("weapons/pkup.wav");		// weapon up
	precache_sound ("items/armor1.wav");		// armor up
	precache_sound ("weapons/lhit.wav");		// lightning
	precache_sound ("weapons/lstart.wav");		// lightning start
	precache_sound ("weapons/shellc.wav");		// Shotgun shell falling to floor
	precache_sound (SOUND_ARTQUAD3);			// Quad firing
	precache_sound (SOUND_ARTPENT3);			// God mode on, taking damage
	precache_sound (SOUND_ARTSHARP3);			// Sharp Shooter firing
	precache_sound (SOUND_ARTNAILP3);			// Nail Piercer firing
	precache_sound (SOUND_ARTBLASTBELT3);		// Blast belt active
	precache_sound (SOUND_ARTLSHIELD3);			// Lava shield active
	
	
	precache_sound ("misc/power.wav");			//lightning for boss

	//----------------------------------------------------------------------
	// player gib sounds
	precache_sound ("player/gib.wav");			// Used for players only
	precache_sound (GIB_SOUND_UDEATH);			// Used for monsters and players (sounds player)
	precache_sound ("player/tornoff2.wav");		// Exit sound for client disconnect

	//----------------------------------------------------------------------
	// player pain sounds
	precache_sound ("player/pain1.wav");
	precache_sound ("player/pain2.wav");
	precache_sound ("player/pain3.wav");
	precache_sound ("player/pain4.wav");
	precache_sound ("player/pain5.wav");
	precache_sound ("player/pain6.wav");

	//----------------------------------------------------------------------
	// player death sounds
	precache_sound ("player/death1.wav");
	precache_sound ("player/death2.wav");
	precache_sound ("player/death3.wav");
	precache_sound ("player/death4.wav");
	precache_sound ("player/death5.wav");

	//----------------------------------------------------------------------
	// more weapon sounds
	//	precache_sound ("weapons/ax1.wav");			// ax swoosh
	//	precache_sound ("player/axhit1.wav");		// ax hit meat
	//	precache_sound ("player/axhit2.wav");		// ax hit world
	precache_sound(SOUND_AXE_SWIPE1);			// Axe swipe 1
	precache_sound(SOUND_AXE_SWIPE2);			// Axe swipe 2
	precache_sound(SOUND_AXE_PLAYER);			// axe hit player
	precache_sound(SOUND_AXE_STONE);			// stone impact
	precache_sound(SOUND_AXE_WOOD);				// wood impact
	precache_sound(SOUND_AXE_GLASS);			// glass impact
	precache_sound(SOUND_AXE_METAL);			// metal impact
	precache_sound(SOUND_AXE_FLESH);			// flesh impact
	precache_sound(SOUND_AXE_CERAMIC);			// Ceramic impact
	precache_sound(GIB_SOUND_HEAVY);			// fleshy
	precache_sound(GIB_SOUND_HEAVY2);			// harder flesh!

	precache_sound ("player/h2ojump.wav");		// player jumping into water
	precache_sound ("player/slimbrn2.wav");		// player enter slime
	precache_sound ("player/inh2o.wav");		// player enter water
	precache_sound ("player/inlava.wav");		// player enter lava
	precache_sound ("misc/outwater.wav");		// leaving water sound

	precache_sound ("player/lburn1.wav");		// lava burn
	precache_sound ("player/lburn2.wav");		// lava burn

	precache_sound ("misc/water1.wav");			// swimming
	precache_sound ("misc/water2.wav");			// swimming
	precache_sound (SOUND_HEARTBEAT);			// Heartbeat (fast 1s)

	precache_model (MODEL_PLAYER);
	precache_model (MODEL_PLAYER_EYES);
	precache_model (MODEL_PLAYER_HEAD);
	//	precache_model ("progs/gib1.mdl");		// Replaced with better models
	//	precache_model ("progs/gib2.mdl");
	//	precache_model ("progs/gib3.mdl");

	precache_model (SBUBBLE_DROWN);			// player drowning bubbles
	precache_model (SEXP_SMALL);			// Fire explosion (ID)
	precache_model (SEXP_MED);				// Fire explosion (Quoth)
	precache_model (SEXP_BIG);				// Fire explosion (Quoth)
	precache_model (SEXP_PLASMA_SMALL);		// Plasma explosion (Marcher)
	precache_model (SEXP_PLASMA_BIG);		// Plasma explosion (Marcher)
	precache_model (SEXP_POISON_SMALL);		// Poison explosion (Marcher)
	precache_model (SEXP_POISON_MED);		// Poison explosion (Quoth)
	precache_model (SEXP_ELECTRIC);			// Impact explosion (Quoth)
	precache_model (SBURST_SMOKE);			// Small puff of smoke (Rubicon2)
	// Hardly ever used, entity cache it if needed
	// precache_model (SEXP_ICE_BIG);			// Ice explosion (ne_ruin)

	precache_model (MODEL_PROJ_SMOKE);		// Empty model + smoke trail
	precache_model (MODEL_PROJ_FLESH);		// SpawnMeatSpray - projectiles.qc
	precache_model (MODEL_PROJ_FLESHP);		// Poisonous version of meat

	precache_model (MODEL_VWEAP_AXE);		// regular
	precache_model (MODEL_VWEAP_UPAXE);		// Upgrade - Shadow
	precache_model (MODEL_VWEAP_GHOOK);		// Upgrade - Grapple Hook
	precache_model (MODEL_VWEAP_SG);
	precache_model (MODEL_VWEAP_SSG);
	precache_model (MODEL_VWEAP_UPSSG);		// Upgrade - Widowmaker
	precache_model (MODEL_VWEAP_NG);
	precache_model (MODEL_VWEAP_SNG);
	precache_model (MODEL_VWEAP_GL);
	precache_model (MODEL_VWEAP_RL);
	precache_model (MODEL_VWEAP_LG);
	precache_model (MODEL_VWEAP_UPLG);		// Upgrade - Plasma Gun
	
	// precache_model (MODEL_VWEAP_ZSSG);	// Zerstorer Riot gun

	precache_model ("progs/bolt.mdl");		// for lightning gun
	precache_model ("progs/bolt2.mdl");		// for lightning gun
	precache_model ("progs/bolt3.mdl");		// for boss shock
	precache_model (MODEL_PROJ_PGPLASMA);	// Plasma bolt for PG
	precache_model (MODEL_PROJ_LIGHTNING2);	// reflected lightning
	//	precache_model ("progs/lavaball.mdl");	// for testing
	
	precache_model (MODEL_PROJ_BEAM);		// Hardcoded grapple beam
	precache_model (MODEL_PROJ_GHOOK);		// Grapple Hook projectile
	precache_sound (SOUND_GHOOKFIRE);		// Firing sound

	precache_model (MODEL_PROJ_SHELLC);		// Launch_ShellCasing - projectiles.qc
	precache_model (MODEL_PROJ_DIAM2);		// Projectile bullets
	precache_model (MODEL_PROJ_NG);
	precache_model (MODEL_PROJ_NGRED);		// Reflected nails
	precache_model (MODEL_PROJ_SNG);
	precache_model (MODEL_PROJ_GRENADE);
	// precache_model (MODEL_PROJ_GRENADEGRN);	// Poisonous Grenade
	precache_model (MODEL_PROJ_ROCKET);
	precache_model (MODEL_BACKPACK);		// DropBackpack - items.qc
	
	//----------------------------------------------------------------------
	// Pre-cache for MOD stuff
	//----------------------------------------------------------------------
	precache_model (MODEL_BROKEN);			// Broken model error
	precache_model (MODEL_EMPTY);			// Used for info_intermission cameras
	precache_model (MODEL_CORNER1);			// Dev spawn angle marker
	
	precache_model (GIB1_BLOOD);			// New gib - arm/leg
	precache_model (GIB2_BLOOD);			// New gib - body
	precache_model (GIB3_BLOOD);			// New gib - slice
	precache_model (GIB4_BLOOD);			// New gib - small chunk/ball
	precache_model (GIB5_BLOOD);			// New gib - large chunk/ball

	precache_sound (GIB1_SOUND);			// Monster Gib 1
	precache_sound (GIB3_SOUND);			// Monster Gib 3
	precache_sound (GIB5_SOUND);			// Monster Gib 5
	precache_sound (GIBHIT1_SOUND);			// Gib Impact sound 1
	precache_sound (GIBHIT2_SOUND);			// Gib Impact sound 2
	precache_sound (GIBHIT3_SOUND);			// Gib Impact sound 3
	precache_sound (GIBHIT4_SOUND);			// Gib Impact sound 4
	precache_sound (GIBHIT5_SOUND);			// Gib Impact sound 5
	precache_sound (GIBHIT1_STONESOUND);	// long roll
	precache_sound (GIBHIT3_STONESOUND);	// quick roll
	precache_sound (GIBHIT5_STONESOUND);	// slow roll
	precache_sound (GIBHIT1_METALSOUND);	// small clink
	precache_sound (GIBHIT3_METALSOUND);	// large clank
	precache_sound (GIBHIT5_METALSOUND);	// gigantic clonk
	precache_sound (GIB_SOUND_HEAVY);		// Large gib
	precache_sound (GIB_SOUND_METALA);		// Sword impact
	precache_sound (GIB_SOUND_METALB);		// Sword impact
	precache_sound (GIB_SOUND_CHAIN);		// Chain impact
	precache_sound (GIB_SOUND_WOOD);		// Wooden impact
	precache_sound (GIB_SOUND_ACID);		// Acid burning
	precache_sound (GIB_SOUND_SDEATH);		// Stone death

	//----------------------------------------------------------------------
	// Footstep sounds (slow, light, medium, heavy, large & giant)
	//----------------------------------------------------------------------
	precache_sound (SOUND_FS_SLOW1);
	precache_sound (SOUND_FS_SLOW2);
	precache_sound (SOUND_FS_SLOW3);
	precache_sound (SOUND_FS_SLOW4);
	precache_sound (SOUND_FS_SLOW5);

	precache_sound (SOUND_FS_DRAG1);
	precache_sound (SOUND_FS_DRAG2);
	precache_sound (SOUND_FS_DRAG3);
	precache_sound (SOUND_FS_DRAG4);
	precache_sound (SOUND_FS_DRAG5);

	precache_sound (SOUND_FS_LIGHT1);
	precache_sound (SOUND_FS_LIGHT2);
	precache_sound (SOUND_FS_LIGHT3);
	precache_sound (SOUND_FS_LIGHT4);
	precache_sound (SOUND_FS_LIGHT5);

	precache_sound (SOUND_FS_MEDIUM1);
	precache_sound (SOUND_FS_MEDIUM2);
	precache_sound (SOUND_FS_MEDIUM3);
	precache_sound (SOUND_FS_MEDIUM4);
	precache_sound (SOUND_FS_MEDIUM5);

	precache_sound (SOUND_FS_HEAVY1);
	precache_sound (SOUND_FS_HEAVY2);
	precache_sound (SOUND_FS_HEAVY3);
	precache_sound (SOUND_FS_HEAVY4);
	precache_sound (SOUND_FS_HEAVY5);

	precache_sound (SOUND_FS_LARGE1);
	precache_sound (SOUND_FS_LARGE2);
	precache_sound (SOUND_FS_LARGE3);
	precache_sound (SOUND_FS_LARGE4);
	precache_sound (SOUND_FS_LARGE5);

	precache_sound (SOUND_FS_GIANT1);
	precache_sound (SOUND_FS_GIANT2);
	precache_sound (SOUND_FS_GIANT3);
	precache_sound (SOUND_FS_GIANT4);
	precache_sound (SOUND_FS_GIANT5);

	//----------------------------------------------------------------------
	// Check for engine type and extensions (different features)
	//----------------------------------------------------------------------
	engine = ENG_FITZ;						// Default engine type (no extensions)
	ext_active = cvar("pr_checkextension");	// Check for extra extensions
	if (ext_active) {
		// This could be DP, QSS, DQ, RMQ, Qbism etc
		engine = ENG_DPEXT;

		// Check for DP/FTE point particle extensions
		ext_dppart = checkextension("DP_SV_POINTPARTICLES");
		ext_ftepart = checkextension("FTE_SV_POINTPARTICLES");
		// DP extra fog params
		ext_dpfog = checkextension("DP_GFX_FOG");
		// surface content
		ext_dpsurf = checkextension("DP_QC_GETSURFACE");
		// particle rain/snow system
		// QSS supports weather extensions in v7+
		ext_dprain = checkextension("DP_TE_PARTICLERAIN");
		ext_dpsnow = checkextension("DP_TE_PARTICLESNOW");
		// If weather extensions active, assume default = ON
		if (ext_dprain || ext_dpsnow) weathersys = TRUE;

		// Engine support for proper rotating/colliding bmodels
		ext_dprot = checkextension("DP_SV_ROTATINGBMODEL");
		// Check for FTE skin/ladder system
		ext_fteskin = checkextension("FTE_ENT_SKIN_CONTENTS");
		// Frik file system, advanced strings and C code sprintf
		ext_frikfile = checkextension("FRIK_FILE");
		ext_ftestrings = checkextension("FTE_STRINGS");
		ext_sprintf = checkextension("DP_QC_SPRINTF");
		
		// There is no way to detect CSQC, no checkextension exists!
		// If DP detect the CSQC functions it will just use them.
		// QSS/FTE has a console variable to toggle CSQC on/off,
		// but requires the map to be reload for changes to take affect.
		// Setup a temp variable if none is found (def=0 CSQC is on)
		autocvar(cl_nocsqc, "0");
		// Read scratch1 in quake.rc (-1=off, 0=on, 1+=diff layouts)
		if (cvar("scratch1") < 0) cvar_set("cl_nocsqc", "1");
		
		// Setup variables for CSQC HUD (cannot directly query variables)
		// FTE/QSS use clientstat, DP use addstat (same function)
		// The addstat is defined in dpextensions.qc
		// void(float index, float type, ...) addstat = #232;
		addstat(CLIENT_MODITEMS, EV_FLOAT, moditems); 
		addstat(CLIENT_CKEYNAME1, EV_STRING, ckeyname1); 
		addstat(CLIENT_CKEYNAME2, EV_STRING, ckeyname2); 
		addstat(CLIENT_CKEYNAME3, EV_STRING, ckeyname3); 
		addstat(CLIENT_CKEYNAME4, EV_STRING, ckeyname4); 
		addstat(CLIENT_CKEYSKIN1, EV_FLOAT, ckeyskin1); 
		addstat(CLIENT_CKEYSKIN2, EV_FLOAT, ckeyskin2); 
		addstat(CLIENT_CKEYSKIN3, EV_FLOAT, ckeyskin3); 
		addstat(CLIENT_CKEYSKIN4, EV_FLOAT, ckeyskin4); 	
	}

	dprint("\n\b[ENGINE]\b ");
	if (engine == ENG_FITZ) dprint("Fitz Compatible\n");
	else if (engine == ENG_DPEXT) dprint("Advanced Engine\n");
	else dprint("Unknown\n");

	// Large maps cannot use this function, check for disable
	if (self.no_surfacecheck == TRUE) ext_dpsurf = 0;
	
	//----------------------------------------------------------------------
	// Check for any custom water alpha defined on the worldspawn
	// This is not very precise because FTOS is only ONE decimal place
	// Once the client has started, the water alpha is fine tuned
	if (self.water_alpha) {
		liquid_alpha = self.water_alpha;
		cvar_set ("r_wateralpha", ftos(liquid_alpha));
	}

	// Default is auto aim OFF
	autoaim_cvar = 1;
	
	// Check for any override on player projectiles
	playerprojsize = world.no_bigprojectiles;
	
	//----------------------------------------------------------------------
	// Check for changes to monster homing missiles on death behaviour
	if (self.no_trackondeath == TRUE) map_notrackondeath = TRUE;
	else map_notrackondeath = FALSE;
	
	//----------------------------------------------------------------------
	// Check for hazard damage override (water=2/sline=4/lava=10)
	if (self.hazard_dmg_x <= 0) map_hazarddmg_x = WATER_DAMAGE;
	else map_hazarddmg_x = self.hazard_dmg_x;
	if (self.hazard_dmg_y <= 0) map_hazarddmg_y = SLIME_DAMAGE;
	else map_hazarddmg_y = self.hazard_dmg_y;
	if (self.hazard_dmg_z <= 0) map_hazarddmg_z = LAVA_DAMAGE;
	else map_hazarddmg_z = self.hazard_dmg_z;
	
	//----------------------------------------------------------------------
	// Check for any custom gravity settings or ziggy secret map
	if (!self.gravity) map_gravity = DEF_GRAVITY;
	else map_gravity = self.gravity;
	if (self.model == "maps/e1m8.bsp") map_gravity = 100; // Ziggy secret map
	cvar_set ("sv_gravity", ftos(map_gravity));
	
	//----------------------------------------------------------------------
	// All value checks done in separate function (triggers.qc)
	player_fallspeed_reset();
	player_fallspeed_setup();
	
	//----------------------------------------------------------------------
	// Check for Plasma gun damage override (Direct, Random, Splash)
	if (!CheckZeroVector(world.plasmagun_dmg)) map_plasmagundmg = world.plasmagun_dmg;
	else map_plasmagundmg = DAMAGE_PGPLAYER;

	//----------------------------------------------------------------------
	// Check for Bleeding damage override (Percentage, HoT, Pause)
	if (!CheckZeroVector(world.bleeding_dmg)) map_bleedingdmg = world.bleeding_dmg;
	else map_bleedingdmg = DAMAGE_BLEEDING;
	// Make sure all parameters are within certain ranges
	// Perc = 0.05-0.75, HoT = 1-10, Pause = 0.1-10
	if (map_bleedingdmg_x <= 0.05) map_bleedingdmg_x = 0.05;
	else if (map_bleedingdmg_x >= 0.75) map_bleedingdmg_x = 0.75;
	if (map_bleedingdmg_y <= 1) map_bleedingdmg_y = 1;
	else if (map_bleedingdmg_y >= 10) map_bleedingdmg_y = 10;
	if (map_bleedingdmg_z <= 0.1) map_bleedingdmg_z = 0.1;
	else if (map_bleedingdmg_z >= 10) map_bleedingdmg_z = 10;
	
	//----------------------------------------------------------------------
	// Check for global body floor check and fading timer
	if (self.bodyflrcheck == 1) map_bodyflrcheck = TRUE;
	else map_bodyflrcheck = FALSE;
	if (self.bodyfadeaway > 0) map_bodyfadeaway = self.bodyfadeaway;
	else map_bodyfadeaway = FALSE;

	// Check for all monsters being setup in a passive state
	// Useful for explore jam events where minimal combat required
	if (self.passive_state == 1) map_passivestate = TRUE;
	else map_passivestate = FALSE;
	
	//----------------------------------------------------------------------
	// The values of configflag is never saved, its always generated!
	// merge any changes from worldspawn into console variable
	configflag = cvar("temp1");
	sycn_worldspawn();
	temp1flag = configflag;

	dprint("\b[WORLD]\b TEMP1 + Worldspawn ("); 
	dprint(ftos(temp1flag)); dprint(")\n");
		
	//----------------------------------------------------------------------
	// Setup Particle System
	//----------------------------------------------------------------------
	if (query_configflag(SVR_PARTICLES) == SVR_PARTICLES) {
		if (self.particlemax > PARTICLE_MAXENTS) part_max = self.particlemax;
		else part_max = PARTICLE_MAXENTS;
		// DP/FTE setup requires less entities for sprite particles
		if (engine == ENG_DPEXT && query_configflag(SVR_SPRPARTON) == FALSE
			&& self.sprite_particles == FALSE)
			part_multiplier = 0.5;
		else part_multiplier = 1;
		
		part_max = part_max * part_multiplier;
		dprint("\b[WORLD]\b Max particles (");
		dprint(ftos(part_max)); dprint(")\n");
		setup_particlechain();		// Setup intial particle chain
	}
	
	//----------------------------------------------------------------------
	// Check if FTE/QSS (FTE_SV_POINTPARTICLES) particles are active
	// This has got to happen after 'sycn_worldspawn' function
	// Allow for 'saved1' variable in quake.rc to be read
	//----------------------------------------------------------------------
	if (ext_ftepart == TRUE) {
		// Switch to vanilla particle effects (no smoke, sparks etc)
		// Don't bother with sprite settings for DP, the default is worse!
		if (query_configflag(SVR_SPRPARTON) == SVR_SPRPARTON) {
			// Load particle effects (mostly empty defs)
			particleeffectnum("effectvanilla.txt");
			// Make sure all extra particle effects are off
			ext_dppart = ext_ftepart = FALSE;
			weathersys = FALSE;
		}
		else {
			// Set both active, used through out code
			ext_dppart = ext_ftepart = TRUE;
			// Check for FTE/QS-S point particle extensions
			// Engine wants config files in different locations
			if (checkextension("FTE_PART_NAMESPACE_EFFECTINFO")) {
				// Load particle effects file (DP default=mod root)
				particleeffectnum("effectinfo.txt");
				// Load up default weather effects
				particleeffectnum("fte_weather.cfg");
			}
		}
	}
	
	//----------------------------------------------------------------------
	// Allow (Eric) compiler to change the starting point for target lights
	light_style_boundary();
	dprint("\b[WORLD]\b Switchable lights start (");
	dprint(ftos(mapstyle_start)); dprint(")\n");
	
	//----------------------------------------------------------------------
	// Setup target light starting point
	// Got to do this early before any light entities
	dprint("\b[WORLD]\b Setup Light style array\n");
	light_style_setuparray();
	dprint("\b[WORLD]\b Setup Pendulum vector array\n");
	pendulum_setuparray();
	dprint("\b[WORLD]\b Setup Map Var bitflag array\n");	
	mapvar_setuparray();
	dprint("\b[WORLD]\b Setup Shadow lightstyle array\n");	
	switch_shadow_setuparray();

	//----------------------------------------------------------------------
	// Original id levels
	// Episode 1
	// The Slipgate Complex, Castle of the Damned, The Necropolis, The Grisly Grotto
	// Gloom Keep, The Door to Chthon, The House of Chthon, Ziggurat Vertigo (S)
	// Episode 2
	// The Installation, The Ogre Citadel, The Crypt of Decay, The Ebon Fortress
	// The Wizard's Manse, The Dismal Oubliette, The Underearth (S)
	// Episode 3
	// Termination Central, The Vaults of Zin, The Tomb of Terror, Satan's Dark Delight
	// The Wind Tunnels, Chambers of Torment, The Haunted Halls (S)
	// Episode 4
	// The Sewage System, The Tower of Despair, The Elder God Shrine, The Palace of Hate
	// Hell's Atrium, The Pain Maze, Azure Agony, The Nameless City (S)
	//----------------------------------------------------------------------
};

//======================================================================
// Start frame
//======================================================================
void() StartFrame =
{
	skill = cvar("skill");
	developer = cvar("developer");
	teamplay = cvar("teamplay");
	coop = cvar("coop");

	framecount = framecount + 1;
};

//======================================================================
// BODY QUE
// Keeps track of dead player models
//======================================================================
entity	bodyque_head;

// just here so spawn functions don't complain after the world
// creates bodyques
void() bodyque = {};

//----------------------------------------------------------------------
// New Code from Inside3d forums (old system was terrible)
//----------------------------------------------------------------------
void() InitBodyQue =
{
	local entity e, prev;
	local float numBodies, num;
	
	num = 0;
	// how many player corpses to allow in the world at once
	numBodies = 10; 
	prev = world;
	bodyque_head = world;
	
	while(num < numBodies) {
		// Spawn another body
		e = spawn();			
		e.classname = "bodyque";

		// If this is the first, set the bodyque_head pointer 
		// (start of the list)
		if(bodyque_head == world) bodyque_head = e;
	
		// Link up to previous item to form the linked list
		if(prev != world) e.owner = prev;
		
		// Point prev to the new item
		prev = e;				
		num = num + 1;
	}
	// turn the linked list into a linked loop
	bodyque_head.owner = prev;	
};

//----------------------------------------------------------------------
// make a body que entry for the given ent so the ent can be
// respawned elsewhere
//----------------------------------------------------------------------
void(entity ent) CopyToBodyQue =
{
	bodyque_head.angles = ent.angles;
	bodyque_head.model = ent.model;
	bodyque_head.modelindex = ent.modelindex;
	bodyque_head.frame = ent.frame;
	bodyque_head.colormap = ent.colormap;
	bodyque_head.movetype = ent.movetype;
	bodyque_head.velocity = ent.velocity;
	bodyque_head.flags = 0;
	setorigin (bodyque_head, ent.origin);
	setsize (bodyque_head, ent.mins, ent.maxs);
	bodyque_head = bodyque_head.owner;
};

/*======================================================================
 Stuff removed
 - QUAKED misc_noisemaker (1 0.5 0) (-10 -10 -10) (10 10 10)
 - QUAKED viewthing (0 .5 .8) (-8 -8 -8) (8 8 8)
 - QUAKED info_null (0 0.5 0) (-4 -4 -4) (4 4 4)
    Used as a positional target for spotlights, etc.
 - QUAKED info_notnull (0 0.5 0) (-4 -4 -4) (4 4 4)
    Used as a positional target for lightning.
 - QUAKED test_teleport (0 .5 .8) ?
 - QUAKED test_fodder (0 .5 .8) ?
 - QUAKED noclass (0 0 0) (-8 -8 -8) (8 8 8)
 - QUAKED item_weapon (0 .5 .8) (0 0 0) (32 32 32) shotgun rocket spikes big
 
======================================================================*/
void() item_weapon = { remove(self); };
void() misc_noisemaker = { remove(self); };
void() noclass = { remove(self); };

void() test_fodder = { remove(self); };
void() test_goaway = { remove(self); };
void() test_spawn = { remove(self); };
void() test_teleport = { remove(self); };

void() testplayerstart = { remove(self); };
void() viewthing = { remove(self); };

//======================================================================
/*QUAKED trigger_onlyregistered (.5 .5 .5) ?
Checks for registered version of game, no one uses this anymore
======================================================================*/
void() trigger_onlyregistered_touch =
{
	if ( !(other.flags & FL_CLIENT) ) return;
	if (self.attack_finished > time) return;

	self.attack_finished = time + 2;
	if (cvar("registered")) {
		self.message = "";
		SUB_UseTargets ();
		remove (self);
	}
	else {
		if (self.message != "") {
			centerprint (other, self.message);
			sound (other, CHAN_BODY, SOUND_TALK, 1, ATTN_NORM);
		}
	}
};

//----------------------------------------------------------------------
void() trigger_onlyregistered =
{
	InitTrigger ();
	self.touch = trigger_onlyregistered_touch;
};

//----------------------------------------------------------------------
// A function that supresses compiler errors
//----------------------------------------------------------------------
void() dpcompiler_errors =
{
	worldstatus = "";
	gettaginfo_parent = 0;
	gettaginfo_name = "";
	gettaginfo_offset = '0 0 0';
	gettaginfo_forward = '0 0 0';
	gettaginfo_right = '0 0 0';
	gettaginfo_up = '0 0 0';
	trace_dpstartcontents = 0;
	trace_dphitcontents = 0;
	trace_dphitq3surfaceflags = 0;
	trace_dphittexturename = "";
};
