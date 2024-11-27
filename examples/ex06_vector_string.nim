import duckdb
import std/[options]

var db = newDb()
var conn = newConn(db)
var res = conn.sql("SELECT CASE WHEN i%2=0 THEN CONCAT('short_', i) ELSE CONCAT('longstringprefix', i) END FROM range(10) t(i)")

for col in 0..<colCount(res):
  var colName = colName(res, col)  # Nombre de la columna
  var colType = colType(res, col) # Tipo de la columna
  echo colName, " - ", colType

let col = 0
#echo res.colType(col)
if res.colType(col) == DUCKDB_TYPE_VARCHAR:
  for i in res.getItemsAsString(col):
    if i.isSome:
      echo i.get()
    else:
      echo "NULL"
