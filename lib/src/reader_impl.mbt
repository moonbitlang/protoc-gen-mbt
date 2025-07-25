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
pub(all) suberror ReaderError {
  EndOfStream
  InvalidString
  UnknownWireType(UInt)
} derive(Eq, Show)

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
pub impl Reader for BytesReader with read(
  self,
  bytes : FixedArray[Byte],
  offset~ : Int,
  max_length~ : Int,
) -> Int? {
  if offset >= self.len || max_length <= 0 || self.start >= self.len {
    return None
  }
  let offset = offset % bytes.length()
  let read_length = @cmp.minimum(
    @cmp.minimum(bytes.length() - offset, max_length),
    self.len - self.start,
  )
  bytes.blit_from_bytes(offset, self.data, self.start, read_length)
  self.start += read_length
  Some(read_length)
}

///|
pub impl AsyncReader for BytesReader with read(
  self,
  bytes : FixedArray[Byte],
  offset~ : Int,
  max_length~ : Int,
) -> Int? raise {
  @async.pause()
  if offset >= bytes.length() || max_length <= 0 || self.start >= self.len {
    return None
  }
  let read_length = @cmp.minimum(
    @cmp.minimum(bytes.length() - offset, max_length),
    self.len - self.start,
  )
  bytes.blit_from_bytes(offset, self.data, self.start, read_length)
  self.start += read_length
  Some(read_length)
}

///|
pub(all) struct LimitedReader[T] {
  reader : T
  mut limit : Int?
}

///|
pub fn[T] LimitedReader::new(reader : T, limit? : Int) -> LimitedReader[T] {
  { reader, limit }
}

///|
pub impl[T : Reader] Reader for LimitedReader[T] with read(
  self,
  bytes : FixedArray[Byte],
  offset~ : Int,
  max_length~ : Int,
) -> Int? {
  if self.limit is Some(0) {
    return None
  }
  let max_length = if self.limit is Some(limit) {
    @cmp.minimum(limit, max_length)
  } else {
    max_length
  }
  let read_length = self.reader.read(bytes, offset~, max_length~)
  if read_length is Some(length) && self.limit is Some(limit) {
    self.limit = Some(limit - length)
  }
  read_length
}

///|
pub impl[T : AsyncReader] AsyncReader for LimitedReader[T] with read(
  self,
  bytes : FixedArray[Byte],
  offset~ : Int,
  max_length~ : Int,
) -> Int? raise {
  if self.limit is Some(0) {
    return None
  }
  let max_length = if self.limit is Some(limit) {
    @cmp.minimum(limit, max_length)
  } else {
    max_length
  }
  let read_length = self.reader.read(bytes, offset~, max_length~)
  if read_length is Some(length) && self.limit is Some(limit) {
    self.limit = Some(limit - length)
  }
  read_length
}
