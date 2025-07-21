pub(all) struct User {
  mut user_id : String
  mut name : String
  mut email : String?
  mut orders : Array[Order]
  mut friends : Array[User]
} derive(Eq, Show)
pub impl @lib.Sized for User with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.user_id); @lib.size_of(size) + size }
  size += 1U + { let size = @lib.size_of(self.name); @lib.size_of(size) + size }
  match self.email {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size += self.orders.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size += self.friends.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size
}
pub impl Default for User with default() -> User {
  User::{
    user_id : String::default(),
    name : String::default(),
    email : None,
    orders : [],
    friends : [],
  }
}
pub impl @lib.Read for User with read(reader : &@lib.Reader) {
  let msg =   User::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.user_id = reader |> @lib.read_string()
      (2, _) => msg.name = reader |> @lib.read_string()
      (3, _) => msg.email = reader |> @lib.read_string() |> Some
      (4, _) => msg.orders.push(((reader |> @lib.read_message()) : Order))
      (5, _) => msg.friends.push(((reader |> @lib.read_message()) : User))
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for User with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.user_id)
  writer |> @lib.write_varint(18UL);writer |> @lib.write_string(self.name)
  match self.email {
    Some(v) => {
      writer |> @lib.write_varint(26UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
  self.orders.iter().each(fn(v) {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  self.friends.iter().each(fn(v) {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
}
pub impl ToJson for User with to_json(self) {

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
pub impl @json.FromJson for User with from_json(json: Json, path: @json.JsonPath) -> User raise {
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
pub(all) struct Order {
  mut order_id : String
  mut product_name : String
  mut amount : Double?
  mut customer : User?
  mut related_orders : Array[Order]
} derive(Eq, Show)
pub impl @lib.Sized for Order with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.order_id); @lib.size_of(size) + size }
  size += 1U + { let size = @lib.size_of(self.product_name); @lib.size_of(size) + size }
  match self.amount {
    Some(v) => size += 1U + 8U
    None => ()
  }
  match self.customer {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size += self.related_orders.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size
}
pub impl Default for Order with default() -> Order {
  Order::{
    order_id : String::default(),
    product_name : String::default(),
    amount : None,
    customer : None,
    related_orders : [],
  }
}
pub impl @lib.Read for Order with read(reader : &@lib.Reader) {
  let msg =   Order::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.order_id = reader |> @lib.read_string()
      (2, _) => msg.product_name = reader |> @lib.read_string()
      (3, _) => msg.amount = reader |> @lib.read_double() |> Some
      (4, _) => msg.customer = ((reader |> @lib.read_message()) : User) |> Some
      (5, _) => msg.related_orders.push(((reader |> @lib.read_message()) : Order))
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Order with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.order_id)
  writer |> @lib.write_varint(18UL);writer |> @lib.write_string(self.product_name)
  match self.amount {
    Some(v) => {
      writer |> @lib.write_varint(25UL);writer |> @lib.write_double(v)
    }
    None => ()
  }
  match self.customer {
    Some(v) => {
      writer |> @lib.write_varint(34UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.related_orders.iter().each(fn(v) {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
}
pub impl ToJson for Order with to_json(self) {

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
pub impl @json.FromJson for Order with from_json(json: Json, path: @json.JsonPath) -> Order raise {
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
pub(all) struct Department {
  mut dept_id : String
  mut name : String
  mut employees : Array[Employee]
  mut projects : Array[Project]
  mut parent_dept : Department?
} derive(Eq, Show)
pub impl @lib.Sized for Department with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.dept_id); @lib.size_of(size) + size }
  size += 1U + { let size = @lib.size_of(self.name); @lib.size_of(size) + size }
  size += self.employees.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size += self.projects.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  match self.parent_dept {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size
}
pub impl Default for Department with default() -> Department {
  Department::{
    dept_id : String::default(),
    name : String::default(),
    employees : [],
    projects : [],
    parent_dept : None,
  }
}
pub impl @lib.Read for Department with read(reader : &@lib.Reader) {
  let msg =   Department::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.dept_id = reader |> @lib.read_string()
      (2, _) => msg.name = reader |> @lib.read_string()
      (3, _) => msg.employees.push(((reader |> @lib.read_message()) : Employee))
      (4, _) => msg.projects.push(((reader |> @lib.read_message()) : Project))
      (5, _) => msg.parent_dept = ((reader |> @lib.read_message()) : Department) |> Some
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Department with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.dept_id)
  writer |> @lib.write_varint(18UL);writer |> @lib.write_string(self.name)
  self.employees.iter().each(fn(v) {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  self.projects.iter().each(fn(v) {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  match self.parent_dept {
    Some(v) => {
      writer |> @lib.write_varint(42UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
}
pub impl ToJson for Department with to_json(self) {

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
pub impl @json.FromJson for Department with from_json(json: Json, path: @json.JsonPath) -> Department raise {
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
pub(all) struct Employee {
  mut emp_id : String
  mut name : String
  mut department : Department?
  mut projects : Array[Project]
  mut supervisor : Employee?
  mut subordinates : Array[Employee]
} derive(Eq, Show)
pub impl @lib.Sized for Employee with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.emp_id); @lib.size_of(size) + size }
  size += 1U + { let size = @lib.size_of(self.name); @lib.size_of(size) + size }
  match self.department {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size += self.projects.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  match self.supervisor {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size += self.subordinates.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size
}
pub impl Default for Employee with default() -> Employee {
  Employee::{
    emp_id : String::default(),
    name : String::default(),
    department : None,
    projects : [],
    supervisor : None,
    subordinates : [],
  }
}
pub impl @lib.Read for Employee with read(reader : &@lib.Reader) {
  let msg =   Employee::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.emp_id = reader |> @lib.read_string()
      (2, _) => msg.name = reader |> @lib.read_string()
      (3, _) => msg.department = ((reader |> @lib.read_message()) : Department) |> Some
      (4, _) => msg.projects.push(((reader |> @lib.read_message()) : Project))
      (5, _) => msg.supervisor = ((reader |> @lib.read_message()) : Employee) |> Some
      (6, _) => msg.subordinates.push(((reader |> @lib.read_message()) : Employee))
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Employee with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.emp_id)
  writer |> @lib.write_varint(18UL);writer |> @lib.write_string(self.name)
  match self.department {
    Some(v) => {
      writer |> @lib.write_varint(26UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.projects.iter().each(fn(v) {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  match self.supervisor {
    Some(v) => {
      writer |> @lib.write_varint(42UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.subordinates.iter().each(fn(v) {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
}
pub impl ToJson for Employee with to_json(self) {

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
pub impl @json.FromJson for Employee with from_json(json: Json, path: @json.JsonPath) -> Employee raise {
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
pub(all) struct Project {
  mut project_id : String
  mut title : String
  mut description : String?
  mut department : Department?
  mut members : Array[Employee]
  mut dependencies : Array[Project]
  mut dependents : Array[Project]
} derive(Eq, Show)
pub impl @lib.Sized for Project with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.project_id); @lib.size_of(size) + size }
  size += 1U + { let size = @lib.size_of(self.title); @lib.size_of(size) + size }
  match self.description {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.department {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size += self.members.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size += self.dependencies.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size += self.dependents.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size
}
pub impl Default for Project with default() -> Project {
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
pub impl @lib.Read for Project with read(reader : &@lib.Reader) {
  let msg =   Project::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.project_id = reader |> @lib.read_string()
      (2, _) => msg.title = reader |> @lib.read_string()
      (3, _) => msg.description = reader |> @lib.read_string() |> Some
      (4, _) => msg.department = ((reader |> @lib.read_message()) : Department) |> Some
      (5, _) => msg.members.push(((reader |> @lib.read_message()) : Employee))
      (6, _) => msg.dependencies.push(((reader |> @lib.read_message()) : Project))
      (7, _) => msg.dependents.push(((reader |> @lib.read_message()) : Project))
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Project with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.project_id)
  writer |> @lib.write_varint(18UL);writer |> @lib.write_string(self.title)
  match self.description {
    Some(v) => {
      writer |> @lib.write_varint(26UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.department {
    Some(v) => {
      writer |> @lib.write_varint(34UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.members.iter().each(fn(v) {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  self.dependencies.iter().each(fn(v) {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  self.dependents.iter().each(fn(v) {
    writer |> @lib.write_varint(58UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
}
pub impl ToJson for Project with to_json(self) {

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
pub impl @json.FromJson for Project with from_json(json: Json, path: @json.JsonPath) -> Project raise {
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
pub(all) struct Node_Connection {
  mut connection_id : String
  mut type_ : String?
  mut source : Node?
  mut target : Node?
  mut weight : Weight?
} derive(Eq, Show)
pub impl @lib.Sized for Node_Connection with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.connection_id); @lib.size_of(size) + size }
  match self.type_ {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.source {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.target {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.weight {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size
}
pub impl Default for Node_Connection with default() -> Node_Connection {
  Node_Connection::{
    connection_id : String::default(),
    type_ : None,
    source : None,
    target : None,
    weight : None,
  }
}
pub impl @lib.Read for Node_Connection with read(reader : &@lib.Reader) {
  let msg =   Node_Connection::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.connection_id = reader |> @lib.read_string()
      (2, _) => msg.type_ = reader |> @lib.read_string() |> Some
      (3, _) => msg.source = ((reader |> @lib.read_message()) : Node) |> Some
      (4, _) => msg.target = ((reader |> @lib.read_message()) : Node) |> Some
      (5, _) => msg.weight = ((reader |> @lib.read_message()) : Weight) |> Some
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Node_Connection with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.connection_id)
  match self.type_ {
    Some(v) => {
      writer |> @lib.write_varint(18UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.source {
    Some(v) => {
      writer |> @lib.write_varint(26UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.target {
    Some(v) => {
      writer |> @lib.write_varint(34UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.weight {
    Some(v) => {
      writer |> @lib.write_varint(42UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
}
pub impl ToJson for Node_Connection with to_json(self) {

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
pub impl @json.FromJson for Node_Connection with from_json(json: Json, path: @json.JsonPath) -> Node_Connection raise {
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
pub(all) struct Node {
  mut id : String
  mut data : String?
  mut connections : Array[Node_Connection]
  mut neighbors : Array[Node]
} derive(Eq, Show)
pub impl @lib.Sized for Node with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.id); @lib.size_of(size) + size }
  match self.data {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size += self.connections.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size += self.neighbors.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size
}
pub impl Default for Node with default() -> Node {
  Node::{
    id : String::default(),
    data : None,
    connections : [],
    neighbors : [],
  }
}
pub impl @lib.Read for Node with read(reader : &@lib.Reader) {
  let msg =   Node::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.id = reader |> @lib.read_string()
      (2, _) => msg.data = reader |> @lib.read_string() |> Some
      (3, _) => msg.connections.push(((reader |> @lib.read_message()) : Node_Connection))
      (4, _) => msg.neighbors.push(((reader |> @lib.read_message()) : Node))
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Node with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.id)
  match self.data {
    Some(v) => {
      writer |> @lib.write_varint(18UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
  self.connections.iter().each(fn(v) {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  self.neighbors.iter().each(fn(v) {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
}
pub impl ToJson for Node with to_json(self) {

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
pub impl @json.FromJson for Node with from_json(json: Json, path: @json.JsonPath) -> Node raise {
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
pub(all) struct Weight {
  mut value : Double
  mut unit : String?
  mut connection : Node_Connection?
  mut related_nodes : Array[Node]
} derive(Eq, Show)
pub impl @lib.Sized for Weight with size_of(self) {
  let mut size = 0U
  size += 1U + 8U
  match self.unit {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.connection {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size += self.related_nodes.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size
}
pub impl Default for Weight with default() -> Weight {
  Weight::{
    value : Double::default(),
    unit : None,
    connection : None,
    related_nodes : [],
  }
}
pub impl @lib.Read for Weight with read(reader : &@lib.Reader) {
  let msg =   Weight::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.value = reader |> @lib.read_double()
      (2, _) => msg.unit = reader |> @lib.read_string() |> Some
      (3, _) => msg.connection = ((reader |> @lib.read_message()) : Node_Connection) |> Some
      (4, _) => msg.related_nodes.push(((reader |> @lib.read_message()) : Node))
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Weight with write(self, writer) {
  writer |> @lib.write_varint(9UL);writer |> @lib.write_double(self.value)
  match self.unit {
    Some(v) => {
      writer |> @lib.write_varint(18UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.connection {
    Some(v) => {
      writer |> @lib.write_varint(26UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.related_nodes.iter().each(fn(v) {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
}
pub impl ToJson for Weight with to_json(self) {

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
pub impl @json.FromJson for Weight with from_json(json: Json, path: @json.JsonPath) -> Weight raise {
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
pub(all) struct Graph {
  mut graph_id : String
  mut name : String?
  mut vertices : Array[Vertex]
  mut edges : Array[Edge]
} derive(Eq, Show)
pub impl @lib.Sized for Graph with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.graph_id); @lib.size_of(size) + size }
  match self.name {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size += self.vertices.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size += self.edges.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size
}
pub impl Default for Graph with default() -> Graph {
  Graph::{
    graph_id : String::default(),
    name : None,
    vertices : [],
    edges : [],
  }
}
pub impl @lib.Read for Graph with read(reader : &@lib.Reader) {
  let msg =   Graph::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.graph_id = reader |> @lib.read_string()
      (2, _) => msg.name = reader |> @lib.read_string() |> Some
      (3, _) => msg.vertices.push(((reader |> @lib.read_message()) : Vertex))
      (4, _) => msg.edges.push(((reader |> @lib.read_message()) : Edge))
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Graph with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.graph_id)
  match self.name {
    Some(v) => {
      writer |> @lib.write_varint(18UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
  self.vertices.iter().each(fn(v) {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  self.edges.iter().each(fn(v) {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
}
pub impl ToJson for Graph with to_json(self) {

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
pub impl @json.FromJson for Graph with from_json(json: Json, path: @json.JsonPath) -> Graph raise {
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
pub(all) struct Vertex {
  mut vertex_id : String
  mut label : String?
  mut graph : Graph?
  mut incoming_edges : Array[Edge]
  mut outgoing_edges : Array[Edge]
  mut adjacent_vertices : Array[Vertex]
} derive(Eq, Show)
pub impl @lib.Sized for Vertex with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.vertex_id); @lib.size_of(size) + size }
  match self.label {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.graph {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size += self.incoming_edges.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size += self.outgoing_edges.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size += self.adjacent_vertices.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size
}
pub impl Default for Vertex with default() -> Vertex {
  Vertex::{
    vertex_id : String::default(),
    label : None,
    graph : None,
    incoming_edges : [],
    outgoing_edges : [],
    adjacent_vertices : [],
  }
}
pub impl @lib.Read for Vertex with read(reader : &@lib.Reader) {
  let msg =   Vertex::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.vertex_id = reader |> @lib.read_string()
      (2, _) => msg.label = reader |> @lib.read_string() |> Some
      (3, _) => msg.graph = ((reader |> @lib.read_message()) : Graph) |> Some
      (4, _) => msg.incoming_edges.push(((reader |> @lib.read_message()) : Edge))
      (5, _) => msg.outgoing_edges.push(((reader |> @lib.read_message()) : Edge))
      (6, _) => msg.adjacent_vertices.push(((reader |> @lib.read_message()) : Vertex))
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Vertex with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.vertex_id)
  match self.label {
    Some(v) => {
      writer |> @lib.write_varint(18UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.graph {
    Some(v) => {
      writer |> @lib.write_varint(26UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.incoming_edges.iter().each(fn(v) {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  self.outgoing_edges.iter().each(fn(v) {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  self.adjacent_vertices.iter().each(fn(v) {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
}
pub impl ToJson for Vertex with to_json(self) {

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
pub impl @json.FromJson for Vertex with from_json(json: Json, path: @json.JsonPath) -> Vertex raise {
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
pub(all) struct Edge {
  mut edge_id : String
  mut weight : Double?
  mut graph : Graph?
  mut source_vertex : Vertex?
  mut target_vertex : Vertex?
  mut parallel_edges : Array[Edge]
} derive(Eq, Show)
pub impl @lib.Sized for Edge with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.edge_id); @lib.size_of(size) + size }
  match self.weight {
    Some(v) => size += 1U + 8U
    None => ()
  }
  match self.graph {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.source_vertex {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.target_vertex {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size += self.parallel_edges.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size
}
pub impl Default for Edge with default() -> Edge {
  Edge::{
    edge_id : String::default(),
    weight : None,
    graph : None,
    source_vertex : None,
    target_vertex : None,
    parallel_edges : [],
  }
}
pub impl @lib.Read for Edge with read(reader : &@lib.Reader) {
  let msg =   Edge::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.edge_id = reader |> @lib.read_string()
      (2, _) => msg.weight = reader |> @lib.read_double() |> Some
      (3, _) => msg.graph = ((reader |> @lib.read_message()) : Graph) |> Some
      (4, _) => msg.source_vertex = ((reader |> @lib.read_message()) : Vertex) |> Some
      (5, _) => msg.target_vertex = ((reader |> @lib.read_message()) : Vertex) |> Some
      (6, _) => msg.parallel_edges.push(((reader |> @lib.read_message()) : Edge))
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Edge with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.edge_id)
  match self.weight {
    Some(v) => {
      writer |> @lib.write_varint(17UL);writer |> @lib.write_double(v)
    }
    None => ()
  }
  match self.graph {
    Some(v) => {
      writer |> @lib.write_varint(26UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.source_vertex {
    Some(v) => {
      writer |> @lib.write_varint(34UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.target_vertex {
    Some(v) => {
      writer |> @lib.write_varint(42UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.parallel_edges.iter().each(fn(v) {
    writer |> @lib.write_varint(50UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
}
pub impl ToJson for Edge with to_json(self) {

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
pub impl @json.FromJson for Edge with from_json(json: Json, path: @json.JsonPath) -> Edge raise {
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
      key => raise @json.JsonDecodeError((path, "Unknown field \{key}"))
      }
  }
  message
}
