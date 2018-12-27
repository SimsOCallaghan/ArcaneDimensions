# ArcaneDimensions
Quake 1 MOD code progs
==============================================================================
(Title) Arcane Dimensions MOD for Quake 1
(Code Lead) Simon OCallaghan
(Additional Support) Corey Jones, Matthew Breit, Andrew Denner, Bengt Jardrup, John Fitzgibbons, Louis Manning

Here is a record of all the changes to the MOD (including version numbers)
==============================================================================

v1.70 DevKit (ad_devkit1_7 release)                                      
------------------------------------------------------------------------------
* Fixed zombies direct hit by rockets resetting the splashdamage to zero

v1.70 Patch 1 Notes (ad_v1_70p1 release)                                      
------------------------------------------------------------------------------
* Fixed logic problem with trigger_count and message/message strings
* Fixed trigger_count message problem in ad_ac and ad_sepulcher maps
* Fixed eddict crash in ad_sepulcher by reducing particle setups
* Fixed spelling mistake in ad_chapters for ad_ac portal entrance
* Added missing features (triggers/bbox/explosions) to func_pushable
* Added func_pressureswitch bmodel entity for extra puzzle logic
* Added func_insidevolume to detect player, monster, item & pushables
* Added trigger_doorstate to force func_door entities to open/close state
* Removed invulnerability frames from zombie/zombiek when using shadow axe
* Changed the behaviour of zombie/zombiek to be easier for knockdowns
* Added death message for Gargoyle minions (spawned from minotaurs)
* Moved all player death messages to relevant monster QC files instead
* Fixed brkmondmg entity key on func_breakables to work with projectiles
* Fixed misc_demon not resetting gib model names when switching gib models
* Removed info_stuffcmd as it was open to abuse from malicious mappers
* Added trigger_cdtrack to allow for custom music changes after map load
* Added trigger_skybox to allow for different skybox setups after map load
* Added client check for changed music/skybox to load/quickload functions
* Fixed respawn_time on all items to not instantly spawn, minimum is 1s
* Fixed frozen bug crash for gargoyle/gaunt when waking up from perch/statue
* Fixed monster_firetopboss to cope with skill 3 shambler group attacks!
* Fixed sighttarget to check for health/damage before creating a sight entity
* Added trigger entity state reset to func_button (will override wait value)
* Added Impulse 170 to toggle monster body fade/removal when playing a map
* Fixed player weapon animation issue with idle/fire states being wrong
* Updated DEF file for GTK/Radiant editors with new patch features
* Added FGD file for Jack/Trenchbroom editors by Dan "twitchy" Ellis
* Added V/G models for players weapons from Stas "dwere" Kuznetsov

