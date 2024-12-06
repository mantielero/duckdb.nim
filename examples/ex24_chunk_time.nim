import duckdb
import std/options

var db = newDb()
var conn = newConn(db)

# Integers
conn.sql("CREATE TABLE times (t TIME);")
conn.sql("INSERT INTO times VALUES ('10:00:00.123456'), ('15:30:45'), (NULL);")
var res = conn.sql("SELECT * FROM times;")

var r = res.toDbResult()
echo "Number of rows: ", r.rows

for i in 0 .. r.colNames.high:
  echo "\nColumn:  name: ", r.colNames[i], "  type: ", r.colTypes[i]
  for i in r.getTimes(i):
    if i.isSome:
      echo i.get.format("HH:mm:ss.ffffff",utc())
    else:
      echo "NULL"



