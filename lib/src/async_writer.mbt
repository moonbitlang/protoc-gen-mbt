///|
pub(open) trait AsyncWriter {
  async write(Self, @bytes.View) -> Unit raise
}

///|
pub async fn[T : AsyncWriter] async_write_varint(
  writer : T,
  input : UInt64,
) -> Unit raise {
  let mut v = input
  while v >= 0x80 {
    writer.write([(v.to_byte() & 0x7F) | 0x80])
    v = v >> 7
  }
  writer.write([v.to_byte()])
}

///|
pub async fn[T : AsyncWriter] async_write_tag(
  writer : T,
  tag : (UInt, UInt),
) -> Unit raise {
  let (tag, wire_type) = tag
  writer |> async_write_varint(((tag << 3) | wire_type).to_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_int32(
  writer : T,
  v : Int,
) -> Unit raise {
  writer |> async_write_varint(v.to_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_int64(
  writer : T,
  v : Int64,
) -> Unit raise {
  writer |> async_write_varint(v.reinterpret_as_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_uint32(
  writer : T,
  v : UInt,
) -> Unit raise {
  writer |> async_write_varint(v.to_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_uint64(
  writer : T,
  v : UInt64,
) -> Unit raise {
  writer |> async_write_varint(v)
}

///|
pub async fn[T : AsyncWriter] async_write_sint32(
  writer : T,
  v : Int,
) -> Unit raise {
  writer |> async_write_varint(((v << 1) ^ (v >> 31)).to_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_sint64(
  writer : T,
  v : Int64,
) -> Unit raise {
  writer |> async_write_varint(((v << 1) ^ (v >> 63)).reinterpret_as_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_fixed32(
  writer : T,
  v : UInt,
) -> Unit raise {
  let mut v = v
  for i in 0..<4 {
    writer.write([(v & 0xFF) |> UInt::to_byte()])
    v = v >> 8
  }
}

///|
pub async fn[T : AsyncWriter] async_write_fixed64(
  writer : T,
  v : UInt64,
) -> Unit raise {
  let mut v = v
  for i in 0..<8 {
    writer.write([(v & 0xFF) |> UInt64::to_byte()])
    v = v >> 8
  }
}

///|
pub async fn[T : AsyncWriter] async_write_sfixed32(
  writer : T,
  v : Int,
) -> Unit raise {
  writer |> async_write_fixed32(v.reinterpret_as_uint())
}

///|
pub async fn[T : AsyncWriter] async_write_sfixed64(
  writer : T,
  v : Int64,
) -> Unit raise {
  writer |> async_write_fixed64(v.reinterpret_as_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_float(
  writer : T,
  v : Float,
) -> Unit raise {
  writer |> async_write_fixed32(v.reinterpret_as_uint())
}

///|
pub async fn[T : AsyncWriter] async_write_double(
  writer : T,
  v : Double,
) -> Unit raise {
  writer |> async_write_fixed64(v.reinterpret_as_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_bool(
  writer : T,
  v : Bool,
) -> Unit raise {
  writer.write([if v { 1 } else { 0 }])
}

///|
pub async fn[T : AsyncWriter] async_write_enum(
  writer : T,
  v : Enum,
) -> Unit raise {
  writer |> async_write_varint(v.0.to_uint64())
}

///|
pub async fn[T : AsyncWriter] async_write_bytes(
  writer : T,
  v : Bytes,
) -> Unit raise {
  let length = v.length()
  writer |> async_write_varint(length.to_uint64())
  writer.write(v)
}

///|
pub async fn[T : AsyncWriter] async_write_string(
  writer : T,
  v : String,
) -> Unit raise {
  let utf8_string = @buffer.new()
  for ch in v {
    let ch = ch.to_int()
    if ch < 0x80 {
      utf8_string.write_byte(ch.to_byte())
    } else if ch < 0x800 {
      utf8_string.write_byte((0xC0 | (ch >> 6)).to_byte())
      utf8_string.write_byte((0x80 | (ch & 0x3F)).to_byte())
    } else if ch < 0x10000 {
      utf8_string.write_byte((0xE0 | (ch >> 12)).to_byte())
      utf8_string.write_byte((0x80 | ((ch >> 6) & 0x3F)).to_byte())
      utf8_string.write_byte((0x80 | (ch & 0x3F)).to_byte())
    } else {
      utf8_string.write_byte((0xF0 | (ch >> 18)).to_byte())
      utf8_string.write_byte((0x80 | ((ch >> 12) & 0x3F)).to_byte())
      utf8_string.write_byte((0x80 | ((ch >> 6) & 0x3F)).to_byte())
      utf8_string.write_byte((0x80 | (ch & 0x3F)).to_byte())
    }
  }
  let utf8_string = utf8_string.to_bytes()
  writer
  |> async_write_varint(utf8_string.length().reinterpret_as_uint().to_uint64())
  writer.write(utf8_string)
}
