///|
pub(all) struct DoubleValue {
  mut value : Double
} derive(Eq, Debug)

///|
pub impl @lib.Sized for DoubleValue with fn size_of(self) {
  let mut size = 0U
  if self.value != Default::default() {
    size += 1U + 8U
  }
  size
}

///|
pub impl Default for DoubleValue with fn default() -> DoubleValue {
  DoubleValue::{ value: Double::default() }
}

///|
pub fn DoubleValue::new(value : Double) -> DoubleValue {
  DoubleValue::{ value, }
}

///|
pub impl @lib.Read for DoubleValue with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> DoubleValue raise {
  let msg = DoubleValue::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) => msg.value = reader |> @lib.read_double()
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for DoubleValue with fn write(
  self : DoubleValue,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.write_varint(9UL)
    writer |> @lib.write_double(self.value)
  }
}

///|
pub impl ToJson for DoubleValue with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.value != Default::default() {
    json["value"] = self.value.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for DoubleValue with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> DoubleValue raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for DoubleValue"))
  }
  let message = DoubleValue::default()
  for key, value in obj {
    match (key, value) {
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for DoubleValue with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> DoubleValue raise {
  let msg = DoubleValue::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) => msg.value = reader |> @lib.async_read_double()
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for DoubleValue with fn write(
  self : DoubleValue,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(9UL)
    writer |> @lib.async_write_double(self.value)
  }
}

///|
pub(all) struct FloatValue {
  mut value : Float
} derive(Eq, Debug)

///|
pub impl @lib.Sized for FloatValue with fn size_of(self) {
  let mut size = 0U
  if self.value != Default::default() {
    size += 1U + 4U
  }
  size
}

///|
pub impl Default for FloatValue with fn default() -> FloatValue {
  FloatValue::{ value: Float::default() }
}

///|
pub fn FloatValue::new(value : Float) -> FloatValue {
  FloatValue::{ value, }
}

///|
pub impl @lib.Read for FloatValue with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> FloatValue raise {
  let msg = FloatValue::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) => msg.value = reader |> @lib.read_float()
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for FloatValue with fn write(
  self : FloatValue,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.write_varint(13UL)
    writer |> @lib.write_float(self.value)
  }
}

