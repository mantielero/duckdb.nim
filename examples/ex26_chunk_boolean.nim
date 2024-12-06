import duckdb
import std/options

var db = newDb()
var conn = newConn(db)

# Integers
conn.sql("CREATE TABLE booleans (booleans BOOLEAN);")
conn.sql("INSERT INTO booleans VALUES (FALSE), (TRUE), (NULL);;")
var res = conn.sql("SELECT * FROM booleans;")

var r = res.toDbResult()
echo "Number of rows: ", r.rows

for i in 0 .. r.colNames.high:
  echo "\nColumn:  name: ", r.colNames[i], "  type: ", r.colTypes[i]
  for i in r.getBooleans(i):
    if i.isSome:
      echo i.get
    else:
      echo "NULL"




