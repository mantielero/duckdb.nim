import duckdb
import std/options

var db = newDb()
var conn = newConn(db)

# Integers
conn.sql("CREATE TABLE floats(myfloats FLOAT, mydoubles DOUBLE);")
conn.sql("INSERT INTO floats VALUES (-2.3, -2.30000000001), (5.4, 5.40000000001), (NULL, NULL);")  # DuckDBOperationError] for bigger
let res = conn.sql("SELECT * FROM floats;")

var r = res.toDbResult()
echo "Number of rows: ", r.rows

for i in 0 .. r.colNames.high:
  echo "\nColumn:  name: ", r.colNames[i], "  type: ", r.colTypes[i]
  for i in r.getFloats(i):
    if i.isSome:
      echo i.get
    else:
      echo "NULL"

