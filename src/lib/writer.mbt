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

pub(open) trait Writer {
  write_byte(Self, Byte) -> Unit
  write_bytes(Self, Bytes) -> Unit
}

pub fn write_varint[T : Writer](writer : T, input : UInt64) -> Unit {
  let mut v = input
  while v >= 0x80 {
    writer.write_byte((v.to_byte() & 0x7F) | 0x80)
    v = v >> 7
  }
  writer.write_byte(v.to_byte())
}

pub fn write_tag[T : Writer](writer : T, tag : (UInt, UInt)) -> Unit {
  let (tag, wire_type) = tag
  writer |> write_varint(((tag << 3) | wire_type).to_uint64())
}

pub fn write_int32[T : Writer](writer : T, v : Int) -> Unit {
  writer |> write_varint(v.to_uint64())
}

pub fn write_int64[T : Writer](writer : T, v : Int64) -> Unit {
  writer |> write_varint(v.reinterpret_as_uint64())
}

pub fn write_uint32[T : Writer](writer : T, v : UInt) -> Unit {
  writer |> write_varint(v.to_uint64())
}

pub fn write_uint64[T : Writer](writer : T, v : UInt64) -> Unit {
  writer |> write_varint(v)
}

pub fn write_sint32[T : Writer](writer : T, v : Int) -> Unit {
  writer |> write_varint(((v << 1) ^ (v >> 31)).to_uint64())
}

pub fn write_sint64[T : Writer](writer : T, v : Int64) -> Unit {
  writer |> write_varint(((v << 1) ^ (v >> 63)).reinterpret_as_uint64())
}

pub fn write_fixed32[T : Writer](writer : T, v : UInt) -> Unit {
  let mut v = v
  for i in 0..<4 {
    writer.write_byte(v & 0xFF |> UInt::to_byte())
    v = v >> 8
  }
}

pub fn write_fixed64[T : Writer](writer : T, v : UInt64) -> Unit {
  let mut v = v
  for i in 0..<8 {
    writer.write_byte(v & 0xFF |> UInt64::to_byte())
    v = v >> 8
  }
}

pub fn write_sfixed32[T : Writer](writer : T, v : Int) -> Unit {
  writer |> write_fixed32(v.reinterpret_as_uint())
}

pub fn write_sfixed64[T : Writer](writer : T, v : Int64) -> Unit {
  writer |> write_fixed64(v.reinterpret_as_uint64())
}

pub fn write_float[T : Writer](writer : T, v : Float) -> Unit {
  writer |> write_fixed32(v.reinterpret_as_uint())
}

pub fn write_double[T : Writer](writer : T, v : Double) -> Unit {
  writer |> write_fixed64(v.reinterpret_as_uint64())
}

pub fn write_bool[T : Writer](writer : T, v : Bool) -> Unit {
  writer.write_byte(if v { 1 } else { 0 })
}

pub fn write_enum[T : Writer](writer : T, v : Enum) -> Unit {
  writer |> write_varint(v._.to_uint64())
}

pub fn write_bytes[T : Writer](writer : T, v : Bytes) -> Unit {
  let length = v.length()
  writer |> write_varint(length.to_uint64())
  writer.write_bytes(v)
}

pub fn write_string[T : Writer](writer : T, v : String) -> Unit {
  let utf8_string = @buffer.Buffer::new()
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
  writer |> write_varint(utf8_string.length().reinterpret_as_uint().to_uint64())
  writer.write_bytes(utf8_string)
}
