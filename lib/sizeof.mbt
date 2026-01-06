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
  size_of(Self) -> UInt
}

///|
pub fn[T : Sized] size_of(t : T) -> UInt {
  t.size_of()
}

///|
fn size_of_varint(v : UInt64) -> UInt {
  if v < 0x80 {
    1
  } else if v < 0x3FFF {
    2
  } else if v < 0x1FFFFF {
    3
  } else if v < 0xFFFFFFF {
    4
  } else if v < 0x7FFFFFFFF {
    5
  } else if v < 0x3FFFFFFFFFF {
    6
  } else if v < 0x1FFFFFFFFFFFF {
    7
  } else if v < 0xFFFFFFFFFFFFFF {
    8
  } else if v < 0x7FFFFFFFFFFFFFFF {
    9
  } else {
    10
  }
}

///|
pub impl Sized for UInt with size_of(self) {
  size_of_varint(self.to_uint64())
}

///|
pub impl Sized for UInt64 with size_of(self) {
  size_of_varint(self)
}

///|
pub impl Sized for Int with size_of(self) {
  size_of_varint(self.to_int64().reinterpret_as_uint64())
}

///|
pub impl Sized for Int64 with size_of(self) {
  size_of_varint(self.reinterpret_as_uint64())
}

///|
pub impl Sized for SInt with size_of(self) {
  size_of_varint(
    ((self.0 << 1) ^ (self.0 >> 31)).reinterpret_as_uint().to_uint64(),
  )
}

///|
pub impl Sized for SInt64 with size_of(self) {
  size_of_varint(((self.0 << 1) ^ (self.0 >> 63)).reinterpret_as_uint64())
}

///|
pub impl Sized for Bool with size_of(__) {
  1
}

///|
pub impl Sized for Enum with size_of(self) {
  size_of_varint(self.0.to_int64().reinterpret_as_uint64())
}

///|
pub impl Sized for Float with size_of(__) {
  4
}

///|
pub impl Sized for Double with size_of(__) {
  8
}

///|
pub impl Sized for Bytes with size_of(self) {
  self.length().reinterpret_as_uint()
}

///|
pub impl Sized for String with size_of(self) {
  self
  .iterator()
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
