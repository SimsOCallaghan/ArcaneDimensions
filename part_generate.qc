/*======================================================================
 Generate PARTICLES

 PRIMARY SPRITE/MODE PARTICLE EMITTER FUNCTION
 - Designed for Fitz type engines (retro pixel goodness)

 DPP particle functions
 - float(string effectname) particleeffectnum
 - -void(entity ent, float effectnum, vector start, vector end) trailparticles
 - -void(float effectnum, vector org, vector vel, float howmany) pointparticles
 
======================================================================*/
float() emit_checksource =
{
	// killtarget can easily destroy connections between entities
	// Some particle emitter types rely on the source entity connection
	// Quake maintains all entities in one list with a number as reference
	// If an entity is deleted the entity number can be given to any new
	// entity spawned. This is not a reference to the original entity but
	// it is just a location in a list. 
	// To get around this problem any entity that spawns a particle
	// emitter will generate an unique number which the emitter will
	// keep track of and compare to make sure the connection is valid.
	//
	// If the connection is broken, destroy particle emitter
	if (self.entno_unique != self.pemit_source.entno_unique)
		self.part_style = PARTICLE_STYLE_EMPTY;
		
	if (self.part_style == PARTICLE_STYLE_EMPTY) self.state = STATE_OFF;
	// Exception - respawning particle are never blocked!
	else if (self.part_style != PARTICLE_STYLE_RESPAWN) {
		// Has the particle emitter SOURCE been switched off?
		if (self.pemit_source.estate & ESTATE_BLOCK) self.state = STATE_OFF;
	}
	
	// Final check to see if emitter is active or not?
	if (self.state == STATE_OFF) { self.estate = ESTATE_OFF; return TRUE; }
	else return FALSE;
};

//----------------------------------------------------------------------
void() emitdpp_default = {
	
	// Check source entity and style type are valid
	if (emit_checksource()) return;

	if (self.pemit_target) {
		self.dpp_vel = vectoangles(self.pemit_target.origin - self.pemit_source.origin);
		self.dpp_vel_z = 0;
		makevectors (self.dpp_vel);
		self.dpp_vel = normalize(v_forward);
	}

	// Generate particles (DP Engine)
	// DP particles are designed to go at origin, not origin+offset
	pointparticles(particleeffectnum(self.dpp_name), self.pemit_source.origin, self.pemit_source.dpp_vel, 1);
	self.think = emitdpp_default;
	self.nextthink = time + self.dpp_wait + (random() * self.dpp_rnd);
};

//----------------------------------------------------------------------
// Custom setup for Floor Circle particle emitter
//----------------------------------------------------------------------
void() emitdpp_fcircle =
{
	local float loop_cnt;
	local vector circle_vec, circle_org;
	
	// Check source entity and style type are valid
	if (emit_checksource()) return;

	loop_cnt = 4;
	while(loop_cnt > 0) {
		loop_cnt = loop_cnt - 1;
	
		circle_vec = '0 0 0';
		circle_vec_y = circle_vec_y + rint(random()*360);
		makevectors(circle_vec);
		circle_org = self.pemit_source.origin + v_forward * self.part_vol_x;
	
		// Generate particles (DP Engine) around circumference
		pointparticles(particleeffectnum(self.dpp_name), circle_org, self.dpp_vel, 1);
	}

	// Draw bright pulse ring texture over the floor pattern
	pointparticles(particleeffectnum(DPP_FCIRCLE_RING), self.pemit_source.origin, '0 0 0', 1);
	
	self.think = emitdpp_fcircle;
	self.nextthink = time + self.dpp_wait + (random() * self.dpp_rnd);
};

//----------------------------------------------------------------------
void(entity gibent) DPP_blood_trail =
{
	if (random() < 0.2) gibent.traileffectnum = particleeffectnum(DPP_ITSBLOOD);
	else gibent.traileffectnum = particleeffectnum(DPP_TRBLOOD);
};

