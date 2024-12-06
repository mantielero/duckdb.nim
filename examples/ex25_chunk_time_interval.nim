import duckdb
import std/options

var db = newDb()
var conn = newConn(db)

# Integers
conn.sql("CREATE TABLE times (t INTERVAL);")
conn.sql("INSERT INTO times VALUES ('10 seconds'), ('2 hours 30 minutes'), ('1 day 12 hours'), ('3 months 15 days'), (NULL);")
var res = conn.sql("SELECT * FROM times;")

var r = res.toDbResult()
echo "Number of rows: ", r.rows

for i in 0 .. r.colNames.high:
  echo "\nColumn:  name: ", r.colNames[i], "  type: ", r.colTypes[i]
  for i in r.getTimeIntervals(i):
    if i.isSome:
      echo i.get#.format("HH:mm:ss.ffffff",utc())
    else:
      echo "NULL"



