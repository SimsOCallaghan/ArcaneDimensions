/*==============================================================================
 Dark (Death) Prince Knight (A mixture of types)
 
 Interesting QC Traits
 * Has a floor damage attack to encourage players to jump
 * Multiple attacks based on close/mid/far range
 * Has special extra damage and attacks against other monsters
 
==============================================================================*/

// (001 - 012) Default stand - breathing
$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8
$frame stand9 stand10 stand11 stand12

// (013 - 024) Stand idle - Shoulder hunch
$frame standA1 standA2 standA3 standA4 standA5 standA6 standA7 standA8
$frame standA9 standA10 standA11 standA12

// (025 - 048) Stand idle - Quick look around
$frame standB1 standB2 standB3 standB4 standB5 standB6 standB7 standB8 
$frame standB9 standB10 standB11 standB12 standB13 standB14 standB15 standB16
$frame standB17 standB18 standB19 standB20 standB21 standB22 standB23 standB24

// (049 - 072) Stand idle - checking sword
$frame standC1 standC2 standC3 standC4 standC5 standC6 standC7 standC8 
$frame standC9 standC10 standC11 standC12 standC13 standC14 standC15 standC16
$frame standC17 standC18 standC19 standC20 standC21 standC22 standC23 standC24

// (073 - 092) Stand idle - scratching chin
$frame standD1 standD2 standD3 standD4 standD5 standD6 standD7 standD8 
$frame standD9 standD10 standD11 standD12 standD13 standD14 standD15 standD16
$frame standD17 standD18 standD19 standD20

// (093 - 106) Default walk - typical hell knight stride
$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9
$frame walk10 walk11 walk12 walk13 walk14

// (107 - 112) Default run
$frame run1 run2 run3 run4 run5 run6

// (113 - 127) Slice (one hand slashing run attack) (file=SWING)
$frame slice1 slice2 slice3 slice4 slice5 slice6 slice7 slice8
$frame slice9 slice10 slice11 slice12 slice13 slice14 slice15

// (128 - 142) Smash (chop overhead to ground) (file=CHOP)
$frame smash1 smash2 smash3 smash4 smash5 smash6 smash7 smash8
$frame smash9 smash10 smash11 smash12 smash13 smash14 smash15

// (143 - 164) W_Attack (two handed slashing attack) (file=SLASH)
$frame w_attack1 w_attack2 w_attack3 w_attack4 w_attack5 w_attack6 w_attack7 w_attack8
$frame w_attack9 w_attack10 w_attack11 w_attack12 w_attack13 w_attack14 w_attack15 w_attack16
$frame w_attack17 w_attack18 w_attack19 w_attack20 w_attack21 w_attack22 

// (165 - 178) MagicC - Typical magic range attack (file=SWEEPCAST)
$frame magicc1 magicc2 magicc3 magicc4 magicc5 magicc6 magicc7 magicc8
$frame magicc9 magicc10 magicc11 magicc12 magicc13 magicc14

// Pain animations A = Slow (179 - 183), D = Stagger (184 - 194)
$frame painA1 painA2 painA3 painA4 painA5
$frame painD1 painD2 painD3 painD4 painD5 painD6 painD7 painD8 painD9 painD10 painD11

// (194 - 206) Charging attack A - swinging sword left to right infront
$frame char_a1 char_a2 char_a3 char_a4 char_a5 char_a6 char_a7 char_a8
$frame char_a9 char_a10 char_a11 char_a12

// (207 - 212) Charging attack B - rotating sword left to right infront
$frame char_b1 char_b2 char_b3 char_b4 char_b5 char_b6

// (212 - 224) Death forward
$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11 death12

// (225 - 244) Death backwards with cool sword wobble
$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9 deathb10 deathb11 deathb12 deathb13 deathb14 deathb15 deathb16
$frame deathb17 deathb18 deathb19 deathb20

// magica and magicb missing

void() dprince_sword_sound;			// Sword swipe sounds

//===========================================================================
void()	dprince_standA1	=[	$standA1,	dprince_standA2	] {ai_stand();};
void()	dprince_standA2	=[	$standA2,	dprince_standA3	] {ai_stand();};
void()	dprince_standA3	=[	$standA3,	dprince_standA4	] {ai_stand();};
void()	dprince_standA4	=[	$standA4,	dprince_standA5	] {ai_stand();};
void()	dprince_standA5	=[	$standA5,	dprince_standA6	] {ai_stand();};
void()	dprince_standA6	=[	$standA6,	dprince_standA7	] {ai_stand();};
void()	dprince_standA7	=[	$standA7,	dprince_standA8	] {ai_stand();};
void()	dprince_standA8	=[	$standA8,	dprince_standA9	] {ai_stand();};
void()	dprince_standA9	=[	$standA9,	dprince_standA10] {ai_stand();};
void()	dprince_standA10=[	$standA10,	dprince_standA11] {ai_stand();};
void()	dprince_standA11=[	$standA11,	dprince_standA12] {ai_stand();};
void()	dprince_standA12=[	$standA12,	dprince_stand1	] {ai_stand();};