//----------------------------------------------------------------------
void() emit_particle =
{
	local float randno;
	local vector angle_vec;

	// Check source entity and style type are valid
	if (emit_checksource()) return;

	// Setup next particle (loop)
	self.think = emit_particle;

	// make sure player distance check is available
	if (!self.enemy) self.enemy = find(world, classname, "player");
	if ( !(self.enemy.flags & FL_CLIENT) ) {
		self.nextthink = time + 0.1;
		return;
	}

	// Is the particle emitter close to the player?
	if (range_distance(self.enemy, TRUE) < self.wakeup_dist) {		
		
		// Normal think timer, player within range
		self.nextthink = time + self.spawn_base + (random()*self.spawn_rand);

		// Is there anymore particles left to spawn? 
		if (self.pemit_tcount < self.part_limit) {
			part = fetch_particle();
			// Only preceed if a particle has been returned
			if (part.classtype == CT_PARTICLE) {
				part.owner = self;
				self.pemit_tcount = self.pemit_tcount + 1;
				part.movetype = self.part_movetype;		// 6=Gravity, 8=Noclip, 10=Bounce
				
				// Select particle type
				randno = random();

				//----------------------------------------------------------------------
				// Setup SPRITE particle (string and frame no)
				//----------------------------------------------------------------------
				if (randno < 0.3) setmodel(part, self.spr_name1);
				else if (randno < 0.6) setmodel(part, self.spr_name2);
				else setmodel(part, self.spr_name3);

				//----------------------------------------------------------------------
				// Sprite Frame style (1=LIGHT, 2=DARK, 3=ALL)
				//----------------------------------------------------------------------
				if (self.spr_frame == 1) part.frame = rint(random()*1.4);
				else if (self.spr_frame == 2) part.frame = rint(random()*2);
				else part.frame = rint(random()*3.4);

				// Zero size and world interaction			
				setsize (part, VEC_ORIGIN, VEC_ORIGIN);

				//----------------------------------------------------------------------
				// STARTING POINT (Particle origin - uses MANGLE key)
				//
				// 0 = Randomly picked from a volume (X/Y/Z) - DEFAULT
				// 1 = Circular motion (radius/segment controlled)
				// 2 = Randomly pick a point on the circle circumference
				// 3 = Spiral in/out from circle circumference
				// 5 = Explosion from central point
				//----------------------------------------------------------------------
				// Circular motion around emitter (self)
				if (self.part_veltype == PARTICLE_ORIGIN_CIRCLE) {
					angle_vec = '0 0 0';
					angle_vec_y = angle_vec_y + self.circular_angle;
					makevectors(angle_vec);
					part.origin = self.origin + v_forward * self.part_vol_x;
					setorigin (part, part.origin + self.part_ofs);
					self.circular_angle = anglemod(self.circular_angle + self.part_vol_y);
				}
				// Random circumference point around emitter (self)
				else if (self.part_veltype == PARTICLE_ORIGIN_RANDCIRCLE) {
					angle_vec = '0 0 0';
					angle_vec_y = angle_vec_y + rint(random()*360);
					makevectors(angle_vec);
					part.origin = self.origin + v_forward * self.part_vol_x;
					setorigin (part, part.origin + self.part_ofs);
				}
				// Spiral in/out around circumference point (self)
				else if (self.part_veltype == PARTICLE_ORIGIN_SPIRAL) {
					angle_vec = '0 0 0';
					angle_vec_y = angle_vec_y + self.circular_angle;
					makevectors(angle_vec);
					if (self.lefty == 0) self.lefty = 1;
					self.part_vol_z = self.part_vol_z + self.lefty;
					if (self.part_vol_z == 0) self.lefty = 1; 
					if (self.part_vol_z == self.part_vol_x) self.lefty = -1;
					part.origin = self.origin + v_forward * self.part_vol_z;
					setorigin (part, part.origin + self.part_ofs);
					self.circular_angle = anglemod(self.circular_angle + self.part_vol_y);
				}
				// Explosion from central point (self)
				else if (self.part_veltype == PARTICLE_ORIGIN_CENTER) {
					// Always calculate from the center of original object
					part.origin = self.pemit_source.origin + self.part_ofs;
					setorigin (part, part.origin);
				}
				// Random volume point around particle (part)
				else {
					// Check if owner is a Bmodel? (different origin location)
					if (self.pemit_source.bsporigin) {
						part.pos1 = self.pemit_source.origin + bmodel_origin(self.owner);
						part.origin = part.pos1;
					}
					else part.origin = self.pemit_source.origin + self.part_ofs;

					part.origin_x = part.origin_x + ( (random()*(self.part_vol_x*2)) - self.part_vol_x);
					part.origin_y = part.origin_y + ( (random()*(self.part_vol_y*2)) - self.part_vol_y);
					part.origin_z = part.origin_z + ( (random()*(self.part_vol_z*2)) - self.part_vol_z);
					setorigin (part, part.origin);
				}

				//----------------------------------------------------------------------
				// VELOCITY (Particle speed/direction - uses ANGLES key)
				//
				// Initially setup linear velocity
				// if PART_VELRAND defined create extra wobble/randomness
				// if oldenemy (noise4) specified go towards specific target entity
				//----------------------------------------------------------------------
				if (self.pemit_target) {
					// Check if finish target is a Bmodel? (different origin location)
					if (self.pemit_target.bsporigin) {
						part.pos2 = self.pemit_target.origin + bmodel_origin(self.pemit_target);
						angle_vec = part.pos2 - part.origin;
					}
					else
						angle_vec = self.pemit_target.origin - part.origin;		// Target -> Self

					angle_vec = normalize(angle_vec);									// vector unit scale
					part.velocity = angle_vec * ( (random()*self.part_vel_x) + self.part_vel_x);

					// Add extra wobble if part_velrand defined
					if (self.part_velrand_x > 0 || self.part_velrand_y > 0 || self.part_velrand_z > 0) {
						part.velocity_x = part.velocity_x + (random()*(self.part_velrand_x*2)) - self.part_velrand_x;
						part.velocity_y = part.velocity_y + (random()*(self.part_velrand_y*2)) - self.part_velrand_y;
						part.velocity_z = part.velocity_z + (random()*(self.part_velrand_z*2)) - self.part_velrand_z;
					}
				}
				// Explosion from central point (self)
				else if (self.part_veltype == PARTICLE_ORIGIN_CENTER) {
					// Setup BASE + CRANDOM (+/-) velocity
					part.velocity = '0 0 0';
					part.velocity_x = self.part_vel_x - (random()*(self.part_vel_x*2));
					part.velocity_y = self.part_vel_y - (random()*(self.part_vel_y*2));
					part.velocity_z = self.part_vel_z - (random()*(self.part_vel_z*2));
					part.velocity = part.velocity + self.part_velbase;
				}
				else {					
					// Setup BASE + RANDOM (+) velocity
					part.velocity = '0 0 0';
					part.velocity_x = random(self.part_vel_x) + self.part_vel_x;
					part.velocity_y = random(self.part_vel_y) + self.part_vel_y;
					part.velocity_z = random(self.part_vel_z) + self.part_vel_z;
					part.velocity = part.velocity + self.part_velbase;
		
					// Add extra wobble if part_velrand defined
					if (self.part_velrand_x > 0 || self.part_velrand_y > 0 || self.part_velrand_z > 0) {
						part.velocity_x = part.velocity_x + (random()*(self.part_velrand_x*2)) - self.part_velrand_x;
						part.velocity_y = part.velocity_y + (random()*(self.part_velrand_y*2)) - self.part_velrand_y;
						part.velocity_z = part.velocity_z + (random()*(self.part_velrand_z*2)) - self.part_velrand_z;
					}
				}				
				//----------------------------------------------------------------------
				// ROTATION (Y axis only - uses PART_VELROT key)
				// Random Y axis rotation
				//----------------------------------------------------------------------
				if (self.part_velrot) {
					part.angles = self.enemy.angles;		// Rotate the same way first
					part.avelocity = '0 0 0';
					part.avelocity_y = self.part_velrot + (random()*self.part_velrot);
				}

				// Setup time of death!
				part.nextthink = time + random() + self.part_life;
				part.think = finish_particle;
			}
			
		}
	}
	else {
		// If no player within range of the emitter, slower think timer
		self.nextthink = time + self.wakeup_timer + (random()*self.spawn_rand);
	}
};

