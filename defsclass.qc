//======================================================================
// Unique Class Groups for quicker searches (mostly items)
// Previous system used classname (slow string search)
//======================================================================
float CG_PLAYERS = 50;			// All player/clients
float CG_LIGHTS = 70;			// All light type entities
float CG_HEALTH = 100;			// All health pack types (15/25/+100)
float CG_AMMOITEM = 200;		// All ammo items/packs
float CG_PROJALL = 205;			// All monster projectiles
float CG_PROJSHELLS = 210;		// To help with combining shell damage
float CG_PROJNAILS = 215;		// Testing ammo resistance in t_damage
float CG_PROJROCKETS = 220;		// Includes homing missiles
float CG_PROJGRENADES = 225;	// Separated for extra testing
float CG_PROJCELLS = 230;		// Mainly used for plasma
float CG_PROJHAZARD = 235;		// Hazard projectiles (flame/plasma)
float CG_MINIONEGG = 245;		// Special minion eggs
float CG_WEAPON = 250;			// All weapon items
float CG_PROGRESSION = 260;		// All progression items
float CG_ARMOR = 275;			// All armor types
float CG_KEY = 300;				// All keys (gold/silver/custom)
float CG_RUNE = 310;			// All runes 1-4
float CG_ARTIFACT = 350;		// All powerups
float CG_TRAPS = 400;			// Endless supply of traps!
float CG_MISCENT = 410;			// All misc entity types
float CG_TEMPENT = 420;			// All temporary types (gibs, smoke, sparks)
float CG_BREAKABLE = 430;		// All breakable types
float CG_TRIGGERS = 440;		// All trigger types (bmodels)
float CG_TARGETS = 445;			// All target types
float CG_FUNCMOVER = 450;		// All FUNC movers
float CG_HIPROTATE = 460;		// All Hipnotic rotation stuff
float CG_MONSTERS = 500;		// Default

//----------------------------------------------------------------------
// Useful for infighting grouping checks
//----------------------------------------------------------------------
float CG_ARMY = 600;			// (4) Shotgun, Rocket Launcher and Plasma
float CG_ENFORCER = 610;		// (5) Standard, Grenade and Flame, Pyro, Centurion
float CG_DEMON = 615;			// (3) Demon, Drole, Minotaur, Boglord
float CG_DOG = 620;				// (1) Dog
float CG_FISH = 625;			// (2) Fish
float CG_ROBOT = 630;			// (2) Jim, Laser/Rocket, Seeker
float CG_KNIGHT = 635;			// (3) Knight, Death Guard and Crossbow
float CG_DKNIGHT = 637;			// (2) Hell and Death Knight
float CG_DCAPTAIN = 640;		// (2) Fury, Sergeant Captains
float CG_STONE = 645;			// (4) Boss Eidolon, Statues and Golem
float CG_OGRE = 650;			// (4) Vanilla and Hunter (Chainsaw, Mace, Hammer), Freddie
float CG_SPIDER = 660;			// (4) Shalrath, Vorling, Wraith, Spider
float CG_SHAM = 666;			// (1) Shambler
float CG_SPAWN = 670;			// (2) Blue/Green, Boil
float CG_WIZARD = 675;			// (6) Wizard, Gargoyle, Gaunt, Skull Wizard, Skull, Nour
float CG_XMAS = 680;			// (3) Elf, Raindeer, Snowman, Santa
float CG_ZOMBIE = 685;			// (3) Zombie, Knight, Mummy
float CG_BOSS = 690;			// (3) Cthon, Old one

//======================================================================
// Unique Class Types for quicker entity searches
// Previous system used classname (slow string search)
//======================================================================
float CT_WORLD = 1;				// World entity
float CT_PLAYER = 7;			// Player (007)

