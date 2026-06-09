///|
pub(open) trait AsyncReader {
  async fn read(Self, FixedArray[Byte], offset~ : Int, max_length~ : Int) -> Int?
}

///|
async fn[T : AsyncReader] async_read_byte(reader : T) -> Byte {
  let varint_bytes : FixedArray[Byte] = FixedArray::make(1, 0)
  match reader.read(varint_bytes, offset=0, max_length=1) {
    Some(1) => varint_bytes[0]
    _ => raise EndOfStream
  }
}

///|
async fn[T : AsyncReader] async_read_exactly(
  reader : T,
  bytes : FixedArray[Byte],
  offset~ : Int,
  length~ : Int,
) -> Unit {
  let mut read_length = 0
  while read_length < length {
    match
      reader.read(
        bytes,
        offset=offset + read_length,
        max_length=length - read_length,
      ) {
      Some(len) => {
        if len <= 0 {
          raise EndOfStream
        }
        read_length += len
      }
      None => raise EndOfStream
    }
  }
}

///|
pub async fn[T : AsyncReader] async_read_tag(reader : T) -> (UInt, UInt) {
  let value = reader |> async_read_varint32()
  let tag = value >> 3
  let wire_type = value & 0x7
  if wire_type > WIRE_TYPE_FIXED32 {
    raise ReaderError::UnknownWireType(wire_type)
  }
  (tag, wire_type)
}

///|
pub async fn[T : AsyncReader] async_read_varint32(reader : T) -> UInt {
  let mut b = 0U
  for i in 0..<5 {
    let byte = reader |> async_read_byte() |> Byte::to_uint()
    if i == 4 && byte > 0x0FU {
      raise ReaderError::OverlongVarint
    }
    b = ((byte & 0x7F) << (i * 7)) | b
    if (byte & 0x80) == 0 {
      return b
    }
  } nobreak {
    raise ReaderError::OverlongVarint
  }
}

///|
async fn[T : AsyncReader] async_read_varint64(reader : T) -> UInt64 {
  let mut b = 0UL
  for i in 0..<10 {
    let byte = reader |> async_read_byte() |> Byte::to_uint64()
    if i == 9 && byte > 0x01UL {
      raise ReaderError::OverlongVarint
    }
    b = ((byte & 0x7F) << (i * 7)) | b
    if (byte & 0x80) == 0 {
      return b
    }
  } nobreak {
    raise ReaderError::OverlongVarint
  }
}

///|
pub async fn[T : AsyncReader] async_read_int32(reader : T) -> Int {
  // if integer is negative, varint32 is encoded as 10 bytes
  reader |> async_read_varint64() |> UInt64::to_int()
}

///|
pub async fn[T : AsyncReader] async_read_int64(reader : T) -> Int64 {
  reader |> async_read_varint64() |> UInt64::reinterpret_as_int64()
}

///|
pub async fn[T : AsyncReader] async_read_uint32(reader : T) -> UInt {
  reader |> async_read_varint32()
}

///|
pub async fn[T : AsyncReader] async_read_uint64(reader : T) -> UInt64 {
  reader |> async_read_varint64()
}

///|
pub async fn[T : AsyncReader] async_read_sint32(reader : T) -> SInt {
  let n = reader |> async_read_varint32()
  // zigzag encoding
  (n >> 1).reinterpret_as_int() ^ -(n & 1).reinterpret_as_int()
}

///|
pub async fn[T : AsyncReader] async_read_sint64(reader : T) -> SInt64 {
  let n = reader |> async_read_varint64()
  // zigzag encoding
  (n >> 1).reinterpret_as_int64() ^ -(n & 1).reinterpret_as_int64()
}

///|
pub async fn[T : AsyncReader] async_read_fixed32(reader : T) -> UInt {
  let varint_bytes : FixedArray[Byte] = FixedArray::make(4, 0)
  reader |> async_read_exactly(varint_bytes, offset=0, length=4)
  let mut v : UInt = 0
  for i in 0..<4 {
    v = v | (varint_bytes[i].to_uint() << (i * 8))
  }
  v
}

///|
pub async fn[T : AsyncReader] async_read_fixed64(reader : T) -> UInt64 {
  let varint_bytes : FixedArray[Byte] = FixedArray::make(8, 0)
  reader |> async_read_exactly(varint_bytes, offset=0, length=8)
  let mut v : UInt64 = 0
  for i in 0..<8 {
    v = v | (varint_bytes[i].to_uint64() << (i * 8))
  }
  v
}

