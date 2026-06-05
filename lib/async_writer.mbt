///|
pub(open) trait AsyncWriter {
  async fn write(Self, BytesView) -> Unit
}

///|
pub async fn[T : AsyncWriter] async_write_varint(
  writer : T,
  input : UInt64,
) -> Unit {
  let mut v = input >> 7
  let mut length = 0
  while v > 0 {
    v = v >> 7
    length += 1
  }
  let bytes = Bytes::makei(length + 1, fn(i) {
    let byte = ((input >> (i * 7)) & 0x7F).to_byte()
    if i == length {
      byte
    } else {
      byte | 0x80
    }
  })
  writer.write(bytes)
}

///|
pub async fn[T : AsyncWriter] async_write_tag(
  writer : T,
  tag : (UInt, UInt),
) -> Unit {
  let (tag, wire_type) = tag
  writer |> async_write_varint(((tag << 3) | wire_type).to_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_int32(writer : T, v : Int) -> Unit {
  writer |> async_write_varint(v.to_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_int64(writer : T, v : Int64) -> Unit {
  writer |> async_write_varint(v.reinterpret_as_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_uint32(writer : T, v : UInt) -> Unit {
  writer |> async_write_varint(v.to_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_uint64(
  writer : T,
  v : UInt64,
) -> Unit {
  writer |> async_write_varint(v)
}

///|
pub async fn[T : AsyncWriter] async_write_sint32(writer : T, v : Int) -> Unit {
  let v64 = v.to_int64()
  writer
  |> async_write_varint(((v64 << 1) ^ (v64 >> 31)).reinterpret_as_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_sint64(writer : T, v : Int64) -> Unit {
  writer |> async_write_varint(((v << 1) ^ (v >> 63)).reinterpret_as_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_fixed32(writer : T, v : UInt) -> Unit {
  writer.write(Bytes::makei(4, fn(i) { ((v >> (i * 8)) & 0xFF).to_byte() }))
}

///|
pub async fn[T : AsyncWriter] async_write_fixed64(
  writer : T,
  v : UInt64,
) -> Unit {
  writer.write(Bytes::makei(8, fn(i) { ((v >> (i * 8)) & 0xFF).to_byte() }))
}

///|
pub async fn[T : AsyncWriter] async_write_sfixed32(writer : T, v : Int) -> Unit {
  writer |> async_write_fixed32(v.reinterpret_as_uint())
}

///|
pub async fn[T : AsyncWriter] async_write_sfixed64(
  writer : T,
  v : Int64,
) -> Unit {
  writer |> async_write_fixed64(v.reinterpret_as_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_float(writer : T, v : Float) -> Unit {
  writer |> async_write_fixed32(v.reinterpret_as_uint())
}

///|
pub async fn[T : AsyncWriter] async_write_double(
  writer : T,
  v : Double,
) -> Unit {
  writer |> async_write_fixed64(v.reinterpret_as_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_bool(writer : T, v : Bool) -> Unit {
  writer.write([if v { 1 } else { 0 }])
}

///|
pub async fn[T : AsyncWriter] async_write_enum(writer : T, v : Enum) -> Unit {
  writer |> async_write_varint(v.0.to_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_bytes(writer : T, v : Bytes) -> Unit {
  let length = v.length()
  writer |> async_write_varint(length.to_uint64())
  writer.write(v)
}

///|
pub async fn[T : AsyncWriter] async_write_string(
  writer : T,
  v : String,
) -> Unit {
  let utf8_string = encode_utf8_string(v)
  writer
  |> async_write_varint(utf8_string.length().reinterpret_as_uint().to_uint64())
  writer.write(utf8_string)
}