float CT_SPAWNSP = 100;			// Spawn location - Single Player
float CT_SPAWNCOOP = 110;		// Spawn location - Coop
float CT_SPAWNDM = 120;			// Spawn location - Deathmatch
float CT_CONTROL = 150;			// Controller entity
float CT_CAMERA = 160;			// Camera entity (info_intermission)
float CT_MISCCAM = 180;			// Misc Camera entity
float CT_GHOOKPROJ = 190;		// Grapple Hook projectile

float CT_LIGHT = 200;			// Light entity
float CT_LIGHTSTATIC = 210;		// Static light entity
float CT_SOUNDEMITTER = 250;	// Sound emitter
float CT_DEVMARKER = 260;		// Developer model marker
float CT_PATHCORNER = 280;		// Standard path nodes

float CT_ENEMYTARGET = 300;		// Target enemy for flying enemies
float CT_ATTACHMENT = 320;		// Attachment for entities
float CT_TETHERENT = 330;		// Code generated tether point
float CT_ESTATE = 340;			// Entity state modifier
float CT_MAPVAR = 350;			// Map Variable logic

float CT_PARTICLE = 400;		// A particle
float CT_PARTICLEEMIT = 410;	// A particle emitter
float CT_PARTICLECONT = 420;	// Particle controller (setup particle banks)
float CT_PARTICLETEMP = 450;	// Particle emitter template

float CT_TEMPGIB = 500;			// Temporary entity (gib)
float CT_TEMPSPARK = 510;		// Temporary entity (spark)
float CT_TEMPSTREAM = 520;		// Temporary entity (stream)
float CT_TEMPTRIG = 530;		// Temporary trigger (touch)

float CT_REFLECTLIGHT = 550;	// Reflection entity (Lightning)
float CT_REFLECTPLASMA = 560;	// Reflection entity (Plasma)
float CT_SUMMONLIGHT = 570;		// Summon entity (Lightning)

float CT_STORYCONTROL = 600;	// Controller for story system
float CT_STORYBOOK = 620;		// Story book for the player
float CT_STORYCHAPTER = 640;	// Story chapter for story system

float CT_TARGETDUMMY = 900;		// Misc target dummy
float CT_TARGETNUMBER = 950;	// Misc number drawn ingame

//----------------------------------------------------------------------
// Class Types for all monsters 
//----------------------------------------------------------------------
float CT_MONARMY = 1000;		// Army Soldier
float CT_MONENFORCER = 1010;	// Enforcer
float CT_MONDEMON = 1100;		// 2 clawed fiend
float CT_MONDOG = 1110;			// 4 legged friend
float CT_MONFISH = 1120;		// Fish fish fishy
float CT_MONHELLK = 1200;		// Strong spikey Knights
float CT_MONKNIGHT = 1210;		// Small metal Knights
float CT_MONOGRE = 1300;		// Chainsaw wielding manics
float CT_MONOGREFISH = 1310;	// Madfox fishing ogre
float CT_MONSHAL = 1400;		// Shalrath / Vore
float CT_MONSHAM = 1410;		// Shambler
float CT_MONBOGLORD = 1420;		// Lord of the Bog! (Big shammy)
float CT_MONSPAWN = 1500;		// Bouncing annoying shit!
float CT_MONWIZARD = 1600;		// Wizard / Scrags
float CT_CACHEWIZARD = 1610;	// Special entity for precache of assets
float CT_MINIONWIZARD = 1620;	// Minion Spawning version for Nour Boss
float CT_MONZOMBIE = 1700;		// Rotten flesh

float CT_MONIDCHTHON = 1900;	// ID Software Chthon
float CT_MONXXCHTHON = 1910;	// Mapper Custom Chthon
float CT_MONFIRETOP = 1920;		// Firetop Mountain Chthon
float CT_MONIDSHUB = 1950;		// ID Software Shub-Niggurath
float CT_MONXXSHUB = 1960;		// Mapper Custom Shub-Niggurath

