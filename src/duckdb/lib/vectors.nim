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

iterator getBooleans*(res:DbResult; column:int):Option[bool] =
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
    of DUCKDB_TYPE_BOOLEAN:
      let arr = cast[ptr UncheckedArray[bool]](data)
      for i in 0..<n:
        if duckdb_validity_row_is_valid(validity, i.idx_t):
          yield some(arr[i].bool)
        else:
          yield none(bool)

    else:  # TODO: to consider all the others INTEGER types
      raise newException(ValueError, "type not supported: " & $typ)

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

#-----
iterator getSeqsInts*(res:DbResult; column:int):Option[seq[Option[int]]] =
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
    of DUCKDB_TYPE_ARRAY:
      #let arr = cast[ptr UncheckedArray[int8]](data)

      let childVector = new DuckDbVector
      childVector.handle = duckdb_list_vector_get_child(vector.handle)
      let childTyp = childVector.getColumnType   
      let childData = childVector.getData()#duckdb_vector_get_data(list_child);
      let childValidity = childVector.getValidity() #duckdb_vector_get_validity(list_child);

      let vectorLogicalType = duckdb_vector_get_column_type(vector.handle)# .duckdb_get_type_id
      #let childType = duckdb_array_type_child_type(vectorLogicalType).duckdb_get_type_id
      let arraySize = duckdb_array_type_array_size(vectorLogicalType).int
      #echo childTyp
      #echo childType
      echo "SIZE: ", arraySize
      
      case childTyp
      of DUCKDB_TYPE_TINYINT:
        let childArray = cast[ptr UncheckedArray[int8]](childData)  
        # let childVector = new DuckDbVector
        # childVector.handle = duckdb_list_vector_get_child(vector.handle)
        # let childTyp = childVector.getColumnType   
        # let childData = childVector.getData()#duckdb_vector_get_data(list_child);
        # let childValidity = childVector.getValidity() #duckdb_vector_get_validity(list_child);

        # duckdb_array_type_child_type
        # duckdb_array_type_array_size
        for i in 0..<n:
          if duckdb_validity_row_is_valid(validity, i.idx_t):          
            var values:seq[Option[int]] = @[]
            #echo arr[0]
            for c in 0..<arraySize:
              let idx = c + i*arraySize
              #echo idx
              if duckdb_validity_row_is_valid(childValidity, idx.idx_t):
                values &= some(childArray[idx].int)
              else:
                values &= none(int)
            yield some(values)
          else:
            yield none(seq[Option[int]])
      of DUCKDB_TYPE_SMALLINT:
        let childArray = cast[ptr UncheckedArray[int16]](childData)  
        # let childVector = new DuckDbVector
        # childVector.handle = duckdb_list_vector_get_child(vector.handle)
        # let childTyp = childVector.getColumnType   
        # let childData = childVector.getData()#duckdb_vector_get_data(list_child);
        # let childValidity = childVector.getValidity() #duckdb_vector_get_validity(list_child);

        # duckdb_array_type_child_type
        # duckdb_array_type_array_size
        for i in 0..<n:
          if duckdb_validity_row_is_valid(validity, i.idx_t):          
            var values:seq[Option[int]] = @[]
            #echo arr[0]
            for c in 0..<arraySize:
              let idx = c + i*arraySize
              #echo idx
              if duckdb_validity_row_is_valid(childValidity, idx.idx_t):
                values &= some(childArray[idx].int)
              else:
                values &= none(int)
            yield some(values)
          else:
            yield none(seq[Option[int]])
      of DUCKDB_TYPE_INTEGER:
        let childArray = cast[ptr UncheckedArray[int32]](childData)  
        # let childVector = new DuckDbVector
        # childVector.handle = duckdb_list_vector_get_child(vector.handle)
        # let childTyp = childVector.getColumnType   
        # let childData = childVector.getData()#duckdb_vector_get_data(list_child);
        # let childValidity = childVector.getValidity() #duckdb_vector_get_validity(list_child);

        # duckdb_array_type_child_type
        # duckdb_array_type_array_size
        for i in 0..<n:
          if duckdb_validity_row_is_valid(validity, i.idx_t):          
            var values:seq[Option[int]] = @[]
            #echo arr[0]
            for c in 0..<arraySize:
              let idx = c + i*arraySize
              #echo idx
              if duckdb_validity_row_is_valid(childValidity, idx.idx_t):
                values &= some(childArray[idx].int)
              else:
                values &= none(int)
            yield some(values)
          else:
            yield none(seq[Option[int]])
      of DUCKDB_TYPE_BIGINT:
        let childArray = cast[ptr UncheckedArray[int64]](childData)  
        # let childVector = new DuckDbVector
        # childVector.handle = duckdb_list_vector_get_child(vector.handle)
        # let childTyp = childVector.getColumnType   
        # let childData = childVector.getData()#duckdb_vector_get_data(list_child);
        # let childValidity = childVector.getValidity() #duckdb_vector_get_validity(list_child);

        # duckdb_array_type_child_type
        # duckdb_array_type_array_size
        for i in 0..<n:
          if duckdb_validity_row_is_valid(validity, i.idx_t):          
            var values:seq[Option[int]] = @[]
            #echo arr[0]
            for c in 0..<arraySize:
              let idx = c + i*arraySize
              #echo idx
              if duckdb_validity_row_is_valid(childValidity, idx.idx_t):
                values &= some(childArray[idx].int)
              else:
                values &= none(int)
            yield some(values)
          else:
            yield none(seq[Option[int]])
      else:
        raise newException(ValueError, "type not supported: " & $childTyp)

    of DUCKDB_TYPE_LIST:
      let arr = cast[ptr UncheckedArray[duckdb_list_entry]](data)
      
      let childVector = new DuckDbVector
      childVector.handle = duckdb_list_vector_get_child(vector.handle)
      let childTyp = childVector.getColumnType   
      let childData = childVector.getData()#duckdb_vector_get_data(list_child);
      let childValidity = childVector.getValidity() #duckdb_vector_get_validity(list_child);

      case childTyp
      of DUCKDB_TYPE_TINYINT:
        let childArray = cast[ptr UncheckedArray[int8]](childData)   # FIXME: This is only valid for the INTEGER case

        for i in 0..<n:
          if duckdb_validity_row_is_valid(validity, i.idx_t):
            var values:seq[Option[int]] = @[]
            for c in 0..<arr[i].length:
              let idx = arr[i].offset + c 
              if duckdb_validity_row_is_valid(childValidity, idx):
                values &= some(childArray[idx].int)
              else:
                values &= none(int)
            yield some(values)
          else:
            yield none(seq[Option[int]])

      of DUCKDB_TYPE_SMALLINT:
        let childArray = cast[ptr UncheckedArray[int16]](childData)   # FIXME: This is only valid for the INTEGER case

        for i in 0..<n:
          if duckdb_validity_row_is_valid(validity, i.idx_t):
            var values:seq[Option[int]] = @[]
            for c in 0..<arr[i].length:
              let idx = arr[i].offset + c 
              if duckdb_validity_row_is_valid(childValidity, idx):
                values &= some(childArray[idx].int)
              else:
                values &= none(int)
            yield some(values)
          else:
            yield none(seq[Option[int]])

      of DUCKDB_TYPE_INTEGER:
        let childArray = cast[ptr UncheckedArray[int32]](childData)   # FIXME: This is only valid for the INTEGER case

        for i in 0..<n:
          if duckdb_validity_row_is_valid(validity, i.idx_t):
            var values:seq[Option[int]] = @[]
            for c in 0..<arr[i].length:
              let idx = arr[i].offset + c 
              if duckdb_validity_row_is_valid(childValidity, idx):
                values &= some(childArray[idx].int)
              else:
                values &= none(int)
            yield some(values)
          else:
            yield none(seq[Option[int]])

      of DUCKDB_TYPE_BIGINT:
        let childArray = cast[ptr UncheckedArray[int64]](childData)   # FIXME: This is only valid for the INTEGER case

        for i in 0..<n:
          if duckdb_validity_row_is_valid(validity, i.idx_t):
            var values:seq[Option[int]] = @[]
            for c in 0..<arr[i].length:
              let idx = arr[i].offset + c 
              if duckdb_validity_row_is_valid(childValidity, idx):
                values &= some(childArray[idx].int)
              else:
                values &= none(int)
            yield some(values)
          else:
            yield none(seq[Option[int]])
      else:
        raise newException(ValueError, "type not supported in list: " & $childTyp)

    else:  # TODO: to consider all the others INTEGER types
      raise newException(ValueError, "type not supported: " & $typ)

