///|
// JSON behavior for well-known types is runtime-owned because protobuf JSON maps
// these messages to strings rather than their protobuf fields.
let timestamp_min_seconds = -62135596800L

///|
let timestamp_max_seconds = 253402300799L

///|
let timestamp_max_nanos = 999999999

///|
let duration_min_seconds = -315576000000L

///|
let duration_max_seconds = 315576000000L

///|
let duration_min_nanos = -999999999

///|
let duration_max_nanos = 999999999

///|
fn wkt_json_format_nanos(nanos : Int) -> String {
  if nanos == 0 {
    return ""
  }
  let (value, width) = if nanos % 1000000 == 0 {
    (nanos / 1000000, 3)
  } else if nanos % 1000 == 0 {
    (nanos / 1000, 6)
  } else {
    (nanos, 9)
  }
  ".\{value.to_string().pad_start(width, '0')}"
}

///|
fn timestamp_floor_div(value : Int64, divisor : Int64) -> Int64 {
  let quotient = value / divisor
  let remainder = value % divisor
  if remainder < 0L {
    quotient - 1L
  } else {
    quotient
  }
}

///|
fn timestamp_floor_mod(value : Int64, divisor : Int64) -> Int64 {
  value - timestamp_floor_div(value, divisor) * divisor
}

///|
fn timestamp_civil_from_days(days_since_epoch : Int64) -> (Int, Int, Int) {
  let days = days_since_epoch + 719468L
  let era = if days >= 0L { days / 146097L } else { (days - 146096L) / 146097L }
  let day_of_era = days - era * 146097L
  let year_of_era = (
      day_of_era -
      day_of_era / 1460L +
      day_of_era / 36524L -
      day_of_era / 146096L
    ) /
    365L
  let year = year_of_era + era * 400L
  let day_of_year = day_of_era -
    (365L * year_of_era + year_of_era / 4L - year_of_era / 100L)
  let month_prime = (5L * day_of_year + 2L) / 153L
  let day = day_of_year - (153L * month_prime + 2L) / 5L + 1L
  let month = month_prime + (if month_prime < 10L { 3L } else { -9L })
  let adjusted_year = year + (if month <= 2L { 1L } else { 0L })
  (adjusted_year.to_int(), month.to_int(), day.to_int())
}

///|
fn timestamp_is_leap_year(year : Int) -> Bool {
  year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
}

///|
fn timestamp_days_before_year(year : Int) -> Int64 {
  let y = (year - 1).to_int64()
  y * 365L + y / 4L - y / 100L + y / 400L
}

///|
fn timestamp_days_before_month(year : Int, month : Int) -> Int {
  let regular = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
  let base = regular[month - 1]
  if month > 2 && timestamp_is_leap_year(year) {
    base + 1
  } else {
    base
  }
}

///|
fn timestamp_days_in_month(year : Int, month : Int) -> Int {
  match month {
    1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
    4 | 6 | 9 | 11 => 30
    2 if timestamp_is_leap_year(year) => 29
    2 => 28
    _ => 0
  }
}

///|
fn timestamp_parse_digits(
  value : StringView,
  path : @json.JsonPath,
) -> Int raise @json.JsonDecodeError {
  if value.length() == 0 {
    raise @json.JsonDecodeError((path, "Invalid Timestamp JSON value"))
  }
  let mut result = 0
  for i in 0..<value.length() {
    if value[i] < '0' || value[i] > '9' {
      raise @json.JsonDecodeError((path, "Invalid Timestamp JSON value"))
    }
    result = result * 10 + value[i].to_int() - '0'.to_int()
  }
  result
}

///|
fn timestamp_parse_nanos(
  value : StringView,
  path : @json.JsonPath,
) -> Int raise @json.JsonDecodeError {
  if value.length() == 0 || value.length() > 9 {
    raise @json.JsonDecodeError((path, "Invalid Timestamp JSON value"))
  }
  let mut nanos = timestamp_parse_digits(value, path)
  for _ in value.length()..<9 {
    nanos *= 10
  }
  nanos
}