///|
pub impl ToJson for FloatValue with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.value != Default::default() {
    json["value"] = self.value.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for FloatValue with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> FloatValue raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for FloatValue"))
  }
  let message = FloatValue::default()
  for key, value in obj {
    match (key, value) {
      ("value", Number(value, ..)) => message.value = Float::from_double(value)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for FloatValue with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> FloatValue raise {
  let msg = FloatValue::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) => msg.value = reader |> @lib.async_read_float()
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for FloatValue with fn write(
  self : FloatValue,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(13UL)
    writer |> @lib.async_write_float(self.value)
  }
}

///|
pub(all) struct Int64Value {
  mut value : Int64
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Int64Value with fn size_of(self) {
  let mut size = 0U
  if self.value != Default::default() {
    size += 1U + @lib.size_of(self.value)
  }
  size
}

///|
pub impl Default for Int64Value with fn default() -> Int64Value {
  Int64Value::{ value: Int64::default() }
}

///|
pub fn Int64Value::new(value : Int64) -> Int64Value {
  Int64Value::{ value, }
}

///|
pub impl @lib.Read for Int64Value with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Int64Value raise {
  let msg = Int64Value::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) => msg.value = reader |> @lib.read_int64()
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for Int64Value with fn write(
  self : Int64Value,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_int64(self.value)
  }
}

///|
pub impl ToJson for Int64Value with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.value != Default::default() {
    json["value"] = self.value.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Int64Value with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Int64Value raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Int64Value"))
  }
  let message = Int64Value::default()
  for key, value in obj {
    match (key, value) {
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Int64Value with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Int64Value raise {
  let msg = Int64Value::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) => msg.value = reader |> @lib.async_read_int64()
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for Int64Value with fn write(
  self : Int64Value,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_int64(self.value)
  }
}

///|
pub(all) struct UInt64Value {
  mut value : UInt64
} derive(Eq, Debug)

///|
pub impl @lib.Sized for UInt64Value with fn size_of(self) {
  let mut size = 0U
  if self.value != Default::default() {
    size += 1U + @lib.size_of(self.value)
  }
  size
}

///|
pub impl Default for UInt64Value with fn default() -> UInt64Value {
  UInt64Value::{ value: UInt64::default() }
}

///|
pub fn UInt64Value::new(value : UInt64) -> UInt64Value {
  UInt64Value::{ value, }
}

///|
pub impl @lib.Read for UInt64Value with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> UInt64Value raise {
  let msg = UInt64Value::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) => msg.value = reader |> @lib.read_uint64()
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for UInt64Value with fn write(
  self : UInt64Value,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_uint64(self.value)
  }
}

///|
pub impl ToJson for UInt64Value with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.value != Default::default() {
    json["value"] = self.value.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for UInt64Value with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> UInt64Value raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for UInt64Value"))
  }
  let message = UInt64Value::default()
  for key, value in obj {
    match (key, value) {
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for UInt64Value with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> UInt64Value raise {
  let msg = UInt64Value::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) => msg.value = reader |> @lib.async_read_uint64()
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for UInt64Value with fn write(
  self : UInt64Value,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_uint64(self.value)
  }
}

///|
pub(all) struct Int32Value {
  mut value : Int
} derive(Eq, Debug)

///|
pub impl @lib.Sized for Int32Value with fn size_of(self) {
  let mut size = 0U
  if self.value != Default::default() {
    size += 1U + @lib.size_of(self.value)
  }
  size
}

///|
pub impl Default for Int32Value with fn default() -> Int32Value {
  Int32Value::{ value: Int::default() }
}

///|
pub fn Int32Value::new(value : Int) -> Int32Value {
  Int32Value::{ value, }
}

///|
pub impl @lib.Read for Int32Value with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> Int32Value raise {
  let msg = Int32Value::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) => msg.value = reader |> @lib.read_int32()
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for Int32Value with fn write(
  self : Int32Value,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_int32(self.value)
  }
}

///|
pub impl ToJson for Int32Value with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.value != Default::default() {
    json["value"] = self.value.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for Int32Value with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Int32Value raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Int32Value"))
  }
  let message = Int32Value::default()
  for key, value in obj {
    match (key, value) {
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for Int32Value with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> Int32Value raise {
  let msg = Int32Value::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) => msg.value = reader |> @lib.async_read_int32()
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for Int32Value with fn write(
  self : Int32Value,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_int32(self.value)
  }
}

///|
pub(all) struct UInt32Value {
  mut value : UInt
} derive(Eq, Debug)

///|
pub impl @lib.Sized for UInt32Value with fn size_of(self) {
  let mut size = 0U
  if self.value != Default::default() {
    size += 1U + @lib.size_of(self.value)
  }
  size
}

///|
pub impl Default for UInt32Value with fn default() -> UInt32Value {
  UInt32Value::{ value: UInt::default() }
}

///|
pub fn UInt32Value::new(value : UInt) -> UInt32Value {
  UInt32Value::{ value, }
}

///|
pub impl @lib.Read for UInt32Value with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> UInt32Value raise {
  let msg = UInt32Value::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) => msg.value = reader |> @lib.read_uint32()
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for UInt32Value with fn write(
  self : UInt32Value,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_uint32(self.value)
  }
}

///|
pub impl ToJson for UInt32Value with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.value != Default::default() {
    json["value"] = self.value.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for UInt32Value with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> UInt32Value raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for UInt32Value"))
  }
  let message = UInt32Value::default()
  for key, value in obj {
    match (key, value) {
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for UInt32Value with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> UInt32Value raise {
  let msg = UInt32Value::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) => msg.value = reader |> @lib.async_read_uint32()
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for UInt32Value with fn write(
  self : UInt32Value,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_uint32(self.value)
  }
}

///|
pub(all) struct BoolValue {
  mut value : Bool
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BoolValue with fn size_of(self) {
  let mut size = 0U
  if self.value != Default::default() {
    size += 1U + @lib.size_of(self.value)
  }
  size
}

///|
pub impl Default for BoolValue with fn default() -> BoolValue {
  BoolValue::{ value: Bool::default() }
}

///|
pub fn BoolValue::new(value : Bool) -> BoolValue {
  BoolValue::{ value, }
}

///|
pub impl @lib.Read for BoolValue with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BoolValue raise {
  let msg = BoolValue::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) => msg.value = reader |> @lib.read_bool()
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for BoolValue with fn write(
  self : BoolValue,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.write_varint(8UL)
    writer |> @lib.write_bool(self.value)
  }
}

///|
pub impl ToJson for BoolValue with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.value != Default::default() {
    json["value"] = self.value.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for BoolValue with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> BoolValue raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for BoolValue"))
  }
  let message = BoolValue::default()
  for key, value in obj {
    match (key, value) {
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BoolValue with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BoolValue raise {
  let msg = BoolValue::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) => msg.value = reader |> @lib.async_read_bool()
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for BoolValue with fn write(
  self : BoolValue,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(8UL)
    writer |> @lib.async_write_bool(self.value)
  }
}

///|
pub(all) struct StringValue {
  mut value : String
} derive(Eq, Debug)

///|
pub impl @lib.Sized for StringValue with fn size_of(self) {
  let mut size = 0U
  if self.value != Default::default() {
    size += 1U +
      ({
        let size = @lib.size_of(self.value)
        @lib.size_of(size) + size
      })
  }
  size
}

///|
pub impl Default for StringValue with fn default() -> StringValue {
  StringValue::{ value: String::default() }
}

///|
pub fn StringValue::new(value : String) -> StringValue {
  StringValue::{ value, }
}

///|
pub impl @lib.Read for StringValue with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> StringValue raise {
  let msg = StringValue::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) => msg.value = reader |> @lib.read_string()
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for StringValue with fn write(
  self : StringValue,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_string(self.value)
  }
}

///|
pub impl ToJson for StringValue with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.value != Default::default() {
    json["value"] = self.value.to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for StringValue with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> StringValue raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for StringValue"))
  }
  let message = StringValue::default()
  for key, value in obj {
    match (key, value) {
      ("value", value) => message.value = @json.from_json(value, path~)
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for StringValue with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> StringValue raise {
  let msg = StringValue::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) => msg.value = reader |> @lib.async_read_string()
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for StringValue with fn write(
  self : StringValue,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_string(self.value)
  }
}

///|
pub(all) struct BytesValue {
  mut value : Bytes
} derive(Eq, Debug)

///|
pub impl @lib.Sized for BytesValue with fn size_of(self) {
  let mut size = 0U
  if self.value != Default::default() {
    size += 1U +
      ({
        let size = @lib.size_of(self.value)
        @lib.size_of(size) + size
      })
  }
  size
}

///|
pub impl Default for BytesValue with fn default() -> BytesValue {
  BytesValue::{ value: Bytes::default() }
}

///|
pub fn BytesValue::new(value : Bytes) -> BytesValue {
  BytesValue::{ value, }
}

///|
pub impl @lib.Read for BytesValue with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.Reader],
) -> BytesValue raise {
  let msg = BytesValue::default()
  try {
    for ;; {
      match (reader |> @lib.read_tag()) {
        (1, _) => msg.value = reader |> @lib.read_bytes()
        (_, wire) => reader |> @lib.read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.Write for BytesValue with fn write(
  self : BytesValue,
  writer : &@lib.Writer,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.write_varint(10UL)
    writer |> @lib.write_bytes(self.value)
  }
}

///|
pub impl ToJson for BytesValue with fn to_json(self) {
  let json : Map[String, Json] = {}
  if self.value != Default::default() {
    json["value"] = @lib.base64_encode(self.value).to_json()
  }
  Json::object(json)
}

///|
pub impl @json.FromJson for BytesValue with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> BytesValue raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for BytesValue"))
  }
  let message = BytesValue::default()
  for key, value in obj {
    match (key, value) {
      ("value", String(value)) =>
        message.value = @lib.base64_decode(value) catch {
          _ => raise @json.JsonDecodeError((path, "Invalid base64 encoding"))
        }
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}

///|
pub impl @lib.AsyncRead for BytesValue with fn read_with_limit(
  reader : @lib.LimitedReader[&@lib.AsyncReader],
) -> BytesValue raise {
  let msg = BytesValue::default()
  try {
    for ;; {
      match (reader |> @lib.async_read_tag()) {
        (1, _) => msg.value = reader |> @lib.async_read_bytes()
        (_, wire) => reader |> @lib.async_read_unknown(wire)
      }
    }
  } catch {
    @lib.EndOfStream => ()
    err => raise err
  }
  msg
}

///|
pub impl @lib.AsyncWrite for BytesValue with fn write(
  self : BytesValue,
  writer : &@lib.AsyncWriter,
) -> Unit raise {
  if self.value != Default::default() {
    writer |> @lib.async_write_varint(10UL)
    writer |> @lib.async_write_bytes(self.value)
  }
}
