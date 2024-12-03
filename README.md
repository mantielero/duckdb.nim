# duckdb.nim
https://duckdb.org/docs/api/c/overview


## Introduction
See the examples.

## Testing
Just run:
```sh
nimble test
```

## Status
- [Connect](https://duckdb.org/docs/api/c/connect): basic
- [Configuration](https://duckdb.org/docs/api/c/config): not started
- [Query](https://duckdb.org/docs/api/c/query): 
- [Types](https://duckdb.org/docs/api/c/types): very few types supported
- [Values](https://duckdb.org/docs/api/c/value): 
- [Data Chunks](https://duckdb.org/docs/api/c/data_chunk): basic support added
- [Vectors](https://duckdb.org/docs/api/c/vector): basic support added
- [Prepared Statements](https://duckdb.org/docs/api/c/prepared): not started. 
- [Table Functions](https://duckdb.org/docs/api/c/table_functions): not started
- [Replacement Scans](https://duckdb.org/docs/api/c/replacement_scans): not started


### ToDo - Data Types
#### [Numeric Types](https://duckdb.org/docs/sql/data_types/numeric.html)
##### [Integer Types](https://duckdb.org/docs/sql/data_types/numeric.html#integer-types)
- [ ] DUCKDB_TYPE_TINYINT: int8
- [ ] DUCKDB_TYPE_SMALLINT: int16
- [ ] DUCKDB_TYPE_INTEGER: int32
- [ ] DUCKDB_TYPE_BIGINT: int64
- [ ] DUCKDB_TYPE_HUGEINT: (import bigint?) int128

- [ ] DUCKDB_TYPE_UTINYINT: uint8
- [ ] DUCKDB_TYPE_USMALLINT: uint16
- [ ] DUCKDB_TYPE_UINTEGER: uint32
- [ ] DUCKDB_TYPE_UBIGINT: uint64
- [ ] DUCKDB_TYPE_UHUGEINT: (import bigint?) int128

##### [Floating Point Types](https://duckdb.org/docs/sql/data_types/numeric.html#floating-point-types)
- [ ] DUCKDB_TYPE_FLOAT
- [ ] DUCKDB_TYPE_DOUBLE

##### [Universally Unique Identifiers (UUIDs)](https://duckdb.org/docs/sql/data_types/numeric.html#universally-unique-identifiers-uuids)
- [ ] DUCKDB_TYPE_UUID


#### Other
- [ ] DUCKDB_TYPE_INVALID
- [ ] DUCKDB_TYPE_BOOLEAN
##### Bit
- [ ] DUCKDB_TYPE_BIT

##### Dates
- [ ] DUCKDB_TYPE_TIMESTAMP
- [ ] DUCKDB_TYPE_DATE
- [ ] DUCKDB_TYPE_TIME
- [ ] DUCKDB_TYPE_INTERVAL

- [ ] DUCKDB_TYPE_TIMESTAMP_S
- [ ] DUCKDB_TYPE_TIMESTAMP_MS
- [ ] DUCKDB_TYPE_TIMESTAMP_NS

- [ ] DUCKDB_TYPE_TIME_TZ
- [ ] DUCKDB_TYPE_TIMESTAMP_TZ

##### String
- [ ] DUCKDB_TYPE_VARCHAR



##### Blob
- [ ] DUCKDB_TYPE_BLOB

##### Decimal?
- [ ] DUCKDB_TYPE_DECIMAL



##### Enum
- [ ] DUCKDB_TYPE_ENUM

##### List
- [ ] DUCKDB_TYPE_LIST

##### Struct
- [ ] DUCKDB_TYPE_STRUCT

##### Map
- [ ] DUCKDB_TYPE_MAP

##### Array
- [ ] DUCKDB_TYPE_ARRAY

##### Union
- [ ] DUCKDB_TYPE_UNION

