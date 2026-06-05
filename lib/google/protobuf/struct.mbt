///|
pub(all) enum NullValue {
  NULL_VALUE
  Unknown(@lib.Enum)
} derive(Eq, Debug)

///|
pub fn NullValue::to_enum(self : NullValue) -> @lib.Enum {
  match self {
    NullValue::NULL_VALUE => 0
    NullValue::Unknown(value) => value
  }
}

///|
pub fn NullValue::from_enum(i : @lib.Enum) -> NullValue {
  match i.0 {
    0 => NullValue::NULL_VALUE
    _ => NullValue::Unknown(i)
  }
}

///|
pub impl Default for NullValue with fn default() -> NullValue {
  NullValue::NULL_VALUE
}

///|
pub impl @lib.Sized for NullValue with fn size_of(self : NullValue) {
  @lib.Sized::size_of(self.to_enum())
}

///|
pub impl @json.FromJson for NullValue with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> NullValue raise {
  match json {
    String("NULL_VALUE") => NullValue::NULL_VALUE
    Number(0, ..) => NullValue::NULL_VALUE
    Number(value, ..) =>
      if value.trunc() == value {
        NullValue::Unknown(@lib.Enum(value.to_uint()))
      } else {
        raise @json.JsonDecodeError(
          (path, "Expected an integer number or string for enum"),
        )
      }
    _ =>
      raise @json.JsonDecodeError(
        (path, "Expected a number or string for enum"),
      )
  }
}

///|
pub impl ToJson for NullValue with fn to_json(self : NullValue) -> Json {
  match self {
    NullValue::NULL_VALUE => "NULL_VALUE"
    NullValue::Unknown(value) => value.0.to_json()
  }
}

///|
pub(all) struct Struct_FieldsEntry {
  mut key : String
  mut value : Value
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Struct_FieldsEntry with fn size_of(self) {
  let mut size = 0U
  if self.key != Default::default() {
    size += 1U +
      ({
        let size = @lib.size_of(self.key)
        @lib.size_of(size) + size
      })
  }
  size += 1U +
    ({
      let size = @lib.size_of(self.value)
      @lib.size_of(size) + size
    })
  size
}

///|
pub impl Default for Struct_FieldsEntry with fn default() -> Struct_FieldsEntry {
  Struct_FieldsEntry::{ key: String::default(), value: Value::default() }
}

///|
pub fn Struct_FieldsEntry::new(
  key : String,
  value : Value,
) -> Struct_FieldsEntry {
  Struct_FieldsEntry::{ key, value }
}

///|
pub impl @lib.Read for Struct_FieldsEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Struct_FieldsEntry raise {
  let msg = Struct_FieldsEntry::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.read_string()
      (2, _) => msg.value = (reader |> @lib.read_message() : Value)
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for Struct_FieldsEntry with fn write(
  self : Struct_FieldsEntry,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.key)
  }
  writer |> @lib.write_varint(18UL)
  writer |> @lib.write_message(self.value)
}

