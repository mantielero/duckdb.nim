# https://github.com/ayman-albaz/nim-duckdb/blob/master/src/duckdb.nim
import ../wrapper/libduckdb
import typs

type
  #DuckDBState* = duckdb_state
  DuckDBBaseError* = object of CatchableError
  DuckDBOperationError* = object of DuckDBBaseError

#proc isSuccessful*(state:DuckDbState):bool =
  

proc checkStateSuccessful(state: DuckDBState) =
  if state != DuckDBSuccess:
    raise newException(DuckDBOperationError, "DuckDB operation did not complete sucessfully.")

#[

proc duckdb_result_error*(result: ptr duckdb_result): cstring {.cdecl,
    importc: "duckdb_result_error".}

proc duckdb_result_error_type*(result: ptr duckdb_result): duckdb_error_type {.
    cdecl, importc: "duckdb_result_error_type".}
]#



#[
type
  enum_duckdb_error_type* {.size: sizeof(cuint).} = enum
    DUCKDB_ERROR_INVALID = 0, 
    DUCKDB_ERROR_OUT_OF_RANGE = 1,
    DUCKDB_ERROR_CONVERSION = 2, 
    DUCKDB_ERROR_UNKNOWN_TYPE = 3,
    DUCKDB_ERROR_DECIMAL = 4, 
    DUCKDB_ERROR_MISMATCH_TYPE = 5,
    DUCKDB_ERROR_DIVIDE_BY_ZERO = 6, 
    DUCKDB_ERROR_OBJECT_SIZE = 7,
    DUCKDB_ERROR_INVALID_TYPE = 8, 
    DUCKDB_ERROR_SERIALIZATION = 9,
    DUCKDB_ERROR_TRANSACTION = 10, 
    DUCKDB_ERROR_NOT_IMPLEMENTED = 11,
    DUCKDB_ERROR_EXPRESSION = 12, 
    DUCKDB_ERROR_CATALOG = 13,
    DUCKDB_ERROR_PARSER = 14, 
    DUCKDB_ERROR_PLANNER = 15,
    DUCKDB_ERROR_SCHEDULER = 16, 
    DUCKDB_ERROR_EXECUTOR = 17,
    DUCKDB_ERROR_CONSTRAINT = 18, 
    DUCKDB_ERROR_INDEX = 19,
    DUCKDB_ERROR_STAT = 20, 
    DUCKDB_ERROR_CONNECTION = 21,
    DUCKDB_ERROR_SYNTAX = 22, 
    DUCKDB_ERROR_SETTINGS = 23,
    DUCKDB_ERROR_BINDER = 24, 
    DUCKDB_ERROR_NETWORK = 25,
    DUCKDB_ERROR_OPTIMIZER = 26, 
    DUCKDB_ERROR_NULL_POINTER = 27,
    DUCKDB_ERROR_IO = 28, 
    DUCKDB_ERROR_INTERRUPT = 29, 
    DUCKDB_ERROR_FATAL = 30,
    DUCKDB_ERROR_INTERNAL = 31, 
    DUCKDB_ERROR_INVALID_INPUT = 32,
    DUCKDB_ERROR_OUT_OF_MEMORY = 33, 
    DUCKDB_ERROR_PERMISSION = 34,
    DUCKDB_ERROR_PARAMETER_NOT_RESOLVED = 35,
    DUCKDB_ERROR_PARAMETER_NOT_ALLOWED = 36, 
    DUCKDB_ERROR_DEPENDENCY = 37,
    DUCKDB_ERROR_HTTP = 38, 
    DUCKDB_ERROR_MISSING_EXTENSION = 39,
    DUCKDB_ERROR_AUTOLOAD = 40, 
    DUCKDB_ERROR_SEQUENCE = 41,
    DUCKDB_INVALID_CONFIGURATION = 42
]#

#[

proc checkStateSuccessful(state: DuckDBState, result: DuckDBResult) =
  if not isStateSuccessful(state):
    let errorMessage = result.result.addr.duckdbResultError()
    raise newException(DuckDBOperationError,
        "DuckDB operation did not complete sucessfully. Reason:\n" & $errorMessage)

proc checkStateSuccessful(state: DuckDBState,
    statement: DuckDBPreparedStatement) =
  if not isStateSuccessful(state):
    let errorMessage = statement.statement.duckdbPrepareError()
    raise newException(DuckDBOperationError,
        "DuckDB operation did not complete sucessfully. Reason:\n" & $errorMessage)

proc checkStateSuccessful(state: DuckDBState, appender: DuckDBAppender) =
  if not isStateSuccessful(state):
    let errorMessage = appender.appender.duckdbAppenderError()
    raise newException(DuckDBOperationError,
]#