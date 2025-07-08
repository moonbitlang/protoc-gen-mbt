///|
fn convert_args(args : String) -> Map[String, String] {
  let params = {}
  let parts = args.split(",")
  for part in parts {
    let key_value = part.split("=").collect()
    if key_value.length() == 2 {
      let key = key_value[0].trim_space()
      let value = key_value[1].trim_space()
      if key.is_empty() || value.is_empty() {
        continue
      }
      params[key.to_string()] = value.to_string()
    }
  }
  return params
}

///|
fn to_camel_case(s : String) -> String {
  // Invariant: if the next letter is lower case, it must be converted
  // to upper case.
  // That is, we process a word at a time, where words are marked by _ or
  // upper case letter. Digits are treated as words.
  let b = StringBuilder::new()
  let chars = s.to_array()
  let len = chars.length()
  let mut i = 0
  while i < len {
    let c = chars[i]
    if c == '.' && i + 1 < len && chars[i + 1].is_ascii_lowercase() {
      // Skip over '.' in ".{{lowercase}}".
    } else if c == '.' {
      b.write_char('_') // convert '.' to '_'
    } else if c == '_' && (i == 0 || chars[i - 1] == '.') {
      // Convert initial '_' to ensure we start with a capital letter.
      // Do the same for '_' after '.' to match historic behavior.
      b.write_char('X') // convert '_' to 'X'
    } else if c == '_' && i + 1 < len && chars[i + 1].is_ascii_lowercase() {
      // Skip over '_' in "_{{lowercase}}".
    } else if c.is_ascii_digit() {
      b.write_char(c)
    } else {
      // Assume we have a letter now - if not, it's a bogus identifier.
      // The next word is a sequence of characters that must start upper case.
      let upper_c = if c.is_ascii_lowercase() {
        c.to_ascii_uppercase()
      } else {
        c
      }
      b.write_char(upper_c)

      // Accept lower case sequence that follows.
      while i + 1 < len && chars[i + 1].is_ascii_lowercase() {
        i = i + 1
        b.write_char(chars[i])
      }
    }
    i = i + 1
  }
  return b.to_string()
}

///|
test "goCamelCase" {
  inspect(to_camel_case("hello_world"), content="HelloWorld")
  inspect(to_camel_case("test.proto"), content="TestProto")
  inspect(to_camel_case("_start"), content="XStart")
  inspect(to_camel_case("simple"), content="Simple")
  inspect(to_camel_case("test123"), content="Test123")
  inspect(to_camel_case("xml_http_request"), content="XmlHttpRequest")
}

///|
fn pascal_to_snake(name : String) -> String {
  let keywords = [
    "type", "match", "if", "else", "for", "while", "loop", "break", "continue", "fn",
    "let", "mut", "struct", "enum", "trait", "impl", "pub", "priv", "import", "export",
    "as", "self", "true", "false", "try", "catch", "finally", "throw", "return",
    "default", "case", "switch", "new", "this", "derive",
  ]
  let new_name = StringBuilder::new()
  let upper = StringBuilder::new()
  let prev = '_'
  loop (name[:], prev) {
    (['A'..='Z' as c, .. rest], prev) => {
      if upper.is_empty() && prev != '_' {
        upper.write_char('_')
      }
      upper.write_char(c.to_ascii_lowercase())
      continue (rest, c)
    }
    ([c, .. rest], _) => {
      if not(upper.is_empty()) {
        new_name.write_string(upper.to_string())
        upper.reset()
      }
      new_name.write_char(c)
      continue (rest, c)
    }
    ([], _) => {
      if not(upper.is_empty()) {
        new_name.write_string(upper.to_string())
      }
      break
    }
  }
  if keywords.contains(new_name.to_string()) {
    new_name.write_char('_')
  }
  return new_name.to_string()
}

///|
fn sizeFixed32() -> UInt {
  return 4U
}

///|
fn sizeFixed64() -> UInt {
  return 8U
}

///|
fn size_tag(num : Int) -> Int {
  size_varint(encode_tag(num, 0))
}

// 计算 varint 的大小

///|
fn size_varint(v : UInt64) -> Int {
  let len64 = if v == 0UL { 1 } else { 64 - v.clz() }
  (9 * len64 + 64) / 64
}

///|
fn encode_tag(num : Int, typ : Int) -> UInt64 {
  (num.to_uint64() << 3) | (typ & 7).to_uint64()
}

///|
fn tag(kind : FieldType, number : Int, is_packed : Bool) -> UInt64 {
  if is_packed {
    return encode_tag(number, 2) // BytesType
  }
  match kind {
    FieldType::FieldDescriptorProto_TYPE_BOOL
    | FieldType::FieldDescriptorProto_TYPE_ENUM
    | FieldType::FieldDescriptorProto_TYPE_INT32
    | FieldType::FieldDescriptorProto_TYPE_INT64
    | FieldType::FieldDescriptorProto_TYPE_SINT32
    | FieldType::FieldDescriptorProto_TYPE_SINT64
    | FieldType::FieldDescriptorProto_TYPE_UINT32
    | FieldType::FieldDescriptorProto_TYPE_UINT64 => encode_tag(number, 0) // VarintType
    FieldType::FieldDescriptorProto_TYPE_FIXED32
    | FieldType::FieldDescriptorProto_TYPE_SFIXED32
    | FieldType::FieldDescriptorProto_TYPE_FLOAT => encode_tag(number, 5) // Fixed32Type
    FieldType::FieldDescriptorProto_TYPE_FIXED64
    | FieldType::FieldDescriptorProto_TYPE_SFIXED64
    | FieldType::FieldDescriptorProto_TYPE_DOUBLE => encode_tag(number, 1) // Fixed64Type
    FieldType::FieldDescriptorProto_TYPE_STRING
    | FieldType::FieldDescriptorProto_TYPE_BYTES
    | FieldType::FieldDescriptorProto_TYPE_MESSAGE => encode_tag(number, 2) // BytesType
    _ => {
      panic()
    }
  }
}

///|
test "pascalToSnake" {
  inspect(pascal_to_snake("PascalCase"), content="pascal_case")
  inspect(pascal_to_snake("SimpleWord"), content="simple_word")
  inspect(pascal_to_snake("XMLHttpRequest"), content="xmlhttp_request")
  inspect(pascal_to_snake("HTTPSConnection"), content="httpsconnection")
}

///|
test "pascalToSnake/edge_cases" {
  inspect(pascal_to_snake(""), content="")
  inspect(pascal_to_snake("A"), content="a")
  inspect(pascal_to_snake("ABC"), content="abc")
  inspect(pascal_to_snake("lowercase"), content="lowercase")
}

///|
test "pascalToSnake/keywords" {
  inspect(pascal_to_snake("Type"), content="type_")
  inspect(pascal_to_snake("Match"), content="match_")
  inspect(pascal_to_snake("New"), content="new_")
}
