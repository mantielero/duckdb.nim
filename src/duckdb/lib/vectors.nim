#https://duckdb.org/docs/archive/1.0/api/c/vector
import ../wrapper/libduckdb
import typs, errors
import std/[options, tables]


type
  DuckDbDataChunkObj* = object
    handle: duckdb_data_chunk
  DuckDbDataChunk* = ref DuckDbDataChunkObj

  DuckDbVectorObj* = object
    handle: duckdb_vector
  DuckDbVector* = ref DuckDbVectorObj

  # DuckDbVectorDataObj* = object
  #   handle: vector_data
  # DuckDbVectorData* = ref DuckDbVectorDataObj

proc `=destroy`*(self:DuckDbDataChunkObj) =
  if self.handle.addr != nil:
    duckdb_destroy_data_chunk(self.handle.addr)

proc fetchChunk*(res:DuckDbResult): DuckDbDataChunk =
  result = new DuckDbDataChunk
  result.handle = duckdb_fetch_chunk(res.handle)

proc isExhausted*(chunk: DuckDbDataChunk): bool =
  if chunk.handle == nil:
    return true
  return false

proc getSize*(chunk: DuckDbDataChunk):int =
  duckdb_data_chunk_get_size(chunk.handle).int

proc getVector*(chunk: DuckDbDataChunk; idx:int): DuckDbVector =
  result = new DuckDbVector
  result.handle = duckdb_data_chunk_get_vector(chunk.handle, idx.idx_t)


proc getColumnType*(vector:DuckDbVector): duckdb_type = #duckdb_logical_type =
  duckdb_vector_get_column_type(vector.handle).duckdb_get_type_id

proc getData*(vector:DuckDbVector) = #: DuckDbVectorData =
  #result = new DuckDbVectorData
  let vectorData = duckdb_vector_get_data(vector.handle) # this is a pointer
  # int64_t *vector_data = (int64_t *) duckdb_vector_get_data(res_col);
  let vectorValidity = duckdb_vector_get_validity(vector.handle)
  #uint64_t *vector_validity = duckdb_vector_get_validity(res_col);



iterator getItemsAsInt64*(res: DuckDbResult; col:int):Option[int64] =
  while true:
    var chunk = res.fetchChunk  
    if chunk.isExhausted:
      break
    
    var vector = chunk.getVector(col)
    var vectorTyp = vector.getColumnType
    assert vectorTyp == DUCKDB_TYPE_BIGINT
    let vectorData = duckdb_vector_get_data(vector.handle)
    let vectorValidity = duckdb_vector_get_validity(vector.handle)

    let vectorDataArray = cast[ptr UncheckedArray[int64]](vectorData)
    for row in 0..<chunk.getSize():
      if duckdb_validity_row_is_valid(vectorValidity, row.uint64):
        #echo cast[ptr UncheckedArray[int64]](vectorData)[0]
        yield some(vectorDataArray[row])
      else:
        yield none(int64)
    duckdb_destroy_data_chunk(chunk.handle.addr)

iterator getItemsAsString*(res: DuckDbResult; col:int):Option[string] =
  while true:
    var chunk = res.fetchChunk  
    if chunk.isExhausted:
      #echo "result is exhausted"
      break
    
    var vector = chunk.getVector(col)
    var vectorTyp = vector.getColumnType
    assert vectorTyp == DUCKDB_TYPE_VARCHAR
    let vectorData = duckdb_vector_get_data(vector.handle)
    let vectorValidity = duckdb_vector_get_validity(vector.handle)

    let vectorDataArray = cast[ptr UncheckedArray[duckdb_string_t]](vectorData)  # duckdb_string_t
    for row in 0..<chunk.getSize():
      if duckdb_validity_row_is_valid(vectorValidity, row.uint64):
        if duckdb_string_is_inlined(vectorDataArray[row]): # inline
          let pInlined = vectorDataArray[row].value.inlined.inlined
          yield some($cast[cstring](unsafeAddr(pInlined[0])))
        else:
          let n = vectorDataArray[row].value.pointer_field.length
          #echo n
          var tmp = $cast[cstring](vectorDataArray[row].value.pointer_field.ptr_field)
          setLen(tmp, n)
          yield some(tmp)

      else:
        yield none(string)
    duckdb_destroy_data_chunk(chunk.handle.addr)    

