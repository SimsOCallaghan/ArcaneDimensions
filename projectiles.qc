/*======================================================================
 PROJECTILE / BLOOD FUNCTIONS
======================================================================*/

// Classic ID rocket/grenade explosion
void() s_explode1 = [0,	s_explode2] {};
void() s_explode2 = [1,	s_explode3] {};
void() s_explode3 = [2,	s_explode4] {};
void() s_explode4 = [3,	s_explode5] {};
void() s_explode5 = [4,	s_explode6] {};
void() s_explode6 = [5,	SUB_Remove] {};

//----------------------------------------------------------------------
void() BecomeExplosion =
{
	self.touch = SUB_Null;
	self.velocity = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	// DP extended engines have particle explosions instead of sprites
	if (ext_dppart) {
		setmodel(self, "");
		self.nextthink = time + 0.6;
		self.think = SUB_Remove;
	}
	else {
		setmodel (self, "progs/s_explod.spr");	// Play sprite explosion
		self.solid = SOLID_NOT;
		s_explode1 ();
	}
};

//----------------------------------------------------------------------
// General purpose animated spite function
// Types: Small, medium, big, plasma, puffpuff!
//----------------------------------------------------------------------
void() SpawnExplosion_think =
{
	self.frame = self.frame + 1;
	if (self.frame > self.count) SUB_Remove();
	else self.nextthink = time + self.speed;
};

//----------------------------------------------------------------------
void(float sprite_type, vector org, string expl_sound) SpawnExplosion =
{
	local string spr_name;
	local float spr_count, spr_speed;
	
	spr_count = -1;
	if (sprite_type == EXPLODE_SMALL) {
		spr_name = "progs/s_explod.spr";
		spr_count = 5;
		spr_speed = 0.1;
	}
	else if (sprite_type == EXPLODE_MED) {
		spr_name = "progs/s_explodmed.spr";
		spr_count = 13;
		spr_speed = 0.05;
	}
	else if (sprite_type == EXPLODE_BIG) {
		spr_name = "progs/s_explodbig.spr";
		spr_count = 16;
		spr_speed = 0.05;
	}
	else if (sprite_type == EXPLODE_SMALLP) {
		if (ext_dppart)
			pointparticles(particleeffectnum(DPP_TEPLASMA), org, '0 0 0', 1);
		else {
			spr_name = "progs/s_explodsmallp.spr";
			spr_count = 12;
			spr_speed = 0.05;
		}
	}
	else if (sprite_type == EXPLODE_BIGP) {
		if (ext_dppart)
			pointparticles(particleeffectnum(DPP_TELRGPLASMA), org, '0 0 0', 1);
		else {
			spr_name = "progs/s_explodbigp.spr";
			spr_count = 12;
			spr_speed = 0.05;
		}
	}
	else if (sprite_type == EXPLODE_ELEC) {
		if (ext_dppart)
			pointparticles(particleeffectnum(DPP_TEPLASMA), org, '0 0 0', 1);
		else {
			spr_name = "progs/s_plasma.spr";
			spr_count = 4;
			spr_speed = 0.1;
		}
	}
	else if (sprite_type == EXPLODE_PUFF) {
		spr_name = "progs/s_smoke.spr";
		spr_count = 6;
		spr_speed = 0.05;
	}
	else return;
	
	if (spr_count > 0) {
		newmis = spawn();
		newmis.classgroup = CG_TEMPENT;
		newmis.movetype = MOVETYPE_NONE;
		newmis.solid = SOLID_NOT;
		
		setmodel(newmis, spr_name);
		setorigin(newmis, org);
		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
		newmis.alpha = 0.7;			// Slightly transparent
		newmis.effects = 32;		// Additive blending
		newmis.count = spr_count;	// Total frames
		newmis.speed = spr_speed;	// Frame speed

		if (expl_sound != "") sound(newmis, CHAN_WEAPON, expl_sound, 1, ATTN_NORM);
		newmis.think = SpawnExplosion_think;
		newmis.nextthink = time + newmis.speed;
	}
};

//----------------------------------------------------------------------
void(vector org, float velrnd, float uprnd) SpawnProjectileSmoke =
{
	newmis = spawn();
	newmis.classgroup = CG_TEMPENT;
	newmis.movetype = MOVETYPE_TOSS;
	newmis.solid = SOLID_NOT;
	setmodel(newmis, MODEL_PROJ_SMOKE);
	setorigin(newmis, org);
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	newmis.velocity = vecrand(0,velrnd,TRUE);
	newmis.velocity_z = random()*uprnd;
	newmis.nextthink = time + 1 + random()*3;
	newmis.think = SUB_Remove;
};

//----------------------------------------------------------------------
void(vector org, float velrnd, float uprnd) SpawnProjectileMeat =
{
	newmis = spawn ();
	newmis.classtype = CT_TEMPGIB;
	newmis.classgroup = CG_TEMPENT;
	newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_NOT;
	setmodel (newmis, MODEL_PROJ_FLESH);
	setorigin (newmis, org);
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	newmis.velocity = vecrand(0,velrnd,TRUE);
	newmis.velocity_z = random()*uprnd;
	newmis.avelocity = vecrand(100,velrnd,FALSE);
	if (ext_dppart) DPP_blood_trail(newmis);
	newmis.nextthink = time + 1 + random()*3;
	newmis.think = SUB_Remove;
};

//----------------------------------------------------------------------
// SpawnBlood
//----------------------------------------------------------------------
void(entity targ, vector org, vector vel, float part_qty) SpawnBlood =
{
	local float loop_count, part_col;
	loop_count = 0;
	vel = vel * 0.1;
	part_qty = part_qty / 2;

	// Exception - breakables don't really bleed red blood
	if (targ.classgroup == CG_BREAKABLE) part_col = targ.bleedcolour;
	else part_col = MON_BCOLOR_RED;
	
	// Loop through particle count creating bursts of particles
	while(loop_count < 4) {
		if (loop_count == 2 && targ.bleedcolour > 0) part_col = targ.bleedcolour;
		particle (org, vel, part_col + rint(random()*7), part_qty);
		loop_count = loop_count + 1;
	}
};

