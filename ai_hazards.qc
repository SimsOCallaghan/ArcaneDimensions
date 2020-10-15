/*======================================================================
 HAZARD PROJECTILE Systems
 ------------------------

 * Flame (SPRITES)
 * Blobs (MODELS)

 * Hazard projectiles are about denying movement space to players
   and creating a temporary hazard to naviagate around
   
 * Players who jump a lot and have greater DM focused movement skills,
   will find hazard damage projectiles easier to deal with.
 
 * Hazard projectiles often have particle emitters or effects
   which can quickly drag down engine FPS. All hazard projectiles
   need to maintain counters to help performance.

 * Kill triggers can be dangerous on monsters that use hazard
   projectiles because the counters are not zero'd correctly
   
 * Void triggers do cope with hazard projectile counters
 
======================================================================*/	
float PROJ_MAXLIMIT = 32;		// Fire sprite limit per monster

.float		proj_count;			// Floor model/sprite active counter
.float		proj_limit;			// Maximum amount of floor model/sprite active
.vector		proj_attqty;		// Proj Count = Base (X) * (Skill * Y) Maximum = Z
.float		proj_attarc;		// Proj Arc Easy=-1/1, Normal=-2/2, Hard=-3/3
.entity		proj_source;		// Source entity for the floor projectiles

float FLAME_RED = 0;				// Default colour
float FLAME_GREEN = 1;				// Not implemented (Add later)
float FLAME_BLUE = 2;				// Extra blue version
float LIFE_HAZARD = 5;				// Bouncing hazard models
float LIFE_FLAME = 5;				// Long burning flame + 2 x random()
float FRAME_FLAME = 14;				// Maximum amount of frames
float FLAME_TINY = 1;				// 50% chance
float FLAME_SML = 2;				// 30% chance
float FLAME_MED = 5;				// 20% chance
float FLAME_VLRG = 10;				// Not implemented (Add later)

.entity		proj_trcont;		// Controller entity for flame lines
.float		proj_trqty;			// Fire trail quantity of flames to create
.float		proj_trdist;		// Fire trail distance for each flame segment
.float		proj_trstep;		// Fire trail step up/down height restrictions
.float		proj_trwobble;		// Fire trail wobble on X/Y axis going forward
.float		proj_trlife;		// Fire trail life time of flame sprites
.float		proj_trdmg;			// Fire trail explosive damage at end of line
.float		proj_trspeed;		// Fire trail tick timing speed

float FLAME_TRCOUNT = 12;			// Trail flame count
float FLAME_TRDIST = 32;			// Trail distance between flames
float FLAME_TRSTEP = 64;			// Trail flame ledge height
float FLAME_TRWOBBLE = 8;			// Trail flame random XY wobble
float FLAME_TREXPLODE = 40;			// Trail flame xxplosive damage
float FLAME_TRLIFE = 8;				// Trail flame life time
float FLAME_TRSPEED = 0.02;			// Trail flame standard speed

string MODEL_PROJ_FLAMETINY = "progs/s_flametiny.spr";
string MODEL_PROJ_FLAMESML = "progs/s_flamesml.spr";
string MODEL_PROJ_FLAMEMED = "progs/s_flamemed.spr";
string MODEL_PROJ_FLAMEVLRG = "progs/s_flamevlrg.spr";

// FIXME : Need to create good blue flames, easier said than done!
// Using the red flames for the moment, until new assets available
string MODEL_PROJ_BFLAMETINY = "progs/s_flametiny.spr";
string MODEL_PROJ_BFLAMESML = "progs/s_flamesml.spr";
string MODEL_PROJ_BFLAMEMED = "progs/s_flamemed.spr";
string MODEL_PROJ_BFLAMEVLRG = "progs/s_flamevlrg.spr";

//----------------------------------------------------------------------
void() PreCache_Flame = 
{
	precache_model (MODEL_PROJ_FLAMETINY);		// 16 (wide) x  48 (high)
	precache_model (MODEL_PROJ_FLAMESML);		// 24 (wide) x  64 (high)
	precache_model (MODEL_PROJ_FLAMEMED);		// 32 (wide) x  96 (high)
	//precache_model (MODEL_PROJ_FLAMEVLRG);		// 48 (wide) x 128 (high)
	precache_sound ("ambience/flames1.wav");
	precache_sound ("ambience/flames2.wav");
	precache_sound ("ambience/flames3.wav");
	precache_sound ("ambience/flames4.wav");
};

