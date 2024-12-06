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
- [X] TINYINT: int8
- [X] SMALLINT: int16
- [X] INTEGER: int32
- [X] BIGINT: int64
- [X] HUGEINT: BigInt

- [X] UTINYINT: uint8
- [X] USMALLINT: uint16
- [X] UINTEGER: uint32
- [X] UBIGINT: uint64
- [X] UHUGEINT: BigInt [pending issue](https://github.com/duckdb/duckdb/issues/15012)

##### [Floating Point Types](https://duckdb.org/docs/sql/data_types/numeric.html#floating-point-types)
- [X] FLOAT
- [X] DOUBLE

##### Decimal - fixed point
- [ ] DECIMAL: see [fixed_point.nim](https://gist.github.com/planetis-m/c13529cac44b4a9de3f073de502315ee)

##### [Universally Unique Identifiers (UUIDs)](https://duckdb.org/docs/sql/data_types/numeric.html#universally-unique-identifiers-uuids)
- [ ] UUID


#### Other
- [ ] INVALID
- [X] BOOLEAN

##### Bit
- [ ] BIT

##### Dates
- [X] TIMESTAMP
- [X] DATE
- [X] TIME
- [X] INTERVAL

- [ ] TIMESTAMP_S
- [ ] TIMESTAMP_MS
- [ ] TIMESTAMP_NS

- [ ] TIME_TZ
- [ ] TIMESTAMP_TZ

#### String
- [X] VARCHAR


#### Blob
- [ ] BLOB


#### Enum
- [ ] ENUM
  - [X] UTINYINT: probably sufficient for most of the cases

#### List
- [ ] LIST: Variable length sequence with a fixed type:
  - [X] TINYINT
  - [X] SMALLINT
  - [X] INTEGER
  - [X] BIGINT
  - [ ] UTINYINT
  - [ ] USMALLINT
  - [ ] UINTEGER
  - [ ] UBIGINT
  - [ ] FLOAT
  - [ ] DOUBLE
  - [ ] VARCHAR
  - [ ] ... 
#### Array
- [ ] ARRAY: fixed length sequence with a fixed type:
  - [X] TINYINT
  - [X] SMALLINT
  - [X] INTEGER
  - [X] BIGINT
  - [ ] UTINYINT
  - [ ] USMALLINT
  - [ ] UINTEGER
  - [ ] UBIGINT
  - [ ] FLOAT
  - [ ] DOUBLE
  - [ ] VARCHAR
  - [ ] ... 

#### Struct
- [ ] STRUCT

#### Map
- [ ] MAP


#### Union
- [ ] UNION

