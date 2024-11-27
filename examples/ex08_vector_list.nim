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
  for i in res.getItemsAsStruct(col):
    if i.isSome:
      echo i.get()
    else:
      echo "NULL"

#[
duckdb_database db;
duckdb_connection con;
duckdb_open(nullptr, &db);
duckdb_connect(db, &con);

duckdb_result res;
duckdb_query(con, "SELECT CASE WHEN i % 5 = 0 THEN NULL WHEN i % 2 = 0 THEN [i, i + 1] ELSE [i * 42, NULL, i * 84] END FROM range(10) t(i)", &res);

// iterate until result is exhausted
while (true) {
	duckdb_data_chunk result = duckdb_fetch_chunk(res);
	if (!result) {
		// result is exhausted
		break;
	}
	// get the number of rows from the data chunk
	idx_t row_count = duckdb_data_chunk_get_size(result);
	// get the list column
	duckdb_vector list_col = duckdb_data_chunk_get_vector(result, 0);
	duckdb_list_entry *list_data = (duckdb_list_entry *) duckdb_vector_get_data(list_col);
	uint64_t *list_validity = duckdb_vector_get_validity(list_col);
	// get the child column of the list
	duckdb_vector list_child = duckdb_list_vector_get_child(list_col);
	int64_t *child_data = (int64_t *) duckdb_vector_get_data(list_child);
	uint64_t *child_validity = duckdb_vector_get_validity(list_child);

	// iterate over the rows
	for (idx_t row = 0; row < row_count; row++) {
		if (!duckdb_validity_row_is_valid(list_validity, row)) {
			// entire list is NULL
			printf("NULL\n");
			continue;
		}
		// read the list offsets for this row
		duckdb_list_entry list = list_data[row];
		printf("[");
		for (idx_t child_idx = list.offset; child_idx < list.offset + list.length; child_idx++) {
			if (child_idx > list.offset) {
				printf(", ");
			}
			if (!duckdb_validity_row_is_valid(child_validity, child_idx)) {
				// col1 is NULL
				printf("NULL");
			} else {
				printf("%lld", child_data[child_idx]);
			}
		}
		printf("]\n");
	}
	duckdb_destroy_data_chunk(&result);
}
// clean-up
duckdb_destroy_result(&res);
duckdb_disconnect(&con);
duckdb_close(&db);
]#