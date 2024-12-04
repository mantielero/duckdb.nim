import ../wrapper/libduckdb
import typs
import std/times


proc toDate*(res:DuckDbResult; col:int = 0; row:int = 0):DateTime =
  let date = duckdb_value_date(res.handle.addr, col.uint64, row.uint64)
  return dateTime(1970, 1.Month,1.MonthdayRange, zone=utc()) + date.days.days


proc toTimeStamp*(res:DuckDbResult; col:int = 0; row:int = 0):DateTime =
  let ts = duckdb_value_timestamp(res.handle.addr, col.uint64, row.uint64)
  return dateTime(1970, 1.Month,1.MonthdayRange, zone=utc()) + ts.micros.microseconds
#   return dateTime( ts.date.year.int, 
#                    ts.date.month.Month,
#                    ts.date.day.MonthdayRange,
#                    ts.time.hour.HourRange,
#                    ts.time.minute.MinuteRange,
#                    ts.time.second.SecondRange,
#                    (ts.time.micros * 1000).NanosecondRange ) 

#[

proc duckdb_value_time*(result: ptr duckdb_result; col: idx_t; row: idx_t): duckdb_time {.
    cdecl, importc: "duckdb_value_time".}

proc duckdb_value_interval*(result: ptr duckdb_result; col: idx_t; row: idx_t): duckdb_interval {.
    cdecl, importc: "duckdb_value_interval".}


  duckdb_date* = struct_duckdb_date ## Generated based on /usr/include/duckdb.h:257:3
  struct_duckdb_date_struct* {.pure, inheritable, bycopy.} = object
    year*: int32             ## Generated based on /usr/include/duckdb.h:258:9
    month*: int8
    day*: int8


]#


#[
epoch	1970-01-01 (Unix system day zero)
infinity	later than all other dates
-infinity	earlier than all other dates
]#
