/*======================================================================
 All CSQC functions (AD ONLY VERSION)
 
 * This file is heavily influenced by QSS devkit (credit=spike)
 * re-written some functions to make better sense to me
 * Contains all HUD elements for full quake interface (SP/Coop/Dm)
 * Sripped out the experimental stuff included in devkit
 * Converted most of the hardcoded values into constants
 * Added loads of extra comments to show what is going on
  
======================================================================*/
float nocsqc;				// CSQC State (0=on, 1=off)
float detectDP;				// Detect DP engine (using wrapper)
float sitems;				// CSQC copy of .items
float sitems2;				// CSQC copy of .items2 (or serverflags)
float sweapon;				// CSQC copy of .weapon
float shealth;				// CSQC copy of .health
float smoditems;			// CSQC copy of .moditems

float sb_showscores;		// Show lower tab scores
float painfinishtime;		// Track player damage for hud face

float intermission;			// in intermission
float intermission_time;	// when the intermission started

float player_localentnum;	// Entity number that csqc is attached to
float numclientseats;		// coop or splitscreen?
float maxclients;			// maximum players possible on this server
float cltime;				// increases regardless of pause or game speed

.float ext_csqc;			// Client Server Quake C HUD alive!
string CSQC_PING = "csqcping";	// Test command to check if CSCQ alive

float CSQC_HUDREV = 100;	// Offset to reverse hud layout

//----------------------------------------------------------------------
// Duplicate of IT_ references in defscustom.qc (AD only stuff)
//----------------------------------------------------------------------
const float CSQC_UPGRADE_SSG = 1<<1;	// 2
const float CSQC_UPGRADE_LG = 1<<6;		// 64
const float CSQC_UPGRADE_GHOOK = 1<<7;	// 128
const float CSQC_UPGRADE_AXE = 1<<12;	// 4096

const float CSQC_CKEY1 = 1<<13;			// 8192
const float CSQC_CKEY2 = 1<<14;			// 16384
const float CSQC_CKEY3 = 1<<15;			// 32768
const float CSQC_CKEY4 = 1<<16;			// 65536

const float CSQC_ARTLAVASHIELD = 1<<17;	// 131072
const float CSQC_ARTAIRTANK = 1<<18;	// 262144
const float CSQC_ARTBLASTBELT = 1<<19;	// 524288
const float CSQC_ARTJUMPBOOTS = 1<<20;	// 1048576

const float CSQC_ARTSHARP = 1<<21;		// 2097152
const float CSQC_ARTPIERCE = 1<<22;		// 4194304

// Default sizes for HUD elements
vector HUDSIZE_24 = '24 24 0';		// Status Bar
vector HUDSIZE_16 = '16 16 0';		// Inventory/Powerups
vector HUDSIZE_1624 = '16 24 0';	// Special key background
vector HUDSIZE_816 = '8 16 0';		// Old Vertical Runes
vector HUDSIZE_168 = '16 8 0';		// Silver/Gold/Custom Keys
vector HUDSIZE_8  = '8 8 0';		// Ammo numbers
vector HUDSIZE_C8 = '8 0 0';		// Character sizes

// 8 pixel font table (index positions)
float HUDFONT_WHITE = 0;	// Default index = 48-57
float HUDFONT_YELLOW = 1;	// index = index - 30
float HUDFONT_RED = 2;		// index = index + 128

// Default sizes for weapons
vector HUDWPN_48 = '48 16 0';		// Vanilla LG
vector HUDWPN_32 = '32 16 0';		// AD/Hipnotic LG
vector HUDWPN_24 = '24 16 0';		// Default

vector HUDRGB_DEF = '1 1 1';
float baralpha;				// Read scr_sbaralpha variable
float hudalpha;				// All gfx on hud bars

//----------------------------------------------------------------------
// These constants are only used in CSQC_UpdateView
float MASK_ENGINE = 1;
float MASK_VIEWMODEL = 2;
float VF_MIN = 1;
float VF_SIZE = 4;
float VF_DRAWENGINESBAR = 20;
float VF_DRAWCROSSHAIR = 21;

//----------------------------------------------------------------------
// Statue, Inventory(split) and Score bars
float HUDTYPE_0 = 0;	// Default ID layout + upside down version
float HUDTYPE_1 = 4;	// Side version 1
float HUDTYPE_2 = 8;	// Floating side bars
float HUDTYPE_4 = 12;	// Chunky Doom setup
string backgrd[16] = { "gfx/ad_sbar0.lmp", "gfx/ad_scorebar0.lmp",
					  "gfx/ad_ibar0a.lmp", "gfx/ad_ibar0b.lmp",
					  "gfx/ad_sbar1.lmp", "gfx/ad_blank.lmp",
					  "gfx/ad_ibar1a.lmp", "gfx/ad_ibar1b.lmp",
					  "gfx/ad_sbar1.lmp", "gfx/ad_blank.lmp",
					  "gfx/ad_ibar2a.lmp", "gfx/ad_ibar2b.lmp",
					  "gfx/ad_sbar4a.lmp", "gfx/ad_sbar4b.lmp",
					  "gfx/ad_ibar4a.lmp", "gfx/ad_ibar4b.lmp"
};

float HUDTYPE_5 = 0;	// Quake Champions inspired
float HUDTYPE_6 = 4;	// Extra wide (bal) version
float HUDTYPE_7 = 8;	// Minimal Pro version
string backgrd2[12] = { "gfx/ad_sbar5a.lmp", "gfx/ad_sbar5b.lmp",
					  "gfx/ad_ibar5a.lmp", "gfx/ad_ibar5b.lmp",
					  "gfx/ad_sbar6.lmp", "gfx/ad_ibar7c.lmp",
					  "gfx/ad_ibar6a.lmp", "gfx/ad_ibar6b.lmp",
					  "gfx/ad_sbar7a.lmp", "gfx/ad_sbar7b.lmp",
					  "gfx/ad_ibar7a.lmp", "gfx/ad_ibar7b.lmp"
};
// Small ammo quantity lines (48x8 and 8x8)
string ammoqty[8] = { "gfx/ad_ibar_shell1.lmp", "gfx/ad_ibar_nail1.lmp",
					  "gfx/ad_ibar_rock1.lmp", "gfx/ad_ibar_cell1.lmp",
					  "gfx/ad_ibar_shell2.lmp", "gfx/ad_ibar_nail2.lmp",
					  "gfx/ad_ibar_rock2.lmp", "gfx/ad_ibar_cell2.lmp"
};
// Ranking (168 x 24), Complete (184 x 24), Inter (160 x 144)
string backlmp[3] = { "gfx/ranking.lmp", "gfx/complete.lmp", "gfx/inter.lmp" };

//----------------------------------------------------------------------
// Regular (24x24) brown numbers
string adn24[10] = {
	"gfx/adn_0.lmp", "gfx/adn_1.lmp", "gfx/adn_2.lmp", "gfx/adn_3.lmp", "gfx/adn_4.lmp",
	"gfx/adn_5.lmp", "gfx/adn_6.lmp", "gfx/adn_7.lmp", "gfx/adn_8.lmp", "gfx/adn_9.lmp"
};
// Red (24x24) numbers for no armour, low HP (<25) and no ammo
string adn24a[10] = {
	"gfx/adn_a0.lmp", "gfx/adn_a1.lmp", "gfx/adn_a2.lmp", "gfx/adn_a3.lmp", "gfx/adn_a4.lmp",
	"gfx/adn_a5.lmp", "gfx/adn_a6.lmp", "gfx/adn_a7.lmp", "gfx/adn_a8.lmp", "gfx/adn_a9.lmp"
};
// Regular (16x16) brown numbers
string adn16[10] = {
	"gfx/adn_s0.lmp", "gfx/adn_s1.lmp", "gfx/adn_s2.lmp", "gfx/adn_s3.lmp", "gfx/adn_s4.lmp",
	"gfx/adn_s5.lmp", "gfx/adn_s6.lmp", "gfx/adn_s7.lmp", "gfx/adn_s8.lmp", "gfx/adn_s9.lmp"
};

// Regular (24x24) characters for intermission
string extrachar[3] = { 
	"gfx/num_colon", "gfx/num_minus", "gfx/num_slash"
};

// 24x24 pixel icons for Status Bar
// key0 = background for keys, key1/2 are unique 16x8 size
string sbitems[14] = {
	"gfx/adsb_shells.lmp", "gfx/adsb_nails.lmp", "gfx/adsb_rocks.lmp", "gfx/adsb_cells.lmp",
	"gfx/adsb_axe1.lmp", "gfx/adsb_axe2.lmp",
	"gfx/adsb_armor0.lmp", "gfx/adsb_armor1.lmp", "gfx/adsb_armor2.lmp", "gfx/adsb_armor3.lmp",
	"gfx/adsb_pent.lmp", "gfx/adsb_key0.lmp", "gfx/adsb_key1.lmp", "gfx/adsb_key2.lmp"
};

// 16x16 pixel icons for Information Bar
string ibitems[12] = {
	"gfx/adib_invis.lmp", "gfx/adib_invuln.lmp", "gfx/adib_suit.lmp", "gfx/adib_quad.lmp",
	"gfx/adib_axe1.lmp", "gfx/adib_axe2.lmp", "gfx/adib_sharp.lmp", "gfx/adib_nailp.lmp",
	"gfx/adib_jboots.lmp", "gfx/adib_bbelt.lmp", "gfx/adib_atank.lmp", "gfx/adib_lshield.lmp"
};

// 16x8 pixel custom keys for Information Bar
float CKEY_ARRAY = 14;
string ibckeys[CKEY_ARRAY] = {
	"gfx/adib_ckey1.lmp", "gfx/adib_ckey2.lmp", "gfx/adib_ckey3.lmp", "gfx/adib_ckey4.lmp",
	"gfx/adib_ckey5.lmp", "gfx/adib_ckey6.lmp", "gfx/adib_ckey7.lmp", "gfx/adib_ckey8.lmp",
	"gfx/adib_ckey9.lmp", "gfx/adib_ckey10.lmp", "gfx/adib_ckey11.lmp", "gfx/adib_ckey12.lmp",
	"gfx/adib_ckey13.lmp", "gfx/adib_ckey14.lmp"
};

// 0-3=16x8, 4-7=8x16 pixel runes for Information Bar
string ibrunes[16] = {
	"gfx/adib_sigil1.lmp", "gfx/adib_sigil2.lmp", "gfx/adib_sigil3.lmp", "gfx/adib_sigil4.lmp",
	"gfx/adib_sigil5.lmp", "gfx/adib_sigil6.lmp", "gfx/adib_sigil7.lmp", "gfx/adib_sigil8.lmp",
	"gfx/adib_sigil9.lmp", "gfx/adib_sigil10.lmp", "gfx/adib_sigil11.lmp", "gfx/adib_sigil12.lmp",
	"gfx/adib_sigil13.lmp", "gfx/adib_sigil14.lmp", "gfx/adib_sigil15.lmp", "gfx/adib_sigil16.lmp"
};

//----------------------------------------------------------------------
// All weapon HUD graphics are prefixed with certain characters which
// means all weapon filenames can be generated with string commands
// CSQC is really an advanced (QSS/FTE/DP) engine only thing and its
// very likely that FTE_STRINGS is supported for string manipulation
//----------------------------------------------------------------------
// Total weapons to precache pics + flash timers
float WPN_ICONS = 9;
// Total actual weapon slots (AD = 2 upgrades)
float WPN_SLOTS = 7;
// Record when weapons have been added (flash mechanic)
float flashtime[WPN_ICONS];

// Shotgun, SuperShotgun, Nailgun, SuperNailGun, GrenadeLauncher
// RocketLauncher, LightningGun, WidowMaker, PlasmaGun, ShadowAxe
string weaponnames[WPN_ICONS] = {
	"shotgun.lmp", "sshotgun.lmp", "nailgun.lmp", "snailgun.lmp", "grenade.lmp",
	"rocket.lmp", "lightng.lmp", "widowm.lmp", "plasma.lmp"
};
// OFF / ON gfx (reflects active weapon)
string weaponselect[2] = { "gfx/adw_", "gfx/adws_" };
// Special flash set for when the player gets weapon
string weaponflash[5] = { "gfx/adx1_","gfx/adx2_","gfx/adx3_","gfx/adx4_","gfx/adx5_" };

//----------------------------------------------------------------------
// Frame 00-04 : Regular HP 100/80/60/40/20
// Frame 05-09 : InPain  HP 100/80/60/40/20
// Frame 10    : Invisibility Ring + Pentagram! 
// Frame 11    : Quad Damage
// Frame 12    : Invisibility Ring
// Frame 13    : Pentagram (invulnerability)
//----------------------------------------------------------------------
string faceid[14] = {
	"gfx/adf_5.lmp", "gfx/adf_4.lmp", "gfx/adf_3.lmp", "gfx/adf_2.lmp", "gfx/adf_1.lmp",
	"gfx/adf_p5.lmp", "gfx/adf_p4.lmp", "gfx/adf_p3.lmp", "gfx/adf_p2.lmp", "gfx/adf_p1.lmp",
	"gfx/adf_inv2.lmp", "gfx/adf_quad.lmp", "gfx/adf_invis.lmp", "gfx/adf_invul2.lmp"
};

string facead[4] = {
	"gfx/adf_evil.lmp", "gfx/adf_evilquad.lmp", "gfx/adf_evilpent.lmp", "gfx/adf_evilinv.lmp"
};

//----------------------------------------------------------------------
// Stubs for extra CSQC functions (not all supported)
//----------------------------------------------------------------------
// Can query or check anything types on the console here
float(string str) CSQC_ConsoleCommand = {
	tokenize_console(str);
	return FALSE;
};

// Can query/check keyboard/mouse/joystick input with this function
// For key events, scanx is one of the KEY_* values
// chary is the character code (chr2str to shove it into a string)
// For mouse events then x+y are the mouse delta/position values
float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent = {
	return FALSE;
};
// This is linked to client dmg_take / dmg_save / dmg_inflictor fields
// returning TRUE will block the red flash damage stuff
float(float save, float take, vector dir) CSQC_Parse_Damage = {
	painfinishtime = time + 0.2;
	return FALSE;
};
// Can query/check server MSG events
// CSQC_Parse_Event is called when the client sees a
// #define svcfte_cgamepacket (83) message from the server
// Not supported for DP, is called from only QSS/FTE
void() CSQC_Parse_Event = { };

