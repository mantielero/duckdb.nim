import ../wrapper/libduckdb
import typs
import std/times


proc toDate*(res:DuckDbResult; col:int = 0; row:int = 0):DateTime =
  let date = duckdb_value_date(res.handle.addr, col.uint64, row.uint64)
  return dateTime(1970, 1.Month,1.MonthdayRange, zone=utc()) + date.days.days


proc toTimeStamp*(res:DuckDbResult; col:int = 0; row:int = 0):DateTime =
  let ts = duckdb_value_timestamp(res.handle.addr, col.uint64, row.uint64)
  return dateTime(1970, 1.Month,1.MonthdayRange, zone=utc()) + ts.micros.microseconds


proc toTime*(res:DuckDbResult; col:int = 0; row:int = 0):Time =
  let t = duckdb_value_time(res.handle.addr, col.uint64, row.uint64)
  return  fromUnixFloat(t.micros.float / 1000000.0 )

proc toInterval*(res:DuckDbResult; col:int = 0; row:int = 0):TimeInterval =
  let interval = duckdb_value_interval(res.handle.addr, col.uint64, row.uint64)
  #return initTimeInterval( 0, interval.micros.int, 0 , 0, 0, 0, 
  #                         interval.days.int, 0, interval.months.int, 0)
  return initTimeInterval( microseconds = interval.micros.int,  
                           days         = interval.days.int, 
                           months       = interval.months.int)  
  #return  interval.months.months + interval.days.days + interval.micros.microseconds #omUnixFloat(t.micros.float / 1000000.0 )

#[
  struct_duckdb_interval* {.pure, inheritable, bycopy.} = object
    months*: int32           ## Generated based on /usr/include/duckdb.h:294:9
    days*: int32
    micros*: int64
]#

#   return dateTime( ts.date.year.int, 
#                    ts.date.month.Month,
#                    ts.date.day.MonthdayRange,
#                    ts.time.hour.HourRange,
#                    ts.time.minute.MinuteRange,
#                    ts.time.second.SecondRange,
#                    (ts.time.micros * 1000).NanosecondRange ) 

#[
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