///|
fn timestamp_parse_timezone_offset(
  negative : Bool,
  hour_text : StringView,
  minute_text : StringView,
  path : @json.JsonPath,
) -> Int64 raise @json.JsonDecodeError {
  let hour = timestamp_parse_digits(hour_text, path)
  let minute = timestamp_parse_digits(minute_text, path)
  if hour > 23 || minute > 59 {
    raise @json.JsonDecodeError((path, "Invalid Timestamp JSON value"))
  }
  let offset = (hour * 3600 + minute * 60).to_int64()
  if negative {
    -offset
  } else {
    offset
  }
}

///|
fn timestamp_validate_range(
  seconds : Int64,
  nanos : Int,
  path : @json.JsonPath,
) -> Unit raise @json.JsonDecodeError {
  if seconds < timestamp_min_seconds ||
    seconds > timestamp_max_seconds ||
    nanos < 0 ||
    nanos > timestamp_max_nanos {
    raise @json.JsonDecodeError((path, "Invalid Timestamp JSON value"))
  }
}

///|
fn timestamp_from_parts(
  year_text : StringView,
  month_text : StringView,
  day_text : StringView,
  hour_text : StringView,
  minute_text : StringView,
  second_text : StringView,
  nanos : Int,
  timezone_offset : Int64,
  path : @json.JsonPath,
) -> Timestamp raise @json.JsonDecodeError {
  let year = timestamp_parse_digits(year_text, path)
  let month = timestamp_parse_digits(month_text, path)
  let day = timestamp_parse_digits(day_text, path)
  let hour = timestamp_parse_digits(hour_text, path)
  let minute = timestamp_parse_digits(minute_text, path)
  let second = timestamp_parse_digits(second_text, path)
  if month < 1 ||
    month > 12 ||
    day < 1 ||
    day > timestamp_days_in_month(year, month) ||
    hour < 0 ||
    hour > 23 ||
    minute < 0 ||
    minute > 59 ||
    second < 0 ||
    second > 59 {
    raise @json.JsonDecodeError((path, "Invalid Timestamp JSON value"))
  }
  let days_since_year_one = timestamp_days_before_year(year) +
    timestamp_days_before_month(year, month).to_int64() +
    (day - 1).to_int64()
  let days_since_epoch = days_since_year_one - timestamp_days_before_year(1970)
  let seconds = days_since_epoch * 86400L +
    hour.to_int64() * 3600L +
    minute.to_int64() * 60L +
    second.to_int64()
  let seconds = seconds - timezone_offset
  timestamp_validate_range(seconds, nanos, path)
  Timestamp::new(seconds, nanos)
}

///|
fn timestamp_json_regex() -> @string.Regex {
  let digit = @string.Regex::unsafe_from_string("[[:digit:]]")
  let two_digits = digit.repeat(min=2, max=2)
  let dash = @string.Regex::string("-")
  let dot = @string.Regex::string(".")
  let colon = @string.Regex::string(":")
  let year = digit.repeat(min=4, max=4).capture("year")
  let month = two_digits.capture("month")
  let day = two_digits.capture("day")
  let hour = two_digits.capture("hour")
  let minute = two_digits.capture("minute")
  let second = two_digits.capture("second")
  let nanos = digit.repeat(min=1, max=9).capture("nanos")
  let fraction = (dot + nanos).repeat(min=0, max=1)
  let offset_sign = (@string.Regex::string("+") | @string.Regex::string("-")).capture(
    "offset_sign",
  )
  let signed_offset = offset_sign +
    two_digits.capture("offset_hour") +
    colon +
    two_digits.capture("offset_minute")
  @string.Regex::unsafe_from_string("^") +
  year +
  dash +
  month +
  dash +
  day +
  @string.Regex::string("T") +
  hour +
  colon +
  minute +
  colon +
  second +
  fraction +
  (@string.Regex::string("Z") | signed_offset) +
  @string.Regex::unsafe_from_string("$")
}

///|
fn timestamp_json_required_group(
  timestamp_match : @string.MatchResult,
  name : String,
  path : @json.JsonPath,
) -> StringView raise @json.JsonDecodeError {
  guard timestamp_match.named_group(name) is Some(value) else {
    raise @json.JsonDecodeError((path, "Invalid Timestamp JSON value"))
  }
  value
}

