/*==============================================================================
 Large rotating surface mount turret (model/animation by Benoit Stordeur)
 * QC was created for Bal's Hypnagogia project

  Interesting QC traits
  * Can be mounted on walls, ceilings or floors
  * Special axis lock feature to prevent turret clipping into world geo
  * Does not use a front facing angle for sight checks (infront)
  * The attacks get faster over time, the longer the enemy is in view
  * Range attack will not bend projectiles if enemy outside axis range
  * Will not track enemies if out of sight, uses last known location instead
  * Has no head model when destroyed on death, can hide stuff behind it! :P
 
  Assets required to get this monster working in AD
    (model's in 'progs' and wav's in 'sound' sub directories)
  * mon_turretbal.mdl (complete model)
  * gib_turretbal1.mdl (base of gun barrel)
  * gib_turretbal2.mdl (end of metal barrel)
  * gib_turretbal3.mdl (barrel section)
  * gib_turretbal4.mdl (main body section)

==============================================================================*/

// (000) Tiny scale version (same as move1 position)
$frame tiny1

// (001-010) Coming out of the wall/ceil/floor
$frame move1 move2 move3 move4 move5 move6 move7 move8
$frame move9 move10

// (011-020) Push barrels out, wake up ready for combat
$frame wakeup1 wakeup2 wakeup3 wakeup4 wakeup5 wakeup6 wakeup7 wakeup8
$frame wakeup9 wakeup10

// (021-021) Ready for combat
$frame run1

// (022-045) Fire 3 shots, 1 barrel at a time (fire1 used once)
$frame fire1 fire2 fire3 fire4 fire5 fire6 fire7 fire8
$frame fire9 fire10 fire11 fire12 fire13 fire14 fire15 fire16
$frame fire17 fire18 fire19 fire20 fire21 fire22 fire23 fire24

// (046-048) Empty frame(s)
$frame emptyB1 emptyB2 emptyB3

// (049-058) Fire 3 barrels at once (blast1 used once)
$frame blast1 blast2 blast3 blast4 blast5 blast6 blast7 blast8
$frame blast9 blast10

// (059-068) Idle 1 (Slight rotate + move barrels in/out)
$frame idleB1 idleB2 idleB3 idleB4 idleB5 idleB6 idleB7 idleB8
$frame idleB9 idleB10

// (069-075) Idle 2 (Slight rotate)
$frame idleC1 idleC2 idleC3 idleC4 idleC5 idleC6 idleC7

// (076-085) Idle 3 (full rotate)
$frame idleD1 idleD2 idleD3 idleD4 idleD5 idleD6 idleD7 idleD8
$frame idleD9 idleD10

// Turret states
float TURRETB_CLOSED = 0;	// hidden in wall/ceil/floor
float TURRETB_OPENED = 1;	// Open and idling
float TURRETB_CLOSING = 2;	// Closing Animation
float TURRETB_OPENING = 3;	// Opening Animation
float TURRETB_BARREL = 4;	// Extending barrels
float TURRETB_COMBAT = 5;	// Attacking enemies

float TURRETB_WAKEWALL = 10;	// Wall boundary overlap
float TURRETB_WAKEUPDOWN = 5;	// Ceil/Floor boundary overlap

//======================================================================
// Many new custom functions because the turret only rotates
// Most monster (AI) functions assume the monster can move around
// All rotations have to go through an axis lock check first
//======================================================================

// Reset origin to stop any velocity drift
void() turretb_resetorigin =
{
	// Make sure no velocity/origin drift over time
	self.velocity = self.avelocity = '0 0 0';
	setorigin(self, self.oldorigin);
};

//----------------------------------------------------------------------
// Will twist the turret around to random angles (idle phase)
void(float rnd_angle) turretb_rotate =
{
	// angles = up/down, angle, tilt left/right 'pitch yaw roll'
	self.mangle = '0 0 0';
	self.mangle_x = crandom() * rnd_angle;
	self.mangle_y = crandom() * rnd_angle;
	// Finalangle is the spawn/starting angle of the model
	// Always reset the angle back to starting position
	self.angles = self.finalangle + self.mangle;
};

//----------------------------------------------------------------------
// Create vector offset of where enemy sight/fire tests are done
// Used by the various visibility check/fire functions
void(vector att_angle, vector att_offset) turretb_attvector =
{
	// Duplicate current turret angles
	self.attack_track = att_angle;
	// X has to be reversed, no idea why!
	self.attack_track_x = -self.attack_track_x;
	// Make all v_ vectors for 'attack_vector' function
	makevectors(self.attack_track);
	// Workout projectile starting point (end of barrel)
	self.attack_track = attack_vector(att_offset);
};