//----------------------------------------------------------------------
void()	dprince_standB1	=[	$standB1,	dprince_standB2	] {ai_stand();};
void()	dprince_standB2	=[	$standB2,	dprince_standB3	] {ai_stand();};
void()	dprince_standB3	=[	$standB3,	dprince_standB4	] {ai_stand();};
void()	dprince_standB4	=[	$standB4,	dprince_standB5	] {ai_stand();};
void()	dprince_standB5	=[	$standB5,	dprince_standB6	] {ai_stand();};
void()	dprince_standB6	=[	$standB6,	dprince_standB7	] {ai_stand();};
void()	dprince_standB7	=[	$standB7,	dprince_standB8	] {ai_stand();};
void()	dprince_standB8	=[	$standB8,	dprince_standB9	] {ai_stand();};
void()	dprince_standB9	=[	$standB9,	dprince_standB10] {ai_stand();};
void()	dprince_standB10=[	$standB10,	dprince_standB11] {ai_stand();};
void()	dprince_standB11=[	$standB11,	dprince_standB12] {ai_stand();};
void()	dprince_standB12=[	$standB12,	dprince_standB13] {ai_stand();};
void()	dprince_standB13=[	$standB13,	dprince_standB14] {ai_stand();};
void()	dprince_standB14=[	$standB14,	dprince_standB15] {ai_stand();};
void()	dprince_standB15=[	$standB15,	dprince_standB16] {ai_stand();};
void()	dprince_standB16=[	$standB16,	dprince_standB17] {ai_stand();};
void()	dprince_standB17=[	$standB17,	dprince_standB18] {ai_stand();};
void()	dprince_standB18=[	$standB18,	dprince_standB19] {ai_stand();};
void()	dprince_standB19=[	$standB19,	dprince_standB20] {ai_stand();};
void()	dprince_standB20=[	$standB20,	dprince_standB21] {ai_stand();};
void()	dprince_standB21=[	$standB21,	dprince_standB22] {ai_stand();};
void()	dprince_standB22=[	$standB22,	dprince_standB23] {ai_stand();};
void()	dprince_standB23=[	$standB23,	dprince_standB24] {ai_stand();};
void()	dprince_standB24=[	$standB24,	dprince_stand1	] {ai_stand();};

//----------------------------------------------------------------------
void()	dprince_standC1	=[	$standC1,	dprince_standC2	] {ai_stand();};
void()	dprince_standC2	=[	$standC2,	dprince_standC3	] {ai_stand();};
void()	dprince_standC3	=[	$standC3,	dprince_standC4	] {ai_stand();};
void()	dprince_standC4	=[	$standC4,	dprince_standC5	] {ai_stand();};
void()	dprince_standC5	=[	$standC5,	dprince_standC6	] {ai_stand();};
void()	dprince_standC6	=[	$standC6,	dprince_standC7	] {ai_stand();};
void()	dprince_standC7	=[	$standC7,	dprince_standC8	] {ai_stand();};
void()	dprince_standC8	=[	$standC8,	dprince_standC9	] {ai_stand();};
void()	dprince_standC9	=[	$standC9,	dprince_standC10] {ai_stand();};
void()	dprince_standC10=[	$standC10,	dprince_standC11] {ai_stand();};
void()	dprince_standC11=[	$standC11,	dprince_standC12] {ai_stand();};
void()	dprince_standC12=[	$standC12,	dprince_standC13] {ai_stand();};
void()	dprince_standC13=[	$standC13,	dprince_standC14] {ai_stand();};
void()	dprince_standC14=[	$standC14,	dprince_standC15] {ai_stand();};
void()	dprince_standC15=[	$standC15,	dprince_standC16] {ai_stand();};
void()	dprince_standC16=[	$standC16,	dprince_standC17] {ai_stand();};
void()	dprince_standC17=[	$standC17,	dprince_standC18] {ai_stand();};
void()	dprince_standC18=[	$standC18,	dprince_standC19] {ai_stand();};
void()	dprince_standC19=[	$standC19,	dprince_standC20] {ai_stand();};
void()	dprince_standC20=[	$standC20,	dprince_standC21] {ai_stand();};
void()	dprince_standC21=[	$standC21,	dprince_standC22] {ai_stand();};
void()	dprince_standC22=[	$standC22,	dprince_standC23] {ai_stand();};
void()	dprince_standC23=[	$standC23,	dprince_standC24] {ai_stand();};
void()	dprince_standC24=[	$standC24,	dprince_stand1	] {ai_stand();};

