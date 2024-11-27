import duckdb
import std/[options]

var db = newDb()
var conn = newConn(db)
var res = conn.sql("SELECT CASE WHEN i%2=0 THEN NULL ELSE i END res_col FROM range(10) t(i);")

for col in 0..<colCount(res):
  var colName = colName(res, col)  # Nombre de la columna
  var colType = colType(res, col) # Tipo de la columna
  echo colName, " - ", colType

let col = 0
if res.colType(col) == DUCKDB_TYPE_BIGINT:
  for i in res.getItemsAsInt64(col):
    if i.isSome:
      echo i.get()
    else:
      echo "NULL"

