{.passL:"-lduckdb".}
#{.passL:"-lSDL2 -lm " & wayland & " " & xkbcommon & " -lpthread".}
#{.passL:"-L./lvgl/linux_x64/"}
import duckdb/wrapper/libduckdb
export libduckdb
import std/times
export times

import bigints
export bigints

import duckdb/lib/[version, typs, db, appender, vectors, dates]
export version, typs,db, appender, vectors, dates

