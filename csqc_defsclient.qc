//======================================================================
// Author : Simon "Sock" OCallaghan
// Website: www.simonoc.com
//
// Based on the qsextensions.qc file in the QSS devkit
// This is a special defs file for csprogs.dat ONLY
// Requires csqc_defs.qc file for 300-399 range commands
//
//======================================================================
// Some extra defs (csqc/csqc_simple)
#ifndef CSQC
#define CSQC
#endif
#ifndef CSQC_SIMPLE
#define CSQC_SIMPLE
#endif
// Suppress reference errors
#pragma noref 1

//----------------------------------------------------------------------
// Mostly stuff from GLOBALVARS_T C STRUCTURE
//----------------------------------------------------------------------
entity		self,other,world;
float		time,frametime,force_retouch;
string		mapname;
float		deathmatch,coop,teamplay,serverflags,total_secrets,total_monsters,found_secrets,killed_monsters,parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8, parm9, parm10, parm11, parm12, parm13, parm14, parm15, parm16;
vector		v_forward, v_up, v_right;
float		trace_allsolid,trace_startsolid,trace_fraction;
vector		trace_endpos,trace_plane_normal;
float		trace_plane_dist;
entity		trace_ent;
float		trace_inopen,trace_inwater;
entity		msg_entity;
void() 		main,StartFrame,PlayerPreThink,PlayerPostThink,ClientKill,ClientConnect,PutClientInServer,ClientDisconnect,SetNewParms,SetChangeParms;
void		end_sys_globals;
.float		modelindex;
.vector		absmin, absmax;
.float		ltime,movetype,solid;
.vector		origin,oldorigin,velocity,angles,avelocity,punchangle;
.string		classname,model;
.float		frame,skin,effects;
.vector		mins, maxs,size;
.void()		touch,use,think,blocked;
.float		nextthink;
.entity		groundentity;
.float		health,frags,weapon;
.string		weaponmodel;
.float		weaponframe,currentammo,ammo_shells,ammo_nails,ammo_rockets,ammo_cells,items,takedamage;
.entity		chain;
.float		deadflag;
.vector		view_ofs;
.float		button0,button1,button2,impulse,fixangle;
.vector		v_angle;
.float		idealpitch;
.string		netname;
.entity 	enemy;
.float		flags,colormap,team,max_health,teleport_time,armortype,armorvalue,waterlevel,watertype,ideal_yaw,yaw_speed;
.entity		aiment,goalentity;
.float		spawnflags;
.string		target,targetname;
.float		dmg_take,dmg_save;
.entity		dmg_inflictor,owner;
.vector		movedir;
.string		message;
.float		sounds;
.string		noise, noise1, noise2, noise3;
void		end_sys_fields;

// Custom types redefined as accessors
#ifdef _ACCESSORS
accessor strbuf:float;
accessor searchhandle:float;
accessor hashtable:float;
accessor infostring:string;
accessor filestream:float;
#else
#define strbuf float
#define searchhandle float
#define hashtable float
#define infostring string
#define filestream float
#endif

void(string cmd) SV_ParseClientCommand;
void() EndFrame;

// Core CSQC functions called by engine
void(float apilevel, string enginename, float engineversion) CSQC_Init;
void(vector virtsize, float showscores) CSQC_DrawHud;
void(vector virtsize, float showscores) CSQC_DrawScores;
float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent;
float(float save, float take, vector dir) CSQC_Parse_Damage;
float(string cmdstr) CSQC_ConsoleCommand;
void() CSQC_Parse_Event;

float player_localnum;		// Player slot that is assigned to us

const float FALSE			= 0;
const float TRUE			= 1;
const float IE_KEYDOWN		= 0;
const float IE_KEYUP		= 1;
const float IE_MOUSEDELTA	= 2;
const float IE_MOUSEABS		= 3;
const float IE_JOYAXIS		= 6;

//----------------------------------------------------------------------
// Extra fields
//----------------------------------------------------------------------
.float gravity;
//.float items2;			/*if defined, overrides serverflags for displaying runes on the hud*/
.float traileffectnum;		/*can also be set with 'traileffect' from a map editor*/
.float emiteffectnum;		/*can also be set with 'traileffect' from a map editor*/
.vector movement;			/*describes which forward/right/up keys the player is holidng*/
.entity viewmodelforclient;	/*attaches this entity to the specified player's view. invisible to other players*/
.float scale;				/*rescales the etntiy*/
.float alpha;				/*entity opacity*/
.vector colormod;			/*tints the entity's colours*/
.entity tag_entity;
.float tag_index;
.float button3;
.float button4;
.float button5;
.float button6;
.float button7;
.float button8;
.float viewzoom;			/*rescales the user's fov*/
.float modelflags;			/*provides additional modelflags to use (effects&EF_NOMODELFLAGS to replace the original model's)*/