//----------------------------------------------------------------------
void() PreCache_BlueFlame = 
{
	precache_model (MODEL_PROJ_BFLAMETINY);		// 16 (wide) x  48 (high)
	precache_model (MODEL_PROJ_BFLAMESML);		// 24 (wide) x  64 (high)
	precache_model (MODEL_PROJ_BFLAMEMED);		// 32 (wide) x  96 (high)
	//precache_model (MODEL_PROJ_BFLAMEVLRG);		// 48 (wide) x 128 (high)
	precache_sound ("ambience/flames1.wav");
	precache_sound ("ambience/flames2.wav");
	precache_sound ("ambience/flames3.wav");
	precache_sound ("ambience/flames4.wav");
};

//----------------------------------------------------------------------
// Is there any space left to spawn a hazard projectile?
// return TRUE if counter is lower than limit
//----------------------------------------------------------------------
float(entity targ, float maxextra) HazardProjectile_CheckLimit =
{
	// Can't do a limit check if no limit (proj_limit) is set!
	// This allows for an override to be defined on attacker
	if (targ.proj_limit <= 0) {
		// Use global particle max to create limit
		// This is a good idea on paper, but this is trashing fps
		//targ.proj_limit = (part_max / (1024*part_multiplier)) * PROJ_MAXLIMIT;
		// Max limit = better default, anything higher will trash memory
		targ.proj_limit = PROJ_MAXLIMIT;
		dprint("\b[HAZARD]\b Monster ("); dprint(targ.classname);
		dprint(") Setup Max ("); dprint(ftos(targ.proj_limit));
		dprint(")\n");
	}
	// Really low chance of DP effects (def=0.02, -1=disabled)
	if (targ.dpp_flame == 0) targ.dpp_flame = 0.02;
	
	// has the hazard damage projectile limit been reached?
	// 'maxextra' used to check for complete projectile attack quantity
	if (targ.proj_count < (targ.proj_limit - maxextra)) return TRUE;
	else return FALSE;
};

//----------------------------------------------------------------------
// Single function for any increase in the projectile counter
// Double check the source entity exists first
//----------------------------------------------------------------------
void(entity targ) HazardProjectile_AddCounter =
{
	// Does the source exist?
	if (targ.proj_source != world) {
		// Update counters on source entity
		if (targ.proj_source.proj_count >= 0) {
			targ.proj_source.proj_count = targ.proj_source.proj_count + 1;
		}
	}
};

//----------------------------------------------------------------------
// Final function to decrease counters and remove entity
//----------------------------------------------------------------------
void(entity targ) HazardProjectile_Finished =
{
	// Does the source exist?
	if (targ.proj_source != world) {
		// Update counters on source entity
		if (targ.proj_source.proj_count > 0) {
			targ.proj_source.proj_count = targ.proj_source.proj_count - 1;
		}
	}
	// Only do this once
	targ.proj_source = world;

	// Puff of smoke
	if (targ.part_exitpuff)
		SpawnExplosion(EXPLODE_BURST_SMOKE, targ.origin+targ.view_ofs, "");
	
	// Stop any ambient sounds
	if (targ.part_exitsound) {
		sound(targ, CHAN_WEAPON, SOUND_EMPTY, 1, 1);
		sound(targ, CHAN_VOICE, SOUND_EMPTY, 1, 1);
		sound(targ, CHAN_ITEM, SOUND_EMPTY, 1, 1);
		sound(targ, CHAN_BODY, SOUND_EMPTY, 1, 1);
	}

	// Fade entity?
	if (targ.part_exitfade) {
		// Stop world interaction
		entity_stop(targ);
		targ.nextthink = time + 0.02;
		targ.think = model_fade;
	}
	// Remove entity
	else entity_remove(targ, 0.1);
};

//----------------------------------------------------------------------
void() HazardProjectile_Exit = { HazardProjectile_Finished(self); };