///|
pub async fn[T : AsyncReader] async_read_sfixed32(reader : T) -> Int {
  reader |> async_read_fixed32() |> UInt::reinterpret_as_int
}

///|
pub async fn[T : AsyncReader] async_read_sfixed64(reader : T) -> Int64 {
  reader |> async_read_fixed64() |> UInt64::reinterpret_as_int64
}

///|
pub async fn[T : AsyncReader] async_read_float(reader : T) -> Float {
  reader |> async_read_sfixed32() |> Float::reinterpret_from_int
}

///|
pub async fn[T : AsyncReader] async_read_double(reader : T) -> Double {
  reader |> async_read_sfixed64() |> Int64::reinterpret_as_double
}

///|
pub async fn[T : AsyncReader] async_read_bool(reader : T) -> Bool {
  (reader |> async_read_varint32()) != 0
}

///|
pub async fn[T : AsyncReader] async_read_enum(reader : T) -> Enum {
  reader |> async_read_uint32()
}

///|
pub async fn[T : AsyncReader] async_read_bytes(reader : T) -> Bytes {
  let length = reader |> async_read_int32()
  if length < 0 {
    raise ReaderError::InvalidLength
  }
  let bytes : FixedArray[Byte] = FixedArray::make(length, 0)
  reader |> async_read_exactly(bytes, offset=0, length~)
  bytes.unsafe_reinterpret_as_bytes()
}

///|
pub async fn[T : AsyncReader] async_read_string(reader : T) -> String {
  reader |> async_read_bytes() |> decode_utf8_string()
}

///|
/// Reads a length-delimited embedded message after its size prefix.
pub async fn[M : AsyncRead + Default] async_read_message(
  reader : LimitedReader[&AsyncReader],
) -> M {
  let len = reader |> async_read_int32()
  if len < 0 {
    raise ReaderError::InvalidLength
  }
  match len {
    0 => M::default()
    _ => {
      let new_limit = if reader.limit is Some(l) {
        if l < len {
          raise EndOfStream
        }
        Some(l - len)
      } else {
        None
      }
      reader.limit = Some(len)
      let previous_end_group = reader.end_group
      let previous_end_group_seen = reader.end_group_seen
      reader.end_group = None
      reader.end_group_seen = false
      let msg = try reader |> M::read_with_limit() catch {
        err => {
          reader.limit = new_limit
          reader.end_group = previous_end_group
          reader.end_group_seen = previous_end_group_seen
          raise err
        }
      }
      reader.end_group = previous_end_group
      reader.end_group_seen = previous_end_group_seen
      reader.limit = new_limit
      msg
    }
  }
}

///|
/// Reads a delimited message payload after its start-group tag has already
/// been consumed, then consumes the matching end-group tag for `field_number`.
///
/// This helper is used by generated code for proto2 groups and Editions
/// `features.message_encoding = DELIMITED`.
pub async fn[M : AsyncRead] async_read_delimited_message(
  reader : LimitedReader[&AsyncReader],
  field_number : UInt,
) -> M {
  let previous_end_group = reader.end_group
  let previous_end_group_seen = reader.end_group_seen
  reader.end_group = Some(field_number)
  reader.end_group_seen = false
  let msg = try {
    let msg = reader |> M::read_with_limit()
    if !reader.end_group_seen {
      reader |> async_read_delimited_message_tail(field_number)
    }
    msg
  } catch {
    err => {
      reader.end_group = previous_end_group
      reader.end_group_seen = previous_end_group_seen
      raise err
    }
  }
  let end_group_seen = reader.end_group_seen
  reader.end_group = previous_end_group
  reader.end_group_seen = previous_end_group_seen
  if !end_group_seen {
    raise EndOfStream
  }
  msg
}

///|
async fn[T : AsyncReader] async_read_delimited_message_tail(
  reader : LimitedReader[T],
  field_number : UInt,
) -> Unit {
  while !reader.end_group_seen {
    let next = Some(reader |> async_read_tag()) catch {
      EndOfStream => None
      err => raise err
    }
    match next {
      Some((nested_field_number, WIRE_TYPE_END_GROUP)) =>
        if nested_field_number == field_number {
          reader.end_group_seen = true
        } else {
          raise ReaderError::UnknownWireType(WIRE_TYPE_END_GROUP)
        }
      Some((nested_field_number, nested_wire_type)) =>
        reader
        |> async_skip_message_field_by_number(
          nested_field_number, nested_wire_type,
        )
      None => break
    }
  }
}