// New (death) Knight series (sock/necros)
float CT_MONDGUARD = 2000;		// HD Knight (Guard)
float CT_MONDCROSS = 2010;		// HD Knight (Crossbow)
float CT_MONDFURY = 2020;		// HD Knight (Fury)
float CT_MONDBLOOD = 2030;		// HD Hell Knight (Blood)
float CT_MONDKNIGHT = 2040;		// HD Hell Knight (Death)
float CT_MONDPRINCE = 2050;		// HD Hell Knight (Prince)
float CT_MONDSERG = 2060;		// HD Hell Knight (Sergeant)
float CT_MONCOMM = 2070;		// HD Hell Knight (Commander)

// Lost Soul for AD (sock)
float CT_MONLOSTSOUL = 2100;	// The Original Doom flying lost soul
float CT_CACHELOSTSOUL = 2102;	// Special entity for precache of assets
float CT_MINIONLOSTSOUL = 2104;	// Minion Spawning version from skullwizard

// New (hunter) Ogre series (sock/necros)
float CT_MONHOGRE = 2150;		// HD Ogre (Chainsaw)
float CT_MONHOGREMAC = 2160;	// HD Ogre (Mace)
float CT_MONHOGREHAM = 2170;	// HD Ogre (Hammer)

// New Medieval series (lunaran)
float CT_MONZOMBIEK = 2200;		// Undead Knights
float CT_MONNOUR = 2210;		// Nour Boss (scragmother)

// Four Feathers MOD (Madfox)
float CT_MONDYONG = 2250;		// Mini Shub with extra tentacles

// New base monster series (Inspired by lunaran/Quoth/Zerstorer)
float CT_MONARMYROCKET = 2300;	// Army Soldier (Rocket)
float CT_MONARMYGRENADE = 2310;	// Army Soldier (Grenade)
float CT_MONARMYPLASMA = 2320;	// Army Soldier (Plasma)
float CT_MONDEFENDER = 2330;	// Enforcer SSG/GL (Defender)
float CT_MONELIMATOR = 2340;	// Enforcer Plasma (Eliminator)
float CT_MONDEFLECTOR = 2350;	// The Deflector (Plasma+Rocket)

// Nehara MOD (Mindcrime)
float CT_MONMANGLIOCH = 2400;	// Strange floating alien creature
float CT_MONBARON = 2410;		// Replaced with mon_justice instead

// RMQ MOD (Ijed/?)
float CT_MONBOIL = 2450;		// Slow moving zombie bomb
float CT_MONSEEKER = 2460;		// Robot replacement for Shambler

// New Monster series (Bal)
float CT_MONTURRETB = 2500;		// Large Surface mounted turret
float CT_MONSWEEPER = 2510;		// Knight size floating mine layer
float CT_MONMAMMOTH = 2520;		// Large two stage mini "the fridge" boss
float CT_MONTHUMPER = 2525;		// Regular version of mammoth boss
float CT_MONJUDGE = 2530;		// Large BOSS with glowing sword
float CT_MONJUSTICE = 2535;		// Large knight with flat sword
float CT_MONPSYDER = 2540;		// Large floating spawner mini boss
float CT_MONPHOBETOR = 2550;	// Final giant cloaked boss

// Hexen 2 series (Raven Software)
float CT_MONSPIDER = 2600;		// Spiders (brown/green versions)
float CT_CACHESPIDER = 2602;	// Special entity for precache of assets
float CT_MINIONSPIDER = 2604;	// Minion Spawning version from wraith
float CT_MONSTEELCLAW = 2605;	// Steel Claw (bleed attack spider)
float CT_MONSCORPION = 2610;	// Deadly Scorpion (HL Black Crab!)
float CT_CACHESCORPION = 2612;	// Special entity for precache of assets
float CT_MINIONSCORPION = 2614;	// Minion Spawning version from wraith
float CT_MONSKULLW = 2620;		// Creepy Skull Wizard (Teleport)
float CT_MONGARGOYLE = 2630;	// Flying Gargoyle (Flying fireball)
float CT_CACHEGARGOYLE = 2640;	// Special entity for precache of assets
float CT_MINIONGARGOYLE = 2650;	// Minion Spawning version from minotaur
float CT_MONGOLEM = 2660;		// Giant stone Golem (ground slam)
float CT_MONICEGOLEM = 2670;	// Giant Ice Golem (shards+ground slam)
float CT_MONICEGOLEMWAVE = 2675;// Wave targets for boss Ice Golem
float CT_MONMINOTAUR = 2680;	// Large tank like bull (magic/charge)
float CT_MONEIDOLON = 2690;		// Large demon boss Eidolon
float CT_MONEIDOLONWAVE = 2695;	// Wave targets for boss Eidolon