//----------------------------------------------------------------------
// Pick a particle sprite based on type
//----------------------------------------------------------------------
void(entity part_ent, float part_style) particle_style =
{
	local float ring_rand;
	
	ring_rand = random();
	if (ring_rand < 0.4) {
		if (part_style & PARTICLE_BURST_YELLOW) setmodel (part_ent, PART_DOTSML_GOLD);
		else if (part_style & PARTICLE_BURST_GREEN) setmodel (part_ent, PART_DOTSML_LGREEN);
		else if (part_style & PARTICLE_BURST_RED) setmodel (part_ent, PART_DOTSML_GREY);
		else if (part_style & PARTICLE_BURST_BLUE) setmodel (part_ent, PART_DOTSML_BLUE);
		else if (part_style & PARTICLE_BURST_PURPLE) setmodel (part_ent, PART_DOTSML_PURP);
		else if (part_style & PARTICLE_BURST_FIRE) setmodel (part_ent, PART_TORCH1);
		else setmodel (part_ent, PART_DOTSML_WHITE);
	}
	else if (ring_rand < 0.8) {
		//----------------------------------------------------------------------
		if (part_style & PARTICLE_BURST_YELLOW) setmodel (part_ent, PART_DOTSML_YELLOW);
		else if (part_style & PARTICLE_BURST_GREEN) setmodel (part_ent, PART_DOTSML_GREEN);
		else if (part_style & PARTICLE_BURST_RED) setmodel (part_ent, PART_DOTSML_RED);
		else if (part_style & PARTICLE_BURST_BLUE) setmodel (part_ent, PART_DOTSML_GREY);
		else if (part_style & PARTICLE_BURST_PURPLE) setmodel (part_ent, PART_DOTSML_GREY);
		else if (part_style & PARTICLE_BURST_FIRE) setmodel (part_ent, PART_DOTSML_GOLD);
		else setmodel (part_ent, PART_DOTSML_GREY);
	}
	else {
		//----------------------------------------------------------------------
		if (part_style & PARTICLE_BURST_YELLOW) setmodel (part_ent, PART_DOTMED_YELLOW);
		else if (part_style & PARTICLE_BURST_GREEN) setmodel (part_ent, PART_DOTMED_GREEN);
		else if (part_style & PARTICLE_BURST_RED) setmodel (part_ent, PART_DOTMED_RED);
		else if (part_style & PARTICLE_BURST_BLUE) setmodel (part_ent, PART_DOTMED_BLUE);
		else if (part_style & PARTICLE_BURST_PURPLE) setmodel (part_ent, PART_DOTMED_PURP);
		else if (part_style & PARTICLE_BURST_FIRE) setmodel (part_ent, PART_DOTMED_GREY);
		else setmodel (part_ent, PART_DOTMED_GREY);
	}
	// Random frame (sprite)
	part.frame = rint(random()*3);
};

