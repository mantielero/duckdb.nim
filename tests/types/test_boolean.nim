import std/unittest
import duckdb


# Define un test suite (conjunto de pruebas)
suite "Basic DuckDB testing":

  setup:
    let db = newDb()
    let conn = newConn(db)
  
  #teardown:
  #  echo "run after each test"

  
  # https://duckdb.org/docs/sql/data_types/numeric#integer-types
  test "BOOLEAN: bool":
    conn.sql("CREATE TABLE integers(i BOOLEAN);")
    conn.sql("INSERT INTO integers VALUES (FALSE), (TRUE), (NULL);")  # DuckDBOperationError] for bigger
    let res = conn.sql("SELECT * FROM integers;")

    check( res.toBool(0, 0) == false )
    check( res.toBool(0, 1) == true )
    check( res.toBool(0, 2) == false )   # NULL defaults to false


