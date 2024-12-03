import std/unittest
import duckdb

# Define un test suite (conjunto de pruebas)
suite "Basic DuckDB testing":

  setup:
    let db = newDb()
    let conn = newConn(db)
  
  #teardown:
  #  echo "run after each test"

  test "SELECT 'Hola, DuckDB!' AS mensaje;":
    var result = conn.sql("SELECT 'Hola, DuckDB!' AS mensaje;")
    check(result.toString() == "Hola, DuckDB!")
  
  test "Insert values":
    conn.sql("CREATE TABLE integers(i INTEGER, j INTEGER);")
    conn.sql("INSERT INTO integers VALUES (3, 4), (5, 6), (7, NULL);")
    let res = conn.sql("SELECT * FROM integers;")
    let nRows = rowCount(res)
    let nCols = colCount(res)
    check( nCols == 2 )
    check( nRows == 3 )
    check( colName(res, 0) == "i" )
    check( colName(res, 1) == "j" )
    check( colType(res,0)  == DUCKDB_TYPE_INTEGER)
    check( res.toInt32(0, 0) == 3 ) # row,col
    check( res.toInt32(1, 0) == 4 )

  test "Appender":
    conn.sql("CREATE TABLE users(id INTEGER, name VARCHAR, age INTEGER);")
    let app = conn.newAppender("users")
    app.append(1i32)
    app.append("Mark")
    app.append(25i32)
    app.endRow()

    app.flush()

    let res = conn.sql("SELECT * FROM users;")
    check( res.toInt32(0, 0)  == 1i32 )
    check( res.toString(1, 0) == "Mark" )
    check( res.toInt32(2, 0)  == 25i32 )
    