/*======================================================================
 Delay Spawning QuickC program by Jim Dose'  10/17/96
 Copyright (c)1996 Hipnotic Interactive, Inc.
 
 * All the functions and defs are self contained in this file
 * Should make it easier to distribute as no other qc file required
 * Collapsed and condensed this QC file as much as possible
 * Renamed all the constants so they don't conflict
 * It was a cool idea for its time (1996) but a horrible solution nowadays
 
//------------------------------------------------------------------------
//QUAKED func_rotate_door (0 .5 .8) (-8 -8 -8) (8 8 8) STAYOPEN
Creates a door that rotates between two positions around a point of
rotation each time it's triggered.

======================================================================*/

// from hipdefs.qc in hipnotic/ritual source qc files
.void() spawnfunction;
.string spawnclassname;
.float  spawnsolidtype;
.string spawnmodel;
.void() spawnthink;
.entity spawnmaster;
.vector spawnmins;
.vector spawnmaxs;
.float  spawnsilent;
.float  spawnmulti;

//======================================================================
/*QUAKED func_spawn (0 .5 .8) (-32 -32 -24) (32 32 64) BIGAMBUSH MEGAHEALTH
This will spawn a thing upon being used
-------- KEYS --------
spawnclassname : Should contain the same value as 'spawnfunction'
spawnfunction  : If unspecified a random monster is chosen
spawnsilent    : set this to 1 if you want a silent spawn
spawnmulti     : set this to 1 if you want this spawn to be reoccuring
angles : Facing direction of spawn
target : Target event of spawn
-------- SPAWNFLAGS --------
BIGAMBUSH  : Spawnflag value to pass on
MEGAHEALTH : Spawnflag value to pass on
-------- NOTES --------
This will spawn a thing upon being used. The thing that
is spawned depends upon the value of spawnfunction
*/
//======================================================================

void() func_spawn =
{
	// Does not work in DM
	if (deathmatch) { remove(self); return; }

	// Cannot trigger this function without a targetname!
	if (self.targetname == "") {
		dprint("\b[FUNC_SPAWN]\b ("); dprint(self.spawnclassname);
		dprint(") - Missing targetname!\n");
		remove(self); 
		return;
	}
	
	// Randomly spawn something, not supported anymore
	if (!self.spawnfunction) {
		dprint("\b[FUNC_SPAWN]\b ("); dprint(self.spawnclassname);
		dprint(") - Random monster not supported!\n");
		remove(self); 
		return;
	}
	
	// Add spawn delay/silent AD flags
	self.spawnflags = self.spawnflags | MON_SPAWN_DELAY;
	if (self.spawnsilent)
		self.spawnflags = self.spawnflags | MON_SPAWN_NOIDLE;
	
	// Switch around classname and setup entity
	self.classname = self.spawnclassname;
	self.spawnfunction();
}

