//----------------------------------------------------------------------
// spawn_touchblood
// Triggered by Touch_Bullet, Touch_PlasmaProjectile, Touch_Projectile
// Used by monsters - DFURY, DOG, FISH, SCORPION, SPIDER, VORELING, ZOMBIEK
//----------------------------------------------------------------------
void(entity source, entity targ, float damage) spawn_touchblood =
{
	local vector org, vel;

	// The vel calculation uses v_up/right, make sure vectors is setup
	makevectors(source.angles);
	vel = normalize (source.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	// Originally vel = ((vel * 200) * 0.2) * 0.01
	vel = vel * 0.4;
	
	// Check for an origin blood offset (monsters)
	if (source.meleeoffset != '0 0 0')
		org = v_forward*source.meleeoffset_x + v_right*source.meleeoffset_y + v_up*source.meleeoffset_z;
	else org = '0 0 0';
	
	SpawnBlood (targ, source.origin + org, vel, damage);
};

//======================================================================
// SpawnMeatSpray
// Changed to remove dependance on 'self' for missile origin
// Changed parameters to add source and destination of attack
// Changed velocity to side so it is calculated correctly from angles
//======================================================================
void(entity source, entity targ, float side) SpawnMeatSpray =
{
	local vector org;

	makevectors(source.angles);

	// Check for a melee offset? - Special vector offset
	if (source.meleeoffset != '0 0 0')
		org = v_forward*source.meleeoffset_x + v_right*source.meleeoffset_y + v_up*source.meleeoffset_z;
	else org = v_forward * 16;
	
	// Create starting point to spawn
	org = org + source.origin;

	if (targ.bleedcolour) SpawnBlood(targ, org, v_up*2, 100);
	else {
		newmis = spawn ();
		newmis.classtype = CT_TEMPGIB;
		newmis.classgroup = CG_TEMPENT;
		newmis.owner = source;
		newmis.movetype = MOVETYPE_BOUNCE;
		newmis.solid = SOLID_NOT;
		setmodel (newmis, MODEL_PROJ_FLESH);
		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
		setorigin (newmis, org);
	
		// Use side velocity to determine which direction to throw
		newmis.velocity = ((crandom()*16) * v_forward) + (side * v_right);
		newmis.velocity_z = newmis.velocity_z + 150 + 50*random();
		
		newmis.avelocity = vecrand(100,200,FALSE);
		if (ext_dppart) DPP_blood_trail(newmis);
		// set newmis duration
		newmis.nextthink = time + 1 + random()*3;
		newmis.think = SUB_Remove;
	}
};

/*======================================================================
 NEW STYLE BULLET SYSTEM (PROJECTILE)
======================================================================*/
void(entity targ, vector org, vector vel, float damage) Resist_Shells =
{
	if (targ.health > 0 && targ.pain_finished < time) {
		targ.pain_finished = time + 0.3 + random();
		sound (targ, CHAN_VOICE, targ.pain_sound, 1, ATTN_NORM);
	}
	// Drastically reduce blood particles
	SpawnBlood (targ, org, vel*0.2, damage/4);
	if (random() < 0.3) {
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		if (random() < 0.5) WriteByte (MSG_BROADCAST, TE_SPIKE);
		else WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
		SpawnProjectileSmoke(org, 200, 200);
	}
};

//----------------------------------------------------------------------
void() Particle_Bullet =
{
	// Is the touch function blocked?
	if (self.waitmin > time) return;
	if (self.delay < time) entity_remove(self, 1);
	else {
		if (random() < 0.5) {
			self.oldorigin = crandom() * '1 1 1';
			if (random() < 0.8) self.lip = rint(random()*4);
			else self.lip = 112 + rint(random()*4);
			particle (self.origin, self.oldorigin, self.lip, 1 + rint(random()*2));
		}
		self.think = Particle_Bullet;
		self.nextthink = time + self.speed;
	}
};

//----------------------------------------------------------------------
void() Touch_Bullet =
{
	if (check_skycontent(self.origin)) {entity_remove(self, 0.1); return;}
	if (self.touchedvoid) return;				// Marked for removal
	if (other == self.owner) return;			// Touching self, do nothing
	if (other.solid == SOLID_TRIGGER) return;	// trigger field, do nothing
	if (self.waitmin > time) return;			// bullet touch has been disabled
	entity_remove(self, 1);						// Setup bullet for removal	
	
	//----------------------------------------------------------------------
	// Hit monster/interactive object, impact blood
	//----------------------------------------------------------------------
	if (other.takedamage) {
		// Only dead center tracer and pellets do damage
		if (self.classtype == CT_PROJ_TRACEPART) self.dmg = 0;
		else if (self.classtype == CT_PROJ_TRACE) {
			// No extra trace damage for zombies, it will kill them
			if (other.classgroup == CG_ZOMBIE) self.dmg = 0;
			else self.dmg = DAMAGE_PTSHELL;	
		}
		// Default shell pellet damage
		else self.dmg = DAMAGE_PSHELL;	
		
		// Show bullet resistance as small blood+gunshot+smoke
		if (other.resist_shells > 0) {
			self.dmg = self.dmg*(1-other.resist_shells);
			Resist_Shells(other, self.origin, self.velocity, self.dmg);
		}
		else {
			// Hitting monsters does twice the amount of blood effects
			if (other.flags & FL_MONSTER) spawn_touchblood (self, other, self.dmg*2);
			else spawn_touchblood (self, other, self.dmg);
		}
		
		if (self.dmg > 0) T_Damage (other, self, self.owner, self.dmg, DAMARMOR);
	}
	//----------------------------------------------------------------------
	// Hit world/static object, impact particles
	//----------------------------------------------------------------------
	else {
		// Tracer bullet, dead center and inflight particle emitter
		// Originally did no damage, but changed to buff particle SG
		if (self.classtype == CT_PROJ_TRACE) {
			self.lip = random();
			// NG tink sound or SG ricochet sound (hardcoded client sounds)
			if (self.lip < 0.5) sound(self, CHAN_VOICE, "weapons/tink1.wav", random()*0.5, ATTN_LOW);
			else if (self.lip < 0.7) sound(self, CHAN_VOICE, "weapons/ric2.wav", random()*0.5, ATTN_LOW);
			else sound(self, CHAN_VOICE, "weapons/ric3.wav", random()*0.5, ATTN_LOW);
		}
		else {
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_GUNSHOT);
			WriteCoord (MSG_BROADCAST, self.origin_x);
			WriteCoord (MSG_BROADCAST, self.origin_y);
			WriteCoord (MSG_BROADCAST, self.origin_z);
		}
	}
};

//----------------------------------------------------------------------
void(vector org, vector dir, float proj_type, float proj_speed) Launch_Bullet =
{
	newmis = spawn();
	newmis.owner = self;
	newmis.classname = "proj_bullet";	// obj name, not really used anymore
	newmis.classtype = proj_type;		// Class type number, quick identity
	newmis.classgroup = CG_PROJSHELLS;	// Ammo type
	//----------------------------------------------------------------------
	// Horrible hack! If the player has the TSG or quad, flag it for zombies
	//----------------------------------------------------------------------
	if (self.moditems & IT_UPGRADE_SSG || self.super_damage_finished > 0)
		newmis.weapon = TRUE;
	
	//----------------------------------------------------------------------
	// Switch model collision based on auto aim functionality
	// Monsters always use large collision (otherwise infighting would be less)
	//----------------------------------------------------------------------
	if (self.classtype == CT_PLAYER) {
		if (serverflags & SVR_AUTOAIM) 
			newmis.movetype = MOVETYPE_FLYMISSILE;	// Large collision (aim on)
		else newmis.movetype = MOVETYPE_FLY;		// Small collision
	}
	else newmis.movetype = MOVETYPE_FLYMISSILE;		// Default = large collision
	
	//----------------------------------------------------------------------
	newmis.solid = SOLID_BBOX;
	newmis.touch = Touch_Bullet;					// touch function
	newmis.waitmin = 0;								// Touch function active

	// Particle tracer (true aim, no damage)
	if (proj_type == CT_PROJ_TRACE || proj_type == CT_PROJ_TRACEPART) {
		newmis.delay = time + LIFE_SHELLS;			// Maximum life time
		if (self.weapon & IT_SUPER_SHOTGUN) newmis.count = 1;
		else newmis.count = 1 + rint(random()*2);	// Default particles for SG
		newmis.speed = 0.02;						// Next function interval (very high tick)
		newmis.think = Particle_Bullet;				// Particle trail
		newmis.nextthink = time + newmis.speed;
	}
	// SG/SSG shells (scatter effect)
	else {
		newmis.think = SUB_Remove;
		newmis.nextthink = time + LIFE_SHELLS;	// Stop projectile going forever
	}

	newmis.mdl = MODEL_PROJ_DIAM2;
	setmodel(newmis, newmis.mdl);				// Diamond model
	newmis.frame = random()*15;					// Full range of sizes
	newmis.skin = 16 + random()*7;				// Dark grey colours

	newmis.velocity = dir * proj_speed;			// Constant speed multiplier
	newmis.angles = vectoangles(dir);			// Create direction angle
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);	// Zero size
	setorigin (newmis, org);					// Move to starting position
	newmis.avelocity = vecrand(100,200,FALSE);
	
};

