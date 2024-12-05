import std/[unittest,math]
import duckdb


# Define un test suite (conjunto de pruebas)
suite "Basic DuckDB testing":

  setup:
    let db = newDb()
    let conn = newConn(db)
  
  #teardown:
  #  echo "run after each test"

  
  # https://duckdb.org/docs/sql/data_types/numeric#integer-types
  test "DATE: DateTime":  
    conn.sql("CREATE TABLE dates(i DATE);")
    conn.sql("INSERT INTO dates VALUES ('1920-01-03'), ('2024-12-04'), (NULL);")  # DuckDBOperationError] for bigger
    let res = conn.sql("SELECT * FROM dates;")

    check( res.toDate(0, 0).getDateStr() == "1920-01-03" )
    check( res.toDate(0, 1).getDateStr() == "2024-12-04" )
    check( res.toDate(0, 2).getDateStr() == "1970-01-01" )   # NULL defaults to "1970-01-01"

  test "DATE: DateTime":  
    conn.sql("CREATE TABLE dates(i TIMESTAMP);")
    conn.sql("INSERT INTO dates VALUES ('1920-01-03 12:34:00.123456'), ('2024-12-04 12:34:56.78'), (NULL);")  # DuckDBOperationError] for bigger
    let res = conn.sql("SELECT * FROM dates;")

    check( $res.toTimeStamp(0, 0) == "1920-01-03T12:34:00Z" )
    check( $res.toTimeStamp(0, 1) == "2024-12-04T12:34:56Z" )
    check( $res.toTimeStamp(0, 2) == "1970-01-01T00:00:00Z" )   # NULL defaults to "1970-01-01"

  test "TIME: Time":  
    conn.sql("CREATE TABLE t(i TIME);")
    conn.sql("INSERT INTO t VALUES ('10:00:00.123456'), ('15:30:45'), (NULL);") 
    let res = conn.sql("SELECT * FROM t;")
    check( res.toTime(0,0).format("HH:mm:ss.ffffff",utc()) == "10:00:00.123456" )
    check( res.toTime(0,1).format("HH:mm:ss.ffffff",utc()) == "15:30:45.000000" )
    check( res.toTime(0,2).format("HH:mm:ss.ffffff",utc()) == "00:00:00.000000" )

  test "INTERVAL: TimeInterval":  
    conn.sql("CREATE TABLE intervals(i INTERVAL);")
    conn.sql("INSERT INTO intervals VALUES ('10 seconds'), ('2 hours 30 minutes'), ('1 day 12 hours'), ('3 months 15 days'), (NULL);") 
    let res = conn.sql("SELECT * FROM intervals;")
    check( (res.toInterval(0,0).toParts[Microseconds]/1000_000).int == 10 )
    check( (res.toInterval(0,1) - (2*3600*10^6).microseconds - (30*60*10^6).microseconds).toParts == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    check( res.toInterval(0,2).toParts[Days] == 1) 
    check( (res.toInterval(0,2).toParts[Microseconds]/1000_000/3600).int == 12 )
    check( res.toInterval(0,3).toParts[Days] == 15) 
    check( res.toInterval(0,3).toParts[Months] == 3) 