//----------------------------------------------------------------------
// Particle ring explosion (used for respawn function)
// ring_org		: center of particle ring
// ring_dir		: direction for particles to move
// ring_rdir	: random wobble for particle direction
// ring_rad		: starting point offset (grow/shrink ring size)
// ring_qty		: circle division (how many points around circumference)
// ring_time	: lifespan of particle (time + random()*time)
// ring_style	: particle ring colour (1=yellow, 2=green, 3=red, 4=white)
//----------------------------------------------------------------------
void(vector ring_org, vector ring_dir, vector ring_rdir, float ring_rad, float ring_qty, float ring_time, float ring_style) particle_ring = 
{
	local vector circle_vec, circle_org;
	local float ring_loop, ring_angle;
	local string dpp_string;

	// Have particles been enabled via serverflags?
	if (query_configflag(SVR_PARTICLES) != SVR_PARTICLES) return;

	// Setup DP particle style based on supplied style
	if (ext_dppart) {
		if (ring_style & PARTICLE_BURST_YELLOW) dpp_string = DPP_RINGPARTY;
		else if (ring_style & PARTICLE_BURST_GREEN) dpp_string = DPP_RINGPARTG;
		else if (ring_style & PARTICLE_BURST_RED) dpp_string = DPP_RINGPARTR;
		else if (ring_style & PARTICLE_BURST_BLUE) dpp_string = DPP_RINGPARTB;
		else if (ring_style & PARTICLE_BURST_PURPLE) dpp_string = DPP_RINGPARTP;
		else dpp_string = DPP_RINGPARTW;
	}
	else {
		// Are there any free particles?
		// Check for maximim amount of particles available
		if ( (part_total+ring_qty) >= part_max - 1) return;
	}

	ring_loop = 0;
	ring_angle = 360 / ring_qty;
	while (ring_loop < ring_qty) {
		// Is the DP particle system active?
		if (ext_dppart) {
			// Work out point on circle circumference using
			// the v_forward vector with incremental angles	
			circle_vec = '0 0 0';
			circle_vec_y = circle_vec_y + (ring_angle * ring_loop);
			makevectors(circle_vec);
			circle_org = ring_org + (v_forward * ring_rad);

			// Generate particles (DP Engine)
			pointparticles(particleeffectnum(dpp_string), circle_org, '0 0 0', 1);
		}
		else {
			part = fetch_particle();
			// Only preceed if a particle has been returned
			if (part.classtype == CT_PARTICLE) {
				part.owner = self;
				part.movetype = MOVETYPE_NOCLIP;
				
				// Setup correct particle type (sprite/model) based on ring colour
				particle_style(part, ring_style);
		
				// Work out point on circle circumference using
				// the v_forward vector with incremental angles	
				circle_vec = '0 0 0';
				circle_vec_y = circle_vec_y + (ring_angle * ring_loop);
				makevectors(circle_vec);
				part.origin = ring_org + (v_forward * ring_rad);
				setorigin (part, part.origin);
				// Zero size and world interaction			
				setsize (part, VEC_ORIGIN, VEC_ORIGIN);
				
				// Setup particle velocity with random element
				part.velocity_x = ring_dir_x + ( (random()*(ring_rdir_x*2)) - ring_rdir_x);
				part.velocity_y = ring_dir_y + ( (random()*(ring_rdir_y*2)) - ring_rdir_y);
				part.velocity_z = ring_dir_z + (random()*ring_rdir_z);
		
				// Setup time of death!
				part.nextthink = time + (random()*ring_time) + ring_time;
				part.think = finish_particle;
			}
		}
		// Keep on loopin!
		ring_loop = ring_loop + 1;
	}
};