///|
pub impl ToJson for Struct_FieldsEntry with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.key != Default::default() {
    json["key"] = self.key.to_json()
  }
  if self.value != Default::default() {
    json["value"] = self.value.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Struct_FieldsEntry with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Struct_FieldsEntry raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "Expected an object for Struct_FieldsEntry"),
    )
  }
  let message = Struct_FieldsEntry::default()
  for key, value in obj {
    match (key, value) {
      ("key", value) => message.key = @json.from_json(value, path~)
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Struct_FieldsEntry with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Struct_FieldsEntry raise {
  let msg = Struct_FieldsEntry::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.key = reader |> @lib.async_read_string()
      (2, _) => msg.value = (reader |> @lib.async_read_message() : Value)
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for Struct_FieldsEntry with fn write(
  self : Struct_FieldsEntry,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.key != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.key)
  }
  writer |> @lib.async_write_varint(18UL)
  writer |> @lib.async_write_message(self.value)
}

///|
pub(all) struct Struct {
  mut fields : Map[String, Value]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Struct with fn size_of(self) {
  let mut size = 0U
  for k, v in self.fields {
    let key_size = 1U +
      ({
        let size = @lib.size_of(k)
        @lib.size_of(size) + size
      })
    let value_size = 1U +
      ({
        let size = @lib.size_of(v)
        @lib.size_of(size) + size
      })
    size += 1U + @lib.size_of(key_size + value_size) + key_size + value_size
  }
  size
}

///|
pub impl Default for Struct with fn default() -> Struct {
  Struct::{ fields: {} }
}

///|
pub fn Struct::new(fields : Map[String, Value]) -> Struct {
  Struct::{ fields, }
}

///|
pub impl @lib.Read for Struct with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Struct raise {
  let msg = Struct::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => {
        let { key, value } = (reader |> @lib.read_message() : Struct_FieldsEntry)
        msg.fields[key] = value
      }
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for Struct with fn write(
  self : Struct,
  writer : &@lib.Writer,
) -> Unit raise {
  let keys = self.fields.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.fields.get(k).unwrap()
    writer |> @lib.write_varint(10UL)
    let key_size = 1U +
      ({
        let size = @lib.size_of(k)
        @lib.size_of(size) + size
      })
    let value_size = 1U +
      ({
        let size = @lib.size_of(v)
        @lib.size_of(size) + size
      })
    writer |> @lib.write_uint32(key_size + value_size)
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(k)

    writer |> @lib.write_varint(18UL)
    writer |> @lib.write_message(v)
  }
}

///|
pub impl ToJson for Struct with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.fields != Default::default() {
    json["fields"] = self.fields.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Struct with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Struct raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Struct"))
  }
  let message = Struct::default()
  for key, value in obj {
    match (key, value) {
      ("fields", _) => message.fields = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Struct with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Struct raise {
  let msg = Struct::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => {
        let { key, value } = (
          reader |> @lib.async_read_message() : Struct_FieldsEntry)
        msg.fields[key] = value
      }
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for Struct with fn write(
  self : Struct,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  let keys = self.fields.keys().collect()
  for i in 0..<keys.length() {
    let k = keys[i]
    let v = self.fields.get(k).unwrap()
    writer |> @lib.async_write_varint(10UL)
    let key_size = 1U +
      ({
        let size = @lib.size_of(k)
        @lib.size_of(size) + size
      })
    let value_size = 1U +
      ({
        let size = @lib.size_of(v)
        @lib.size_of(size) + size
      })
    writer |> @lib.async_write_uint32(key_size + value_size)
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(k)

    writer |> @lib.async_write_varint(18UL)
    writer |> @lib.async_write_message(v)
  }
}

///|
pub(all) struct Value {
  mut kind : Value_Kind
} derive(Eq, Debug)

///|
pub(all) enum Value_Kind {
  NullValue(NullValue)
  NumberValue(Double)
  StringValue(String)
  BoolValue(Bool)
  StructValue(Struct)
  ListValue(ListValue)
  NotSet
} derive(Eq, Debug)

///|
pub impl Default for Value_Kind with fn default() -> Value_Kind {
  NotSet
}

///|
pub impl @json.FromJson for Value_Kind with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Value_Kind raise {
  try Value_Kind::NullValue(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try Value_Kind::NumberValue(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try Value_Kind::StringValue(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try Value_Kind::BoolValue(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try Value_Kind::StructValue(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  try Value_Kind::ListValue(json |> @json.from_json(path~)) catch {
    _ => ()
  } noraise {
    v => return v
  }
  Value_Kind::NotSet
}

///|
pub impl ToJson for Value_Kind with fn to_json(self : Value_Kind) -> Json {
  match self {
    Value_Kind::NullValue(v) => v.to_json()
    Value_Kind::NumberValue(v) => v.to_json()
    Value_Kind::StringValue(v) => v.to_json()
    Value_Kind::BoolValue(v) => v.to_json()
    Value_Kind::StructValue(v) => v.to_json()
    Value_Kind::ListValue(v) => v.to_json()
    Value_Kind::NotSet => Json::null()
  }
}

///|
pub impl @lib.Sized for Value with fn size_of(self) {
  let mut size = 0U
  match self.kind {
    NullValue(v) => size += 1U + @lib.size_of(v)
    NumberValue(_) => size += 1U + 8U
    StringValue(v) =>
      size += 1U +
        ({
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        })
    BoolValue(v) => size += 1U + @lib.size_of(v)
    StructValue(v) =>
      size += 1U +
        ({
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        })
    ListValue(v) =>
      size += 1U +
        ({
          let size = @lib.size_of(v)
          @lib.size_of(size) + size
        })
    NotSet => ()
  }
  size
}

///|
pub impl Default for Value with fn default() -> Value {
  Value::{ kind: Value_Kind::NotSet }
}

///|
pub fn Value::new(kind? : Value_Kind = Value_Kind::NotSet) -> Value {
  Value::{ kind, }
}

///|
pub impl @lib.Read for Value with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Value raise {
  let msg = Value::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.kind = reader
          |> @lib.read_enum()
          |> NullValue::from_enum
          |> Value_Kind::NullValue
      (2, _) =>
        msg.kind = reader |> @lib.read_double() |> Value_Kind::NumberValue
      (3, _) =>
        msg.kind = reader |> @lib.read_string() |> Value_Kind::StringValue
      (4, _) => msg.kind = reader |> @lib.read_bool() |> Value_Kind::BoolValue
      (5, _) =>
        msg.kind = (reader |> @lib.read_message() : Struct)
          |> Value_Kind::StructValue
      (6, _) =>
        msg.kind = (reader |> @lib.read_message() : ListValue)
          |> Value_Kind::ListValue
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for Value with fn write(self : Value, writer : &@lib.Writer) -> Unit raise {
  match self.kind {
    Value_Kind::NullValue(v) => {
      writer |> @lib.write_varint(8UL)
      writer |> @lib.write_enum(v.to_enum())
    }
    Value_Kind::NumberValue(v) => {
      writer |> @lib.write_varint(17UL)
      writer |> @lib.write_double(v)
    }
    Value_Kind::StringValue(v) => {
      writer |> @lib.write_varint(26UL)
      writer |> @lib.write_string(v)
    }
    Value_Kind::BoolValue(v) => {
      writer |> @lib.write_varint(32UL)
      writer |> @lib.write_bool(v)
    }
    Value_Kind::StructValue(v) => {
      writer |> @lib.write_varint(42UL)
      writer |> @lib.write_message(v)
    }
    Value_Kind::ListValue(v) => {
      writer |> @lib.write_varint(50UL)
      writer |> @lib.write_message(v)
    }
    Value_Kind::NotSet => ()
  }
}

///|
pub impl ToJson for Value with fn to_json(self) {
  let json : Map[String, Json] = {}
  match self.kind {
    NotSet => ()
    NullValue(v) => json["nullValue"] = v.to_json()
    NumberValue(v) => json["numberValue"] = v.to_json()
    StringValue(v) => json["stringValue"] = v.to_json()
    BoolValue(v) => json["boolValue"] = v.to_json()
    StructValue(v) => json["structValue"] = v.to_json()
    ListValue(v) => json["listValue"] = v.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Value with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Value raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Value"))
  }
  let message = Value::default()
  for key, value in obj {
    match (key, value) {
      ("nullValue", value) => message.kind = @json.from_json(value, path~)
      ("numberValue", value) => message.kind = @json.from_json(value, path~)
      ("stringValue", value) => message.kind = @json.from_json(value, path~)
      ("boolValue", value) => message.kind = @json.from_json(value, path~)
      ("structValue", value) => message.kind = @json.from_json(value, path~)
      ("listValue", value) => message.kind = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Value with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Value raise {
  let msg = Value::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) =>
        msg.kind = reader
          |> @lib.async_read_enum()
          |> NullValue::from_enum
          |> Value_Kind::NullValue
      (2, _) =>
        msg.kind = reader |> @lib.async_read_double() |> Value_Kind::NumberValue
      (3, _) =>
        msg.kind = reader |> @lib.async_read_string() |> Value_Kind::StringValue
      (4, _) =>
        msg.kind = reader |> @lib.async_read_bool() |> Value_Kind::BoolValue
      (5, _) =>
        msg.kind = (reader |> @lib.async_read_message() : Struct)
          |> Value_Kind::StructValue
      (6, _) =>
        msg.kind = (reader |> @lib.async_read_message() : ListValue)
          |> Value_Kind::ListValue
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for Value with fn write(
  self : Value,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  match self.kind {
    Value_Kind::NullValue(v) => {
      writer |> @lib.async_write_varint(8UL)
      writer |> @lib.async_write_enum(v.to_enum())
    }
    Value_Kind::NumberValue(v) => {
      writer |> @lib.async_write_varint(17UL)
      writer |> @lib.async_write_double(v)
    }
    Value_Kind::StringValue(v) => {
      writer |> @lib.async_write_varint(26UL)
      writer |> @lib.async_write_string(v)
    }
    Value_Kind::BoolValue(v) => {
      writer |> @lib.async_write_varint(32UL)
      writer |> @lib.async_write_bool(v)
    }
    Value_Kind::StructValue(v) => {
      writer |> @lib.async_write_varint(42UL)
      writer |> @lib.async_write_message(v)
    }
    Value_Kind::ListValue(v) => {
      writer |> @lib.async_write_varint(50UL)
      writer |> @lib.async_write_message(v)
    }
    Value_Kind::NotSet => ()
  }
}

///|
pub(all) struct ListValue {
  mut values : Array[Value]
} derive(Eq, Debug)

///|
pub impl @lib.Sized for ListValue with fn size_of(self) {
  let mut size = 0U
  for s in self.values {
    size += 1U +
      ({
        let size = @lib.size_of(s)
        @lib.size_of(size) + size
      })
  }
  size
}

///|
pub impl Default for ListValue with fn default() -> ListValue {
  ListValue::{ values: [] }
}

///|
pub fn ListValue::new(values : Array[Value]) -> ListValue {
  ListValue::{ values, }
}

///|
pub impl @lib.Read for ListValue with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> ListValue raise {
  let msg = ListValue::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.values.push((reader |> @lib.read_message() : Value))
      _ => reader |> @lib.skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.Write for ListValue with fn write(
  self : ListValue,
  writer : &@lib.Writer,
) -> Unit raise {
  for item in self.values {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_message(item)
  }
}

///|
pub impl ToJson for ListValue with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.values != Default::default() {
    json["values"] = self.values.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for ListValue with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> ListValue raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for ListValue"))
  }
  let message = ListValue::default()
  for key, value in obj {
    match (key, value) {
      ("values", Array(value)) =>
        message.values = value.map(v => @json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for ListValue with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> ListValue raise {
  let msg = ListValue::default()
  while (reader |> @lib.async_read_next_message_field())
        is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.values.push((reader |> @lib.async_read_message() : Value))
      _ => reader |> @lib.async_skip_message_field(wire)
    }
  }
  msg
}

///|
pub impl @lib.AsyncWrite for ListValue with fn write(
  self : ListValue,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  for item in self.values {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_message(item)
  }
}
