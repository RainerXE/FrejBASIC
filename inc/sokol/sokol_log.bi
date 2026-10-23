'' FreeBASIC binding for sokol_log
''
'' Generated with fbfrog from sokol_log.h; do not edit by hand.
'' Pinned source: sokol-odin snapshot 2026-08-31, sokol_log.h
'' sha256 008999c5cd000adf... (full hash in doc/FrejBASIC-sokol-binding-notes.txt)
''
'' Regenerate:
''   fbfrog sokol_log.h -o sokol_log.bi -inclib sokol_log \
''       -fbfroginclude stdbool.h -removeinclude stdbool.h

#pragma once

#inclib "sokol_log"

#include once "crt/stdint.bi"

extern "C"

const SOKOL_LOG_INCLUDED = 1
'' TODO: #define SOKOL_LOG_API_DECL extern
declare sub slog_func(byval tag as const zstring ptr, byval log_level as ulong, byval log_item as ulong, byval message as const zstring ptr, byval line_nr as ulong, byval filename as const zstring ptr, byval user_data as any ptr)

end extern
