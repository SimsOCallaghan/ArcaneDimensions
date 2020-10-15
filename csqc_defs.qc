//======================================================================
// Author : Simon "Sock" OCallaghan
// Website: www.simonoc.com
//
// This is a special defs file with all the relevant CSQC references
// Should be included into progs and csprogs to reduce duplicates
//
//----------------------------------------------------------------------
// The CSQC files are setup to be self contained and easy to port
// to other MODS, but some stuff needs to exist in other QC files
// In world.qc the extra variables for AD are located there
//
//----------------------------------------------------------------------
// Special Variables used by CSQC (Client Side Quake C)
// The engine will keep these insync between server and client
// Defined with the addstat/clientstat command DP/FTE
//----------------------------------------------------------------------

const float CLIENT_HEALTH = 0;			// Player's health
const float CLIENT_WEAPONMODELI = 2;	// Modelindex of current viewmodel
const float CLIENT_AMMO = 3;			// player.currentammo
const float CLIENT_ARMOR = 4;
const float CLIENT_WEAPONFRAME = 5;
const float CLIENT_SHELLS = 6;
const float CLIENT_NAILS = 7;
const float CLIENT_ROCKETS = 8;
const float CLIENT_CELLS = 9;
const float CLIENT_ACTIVEWEAPON = 10;	// player.weapon
const float CLIENT_TOTALSECRETS = 11;
const float CLIENT_TOTALMONSTERS = 12;
const float CLIENT_FOUNDSECRETS = 13;
const float CLIENT_KILLEDMONSTERS = 14;
// getstatbits(CLIENT_ITEMS,0,23) to read self.items
// getstatbits(CLIENT_ITEMS,23,11) to read self.items2
// or getstatbits(CLIENT_ITEMS,28,4) to read the visible part of serverflags
const float CLIENT_ITEMS = 15;			// self.items | (self.items2<<23)
const float CLIENT_VIEWHEIGHT = 16;		// player.view_ofs_z
const float CLIENT_VIEW2 = 20;			// Entity Qty in server's .view2 field
const float CLIENT_VIEWZOOM = 21;		// Scales fov and sensitiity
const float CLIENT_IDEALPITCH = 25;
const float CLIENT_PUNCHANGLE_X = 26;
const float CLIENT_PUNCHANGLE_Y = 27;
const float CLIENT_PUNCHANGLE_Z = 28;
// 32-127 is custom variables (defined here and linked in world.qc)
const float CLIENT_MODITEMS = 40;		// self.moditems (AD extra stuff)
const float CLIENT_CKEYNAME1 = 50;		// self.ckeyname1
const float CLIENT_CKEYNAME2 = 51;		// self.ckeyname2
const float CLIENT_CKEYNAME3 = 52;		// self.ckeyname3
const float CLIENT_CKEYNAME4 = 53;		// self.ckeyname4
const float CLIENT_CKEYSKIN1 = 55;		// self.ckeyskin1
const float CLIENT_CKEYSKIN2 = 56;		// self.ckeyskin2
const float CLIENT_CKEYSKIN3 = 57;		// self.ckeyskin3
const float CLIENT_CKEYSKIN4 = 58;		// self.ckeyskin4

//----------------------------------------------------------------------
// Duplicate of IT_ references in defs.qc
//----------------------------------------------------------------------
const float CSQC_SHOTGUN = 1<<0;			// 1
const float CSQC_SUPER_SHOTGUN = 1<<1;		// 2
const float CSQC_NAILGUN = 1<<2;			// 4
const float CSQC_SUPER_NAILGUN = 1<<3;		// 8
const float CSQC_GRENADE_LAUNCHER = 1<<4;	// 16
const float CSQC_ROCKET_LAUNCHER = 1<<5;	// 32
const float CSQC_LIGHTNING = 1<<6;			// 64
// const float CSQC_EXTRA_WEAPON = 1<<7;	// 128

const float CSQC_SHELLS = 1<<8;				// 256
const float CSQC_NAILS = 1<<9;				// 512
const float CSQC_ROCKETS = 1<<10;			// 1024
const float CSQC_CELLS = 1<<11;				// 2048
const float CSQC_AXE = 1<<12;				// 4096

