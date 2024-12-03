import duckdb
import bigints

var db = newDb()
var conn = newConn(db)
#var res = conn.sql("SELECT CASE WHEN i%2=0 THEN NULL ELSE i END res_col FROM range(10) t(i);")
conn.sql("CREATE TABLE integers(i HUGEINT);")
conn.sql("INSERT INTO integers VALUES (-170141183460469231731687303715884105728), (170141183460469231731687303715884105727), (-20);") 

let res = conn.sql("SELECT * FROM integers;")
#let tmp = res.toHugeInt(0,1) 

var tmp = res.toHugeInt2(0,1)
echo repr tmp
var upper = initBigInt(tmp.upper)
var lower = initBigInt(tmp.lower)

var val = upper.shl(64) + lower
echo $val  # 170141183460469231713240559642174554112

tmp = res.toHugeInt2(0,0)
echo repr tmp
upper = initBigInt(tmp.upper)
lower = initBigInt(tmp.lower)

val = upper.shl(64) - lower
echo $val  # 170141183460469231713240559642174554112

echo $res.toHugeInt(0,0)
echo $res.toHugeInt(0,1)