// Can intercept printed messages from the server (top of screen)
// printlvl (text filtering) 0=low, 1=medium, 2=high, 3=chat
// con_notifytime = amount of time the text remains on screen
// ONLY define this function, if doing something with the text!!
void(string printmsg, float printlvl) CSQC_Parse_Print = {
	print(printmsg);
};

// Running on the Server side of CSCQ listening for commands back
// This is never called on the client side of the progs
void(string str) SV_ParseClientCommand = {
	local string ostr, cmd;
	// Save command string for later
	ostr = str;
	// Search for tokens in string
	tokenize_console(str);
	// Find the first argument of the command
	cmd = argv(0);	
	// Is this my (AD CSQC) command?
	if (cmd == CSQC_PING) self.ext_csqc = TRUE;
	// Pass through original command
	else clientcommand(self, ostr);
};

//======================================================================
// Display 24pixel numbers to HUD (cope with red version)
//----------------------------------------------------------------------
void(vector pos, float value, float threshhold) Hud_DrawNoFont24 =
{
	local string val_str, disp_str;
	local float disp_col, disp_len, disp_no;

	// Make sure value is within range
	if (value < 0) value = 0;
	else if (value > 999) value = 999;
	// Work out which number colour to use
	if (value <= threshhold) disp_col = TRUE;
	
	// Round number down (floor) and work out length
	val_str = ftos(floor(value));
	disp_len = strlen(val_str);
	// Move to the lowest digit position first
	pos_x = pos_x + (3 * HUDSIZE_24_x);
	
	while (disp_len > 0) {
		// Countdown early (range is 0-2, strlen returns 1-3)
		disp_len = disp_len - 1;
		// Move backward to display a digit
		pos_x = pos_x - HUDSIZE_24_x;
		// Convert str character to font index numbers
		disp_no = (str2chr(val_str, disp_len) - '0');
		// Double check for any wierd range issues
		if (disp_no < 0 || disp_no > 9) disp_no = 0;
		// Work out which number colour to use
		if (disp_col) disp_str = adn24a[disp_no];
		else disp_str = adn24[disp_no];
		// Draw number in correct (right-justified) position
		drawpic(pos, disp_str, HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);	
	}	
};

//----------------------------------------------------------------------
void(vector pos, float value) Hud_DrawNoFont16 =
{
	local string val_str;
	local float disp_len, disp_no;

	// Make sure value is within range
	if (value < 0) value = 0;
	else if (value > 999) value = 999;
	
	// Round number down (floor) and work out length
	val_str = ftos(floor(value));
	disp_len = strlen(val_str);
	// Move to the lowest digit position first
	pos_x = pos_x + (3 * HUDSIZE_16_x);
	
	while (disp_len > 0) {
		// Countdown early (range is 0-2, strlen returns 1-3)
		disp_len = disp_len - 1;
		// Move backward to display a digit
		pos_x = pos_x - HUDSIZE_16_x;
		// Convert str character to font index numbers
		disp_no = (str2chr(val_str, disp_len) - '0');
		// Double check for any wierd range issues
		if (disp_no < 0 || disp_no > 9) disp_no = 0;
		// Draw number in correct (right-justified) position
		drawpic(pos, adn16[disp_no], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);	
	}	
};