//----------------------------------------------------------------------
void() Animate_HazardProjectile =
{
	// Check if owner of flame is busy and needs flame to stop!
	if (self.owner.part_exitbusy > 0 && self.part_exitbusy == FALSE) {
		// Kill the entity this frame (0) or the next (+0.05)
		if (random() < 0.5) self.attack_finished = 0;
		else self.attack_finished = time + 0.05;
		// Randomly get rid of half of all smoke puffs
		if (self.part_exitpuff && random() < 0.5)
			self.part_exitpuff = FALSE;
		// Block this feature, its finished
		self.part_exitbusy = TRUE;
	}
	// Projectile has run out of time (cope with hazard counters)
	if (self.attack_finished < time) {HazardProjectile_Finished(self); return;}
	
	// Animate sprite
	self.walkframe = self.walkframe + 1;
	if (self.walkframe >= FRAME_FLAME) self.walkframe = 0;
	self.frame = self.walkframe;
	
	// Keep playing ambient sound
	if (self.noise != "" && self.volume < time) {
		sound(self, CHAN_AUTO, self.noise, 0.3, ATTN_IDLE);
		self.volume = time + 1;
	}

	// Advanced engines?
	if (ext_dppart) {
		// Way to disable DP/FTE/QSS particle effects
		if (self.owner.dpp_flame > 0) {
			// Really need low particle rate (can trash frame rate)
			if (query_configflag(SVR_SPRPARTON) == FALSE && random() < self.owner.dpp_flame) {
				// Only use this for the red flames
				if (self.part_style == PARTICLE_BURST_RED)
					// Use the small flame particle effect (dots+smoke)
					pointparticles(particleeffectnum(DPP_FLAMES), self.origin, '0 0 0', 1);
			}
		}
	}
	else {
		// Random particle spark
		if (random() < 0.05) SpawnProjectileSmoke(self.origin, 200, 50, 250);
		// Random particle burst, expects defaults have been setup
		if (random() < self.part_chance)
			particle_explode(self.origin+self.part_ofs, self.part_base+random()*self.part_rand, self.part_life+random(), self.part_style, 0);
	}
	
	// Keep looping
	self.think = Animate_HazardProjectile;
	self.nextthink = time + 0.1;	
};

//----------------------------------------------------------------------
void() Touch_HazardProjectile =
{
	if (self.touchedvoid) return;				// Marked for removal
	if (check_skycontent(self.origin)) { HazardProjectile_Finished(self); return;}
	if (other == self.owner) return;			// Touching attacker, do nothing
	if (other.solid == SOLID_TRIGGER) return;	// trigger field, do nothing
	if (other.classgroup == CG_PROJHAZARD) return;	// Touching other hazards
	if (self.attack_finished < time) return;	// Hazard finished, no more touch
	if (self.pain_finished > time) return;		// Slow down touch damage

	self.velocity = self.velocity * 0.5;	// Slow down velocity bounce
	self.pain_finished = time + 0.1;		// Slow down touch/pain cycle
	self.part_qctrail = FALSE;				// No more particle trail effect

	// Switch to trigger type so that monsters can interact with them
	// Need to reset size, so the solid type can be changed to trigger
	if (self.solid != SOLID_TRIGGER) {
		self.solid = SOLID_TRIGGER;
		setsize(self, self.bbmins, self.bbmaxs);
	}
	
	// Check if can damage target
	if (other.takedamage) {
		// Check target is the same group type as owner of projectile
		// This is to prevent groups of the same enemy type killing each other!
		if (other.classgroup == self.owner.classgroup) self.dmg = 0;
		else {
			// DMG easy=1-2, normal=1-3, hard=1-4, nm=1-5, evil=1-6
			self.dmg = 1;
			self.cnt = 1 + skill;
			// Loop through base + random damage
			while (self.cnt > 0) { 
				self.dmg = self.dmg + random(); 
				self.cnt = self.cnt - 1;
			}
		}

		//----------------------------------------------------------------------
		// LAVA SHIELD
		// Resistance = 50% fire/lava attacks
		if (other.flags & FL_CLIENT && other.moditems & IT_ARTLAVASHIELD) {
			PlayLavaShieldSound(other);
			if (self.dmg > 0) self.dmg = floor(self.dmg * 0.5);
		}
	
		//----------------------------------------------------------------------
		// Add any monster infighting modifiers (no negative or zero)
		// Round down the damage to integers (can cause logic issues)
		if (self.infightextra <= 0) self.infightextra = 1;
		if (self.dmg > 0) self.dmg = floor(self.infightextra * self.dmg);
		
		//----------------------------------------------------------------------
		// FINALLY any damage?
		if (self.dmg > 0) {
			// Spawn some blood, cause harm and play a sound!
			spawn_touchblood (self, other, self.dmg);
			T_Damage (other, self, self.owner, self.dmg, DAMARMOR);
			// Play touch sound if defined? (limit replay)
			if (self.part_soundtouch != "" && self.part_soundtimer < time) {
				self.part_soundtimer = time + 0.3;
				self.volume = 0.5 + (random() * 0.5);
				sound (self, CHAN_WEAPON, self.part_soundtouch, self.volume, ATTN_FEET);
			}
		}
	}
	else {
		// Any impact/miss sound defined?
		if (self.part_soundmiss != "") {
			sound (self, CHAN_WEAPON, self.part_soundmiss, 1, ATTN_FEET);
			// trigger sound once
			self.part_soundmiss = "";
		}
	}
};