//----------------------------------------------------------------------
void(float bullet_count, vector bullet_spread, float bullet_type) Launch_Shells =
{
	local	vector src_origin, bullet_dir, spread_dir;
	local float bullet_speed, var_speed;
	
	makevectors(self.v_angle);		// Working where cursor is pointing (using self)

	// Is the player firing the shotgun?
	if (self.flags & FL_CLIENT) {
		if (bullet_type == CT_PROJ_SG) bullet_speed = SPEED_PLAYERSG;
		else bullet_speed = SPEED_PLAYERSSG;
		// Either straight line or auto aim assist (builtin function 44)
		if (serverflags & SVR_AUTOAIM) bullet_dir = aim(self, SPEED_PLAYAIM);
		else bullet_dir = normalize(v_forward * bullet_speed);
	}
	else {
		bullet_speed = SPEED_MONSG + (skill*SPEED_MONSGMULT);
		// fire somewhat behind the player, so a dodging player is harder to hit
		bullet_dir = self.enemy.origin - self.enemy.velocity*0.2;
		bullet_dir = normalize (bullet_dir - self.origin);
	}

	// Infront of model and down towards gun
	src_origin = self.origin + (v_forward*10) + '0 0 8';
	
	// Setup particle emitter/tracer shot (true aim)
	Launch_Bullet(src_origin, bullet_dir, CT_PROJ_TRACE, bullet_speed);
	// Reduced the amount of visual noise infront of the player
	// The projectiles below are particle trail emitters only
	//	Launch_Bullet(src_origin+(v_right*(crandom()*10)), bullet_dir, CT_PROJ_TRACEPART, bullet_speed + (crandom()*30) );
	//	Launch_Bullet(src_origin+(v_right*(crandom()*10)), bullet_dir, CT_PROJ_TRACEPART, bullet_speed + (crandom()*30) );

	while (bullet_count > 0) {
		var_speed = crandom()*10 + bullet_speed;		// Slight speed variance
		spread_dir = bullet_dir + (crandom()*bullet_spread_x) * v_right + (crandom()*bullet_spread_y) * v_up;
		Launch_Bullet(src_origin, spread_dir, bullet_type, var_speed);

		bullet_count = bullet_count - 1;
	}
};

/*======================================================================
 PLASMA PROJECTILES 
 * requires special blue/white particle trail
 * Has radius and impact touch damage
 * used by Eliminator (enforcer), Soldier and Minotaur
======================================================================*/
void() Resist_Plasma =
{
	if (other.health > 0 && other.pain_finished < time) {
		other.pain_finished = time + 0.3 + random();
		sound (other, CHAN_VOICE, other.pain_sound, 1, ATTN_NORM);
	}	
	SpawnExplosion(EXPLODE_PUFF,self.origin,"weapons/plasma_hit.wav");
	SpawnProjectileSmoke(self.origin, 200, 200);
	SpawnProjectileSmoke(self.origin, 200, 300);
	SpawnProjectileSmoke(self.origin, 300, 200);
	if (random() < 0.3) SpawnProjectileMeat(self.origin, 200, 200);
	entity_remove(self, 1);
};

//----------------------------------------------------------------------
void() Particle_Plasma =
{
	// projectile has touched something
	if (self.waitmin > time) return;
	
	// Generate sprite particles? DP not active?
	if (random() < 0.5 && !ext_dppart) {
		self.oldorigin = crandom() * '1 1 1';
		self.lip = 40 + rint(random()*8);
		particle (self.origin, self.oldorigin, self.lip, 4 + rint(random()*4));
		self.lip = 198 + rint(random()*4);
		particle (self.origin, self.oldorigin, self.lip, 2 + rint(random()*2));
	}

	// The Player plasma projectile grows over frames
	if (self.owner.classtype == CT_PLAYER) {
		if (self.attack_finished < time) {
			self.frame = self.frame + 1;
			if (self.frame < 6) self.attack_finished = time + 0.1;
			else self.frame = 6;
		}
	}

	self.think = Particle_Plasma;
	self.nextthink = time + self.speed;	
};

//----------------------------------------------------------------------
void() Touch_PlasmaProjectile =
{
	if (check_skycontent(self.origin)) {entity_remove(self, 0.1); return;}
	if (self.touchedvoid) return;				// Marked for removal
	if (other == self.owner) return;			// Touching self, do nothing
	if (other.solid == SOLID_TRIGGER) return;	// trigger field, do nothing
	if (self.waitmin > time) return;			// plasma touch has been disabled
	entity_remove(self, 1);						// Setup plasma for removal	
	
	if (self.owner.classtype == CT_MONMINOTAUR) self.pos1 = DAMAGE_PGMINOTAUR;
	else if (self.owner.classtype == CT_MONGAUNT) self.pos1 = DAMAGE_PGGAUNT;
	else if (self.owner.classtype == CT_PLAYER) self.pos1 = DAMAGE_PGPLAYER;
	else self.pos1 = DAMAGE_PLASMA;
	self.dmg = self.pos1_x + random()*self.pos1_y;

	// Plasma Splashdamage affects everything, check for 0 dmg first
	if (self.pos1_z > 0) T_RadiusDamage (self, self.owner, self.pos1_z, world, DAMAGEALL);

	//----------------------------------------------------------------------
	// Hit monster/interactive object, impact blood
	//----------------------------------------------------------------------
	if (other.takedamage) {
		// Check for plasma/cell resistance
		if (other.resist_cells > 0) {
			self.dmg = self.dmg*(1-other.resist_cells);
			Resist_Plasma();
		}
		else {
			// Hitting monsters does twice the amount of blood effects
			if (other.flags & FL_MONSTER) spawn_touchblood (self, other, self.dmg*2);
			else spawn_touchblood (self, other, self.dmg);

			// Randomly pick between quoth electric and blue explosions
			if (random() < 0.3) SpawnExplosion(EXPLODE_SMALLP, self.origin, SOUND_REXP3);
			else SpawnExplosion(EXPLODE_ELEC, self.origin, "weapons/plasma_hit.wav");
		}
		
		// Plasma hits always kill any zombie (1 hit)
		if (other.classgroup == CG_ZOMBIE) self.dmg = DAMAGE_ZOMBIECLASS;
		T_Damage (other, self, self.owner, self.dmg, DAMARMOR);

	}
	//----------------------------------------------------------------------
	// Hit world/static object, impact particles
	//----------------------------------------------------------------------
	else {
		// New special coloured particle explosion (rogue expansion)
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_EXPLOSION2);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
		WriteByte (MSG_BROADCAST, 35);
		WriteByte (MSG_BROADCAST, 8);

		// Classic quoth electric impact explosion
		SpawnExplosion(EXPLODE_ELEC, self.origin, "weapons/plasma_hit.wav");
	}
};