// Quake Expansion Packs (Rogue Software)
float CT_MONWRAITH = 2700;		// Undead wraith (Burning debuff)
float CT_MONMUMMY = 2710;		// Undead mummy (Poison debuff)
float CT_MONEEL = 2720;			// Plasma bolt spewing eel
float CT_MONINVSWORD = 2730;	// Ghostly invisible sword warrior

// Twisted Xmas MOD (Twisted Matrix)
float CT_MONELF = 2750;			// Little melee (knight)
float CT_MONRAINDEER = 2760;	// Rocket wielding stag (ogre)
float CT_MONSNOWMAN = 2770;		// Quick firing turret
float CT_MONSANTA = 2780;		// Good/bad santa (boss)

// Quoth MOD (Kell/Necros/Preach)
float CT_MONVORELING = 2800;	// Little baby vorelings! ahh so cute!
float CT_CACHEVORELING = 2802;	// Special entity for precache of assets
float CT_MINIONVORELING = 2804;	// Minion Spawning version from shalrath
float CT_MONSWAMPLING = 2810;	// Tiny swamplings! ahh so cute!
float CT_MONDGUARDQ = 2820;		// Special Hell Knight with fireball
float CT_MONDLORD = 2825;		// Special Hell Knight with shield
float CT_MONDROLE = 2830;		// Fast moving tentacle tank with rockets
float CT_MONGUG = 2840;			// Large hulking bile spewing nightmare
float CT_MONFREDDIE = 2850;		// Slow moving mechanical ogre mutant
float CT_MONGAUNT = 2860;		// Flying harpy thing with plasma bolts!
float CT_CACHEGAUNT = 2862;		// Special entity for precache of assets
float CT_MINIONGAUNT = 2864;	// Minion Spawning version for Judge Boss
float CT_MONJIM = 2870;			// Jim the flying robot of doom!
float CT_MONJIMROCKET = 2880;	// Jim has a rocket launcher!
float CT_MONSENTINEL = 2890;	// Fleshy robot Sentry

// Rubicon series (metlslime)
float CT_MONPYRO = 2900;		// Enforcer Flame (Pyro)
float CT_MONFUMIGATOR = 2910;	// Poison version of the Pyro
float CT_MONCENTURION = 2920;	// Enforcer hoverboard (Plasma)
float CT_MONFLOYD = 2930;		// Floyd Robot (Laser)

//----------------------------------------------------------------------
// 3000-3999 Reservered for other custom MODs
//----------------------------------------------------------------------

//----------------------------------------------------------------------
// Class Types for all projectiles in game (there is a lot!)
//----------------------------------------------------------------------
float CT_PROJ_TRACE = 4000;		// Tracer shot (true aim)
float CT_PROJ_TRACEPART = 4010;	// Tracer shot (extra particles)
float CT_PROJ_SHELLC = 4020;	// Shellcase projectile

float CT_PROJ_SG = 4100;		// SG projectile
float CT_PROJ_SSG = 4110;		// SSG projectile

float CT_PROJ_NG = 4200;		// NG projectile
float CT_PROJ_SNG = 4210;		// SNG projectile
float CT_PROJ_MONNG = 4220;		// NG monster projectile (glowing red)
float CT_PROJ_REFNG = 4230;		// Reflected (glowing red)
float CT_PROJ_HKN = 4240;		// Hell Knight Spike

