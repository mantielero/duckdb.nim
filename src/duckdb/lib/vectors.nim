#https://duckdb.org/docs/archive/1.0/api/c/vector
import ../wrapper/libduckdb
import typs, errors
import std/[options, tables, times]

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

# iterator getChunks*(res:DuckDbResult): DuckDbDataChunk =
#   while true:
#     let chunk = new DuckDbDataChunk
#     chunk.handle = duckdb_fetch_chunk(res.handle)
#     if chunk.handle == nil:
#       break
#     yield chunk
proc getColumnsCount*(res:DuckDbResult):int =
  let chunk = res.fetchChunk()
  return duckdb_data_chunk_get_column_count(chunk.handle).int


type
  DbResultObj* = object
    res*:DuckDbResult
    chunks*:seq[DuckDbDataChunk]
    rows*:seq[int]
    colNames*:seq[string]
    colTypes*:seq[duckdb_type]
  DbResult* = ref DbResultObj

proc toDbResult*(res:DuckDbResult): DbResult =
  result = new DbResult
  result.res = res
  while true:
    let chunk = new DuckDbDataChunk
    chunk.handle = duckdb_fetch_chunk(res.handle)
    if chunk.handle == nil:
      break
    result.chunks &= chunk
    result.rows &= duckdb_row_count(res.handle.addr).int
  let nCols = duckdb_column_count(res.handle.addr) #res.getColumnsCount()
  #echo nCols
  for col in 0 ..< nCols:
    #echo $duckdb_column_name(res.handle.addr, col.idx_t)
    result.colNames &= $duckdb_column_name(res.handle.addr, col.idx_t)
    result.colTypes &= duckdb_column_type(res.handle.addr, col.idx_t)



proc getSize*(chunk: DuckDbDataChunk):int =
  duckdb_data_chunk_get_size(chunk.handle).int

proc getVector*(chunk: DuckDbDataChunk; idx:int): DuckDbVector =
  result = new DuckDbVector
  result.handle = duckdb_data_chunk_get_vector(chunk.handle, idx.idx_t)

# proc getSize*(vector: DuckDbVector):int =
#   let logicalType = duckdb_vector_get_column_type(vector.handle)
#   duckdb_data_chunk_get_size(chunk.handle).int

# proc getVectors*(res:DuckDbResult):seq[DuckDbVector] =
#   result = @[]
#   while true:
#     let chunk = new DuckDbDataChunk
#     chunk.handle = duckdb_fetch_chunk(res.handle)    
#     if chunk.handle == nil:
#       break
#     var nCols = duckdb_data_chunk_get_column_count(chunk.handle)
#     echo nCols
#     for col in 0..<nCols: #chunk.getSize():
#       let vector = new DuckDbVector
#       vector.handle = duckdb_data_chunk_get_vector(chunk.handle, col.idx_t)
#       result &= vector



#---------------------------------

proc getColumnType*(vector:DuckDbVector): duckdb_type = #duckdb_logical_type =
  duckdb_vector_get_column_type(vector.handle).duckdb_get_type_id

# proc getData*(vector:DuckDbVector) = #: DuckDbVectorData =
#   #result = new DuckDbVectorData
#   let vectorData = duckdb_vector_get_data(vector.handle) # this is a pointer
#   # int64_t *vector_data = (int64_t *) duckdb_vector_get_data(res_col);
#   let vectorValidity = duckdb_vector_get_validity(vector.handle)
#   #uint64_t *vector_validity = duckdb_vector_get_validity(res_col);


#---------------------------------
# This is invented just for Nim
# type
#   VectorObj* = object
#     typ*:duckdb_type
#     data*:pointer
#     validity*:ptr uint64
#     n*:int

#   Vector* = ref VectorObj

#   ColumnObj* = object
#     col*:int
#     name*:string
#     vectors*:seq[Vector]
#     #typ*:duckdb_type
#     #vectors*:seq[tuple[n:int]]
#   Column* = ref ColumnObj

