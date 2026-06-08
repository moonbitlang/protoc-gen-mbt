pub(all) struct Hello_MetadataEntry {
  mut key : String
  mut value : String
} derive(Eq, Debug)
pub impl @lib.Sized for Hello_MetadataEntry with fn size_of(self) {
  let mut size = 0U
  if self.key != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.key))
  }
  if self.value != Default::default() {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.value))
  }
  size
}
pub impl Default for Hello_MetadataEntry with fn default() -> Hello_MetadataEntry {
  Hello_MetadataEntry::{
    key : String::default(),
    value : String::default(),
  }
}
pub fn Hello_MetadataEntry::new(key : String, value : String) -> Hello_MetadataEntry {
  Hello_MetadataEntry::{
    key,
    value,
  }
}
pub impl @lib.Read for Hello_MetadataEntry with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> Hello_MetadataEntry raise {
  let msg = Hello_MetadataEntry::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, _) => msg.value = reader |> @lib.read_string()
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.Write for Hello_MetadataEntry with fn write(self: Hello_MetadataEntry, writer : &@lib.Writer) -> Unit raise {
  if self.key != Default::default() {
  writer |> @lib.write_varint(10UL);
  writer |> @lib.write_string(self.key)
  }
  if self.value != Default::default() {
  writer |> @lib.write_varint(18UL);
  writer |> @lib.write_string(self.value)
  }
}
pub impl ToJson for Hello_MetadataEntry with fn to_json(self) {
  let json: Map[String, Json] = {}
  if self.key != Default::default() {
  json["key"] = self.key.to_json()
  }
  if self.value != Default::default() {
  json["value"] = self.value.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for Hello_MetadataEntry with fn from_json(json: Json, path: @json.JsonPath) -> Hello_MetadataEntry raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Hello_MetadataEntry"))
  }
  let message = Hello_MetadataEntry::default()
  for key, value in obj {
    match (key, value) {
      ("key", value) => message.key = @json.from_json(value, path~)
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for Hello_MetadataEntry with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> Hello_MetadataEntry raise {
  let msg = Hello_MetadataEntry::default()
  while (reader |> @lib.async_read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.async_read_string()
      (2, _) => msg.value = reader |> @lib.async_read_string()
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.AsyncWrite for Hello_MetadataEntry with fn write(self: Hello_MetadataEntry, writer : &@lib.AsyncWriter) -> Unit raise {
  if self.key != Default::default() {
  writer |> @lib.async_write_varint(10UL);
  writer |> @lib.async_write_string(self.key)
  }
  if self.value != Default::default() {
  writer |> @lib.async_write_varint(18UL);
  writer |> @lib.async_write_string(self.value)
  }
}
pub(all) struct Hello {
  mut name : String
  mut age : Int
  mut hobbies : Array[String]
  mut metadata : Map[String, String]
  mut friend : Hello?
} derive(Eq, Debug)
pub impl @lib.Sized for Hello with fn size_of(self) {
  let mut size = 0U
  if self.name != Default::default() {
    size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.name))
  }
  if self.age != Default::default() {
    size += @lib.size_of_field(2U, @lib.size_of(self.age))
  }
  for s in self.hobbies {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(s))
  }
  for k, v in self.metadata {
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    size += @lib.size_of_length_delimited_field(4U, key_size + value_size)
  }
  if self.friend is Some(v) {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(v))
  }
  size
}
pub impl Default for Hello with fn default() -> Hello {
  Hello::{
    name : String::default(),
    age : Int::default(),
    hobbies : [],
    metadata : {},
    friend : None,
  }
}
pub fn Hello::new(name : String, age : Int, hobbies : Array[String], metadata : Map[String, String], friend? : Hello) -> Hello {
  Hello::{
    name,
    age,
    hobbies,
    metadata,
    friend,
  }
}
pub impl @lib.Read for Hello with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> Hello raise {
  let msg = Hello::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, _) => msg.age = reader |> @lib.read_int32()
      (3, _) => msg.hobbies.push(reader |> @lib.read_string())
      (4, 2) => { let {key, value} = (reader |> @lib.read_message() : Hello_MetadataEntry); msg.metadata[key] = value }
      (5, 2) => msg.friend = (reader |> @lib.read_message() : Hello) |> Some
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.Write for Hello with fn write(self: Hello, writer : &@lib.Writer) -> Unit raise {
  if self.name != Default::default() {
  writer |> @lib.write_varint(10UL);
  writer |> @lib.write_string(self.name)
  }
  if self.age != Default::default() {
  writer |> @lib.write_varint(16UL);
  writer |> @lib.write_int32(self.age)
  }
  for item in self.hobbies {
    writer |> @lib.write_varint(26UL)

    writer |> @lib.write_string(item)

  }
  let keys = self.metadata.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.metadata.get(k).unwrap()
    writer |> @lib.write_varint(34UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    writer |> @lib.write_uint32(key_size + value_size)
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(k)

    writer |> @lib.write_varint(18UL);
    writer |> @lib.write_string(v)

  }
  if self.friend is Some(v) {
    writer |> @lib.write_varint(42UL);

    writer |> @lib.write_message(v)

  }
}
pub impl ToJson for Hello with fn to_json(self) {
  let json: Map[String, Json] = {}
  if self.name != Default::default() {
  json["name"] = self.name.to_json()
  }
  if self.age != Default::default() {
  json["age"] = self.age.to_json()
  }
  if self.hobbies != Default::default() {
  json["hobbies"] = self.hobbies.to_json()
  }
  if self.metadata != Default::default() {
  json["metadata"] = self.metadata.to_json()
  }
  match self.friend {
      Some(v) => json["friend"] = v.to_json()
      _ => ()
    }
  Json::object(json)
}
pub impl @json.FromJson for Hello with fn from_json(json: Json, path: @json.JsonPath) -> Hello raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Hello"))
  }
  let message = Hello::default()
  for key, value in obj {
    match (key, value) {
      ("name", value) => message.name = @json.from_json(value, path~)
      ("age", value) => message.age = @json.from_json(value, path~)
      ("hobbies", Array(value)) => message.hobbies = value.map(v => 
@json.from_json(v, path~))
      ("metadata", _) => message.metadata = @json.from_json(value, path~)
      ("friend", value) => message.friend = Some(@json.from_json(value, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for Hello with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> Hello raise {
  let msg = Hello::default()
  while (reader |> @lib.async_read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.name = reader |> @lib.async_read_string()
      (2, _) => msg.age = reader |> @lib.async_read_int32()
      (3, _) => msg.hobbies.push(reader |> @lib.async_read_string())
      (4, 2) => { let {key, value} = (reader |> @lib.async_read_message() : Hello_MetadataEntry); msg.metadata[key] = value }
      (5, 2) => msg.friend = (reader |> @lib.async_read_message() : Hello) |> Some
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.AsyncWrite for Hello with fn write(self: Hello, writer : &@lib.AsyncWriter) -> Unit raise {
  if self.name != Default::default() {
  writer |> @lib.async_write_varint(10UL);
  writer |> @lib.async_write_string(self.name)
  }
  if self.age != Default::default() {
  writer |> @lib.async_write_varint(16UL);
  writer |> @lib.async_write_int32(self.age)
  }
  for item in self.hobbies {
    writer |> @lib.async_write_varint(26UL)

    writer |> @lib.async_write_string(item)

  }
  let keys = self.metadata.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.metadata.get(k).unwrap()
    writer |> @lib.async_write_varint(34UL)
    let key_size = @lib.size_of_length_delimited_field(1U, @lib.size_of(k))
    let value_size = @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
    writer |> @lib.async_write_uint32(key_size + value_size)
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(k)

    writer |> @lib.async_write_varint(18UL);
    writer |> @lib.async_write_string(v)

  }
  if self.friend is Some(v) {
    writer |> @lib.async_write_varint(42UL);

    writer |> @lib.async_write_message(v)

  }
}