//----------------------------------------------------------------------
void()	dprince_standD1	=[	$standD1,	dprince_standD2	] {ai_stand();};
void()	dprince_standD2	=[	$standD2,	dprince_standD3	] {ai_stand();};
void()	dprince_standD3	=[	$standD3,	dprince_standD4	] {ai_stand();};
void()	dprince_standD4	=[	$standD4,	dprince_standD5	] {ai_stand();};
void()	dprince_standD5	=[	$standD5,	dprince_standD6	] {ai_stand();};
void()	dprince_standD6	=[	$standD6,	dprince_standD7	] {ai_stand();};
void()	dprince_standD7	=[	$standD7,	dprince_standD8	] {ai_stand();};
void()	dprince_standD8	=[	$standD8,	dprince_standD9	] {ai_stand();};
void()	dprince_standD9	=[	$standD9,	dprince_standD10] {ai_stand();};
void()	dprince_standD10=[	$standD10,	dprince_standD11] {ai_stand();};
void()	dprince_standD11=[	$standD11,	dprince_standD12] {ai_stand();};
void()	dprince_standD12=[	$standD12,	dprince_standD13] {ai_stand();};
void()	dprince_standD13=[	$standD13,	dprince_standD14] {ai_stand();};
void()	dprince_standD14=[	$standD14,	dprince_standD15] {ai_stand();};
void()	dprince_standD15=[	$standD15,	dprince_standD16] {ai_stand();};
void()	dprince_standD16=[	$standD16,	dprince_standD17] {ai_stand();};
void()	dprince_standD17=[	$standD17,	dprince_standD18] {ai_stand();};
void()	dprince_standD18=[	$standD18,	dprince_standD19] {ai_stand();};
void()	dprince_standD19=[	$standD19,	dprince_standD20] {ai_stand();};
void()	dprince_standD20=[	$standD20,	dprince_stand1	] {ai_stand();};

//----------------------------------------------------------------------
void()	dprince_stand1	=[	$stand1,	dprince_stand2	] {monster_idle_sound();ai_stand();};
void()	dprince_stand2	=[	$stand2,	dprince_stand3	] {ai_stand();};
void()	dprince_stand3	=[	$stand3,	dprince_stand4	] {ai_stand();};
void()	dprince_stand4	=[	$stand4,	dprince_stand5	] {ai_stand();};
void()	dprince_stand5	=[	$stand5,	dprince_stand6	] {ai_stand();};
void()	dprince_stand6	=[	$stand6,	dprince_stand7	] {ai_stand();};
void()	dprince_stand7	=[	$stand7,	dprince_stand8	] {ai_stand();};
void()	dprince_stand8	=[	$stand8,	dprince_stand9	] {ai_stand();};
void()	dprince_stand9	=[	$stand9,	dprince_stand10	] {ai_stand();};
void()	dprince_stand10	=[	$stand10,	dprince_stand11	] {ai_stand();};
void()	dprince_stand11	=[	$stand11,	dprince_stand12	] {ai_stand();};
void()	dprince_stand12	=[	$stand12,	dprince_stand1	] {
	self.idlebusy = FALSE; 
	if (random() < MON_IDLE_ANIMATION) {
		self.idlebusy = TRUE; 
		// Make sure the idle animations don't repeat in a row
		self.lefty = self.lip;
		while (self.lefty == self.lip) { self.lefty = rint(random()*4);}
		self.lip = self.lefty;
		if (self.lip < 1) self.think = dprince_standD1;			// Scratch chin
		else if (self.lip < 2) self.think = dprince_standC1;	// Look at weapon
		else if (self.lip < 3) self.think = dprince_standA1;	// Shoulder hunch
		else self.think = dprince_standB1;						// Look around
	}
};

//===========================================================================
void()	dprince_walk1	=[	$walk1,		dprince_walk2	] {
	self.idlebusy = FALSE; monster_idle_sound(); ai_walk(2);};
void()	dprince_walk2	=[	$walk2,		dprince_walk3	] {
	monster_footstep(FALSE);ai_walk(5);};
void()	dprince_walk3	=[	$walk3,		dprince_walk4	] {ai_walk(5);};
void()	dprince_walk4	=[	$walk4,		dprince_walk5	] {ai_walk(4);};
void()	dprince_walk5	=[	$walk5,		dprince_walk6	] {ai_walk(4);};
void()	dprince_walk6	=[	$walk6,		dprince_walk7	] {ai_walk(2);};
void()	dprince_walk7	=[	$walk7,		dprince_walk8	] {ai_walk(2);};
void()	dprince_walk8	=[	$walk8,		dprince_walk9	] {
	monster_footstep(FALSE); ai_walk(3);};
void()	dprince_walk9	=[	$walk9,		dprince_walk10	] {ai_walk(3);};
void()	dprince_walk10	=[	$walk10,	dprince_walk11	] {ai_walk(4);};
void()	dprince_walk11	=[	$walk11,	dprince_walk12	] {ai_walk(3);};
void()	dprince_walk12	=[	$walk12,	dprince_walk13	] {ai_walk(4);};
void()	dprince_walk13	=[	$walk13,	dprince_walk14	] {ai_walk(6);};
void()	dprince_walk14	=[	$walk14,	dprince_walk1	] {ai_walk(2);};

//===========================================================================
void()	dprince_run1	=[	$run1,	dprince_run2	] {monster_idle_sound(); 
	self.idlebusy = FALSE; ai_run (20); CheckForCharge(); };
void()	dprince_run2	=[	$run2,	dprince_run3	] {monster_footstep(FALSE); ai_run(25);};
void()	dprince_run3	=[	$run3,	dprince_run4	] {ai_run(16);};
void()	dprince_run4	=[	$run4,	dprince_run5	] {ai_run(14);};
void()	dprince_run5	=[	$run5,	dprince_run6	] {monster_footstep(FALSE); ai_run(25);};
void()	dprince_run6	=[	$run6,	dprince_run1	] {ai_run(13);};

