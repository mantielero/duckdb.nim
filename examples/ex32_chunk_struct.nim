import duckdb
import std/[options,tables]

var db = newDb()
var conn = newConn(db)

# y STRUCT(a BIGINT, b TEXT),

conn.sql("CREATE TABLE items (attributes STRUCT(name VARCHAR, age INTEGER));")
conn.sql("INSERT INTO items VALUES ({'name' : 'Joe', 'age': 10}), ({'name' : 'Anne', 'age': 35}), ({'name' : NULL, 'age': NULL}), (NULL);") # ('hola' : NULL), 
var res = conn.sql("SELECT * FROM items;")

var r = res.toDbResult()
echo "Number of rows: ", r.rows

for i in 0 .. r.colNames.high:
  echo "\nColumn:  name: ", r.colNames[i], "  type: ", r.colTypes[i]
  for i in r.getStructs(i):
    if i.isSome:
      for key,value in i.get.pairs():
        echo key
        if value.isSome:
          let val = value.get
          case val.kind
          of DUCKDB_TYPE_INTEGER:
            echo "  ", val.int32Val
          of DUCKDB_TYPE_VARCHAR:
            echo "  ", val.stringVal  
          else:
            echo "  <NOT MANAGED>"
        else:
          echo "  NULL"
    else:
      echo "NULL"