//----------------------------------------------------------------------
void(vector org, vector dir, float proj_type, float proj_speed) launch_plasma =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.classname = "proj_plasma";	// obj name, not really used anymore
	newmis.classtype = proj_type;		// Class type number, quick identity
	newmis.classgroup = CG_PROJCELLS;	// Ammo type

	// Switch model collision based on auto aim functionality
	// Monsters always use large collision (otherwise infighting would be less)
	//----------------------------------------------------------------------
	if (self.classtype == CT_PLAYER) {
		// Autoaim = large collision, off = small collision
		if (serverflags & SVR_AUTOAIM) newmis.movetype = MOVETYPE_FLYMISSILE;
		else newmis.movetype = MOVETYPE_FLY;
	}
	// Default = small collision
	else {
		newmis.movetype = MOVETYPE_FLY;
		// Minotaur, Gaunt is rapid fire, don't need glow effect (slow down)
		if (self.classtype != CT_MONGAUNT && self.classtype != CT_MONMINOTAUR) 
			newmis.effects = EF_DIMLIGHT;
	}

	//----------------------------------------------------------------------
	newmis.solid = SOLID_BBOX;
	newmis.touch = Touch_PlasmaProjectile;
	newmis.nextthink = time + LIFE_PROJECTILE;
	newmis.think = SUB_Remove;
	
	// Setup model and special parameters (zombie, boss)
	//----------------------------------------------------------------------
	if (self.classtype == CT_MONARMYPLASMA) setmodel (newmis, MODEL_PROJ_PLASMA);
	else if (self.classtype == CT_MONELIMATOR) setmodel (newmis, MODEL_PROJ_PLASMA);
	else if (self.classtype == CT_MONCENTURION) setmodel (newmis, MODEL_PROJ_PLASMA);
	else if (self.classtype == CT_MONGAUNT) setmodel (newmis, MODEL_PROJ_GAPLASMA);
	else if (self.classtype == CT_MONMINOTAUR) setmodel (newmis, MODEL_PROJ_MPLASMA);
	else if (self.classtype == CT_PLAYER) {
		setmodel (newmis, MODEL_PROJ_PGPLASMA);
		newmis.attack_finished = time + 0.1;	// Update model frame every 0.1s
		newmis.avelocity = vecrand(0,300,TRUE);	// randomize avel
		newmis.angles_y = rint(random()*360);	// Random angle
		newmis.frame = 0;						// Start really small
	}
		
	//----------------------------------------------------------------------
	// Is DP engine active for new particle trail?
	if (ext_dppart) {
		newmis.traileffectnum = particleeffectnum(DPP_TRPLASMA);
		newmis.effects = 0;
		// Extra glow and light colour (DP mostly)
		//newmis.effects = EF_BLUE;
		//newmis.glow_color = 246;	// Blue/gold	
	}

	// Manually generate blue/white particle trail
	newmis.count = 1 + rint(random()*2);	// Default particles
	newmis.speed = 0.02;					// Next function interval (very high tick)
	newmis.think = Particle_Plasma;			// Particle trail
	newmis.nextthink = time + newmis.speed;

	// Standard projectile setup (origin, size and velocity)
	//----------------------------------------------------------------------
	newmis.velocity = dir * proj_speed;
	if (self.classtype != CT_PLAYER) newmis.angles = vectoangles(dir);
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);
};

/*======================================================================
 SMALL PROJECTILES - used all over the place ...
 
 * player (nailgun, super nailgun)
 * Wizards (double spit)
 * Hell Knights (magic spray)
 * spike shooters (regular, super, laser)
 * Enforcers (laser)
 * Crossbow Knights (bolts)
 * Zombies (flesh)
======================================================================*/
void() Resist_Nails =
{
	if (other.health > 0 && other.pain_finished < time) {
		other.pain_finished = time + 0.3 + random();
		sound (other, CHAN_VOICE, other.pain_sound, 1, ATTN_NORM);
	}	
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	if (random() < 0.5) WriteByte (MSG_BROADCAST, TE_SPIKE);
	else WriteByte (MSG_BROADCAST, TE_GUNSHOT);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	if (random() < 0.5) SpawnProjectileSmoke(self.origin, 200, 200);
};

//----------------------------------------------------------------------
// Forward compiler reference because of peircing nails function
void(vector org, vector dir, float proj_type, float proj_speed) launch_projectile;