proc getData*(vector:DuckDbVector):pointer =
  duckdb_vector_get_data(vector.handle)

proc getValidity*(vector:DuckDbVector):ptr uint64 =
  duckdb_vector_get_validity(vector.handle)

# proc getColumn*(res:DuckDbResult; column:int):Column =
#   result = new Column
#   result.col = column
#   var nCols = -1
#   var firstVector = true
#   for chunk in res.getChunks():
#     if nCols == -1:
#       nCols = duckdb_data_chunk_get_column_count(chunk.handle).int
#     let n = chunk.getSize()  # Number of elements in the vector
#     assert column < nCols

#     # Get the vector
#     let vector = new DuckDbVector
#     vector.handle = duckdb_data_chunk_get_vector(chunk.handle, column.idx_t)

#     #if firstVector:
#     let v = new Vector
#     v.typ = vector.getColumnType
#     v.data = vector.getData() # duckdb_vector_get_data(vector.handle)
#     v.validity = vector.getValidity() #duckdb_vector_get_validity(vector.handle)  
#     v.n = n   
#     let arr = cast[ptr UncheckedArray[int32]](v.data)
#     echo arr[0]
#     echo arr[1]    
#     #  firstVector = false
#     result.vectors &= v

# iterator getInts*(res:DuckDbResult; column:int):Option[int64] =
#   while true:
#     let chunk = new DuckDbDataChunk
#     chunk.handle = duckdb_fetch_chunk(res.handle)

#     if chunk.handle == nil:
#       break
#     #duckdb_data_chunk_reset(chunk.handle)
#     let nCols = duckdb_data_chunk_get_column_count(chunk.handle).int
#     assert column < nCols
    
#     let n = chunk.getSize() 

#     let vector = new DuckDbVector
#     vector.handle = duckdb_data_chunk_get_vector(chunk.handle, column.idx_t)
#     let typ = vector.getColumnType
#     let data = vector.getData() # duckdb_vector_get_data(vector.handle)
#     let validity = vector.getValidity() #duckdb_vector_get_validity(vector.handle)  
#     case typ
#     of DUCKDB_TYPE_INTEGER:
#       let arr = cast[ptr UncheckedArray[int32]](data)
#       for i in 0..<n:
#         if duckdb_validity_row_is_valid(validity, i.idx_t):
#           yield some(arr[i].int64)
#         else:
#           yield none(int64)
#     else:
#       discard

iterator getInts*(res:DbResult; column:int):Option[int64] =
  ## iterates over all the integers in a result casting them into int64
  for chunk in res.chunks:
    let nCols = duckdb_data_chunk_get_column_count(chunk.handle).int
    assert column < nCols
    
    let n = chunk.getSize() 

    let vector = new DuckDbVector
    vector.handle = duckdb_data_chunk_get_vector(chunk.handle, column.idx_t)
    let typ = vector.getColumnType
    let data = vector.getData() # duckdb_vector_get_data(vector.handle)
    let validity = vector.getValidity() #duckdb_vector_get_validity(vector.handle)  
    case typ
    of DUCKDB_TYPE_TINYINT:
      let arr = cast[ptr UncheckedArray[int8]](data)
      for i in 0..<n:
        if duckdb_validity_row_is_valid(validity, i.idx_t):
          yield some(arr[i].int64)
        else:
          yield none(int64)
    of DUCKDB_TYPE_SMALLINT:
      let arr = cast[ptr UncheckedArray[int16]](data)
      for i in 0..<n:
        if duckdb_validity_row_is_valid(validity, i.idx_t):
          yield some(arr[i].int64)
        else:
          yield none(int64)
    of DUCKDB_TYPE_INTEGER:
      let arr = cast[ptr UncheckedArray[int32]](data)
      for i in 0..<n:
        if duckdb_validity_row_is_valid(validity, i.idx_t):
          yield some(arr[i].int64)
        else:
          yield none(int64)
    of DUCKDB_TYPE_BIGINT:
      let arr = cast[ptr UncheckedArray[int64]](data)
      for i in 0..<n:
        if duckdb_validity_row_is_valid(validity, i.idx_t):
          yield some(arr[i].int64)
        else:
          yield none(int64)
    else:  # TODO: to consider all the others INTEGER types
      raise newException(ValueError, "type not supported: " & $typ)

