# https://duckdb.org/docs/api/c/connect
import ../wrapper/libduckdb
import typs,errors
import bigints

proc newDb*(path:string = ""):DuckDb =
  ## Creates a new database or opens an existing database file stored at the given path. 
  ## If no path is given a new in-memory database is created instead. The instantiated database should be closed with 'duckdb_close'.
  result = new DuckDb
  var state:DuckDBState
  if path == "":
    state = duckdb_open(nil, result.handle.addr)
  else:
    state = duckdb_open(path.cstring, result.handle.addr)

  if state != DuckDBSuccess:
    raise newException(ValueError, "failed opening the database")

proc newConn*(db:DuckDb):DuckDbConn =
  result = new DuckDbConn
  var state = duckdb_connect(db.handle, result.handle.addr)
  if state != DuckDBSuccess:
    raise newException(ValueError, "failed connecting to the database")  

# var result = duckdb_open(nil, db.addr)
# if (result != DuckDBSuccess):
#   quit( "No se pudo abrir la base de datos", QuitFailure)

proc sql*(conn:DuckDbConn; sql:string): DuckDbResult {.discardable.} =
  result = new DuckDbResult
  var state = duckdb_query(conn.handle, sql.cstring, result.handle.addr)
  if state != DuckDBSuccess:
    let errorMessage = $duckdb_result_error(result.handle.addr) #.duckdbResultError()
    let errorType    = duckdb_result_error_type(result.handle.addr)
    raise newException(DuckDBOperationError,
        "DuckDB operation did not complete sucessfully. Reason:\n" & $errorType & ": " & $errorMessage)
 

#[
proc duckdb_result_error*(result: ptr duckdb_result): cstring {.cdecl,
    importc: "duckdb_result_error".}
proc duckdb_result_error_type*(result: ptr duckdb_result): duckdb_error_type {.
    cdecl, importc: "duckdb_result_error_type".}
]#

# proc exec*(conn:DuckDbConn; sql:string) =
#   var res = duckdb_query(conn.handle, sql.cstring, nil )
#   if res != DuckDBSuccess:
#     raise newException(ValueError, "error querying the database")  



proc rowCount*(res:DuckDbResult):int =
  duckdb_row_count(res.handle.addr).int

proc colCount*(res:DuckDbResult):int =
  #duckdb_row_count(res.handle.addr).int
  duckdb_column_count(res.handle.addr).int


proc colName*(res:DuckDbResult; col:int):string =
  $duckdb_column_name(res.handle.addr, col.uint64) 
#duckdb_column_name(res.handle.addr, col)

proc colType*(res:DuckDbResult; col:int):duckdb_type =
  duckdb_column_type(res.handle.addr, col.uint64)

# Converters

proc toString*(res:DuckDbResult; col:int = 0; row: int = 0):string =
  $duckdb_value_varchar(res.handle.addr, col.uint64, row.uint64)

#[
proc duckdb_value_varchar*(result: ptr duckdb_result; col: idx_t; row: idx_t): cstring {.
    cdecl, importc: "duckdb_value_varchar".}
proc duckdb_value_string*(result: ptr duckdb_result; col: idx_t; row: idx_t): duckdb_string {.
    cdecl, importc: "duckdb_value_string".}

proc duckdb_value_varchar_internal*(result: ptr duckdb_result; col: idx_t;
                                    row: idx_t): cstring {.cdecl,
    importc: "duckdb_value_varchar_internal".}
proc duckdb_value_string_internal*(result: ptr duckdb_result; col: idx_t;
                                   row: idx_t): duckdb_string {.cdecl,
    importc: "duckdb_value_string_internal".}
]#

proc toBool*(res:DuckDbResult; col:int = 0; row:int = 0):bool =
  duckdb_value_boolean(res.handle.addr, col.uint64, row.uint64).bool

