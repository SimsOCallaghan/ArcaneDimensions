/*======================================================================
 All CSQC functions (Vanilla ONLY version)
 
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

// Default sizes for HUD elements
vector HUDSIZE_320 = '320 24 0';	// Background images
vector HUDSIZE_24 = '24 24 0';		// Status Bar
vector HUDSIZE_16 = '16 16 0';		// Inventory/Powerups
vector HUDSIZE_816 = '8 16 0';		// Runes
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
// Statue, Inventory and Score bars (All 320 x 24)
string backgrd[3] = { "gfx/sbar", "gfx/ibar", "gfx/scorebar" };
// Ranking (168 x 24), Complete (184 x 24), Inter (160 x 144)
// Require .lmp extensions if not loaded diectly from GFX file
string backlmp[3] = { "gfx/ranking.lmp", "gfx/complete.lmp", "gfx/inter.lmp" };

//----------------------------------------------------------------------
// Regular (24x24) brown numbers
string number[10] = {
	"gfx/num_0", "gfx/num_1", "gfx/num_2", "gfx/num_3", "gfx/num_4",
	"gfx/num_5", "gfx/num_6", "gfx/num_7", "gfx/num_8", "gfx/num_9"
};
// Red (24x24) numbers for no armour, low HP (<25) and no ammo
string anumber[10] = {
	"gfx/anum_0", "gfx/anum_1", "gfx/anum_2", "gfx/anum_3", "gfx/anum_4",
	"gfx/anum_5", "gfx/anum_6", "gfx/anum_7", "gfx/anum_8", "gfx/anum_9"
};

// Regular (24x24) characters for intermission
string extrachar[3] = {
	"gfx/num_colon", "gfx/num_minus", "gfx/num_slash"
};

// 24x24 pixel icons for Status Bar
string sbitems[8] = {
	"gfx/sb_shells", "gfx/sb_nails", "gfx/sb_rocket", "gfx/sb_cells",
	"gfx/sb_armor1", "gfx/sb_armor2", "gfx/sb_armor3", "gfx/disc"
};

// 16x16 pixel icons for Information Bar
string ibitems[6] = {
	"gfx/sb_key1", "gfx/sb_key2", "gfx/sb_invis", "gfx/sb_invuln",
	"gfx/sb_suit", "gfx/sb_quad"
};

// 8x16 pixel runes for Information Bar
string ibrunes[4] = {
	"gfx/sb_sigil1", "gfx/sb_sigil2", "gfx/sb_sigil3", "gfx/sb_sigil4"
};

//----------------------------------------------------------------------
// All weapon HUD graphics are prefixed with certain characters which
// means all weapon filenames can be generated with string commands
// CSQC is really an advanced (QSS/FTE/DP) engine only thing and its
// very likely that FTE_STRINGS is supported for string manipulation
//----------------------------------------------------------------------
// Special constants for weapons
float WPN_ICONS = 7;	// Total weapons to precache pics + flash timers
float WPN_WIDTHLG = 6;	// Odd weapon gfx width (48) default (24)	
// Record when weapons have been added (flash mechanic)
float flashtime[WPN_ICONS];

// Shotgun, SuperShotgun, Nailgun, SuperNailGun, GrenadeLauncher
// RocketLauncher, LightningGun
string weaponnames[WPN_ICONS] = {
	"shotgun", "sshotgun", "nailgun", "snailgun", "rlaunch",
	"srlaunch", "lightng"
};
// OFF / ON gfx (reflects active weapon)
string weaponselect[2] = { "gfx/inv_", "gfx/inv2_" };
// Special flash set for when the player gets weapon
string weaponflash[5] = { "gfx/inva1_","gfx/inva2_","gfx/inva3_","gfx/inva4_","gfx/inva5_" };

//----------------------------------------------------------------------
// Frame 00-04 : Regular HP 100/80/60/40/20
// Frame 05-09 : InPain  HP 100/80/60/40/20
// Frame 10    : Invisibility Ring + Pentagram! 
// Frame 11    : Quad Damage
// Frame 12    : Invisibility Ring
// Frame 13    : Pentagram (invulnerability)
//----------------------------------------------------------------------
string facetab[14] = {
	"gfx/face5", "gfx/face4", "gfx/face3", "gfx/face2", "gfx/face1",
	"gfx/face_p5", "gfx/face_p4", "gfx/face_p3", "gfx/face_p2", "gfx/face_p1",
	"gfx/face_inv2", "gfx/face_quad", "gfx/face_invis", "gfx/face_invul2"
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
		if (disp_col) disp_str = anumber[disp_no];
		else disp_str = number[disp_no];
		// Draw number in correct (right-justified) position
		drawpic(pos, disp_str, HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);	
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
			drawpic(pos, number[c], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
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
	
	// Start with InvRing as it has two states
	if (sitems & CSQC_INVISIBILITY) {
		// InvRing + Pentagram!?! WTF!?! SandyP E4 design!
		if (sitems & CSQC_INVULNERABILITY) face = facetab[10];
		// Just InvRing only
		else face = facetab[12];
	}
	// Quad only
	else if (sitems & CSQC_QUAD) face = facetab[11];
	// Pentagram only
	else if (sitems & CSQC_INVULNERABILITY) face = facetab[13];
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
		face = facetab[hpframe];
	}
	
	// Draw face - always 24x24 size, full rgb/alpha
	drawpic(pos, face, HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
};

//----------------------------------------------------------------------
// Update a weapon icon with selection or flash features
//----------------------------------------------------------------------
static void(float num, vector pos) Hud_DrawWeapon =
{
	local string prefix, file_str;
	local vector gfx_size;
	local float flash;
	
	// The weapon flash is done every 0.1s and repeated twice!
	// When the player gets a new weapon the time is reset
	// This function will count the time difference for flashing
	// Convert the flash time to a 0-10+ range
	flash = (time - flashtime[num])*10;
	
	// Has the flash happened twice? (finished)
	if (flash >= 10) {
		// Work out if this weapon is currently selected
		if (sweapon == (1<<num)) prefix = weaponselect[1];
		// Default is no highlight
		else prefix = weaponselect[0];
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
	
	// Most weapons are 24 pixels wide (half of ammo above)
	// As always there is an exception (lightning gun)
	if (num == WPN_WIDTHLG) gfx_size = HUDWPN_48;
	else gfx_size = HUDWPN_24;
	// Show weapon GFX (active/deactive/flashing)
	drawpic(pos, file_str, gfx_size, HUDRGB_DEF, hudalpha, 0);
};

//======================================================================
// STATUS BAR ( Armour / Health quantities and current Ammo selected)
//----------------------------------------------------------------------
void (vector pos, vector virtsize) Hud_DrawSBar =
{
	// Draw primary HUD bar (Armour/Face/Health/Ammo)
	drawpic(pos, backgrd[0], HUDSIZE_320, HUDRGB_DEF, baralpha, 0);

	// Deal with Pentagram first, its a simple test/update
	if (sitems & CSQC_INVULNERABILITY) {
		// Make sure 666 is in 24 pixel giant red numbers!
		Hud_DrawNoFont24(pos+[24,0], 666, 666);
		// Draw a pentagram symbol in the armour HUD slot
		drawpic(pos, sbitems[7], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}
	else {
		// Show armour type/quantity active
		Hud_DrawNoFont24(pos+'24 0 0', getstatf(CLIENT_ARMOR), 25);
		// Only 3 armour types (green/yellow/red)
		if (sitems & CSQC_ARMOR1)
			drawpic(pos, sbitems[4], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ARMOR2)
			drawpic(pos, sbitems[5], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ARMOR3)
			drawpic(pos, sbitems[6], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}

	// Draw face + HP value
	Hud_DrawFace(pos+[112,0]);
	Hud_DrawNoFont24(pos+[136,0], shealth, 25);

	// Only update ammo type/quantity if not using axe!
	if (sweapon != CSQC_AXE) { 
		Hud_DrawNoFont24(pos+[248,0], getstatf(CLIENT_AMMO), 10);
		if (sitems & CSQC_SHELLS)
			drawpic(pos+[224,0], sbitems[0], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_NAILS)
			drawpic(pos+[224,0], sbitems[1], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_ROCKETS)
			drawpic(pos+[224,0], sbitems[2], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
		else if (sitems & CSQC_CELLS)
			drawpic(pos+[224,0], sbitems[3], HUDSIZE_24, HUDRGB_DEF, hudalpha, 0);
	}
};

//======================================================================
// INVENTORY BAR ( Ammo quantities, keys/runes and powerups )
//----------------------------------------------------------------------
void (vector pos, vector br) Hud_DrawIBar =
{
	local vector topcol, botcol;
	local string player_frags;
	
	// Draw background bar using scr_sbaralpha default
	drawpic(pos, backgrd[1], HUDSIZE_320, HUDRGB_DEF, baralpha, 0);

	// Always draw ammo scores
	Hud_DrawNoFont8(pos + [10,0], getstatf(CLIENT_SHELLS), 3, FALSE, HUDFONT_YELLOW);
	Hud_DrawNoFont8(pos + [58,0], getstatf(CLIENT_NAILS), 3, FALSE, HUDFONT_YELLOW);
	Hud_DrawNoFont8(pos + [106,0], getstatf(CLIENT_ROCKETS), 3, FALSE, HUDFONT_YELLOW);
	Hud_DrawNoFont8(pos + [154,0], getstatf(CLIENT_CELLS), 3, FALSE, HUDFONT_YELLOW);

	// Draw weapons and highlight current one
	if (sitems & CSQC_SHOTGUN)			Hud_DrawWeapon(0, pos+[24*0,8]);
	if (sitems & CSQC_SUPER_SHOTGUN)	Hud_DrawWeapon(1, pos+[24*1,8]);
	if (sitems & CSQC_NAILGUN)			Hud_DrawWeapon(2, pos+[24*2,8]);
	if (sitems & CSQC_SUPER_NAILGUN)	Hud_DrawWeapon(3, pos+[24*3,8]);
	if (sitems & CSQC_GRENADE_LAUNCHER)	Hud_DrawWeapon(4, pos+[24*4,8]);
	if (sitems & CSQC_ROCKET_LAUNCHER)	Hud_DrawWeapon(5, pos+[24*5,8]);
	if (sitems & CSQC_LIGHTNING)		Hud_DrawWeapon(6, pos+[24*6,8]);

	// Draw inventory items
	if (sitems & CSQC_KEY1)
		drawpic(pos+[192,8], ibitems[0], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_KEY2)
		drawpic(pos+[208,8], ibitems[1], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_INVISIBILITY)
		drawpic(pos+[224,8], ibitems[2], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_INVULNERABILITY)
		drawpic(pos+[240,8], ibitems[3], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_SUIT)
		drawpic(pos+[256,8], ibitems[4], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);
	if (sitems & CSQC_QUAD)
		drawpic(pos+[272,8], ibitems[5], HUDSIZE_16, HUDRGB_DEF, hudalpha, 0);

	// Draw Runes (special size + location)
	if (sitems2 & CSQC_RUNE1)
		drawpic(pos+[288,8], ibrunes[0], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
	if (sitems2 & CSQC_RUNE2)
		drawpic(pos+[296,8], ibrunes[1], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
	if (sitems2 & CSQC_RUNE3)
		drawpic(pos+[304,8], ibrunes[2], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);
	if (sitems2 & CSQC_RUNE4)
		drawpic(pos+[312,8], ibrunes[3], HUDSIZE_816, HUDRGB_DEF, hudalpha, 0);

	//should probably show team scores, but this mimics vanilla
	if (deathmatch) {
		// Move to space above powerups
		pos_x += 194;
		
		// Loop through 4 players
		for (float i = -1; i >= -4; i--) {
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
			Hud_DrawNoFont8(pos + '2 0 0', stof(player_frags), 3, FALSE, HUDFONT_WHITE);
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
};

//======================================================================
// Scoreboard Bar (shows monster/secret quantities and map info)
//----------------------------------------------------------------------
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
void(vector pos) Hud_QSScores_SBar =
{
	local string skill_str, map_str;
	local float digit;
	
	// Clear status bar ready for map info/scores
	drawpic(pos, backgrd[2], HUDSIZE_320, HUDRGB_DEF, baralpha, 0);
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
// The original ID scoreboard layout (no skill, map filename)
//----------------------------------------------------------------------
void(vector pos) Hud_IDScores_SBar =
{
	local float nsecs, nmins;
	
	// Clear status bar ready for map info/scores
	drawpic(pos, backgrd[2], HUDSIZE_320, HUDRGB_DEF, baralpha, 0);
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
// Deathmatch scoreboard
//----------------------------------------------------------------------
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
void(vector virtmin, vector virtsize) Hud_DMScoreboard =
{
	local float isspec; 
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
	for (float i = -1; ; i--, pos_y += 10) {
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
// Final Intermission
//----------------------------------------------------------------------
void(vector virtmin, vector virtsize) Hud_Intermission =
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
// MAIN ENTRY POINT FOR HUD!!!
//----------------------------------------------------------------------
void(vector virtsize, float showscores) CSQC_DrawHud =
{
	local vector pos;
	local float oitems, hudviewsize, i;

	// Save previous HUD versions for flash function
	oitems = sitems;

	//------------------------------------------------------------------
	// All variables have to be specially setup and passed between
	// progs and csprogs as they are not connected in VM space
	// By default CSQC has 30 (most commonly used) parameters setup
	// Unfortunately some of them need to be converted (bitswapped)
	// to make them reaable again (I blame spike for this mess)
	// The downside to this bitswapping mess is that the serverflags
	// is not passed to CSQC completely, only the first 4bits (runes)
	//------------------------------------------------------------------
	sitems = getstatbits(CLIENT_ITEMS, 0, 23);	
	sitems2 = getstatbits(CLIENT_ITEMS, 23, 9);
	sweapon = getstatf(CLIENT_ACTIVEWEAPON);
	shealth = getstatf(CLIENT_HEALTH);

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
	if (numclientseats <= 1) {
		// Player alive and inventory changd?
		if (shealth && sitems != oitems) {
			// Go through all weapon flash counters
			for (i = 0; i < WPN_ICONS; i++) {
				// Found weapon and its new?
				if ((sitems & (1<<i)) && !(oitems & (1<<i)))
					// Reset timer
					flashtime[i] = time;
			}
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
		pos_x = (virtsize_x-320)/2;
		pos_y = virtsize_y;
		pos_z = 0;

		// Either show Sbar or Scores (bars are centered)
		if (showscores) Hud_QSScores_SBar(pos - '0 24 0');
		else Hud_DrawSBar(pos - '0 24 0', virtsize);
		// Can the Info Bar be displayed?
		if (hudviewsize < 110)
			Hud_DrawIBar(pos - '0 48 0', virtsize);
	}
};

//----------------------------------------------------------------------
void(vector virtsize, float showscores) CSQC_DrawScores =
{
	shealth = getstatf(CLIENT_HEALTH);
	if (intermission || showscores || shealth <= 0) {
		if (deathmatch) Hud_DMScoreboard('0 0 0', virtsize);
		else if (intermission) Hud_Intermission('0 0 0', virtsize);
	}
};

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
	wadonly = TRUE;
	
	// Cache all string tables
	for (i = 0; i < 14; i++) {
		// HUD background images (320 wide+)
		if (i < backgrd.length) precache_pic(backgrd[i], wadonly);
		// Large 24x24 brown/red numbers
		if (i < number.length) {
			precache_pic(number[i], wadonly);
			precache_pic(anumber[i], wadonly);
		}
		// Large 24x24 extra font characters (intermission)
		if (i < extrachar.length) precache_pic(extrachar[i], wadonly);
		// Large 24x24 player face
		if (i < facetab.length) precache_pic(facetab[i], wadonly);
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
	registercommand("+showteamscores");
	registercommand("+showteamscores");
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
    else if (c == "+showteamscores")
        sb_showscores |= 2;
    else if (c == "-showteamscores")
        sb_showscores &~= 2;
    else return FALSE;
    return TRUE;
};
