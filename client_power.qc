/*======================================================================
	CheckPowerups
	- Check for turning off powerups
======================================================================*/
void() ClientPowerups =
{
	if (intermission_running > 0) return;
	if (self.health < 1) return;

	//----------------------------------------------------------------------
	// Invisibility (Gold Ring)
	// - Flash screen 3s before running out
	//----------------------------------------------------------------------
	if (self.invisible_finished > 0) {
		// sound and screen flash when items starts to run out
		if (self.invisible_sound < time) {
			sound (self, CHAN_AUTO, SOUND_ARTINV3, 0.5, ATTN_IDLE);
			self.invisible_sound = time + ((random() * 3) + 1);
		}

		if (self.invisible_finished < time + 3) {
			if (self.invisible_time == 1) {
				sprint (self, "Ring of Shadows magic is fading\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, SOUND_ARTINV2, 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}
			
			if (self.invisible_time < time) {
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		// just stopped, don't use eyes
		if (self.invisible_finished < time) {	
			self.modelindex = modelindex_player;
			self.items = self.items - (self.items & IT_INVISIBILITY);
			self.invisible_finished = 0;
			self.invisible_time = 0;
			self.frame = 0;
		}
		else {
			// keep using the eyes
			self.modelindex = modelindex_eyes;
			self.frame = 0;
		}
	}

	//----------------------------------------------------------------------
	// Env Suit	
	// - Flash screen 3s before running out
	// - Give player 12s of air after suit finishes
	//----------------------------------------------------------------------
	if (self.radsuit_finished > 0) {
		self.air_finished = time + 12;		// don't drown

	// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3) {
			if (self.rad_time == 1) {
				sprint (self, "Air supply in Biosuit expiring\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, SOUND_ARTSUIT2, 1, ATTN_NORM);
				self.rad_time = time + 1;
			}
			if (self.rad_time < time) {
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		if (self.radsuit_finished < time) {	// just stopped
			self.items = self.items - (self.items & IT_SUIT);
			self.radsuit_finished = 0;
			self.rad_time = 0;
		}
	}
	
	//----------------------------------------------------------------------
	// Invincibility (Pentagram)
	// - Flash screen 3s before running out
	//----------------------------------------------------------------------
	if (self.invincible_finished > 0) {
	// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + 3) {
			if (self.invincible_time == 1) {
				sprint (self, "Protection is almost burned out\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, SOUND_ARTPENT2, 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}
			if (self.invincible_time < time) {
				self.invincible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}	
		if (self.invincible_finished < time) {	// just stopped
			self.items = self.items - (self.items & IT_INVULNERABILITY);
			self.invincible_finished = 0;
			self.invincible_time = 0;
		}
	}

	//----------------------------------------------------------------------
	// Super Damage (Quad)
	// - Flash screen 3s before running out
	//----------------------------------------------------------------------
	if (self.super_damage_finished > 0) {
		// sound and screen flash when items starts to run out
		if (self.super_damage_finished < time + 3) {
			if (self.super_time == 1) {
				sprint (self, "Quad Damage is wearing off\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, SOUND_ARTQUAD2, 1, ATTN_NORM);
				self.super_time = time + 1;
			}	  
			if (self.super_time < time) {
				self.super_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		if (self.super_damage_finished < time) {	// just stopped
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
	}	

	//----------------------------------------------------------------------
	// SharpShooter
	// - Flash screen 3s before running out
	//----------------------------------------------------------------------
	if (self.sharpshoot_finished > 0) {
	// sound and screen flash when items starts to run out
		if (self.sharpshoot_finished < time + 3) {
			if (self.sharpshoot_time == 1) {
				sprint (self, "Sharpshooter has almost gone\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, SOUND_ARTSHARP2, 1, ATTN_NORM);
				self.sharpshoot_time = time + 1;
			}
			if (self.sharpshoot_time < time) {
				self.sharpshoot_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}	
		if (self.sharpshoot_finished < time) {	// just stopped
			self.moditems = self.moditems - (self.moditems & IT_ARTSHARP);
			self.sharpshoot_finished = 0;
			self.sharpshoot_time = 0;
		}
	}

	//----------------------------------------------------------------------
	// Nail Piercer
	// - Flash screen 3s before running out
	//----------------------------------------------------------------------
	if (self.nailpiercer_finished > 0) {
		// sound and screen flash when items starts to run out
		if (self.nailpiercer_finished < time + 3) {
			if (self.nailpiercer_time == 1) {
				sprint (self, "Nail Piercer is wearing off\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, SOUND_ARTNAILP2, 1, ATTN_NORM);
				self.nailpiercer_time = time + 1;
			}	  
			if (self.nailpiercer_time < time) {
				self.nailpiercer_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		if (self.nailpiercer_finished < time) {	// just stopped
			self.moditems = self.moditems - (self.moditems & IT_ARTPIERCE);
			self.nailpiercer_finished = 0;
			self.nailpiercer_time = 0;
		}
	}	

	//------------------------------------------------------------------
	// Only remove the quad effect (status bar update)
	// if all extra mod artifacts have expired as well
	//------------------------------------------------------------------
	if (self.super_damage_finished == 0 && self.sharpshoot_finished == 0 
		&& self.nailpiercer_finished == 0)
		self.items = self.items - (self.items & IT_QUAD);

	//------------------------------------------------------------------
	// This check for setting the client effect needs to be separate 
	// because its setup by several different artifacts!
	//------------------------------------------------------------------
	if (self.super_damage_finished > 0 || self.invincible_finished > 0 ||
		self.sharpshoot_finished > 0 || self.nailpiercer_finished > 0) {
		self.effects = self.effects | EF_DIMLIGHT;
	}
	else self.effects = self.effects - (self.effects & EF_DIMLIGHT);
};