/*======================================================================
 FLAME WALL PROJECTILE ATTACK
 * Uses sprites for animation/flame effect
 * Has radius and impact touch damage
======================================================================*/
// Wall of flame, left > right
// Easy = 3(-1/1), Normal = 5(-2/2), Hard/NM = 7(-3/3)
float(vector waveqty) SpriteCount_Flame =
{
	float wave_count;
	wave_count = waveqty_x + (skill * waveqty_y);
	if (wave_count > waveqty_z) wave_count = waveqty_z;
	return wave_count;
};

//----------------------------------------------------------------------
// target entity, origin, v_forward, colour, size, lifetime, speed
void(entity targ, vector org, vector dir, float proj_color, float proj_size, float proj_life, float proj_speed) Launch_Flame =
{
	// Check if the hazard projectile limit exists and has been reached?
	if ( !(HazardProjectile_CheckLimit(targ,1)) ) return;
	
	newmis = spawn ();
	newmis.owner = targ;
	newmis.classname = "proj_flame";	// obj name, not really used anymore
	newmis.classtype = CT_PROJ_FLAME;	// Class type number, quick identity
	newmis.classgroup = CG_PROJHAZARD;	// Special Hazard Projectile Type

	newmis.attack_speed = proj_speed;		// Projectile Speed (velocity)
	newmis.view_ofs = '0 0 16';				// Offset for particle effects
	newmis.oldorigin = newmis.origin = org;	// Save starting origin
	setorigin (newmis, newmis.origin);		// Move to start point

	// Allow for stationary fire hazards to exist
	if (newmis.attack_speed <= 0) newmis.movetype = MOVETYPE_NONE;
	else newmis.movetype = MOVETYPE_BOUNCE;
	// Need trigger type for monster/player interaction
	newmis.solid = SOLID_TRIGGER;

	// Monsters do extra (quad) damage to other monsters
	if (targ.flags & FL_MONSTER && targ.enemy.flags & FL_MONSTER) {
		// Take value from source monster so it can be changed
		newmis.infightextra = targ.infightextra;
	}
	
	// Setup Touch function and lifetime timer
	newmis.touch = Touch_HazardProjectile;
	if (proj_life <= 0) 
		newmis.attack_finished = time + LIFE_FLAME + random() + random();
	else newmis.attack_finished = time + proj_life;
	// On death, show puff of smoke and clear sounds
	newmis.part_exitpuff = targ.part_exitpuff;
	newmis.part_exitsound = targ.part_exitsound;
	newmis.part_exitfade = targ.part_exitfade;

	// Update hazard projectile counters
	newmis.proj_source = targ;
	HazardProjectile_AddCounter(newmis);
	
	//----------------------------------------------------------------------
	// Allow for random selection of sprite size
	if (proj_size <= 0) {
		newmis.lip = random();
		// 20% Medium, 30% Small, 50% Tiny
		if (newmis.lip < 0.2) proj_size = FLAME_MED;
		else if (newmis.lip < 0.5) proj_size = FLAME_SML;
		else proj_size = FLAME_TINY;
	}

	// Default = Tiny flame
	if (proj_size == FLAME_SML) {
		newmis.bbmins = '-6 -6 0'; newmis.bbmaxs = '6 6 24';
		if (proj_color == FLAME_BLUE) setmodel (newmis, MODEL_PROJ_BFLAMESML);
		else setmodel (newmis, MODEL_PROJ_FLAMESML);		// 24x64 BB=12x24
	}
	else if (proj_size == FLAME_MED) {
		newmis.bbmins = '-8 -8 0'; newmis.bbmaxs = '8 8 32';
		if (proj_color == FLAME_BLUE) setmodel (newmis, MODEL_PROJ_BFLAMEMED);
		else setmodel (newmis, MODEL_PROJ_FLAMEMED);		// 32x96 BB=16x32
	}
	/* Maybe add it later
	else if (proj_size == FLAME_VLRG) {
		newmis.bbmins = '-12 -12 0'; newmis.bbmaxs = '12 12 48';
		if (proj_color == FLAME_BLUE) setmodel (newmis, MODEL_PROJ_BFLAMEVLRG);
		else setmodel (newmis, MODEL_PROJ_FLAMEVLRG);	// 48x128 BB=24x48
	} */
	else {
		newmis.bbmins = '-4 -4 0'; newmis.bbmaxs = '4 4 16';
		if (proj_color == FLAME_BLUE) setmodel (newmis, MODEL_PROJ_BFLAMETINY);
		else setmodel (newmis, MODEL_PROJ_FLAMETINY);	// 16x48 BB=8x16
	}
	
	// override sprite default bounding box
	setsize (newmis, newmis.bbmins, newmis.bbmaxs);
	// Setup starting (randomize) frame
	newmis.walkframe = rint(random() * FRAME_FLAME);
	if (newmis.walkframe >= FRAME_FLAME) newmis.walkframe = 0;
	newmis.frame = newmis.walkframe;

	// Movement done in projectile tick function
	newmis.velocity = dir;
	newmis.avelocity = '0 0 0';

	newmis.lip = random();
	if (newmis.lip < 0.25) newmis.noise = "ambience/flames1.wav";
	else if (newmis.lip < 0.5) newmis.noise = "ambience/flames2.wav";
	else if (newmis.lip < 0.75) newmis.noise = "ambience/flames3.wav";
	else newmis.noise = "ambience/flames4.wav";
	sound(newmis, CHAN_VOICE, newmis.noise, 0.3, ATTN_IDLE);
	newmis.volume = time + 1;
	
	// Setup particle defaults for hazard emitter
	if (proj_color == FLAME_BLUE) newmis.part_trstyle = PARTICLE_TRAIL_PLASMA;
	newmis.part_trstyle = PARTICLE_TRAIL_YELLOW;
	Default_ParticleTrail(newmis);
	// Manually animate the sprite flames
	newmis.nextthink = time + 0.1;
	newmis.think = Animate_HazardProjectile;
};

