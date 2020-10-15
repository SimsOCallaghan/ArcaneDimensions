/*======================================================================
  CheckDeBuff - Check for negative buffs affecting the player
======================================================================*/

.float		debuff_sound;		// Heartbeat sound when tick happens
.float		debuff_qty;			// Quantity to do something with (temp)

.float		bleeding;			// Bleeding debuff status
.float		bleeding_time;		// Timer (1s tick) for screen/sound update
.float		bleeding_qty;		// Total amount of health stored (HoT)

.float		rotting;			// Rotting debuff status (DoT)
.float		rotting_time;		// Timer (1s tick) for health update
// Has to be defined early in defscustom.qc because of the randomizer.qc
//.float		rotting_qty;		// Total ammount to rot down (DoT)

.float		burning;			// Burning debuff status
.float		burning_time;		// Timer (1s tick) for screen/sound update
.float		burning_qty;		// Total amount of damage stored (DoT)

.float		poisoned;			// Poison debuff status
.float		poisoned_time;		// Timer (1s tick) for screen/sound update
.float		poisoned_qty;		// Total amount of damage stored (DoT)

// IT_INVISIBILITY + IT_INVULNERABILITY + IT_SUIT + IT_QUAD
// 524288 + 1048576 + 2097152 + 4194304
float ALL_ITARTIFACTS = 7864320;

// Wraith Health drain
vector DEBUFF_BLEED_COL = '50 35 0';		// Dark Orange
float DEBUFF_BLEED_DEN = 80;
float DEBUFF_BLEED_STEP = 10;

vector DEBUFF_START_BLEED_COL = '200 0 0';	// Strong red
float DEBUFF_START_BLEED_DEN = 160;
float DEBUFF_START_BLEED_STEP = 7;

float DEBUFF_BLEED_MIN = 5;				// Minimum health to apply debuff
float DEBUFF_BLEED_DMG = 10;			// Immunity with pent/envsuit

// Pyro flame burn
vector DEBUFF_BURN_COL = '200 100 0';	// Orange
float DEBUFF_BURN_DEN = 120;
float DEBUFF_BURN_STEP = 10;
float DEBUFF_BURN_DMG = 1;				// Damage Over Time
float DEBUFF_BURN_MAX = 10;				// Max amount of burning multiplier

// Mummy poisoned gibs
vector DEBUFF_POISON_COL = '0 200 0';	// Strong Green
float DEBUFF_POISON_DEN = 80;
float DEBUFF_POISON_STEP = 7;
float DEBUFF_POISON_DMG = 1;			// Damage Over Time

//----------------------------------------------------------------------
// Various debuff reset functions, used all over the place
//----------------------------------------------------------------------
void(entity targ) ResetDebuffScreen =
{
	targ.cshift_upd = FALSE;
	targ.cshift_time = LARGE_TIMER;
	stuffcmd(targ, "v_cshift 0 0 0 0\n");
	targ.cshift_col = '0 0 0';
	targ.cshift_den = 0;
};

void(entity targ) ResetDebuffBurning =
{ targ.burning = targ.burning_qty = 0; };

void(entity targ) ResetDebuffRotting = {
	targ.rotting = 0; 
	// Force reset health and remove MH inventory item
	if (targ.health > targ.max_health) targ.health = targ.max_health;
	targ.items = targ.items - (targ.items & IT_SUPERHEALTH);
};

void(entity targ) ResetDebuffPoisoned =
{ targ.poisoned = targ.poisoned_qty = 0; };

void(entity targ) ResetDebuffBleeding =
{ targ.bleeding = targ.bleeding_qty = 0; };

//----------------------------------------------------------------------
void(entity targ) ResetDebuffSystem =
{
	// This only works for player clients
	if (!(targ.flags & FL_CLIENT)) return;
	
	ResetDebuffScreen(targ);
	ResetDebuffBurning(targ);
	ResetDebuffPoisoned(targ);
	ResetDebuffBleeding(targ);
};

