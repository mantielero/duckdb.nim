import duckdb
import std/options

var db = newDb()
var conn = newConn(db)

# Integers
conn.sql("CREATE TABLE strings (mystrings VARCHAR);")
conn.sql("INSERT INTO strings VALUES ('H'), ('Hello'), ('This is a much much much longer string'), (NULL);")
var res = conn.sql("SELECT * FROM strings;")

var r = res.toDbResult()
echo "Number of rows: ", r.rows

for i in 0 .. r.colNames.high:
  echo "\nColumn:  name: ", r.colNames[i], "  type: ", r.colTypes[i]
  for i in r.getStrings(i):
    if i.isSome:
      echo i.get
    else:
      echo "NULL"