/*======================================================================
 FLAME TRAIL PROJECTILE ATTACK
 * Uses sprites for animation/flame effect
 * Has radius and impact touch damage
======================================================================*/
void() Fire_Trail =
{
	local float trblocked, trstepup;
	
	// Is the flame trail active?
	if (self.count < 0) return;
	
	// Check if the hazard projectile limit exists and has been reached?
	if ( !(HazardProjectile_CheckLimit(self.owner,1)) ) trblocked = TRUE;
	else {
		// default condition
		trblocked = trstepup = FALSE;
		// Move forward along the line (movedir)
		self.pos2 = self.pos1 + (self.movedir * self.owner.proj_trdist);
		// Is next position is solid world/geo?
		if (pointcontents(self.pos2) == CONTENT_SOLID) {
			// Check maximum step height is available?
			if (pointcontents(self.pos2 + self.finaldest) == CONTENT_EMPTY) {
				// Trace down from maximum step height to find new pos
				traceline(self.pos2 + self.finaldest, self.pos2, TRUE, self);
				self.pos2 = trace_endpos + '0 0 8';
				trstepup = TRUE;
			}
			// Max step height is solid geo/world
			else trblocked = TRUE;
		}
		// Is next position solid, liquid or sky?
		if (pointcontents(self.pos2) != CONTENT_EMPTY) trblocked = TRUE;
		else {
			// Can previous position see next position? nothing blocking
			traceline(self.pos1, self.pos2, TRUE, self);
			// 'STEP UP' will often block line of sight to next point
			if (trace_fraction < 1 && trstepup == FALSE) trblocked = TRUE;
			else {
				// Find ground below next step point
				traceline(self.pos2, self.pos2 - (self.finaldest*2), TRUE, self);
				// Check distance between step points
				self.t_length = fabs(self.pos1_z - trace_endpos_z);
				// Can only step up or down a certain distance
				if ( self.t_length > (self.owner.proj_trstep+8)) trblocked = TRUE;
				// Check final position is not solid,liquid or sky
				if (pointcontents(trace_endpos) != CONTENT_EMPTY) trblocked = TRUE;
			}
		}
		
		// Is the next sprite blocked?
		if (trblocked == FALSE) {
			// Update line position (next point)
			self.pos1 = trace_endpos;
			// Random lifetime
			self.height = self.owner.proj_trlife + random() + random();
			// Setup random wobble to origin for new flame
			self.pos3 = vecrand(0, self.owner.proj_trwobble, TRUE);
			// Flatten any z changes first
			self.pos3_z = 0; self.pos3 = self.pos3 + self.pos1;
			// target, origin, v_forward, colour, size, lifetime, speed
			Launch_Flame (self.owner, self.pos3, '0 0 0', self.lip, -1, self.height, 0);
		}
	}

	// Keep counting down
	self.count = self.count - 1;
	// reach end of the line?
	if (self.count <= 0 || trblocked == TRUE) {
		self.count = 0;
		self.origin = self.pos1 + '0 0 24';
		// Move to explosion for t_radiusdamage
		setorigin(self, self.origin);
		SpawnExplosion(self.attack_expflame, self.origin, self.noise);
		// Any explosive damage?
		if (self.owner.proj_trdmg > 0) 
			T_RadiusDamage (self, self.owner, self.owner.proj_trdmg, world, DAMAGEALL);
	}
	else {
		// Keep looping
		self.think = Fire_Trail;
		self.nextthink = time + self.speed;
	}
};