//----------------------------------------------------------------------
// Core debuff function, run every frame from client.qc
//----------------------------------------------------------------------
void() ClientDeBuff =
{
	// Check is self is a NOT player (client) FIRST!
	// Bug fix from ericw on func msgboard
	// #655 posted by ericw on 2018/04/10 09:53:36
	if (!(self.flags & FL_CLIENT)) return;
	
	// If player is dead or intermission running, turn everything off
	// Cinematic camera system exception is later on in code
	if (intermission_running > 0 || self.health < 1) {
		ResetDebuffSystem(self);
		return;
	}

	// Check for burning debuff (DoT)
	if (self.burning) {
		// Is it time for a debuff update
		if (self.burning_time < time) {
			if (self.burning_qty > 0) {
				// Reset burning tick timer
				self.burning_time = time + 1;
				
				// Give priority to bleeding(heal) and poisoned
				if (!self.bleeding && !self.poisoned) {
					if (self.debuff_sound < time) self.debuff_sound = time + 1;
					self.cshift_upd = TRUE;		// Update screen colour
					self.cshift_time = -1;		// Update striaght away
					self.cshift_col = DEBUFF_BURN_COL;
					self.cshift_den = DEBUFF_BURN_DEN;
					self.cshift_step = DEBUFF_BURN_STEP;
				}
				
				// Setup default burning damage
				self.debuff_qty = DEBUFF_BURN_DMG;
				// Check burning does not exceed stored damage
				if (self.burning_qty < self.debuff_qty) self.debuff_qty = self.burning_qty;
				// Subtract burning damage from counters
				self.burning_qty = self.burning_qty - self.debuff_qty;
				
				// Use global damage function (has death checks)
				T_Damage (self, world, world, self.debuff_qty, NOARMOR);
			}
		}
		// Check if player is in water up to waist?
		// 0 = not in, 1 = feet, 2 = waist, 3 = eyes
		if (self.waterlevel >= 2 || self.burning_qty < 1) {
			ResetDebuffBurning(self);
		}
	}
	
	// Check for poisoned debuff (DoT)
	if (self.poisoned) {
		// Is it time for a debuff update
		if (self.poisoned_time < time) {
			if (self.poisoned_qty > 0) {
				// Reset poisoned tick timer
				self.poisoned_time = time + 1;

				// Give priority to bleeding(heal)
				if (!self.bleeding) {
					if (self.debuff_sound < time) self.debuff_sound = time + 1;
					self.cshift_upd = TRUE;		// Update screen colour
					self.cshift_time = -1;		// Update striaght away
					self.cshift_col = DEBUFF_POISON_COL;
					self.cshift_den = DEBUFF_POISON_DEN;
					self.cshift_step = DEBUFF_POISON_STEP;
				}
				
				// Setup default poison damage
				self.debuff_qty = DEBUFF_POISON_DMG;
				// Check poison does not exceed damage left
				if (self.poisoned_qty < self.debuff_qty) self.debuff_qty = self.poisoned_qty;
				// Subtract poison damage from counters
				self.poisoned_qty = self.poisoned_qty - self.debuff_qty;
				
				// Use global damage function (has death checks)
				T_Damage (self, world, world, self.debuff_qty, NOARMOR);
			}
		}
		// Check if poison has finished?
		if (self.poisoned_qty < 1) ResetDebuffPoisoned(self);
	}

	// Check for bleeding debuff (HoT)
	if (self.bleeding) {
		// Is it time for a debuff update
		if (self.bleeding_time < time) {
			if (self.bleeding_qty > 0) {
				// Reset bleeding(healing) tick timer
				self.bleeding_time = time + 1;
				if (self.debuff_sound < time) self.debuff_sound = time + 1;
				self.cshift_upd = TRUE;		// Update screen colour
				self.cshift_time = -1;		// Update striaght away
				self.cshift_col = DEBUFF_BLEED_COL;
				self.cshift_den = DEBUFF_BLEED_DEN;
				self.cshift_step = DEBUFF_BLEED_STEP;

				// Setup default healing
				// Check healing does not exceed current reserve
				if (self.bleeding_qty < map_bleedingdmg_y) self.debuff_qty = self.bleeding_qty;
				else self.debuff_qty = map_bleedingdmg_y;
				// Subtract bleeding heals from counter
				self.bleeding_qty = self.bleeding_qty - self.debuff_qty;
				
				// Directly add health back to player
				self.health = self.health + self.debuff_qty;
				if (self.health > self.max_health) self.health = self.max_health;
			}
		}
		// Check if player is over max health or run out of healing
		if (self.health >= self.max_health || self.bleeding_qty < 1) {
			ResetDebuffBleeding(self);
		}
	}

	// Check for rotting debuff (DoT)
	if (self.rotting) {
		// Is it time for a debuff update
		if (self.rotting_time < time) {
			if (self.health > self.max_health) {
				// Reset rotting tick timer
				self.rotting_time = time + 1;
				// Directly subject health from player
				self.health = self.health - self.rotting_qty;
			}
		}
		// Reset (if over max) HP and remove inventory item
		if (self.health <= self.max_health) ResetDebuffRotting(self);
	}
	
	// Don't need sound or visual updates for cinematic stuff
	if (cinematic_running) return;
	
	// Check for any debuff screen updates?
	if (self.cshift_upd) {
		// Play different debuff sounds (pressure is on!)
		if (self.debuff_sound > time) {
			self.debuff_sound = -1;		// Reset

			// Sound exception for god/pentagram mode
			if (self.flags & FL_GODMODE || self.invincible_finished >= time) {
				PlayPentagramSound(self);
			}
			else {
				// Play heartbeat only for bleeding/healing
				if (self.bleeding) 
					sound (self, CHAN_VOICE, SOUND_HEARTBEAT, 1, ATTN_IDLE);
				// Re-use player pain sounds
				else if (self.poisoned) {
					if (random() < 0.5) sound (self, CHAN_VOICE, "player/pain2.wav", 1, ATTN_IDLE);
					else sound (self, CHAN_VOICE, "player/pain3.wav", 1, ATTN_IDLE);
				}
				// Play on the same channel as player pain
				else if (self.burning) {
					if (random() < 0.5) sound (self, CHAN_VOICE, "player/pain1.wav", 1, ATTN_IDLE);
					else sound (self, CHAN_VOICE, "player/pain4.wav", 1, ATTN_IDLE);
				}
			}
		}
		// Check for screen update? 0.1s tick interval
		if (self.cshift_time < time) {
			// Generate some particles based on debuff
			// Priority is bleeding > poisoned > burning
			if (self.bleeding) particle_debuff(self.origin, 16, rint(1+random()*4), PARTICLE_BURST_RED);
			else if (self.poisoned) particle_debuff(self.origin, 16, rint(1+random()*4), PARTICLE_BURST_GREEN);
			else if (self.burning) particle_debuff(self.origin, 16, rint(1+random()*4), PARTICLE_BURST_YELLOW);

			// Count down density and check for reset condition
			self.cshift_den = self.cshift_den - self.cshift_step;
			if (self.cshift_den < 1) ResetDebuffScreen(self);
			else {
				// Update screen using stuffcmds!
				self.cshift_time = time + 0.1;

				// Don't update the screen if an artifact is active
				// The engine will be updating at the same time
				if (self.items & ALL_ITARTIFACTS == 0) {
					stuffcmd(self, "v_cshift ");
					stuffcmd(self, ftos(rint(self.cshift_col_x)));
					stuffcmd(self, " ");
					stuffcmd(self, ftos(rint(self.cshift_col_y)));
					stuffcmd(self, " ");
					stuffcmd(self, ftos(rint(self.cshift_col_z)));
					stuffcmd(self, " ");
					stuffcmd(self, ftos(rint(self.cshift_den)));
					stuffcmd(self, "\n");
				}
			}
		}
	}
	// Reset cshift if nothing is active (engine does not reset)
	// This is to catch new games or quickload resets
	else if (self.cshift_time < time) ResetDebuffScreen(self);
};