#-----
iterator getEnums*(res:DbResult; column:int):Option[tuple[idx:uint;value:string]] =
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

    let vectorLogicalType = duckdb_vector_get_column_type(vector.handle)
    let enumTyp = duckdb_enum_internal_type(vectorLogicalType)
    let enumSize = duckdb_enum_dictionary_size(vectorLogicalType).int
    var items:seq[string] = @[]
    for idx in 0..<enumSize:
      var nameAddress = duckdb_enum_dictionary_value(vectorLogicalType, idx.idx_t)
      var tmp = cast[cstring](nameAddress)
      items &= $tmp
    echo items
    case typ
    of DUCKDB_TYPE_ENUM:
      let arr = cast[ptr UncheckedArray[uint8]](data)
      for i in 0..<n:
        if duckdb_validity_row_is_valid(validity, i.idx_t):
          yield some((arr[i].uint, items[arr[i]]))
        else:
          yield none(tuple[idx:uint;value:string])

    else:  # TODO: to consider all the others INTEGER types
      raise newException(ValueError, "type not supported: " & $typ)

#--------
#[
Maps are just lists of {key: V, value: K} structs, and 
unions are just structs with a special "tag" field as first member, 
so you should be able to use the same functions as when accessing lists and structs.
]#

iterator getMaps*(res:DbResult; column:int):Option[tuple[idx:uint;value:string]] =
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

    let vectorLogicalType = duckdb_vector_get_column_type(vector.handle)
    let keyTyp   = duckdb_map_type_key_type(vectorLogicalType).duckdb_get_type_id
    let valueTyp = duckdb_map_type_value_type(vectorLogicalType).duckdb_get_type_id
    echo $keyTyp
    echo $valueTyp
    var items:seq[string] = @[]
    # for idx in 0..<enumSize:
    #   var nameAddress = duckdb_enum_dictionary_value(vectorLogicalType, idx.idx_t)
    #   var tmp = cast[cstring](nameAddress)
    #   items &= $tmp
    # echo items
    case typ
    of DUCKDB_TYPE_MAP:
      #let arr = cast[ptr UncheckedArray[uint8]](data)
      let childVector = new DuckDbVector

      childVector.handle = duckdb_data_chunk_get_vector(chunk.handle, 0.idx_t)
      let childData = childVector.getData()
      let childValidity = childVector.getValidity() #duckdb_vector_get_validity(childVector);

      # for i in 0..<n:
      #   if duckdb_validity_row_is_valid(validity, i.idx_t):
      #     yield some((arr[i].uint, items[arr[i]]))
      #   else:
      #     yield none(tuple[idx:uint;value:string])

    else:  # TODO: to consider all the others INTEGER types
      raise newException(ValueError, "type not supported: " & $typ)

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
    colNames*:seq[string]
    namecol*:Table[string, int]
  Fields* = ref FieldsObj

  DuckStruct* = tuple[fields:Fields; row:int]

