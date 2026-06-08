pub(all) struct User {
  mut user_id : String
  mut name : String
  mut email : String?
  mut orders : Array[Order]
  mut friends : Array[User]
} derive(Eq, Debug)
pub impl @lib.Sized for User with fn size_of(self) {
  let mut size = 0U
  size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.user_id))
  size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.name))
  if self.email is Some(v) {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(v))
  }
  for s in self.orders {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(s))
  }
  for s in self.friends {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(s))
  }
  size
}
pub impl Default for User with fn default() -> User {
  User::{
    user_id : String::default(),
    name : String::default(),
    email : None,
    orders : [],
    friends : [],
  }
}
pub fn User::new(user_id : String, name : String, email? : String, orders : Array[Order], friends : Array[User]) -> User {
  User::{
    user_id,
    name,
    email,
    orders,
    friends,
  }
}
pub impl @lib.Read for User with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> User raise {
  let msg = User::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.user_id = reader |> @lib.read_string()
      (2, _) => msg.name = reader |> @lib.read_string()
      (3, _) => msg.email = reader |> @lib.read_string() |> Some
      (4, 2) => msg.orders.push((reader |> @lib.read_message() : Order))
      (5, 2) => msg.friends.push((reader |> @lib.read_message() : User))
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.Write for User with fn write(self: User, writer : &@lib.Writer) -> Unit raise {
  writer |> @lib.write_varint(10UL);
  writer |> @lib.write_string(self.user_id)
  writer |> @lib.write_varint(18UL);
  writer |> @lib.write_string(self.name)
  if self.email is Some(v) {
    writer |> @lib.write_varint(26UL);
    writer |> @lib.write_string(v)
  }
  for item in self.orders {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_message(item)
  }
  for item in self.friends {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_message(item)
  }
}
pub impl ToJson for User with fn to_json(self) {
  let json: Map[String, Json] = {}
  if self.user_id != Default::default() {
  json["userId"] = self.user_id.to_json()
  }
  if self.name != Default::default() {
  json["name"] = self.name.to_json()
  }
  match self.email {
      Some(v) => json["email"] = v.to_json()
      _ => ()
    }
  if self.orders != Default::default() {
  json["orders"] = self.orders.to_json()
  }
  if self.friends != Default::default() {
  json["friends"] = self.friends.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for User with fn from_json(json: Json, path: @json.JsonPath) -> User raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for User"))
  }
  let message = User::default()
  for key, value in obj {
    match (key, value) {
      ("userId", value) => message.user_id = @json.from_json(value, path~)
      ("name", value) => message.name = @json.from_json(value, path~)
      ("email", value) => message.email = Some(@json.from_json(value, path~))
      ("orders", Array(value)) => message.orders = value.map(v => 
@json.from_json(v, path~))
      ("friends", Array(value)) => message.friends = value.map(v => 
@json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for User with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> User raise {
  let msg = User::default()
  while (reader |> @lib.async_read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.user_id = reader |> @lib.async_read_string()
      (2, _) => msg.name = reader |> @lib.async_read_string()
      (3, _) => msg.email = reader |> @lib.async_read_string() |> Some
      (4, 2) => msg.orders.push((reader |> @lib.async_read_message() : Order))
      (5, 2) => msg.friends.push((reader |> @lib.async_read_message() : User))
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.AsyncWrite for User with fn write(self: User, writer : &@lib.AsyncWriter) -> Unit raise {
  writer |> @lib.async_write_varint(10UL);
  writer |> @lib.async_write_string(self.user_id)
  writer |> @lib.async_write_varint(18UL);
  writer |> @lib.async_write_string(self.name)
  if self.email is Some(v) {
    writer |> @lib.async_write_varint(26UL);
    writer |> @lib.async_write_string(v)
  }
  for item in self.orders {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_message(item)
  }
  for item in self.friends {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_message(item)
  }
}
pub(all) struct Order {
  mut order_id : String
  mut product_name : String
  mut amount : Double?
  mut customer : User?
  mut related_orders : Array[Order]
} derive(Eq, Debug)
pub impl @lib.Sized for Order with fn size_of(self) {
  let mut size = 0U
  size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.order_id))
  size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.product_name))
  if self.amount is Some(_) {
    size += @lib.size_of_field(3U, 8U)
  }
  if self.customer is Some(v) {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(v))
  }
  for s in self.related_orders {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(s))
  }
  size
}
pub impl Default for Order with fn default() -> Order {
  Order::{
    order_id : String::default(),
    product_name : String::default(),
    amount : None,
    customer : None,
    related_orders : [],
  }
}
pub fn Order::new(order_id : String, product_name : String, amount? : Double, customer? : User, related_orders : Array[Order]) -> Order {
  Order::{
    order_id,
    product_name,
    amount,
    customer,
    related_orders,
  }
}
pub impl @lib.Read for Order with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> Order raise {
  let msg = Order::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.order_id = reader |> @lib.read_string()
      (2, _) => msg.product_name = reader |> @lib.read_string()
      (3, _) => msg.amount = reader |> @lib.read_double() |> Some
      (4, 2) => msg.customer = (reader |> @lib.read_message() : User) |> Some
      (5, 2) => msg.related_orders.push((reader |> @lib.read_message() : Order))
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.Write for Order with fn write(self: Order, writer : &@lib.Writer) -> Unit raise {
  writer |> @lib.write_varint(10UL);
  writer |> @lib.write_string(self.order_id)
  writer |> @lib.write_varint(18UL);
  writer |> @lib.write_string(self.product_name)
  if self.amount is Some(v) {
    writer |> @lib.write_varint(25UL);
    writer |> @lib.write_double(v)
  }
  if self.customer is Some(v) {
    writer |> @lib.write_varint(34UL);
    writer |> @lib.write_message(v)
  }
  for item in self.related_orders {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_message(item)
  }
}
pub impl ToJson for Order with fn to_json(self) {
  let json: Map[String, Json] = {}
  if self.order_id != Default::default() {
  json["orderId"] = self.order_id.to_json()
  }
  if self.product_name != Default::default() {
  json["productName"] = self.product_name.to_json()
  }
  match self.amount {
      Some(v) => json["amount"] = v.to_json()
      _ => ()
    }
  match self.customer {
      Some(v) => json["customer"] = v.to_json()
      _ => ()
    }
  if self.related_orders != Default::default() {
  json["relatedOrders"] = self.related_orders.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for Order with fn from_json(json: Json, path: @json.JsonPath) -> Order raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Order"))
  }
  let message = Order::default()
  for key, value in obj {
    match (key, value) {
      ("orderId", value) => message.order_id = @json.from_json(value, path~)
      ("productName", value) => message.product_name = @json.from_json(value, path~)
      ("amount", value) => message.amount = Some(@json.from_json(value, path~))
      ("customer", value) => message.customer = Some(@json.from_json(value, path~))
      ("relatedOrders", Array(value)) => message.related_orders = value.map(v => 
@json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for Order with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> Order raise {
  let msg = Order::default()
  while (reader |> @lib.async_read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.order_id = reader |> @lib.async_read_string()
      (2, _) => msg.product_name = reader |> @lib.async_read_string()
      (3, _) => msg.amount = reader |> @lib.async_read_double() |> Some
      (4, 2) => msg.customer = (reader |> @lib.async_read_message() : User) |> Some
      (5, 2) => msg.related_orders.push((reader |> @lib.async_read_message() : Order))
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.AsyncWrite for Order with fn write(self: Order, writer : &@lib.AsyncWriter) -> Unit raise {
  writer |> @lib.async_write_varint(10UL);
  writer |> @lib.async_write_string(self.order_id)
  writer |> @lib.async_write_varint(18UL);
  writer |> @lib.async_write_string(self.product_name)
  if self.amount is Some(v) {
    writer |> @lib.async_write_varint(25UL);
    writer |> @lib.async_write_double(v)
  }
  if self.customer is Some(v) {
    writer |> @lib.async_write_varint(34UL);
    writer |> @lib.async_write_message(v)
  }
  for item in self.related_orders {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_message(item)
  }
}
pub(all) struct Department {
  mut dept_id : String
  mut name : String
  mut employees : Array[Employee]
  mut projects : Array[Project]
  mut parent_dept : Department?
} derive(Eq, Debug)
pub impl @lib.Sized for Department with fn size_of(self) {
  let mut size = 0U
  size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.dept_id))
  size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.name))
  for s in self.employees {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(s))
  }
  for s in self.projects {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(s))
  }
  if self.parent_dept is Some(v) {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(v))
  }
  size
}
pub impl Default for Department with fn default() -> Department {
  Department::{
    dept_id : String::default(),
    name : String::default(),
    employees : [],
    projects : [],
    parent_dept : None,
  }
}
pub fn Department::new(dept_id : String, name : String, employees : Array[Employee], projects : Array[Project], parent_dept? : Department) -> Department {
  Department::{
    dept_id,
    name,
    employees,
    projects,
    parent_dept,
  }
}
pub impl @lib.Read for Department with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> Department raise {
  let msg = Department::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.dept_id = reader |> @lib.read_string()
      (2, _) => msg.name = reader |> @lib.read_string()
      (3, 2) => msg.employees.push((reader |> @lib.read_message() : Employee))
      (4, 2) => msg.projects.push((reader |> @lib.read_message() : Project))
      (5, 2) => msg.parent_dept = (reader |> @lib.read_message() : Department) |> Some
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.Write for Department with fn write(self: Department, writer : &@lib.Writer) -> Unit raise {
  writer |> @lib.write_varint(10UL);
  writer |> @lib.write_string(self.dept_id)
  writer |> @lib.write_varint(18UL);
  writer |> @lib.write_string(self.name)
  for item in self.employees {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_message(item)
  }
  for item in self.projects {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_message(item)
  }
  if self.parent_dept is Some(v) {
    writer |> @lib.write_varint(42UL);
    writer |> @lib.write_message(v)
  }
}
pub impl ToJson for Department with fn to_json(self) {
  let json: Map[String, Json] = {}
  if self.dept_id != Default::default() {
  json["deptId"] = self.dept_id.to_json()
  }
  if self.name != Default::default() {
  json["name"] = self.name.to_json()
  }
  if self.employees != Default::default() {
  json["employees"] = self.employees.to_json()
  }
  if self.projects != Default::default() {
  json["projects"] = self.projects.to_json()
  }
  match self.parent_dept {
      Some(v) => json["parentDept"] = v.to_json()
      _ => ()
    }
  Json::object(json)
}
pub impl @json.FromJson for Department with fn from_json(json: Json, path: @json.JsonPath) -> Department raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Department"))
  }
  let message = Department::default()
  for key, value in obj {
    match (key, value) {
      ("deptId", value) => message.dept_id = @json.from_json(value, path~)
      ("name", value) => message.name = @json.from_json(value, path~)
      ("employees", Array(value)) => message.employees = value.map(v => 
@json.from_json(v, path~))
      ("projects", Array(value)) => message.projects = value.map(v => 
@json.from_json(v, path~))
      ("parentDept", value) => message.parent_dept = Some(@json.from_json(value, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for Department with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> Department raise {
  let msg = Department::default()
  while (reader |> @lib.async_read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.dept_id = reader |> @lib.async_read_string()
      (2, _) => msg.name = reader |> @lib.async_read_string()
      (3, 2) => msg.employees.push((reader |> @lib.async_read_message() : Employee))
      (4, 2) => msg.projects.push((reader |> @lib.async_read_message() : Project))
      (5, 2) => msg.parent_dept = (reader |> @lib.async_read_message() : Department) |> Some
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.AsyncWrite for Department with fn write(self: Department, writer : &@lib.AsyncWriter) -> Unit raise {
  writer |> @lib.async_write_varint(10UL);
  writer |> @lib.async_write_string(self.dept_id)
  writer |> @lib.async_write_varint(18UL);
  writer |> @lib.async_write_string(self.name)
  for item in self.employees {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_message(item)
  }
  for item in self.projects {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_message(item)
  }
  if self.parent_dept is Some(v) {
    writer |> @lib.async_write_varint(42UL);
    writer |> @lib.async_write_message(v)
  }
}
pub(all) struct Employee {
  mut emp_id : String
  mut name : String
  mut department : Department?
  mut projects : Array[Project]
  mut supervisor : Employee?
  mut subordinates : Array[Employee]
} derive(Eq, Debug)
pub impl @lib.Sized for Employee with fn size_of(self) {
  let mut size = 0U
  size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.emp_id))
  size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.name))
  if self.department is Some(v) {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(v))
  }
  for s in self.projects {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(s))
  }
  if self.supervisor is Some(v) {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(v))
  }
  for s in self.subordinates {
    size += @lib.size_of_length_delimited_field(6U, @lib.size_of(s))
  }
  size
}
pub impl Default for Employee with fn default() -> Employee {
  Employee::{
    emp_id : String::default(),
    name : String::default(),
    department : None,
    projects : [],
    supervisor : None,
    subordinates : [],
  }
}
pub fn Employee::new(emp_id : String, name : String, department? : Department, projects : Array[Project], supervisor? : Employee, subordinates : Array[Employee]) -> Employee {
  Employee::{
    emp_id,
    name,
    department,
    projects,
    supervisor,
    subordinates,
  }
}
pub impl @lib.Read for Employee with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> Employee raise {
  let msg = Employee::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.emp_id = reader |> @lib.read_string()
      (2, _) => msg.name = reader |> @lib.read_string()
      (3, 2) => msg.department = (reader |> @lib.read_message() : Department) |> Some
      (4, 2) => msg.projects.push((reader |> @lib.read_message() : Project))
      (5, 2) => msg.supervisor = (reader |> @lib.read_message() : Employee) |> Some
      (6, 2) => msg.subordinates.push((reader |> @lib.read_message() : Employee))
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.Write for Employee with fn write(self: Employee, writer : &@lib.Writer) -> Unit raise {
  writer |> @lib.write_varint(10UL);
  writer |> @lib.write_string(self.emp_id)
  writer |> @lib.write_varint(18UL);
  writer |> @lib.write_string(self.name)
  if self.department is Some(v) {
    writer |> @lib.write_varint(26UL);
    writer |> @lib.write_message(v)
  }
  for item in self.projects {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_message(item)
  }
  if self.supervisor is Some(v) {
    writer |> @lib.write_varint(42UL);
    writer |> @lib.write_message(v)
  }
  for item in self.subordinates {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_message(item)
  }
}
pub impl ToJson for Employee with fn to_json(self) {
  let json: Map[String, Json] = {}
  if self.emp_id != Default::default() {
  json["empId"] = self.emp_id.to_json()
  }
  if self.name != Default::default() {
  json["name"] = self.name.to_json()
  }
  match self.department {
      Some(v) => json["department"] = v.to_json()
      _ => ()
    }
  if self.projects != Default::default() {
  json["projects"] = self.projects.to_json()
  }
  match self.supervisor {
      Some(v) => json["supervisor"] = v.to_json()
      _ => ()
    }
  if self.subordinates != Default::default() {
  json["subordinates"] = self.subordinates.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for Employee with fn from_json(json: Json, path: @json.JsonPath) -> Employee raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Employee"))
  }
  let message = Employee::default()
  for key, value in obj {
    match (key, value) {
      ("empId", value) => message.emp_id = @json.from_json(value, path~)
      ("name", value) => message.name = @json.from_json(value, path~)
      ("department", value) => message.department = Some(@json.from_json(value, path~))
      ("projects", Array(value)) => message.projects = value.map(v => 
@json.from_json(v, path~))
      ("supervisor", value) => message.supervisor = Some(@json.from_json(value, path~))
      ("subordinates", Array(value)) => message.subordinates = value.map(v => 
@json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for Employee with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> Employee raise {
  let msg = Employee::default()
  while (reader |> @lib.async_read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.emp_id = reader |> @lib.async_read_string()
      (2, _) => msg.name = reader |> @lib.async_read_string()
      (3, 2) => msg.department = (reader |> @lib.async_read_message() : Department) |> Some
      (4, 2) => msg.projects.push((reader |> @lib.async_read_message() : Project))
      (5, 2) => msg.supervisor = (reader |> @lib.async_read_message() : Employee) |> Some
      (6, 2) => msg.subordinates.push((reader |> @lib.async_read_message() : Employee))
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.AsyncWrite for Employee with fn write(self: Employee, writer : &@lib.AsyncWriter) -> Unit raise {
  writer |> @lib.async_write_varint(10UL);
  writer |> @lib.async_write_string(self.emp_id)
  writer |> @lib.async_write_varint(18UL);
  writer |> @lib.async_write_string(self.name)
  if self.department is Some(v) {
    writer |> @lib.async_write_varint(26UL);
    writer |> @lib.async_write_message(v)
  }
  for item in self.projects {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_message(item)
  }
  if self.supervisor is Some(v) {
    writer |> @lib.async_write_varint(42UL);
    writer |> @lib.async_write_message(v)
  }
  for item in self.subordinates {
    writer |> @lib.async_write_varint(50UL)
    writer |> @lib.async_write_message(item)
  }
}
pub(all) struct Project {
  mut project_id : String
  mut title : String
  mut description : String?
  mut department : Department?
  mut members : Array[Employee]
  mut dependencies : Array[Project]
  mut dependents : Array[Project]
} derive(Eq, Debug)
pub impl @lib.Sized for Project with fn size_of(self) {
  let mut size = 0U
  size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.project_id))
  size += @lib.size_of_length_delimited_field(2U, @lib.size_of(self.title))
  if self.description is Some(v) {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(v))
  }
  if self.department is Some(v) {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(v))
  }
  for s in self.members {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(s))
  }
  for s in self.dependencies {
    size += @lib.size_of_length_delimited_field(6U, @lib.size_of(s))
  }
  for s in self.dependents {
    size += @lib.size_of_length_delimited_field(7U, @lib.size_of(s))
  }
  size
}
pub impl Default for Project with fn default() -> Project {
  Project::{
    project_id : String::default(),
    title : String::default(),
    description : None,
    department : None,
    members : [],
    dependencies : [],
    dependents : [],
  }
}
pub fn Project::new(project_id : String, title : String, description? : String, department? : Department, members : Array[Employee], dependencies : Array[Project], dependents : Array[Project]) -> Project {
  Project::{
    project_id,
    title,
    description,
    department,
    members,
    dependencies,
    dependents,
  }
}
pub impl @lib.Read for Project with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> Project raise {
  let msg = Project::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.project_id = reader |> @lib.read_string()
      (2, _) => msg.title = reader |> @lib.read_string()
      (3, _) => msg.description = reader |> @lib.read_string() |> Some
      (4, 2) => msg.department = (reader |> @lib.read_message() : Department) |> Some
      (5, 2) => msg.members.push((reader |> @lib.read_message() : Employee))
      (6, 2) => msg.dependencies.push((reader |> @lib.read_message() : Project))
      (7, 2) => msg.dependents.push((reader |> @lib.read_message() : Project))
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.Write for Project with fn write(self: Project, writer : &@lib.Writer) -> Unit raise {
  writer |> @lib.write_varint(10UL);
  writer |> @lib.write_string(self.project_id)
  writer |> @lib.write_varint(18UL);
  writer |> @lib.write_string(self.title)
  if self.description is Some(v) {
    writer |> @lib.write_varint(26UL);
    writer |> @lib.write_string(v)
  }
  if self.department is Some(v) {
    writer |> @lib.write_varint(34UL);
    writer |> @lib.write_message(v)
  }
  for item in self.members {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_message(item)
  }
  for item in self.dependencies {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_message(item)
  }
  for item in self.dependents {
    writer |> @lib.write_varint(58UL)
    writer |> @lib.write_message(item)
  }
}
pub impl ToJson for Project with fn to_json(self) {
  let json: Map[String, Json] = {}
  if self.project_id != Default::default() {
  json["projectId"] = self.project_id.to_json()
  }
  if self.title != Default::default() {
  json["title"] = self.title.to_json()
  }
  match self.description {
      Some(v) => json["description"] = v.to_json()
      _ => ()
    }
  match self.department {
      Some(v) => json["department"] = v.to_json()
      _ => ()
    }
  if self.members != Default::default() {
  json["members"] = self.members.to_json()
  }
  if self.dependencies != Default::default() {
  json["dependencies"] = self.dependencies.to_json()
  }
  if self.dependents != Default::default() {
  json["dependents"] = self.dependents.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for Project with fn from_json(json: Json, path: @json.JsonPath) -> Project raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Project"))
  }
  let message = Project::default()
  for key, value in obj {
    match (key, value) {
      ("projectId", value) => message.project_id = @json.from_json(value, path~)
      ("title", value) => message.title = @json.from_json(value, path~)
      ("description", value) => message.description = Some(@json.from_json(value, path~))
      ("department", value) => message.department = Some(@json.from_json(value, path~))
      ("members", Array(value)) => message.members = value.map(v => 
@json.from_json(v, path~))
      ("dependencies", Array(value)) => message.dependencies = value.map(v => 
@json.from_json(v, path~))
      ("dependents", Array(value)) => message.dependents = value.map(v => 
@json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for Project with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> Project raise {
  let msg = Project::default()
  while (reader |> @lib.async_read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.project_id = reader |> @lib.async_read_string()
      (2, _) => msg.title = reader |> @lib.async_read_string()
      (3, _) => msg.description = reader |> @lib.async_read_string() |> Some
      (4, 2) => msg.department = (reader |> @lib.async_read_message() : Department) |> Some
      (5, 2) => msg.members.push((reader |> @lib.async_read_message() : Employee))
      (6, 2) => msg.dependencies.push((reader |> @lib.async_read_message() : Project))
      (7, 2) => msg.dependents.push((reader |> @lib.async_read_message() : Project))
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.AsyncWrite for Project with fn write(self: Project, writer : &@lib.AsyncWriter) -> Unit raise {
  writer |> @lib.async_write_varint(10UL);
  writer |> @lib.async_write_string(self.project_id)
  writer |> @lib.async_write_varint(18UL);
  writer |> @lib.async_write_string(self.title)
  if self.description is Some(v) {
    writer |> @lib.async_write_varint(26UL);
    writer |> @lib.async_write_string(v)
  }
  if self.department is Some(v) {
    writer |> @lib.async_write_varint(34UL);
    writer |> @lib.async_write_message(v)
  }
  for item in self.members {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_message(item)
  }
  for item in self.dependencies {
    writer |> @lib.async_write_varint(50UL)
    writer |> @lib.async_write_message(item)
  }
  for item in self.dependents {
    writer |> @lib.async_write_varint(58UL)
    writer |> @lib.async_write_message(item)
  }
}
pub(all) struct Node_Connection {
  mut connection_id : String
  mut type_ : String?
  mut source : Node?
  mut target : Node?
  mut weight : Weight?
} derive(Eq, Debug)
pub impl @lib.Sized for Node_Connection with fn size_of(self) {
  let mut size = 0U
  size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.connection_id))
  if self.type_ is Some(v) {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
  }
  if self.source is Some(v) {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(v))
  }
  if self.target is Some(v) {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(v))
  }
  if self.weight is Some(v) {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(v))
  }
  size
}
pub impl Default for Node_Connection with fn default() -> Node_Connection {
  Node_Connection::{
    connection_id : String::default(),
    type_ : None,
    source : None,
    target : None,
    weight : None,
  }
}
pub fn Node_Connection::new(connection_id : String, type_? : String, source? : Node, target? : Node, weight? : Weight) -> Node_Connection {
  Node_Connection::{
    connection_id,
    type_,
    source,
    target,
    weight,
  }
}
pub impl @lib.Read for Node_Connection with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> Node_Connection raise {
  let msg = Node_Connection::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.connection_id = reader |> @lib.read_string()
      (2, _) => msg.type_ = reader |> @lib.read_string() |> Some
      (3, 2) => msg.source = (reader |> @lib.read_message() : Node) |> Some
      (4, 2) => msg.target = (reader |> @lib.read_message() : Node) |> Some
      (5, 2) => msg.weight = (reader |> @lib.read_message() : Weight) |> Some
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.Write for Node_Connection with fn write(self: Node_Connection, writer : &@lib.Writer) -> Unit raise {
  writer |> @lib.write_varint(10UL);
  writer |> @lib.write_string(self.connection_id)
  if self.type_ is Some(v) {
    writer |> @lib.write_varint(18UL);
    writer |> @lib.write_string(v)
  }
  if self.source is Some(v) {
    writer |> @lib.write_varint(26UL);
    writer |> @lib.write_message(v)
  }
  if self.target is Some(v) {
    writer |> @lib.write_varint(34UL);
    writer |> @lib.write_message(v)
  }
  if self.weight is Some(v) {
    writer |> @lib.write_varint(42UL);
    writer |> @lib.write_message(v)
  }
}
pub impl ToJson for Node_Connection with fn to_json(self) {
  let json: Map[String, Json] = {}
  if self.connection_id != Default::default() {
  json["connectionId"] = self.connection_id.to_json()
  }
  match self.type_ {
      Some(v) => json["type"] = v.to_json()
      _ => ()
    }
  match self.source {
      Some(v) => json["source"] = v.to_json()
      _ => ()
    }
  match self.target {
      Some(v) => json["target"] = v.to_json()
      _ => ()
    }
  match self.weight {
      Some(v) => json["weight"] = v.to_json()
      _ => ()
    }
  Json::object(json)
}
pub impl @json.FromJson for Node_Connection with fn from_json(json: Json, path: @json.JsonPath) -> Node_Connection raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Node_Connection"))
  }
  let message = Node_Connection::default()
  for key, value in obj {
    match (key, value) {
      ("connectionId", value) => message.connection_id = @json.from_json(value, path~)
      ("type", value) => message.type_ = Some(@json.from_json(value, path~))
      ("source", value) => message.source = Some(@json.from_json(value, path~))
      ("target", value) => message.target = Some(@json.from_json(value, path~))
      ("weight", value) => message.weight = Some(@json.from_json(value, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for Node_Connection with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> Node_Connection raise {
  let msg = Node_Connection::default()
  while (reader |> @lib.async_read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.connection_id = reader |> @lib.async_read_string()
      (2, _) => msg.type_ = reader |> @lib.async_read_string() |> Some
      (3, 2) => msg.source = (reader |> @lib.async_read_message() : Node) |> Some
      (4, 2) => msg.target = (reader |> @lib.async_read_message() : Node) |> Some
      (5, 2) => msg.weight = (reader |> @lib.async_read_message() : Weight) |> Some
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.AsyncWrite for Node_Connection with fn write(self: Node_Connection, writer : &@lib.AsyncWriter) -> Unit raise {
  writer |> @lib.async_write_varint(10UL);
  writer |> @lib.async_write_string(self.connection_id)
  if self.type_ is Some(v) {
    writer |> @lib.async_write_varint(18UL);
    writer |> @lib.async_write_string(v)
  }
  if self.source is Some(v) {
    writer |> @lib.async_write_varint(26UL);
    writer |> @lib.async_write_message(v)
  }
  if self.target is Some(v) {
    writer |> @lib.async_write_varint(34UL);
    writer |> @lib.async_write_message(v)
  }
  if self.weight is Some(v) {
    writer |> @lib.async_write_varint(42UL);
    writer |> @lib.async_write_message(v)
  }
}
pub(all) struct Node {
  mut id : String
  mut data : String?
  mut connections : Array[Node_Connection]
  mut neighbors : Array[Node]
} derive(Eq, Debug)
pub impl @lib.Sized for Node with fn size_of(self) {
  let mut size = 0U
  size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.id))
  if self.data is Some(v) {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
  }
  for s in self.connections {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(s))
  }
  for s in self.neighbors {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(s))
  }
  size
}
pub impl Default for Node with fn default() -> Node {
  Node::{
    id : String::default(),
    data : None,
    connections : [],
    neighbors : [],
  }
}
pub fn Node::new(id : String, data? : String, connections : Array[Node_Connection], neighbors : Array[Node]) -> Node {
  Node::{
    id,
    data,
    connections,
    neighbors,
  }
}
pub impl @lib.Read for Node with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> Node raise {
  let msg = Node::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.id = reader |> @lib.read_string()
      (2, _) => msg.data = reader |> @lib.read_string() |> Some
      (3, 2) => msg.connections.push((reader |> @lib.read_message() : Node_Connection))
      (4, 2) => msg.neighbors.push((reader |> @lib.read_message() : Node))
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.Write for Node with fn write(self: Node, writer : &@lib.Writer) -> Unit raise {
  writer |> @lib.write_varint(10UL);
  writer |> @lib.write_string(self.id)
  if self.data is Some(v) {
    writer |> @lib.write_varint(18UL);
    writer |> @lib.write_string(v)
  }
  for item in self.connections {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_message(item)
  }
  for item in self.neighbors {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_message(item)
  }
}
pub impl ToJson for Node with fn to_json(self) {
  let json: Map[String, Json] = {}
  if self.id != Default::default() {
  json["id"] = self.id.to_json()
  }
  match self.data {
      Some(v) => json["data"] = v.to_json()
      _ => ()
    }
  if self.connections != Default::default() {
  json["connections"] = self.connections.to_json()
  }
  if self.neighbors != Default::default() {
  json["neighbors"] = self.neighbors.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for Node with fn from_json(json: Json, path: @json.JsonPath) -> Node raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Node"))
  }
  let message = Node::default()
  for key, value in obj {
    match (key, value) {
      ("id", value) => message.id = @json.from_json(value, path~)
      ("data", value) => message.data = Some(@json.from_json(value, path~))
      ("connections", Array(value)) => message.connections = value.map(v => 
@json.from_json(v, path~))
      ("neighbors", Array(value)) => message.neighbors = value.map(v => 
@json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for Node with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> Node raise {
  let msg = Node::default()
  while (reader |> @lib.async_read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.id = reader |> @lib.async_read_string()
      (2, _) => msg.data = reader |> @lib.async_read_string() |> Some
      (3, 2) => msg.connections.push((reader |> @lib.async_read_message() : Node_Connection))
      (4, 2) => msg.neighbors.push((reader |> @lib.async_read_message() : Node))
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.AsyncWrite for Node with fn write(self: Node, writer : &@lib.AsyncWriter) -> Unit raise {
  writer |> @lib.async_write_varint(10UL);
  writer |> @lib.async_write_string(self.id)
  if self.data is Some(v) {
    writer |> @lib.async_write_varint(18UL);
    writer |> @lib.async_write_string(v)
  }
  for item in self.connections {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_message(item)
  }
  for item in self.neighbors {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_message(item)
  }
}
pub(all) struct Weight {
  mut value : Double
  mut unit : String?
  mut connection : Node_Connection?
  mut related_nodes : Array[Node]
} derive(Eq, Debug)
pub impl @lib.Sized for Weight with fn size_of(self) {
  let mut size = 0U
  size += @lib.size_of_field(1U, 8U)
  if self.unit is Some(v) {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
  }
  if self.connection is Some(v) {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(v))
  }
  for s in self.related_nodes {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(s))
  }
  size
}
pub impl Default for Weight with fn default() -> Weight {
  Weight::{
    value : Double::default(),
    unit : None,
    connection : None,
    related_nodes : [],
  }
}
pub fn Weight::new(value : Double, unit? : String, connection? : Node_Connection, related_nodes : Array[Node]) -> Weight {
  Weight::{
    value,
    unit,
    connection,
    related_nodes,
  }
}
pub impl @lib.Read for Weight with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> Weight raise {
  let msg = Weight::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.value = reader |> @lib.read_double()
      (2, _) => msg.unit = reader |> @lib.read_string() |> Some
      (3, 2) => msg.connection = (reader |> @lib.read_message() : Node_Connection) |> Some
      (4, 2) => msg.related_nodes.push((reader |> @lib.read_message() : Node))
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.Write for Weight with fn write(self: Weight, writer : &@lib.Writer) -> Unit raise {
  writer |> @lib.write_varint(9UL);
  writer |> @lib.write_double(self.value)
  if self.unit is Some(v) {
    writer |> @lib.write_varint(18UL);
    writer |> @lib.write_string(v)
  }
  if self.connection is Some(v) {
    writer |> @lib.write_varint(26UL);
    writer |> @lib.write_message(v)
  }
  for item in self.related_nodes {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_message(item)
  }
}
pub impl ToJson for Weight with fn to_json(self) {
  let json: Map[String, Json] = {}
  if self.value != Default::default() {
  json["value"] = self.value.to_json()
  }
  match self.unit {
      Some(v) => json["unit"] = v.to_json()
      _ => ()
    }
  match self.connection {
      Some(v) => json["connection"] = v.to_json()
      _ => ()
    }
  if self.related_nodes != Default::default() {
  json["relatedNodes"] = self.related_nodes.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for Weight with fn from_json(json: Json, path: @json.JsonPath) -> Weight raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Weight"))
  }
  let message = Weight::default()
  for key, value in obj {
    match (key, value) {
      ("value", value) => message.value = @json.from_json(value, path~)
      ("unit", value) => message.unit = Some(@json.from_json(value, path~))
      ("connection", value) => message.connection = Some(@json.from_json(value, path~))
      ("relatedNodes", Array(value)) => message.related_nodes = value.map(v => 
@json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for Weight with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> Weight raise {
  let msg = Weight::default()
  while (reader |> @lib.async_read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.value = reader |> @lib.async_read_double()
      (2, _) => msg.unit = reader |> @lib.async_read_string() |> Some
      (3, 2) => msg.connection = (reader |> @lib.async_read_message() : Node_Connection) |> Some
      (4, 2) => msg.related_nodes.push((reader |> @lib.async_read_message() : Node))
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.AsyncWrite for Weight with fn write(self: Weight, writer : &@lib.AsyncWriter) -> Unit raise {
  writer |> @lib.async_write_varint(9UL);
  writer |> @lib.async_write_double(self.value)
  if self.unit is Some(v) {
    writer |> @lib.async_write_varint(18UL);
    writer |> @lib.async_write_string(v)
  }
  if self.connection is Some(v) {
    writer |> @lib.async_write_varint(26UL);
    writer |> @lib.async_write_message(v)
  }
  for item in self.related_nodes {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_message(item)
  }
}
pub(all) struct Graph {
  mut graph_id : String
  mut name : String?
  mut vertices : Array[Vertex]
  mut edges : Array[Edge]
} derive(Eq, Debug)
pub impl @lib.Sized for Graph with fn size_of(self) {
  let mut size = 0U
  size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.graph_id))
  if self.name is Some(v) {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
  }
  for s in self.vertices {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(s))
  }
  for s in self.edges {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(s))
  }
  size
}
pub impl Default for Graph with fn default() -> Graph {
  Graph::{
    graph_id : String::default(),
    name : None,
    vertices : [],
    edges : [],
  }
}
pub fn Graph::new(graph_id : String, name? : String, vertices : Array[Vertex], edges : Array[Edge]) -> Graph {
  Graph::{
    graph_id,
    name,
    vertices,
    edges,
  }
}
pub impl @lib.Read for Graph with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> Graph raise {
  let msg = Graph::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.graph_id = reader |> @lib.read_string()
      (2, _) => msg.name = reader |> @lib.read_string() |> Some
      (3, 2) => msg.vertices.push((reader |> @lib.read_message() : Vertex))
      (4, 2) => msg.edges.push((reader |> @lib.read_message() : Edge))
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.Write for Graph with fn write(self: Graph, writer : &@lib.Writer) -> Unit raise {
  writer |> @lib.write_varint(10UL);
  writer |> @lib.write_string(self.graph_id)
  if self.name is Some(v) {
    writer |> @lib.write_varint(18UL);
    writer |> @lib.write_string(v)
  }
  for item in self.vertices {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_message(item)
  }
  for item in self.edges {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_message(item)
  }
}
pub impl ToJson for Graph with fn to_json(self) {
  let json: Map[String, Json] = {}
  if self.graph_id != Default::default() {
  json["graphId"] = self.graph_id.to_json()
  }
  match self.name {
      Some(v) => json["name"] = v.to_json()
      _ => ()
    }
  if self.vertices != Default::default() {
  json["vertices"] = self.vertices.to_json()
  }
  if self.edges != Default::default() {
  json["edges"] = self.edges.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for Graph with fn from_json(json: Json, path: @json.JsonPath) -> Graph raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Graph"))
  }
  let message = Graph::default()
  for key, value in obj {
    match (key, value) {
      ("graphId", value) => message.graph_id = @json.from_json(value, path~)
      ("name", value) => message.name = Some(@json.from_json(value, path~))
      ("vertices", Array(value)) => message.vertices = value.map(v => 
@json.from_json(v, path~))
      ("edges", Array(value)) => message.edges = value.map(v => 
@json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for Graph with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> Graph raise {
  let msg = Graph::default()
  while (reader |> @lib.async_read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.graph_id = reader |> @lib.async_read_string()
      (2, _) => msg.name = reader |> @lib.async_read_string() |> Some
      (3, 2) => msg.vertices.push((reader |> @lib.async_read_message() : Vertex))
      (4, 2) => msg.edges.push((reader |> @lib.async_read_message() : Edge))
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.AsyncWrite for Graph with fn write(self: Graph, writer : &@lib.AsyncWriter) -> Unit raise {
  writer |> @lib.async_write_varint(10UL);
  writer |> @lib.async_write_string(self.graph_id)
  if self.name is Some(v) {
    writer |> @lib.async_write_varint(18UL);
    writer |> @lib.async_write_string(v)
  }
  for item in self.vertices {
    writer |> @lib.async_write_varint(26UL)
    writer |> @lib.async_write_message(item)
  }
  for item in self.edges {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_message(item)
  }
}
pub(all) struct Vertex {
  mut vertex_id : String
  mut label : String?
  mut graph : Graph?
  mut incoming_edges : Array[Edge]
  mut outgoing_edges : Array[Edge]
  mut adjacent_vertices : Array[Vertex]
} derive(Eq, Debug)
pub impl @lib.Sized for Vertex with fn size_of(self) {
  let mut size = 0U
  size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.vertex_id))
  if self.label is Some(v) {
    size += @lib.size_of_length_delimited_field(2U, @lib.size_of(v))
  }
  if self.graph is Some(v) {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(v))
  }
  for s in self.incoming_edges {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(s))
  }
  for s in self.outgoing_edges {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(s))
  }
  for s in self.adjacent_vertices {
    size += @lib.size_of_length_delimited_field(6U, @lib.size_of(s))
  }
  size
}
pub impl Default for Vertex with fn default() -> Vertex {
  Vertex::{
    vertex_id : String::default(),
    label : None,
    graph : None,
    incoming_edges : [],
    outgoing_edges : [],
    adjacent_vertices : [],
  }
}
pub fn Vertex::new(vertex_id : String, label? : String, graph? : Graph, incoming_edges : Array[Edge], outgoing_edges : Array[Edge], adjacent_vertices : Array[Vertex]) -> Vertex {
  Vertex::{
    vertex_id,
    label,
    graph,
    incoming_edges,
    outgoing_edges,
    adjacent_vertices,
  }
}
pub impl @lib.Read for Vertex with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> Vertex raise {
  let msg = Vertex::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.vertex_id = reader |> @lib.read_string()
      (2, _) => msg.label = reader |> @lib.read_string() |> Some
      (3, 2) => msg.graph = (reader |> @lib.read_message() : Graph) |> Some
      (4, 2) => msg.incoming_edges.push((reader |> @lib.read_message() : Edge))
      (5, 2) => msg.outgoing_edges.push((reader |> @lib.read_message() : Edge))
      (6, 2) => msg.adjacent_vertices.push((reader |> @lib.read_message() : Vertex))
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.Write for Vertex with fn write(self: Vertex, writer : &@lib.Writer) -> Unit raise {
  writer |> @lib.write_varint(10UL);
  writer |> @lib.write_string(self.vertex_id)
  if self.label is Some(v) {
    writer |> @lib.write_varint(18UL);
    writer |> @lib.write_string(v)
  }
  if self.graph is Some(v) {
    writer |> @lib.write_varint(26UL);
    writer |> @lib.write_message(v)
  }
  for item in self.incoming_edges {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_message(item)
  }
  for item in self.outgoing_edges {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_message(item)
  }
  for item in self.adjacent_vertices {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_message(item)
  }
}
pub impl ToJson for Vertex with fn to_json(self) {
  let json: Map[String, Json] = {}
  if self.vertex_id != Default::default() {
  json["vertexId"] = self.vertex_id.to_json()
  }
  match self.label {
      Some(v) => json["label"] = v.to_json()
      _ => ()
    }
  match self.graph {
      Some(v) => json["graph"] = v.to_json()
      _ => ()
    }
  if self.incoming_edges != Default::default() {
  json["incomingEdges"] = self.incoming_edges.to_json()
  }
  if self.outgoing_edges != Default::default() {
  json["outgoingEdges"] = self.outgoing_edges.to_json()
  }
  if self.adjacent_vertices != Default::default() {
  json["adjacentVertices"] = self.adjacent_vertices.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for Vertex with fn from_json(json: Json, path: @json.JsonPath) -> Vertex raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Vertex"))
  }
  let message = Vertex::default()
  for key, value in obj {
    match (key, value) {
      ("vertexId", value) => message.vertex_id = @json.from_json(value, path~)
      ("label", value) => message.label = Some(@json.from_json(value, path~))
      ("graph", value) => message.graph = Some(@json.from_json(value, path~))
      ("incomingEdges", Array(value)) => message.incoming_edges = value.map(v => 
@json.from_json(v, path~))
      ("outgoingEdges", Array(value)) => message.outgoing_edges = value.map(v => 
@json.from_json(v, path~))
      ("adjacentVertices", Array(value)) => message.adjacent_vertices = value.map(v => 
@json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for Vertex with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> Vertex raise {
  let msg = Vertex::default()
  while (reader |> @lib.async_read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.vertex_id = reader |> @lib.async_read_string()
      (2, _) => msg.label = reader |> @lib.async_read_string() |> Some
      (3, 2) => msg.graph = (reader |> @lib.async_read_message() : Graph) |> Some
      (4, 2) => msg.incoming_edges.push((reader |> @lib.async_read_message() : Edge))
      (5, 2) => msg.outgoing_edges.push((reader |> @lib.async_read_message() : Edge))
      (6, 2) => msg.adjacent_vertices.push((reader |> @lib.async_read_message() : Vertex))
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.AsyncWrite for Vertex with fn write(self: Vertex, writer : &@lib.AsyncWriter) -> Unit raise {
  writer |> @lib.async_write_varint(10UL);
  writer |> @lib.async_write_string(self.vertex_id)
  if self.label is Some(v) {
    writer |> @lib.async_write_varint(18UL);
    writer |> @lib.async_write_string(v)
  }
  if self.graph is Some(v) {
    writer |> @lib.async_write_varint(26UL);
    writer |> @lib.async_write_message(v)
  }
  for item in self.incoming_edges {
    writer |> @lib.async_write_varint(34UL)
    writer |> @lib.async_write_message(item)
  }
  for item in self.outgoing_edges {
    writer |> @lib.async_write_varint(42UL)
    writer |> @lib.async_write_message(item)
  }
  for item in self.adjacent_vertices {
    writer |> @lib.async_write_varint(50UL)
    writer |> @lib.async_write_message(item)
  }
}
pub(all) struct Edge {
  mut edge_id : String
  mut weight : Double?
  mut graph : Graph?
  mut source_vertex : Vertex?
  mut target_vertex : Vertex?
  mut parallel_edges : Array[Edge]
} derive(Eq, Debug)
pub impl @lib.Sized for Edge with fn size_of(self) {
  let mut size = 0U
  size += @lib.size_of_length_delimited_field(1U, @lib.size_of(self.edge_id))
  if self.weight is Some(_) {
    size += @lib.size_of_field(2U, 8U)
  }
  if self.graph is Some(v) {
    size += @lib.size_of_length_delimited_field(3U, @lib.size_of(v))
  }
  if self.source_vertex is Some(v) {
    size += @lib.size_of_length_delimited_field(4U, @lib.size_of(v))
  }
  if self.target_vertex is Some(v) {
    size += @lib.size_of_length_delimited_field(5U, @lib.size_of(v))
  }
  for s in self.parallel_edges {
    size += @lib.size_of_length_delimited_field(6U, @lib.size_of(s))
  }
  size
}
pub impl Default for Edge with fn default() -> Edge {
  Edge::{
    edge_id : String::default(),
    weight : None,
    graph : None,
    source_vertex : None,
    target_vertex : None,
    parallel_edges : [],
  }
}
pub fn Edge::new(edge_id : String, weight? : Double, graph? : Graph, source_vertex? : Vertex, target_vertex? : Vertex, parallel_edges : Array[Edge]) -> Edge {
  Edge::{
    edge_id,
    weight,
    graph,
    source_vertex,
    target_vertex,
    parallel_edges,
  }
}
pub impl @lib.Read for Edge with fn read_with_limit(reader : @lib.LimitedReader[&@lib.Reader]) -> Edge raise {
  let msg = Edge::default()
  while (reader |> @lib.read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.edge_id = reader |> @lib.read_string()
      (2, _) => msg.weight = reader |> @lib.read_double() |> Some
      (3, 2) => msg.graph = (reader |> @lib.read_message() : Graph) |> Some
      (4, 2) => msg.source_vertex = (reader |> @lib.read_message() : Vertex) |> Some
      (5, 2) => msg.target_vertex = (reader |> @lib.read_message() : Vertex) |> Some
      (6, 2) => msg.parallel_edges.push((reader |> @lib.read_message() : Edge))
      _ => reader |> @lib.skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.Write for Edge with fn write(self: Edge, writer : &@lib.Writer) -> Unit raise {
  writer |> @lib.write_varint(10UL);
  writer |> @lib.write_string(self.edge_id)
  if self.weight is Some(v) {
    writer |> @lib.write_varint(17UL);
    writer |> @lib.write_double(v)
  }
  if self.graph is Some(v) {
    writer |> @lib.write_varint(26UL);
    writer |> @lib.write_message(v)
  }
  if self.source_vertex is Some(v) {
    writer |> @lib.write_varint(34UL);
    writer |> @lib.write_message(v)
  }
  if self.target_vertex is Some(v) {
    writer |> @lib.write_varint(42UL);
    writer |> @lib.write_message(v)
  }
  for item in self.parallel_edges {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_message(item)
  }
}
pub impl ToJson for Edge with fn to_json(self) {
  let json: Map[String, Json] = {}
  if self.edge_id != Default::default() {
  json["edgeId"] = self.edge_id.to_json()
  }
  match self.weight {
      Some(v) => json["weight"] = v.to_json()
      _ => ()
    }
  match self.graph {
      Some(v) => json["graph"] = v.to_json()
      _ => ()
    }
  match self.source_vertex {
      Some(v) => json["sourceVertex"] = v.to_json()
      _ => ()
    }
  match self.target_vertex {
      Some(v) => json["targetVertex"] = v.to_json()
      _ => ()
    }
  if self.parallel_edges != Default::default() {
  json["parallelEdges"] = self.parallel_edges.to_json()
  }
  Json::object(json)
}
pub impl @json.FromJson for Edge with fn from_json(json: Json, path: @json.JsonPath) -> Edge raise {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Expected an object for Edge"))
  }
  let message = Edge::default()
  for key, value in obj {
    match (key, value) {
      ("edgeId", value) => message.edge_id = @json.from_json(value, path~)
      ("weight", value) => message.weight = Some(@json.from_json(value, path~))
      ("graph", value) => message.graph = Some(@json.from_json(value, path~))
      ("sourceVertex", value) => message.source_vertex = Some(@json.from_json(value, path~))
      ("targetVertex", value) => message.target_vertex = Some(@json.from_json(value, path~))
      ("parallelEdges", Array(value)) => message.parallel_edges = value.map(v => 
@json.from_json(v, path~))
      (key, _) => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
    }
  }
  message
}
pub impl @lib.AsyncRead for Edge with fn read_with_limit(reader : @lib.LimitedReader[&@lib.AsyncReader]) -> Edge raise {
  let msg = Edge::default()
  while (reader |> @lib.async_read_next_message_field()) is Some((field_number, wire)) {
    match (field_number, wire) {
      (1, _) => msg.edge_id = reader |> @lib.async_read_string()
      (2, _) => msg.weight = reader |> @lib.async_read_double() |> Some
      (3, 2) => msg.graph = (reader |> @lib.async_read_message() : Graph) |> Some
      (4, 2) => msg.source_vertex = (reader |> @lib.async_read_message() : Vertex) |> Some
      (5, 2) => msg.target_vertex = (reader |> @lib.async_read_message() : Vertex) |> Some
      (6, 2) => msg.parallel_edges.push((reader |> @lib.async_read_message() : Edge))
      _ => reader |> @lib.async_skip_message_field_by_number(field_number, wire)
    }
  }
  msg
}
pub impl @lib.AsyncWrite for Edge with fn write(self: Edge, writer : &@lib.AsyncWriter) -> Unit raise {
  writer |> @lib.async_write_varint(10UL);
  writer |> @lib.async_write_string(self.edge_id)
  if self.weight is Some(v) {
    writer |> @lib.async_write_varint(17UL);
    writer |> @lib.async_write_double(v)
  }
  if self.graph is Some(v) {
    writer |> @lib.async_write_varint(26UL);
    writer |> @lib.async_write_message(v)
  }
  if self.source_vertex is Some(v) {
    writer |> @lib.async_write_varint(34UL);
    writer |> @lib.async_write_message(v)
  }
  if self.target_vertex is Some(v) {
    writer |> @lib.async_write_varint(42UL);
    writer |> @lib.async_write_message(v)
  }
  for item in self.parallel_edges {
    writer |> @lib.async_write_varint(50UL)
    writer |> @lib.async_write_message(item)
  }
}
