import duckdb
import std/[times, math]

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

# Time
conn.sql("CREATE TABLE t(i TIME);")
conn.sql("INSERT INTO t VALUES ('10:00:00.123456'), ('15:30:45'), (NULL);") 
res = conn.sql("SELECT * FROM t;")
echo res.toTime(0,0).format("HH:mm:ss.ffffff",utc())
echo res.toTime(0,1).format("HH:mm:ss.ffffff",utc())
echo res.toTime(0,2).format("HH:mm:ss.ffffff",utc())

# Interval
conn.sql("CREATE TABLE intervals(i INTERVAL);")
conn.sql("INSERT INTO intervals VALUES ('10 seconds'), ('2 hours 30 minutes'), ('1 day 12 hours'), ('3 months 15 days'), (NULL);") 
res = conn.sql("SELECT * FROM intervals;")
echo res.toInterval(0,0)#.toParts
echo res.toInterval(0,1)#.toParts
echo res.toInterval(0,2)#.toParts
echo res.toInterval(0,3)#.toParts
echo res.toInterval(0,0).seconds

echo res.toInterval(0,0).toParts[Microseconds]/1000_000
echo (res.toInterval(0,1) - (2*3600*10^6).microseconds - (30*60*10^6).microseconds).toParts
echo 2.hours.toParts
echo res.toInterval(0,2).toParts[Days] 


# Timestamps
conn.sql("CREATE TABLE tss(i TIMESTAMP_S);")
conn.sql("INSERT INTO tss VALUES ('2023-01-01 10:00:00'), ('1992-09-20 11:30:00.123456'), (NULL);") 
res = conn.sql("SELECT * FROM tss;")
echo res.toTimeStamp(0,0)
echo res.toTimeStamp(0,1)
echo res.toTimeStamp(0,2)