//----------------------------------------------------------------------
// Supported Extension Constants
//----------------------------------------------------------------------
const float MOVETYPE_FOLLOW	= 12;
const float SOLID_CORPSE	= 5;
const float CLIENTTYPE_DISCONNECT	= 0;
const float CLIENTTYPE_REAL			= 1;
const float CLIENTTYPE_BOT			= 2;
const float CLIENTTYPE_NOTCLIENT	= 3;
const float EF_NOSHADOW		= 0x1000;
const float EF_NOMODELFLAGS	= 0x800000; /*the standard modelflags from the model are ignored*/
const float MF_ROCKET		= 0x1;
const float MF_GRENADE		= 0x2;
const float MF_GIB			= 0x4;
const float MF_ROTATE		= 0x8;
const float MF_TRACER		= 0x10;
const float MF_ZOMGIB		= 0x20;
const float MF_TRACER2		= 0x40;
const float MF_TRACER3		= 0x80;
const float MSG_MULTICAST	= 4;
const float MULTICAST_ALL	= 0;
const float MULTICAST_PVS	= 2;
const float MULTICAST_ONE	= 6;
const float MULTICAST_ALL_R	= 3;
const float MULTICAST_PVS_R	= 5;
const float MULTICAST_ONE_R	= 7;
const float MULTICAST_INIT	= 8;
const float FILE_READ		= 0;
const float FILE_APPEND		= 1;
const float FILE_WRITE		= 2;

//----------------------------------------------------------------------
// Vanilla Builtin list (reduced, so as to avoid conflicts)
//----------------------------------------------------------------------
void(vector) makevectors = #1;
void(entity,vector) setorigin = #2;
void(entity,string) setmodel = #3;
void(entity,vector,vector) setsize = #4;
float() random = #7;
vector(vector) normalize = #9;
void(string e) error = #10;
void(string n) objerror = #11;
float(vector) vlen = #12;
entity() spawn = #14;
void(entity e) remove = #15;
void(string,...) dprint = #25;
string(float) ftos = #26;
string(vector) vtos = #27;
float(float n) rint = #36;
float(float n) floor = #37;
float(float n) ceil = #38;
float(float n) fabs = #43;
float(string) cvar = #45;
void(string,...) localcmd = #46;
entity(entity) nextent = #47;
void(string var, string val) cvar_set = #72;

//----------------------------------------------------------------------
// Builtin list
//----------------------------------------------------------------------
vector(vector fwd, optional vector up) vectoangles2 = #51; /*
		Returns the angles (+x=UP) required to orient an entity to look in the given direction. The 'up' argument is required if you wish to set a roll angle, otherwise it will be limited to just monster-style turning. */

float(float angle) sin = #60;
float(float angle) cos = #61;
float(float value) sqrt = #62;
void(entity ent, entity ignore) tracetoss = #64;
string(entity ent) etos = #65;
string(entity e, string key) infokey = #80; /*
		If e is world, returns the field 'key' from either the serverinfo or the localinfo. If e is a player, returns the value of 'key' from the player's userinfo string. There are a few special exceptions, like 'ip' which is not technically part of the userinfo. */

float(entity e, string key) infokeyf = #0; /*
		Identical to regular infokey, but returns it as a float instead of creating new tempstrings. */

float(string) stof = #81;
#define unicast(pl,reli) do{msg_entity = pl; multicast('0 0 0', reli?MULITCAST_ONE_R:MULTICAST_ONE);}while(0)
void(vector where, float set) multicast = #82; /*
		Once the MSG_MULTICAST network message buffer has been filled with data, this builtin is used to dispatch it to the given target, filtering by pvs for reduced network bandwidth. */

void(vector start, vector mins, vector maxs, vector end, float nomonsters, entity ent) tracebox = #90; /*
		Exactly like traceline, but a box instead of a uselessly thin point. Acceptable sizes are limited by bsp format, q1bsp has strict acceptable size values. */