const float CSQC_ARMOR1 = 1<<13;			// 8192
const float CSQC_ARMOR2 = 1<<14;			// 16384
const float CSQC_ARMOR3 = 1<<15;			// 32768
// const float CSQC_SUPERHEALTH = 1<<16;	// 65536

const float CSQC_KEY1 = 1<<17;				// 131072
const float CSQC_KEY2 = 1<<18;				// 262144

const float CSQC_INVISIBILITY = 1<<19;		// 524288
const float CSQC_INVULNERABILITY = 1<<20;	// 1048576
const float CSQC_SUIT = 1<<21;				// 2097152
const float CSQC_QUAD = 1<<22;				// 4194304

// Runes in Serverflags
const float CSQC_RUNE1 = 1<<5;	// 32
const float CSQC_RUNE2 = 1<<6;	// 64
const float CSQC_RUNE3 = 1<<7;	// 128
const float CSQC_RUNE4 = 1<<8;	// 256

// Variable types
const float EV_VOID = 0;
const float EV_STRING = 1;
const float EV_FLOAT = 2;
const float EV_VECTOR = 3;
const float EV_ENTITY = 4;
const float EV_FIELD = 5;
const float EV_FUNCTION = 6;
const float EV_POINTER = 7;
const float EV_INTEGER = 8;

// ======================================================================
// This is a merge of three (DP/FTE/QSS) engine def files
// dpextensions+csprogsdefs from SVN ICCULUS site (DP trunk)
// fteexentions from triptohell website
// qsextensions from QSS devkit on triptohell website
// 
// CSQC range #300-#399
// ======================================================================

// ----------------------------------------------------------------------
// DP/FTE extensions ONLY
// ----------------------------------------------------------------------
// Forgets all rentities, polygons, and temporary dlights. 
// Resets all view properties to their default values.
void() clearscene = #300;
void(float mask) addentities = #301;
// Copies the entity fields into a new rentity for
// later rendering via addscene
void(entity ent) addentity = #302;
// Allows you to override default view properties like
// viewport, fov, and whether the engine hud will be drawn.
// Different VF_ values have slightly different arguments,
// some are vectors, some floats.
float(float property, ...) setproperty = #303;
// Draws all entities, polygons, and particles on the rentity list
// (which were added via addentities or addentity), using the various
// view properties set via setproperty. There is no ordering dependancy.
// The scene must generally be cleared again before more entities
// are added, as entities will persist even over to the next frame.
// You may call this builtin multiple times per frame, but should
// only be called from CSQC_UpdateView.
void() renderscene = #304;
// Adds a temporary dlight, ready to be drawn via addscene.
// Cubemap orientation will be read from v_forward/v_right/v_up.
void(vector org, float radius, vector lightcolours) adddynamiclight = #305;
void(vector org, float radius, vector lightcolours, float style, string cubemapname, float pflags) adddynamiclight2 = #305;
// Specifies the shader to use for the following polygons, along
// with optional flags.
// If is2d, the polygon will be drawn as soon as the EndPolygon
// call is made, rather than waiting for renderscene. This allows
// complex 2d effects.
// FTE = void(string texturename, optional float flags, optional float is2d) R_BeginPolygon = #306;
void(string texturename, float flag, ...) R_BeginPolygon = #306;
// Specifies a polygon vertex with its various properties
void(vector org, vector texcoords, vector rgb, float alpha) R_PolygonVertex = #307;
// Ends the current polygon. At least 3 verticies must have been 
// specified. You do not need to call beginpolygon if you wish to
// draw another polygon with the same shader
void() R_EndPolygon = #308;
// Retrieve a currently-set (typically view) property, allowing you
// to read the current viewport or other things. Due to cheat protection,
// certain values may be unretrievable
// define = FTE version of DP version
#define getviewprop getproperty
float(float property) getproperty = #309;
vector(float property) getpropertyvec = #309;
// Transform a 2d screen-space point (with depth) into a 3d world-space
// point, according the various origin+angle+fov etc settings set via
// setproperty
vector (vector v) cs_unproject = #310;
// Transform a 3d world-space point into a 2d screen-space point,
// according the various origin+angle+fov etc settings set via
// setproperty
vector (vector v) cs_project = #311;
// Draws a 2d line between the two 2d points
void(float width, vector pos1, vector pos2, vector rgb, float alpha, float flag) drawline = #315;
// Tells the engine that the image is no longer needed. 
// The image will appear to be new the next time its needed
void(string name) freepic = #319;
// Draws the specified string without using any markup at all, 
// even in engines that support it.
// If UTF-8 is globally enabled in the engine, then that encoding
// is used (without additional markup), otherwise it is raw quake chars.
// Software engines may assume a size of '8 8 0', rgb='1 1 1', 
// alpha=1, flag&3=0, but it is not an error to draw out of the screen.
float(vector position, string text, vector scale, vector rgb, float alpha, float flag) drawstring = #321;
// Retrieves the value of the given EV_STRING stat, as a tempstring.
// Older engines may use 4 consecutive integer stats, with a limit
// of 15 chars (yes, really. 15.), but FTE Quake uses a separate
// namespace for string stats and has a much higher length limit.
string(float stnum) getstats = #332;
// Retrieves the name of the model based upon a precache index.
// This can be used to reduce csqc network traffic by enabling
// model matching
string(float mdlindex) modelnameforindex = #334;
// Looks up a named font slot. Matches the actual font name as a last resort.
// find font by fontname and return it's index
float findfont(string s) = #356;
float loadfont(string fontname, string fontmaps, string sizes, float slot, float fix_scale, float fix_voffset) = #357;

