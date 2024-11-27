import ../wrapper/libduckdb

type
  DuckDbObj* = object
    handle*: duckdb_database
  DuckDb* = ref DuckDbObj

  DuckDbConnObj* = object
    handle*: duckdb_connection
  DuckDbConn* = ref DuckDbConnObj

  DuckDbResultObj* = object
    handle*: duckdb_result
  DuckDbResult* = ref DuckDbResultObj

  DuckDbState* = duckdb_state



proc `=destroy`*(self:DuckDbObj) =
  if self.handle.addr != nil:
    duckdb_close(self.handle.addr)

proc `=destroy`*(self:DuckDbConnObj) =
  if self.handle.addr != nil:
    duckdb_disconnect(self.handle.addr)

proc `=destroy`*(self:DuckDbResultObj) =
  if self.handle.addr != nil:
    duckdb_destroy_result(self.handle.addr)