//===========================================================================
// Charging attack A - swinging sword left to right infront
// Hell Knight - 16 frames / Death Knight - 12 frames
// Death Knight is faster (-4 frames will cycle damage frames quicker)
// Damage Frames - Hell Knight (6-11, Total 6) Death Knight (6-10, Total 5)

void()	dprince_char_a1	=[	$char_a1,	dprince_char_a2	] {ai_charge(20); dprince_sword_sound();};
void()	dprince_char_a2	=[	$char_a2,	dprince_char_a3	] {monster_footstep(FALSE); ai_charge(25);ai_melee(); };
void()	dprince_char_a3	=[	$char_a3,	dprince_char_a4	] {ai_charge(18);ai_melee(); };
void()	dprince_char_a4	=[	$char_a4,	dprince_char_a5	] {ai_charge(16);};
void()	dprince_char_a5	=[	$char_a5,	dprince_char_a6	] {monster_footstep(FALSE); ai_charge(14);};
void()	dprince_char_a6	=[	$char_a6,	dprince_char_a7	] {ai_charge(20); ai_melee();};
void()	dprince_char_a7	=[	$char_a7,	dprince_char_a8	] {ai_charge(21); ai_melee(); dprince_sword_sound();};
void()	dprince_char_a8	=[	$char_a8,	dprince_char_a9	] {monster_footstep(FALSE); ai_charge(13); ai_melee();};
void()	dprince_char_a9	=[	$char_a9,	dprince_char_a10] {ai_charge(20); ai_melee();};
void()	dprince_char_a10=[	$char_a10,	dprince_char_a11] {ai_charge(20); ai_melee();};
void()	dprince_char_a11=[	$char_a11,	dprince_char_a12] {monster_footstep(FALSE); ai_charge(18);};
void()	dprince_char_a12=[	$char_a12,	dprince_run1	] {ai_charge(16);};

//----------------------------------------------------------------------
// Identical frame set (Hell Knight / Death Knight)

void()	dprince_char_b1	=[	$char_b1,	dprince_char_b2	] {
	CheckContinueCharge (); ai_charge(23); ai_melee(); dprince_sword_sound();};
void()	dprince_char_b2	=[	$char_b2,	dprince_char_b3	] {monster_footstep(FALSE); ai_charge(17); ai_melee();};
void()	dprince_char_b3	=[	$char_b3,	dprince_char_b4	] {ai_charge(12); ai_melee();};
void()	dprince_char_b4	=[	$char_b4,	dprince_char_b5	] {ai_charge(22); ai_melee();};
void()	dprince_char_b5	=[	$char_b5,	dprince_char_b6	] {monster_footstep(FALSE); ai_charge(18); ai_melee();};
void()	dprince_char_b6	=[	$char_b6,	dprince_char_b1	] {ai_charge(8); ai_melee();};

//===========================================================================
// Melee Attack 1 - Slice (one hand slashing run attack)
// Hell Knight - 10 frames / Death Knight - 15 frames (skipped 1, 3, 12, 15)
// Death Knight - trimmed frames so melee attack 1 and 2 the same

void()	dprince_slice1	=[	$slice2,	dprince_slice2	] {ai_charge(9);};
void()	dprince_slice2	=[	$slice4,	dprince_slice3	] {monster_footstep(FALSE); ai_charge(6);};
void()	dprince_slice3	=[	$slice5,	dprince_slice4	] {ai_charge(13);};
void()	dprince_slice4	=[	$slice6,	dprince_slice5	] {ai_charge(4); dprince_sword_sound();};
void()	dprince_slice5	=[	$slice7,	dprince_slice6	] {monster_footstep(FALSE); ai_charge(7); ai_melee();};
void()	dprince_slice6	=[	$slice8,	dprince_slice7	] {ai_charge(15); ai_melee();};
void()	dprince_slice7	=[	$slice9,	dprince_slice8	] {ai_charge(8); ai_melee();};
void()	dprince_slice8	=[	$slice10,	dprince_slice9	] {monster_footstep(FALSE); ai_charge(2); ai_melee();};
void()	dprince_slice9	=[	$slice11,	dprince_slice10	] {ai_melee();};
void()	dprince_slice10	=[	$slice13,	dprince_slice11	] {monster_footstep(FALSE); ai_charge(0);};
void()	dprince_slice11	=[	$slice14,	dprince_run1	] {ai_charge(3);};

//----------------------------------------------------------------------
// Melee Attack 2 - Smash (chop overhead to ground)
// Hell Knight - 11 frames / Death Knight - 15 frames (skipped (1, 11, 14, 15)
// Death Knight frames trimmed down to match Hell Knight (damage ratio)

