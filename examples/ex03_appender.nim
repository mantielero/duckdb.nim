import duckdb


var db = newDb()
var conn = newConn(db)
conn.sql("CREATE TABLE users(id INTEGER, name VARCHAR, age INTEGER);")

let app = conn.newAppender("users")

# Append the first row
app.append(1i32)
app.append("Mark")
app.append(25i32)
app.endRow()

# Append second row
app.append(2i32)
app.append("Hannes")
app.append(21i32)
app.endRow()

app.flush()

var res = conn.sql("SELECT * FROM users;")
var nRows = rowCount(res)

for row in 0..<nRows:
  var col1 = res.toInt32(0, row)
  var col2 = res.toString(1, row)
  var col3 = res.toInt32(2, row)
  echo col1, " ", col2, " ", col3

