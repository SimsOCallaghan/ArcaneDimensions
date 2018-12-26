/*==============================================================================
OLD ONE
==============================================================================*/
$cd id1/models/old_one
$origin 0 0 24
$base base
$skin skin
$scale 1

$frame old1 old2 old3 old4 old5 old6 old7 old8 old9 
$frame old10 old11 old12 old13 old14 old15 old16 old17 old18 old19 
$frame old20 old21 old22 old23 old24 old25 old26 old27 old28 old29 
$frame old30 old31 old32 old33 old34 old35 old36 old37 old38 old39 
$frame old40 old41 old42 old43 old44 old45 old46 

$frame shake1 shake2 shake3 shake4 shake5 shake6 shake7 shake8
$frame shake9 shake10 shake11 shake12 shake13 shake14
$frame shake15 shake16 shake17 shake18 shake19 shake20

void() finale_1;
void() finale_2;
void() finale_3;
void() finale_4;
entity	shub;

//===========================================================================
//void() old_stand     =[      $old1,       old_stand    ] {};

void() old_idle1        =[      $old1,  old_idle2       ] {};
void() old_idle2        =[      $old2,  old_idle3       ] {};
void() old_idle3        =[      $old3,  old_idle4       ] {};
void() old_idle4        =[      $old4,  old_idle5       ] {};
void() old_idle5        =[      $old5,  old_idle6       ] {};
void() old_idle6        =[      $old6,  old_idle7       ] {};
void() old_idle7        =[      $old7,  old_idle8       ] {};
void() old_idle8        =[      $old8,  old_idle9       ] {};
void() old_idle9        =[      $old9,  old_idle10      ] {};
void() old_idle10       =[      $old10, old_idle11      ] {};
void() old_idle11       =[      $old11, old_idle12      ] {};
void() old_idle12       =[      $old12, old_idle13      ] {};
void() old_idle13       =[      $old13, old_idle14      ] {};
void() old_idle14       =[      $old14, old_idle15      ] {};
void() old_idle15       =[      $old15, old_idle16      ] {};
void() old_idle16       =[      $old16, old_idle17      ] {};
void() old_idle17       =[      $old17, old_idle18      ] {};
void() old_idle18       =[      $old18, old_idle19      ] {};
void() old_idle19       =[      $old19, old_idle20      ] {};
void() old_idle20       =[      $old20, old_idle21      ] {};
void() old_idle21       =[      $old21, old_idle22      ] {};
void() old_idle22       =[      $old22, old_idle23      ] {};
void() old_idle23       =[      $old23, old_idle24      ] {};
void() old_idle24       =[      $old24, old_idle25      ] {};
void() old_idle25       =[      $old25, old_idle26      ] {};
void() old_idle26       =[      $old26, old_idle27      ] {};
void() old_idle27       =[      $old27, old_idle28      ] {};
void() old_idle28       =[      $old28, old_idle29      ] {};
void() old_idle29       =[      $old29, old_idle30      ] {};
void() old_idle30       =[      $old30, old_idle31      ] {};
void() old_idle31       =[      $old31, old_idle32      ] {};
void() old_idle32       =[      $old32, old_idle33      ] {};
void() old_idle33       =[      $old33, old_idle34      ] {};
void() old_idle34       =[      $old34, old_idle35      ] {};
void() old_idle35       =[      $old35, old_idle36      ] {};
void() old_idle36       =[      $old36, old_idle37      ] {};
void() old_idle37       =[      $old37, old_idle38      ] {};
void() old_idle38       =[      $old38, old_idle39      ] {};
void() old_idle39       =[      $old39, old_idle40      ] {};
void() old_idle40       =[      $old40, old_idle41      ] {};
void() old_idle41       =[      $old41, old_idle42      ] {};
void() old_idle42       =[      $old42, old_idle43      ] {};
void() old_idle43       =[      $old43, old_idle44      ] {};
void() old_idle44       =[      $old44, old_idle45      ] {};
void() old_idle45       =[      $old45, old_idle46      ] {};
void() old_idle46       =[      $old46, old_idle1       ] {};