v1.70 Notes (ad_v1_70final release)
------------------------------------------------------------------------------
* Added Arcane Key Inventory centerprint message (press 'i' key to access)
* Added centerprint message when picking up arcane keys (only happens once)
* Removed 'always rotate items' option from temp1 variable in quake.rc
* Changed temp1 variable in quake.rc 512 = Alway use sprite particles
* Added trigger_giveitems to give items to the player without picking them up
* Added sounds=4 to all items to prevent a pickup sound from playing
* Added ability to kill crucified zombies, counts towards kill counter
* Added liquidblock entity key to monsters, blocks sightline through liquids
* Added monster_eel with high damage (range) plasma attack (QC was in 1.6)
* Added monster_sentinel, _death_guard, _death_lord (Just QC)
* Added twisted xmas monster_elf, _raindeer, _snowman, _santa (Just QC)
* Added Light/Plasma Reflection effect (used for boglord, nour, deathlord)
* Added Nail Reflection effect (used for most stone statues, stone bosses)
* Changed player projectile size for nails/rockets back to ID default
* Changed player projectile size for plasma/shells to larger collision
* Removed extra damage (+4 per shot) from projectile shotguns (SG/SSG/WM)
* Changed plasma projectile function from proj_type to self classtype instead
* Changed all rocket projectile types and monster grenades to gib zombies
* Added spawnflag to misc_smoke to only draw smoke particles for DP/FTE engines
* Fixed inconsistency with the poisonous flag on all monsters (new proj/fx)
* Added new poison skin option for monster_wizard including main/head/gibs 
* Added new poison skin option for monster_zombiek including main/head/sword
* Added new poison skin option for monster_dcrossbow including main/head
* Added nail attack (spawnflag=2) to monster_ogre, attack_count=5(def)
* Fixed monster_eel falling to the ground (was floating) after being killed
* Fixed monster_zombie throwing flesh attack positions to match animation
* Merged monster_mummy into monster_zombie setup as it has minimal difference
* Changed monster_zombie crucified so can be gibbed/destroyed by grenades
* Fixed problem with the minion_maxamount entity key for Wraith Scorpion Spawners
* Fixed problem with exact_skin for health items (can override type properly)
* Removed eliminator & shambler attack range when using attack_sniper entity key
* Added check to all bmodels functions to make sure a model key is defined
* Added silent additional sound option (sounds=4) to misc_builtineffects 
* Added sprite_particles to worldspawn to force sprites (builtin's are excluded)
* Fixed velocity direction for DP particles (eg electric effect) was reversed
* Fixed humanoid torso gib appearing for misc bodies, checks for blockudeath
* Added spawnflags=4 to misc_model entities to work with moving bmodels
* Changed monster_shalrath homing missile speed to be slower (hard=300>250)
* Changed monster_drole to NOT track the player for range attack 
* Fixed monster_gaunt not falling to ground on death (perch only affected)
* Fixed monster_shambler lightning model being moved from 0,0,0 before attack
* Fixed monster_shambler lightning model not being reset properly when finished
* Changed monster_shambler to overhead smash zombies when infighting
* Changed monster_nour default to no boss wave/minion setup (spawnflag 2=boss mode)
* Added delaymonstercount to all monsters, will update count on spawn only
* Added func_pushable with 5 sound types, entity states and breakable support
* Fixed breakable/pushable to resist monster damage from all projectile types
* Added map variable system with new trigger entities (132 binary variables)
* Fixed precache problem with ambient_custom_x entities and save/load games
* Added coop impulse commands for respawning weapons, health, ammo & powerups

v1.60 Notes (ad_sepulcher release)
------------------------------------------------------------------------------
* Restored monster_boil and monster_boglord assets and code
* Added monster_swampling (poisonous voreling, small+large)
* Added monster_boglord evil twin (red skin/projectiles and +HP)
* Added no_sgprojectile to worldspawn to override MOD default
* Added no_surfacecheck to worldspawn to override DP extension
* Changed all blood particles in effectinfo.txt to produce less
* Removed skycontent check for gibs, really bad slowdowns for QSS
* Changed monster_ogre_fishing to be 100% resistant to rockets
* Added lighttarget key for light entities to be mdl switchable
* Fixed misc_bob spawn delay (=-1) to be an actual random value
* Added aflag to zombies/knight zombies for onspawn fall direction
* Fixed bounding box error for zombie/knights getting up off floor
* Added infighting multiplier to monster_boil to damage other monsters
* Renamed trigger_nomonjump to trigger_monsternojump to be consistent
* Added trigger_monsterdrop to naturally drop monsters from height
* Allowed entity key idletimer to be set for first time after spawn
* Added item_backpack_armour entity, a backpack armour shard (def=15)
* Matched particle effect colour of backpack to exactskin value
* Allowed item_backpack to have types of armor (grn, yel, red)
* Updated particle effects for backpacks to match colour of skin
* Added devmode only functionality to trigger_once & trigger_multiple
* Added shambler infighting attack style to use smash on enemy low HP
* Fixed bug with gibondeath monster not being less zero when dying
* Fixed bug with many of the gibs being spawned below monster bbox
* Added switchoverride to all monsters to adjust infighting switch timer
* Fixed trigger function on client cameras not detecting empty string
* Added trigger_engine entity to cope with unique engine features
* Added static option to func_illusionary, light_candle & misc_model
* Added tetherpause to tether system, % to stop attacking when no sight
* Added brkdelaydamage to func_breakable, delay to damage functions
* Fixed monster_jim and turret mode to not use velocity movement
* Fixed monster_jim projectile sightchecks to use correct enemy target
* Added support for changing particle system setup if quickloading
* Added special ambient sounds (chime, rain, rumble, water, wind, wood)
* Updated trigger_count spawnflag to allow for displaying exact count no.
* Added trigger_count to start disabled, requires trigger_entity state
* Removed player autoaim server flag (check/set console variable)
* Merged server flag for AI path arrows into a dev helpers instead
* Added impulse 160 (Toggle Weather) works for enhanced engines only
* Added server flag for Advanced Engine Weather Systems (DP/FTE/QSS)
* Updated func_door to allow for custom silver/gold lock messages
* Fixed bug with func_door and custom keys overriding silver/gold options
* Added jump_flag to any monster to block the ability to use jump attack
* Updated trigger_hurt falling option to affect monsters and players
* Added attack_instant entity key for monsters to instantly wake+attack
* Added attack_sniper entity key for monsters to wakeup at any distance
* Added sniper mode (no attack long range check) for crossbow knights
* Added spawnnotelefrag for all monsters to prevent telefrags on spawn
* Added spawnnosight for all monsters to spawn out of sight of players
* Added custom pickup sound to item_backpack and item_backpack_armour
* Fixed v_offset problem with onceiling spiders, swampling and vorelings
* Fixed nomonstercount to update monster totals if they die or are killed
* Fixed defender, army_grenade & ogres to detect grenadebounce flag on enemy
* Added wakeup range to misc_drip as they always draw regardless of portals
* Fixed rounding error in lftos function for creating long floats
* Fixed trigger_fog speed/wait defaults not being setup correctly

v1.50 Notes (ad_v1_50final release)
------------------------------------------------------------------------------
* Added corner_speed override for updates to path_corner entities
* Added func_button spawnflag option to start in disabled entity state
* Added separate impulse/server command for projectile shotgun casing
* Added trigger_clientmsg to display messages regardless of trigger source
* Added bouncegrenade entity key allow bounce grenades off monster bodies
* Changed rocket/cell resistance visual language to no blood for 100% resist
* Added monster_seeker a base version of the shambler with laser/rocket attacks
* Added wood/glass/metal gib impact sounds, updated gib touch impact system
* Added extra text body strings to misc_textbook to fix Quark editor issues
* Added misc_dknight for dead death knight posing and shadow axing
* Added monster_ogre_fishing a passive monster that likes to fish a lot!
* Random lying down rotation for zombie+knights with angle key=0 or <1
* Added new poisonous setup to demon/shambler with debuff and different skins
* Added new animated lightning projectile to shambler (designed for new model)
* Added trigger event (target2) to monster_seeker shield turning off
* Added optional falling damage to trigger_hurt (velocity speed def=300)
* Updated g_rock.mdl and g_rock2.mdl weapon G model pickups to HD version
* Changed all monster_seeker gibs to models (was using metal breakables)
* Changed coop monster combat & classic infighting to prevent target deadlock
* Changed coop dropped backpacks to never despawn (default was 120s)
* Changed coop player backpacks to drop all weapons, ammo, keys, armour
* Changed coop centerprint messages from triggers to display on all clients
* Changed coop weapon pickups to respawn after 5s and give weapon ammo pickup qty
* Changed coop weapon pickups to only give extra ammo if < 50% of max ammo type
* Changed coop weapons/keys to never respawn if entity key respawn_time < 0
* Changed coop weapons to always fire any triggers on them once
* Changed coop spawn points to work with entity state system, can be switched on/off
* Changed coop spawn points to always trigger target(s) once when used
* Changed coop spawn points not to include player start if coop points exist
* Added Impulse 150, Coop players can drop artifacts in backpacks (def=off)
* Added Impulse 155, all ammo boxes will respawn in coop mode (def=off)
* Added coop colour (pink) to debug diamond system to show cooponly entities
* Added coop console warning message for items with unreliable triggers
* Added cooponly/nightmare entity key to items, monsters, triggers & func entities
* Updated cooponly entity key, -1 = will not spawn in coop mode (all items)
* Added monster_freddie a mutant ogre with blade and nail/laser gun
* Added wakeup trigger to monster_ogre_fishing for special events
* Added trigger_nomonjump to stop/delay jumping monsters from jumpin!
* Added damage multiplier option to func_breakable for monster damage
* Added new entity key 'bodystatic' to stop skull wizards from teleporting 
* Added monster tether system to allowing guarding of map areas
* Added target2 to func_rotate_door to solve lighting issues
* Added silent sound option to func_rotate_door to reduce sound distortions
* Added storybook controller and text book chapter system 
* Added support for QuakeSpasm-Spike engine and weather effects
* Updated misc_smoke DP particle effects to use custom velocity
* Added support for spawning volumes to the DP forcefield particles
* Updated misc_fireball with slime green option for slimey pits
* Changed monster_drole to no longer have shell/shotgun resistance
* Changed stone knight/hellk from 80% to 50% nail resistance
* Changed Hammer Ogre to be more aggressive with attacks and resist pain
* Changed Shamblers to be lightning turrets on Nightmare (ID behaviour)
* Added monster_chthon, _shub and _shubupsd customizable ID bosses
* Added trigger_touchsound for fake water touch sounds and movement
* Added yaw_speed variable to trigger_heal/_hurt to change bubble speed
* Fixed mouse scroll wheel affecting footstep sounds for player
* Fixed telefrag problem, all bosses are immune, except shub!
* Changed player footstep sound to be quieter and more random
* Added red spark colour option (spawnflag) to misc_spark entity
* Fixed effects flag on monster/items is saved and restored when active
* Fixed hammer/golem impact attack to be limited +/- 128 units vertically
* Added trigger_fog functionality to info intermission camera system
* Added start disable function to func_plat (spawnflags=32)
* Added new entity state AFRAME for animated textures (func_wall only)

v1.49 Notes
------------------------------------------------------------------------------
* Changed projectile meat to use same parameter format as projectile smoke
* Lowered monster_boil radius damage from 100 to 60 (more forgiving)
* Added particle effects to gibs, only works with special type 1
* Added entity boss flag and fixed missing client death messages
* Fixed monster targets after combat, stop them wandering towards 0,0,0
* Added missing attack offset vector for centurion, gargoyle, gaunt and jim
* Changed many monsters to use facing vector instead of center for sight checks
* Changed monster_dsergeant to fire homing missiles more and be aggressive
* Changed homing missiles to allow impact on owner (no owner dmg, just splash)
* Added monster_boglord a special event in the dungeon for ad_sepulcher
* Fixed trigger_monsterjump only working for specific monster types
* Added blood and slime to misc_drips, selected by different spawnflags
* Added debug diamonds; blue=delay spawn, green=no monster count, red=nightmare
* Changed monster_voreling to jump further at the player (400 -> 500)
* Added poison debuff attack to poisonous spider (Green large one)
* Added poisonous gibs, blood and explosive attack damage to monster_boil
* Changed poisonous monsters to bleed green blood particles instead of red
* Fixed problem with misc_model not randomly selecting from a range correctly
* Added projectile dust models to trigger_explode (directional velocity)
* Added custom particle emitter colours for custom keys using message2
* Added second (randomly picked) sound option to ambient_custom_sound
* Added triggered targets to ambient_custom_sound each time sound is played
* Added option to ambient_custom_sound to not silence sound if switching off
* Changed many monsters to be locked in pain animations if using shadow axe

v1.48 Notes
------------------------------------------------------------------------------
* Fixed func_secretdoor def angles being changed from '0 0 0' to '0 90 0'
* Updated mon_shalrath skins (1=regular,2=green,3=purple) to be more unique
* Added new skin (1=blue, 2=yellow) to misc_fixture for fifth map
* Updated documentation about monster bodyflrcheck and bodyfadeaway keys
* worldspawn replace_hknight and replace_ogre keys no longer valid
* Added monster_hell_pointknight special event for noel/andrey map
* Replaced Shambler head and gib models with new versions (+blood trails)
* Fixed misc_particle being able to switch state before setup finished
* Fixed trap_lightningshooter to play hit sound every 0.6s instead of 0.1s
* Added random XYZ wobble to trap_lightningshooter source and target
* Changed trap_lightningshooter to not spawn if target is missing (required)
* Added blue particle effect to trap_lightningshooter on impact (spawnflag)
* Added dust/smoke velocity impact to trap_lightningshooter (spawnflag)
* Added error message to monsters, cannot delay spawn without targetname!
* Added new entity key nospawndamage for monsters to prevent telefrag damage
* Added telefrag death checks for breakables exclusions (noshoot, nomonster)
* Added frame_override key to func_door for alternative texture switching
* Added jim rocket type to trap_rocketshooter (lower damage player rocket)
* Fixed sprite explosion sound being played on previous temp sprite intead
* Added spark once (automatic switch off) to misc_spark (wait=-1)
* Added random rotation of spark burst on Y axis to misc_spark (angle=-1)
* Fixed gargoyle not using spawnangry, angrytarget or pathing when waking up
* Changed all lightning damage (except player) checks to new function
* Changed trigger_fog wait (re-trigger) cannot be less than speed (fade time)
* Added custom sound (noise key) option to trigger_push entity
* Added new gib projectile move style MON_GIBEXPLOSION for more impact
* Changed gib spawn origin formula to cope with larger bounding boxes
* Boss fights Nour/Eidolon reset health each wave to prevent excessive dmg
* Added Eidolon boss fight with multiple waves and minion support (ad_stone)
* Added brktrignoplayer to func_breakable, prevents damage from players
* Added spawnflags = 16 to trigger_monsterkill to use death function instead
* Added check for death function to trigger_monsterkill before using it
* Changed all stone statues to check health before using waking up trigger
* Added th_die functionality to all stone statues for trigger_monsterkill
* Added 10 extra scale frames to misc_heart.mdl and misc_skull.mdl
* Added misc_doomhelm.mdl for super secret locations (3 poses & 3 skins)
* Added mon_fish.mdl from rmq/rrp with squashed head fix and smaller version
* Added mon_boil monster, proximity mine with tarbaby like explosive damage

v1.47 Notes
------------------------------------------------------------------------------
* Fixed old ID particle explosion for rockets (was broken based on type)
* Changed func_buttons are moved to their finished position when disabled
* Updated Super Shotgun G model with new version by Dwere (kept ID V model)
* Added new particle effect Implosion for monsters and items (code function)
* Finished Nour boss fight with multiple waves and minion support (ad_azad)
* Added trigger event on dead bodies which are gibbed via the shadow axe
* Fixed range attack for green spider with proper elevation tracking
* Added large purple voreling with range attack (same as green spider)
* Fixed path_corner targetback override key (was searching wrong field)
* Added delay to radius explosion on breakables to prevent endless loops
* Skull Wizards have gib state (-40 HP) they will explode into dust!

v1.46 Notes
------------------------------------------------------------------------------
* Fixed Shambler lightning bolt will damage breakables if LOS blocked
* Fixed enemy target problems with Firetop Mountain Chthon
* Added particle effect to base of Firetop Chthon body
* Changed particle_debuff to allow for custom volume range
* Added trigger_monsterattack entity to create infighting sequences
* Added missing trigger point entities to ad_quake.fgd
* Added Cameramode and solid options to info_intermission entity
* Fixed wetsuit artifact not being reset when intermission active
* Fixed func_plat/func_door entity state off not stopping movement sounds
* Changed zombie knight sight sound from zombie idle to red knight instead
* Changed all sprite explosion files and setup equivalent DP versions
* Added DP poison and stone blood decals, re-arranged particlefont.tga file
* Added more DP specific particle effects especially for poison attacks
* Fixed DP blood trails only affecting blood gib types (not stone/poison)
* Added damage ability to gib model touch function (new code parameters)
* Changed trigger_explode to cope with more types (fire/plasma/poison)
* Changed Lost Souls to have variable (small/med/large) sized explosion death
* Changed Tarbaby explosive death damage can be changed with death_dmg key
* Added Tarbaby with poison attack instead of direct damage, has 8 new skins
* Added new monster_fumigator, which is a poisonous pyro who loves slime!
* Added respawn particle effect to items which start off (reqs respawn flag)
* Fixed instant respawn items (respawn_time=-1) to check respawn counters
* Updated the MOD GFX directory with replacement LMP files (esp help)
* Added misc_player for dead marine posing and axing, extra 8 skins + blood

v1.45 Notes
------------------------------------------------------------------------------
* Added entity state spawn value to func_buttons (on/off/reset) 
* func_doorsecret can move up/down for second phase (angle=-1/-2)
* Moved external bmodels from maps to subdirectory (bmodels)

v1.44 Notes
------------------------------------------------------------------------------
* Added global/individual bodyfadeaway function for all monsters
* Created global floor check function for monsters, gibs and breakables
* Added floor check for all items with new entity key (simulate gravity)
* Added global variable for monsters using floor check function
* Changed gibs/head, breakable models to always use the floor check function
* Changed gibs to keep touch function alive for additional sound triggers
* Added new artifact wetsuit, player can breath underwater for 5mins/300secs
* Fixed wetsuit giving env suit screen tint and not resetting afterward
* Fixed frame_box entity key for rockets/plasma -1=random, 0-7=exact
* Placeholder menu graphic images (will change over coming weeks)
* Added new impulse command, 145 cycles through intermission cameras

v1.43 Notes
------------------------------------------------------------------------------
* Fixed gravity variable on worldspawn to be set correctly
* Fixed nightmare skill allowing zombies to be gibbed
* Updated shambler to new HD shambler model + head gib
* Added forcefield particle effect to func_laser (new variables)
* Added bmodel source detection for particle emitters
* Added worldtype override to keys and doors messages
* Added timed switch off mode to all trap_shooter entities
* Added timed switch off mode to misc_particle_burst entity
* Fixed func_laser to create a sound emitter for on/off sounds
* Changed Gaunt to fall properly after death (like wizard body)
* Changed standing monsters to fall if floor surface is changed
* Monster dead bodies, heads and gibs can fall if floor surface is changed
* Falling dead monster bodies interact with _void,_hurt,_push and sawblade
* Backpack items (temporary and placed) can fall if floor changes
* Fixed pendulum default damage to 5, use -1 for no damage option
* Fixed voidsmoke_dn.tga dimensions from 1022x1024 to 1024x1024

V1.42 Patch 2 Notes (ad_v1_42p2 release)
------------------------------------------------------------------------------
* Added two new remix maps (ad_e1m1 and ad_e2m2) to the start map
* Fixed sprite particle system reaching limit and not going back down
* Added new quake.rc option to stop all global fog command/functions working
* Updated various models in progs directory to work with winQuake clients
* Added think/nextthink reset to monster_death_precheck to stop animation errors
* Added think/nextthink reset to entity_hide to stop animation when hidden
* Fixed remove(self) code problems with _once, _multi, _hurt and misc_bubble
* Added variable (cnt) override for all item_artifacts expiration timers
* Client debuff pain sounds can be blocked by god/pentagram mode
* Moved lost souls death radius explosion to second death frame
* Added more enemy/health checks to crossbow knight attack functions
* Fixed ceiling spider/Voreling for QuakeSpasm and Darkplaces engines
* Spider and Voreling melee range changed from 50 to 60 (diagonal bbox problem)
* Pyro flame sprite movetype changed to fat missile type for monsters
* Pyro correctly aims flames at smaller targets and resets ricochet effect
* Changed zombies to die after 30s if blocked trying to get up off the floor
* Can now switch weapons (via keys 1-8) while firing (was locked before)
* Fury Knight triple rocket attack changed to 20 direct and 20 splash
* Soldier shotgun/rocket/plasma can now drop exact amounts of ammo
* Fixed zombie/knights idle sound not being blocked via spawnflag
* Fixed nomonstercount not being read properly when monster dies
* misc_builtineffects now plays any associated sounds on self or target
* Fixed misc_particle_burst particle count being reset after trigger
* item pickup triggers for weapons now fires once when playing co-op

V1.42 Patch 1 Notes (ad_v1_42p1 release)
------------------------------------------------------------------------------
* Added transparent texture support for DP
* Updated breakables for ad_crucial, ad_swampy, ad_test3
* Fixed ad_crucial so that the rune room does not lock
* Fixing bounding boxes for misc/func exploding boxes
* Removed FTE engine detection (simplified to DP/Fitz)
* Changed pixels command to understand default=blurry
* Added DP laser particle effect (TR_LASER)
* Removed EF_DIMLIGHT from plasma/laser for DP
* Added plasma burn explosion for DP (large cloud effect)
* Added altar (red/grey) DP (floating upward dots/smoke)
* Fixed skill pillar directional particles for DP
* changed misc_drip movetype to prevent engine splash sound
* Fixed extra global fog parameters for ad_end in DP
* Changed trigger_heal/hurt bubbles to be noclip instead of fly
* Fixed spiders/voreling dropping from ceiling properly in DP
* Gaunt projectile speed - old (600/600/600/600) new (500/650/800/950)
* Gargoyle projectile speed - old (500/550/600/650) new (500/650/800/950)
* Minotaur projectile speed - old (500/600/700/800) new (500/650/800/950)
* Ceiling spiders are broken with patch 1 for QuakeSpasm Engine

==============================================================================
Distribution / Copyright / Permissions 

The QC files in this MOD are based on 1.06 source files by ID Software.
These files are released under the terms of GNU General Public License v2 or
later. You may use the source files as a base to build your own MODs as long
as you release them under the same license and make the source available.
Please also give proper credit. Check http://www.gnu.org for details.

Quake I is a registered trademark of id Software, Inc.

===========================================================================
