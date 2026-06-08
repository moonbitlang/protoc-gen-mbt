// Copyright 2024 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
/// Trait representing the Writer
pub(open) trait Writer {
  fn write(Self, BytesView) -> Unit raise
}

///|
pub fn[T : Writer] write_varint(writer : T, input : UInt64) -> Unit raise {
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
pub fn[T : Writer] write_tag(writer : T, tag : (UInt, UInt)) -> Unit raise {
  let (tag, wire_type) = tag
  writer |> write_varint(((tag << 3) | wire_type).to_uint64())
}

///|
pub fn[T : Writer] write_int32(writer : T, v : Int) -> Unit raise {
  writer |> write_varint(v.to_uint64())
}

///|
pub fn[T : Writer] write_int64(writer : T, v : Int64) -> Unit raise {
  writer |> write_varint(v.reinterpret_as_uint64())
}

///|
pub fn[T : Writer] write_uint32(writer : T, v : UInt) -> Unit raise {
  writer |> write_varint(v.to_uint64())
}

///|
pub fn[T : Writer] write_uint64(writer : T, v : UInt64) -> Unit raise {
  writer |> write_varint(v)
}

///|
pub fn[T : Writer] write_sint32(writer : T, v : Int) -> Unit raise {
  let v64 = v.to_int64()
  writer |> write_varint(((v64 << 1) ^ (v64 >> 31)).reinterpret_as_uint64())
}

///|
pub fn[T : Writer] write_sint64(writer : T, v : Int64) -> Unit raise {
  writer |> write_varint(((v << 1) ^ (v >> 63)).reinterpret_as_uint64())
}

///|
pub fn[T : Writer] write_fixed32(writer : T, v : UInt) -> Unit raise {
  writer.write(Bytes::makei(4, fn(i) { ((v >> (i * 8)) & 0xFF).to_byte() }))
}

///|
pub fn[T : Writer] write_fixed64(writer : T, v : UInt64) -> Unit raise {
  writer.write(Bytes::makei(8, fn(i) { ((v >> (i * 8)) & 0xFF).to_byte() }))
}

///|
pub fn[T : Writer] write_sfixed32(writer : T, v : Int) -> Unit raise {
  writer |> write_fixed32(v.reinterpret_as_uint())
}

///|
pub fn[T : Writer] write_sfixed64(writer : T, v : Int64) -> Unit raise {
  writer |> write_fixed64(v.reinterpret_as_uint64())
}

///|
pub fn[T : Writer] write_float(writer : T, v : Float) -> Unit raise {
  writer |> write_fixed32(v.reinterpret_as_uint())
}

///|
pub fn[T : Writer] write_double(writer : T, v : Double) -> Unit raise {
  writer |> write_fixed64(v.reinterpret_as_uint64())
}

///|
pub fn[T : Writer] write_bool(writer : T, v : Bool) -> Unit raise {
  writer.write([if v { 1 } else { 0 }])
}

///|
pub fn[T : Writer] write_enum(writer : T, v : Enum) -> Unit raise {
  writer |> write_varint(v.0.to_uint64())
}

///|
pub fn[T : Writer] write_bytes(writer : T, v : Bytes) -> Unit raise {
  let length = v.length()
  writer |> write_varint(length.to_uint64())
  writer.write(v)
}

///|
pub fn[T : Writer] write_string(writer : T, v : String) -> Unit raise {
  let utf8_string = encode_utf8_string(v)
  writer |> write_varint(utf8_string.length().reinterpret_as_uint().to_uint64())
  writer.write(utf8_string)
}

///|
/// Writes a length-delimited embedded message with a size prefix.
pub fn[M : Write + Sized, T : Writer] write_message(
  writer : T,
  message : M,
) -> Unit raise {
  writer |> write_uint32(size_of(message))
  Write::write(message, writer)
}

///|
/// Writes a delimited message field envelope for `field_number`.
///
/// The encoded form is start-group tag, message payload, then the matching
/// end-group tag. Generated code uses this for proto2 groups and Editions
/// `features.message_encoding = DELIMITED`.
pub fn[M : Write, T : Writer] write_delimited_message(
  writer : T,
  field_number : UInt,
  message : M,
) -> Unit raise {
  writer |> write_tag((field_number, WIRE_TYPE_START_GROUP))
  Write::write(message, writer)
  writer |> write_tag((field_number, WIRE_TYPE_END_GROUP))
}