vector() randomvec = #91; /*
		Returns a vector with random values. Each axis is independantly a value between -1 and 1 inclusive. */

vector(vector org) getlight = #92;
float(string cvarname, string defaultvalue) registercvar = #93; /*
		Creates a new cvar on the fly. If it does not already exist, it will be given the specified value. If it does exist, this is a no-op.
		This builtin has the limitation that it does not apply to configs or commandlines. Such configs will need to use the set or seta command causing this builtin to be a noop.
		In engines that support it, you will generally find the autocvar feature easier and more efficient to use. */

float(float a, float b, ...) min = #94; /*
		Returns the lowest value of its arguments. */

float(float a, float b, ...) max = #95; /*
		Returns the highest value of its arguments. */

float(float minimum, float val, float maximum) bound = #96; /*
		Returns val, unless minimum is higher, or maximum is less. */

float(float value, float exp) pow = #97;
#define findentity findfloat
entity(entity start, .__variant fld, __variant match) findfloat = #98; /*
		Equivelent to the find builtin, but instead of comparing strings contents, this builtin compares the raw values. This builtin requires multiple calls in order to scan all entities - set start to the previous call's return value.
		world is returned when there are no more entities. */

float(string extname) checkextension = #99; /*
		Checks for an extension by its name (eg: checkextension("FRIK_FILE") says that its okay to go ahead and use strcat).
		Use cvar("pr_checkextension") to see if this builtin exists. */

float(__variant funcref) checkbuiltin = #0; /*
		Checks to see if the specified builtin is supported/mapped. This is intended as a way to check for #0 functions, allowing for simple single-builtin functions. */

//----------------------------------------------------------------------
// 100-199 Range
//----------------------------------------------------------------------
float(string builtinname) builtin_find = #100; /*
		Looks to see if the named builtin is valid, and returns the builtin number it exists at. */

float(float value) anglemod = #102;
filestream(string filename, float mode, optional float mmapminsize) fopen = #110; /*
		Opens a file, typically prefixed with "data/", for either read or write access. */