type
  # ValueKind = enum  # the different node types
  #   nkInt,          # a leaf with an integer value
  #   nkFloat,        # a leaf with a float value
  #   nkString,       # a leaf with a string value
  #   nkAdd,          # an addition
  #   nkSub,          # a subtraction
  #   nkIf            # an if statement
  Value* = ref object
    case kind*: duckdb_type  # the `kind` field is the discriminator
    of DUCKDB_TYPE_BOOLEAN: boolVal*: bool
    of DUCKDB_TYPE_TINYINT: int8Val*: int8
    of DUCKDB_TYPE_SMALLINT: int16Val*: int16
    of DUCKDB_TYPE_INTEGER: int32Val*: int32
    of DUCKDB_TYPE_BIGINT: int64Val*: int64
    of DUCKDB_TYPE_UTINYINT: uint8Val*: uint8
    of DUCKDB_TYPE_USMALLINT: uint16Val*: uint16
    of DUCKDB_TYPE_UINTEGER: uint32Val*: uint32
    of DUCKDB_TYPE_UBIGINT: uint64Val*: uint64
    of DUCKDB_TYPE_FLOAT: floatVal*: float32
    of DUCKDB_TYPE_DOUBLE: doubleVal*: float64    
    of DUCKDB_TYPE_VARCHAR: stringVal*: string
    else:
      todo:string
    # of DUCKDB_TYPE_INVALID, DUCKDB_TYPE_TIMESTAMP, DUCKDB_TYPE_DATE,
    #    DUCKDB_TYPE_TIME, DUCKDB_TYPE_INTERVAL, DUCKDB_TYPE_HUGEINT, DUCKDB_TYPE_UHUGEINT,
    #    DUCKDB_TYPE_BLOB, DUCKDB_TYPE_DECIMAL,
    #    DUCKDB_TYPE_TIMESTAMP_S, DUCKDB_TYPE_TIMESTAMP_MS, DUCKDB_TYPE_TIMESTAMP_NS,
    #    DUCKDB_TYPE_ENUM, DUCKDB_TYPE_LIST, DUCKDB_TYPE_STRUCT,
    #    DUCKDB_TYPE_MAP,  DUCKDB_TYPE_ARRAY,  DUCKDB_TYPE_UUID,  DUCKDB_TYPE_UNION,
    #    DUCKDB_TYPE_BIT, DUCKDB_TYPE_TIME_TZ, DUCKDB_TYPE_TIMESTAMP_TZ: todo: string

