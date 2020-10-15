/*======================================================================
	CheckPowerups
	- Check for turning off powerups
======================================================================*/
float PWR_FADING = 3;

//----------------------------------------------------------------------
void(entity targ, float powtimer) ResetPowerInvRing =
{
	if (powtimer == 0) {
		targ.items = targ.items - (targ.items & IT_INVISIBILITY);
		targ.invisible_finished = targ.invisible_time = 0;
		// Reset player model
		targ.modelindex = modelindex_player;
		targ.frame = 0;
	}
	else if (targ.items & IT_INVISIBILITY) {
		// Stop powerup constantly being reset once below timer
		if (targ.invisible_finished > (time + powtimer) ) {
			targ.invisible_finished = time + powtimer;
			// Enable fading message
			targ.invisible_time = 1;
		}
	}
};

//----------------------------------------------------------------------
void(entity targ, float powtimer) ResetPowerPent =
{
	if (powtimer == 0) {
		targ.items = targ.items - (targ.items & IT_INVULNERABILITY);
		targ.invincible_finished = targ.invincible_time = 0;
	}
	else if (targ.items & IT_INVULNERABILITY) {
		// Stop powerup constantly being reset once below timer
		if (targ.invincible_finished > (time + powtimer) ) {
			targ.invincible_finished = time + powtimer;
			// Enable fading message
			targ.invincible_time = 1;
		}
	}
};

//----------------------------------------------------------------------
void(entity targ, float powtimer) ResetPowerEnvSuit =
{
	if (powtimer == 0) {
		targ.items = targ.items - (targ.items & IT_SUIT);
		targ.radsuit_finished = targ.rad_time = 0;
	}
	else if (targ.items & IT_SUIT) {
		// Stop powerup constantly being reset once below timer
		if (targ.radsuit_finished > (time + powtimer) ) {
			targ.radsuit_finished = time + powtimer;
			// Enable fading message
			targ.rad_time = 1;
		}
	}
};

//----------------------------------------------------------------------
void(entity targ, float powtimer) ResetPowerQuad =
{
	if (powtimer == 0) {
		targ.super_damage_finished = targ.super_time = 0;
	}
	else if (targ.items & IT_QUAD) {
		// Stop powerup constantly being reset once below timer
		if (targ.super_damage_finished > (time + powtimer) ) {
			targ.super_damage_finished = time + powtimer;
			// Enable fading message
			targ.super_time = 1;
		}
	}
};
// Quad screen effect is shared by several items
void(entity targ) ResetPowerQuadItem = {
	targ.items = targ.items - (targ.items & IT_QUAD);
};

//----------------------------------------------------------------------
void(entity targ, float powtimer) ResetPowerSharp =
{
	if (powtimer == 0) {
		targ.moditems = targ.moditems - (targ.moditems & IT_ARTSHARP);
		targ.sharpshoot_finished = targ.sharpshoot_time = 0;
	}
	else if (targ.moditems & IT_ARTSHARP) {
		// Stop powerup constantly being reset once below timer
		if (targ.sharpshoot_finished > (time + powtimer) ) {
			targ.sharpshoot_finished = time + powtimer;
			// Enable fading message
			targ.sharpshoot_time = 1;
		}
	}
};

//----------------------------------------------------------------------
void(entity targ, float powtimer) ResetPowerPiercer =
{
	if (powtimer == 0) {
		targ.moditems = targ.moditems - (targ.moditems & IT_ARTPIERCE);
		targ.nailpiercer_finished = targ.nailpiercer_time = 0;
	}
	else if (targ.moditems & IT_ARTPIERCE) {
		// Stop powerup constantly being reset once below timer
		if (targ.nailpiercer_finished > (time + powtimer) ) {
			targ.nailpiercer_finished = time + powtimer;
			// Enable fading message
			targ.nailpiercer_time = 1;
		}
	}
};

//----------------------------------------------------------------------
void(entity targ, float powtimer) ResetPowerLavaShield =
{
	if (powtimer == 0) {
		targ.moditems = targ.moditems - (targ.moditems & IT_ARTLAVASHIELD);
		targ.lavashield_finished = targ.lavashield_time = 0;
	}
	else if (targ.moditems & IT_ARTLAVASHIELD) {
		// Stop powerup constantly being reset once below timer
		if (targ.lavashield_finished > (time + powtimer) ) {
			targ.lavashield_finished = time + powtimer;
			// Enable fading message
			targ.lavashield_time = 1;
		}
	}
};