float CT_PROJ_WBONE = 4300;		// Wraith Bone Bolt (nail)
float CT_PROJ_GROCK = 4310;		// Golem rock debris (pebble)
float CT_PROJ_SCORP = 4320;		// Scorpion Tail (nail)
float CT_PROJ_DLORD = 4330;		// Death Lord spike ball
float CT_PROJ_SANTA = 4340;		// Santa Snowball shotgun!

float CT_PROJ_WIZ = 4400;		// Wizard Spit
float CT_PROJ_NOUR1 = 4410;		// Nour Spit 
float CT_PROJ_MPOISON = 4420;	// Minotaur Poison Bolt (nail)
float CT_PROJ_MBLOOD = 4430;	// Alternative Minotaur Bolt (nail)
float CT_PROJ_FURY2 = 4440;		// Fury Spit with grenade trail

float CT_PROJ_PLASMA = 4500;	// Generic Plasma (blue laser version)
float CT_PROJ_FLAME = 4510;		// Burning (sprite based) flame

float CT_PROJ_LASER = 4600;		// Enforcer/Traps/Bob Laser
float CT_PROJ_RICLASER = 4610;	// Ricochet ( attack_ricochet = bounce qty )

float CT_PROJ_WBOLT = 4700;		// Fire Wraith Hitscan Bolt 
float CT_PROJ_BOLT1 = 4710;		// Crossbow Knight Bolt +hknight trail
float CT_PROJ_BLBOLT = 4720;	// Boglord fast bolt (green)
float CT_PROJ_BLBOLT2 = 4730;	// Boglord fast bolt (red)

// Grenade projectiles
float CT_PROJ_GL = 5000;		// Grenade projectile
float CT_PROJ_GLMON = 5010;		// Monster grenades
float CT_PROJ_MEGG = 5020;		// Minion Egg (grenade arc+bounce)
float CT_PROJ_CHTHON2 = 5030;	// Chthon Frenzy (grenade arc)
float CT_PROJ_SHUB2 = 5040;		// Shub Frenzy (grenade arc)
float CT_PROJ_NOUR2 = 5050;		// Nour Spit bomb! (grenade arc+bounce)
float CT_PROJ_FLESH = 5060;		// Zombie Flesh (grenade arc)
float CT_PROJ_SPID = 5070;		// Spider Spit (grenade arc)
float CT_PROJ_VORE = 5080;		// Voreling Spit (grenade arc)
float CT_PROJ_SWAMP = 5090;		// Swampling Spit (grenade arc)
float CT_PROJ_ELF = 5100;		// Elf snowball (grenade arc)

// Hazard / Grenade projectiles
float CT_PROJ_SWEEPER2 = 5300;	// Sweeper (blue/red+grenade arc)
float CT_PROJ_DPRINCE2 = 5310;	// Dark prince (blue/red+grenade arc)

// Rockets (Direct / Steered)
float CT_PROJ_ROCKET = 5400;	// Rocket projectile
float CT_PROJ_ARMY = 5410;		// Army rocket
float CT_PROJ_JIM2 = 5420;		// Jim robot rocket
float CT_PROJ_SKULLW = 5430;	// Skull Wizard Skull (rocket)
float CT_PROJ_SEEKER = 5440;	// Seeker robot rocket
float CT_PROJ_RAINDEER = 5450;	// Raindeer rocket
float CT_PROJ_DGUARDQ = 5460;	// Death Guard (Quoth) fireball
float CT_PROJ_DEFLECT1 = 5470;	// The Deflector (rocket)
float CT_PROJ_SWEEP1 = 5480;	// Sweeper mine/rocket

float CT_PROJ_GARG = 5500;		// Gargoyle fireball
float CT_PROJ_DROLE = 5510;		// Drole fireball

