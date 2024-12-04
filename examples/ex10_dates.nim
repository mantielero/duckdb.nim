import duckdb
import std/times

var db = newDb()
var conn = newConn(db)

conn.sql("CREATE TABLE dates(i DATE);")
conn.sql("INSERT INTO dates VALUES ('1290-01-01'), ('2024-12-04'), (NULL);") 

var res = conn.sql("SELECT * FROM dates;")
#let tmp = res.toHugeInt(0,1) 

echo res.toDate(0,0).getDateStr()
echo res.toDate(0,1).getDateStr()
echo res.toDate(0,2).getDateStr()

# Timestamps
conn.sql("CREATE TABLE ts(i TIMESTAMP);")
conn.sql("INSERT INTO ts VALUES ('2023-01-01 10:00:00.123456'), ('2023-12-25 15:30:45'), (NULL);") 
res = conn.sql("SELECT * FROM ts;")
echo res.toTimeStamp(0,0)
echo res.toTimeStamp(0,1)
echo res.toTimeStamp(0,2)





