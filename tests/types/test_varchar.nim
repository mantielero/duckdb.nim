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
  test "VARCHAR: string":
    conn.sql("CREATE TABLE integers(i VARCHAR);")
    conn.sql("""INSERT INTO integers VALUES ('Hola'), (NULL);""")  # DuckDBOperationError] for bigger
    let res = conn.sql("SELECT * FROM integers;")

    check( res.toString(0, 0) == "Hola" )
    check( res.toString(0, 1) == "" )