///|
fn timestamp_from_json_string(
  value : String,
  path : @json.JsonPath,
) -> Timestamp raise @json.JsonDecodeError {
  guard timestamp_json_regex().execute(value) is Some(timestamp_match) else {
    raise @json.JsonDecodeError((path, "Invalid Timestamp JSON value"))
  }
  let nanos = match timestamp_match.named_group("nanos") {
    Some(nanos) => timestamp_parse_nanos(nanos, path)
    None => 0
  }
  let timezone_offset = match timestamp_match.named_group("offset_sign") {
    Some(sign) =>
      timestamp_parse_timezone_offset(
        sign == "-",
        timestamp_json_required_group(timestamp_match, "offset_hour", path),
        timestamp_json_required_group(timestamp_match, "offset_minute", path),
        path,
      )
    None => 0L
  }
  timestamp_from_parts(
    timestamp_json_required_group(timestamp_match, "year", path),
    timestamp_json_required_group(timestamp_match, "month", path),
    timestamp_json_required_group(timestamp_match, "day", path),
    timestamp_json_required_group(timestamp_match, "hour", path),
    timestamp_json_required_group(timestamp_match, "minute", path),
    timestamp_json_required_group(timestamp_match, "second", path),
    nanos,
    timezone_offset,
    path,
  )
}

///|
pub impl ToJson for Timestamp with fn to_json(self) {
  let days = timestamp_floor_div(self.seconds, 86400L)
  let seconds_of_day = timestamp_floor_mod(self.seconds, 86400L).to_int()
  let (year, month, day) = timestamp_civil_from_days(days)
  let hour = seconds_of_day / 3600
  let minute = seconds_of_day % 3600 / 60
  let second = seconds_of_day % 60
  let year_text = year.to_string().pad_start(4, '0')
  let month_text = month.to_string().pad_start(2, '0')
  let day_text = day.to_string().pad_start(2, '0')
  let hour_text = hour.to_string().pad_start(2, '0')
  let minute_text = minute.to_string().pad_start(2, '0')
  let second_text = second.to_string().pad_start(2, '0')
  let date = "\{year_text}-\{month_text}-\{day_text}"
  let time = "\{hour_text}:\{minute_text}:\{second_text}"
  "\{date}T\{time}\{wkt_json_format_nanos(self.nanos)}Z".to_json()
}

///|
pub impl @json.FromJson for Timestamp with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Timestamp raise {
  guard json is String(value) else {
    raise @json.JsonDecodeError((path, "Expected a string for Timestamp"))
  }
  timestamp_from_json_string(value, path)
}

///|
test "timestamp json accepts timezone offsets" {
  let timestamp : Timestamp = @json.from_json(
    "2017-01-15T01:30:15.01+08:00".to_json(),
  )
  inspect(timestamp.seconds, content="1484415015")
  inspect(timestamp.nanos, content="10000000")
  guard timestamp.to_json() is String(encoded) else {
    fail("expected Timestamp JSON string")
  }
  inspect(encoded, content="2017-01-14T17:30:15.010Z")

  let timestamp : Timestamp = @json.from_json(
    "2017-01-14T12:00:00.123-05:30".to_json(),
  )
  inspect(timestamp.seconds, content="1484415000")
  inspect(timestamp.nanos, content="123000000")
  guard timestamp.to_json() is String(encoded) else {
    fail("expected Timestamp JSON string")
  }
  inspect(encoded, content="2017-01-14T17:30:00.123Z")

  let timestamp : Timestamp = @json.from_json(
    "1970-01-01T00:00:00+01:00".to_json(),
  )
  inspect(timestamp.seconds, content="-3600")
  inspect(timestamp.nanos, content="0")
  guard timestamp.to_json() is String(encoded) else {
    fail("expected Timestamp JSON string")
  }
  inspect(encoded, content="1969-12-31T23:00:00Z")
}

///|
test "timestamp json rejects offset outside valid range" {
  try {
    let _ : Timestamp = @json.from_json("0001-01-01T00:00:00+01:00".to_json())
    fail("expected JsonDecodeError")
  } catch {
    @json.JsonDecodeError(_) => ()
    err => raise err
  }
}