// ----------------------------------------------------------------------
// QSS (CSQC Lit) + DP/FTE extensions
// ----------------------------------------------------------------------
// Checks to see if the image is currently loaded. 
// Engines might lie, or cache between maps.
float(string name) iscachedpic = #316;
// Forces the engine to load the named image. If trywad is specified,
// the specified name must any lack path and extension.
string(string name, optional float trywad) precache_pic = #317;
// Returns the dimensions of the named image. Images specified
// with .lmp should give the original .lmp's dimensions even if
// texture replacements use a different resolution.
// define = FTE version of DP version
#define drawgetimagesize draw_getimagesize 
vector(string picname) draw_getimagesize = #318;
// Draw the given quake character at the given position.
// If flag&4, the function will consider the char to be a unicode 
// char instead (or display as a ? if outside the 32-127 range).
// size should normally be something like '8 8 0'.
// rgb should normally be '1 1 1' and alpha normally 1.
// Software engines may assume the named defaults.
// Note that ALL text may be rescaled on the X axis due to 
// variable width fonts. The X axis may even be ignored completely.
float(vector position, float character, vector scale, vector rgb, float alpha, float flag) drawcharacter = #320;
// Draws an shader within the given 2d screen box. Software engines
// may omit support for rgb+alpha, but must support rescaling,
// and must clip to the screen without crashing
// flag = draw method; 0=normal, 1=additive, 2=modulate, 3=modulate2
float(vector position, string pic, vector size, vector rgb, float alpha, float flag) drawpic = #322;
// Draws a solid block over the given 2d box, with given colour, 
// alpha, and blend mode (specified via flags).
// flags&3=0 simple blend flags&3=1 additive blend
float(vector position, vector size, vector rgb, float alpha, float flag) drawfill = #323;
// Specifies a 2d clipping region (aka: scissor test).
// 2d draw calls will all be clipped to this 2d box,
// the area outside will not be modified by any 
// 2d draw call (even 2d polygons).
void(float x, float y, float width, float height) drawsetcliparea = #324;
// Reverts the scissor/clip area to the whole screen
void(void) drawresetcliparea = #325;
// Draws a string, interpreting markup and recolouring as appropriate
// QSS/FTE = drawstring, DP = drawcolorcodedstring/drawcolorcodedstring2
// float(vector position, string text, vector size, vector rgb, float alpha, float drawflag) drawstring = #326;
float(vector position, string text, vector scale, float alpha, float flag) drawcolorcodedstring = #326;
vector(vector position, string text, vector scale, vector rgb, float alpha, float flag) drawcolorcodedstring2 = #326;
// Calculates the width of the screen in virtual pixels.
// If usecolours is 1, markup that does not affect the string
// width will be ignored. Will always be decoded as UTF-8 if
// UTF-8 is globally enabled.
// If the char size is not specified, '8 8 0' will be assumed
// float(string text, float usecolours, optional vector fontsize) stringwidth = #327;
// QSS/FTE = float(string text, float usecolours, optional vector fontsize) stringwidth = #327;
float(string text, float allowColorCodes, vector size) stringwidth = #327;
// Draws a rescaled subsection of an image to the screen
// QSS/FTE = void(vector pos, vector sz, string pic, vector srcpos, vector srcsz, vector rgb, float alpha, optional float drawflag) drawsubpic = #328;
float(vector position, vector size, string pic, vector srcPosition, vector srcSize, vector rgb, float alpha, float flag) drawsubpic = #328;
// Nasty convoluted DP extension. Typically returns deltas instead
// of positions. Use CSQC_InputEvent for such things in csqc mods
vector() getmousepos = #344;
// Looks up an input frame from the log, setting the input_*
// globals accordingly.
// The sequence number range used for prediction should normally
// be servercommandframe < sequence <= clientcommandframe.
// The sequence equal to clientcommandframe will change between
// input frames
float(float framenum) getinputstate = #345;
// Perform the engine's standard player movement prediction upon
// the given entity using the input_* globals to describe movement
// this may or may not take a player ent
void(...) runstandardplayerphysics = #347;
// Sets the position of the view, as far as the audio subsystem is
// concerned. This should be called once per CSQC_UpdateView as it
// will otherwise revert to default. For reverbtype,
// see setup_reverb or treat as 'underwater'
// FTE = void(vector origin, vector forward, vector right, vector up, optional float reverbtype) SetListener = #351;
void(vector origin, vector forward, vector right, vector up) SetListener = #351;