float CT_PROJ_FURY1 = 5600;		// Fury Knight spike ball +rocket trail
float CT_PROJ_DPRINCE1 = 5610;	// Dark Prince (spike ball)
float CT_PROJ_BARON = 5620;		// The Baron spike ball
float CT_PROJ_JUDGER = 5630;	// RED judicator arrows
float CT_PROJ_JUDGEB = 5632;	// BLUE judicator arrows
float CT_PROJ_JUSTICER = 5634;	// RED justice arrows

float CT_PROJ_LAVA = 5800;		// Chthon Lavaball
float CT_PROJ_CHTHON = 5810;	// Custom Chthon Lava/Slime ball
float CT_PROJ_FIRETOP = 5820;	// Chthon Lavaball (less splash dmg)
float CT_PROJ_EIDO1 = 5830;		// Eidolon boulder
float CT_PROJ_ICEG1 = 5840;		// Ice Golem ice shard
float CT_PROJ_BLORD = 5850;		// Bog Lord Green Slime bomb
float CT_PROJ_BLORD2 = 5860;	// Bog Lord Red Slime bomb
float CT_PROJ_MAMMOTH = 5870;	// Mammoth rocket

float CT_PROJ_SHAL = 5900;		// Shalrath spike ball +purple trail
float CT_PROJ_SERG = 5910;		// Death Sergeant spike ball +hknight trail
float CT_PROJ_SHUB1 = 5920;		// Custom Shub homing spike attack

//----------------------------------------------------------------------
float CT_AXE = 6000;			// Quak Axe
float CT_UPGRADE_AXE = 6002;	// Shadow Axe
float CT_UPGRADE_GHOOK = 6004;	// Grapple Hook
float CT_SHOTGUN = 6010;		// Shotgun
float CT_SUPER_SHOTGUN = 6020;	// Super Shotgun
float CT_UPGRADE_SSG = 6030;	// The Widowmaker Shotgun
float CT_NAILGUN = 6040;		// Nailgun
float CT_SUPER_NAILGUN = 6050;	// Super Nailgun
float CT_GRENADE_LAUNCHER = 6060;// Grenade Launcher
float CT_ROCKET_LAUNCHER = 6070;// Rocket Launcher
float CT_LIGHTNING = 6080;		// Lightning Gun
float CT_UPGRADE_LG = 6090;		// Plasma Gun

float CT_ARTSUIT = 6200;		// Environment Suit
float CT_ARTPENT = 6210;		// Pentagram - Invulnerability
float CT_ARTINVS = 6220;		// Ring of Shadows
float CT_ARTQUAD = 6230;		// Quad Damage
float CT_ARTSHARP = 6240;		// Sharp Shooter
float CT_ARTPIERCE = 6250;		// Nail Piercer
float CT_ARTAIRTANK = 6260;		// Air Tank
float CT_ARTLAVASHIELD = 6270;	// Lava Shield
float CT_ARTBLASTBELT = 6280;	// Blast Belt
float CT_ARTJUMPBOOTS = 6290;	// Jump Boots

float CT_ARTTOME = 6400;		// Tome of Power
float CT_PROGSPAWN = 6410;		// Progression spawn

float CT_SILVERKEY = 6500;		// Silver key
float CT_GOLDKEY = 6510;		// Gold key
float CT_CUSTOMKEY = 6520;		// Custom key
float CT_CUSTOMITEM = 6530;		// Custom pickup item
float CT_RUNEKEY = 6540;		// End of Level rune keys 1-4

float CT_SPIKESHOOTER = 6600;	// Trap SPIKE shooter
float CT_GRENADESHOOTER = 6610;	// Trap GRENADE shooter
float CT_ROCKETSHOOTER = 6620;	// Trap ROCKET shooter
float CT_LIGHTSHOOTER = 6630;	// Trap LIGHTNING shooter
float CT_GASSHOOTER = 6640;		// Trap GAS shooter
float CT_EXPLO_BOX = 6650;		// Exploding box
float CT_PENDULUM = 6660;		// Swing Pendulum
float CT_SAWBLADE = 6670;		// Saw Blade