//----------------------------------------------------------------------
void(entity targ, float powtimer) ResetPowerAirTank =
{
	if (powtimer == 0) {
		targ.moditems = targ.moditems - (targ.moditems & IT_ARTAIRTANK);
		targ.airtank_finished = targ.airtank_time = 0;
	}
	else if (targ.moditems & IT_ARTAIRTANK) {
		// Stop powerup constantly being reset once below timer
		if (targ.airtank_finished > (time + powtimer) ) {
			targ.airtank_finished = time + powtimer;
			// Enable fading message
			targ.airtank_time = 1;
		}
	}
};

//----------------------------------------------------------------------
void(entity targ, float powtimer) ResetPowerBlastbelt =
{
	if (powtimer == 0) {
		targ.moditems = targ.moditems - (targ.moditems & IT_ARTBLASTBELT);
		targ.blastbelt_finished = targ.blastbelt_time = 0;
	}
	else if (targ.moditems & IT_ARTBLASTBELT) {
		// Stop powerup constantly being reset once below timer
		if (targ.blastbelt_finished > (time + powtimer) ) {
			targ.blastbelt_finished = time + powtimer;
			// Enable fading message
			targ.blastbelt_time = 1;
		}
	}
};

//----------------------------------------------------------------------
void(entity targ, float powtimer) ResetPowerJumpBoots =
{
	if (powtimer == 0) {
		targ.moditems = targ.moditems - (targ.moditems & IT_ARTJUMPBOOTS);
		targ.jumpboots_finished = targ.jumpboots_time = 0;
	}
	else if (targ.moditems & IT_ARTJUMPBOOTS) {
		// Stop powerup constantly being reset once below timer
		if (targ.jumpboots_finished > (time + powtimer) ) {
			targ.jumpboots_finished = time + powtimer;
			// Enable fading message
			targ.jumpboots_time = 1;
		}
	}
};

//----------------------------------------------------------------------
void(entity targ, float powtimer, float novania) ResetPowerSystem =
{
	// This only works for player clients
	if (!(targ.flags & FL_CLIENT)) return;
	
	targ.effects = 0;
	ResetPowerInvRing(targ, powtimer);
	ResetPowerPent(targ, powtimer);
	ResetPowerEnvSuit(targ, powtimer);
	ResetPowerQuad(targ, powtimer);
	ResetPowerSharp(targ, powtimer);
	ResetPowerPiercer(targ, powtimer);
	// Don't reset Vania items
	if (novania) {
		ResetPowerLavaShield(targ, powtimer);
		ResetPowerAirTank(targ, powtimer);
		ResetPowerBlastbelt(targ, powtimer);
		ResetPowerJumpBoots(targ, powtimer);
	}
};

//----------------------------------------------------------------------
void(entity targ) PlayLavaShieldSound =
{
	// Only works for the player
	if (!(targ.flags & FL_CLIENT)) return;
	
	// Can still drown from liquid damage!?!
	targ.air_finished = time + WATER_AIR;
	// Time for another sound reminder?
	if (targ.lavashield_sound < time) {
		if (targ.lavashield_volume > 0) {
			targ.volume = (0.5 + random() * 0.5) * targ.lavashield_volume;
			// Make sure volume is within range (will get errors)
			if (targ.volume > 1) targ.volume = 1;
			sound (targ, CHAN_ITEM, SOUND_ARTLSHIELD3, targ.volume, ATTN_NORM);
		}
		targ.lavashield_sound = time + 2;
	}
};

//----------------------------------------------------------------------
void(entity targ) PlayBlastBeltSound =
{
	// Only works for the player
	if (!(targ.flags & FL_CLIENT)) return;
	
	// Time for another sound reminder?
	if (targ.blastbelt_sound < time) {
		if (targ.blastbelt_volume > 0) {
			targ.volume = (0.5 + random() * 0.5) * targ.blastbelt_volume;
			// Make sure volume is within range (will get errors)
			if (targ.volume > 1) targ.volume = 1;
			sound (targ, CHAN_ITEM, SOUND_ARTBLASTBELT3, targ.volume, ATTN_NORM);
		}
		targ.blastbelt_sound = time + 2;
	}
};

//----------------------------------------------------------------------
void(entity targ) PlayPentagramSound =
{
	// Only works for the player
	if (!(targ.flags & FL_CLIENT)) return;
	
	// Time for another sound reminder?
	if (targ.invincible_sound < time) {
		sound (targ, CHAN_ITEM, SOUND_ARTPENT3, 1, ATTN_NORM);
		targ.invincible_sound = time + 2;
	}
};