void()	dprince_smash1	=[	$smash2,	dprince_smash2	] {ai_charge(1);};
void()	dprince_smash2	=[	$smash3,	dprince_smash3	] {ai_charge(13);};
void()	dprince_smash3	=[	$smash4,	dprince_smash4	] {monster_footstep(FALSE); ai_charge(9);};
void()	dprince_smash4	=[	$smash5,	dprince_smash5	] {ai_charge(11);dprince_sword_sound();};
void()	dprince_smash5	=[	$smash6,	dprince_smash6	] {ai_charge(10);};
void()	dprince_smash6	=[	$smash7,	dprince_smash7	] {ai_charge(7); self.meleecontact = TRUE; ai_meleesmash(40);};
void()	dprince_smash7	=[	$smash8,	dprince_smash8	] {monster_footstep(FALSE);ai_charge(12);ai_melee();};
void()	dprince_smash8	=[	$smash9,	dprince_smash9	] {ai_charge(2);self.meleecontact = FALSE;ai_melee();};
void()	dprince_smash9	=[	$smash10,	dprince_smash10	] {ai_charge(3);ai_melee();};
void()	dprince_smash10	=[	$smash12,	dprince_smash11	] {ai_charge(0);ai_melee();};
void()	dprince_smash11	=[	$smash13,	dprince_run1	] {ai_charge(0);};

//----------------------------------------------------------------------
// Melee Attack 3 - W_Attack (two handed slashing attack)
// Identical frame set (Hell Knight / Death Knight)

void()	dprince_watk1	=[	$w_attack1,	dprince_watk2	] {ai_charge(2);};
void()	dprince_watk2	=[	$w_attack2,	dprince_watk3	] {monster_footstep(FALSE); ai_charge(0);};
void()	dprince_watk3	=[	$w_attack3,	dprince_watk4	] {ai_charge(0);};
void()	dprince_watk4	=[	$w_attack4,	dprince_watk5	] {ai_charge(0); dprince_sword_sound();};
void()	dprince_watk5	=[	$w_attack5,	dprince_watk6	] {ai_melee();};
void()	dprince_watk6	=[	$w_attack6,	dprince_watk7	] {ai_melee();};
void()	dprince_watk7	=[	$w_attack7,	dprince_watk8	] {monster_footstep(FALSE); ai_charge(1);};
void()	dprince_watk8	=[	$w_attack8,	dprince_watk9	] {ai_charge(4);};
void()	dprince_watk9	=[	$w_attack9,	dprince_watk10	] {ai_charge(5);};
void()	dprince_watk10	=[	$w_attack10,dprince_watk11	] {ai_charge(3); ai_melee();};
void()	dprince_watk11	=[	$w_attack11,dprince_watk12	] {ai_charge(2); ai_melee();};
void()	dprince_watk12	=[	$w_attack12,dprince_watk13	] {ai_charge(2); ai_melee();};
void()	dprince_watk13	=[	$w_attack13,dprince_watk14	] {ai_charge(0);};
void()	dprince_watk14	=[	$w_attack14,dprince_watk15	] {ai_charge(0);};
void()	dprince_watk15	=[	$w_attack15,dprince_watk16	] {ai_charge(0); dprince_sword_sound();};
void()	dprince_watk16	=[	$w_attack16,dprince_watk17	] {ai_charge(1);};
void()	dprince_watk17	=[	$w_attack17,dprince_watk18	] {monster_footstep(FALSE); ai_charge(1); ai_melee();};
void()	dprince_watk18	=[	$w_attack18,dprince_watk19	] {ai_charge(3); ai_melee();};
void()	dprince_watk19	=[	$w_attack19,dprince_watk20	] {ai_charge(4); ai_melee();};
void()	dprince_watk20	=[	$w_attack20,dprince_watk21	] {ai_charge(6);};
void()	dprince_watk21	=[	$w_attack21,dprince_watk22	] {ai_charge(7);};
void()	dprince_watk22	=[	$w_attack22,dprince_run1	] {ai_charge(3);};

//============================================================================
// Cycle between 3 melee attacks
// Attack 1 - Slice (one hand slashing run attack)
// Attack 2 - Smash (chop overhead to ground)
// Attack 3 - W_Attack (two handed slashing attack)

//----------------------------------------------------------------------
void() dprince_melee =
{
	// Do heavy overhead attack against other monsters
	if (self.enemy.flags & FL_MONSTER) dprince_smash1();
	else {
		// Cycle around 3 melee attacks against player
		self.meleeattack = self.meleeattack + 1;

		// Slice = Swing attack, Smash = Overhead down, Watk = long swing
		if (self.meleeattack == 1) dprince_slice1 ();
		else if (self.meleeattack == 2) dprince_smash1 ();
		else {
			dprince_watk1 ();
			self.meleeattack = 0;
		}
	}
};

//======================================================================
// Magic Attacks - Range Far = Rockets, Range Near = Hazard
//----------------------------------------------------------------------
void() dprince_rocket =
{
	local vector org, dir, avel;
	
	if (!self.enemy) return;
	if (self.enemy.health < 1) return;
	if (self.health < 1) return;

	self.effects = self.effects | EF_MUZZLEFLASH;	
	sound (self, CHAN_WEAPON, "hknight/attack1.wav", 1, ATTN_NORM);

	// Re-use spike projectile speeds
	// Maximum speed, initial speed set in Launch_Missile
	self.attack_speed = SPEED_DPRINCEBOLT + (skill * SPEED_DPRINCESKILL);

	makevectors (self.angles);
	org = self.origin + attack_vector(self.attack_offset);
	dir = normalize(self.attack_track - org);
	avel = avel = vecrand(100,200,FALSE);
	
	// Colour type and trail selected in missile function
	Launch_Missile(org, dir, avel, CT_PROJ_DPRINCE1, self.attack_speed);
};