//----------------------------------------------------------------------
void() Touch_Projectile =
{
	local vector org, dir;
	local float proj_type, proj_speed;
	local entity tself;
	
	if (check_skycontent(self.origin)) {entity_remove(self, 0.1); return;}
	if (self.touchedvoid) return;				// Marked for removal
	if (other == self.owner) return;			// no touching self
	if (other.solid == SOLID_TRIGGER) return;	// trigger field, do nothing

	// No more touch/world interaction
	self.touch = SUB_Null;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	
	//----------------------------------------------------------------------
	//	Laser impact/stop sound (precached by owner)
	if (self.classtype == CT_PROJ_LASER)
		sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	// Golem rock impact sound (precached by owner)
	else if (self.classtype == CT_PROJ_GROCK) {
		self.lip = random();
		self.volume = 0.5 + random()*0.5;
		if (self.lip < 0.25) sound (self, CHAN_WEAPON, SOUND_IMP_ROCK1, self.volume, ATTN_BREAK);
		else if (self.lip < 0.5) sound (self, CHAN_WEAPON, SOUND_IMP_ROCK2, self.volume, ATTN_BREAK);
		else if (self.lip < 0.75) sound (self, CHAN_WEAPON, SOUND_IMP_ROCK3, self.volume, ATTN_BREAK);
		else sound (self, CHAN_WEAPON, SOUND_IMP_ROCK4, self.volume, ATTN_BREAK);
	}

	//----------------------------------------------------------------------
	// hit something that bleeds
	if (other.takedamage) {
		// SNG spikes are essentially double damage (cheap way of 2 x nails)
		if (self.classtype == CT_PROJ_SNG) self.dmg = DAMAGE_SNGSPIKE;
		// Bob and enforcer lasers are different
		else if (self.owner.classtype == CT_MONJIM) 
				self.dmg = DAMAGE_BOBLASER + (random() * DAMAGE_BOBLASER);
		else if (self.classtype == CT_PROJ_LASER) self.dmg = DAMAGE_LASER;
		// Special damage and sound effects for crossbow knights
		else if (self.classtype == CT_PROJ_BOLT1) {
			// hit4 = flesh wound, hit1 = ting sound
			if (random() < 0.3) sound (self, CHAN_WEAPON, "weapons/bolt_hit1.wav", 1, ATTN_NORM);
			else sound (self, CHAN_WEAPON, "weapons/bolt_hit4.wav", 1, ATTN_NORM);
			// Reduce the damage if the bolt has hit another dcrossbow knight
			if (other.classtype == self.owner.classtype) self.dmg = DAMAGE_BOLT0;
			else self.dmg = DAMAGE_BOLT1;
		}
		// Zombies have special impact sound
		else if (self.classtype == CT_PROJ_FLESH || self.classtype == CT_PROJ_FLESHP) {
			sound (self, CHAN_WEAPON, "zombie/z_hit.wav", 1, ATTN_NORM);
			self.dmg = DAMAGE_FLESH;
		}
		// Scorpion spikes cannot hurt other spider types
		// This is to prevent the minion scorpion killing other minions
		else if (self.classtype == CT_PROJ_SCORP) {
			if (other.classgroup == self.owner.classgroup) self.dmg = 0;
			else self.dmg = DAMAGE_NGSPIKE;
		}
		// Rock projectiles cannot hurt stone monsters!
		else if (self.classtype == CT_PROJ_GROCK) {
			if (other.classgroup == self.owner.classgroup) self.dmg = 0;
			else self.dmg = DAMAGE_NGSPIKE;
		}
		// Default spike damage (nails)
		else self.dmg = DAMAGE_NGSPIKE;
		

		//----------------------------------------------------------------------
		// Check for poison debuff (currently mummy and green spiders)
		if (self.owner.classtype == CT_MONMUMMY || self.owner.classtype == CT_MONSPIDER
			|| self.owner.classtype == CT_MONMINOTAUR || self.owner.classtype == CT_MONWRAITH) {
				if (self.owner.poisonous > 0) PoisonDeBuff(other);
		}

		//----------------------------------------------------------------------
		// Check for NG/SNG nail resistance
		if (self.classgroup == CG_PROJNAILS && other.resist_nails > 0) {
			self.dmg = self.dmg*other.resist_nails;
			Resist_Nails();
		}
		//----------------------------------------------------------------------
		// Produce blood particles at impact and apply damage to target
		spawn_touchblood (self, other, self.dmg);
		if (self.dmg > 0) T_Damage (other, self, self.owner, self.dmg, DAMARMOR);

		//----------------------------------------------------------------------
		// Nail Piercing affect, move nail through monster
		if (self.projeffect & IT_ARTPIERCE) {
			// a small pile of gibs!
			if (random() < 0.2) SpawnMeatSpray (self, other, crandom() * 100);
			// Setup projectile ready for monster tests
			self.movetype = MOVETYPE_FLY;
			self.solid = SOLID_BBOX;
			self.oldorigin = self.origin;
			self.count = 0;

			// Loop forward 8 times to find space on the other side
			while (self.count < 8) {
				// Trace forward from current position
				self.finaldest = self.oldorigin + self.finalangle*512;
				traceline(self.oldorigin, self.finaldest,FALSE,self);
				// Still inside bleeding object?
				if (trace_ent == other)
					self.oldorigin = self.oldorigin + self.finalangle*16;
				// On the other side!
				else self.count = 8;
				self.count = self.count + 1;
			}
			// Is the other side free space to spawn?
			if (pointcontents(self.oldorigin) == CONTENT_EMPTY) {
				tself = self;
				org = self.oldorigin;
				dir = self.finalangle;
				proj_type = self.classtype;
				proj_speed = self.speed;
				self = self.owner;
				// Once a projectile hits an object it is impossible
				// to reset its velocity/angles and carry on
				// It is easier to create a new projectile and delete
				// the currently damaged one instead!
				launch_projectile(org, dir, proj_type, proj_speed);
				self = tself;
			}
		}
	}
	//----------------------------------------------------------------------
	else {
		// Some projectiles need to be left lying around for a while
		if (self.bodyfadeaway) {
			if (self.classtype == CT_PROJ_FLESH || self.classtype == CT_PROJ_FLESHP) 
				sound (self, CHAN_WEAPON, "zombie/z_miss.wav", 1, ATTN_NORM);
			else if (self.classtype == CT_PROJ_SPID)
				sound (self, CHAN_WEAPON, "spider/miss.wav", 1, ATTN_NORM);
			else if (self.classtype == CT_PROJ_BOLT1) {
				if (random() < 0.5) sound (self, CHAN_WEAPON, "weapons/bolt_hit2.wav", 1, ATTN_NORM);
				else sound (self, CHAN_WEAPON, "weapons/bolt_hit3.wav", 1, ATTN_NORM);
			}
				
			self.velocity = self.avelocity = '0 0 0';
			self.nextthink = time + 2 + random();
			self.ltime = self.nextthink;
			self.think = model_fade;	
			return;
		}
		
		//----------------------------------------------------------------------
		// Standard engine impact particles and sounds
		else {
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			
			if (self.classtype == CT_PROJ_SNG) WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
			else if (self.classtype == CT_PROJ_LASER) WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
			else if (self.classtype == CT_PROJ_GROCK) WriteByte (MSG_BROADCAST, TE_GUNSHOT);
			else if (self.classtype == CT_PROJ_WIZ) WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
			else if (self.classtype == CT_PROJ_SPID) WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
			else if (self.classtype == CT_PROJ_FURY2) WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
			else if (self.classtype == CT_PROJ_HKN) WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
			else WriteByte (MSG_BROADCAST, TE_SPIKE);
			
			WriteCoord (MSG_BROADCAST, self.origin_x);
			WriteCoord (MSG_BROADCAST, self.origin_y);
			WriteCoord (MSG_BROADCAST, self.origin_z);
		}
	}
	
	// Hide projectile and wait for any sounds to finish playing
	entity_remove(self,2);
};

//----------------------------------------------------------------------
void(vector org, vector dir, float proj_type, float proj_speed) launch_projectile =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.classname = "proj_nail";		// obj name, not really used anymore
	newmis.classtype = proj_type;		// Class type number, quick identity

	if (newmis.classtype == CT_PROJ_NG || newmis.classtype == CT_PROJ_SNG) 
		newmis.classgroup = CG_PROJNAILS;	// Ammo type
	else newmis.classgroup = CG_PROJALL;	// Ammo type (default)

	// Switch model collision based on auto aim functionality
	// Monsters always use large collision (otherwise infighting would be less)
	//----------------------------------------------------------------------
	if (self.classtype == CT_PLAYER) {
		// Autoaim = large collision, off = small collision
		if (serverflags & SVR_AUTOAIM) newmis.movetype = MOVETYPE_FLYMISSILE;
		else newmis.movetype = MOVETYPE_FLY;
		// Check if the player has the nail piercer effect active
		if (self.moditems & IT_ARTPIERCE && newmis.classgroup == CG_PROJNAILS) {
			newmis.projeffect = IT_ARTPIERCE;
		}
	}
	// lasers/plasma are small and glowing
	else if (proj_type == CT_PROJ_LASER) {			
		newmis.movetype = MOVETYPE_FLY;
		newmis.effects = EF_DIMLIGHT;
	}
	// Crossbow bolts are small and stick around
	else if (proj_type == CT_PROJ_BOLT1) {
		newmis.movetype = MOVETYPE_FLY;
		newmis.bodyfadeaway = TRUE;
	}
	// Default = large collision
	else newmis.movetype = MOVETYPE_FLYMISSILE;

	//----------------------------------------------------------------------
	newmis.solid = SOLID_BBOX;
	newmis.touch = Touch_Projectile;
	newmis.nextthink = time + LIFE_PROJECTILE;
	newmis.think = SUB_Remove;
	
	// Setup model
	//----------------------------------------------------------------------
	if (proj_type == CT_PROJ_NG) setmodel (newmis, MODEL_PROJ_NG);
	else if (proj_type == CT_PROJ_SNG) setmodel (newmis, MODEL_PROJ_SNG);
	else if (proj_type == CT_PROJ_BOLT1) setmodel (newmis, MODEL_PROJ_BOLT1);
	else if (proj_type == CT_PROJ_HKN) setmodel (newmis, MODEL_PROJ_HKN);
	else if (proj_type == CT_PROJ_WIZ) setmodel (newmis, MODEL_PROJ_WIZ);
	else if (proj_type == CT_PROJ_MPOISON) setmodel (newmis, MODEL_PROJ_MPOISON);
	else if (proj_type == CT_PROJ_WBONE) setmodel (newmis, MODEL_PROJ_WBONE);
	else if (proj_type == CT_PROJ_WPOISON) setmodel (newmis, MODEL_PROJ_WPOISON);
	else if (proj_type == CT_PROJ_SCORP) setmodel (newmis, MODEL_PROJ_SCORP);
	else if (proj_type == CT_PROJ_FURY2) setmodel (newmis, MODEL_PROJ_FURY2);
	else if (proj_type == CT_PROJ_LASER) {
		setmodel (newmis, MODEL_PROJ_LASER);
		// Is DP engine active for new particle trail?
		if (ext_dppart) {
			newmis.traileffectnum = particleeffectnum(DPP_TRLASER);
			newmis.effects = 0;
		}
	}
	else if (proj_type == CT_PROJ_GROCK) {
		if (random() < 0.5) setmodel (newmis, MODEL_PROJ_GROCK1);
		else setmodel (newmis, MODEL_PROJ_GROCK2);
		newmis.frame = rint(random()*9);
		newmis.avelocity = vecrand(0,200,TRUE);
	}

	// Standard projectile setup (origin, size and velocity)
	//----------------------------------------------------------------------
	newmis.speed = proj_speed;
	newmis.finalangle = dir;
	newmis.velocity = newmis.finalangle * newmis.speed;
	newmis.angles = vectoangles(newmis.finalangle);
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);
};

