import duckdb

var db = newDb()
var conn = newConn(db)
conn.sql("CREATE TABLE integers (i INTEGER, j INTEGER);")
conn.sql("INSERT INTO integers VALUES (3, 4), (5, 6), (7, NULL);")
var res = conn.sql("SELECT * FROM integers;")

# iterate until result is exhausted
while true:
  var r:duckdb_data_chunk = duckdb_fetch_chunk(res.handle)

  if r == nil:
    echo "result is exhausted"
    break

  # get the number of rows from the data chunk
  var rowCount = duckdb_data_chunk_get_size(r).int
  echo rowCount

  # get the first column
  var col1:duckdb_vector = duckdb_data_chunk_get_vector(r, 0)
  var col1Data = duckdb_vector_get_data(col1)  #  int32_t *col1_data 
  var col1Validity = duckdb_vector_get_validity(col1)  # uint64_t *

  # get the second column
  var col2 = duckdb_data_chunk_get_vector(r, 1)  # :duckdb_vector 
  var col2Data = duckdb_vector_get_data(col2)  #  int32_t *col1_data 
  var col2Validity = duckdb_vector_get_validity(col2)  # uint64_t *

  # iterate over the rows
  for row in 0..<rowCount:
    if duckdb_validity_row_is_valid(col1Validity, row.uint64):
      #echo "ok"
      var arr = cast[ptr UncheckedArray[int32]](col1Data)
      stdout.write(arr[row])

    else:
      echo "NULL"
      
    stdout.write(",")
    if duckdb_validity_row_is_valid(col2Validity, row.uint64):
      #echo "ok"
      var arr = cast[ptr UncheckedArray[int32]](col2Data)
      stdout.write(arr[row])

      # cast[ptr UncheckedArray[aiMesh]](myPtr)[0]
      #echo cast[int](col1Data + row)
      #echo repr col1Data
    else:
      echo "NULL"   
    echo "" 

  duckdb_destroy_data_chunk(r.addr)