#[

]#

iterator getStructs*(res:DbResult; column:int):Option[Table[string, Option[Value]]] =
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

    let vectorLogicalType = duckdb_vector_get_column_type(vector.handle)
    #let keyTyp   = duckdb_map_type_key_type(vectorLogicalType).duckdb_get_type_id
    #let valueTyp = duckdb_map_type_value_type(vectorLogicalType).duckdb_get_type_id
    #echo $keyTyp
    #echo $valueTyp

    let childNcols = duckdb_struct_type_child_count(vectorLogicalType).int
    #echo childNcols
    #let vectorChild = vector.getChild(0)

    # get the data for each specific col in the struct
    var fields = new Fields
    for col in 0..<childNcols:
      var field = new Field
      field.vector = vector.getChild(col)
      field.data = duckdb_vector_get_data(field.vector.handle)
      field.validity = duckdb_vector_get_validity(field.vector.handle)
      field.typ = field.vector.getColumnType
      echo field.typ
      field.name = $duckdb_struct_type_child_name(vectorLogicalType, col.idx_t)
      
      fields.fields &= field
      fields.colNames &= field.name 
      fields.namecol[field.name] = col

    case typ
    of DUCKDB_TYPE_STRUCT:
      for row in 0..<n:
        if duckdb_validity_row_is_valid(validity, row.uint64):
          var tmp:Table[string, Option[Value]]
          for col in 0..<childNcols:
            let name = fields.colNames[col]
            let field = fields.fields[col]
            #var value:Value
            case field.typ
            of DUCKDB_TYPE_VARCHAR: #     of DUCKDB_TYPE_VARCHAR: stringVal: string
              let arr = cast[ptr UncheckedArray[duckdb_string_t]](field.data)
              if duckdb_validity_row_is_valid(field.validity, row.idx_t):
                var cad:string
                if duckdb_string_is_inlined(arr[row]): # inline
                  let pInlined = arr[row].value.inlined.inlined
                  cad = $cast[cstring](unsafeAddr(pInlined[0]))
                  #yield some($cast[cstring](unsafeAddr(pInlined[0])))
                  #tmp[name] = value
                else:
                  let nchars = arr[row].value.pointer_field.length
                  cad = $cast[cstring](arr[row].value.pointer_field.ptr_field)
                  setLen(cad, nchars)
                  #tmp[name] = some(tmp)
                #value = 
                tmp[name] = some( Value(kind: DUCKDB_TYPE_VARCHAR, stringVal: cad) )
              else:
                tmp[name] = none(Value)
            of DUCKDB_TYPE_INTEGER:
              var arr = cast[ptr UncheckedArray[int32]](field.data)
              var val:Option[Value]
              if duckdb_validity_row_is_valid(field.validity, row.idx_t):
                val = some( Value(kind: DUCKDB_TYPE_INTEGER, int32Val: arr[row]) )
              else:
                val = none(Value)

              tmp[name] = val
            else:
              discard
          yield some(tmp)
                          
        else:
          yield none(Table[string, Option[Value]])

    else:  # TODO: to consider all the others INTEGER types
      raise newException(ValueError, "type not supported: " & $typ)


#[
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
]#


#[
duckdb_logical_type duckdb_map_type_key_type(duckdb_logical_type type);
duckdb_logical_type duckdb_map_type_value_type(duckdb_logical_type type);
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










# proc getInt64*(s:DuckStruct; name:string):Option[int64] =
#   let fields = s.fields
#   let row = s.row
#   let col = fields.namecol[name]
#   var tmp = fields.fields[col]
#   assert tmp.typ == DUCKDB_TYPE_BIGINT
#   #var col = tmp.col

#   #let vCol = tmp.vector.getChild(col)
#   let vData = tmp.data #duckdb_vector_get_data(vCol.handle)
#   let vValidity = tmp.validity #duckdb_vector_get_validity(vCol.handle)


#   let vectorDataArray = cast[ptr UncheckedArray[int64]](vData)
#   #echo "----"
#   if duckdb_validity_row_is_valid(vValidity, row.uint64):
#     return some(vectorDataArray[row])
#   else:
#     return none(int64)
#   # for row in 0..<chunk.getSize():
#   #   if duckdb_validity_row_is_valid(vValidity, row.uint64):
#   #     #echo cast[ptr UncheckedArray[int64]](vectorData)[0]
#   #     yield some(vectorDataArray[row])
#   #   else:
#   #     yield none(int64)



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