void(filestream fhandle) fclose = #111;
string(filestream fhandle) fgets = #112; /*
		Reads a single line out of the file. The new line character is not returned as part of the string. Returns the null string on EOF (use if not(string) to easily test for this, which distinguishes it from the empty string which is returned if the line being read is blank */

void(filestream fhandle, string s, optional string s2, optional string s3, optional string s4, optional string s5, optional string s6, optional string s7) fputs = #113; /*
		Writes the given string(s) into the file. For compatibility with fgets, you should ensure that the string is terminated with a \n - this will not otherwise be done for you. It is up to the engine whether dos or unix line endings are actually written. */

#define ftell fseek //c-compat
int(filestream fhandle, optional int newoffset) fseek = #0; /*
		Changes the current position of the file, if specified. Returns prior position, in bytes. */

float(string s) strlen = #114;
string(string s1, optional string s2, optional string s3, optional string s4, optional string s5, optional string s6, optional string s7, optional string s8) strcat = #115;
string(string s, float start, float length) substring = #116;
vector(string s) stov = #117;
string(string s, ...) strzone = #118; /*
		Create a semi-permanent copy of a string that only becomes invalid once strunzone is called on the string (instead of when the engine assumes your string has left scope). */

void(string s) strunzone = #119; /*
		Destroys a string that was allocated by strunzone. Further references to the string MAY crash the game. */

//----------------------------------------------------------------------
// 200-299 FTE Range
//----------------------------------------------------------------------
float(float number, float quantity) bitshift = #218;
void(vector org) te_lightningblood = #219;
float(string s1, string sub, optional float startidx) strstrofs = #221; /*
		Returns the 0-based offset of sub within the s1 string, or -1 if sub is not in s1.
		If startidx is set, this builtin will ignore matches before that 0-based offset. */

float(string str, float index) str2chr = #222; /*
		Retrieves the character value at offset 'index'. */

string(float chr, ...) chr2str = #223; /*
		The input floats are considered character values, and are concatenated. */

string(float ccase, float redalpha, float redchars, string str, ...) strconv = #224; /*
		Converts quake chars in the input string amongst different representations.
		ccase specifies the new case for letters.
		 0: not changed.
		 1: forced to lower case.
		 2: forced to upper case.
		redalpha and redchars switch between colour ranges.
		 0: no change.
		 1: Forced white.
		 2: Forced red.
		 3: Forced gold(low) (numbers only).
		 4: Forced gold (high) (numbers only).
		 5+6: Forced to white and red alternately.
		You should not use this builtin in combination with UTF-8. */

string(float pad, string str1, ...) strpad = #225; /*
		Pads the string with spaces, to ensure its a specific length (so long as a fixed-width font is used, anyway). If pad is negative, the spaces are added on the left. If positive the padding is on the right. */

string(infostring old, string key, string value) infoadd = #226; /*
		Returns a new tempstring infostring with the named value changed (or added if it was previously unspecified). Key and value may not contain the \ character. */

string(infostring info, string key) infoget = #227; /*
		Reads a named value from an infostring. The returned value is a tempstring */

#define strcmp strncmp
float(string s1, string s2, optional float len, optional float s1ofs, optional float s2ofs) strncmp = #228; /*
		Compares up to 'len' chars in the two strings. s1ofs allows you to treat s2 as a substring to compare against, or should be 0.
		Returns 0 if the two strings are equal, a negative value if s1 appears numerically lower, and positive if s1 appears numerically higher. */

float(string s1, string s2) strcasecmp = #229; /*
		Compares the two strings without case sensitivity.
		Returns 0 if they are equal. The sign of the return value may be significant, but should not be depended upon. */

float(string s1, string s2, float len, optional float s1ofs, optional float s2ofs) strncasecmp = #230; /*
		Compares up to 'len' chars in the two strings without case sensitivity. s1ofs allows you to treat s2 as a substring to compare against, or should be 0.
		Returns 0 if they are equal. The sign of the return value may be significant, but should not be depended upon. */

string(string s) strtrim = #0; /*
		Trims the whitespace from the start+end of the string. */

void(float num, float type, .__variant fld) clientstat = #232; /*
		Specifies what data to use in order to send various stats, in a client-specific way.
		'num' should be a value between 32 and 127, other values are reserved.
		'type' must be set to one of the EV_* constants, one of EV_FLOAT, EV_STRING, EV_INTEGER, EV_ENTITY.
		fld must be a reference to the field used, each player will be sent only their own copy of these fields. */

void(float num, float type, string name) globalstat = #233; /*
		Specifies what data to use in order to send various stats, in a non-client-specific way. num and type are as in clientstat, name however, is the name of the global to read in the form of a string (pass "foo"). */

void(float num, float type, __variant *address) pointerstat = #0; /*
		Specifies what data to use in order to send various stats, in a non-client-specific way. num and type are as in clientstat, address however, is the address of the variable you would like to use (pass &foo). */

float(entity player) isbackbuffered = #234; /*
		Returns if the given player's network buffer will take multiple network frames in order to clear. If this builtin returns non-zero, you should delay or reduce the amount of reliable (and also unreliable) data that you are sending to that client. */

void(vector org, float count) te_bloodqw = #239;
float(float a, float n) mod = #245;
int(string) stoi = #259; /*
		Converts the given string into a true integer. Base 8, 10, or 16 is determined based upon the format of the string. */

string(int) itos = #260; /*
		Converts the passed true integer into a base10 string. */

int(string) stoh = #261; /*
		Reads a base-16 string (with or without 0x prefix) as an integer. Bugs out if given a base 8 or base 10 string. :P */

string(int) htos = #262; /*
		Formats an integer as a base16 string, with leading 0s and no prefix. Always returns 8 characters. */

int(float) ftoi = #0; /*
		Converts the given float into a true integer without depending on extended qcvm instructions. */

float(int) itof = #0; /*
		Converts the given true integer into a float without depending on extended qcvm instructions. */

#ifndef dotproduct
#define dotproduct(v1,v2) ((vector)(v1)*(vector)(v2))
#endif
vector(vector v1, vector v2) crossproduct = #0; /*
		Small helper function to calculate the crossproduct of two vectors. */

float(float modidx, string framename) frameforname = #276; /*
		Looks up a framegroup from a model by name, avoiding the need for hardcoding. Returns -1 on error. */

float(float modidx, float framenum) frameduration = #277; /*
		Retrieves the duration (in seconds) of the specified framegroup. */

void(float buf, float fl) WriteFloat = #280;
string(float modidx, float framenum) frametoname = #284;
float(string name) checkcommand = #294; /*
		Checks to see if the supplied name is a valid command, cvar, or alias. Returns 0 if it does not exist. */

// ----------------------------------------------------------------------
// 300-399 Range - Moved to CSQC DEFS file
// ----------------------------------------------------------------------

//----------------------------------------------------------------------
// 400-499 DP Range
//----------------------------------------------------------------------
entity(entity from, optional entity to) copyentity = #400; /*
		Copies all fields from one entity to another. */

void(entity ent, float colours) setcolors = #401; /*
		Changes a player's colours. The bits 0-3 are the lower/trouser colour, bits 4-7 are the upper/shirt colours. */

entity(.string field, string match) findchain = #402;
entity(.float fld, float match) findchainfloat = #403;
void(vector org, vector dir, float count) te_blood = #405;
void(vector mincorner, vector maxcorner, vector vel, float howmany, float color) te_particlerain = #409;
void(vector mincorner, vector maxcorner, vector vel, float howmany, float color) te_particlesnow = #410;
void(vector org, optional float count) te_gunshot = #418;
void(vector org) te_spike = #419;
void(vector org) te_superspike = #420;
void(vector org) te_explosion = #421;
void(vector org) te_tarexplosion = #422;
void(vector org) te_wizspike = #423;
void(vector org) te_knightspike = #424;
void(vector org) te_lavasplash = #425;
void(vector org) te_teleport = #426;
void(vector org, float color, float colorlength) te_explosion2 = #427;
void(entity own, vector start, vector end) te_lightning1 = #428;
void(entity own, vector start, vector end) te_lightning2 = #429;
void(entity own, vector start, vector end) te_lightning3 = #430;
void(entity own, vector start, vector end) te_beam = #431;
void(vector dir) vectorvectors = #432;
float(entity e, float s) getsurfacenumpoints = #434;
vector(entity e, float s, float n) getsurfacepoint = #435;
vector(entity e, float s) getsurfacenormal = #436;
string(entity e, float s) getsurfacetexture = #437;
float(entity e, vector p) getsurfacenearpoint = #438;
vector(entity e, float s, vector p) getsurfaceclippedpoint = #439;
void(entity e, string s) clientcommand = #440;
float(string s) tokenize = #441;
string(float n) argv = #442;
float() argc = #0;
void(entity e, entity tagentity, string tagname) setattachment = #443; /* */

searchhandle(string pattern, optional float caseinsensitive, optional float quiet) search_begin = #444; /*
		initiate a filesystem scan based upon filenames. Be sure to call search_end on the returned handle. */

void(searchhandle handle) search_end = #445; /* */

float(searchhandle handle) search_getsize = #446; /*
		 Retrieves the number of files that were found. */

string(searchhandle handle, float num) search_getfilename = #447; /*
		Retrieves name of one of the files that was found by the initial search. */

float(searchhandle handle, float num) search_getfilesize = #0; /*
		Retrieves the size of one of the files that was found by the initial search. */

string(searchhandle handle, float num) search_getfilemtime = #0; /*
		Retrieves modification time of one of the files in %Y-%m-%d %H:%M:%S format. */

string(string cvarname) cvar_string = #448;
entity(entity start, .float fld, float match) findflags = #449;
entity(.float fld, float match) findchainflags = #450;
void(entity player) dropclient = #453;
entity() spawnclient = #454; /*
		Spawns a dummy player entity.
		Note that such dummy players will be carried from one map to the next.
		Warning: DP_SV_CLIENTCOLORS DP_SV_CLIENTNAME are not implemented in quakespasm, so use KRIMZON_SV_PARSECLIENTCOMMAND's clientcommand builtin to change the bot's name/colours/skin/team/etc, in the same way that clients would ask. */

float(entity client) clienttype = #455;
void(float target, string str) WriteUnterminatedString = #456;
entity(float entnum) edict_num = #459;
strbuf() buf_create = #460;
void(strbuf bufhandle) buf_del = #461;
float(strbuf bufhandle) buf_getsize = #462;
void(strbuf bufhandle_from, strbuf bufhandle_to) buf_copy = #463;
void(strbuf bufhandle, float sortprefixlen, float backward) buf_sort = #464;
string(strbuf bufhandle, string glue) buf_implode = #465;
string(strbuf bufhandle, float string_index) bufstr_get = #466;
void(strbuf bufhandle, float string_index, string str) bufstr_set = #467;
float(strbuf bufhandle, string str, float order) bufstr_add = #468;
void(strbuf bufhandle, float string_index) bufstr_free = #469;
float(float s) asin = #471;
float(float c) acos = #472;
float(float t) atan = #473;
float(float c, float s) atan2 = #474;
float(float a) tan = #475;
float(string s) strlennocol = #476; /*
		Returns the number of characters in the string after any colour codes or other markup has been parsed. */

string(string s) strdecolorize = #477; /*
		Flattens any markup/colours, removing them from the string. */

string(float uselocaltime, string format, ...) strftime = #478;
float(string s, string separator1, ...) tokenizebyseparator = #479;
string(string s) strtolower = #480;
string(string s) strtoupper = #481;
string(string s) cvar_defstring = #482;
void(vector origin, string sample, float volume, float attenuation) pointsound = #483;
string(string search, string replace, string subject) strreplace = #484;
string(string search, string replace, string subject) strireplace = #485;
vector(entity e, float s, float n, float a) getsurfacepointattribute = #486;
float(float caseinsensitive, string s, ...) crc16 = #494;
float(string name) cvar_type = #495;
float() numentityfields = #496; /*
		Gives the number of named entity fields. Note that this is not the size of an entity, but rather just the number of unique names (ie: vectors use 4 names rather than 3). */

float(string fieldname) findentityfield = #0; /*
		Find a field index by name. */

typedef .__variant field_t;
field_t(float fieldnum) entityfieldref = #0; /*
		Returns a field value that can be directly used to read entity fields. Be sure to validate the type with entityfieldtype before using. */

string(float fieldnum) entityfieldname = #497; /*
		Retrieves the name of the given entity field. */

float(float fieldnum) entityfieldtype = #498; /*
		Provides information about the type of the field specified by the field num. Returns one of the EV_ values. */

string(float fieldnum, entity ent) getentityfieldstring = #499;

//----------------------------------------------------------------------
// 500-599 Range
//----------------------------------------------------------------------
float(float fieldnum, entity ent, string s) putentityfieldstring = #500;
string(string filename, optional float makereferenced) whichpack = #503; /*
		Returns the pak file name that contains the file specified. progs/player.mdl will generally return something like 'pak0.pak'. If makereferenced is true, clients will automatically be told that the returned package should be pre-downloaded and used, even if allow_download_refpackages is not set. */

string(string in) uri_escape = #510;
string(string in) uri_unescape = #511;
float(entity ent) num_for_edict = #512;
float(string str) tokenize_console = #514; /*
		Tokenize a string exactly as the console's tokenizer would do so. The regular tokenize builtin became bastardized for convienient string parsing, which resulted in a large disparity that can be exploited to bypass checks implemented in a naive SV_ParseClientCommand function, therefore you can use this builtin to make sure it exactly matches. */

float(float idx) argv_start_index = #515; /*
		Returns the character index that the tokenized arg started at. */

float(float idx) argv_end_index = #516; /*
		Returns the character index that the tokenized arg stopped at. */

string(string cvarname) cvar_description = #518; /*
		Retrieves the description of a cvar, which might be useful for tooltips or help files. This may still not be useful. */

float(optional float timetype) gettime = #519;
string(string command, optional float bindmap) findkeysforcommand = #521; /*
		Returns a list of keycodes that perform the given console command in a format that can only be parsed via tokenize (NOT tokenize_console). This always returns at least two values - if only one key is actually bound, -1 will be returned. The bindmap argument is listed for compatibility with dp-specific defs, but is ignored in FTE. */

string(string command, optional float bindmap) findkeysforcommandex = #0; /*
		Returns a list of key bindings in keyname format instead of keynums. Use tokenize to parse. This list may contain modifiers. May return large numbers of keys. */

float(float v, optional float base) log = #532; /*
		Determines the logarithm of the input value according to the specified base. This can be used to calculate how much something was shifted by. */

float(string filename, strbuf bufhandle) buf_loadfile = #535; /*
		Appends the named file into a string buffer (which must have been created in advance). The return value merely says whether the file was readable. */

float(filestream filehandle, strbuf bufhandle, optional float startpos, optional float numstrings) buf_writefile = #536; /*
		Writes the contents of a string buffer onto the end of the supplied filehandle (you must have already used fopen). Additional optional arguments permit you to constrain the writes to a subsection of the stringbuffer. */

//----------------------------------------------------------------------
// 600-699 Range
//----------------------------------------------------------------------
void(.../*, string funcname*/) callfunction = #605; /*
		Invokes the named function. The function name is always passed as the last parameter and must always be present. The others are passed to the named function as-is */

float(string s) isfunction = #607; /*
		Returns true if the named function exists and can be called with the callfunction builtin. */

float(entity e, string s, optional float offset) parseentitydata = #613; /*
		Reads a single entity's fields into an already-spawned entity. s should contain field pairs like in a saved game: {"foo1" "bar" "foo2" "5"}. Returns <=0 on failure, otherwise returns the offset in the string that was read to. */

string(string fmt, ...) sprintf = #627;
float(entity e, float s) getsurfacenumtriangles = #628;
vector(entity e, float s, float n) getsurfacetriangle = #629;

//----------------------------------------------------------------------
//Builtin Stubs List - present for simpler compatibility
// Not properly supported in QuakeSpasm at this time
//----------------------------------------------------------------------
/*
void(vector org, string modelname, float startframe, float endframe, float framerate) effect = #404;
void(vector mincorner, vector maxcorner, float explosionspeed, float howmany) te_bloodshower = #406;
void(vector org, vector color) te_explosionrgb = #407;
void(vector mincorner, vector maxcorner, vector vel, float howmany, float color, float gravityflag, float randomveljitter) te_particlecube = #408;
void(vector org, vector vel, float howmany) te_spark = #411;
void(vector org) te_gunshotquad = #412;
void(vector org) te_spikequad = #413;
void(vector org) te_superspikequad = #414;
void(vector org) te_explosionquad = #415;
void(vector org) te_smallflash = #416;
void(vector org, float radius, float lifetime, vector color) te_customflash = #417;
void(vector org) te_plasmaburn = #433;
*/

//----------------------------------------------------------------------
// Keyboard input values
//----------------------------------------------------------------------
const float K_TAB = 9;
const float K_ENTER = 13;
const float K_ESCAPE = 27;
const float K_SPACE = 32;
const float K_BACKSPACE = 127;
const float K_UPARROW = 128;
const float K_DOWNARROW = 129;
const float K_LEFTARROW = 130;
const float K_RIGHTARROW = 131;
const float K_ALT = 132;
const float K_CTRL = 133;
const float K_SHIFT = 134;
const float K_F1 = 135;
const float K_F2 = 136;
const float K_F3 = 137;
const float K_F4 = 138;
const float K_F5 = 139;
const float K_F6 = 140;
const float K_F7 = 141;
const float K_F8 = 142;
const float K_F9 = 143;
const float K_F10 = 144;
const float K_F11 = 145;
const float K_F12 = 146;
const float K_INS = 147;
const float K_DEL = 148;
const float K_PGDN = 149;
const float K_PGUP = 150;
const float K_HOME = 151;
const float K_END = 152;
const float K_KP_SLASH = 168;
const float K_KP_STAR = 169;
const float K_KP_MINUS = 170;
const float K_KP_HOME = 164;
const float K_KP_UPARROW = 165;
const float K_KP_PGUP = 166;
const float K_KP_PLUS = 171;
const float K_KP_LEFTARROW = 161;
const float K_KP_5 = 162;
const float K_KP_RIGHTARROW = 163;
const float K_KP_END = 158;
const float K_KP_DOWNARROW = 159;
const float K_KP_PGDN = 160;
const float K_KP_ENTER = 172;
const float K_KP_INS = 157;
const float K_KP_DEL = 167;
const float K_COMMAND = -170;
const float K_MOUSE1 = 512;
const float K_MOUSE2 = 513;
const float K_MOUSE3 = 514;
const float K_JOY1 = 768;
const float K_JOY2 = 769;
const float K_JOY3 = 770;
const float K_JOY4 = 771;
const float K_AUX1 = 784;
const float K_AUX2 = 785;
const float K_AUX3 = 786;
const float K_AUX4 = 787;
const float K_AUX5 = 788;
const float K_AUX6 = 789;
const float K_AUX7 = 790;
const float K_AUX8 = 791;
const float K_AUX9 = 792;
const float K_AUX10 = 793;
const float K_AUX11 = 794;
const float K_AUX12 = 795;
const float K_AUX13 = 796;
const float K_AUX14 = 797;
const float K_AUX15 = 798;
const float K_AUX16 = 799;
const float K_AUX17 = 800;
const float K_AUX18 = 801;
const float K_AUX19 = 802;
const float K_AUX20 = 803;
const float K_AUX21 = 804;
const float K_AUX22 = 805;
const float K_AUX23 = 806;
const float K_AUX24 = 807;
const float K_AUX25 = 808;
const float K_AUX26 = 809;
const float K_AUX27 = 810;
const float K_AUX28 = 811;
const float K_AUX29 = 812;
const float K_AUX30 = 813;
const float K_AUX31 = 814;
const float K_AUX32 = 815;
const float K_MWHEELUP = 515;
const float K_MWHEELDOWN = 516;
const float K_MOUSE4 = 517;
const float K_MOUSE5 = 518;
const float K_LTHUMB = 822;
const float K_RTHUMB = 823;
const float K_LSHOULDER = 824;
const float K_RSHOULDER = 825;
const float K_ABUTTON = 826;
const float K_BBUTTON = 827;
const float K_XBUTTON = 828;
const float K_YBUTTON = 829;
const float K_LTRIGGER = 830;
const float K_RTRIGGER = 831;
const float K_PAUSE = 153;

//----------------------------------------------------------------------
// Reset suppression of ref errors
#pragma noref 0

//----------------------------------------------------------------------
// List of advertised extensions (not used, reference only)
//----------------------------------------------------------------------
//DP_CON_SET
//DP_CON_SETA
//DP_EF_NOSHADOW
//DP_ENT_ALPHA
//DP_ENT_COLORMOD
//DP_ENT_SCALE
//DP_ENT_TRAILEFFECTNUM
//DP_INPUTBUTTONS
//DP_QC_AUTOCVARS
//DP_QC_ASINACOSATANATAN2TAN
//DP_QC_COPYENTITY
//DP_QC_CRC16
//DP_QC_CVAR_DEFSTRING
//DP_QC_CVAR_STRING
//DP_QC_CVAR_TYPE
//DP_QC_EDICT_NUM
//DP_QC_ENTITYDATA
//DP_QC_ETOS
//DP_QC_FINDCHAIN
//DP_QC_FINDCHAINFLAGS
//DP_QC_FINDCHAINFLOAT
//DP_QC_FINDFLAGS
//DP_QC_FINDFLOAT
//DP_QC_GETLIGHT
//DP_QC_GETSURFACE
//DP_QC_GETSURFACETRIANGLE
//DP_QC_GETSURFACEPOINTATTRIBUTE
//DP_QC_MINMAXBOUND
//DP_QC_MULTIPLETEMPSTRINGS
//DP_QC_RANDOMVEC
//DP_QC_SINCOSSQRTPOW
//DP_QC_SPRINTF
//DP_QC_STRFTIME
//DP_QC_STRING_CASE_FUNCTIONS
//DP_QC_STRINGBUFFERS
//DP_QC_STRINGCOLORFUNCTIONS
//DP_QC_STRREPLACE
//DP_QC_TOKENIZEBYSEPARATOR
//DP_QC_TRACEBOX
//DP_QC_TRACETOSS
//DP_QC_TRACE_MOVETYPES
//DP_QC_URI_ESCAPE
//DP_QC_VECTOANGLES_WITH_ROLL
//DP_QC_VECTORVECTORS
//DP_QC_WHICHPACK
//DP_VIEWZOOM
//DP_REGISTERCVAR
//DP_SV_BOTCLIENT
//DP_SV_DROPCLIENT
//DP_SV_POINTSOUND
//DP_SV_PRINT
//DP_SV_SETCOLOR
//DP_SV_SPAWNFUNC_PREFIX
//DP_SV_WRITEUNTERMINATEDSTRING
//DP_TE_PARTICLERAIN
//DP_TE_PARTICLESNOW
//DP_TE_STANDARDEFFECTBUILTINS
//EXT_BITSHIFT
//FRIK_FILE
//FTE_PART_SCRIPT
//FTE_PART_NAMESPACES
//FTE_PART_NAMESPACE_EFFECTINFO
//FTE_QC_CHECKCOMMAND
//FTE_QC_CROSSPRODUCT
//FTE_QC_INFOKEY
//FTE_QC_INTCONV
//FTE_QC_MULTICAST
//FTE_STRINGS
//FTE_SV_POINTPARTICLES
//KRIMZON_SV_PARSECLIENTCOMMAND
//ZQ_QC_STRINGS
