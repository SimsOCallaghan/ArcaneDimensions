/*======================================================================
 v_cshift - Quake engine screen flash or colour tint
======================================================================*/

.float		cshift_func;		// 1=Screen flash, 3=artifacts, 5=debuff
.float		cshift_upd;			// Screen updates (v_cshift) are active
.float		cshift_time;		// Timer (0.1s tick) for screen updates
.vector		cshift_col;			// RGB / XYZ values for screen colour
.float		cshift_den;			// Screen colour density
.float		cshift_step;		// Quantity to reduce density by per tick

//----------------------------------------------------------------------
void(entity targ) ResetCShift =
{
	stuffcmd(targ, "v_cshift 0 0 0 0\n");
};