//============================================================================
void() ClientPowerups =
{
	// Exceptions: Dead, intermission or cinematic cameras
	if (self.health < 1) return;
	if (intermission_running > 0) return;
	if (cinematic_running > 0) return;

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

		if (self.invisible_finished < time + PWR_FADING) {
			// First part of 3s cooldown
			if (self.invisible_time == 1) {
				sprint (self, "Ring of Shadows magic is fading\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, SOUND_ARTINV2, 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}
			// 2md/3rd part of cooldown
			if (self.invisible_time < time) {
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		// Update inventory and timers
		if (self.invisible_finished < time) ResetPowerInvRing(self,0);
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
		self.air_finished = time + WATER_AIR;	// don't drown

	// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + PWR_FADING) {
			if (self.rad_time == 1) {
				sprint (self, "Air supply in Biosuit expiring!\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, SOUND_ARTSUIT2, 1, ATTN_NORM);
				self.rad_time = time + 1;
			}
			if (self.rad_time < time) {
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		// Update inventory and timers
		if (self.radsuit_finished < time) ResetPowerEnvSuit(self,0);
	}
	
	//----------------------------------------------------------------------
	// Invincibility (Pentagram)
	// - Flash screen 3s before running out
	//----------------------------------------------------------------------
	if (self.invincible_finished > 0) {
	// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + PWR_FADING) {
			if (self.invincible_time == 1) {
				sprint (self, "Protection is almost burned out!\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, SOUND_ARTPENT2, 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}
			if (self.invincible_time < time) {
				self.invincible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}	
		// Update inventory and timers
		if (self.invincible_finished < time) ResetPowerPent(self,0);
	}

	//----------------------------------------------------------------------
	// Super Damage (Quad)
	// - Flash screen 3s before running out
	//----------------------------------------------------------------------
	if (self.super_damage_finished > 0) {
		// sound and screen flash when items starts to run out
		if (self.super_damage_finished < time + PWR_FADING) {
			if (self.super_time == 1) {
				sprint (self, "Quad Damage is wearing off!\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, SOUND_ARTQUAD2, 1, ATTN_NORM);
				self.super_time = time + 1;
			}	  
			if (self.super_time < time) {
				self.super_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		// Update inventory and timers
		if (self.super_damage_finished < time) ResetPowerQuad(self,0);
	}	

	//----------------------------------------------------------------------
	// Lava Shield (Aegis of Chthon)
	// - Flash screen 3s before running out
	//----------------------------------------------------------------------
	if (self.lavashield_finished > 0) {
	// sound and screen flash when items starts to run out
		if (self.lavashield_finished < time + PWR_FADING) {
			if (self.lavashield_time == 1) {
				sprint (self, "Aegis is falling apart!\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, SOUND_ARTLSHIELD2, 1, ATTN_NORM);
				self.lavashield_time = time + 1;
			}
			if (self.lavashield_time < time) {
				self.lavashield_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}	
		// Update inventory and timers
		if (self.lavashield_finished < time) ResetPowerLavaShield(self,0);
	}

	//----------------------------------------------------------------------
	// Air Tank	
	// - Flash screen 3s before running out
	// - Give player 12s of air after suit finishes
	//----------------------------------------------------------------------
	if (self.airtank_finished > 0 || self.airtank_finished == -1) {
		self.air_finished = time + 12;		// don't drown

		// Produce particle bubbles
		if (self.waterlevel == 3) {
			if (self.airtank_bubbles < time) {
				self.airtank_bubbles = time + 0.5 + random();
				particle_debuff(self.origin, 16, rint(10+random()*40), PARTICLE_BURST_BLUE);
			}
		}
		
		// Check to see if the water level has changed
		if (self.airtank_level != self.waterlevel) {
			// Is the player coming out of the water?
			if (self.airtank_level > 2 && self.waterlevel < 3)
				self.airtank_sound = 0;
			// Is the player going into the water? (above head)
			else if (self.airtank_level < 3 && self.waterlevel > 2)
				self.airtank_sound = 0;
			self.airtank_level = self.waterlevel;
		}		
		
		// Play active sound based on water level
		// Check for silent sound option (1.7 Patch 2)
		if (self.airtank_sound < time && self.airtank_silent == FALSE) {
			if (self.waterlevel == 3) {
				// Under water sound with bubbbles
				if (self.airtank_volume > 0) {
					self.volume = (0.5 + random() * 0.5) * self.airtank_volume;
					// Make sure volume is within range (will get errors)
					if (self.volume > 1) self.volume = 1;
					// Play underwater sound (breathing + bubbles)
					sound (self, CHAN_ITEM, SOUND_ARTAIRTANK3, self.volume, ATTN_IDLE);
				}
				self.airtank_sound = time + 4;
			}
			else {
				if (!self.airtank_outwater) {
					// Different sound when not in the water (faster)
					if (self.airtank_volume > 0) {
						self.volume = (0.3 + random() * 0.3) * self.airtank_volume;
						// Make sure volume is within range (will get errors)
						if (self.volume > 1) self.volume = 1;
						// Play out of water sound (heavy breathing)
						sound (self, CHAN_ITEM, SOUND_ARTAIRTANK3B, self.volume, ATTN_IDLE);
					}
					self.airtank_sound = time + 3 + random();
				}
			}
		}
		
		// Don't check expiration if infinite
		if (self.airtank_finished > -1) {
			// sound and screen flash when items starts to run out
			if (self.airtank_finished < time + PWR_FADING) {
				self.airtank_sound = time + 4;	// Stop breathing sound
				self.airtank_silent = FALSE;	// Reset sound suppression
				if (self.airtank_time == 1) {
					sprint (self, "Air supply in Tanks is expiring\n");
					stuffcmd (self, "bf\n");
					sound (self, CHAN_AUTO, SOUND_ARTAIRTANK2, 1, ATTN_NORM);
					self.airtank_time = time + 1;
				}
				if (self.airtank_time < time) {
					self.airtank_time = time + 1;
					stuffcmd (self, "bf\n");
				}
			}
			// Update inventory and timers
			if (self.airtank_finished < time) ResetPowerAirTank(self,0);
		}
	}
	
	//----------------------------------------------------------------------
	// Blast Belt - Splash Damage Immunity
	// - Flash screen 3s before running out
	//----------------------------------------------------------------------
	if (self.blastbelt_finished > 0) {
	// sound and screen flash when items starts to run out
		if (self.blastbelt_finished < time + PWR_FADING) {
			if (self.blastbelt_time == 1) {
				sprint (self, "Blast belt is failing\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, SOUND_ARTBLASTBELT2, 1, ATTN_NORM);
				self.blastbelt_time = time + 1;
			}
			if (self.blastbelt_time < time) {
				self.blastbelt_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}	
		// Update inventory and timers
		if (self.blastbelt_finished < time) ResetPowerBlastbelt(self,0);
	}

	//----------------------------------------------------------------------
	// Jump Boots - Vertical Height Exploration
	//----------------------------------------------------------------------
	if (self.jumpboots_finished > 0) {
		// sound and screen flash when items starts to run out
		if (self.jumpboots_finished < time + PWR_FADING) {
			if (self.jumpboots_time == 1) {
				sprint (self, "Jump Boots are wearing off\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, SOUND_ARTJUMPBOOTS2, 1, ATTN_NORM);
				self.jumpboots_time = time + 1;
			}	  
			if (self.jumpboots_time < time) {
				self.jumpboots_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		// Update inventory and timers
		if (self.jumpboots_finished < time) ResetPowerJumpBoots(self,0);
	}
	
	//----------------------------------------------------------------------
	// SharpShooter
	// - Flash screen 3s before running out
	//----------------------------------------------------------------------
	if (self.sharpshoot_finished > 0) {
	// sound and screen flash when items starts to run out
		if (self.sharpshoot_finished < time + PWR_FADING) {
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
		// Update inventory and timers
		if (self.sharpshoot_finished < time) ResetPowerSharp(self,0);
	}

	//----------------------------------------------------------------------
	// Nail Piercer
	// - Flash screen 3s before running out
	//----------------------------------------------------------------------
	if (self.nailpiercer_finished > 0) {
		// sound and screen flash when items starts to run out
		if (self.nailpiercer_finished < time + PWR_FADING) {
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
		// Update inventory and timers
		if (self.nailpiercer_finished < time) ResetPowerPiercer(self,0);
	}	

	//------------------------------------------------------------------
	// Only remove the quad effect (status bar update)
	// if all extra mod artifacts have expired as well
	//------------------------------------------------------------------
	if (self.super_damage_finished == 0 && self.sharpshoot_finished == 0 
		&& self.nailpiercer_finished == 0)
		ResetPowerQuadItem(self);

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

