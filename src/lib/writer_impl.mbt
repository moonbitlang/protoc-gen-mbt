pub impl Writer for @buffer.Buffer with write_byte(self, b : Byte) {
  self.write_byte(b)
}

pub impl Writer for @buffer.Buffer with write_bytes(self, bytes : Bytes) {
  self.write_bytes(bytes)
}
