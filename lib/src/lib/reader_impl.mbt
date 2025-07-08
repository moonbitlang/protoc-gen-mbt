// Copyright 2025 International Digital Economy Academy
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
struct BytesReader {
  data : Bytes
  len : Int
  mut start : Int
} derive(Show)

///|
pub fn BytesReader::from_bytes(data : Bytes) -> BytesReader {
  { data, len: data.length(), start: 0 }
}

///|
pub impl Reader for BytesReader with next(self) {
  if self.start >= self.len {
    return None
  }
  let b = self.data[self.start]
  self.start += 1
  Some(b)
}

///|
pub impl Reader for BytesReader with next_bytes(self, n : UInt) {
  if self.start >= self.len || self.start + n.reinterpret_as_int() > self.len {
    return None
  }
  if n <= 0 {
    return Some(Bytes::new(0))
  }
  let b = FixedArray::make(n.reinterpret_as_int(), b'\x00')
  b.blit_from_bytes(0, self.data, self.start, n.reinterpret_as_int())
  self.start += n.reinterpret_as_int()
  Some(Bytes::from_fixedarray(b))
}
