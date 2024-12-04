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
  test "FLOAT: float32":  # 4 bytes
    conn.sql("CREATE TABLE integers(i FLOAT);")
    conn.sql("INSERT INTO integers VALUES (-2.3), (5.4), (NULL);")  # DuckDBOperationError] for bigger
    let res = conn.sql("SELECT * FROM integers;")

    check( res.toFloat32(0, 0) == -2.3'f32 )
    check( res.toFloat32(0, 1) == 5.4'f32 )
    check( res.toFloat32(0, 2) == 0.0'f32 )   # NULL defaults to 0

  test "DOUBLE: float64":  # 4 bytes
    conn.sql("CREATE TABLE integers(i DOUBLE);")
    conn.sql("INSERT INTO integers VALUES (-2.30000000001), (5.40000000001), (NULL);")  # DuckDBOperationError] for bigger
    let res = conn.sql("SELECT * FROM integers;")

    check( res.toFloat64(0, 0) == -2.30000000001'f64 )
    check( res.toFloat64(0, 1) == 5.40000000001'f64 )
    check( res.toFloat64(0, 2) == 0.0'f64 )   # NULL defaults to 0