///|
fn duration_parse_nanos(
  value : String,
  start : Int,
  end : Int,
  path : @json.JsonPath,
) -> Int raise @json.JsonDecodeError {
  if start == end || end - start > 9 {
    raise @json.JsonDecodeError((path, "Invalid Duration JSON value"))
  }
  let mut nanos = 0
  for i in start..<end {
    if value[i] < '0' || value[i] > '9' {
      raise @json.JsonDecodeError((path, "Invalid Duration JSON value"))
    }
    nanos = nanos * 10 + value[i].to_int() - '0'.to_int()
  }
  for _ in (end - start)..<9 {
    nanos *= 10
  }
  nanos
}

///|
fn duration_parse_seconds(
  value : String,
  start : Int,
  end : Int,
  path : @json.JsonPath,
) -> Int64 raise @json.JsonDecodeError {
  if start == end {
    raise @json.JsonDecodeError((path, "Invalid Duration JSON value"))
  }
  let mut seconds = 0L
  for i in start..<end {
    if value[i] < '0' || value[i] > '9' {
      raise @json.JsonDecodeError((path, "Invalid Duration JSON value"))
    }
    let digit = (value[i].to_int() - '0'.to_int()).to_int64()
    if seconds > (duration_max_seconds - digit) / 10L {
      raise @json.JsonDecodeError((path, "Invalid Duration JSON value"))
    }
    seconds = seconds * 10L + digit
  }
  seconds
}

///|
fn duration_validate_range(
  seconds : Int64,
  nanos : Int,
  path : @json.JsonPath,
) -> Unit raise @json.JsonDecodeError {
  if seconds < duration_min_seconds ||
    seconds > duration_max_seconds ||
    nanos < duration_min_nanos ||
    nanos > duration_max_nanos ||
    (seconds > 0L && nanos < 0) ||
    (seconds < 0L && nanos > 0) {
    raise @json.JsonDecodeError((path, "Invalid Duration JSON value"))
  }
}

///|
fn duration_from_json_string(
  value : String,
  path : @json.JsonPath,
) -> Duration raise @json.JsonDecodeError {
  if value.length() < 2 || value[value.length() - 1] != 's' {
    raise @json.JsonDecodeError((path, "Invalid Duration JSON value"))
  }
  let negative = value[0] == '-'
  let start = if negative { 1 } else { 0 }
  let end = value.length() - 1
  let fraction_start = value.find(".")
  let (whole_end, nanos) = if fraction_start is Some(dot) {
    (dot, duration_parse_nanos(value, dot + 1, end, path))
  } else {
    (end, 0)
  }
  if start == whole_end {
    raise @json.JsonDecodeError((path, "Invalid Duration JSON value"))
  }
  let seconds = duration_parse_seconds(value, start, whole_end, path)
  let duration = if negative {
    Duration::new(-seconds, -nanos)
  } else {
    Duration::new(seconds, nanos)
  }
  duration_validate_range(duration.seconds, duration.nanos, path)
  duration
}

///|
pub impl ToJson for Duration with fn to_json(self) {
  let sign = if self.seconds < 0L || self.nanos < 0 { "-" } else { "" }
  let seconds = if self.seconds < 0L { -self.seconds } else { self.seconds }
  let nanos = if self.nanos < 0 { -self.nanos } else { self.nanos }
  "\{sign}\{seconds}\{wkt_json_format_nanos(nanos)}s".to_json()
}

///|
pub impl @json.FromJson for Duration with fn from_json(
  json : Json,
  path : @json.JsonPath,
) -> Duration raise {
  guard json is String(value) else {
    raise @json.JsonDecodeError((path, "Expected a string for Duration"))
  }
  duration_from_json_string(value, path)
}

///|
test "duration json rejects values outside valid range" {
  try {
    let _ : Duration = @json.from_json("315576000001s".to_json())
    fail("expected JsonDecodeError")
  } catch {
    @json.JsonDecodeError(_) => ()
    err => raise err
  }

  try {
    let _ : Duration = @json.from_json(
      "999999999999999999999999999999999999999999s".to_json(),
    )
    fail("expected JsonDecodeError")
  } catch {
    @json.JsonDecodeError(_) => ()
    err => raise err
  }
}
