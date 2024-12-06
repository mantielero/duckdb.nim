import duckdb
import std/options

var db = newDb()
var conn = newConn(db)

# Integers
conn.sql("CREATE TABLE integers (ti TINYINT, si SMALLINT, i INTEGER, bi BIGINT);")
conn.sql("INSERT INTO integers VALUES (-128, -32768, -2147483648, -9223372036854775808), (NULL, NULL, 2147483647, 9223372036854775807), (127, 32767, NULL, NULL), (-10,-3,9, -100), (3, 8,11, 200);")
var res = conn.sql("SELECT * FROM integers;")

var r = res.toDbResult()
echo "Number of rows: ", r.rows

for i in 0 .. r.colNames.high:
  echo "\nColumn:  name: ", r.colNames[i], "  type: ", r.colTypes[i]
  for i in r.getInts(i):
    if i.isSome:
      echo i.get
    else:
      echo "NULL"



# Integer
# conn.sql("CREATE TABLE integers (i INTEGER, j INTEGER);")
# conn.sql("INSERT INTO integers VALUES (3, 4), (5, 6), (7, NULL), (8,9), (100,11);")
# var res = conn.sql("SELECT * FROM integers;")

# var r = res.toDbResult()
# echo "Number of rows: ", r.rows

# echo "\nColumn:  name: ", r.colNames[0], "  type: ", r.colTypes[0]
# for i in r.getInts(0):
#   if i.isSome:
#     echo i.get
#   else:
#     echo "NULL"

# echo "\nColumn:  name: ", r.colNames[1], "  type: ", r.colTypes[1]
# for i in r.getInts(1):
#   if i.isSome:
#     echo i.get
#   else:
#     echo "NULL"