//----------------------------------------------------------------------
// The main function for checking if axis rotation has hit a limit
// Uses local and return variable so that it can cope with re-use
//----------------------------------------------------------------------
vector(vector angcheck) turretb_axischeck =
{
	local vector angpos1, angpos2, newlockx, newlocky;

	// This is a horrible hack, but the wakeup angle for the turret
	// needs to be adjusted to cope with targets moving around quickly.
	// The default wakeup can be right at the edge of the axis lock
	// and this adjustment allows for a bit of angle boundary overlap
	if (self.state == TURRETB_CLOSED) {
		newlockx_x = self.anglockx_x + self.wakeup_angle;	// (270-360)
		newlockx_y = self.anglockx_y - self.wakeup_angle;	// (000-090)
		newlocky_x = self.anglocky_x + self.wakeup_angle;	// (270-360)
		newlocky_y = self.anglocky_y - self.wakeup_angle;	// (000-090)
	}
	else {
		// No boundary overlap (max axis lock)
		newlockx = self.anglockx;
		newlocky = self.anglocky;
	}
	
	// What is the difference between current angle and spawn angle?
	// First convert the angles to the new system (0/360 = spawn direction)
	// Use anglemod to convert angles to 0-360 range (fix neg values)
	angpos1_x = anglemod(angcheck_x - self.anglockx_z);
	angpos1_y = anglemod(angcheck_y - self.anglocky_z);
	angpos1_z = 0;
	angpos2 = angcheck;

	// Check for angle zone from lock number to 180
	if (angpos1_x >= 180 && angpos1_x <= newlockx_x)
		angpos2_x = anglemod(newlockx_x + self.anglockx_z);
	if (angpos1_x < 180 && angpos1_x >= newlockx_y)
		angpos2_x = anglemod(newlockx_y + self.anglockx_z);
	
	// Wall mounted turrets use two axis (XY) instead
	if (self.volume) {
		if (angpos1_y >= 180 && angpos1_y <= newlocky_x)
			angpos2_y = anglemod(newlocky_x + self.anglocky_z);
		if (angpos1_y < 180 && angpos1_y >= newlocky_y)
			angpos2_y = anglemod(newlocky_y + self.anglocky_z);
	}
	
	// Result of axis lock
	return angpos2;
};

//----------------------------------------------------------------------
// Move the turret back to the spawn angle ready for hide animation
// This is based on the HALFSPEED code from turret_ai_face
//----------------------------------------------------------------------
void() turretb_ai_return =
{
	if (self.health < 1) return;

	// Current facing angle of turret
	makevectors(self.angles);
	self.pos1 = v_forward;
	// The spawn angle for the turret
	makevectors(self.finalangle);
	self.pos2 = v_forward;
	// Create half way point between two vectors
	self.pos3 = self.pos1 + (self.pos2 * 0.5);
	// Switch back to an angle
	self.finaldest = vectoangles(self.pos3);
	// Fix angle conversion errors (Pitch is reversed)
	self.finaldest_x = self.finaldest_x = -self.finaldest_x;
	// Finally rotate to new position
	self.angles = vectormod(self.finaldest);
};

//----------------------------------------------------------------------
// Works like ai_face and turns the model barrels towards the enemy
// This function takes care of axis movement restrictions 
// HALFSPEED : Used when waking up to slowdown the turning speed
//----------------------------------------------------------------------
vector(float halfspeed) turretb_ai_face =
{
	local vector retangles, newangles;
	retangles = self.angles;
	
	// Exceptions return no angle change
	if (!self.enemy) return retangles;
	if (self.health < 1) return retangles;
	
	// Create enemy facing vector (Will use last known position as well)
	// This has got to always face the enemy regardless of axis locks
	// Axis lock needs to be from monster origin, not end of barrel
	// Second offset is to aim at the enemies head (catch jumpers)
	if ( !visxray(self.enemy, '0 0 0', '0 0 12', FALSE) )
		// use backup origin instead, something wrong
		self.movedir = normalize((self.move_state + '0 0 12') - self.origin);
	// Still got the enemy in sight, aim at head to catch jumpers
	else self.movedir = normalize((self.enemy.origin + '0 0 12') - self.origin);

	// Convert enemy vector into ideal facing angle
	self.pos1 = vectoangles(self.movedir);
	// Checks that enemy facing angles is within axis lock range
	newangles = turretb_axischeck(self.pos1);
	
	// Half speed angle movement?
	if (halfspeed) {
		// Calculate the half way point between current and destination
		// rotation angle of model. Originally tried to do this by
		// calculating the difference between two angles. It was
		// a total mess because the turret would often clip through
		// the walls because of rotation errors.
		// The final idea was to use vectors (v_forward) and add half
		// the distance to the original and turn back into an angle
		// Does not suffer from any clipping issues because the axis
		// rotations are validated beforehand.
		makevectors(self.angles);
		self.pos1 = v_forward;
		makevectors(newangles);
		self.pos2 = v_forward;
		// Create half way point between two vectors
		self.pos3 = self.pos1 + (self.pos2 * 0.5);
		// Switch back to an angle
		newangles = vectoangles(self.pos3);
		// Fix angle conversion errors (Pitch is reversed)
		newangles_x = newangles_x = -newangles_x;
	}
	// Finally rotate to new position
	retangles = vectormod(newangles);
	return retangles;
};

//======================================================================
// Move barrels out/in quickly
void() turretb_idleA1 =[ $wakeup2, turretb_idleA2 ] {ai_stand();
	// Slight movement sound of barrels
	sound (self, CHAN_VOICE, "turretb/barrel_idle1.wav", 1, ATTN_NORM);};