//----------------------------------------------------------------------
void(float offset) dprince_hazard =
{
	local vector org, torg, dir, ang, avel;
	local float targetang, haz_loop;
	
	if (!self.enemy) return;
	if (self.enemy.health < 1) return;
	if (self.health < 1) return;

	sound (self, CHAN_WEAPON, "hknight/attack1.wav", 1, ATTN_NORM);

	makevectors (self.angles);	
	org = self.origin + attack_vector(self.attack_offset);

	if (skill <= SKILL_NORMAL) haz_loop = 1;
	else haz_loop = 2;
	
	while(haz_loop > 0) {
		// Keep looping
		haz_loop = haz_loop - 1;
		torg = self.enemy.origin;
		// Last projectile (0) is direct at enemy
		if (haz_loop > 0) {
			// Very large random area around target
			torg_x = torg_x + (crandom() * 128);
			torg_y = torg_y + (crandom() * 128);
		}
		// Work out elevation towards target origin
		targetang = SUB_Elevation(ELEV_DEFAULT, self.origin, torg, SPEED_DPRINCE);
		ang = vectoangles(torg - org);
		ang_x = -targetang;
		makevectors (ang);
		// fire projectile in arc pattern (offset)
		dir = ( (v_forward * (0.75 + random()*0.25)) + (v_right * (offset*0.1)) ) * SPEED_DPRINCE;	
		// Some random angle rotation
		avel = vecrand(100,200,FALSE);
		Launch_Hazard(org, dir, avel, CT_PROJ_DPRINCE2);
	}
};

//----------------------------------------------------------------------
void() dprince_magicframe =
{
	if (self.health < 1) return;
	if (!self.enemy) return;
	
	// Keep looping
	self.nextthink = time + 0.1;
	self.think = dprince_magicframe;
	
	// 2=Rockets use direct tracking system
	if (self.weaponstate == 2) {
		// check for enemy origin (based on sight test)
		// if cannot see enemy fire at last known location
		if (self.walkframe == 0) self.attack_track = self.enemy.origin;
		else ai_trackenemy();
		
		// Start projectile attacks
		// Easy = 1, Normal = 2, Hard/NM = 3
		if (self.walkframe == 4 && skill >= SKILL_NORMAL) dprince_rocket();
		else if (self.walkframe == 6) dprince_rocket();
		else if (self.walkframe == 8 && skill >= SKILL_HARD) dprince_rocket();
	}
	else {
		// Hazard attack uses elevation tracking
		if (self.walkframe <= 5) ai_face();
		
		// Fine tune projectile elevation
		if (self.walkframe == 0) 
			self.attack_elev = SUB_Elevation(ELEV_DEFAULT, self.origin, self.enemy.origin, SPEED_DPRINCE);
		else if (self.walkframe > 0 && self.walkframe < 5)
			self.attack_elev = SUB_Elevation(self.attack_elev, self.origin, self.enemy.origin, SPEED_DPRINCE);
		// Start projectile attacks (no facing)
		if (self.walkframe == 5) dprince_hazard(-2);
		else if (self.walkframe == 6) dprince_hazard(-1);
		else if (self.walkframe == 7) dprince_hazard(0);
		else if (self.walkframe == 8) dprince_hazard(1);
		else if (self.walkframe == 9) dprince_hazard(2);
		else if (self.walkframe == 10) dprince_hazard(3);
	}
		
	// Update frame and move forward
	self.frame = $magicc2 + self.walkframe;
	self.walkframe = self.walkframe + 1;
	// Finished animation set?
	if (self.walkframe > 10) self.th_run();
};

void() dprince_range = { self.walkframe = 0; dprince_magicframe();};

//============================================================================
void()	dprince_painA1	=[	$painA1, dprince_painA2	] {};
void()	dprince_painA2	=[	$painA2, dprince_painA3	] {};
void()	dprince_painA3	=[	$painA3, dprince_painA4	] {};
void()	dprince_painA4	=[	$painA4, dprince_painA5	] {};
void()	dprince_painA5	=[	$painA5, dprince_run1	] {};

//----------------------------------------------------------------------
void()	dprince_painD1	=[	$painD1, dprince_painD2	] {};
void()	dprince_painD2	=[	$painD2, dprince_painD3	] {};
void()	dprince_painD3	=[	$painD3, dprince_painD4	] {};
void()	dprince_painD4	=[	$painD4, dprince_painD5	] {monster_footstep(FALSE); };
void()	dprince_painD5	=[	$painD5, dprince_painD6	] {};
void()	dprince_painD6	=[	$painD6, dprince_painD7	] {};
void()	dprince_painD7	=[	$painD7, dprince_painD8	] {};
void()	dprince_painD8	=[	$painD8, dprince_painD9	] {monster_footstep(FALSE); };
void()	dprince_painD9	=[	$painD9, dprince_painD10	] {};
void()	dprince_painD10	=[	$painD10, dprince_painD11	] {};
void()	dprince_painD11	=[	$painD11, dprince_run1	] {};