/*======================================================================
 This missile touch function is designed for monsters NOT players
 * No DIRECT damage, just radius and a lot lower (40 vs 110)
 * Half damage to shamblers (inside T_RadiusDamage)
 * Will work with homing or direct missile attacks
 * checks for breakables that can be destroyed with explosives
 * uses default explosion function 
======================================================================*/
void() Touch_HomingMissile =
{
	if (check_skycontent(self.origin)) {entity_remove(self, 0.1); return;}
	if (self.touchedvoid) return;				// Marked for removal
	if (other == self.owner) return;			// Touching self, do nothing
	if (other.solid == SOLID_TRIGGER) return;	// trigger field, do nothing
	if (ai_foundbreakable(self.owner, other, TRUE) && other.brktrigmissile != 0) {
		// Found a breakable which is prone to explosive damage
		trigger_ent(other, self.owner);
	}
	else {
		// Homing Missiles always kill any zombie class
		if (other.classgroup == CG_ZOMBIE) 
			T_Damage (other, self, self, DAMAGE_ZOMBIECLASS, NOARMOR);	
		T_RadiusDamage (self, self.owner, DAMAGE_MONROCKET, world, DAMAGEALL);
	}

	// DP has special effect for voreball explosions
	if (ext_dppart) pointparticles(particleeffectnum(DPP_SHALEXPLOSION), self.origin, '0 0 0', 1);
	else {
		// Standard voreball explosion
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_EXPLOSION);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}
	
	// Play original explosion sound
	sound(self, CHAN_WEAPON, SOUND_REXP3, 1, ATTN_NORM);
	// Sprite explosion or nothing for DP
	BecomeExplosion();
};

//----------------------------------------------------------------------
// Re-direct any map hacks to the new function replacement
void() ShalMissileTouch = { Touch_HomingMissile(); };

//----------------------------------------------------------------------
void() Steer_HomingMissile =
{
	local vector	dir, vtemp;
	
	// If tracking enemies dies or end level? remove homing missiles
	if (self.enemy.health < 1) { remove(self); return; }
	if (intermission_running > 1) { remove(self); return; }

	vtemp = self.enemy.origin + self.v_angle;
	dir = normalize(vtemp - self.origin);
	self.velocity = dir * self.attack_speed;

	// Slow speed update that the missile can steer around corners
	// sloppy slow updates allows for a better game experience		
	self.nextthink = time + 0.2;
	self.think = Steer_HomingMissile;	
};

//----------------------------------------------------------------------
void(vector orgofs, vector targofs, float proj_type, float proj_speed) Launch_HomingMissile =
{
	local	vector	org, dir;
	local	float	dist, flytime;

	// Check if there is space to spawn entity
	makevectors(self.angles);
	org = self.origin + v_forward*orgofs_x + v_right*orgofs_y + v_up*orgofs_z;
	if (entity_pcontent(org)) return;
	
	newmis = spawn ();
	newmis.owner = self;
	newmis.classname = "proj_rocket";		// obj name, not really used anymore
	newmis.classtype = proj_type;			// Class type number, quick identity
	newmis.classgroup = CG_PROJROCKETS;		// Ammo type

	newmis.movetype = MOVETYPE_FLYMISSILE;	// Default = large collision
	newmis.enemy = self.enemy;				// Used for homing target
	newmis.v_angle = targofs;				// Store for later

	//----------------------------------------------------------------------
	// Aim the missile slightly above enemy
	dir = normalize((self.enemy.origin + newmis.v_angle) - org);
	dist = vlen (self.enemy.origin - org);
	flytime = dist * 0.002;
	if (flytime < 0.1) flytime = 0.1;

	//----------------------------------------------------------------------
	newmis.solid = SOLID_BBOX;
	newmis.touch = Touch_HomingMissile;
	newmis.nextthink = flytime + time;
	newmis.think = Steer_HomingMissile;
	newmis.attack_speed = proj_speed;

	// Setup model for each missile type
	//----------------------------------------------------------------------
	if (proj_type == CT_PROJ_SHAL) setmodel(newmis, MODEL_PROJ_SHAL);
	else if (proj_type == CT_PROJ_SERG) setmodel(newmis, MODEL_PROJ_SERG);

	// Standard projectile setup (origin, size and velocity)
	//----------------------------------------------------------------------
	newmis.velocity = dir * newmis.attack_speed;
	newmis.avelocity = vecrand(100,200,FALSE);
	newmis.angles = vectoangles(dir);
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);
};

/*======================================================================
 ROCKETS
 * Half damage to shamblers (T_MissileTouch and T_RadiusDamage)
 * checks for breakables that can be destroyed with explosives
 * All rockets have direct & radius damage (based on projectile type)
======================================================================*/
void() Resist_Missile =
{
	if (other.health > 0 && other.pain_finished < time) {
		other.pain_finished = time + 0.3 + random();
		sound (other, CHAN_VOICE, other.pain_sound, 1, ATTN_NORM);
	}
	SpawnExplosion(EXPLODE_PUFF,self.origin,SOUND_RESIST_ROCKET);
	SpawnProjectileSmoke(self.origin, 200, 200);
	SpawnProjectileSmoke(self.origin, 200, 300);
	SpawnProjectileSmoke(self.origin, 300, 200);
	SpawnProjectileMeat(self.origin, 200, 200);
	SpawnProjectileMeat(self.origin, 300, 200);
	entity_remove(self, 1);
};

//----------------------------------------------------------------------
void() Touch_Missile =
{
	if (check_skycontent(self.origin)) {entity_remove(self, 0.1); return;}
	if (self.touchedvoid) return;				// Marked for removal
	if (other == self.owner) return;			// Touching self, do nothing
	if (other.solid == SOLID_TRIGGER) return;	// trigger field, do nothing
	if (self.oldenemy) {		// stop packs of owners killing each other
		if (other.classtype == self.oldenemy.classtype) return;	}
	// Guardian skull wizards have special poison explosion
	if (self.classtype == CT_PROJ_SKULLWP) {self.owner.th_updmissile(); return;}
	if (ai_foundbreakable(self.owner, other, TRUE) && other.brktrigmissile != 0) {
		// Found a breakable which is prone to explosive damage
		trigger_ent(other, self.owner);
	}
	else {
		// Stop any updates to the missile velocity
		self.nextthink = time + 1;
		self.think = SUB_Null;
	
		// Setup rocket damage (vector = base + random and splash)
		if (self.classtype == CT_PROJ_ROCKET) self.pos1 = DAMAGE_RLPLAYER;
		else if (self.classtype == CT_PROJ_FURY1) self.pos1 = DAMAGE_RLFURY;
		else if (self.classtype == CT_PROJ_LAVA) self.pos1 = DAMAGE_RLPLAYER;
		else if (self.classtype == CT_PROJ_FIRETOP) self.pos1 = DAMAGE_RLFIRETOP;
		else if (self.classtype == CT_PROJ_SKULLW) self.pos1 = DAMAGE_RLSKULLW;
		else if (self.classtype == CT_PROJ_GARG) self.pos1 = DAMAGE_RLGARG;
		else if (self.classtype == CT_PROJ_ARMY) self.pos1 = DAMAGE_RLARMY;
		else if (self.classtype == CT_PROJ_JIM2) self.pos1 = DAMAGE_RLJIM2;
		else if (self.classtype == CT_PROJ_DROLE) self.pos1 = DAMAGE_RLDROLE;

		// pre-calculate rocket damage
		self.dmg = self.pos1_x + (random() * self.pos1_y);
		// Check for any rocket ammo resistance
		if (other.resist_rockets > 0) 
			self.dmg = self.dmg * (1-other.resist_rockets);

		// Only call T_ functions if there is damage to do!
		if (self.dmg > 0 && other.health > 0) 
			T_Damage (other, self, self.owner, self.dmg, DAMARMOR);
		if (self.pos1_z > 0) 
			T_RadiusDamage (self, self.owner, self.pos1_z, other, DAMAGEALL);
	}
	
	// Rocket resistance is shown with puffs of smoke
	if (other.resist_rockets > 0) Resist_Missile();
	else {
		// Move the explosion effect higher up from point of contact
		self.origin = self.origin - 8*normalize(self.velocity);

		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_EXPLOSION);	// Hard coded explosion sound
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);

		// Play original explosion sound or replacement
		if (self.noise == "") sound(self, CHAN_WEAPON, SOUND_REXP3, 1, ATTN_NORM);
		else sound (self, CHAN_WEAPON, self.noise, 1, ATTN_NORM);

		BecomeExplosion ();
	}	
};

