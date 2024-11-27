import duckdb
import system

# Create connection to duckdb
var db:duckdb_database
var conn:duckdb_connection

var result = duckdb_open(nil, db.addr)
if (result != DuckDBSuccess):
  quit( "No se pudo abrir la base de datos", QuitFailure)

result = duckdb_connect(db, conn.addr)

if result != DuckDBSuccess:
  quit( "No se pudo conectar a la base de datos", QuitFailure)

# Ejecutar una consulta
var res:duckdb_result
if duckdb_query(conn, "SELECT 'Hola, DuckDB!' AS mensaje;".cstring, res.addr) != DuckDBSuccess:
  quit( "Error al ejecutar la consulta", QuitFailure)

# Mostrar el resultado
var msg:cstring = duckdb_value_varchar(res.addr, 0, 0)
echo "Resultado: ", msg

# Liberar recursos
duckdb_destroy_result(res.addr)
duckdb_disconnect(conn.addr)
duckdb_close(db.addr)

#[

    // Mostrar el resultado
    const char *mensaje = duckdb_value_varchar(&result, 0, 0);
    printf("Resultado: %s\n", mensaje);

    // Liberar recursos
    duckdb_destroy_result(&result);
    duckdb_disconnect(&con);
    duckdb_close(&db);

    return 0;
}
]#