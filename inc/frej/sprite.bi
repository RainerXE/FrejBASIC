'' frej/sprite.bi - masked sprite blit, in the spirit of GFA-BASIC 3.5
''
'' GFA moved screen blocks with GET and PUT, and transparency was done with a
'' mask: AND the mask, then OR the image.  The same idea here is one call:
''
''     #include once "frej/sprite.bi"
''
''     PutMask x, y, sprite, mask
''
'' sprite and mask must be the same size and 32 bits per pixel; the mask's
'' alpha byte is the blend factor - 0 keeps the destination, 255 copies the
'' source, anything in between blends.  The mask's colour is ignored, so a
'' mask can be drawn as a greyscale image or as an alpha channel.
''
'' Copyright (c) 2026 the FrejBASIC contributors
'' Distributed under the same terms as the FreeBASIC runtime library.

#ifndef __FREJ_SPRITE_BI__
#define __FREJ_SPRITE_BI__

#pragma once

'' PutMask errors are reported through the normal runtime error mechanism so
'' that a program compiled with -exx gets the line number, and a program
'' compiled without -exx simply stops.
const FREJ_SPRITE_OK = 0

'' Error codes we raise.  5 = illegal function call, the conventional FB
'' code for "this combination is not supported".
const FREJ_SPRITE_ERR = 5

'' -------------------------------------------------------------- PutMask --

'' Blit img onto the screen at (x, y), using mask as the alpha channel.
'' Both images must be 32 bpp and the same size; the screen must be 32 bpp.
sub PutMask(byval x as integer, byval y as integer, _
            byval img as any ptr, byval mask as any ptr)

    if img = 0 or mask = 0 then error FREJ_SPRITE_ERR : exit sub

    '' image geometry
    dim as long iw, ih, ibpp, ipitch
    dim as any ptr idata
    dim as long idummy
    imageinfo img, iw, ih, ibpp, ipitch, idata, idummy
    if iw <= 0 or ih <= 0 or idata = 0 or ibpp <> 4 then error FREJ_SPRITE_ERR : exit sub

    dim as long mw, mh, mbpp, mpitch
    dim as any ptr mdata
    dim as long mdummy
    imageinfo mask, mw, mh, mbpp, mpitch, mdata, mdummy
    if mw <= 0 or mh <= 0 or mdata = 0 or mbpp <> 4 then error FREJ_SPRITE_ERR : exit sub
    if mw <> iw or mh <> ih then error FREJ_SPRITE_ERR : exit sub

    '' screen geometry
    dim as long sw, sh, sdepth, sbpp, spitch
    screeninfo sw, sh, sdepth, sbpp, spitch
    if sw <= 0 or sh <= 0 or sdepth <> 32 or sbpp <> 4 then error FREJ_SPRITE_ERR : exit sub

    dim as any ptr sptr = screenptr()
    if sptr = 0 then error FREJ_SPRITE_ERR : exit sub

    '' clipped rectangle, in source coordinates
    dim as integer dx0 = 0, dy0 = 0, dx1 = iw, dy1 = ih
    if x < 0 then dx0 = -x
    if y < 0 then dy0 = -y
    if x + iw > sw then dx1 = sw - x
    if y + ih > sh then dy1 = sh - y
    if dx0 >= dx1 or dy0 >= dy1 then exit sub

    '' stride in ULongs (4 bytes per pixel at 32 bpp)
    dim as integer src_stride = ipitch \ 4
    dim as integer msk_stride = mpitch \ 4
    dim as integer dst_stride = spitch \ 4

    dim as ulong ptr src_row = cast(ulong ptr, idata)
    dim as ulong ptr msk_row = cast(ulong ptr, mdata)
    dim as ulong ptr dst_row = cast(ulong ptr, sptr)

    dim as integer dx, dy
    for dy = dy0 to dy1 - 1
        dim as ulong ptr s = src_row + (dy * src_stride) + dx0
        dim as ulong ptr m = msk_row + (dy * msk_stride) + dx0
        dim as ulong ptr d = dst_row + ((y + dy) * dst_stride) + (x + dx0)
        for dx = 0 to (dx1 - dx0) - 1
            dim as ulong ma = (*m and &hFF000000) shr 24
            if ma > 0 then
                if ma = 255 then
                    *d = *s
                else
                    dim as ulong sa = *s, da = *d
                    dim as integer sr = (sa shr 16) and &hFF
                    dim as integer sg = (sa shr 8)  and &hFF
                    dim as integer sb = sa and &hFF
                    dim as integer dr = (da shr 16) and &hFF
                    dim as integer dg = (da shr 8)  and &hFF
                    dim as integer db = da and &hFF
                    '' blend: dest = dest + (source - dest) * ma / 255
                    dim as integer nr = dr + (sr - dr) * ma \ 255
                    dim as integer ng = dg + (sg - dg) * ma \ 255
                    dim as integer nb = db + (sb - db) * ma \ 255
                    *d = (&hFF shl 24) or (nr shl 16) or (ng shl 8) or nb
                end if
            end if
            s += 1 : m += 1 : d += 1
        next
    next
end sub

#endif '' __FREJ_SPRITE_BI__
