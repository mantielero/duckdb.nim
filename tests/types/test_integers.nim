import std/unittest
import duckdb
#import bigints


# Define un test suite (conjunto de pruebas)
suite "Basic DuckDB testing":

  setup:
    let db = newDb()
    let conn = newConn(db)
  
  #teardown:
  #  echo "run after each test"

  
  # https://duckdb.org/docs/sql/data_types/numeric#integer-types
  test "TINYINT: int8":
    conn.sql("CREATE TABLE integers(i TINYINT);")
    conn.sql("INSERT INTO integers VALUES (-128), (127), (NULL);")  # DuckDBOperationError] for bigger
    let res = conn.sql("SELECT * FROM integers;")

    check( res.toInt8(0, 0) == -128'i8 )
    check( res.toInt8(0, 1) == 127'i8 )
    check( res.toInt8(0, 2) == 0'i8 )   # NULL defaults to 0

    # Autocasting to int64 example
    check( res.toInt64(0, 0) == -128 )
    check( res.toInt64(0, 1) == 127 )
    check( res.toInt64(0, 2) == 0 )   # NULL defaults to 0    

  test "SMALLINT: int16":
    conn.sql("CREATE TABLE integers(i SMALLINT);")
    conn.sql("INSERT INTO integers VALUES (-32768	), (32767), (NULL);")  # DuckDBOperationError] for bigger
    let res = conn.sql("SELECT * FROM integers;")

    check( res.toInt16(0, 0) == -32768'i16 )
    check( res.toInt16(0, 1) == 32767'i16 )
    check( res.toInt16(0, 2) == 0'i16 )   # NULL defaults to 0

  test "INTEGER: int32":
    conn.sql("CREATE TABLE integers(i INTEGER);")
    conn.sql("INSERT INTO integers VALUES (-2147483648	), (2147483647), (NULL);")  # DuckDBOperationError] for bigger
    let res = conn.sql("SELECT * FROM integers;")

    check( res.toInt32(0, 0) == -2147483648'i32 )
    check( res.toInt32(0, 1) == 2147483647'i32 )
    check( res.toInt32(0, 2) == 0'i32 )   # NULL defaults to 0

  test "BIGINT: int64":
    conn.sql("CREATE TABLE integers(i BIGINT);")
    conn.sql("INSERT INTO integers VALUES (-9223372036854775808	), (9223372036854775807), (NULL);")  # DuckDBOperationError] for bigger
    let res = conn.sql("SELECT * FROM integers;")

    check( res.toInt64(0, 0) == -9223372036854775808'i64 )
    check( res.toInt64(0, 1) == 9223372036854775807'i64 )
    check( res.toInt64(0, 2) == 0'i64 )   # NULL defaults to 0


  test "HUGEINT: bigints":
    conn.sql("CREATE TABLE integers(i HUGEINT);")
    conn.sql("INSERT INTO integers VALUES (-170141183460469231731687303715884105728), (170141183460469231731687303715884105727), (NULL);")  # DuckDBOperationError] for bigger
    let res = conn.sql("SELECT * FROM integers;")
    check( $res.toHugeInt(0,0) == "-170141183460469231731687303715884105728" )
    check( $res.toHugeInt(0,1) == "170141183460469231731687303715884105727" )


  test "UTINYINT: uint8":
    conn.sql("CREATE TABLE integers(i UTINYINT);")
    conn.sql("INSERT INTO integers VALUES (0), (255), (NULL);")  # DuckDBOperationError] for bigger
    let res = conn.sql("SELECT * FROM integers;")

    check( res.toUint8(0, 0) == 0'u8 )
    check( res.toUint8(0, 1) == 255'u8 )

  test "USMALLINT: uint16":
    conn.sql("CREATE TABLE integers(i USMALLINT);")
    conn.sql("INSERT INTO integers VALUES (0), (65535), (NULL);")  # DuckDBOperationError] for bigger
    let res = conn.sql("SELECT * FROM integers;")

    check( res.toUint16(0, 0) == 0'u16 )
    check( res.toUint16(0, 1) == 65535'u16 )
    check( res.toUint16(0, 2) == 0'u16 )   # NULL defaults to 0

  test "UINTEGER: uint32":
    conn.sql("CREATE TABLE integers(i UINTEGER);")
    conn.sql("INSERT INTO integers VALUES (0), (4294967295), (NULL);")  # DuckDBOperationError] for bigger
    let res = conn.sql("SELECT * FROM integers;")

    check( res.toUint32(0, 0) == 0'u32 )
    check( res.toUint32(0, 1) == 4294967295'u32 )
    check( res.toUint32(0, 2) == 0'u32 )   # NULL defaults to 0

  test "UBIGINT: uint64":
    conn.sql("CREATE TABLE integers(i UBIGINT);")
    conn.sql("INSERT INTO integers VALUES (0), (18446744073709551615), (NULL);")  # DuckDBOperationError] for bigger
    let res = conn.sql("SELECT * FROM integers;")

    check( res.toUint64(0, 0) == 0'u64 )
    check( res.toUint64(0, 1) == 18446744073709551615'u64 )
    check( res.toUint64(0, 2) == 0'u64 )   # NULL defaults to 0    

  #[ https://github.com/duckdb/duckdb/issues/15012
  test "UHUGEINT: bigints":
    conn.sql("CREATE TABLE integers(i UHUGEINT);")
    conn.sql("INSERT INTO integers VALUES (0), (340282366920938463463374607431768211455), (NULL);")  # DuckDBOperationError] for bigger
    let res = conn.sql("SELECT * FROM integers;")
    check( $res.toUhugeInt(0,0) == "0" )
    check( $res.toUhugeInt(0,1) == "340282366920938463463374607431768211455" )
  ]#