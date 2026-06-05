///|
pub fn base64_encode(data : Bytes) -> String {
  let base64 = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  let buf = StringBuilder::new()
  let len = data.length()
  let rem = len % 3
  for i = 0; i < len - rem; i = i + 3 {
    let b0 = data[i].to_int()
    let b1 = data[i + 1].to_int()
    let b2 = data[i + 2].to_int()
    let x0 = base64[(b0 & 0xFC) >> 2]
    let x1 = base64[((b0 & 0x03) << 4) | ((b1 & 0xF0) >> 4)]
    let x2 = base64[((b1 & 0x0F) << 2) | ((b2 & 0xC0) >> 6)]
    let x3 = base64[b2 & 0x3F]
    buf.write_char(x0.to_char())
    buf.write_char(x1.to_char())
    buf.write_char(x2.to_char())
    buf.write_char(x3.to_char())
  }
  if rem == 1 {
    let b0 = data[len - 1].to_int()
    let x0 = base64[(b0 & 0xFC) >> 2]
    let x1 = base64[(b0 & 0x03) << 4]
    buf.write_char(x0.to_char())
    buf.write_char(x1.to_char())
    buf.write_char('=')
    buf.write_char('=')
  } else if rem == 2 {
    let b0 = data[len - 2].to_int()
    let b1 = data[len - 1].to_int()
    let x0 = base64[(b0 & 0xFC) >> 2]
    let x1 = base64[((b0 & 0x03) << 4) | ((b1 & 0xF0) >> 4)]
    let x2 = base64[(b1 & 0x0F) << 2]
    buf.write_char(x0.to_char())
    buf.write_char(x1.to_char())
    buf.write_char(x2.to_char())
    buf.write_char('=')
  }
  buf.to_string()
}

///|
pub fn base64_decode(s : String) -> Bytes raise {
  let base64 = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  let input_length = s.length()
  if input_length == 0 {
    return Bytes::new(0)
  }
  if input_length % 4 != 0 {
    raise ReaderError::InvalidBase64
  }
  let padding_start = match s {
    [.., '=', '='] => input_length - 2
    [.., '='] => input_length - 1
    _ => input_length
  }
  let padding_length = input_length - padding_start
  let output_length = input_length / 4 * 3 - padding_length
  let buf = Array::new(capacity=output_length)
  let rev_table : Array[Byte] = Array::make(256, 0)
  let valid_table : Array[Bool] = Array::make(256, false)
  for j = 0; j < 64; j = j + 1 {
    rev_table[base64[j].to_int()] = j.to_byte()
    valid_table[base64[j].to_int()] = true
  }
  let get_char = fn(i : Int) -> Byte raise {
    match s.get_char(i) {
      None => raise ReaderError::InvalidBase64
      Some('=') =>
        if i < padding_start {
          raise ReaderError::InvalidBase64
        } else {
          0
        }
      Some(ch) => {
        let code = ch.to_int()
        if code >= 256 || !valid_table[code] {
          raise ReaderError::InvalidBase64
        }
        rev_table[code]
      }
    }
  }
  for i = 0; i < input_length; i = i + 4 {
    let b0 = get_char(i)
    let b1 = get_char(i + 1)
    let b2 = get_char(i + 2)
    let b3 = get_char(i + 3)
    let triplet = (b0.to_int() << 18) |
      (b1.to_int() << 12) |
      (b2.to_int() << 6) |
      b3.to_int()
    for j = 2; j >= 0 && buf.length() < output_length; j = j - 1 {
      buf.push((triplet >> (j * 8)).to_byte())
    }
  }
  Bytes::from_array(buf)
}

///|
fn expect_invalid_base64(s : String) -> Unit raise {
  try {
    let _ = base64_decode(s)
    fail("expected InvalidBase64")
  } catch {
    ReaderError::InvalidBase64 => ()
    err => raise err
  }
}

///|
test "decode/encode" {
  let data = b"Hello, World!"
  let encoded = base64_encode(data)
  inspect(encoded, content="SGVsbG8sIFdvcmxkIQ==")
  let decoded = base64_decode(encoded)
  inspect(
    decoded,
    content=(
      #|b"Hello, World!"
    ),
  )
  @debug.assert_eq(data, decoded)
}

///|
test "decode/encode emoji" {
  let data = b"\xf0\x9f\x98\x80" // 😀
  let encoded = base64_encode(data)
  inspect(encoded, content="8J+YgA==")
  let decoded = base64_decode(encoded)
  inspect(
    decoded,
    content=(
      #|b"\xf0\x9f\x98\x80"
    ),
  )
  @debug.assert_eq(data, decoded)
}

///|
test "decode/empty string" {
  let decoded = base64_decode("")
  inspect(decoded, content="b\"\"")
}

///|
test "decode/invalid length" {
  expect_invalid_base64("abc")
}

///|
test "decode/invalid characters" {
  expect_invalid_base64("a!b=")
}

///|
test "decode/invalid padding" {
  expect_invalid_base64("====")
  expect_invalid_base64("AA=A")
  expect_invalid_base64("AAA=AAAA")
}
