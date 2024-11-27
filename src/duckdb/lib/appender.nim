# https://duckdb.org/docs/api/c/appender.html
import ../wrapper/libduckdb
import typs, errors

type
  DuckDbAppenderObj* = object
    handle*: duckdb_appender
  DuckDbAppender* = ref DuckDbAppenderObj

proc `=destroy`*(self:DuckDbAppenderObj) =
  if self.handle.addr != nil:
    let state = duckdb_appender_destroy(self.handle.addr)
    if state != DuckDBSuccess:
      raise newException(DuckDBOperationError, "DuckDB operation -destroy- did not complete sucessfully.")

proc newAppender*(conn:DuckDbConn; table:string): DuckDbAppender =
  result = new DuckDbAppender
  let state = duckdb_appender_create(conn.handle, 
                                     cast[cstring](nil), 
                                     table.cstring, 
                                     result.handle.addr)
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -newAppender- did not complete sucessfully.")

#[
proc duckdb_appender_create*(connection: duckdb_connection; schema: cstring;
                             table: cstring; out_appender: ptr duckdb_appender): duckdb_state {.
    cdecl, importc: "duckdb_appender_create".}
]#

proc endRow*(app:DuckDbAppender) =
  let state = duckdb_appender_end_row(app.handle)
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -endRow- did not complete sucessfully.")

proc flush*(app:DuckDbAppender) =
  let state = duckdb_appender_flush(app.handle)
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -flush- did not complete sucessfully.")


proc close*(app:DuckDbAppender) =
  let state = duckdb_appender_close(app.handle)
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -close- did not complete sucessfully.")


#[

proc duckdb_appender_column_count*(appender: duckdb_appender): idx_t {.cdecl,
    importc: "duckdb_appender_column_count".}
proc duckdb_appender_column_type*(appender: duckdb_appender; col_idx: idx_t): duckdb_logical_type {.
    cdecl, importc: "duckdb_appender_column_type".}
proc duckdb_appender_error*(appender: duckdb_appender): cstring {.cdecl,
    importc: "duckdb_appender_error".}

proc duckdb_appender_begin_row*(appender: duckdb_appender): duckdb_state {.
    cdecl, importc: "duckdb_appender_begin_row".}

]#

proc append*(appender:DuckDbAppender; value:bool) =
  let state = duckdb_append_bool(appender.handle, value )
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -int8- did not complete sucessfully.")


proc append*(appender:DuckDbAppender; value:int8) =
  let state = duckdb_append_int8(appender.handle, value )
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -int8- did not complete sucessfully.")

proc append*(appender:DuckDbAppender; value:int16) =
  let state = duckdb_append_int16(appender.handle, value )
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -int16- did not complete sucessfully.")


proc append*(appender:DuckDbAppender; value:int32) =
  let state = duckdb_append_int32(appender.handle, value )
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -int32- did not complete sucessfully.")

proc append*(appender:DuckDbAppender; value:int64) =
  let state = duckdb_append_int64(appender.handle, value )
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -int64- did not complete sucessfully.")

proc append*(appender:DuckDbAppender; value:uint8) =
  let state = duckdb_append_uint8(appender.handle, value )
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -uint8- did not complete sucessfully.")

proc append*(appender:DuckDbAppender; value:uint16) =
  let state = duckdb_append_uint16(appender.handle, value )
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -uint16- did not complete sucessfully.")


proc append*(appender:DuckDbAppender; value:uint32) =
  let state = duckdb_append_uint32(appender.handle, value )
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -uint32- did not complete sucessfully.")

proc append*(appender:DuckDbAppender; value:uint64) =
  let state = duckdb_append_uint64(appender.handle, value )
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -uint64- did not complete sucessfully.")


proc append*(appender:DuckDbAppender; value:float64) =
  let state = duckdb_append_double(appender.handle, value )
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -float64- did not complete sucessfully.")

proc append*(appender:DuckDbAppender; value:float32) =
  let state = duckdb_append_float(appender.handle, value )
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -float32- did not complete sucessfully.")

proc append*(appender:DuckDbAppender; value:string) =
  let state = duckdb_append_varchar(appender.handle, value.cstring )
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -string- did not complete sucessfully.")


proc append*(appender:DuckDbAppender) =
  let state = duckdb_append_null(appender.handle)
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation -null- did not complete sucessfully.")



#[
proc duckdb_append_default*(appender: duckdb_appender): duckdb_state {.cdecl,
    importc: "duckdb_append_default".}



proc duckdb_append_hugeint*(appender: duckdb_appender; value: duckdb_hugeint): duckdb_state {.
    cdecl, importc: "duckdb_append_hugeint".}

proc duckdb_append_uhugeint*(appender: duckdb_appender; value: duckdb_uhugeint): duckdb_state {.
    cdecl, importc: "duckdb_append_uhugeint".}

proc duckdb_append_date*(appender: duckdb_appender; value: duckdb_date): duckdb_state {.
    cdecl, importc: "duckdb_append_date".}
proc duckdb_append_time*(appender: duckdb_appender; value: duckdb_time): duckdb_state {.
    cdecl, importc: "duckdb_append_time".}
proc duckdb_append_timestamp*(appender: duckdb_appender; value: duckdb_timestamp): duckdb_state {.
    cdecl, importc: "duckdb_append_timestamp".}
proc duckdb_append_interval*(appender: duckdb_appender; value: duckdb_interval): duckdb_state {.
    cdecl, importc: "duckdb_append_interval".}

proc duckdb_append_varchar_length*(appender: duckdb_appender; val: cstring;
                                   length: idx_t): duckdb_state {.cdecl,
    importc: "duckdb_append_varchar_length".}
proc duckdb_append_blob*(appender: duckdb_appender; data: pointer; length: idx_t): duckdb_state {.
    cdecl, importc: "duckdb_append_blob".}

proc duckdb_append_data_chunk*(appender: duckdb_appender;
                               chunk: duckdb_data_chunk): duckdb_state {.cdecl,
    importc: "duckdb_append_data_chunk".}
]#