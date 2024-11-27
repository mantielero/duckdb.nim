import ../wrapper/libduckdb

# Version
proc version*():string =
  $duckdb_library_version()