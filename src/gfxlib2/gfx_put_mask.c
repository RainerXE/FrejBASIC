/* MASK drawing method for PUT statement */

#include "fb_gfx.h"

/* Not thread-safe; putters should only be called from other gfx functions that
   take care of the synchronization */
void fb_hPutMask(unsigned char *src, unsigned char *dest, int w, int h, int src_pitch, int dest_pitch, int alpha, BLENDER *blender, void *param)
{
	PUT_HEADER *mask_header;
	unsigned char *mask_data;
	unsigned int *s, *d, *m;
	unsigned int sc, dc, mc;
	int mask_pitch, mask_bpp, x;

	mask_header = (PUT_HEADER *)param;
	if (!mask_header) {
		return;
	}

	if (mask_header->type == PUT_HEADER_NEW) {
		mask_bpp   = mask_header->bpp;
		mask_pitch = mask_header->pitch;
		mask_data  = (unsigned char *)mask_header + sizeof(PUT_HEADER);
	} else {
		mask_bpp = mask_header->old.bpp;
		if (!mask_bpp) mask_bpp = 4;
		mask_pitch = mask_header->old.width * mask_bpp;
		mask_data  = (unsigned char *)mask_header + 4;
	}

	if (mask_bpp != 4) {
		return;   /* 32 bpp only in this version */
	}

	s = (unsigned int *)src;
	m = (unsigned int *)mask_data;
	src_pitch = (src_pitch >> 2) - w;
	for (; h; h--) {
		d = (unsigned int *)dest;
		for (x = w; x; x--) {
			sc = *s++;
			dc = *d;
			mc = *m++;
			if ((mc >> 24) == 0) {
				/* skip: leave dest untouched */
			} else if ((mc >> 24) == 255) {
				*d = sc;
			} else {
				unsigned int a = (mc >> 24) + 1;
				unsigned int srb, sga, drb, dga;
				srb = sc & MASK_RB_32;
				sga = sc & MASK_GA_32;
				drb = dc & MASK_RB_32;
				dga = dc & MASK_GA_32;
				srb = ((srb - drb) * a) >> 8;
				sga = ((sga >> 8) - (dga >> 8)) * a;
				*d = ((drb + srb) & MASK_RB_32) | ((dga + sga) & MASK_GA_32);
			}
			d++;
		}
		s += src_pitch;
		m += (mask_pitch >> 2) - w;
		dest += dest_pitch;
	}
}
