import duckdb
import system

var db = newDb()
var conn = newConn(db)
var result = conn.sql("SELECT 'Hola, DuckDB!' AS mensaje;")
echo "Resultado: ", result.toString() #(result,0,0)