//----------------------------------------------------------------------
// Re-direct any map hacks to the new function replacement
void() T_MissileTouch = { Touch_Missile(); };

//----------------------------------------------------------------------
void(vector org, vector dir, vector avel, float proj_type, float proj_speed) Launch_Missile =
{
	// Check if there is space to spawn entity
	if (entity_pcontent(org)) return;
	
	newmis = spawn ();
	newmis.owner = self;
	newmis.classname = "proj_rocket";	// obj name, not really used anymore
	newmis.classtype = proj_type;		// Class type number, quick identity
	newmis.classgroup = CG_PROJROCKETS;	// Ammo type

	// Player rockets need to take into account autoaim
	if (self.classtype == CT_PLAYER) {
		// Autoaim = Fat collision, off = small collision
		if (serverflags & SVR_AUTOAIM) newmis.movetype = MOVETYPE_FLYMISSILE;
		else newmis.movetype = MOVETYPE_FLY;
	}
	else {
		// default monster missile width is thin!
		newmis.movetype = MOVETYPE_FLY;
		// Horrible exception for the missile touch function
		// Gargoyle rockets need to pass through other gargoyles
		// otherwise a pack of them would kill each other!
		if (self.classtype == CT_MONGARGOYLE) newmis.oldenemy = self;
	}

	//----------------------------------------------------------------------
	newmis.solid = SOLID_BBOX;
	newmis.touch = Touch_Missile;
	newmis.nextthink = time + LIFE_ROCKET;
	newmis.think = SUB_Remove;

	// Setup model for each missile type
	//----------------------------------------------------------------------
	if (proj_type == CT_PROJ_ROCKET) setmodel(newmis, MODEL_PROJ_ROCKET);
	else if (proj_type == CT_PROJ_GARG) setmodel(newmis, MODEL_PROJ_GARGOYLE);
	else if (proj_type == CT_PROJ_SKULLW) setmodel(newmis, MODEL_PROJ_SWSKULL);
	else if (proj_type == CT_PROJ_SKULLWP) setmodel(newmis, MODEL_PROJ_SWSKULLP);
	else if (proj_type == CT_PROJ_FURY1) setmodel(newmis, MODEL_PROJ_FURY1);
	else if (proj_type == CT_PROJ_LAVA) setmodel (newmis, MODEL_PROJ_LAVA);
	else if (proj_type == CT_PROJ_FIRETOP) setmodel (newmis, MODEL_PROJ_LAVA);
	else if (proj_type == CT_PROJ_JIM2) {
		setmodel(newmis, MODEL_PROJ_ROCKET);
		newmis.noise = "jim/rocket_hit.wav";
	}
	else if (proj_type == CT_PROJ_ARMY) {
		setmodel(newmis, MODEL_PROJ_ROCKET);
		newmis.noise = "soldier/rocket_hit.wav";
		newmis.nextthink = time + 0.1;
		newmis.think = self.th_updmissile;
		// If can see enemy, steer the rocket towards them
		if (visible(self.enemy)) newmis.enemy = self.enemy;
	}
	else if (proj_type == CT_PROJ_DROLE) {
		setmodel (newmis, MODEL_PROJ_DROLE);
		newmis.noise = "drole/r_explode.wav";
		newmis.nextthink = time + 0.025;
		newmis.think = self.th_updmissile;
	}

	// Standard projectile setup (origin, size and velocity)
	//----------------------------------------------------------------------
	newmis.velocity = dir * proj_speed;
	newmis.avelocity = avel;
	newmis.angles = vectoangles(newmis.velocity);
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, org);
};

/*======================================================================
 GRENADES
 * Half damage to shamblers (T_MissileTouch and T_RadiusDamage)
 * checks for breakables that can be destroyed with explosives
 * Grenade damage is based on dmg key (default = player)
======================================================================*/
void() Explode_Grenade =
{
	// Block touch functions
	if (self.state == STATE_DISABLED) return;
	self.touch = SUB_Null;
	self.state = STATE_DISABLED;
	
	// Customize damage based on projectile type
	if (self.classtype == CT_PROJ_GLMON) self.dmg = DAMAGE_MONGRENADE;
	else if (self.classtype == CT_PROJ_MEGG) self.dmg = 0;
	else if (!self.dmg) self.dmg = DAMAGE_PLAYGRENADE; 
	// Rocket resistance is checked in RadiusDamage
	T_RadiusDamage (self, self.owner, self.dmg, world, DAMAGEALL);

	// Rocket resistance is shown with puffs of smoke
	if (other.resist_rockets > 0) Resist_Missile();
	else {
		// Sprite/Particle based explosion
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_EXPLOSION);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);

		// Play original explosion sound
		sound(self, CHAN_WEAPON, SOUND_REXP3, 1, ATTN_NORM);
		BecomeExplosion ();
	}
};

//----------------------------------------------------------------------
void() Touch_Grenade =
{
	if (entity_pcontent(self.origin)) {remove(self); return;}
	if (self.touchedvoid) return;				// Marked for removal
	if (other == self.owner) return;			// Touching self, do nothing
	if (other.solid == SOLID_TRIGGER) return;	// trigger field, do nothing
	
	// Let minion eggs re-bounce in opposite direction
	// Don't want them to explode like grenades
	if (self.classtype == CT_PROJ_MEGG && other.takedamage == DAMAGE_AIM) {
		if (self.velocity != '0 0 0') {
			self.angles = vectoangles(self.mangle);
			self.angles_y = anglemod(self.angles_y + 180);
			self.velocity = -self.mangle;	// Reverse direction
			self.mangle = self.velocity;	// Update new direction
			sound (self, CHAN_WEAPON, self.noise, 1, ATTN_NORM);
			// Reset egg timer if still bouncing a lot
			if ( vlen(self.velocity) > 100 ) self.nextthink = time + LIFE_EGG;
		}
	}
	else {
		// Hit something that bleeds?
		if (other.takedamage == DAMAGE_AIM) {Explode_Grenade(); return;}
		// Any monster firing a grenade at a breakable will explode without bounce
		if (ai_foundbreakable(self.owner, other, TRUE) && (self.owner.flags & FL_MONSTER)) {
			// Found a breakable which is prone to explosive damage
			trigger_ent(other, self.owner);
			Explode_Grenade();
			return;
		}
		
		// bounce sound and stop spinning
		sound (self, CHAN_WEAPON, self.noise, 1, ATTN_NORM);
		if (self.velocity == '0 0 0') self.avelocity = '0 0 0';
	}
};