//----------------------------------------------------------------------
void(entity targ) BleedDeBuff =
{
	local float pain_type;
	
	// Sanity check!
	if (!(targ.flags & FL_CLIENT)) return;
	// Check for bleeding and minimum amount of health for debuff
	if (targ.health <= DEBUFF_BLEED_MIN) return;
	if (targ.bleeding == TRUE) {
		// Do minimum damage, checked min does not kill before
		T_Damage (targ, self, self, DEBUFF_BLEED_MIN, DAMARMOR);
		return;
	}
	// Immune to debuff if using Pent of Protection or BioSuit
	if (targ.items & (IT_INVULNERABILITY | IT_SUIT)) {
		T_Damage (targ, self, self, DEBUFF_BLEED_DMG, DAMARMOR);
		return;
	}
	
	// Starting bleeding!
	targ.bleeding = TRUE;
	// Pause before bleeding Healing starts (def=1s)
	targ.bleeding_time = time + map_bleedingdmg_z;

	// Pick a random player sound
	pain_type = rint(random() * 3);
	if (pain_type < 1) sound (targ, CHAN_VOICE, "player/pain4.wav", 1, ATTN_NORM);
	else if (pain_type < 2) sound (targ, CHAN_VOICE, "player/pain5.wav", 1, ATTN_NORM);
	else sound (targ, CHAN_VOICE, "player/pain6.wav", 1, ATTN_NORM);

	// Work out maximum bleed HP (remove MH excess)
	targ.bleeding_qty = targ.health;
	if (targ.bleeding_qty > targ.max_health) targ.bleeding_qty = targ.max_health;
	// Reduce HP down to % (def=0.25) and restore the rest later on
	targ.health = rint(targ.bleeding_qty * map_bleedingdmg_x);
	targ.bleeding_qty = targ.bleeding_qty - targ.health;

	targ.cshift_upd = TRUE;		// Update screen colour
	targ.cshift_time = -1;		// Update striaght away
	targ.cshift_col = DEBUFF_START_BLEED_COL;
	targ.cshift_den = DEBUFF_START_BLEED_DEN;
	targ.cshift_step = DEBUFF_START_BLEED_STEP;
};