void() turretb_idleA2 =[ $wakeup4, turretb_idleA3 ] {ai_stand(); };
void() turretb_idleA3 =[ $wakeup6, turretb_idleA4 ] {ai_stand(); };
void() turretb_idleA4 =[ $wakeup8, turretb_idleA5 ] {ai_stand(); };
void() turretb_idleA5 =[ $wakeup7, turretb_idleA6 ] {ai_stand(); };
void() turretb_idleA6 =[ $wakeup6, turretb_idleA7 ] {ai_stand(); };
void() turretb_idleA7 =[ $wakeup5, turretb_idleA8 ] {ai_stand(); };
void() turretb_idleA8 =[ $wakeup4, turretb_idleA9 ] {ai_stand(); };
void() turretb_idleA9 =[ $wakeup3, turretb_idleA10 ] {ai_stand(); };
void() turretb_idleA10 =[ $wakeup2, turretb_idle1 ] {ai_stand(); };

//----------------------------------------------------------------------
// Rotate barrels (Slight rotate + move barrels in/out)
void() turretb_idleB1 =[ $idleB1, turretb_idleB2 ] {ai_stand();
	// Slight movement sound of barrels
	sound (self, CHAN_VOICE, "turretb/barrel_idle1.wav", 1, ATTN_NORM);};
void() turretb_idleB2 =[ $idleB2, turretb_idleB3 ] {ai_stand(); };
void() turretb_idleB3 =[ $idleB3, turretb_idleB4 ] {ai_stand(); };
void() turretb_idleB4 =[ $idleB4, turretb_idleB5 ] {ai_stand(); };
void() turretb_idleB5 =[ $idleB5, turretb_idleB6 ] {ai_stand(); };
void() turretb_idleB6 =[ $idleB6, turretb_idleB7 ] {ai_stand(); };
void() turretb_idleB7 =[ $idleB7, turretb_idleB8 ] {ai_stand(); };
void() turretb_idleB8 =[ $idleB8, turretb_idleB9 ] {ai_stand(); };
void() turretb_idleB9 =[ $idleB9, turretb_idleB10 ] {ai_stand(); };
void() turretb_idleB10 =[ $idleB10, turretb_idle1 ] {ai_stand(); };

//----------------------------------------------------------------------
// Rotate barrels (slight twist)
void() turretb_idleC1 =[ $idleC1, turretb_idleC2 ] {ai_stand();
	// Twirling sound to match barrel movement
	sound (self, CHAN_VOICE, "turretb/barrel_idle2.wav", 1, ATTN_NORM);};
void() turretb_idleC2 =[ $idleC2, turretb_idleC3 ] {ai_stand(); };
void() turretb_idleC3 =[ $idleC3, turretb_idleC4 ] {ai_stand(); };
void() turretb_idleC4 =[ $idleC4, turretb_idleC5 ] {ai_stand(); };
void() turretb_idleC5 =[ $idleC5, turretb_idleC6 ] {ai_stand(); };
void() turretb_idleC6 =[ $idleC6, turretb_idleC7 ] {ai_stand(); };
void() turretb_idleC7 =[ $idleC7, turretb_idle1 ] {ai_stand(); };

//----------------------------------------------------------------------
// Rotate barrels (full 360 rotate)
void() turretb_idleD1 =[ $idleD1, turretb_idleD2 ] {ai_stand(); 
	// Twirling sound to match barrel movement
	sound (self, CHAN_VOICE, "turretb/barrel_idle2.wav", 1, ATTN_NORM);};
void() turretb_idleD2 =[ $idleD2, turretb_idleD3 ] {ai_stand(); };
void() turretb_idleD3 =[ $idleD3, turretb_idleD4 ] {ai_stand(); };
void() turretb_idleD4 =[ $idleD4, turretb_idleD5 ] {ai_stand(); };
void() turretb_idleD5 =[ $idleD5, turretb_idleD6 ] {ai_stand(); };
void() turretb_idleD6 =[ $idleD6, turretb_idleD7 ] {ai_stand(); };
void() turretb_idleD7 =[ $idleD7, turretb_idleD8 ] {ai_stand(); };
void() turretb_idleD8 =[ $idleD8, turretb_idleD9 ] {ai_stand(); };
void() turretb_idleD9 =[ $idleD9, turretb_idleD10 ] {ai_stand(); };
void() turretb_idleD10 =[ $idleD10, turretb_idle1 ] {ai_stand(); };

//----------------------------------------------------------------------
// Main idle loop (10 frames so idle sounds are less frequent)
void()	turretb_idle1 =[ $wakeup1, turretb_idle2 ] { 
	self.state = TURRETB_OPENED; 
	// Stop velocity drift
	turretb_resetorigin();
	monster_idle_sound(); 
	ai_stand();
};
void()	turretb_idle2 =[ $wakeup1, turretb_idle3 ] { ai_stand(); };
void()	turretb_idle3 =[ $wakeup1, turretb_idle4 ] { ai_stand(); };
void()	turretb_idle4 =[ $wakeup1, turretb_idle5 ] { ai_stand(); };
void()	turretb_idle5 =[ $wakeup1, turretb_idle6 ] { ai_stand(); };
void()	turretb_idle6 =[ $wakeup1, turretb_idle7 ] { ai_stand(); };
void()	turretb_idle7 =[ $wakeup1, turretb_idle8 ] { ai_stand(); };
void()	turretb_idle8 =[ $wakeup1, turretb_idle9 ] { ai_stand(); };
void()	turretb_idle9 =[ $wakeup1, turretb_idle10 ] { ai_stand(); };
void()	turretb_idle10 =[ $wakeup1, turretb_idle1 ] {
	self.idlebusy = FALSE; 
	// make sure no idle animations if about to go into combat
	if (random() < MON_IDLE_ANIMATION && !self.enemy) {
		// Slight random movement of turret barrels
		turretb_rotate(25);
		self.idlebusy = TRUE; 
		// Make sure the idle animations don't repeat in a row
		self.lefty = self.lip;
		while (self.lefty == self.lip) { self.lefty = rint(random()*4);}
		self.lip = self.lefty;
		if (self.lip < 1) self.think = turretb_idleA1;		// Push barrels out/in
		else if (self.lip < 2) self.think = turretb_idleB1;	// Slight rotate
		else if (self.lip < 3) self.think = turretb_idleC1;	// Slight Twist
		else self.think = turretb_idleD1;					// Full rotate
	}
};

