import duckdb
import std/options

var db = newDb()
var conn = newConn(db)

# Integers
conn.sql("CREATE TYPE colors AS ENUM ('red','green','blue');")
conn.sql("CREATE TABLE colors_table (myColors colors);")
conn.sql("INSERT INTO colors_table VALUES ('red'), ('green'), (NULL), ('blue');")
var res = conn.sql("SELECT * FROM colors_table;")

var r = res.toDbResult()
echo "Number of rows: ", r.rows

for i in 0 .. r.colNames.high:
  echo "\nColumn:  name: ", r.colNames[i], "  type: ", r.colTypes[i]
  for i in r.getEnums(i):
    if i.isSome:
      echo i.get
    else:
      echo "NULL"