//===========================================================================
void() old_thrash1        =[ $shake1,  old_thrash2       ] {lightstyle(0, "m");};
void() old_thrash2        =[ $shake2,  old_thrash3       ] {lightstyle(0, "k");};
void() old_thrash3        =[ $shake3,  old_thrash4       ] {lightstyle(0, "k");};
void() old_thrash4        =[ $shake4,  old_thrash5       ] {lightstyle(0, "i");};
void() old_thrash5        =[ $shake5,  old_thrash6       ] {lightstyle(0, "g");};
void() old_thrash6        =[ $shake6,  old_thrash7       ] {lightstyle(0, "e");};
void() old_thrash7        =[ $shake7,  old_thrash8       ] {lightstyle(0, "c");};
void() old_thrash8        =[ $shake8,  old_thrash9       ] {lightstyle(0, "a");};
void() old_thrash9        =[ $shake9,  old_thrash10      ] {lightstyle(0, "c");};
void() old_thrash10       =[ $shake10, old_thrash11      ] {lightstyle(0, "e");};
void() old_thrash11       =[ $shake11, old_thrash12      ] {lightstyle(0, "g");};
void() old_thrash12       =[ $shake12, old_thrash13      ] {lightstyle(0, "i");};
void() old_thrash13       =[ $shake13, old_thrash14      ] {lightstyle(0, "k");};
void() old_thrash14       =[ $shake14, old_thrash15      ] {lightstyle(0, "m");};
void() old_thrash15       =[ $shake15, old_thrash16      ] {lightstyle(0, "m");
self.cnt = self.cnt + 1; if (self.cnt != 3) self.think = old_thrash1; };
void() old_thrash16       =[ $shake16, old_thrash17      ] {lightstyle(0, "g");};
void() old_thrash17       =[ $shake17, old_thrash18      ] {lightstyle(0, "c");};
void() old_thrash18       =[ $shake18, old_thrash19      ] {lightstyle(0, "b");};
void() old_thrash19       =[ $shake19, old_thrash20      ] {lightstyle(0, "a");};
void() old_thrash20       =[ $shake20, old_thrash20      ] {finale_4();};

//============================================================================
// Final thrash, explosion and on screen text waffle
//============================================================================
void() finale_1 =
{
	intermission_running = 4;				// don't check for button presses
	intermission_exittime = time + 100000;	// never allow exit

	// find the intermission spot
	self.owner = find (world, classname, "info_intermission");
	if (!self.owner) dprint("Cannot find info_intermission");
		
	// Find misc teleport thing and remove it
	self.enemy = find (world, classname, "misc_teleporttrain");
	if (!self.enemy) dprint("Cannot find teleporttrain");
	else remove (self.enemy);

	WriteByte (MSG_ALL, SVC_FINALE);
	WriteString (MSG_ALL, "");

	// Cycle through all players and reset them as below
	self.enemy = find (world, classname, "player");
	while (self.enemy != world) {
		self.enemy.view_ofs = '0 0 0';
		self.enemy.angles = self.enemy.v_angle = self.owner.mangle;
		self.enemy.fixangle = TRUE;		// turn this way immediately
		self.enemy.map = self.map;
		self.enemy.nextthink = time + 0.5;
		self.enemy.takedamage = DAMAGE_NO;
		self.enemy.solid = SOLID_NOT;
		self.enemy.movetype = MOVETYPE_NONE;
		self.enemy.modelindex = 0;
		setorigin (self.enemy, self.owner.origin);
		self.enemy = find (self.enemy, classname, "player");
	}	
	
	self.nextthink = time + 0.3;
	self.think = finale_2;
	self.count = 10;
};

//----------------------------------------------------------------------
// Randomnly spawn 10 teleporter sparkle effects
//----------------------------------------------------------------------
void() finale_2 =
{
	if (self.count < 0) finale_3();
	else {
		sound (self, CHAN_VOICE, "misc/r_tele1.wav", 1, ATTN_NORM);

		// start a teleport splash inside shub
		self.view_ofs_x = crandom()*50;
		self.view_ofs_y = -100;
		self.view_ofs_z = random()*100;
		self.oldorigin = self.origin + self.view_ofs;
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_TELEPORT);
		WriteCoord (MSG_BROADCAST, self.oldorigin_x);
		WriteCoord (MSG_BROADCAST, self.oldorigin_y);
		WriteCoord (MSG_BROADCAST, self.oldorigin_z);

		self.count = self.count - 1;
		self.nextthink = time + random()*0.5;
		self.think = finale_2;
	}
};