//======================================================================
// OPENING : Coming out of wall/ceil/floor
//======================================================================
void() turretb_opening1 = [ $move1, turretb_opening2 ] {
	self.state = TURRETB_OPENING;
	// Gun moving out and twirling barrels
	sound (self, CHAN_VOICE, "turretb/barrel_idle2.wav", 1, ATTN_NORM);
	// Fire any entity trigger(s), can use delay ents if needed
	if (self.turretopening != "") trigger_strs(self.turretopening, self.enemy);
};
void() turretb_opening2 = [ $move2, turretb_opening3 ] {};
void() turretb_opening3 = [ $move3, turretb_opening4 ] {};
void() turretb_opening4 = [ $move4, turretb_opening5 ] {};
void() turretb_opening5 = [ $move5, turretb_opening6 ] {};
void() turretb_opening6 = [ $move6, turretb_opening7 ] {};
void() turretb_opening7 = [ $move7, turretb_opening8 ] {};
void() turretb_opening8 = [ $move9, turretb_wakeup ] {
	self.state = TURRETB_OPENED; 
	// Restore damage ability
	self.takedamage = DAMAGE_AIM; 
	// Restore bounding box and size (were missing)
	self.solid = SOLID_SLIDEBOX;
	setsize (self, self.bbmins, self.bbmaxs);
	// If no enemy? Back to idling
	if (!self.enemy) self.think = turretb_idle1;
};

//----------------------------------------------------------------------
// WAKEUP : Going into combat (+slowly rotating towards enemy)
//----------------------------------------------------------------------
void() turretb_wakeup =[ $wakeup4, turretb_wakeup2 ] {
	// Reset timer for closing down turret
	self.attack_timer = time + self.waitmin;
	self.state = TURRETB_BARREL;
	// Slowly move the barrels toward the enemy
	self.angles = turretb_ai_face(TRUE);
	// Gun barrels moving towards enemy
	sound (self, CHAN_VOICE, "turretb/barrel_idle1.wav", 1, ATTN_NORM);
};
void() turretb_wakeup2 =[ $wakeup6, turretb_wakeup3 ] {self.angles = turretb_ai_face(TRUE);};
void() turretb_wakeup3 =[ $wakeup8, turretb_wakeup4 ] {self.angles = turretb_ai_face(TRUE);};
void() turretb_wakeup4 =[ $wakeup10, turretb_combat ] {self.angles = turretb_ai_face(FALSE);};

//----------------------------------------------------------------------
// CLOSED : Buried in wall/ceil/floor and cannot take any damage
//----------------------------------------------------------------------
void() turretb_closed = [ $move1, turretb_closed ] { 
	self.state = TURRETB_CLOSED; 
	// Don't want turret damaged when hidden in wall/ceil/floor
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	// Stop velocity drift
	turretb_resetorigin();
	// Only start checking for enemies once timer ready
	if (self.attack_timer < time) {
		// Return passive turrets back to combat
		if (self.passive_mode) self.passive_mode = FALSE;
		if (self.passive_state) self.passive_state = FALSE;

		// Look for any enemies
		if (FindTarget ()) {
			// Can return world as enemy, block it!
			if (!self.enemy) return;
			
			// Create angle that would be needed to hit enemy
			self.finaldest = turretb_ai_face(FALSE);
			self.finaldest_x = -self.finaldest_x;

			// Check if the turret can hit the new enemy?
			if ( visang(self.enemy, '0 0 0', self.finaldest, FALSE) ) {

				// Check if enemy distance is right?
				self.lip = range_distance(self.enemy, FALSE);
				if (self.lip >= self.distance) {
					// Reset targets and go back to loop
					self.enemy = self.goalentity = self.movetarget = world;
					self.think = turretb_closed;
				}
				// Start opening sequence
				else self.think = turretb_opening1;
			}
			else {
				// Reset targets and go back to loop
				self.enemy = self.goalentity = self.movetarget = world;
				self.think = turretb_closed;
			}
		}
	}
};

