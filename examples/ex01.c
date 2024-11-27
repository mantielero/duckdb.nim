// gcc -o ejemplo ejemplo.c -L. -lduckdb

#include <duckdb.h>
#include <stdio.h>

int main() {
    // Crear una conexión de DuckDB
    duckdb_database db;
    duckdb_connection con;

    if (duckdb_open(NULL, &db) != DuckDBSuccess) {
        fprintf(stderr, "No se pudo abrir la base de datos\n");
        return 1;
    }

    if (duckdb_connect(db, &con) != DuckDBSuccess) {
        fprintf(stderr, "No se pudo conectar a la base de datos\n");
        return 1;
    }

    // Ejecutar una consulta
    duckdb_result result;
    if (duckdb_query(con, "SELECT 'Hola, DuckDB!' AS mensaje;", &result) != DuckDBSuccess) {
        fprintf(stderr, "Error al ejecutar la consulta\n");
        return 1;
    }

    // Mostrar el resultado
    const char *mensaje = duckdb_value_varchar(&result, 0, 0);
    printf("Resultado: %s\n", mensaje);

    // Liberar recursos
    duckdb_destroy_result(&result);
    duckdb_disconnect(&con);
    duckdb_close(&db);

    return 0;
}