//----------------------------------------------------------------------
void(entity targ, float rotoverride) RotDeBuff =
{
	// Only need to check for player/client
	if (targ.flags & FL_CLIENT == FALSE) return;

	// Extra Health is added via item pickup
	targ.rotting = TRUE;
	
	// Check for a rotting override value
	if (rotoverride <= 1) targ.rotting_qty = 1;
	else targ.rotting_qty = rotoverride;
	
	// Always give inventory item
	targ.items = targ.items | IT_SUPERHEALTH;
	// 5s second pause to start of HP rot
	targ.rotting_time = time + 5;
};

//----------------------------------------------------------------------
void(entity targ) BurnDeBuff =
{
	local float debuffqty;
	
	// Do not stack burning time beyond a certain limit
	// Cannot be burning if knee deep in water
	// Immune to debuff if using Pent of Protection or BioSuit
	if (targ.burning_qty > DEBUFF_BURN_MAX) return;
	if (targ.flags & FL_CLIENT == FALSE) return;
	if (targ.waterlevel >= 3) return;
	if (targ.items & (IT_INVULNERABILITY | IT_SUIT)) return;
	
	// if debuff not active, starting burning!
	if (!targ.burning) {
		targ.burning = TRUE;
		targ.burning_time = -1;
	}
		
	// work out time remaining on debuff
	debuffqty = rint(5*skill + 3 + 2*random());
	targ.burning_qty = targ.burning_qty + debuffqty;
	if (targ.burning_qty > DEBUFF_BURN_MAX) targ.burning_qty = DEBUFF_BURN_MAX;

	targ.cshift_upd = TRUE;		// Update screen colour
	targ.cshift_time = -1;		// Update striaght away
	targ.cshift_col = DEBUFF_BURN_COL;
	targ.cshift_den = DEBUFF_BURN_DEN;
	targ.cshift_step = DEBUFF_BURN_STEP;
};

//----------------------------------------------------------------------
void(entity targ) PoisonDeBuff =
{
	local float debuffqty;
	
	// Immune to debuff if using Pent of Protection or BioSuit
	if (targ.flags & FL_CLIENT == FALSE) return;
	if (targ.items & (IT_INVULNERABILITY | IT_SUIT)) return;
	if (targ.poisoned) return;	// Only poison once
	
	// work out time remaining on debuff
	// poison time Easy=3+2 Normal=4+2, Hard=5+2, NM=6+2, Evil=7+2
	debuffqty = floor(skill + 3 + 2*random());
	// Air tanks help reduce poison debuff duration
	if (targ.moditems & IT_ARTAIRTANK) debuffqty = floor(debuffqty * 0.5);
	// Is there any poison debuff time left?
	if (debuffqty > 0) {
		targ.poisoned = TRUE;
		targ.poisoned_time = -1;
		targ.poisoned_qty = debuffqty;
		targ.cshift_upd = TRUE;		// Update screen colour
		targ.cshift_time = -1;		// Update striaght away
		targ.cshift_col = DEBUFF_POISON_COL;
		targ.cshift_den = DEBUFF_POISON_DEN;
		targ.cshift_step = DEBUFF_POISON_STEP;
	}
};

//----------------------------------------------------------------------
// Used by Pyro and Wraith; consistent damage from both monsters
//----------------------------------------------------------------------
void(entity targ, float playdmg, float mondmg) ApplyFireDmg =
{
	local float reduction, firedamage;
	
	// Bio suit reduction - easy=80%, normal=70%, hard=60%, nm=50%
	reduction = 0.2 + skill * 0.1;
	
	// Damage is different for monsters/players
	if (targ.flags & FL_MONSTER) firedamage = mondmg;
	else if (targ.items & IT_SUIT) firedamage = rint(playdmg * reduction);
	else firedamage = playdmg;
	
	// Final damage (no armour save)
	T_Damage (targ, self, self.owner, firedamage, NOARMOR);
	BurnDeBuff(targ);
};