//----------------------------------------------------------------------
// RETURN : Preparing barrels to hide (+slowly rotate towards center)
//----------------------------------------------------------------------
void() turretb_return =[ $wakeup8, turretb_return2 ] {
	self.state = TURRETB_BARREL;
	turretb_ai_return();
	// Gun barrels moving towards spawn location
	sound (self, CHAN_VOICE, "turretb/barrel_idle1.wav", 1, ATTN_NORM);
};
void() turretb_return2 =[ $wakeup6, turretb_return3 ] {turretb_ai_return();};
void() turretb_return3 =[ $wakeup4, turretb_return4 ] {turretb_ai_return();};
void() turretb_return4 =[ $wakeup2, turretb_closing1 ] {
	// Force spawn/start angle for hide animation
	self.angles = self.finalangle;
	self.fixangle = TRUE;
};

//----------------------------------------------------------------------
// CLOSING : Going back INTO the wall/ceil/floor (hidden state)
//----------------------------------------------------------------------
void() turretb_closing1 = [ $move8, turretb_closing2 ] {
	self.state = TURRETB_CLOSING;
	// No more damage or collision
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	// Gun moving in and twirling barrels
	sound (self, CHAN_VOICE, "turretb/barrel_idle2.wav", 1, ATTN_NORM);
};
void() turretb_closing2 = [ $move7, turretb_closing3 ] {};
void() turretb_closing3 = [ $move6, turretb_closing4 ] {};
void() turretb_closing4 = [ $move5, turretb_closing5 ] {};
void() turretb_closing5 = [ $move4, turretb_closing6 ] {};
void() turretb_closing6 = [ $move3, turretb_closing7 ] {
	if (self.turretclosing != "") trigger_strs(self.turretclosing, self.oldenemy);
	self.oldenemy = world;
};
void() turretb_closing7 = [ $move2, turretb_closing8 ] {};
void() turretb_closing8 = [ $move1, turretb_closed ] {
	// Setup timer to wait in closed position
	self.attack_timer = time + self.waitmin2 + (random() * self.waitmin2);
};

//======================================================================
// Entry point for stand/walk function
//======================================================================
void() turretb_stand = {
	// This is the entry point for spawning and re-use of turrets
	// For spawn delay it needs to be active straight away
	// For spawning at the beginning of the map, needs a slight delay
	// For re-entry of this function, it needs to be instant (=0)
	if (self.attack_timer < 0) self.attack_timer = time + self.waitmin3;
	else self.attack_timer = 0;
	// Stop velocity drift
	turretb_resetorigin();
	// Check the state of the turret (closed/open/combat)
	if (self.state == TURRETB_CLOSED) turretb_closed();
	else if (self.state == TURRETB_OPENED) turretb_idle1();
};

//----------------------------------------------------------------------
// Main combat loop for tracking / attacking player
void() turretb_combat =[ $run1, turretb_combat ] {
	// barrels extended and ready for attack
	self.state = TURRETB_COMBAT;
	// Stop velocity drift
	turretb_resetorigin();
	
	// Check if turret is giving up on enemy
	if (self.attack_timer < time && !self.turretlocked) {
		// Save later for triggers
		self.oldenemy = self.enemy;
		// Reset enemy and target system
		self.enemy = self.goalentity = self.movetarget = world;
		// Return to wall/ceil/floor animation
		turretb_return();
	}
	else {
		// Turn barrels to face enemy (axis restriction + full turn speed)
		self.angles = turretb_ai_face(FALSE);
		// typical run function (check for attacks)
		ai_run(0);
	}
};

//----------------------------------------------------------------------
// Entry point for run function
void() turretb_run = {
	// Reset timer for closing down turret
	self.attack_timer = time + self.waitmin;
	// Create backup copy for later
	self.move_state = self.enemy.origin;
	// Stop velocity drift
	turretb_resetorigin();
	// Check the state of the turret (closed/open/combat)
	if (self.state == TURRETB_CLOSED) turretb_opening1();
	else if (self.state == TURRETB_OPENED) turretb_wakeup();
	else if (self.state == TURRETB_COMBAT) turretb_combat();
};
	
//======================================================================
// Range (LASERS or PLASMA)
//======================================================================
void(vector att_offset) turretb_laser =
{
	local vector org, vec;

	if (!self.enemy) return;
	if (self.health < 1) return;
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	// Work out attack offset from end of barrel
	turretb_attvector(self.angles, att_offset);
	org = self.origin + self.attack_track;
	// Typically a projectile will fire directly at the enemy
	// This monster/turret has an axis lock and cannot fire any angle
	// The firing vector is taken from the monsters angles field instead
	// This means the projectile will not bend towards the enemy and
	// fire directly from the barrel using axis restrictions
	// This looks better and does not feel like the AI is cheating
	vec = v_forward;

	// Variable speed projectiles
	self.attack_speed = SPEED_TURRETBPROJ + (skill * SPEED_TURRETBPROJSKILL);
	// Laser or plasma? (different damage, same speed)
	if (self.spawnflags & MON_TURRETB_PLASMA) {
		sound (self, CHAN_WEAPON, SOUND_PLASMA_FIRE, 1, ATTN_NORM);
		launch_plasma(org, vec, CT_MONTURRETB, self.attack_speed);
	}
	else {
		sound (self, CHAN_WEAPON, SOUND_LASER_FIRE, 1, ATTN_NORM);
		launch_projectile(org, vec, CT_PROJ_LASER, self.attack_speed);
	}
};

