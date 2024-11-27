{.passL:"-lduckdb".}
#{.passL:"-lSDL2 -lm " & wayland & " " & xkbcommon & " -lpthread".}
#{.passL:"-L./lvgl/linux_x64/"}
import duckdb/wrapper/libduckdb
export libduckdb

import duckdb/lib/[version, typs, db, appender,vectors]
export version, typs,db, appender, vectors