//----------------------------------------------------------------------
void(entity part_ent, vector part_org, float expl_style) explosion_style =
{
	local vector org_volume, expl_vel;
	
	// Ogre hammer is a flat floor explosion with particles bouncing
	if (expl_style & PARTICLE_BURST_SHOCKWAVE) {
		org_volume = '0 0 0';
		org_volume_x = crandom()*16;
		org_volume_y = crandom()*16;
		part_ent.origin = part_org + org_volume;
		setorigin (part_ent, part_ent.origin);

		// Random chance of dead particles that are
		// stationary on the ground
		if (random() < 0.3) {
			part_ent.velocity = '0 0 0';
			if (random() < 0.5) setmodel (part_ent, PART_DOTSML_GREY);
			else setmodel (part_ent, PART_DOTMED_GREY);
			part_ent.frame = rint(random()*3);
		}
		else {
			// Particles that explode up and out
			expl_vel_x = crandom() * 75;
			expl_vel_y = crandom() * 75;
			expl_vel_z = 150 + random() * 150;
			part_ent.velocity = expl_vel;
			part_ent.avelocity = vecrand(100,200,FALSE);
			part_ent.movetype = MOVETYPE_TOSS;
			part_ent.gravity = 0.75;
			part_ent.flags = 0;
		}
	}
	// Skull wizard teleporting = particle burst upwards
	else if (expl_style & PARTICLE_BURST_SKULLUP) {
		part_ent.origin_x = part_org_x + crandom()*8;
		part_ent.origin_y = part_org_y + crandom()*8;
		// If skull wizard dead, spawn particles from robes on floor
		// Otherwise the particles are being used for a teleport
		if (self.health < 0) part_ent.origin_z = part_org_z - MON_VIEWOFS;
		else part_ent.origin_z = part_org_z - crandom()*MON_VIEWOFS;
		setorigin (part_ent, part_ent.origin);
		part_ent.velocity_x = crandom()*8;
		part_ent.velocity_y = crandom()*8;
		part_ent.velocity_z = random()*25;
		part_ent.avelocity = vecrand(100,200,FALSE);
		part_ent.movetype = MOVETYPE_FLY;
		part_ent.flags = 0;
	}
	// Lost souls fire particles upwards
	else if (expl_style & PARTICLE_BURST_LOSTUP) {
		part_ent.origin_x = part_org_x + crandom()*4;
		part_ent.origin_y = part_org_y + crandom()*4;
		part_ent.origin_z = part_org_z;
		setorigin (part_ent, part_ent.origin);
		part_ent.velocity_x = crandom()*4;
		part_ent.velocity_y = crandom()*4;
		part_ent.velocity_z = random()*10;
		part_ent.avelocity = vecrand(100,200,FALSE);
		part_ent.movetype = MOVETYPE_FLY;
		part_ent.flags = 0;
	}
	// Minotaur finished plasma attack
	else if (expl_style & PARTICLE_BURST_MINOTAUR) {
		part_ent.origin_x = part_org_x + crandom()*8;
		part_ent.origin_y = part_org_y + crandom()*8;
		part_ent.origin_z = part_org_z - crandom()*MON_VIEWOFS;
		setorigin (part_ent, part_ent.origin);
		part_ent.velocity_x = crandom()*8;
		part_ent.velocity_y = crandom()*8;
		part_ent.velocity_z = random()*35;
		part_ent.avelocity = vecrand(100,200,FALSE);
		part_ent.movetype = MOVETYPE_FLY;
		part_ent.flags = 0;
	}
	// Generic particle burst drifting upward
	else if (expl_style & PARTICLE_BURST_UPWARD) {
		part_ent.origin_x = part_org_x + crandom()*24;
		part_ent.origin_y = part_org_y + crandom()*24;
		part_ent.origin_z = part_org_z + random()*64;
		setorigin (part_ent, part_ent.origin);
		part_ent.velocity_x = crandom()*16;
		part_ent.velocity_y = crandom()*16;
		part_ent.velocity_z = 8+random()*16;
		part_ent.movetype = MOVETYPE_FLY;
		part_ent.flags = 0;
	}
	else {
		// default = explode outwards in all directions
		part_ent.origin = part_org;
		setorigin (part_ent, part_ent.origin);
		part_ent.velocity = vecrand(0,16,TRUE);
		part_ent.avelocity = vecrand(100,200,FALSE);
		part_ent.movetype = MOVETYPE_FLY;
		part_ent.flags = 0;
	}
};	