//----------------------------------------------------------------------
void(entity inflictor, entity attacker, float damage) dprince_pain =
{
	if (self.spawnflags & MON_GHOST_ONLY) return;
	
	// Check all pain conditions and set up what to do next
	monster_pain_check(attacker, damage);

	// Any pain animation/sound required?
	if (self.pain_check > 0) {
		sound (self, CHAN_VOICE, self.pain_sound, 1, ATTN_NORM);
		if (self.pain_check == 1) {
			// Randomly pick which pain animation to play
			if (random() < 0.85) dprince_painA1 ();	// classic, body recoil
			else {
				dprince_painD1 ();				// Cool stumble, hand over mouth
				self.pain_finished = time + 2;	// long animation
			}
		}
		else if (self.pain_check == 2) {
			// reset axe hit and setup short pain recovery
			self.pain_finished = time + 1.1;
			self.axhitme = 0;
			dprince_painD1 ();
		}
	}
};

//============================================================================
void()	dprince_die1	=[	$death1,	dprince_die2	] {ai_forward(10);};
void()	dprince_die2	=[	$death2,	dprince_die3	] {monster_check_gib();ai_forward(8);};
void()	dprince_die3	=[	$death3,	dprince_die4	] {monster_check_gib();
	self.solid = SOLID_NOT; ai_forward(7);};
void()	dprince_die4	=[	$death4,	dprince_die5	] {};
void()	dprince_die5	=[	$death5,	dprince_die6	] {};
void()	dprince_die6	=[	$death6,	dprince_die7	] {
	sound (self, CHAN_WEAPON, GIB_SOUND_METALA, 1, ATTN_NORM);};
void()	dprince_die7	=[	$death7,	dprince_die8	] {};
void()	dprince_die8	=[	$death8,	dprince_die9	] {ai_forward(10);};
void()	dprince_die9	=[	$death9,	dprince_die10	] {ai_forward(11);};
void()	dprince_die10	=[	$death10,	dprince_die11	] {};
void()	dprince_die11	=[	$death11,	dprince_die12	] {monster_death_postcheck();};
void()	dprince_die12	=[	$death12,	dprince_die12	] {monster_deadbody_check();};

//----------------------------------------------------------------------
void()	dprince_dieb1	=[	$deathb1,	dprince_dieb2	] {};
void()	dprince_dieb2	=[	$deathb2,	dprince_dieb3	] {monster_check_gib();};
void()	dprince_dieb3	=[	$deathb3,	dprince_dieb4	] {monster_check_gib();
	self.solid = SOLID_NOT;};
void()	dprince_dieb4	=[	$deathb4,	dprince_dieb5	] {};
void()	dprince_dieb5	=[	$deathb5,	dprince_dieb6	] {};
void()	dprince_dieb6	=[	$deathb6,	dprince_dieb7	] {};
void()	dprince_dieb7	=[	$deathb7,	dprince_dieb8	] {};
void()	dprince_dieb8	=[	$deathb8,	dprince_dieb9	] {};
void()	dprince_dieb9	=[	$deathb9,	dprince_dieb10	] {
	sound (self, CHAN_WEAPON, GIB_SOUND_METALB, 1, ATTN_NORM);};
void()	dprince_dieb10	=[	$deathb10,	dprince_dieb11	] {};
void()	dprince_dieb11	=[	$deathb11,	dprince_dieb12	] {};
void()	dprince_dieb12	=[	$deathb12,	dprince_dieb13	] {};
void()	dprince_dieb13	=[	$deathb13,	dprince_dieb14	] {};
void()	dprince_dieb14	=[	$deathb14,	dprince_dieb15	] {};
void()	dprince_dieb15	=[	$deathb15,	dprince_dieb16	] {};
void()	dprince_dieb16	=[	$deathb16,	dprince_dieb17	] {};
void()	dprince_dieb17	=[	$deathb17,	dprince_dieb18	] {};
void()	dprince_dieb18	=[	$deathb18,	dprince_dieb19	] {};
void()	dprince_dieb19	=[	$deathb19,	dprince_dieb20	] {monster_death_postcheck();};
void()	dprince_dieb20	=[	$deathb20,	dprince_dieb20	] {monster_deadbody_check();};

//----------------------------------------------------------------------
void() dprince_die =
{
	// Pre-check routine to tidy up extra entities
	monster_death_precheck();

	// regular death
	if (!self.gibbed) {
		sound (self, CHAN_VOICE, self.death_sound, 1, ATTN_NORM);
		if (random() > 0.5) dprince_die1 ();
		else dprince_dieb1 ();
	}
};

//============================================================================
void() dprince_sword_sound =
{
	self.lip = random();
	if (self.lip < 0.25) sound (self, CHAN_WEAPON, "weapons/sword1a.wav", 1, ATTN_NORM);
	else if (self.lip < 0.5) sound (self, CHAN_WEAPON, "weapons/sword2a.wav", 1, ATTN_NORM);
	else if (self.lip < 0.75) sound (self, CHAN_WEAPON, "weapons/sword1b.wav", 1, ATTN_NORM);
	else sound (self, CHAN_WEAPON, "weapons/sword2b.wav", 1, ATTN_NORM);
};

