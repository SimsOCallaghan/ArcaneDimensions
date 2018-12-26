/*======================================================================
 TRAP LIGHTNING
======================================================================*/
float LIGHTNING_STARTON = 1;

/*======================================================================
/*QUAKED trap_lightning_start (.5 .5 .8) (-8 -8 -8) (8 8 8) x x x x x x x x
Lightning stream system
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
dmg      : Damage to do for each contact, def=25
wait     : amount of time to remain on def=0.3
delay    : amount of time before next firing
-------- SPAWNFLAGS --------
-------- NOTES --------
Lightning stream system, always starts off

/*QUAKED trap_lightning_relay (.2 .2 .5) (-8 -8 -8) (8 8 8) x x x x x x x x
Lightning stream relay, controlled via start
-------- KEYS --------
-------- SPAWNFLAGS --------
-------- NOTES --------
Lightning stream relay, controlled via start

/*QUAKED trap_lightning_end (.1 .1 .4) (-8 -8 -8) (8 8 8) x x x x x x x x
Lightning stream end, controlled via start
-------- KEYS --------
-------- SPAWNFLAGS --------
-------- NOTES --------
Lightning stream end, controlled via start

======================================================================*/
void() trap_lightning_start = 
{
};

void() trap_lightning_relay = 
{
};

void() trap_lightning_end = 
{
};