/*======================================================================
 Particle explosion
 
 e_org		: center of particle explosion
 e_qty		: quantity of particle burst
 e_time		: lifespan of particle (time + random()*time)
 p_style	: sprite style (check function particle_style above)
 e_style	: explosion style (pre-defined in part_manage.qc)
======================================================================*/
void(vector e_org, float e_qty, float e_time, float p_style, float e_style) particle_explode = 
{
	local float e_loop;
	local vector dp_vec;
	local string dpp_string;

	// Have particles been enabled via serverflags?
	if (query_configflag(SVR_PARTICLES) != SVR_PARTICLES) return;

	if (ext_dppart) {
		// DP hammer impact, 1=regular 2=shockwave
		if (e_style & PARTICLE_BURST_SHOCKWAVE) {
			if (e_style & 1) pointparticles(particleeffectnum(DPP_BURSTSHOCKWAVE1), e_org, '0 0 0', 1);
			else pointparticles(particleeffectnum(DPP_BURSTSHOCKWAVE1), e_org, '0 0 0', 1);
		}
		else {
			// Setup DP particle style based on supplied style
			if (e_style & PARTICLE_BURST_YELLOW) dpp_string = DPP_BURSTPARTY;
			else if (e_style & PARTICLE_BURST_GREEN) dpp_string = DPP_BURSTPARTG;
			else if (e_style & PARTICLE_BURST_RED) dpp_string = DPP_BURSTPARTR;
			else if (e_style & PARTICLE_BURST_BLUE) dpp_string = DPP_BURSTPARTB;
			else if (e_style & PARTICLE_BURST_PURPLE) dpp_string = DPP_BURSTPARTP;
			else dpp_string = DPP_BURSTPARTW;
			pointparticles(particleeffectnum(dpp_string), e_org, '0 0 0', e_qty);
		}
	}
	else {
		// Are there any free particles?
		// Check for maximim amount of particles available
		if ( (part_total+e_qty) >= part_max - 1) return;
		e_loop = 0;
		while (e_loop < e_qty) {
			e_loop = e_loop + 1;	// Keep on loopin!
			part = fetch_particle();
			// Only preceed if a particle has been returned
			if (part.classtype == CT_PARTICLE) {
				part.owner = self;
				particle_style(part, p_style);
				explosion_style(part, e_org, e_style);
				// Zero size and world interaction			
				setsize (part, VEC_ORIGIN, VEC_ORIGIN);
				part.nextthink = ((time + (random() * e_time)) + e_time);
				part.think = finish_particle;
			}
		}
	}
};

