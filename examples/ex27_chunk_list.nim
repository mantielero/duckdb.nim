import duckdb
import std/options

var db = newDb()
var conn = newConn(db)

# Integers
conn.sql("CREATE TABLE lists (myTinyInt TINYINT[], mySmallInt SMALLINT[]);")
conn.sql("INSERT INTO lists VALUES ([-1], [1]), ([-2,-3], [1,2,3,4]), (NULL, NULL), ([],[]), ([1,NULL,2], [5,6]), ([NULL],[7,NULL,9]);")
var res = conn.sql("SELECT * FROM lists;")

var r = res.toDbResult()
echo "Number of rows: ", r.rows

for i in 0 .. r.colNames.high:
  echo "\nColumn:  name: ", r.colNames[i], "  type: ", r.colTypes[i]
  for i in r.getSeqsInts(i):
    if i.isSome:
      echo i.get
    else:
      echo "NULL"


conn.sql("CREATE TABLE lists2 (myIntegers INTEGER[], myBigInts BIGINT[]);")
conn.sql("INSERT INTO lists2 VALUES ([-1], [1]), ([-2,-3], [1,2,3,4]), (NULL, NULL), ([],[]), ([1,NULL,2], [5,6]), ([NULL],[7,NULL,9]);")
res = conn.sql("SELECT * FROM lists2;")

r = res.toDbResult()
echo "Number of rows: ", r.rows

for i in 0 .. r.colNames.high:
  echo "\nColumn:  name: ", r.colNames[i], "  type: ", r.colTypes[i]
  for i in r.getSeqsInts(i):
    if i.isSome:
      echo i.get
    else:
      echo "NULL"