//----------------------------------------------------------------------
void() turretb_fireframe =
{
	// If dead, no more updates
	if (self.health < 1) return;
	
	// Start animation at 10fps, spin up to 20fps (x 2 speed)
	self.nextthink = time + 0.05 + (0.01*(self.attack_rage-self.attack_chance));
	self.think = turretb_fireframe;

	// Turn towards enemy or use last known position
	// Check angle against axis lock at all times
	self.angles = turretb_ai_face(FALSE);
	
	// Animation trigger events
	if (self.spawnflags & MON_TURRETB_TRIPLE) {
		self.frame = $blast1 + self.walkframe;
		if (self.walkframe == 1) turretb_laser('66 0 5');
		if (self.walkframe == 1) turretb_laser('66 6 -4');
		if (self.walkframe == 1) turretb_laser('66 -6 -4');
		// Play attack barrel rotate sound
		if (self.walkframe == 2) 
			sound (self, CHAN_BODY, "turretb/attack1.wav", 1, ATTN_NORM);
	}
	else {
		self.frame = $fire1 + self.walkframe;		
		if (self.walkframe == 1) turretb_laser('66 0 5');
		else if (self.walkframe == 10) turretb_laser('66 0 5');
		else if (self.walkframe == 18) turretb_laser('66 0 5');
		// Play attack barrel rotate sound
		if (self.walkframe == 2) 
			sound (self, CHAN_BODY, "turretb/attack1.wav", 1, ATTN_NORM);
		if (self.walkframe == 11) 
			sound (self, CHAN_BODY, "turretb/attack1.wav", 1, ATTN_NORM);
		if (self.walkframe == 19) 
			sound (self, CHAN_BODY, "turretb/attack1.wav", 1, ATTN_NORM);
	}
	
	// Move frame forward, check for conditions
	self.walkframe = self.walkframe + 1;
	
	// End of animation loop?
	if (self.walkframe > self.attack_frame) {
		// Reset animation to fire on first frame
		self.walkframe = 1;

		// Check if enemy distance is too far away?
		self.lip = range_distance(self.enemy, FALSE);
		if (self.lip >= self.distance) {
			self.think = turretb_combat;
			self.attack_timer = 0;
		}
		else {
			// Setup current angles for traceline function
			self.finaldest = self.angles;
			self.finaldest_x = -self.finaldest_x;
			
			// Can the turret HIT the enemy? (new traceline function)
			if ( !visang(self.enemy, '0 0 0', self.finaldest, FALSE) ) {
				sound (self, CHAN_BODY, "turretb/spin_down.wav", 1, ATTN_NORM);
				// Enemy out axis range, stop firing and exit
				self.think = turretb_combat;
				// Can the turret SEE the enemy?
				if ( visxray(self.enemy, '0 0 0',  '0 0 0', FALSE) ) {
					// Enemy is waiting outside lock range, hide immediately
					self.attack_timer = 0;
				}
				else {
					// Enemy hidden, pause a bit to catch strafer's
					self.attack_timer = time + 1 + random();
				}
			}
			// Can HIT the enemy !!!!
			else {
				// Save origin for later
				self.move_state = self.enemy.origin;
			
				// Increase fire rate
				if (self.attack_chance < self.attack_rage) 
					self.attack_chance = self.attack_chance + self.attack_count;
			}
		}
	}
};

//----------------------------------------------------------------------
void() turretb_fire = { 
	self.walkframe = 0; self.attack_chance = 0; turretb_fireframe();
};

//======================================================================
vector() turretb_spawnvec =
{
	// Work out v_* directions
	makevectors(self.finalangle);
	// reverse direction if up/down config active
	if(self.volume) return v_forward;
	else return -v_forward;
}

//----------------------------------------------------------------------
void(entity inflictor, entity attacker, float damage) turretb_pain =
{
	// Check all pain conditions and set up what to do next
	monster_pain_check(attacker, damage);

	// Work out spawn angle/v_forward direction
	self.dest1 = turretb_spawnvec();
	// Spawn dust/model particles
	SpawnVelocitySmoke(self.origin, self.dest1+(crandom()*v_up), 200, 200);
	SpawnVelocitySmoke(self.origin, self.dest1+(crandom()*v_up), 200, 200);
	SpawnVelocitySmoke(self.origin, self.dest1+(crandom()*v_up), 200, 200);
	particle_dust(self.origin, 10+random()*10, 16, PARTICLE_BURST_YELLOW);

	// Any pain animation/sound required?
	if (self.pain_check > 0) {
		sound (self, CHAN_VOICE, self.pain_sound, 1, ATTN_NORM);
		self.pain_finished = time + 1;
	}
};

//======================================================================
void() turretb_die =
{
	// Pre-check routine to tidy up extra entities
	monster_death_precheck();

	// Work out spawn angle/v_forward direction
	self.dest1 = turretb_spawnvec();
	// Spawn dust/model particles
	SpawnVelocitySmoke(self.origin, self.dest1+(crandom()*v_up), 200, 200);
	SpawnVelocitySmoke(self.origin, self.dest1+(crandom()*v_up), 200, 200);
	SpawnVelocitySmoke(self.origin, self.dest1+(crandom()*v_up), 200, 200);
	particle_dust(self.origin, 10+random()*10, 16, PARTICLE_BURST_YELLOW);
	// Sprite explosion
	SpawnExplosion(EXPLODE_BIG, self.origin, self.death_sound);

	// no more turret
	entity_hide (self);
	// Make sure gibs go flying up
	self.max_health = MON_GIBFOUNTAIN;
	self.health = -100;

	// Metal and custom body parts
	self.gibtype = GIBTYPE_METAL;
	ThrowGib(11, 1);						// Base of gun barrel
	ThrowGib(12, 1 + rint(random()*2));		// End of barrel (max 3)
	ThrowGib(13, 2 + rint(random()*2));		// Barrel section
	ThrowGib(14, 1 + rint(random()*2));		// Main body chunks
	ThrowGib(15, 2 + rint(random()*3));		// Generic metal
};

