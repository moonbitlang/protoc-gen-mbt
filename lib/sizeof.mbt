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
pub(open) trait Sized {
  fn size_of(Self) -> UInt
}

///|
pub fn[T : Sized] size_of(t : T) -> UInt {
  t.size_of()
}

///|
pub fn size_of_field(tag_size : UInt, payload_size : UInt) -> UInt {
  tag_size + payload_size
}

///|
pub fn size_of_length_delimited(payload_size : UInt) -> UInt {
  size_of(payload_size) + payload_size
}

///|
pub fn size_of_length_delimited_field(
  tag_size : UInt,
  payload_size : UInt,
) -> UInt {
  tag_size + size_of_length_delimited(payload_size)
}

///|
fn size_of_varint(v : UInt64) -> UInt {
  if v < 0x80UL {
    1
  } else if v < 0x4000UL {
    2
  } else if v < 0x200000UL {
    3
  } else if v < 0x10000000UL {
    4
  } else if v < 0x800000000UL {
    5
  } else if v < 0x40000000000UL {
    6
  } else if v < 0x2000000000000UL {
    7
  } else if v < 0x100000000000000UL {
    8
  } else if v < 0x8000000000000000UL {
    9
  } else {
    10
  }
}

///|
pub impl Sized for UInt with fn size_of(self) {
  size_of_varint(self.to_uint64())
}

///|
pub impl Sized for UInt64 with fn size_of(self) {
  size_of_varint(self)
}

///|
pub impl Sized for Int with fn size_of(self) {
  size_of_varint(self.to_int64().reinterpret_as_uint64())
}

///|
pub impl Sized for Int64 with fn size_of(self) {
  size_of_varint(self.reinterpret_as_uint64())
}

///|
pub impl Sized for SInt with fn size_of(self) {
  let v64 = self.0.to_int64()
  size_of_varint(((v64 << 1) ^ (v64 >> 31)).reinterpret_as_uint64())
}

///|
pub impl Sized for SInt64 with fn size_of(self) {
  size_of_varint(((self.0 << 1) ^ (self.0 >> 63)).reinterpret_as_uint64())
}

///|
pub impl Sized for Bool with fn size_of(__) {
  1
}

///|
pub impl Sized for Enum with fn size_of(self) {
  size_of_varint(self.0.to_int64().reinterpret_as_uint64())
}

///|
pub impl Sized for Float with fn size_of(__) {
  4
}

///|
pub impl Sized for Double with fn size_of(__) {
  8
}

///|
pub impl Sized for Bytes with fn size_of(self) {
  self.length().reinterpret_as_uint()
}

///|
pub impl Sized for String with fn size_of(self) {
  self
  .iter()
  .map(ch => {
    let point = ch.to_int()
    if point <= 0x007F {
      1U
    } else if point <= 0x07FF {
      2
    } else if point <= 0xFFFF {
      3
    } else {
      4
    }
  })
  .fold(init=0, UInt::add)
}