iterator getUints*(res:DbResult; column:int):Option[uint64] =
  ## iterates over all the unsigned integers in a result casting them into uint64  
  for chunk in res.chunks:
    let nCols = duckdb_data_chunk_get_column_count(chunk.handle).int
    assert column < nCols
    
    let n = chunk.getSize() 

    let vector = new DuckDbVector
    vector.handle = duckdb_data_chunk_get_vector(chunk.handle, column.idx_t)
    let typ = vector.getColumnType
    let data = vector.getData() # duckdb_vector_get_data(vector.handle)
    let validity = vector.getValidity() #duckdb_vector_get_validity(vector.handle)  
    case typ
    of DUCKDB_TYPE_UTINYINT:
      let arr = cast[ptr UncheckedArray[uint8]](data)
      for i in 0..<n:
        if duckdb_validity_row_is_valid(validity, i.idx_t):
          yield some(arr[i].uint64)
        else:
          yield none(uint64)
    of DUCKDB_TYPE_USMALLINT:
      let arr = cast[ptr UncheckedArray[uint16]](data)
      for i in 0..<n:
        if duckdb_validity_row_is_valid(validity, i.idx_t):
          yield some(arr[i].uint64)
        else:
          yield none(uint64)
    of DUCKDB_TYPE_UINTEGER:
      let arr = cast[ptr UncheckedArray[uint32]](data)
      for i in 0..<n:
        if duckdb_validity_row_is_valid(validity, i.idx_t):
          yield some(arr[i].uint64)
        else:
          yield none(uint64)
    of DUCKDB_TYPE_UBIGINT:
      let arr = cast[ptr UncheckedArray[uint64]](data)
      for i in 0..<n:
        if duckdb_validity_row_is_valid(validity, i.idx_t):
          yield some(arr[i].uint64)
        else:
          yield none(uint64)
    else:  # TODO: to consider all the others INTEGER types
      raise newException(ValueError, "type not supported: " &  $typ)

# TODO: iterators specific for INT8, INT16, INY32, UINT8. UINT16, UINT32


iterator getFloats*(res:DbResult; column:int):Option[float64] =
  ## iterates over all the floats in a result casting them into float64
  for chunk in res.chunks:
    let nCols = duckdb_data_chunk_get_column_count(chunk.handle).int
    assert column < nCols
    
    let n = chunk.getSize() 

    let vector = new DuckDbVector
    vector.handle = duckdb_data_chunk_get_vector(chunk.handle, column.idx_t)
    let typ = vector.getColumnType
    let data = vector.getData() # duckdb_vector_get_data(vector.handle)
    let validity = vector.getValidity() #duckdb_vector_get_validity(vector.handle)  
    case typ
    of DUCKDB_TYPE_FLOAT:
      let arr = cast[ptr UncheckedArray[float32]](data)
      for i in 0..<n:
        if duckdb_validity_row_is_valid(validity, i.idx_t):
          yield some(arr[i].float64)
        else:
          yield none(float64)
    of DUCKDB_TYPE_DOUBLE:
      let arr = cast[ptr UncheckedArray[float64]](data)
      for i in 0..<n:
        if duckdb_validity_row_is_valid(validity, i.idx_t):
          yield some(arr[i].float64)
        else:
          yield none(float64)
    else:  # TODO: to consider all the others INTEGER types
      raise newException(ValueError, "type not supported: " & $typ)


