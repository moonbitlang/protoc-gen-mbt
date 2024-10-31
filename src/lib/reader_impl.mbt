struct BytesReader {
  data : Bytes
  len : Int
  mut start : Int
} derive(Show)

pub fn BytesReader::from_bytes(data : Bytes) -> BytesReader {
  { data, len: data.length(), start: 0 }
}

pub impl Reader for BytesReader with next(self) {
  if self.start >= self.len {
    return None
  }
  let b = self.data[self.start]
  self.start += 1
  Some(b)
}

pub impl Reader for BytesReader with next_bytes(self, n : UInt) {
  if self.start >= self.len || self.start + n.reinterpret_as_int() > self.len {
    return None
  }
  if n <= 0 {
    return Some(Bytes::new(0))
  }
  let b = Bytes::new(n.reinterpret_as_int())
  b.blit(0, self.data, self.start, n.reinterpret_as_int())
  self.start += n.reinterpret_as_int()
  Some(b)
}
