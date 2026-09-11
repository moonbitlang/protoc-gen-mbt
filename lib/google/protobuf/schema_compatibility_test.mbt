///|
// These fields must survive regeneration with a different protoc installation.
fn[T : @lib.Write + @lib.Sized + ToJson] assert_schema_encoding(
  message : T,
  wire~ : Bytes,
  json~ : Json,
) -> Unit raise {
  let writer = @buffer.Buffer()
  @lib.Write::write(message, writer)
  assert_eq(writer.to_bytes(), wire)
  assert_eq(@lib.size_of(message), wire.length().reinterpret_as_uint())
  assert_eq(ToJson::to_json(message), json)
}

///|
test "api and method editions survive binary and JSON roundtrips" {
  let wire = b"\x38\x02\x42\x04\x32\x30\x32\x34"
  let json : Json = { "syntax": "SYNTAX_EDITIONS", "edition": "2024" }
  let api : Api = @lib.Read::read(@lib.BytesReader::from_bytes(wire))
  assert_schema_encoding(api, wire~, json~)
  let api : Api = @json.from_json(json)
  assert_schema_encoding(api, wire~, json~)
  let method_ : Method = @lib.Read::read(@lib.BytesReader::from_bytes(wire))
  assert_schema_encoding(method_, wire~, json~)
  let method_ : Method = @json.from_json(json)
  assert_schema_encoding(method_, wire~, json~)
}

///|
test "descriptor option dependencies survive binary and JSON roundtrips" {
  let wire = b"\x7a\x07a.proto"
  let json : Json = { "optionDependency": ["a.proto"] }
  let descriptor : FileDescriptorProto = @lib.Read::read(
    @lib.BytesReader::from_bytes(wire),
  )
  assert_schema_encoding(descriptor, wire~, json~)
  let descriptor : FileDescriptorProto = @json.from_json(json)
  assert_schema_encoding(descriptor, wire~, json~)
}

///|
test "descriptor visibility survives binary and JSON roundtrips" {
  let wire = b"\x58\x02"
  let json : Json = { "visibility": "VISIBILITY_EXPORT" }
  let descriptor : DescriptorProto = @lib.Read::read(
    @lib.BytesReader::from_bytes(wire),
  )
  assert_schema_encoding(descriptor, wire~, json~)
  let descriptor : DescriptorProto = @json.from_json(json)
  assert_schema_encoding(descriptor, wire~, json~)
  let wire = b"\x30\x02"
  let descriptor : EnumDescriptorProto = @lib.Read::read(
    @lib.BytesReader::from_bytes(wire),
  )
  assert_schema_encoding(descriptor, wire~, json~)
  let descriptor : EnumDescriptorProto = @json.from_json(json)
  assert_schema_encoding(descriptor, wire~, json~)
}

///|
test "edition naming and visibility features survive binary and JSON roundtrips" {
  let wire = b"\x38\x01\x40\x02"
  let json : Json = {
    "enforceNamingStyle": "STYLE2024",
    "defaultSymbolVisibility": "EXPORT_TOP_LEVEL",
  }
  let features : FeatureSet = @lib.Read::read(
    @lib.BytesReader::from_bytes(wire),
  )
  assert_schema_encoding(features, wire~, json~)
  let features : FeatureSet = @json.from_json(json)
  assert_schema_encoding(features, wire~, json~)
}
