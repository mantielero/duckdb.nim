import std/unittest
import duckdb
#import bigints


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