float CT_FIREBALL = 6700;		// Misc Fireball
float CT_MISCSPARK = 6710;		// Misc Spark
float CT_MISCSHAKE = 6720;		// Misc Shake of screen/player
float CT_MISCMARSH = 6730;		// Misc Marsh lights (Quoth)
float CT_MISCDRIP = 6740;		// Misc Drip (water)
float CT_BUBBLE = 6750;			// Bubbles
float CT_MISCMODEL = 6760;		// Misc Model
float CT_MISCSMOKE = 6770;		// Misc Smoke
float CT_MISCGIBF = 6780;		// Misc Gib fountain

//----------------------------------------------------------------------
float CT_AMMODROPPACK = 6800;	// Dropped Ammo Backpacks from monsters
float CT_AMMOITEMPACK = 6810;	// Ammo Backpack for players
float CT_AMMOSHELLS = 6820;		// Different ammo types
float CT_AMMONAILS = 6830;
float CT_AMMOROCKETS = 6840;
float CT_AMMOCELLS = 6850;

float CT_HEALDROPPACK = 6900;	// Dropped Health pack from monsters
float CT_HEALVIAL = 6910;		//  5 health pack
float CT_HEALROT = 6920;		// 15 health pack
float CT_HEALNORM = 6930;		// 25 health pack
float CT_HEALMEGA = 6940;		// 100 Mega health

float CT_ARMOR1 = 6950;			// Green armour
float CT_ARMOR2 = 6960;			// Yellow armour
float CT_ARMORINV = 6970;		// Red armour
float CT_ARMORITEMPACK = 6980;	// Armour shard system
float ARMOR_BLUE = 2;			// Display a blue armour
float BACKARMGRN = 15;			// Green shards
float BACKARMYEL = 30;			// Yellow shards
float BACKARMRED = 45;			// Red shards 

//----------------------------------------------------------------------
float CT_FUNCDOOR = 7000;		// Func door
float CT_FUNCDOORTRIG = 7010;	// Generated touch trigger around door
float CT_FUNCSECDOOR = 7020;	// Func SECRET door
float CT_FUNCBUTTON = 7030;		// Func button
float CT_FUNCPSWITCH = 7040;	// Func Pressure Switch
float CT_FUNCINSVOLUME = 7050;	// Func to detect inside volume
float CT_FUNCBOB = 7060;		// Func bobbing bmodels
float CT_FUNCSHADOW = 7070;		// Func shadows
float CT_FUNCTRAIN = 7080;		// Func train
float CT_FUNCWALL = 7090;		// Func wall
float CT_FUNCTOGWALL = 7100;	// Func wall (toggle)
float CT_FUNCILLUSIONARY = 7110;// Func illusionary
float CT_FUNCLASER = 7120;		// Func laser
float CT_FUNCSKILL = 7130;		// Func_skill pillars
float CT_FUNCCHAOS = 7135;		// Func_chaos pillar
float CT_FUNCHOOK = 7140;		// Func Grapple Hook point

float CT_FUNCBREAK = 7500;		// Func breakable (parent)
float CT_FUNCBREAKWALL = 7510;	// Bmodel to activate after breakage
float CT_FUNCBREAKMDL = 7520;	// Func breakable (model)
float CT_FUNCBREAKSPN = 7530;	// Func breakable (spawner)
float CT_FUNCBREAKOBJ = 7540;	// Func breakable (rubble))
float CT_FUNCPUSHABLE = 7550;	// Func pushable

float CT_ROTATEORG = 7600;		// Origin point for rotation
float CT_ROTATEPATH = 7610;		// Rotating entity path_corner
float CT_ROTATEOBJ = 7620;		// Rotating bmodel

float CT_ROTATEENT = 7700;		// Rotating entity (continous)
float CT_ROTATEMOVE = 7710;		// Rotating clip brushes!
float CT_ROTATETRAIN = 7720;	// Rotating func_train (path corners)
float CT_ROTATEDOOR = 7730;		// Rotating func_door (dual-state)

