pub(all) struct TreeNode {
  mut name : String
  mut value : Int?
  mut parent : TreeNode?
  mut children : Array[TreeNode]
  mut sibling : TreeNode?
} derive(Eq, Show)
pub impl @lib.Sized for TreeNode with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.name); @lib.size_of(size) + size }
  match self.value {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  match self.parent {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size += self.children.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  match self.sibling {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size
}
pub impl Default for TreeNode with default() -> TreeNode {
  TreeNode::{
    name : String::default(),
    value : None,
    parent : None,
    children : [],
    sibling : None,
  }
}
pub impl @lib.Read for TreeNode with read(reader : &@lib.Reader) {
  let msg =   TreeNode::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, _) => msg.value = reader |> @lib.read_int32() |> Some
      (3, _) => msg.parent = ((reader |> @lib.read_message()) : TreeNode) |> Some
      (4, _) => msg.children.push(((reader |> @lib.read_message()) : TreeNode))
      (5, _) => msg.sibling = ((reader |> @lib.read_message()) : TreeNode) |> Some
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for TreeNode with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.name)
  match self.value {
    Some(v) => {
      writer |> @lib.write_varint(16UL);writer |> @lib.write_int32(v)
    }
    None => ()
  }
  match self.parent {
    Some(v) => {
      writer |> @lib.write_varint(26UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.children.iter().each(fn(v) {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  match self.sibling {
    Some(v) => {
      writer |> @lib.write_varint(42UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
}
pub(all) struct ListNode {
  mut data : String
  mut next : ListNode?
  mut prev : ListNode?
} derive(Eq, Show)
pub impl @lib.Sized for ListNode with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.data); @lib.size_of(size) + size }
  match self.next {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.prev {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size
}
pub impl Default for ListNode with default() -> ListNode {
  ListNode::{
    data : String::default(),
    next : None,
    prev : None,
  }
}
pub impl @lib.Read for ListNode with read(reader : &@lib.Reader) {
  let msg =   ListNode::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.data = reader |> @lib.read_string()
      (2, _) => msg.next = ((reader |> @lib.read_message()) : ListNode) |> Some
      (3, _) => msg.prev = ((reader |> @lib.read_message()) : ListNode) |> Some
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for ListNode with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.data)
  match self.next {
    Some(v) => {
      writer |> @lib.write_varint(18UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.prev {
    Some(v) => {
      writer |> @lib.write_varint(26UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
}
pub(all) struct GraphNode {
  mut id : String
  mut label : String?
  mut neighbors : Array[GraphNode]
  mut visited : Bool?
} derive(Eq, Show)
pub impl @lib.Sized for GraphNode with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.id); @lib.size_of(size) + size }
  match self.label {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size += self.neighbors.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  match self.visited {
    Some(v) => size += 1U + @lib.size_of(v)
    None => ()
  }
  size
}
pub impl Default for GraphNode with default() -> GraphNode {
  GraphNode::{
    id : String::default(),
    label : None,
    neighbors : [],
    visited : Some(false),
  }
}
pub impl @lib.Read for GraphNode with read(reader : &@lib.Reader) {
  let msg =   GraphNode::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.id = reader |> @lib.read_string()
      (2, _) => msg.label = reader |> @lib.read_string() |> Some
      (3, _) => msg.neighbors.push(((reader |> @lib.read_message()) : GraphNode))
      (4, _) => msg.visited = reader |> @lib.read_bool() |> Some
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for GraphNode with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.id)
  match self.label {
    Some(v) => {
      writer |> @lib.write_varint(18UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
  self.neighbors.iter().each(fn(v) {
    writer |> @lib.write_varint(26UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  match self.visited {
    Some(v) => {
      writer |> @lib.write_varint(32UL);writer |> @lib.write_bool(v)
    }
    None => ()
  }
}
pub(all) struct NestedSelfRef_Inner {
  mut inner_name : String?
  mut outer_ref : NestedSelfRef?
  mut inner_ref : NestedSelfRef_Inner?
} derive(Eq, Show)
pub impl @lib.Sized for NestedSelfRef_Inner with size_of(self) {
  let mut size = 0U
  match self.inner_name {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.outer_ref {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.inner_ref {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size
}
pub impl Default for NestedSelfRef_Inner with default() -> NestedSelfRef_Inner {
  NestedSelfRef_Inner::{
    inner_name : None,
    outer_ref : None,
    inner_ref : None,
  }
}
pub impl @lib.Read for NestedSelfRef_Inner with read(reader : &@lib.Reader) {
  let msg =   NestedSelfRef_Inner::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.inner_name = reader |> @lib.read_string() |> Some
      (2, _) => msg.outer_ref = ((reader |> @lib.read_message()) : NestedSelfRef) |> Some
      (3, _) => msg.inner_ref = ((reader |> @lib.read_message()) : NestedSelfRef_Inner) |> Some
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for NestedSelfRef_Inner with write(self, writer) {
  match self.inner_name {
    Some(v) => {
      writer |> @lib.write_varint(10UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.outer_ref {
    Some(v) => {
      writer |> @lib.write_varint(18UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.inner_ref {
    Some(v) => {
      writer |> @lib.write_varint(26UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
}
pub(all) struct NestedSelfRef {
  mut name : String
  mut inner : NestedSelfRef_Inner?
  mut self_ref : NestedSelfRef?
} derive(Eq, Show)
pub impl @lib.Sized for NestedSelfRef with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.name); @lib.size_of(size) + size }
  match self.inner {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.self_ref {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size
}
pub impl Default for NestedSelfRef with default() -> NestedSelfRef {
  NestedSelfRef::{
    name : String::default(),
    inner : None,
    self_ref : None,
  }
}
pub impl @lib.Read for NestedSelfRef with read(reader : &@lib.Reader) {
  let msg =   NestedSelfRef::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, _) => msg.inner = ((reader |> @lib.read_message()) : NestedSelfRef_Inner) |> Some
      (3, _) => msg.self_ref = ((reader |> @lib.read_message()) : NestedSelfRef) |> Some
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for NestedSelfRef with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.name)
  match self.inner {
    Some(v) => {
      writer |> @lib.write_varint(18UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.self_ref {
    Some(v) => {
      writer |> @lib.write_varint(26UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
}
pub(all) struct Organization {
  mut name : String
  mut description : String?
  mut parent_org : Organization?
  mut sub_orgs : Array[Organization]
  mut employees : Array[Employee]
} derive(Eq, Show)
pub impl @lib.Sized for Organization with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.name); @lib.size_of(size) + size }
  match self.description {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.parent_org {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size += self.sub_orgs.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size += self.employees.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size
}
pub impl Default for Organization with default() -> Organization {
  Organization::{
    name : String::default(),
    description : None,
    parent_org : None,
    sub_orgs : [],
    employees : [],
  }
}
pub impl @lib.Read for Organization with read(reader : &@lib.Reader) {
  let msg =   Organization::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, _) => msg.description = reader |> @lib.read_string() |> Some
      (3, _) => msg.parent_org = ((reader |> @lib.read_message()) : Organization) |> Some
      (4, _) => msg.sub_orgs.push(((reader |> @lib.read_message()) : Organization))
      (5, _) => msg.employees.push(((reader |> @lib.read_message()) : Employee))
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Organization with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.name)
  match self.description {
    Some(v) => {
      writer |> @lib.write_varint(18UL);writer |> @lib.write_string(v)
    }
    None => ()
  }
  match self.parent_org {
    Some(v) => {
      writer |> @lib.write_varint(26UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.sub_orgs.iter().each(fn(v) {
    writer |> @lib.write_varint(34UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
  self.employees.iter().each(fn(v) {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
}
pub(all) struct Employee {
  mut name : String
  mut id : String
  mut organization : Organization?
  mut manager : Employee?
  mut subordinates : Array[Employee]
} derive(Eq, Show)
pub impl @lib.Sized for Employee with size_of(self) {
  let mut size = 0U
  size += 1U + { let size = @lib.size_of(self.name); @lib.size_of(size) + size }
  size += 1U + { let size = @lib.size_of(self.id); @lib.size_of(size) + size }
  match self.organization {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  match self.manager {
    Some(v) => size += 1U + { let size = @lib.size_of(v); @lib.size_of(size) + size }
    None => ()
  }
  size += self.subordinates.iter().map(@lib.size_of).map(s => 1U + @lib.size_of(s) + s).fold(init=0U, UInt::op_add)
  size
}
pub impl Default for Employee with default() -> Employee {
  Employee::{
    name : String::default(),
    id : String::default(),
    organization : None,
    manager : None,
    subordinates : [],
  }
}
pub impl @lib.Read for Employee with read(reader : &@lib.Reader) {
  let msg =   Employee::default()

  while not(reader |> @lib.is_eof()) {
    match (reader |> @lib.read_tag()) {
      (1, _) => msg.name = reader |> @lib.read_string()
      (2, _) => msg.id = reader |> @lib.read_string()
      (3, _) => msg.organization = ((reader |> @lib.read_message()) : Organization) |> Some
      (4, _) => msg.manager = ((reader |> @lib.read_message()) : Employee) |> Some
      (5, _) => msg.subordinates.push(((reader |> @lib.read_message()) : Employee))
     (_, wire) => reader |> @lib.read_unknown(wire)
    }
  }
  msg
}
pub impl @lib.Write for Employee with write(self, writer) {
  writer |> @lib.write_varint(10UL);writer |> @lib.write_string(self.name)
  writer |> @lib.write_varint(18UL);writer |> @lib.write_string(self.id)
  match self.organization {
    Some(v) => {
      writer |> @lib.write_varint(26UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  match self.manager {
    Some(v) => {
      writer |> @lib.write_varint(34UL);writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
    }
    None => ()
  }
  self.subordinates.iter().each(fn(v) {
    writer |> @lib.write_varint(42UL)
    writer |> @lib.write_uint32(@lib.size_of(v)); @lib.Write::write(v, writer)
  })
}
