import duckdb
import std/[options]

var db = newDb()
var conn = newConn(db)
var res = conn.sql("SELECT CASE WHEN i%5=0 THEN NULL ELSE {'col1': i, 'col2': CASE WHEN i%2=0 THEN NULL ELSE 100 + i * 42 END} END FROM range(10) t(i)")

for col in 0..<colCount(res):
  var colName = colName(res, col)  # Nombre de la columna
  var colType = colType(res, col) # Tipo de la columna
  echo colName, " - ", colType

let col = 0
#echo res.colType(col)
if res.colType(col) == DUCKDB_TYPE_STRUCT:
  var n = 0
  for i in res.getItemsAsStruct(col):
    echo "Row #",n
    if i.isSome:
      var s = i.get()
      var val = s.getInt64("col1")
      if val.isSome:
        echo "col1: ", val.get() #.s.getInt64("col1")
      else:
        echo "col1: NULL"
      val = s.getInt64("col2")
      if val.isSome:
        echo "col2: ", val.get() #.s.getInt64("col1")
      else:
        echo "col2: NULL"      
      #echo "col2: ", s.getInt64("col2")
    else:
      echo "NULL"
    n += 1
#[

  // get the child columns of the struct
  duckdb_vector col1_vector = duckdb_struct_vector_get_child(struct_col, 0);
  int64_t *col1_data = (int64_t *) duckdb_vector_get_data(col1_vector);
  uint64_t *col1_validity = duckdb_vector_get_validity(col1_vector);

  duckdb_vector col2_vector = duckdb_struct_vector_get_child(struct_col, 1);
  int64_t *col2_data = (int64_t *) duckdb_vector_get_data(col2_vector);
  uint64_t *col2_validity = duckdb_vector_get_validity(col2_vector);

  // iterate over the rows
  for (idx_t row = 0; row < row_count; row++) {
    if (!duckdb_validity_row_is_valid(struct_validity, row)) {
      // entire struct is NULL
      printf("NULL\n");
      continue;
    }
    // read col1
    printf("{'col1': ");
    if (!duckdb_validity_row_is_valid(col1_validity, row)) {
      // col1 is NULL
      printf("NULL");
    } else {
      printf("%lld", col1_data[row]);
    }
    printf(", 'col2': ");
    if (!duckdb_validity_row_is_valid(col2_validity, row)) {
      // col2 is NULL
      printf("NULL");
    } else {
      printf("%lld", col2_data[row]);
    }
    printf("}\n");
  }

]#

#[
i     col1     col2
0     NULL     NULL
1     1       142
2     2       NULL
3     3       226
4     4       NULL
5     NULL    NULL
6     6       NULL
7     7       394
8     8       NULL
9     9       478
]#