//----------------------------------------------------------------------
// Display 24pixel characters to HUD (limited chars available)
//----------------------------------------------------------------------
void(vector pos, string num) Hud_DrawCharFont24 =
{
	float i, c;
	// Endless loop until end of string
	// Keep moving draw pos forward (pos_x)
	for(i = 0; ; i++, pos_x += HUDSIZE_24_x) {
		// Read next character from string
		c = str2chr(num, i);
		// End of string found?
		if (!c) break;
		// Check for special characters
		else if (c == ':' || c == '.')
			drawpic(pos, extrachar[0], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (c == '-')
			drawpic(pos, extrachar[1], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (c == '/')
			drawpic(pos, extrachar[2], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		// Draw rest of the numbers
		else if (c >= '0' && c <= '9') {
			// Sanity check, make sure within range of array
			c = c - 48; if (c<0 || c>9) c=0;
			drawpic(pos, adn24[c], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		}
	}
};

//----------------------------------------------------------------------
// Draws small 8 pixel numbers to HUD (white/yellow/red text options)
//----------------------------------------------------------------------
void(vector pos, float value, float digit, float zerofill, float fontcol) Hud_DrawNoFont8 =
{
	local string val_str;
	local float disp_len, disp_no;

	// Make sure value is within range
	if (value < 0) value = 0;
	// Check max range against max digits
	else if (value > 999 && digit >= 3) value = 999;
	else if (value > 99 && digit == 2) value = 99;
	else if (value > 9 && digit <= 1) value = 9;
	
	// Round number down (floor) and work out length
	val_str = ftos(floor(value));
	disp_len = strlen(val_str);
	
	// Zero fill number?
	if (zerofill) {
		while (disp_len < digit) {
			// Keep adding more zero's
			val_str = strcat("0", val_str);
			// Exit condition?
			disp_len = strlen(val_str);
		}
	}

	// Move to the lowest digit position first
	pos_x = pos_x + (digit * HUDSIZE_8_x);
	
	while (disp_len > 0) {
		// Countdown first (digit positions = 0-2)
		disp_len = disp_len - 1;
		// Move backward to display a digit
		pos_x = pos_x - HUDSIZE_8_x;
		// Convert character to number (font table index 48-57)
		disp_no = str2chr(val_str, disp_len);
		if (fontcol == HUDFONT_YELLOW) disp_no = disp_no - 30;
		else if (fontcol == HUDFONT_RED) disp_no = disp_no + 128;
		// Draw character from ascii font table (right-justified)
		drawcharacter(pos, disp_no, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);	
	}	
};

//----------------------------------------------------------------------
// Change HUD face to reflect Health, Pain or Powerups
//----------------------------------------------------------------------
void(vector pos) Hud_DrawFace =
{
	string face;
	local float hpframe;

	// Different faces for Skill 4 (Evil mode)
	if (cvar("scratch4") == TRUE) {
		if (sitems & CSQC_QUAD) face = facead[1];
		else if (sitems & CSQC_INVULNERABILITY) face = facead[2];
		else if (sitems & CSQC_INVISIBILITY) face = facead[3];
		else face = facead[0];
	}
	// Regular Ranger
	else {
		// Start with InvRing as it has two states
		if (sitems & CSQC_INVISIBILITY) {
			// InvRing + Pentagram!?! WTF!?! SandyP E4 design!
			if (sitems & CSQC_INVULNERABILITY) face = faceid[10];
			// Just InvRing only
			else face = faceid[12];
		}
		// Quad only
		else if (sitems & CSQC_QUAD) face = faceid[11];
		// Pentagram only
		else if (sitems & CSQC_INVULNERABILITY) face = faceid[13];
		// Regular face
		else {
			// Work out face based on HP (100/80/60/40/20)
			hpframe = floor(shealth / 20);
			// Check for negative and upper (MegaHP) limits
			if (hpframe < 0) hpframe = 0;
			else if (hpframe > 4) hpframe = 4;
			// Check for any pain/flinch updates
			if (painfinishtime > time) hpframe = hpframe + 5;
			// Final HP face
			face = faceid[hpframe];
		}
	}
		
	// Draw face - always 24x24 size, full rgb/alpha
	drawpic(pos, face, HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
};

//----------------------------------------------------------------------
// Update a weapon icon with selection or flash features
//----------------------------------------------------------------------
static void(float num, vector gfx_size, vector pos) Hud_DrawWeapon =
{
	local string prefix, file_str;
	local float flash;
	
	// The weapon flash is done every 0.1s and repeated twice!
	// When the player gets a new weapon the time is reset
	// This function will count the time difference for flashing
	// Convert the flash time to a 0-10+ range
	flash = (time - flashtime[num])*10;
	
	// Has the flash happened twice? (finished)
	if (flash >= 10) {
		// Check for weapon upgrades?
		if (num >= WPN_SLOTS) {
			// Got Widowmaker and its selected?
			if (num == 7 && sweapon == CSQC_SUPER_SHOTGUN && smoditems & CSQC_UPGRADE_SSG)
				prefix = weaponselect[1];
			// Got Plasma Gun and its selected?
			else if (num == 8 && sweapon == CSQC_LIGHTNING && smoditems & CSQC_UPGRADE_LG)
				prefix = weaponselect[1];
			// Default = no weapon selection
			else prefix = weaponselect[0];
		}
		else {
			// Work out if this weapon is currently selected
			if (sweapon == (1<<num)) prefix = weaponselect[1];
			// Default is no highlight
			else prefix = weaponselect[0];
		}
	}
	// Flashing!
	else {
		// Is the flash into second phase?
		if (flash < 0) flash = 0;
		else if (flash >= 5) flash = flash - 5;
		// flash is only 0-4 frames
		prefix = weaponflash[flash];
	}
	// Merge prefix type (defined above) to weapon filename
	// Without string (str) functions this would involve a giant table
	// This sorta assumes that CSQC is running on an advanced engine
	// QSS/FTE/DP all support FTE_STRINGS extra str functions
	file_str = strcat(prefix, weaponnames[num]);
	
	// Show weapon GFX (active/deactive/flashing)
	drawpic(pos, file_str, gfx_size, HUDRGB_DEF, hudalpha, 0);
};

//----------------------------------------------------------------------
// Sanity check to make sure custom key skins are alway in range
// If this is out of range, the array will overflow and error!
//----------------------------------------------------------------------
float (float hudvar) Hud_CKeyRange =
{
	local float ret_val;
	// Find out variable value
	ret_val = getstatf(hudvar);
	// Sanity check, ALWAYS make sure within range!
	if (ret_val >= CKEY_ARRAY) ret_val = 0;
	else if (ret_val <= 0) ret_val = 0;
	return ret_val;
};

//======================================================================
// INVENTORY BARS
//
// - shows ammo quanity, key/runes and powerups
// - multiple setups for different hud layouts
//
//======================================================================
void (vector pos, vector br) Hud_DrawIBar0a =
{
	// Draw background bar using scr_sbaralpha default
	drawpic(pos, backgrd[HUDTYPE_0+3], [320, 16], HUDRGB_DEF, baralpha, 0);

	// Draw weapons and highlight current one
	if (sitems & CSQC_SHOTGUN) Hud_DrawWeapon(0, HUDWPN_24, pos+[0,0]);
	if (smoditems & CSQC_UPGRADE_SSG) Hud_DrawWeapon(7, HUDWPN_24, pos+[24,0]);
	else if (sitems & CSQC_SUPER_SHOTGUN) Hud_DrawWeapon(1, HUDWPN_24, pos+[24,0]);
	if (sitems & CSQC_NAILGUN) Hud_DrawWeapon(2, HUDWPN_24, pos+[48,0]);
	if (sitems & CSQC_SUPER_NAILGUN) Hud_DrawWeapon(3, HUDWPN_24, pos+[72,0]);
	if (sitems & CSQC_GRENADE_LAUNCHER) Hud_DrawWeapon(4, HUDWPN_24, pos+[96,0]);
	if (sitems & CSQC_ROCKET_LAUNCHER) Hud_DrawWeapon(5, HUDWPN_24, pos+[120,0]);
	if (smoditems & CSQC_UPGRADE_LG) Hud_DrawWeapon(8, HUDWPN_32, pos+[144,0]);
	else if (sitems & CSQC_LIGHTNING) Hud_DrawWeapon(6, HUDWPN_32, pos+[144,0]);

	// Draw regular/upgrade axe
	if (sitems & CSQC_AXE) {
		if (smoditems & CSQC_UPGRADE_AXE)
			drawpic(pos+[176,0], ibitems[5], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
		else
			drawpic(pos+[176,0], ibitems[4], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	}

	// Draw Classic ID powerups
	if (sitems & CSQC_INVISIBILITY)
		drawpic(pos+[192,0], ibitems[0], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_INVULNERABILITY)
		drawpic(pos+[208,0], ibitems[1], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_SUIT)
		drawpic(pos+[224,0], ibitems[2], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);

	// Draw Quad/Sharp/Pierce combo
	if (smoditems & CSQC_ARTSHARP)
		drawpic(pos+[240,0], ibitems[6], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	else if (smoditems & CSQC_ARTPIERCE)
		drawpic(pos+[240,0], ibitems[7], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	else if (sitems & CSQC_QUAD)
		drawpic(pos+[240,0], ibitems[3], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);

	// Draw New AD poweerups
	if (smoditems & CSQC_ARTJUMPBOOTS)
		drawpic(pos+[256,0], ibitems[8], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTBLASTBELT)
		drawpic(pos+[272,0], ibitems[9], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTAIRTANK)
		drawpic(pos+[288,0], ibitems[10], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTLAVASHIELD)
		drawpic(pos+[304,0], ibitems[11], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);	
};

//----------------------------------------------------------------------
void (vector pos, vector br) Hud_DrawIBar0b =
{
	local vector topcol, botcol;
	local string player_frags;
	local float i;
	
	// Draw background bar using scr_sbaralpha default
	drawpic(pos, backgrd[HUDTYPE_0+2], [320, 8], HUDRGB_DEF, baralpha, 0);

	// Always draw ammo scores
	Hud_DrawNoFont8(pos + [10,0], getstatf(CLIENT_SHELLS), 3, FALSE, HUDFONT_YELLOW);
	Hud_DrawNoFont8(pos + [58,0], getstatf(CLIENT_NAILS), 3, FALSE, HUDFONT_YELLOW);
	Hud_DrawNoFont8(pos + [106,0], getstatf(CLIENT_ROCKETS), 3, FALSE, HUDFONT_YELLOW);
	Hud_DrawNoFont8(pos + [154,0], getstatf(CLIENT_CELLS), 3, FALSE, HUDFONT_YELLOW);

	//should probably show team scores, but this mimics vanilla
	if (deathmatch) {
		// Move to space above powerups
		pos_x += 194;
		
		// Loop through 4 players
		for (i = -1; i >= -4; i--) {
			// Read frag score of next player
			player_frags = getplayerkeyvalue(i, "frags");
			// No frags? stop loop
			if (player_frags == "") break;
			// Read deathmatch player top/bottom skin colours
			topcol = stov(getplayerkeyvalue(i, "topcolor_rgb"));
			botcol = stov(getplayerkeyvalue(i, "bottomcolor_rgb"));
			// Draw skin colours (alpha was 0.75 hardcoded)
			drawfill(pos+[0,1], [28,3], topcol, 0.75, 0);
			drawfill(pos+[0,4], [28,4], botcol, 0.75, 0);
			// Draw frag score (New global small font function)
			Hud_DrawNoFont8(pos+[2,0], stof(player_frags), 3, FALSE, HUDFONT_WHITE);
			// Find player entity attached to this HUD
			if (player_localentnum == stof(getplayerkeyvalue(i, "viewentity"))) {
				// special characters = [] 
				drawcharacter(pos+[-4,0], 0xe010, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
				drawcharacter(pos+[24,0], 0xe011, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
			}
			// Move forward to next hud space
			pos_x += 8*4;
		}
	}
	else {
		// Draw Custom Keys
		if (smoditems & CSQC_CKEY1)
			drawpic(pos+[192,0], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN1)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY2)
			drawpic(pos+[208,0], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN2)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY3)
			drawpic(pos+[224,0], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN3)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY4)
			drawpic(pos+[240,0], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN4)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
			
		// Draw Runes (special size + location)
		if (sitems2 & CSQC_RUNE1)
			drawpic(pos+[256,0], ibrunes[0], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE2)
			drawpic(pos+[272,0], ibrunes[1], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE3)
			drawpic(pos+[288,0], ibrunes[2], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE4)
			drawpic(pos+[304,0], ibrunes[3], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
	}
};

//----------------------------------------------------------------------
void (vector pos, vector br) Hud_DrawIBar1a =
{
	// Draw background bar using scr_sbaralpha default
	drawpic(pos, backgrd[HUDTYPE_1+2], [96, 48], HUDRGB_DEF, baralpha, 0);

	// Always draw ammo scores
	Hud_DrawNoFont8(pos + [10,0], getstatf(CLIENT_SHELLS), 3, FALSE, HUDFONT_YELLOW);
	Hud_DrawNoFont8(pos + [58,0], getstatf(CLIENT_NAILS), 3, FALSE, HUDFONT_YELLOW);
	Hud_DrawNoFont8(pos + [10,24], getstatf(CLIENT_ROCKETS), 3, FALSE, HUDFONT_YELLOW);
	Hud_DrawNoFont8(pos + [58,24], getstatf(CLIENT_CELLS), 3, FALSE, HUDFONT_YELLOW);

	// Draw weapons and highlight current one
	if (sitems & CSQC_SHOTGUN) Hud_DrawWeapon(0, HUDWPN_24, pos+[0,8]);
	if (smoditems & CSQC_UPGRADE_SSG) Hud_DrawWeapon(7, HUDWPN_24, pos+[24,8]);
	else if (sitems & CSQC_SUPER_SHOTGUN) Hud_DrawWeapon(1, HUDWPN_24, pos+[24,8]);
	if (sitems & CSQC_NAILGUN) Hud_DrawWeapon(2, HUDWPN_24, pos+[48,8]);
	if (sitems & CSQC_SUPER_NAILGUN) Hud_DrawWeapon(3, HUDWPN_24, pos+[72,8]);
	if (sitems & CSQC_GRENADE_LAUNCHER) Hud_DrawWeapon(4, HUDWPN_24, pos+[0,32]);
	if (sitems & CSQC_ROCKET_LAUNCHER) Hud_DrawWeapon(5, HUDWPN_24, pos+[24,32]);
	if (smoditems & CSQC_UPGRADE_LG) Hud_DrawWeapon(8, HUDWPN_32, pos+[48,32]);
	else if (sitems & CSQC_LIGHTNING) Hud_DrawWeapon(6, HUDWPN_32, pos+[48,32]);

	// Draw regular/upgrade axe
	if (sitems & CSQC_AXE) {
		if (smoditems & CSQC_UPGRADE_AXE)
			drawpic(pos+[80,32], ibitems[5], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
		else
			drawpic(pos+[80,32], ibitems[4], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	}
};

//----------------------------------------------------------------------
void (vector pos, vector br) Hud_DrawIBar1b =
{
	local vector topcol, botcol;
	local string player_frags;
	local float i, j;
	
	// Draw background bar using scr_sbaralpha default
	drawpic(pos, backgrd[HUDTYPE_1+3], [64, 48], HUDRGB_DEF, baralpha, 0);

	// Draw Classic ID powerups
	if (sitems & CSQC_INVISIBILITY)
		drawpic(pos+[0,16], ibitems[0], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_INVULNERABILITY)
		drawpic(pos+[16,16], ibitems[1], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_SUIT)
		drawpic(pos+[32,16], ibitems[2], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);

	// Draw Quad/Sharp/Pierce combo
	if (smoditems & CSQC_ARTSHARP)
		drawpic(pos+[48,16], ibitems[6], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	else if (smoditems & CSQC_ARTPIERCE)
		drawpic(pos+[48,16], ibitems[7], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	else if (sitems & CSQC_QUAD)
		drawpic(pos+[48,16], ibitems[3], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);

	// Draw New AD poweerups
	if (smoditems & CSQC_ARTJUMPBOOTS)
		drawpic(pos+[0,32], ibitems[8], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTBLASTBELT)
		drawpic(pos+[16,32], ibitems[9], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTAIRTANK)
		drawpic(pos+[32,32], ibitems[10], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTLAVASHIELD)
		drawpic(pos+[48,32], ibitems[11], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);	

	//should probably show team scores, but this mimics vanilla
	if (deathmatch) {
		// Loop through 4 players
		for (i = -1, j = 0; i >= -4; i--, j++) {
			// Check for second line
			if (j>1) { j=0; pos_y += 8; }
			// Read frag score of next player
			player_frags = getplayerkeyvalue(i, "frags");
			// No frags? stop loop
			if (player_frags == "") break;
			// Read deathmatch player top/bottom skin colours
			topcol = stov(getplayerkeyvalue(i, "topcolor_rgb"));
			botcol = stov(getplayerkeyvalue(i, "bottomcolor_rgb"));
			// Draw skin colours (alpha was 0.75 hardcoded)
			drawfill(pos+[0+(j*32),1], [28,3], topcol, 0.75, 0);
			drawfill(pos+[0+(j*32),4], [28,4], botcol, 0.75, 0);
			// Draw frag score (New global small font function)
			Hud_DrawNoFont8(pos+[2+(j*32),0], stof(player_frags), 3, FALSE, HUDFONT_WHITE);
			// Find player entity attached to this HUD
			if (player_localentnum == stof(getplayerkeyvalue(i, "viewentity"))) {
				// special characters = [] 
				drawcharacter(pos+[-4+(j*32),0], 0xe010, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
				drawcharacter(pos+[24+(j*32),0], 0xe011, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
			}
		}
	}
	else {
		// Draw Custom Keys
		if (smoditems & CSQC_CKEY1)
			drawpic(pos+[0,0], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN1)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY2)
			drawpic(pos+[0,8], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN2)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY3)
			drawpic(pos+[16,0], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN3)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY4)
			drawpic(pos+[16,8], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN4)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
			
		// Draw Runes (special size + location)
		if (sitems2 & CSQC_RUNE1)
			drawpic(pos+[32,0], ibrunes[4], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE2)
			drawpic(pos+[40,0], ibrunes[5], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE3)
			drawpic(pos+[48,0], ibrunes[6], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE4)
			drawpic(pos+[56,0], ibrunes[7], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
	}
};

//----------------------------------------------------------------------
void (vector pos, vector br) Hud_DrawIBar2a =
{
	// Draw background bar using scr_sbaralpha default
	drawpic(pos, backgrd[HUDTYPE_2+2], [48, 96], HUDRGB_DEF, baralpha, 0);

	// Always draw ammo scores
	Hud_DrawNoFont8(pos + [10,0], getstatf(CLIENT_SHELLS), 3, FALSE, HUDFONT_YELLOW);
	Hud_DrawNoFont8(pos + [10,24], getstatf(CLIENT_NAILS), 3, FALSE, HUDFONT_YELLOW);
	Hud_DrawNoFont8(pos + [10,48], getstatf(CLIENT_ROCKETS), 3, FALSE, HUDFONT_YELLOW);
	Hud_DrawNoFont8(pos + [10,72], getstatf(CLIENT_CELLS), 3, FALSE, HUDFONT_YELLOW);

	// Draw weapons and highlight current one
	if (sitems & CSQC_SHOTGUN) Hud_DrawWeapon(0, HUDWPN_24, pos+[0,8]);
	if (smoditems & CSQC_UPGRADE_SSG) Hud_DrawWeapon(7, HUDWPN_24, pos+[24,8]);
	else if (sitems & CSQC_SUPER_SHOTGUN) Hud_DrawWeapon(1, HUDWPN_24, pos+[24,8]);
	if (sitems & CSQC_NAILGUN) Hud_DrawWeapon(2, HUDWPN_24, pos+[0,32]);
	if (sitems & CSQC_SUPER_NAILGUN) Hud_DrawWeapon(3, HUDWPN_24, pos+[24,32]);
	if (sitems & CSQC_GRENADE_LAUNCHER) Hud_DrawWeapon(4, HUDWPN_24, pos+[0,56]);
	if (sitems & CSQC_ROCKET_LAUNCHER) Hud_DrawWeapon(5, HUDWPN_24, pos+[24,56]);
	if (smoditems & CSQC_UPGRADE_LG) Hud_DrawWeapon(8, HUDWPN_32, pos+[0,80]);
	else if (sitems & CSQC_LIGHTNING) Hud_DrawWeapon(6, HUDWPN_32, pos+[0,80]);

	// Draw regular/upgrade axe
	if (sitems & CSQC_AXE) {
		if (smoditems & CSQC_UPGRADE_AXE)
			drawpic(pos+[32,80], ibitems[5], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
		else
			drawpic(pos+[32,80], ibitems[4], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	}
};
//----------------------------------------------------------------------
void (vector pos, vector br) Hud_DrawIBar2b =
{
	local vector topcol, botcol;
	local string player_frags;
	local float i, j;
	
	// Draw background bar using scr_sbaralpha default
	drawpic(pos, backgrd[HUDTYPE_2+3], [32, 96], HUDRGB_DEF, baralpha, 0);

	// Draw Classic ID powerups
	if (sitems & CSQC_INVISIBILITY)
		drawpic(pos+[0,32], ibitems[0], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_INVULNERABILITY)
		drawpic(pos+[16,32], ibitems[1], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_SUIT)
		drawpic(pos+[0,48], ibitems[2], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);

	// Draw Quad/Sharp/Pierce combo
	if (smoditems & CSQC_ARTSHARP)
		drawpic(pos+[16,48], ibitems[6], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	else if (smoditems & CSQC_ARTPIERCE)
		drawpic(pos+[16,48], ibitems[7], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	else if (sitems & CSQC_QUAD)
		drawpic(pos+[16,48], ibitems[3], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);

	// Draw New AD poweerups
	if (smoditems & CSQC_ARTJUMPBOOTS)
		drawpic(pos+[0,64], ibitems[8], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTBLASTBELT)
		drawpic(pos+[16,64], ibitems[9], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTAIRTANK)
		drawpic(pos+[0,80], ibitems[10], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTLAVASHIELD)
		drawpic(pos+[16,80], ibitems[11], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);	

	//should probably show team scores, but this mimics vanilla
	if (deathmatch) {
		// Loop through 4 players
		for (i = -1, j = 0; i >= -4; i--, j++) {
			// Read frag score of next player
			player_frags = getplayerkeyvalue(i, "frags");
			// No frags? stop loop
			if (player_frags == "") break;
			// Read deathmatch player top/bottom skin colours
			topcol = stov(getplayerkeyvalue(i, "topcolor_rgb"));
			botcol = stov(getplayerkeyvalue(i, "bottomcolor_rgb"));
			// Draw skin colours (alpha was 0.75 hardcoded)
			drawfill(pos+[0,1+(j*32)], [28,3], topcol, 0.75, 0);
			drawfill(pos+[0,4+(j*32)], [28,4], botcol, 0.75, 0);
			// Draw frag score (New global small font function)
			Hud_DrawNoFont8(pos+[2,0+(j*32)], stof(player_frags), 3, FALSE, HUDFONT_WHITE);
			// Find player entity attached to this HUD
			if (player_localentnum == stof(getplayerkeyvalue(i, "viewentity"))) {
				// special characters = [] 
				drawcharacter(pos+[-4,0+(j*32)], 0xe010, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
				drawcharacter(pos+[24,0+(j*32)], 0xe011, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
			}
		}
	}
	else {
		// Draw Custom Keys
		if (smoditems & CSQC_CKEY1)
			drawpic(pos+[0,16], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN1)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY2)
			drawpic(pos+[16,16], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN2)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY3)
			drawpic(pos+[0,24], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN3)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY4)
			drawpic(pos+[16,24], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN4)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
			
		// Draw Runes (special size + location)
		if (sitems2 & CSQC_RUNE1)
			drawpic(pos+[0,0], ibrunes[4], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE2)
			drawpic(pos+[8,0], ibrunes[5], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE3)
			drawpic(pos+[16,0], ibrunes[6], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE4)
			drawpic(pos+[24,0], ibrunes[7], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
	}
};

//----------------------------------------------------------------------
void (vector pos, vector br) Hud_DrawIBar3a =
{
};

//----------------------------------------------------------------------
void (vector pos, vector br) Hud_DrawIBar3b =
{
};

//----------------------------------------------------------------------
void (vector pos, vector br) Hud_DrawIBar4a =
{
	local vector topcol, botcol;
	local string player_frags;
	local float i, j;
	
	// Draw background bar using scr_sbaralpha default
	drawpic(pos, backgrd[HUDTYPE_4+2], [48, 64], HUDRGB_DEF, baralpha, 0);

	// Draw Classic ID powerups
	if (sitems & CSQC_INVISIBILITY)
		drawpic(pos+[0,16], ibitems[0], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_INVULNERABILITY)
		drawpic(pos+[16,16], ibitems[1], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_SUIT)
		drawpic(pos+[0,32], ibitems[2], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);

	// Draw Quad/Sharp/Pierce combo
	if (smoditems & CSQC_ARTSHARP)
		drawpic(pos+[16,32], ibitems[6], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	else if (smoditems & CSQC_ARTPIERCE)
		drawpic(pos+[16,32], ibitems[7], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	else if (sitems & CSQC_QUAD)
		drawpic(pos+[16,32], ibitems[3], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);

	// Draw New AD poweerups
	if (smoditems & CSQC_ARTJUMPBOOTS)
		drawpic(pos+[0,48], ibitems[8], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTBLASTBELT)
		drawpic(pos+[16,48], ibitems[9], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTAIRTANK)
		drawpic(pos+[32,48], ibitems[10], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTLAVASHIELD)
		drawpic(pos+[32,32], ibitems[11], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);	

	//should probably show team scores, but this mimics vanilla
	if (deathmatch) {
		// Loop through 4 players
		for (i = -1, j = 0; i >= -2; i--, j++) {
			// Read frag score of next player
			player_frags = getplayerkeyvalue(i, "frags");
			// No frags? stop loop
			if (player_frags == "") break;
			// Read deathmatch player top/bottom skin colours
			topcol = stov(getplayerkeyvalue(i, "topcolor_rgb"));
			botcol = stov(getplayerkeyvalue(i, "bottomcolor_rgb"));
			// Draw skin colours (alpha was 0.75 hardcoded)
			drawfill(pos+[0,1+(j*32)], [28,3], topcol, 0.75, 0);
			drawfill(pos+[0,4+(j*32)], [28,4], botcol, 0.75, 0);
			// Draw frag score (New global small font function)
			Hud_DrawNoFont8(pos+[2,0+(j*32)], stof(player_frags), 3, FALSE, HUDFONT_WHITE);
			// Find player entity attached to this HUD
			if (player_localentnum == stof(getplayerkeyvalue(i, "viewentity"))) {
				// special characters = [] 
				drawcharacter(pos+[-4,0+(j*32)], 0xe010, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
				drawcharacter(pos+[24,0+(j*32)], 0xe011, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
			}
		}
	}
	else {
		// Draw Custom Keys
		if (smoditems & CSQC_CKEY1)
			drawpic(pos+[32,0], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN1)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY2)
			drawpic(pos+[32,8], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN2)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY3)
			drawpic(pos+[32,16], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN3)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY4)
			drawpic(pos+[32,24], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN4)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
			
		// Draw Runes (special size + location)
		if (sitems2 & CSQC_RUNE1)
			drawpic(pos+[0,0], ibrunes[4], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE2)
			drawpic(pos+[8,0], ibrunes[5], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE3)
			drawpic(pos+[16,0], ibrunes[6], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE4)
			drawpic(pos+[24,0], ibrunes[7], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
	}
};

//----------------------------------------------------------------------
void (vector pos, vector br) Hud_DrawIBar4b =
{
	// Draw background bar using scr_sbaralpha default
	drawpic(pos, backgrd[HUDTYPE_4+3], [48, 64], HUDRGB_DEF, baralpha, 0);

	// Draw weapons and highlight current one
	if (sitems & CSQC_SHOTGUN) Hud_DrawWeapon(0, HUDWPN_24, pos+[0,0]);
	if (smoditems & CSQC_UPGRADE_SSG) Hud_DrawWeapon(7, HUDWPN_24, pos+[24,0]);
	else if (sitems & CSQC_SUPER_SHOTGUN) Hud_DrawWeapon(1, HUDWPN_24, pos+[24,0]);
	if (sitems & CSQC_NAILGUN) Hud_DrawWeapon(2, HUDWPN_24, pos+[0,16]);
	if (sitems & CSQC_SUPER_NAILGUN) Hud_DrawWeapon(3, HUDWPN_24, pos+[24,16]);
	if (sitems & CSQC_GRENADE_LAUNCHER) Hud_DrawWeapon(4, HUDWPN_24, pos+[0,32]);
	if (sitems & CSQC_ROCKET_LAUNCHER) Hud_DrawWeapon(5, HUDWPN_24, pos+[24,32]);
	if (smoditems & CSQC_UPGRADE_LG) Hud_DrawWeapon(8, HUDWPN_32, pos+[0,48]);
	else if (sitems & CSQC_LIGHTNING) Hud_DrawWeapon(6, HUDWPN_32, pos+[0,48]);

	// Draw regular/upgrade axe
	if (sitems & CSQC_AXE) {
		if (smoditems & CSQC_UPGRADE_AXE)
			drawpic(pos+[32,48], ibitems[5], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
		else
			drawpic(pos+[32,48], ibitems[4], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	}
};
	
//----------------------------------------------------------------------
void (vector pos, vector br) Hud_DrawIBar5a =
{
	local vector topcol, botcol;
	local string player_frags;
	local float i, j;
	
	// Draw background bar using scr_sbaralpha default
	drawpic(pos, backgrd2[HUDTYPE_5+2], [64, 48], HUDRGB_DEF, baralpha, 0);

	// Draw Classic ID powerups
	if (sitems & CSQC_INVISIBILITY)
		drawpic(pos+[0,16], ibitems[0], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_INVULNERABILITY)
		drawpic(pos+[16,16], ibitems[1], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_SUIT)
		drawpic(pos+[32,16], ibitems[2], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);

	// Draw Quad/Sharp/Pierce combo
	if (smoditems & CSQC_ARTSHARP)
		drawpic(pos+[48,16], ibitems[6], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	else if (smoditems & CSQC_ARTPIERCE)
		drawpic(pos+[48,16], ibitems[7], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	else if (sitems & CSQC_QUAD)
		drawpic(pos+[48,16], ibitems[3], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);

	// Draw New AD poweerups
	if (smoditems & CSQC_ARTJUMPBOOTS)
		drawpic(pos+[0,32], ibitems[8], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTBLASTBELT)
		drawpic(pos+[16,32], ibitems[9], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTAIRTANK)
		drawpic(pos+[32,32], ibitems[10], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTLAVASHIELD)
		drawpic(pos+[48,32], ibitems[11], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);	

	//should probably show team scores, but this mimics vanilla
	if (deathmatch) {
		// Loop through 4 players
		for (i = -1, j = 0; i >= -4; i--, j++) {
			// Check for second line
			if (j>1) { j=0; pos_y += 8; }
			// Read frag score of next player
			player_frags = getplayerkeyvalue(i, "frags");
			// No frags? stop loop
			if (player_frags == "") break;
			// Read deathmatch player top/bottom skin colours
			topcol = stov(getplayerkeyvalue(i, "topcolor_rgb"));
			botcol = stov(getplayerkeyvalue(i, "bottomcolor_rgb"));
			// Draw skin colours (alpha was 0.75 hardcoded)
			drawfill(pos+[0+(j*32),1], [28,3], topcol, 0.75, 0);
			drawfill(pos+[0+(j*32),4], [28,4], botcol, 0.75, 0);
			// Draw frag score (New global small font function)
			Hud_DrawNoFont8(pos+[2+(j*32),0], stof(player_frags), 3, FALSE, HUDFONT_WHITE);
			// Find player entity attached to this HUD
			if (player_localentnum == stof(getplayerkeyvalue(i, "viewentity"))) {
				// special characters = [] 
				drawcharacter(pos+[-4+(j*32),0], 0xe010, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
				drawcharacter(pos+[24+(j*32),0], 0xe011, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
			}
		}
	}
	else {
		// Draw Runes (special size + location)
		if (sitems2 & CSQC_RUNE1)
			drawpic(pos+[0,0], ibrunes[4], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE2)
			drawpic(pos+[8,0], ibrunes[5], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE3)
			drawpic(pos+[16,0], ibrunes[6], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE4)
			drawpic(pos+[24,0], ibrunes[7], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);

		// Draw Custom Keys
		if (smoditems & CSQC_CKEY1)
			drawpic(pos+[32,0], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN1)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY2)
			drawpic(pos+[48,0], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN2)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY3)
			drawpic(pos+[32,8], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN3)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY4)
			drawpic(pos+[48,8], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN4)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
	}
};	

//----------------------------------------------------------------------
void (vector pos, vector br) Hud_DrawIBar5b =
{
	// no point drawing, nothing to show!
	if (sweapon == 0) return;
	// Draw background bar using scr_sbaralpha default
	drawpic(pos, backgrd2[HUDTYPE_5+3], [48, 96], HUDRGB_DEF, baralpha, 0);

	// Draw weapons and highlight current one
	if (sitems & CSQC_SHOTGUN) Hud_DrawWeapon(0, HUDWPN_24, pos+[0,0]);
	if (smoditems & CSQC_UPGRADE_SSG) Hud_DrawWeapon(7, HUDWPN_24, pos+[24,0]);
	else if (sitems & CSQC_SUPER_SHOTGUN) Hud_DrawWeapon(1, HUDWPN_24, pos+[24,0]);
	if (sitems & CSQC_NAILGUN) Hud_DrawWeapon(2, HUDWPN_24, pos+[0,24]);
	if (sitems & CSQC_SUPER_NAILGUN) Hud_DrawWeapon(3, HUDWPN_24, pos+[24,24]);
	if (sitems & CSQC_GRENADE_LAUNCHER) Hud_DrawWeapon(4, HUDWPN_24, pos+[0,48]);
	if (sitems & CSQC_ROCKET_LAUNCHER) Hud_DrawWeapon(5, HUDWPN_24, pos+[24,48]);
	if (smoditems & CSQC_UPGRADE_LG) Hud_DrawWeapon(8, HUDWPN_32, pos+[0,72]);
	else if (sitems & CSQC_LIGHTNING) Hud_DrawWeapon(6, HUDWPN_32, pos+[0,72]);

	// Draw regular/upgrade axe
	if (sitems & CSQC_AXE) {
		if (smoditems & CSQC_UPGRADE_AXE)
			drawpic(pos+[32,72], ibitems[5], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
		else
			drawpic(pos+[32,72], ibitems[4], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	}
};	
	
//----------------------------------------------------------------------
void (vector pos, vector br) Hud_DrawIBar6 =
{
	local vector topcol, botcol;
	local string player_frags;
	local float i;
	
	// Draw background bar using scr_sbaralpha default
	drawpic(pos, backgrd2[HUDTYPE_6+2], [320, 24], HUDRGB_DEF, baralpha, 0);
	drawpic(pos+[320, 0], backgrd2[HUDTYPE_6+3], [320, 24], HUDRGB_DEF, baralpha, 0);

	// Always draw ammo scores
	Hud_DrawNoFont8(pos + [458,0], getstatf(CLIENT_SHELLS), 3, FALSE, HUDFONT_YELLOW);
	Hud_DrawNoFont8(pos + [506,0], getstatf(CLIENT_NAILS), 3, FALSE, HUDFONT_YELLOW);
	Hud_DrawNoFont8(pos + [554,0], getstatf(CLIENT_ROCKETS), 3, FALSE, HUDFONT_YELLOW);
	Hud_DrawNoFont8(pos + [602,0], getstatf(CLIENT_CELLS), 3, FALSE, HUDFONT_YELLOW);

	// Draw weapons and highlight current one
	if (sitems & CSQC_SHOTGUN) Hud_DrawWeapon(0, HUDWPN_24, pos+[448,8]);
	if (smoditems & CSQC_UPGRADE_SSG) Hud_DrawWeapon(7, HUDWPN_24, pos+[472,8]);
	else if (sitems & CSQC_SUPER_SHOTGUN) Hud_DrawWeapon(1, HUDWPN_24, pos+[472,8]);
	if (sitems & CSQC_NAILGUN) Hud_DrawWeapon(2, HUDWPN_24, pos+[496,8]);
	if (sitems & CSQC_SUPER_NAILGUN) Hud_DrawWeapon(3, HUDWPN_24, pos+[520,8]);
	if (sitems & CSQC_GRENADE_LAUNCHER) Hud_DrawWeapon(4, HUDWPN_24, pos+[544,8]);
	if (sitems & CSQC_ROCKET_LAUNCHER) Hud_DrawWeapon(5, HUDWPN_24, pos+[568,8]);
	if (smoditems & CSQC_UPGRADE_LG) Hud_DrawWeapon(8, HUDWPN_32, pos+[592,8]);
	else if (sitems & CSQC_LIGHTNING) Hud_DrawWeapon(6, HUDWPN_32, pos+[592,8]);

	// Draw regular/upgrade axe
	if (sitems & CSQC_AXE) {
		if (smoditems & CSQC_UPGRADE_AXE)
			drawpic(pos+[624,8], ibitems[5], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
		else
			drawpic(pos+[624,8], ibitems[4], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	}

	// Draw Classic ID powerups
	if (sitems & CSQC_INVISIBILITY)
		drawpic(pos+[0,8], ibitems[0], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_INVULNERABILITY)
		drawpic(pos+[16,8], ibitems[1], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_SUIT)
		drawpic(pos+[32,8], ibitems[2], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);

	// Draw Quad/Sharp/Pierce combo
	if (smoditems & CSQC_ARTSHARP)
		drawpic(pos+[48,8], ibitems[6], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	else if (smoditems & CSQC_ARTPIERCE)
		drawpic(pos+[48,8], ibitems[7], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	else if (sitems & CSQC_QUAD)
		drawpic(pos+[48,8], ibitems[3], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);

	// Draw New AD poweerups
	if (smoditems & CSQC_ARTJUMPBOOTS)
		drawpic(pos+[64,8], ibitems[8], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTBLASTBELT)
		drawpic(pos+[80,8], ibitems[9], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTAIRTANK)
		drawpic(pos+[96,8], ibitems[10], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTLAVASHIELD)
		drawpic(pos+[112,8], ibitems[11], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);	

	//should probably show team scores, but this mimics vanilla
	if (deathmatch) {
		// Loop through 4 players
		for (i = -1; i >= -4; i--) {
			// Read frag score of next player
			player_frags = getplayerkeyvalue(i, "frags");
			// No frags? stop loop
			if (player_frags == "") break;
			// Read deathmatch player top/bottom skin colours
			topcol = stov(getplayerkeyvalue(i, "topcolor_rgb"));
			botcol = stov(getplayerkeyvalue(i, "bottomcolor_rgb"));
			// Draw skin colours (alpha was 0.75 hardcoded)
			drawfill(pos+[0,1], [28,3], topcol, 0.75, 0);
			drawfill(pos+[0,4], [28,4], botcol, 0.75, 0);
			// Draw frag score (New global small font function)
			Hud_DrawNoFont8(pos+[2,0], stof(player_frags), 3, FALSE, HUDFONT_WHITE);
			// Find player entity attached to this HUD
			if (player_localentnum == stof(getplayerkeyvalue(i, "viewentity"))) {
				// special characters = [] 
				drawcharacter(pos+[-4,0], 0xe010, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
				drawcharacter(pos+[24,0], 0xe011, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
			}
			// Move forward to next hud space
			pos_x += 8*4;
		}
	}
	else {
		// Draw Runes (special size + location)
		if (sitems2 & CSQC_RUNE1)
			drawpic(pos+[0,0], ibrunes[0], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE2)
			drawpic(pos+[16,0], ibrunes[1], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE3)
			drawpic(pos+[32,0], ibrunes[2], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE4)
			drawpic(pos+[48,0], ibrunes[3], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);

		// Draw Custom Keys
		if (smoditems & CSQC_CKEY1)
			drawpic(pos+[64,0], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN1)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY2)
			drawpic(pos+[80,0], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN2)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY3)
			drawpic(pos+[96,0], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN3)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY4)
			drawpic(pos+[112,0], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN4)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
	}
};

//----------------------------------------------------------------------
void (vector pos, vector br, float grid) Hud_DrawIBar7a =
{
	// Draw background bar using scr_sbaralpha default
	if(grid >0 && grid <=1) 
		drawpic(pos, backgrd2[HUDTYPE_7+2], [96, 64], HUDRGB_DEF, grid, 0);

	// Alpha HP value only (no background
	Hud_DrawNoFont24(pos+[24,0], shealth, 25);

	// Deal with Pentagram first, its a simple test/update
	if (sitems & CSQC_INVULNERABILITY) {
		// Make sure 666 is in 24 pixel giant red numbers!
		Hud_DrawNoFont16(pos+[48,28], 666);
		// Draw a pentagram symbol in the armour HUD slot
		drawpic(pos+[24,24], sbitems[10], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}
	else {
		// Show armour type/quantity active
		if (getstatf(CLIENT_ARMOR) > 0)
			Hud_DrawNoFont16(pos+[48,28], getstatf(CLIENT_ARMOR));
		// Only 3 armour types (green/yellow/red)
		if (sitems & CSQC_ARMOR1)
			drawpic(pos+[24,24], sbitems[7], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ARMOR2)
			drawpic(pos+[24,24], sbitems[8], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ARMOR3)
			drawpic(pos+[24,24], sbitems[9], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		// Draw empty armour icon
		else drawpic(pos+[24,24], sbitems[6], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}
	// Draw Classic ID powerups
	if (sitems & CSQC_INVISIBILITY)
		drawpic(pos+[8,48], ibitems[0], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_INVULNERABILITY)
		drawpic(pos+[8,32], ibitems[1], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_SUIT)
		drawpic(pos+[8,16], ibitems[2], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);

	// Draw Quad/Sharp/Pierce combo
	if (smoditems & CSQC_ARTSHARP)
		drawpic(pos+[8,0], ibitems[6], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	else if (smoditems & CSQC_ARTPIERCE)
		drawpic(pos+[8,0], ibitems[7], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	else if (sitems & CSQC_QUAD)
		drawpic(pos+[8,0], ibitems[3], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);

	// Draw New AD poweerups
	if (smoditems & CSQC_ARTJUMPBOOTS)
		drawpic(pos+[24,48], ibitems[8], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTBLASTBELT)
		drawpic(pos+[40,48], ibitems[9], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTAIRTANK)
		drawpic(pos+[56,48], ibitems[10], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_ARTLAVASHIELD)
		drawpic(pos+[72,48], ibitems[11], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);	
};

//----------------------------------------------------------------------
void (vector pos, vector br, float grid) Hud_DrawIBar7b =
{
	local vector topcol, botcol;
	local string player_frags;
	local float ammorow,i,j;
	
	// Draw background bar using scr_sbaralpha default
	if(grid >0 && grid <=1) 
		drawpic(pos, backgrd2[HUDTYPE_7+3], [104, 56], HUDRGB_DEF, grid, 0);

	// Draw silver/gold key
	if (sitems & CSQC_KEY1)
		drawpic(pos+[72,0], sbitems[12], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_KEY2)
		drawpic(pos+[72,8], sbitems[13], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);

	// Show ammo type + quantity
	if (sweapon > 0 && sweapon < CSQC_AXE) {
		ammorow = 24;
		// Show ammo type + quantity
		Hud_DrawNoFont24(pos+[0,0], getstatf(CLIENT_AMMO), 10);
		if (!(sitems & CSQC_SHELLS)) {
			drawpic(pos+[60,ammorow], ammoqty[4], [8,8], HUDRGB_DEF, hudalpha, 0);
			Hud_DrawNoFont8(pos+[32,ammorow], getstatf(CLIENT_SHELLS), 3, FALSE, HUDFONT_YELLOW);
			ammorow = ammorow + 8;
		}
		if (!(sitems & CSQC_NAILS)) {
			drawpic(pos+[60,ammorow], ammoqty[5], [8,8], HUDRGB_DEF, hudalpha, 0);
			Hud_DrawNoFont8(pos+[32,ammorow], getstatf(CLIENT_NAILS), 3, FALSE, HUDFONT_YELLOW);
			ammorow = ammorow + 8;
		}
		if (!(sitems & CSQC_ROCKETS)) {
			drawpic(pos+[60,ammorow], ammoqty[6], [8,8], HUDRGB_DEF, hudalpha, 0);
			Hud_DrawNoFont8(pos+[32,ammorow], getstatf(CLIENT_ROCKETS), 3, FALSE, HUDFONT_YELLOW);
			ammorow = ammorow + 8;
		}
		if (!(sitems & CSQC_CELLS)) {
			drawpic(pos+[60,ammorow], ammoqty[7], [8,8], HUDRGB_DEF, hudalpha, 0);
			Hud_DrawNoFont8(pos+[32,ammorow], getstatf(CLIENT_CELLS), 3, FALSE, HUDFONT_YELLOW);
		}
	}

	//should probably show team scores, but this mimics vanilla
	if (deathmatch) {
		// Loop through 4 players
		for (i = -1, j = 2; i >= -4; i--, j++) {
			// Read frag score of next player
			player_frags = getplayerkeyvalue(i, "frags");
			// No frags? stop loop
			if (player_frags == "") break;
			// Read deathmatch player top/bottom skin colours
			topcol = stov(getplayerkeyvalue(i, "topcolor_rgb"));
			botcol = stov(getplayerkeyvalue(i, "bottomcolor_rgb"));
			// Draw skin colours (alpha was 0.75 hardcoded)
			drawfill(pos+[72,1+(j*8)], [28,3], topcol, 0.75, 0);
			drawfill(pos+[72,4+(j*8)], [28,4], botcol, 0.75, 0);
			// Draw frag score (New global small font function)
			Hud_DrawNoFont8(pos+[74,0+(j*8)], stof(player_frags), 3, FALSE, HUDFONT_WHITE);
			// Find player entity attached to this HUD
			if (player_localentnum == stof(getplayerkeyvalue(i, "viewentity"))) {
				// special characters = [] 
				drawcharacter(pos+[68,0+(j*8)], 0xe010, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
				drawcharacter(pos+[96,0+(j*8)], 0xe011, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
			}
		}
	}
	else {
		// Draw Custom Keys
		if (smoditems & CSQC_CKEY1)
			drawpic(pos+[72,16], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN1)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY2)
			drawpic(pos+[72,24], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN2)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY3)
			drawpic(pos+[72,32], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN3)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (smoditems & CSQC_CKEY4)
			drawpic(pos+[72,40], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN4)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		// Draw Runes (regular size)
		if (sitems2 & CSQC_RUNE1)
			drawpic(pos+[88,16], ibrunes[8], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE2)
			drawpic(pos+[88,24], ibrunes[9], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE3)
			drawpic(pos+[88,32], ibrunes[10], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (sitems2 & CSQC_RUNE4)
			drawpic(pos+[88,40], ibrunes[11], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
	}
};

//----------------------------------------------------------------------
void (vector pos, vector br, float grid) Hud_DrawIBar7c =
{
	// Draw background bar using scr_sbaralpha default
	if(grid >0 && grid <=1) 
		drawpic(pos, backgrd2[HUDTYPE_6+1], [32, 128], HUDRGB_DEF, grid, 0);

	// Draw weapons and highlight current one
	if (sitems & CSQC_SHOTGUN) Hud_DrawWeapon(0, HUDWPN_24, pos+[8,16]);
	if (smoditems & CSQC_UPGRADE_SSG) Hud_DrawWeapon(7, HUDWPN_24, pos+[8,32]);
	else if (sitems & CSQC_SUPER_SHOTGUN) Hud_DrawWeapon(1, HUDWPN_24, pos+[8,32]);
	if (sitems & CSQC_NAILGUN) Hud_DrawWeapon(2, HUDWPN_24, pos+[8,48]);
	if (sitems & CSQC_SUPER_NAILGUN) Hud_DrawWeapon(3, HUDWPN_24, pos+[8,64]);
	if (sitems & CSQC_GRENADE_LAUNCHER) Hud_DrawWeapon(4, HUDWPN_24, pos+[8,80]);
	if (sitems & CSQC_ROCKET_LAUNCHER) Hud_DrawWeapon(5, HUDWPN_24, pos+[8,96]);
	if (smoditems & CSQC_UPGRADE_LG) Hud_DrawWeapon(8, HUDWPN_32, pos+[0,112]);
	else if (sitems & CSQC_LIGHTNING) Hud_DrawWeapon(6, HUDWPN_32, pos+[0,112]);

	// Draw regular/upgrade axe
	if (sitems & CSQC_AXE) {
		if (smoditems & CSQC_UPGRADE_AXE)
			drawpic(pos+[16,0], ibitems[5], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
		else
			drawpic(pos+[16,0], ibitems[4], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	}
};

//----------------------------------------------------------------------
void (vector pos, vector br) Hud_DrawIBar8a =
{
};

//----------------------------------------------------------------------
void (vector pos, vector br) Hud_DrawIBar8b =
{
};

//----------------------------------------------------------------------
void (vector pos, vector br) Hud_DrawIBar9 =
{
};

//======================================================================
// STATUS BARS
//
// - shows armour / health and current ammo/qty
// - multiple setups for different hud layouts
//
//======================================================================
// SBar1 is default ID layout, used for Huds 0,2,3
void (vector pos, vector virtsize) Hud_DrawSBar0 =
{
	// Draw primary HUD bar (Armour/Face/Health/Ammo)
	drawpic(pos, backgrd[HUDTYPE_0], [320, 24], HUDRGB_DEF, baralpha, 0);

	// Deal with Pentagram first, its a simple test/update
	if (sitems & CSQC_INVULNERABILITY) {
		// Make sure 666 is in 24 pixel giant red numbers!
		Hud_DrawNoFont24(pos+[24,0], 666, 666);
		// Draw a pentagram symbol in the armour HUD slot
		drawpic(pos, sbitems[10], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}
	else {
		// Show armour type/quantity active
		Hud_DrawNoFont24(pos+[24,0], getstatf(CLIENT_ARMOR), 25);
		// Only 3 armour types (green/yellow/red)
		if (sitems & CSQC_ARMOR1)
			drawpic(pos, sbitems[7], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ARMOR2)
			drawpic(pos, sbitems[8], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ARMOR3)
			drawpic(pos, sbitems[9], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		// Draw empty armour icon
		else drawpic(pos, sbitems[6], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}

	// Draw face + HP value
	Hud_DrawFace(pos+[112,0]);
	Hud_DrawNoFont24(pos+[136,0], shealth, 25);

	// Show axe/upgrade separately (no ammo displayed)
	if (sweapon == CSQC_AXE) {
		if (smoditems & CSQC_UPGRADE_AXE)
			drawpic(pos+[224,0], sbitems[5], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else
			drawpic(pos+[224,0], sbitems[4], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}
	else {
		// Show ammo type + quantity
		if (sweapon > 0) Hud_DrawNoFont24(pos+[248,0], getstatf(CLIENT_AMMO), 10);
		if (sitems & CSQC_SHELLS)
			drawpic(pos+[224,0], sbitems[0], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_NAILS)
			drawpic(pos+[224,0], sbitems[1], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ROCKETS)
			drawpic(pos+[224,0], sbitems[2], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_CELLS)
			drawpic(pos+[224,0], sbitems[3], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}

	// Draw silver/gold key new location on Status Bar
	if (sitems & (CSQC_KEY1 | CSQC_KEY2)) {
		// New key background (only show when got a SK/GK)
		drawpic(pos+[208,0], sbitems[11], HUDSIZE_1624, HUDRGB_DEF, hudalpha, 0);
		if (sitems & CSQC_KEY1)
			drawpic(pos+[208,4], sbitems[12], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (sitems & CSQC_KEY2)
			drawpic(pos+[208,12], sbitems[13], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
	}
};

//----------------------------------------------------------------------
void (vector pos, vector virtsize) Hud_DrawSBar4a =
{
	// Draw primary HUD bar (Armour/Face/Health/Ammo)
	drawpic(pos, backgrd[HUDTYPE_4+0], [96, 48], HUDRGB_DEF, baralpha, 0);

	// Deal with Pentagram first, its a simple test/update
	if (sitems & CSQC_INVULNERABILITY) {
		// Make sure 666 is in 24 pixel giant red numbers!
		Hud_DrawNoFont24(pos+[0,24], 666, 666);
		// Draw a pentagram symbol in the armour HUD slot
		drawpic(pos+[72,24], sbitems[10], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}
	else {
		// Show armour type/quantity active
		Hud_DrawNoFont24(pos+[0,24], getstatf(CLIENT_ARMOR), 25);
		// Only 3 armour types (green/yellow/red)
		if (sitems & CSQC_ARMOR1)
			drawpic(pos+[72,24], sbitems[7], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ARMOR2)
			drawpic(pos+[72,24], sbitems[8], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ARMOR3)
			drawpic(pos+[72,24], sbitems[9], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		// Draw empty armour icon
		else drawpic(pos+[72,24], sbitems[6], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}

	// Draw face + HP value
	Hud_DrawFace(pos+[72,0]);
	Hud_DrawNoFont24(pos+[0,0], shealth, 25);
	
};

//----------------------------------------------------------------------
void (vector pos, vector virtsize) Hud_DrawSBar4b =
{
	// Draw primary HUD bar (Armour/Face/Health/Ammo)
	drawpic(pos, backgrd[HUDTYPE_4+1], [96, 48], HUDRGB_DEF, baralpha, 0);
	
	// Draw ammo scores
	if (!(sitems & CSQC_SHELLS))
		Hud_DrawNoFont8(pos + [20,3], getstatf(CLIENT_SHELLS), 3, FALSE, HUDFONT_YELLOW);
	if (!(sitems & CSQC_NAILS))
		Hud_DrawNoFont8(pos + [60,3], getstatf(CLIENT_NAILS), 3, FALSE, HUDFONT_YELLOW);
	if (!(sitems & CSQC_ROCKETS))
		Hud_DrawNoFont8(pos + [20,13], getstatf(CLIENT_ROCKETS), 3, FALSE, HUDFONT_YELLOW);
	if (!(sitems & CSQC_CELLS))
		Hud_DrawNoFont8(pos + [60,13], getstatf(CLIENT_CELLS), 3, FALSE, HUDFONT_YELLOW);


	// Show axe/upgrade separately (no ammo displayed)
	if (sweapon == CSQC_AXE) {
		if (smoditems & CSQC_UPGRADE_AXE)
			drawpic(pos+[0,24], sbitems[5], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else
			drawpic(pos+[0,24], sbitems[4], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}
	else {
		// Show ammo type + quantity
		if (sweapon > 0) Hud_DrawNoFont24(pos+[24,24], getstatf(CLIENT_AMMO), 10);
		if (sitems & CSQC_SHELLS)
			drawpic(pos+[0,24], sbitems[0], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_NAILS)
			drawpic(pos+[0,24], sbitems[1], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ROCKETS)
			drawpic(pos+[0,24], sbitems[2], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_CELLS)
			drawpic(pos+[0,24], sbitems[3], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}

	// Draw silver/gold key new location on Status Bar
	if (sitems & (CSQC_KEY1 | CSQC_KEY2)) {
		if (sitems & CSQC_KEY1)
			drawpic(pos+[0,4], sbitems[12], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (sitems & CSQC_KEY2)
			drawpic(pos+[0,12], sbitems[13], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
	}
};

//----------------------------------------------------------------------
void (vector pos, vector virtsize) Hud_DrawSBar5a =
{
	// Draw face first (bar is over face)
	Hud_DrawFace(pos+[8,8]);
	// Draw primary HUD bar (Armour/Face/Health/Ammo)
	drawpic(pos, backgrd2[HUDTYPE_5+0], [64, 48], HUDRGB_DEF, baralpha, 0);
	
	// Alpha HP value only (no background
	Hud_DrawNoFont24(pos+[40,0], shealth, 25);

	// Deal with Pentagram first, its a simple test/update
	if (sitems & CSQC_INVULNERABILITY) {
		// Make sure 666 is in 24 pixel giant red numbers!
		Hud_DrawNoFont16(pos+[64,28], 666);
		// Draw a pentagram symbol in the armour HUD slot
		drawpic(pos+[40,24], sbitems[10], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}
	else {
		// Show armour type/quantity active
		if (getstatf(CLIENT_ARMOR) > 0)
			Hud_DrawNoFont16(pos+[64,28], getstatf(CLIENT_ARMOR));
		// Only 3 armour types (green/yellow/red)
		if (sitems & CSQC_ARMOR1)
			drawpic(pos+[40,24], sbitems[7], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ARMOR2)
			drawpic(pos+[40,24], sbitems[8], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ARMOR3)
			drawpic(pos+[40,24], sbitems[9], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		// Draw empty armour icon
		else drawpic(pos+[40,24], sbitems[6], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}
	// Draw silver/gold key new location on Status Bar
	if (sitems & (CSQC_KEY1 | CSQC_KEY2)) {
		if (sitems & CSQC_KEY1)
			drawpic(pos+[4,36], sbitems[12], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (sitems & CSQC_KEY2)
			drawpic(pos+[20,36], sbitems[13], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
	}
};

//----------------------------------------------------------------------
void (vector pos, vector virtsize) Hud_DrawSBar5b =
{
	local float ammorow;
	
	// no point drawing, nothing to show!
	if (sweapon == 0) return;
	// Draw primary HUD bar (Armour/Face/Health/Ammo)
	drawpic(pos, backgrd2[HUDTYPE_5+1], [48, 48], HUDRGB_DEF, baralpha, 0);
	
	// Show axe/upgrade separately (no ammo displayed)
	if (sweapon == CSQC_AXE) {
		if (smoditems & CSQC_UPGRADE_AXE)
			drawpic(pos+[24,0], sbitems[5], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else
			drawpic(pos+[24,0], sbitems[4], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}
	else {
		ammorow = 24;
		// Show ammo type + quantity
		Hud_DrawNoFont24(pos+[-48,0], getstatf(CLIENT_AMMO), 10);
		if (sitems & CSQC_SHELLS)
			drawpic(pos+[24,0], sbitems[0], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else {
			drawpic(pos+[0,ammorow], ammoqty[0], [48,8], HUDRGB_DEF, hudalpha, 0);
			Hud_DrawNoFont8(pos+[10,ammorow], getstatf(CLIENT_SHELLS), 3, FALSE, HUDFONT_YELLOW);
			ammorow = ammorow + 8;
		}
		if (sitems & CSQC_NAILS)
			drawpic(pos+[24,0], sbitems[1], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else {
			drawpic(pos+[0,ammorow], ammoqty[1], [48,8], HUDRGB_DEF, hudalpha, 0);
			Hud_DrawNoFont8(pos+[10,ammorow], getstatf(CLIENT_NAILS), 3, FALSE, HUDFONT_YELLOW);
			ammorow = ammorow + 8;
		}
		if (sitems & CSQC_ROCKETS)
			drawpic(pos+[24,0], sbitems[2], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else {
			drawpic(pos+[0,ammorow], ammoqty[2], [48,8], HUDRGB_DEF, hudalpha, 0);
			Hud_DrawNoFont8(pos+[10,ammorow], getstatf(CLIENT_ROCKETS), 3, FALSE, HUDFONT_YELLOW);
			ammorow = ammorow + 8;
		}
		if (sitems & CSQC_CELLS)
			drawpic(pos+[24,0], sbitems[3], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else {
			drawpic(pos+[0,ammorow], ammoqty[3], [48,8], HUDRGB_DEF, hudalpha, 0);
			Hud_DrawNoFont8(pos+[10,ammorow], getstatf(CLIENT_CELLS), 3, FALSE, HUDFONT_YELLOW);
		}
	}
};

//----------------------------------------------------------------------
void (vector pos, vector virtsize, float bckgrd) Hud_DrawSBar6 =
{
	// Draw primary HUD bar (Armour/Face/Health/Ammo)
	if (bckgrd) drawpic(pos, backgrd2[HUDTYPE_6+0], [416, 24], HUDRGB_DEF, baralpha, 0);

	// Deal with Pentagram first, its a simple test/update
	if (sitems & CSQC_INVULNERABILITY) {
		// Make sure 666 is in 24 pixel giant red numbers!
		Hud_DrawNoFont24(pos+[40,0], 666, 666);
		// Draw a pentagram symbol in the armour HUD slot
		drawpic(pos+[16,0], sbitems[10], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}
	else {
		// Show armour type/quantity active
		Hud_DrawNoFont24(pos+[40,0], getstatf(CLIENT_ARMOR), 25);
		// Only 3 armour types (green/yellow/red)
		if (sitems & CSQC_ARMOR1)
			drawpic(pos+[16,0], sbitems[7], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ARMOR2)
			drawpic(pos+[16,0], sbitems[8], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ARMOR3)
			drawpic(pos+[16,0], sbitems[9], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		// Draw empty armour icon
		else drawpic(pos+[16,0], sbitems[6], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}

	// Draw face + HP value
	Hud_DrawFace(pos+[128,0]);
	Hud_DrawNoFont24(pos+[152,0], shealth, 25);

	// Show axe/upgrade separately (no ammo displayed)
	if (sweapon == CSQC_AXE) {
		if (smoditems & CSQC_UPGRADE_AXE)
			drawpic(pos+[224,0], sbitems[5], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else
			drawpic(pos+[224,0], sbitems[4], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}
	else {
		// Show ammo type + quantity
		if (sweapon > 0) Hud_DrawNoFont24(pos+[248,0], getstatf(CLIENT_AMMO), 10);
		if (sitems & CSQC_SHELLS)
			drawpic(pos+[224,0], sbitems[0], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_NAILS)
			drawpic(pos+[224,0], sbitems[1], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ROCKETS)
			drawpic(pos+[224,0], sbitems[2], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_CELLS)
			drawpic(pos+[224,0], sbitems[3], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}

	// Draw silver/gold key new location on Status Bar
	if (sitems & (CSQC_KEY1 | CSQC_KEY2)) {
		// New key background (only show when got a SK/GK)
		drawpic(pos+[0,0], sbitems[11], HUDSIZE_1624, HUDRGB_DEF, hudalpha, 0);
		if (sitems & CSQC_KEY1)
			drawpic(pos+[0,4], sbitems[12], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
		if (sitems & CSQC_KEY2)
			drawpic(pos+[0,12], sbitems[13], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
	}
	
	// Only draw ammo if drawing background
	if (bckgrd) {
		// Draw ammo scores
		Hud_DrawNoFont8(pos + [328,3], getstatf(CLIENT_SHELLS), 3, FALSE, HUDFONT_YELLOW);
		Hud_DrawNoFont8(pos + [376,3], getstatf(CLIENT_NAILS), 3, FALSE, HUDFONT_YELLOW);
		Hud_DrawNoFont8(pos + [328,13], getstatf(CLIENT_ROCKETS), 3, FALSE, HUDFONT_YELLOW);
		Hud_DrawNoFont8(pos + [376,13], getstatf(CLIENT_CELLS), 3, FALSE, HUDFONT_YELLOW);
	}
};

//----------------------------------------------------------------------
void (vector pos, vector virtsize, float grid) Hud_DrawSBar7a =
{
	// Draw primary HUD bar (Armour/Health)
	if(grid >0 && grid <=1) 
		drawpic(pos, backgrd2[HUDTYPE_7+0], [72, 48], HUDRGB_DEF, grid, 0);

	// Alpha HP value only (no background
	Hud_DrawNoFont24(pos+[0,0], shealth, 25);

	// Deal with Pentagram first, its a simple test/update
	if (sitems & CSQC_INVULNERABILITY) {
		// Make sure 666 is in 24 pixel giant red numbers!
		Hud_DrawNoFont16(pos+[24,28], 666);
		// Draw a pentagram symbol in the armour HUD slot
		drawpic(pos+[0,24], sbitems[10], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}
	else {
		// Show armour type/quantity active
		if (getstatf(CLIENT_ARMOR) > 0)
			Hud_DrawNoFont16(pos+[24,28], getstatf(CLIENT_ARMOR));
		// Only 3 armour types (green/yellow/red)
		if (sitems & CSQC_ARMOR1)
			drawpic(pos+[0,24], sbitems[7], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ARMOR2)
			drawpic(pos+[0,24], sbitems[8], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ARMOR3)
			drawpic(pos+[0,24], sbitems[9], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		// Draw empty armour icon
		else drawpic(pos+[0,24], sbitems[6], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}
};

//----------------------------------------------------------------------
void (vector pos, vector virtsize, float grid) Hud_DrawSBar7b =
{
	// Draw primary HUD bar (Ammo/Keys)
	if(grid >0 && grid <=1) 
		drawpic(pos, backgrd2[HUDTYPE_7+1], [88, 40], HUDRGB_DEF, grid, 0);

	// Draw Custom Keys
	if (smoditems & CSQC_CKEY1)
		drawpic(pos+[72,0], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN1)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_CKEY2)
		drawpic(pos+[72,8], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN2)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_CKEY3)
		drawpic(pos+[72,16], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN3)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
	if (smoditems & CSQC_CKEY4)
		drawpic(pos+[72,24], ibckeys[Hud_CKeyRange(CLIENT_CKEYSKIN4)], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);

	// Show ammo type + quantity
	if (sweapon > 0 && sweapon < CSQC_AXE) 
		Hud_DrawNoFont24(pos+[0,0], getstatf(CLIENT_AMMO), 10);

	// Draw silver/gold key
	if (sitems & CSQC_KEY1)
		drawpic(pos+[40,24], sbitems[12], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_KEY2)
		drawpic(pos+[56,24], sbitems[13], HUDSIZE_168, HUDRGB_DEF, hudalpha, 0);
};

//----------------------------------------------------------------------
void (vector pos, vector virtsize) Hud_DrawSBar8a =
{
};

//----------------------------------------------------------------------
void (vector pos, vector virtsize) Hud_DrawSBar8b =
{
};

//----------------------------------------------------------------------
void (vector pos, vector virtsize) Hud_DrawSBar9 =
{
};

//======================================================================
// SCOREBOARD BARS
//
// - shows monster/secret quantities and map info
// - multiple setups for different hud layouts
//
//======================================================================
void(vector pos, float bx, float by, float bwidth, float bheight, float pixelspeed, string draw_str) Hud_ScrollTextBox =
{
	local float str_width, str_double, str_speed;
	local string wide_str;
	
	// draw debug visual box to show area on screen
	//drawfill( pos+[bx,by], [bwidth,bheight], HUDRGB_DEF, 0.1, 0);

	// Find out width of string in pixels (using font 8)
	str_width = stringwidth( draw_str, TRUE, HUDSIZE_8);
	// String less than window width?
	if (str_width < bwidth) {
		// Center the map name string in the box area
		str_double = (bwidth - str_width) / 2;
		// Display string normally (no scrolling required)
		drawstring( pos+[bx+str_double, by], draw_str, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	}
	else {
		// Create double length string with boundary marker
		wide_str = strcat(draw_str, " /// ", draw_str);
		// Setup clip (scissor) area for exclusive drawing
		drawsetcliparea( pos_x + bx, pos_y + by, bwidth, bheight);
		str_double = stringwidth( wide_str, TRUE, HUDSIZE_8);
		// create offset of string to make it look like its scrolling
		str_speed = mod(cltime * pixelspeed, (str_double - str_width));
		// draw string (with offset) inside of clip (scissor) area only
		drawstring( pos+[bx - str_speed, by], wide_str, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
		// Reset clip string area to default
		drawresetcliparea();
	}
};

//----------------------------------------------------------------------
// Quakespasm scoreboard layout (no time) 
//----------------------------------------------------------------------
void(vector pos) Hud_DrawScoreBar_QS =
{
	local string skill_str, map_str;
	local float digit;
	
	// Clear status bar ready for map info/scores
	drawpic(pos, backgrd[HUDTYPE_0+1], [320, 24], HUDRGB_DEF, baralpha, 0);
	// Display headings
	drawstring(pos+[8,12], "Kills:", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	drawstring(pos+[80,12], "/", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);	
	drawstring(pos+[132,12], "Skill ", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	drawstring(pos+[208,12], "Secrets:", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	drawstring(pos+[288,12], "/", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);	
	// Display monster/secret totals
	Hud_DrawNoFont8(pos+[56,12], getstatf(CLIENT_KILLEDMONSTERS), 3, FALSE, HUDFONT_WHITE);
	if (getstatf(CLIENT_TOTALMONSTERS) < 100) digit = 2;
	else digit = 3;
	Hud_DrawNoFont8(pos+[88,12], getstatf(CLIENT_TOTALMONSTERS), digit, FALSE, HUDFONT_WHITE);
	Hud_DrawNoFont8(pos+[272,12], getstatf(CLIENT_FOUNDSECRETS), 2, FALSE, HUDFONT_WHITE);
	Hud_DrawNoFont8(pos+[296,12], getstatf(CLIENT_TOTALSECRETS), 2, FALSE, HUDFONT_WHITE);
	// Display map skill level
	skill_str = autocvar(skill, "1");
	drawstring(pos+[180,12], skill_str, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);	

	// Level designers Map name + File name
	map_str = strcat(world.message, " (", mapname, ")");
	Hud_ScrollTextBox(pos, 8, 4, 304, 8, 16, map_str);
};

//----------------------------------------------------------------------
// QS scoreboard layout (time at bottom and skill with map name) 
//----------------------------------------------------------------------
void(vector pos) Hud_DrawScoreBar_QSClock =
{
	local string skill_str, map_str;
	local float digit, skill_no;
	local float nsecs, nmins;
	
	// Clear status bar ready for map info/scores
	drawpic(pos, backgrd[HUDTYPE_0+1], [320, 24], HUDRGB_DEF, baralpha, 0);
	// Display headings
	drawstring(pos+[8,12], "Kills:", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	drawstring(pos+[80,12], "/", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);	
	//drawstring(pos+[112,12], "Time", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	drawstring(pos+[208,12], "Secrets:", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	drawstring(pos+[288,12], "/", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);	
	// Display monster/secret totals
	Hud_DrawNoFont8(pos+[56,12], getstatf(CLIENT_KILLEDMONSTERS), 3, FALSE, HUDFONT_WHITE);
	if (getstatf(CLIENT_TOTALMONSTERS) < 100) digit = 2;
	else digit = 3;
	Hud_DrawNoFont8(pos+[88,12], getstatf(CLIENT_TOTALMONSTERS), digit, FALSE, HUDFONT_WHITE);
	Hud_DrawNoFont8(pos+[272,12], getstatf(CLIENT_FOUNDSECRETS), 2, FALSE, HUDFONT_WHITE);
	Hud_DrawNoFont8(pos+[296,12], getstatf(CLIENT_TOTALSECRETS), 2, FALSE, HUDFONT_WHITE);
	// Work out time passed
	nmins = floor(time/60);
	nsecs = floor(time - nmins*60);
	Hud_DrawNoFont8(pos+[128,12], nmins, 3, FALSE, HUDFONT_WHITE);
	drawstring(pos+[152,12], ":", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);	
	Hud_DrawNoFont8(pos+[162,12], nsecs, 2, TRUE, HUDFONT_WHITE);
	// Display map skill level
	skill_no = stof(autocvar(skill, "1"));
	if (skill_no == 0) skill_str = "Easy";
	else if (skill_no == 1) skill_str = "Normal";
	else if (skill_no == 2) skill_str = "Hard";
	else if (skill_no == 3) skill_str = "Nightmare";
	else skill_str = "Unknown";
	// Level designers Map name + Skill level name
	map_str = strcat(world.message, " (", skill_str, ")");
	Hud_ScrollTextBox(pos, 8, 4, 304, 8, 16, map_str);
};

//----------------------------------------------------------------------
// The original ID scoreboard layout (no skill, map filename)
//----------------------------------------------------------------------
void(vector pos) Hud_DrawScoreBar_ID =
{
	local float nsecs, nmins;
	
	// Clear status bar ready for map info/scores
	drawpic(pos, backgrd[HUDTYPE_0+1], [320, 24], HUDRGB_DEF, baralpha, 0);
	// Display headings
	drawstring(pos+[8,4], "Monsters:", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);	
	drawstring(pos+[104,4], "/", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);	
	drawstring(pos+[8,12], "Secrets :", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	drawstring(pos+[104,12], "/", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);	
	drawstring(pos+[184,4], "Time :", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	drawstring(pos+[256,4], ":", HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);	
	// Display monster/secret totals
	Hud_DrawNoFont8(pos+[80,4], getstatf(CLIENT_KILLEDMONSTERS), 3, FALSE, HUDFONT_WHITE);
	Hud_DrawNoFont8(pos+[112,4], getstatf(CLIENT_TOTALMONSTERS), 3, FALSE, HUDFONT_WHITE);
	Hud_DrawNoFont8(pos+[80,12], getstatf(CLIENT_FOUNDSECRETS), 3, FALSE, HUDFONT_WHITE);
	Hud_DrawNoFont8(pos+[112,12], getstatf(CLIENT_TOTALSECRETS), 3, FALSE, HUDFONT_WHITE);
	// Work out time passed
	nmins = floor(time/60);
	nsecs = floor(time - nmins*60);
	Hud_DrawNoFont8(pos+[232,4], nmins, 3, FALSE, HUDFONT_WHITE);
	Hud_DrawNoFont8(pos+[264,4], nsecs, 2, TRUE, HUDFONT_WHITE);
	// Level designers Map name
	Hud_ScrollTextBox(pos, 140, 12, 176, 8, 16, world.message);
};

//======================================================================
// SCOREBOARD - DEATHMATCH
// - Shows table of players with frags/ping
//
//======================================================================
vector(string picname, float height) Hud_AspectSize =
{
	local vector sz;
	sz = drawgetimagesize(picname);
	return [sz_x * height/sz_y, height];
};

//----------------------------------------------------------------------
void(string picname, float screenwidth, vector pos, float height) Hud_CentrePic =
{
	local vector sz;
	sz = Hud_AspectSize(picname, height);
	pos_x += (screenwidth-sz_x)/2;
	drawpic(pos, picname, sz, HUDRGB_DEF, hudalpha, 0);
};

//----------------------------------------------------------------------
void(vector virtmin, vector virtsize) Hud_DrawDeathmatch_Table =
{
	local float isspec, i; 
	local vector pos, topcol, botcol;
	string player_name, player_frags, player_ping;
	
	// Working copy
	pos = virtmin;
	
	// Check for 16 players?
	player_name = getplayerkeyvalue(-16, "name");
	if (player_name == "") pos_y += (virtsize_y-200)/2;

	// Only draw the header when its not a really big game
	player_name = getplayerkeyvalue(-24, "name");
	if (player_name == "") {	
		pos_y += 8;
		// Display header (ranking.lmp) gfx for DM scoreboard
		Hud_CentrePic(backlmp[0], virtsize_x, pos, 24);
		// A double update of Y, only spike knows why!?!
		pos_y += 24; pos_y += 10;
	}

	// Another double X update, no idea why!
	pos_x += (virtsize_x-320)/2;
	pos_x += 80;

	//negative numbers are players sorted by frags.
	for (i = -1; ; i--, pos_y += 10) {
		// Check for next player name
		player_name = getplayerkeyvalue(i, "name");
		// No more in list, end loop
		if (player_name == "") break;
		
		// Read player stats (frag/ping)
		isspec = stof(getplayerkeyvalue(i, "*spectator"));
		player_frags = getplayerkeyvalue(i, "frags");
		player_ping = getplayerkeyvalue(i, "ping");
		// Read deathmatch player top/bottom skin colours
		topcol = stov(getplayerkeyvalue(i, "topcolor_rgb"));
		botcol = stov(getplayerkeyvalue(i, "bottomcolor_rgb"));
		
		// Re-format the player name (no case conversion, force red)
		player_name = strconv(0,2,2, player_name);
		// Draw frag score (New global small font function)
		Hud_DrawNoFont8(pos-[8*5,0], stof(player_ping), 3, FALSE, HUDFONT_WHITE);
		
		// Which type of player? Spectator or Active?
		if (isspec)
			drawstring(pos+[4,0], "spec", [8,8], HUDRGB_DEF, hudalpha, 0);
		else
		{
			// Draw skin colours (alpha was 0.75 hardcoded)
			drawfill(pos+[0,0], [40,4], topcol, 0.75, 0);
			drawfill(pos+[0,4], [40,4], botcol, 0.75, 0);
			
			// Draw frag score (New global small font function)
			Hud_DrawNoFont8(pos+[8,0], stof(player_frags), 3, FALSE, HUDFONT_WHITE);
			// Find player entity attached to this HUD
			if (player_localentnum == stof(getplayerkeyvalue(i, "viewentity"))) {
				// special characters = [] 
				drawcharacter(pos+[0,0], 0xe010, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
				drawcharacter(pos+[32,0], 0xe011, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
			}
		}
		// Finally draw player name
		drawstring(pos+[64,0], player_name, HUDSIZE_8, HUDRGB_DEF, hudalpha, 0);
	}
};

//======================================================================
// SCOREBOARD - Intermission
// - Shows summary of monster/secrets completed
//
//======================================================================
void(vector virtmin, vector virtsize) Hud_DrawIntermission =
{
	local vector pos;
	// Create positions based on virtual screen
	pos = virtmin + (virtsize-[320,200])/2;

	// Draw Intermission title and table info (Time/secret/kill)
	Hud_CentrePic(backlmp[1], 320, pos+[0,24], 24);
	drawpic(pos+[0,56], backlmp[2], [160,144], HUDRGB_DEF, hudalpha, 0);
	
	// Generate complete string and then draw 1 character at time
	// Uses Sprintf function to feed values into final string
	// This function should be supported by Advanced engines
	Hud_DrawCharFont24(pos+[144, 64], sprintf("%3.0f:%02.0f", intermission_time/60, intermission_time%60));
	Hud_DrawCharFont24(pos+[144, 104], sprintf("%3.0f/%.0f", getstatf(CLIENT_FOUNDSECRETS), getstatf(CLIENT_TOTALSECRETS)));
	Hud_DrawCharFont24(pos+[144, 144], sprintf("%3.0f/%.0f", getstatf(CLIENT_KILLEDMONSTERS), getstatf(CLIENT_TOTALMONSTERS)));
};

//======================================================================
// DRAW HUD (main entry point)
//
// - Updates client/sever variables and setup weapon flash timers
// - Decide which huds to draw based on scratch1 variable
//
//======================================================================
void(vector virtsize, float showscores) CSQC_DrawHud =
{
	local vector pos, hudbar;
	local float oitems, omoditems, i;
	local float hudviewsize, hudlayout, hudreverse, hudgrid;
	local float hud_xofs, hud_yofs, hud_mofs, hudscale;
	
	// Save previous HUD versions for flash function
	oitems = sitems; omoditems = smoditems;
	
	//------------------------------------------------------------------
	// All variables have to be specially setup and passed between
	// progs and csprogs as they are not connected in VM space
	// By default CSQC has 30 (most commonly used) parameters setup
	// Unfortunately some of them need to be converted (bitshifted)
	// to make them reaable again (I blame spike for this mess)
	// The downside to this bitswapping mess is that the serverflags
	// is not passed to CSQC completely, only the first 9bits (runes)
	//------------------------------------------------------------------
	// getstatbits is re-using getstatf with 2 extra optional parameters
	sitems = getstatbits(CLIENT_ITEMS, 0, 23);	
	sitems2 = getstatbits(CLIENT_ITEMS, 23, 9);
	sweapon = getstatf(CLIENT_ACTIVEWEAPON);
	shealth = getstatf(CLIENT_HEALTH);
	smoditems = getstatf(CLIENT_MODITEMS);

	// Don't show HUD, intermission or dead
	if (intermission || shealth <= 0) return;
	
	//------------------------------------------------------------------
	// Read console variable for background HUD alpha
	baralpha = cvar("scr_sbaralpha");
	if (baralpha == 0) baralpha = 0.75;
	// Default is 1 for everything else
	hudalpha = 1;

	//------------------------------------------------------------------
	// Check if any weapons have been added to the inventory
	// Update time so the flash function can detect it
	// Check for player count for splitscreen!?! QSS/FTE feature
	if (numclientseats <= 1 && shealth > 0) {
		// Check for any weapon changes?
		if (sitems != oitems) {
			// Go through all weapon slots
			for (i = 0; i < WPN_SLOTS; i++) {
				// Found weapon and its new?
				if ( (sitems & (1<<i)) && !(oitems & (1<<i)) )
					// Reset timer
					flashtime[i] = time;
			}
		}
		// Check for AD weapon upgrades?
		if (smoditems != omoditems) {
			if (smoditems & CSQC_UPGRADE_SSG && !(omoditems & CSQC_UPGRADE_SSG))
				flashtime[7] = time;
			if (smoditems & CSQC_UPGRADE_LG && !(omoditems & CSQC_UPGRADE_LG))
				flashtime[8] = time;
		}
	}

	//------------------------------------------------------------------
	// Find out how much of the HUD is being displayed
	// 100 = InfoBar & StatusBar (ALL=Default)
	// 110 = StatusBar Only
	// 120 = Nothing
	//------------------------------------------------------------------
	// Read current HUD size
	hudviewsize = cvar("viewsize");
	// Any HUD to display?
	if (hudviewsize < 120) {
		// Override scoreboard - check if no player health
		if (shealth <= 0) showscores = TRUE;
		// Find out mid point of screen
		pos_x = virtsize_x/2;
		pos_y = 0; pos_z = 0;
		hud_xofs = 0 - (320/2);
		hud_yofs = 0 + (virtsize_y/2);

		// Find out HUD layout and reversing (check ranges)
		hudlayout = cvar("scratch1");
		hudreverse = FALSE;
		// +100 for reverse hud option
		if (hudlayout > CSQC_HUDREV) {
			hudreverse = TRUE;
			hudlayout = hudlayout - CSQC_HUDREV;
		}
		// Check for negative range issues
		if (hudlayout < 0) hudlayout = 0;
		
		// Find out HUD virtual scaling
		hudscale = cvar("scr_sbarscale");
		// Always have a default if cvar does not exist!
		if (hudscale < 1) hudscale = 1;
		
		//------------------------------------------------------------------
		// Default (status/inventory) at bottom
		if (hudlayout == 0) {
			// Setup top/bottom Y offset for all 3 parts (bottom=default)
			// Inventory bar split into 2, hence the hudbar variable mess
			// Literally every part of the hud is in a different place!
			if (hudreverse == TRUE) hudbar = [0, 24, 40];
			else hudbar = [virtsize_y-24, virtsize_y-40, virtsize_y-48];
			// Either show Sbar or Scores (bars are centered)
			if (showscores) Hud_DrawScoreBar_QS(pos + [hud_xofs, hudbar_x]);
			else Hud_DrawSBar0(pos + [hud_xofs, hudbar_x], virtsize);
			// Can the Info Bar be displayed?
			if (hudviewsize < 110) {
				// Draw weapons/powerups
				Hud_DrawIBar0a(pos + [hud_xofs, hudbar_y], virtsize);
				// Draw ammo quantites + keys
				Hud_DrawIBar0b(pos + [hud_xofs, hudbar_z], virtsize);
			}
		}
		//------------------------------------------------------------------
		// Side Inventory Bar (locked to the status bar)
		else if (hudlayout == 1) {
			// Setup top/bottom Y offset (bottom=default)
			if (hudreverse == FALSE) hud_yofs = virtsize_y-24;
			else hud_yofs = 0;
			// Either show Sbar or Scores (bars are centered)
			if (showscores) Hud_DrawScoreBar_QS(pos + [hud_xofs-16, hud_yofs]);
			else Hud_DrawSBar0(pos + [hud_xofs-16, hud_yofs], virtsize);
			// Can the Info Bar be displayed?
			if (hudviewsize < 110) {
				// Adjust Y offset for inventory at bottom
				if (hudreverse == FALSE) hud_yofs = virtsize_y-48;
				Hud_DrawIBar1a(pos + [hud_xofs+304, hud_yofs], virtsize);
				Hud_DrawIBar1b(pos + [hud_xofs-80, hud_yofs], virtsize);
			}
		}
		//------------------------------------------------------------------
		// Side Inventory Bar (Double width icons)
		else if (hudlayout == 2) {
			// Setup top/bottom Y offset (bottom=default)
			if (hudreverse == FALSE) hud_yofs = virtsize_y-24;
			else hud_yofs = 0;
			// Either show Sbar or Scores (bars are centered)
			if (showscores) Hud_DrawScoreBar_QS(pos + [hud_xofs, hud_yofs]);
			else Hud_DrawSBar0(pos + [hud_xofs, hud_yofs], virtsize);
			// Can the Info Bar be displayed?
			if (hudviewsize < 110) {
				// The inventory bar is centered down sides
				hud_yofs = (virtsize_y/2) - 48;
				Hud_DrawIBar2b([0, hud_yofs], virtsize);
				Hud_DrawIBar2a([virtsize_x-48, hud_yofs], virtsize);
			}
		}
		//------------------------------------------------------------------
		// Side Inventory Bar (Single icons down sides)
		else if (hudlayout == 3) {
		}
		//------------------------------------------------------------------
		// Doom layout (markie)
		// Designed for 1440+ screen with middle gap adjusting to width
		// 960=-48, 1280=-16, 1440=0, 1680=24, 1920=48
		else if (hudlayout == 4) {
			// Setup top/bottom Y offset (bottom=default)
			if (hudreverse == FALSE) hud_yofs = virtsize_y-48;
			else hud_yofs = 0;
			// Adjust the middle gap based on virtual size
			hud_mofs = ((virtsize_x*hudscale)-1440)/10;
			// Scores layered over the top of status (bars are centered)
			Hud_DrawSBar4a(pos + [hud_xofs-hud_mofs, hud_yofs], virtsize);
			Hud_DrawSBar4b(pos + [hud_xofs+224+hud_mofs, hud_yofs], virtsize);
			// Adjust Y offset for inventory at bottom
			if (hudreverse == FALSE) hud_yofs = virtsize_y-24;
			if (showscores) Hud_DrawScoreBar_QS(pos + [hud_xofs, hud_yofs]);
			// Can the Info Bar be displayed?
			if (hudviewsize < 110) {
				// Adjust Y offset for inventory at bottom
				if (hudreverse == FALSE) hud_yofs = virtsize_y-64;
				Hud_DrawIBar4a(pos + [hud_xofs-(48+hud_mofs), hud_yofs], virtsize);
				Hud_DrawIBar4b(pos + [hud_xofs+320+hud_mofs, hud_yofs], virtsize);
			}
		}
		//------------------------------------------------------------------
		// Quake Champions layout (markie)
		else if (hudlayout == 5) {
			// Setup top/bottom Y offset (bottom=default)
			if (hudreverse == FALSE) hud_yofs = virtsize_y-48;
			else hud_yofs = 0;
			// The inventory bar pushes the sbar into the center
			if (hudviewsize < 110) Hud_DrawSBar5a([64, hud_yofs], virtsize);
			else Hud_DrawSBar5a([0, hud_yofs], 0);
			// Draw condensed ammo quantities
			Hud_DrawSBar5b([virtsize_x-48, hud_yofs], virtsize);
			// Can the Info Bar be displayed?
			if (hudviewsize < 110) {
				// Extra powerups, keys and runes
				Hud_DrawIBar5a([0, hud_yofs], virtsize);
			}
			
			// Weapon bar added to both huds (100+110)
			// Place all the weapon stuff above ammo count
			if (hudreverse == FALSE) hud_yofs = virtsize_y-192;
			else hud_yofs = 64;
			// Double wide weapons down right side (virtsize_y-144)
			//Hud_DrawIBar5b([virtsize_x-48, hud_yofs], virtsize);
			// Markie wanted single weapon setup from hud 7
			Hud_DrawIBar7c([virtsize_x-32, hud_yofs], virtsize, 0);
			
			// Always show Scoreboard in the middle
			if (hudreverse == FALSE) hud_yofs = virtsize_y-24;
			else hud_yofs = 0;
			if (showscores) Hud_DrawScoreBar_QS(pos + [hud_xofs, hud_yofs]);
		}
		//------------------------------------------------------------------
		// Wide screen layout (bal)
		else if (hudlayout == 6) {
			// Setup top/bottom Y offset (bottom=default)
			if (hudreverse == FALSE) hud_yofs = virtsize_y-24;
			else hud_yofs = 0;
			// Bar layout completely different for each HUD type
			if (hudviewsize <= 100) {
				// Extra wide (640) bar (cut into 2x320 pieces)
				Hud_DrawIBar6(pos + [0 - (640/2), hud_yofs], virtsize);
				// Draw the scoreboard over the top of existing hud
				if (showscores) Hud_DrawScoreBar_QSClock(pos + [hud_xofs-32, hud_yofs]);
				// Re-use previous Sbar function with no background option
				else Hud_DrawSBar6(pos + [hud_xofs-32, hud_yofs], virtsize, FALSE);
			}
			else if (hudviewsize <= 110) {
				if (showscores) {
					// Switch to extra wide + scoreboard on top
					Hud_DrawIBar6(pos + [0 - (640/2), hud_yofs], virtsize);
					Hud_DrawScoreBar_QSClock(pos + [hud_xofs-32, hud_yofs]);
				}
				else {
					// Wide (416) status bar (+ammo qty on right)
					Hud_DrawSBar6(pos + [0 - (416/2), hud_yofs], virtsize, TRUE);
				}
			}
		}
		//------------------------------------------------------------------
		// Central HUD layout (fairweather)
		else if (hudlayout == 7) {
			hudgrid = FALSE;
			// The hud elements are around the middle of the screen
			hud_xofs = virtsize_x/2; hud_yofs = virtsize_y/2;
			// Middle gap
			hud_mofs = 48;
			// Bar layout completely different for each HUD type
			// Can the Info Bar be displayed?
			if (hudviewsize <= 100) {
				Hud_DrawIBar7a([hud_xofs-(96+24+hud_mofs), hud_yofs+48], virtsize, hudgrid);
				Hud_DrawIBar7b([hud_xofs+hud_mofs, hud_yofs+48], virtsize, hudgrid);
				Hud_DrawIBar7c([virtsize_x-32, hud_yofs-32], virtsize, hudgrid);
			}
			else if (hudviewsize <= 110) {
				// Scores at bottom and hud bits around middle
				Hud_DrawSBar7a([hud_xofs-(72+24+hud_mofs), hud_yofs+48], virtsize, hudgrid);
				Hud_DrawSBar7b([hud_xofs+hud_mofs, hud_yofs+48], virtsize, hudgrid);
			}
			if (showscores) {
				// Scoreboard top/bottom Y offset (bottom=default)
				if (hudreverse == FALSE) hud_yofs = virtsize_y-24;
				else hud_yofs = 0;
				Hud_DrawScoreBar_QSClock(pos + [(0 - (320/2)), hud_yofs]);
			}
		}
		//------------------------------------------------------------------
		// Quake Live layout (giftmacher)
		else if (hudlayout == 8) {
		}
		//------------------------------------------------------------------
		// ??? (sock)
		else if (hudlayout == 9) {
		}
	}
};

//----------------------------------------------------------------------
void(vector virtsize, float showscores) CSQC_DrawScores =
{
	shealth = getstatf(CLIENT_HEALTH);
	if (intermission || showscores || shealth <= 0) {
		if (deathmatch) Hud_DrawDeathmatch_Table('0 0 0', virtsize);
		else if (intermission) Hud_DrawIntermission('0 0 0', virtsize);
	}
};

//----------------------------------------------------------------------
// This is mainly used by DP (hence all the scene stuff)
//----------------------------------------------------------------------
void(float vwidth, float vheight, float notmenu) CSQC_UpdateView =
{
	local vector ssize;
	ssize_x = vwidth; ssize_y = vheight; ssize_z = 0;
	
	// Is the CSQC functionality enabled/disabled?
	nocsqc = cvar("cl_nocsqc");

	clearscene();
	addentities(MASK_ENGINE|MASK_VIEWMODEL);
	setproperty(VF_MIN, '0 0');
	setproperty(VF_SIZE, ssize);
	// If hud is disabled, draw engine hud instead
	setproperty(VF_DRAWENGINESBAR, nocsqc);
	setproperty(VF_DRAWCROSSHAIR, TRUE);
	renderscene();
	
	// Revert back to using engine HUD?
	if (nocsqc > 0) return;
	
	// Required for DP engine
	if (detectDP == TRUE) {
		ssize_x = cvar("vid_conwidth");
		ssize_y = cvar("vid_conheight");
	}
	
	// Used on intermission screen later
	if (!intermission) intermission_time = time;
	// Read deathmatch variable and create csprogs coop variable
	// csprogs has no knowledge of the coop variable
	deathmatch = stof(serverkey("deathmatch"));
	coop = !deathmatch && maxclients > 1;
	
	// Draw the HUDs and scoreboards
	// ssize is the video mode size
	CSQC_DrawHud(ssize, sb_showscores);
	CSQC_DrawScores(ssize, sb_showscores);
};

//----------------------------------------------------------------------
// Registers HUD gfx images (all setup in string arrays)
//----------------------------------------------------------------------
void(float apilevel, string enginename, float engineversion) CSQC_Init =
{
	local float i, wadonly;
	
	// Is the CSQC functionality enabled/disabled?
	nocsqc = cvar("cl_nocsqc");
	// Revert back to using engine HUD?
	if (nocsqc > 0) return;

	// Send ping back to server that CSQC client is alive
	// This can be used on the server side to detect CSQC
	// and change functions for new features 
	localcmd(strcat("cmd ", CSQC_PING, "\n"));
	
	// precache from gfx.wad ONLY!?!
	wadonly = FALSE;
	
	// Cache all string tables
	for (i = 0; i < 16; i++) {
		// HUD background images (various sizes)
		if (i < backgrd.length) precache_pic(backgrd[i], wadonly);
		if (i < backgrd2.length) precache_pic(backgrd2[i], wadonly);
		// Small ammo quantity lines (32x8)
		if (i < ammoqty.length) precache_pic(ammoqty[i], wadonly);
		// Large brown/red numbers (24x24 and 16x16)
		if (i < adn24.length) {
			precache_pic(adn24[i], wadonly);
			precache_pic(adn24a[i], wadonly);
			precache_pic(adn16[i], wadonly);
		}
		// Large 24x24 extra font characters (intermission)
		if (i < extrachar.length) precache_pic(extrachar[i], wadonly);
		// Large 24x24 player face
		if (i < faceid.length) precache_pic(faceid[i], wadonly);
		if (i < facead.length) precache_pic(facead[i], wadonly);
		// Large 24x24 icons
		if (i < sbitems.length) precache_pic(sbitems[i], wadonly);
		// Small 16x16 icons
		if (i < ibitems.length) precache_pic(ibitems[i], wadonly);
		// Special 8x16 runes
		if (i < ibrunes.length) precache_pic(ibrunes[i], wadonly);
		// All weapon setups (on/off/flashing)
		if (i < weaponnames.length) {
			precache_pic(strcat(weaponselect[0], weaponnames[i]), wadonly);
			precache_pic(strcat(weaponselect[1], weaponnames[i]), wadonly);
			precache_pic(strcat(weaponflash[0], weaponnames[i]), wadonly);
			precache_pic(strcat(weaponflash[1], weaponnames[i]), wadonly);
			precache_pic(strcat(weaponflash[2], weaponnames[i]), wadonly);
			precache_pic(strcat(weaponflash[3], weaponnames[i]), wadonly);
			precache_pic(strcat(weaponflash[4], weaponnames[i]), wadonly);
		}
	}
};

//----------------------------------------------------------------------
// Wrapper for CSQC_Init to try and detect DP engine
//----------------------------------------------------------------------
__wrap void(float apilevel, string enginename, float engineversion) CSQC_Init =
{
	// Try to detect DP engine (needed for CSQC_UpdateView later)
	if (!apilevel && !enginename && !engineversion) detectDP = TRUE;
	// Execute previous CSQC_Init function
	prior(apilevel, enginename, engineversion);
	
	registercommand("+showscores");
	registercommand("+showscores");
	// Different scoreboards for DM and Team DM
	// AD is aimed at SP/Coop only, not included
	//registercommand("+showteamscores");
	//registercommand("+showteamscores");
};

//----------------------------------------------------------------------
// Wrapper for CSQC_ConsoleCommand to show different scoreboards
//----------------------------------------------------------------------
__wrap float(string str) CSQC_ConsoleCommand =
{
    if (prior(str))
        return TRUE;
    string c = argv(0);
    if (c == "+showscores")
        sb_showscores |= 1;
    else if (c == "-showscores")
        sb_showscores &~= 1;
	// Different scoreboards for DM and Team DM
	// AD is aimed at SP/Coop only, not included
    //else if (c == "+showteamscores")
    //    sb_showscores |= 2;
    //else if (c == "-showteamscores")
    //    sb_showscores &~= 2;
    else return FALSE;
    return TRUE;
};