iterator getStrings*(res:DbResult; column:int):Option[string] =
  ## iterates over all the unsigned integers in a result casting them into uint64  
  for chunk in res.chunks:
    let nCols = duckdb_data_chunk_get_column_count(chunk.handle).int
    assert column < nCols
    
    let n = chunk.getSize() 

    let vector = new DuckDbVector
    vector.handle = duckdb_data_chunk_get_vector(chunk.handle, column.idx_t)
    let typ = vector.getColumnType
    let data = vector.getData() # duckdb_vector_get_data(vector.handle)
    let validity = vector.getValidity() #duckdb_vector_get_validity(vector.handle)  
    case typ
    of DUCKDB_TYPE_VARCHAR:
      let arr = cast[ptr UncheckedArray[duckdb_string_t]](data)
      for row in 0..<n:
        if duckdb_validity_row_is_valid(validity, row.idx_t):
          if duckdb_string_is_inlined(arr[row]): # inline
            let pInlined = arr[row].value.inlined.inlined
            yield some($cast[cstring](unsafeAddr(pInlined[0])))
          else:
            let nchars = arr[row].value.pointer_field.length
            #echo n
            var tmp = $cast[cstring](arr[row].value.pointer_field.ptr_field)
            setLen(tmp, nchars)
            yield some(tmp)
        else:
          yield none(string)

    else:  # TODO: to consider all the others INTEGER types
      raise newException(ValueError, "type not supported: " &  $typ)



iterator getDates*(res:DbResult; column:int):Option[DateTime] =
  ## iterates over all the floats in a result casting them into float64
  for chunk in res.chunks:
    let nCols = duckdb_data_chunk_get_column_count(chunk.handle).int
    assert column < nCols
    
    let n = chunk.getSize() 

    let vector = new DuckDbVector
    vector.handle = duckdb_data_chunk_get_vector(chunk.handle, column.idx_t)
    let typ = vector.getColumnType
    let data = vector.getData() # duckdb_vector_get_data(vector.handle)
    let validity = vector.getValidity() #duckdb_vector_get_validity(vector.handle)  
    case typ
    of DUCKDB_TYPE_DATE:
      let arr = cast[ptr UncheckedArray[duckdb_date]](data)
      for i in 0..<n:
        if duckdb_validity_row_is_valid(validity, i.idx_t):
          let days = arr[i].days
          yield some(dateTime(1970, 1.Month,1.MonthdayRange, zone=utc()) + days.days)
        else:
          yield none(DateTime)
    of DUCKDB_TYPE_TIMESTAMP:
      let arr = cast[ptr UncheckedArray[duckdb_timestamp]](data)
      for i in 0..<n:
        if duckdb_validity_row_is_valid(validity, i.idx_t):
          let micros = arr[i].micros
          yield some(dateTime(1970, 1.Month,1.MonthdayRange, zone=utc()) + micros.microseconds)
        else:
          yield none(DateTime)      
    else:  # TODO: to consider all the others INTEGER types
      raise newException(ValueError, "type not supported: " & $typ)

iterator getTimes*(res:DbResult; column:int):Option[Time] =
  ## iterates over all the floats in a result casting them into float64
  for chunk in res.chunks:
    let nCols = duckdb_data_chunk_get_column_count(chunk.handle).int
    assert column < nCols
    
    let n = chunk.getSize() 

    let vector = new DuckDbVector
    vector.handle = duckdb_data_chunk_get_vector(chunk.handle, column.idx_t)
    let typ = vector.getColumnType
    let data = vector.getData() # duckdb_vector_get_data(vector.handle)
    let validity = vector.getValidity() #duckdb_vector_get_validity(vector.handle)  
    case typ
    of DUCKDB_TYPE_TIME:
      let arr = cast[ptr UncheckedArray[duckdb_time]](data)
      for i in 0..<n:
        if duckdb_validity_row_is_valid(validity, i.idx_t):
          let micros = arr[i].micros.float
          yield some(fromUnixFloat(micros / 1000000.0 ))
        else:
          yield none(Time)

    else:  # TODO: to consider all the others INTEGER types
      raise newException(ValueError, "type not supported: " & $typ)