//----------------------------------------------------------------------
void() finale_3 =
{
	// start shub thrashing wildly
	sound (self, CHAN_VOICE, "boss2/death.wav", 1, ATTN_NORM);
	lightstyle(0, "abcdefghijklmlkjihgfedcb");	
	old_thrash1();
};

//----------------------------------------------------------------------
// Called after thrash animation (last frame)
//----------------------------------------------------------------------
void() finale_4 =
{
	// Play exploding sound
	sound (self, CHAN_VOICE, "boss2/pop2.wav", 1, ATTN_NORM);
	self.oldorigin = self.origin;

	// Setup temp entity for directional force for gibs
	self.movelast = spawn();
	self.movelast.oldorigin = self.origin - '0 0 -300';
	setorigin (self.movelast, self.movelast.oldorigin);
	setmodel (self.movelast, MODEL_BROKEN);
	self.enemy = self.movelast;

	// loop through old one x/y/z space and throw tons of meat chunks	
	self.count = 16;
	while (self.count > 0) {
		self.view_ofs = vecrand(0,64,TRUE);				// random xyz volume loc
		self.view_ofs_z = 50 + random()*200;			// Extra lift up
		self.origin = self.oldorigin + self.view_ofs;	// Move origin around
		self.health = 0 - random()*200;					// Velocity boast
		
		self.lip = random();
		if (self.lip < 0.1) ThrowGib(1, 1);
		else if (self.lip < 0.3) ThrowGib(2, 1);
		else if (self.lip < 0.5) ThrowGib(4, 1+random()*3);
		else ThrowGib(5, 1+random()*3);

		self.count = self.count - 1;
	}
	// start the end text
	WriteByte (MSG_ALL, SVC_FINALE);
	WriteString (MSG_ALL, "Congratulations and well done! You have\nbeaten the hideous Shub-Niggurath, and\nher hundreds of ugly changelings and\nmonsters. You have proven that your\nskill and your cunning are greater than\nall the powers of Quake. You are the\nmaster now. Id Software salutes you.");

	// put a player model down
	self.oldorigin = self.oldorigin - '32 264 0';
	setorigin (self.movelast, self.oldorigin);
	setmodel (self.movelast, MODEL_PLAYER);
	self.movelast.angles = '0 290 0';
	self.movelast.frame = 1;

	remove(self);

	// switch cd track
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);
	lightstyle(0, "m");	
};

//============================================================================
void (entity inflictor, entity attacker, float damage) old_nopain =
{
	self.health = self.max_health;
};

/*============================================================================
 QUAKED monster_oldone (1 0 0) (-16 -16 -24) (16 16 32)
============================================================================*/
void() monster_oldone =
{
	if (deathmatch) { remove(self); return; }

	self.mdl = "progs/oldone.mdl";
	precache_model (self.mdl);

	precache_sound ("boss2/death.wav");
	
	precache_sound ("boss2/idle.wav");
	precache_sound ("boss2/sight.wav");
	precache_sound ("boss2/pop2.wav");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.bbmins = '-160 -128 -24';		// has own entity setup
	self.bbmaxs = '160 128 256';

	setmodel(self, self.mdl);					// Setup model
	setsize (self, self.bbmins, self.bbmaxs);	// Restore BB size

	// Always reset Ammo Resistance to be consistent
	self.resist_shells = self.resist_nails = 0;
	self.resist_rockets = self.resist_cells = 0;

	self.classtype = CT_MONOLDONE;
	self.classgroup = CG_BOSS;
	self.health = self.max_health = 40000;		// kill by telefrag
	self.think = old_idle1;
	self.nextthink = time + 0.1;	
	self.takedamage = DAMAGE_YES;
	self.th_pain = old_nopain;
	self.th_die = finale_1;
	shub = self;
	
	total_monsters = total_monsters + 1;
};