//----------------------------------------------------------------------
// Slowly rising cloud of particle dots
//----------------------------------------------------------------------
void(vector debuff_center, float debuff_qty, float debuff_style) particle_debuff =
{
	local float debuff_loop, debuff_volsize, debuff_time;
	local vector debuff_org, debuff_vol;
	local string dpp_string;

	// Have particles been enabled via serverflags?
	if (query_configflag(SVR_PARTICLES) != SVR_PARTICLES) return;

	// Setup DP particle style based on supplied style
	if (ext_dppart) {
		if (debuff_style & PARTICLE_BURST_YELLOW) dpp_string = DPP_RINGPARTY;
		else if (debuff_style & PARTICLE_BURST_GREEN) dpp_string = DPP_RINGPARTG;
		else if (debuff_style & PARTICLE_BURST_RED) dpp_string = DPP_RINGPARTR;
		else if (debuff_style & PARTICLE_BURST_BLUE) dpp_string = DPP_RINGPARTB;
		else if (debuff_style & PARTICLE_BURST_PURPLE) dpp_string = DPP_RINGPARTP;
		else dpp_string = DPP_RINGPARTW;
	}
	else {
		// Are there any free particles?
		// Check for maximim amount of particles available
		if ( (part_total+debuff_qty) >= part_max - 1) return;
	}

	debuff_loop = 0;
	debuff_time = 2;
	debuff_volsize = 16;
	
	while (debuff_loop < debuff_qty) {
		debuff_vol = vecrand(0,debuff_volsize,TRUE);
		debuff_org = debuff_center + debuff_vol;

		// Is the DP particle system active?
		if (ext_dppart)
			pointparticles(particleeffectnum(dpp_string), debuff_org, '0 0 0', 1);
		else {
			part = fetch_particle();
			// Only preceed if a particle has been returned
			if (part.classtype == CT_PARTICLE) {
				part.owner = self;
				part.movetype = MOVETYPE_NOCLIP;
				
				// Setup correct particle type (sprite/model) based on ring colour
				particle_style(part, debuff_style);
				setorigin (part, debuff_org);
				// Zero size and world interaction			
				setsize (part, VEC_ORIGIN, VEC_ORIGIN);

				// Setup particle velocity with random element
				part.velocity = vecrand(0,2,TRUE);
				part.velocity_z = 8 + random()*24;
		
				// Setup time of death!
				part.nextthink = time + (random()*debuff_time) + debuff_time;
				part.think = finish_particle;
			}
		}
		// Keep on loopin!
		debuff_loop = debuff_loop + 1;
	}
};