/*======================================================================
QUAKED monster_turretbal (1 0 0) (-20 -20 -20) (20 20 20) Ambush
======================================================================*/
void() monster_turretbal =
{
	// Check all spawn exceptions (monsters.qc)
	if (monster_checkspawn() == TRUE) return;

	self.mdl = "progs/mon_turretbal.mdl";		// Turret
//	self.headmdl = "progs/h_turretbal.mdl";		// Not used
	self.gib1mdl = "progs/gib_turretbal1.mdl";	// base of gun barrel
	self.gib2mdl = "progs/gib_turretbal2.mdl";	// end of metal barrel
	self.gib3mdl = "progs/gib_turretbal3.mdl";	// barrel section
	self.gib4mdl = "progs/gib_turretbal4.mdl";	// main body section
	self.gib5mdl = "progs/gib_metal1.mdl";		// generic metal chunk

	precache_model (self.mdl);			// Turret
//	precache_model (self.headmdl);		// Not used
	precache_model (self.gib1mdl);		// frame of gun barrel
	precache_model (self.gib2mdl);		// end of metal barrel
	precache_model (self.gib3mdl);		// barrel section
	precache_model (self.gib4mdl);		// main body section
	precache_model (self.gib5mdl);		// generic metal chunk
	
	// Robot talktalk
	self.idle_sound = "turretb/idle1.wav";
	precache_sound (self.idle_sound);
	self.idle_sound2 = "turretb/idle2.wav";
	precache_sound (self.idle_sound2);

	// Idle barrel movements
	precache_sound ("turretb/barrel_idle1.wav");
	precache_sound ("turretb/barrel_idle2.wav");

	// Attack with spinning barrel
	precache_sound ("turretb/attack1.wav");
	precache_sound ("turretb/spin_down.wav");
	
	// Default attack - lasers!
	precache_model (MODEL_PROJ_LASER);			// Copy of enforcer laser
	precache_sound (SOUND_LASER_FIRE);
	precache_sound (SOUND_LASER_HIT);

	// Extra attack - plasma!
	precache_model (MODEL_PROJ_LASERBLUE);		// Blue version of laser
	precache_sound (SOUND_PLASMA_FIRE);
	precache_sound (SOUND_PLASMA_HIT);
	
	self.pain_sound = "turretb/pain1.wav";
	precache_sound (self.pain_sound);
	self.death_sound = "turretb/explode_major.wav";
	precache_sound (self.death_sound);
	
	self.sight_sound = "turretb/sight1.wav";
	precache_sound (self.sight_sound);

	self.solid = SOLID_NOT;				// No interaction with world
	self.movetype = MOVETYPE_NONE;		// Static item, no movement
	if (self.bboxtype < 1) self.bboxtype = BBOX_SQUARE;
	if (self.health < 1) self.health = 180;
	self.gibhealth = MON_NEVERGIB;		// Special explosion death
	self.gibbed = FALSE;
	self.pain_flinch = 1;				// Always flinch
	self.pain_timeout = 1;				// Low pain threshold
	self.steptype = FS_FLYING;			// Silent feet
	self.pain_longanim = FALSE;			// No long pain animation
	self.blockudeath = TRUE;			// No humanoid death sound
	self.poisonous = FALSE;				// Robots are not poisonous
	self.no_liquiddmg = TRUE;			// Immune to slime/lava
	self.deathstring = " was blasted to hell by a Turret\n";
	self.attack_offset = '66 0 0';		// Middle of three barrels
	self.sight_nofront = TRUE;			// Has no front facing
	self.weaponstate = FALSE;			// Open/close barrel state
	self.movespeed = -1;				// Never move model
	if (self.attack_count < 0) self.attack_count = 0;
	else self.attack_count = 1;			// Fire rate Increment
	self.attack_rage = 5;				// Fire rate Maximum
	// Different animation sets for single/blast attacks
	if (self.spawnflags & MON_TURRETB_TRIPLE) self.attack_frame = 10;
	else self.attack_frame = 24;

	// Check state is within range (state types)
	if (self.state < TURRETB_CLOSED) self.state = TURRETB_CLOSED;
	if (self.state > TURRETB_COMBAT) self.state = TURRETB_COMBAT;
	// QC hack to make sure spawn delay starts with correct frame
	if (self.state == TURRETB_CLOSED) self.frame = $move1;

	// Sight check parameters
	if (self.waitmin <= 0) self.waitmin = 2;	// Give up timer
	if (self.waitmin2 <= 0) self.waitmin2 = 2;	// Stay hidden timer
	if (self.waitmin3 <= 0) self.waitmin3 = 2;	// Delay start turrets
	if (self.distance <= 0) self.distance = 600;// Attack distance
	if (!(self.spawnflags & MON_SPAWN_DELAY)) self.attack_timer = -1;
	else self.attack_timer = 0;
	
	//----------------------------------------------------------------------
	// The turret can only be setup in two positions, wall or floor/ceiling.
	// The floor/ceiling are treated the same because its just reversed.
	// The wall version uses the 'angle' key to determine its center point
	// and the floor/ceiling uses the weird -1/-2 'angle' setting instead.
	// If the up/down version is detected then the 'angles' key is reset.
	// 
	if (self.angles == '0 -1 0') self.angles = '90 0 0';		// UP
	else if (self.angles == '0 -2 0') self.angles = '270 0 0';	// Down
	else self.angles_x = 0;		// Yaw movement only (wall setup)

	// Due to the way the model is setup for up/down and yaw axis rotation
	// the up/down setups only need to check one axis (X) range and the
	// wall setup requires multiple (XY) ranges instead
	if (self.angles_x > 0) self.volume = FALSE;
	else self.volume = TRUE;
	
	// Make sure angle values (xyz) are in the range of 0-360 otherwise
	// comparisions for XY range will not work if values are negative
	self.angles = vectormod(self.angles);
	// Create the v_ vectors
	makevectors (self.angles);
	self.movedir = v_forward;
	// Save spawning angle for idle movement adjustment
	self.finalangle = self.angles;
	
	// Need to sortout view ofs because the default is expecting
	// the monster to stand/walk/run and not be angled on surfaces
	if (self.volume) self.view_ofs = v_forward*8;
	else self.view_ofs = (-v_forward)*8;

	// Make sure axis lock ranges are 15-90 degree's
	if (self.t_length <= 15) self.t_length = 75;
	if (self.t_length > 90) self.t_length = 90;
	if (self.t_width <= 15) self.t_width = 75;
	if (self.t_width > 90) self.t_width = 90;
	// Setup angle lock boundary adjustment when turret is closed
	if (self.wakeup_angle <= 0) {
		// Ceiling/floor turrets should have less angle
		// They are difficult to get right with default
		if (!self.volume) self.wakeup_angle = TURRETB_WAKEUPDOWN;
		else self.wakeup_angle = TURRETB_WAKEWALL;
	}
	// Check wakeup angle is less that total rotation angle
	if (self.wakeup_angle > (self.t_length - self.wakeup_angle)) 
		self.wakeup_angle = self.t_length - self.wakeup_angle;
	
	// The problem with QC angle maths is when 0 should wrap around to 360
	// This becomes apparent when looking for certain angle ranges (> && <)
	// because you can end up with a range spanning across the 0/360 boundary.
	// The best solution is to move the 0/360 boundary to an angle location
	// where the crossover has no affect on the target range.
	// 
	// The axis lock feature is centered around the spawning angle, which will
	// always be accessible to the turret and never blocked. This angle is the
	// perfect location for the 0/360 boundary because its never tested.
	//
	// The lock range is setup using the new 0/360 location and the ai_run
	// test function converts 'angles' key to that range first before testing.
	// Once the test has finished, then 'angles' key is converted back using
	// the spawn angle as a way to switch between formats.
	//
	// Setup axis lock cone (+/-) around 0/360 boundary
	// The setup cone cannot be more than 90 degree's, the default is 75
	self.anglockx_x = 0 - self.t_length;
	self.anglockx_y = 0 + self.t_length;
	// Z is the original spawn angle (used to move between formats)
	self.anglockx_z = self.angles_x;
	// make sure all parameters are within range 0-360
	self.anglockx = vectormod(self.anglockx);
	
	// Setup axis lock cone (+/-) around 0/360 boundary
	// This is really a duplicate of the X axis, but it can be different
	// for turrets which are setup on walls as they use two axis instead.
	self.anglocky_x = 0 - self.t_width;
	self.anglocky_y = 0 + self.t_width;
	// Z is the original spawn angle (used to move between formats)
	self.anglocky_z = self.angles_y;
	// make sure all parameters are within range 0-360
	self.anglocky = vectormod(self.anglocky);
	
	// Debug makevector arrow directions
	// v_forward reversed for up/down model angles
/*	
	if (self.volume) spawn_arrow(self.origin, vectoangles(v_forward), 0);
		spawn_arrow(self.origin, vectoangles(-v_forward), 0);
	spawn_arrow(self.origin, vectoangles(v_up), 3);
	spawn_arrow(self.origin, vectoangles(v_right), 4);
*/

	//----------------------------------------------------------------------
	// Always reset Ammo Resistance to be consistent
	self.resist_shells = self.resist_nails = 0;
	self.resist_cells = 0;
	self.resist_rockets = -1;	// Double damage from grenades/rockets
	
	self.th_checkattack = TurretbCheckAttack;
	self.th_stand = turretb_stand;
	self.th_walk = turretb_stand;
	self.th_run = turretb_run;
	self.th_missile = turretb_fire;
	self.th_pain = turretb_pain;
	self.th_die = turretb_die;

	self.classtype = CT_MONTURRETB;
	self.classgroup = CG_ROBOT;
	self.classmove = MON_MOVESTATIC;
	
	monster_start();
};