iterator getTimeIntervals*(res:DbResult; column:int):Option[TimeInterval] =
  ## iterates over all the floats in a result casting them into float64
  for chunk in res.chunks:
    let nCols = duckdb_data_chunk_get_column_count(chunk.handle).int
    assert column < nCols
    
    let n = chunk.getSize() 

    let vector = new DuckDbVector
    vector.handle = duckdb_data_chunk_get_vector(chunk.handle, column.idx_t)
    let typ = vector.getColumnType
    let data = vector.getData() # duckdb_vector_get_data(vector.handle)
    let validity = vector.getValidity() #duckdb_vector_get_validity(vector.handle)  
    case typ
    of DUCKDB_TYPE_INTERVAL:
      let arr = cast[ptr UncheckedArray[duckdb_interval]](data)
      for i in 0..<n:
        if duckdb_validity_row_is_valid(validity, i.idx_t):
          #let micros = arr[i].micros.float
          yield some(initTimeInterval( microseconds = arr[i].micros.int,  
                                       days         = arr[i].days.int, 
                                       months       = arr[i].months.int)  )
        else:
          yield none(TimeInterval)

    else:  # TODO: to consider all the others INTEGER types
      raise newException(ValueError, "type not supported: " & $typ)


#[
  struct_duckdb_date* {.pure, inheritable, bycopy.} = object
    days*: int32             ## Generated based on /usr/include/duckdb.h:255:9
  duckdb_date* = struct_duckdb_date ## Generated based on /usr/include/duckdb.h:257:3
]#

#[
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
]#

#-----------

# Itereate over specific columns' types =======================================================
# iterator getItemsAsInt64*(res: DuckDbResult; col:int):Option[int64] =
#   while true:
#     var chunk = res.fetchChunk  
#     if chunk.isExhausted:
#       break
    
    
#     var vector = chunk.getVector(col)
#     var vectorTyp = vector.getColumnType
#     assert vectorTyp == DUCKDB_TYPE_BIGINT
#     let vectorData = duckdb_vector_get_data(vector.handle)
#     let vectorValidity = duckdb_vector_get_validity(vector.handle)

#     let vectorDataArray = cast[ptr UncheckedArray[int64]](vectorData)
#     for row in 0..<chunk.getSize():
#       if duckdb_validity_row_is_valid(vectorValidity, row.uint64):
#         #echo cast[ptr UncheckedArray[int64]](vectorData)[0]
#         yield some(vectorDataArray[row])
#       else:
#         yield none(int64)
#     duckdb_destroy_data_chunk(chunk.handle.addr)

# iterator getItemsAsString*(res: DuckDbResult; col:int):Option[string] =
#   while true:
#     var chunk = res.fetchChunk  
#     if chunk.isExhausted:
#       #echo "result is exhausted"
#       break
    
#     var vector = chunk.getVector(col)
#     var vectorTyp = vector.getColumnType
#     assert vectorTyp == DUCKDB_TYPE_VARCHAR
#     let vectorData = duckdb_vector_get_data(vector.handle)
#     let vectorValidity = duckdb_vector_get_validity(vector.handle)

#     let vectorDataArray = cast[ptr UncheckedArray[duckdb_string_t]](vectorData)  # duckdb_string_t
#     for row in 0..<chunk.getSize():
#       if duckdb_validity_row_is_valid(vectorValidity, row.uint64):
#         if duckdb_string_is_inlined(vectorDataArray[row]): # inline
#           let pInlined = vectorDataArray[row].value.inlined.inlined
#           yield some($cast[cstring](unsafeAddr(pInlined[0])))
#         else:
#           let n = vectorDataArray[row].value.pointer_field.length
#           #echo n
#           var tmp = $cast[cstring](vectorDataArray[row].value.pointer_field.ptr_field)
#           setLen(tmp, n)
#           yield some(tmp)

#       else:
#         yield none(string)
#     duckdb_destroy_data_chunk(chunk.handle.addr)    

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