float CT_FUNCEPISODEGATE = 7800;// Episode gates (not used anymore)
float CT_FUNCBOSSGATE = 7810;	// Final boss gate (not used anymore)
float CT_FUNCPLAT = 7820;		// Old platform system
float CT_FUNCLIFT = 7830;		// New platform system

//----------------------------------------------------------------------
float CT_TRIGONCE = 8000;		// Once, volume
float CT_TRIGMULTI = 8010;		// Multiple, volume
float CT_TRIGRELAY = 8020;		// Relay, point entity no touch
float CT_TRIGRELAYDELAY = 8030;	// Relay, used in SUBS for delays
float CT_TRIGDOORSTATE = 8040;	// Set func_door to specific state
float CT_TRIGCOUNT = 8050;		// Count, point entity no touch
float CT_TRIGTIMER = 8060;		// Timer, point entity no touch
float CR_TRIGENG = 8070;		// Engine, point entity no touch
float CT_TRIGPLAYPART = 8080;	// Player particles, point entity no touch

float CT_TRIGRUNES = 8100;		// Rune, volume
float CT_TRIGSKILLS = 8110;		// Skill, volume
float CT_TRIGTELEPORT = 8120;	// Trigger teleport

float CT_MISCTELEPORT = 8200;	// info_teleport_destination
float CT_MISCTELCAMERA = 8210;	// info_camera_destination
float CT_MISCTELINSTANT = 8220;	// info_teleportinstant_dest (volume)
float CT_SKULLTELEPORT = 8230;	// info_skullwiz_destination
float CT_TRIGEXPLODE = 8240;	// Trigger sprite explosion

float CT_TRIGSECRET = 8300;		// Secret, volume
float CT_TRIGLADDER = 8310;		// Ladder, volume
float CT_TRIGLIGHTSTYLE = 8320;	// Lightstyle, volume
float CT_TRIGFOG = 8330;		// Fog, volume
float CT_TRIGSKYFOG = 8340;		// Sky Fog, volume
float CT_TRIGGRAVITY = 8350;	// Gravity, volume
float CR_TRIGFALLSPEED = 8360;	// Player fall speed, volume
float CR_TRIGMAXHP = 8370;		// Player max HP, volume

float CT_TRIGHURT = 8400;		// Hurt, volume
float CT_TRIGHEAL = 8410;		// Heal, volume
float CT_TRIGGIVEITEM = 8420;	// Give items, volume
float CT_TRIGTAKEART = 8430;	// Take artifacts, volume
float CT_TRIGTSOUND = 8440;		// Touch sounds, volume
float CT_TRIGPUSH = 8450;		// Push, volume

float CT_TRIGVELOCITY = 8500;	// Velocity, volume
float CT_TRIGCONVEYOR = 8510;	// Conveyor, volume
float CT_TRIGLEVEL = 8520;		// Change level
float CT_TRIGSKYBOX = 8530;		// Change/Load Skybox console command
float CT_TRIGITEMFLAG = 8540;	// Change item spawnflags
float CT_TRIGCLMSG = 8550;		// Message to all clients
float CT_TRIGCDTRACK = 8560;	// Change CD track

float CT_TRIGMONJUMP = 9000;	// Triger monster to jump forward
float CT_TRIGNOJUMP = 9010;		// Trigger monster to NOT jump!
float CT_TRIGMONDROP = 9020;	// Trigger monster to fall naturally
float CT_TRIGMONTURRET = 9030;	// Trigger monster to turn into turret
float CT_TRIGMONMOVE = 9040;	// Trigger monster movement state
float CT_TRIGMONATTACK = 9050;	// Trigger monster attack state
float CT_TRIGMONBREAK = 9060;	// Trigger monster/breakable together
float CT_TRIGMONKILL = 9070;	// Trigger monster to be killed
float CT_TRIGMONATT = 9080;		// Trigger monster to attack something

float CT_TRIGVOID = 9999;		// Skybox garbage collector!