proc getChild(vector:DuckDbVector; col:Natural):DuckDbVector =
  result = new DuckDbVector
  result.handle = duckdb_struct_vector_get_child(vector.handle, col.idx_t)






type
  # DuckStructObj = object
  #   vector*:DuckDbVector
  #   kv*: Table[string, tuple[col:int; typ:duckdb_type; validity:ptr uint64]]
  #   row*:int
  # DuckStruct* = ref DuckStructObj

  FieldObj* = object
    name*: string
    col*: int
    typ*: duckdb_type
    validity*: ptr uint64
    vector*: DuckDbVector
    data*: pointer

  Field* = ref FieldObj

  #DuckDbStruct* = seq[tuple[name:string; typ:duckdb_type; validity: ptr uint64]]
  FieldsObj* = object
    fields*:seq[Field]
    namecol*:Table[string, int]
  Fields* = ref FieldsObj

  DuckStruct* = tuple[fields:Fields; row:int]

proc getInt64*(s:DuckStruct; name:string):Option[int64] =
  let fields = s.fields
  let row = s.row
  let col = fields.namecol[name]
  var tmp = fields.fields[col]
  assert tmp.typ == DUCKDB_TYPE_BIGINT
  #var col = tmp.col

  #let vCol = tmp.vector.getChild(col)
  let vData = tmp.data #duckdb_vector_get_data(vCol.handle)
  let vValidity = tmp.validity #duckdb_vector_get_validity(vCol.handle)


  let vectorDataArray = cast[ptr UncheckedArray[int64]](vData)
  #echo "----"
  if duckdb_validity_row_is_valid(vValidity, row.uint64):
    return some(vectorDataArray[row])
  else:
    return none(int64)
  # for row in 0..<chunk.getSize():
  #   if duckdb_validity_row_is_valid(vValidity, row.uint64):
  #     #echo cast[ptr UncheckedArray[int64]](vectorData)[0]
  #     yield some(vectorDataArray[row])
  #   else:
  #     yield none(int64)



iterator getItemsAsStruct*(res: DuckDbResult; col:int):Option[DuckStruct] =
  while true:
    var chunk = res.fetchChunk  
    if chunk.isExhausted:
      #echo "result is exhausted"
      break
    
    var vector = chunk.getVector(col)
    var vectorTyp = vector.getColumnType
    assert vectorTyp == DUCKDB_TYPE_STRUCT
    let vectorData = duckdb_vector_get_data(vector.handle)
    let vectorValidity = duckdb_vector_get_validity(vector.handle)

    var s = new DuckStruct
    let logicalTyp = duckdb_vector_get_column_type(vector.handle)
    # get the number of columns in the struct
    let nCols = duckdb_struct_type_child_count(logicalTyp).int
    # get the data for each specific col in the struct
    var fields = new Fields
    for col in 0..<nCols:
      var field = new Field
      let vCol = vector.getChild(col)
      let vData = duckdb_vector_get_data(vCol.handle)
      let vValidity = duckdb_vector_get_validity(vCol.handle)
      var vTyp = vCol.getColumnType
      let vName = $duckdb_struct_type_child_name(logicalTyp, col.idx_t)

      field.name = vName
      field.col = col
      field.typ = vTyp
      field.vector = vcol
      field.validity = vValidity
      field.data = vData


      fields.fields &= field
      fields.namecol[vName] = col

      #s.kv[vName] = (col:col, typ: vTyp, validity: vValidity)
      #s.vector = vector
      #case vTyp:
      #of DUCKDB_TYPE_BIGINT:
      #  discard
      #else:
      #  echo "Not supported: ", vTyp
    #for k,v in s.kv.pairs():
    #  echo k, " ", v
    #echo chunk.getSize()
    #yield s
    # let vectorDataArray = cast[ptr UncheckedArray[int64]](vectorData)
    for row in 0..<chunk.getSize():
      if duckdb_validity_row_is_valid(vectorValidity, row.uint64):
        #if duckdb_validity_row_is_valid(col1_validity, row))
        #s.row = row
        yield some((fields:fields, row:row))
    #     yield some(vectorDataArray[row])
      else:
        yield none(DuckStruct)
    #     yield none(int64)
    duckdb_destroy_data_chunk(chunk.handle.addr)

