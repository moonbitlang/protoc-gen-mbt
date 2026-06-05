///|
fn decode_utf8_string(bytes : BytesView) -> String raise {
  @utf8.decode(bytes) catch {
    @utf8.Malformed(_) => raise ReaderError::InvalidString
  }
}

///|
fn encode_utf8_string(string : String) -> Bytes {
  @utf8.encode(string)
}
