#include "mcgill.h"
/*************************************************************************

             M c G i l l -- S U P E R   D U P E R

               Random number generation package
            -------------------------------------
          G. Marsaglia, K. Ananthanarayanan, N. Paul

         Incorparating the Ziggurat metho of sampling
    from decreasing or symmetric unimodal density functions
                  G. Marsaglia, W. W. Tsang

           Rewritten into C for the AT&T PC 6300 by
                         E. Schneider

*************************************************************************/

#define MULT 69069L

static uint32 mcgn, srgn;

void
rstart(i1, i2)
int32 i1, i2;
{
	mcgn = (i1 == 0) ? 0 : i1 | 1;
	srgn = (i2 == 0) ? 0 : (i2 & 0x7ff) | 1;
}

int32
iuni()
{
	register uint32 r0, r1;

	r0 = (srgn >> 15);
	r1 = srgn ^ r0;
	r0 = (r1 << 17);
	srgn = r0 ^ r1;
	mcgn = MULT * mcgn;
	r1 = mcgn ^ srgn;
	return ((r1 >> 1));
}

int32
ivni()
{
	register uint32 r0, r1;

	r0 = (srgn >> 15);
	r1 = srgn ^ r0;
	r0 = (r1 << 17);
	srgn = r0 ^ r1;
	mcgn = MULT * mcgn;
	r1 = mcgn ^ srgn;
	return (r1);
}

double
uni()
{
	register uint32 r0, r1;

	r0 = (srgn >> 15);
	r1 = srgn ^ r0;
	r0 = (r1 << 17);
	srgn = r0 ^ r1;
	mcgn = MULT * mcgn;
	r1 = mcgn ^ srgn;
	return ((double)(r1 >> 1) / 2147483648.);
}

double
vni()
{
	register uint32 r0, r1;

	r0 = (srgn >> 15);
	r1 = srgn ^ r0;
	r0 = (r1 << 17);
	srgn = r0 ^ r1;
	mcgn = MULT * mcgn;
	r1 = mcgn ^ srgn;
	return ((double)(r1) / 2147483648.);
}
