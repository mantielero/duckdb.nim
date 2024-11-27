import duckdb
import system

var db = newDb()
var conn = newConn(db)
conn.sql("CREATE TABLE integers(i INTEGER, j INTEGER);")
conn.sql("INSERT INTO integers VALUES (3, 4), (5, 6), (7, NULL);")

var res = conn.sql("SELECT * FROM integers;")
var nRows = rowCount(res)
var nCols = colCount(res)


for col in 0..<nCols:
  var colName = colName(res, col)  # Nombre de la columna
  var colType = colType(res, col) # Tipo de la columna

  echo colName, " --> ", colType


for row in 0..<nRows:
  var col1 = res.toInt32(0, row)
  var col2 = res.toInt32(1, row)
  echo col1, " ", col2