//----------------------------------------------------------------------
// Re-direct any map hacks to the new function replacement
void() OgreGrenadeExplode = { self.classtype = CT_PROJ_GLMON; Explode_Grenade(); };
void() GrenadeExplode = { self.classtype = CT_PROJ_GLMON; Explode_Grenade(); };
void() GrenadeTouch = { self.classtype = CT_PROJ_GLMON; Touch_Grenade(); };

// Compile forward functions for Launch_Grenade
void() Touch_ShellCasing;

//----------------------------------------------------------------------
void(vector org, vector dir, vector avel, float proj_type) Launch_Grenade =
{
	// Check if there is space to spawn entity
	if (entity_pcontent(org)) return;
	
	newmis = spawn ();
	newmis.owner = self;
	newmis.classname = "proj_grenade";	// obj name, not really used anymore
	newmis.classtype = proj_type;		// Class type number, quick identity
	newmis.classgroup = CG_PROJROCKETS;	// Ammo type
	newmis.movetype = MOVETYPE_BOUNCE;

	//----------------------------------------------------------------------
	newmis.solid = SOLID_BBOX;
	newmis.touch = Touch_Grenade;
	newmis.nextthink = time + LIFE_GRENADE;
	newmis.think = Explode_Grenade;
	newmis.noise = "weapons/bounce.wav";
	newmis.bbmins = newmis.bbmaxs = VEC_ORIGIN;

	// Setup model for each missile type
	//----------------------------------------------------------------------
	if (proj_type == CT_PROJ_GL) setmodel(newmis, MODEL_PROJ_GRENADE);
	else if (proj_type == CT_PROJ_GLMON) setmodel(newmis, MODEL_PROJ_GRENADE);
	else if (proj_type == CT_PROJ_FLESH) setmodel (newmis, MODEL_PROJ_FLESH);
	else if (proj_type == CT_PROJ_FLESHP) setmodel (newmis, MODEL_PROJ_FLESHP);
	else if (proj_type == CT_PROJ_MEGG) {
		if (self.classtype == CT_MONWRAITH) {
			setmodel( newmis, MODEL_PROJ_WEGG);
			newmis.noise = "wraith/bounce.wav";
		}
		else if (self.classtype == CT_MONSHAL) {
			setmodel( newmis, MODEL_PROJ_SEGG);
			newmis.noise = "shalrath/bounce.wav";
		}
		newmis.classgroup = CG_MINIONEGG;		// Proper group type
		newmis.enemy = SUB_entEnemyTarget();	// Make sure got right enemy
		newmis.bbmins = VEC_HULLE_MIN;			// Small egg size
		newmis.bbmaxs = VEC_HULLE_MAX;
		newmis.frame = self.attachment.frame;	// Current ball size (frame)
		newmis.think = Hatch_Egg;				// Eventually hatch
		newmis.nextthink = time + LIFE_EGG;		// Short timer
	}
	else if (proj_type == CT_PROJ_SPID) {
		setmodel (newmis, MODEL_PROJ_SPID);
		newmis.frame = rint((random() * 9));
	}
	else if (proj_type == CT_PROJ_SHELLC) {
		setmodel(newmis, MODEL_PROJ_SHELLC);
		newmis.touch = Touch_ShellCasing;
		newmis.think = model_fade;
		newmis.nextthink = time + random() + LIFE_SHELLS;
		newmis.ltime = newmis.nextthink;
	}
	
	// These projectile fly like grenades but are really spikes!
	//----------------------------------------------------------------------
	if (proj_type == CT_PROJ_SPID || proj_type == CT_PROJ_FLESH 
		|| proj_type == CT_PROJ_FLESHP) {
		newmis.touch = Touch_Projectile;
		newmis.nextthink = time + LIFE_PROJECTILE;
		newmis.think = SUB_Remove;
		newmis.bodyfadeaway = TRUE;
	}
	
	// Standard projectile setup (origin, size and velocity)
	//----------------------------------------------------------------------
	newmis.mangle = dir;	// Save for later
	newmis.velocity = newmis.mangle;
	newmis.avelocity = avel;
	newmis.angles = vectoangles(newmis.velocity);
	setsize (newmis, newmis.bbmins, newmis.bbmaxs);
	setorigin (newmis, org);
};

//======================================================================
// Generic functions for firing grenades from monsters
// MonsterGrenadeSound = play generic load grenade sound
// MonsterGrenadeSpeed = return generic attack speed
// MonsterFireGrenade = fire grenade at enemy origin
//
//----------------------------------------------------------------------
void() MonsterGrenadeSound =
{ sound (self, CHAN_WEAPON, "weapons/gl_loadshort.wav", 0.1+random()*0.5, ATTN_LOW); };
float() MonsterGrenadeSpeed =
{ return SPEED_MONGRENADE + (skill * SPEED_MONGLSKILL); };

//----------------------------------------------------------------------
void(vector grenade_org, vector grenade_enemyorg) MonsterFireGrenade =
{
	local vector ang, dir, avel;
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	// Is Z aware disabled?
	if ( query_configflag(SVR_ZAWARE) || self.no_zaware ) {
		makevectors (self.angles);
		dir = normalize(grenade_enemyorg - grenade_org);
		// Default grenade speed (player = 600)
		dir = dir * SPEED_PLAYGRENADE;
		dir_z = ELEV_ZAXIS;
	}
	else {
		// Z Aware tracking is ENABLED (AI track player much better)
		// One final angle adjustment (based on actual projectile origin)
		self.attack_speed = MonsterGrenadeSpeed();
		self.attack_elev = SUB_Elevation(self.attack_elev, grenade_org, grenade_enemyorg, self.attack_speed);
		ang = vectoangles(grenade_enemyorg - grenade_org);
		ang_x = -self.attack_elev;
		makevectors (ang);
 		dir = v_forward * self.attack_speed;
	}

	avel = vecrand(100,200,FALSE);
	Launch_Grenade(grenade_org, dir, avel, CT_PROJ_GLMON);
};

/*======================================================================
 Ejecting Shell Casing for SG/SSG/Upgrade
======================================================================*/
void() Touch_ShellCasing =
{
	if (check_skycontent(self.origin)) {entity_remove(self, 0.1); return;}
	if (self.touchedvoid) return;				// Marked for removal
	if (other == self.owner) return;			// Touching self, do nothing
	if (other.solid == SOLID_TRIGGER) return;	// trigger field, do nothing

	self.touch = SUB_Null;
	if (random() < 0.5)  
		sound(self, CHAN_VOICE, "weapons/shellc.wav", random()*0.25, ATTN_LOW);		
};

//----------------------------------------------------------------------
void(float shell_qty) Launch_ShellCasing =
{
	local vector org, dir, avel;
	
	if ( self.health < 1 ) return;

	if (self.flags & FL_CLIENT) makevectors (self.v_angle);
	else makevectors (self.angles);
	org = self.origin + v_up*10;
	
	while (shell_qty > 0) {
		dir = -v_right*75 + v_forward*(random()*50) + v_up*(100 + random()*100);
		avel = vecrand(0,300,TRUE);
		Launch_Grenade(org, dir, avel, CT_PROJ_SHELLC);
		shell_qty = shell_qty - 1;
	}
};