// ----------------------------------------------------------------------
// This is a bit of mess with DP (below) and FTE/QSS (further below)
// Going in different directions with the CSQC standard
// This is all about #330 returning an INT instead of a FLOAT
// As getstatf has optional parameters it will still work fine with DP
// Going with the FTE/QSS direction as it still works for DP
// ----------------------------------------------------------------------
//float(float stnum) getstatf = #330;
// Can optionally take first bit and count
//float(float stnum, ...) getstati = #331;

// Retrieves the numerical value of the given EV_INTEGER or EV_ENTITY stat.
// Use getstati_punf if you wish to type-pun a float stat as an int to
// avoid truncation issues in DP
#define getstati_punf(stnum) (float)(__variant)getstati(stnum)
int(float stnum) getstati = #330;
#define getstatbits getstatf
float(float stnum, optional float firstbit, optional float bitcount) getstatf = #331;

// ----------------------------------------------------------------------
// QSS (CSQC Lit) + DP/FTE extensions
// ----------------------------------------------------------------------
// Sets a model by precache index instead of by name. 
// Otherwise identical to setmodel.
void(entity e, float mdlindex) setmodelindex = #333;
// Part of DP_ENT_TRAILEFFECTNUM, FTE_SV_POINTPARTICLES
// Precaches the named particle effect. If your effect name is of
// the form 'foo.bar' then particles/foo.cfg will be loaded by the
// client if foo.bar was not already defined.
// Different engines will have different particle systems, this
// specifies the QC API only
float(string effectname) particleeffectnum = #335;
// Part of FTE_SV_POINTPARTICLES
// Draws the given effect between the two named points. If ent is
// not world, distances will be cached in the entity in order to
// avoid framerate dependancies. The entity is not otherwise used
void(float effectnum, entity ent, vector start, vector end) trailparticles = #336;
// Part of FTE_SV_POINTPARTICLES
// Spawn a load of particles from the given effect at the given
// point traveling or aiming along the direction specified.
// The number of particles are scaled by the count argument.
// For regular particles, the dir vector is multiplied by the 
// 'veladd' property (while orgadd will push the particles along it).
// Decals will use it as a hint to align to the correct surface.
// In both cases, it should normally be a unit vector, but other
// lengths will still work. If it has length 0 then FTE will
// assume downwards
void(float effectnum, vector origin, optional vector dir, optional float count) pointparticles = #337;

