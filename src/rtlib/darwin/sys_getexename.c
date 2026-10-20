/* get the executable's name */

#include <limits.h>
#include <string.h>

#include "../fb.h"
#include "mach-o/dyld.h"

/* _NSGetExecutablePath() fails when the caller's buffer is too small, and the
   window title buffer is only WINDOW_TITLE_SIZE bytes - a program started from
   a long path used to get NULL back here and then crash in strrchr().  Work in
   a PATH_MAX buffer instead and copy out just the base name. */
char *fb_hGetExeName( char *dst, ssize_t maxlen )
{
	char path[PATH_MAX];
	uint32_t len = sizeof(path);
	char *base;
	size_t n;

	if (dst == NULL || maxlen <= 0)
		return NULL;

	if (_NSGetExecutablePath(path, &len) != 0)
		return NULL;
	path[PATH_MAX - 1] = '\0';

	base = strrchr(path, '/');
	base = (base != NULL) ? base + 1 : path;

	/* callers pass a small buffer (the window title) and expect the base
	   name in it, truncated rather than rejected */
	n = strlen(base);
	if (n > (size_t)maxlen - 1)
		n = (size_t)maxlen - 1;
	memcpy(dst, base, n);
	dst[n] = '\0';

	return dst;
}