//----------------------------------------------------------------------
void(vector org, vector dir, float proj_color, string proj_sfx) Launch_Trail =
{
	// Check if the hazard projectile limit exists and has been reached?
	if ( !(HazardProjectile_CheckLimit(self,1)) ) return;
	
	// Is the flame trail controller setup?
	if (!self.proj_trcont) self.proj_trcont = spawn ();
	// Is the flame trail currently active?
	if (self.proj_trcont.count > 0) return;
	
	self.proj_trcont.owner = self;
	self.proj_trcont.classname = "proj_trail";
	self.proj_trcont.classtype = CT_CONTROL;
	self.proj_trcont.classgroup = CG_PROJHAZARD;

	self.proj_trcont.solid = SOLID_NOT;
	self.proj_trcont.movetype = MOVETYPE_NONE;
	self.proj_trcont.origin = self.origin + '0 0 64';
	setorigin(self.proj_trcont, self.proj_trcont.origin);
	setsize(self.proj_trcont, VEC_ORIGIN, VEC_ORIGIN);
	self.proj_trcont.movedir = dir;
	
	// Quantity of sprites per line
	if (self.proj_trqty <= 0) self.proj_trqty = FLAME_TRCOUNT;
	// Always reset count to new value (loop variable)
	self.proj_trcont.count = self.proj_trqty;

	// Sprite flame colour (def=red)
	if (proj_color <= 0) self.proj_trcont.lip = FLAME_RED;
	else self.proj_trcont.lip = proj_color;
	// Setup explosion sprite to match projectile
	if (self.proj_trcont.lip == FLAME_BLUE)
		self.proj_trcont.attack_expflame = EXPLODE_PLASMA_BIG;
	else self.proj_trcont.attack_expflame = EXPLODE_BIG;
	// Final explosion sound FX
	if (proj_sfx == "") self.proj_trcont.noise = SOUND_REXP3;
	else self.proj_trcont.noise = proj_sfx;
	
	// Setup trail segment distance, random wobble and max step height
	if (self.proj_trdist <= 0) self.proj_trdist = FLAME_TRDIST;
	if (self.proj_trwobble <= 0) self.proj_trwobble = FLAME_TRWOBBLE;
	if (self.proj_trstep <= 0) self.proj_trstep = FLAME_TRSTEP;

	// Final explosive damage at end of line/trail (-1 = no damage)
	if (self.proj_trdmg == 0) self.proj_trdmg = FLAME_TREXPLODE;
	// Life time for flames to remain on floor (x + rnd + rnd)
	if (self.proj_trlife <= 0) self.proj_trlife = FLAME_TRLIFE;
	
	// Speed at which flame line is created (tick speed)
	// Skill based speed 0=0.10, 1=0.08, 2=0.06, 3=0.04
	if (self.proj_trspeed > 0.04) self.proj_trcont.speed = self.proj_trspeed;
	else self.proj_trcont.speed = 0.1 - (skill * FLAME_TRSPEED);
	// Always have lower limit for speed tick value
	if (self.proj_trcont.speed < 0.04) self.proj_trcont.speed = 0.04;
	
	// Setup STEP height as a vector
	self.proj_trcont.finaldest = '0 0 0'; 
	self.proj_trcont.finaldest_z = self.proj_trstep + 8;

	// Find out start position
	traceline(org, org - self.proj_trcont.finaldest, TRUE, self);
	self.proj_trcont.pos1 = trace_endpos;
	
	// Start with initial flame
	// target, origin, v_forward, colour, size, lifetime, speed
	Launch_Flame (self, self.proj_trcont.pos1, '0 0 0', self.proj_trcont.lip, -1, -1, 0);

	// Keep the conga line going ...
	self.proj_trcont.think = Fire_Trail;
	self.proj_trcont.nextthink = time + self.proj_trcont.speed;
};