// conflicts with void(entity client, string s1) centerprint = #73;
void(string s, ...) csqc_centerprint = #338;
// Print into the center of the screen just as ssqc's centerprint
// would appear
void(string s, ...) cprint = #338;
// This is identical to dprint except that it always prints 
// regardless of the developer cvar. Same number as in EXT_CSQC
// Unconditionally print on the local system's console, even in
// ssqc (doesn't care about the value of the developer cvar)
void(string s, ...) print = #339;
// Returns a hunam-readable name for the given keycode, as a tempstring
string(float keynum) keynumtostring = #340;
// Looks up the key name in the same way that the bind command would,
// returning the keycode for that key
float(string keyname) stringtokeynum = #341;
// Returns the current binding for the given key (returning only the 
// command executed when no modifiers are pressed)
string(float key, float bindmap) getkeybind_bindmap = #342;
string(float keynum) getkeybind = #342;
// Pass TRUE if you want the engine to release the mouse cursor
// (absolute input events + touchscreen mode). Pass FALSE if you
// want the engine to grab the cursor (relative input
// events + standard looking). If the image name is specified,
// the engine will use that image for a cursor (use an empty
// string to clear it again), in a way that will not conflict
// with the console. Images specified this way will be hardware
// accelerated, if supported by the platform/port
// QSS/FTE = void(float usecursor, optional string cursorimage, optional vector hotspot, optional float scale) setcursormode = #343;
void(float usecursor) setcursormode = #343;
// Reports the cursor mode this module previously attempted to use.
// If 'effective' is true, reports the cursor mode currently active
// (if was overriden by a different module which has precidence,
// for instance, or if there is only a touchscreen and no mouse)
float(float effective) getcursormode = #0;
// Temporarily scales the player's mouse sensitivity based upon
// something like zoom, avoiding potential cvar saving and thus
// corruption
void(float sens) setsensitivityscale = #346;
// Look up a player's userinfo, to discover things like their name,
// topcolor, bottomcolor, skin, team, *ver.
// Also includes scoreboard info like frags, ping, pl, userid,
// entertime, as well as voipspeaking and voiploudness
string(float playernum, string keyname) getplayerkeyvalue = #348;
// Cheaper version of getplayerkeyvalue that avoids the need for
// so many tempstrings
float(float playernum, string keyname, optional float assumevalue) getplayerkeyfloat = #0;
// Returns if the client is currently playing a demo or not
float() isdemo = #349;
// Returns if the client is acting as the server (aka: listen server)
float() isserver = #350;
// Register the given console command, for easy console use.
// Console commands that are later used will invoke CSQC_ConsoleCommand
void(string cmdname) registercommand = #352;
// Quickly check to see if the entity is currently free. This
// function is only valid during the two-second non-reuse window,
// after that it may give bad results. Try one second to make it
// more robust.
float(entity ent) wasfreed = #353;
// Look up a key in the server's public serverinfo string
string(string key) serverkey = #354;
// Version of serverkey that returns the value as a float
// (which avoids tempstrings)
float(string key, optional float assumevalue) serverkeyfloat = #0;
// Use proper case; refer to the id1 Write* functions!
float() ReadByte = #360;
float() ReadChar = #361;
float() ReadShort = #362;
float() ReadLong = #363;
float() ReadCoord = #364;
float() ReadAngle = #365;
string() ReadString = #366;
float() ReadFloat = #367;
float() readentitynum = #368;
// Replaces the title of the game window, as seen when 
// task switching or just running in windowed mode
void(string newcaption) setwindowcaption = #0;