//----------------------------------------------------------------------
// Falling particle dust/dots
//----------------------------------------------------------------------
void(vector dust_center, float dust_qty, float dust_style) particle_dust =
{
	local float dust_loop, dust_volsize, dust_time;
	local vector dust_org, dust_vol;
	local string dpp_string;

	// Have particles been enabled via serverflags?
	if (query_configflag(SVR_PARTICLES) != SVR_PARTICLES) return;

	// Setup DP particle style based on supplied style
	if (ext_dppart) {
		if (dust_style & PARTICLE_BURST_YELLOW) dpp_string = DPP_RINGPARTY;
		else if (dust_style & PARTICLE_BURST_GREEN) dpp_string = DPP_RINGPARTG;
		else if (dust_style & PARTICLE_BURST_RED) dpp_string = DPP_RINGPARTR;
		else if (dust_style & PARTICLE_BURST_BLUE) dpp_string = DPP_RINGPARTB;
		else if (dust_style & PARTICLE_BURST_PURPLE) dpp_string = DPP_RINGPARTP;
		else dpp_string = DPP_RINGPARTW;
	}
	else {
		// Are there any free particles?
		// Check for maximim amount of particles available
		if ( (part_total+dust_qty) >= part_max - 1) return;
	}

	dust_loop = 0;
	dust_time = 1;
	dust_volsize = 16;
	
	while (dust_loop < dust_qty) {
		dust_vol = vecrand(0,dust_volsize,TRUE);
		dust_org = dust_center + dust_vol;

		// Is the DP particle system active?
		if (ext_dppart)
			pointparticles(particleeffectnum(dpp_string), dust_org, '0 0 0', 1);
		else {
			part = fetch_particle();
			// Only preceed if a particle has been returned
			if (part.classtype == CT_PARTICLE) {
				part.owner = self;
				part.movetype = MOVETYPE_NOCLIP;
				part.solid = SOLID_NOT;
				
				// Setup correct particle type (sprite/model) based on ring colour
				particle_style(part, dust_style);
				setorigin (part, dust_org);
				// Zero size and world interaction			
				setsize (part, VEC_ORIGIN, VEC_ORIGIN);

				// Setup particle velocity with random element
				part.velocity = vecrand(0,35,TRUE);
				part.velocity_z = -100 - random()*100;
				part.avelocity = '300 300 300';
		
				// Setup time of death!
				part.nextthink = time + (random()*dust_time) + dust_time;
				part.think = finish_particle;
			}
		}
		// Keep on loopin!
		dust_loop = dust_loop + 1;
	}
};