/*======================================================================
 HAZARD PROJECTILES 
 * Uses models and particle/trails for effects
 * Has radius and impact touch damage
======================================================================*/
void(vector org, vector dir, vector avel, float proj_type) Launch_Hazard =
{
	// Check if the hazard projectile limit exists and has been reached?
	if ( !(HazardProjectile_CheckLimit(self,1)) ) return;
	
	newmis = spawn ();
	newmis.owner = self;
	newmis.classname = "proj_hazard";	// obj name, not really used anymore
	newmis.classtype = proj_type;		// Class type number, quick identity
	newmis.classgroup = CG_PROJHAZARD;	// Special Hazard Projectile Type

	newmis.movetype = MOVETYPE_BOUNCE;	// Bounce like a grenade, classic arc
	newmis.solid = SOLID_BBOX;			// trigger is limited, use bbox until touch
	newmis.bbmins = '-4 -4 0'; 			// Save for touch function
	newmis.bbmaxs = '4 4 0';

	// Setup Touch function and lifetime timer
	newmis.touch = Touch_HazardProjectile;
	newmis.attack_finished = time + LIFE_HAZARD + random() + random();

	// Update hazard projectile counters
	newmis.proj_source = self;
	HazardProjectile_AddCounter(newmis);

	// Monsters do extra (quad) damage to other monsters
	if (self.flags & FL_MONSTER && self.enemy.flags & FL_MONSTER) {
		// Take value from source monster so it can be changed
		newmis.infightextra = self.infightextra;
	}

	// Setup model for each missile type
	//----------------------------------------------------------------------
	if (proj_type == CT_PROJ_DPRINCE2) {
		setmodel(newmis, self.attack_proj2);
		newmis.part_qctrail = TRUE;
		newmis.part_trstyle = self.part_trstyle;
		newmis.frame = rint((random() * 9));
		newmis.part_soundmiss = "dknight/dprince_miss.wav";
	}
	else if (proj_type == CT_PROJ_SWEEPER2) {
		setmodel(newmis, self.attack_proj2);
		newmis.part_qctrail = TRUE;
		newmis.part_trstyle = self.part_trstyle;
		newmis.frame = rint((random() * 9));
		newmis.part_soundmiss = "sweeper/hazard_miss.wav";
	}
	
	// Standard projectile setup (origin, size and velocity)
	//----------------------------------------------------------------------
	newmis.velocity = dir;
	newmis.avelocity = avel;
	newmis.angles = vectoangles(newmis.velocity);
	newmis.oldorigin = newmis.origin = org;	// Save starting origin
	setorigin (newmis, newmis.origin);		// Move to start point
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);

	// Burning touch sound (precached in world.qc)
	newmis.part_soundtouch = GIB_SOUND_ACID;
	// Setup particle defaults for hazard emitter
	Default_ParticleTrail(newmis);
	newmis.think = Custom_ParticleTrail;	
	newmis.nextthink = time + 0.1;

	// Special particle trail
	//----------------------------------------------------------------------
	if (newmis.part_qctrail == TRUE ) {
		// Is DP/FTE/QSS engine active for particle trail feature?
		if (ext_dppart && newmis.dpp_name != "") {
			newmis.traileffectnum = particleeffectnum(newmis.dpp_name);
			newmis.effects = 0;
		}
		// Particle trail needs quick update
		newmis.nextthink = time + 0.02;
	}
};

