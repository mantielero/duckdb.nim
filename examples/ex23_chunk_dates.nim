import duckdb
import std/options

var db = newDb()
var conn = newConn(db)

# Integers
conn.sql("CREATE TABLE dt (dates DATE, ts TIMESTAMP);")
conn.sql("INSERT INTO dt VALUES ('1920-01-03', '1920-01-03 12:34:00.123456'), ('2024-12-04', '2024-12-04 12:34:56.78'), (NULL, NULL);")
var res = conn.sql("SELECT * FROM dt;")

var r = res.toDbResult()
echo "Number of rows: ", r.rows

for i in 0 .. r.colNames.high:
  echo "\nColumn:  name: ", r.colNames[i], "  type: ", r.colTypes[i]
  for i in r.getDates(i):
    if i.isSome:
      echo i.get
    else:
      echo "NULL"



