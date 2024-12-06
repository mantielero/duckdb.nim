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



# Unsigned Integers
conn.sql("CREATE TABLE unsignedintegers (ti UTINYINT, si USMALLINT, i UINTEGER, bi UBIGINT);")
conn.sql("INSERT INTO unsignedintegers VALUES (0, 0, 0, 0), (NULL, NULL, NULL, NULL), (255, 65535, 4294967295, 18446744073709551615), (1,2,3, 4);")
res = conn.sql("SELECT * FROM unsignedintegers;")

r = res.toDbResult()
echo "\n\n\nNumber of rows: ", r.rows

for i in 0 .. r.colNames.high:
  echo "\nColumn:  name: ", r.colNames[i], "  type: ", r.colTypes[i]
  for i in r.getUints(i):
    if i.isSome:
      echo i.get
    else:
      echo "NULL"