///|
/// Reads the next field number and wire type within a message body.
///
/// Returns `None` at the end of a length-delimited message or after consuming
/// the matching end-group tag for a delimited message.
pub async fn[R : AsyncReader] async_read_next_message_field(
  reader : LimitedReader[R],
) -> (UInt, UInt)? {
  Some(
    {
      let (field_number, wire) = reader |> async_read_tag()
      if wire == WIRE_TYPE_END_GROUP {
        match reader.end_group {
          Some(end_group) if field_number == end_group => {
            reader.end_group_seen = true
            return None
          }
          _ => raise ReaderError::UnknownWireType(wire)
        }
      }
      (field_number, wire)
    },
  ) catch {
    EndOfStream => None
    err => raise err
  }
}

///|
/// Reads packed repeated field (Array[M])
///
/// Note: packed field are stored as a variable length chunk of data, while regular repeated
/// fields behaves like an iterator, yielding their tag everytime
pub async fn[M : Sized, R : AsyncReader] async_read_packed(
  reader : R,
  async_read_fn : async (LimitedReader[R]) -> M,
  size : UInt?,
) -> Array[M] {
  let len = reader |> async_read_varint32()
  let array = []
  let reader = LimitedReader::new(reader, limit=len.reinterpret_as_int())
  match size {
    Some(size) => {
      if len % size != 0U {
        raise ReaderError::InvalidPackedLength
      }
      for i = 0U; i < len / size; i = i + 1 {
        array.push(reader |> async_read_fn())
      }
    }
    None =>
      for i = 0U; i < len; {
        let value = reader |> async_read_fn()
        let size = Sized::size_of(value)
        array.push(value)
        continue i + size
      }
  }
  array
}

///|
/// Skips an unknown non-group field payload by wire type.
///
/// Use `async_skip_message_field_by_number` while parsing message bodies so
/// unknown group fields can be skipped with their matching end-group field
/// number.
pub async fn[T : AsyncReader] async_read_unknown(
  reader : T,
  wire_type : UInt,
) -> Unit {
  match wire_type {
    WIRE_TYPE_VARINT => reader |> async_read_varint64() |> ignore
    WIRE_TYPE_FIXED64 => reader |> async_read_fixed64() |> ignore
    WIRE_TYPE_LENGTH_DELIMITED => reader |> async_read_bytes() |> ignore
    WIRE_TYPE_FIXED32 => reader |> async_read_fixed32() |> ignore
    _ => raise ReaderError::UnknownWireType(wire_type)
  }
}

///|
async fn[T : AsyncReader] async_read_unknown_field(
  reader : T,
  field_number : UInt,
  wire_type : UInt,
) -> Unit {
  match wire_type {
    WIRE_TYPE_START_GROUP =>
      while true {
        let (nested_field_number, nested_wire_type) = reader |> async_read_tag()
        if nested_wire_type == WIRE_TYPE_END_GROUP {
          if nested_field_number == field_number {
            return
          }
          raise ReaderError::UnknownWireType(nested_wire_type)
        }
        reader
        |> async_read_unknown_field(nested_field_number, nested_wire_type)
      }
    WIRE_TYPE_END_GROUP => raise ReaderError::UnknownWireType(wire_type)
    _ => reader |> async_read_unknown(wire_type)
  }
}

///|
/// Skips an unknown non-group message field by wire type.
///
/// This legacy helper cannot skip `WIRE_TYPE_START_GROUP` fields because the
/// matching end-group tag requires the field number.
pub async fn[T : AsyncReader] async_skip_message_field(
  reader : T,
  wire_type : UInt,
) -> Unit {
  reader |> async_read_unknown(wire_type)
}

///|
/// Skips an unknown message field by field number and wire type.
///
/// Unlike `async_skip_message_field`, this handles `WIRE_TYPE_START_GROUP`
/// fields by reading nested fields until the matching `WIRE_TYPE_END_GROUP`
/// tag is found.
pub async fn[T : AsyncReader] async_skip_message_field_by_number(
  reader : T,
  field_number : UInt,
  wire_type : UInt,
) -> Unit {
  reader |> async_read_unknown_field(field_number, wire_type)
}
