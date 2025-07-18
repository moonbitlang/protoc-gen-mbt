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