/*======================================================================
QUAKED monster_dprince (1 0 0) (-16 -16 -24) (16 16 40) Ambush
======================================================================*/
void() monster_dprince =
{
	// Check all spawn exceptions (monsters.qc)
	if (monster_checkspawn() == TRUE) return;

	self.mdl = "progs/mon_dprince.mdl";			// New Hell Knight
	self.headmdl = "progs/h_dprince.mdl";
	self.gib1mdl = "progs/w_dprincesword.mdl";	// Unique sword
	self.gib2mdl = "progs/gib_knfoot_l.mdl";	// left foot
	self.gib3mdl = "progs/gib_knfoot_r.mdl";	// right foot

	precache_model (self.mdl);
	precache_model (self.headmdl);
	precache_model (self.gib2mdl);
	precache_model (self.gib3mdl);
	precache_model (self.gib1mdl);

	self.gib1sound = GIB_IMPACT_METALA;
	if (random() < 0.5) self.gib2mdl = "";
	if (random() < 0.5) self.gib3mdl = "";

	if (self.spawnflags & MON_DPRINCE_FIRE) {
		// red version (new)
		self.exactskin = 1;						// Red armour
		self.gib1skin = 1;						// Red sword
		self.part_trstyle = PARTICLE_TRAIL_RED;
		self.attack_proj1 = MODEL_PROJ_DPRINCE1R;	// Steering rocket
		self.attack_proj2 = MODEL_PROJ_DPRINCE2R;	// Red hazard plasma
	}
	else {
		// blue version (default)
		self.part_trstyle = PARTICLE_TRAIL_BLUE;
		self.attack_proj1 = MODEL_PROJ_DPRINCE1B;	// Steering rocket
		self.attack_proj2 = MODEL_PROJ_DPRINCE2B;	// Blue hazard plasma
	}
	precache_model (self.attack_proj1);	
	precache_model (self.attack_proj2);	
	
	self.idle_sound = "hknight/idle.wav";
	precache_sound (self.idle_sound);

	// Firing of magic spikes (first 0.1s must loop)
	precache_sound ("hknight/attack1.wav");

	// TE_KNIGHTSPIKE = Magic spike hitting the wall
	// Has got to be in this location because the
	// filename is hardcoded (engine.exe)
	precache_sound ("hknight/hit.wav");
	precache_sound ("dknight/dprince_miss.wav");

	self.sight_sound = "hknight/sight1.wav";
	precache_sound (self.sight_sound);

	self.pain_sound = "hknight/pain1.wav";
	self.death_sound = "hknight/death1.wav";
	precache_sound (self.pain_sound);
	precache_sound (self.death_sound);

	// New sword sweep/slash sounds
	precache_sound ("weapons/sword1a.wav");
	precache_sound ("weapons/sword1b.wav");
	precache_sound ("weapons/sword2a.wav");
	precache_sound ("weapons/sword2b.wav");

	self.solid = SOLID_NOT;				// No interaction with world
	self.movetype = MOVETYPE_NONE;		// Static item, no movement
	if (self.bboxtype < 1) self.bboxtype = BBOX_TALL;
	if (self.health < 1) self.health = 400;

	self.gibhealth = -50;
	self.gibbed = FALSE;				// Starts complete
	self.pain_flinch = 400;				// Really low chance of pain
	self.pain_longanim = FALSE;			// cannot be chopped with shadow axe
	self.pain_timeout = 2;				// High pain level
	if (self.infightextra <= 0) self.infightextra = 4; // High infighting damage
	self.steptype = FS_TYPEHEAVY;		// Heavy feet
	self.poisonous = FALSE;				// No Poison version
	self.no_liquiddmg = TRUE;			// Immune to slime/lava
	self.meleecontact = FALSE;			// Smash contact
	self.meleerange = MONAI_MELEEFRONT;	// Smash attack
	self.attack_offset = '20 0 8';		// Middle of body (id location)
	self.attack_count = 6;				// Default floor projectiles
	self.deathstring = " was annihilated by a Dark Prince\n";

	// Always reset Ammo Resistance to be consistent
	self.resist_shells = self.resist_nails = self.resist_rockets = 0;
	self.resist_cells = 0.75;
	self.reflectlightning = TRUE;	// Reflect lightning strikes
	self.reflectplasma = TRUE;		// Reflect plasma projectiles

	self.th_checkattack = DPrinceCheckAttack;
	self.th_stand = dprince_stand1;
	self.th_walk = dprince_walk1;
	self.th_run = dprince_run1;
	self.th_melee = dprince_melee;
	self.th_charge = dprince_char_a1;
	self.th_missile = dprince_range;
	self.th_pain = dprince_pain;
	self.th_die = dprince_die;

	// randomize last melee attack
	self.meleeattack = rint(random()*3);

	self.classtype = CT_MONDPRINCE;
	self.classgroup = CG_DCAPTAIN;
	self.classmove = MON_MOVEWALK;
	
	// Start monster (default)
	monster_start();
};