proc toInt8*(res:DuckDbResult; col:int = 0; row:int = 0):int8 =
  duckdb_value_int8(res.handle.addr, col.uint64, row.uint64).int8

proc toInt16*(res:DuckDbResult; col:int = 0; row:int = 0):int16 =
  duckdb_value_int16(res.handle.addr, col.uint64, row.uint64).int16

proc toInt32*(res:DuckDbResult; col:int = 0; row:int = 0):int32 =
  duckdb_value_int32(res.handle.addr, col.uint64, row.uint64).int32

proc toInt64*(res:DuckDbResult; col:int = 0; row:int = 0):int64 =
  duckdb_value_int64(res.handle.addr, col.uint64, row.uint64).int64

proc toHugeInt*(res:DuckDbResult; col:int = 0; row:int = 0): BigInt=
  var tmp = duckdb_value_hugeint(res.handle.addr, col.uint64, row.uint64)
  if tmp.upper < 0:
    return initBigInt(tmp.upper).shl(64) - initBigInt(tmp.lower)
  else:
    return initBigInt(tmp.upper).shl(64) + initBigInt(tmp.lower)

proc toUhugeInt*(res:DuckDbResult; col:int = 0; row:int = 0): BigInt=
  var tmp = duckdb_value_uhugeint(res.handle.addr, col.uint64, row.uint64)
  #if tmp.upper < 0:
  return initBigInt(tmp.upper).shl(64) + initBigInt(tmp.lower)
  #else:
  #  return initBigInt(tmp.upper).shl(64) + initBigInt(tmp.lower)


proc toUint8*(res:DuckDbResult; col:int = 0; row:int = 0):uint8 =
  duckdb_value_uint8(res.handle.addr, col.uint64, row.uint64).uint8

proc toUint16*(res:DuckDbResult; col:int = 0; row:int = 0):uint16 =
  duckdb_value_uint16(res.handle.addr, col.uint64, row.uint64).uint16

proc toUint32*(res:DuckDbResult; col:int = 0; row:int = 0):uint32 =
  duckdb_value_uint32(res.handle.addr, col.uint64, row.uint64).uint32

proc toUint64*(res:DuckDbResult; col:int = 0; row:int = 0):uint64 =
  duckdb_value_uint64(res.handle.addr, col.uint64, row.uint64).uint64

proc toFloat32*(res:DuckDbResult; col:int = 0; row:int = 0):float32 =
  duckdb_value_float(res.handle.addr, col.uint64, row.uint64).float32

proc toFloat64*(res:DuckDbResult; col:int = 0; row:int = 0):float64 =
  duckdb_value_double(res.handle.addr, col.uint64, row.uint64).float64

#[

proc duckdb_value_decimal*(result: ptr duckdb_result; col: idx_t; row: idx_t): duckdb_decimal {.
    cdecl, importc: "duckdb_value_decimal".}

proc duckdb_value_date*(result: ptr duckdb_result; col: idx_t; row: idx_t): duckdb_date {.
    cdecl, importc: "duckdb_value_date".}
proc duckdb_value_time*(result: ptr duckdb_result; col: idx_t; row: idx_t): duckdb_time {.
    cdecl, importc: "duckdb_value_time".}
proc duckdb_value_timestamp*(result: ptr duckdb_result; col: idx_t; row: idx_t): duckdb_timestamp {.
    cdecl, importc: "duckdb_value_timestamp".}
proc duckdb_value_interval*(result: ptr duckdb_result; col: idx_t; row: idx_t): duckdb_interval {.
    cdecl, importc: "duckdb_value_interval".}


proc duckdb_value_blob*(result: ptr duckdb_result; col: idx_t; row: idx_t): duckdb_blob {.
    cdecl, importc: "duckdb_value_blob".}
proc duckdb_value_is_null*(result: ptr duckdb_result; col: idx_t; row: idx_t): bool {.
    cdecl, importc: "duckdb_value_is_null".}
]#

