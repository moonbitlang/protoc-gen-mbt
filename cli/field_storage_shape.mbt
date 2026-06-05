///|
fn CodeGenerator::field_storage_shape(
  self : CodeGenerator,
  field : Field,
  parent_path : ImportPath,
) -> FieldStorageShape raise {
  let field_name = field.import_path.name() |> pascal_to_snake
  let field_type = self.get_moonbit_type(field, parent_path~)
  let mut declaration_type = field_type
  let mut constructor_name = field_name
  let mut constructor_type = field_type
  let mut default_expr = "\{field_type}::default()"
  if field.map_key_value() is Some(map_entry) {
    let key_type = self.get_moonbit_type(map_entry.fields[0], parent_path~)
    let value_type = self.get_moonbit_type(map_entry.fields[1], parent_path~)
    let map_type = "Map[\{key_type}, \{value_type}]"
    declaration_type = map_type
    constructor_type = map_type
    default_expr = "{}"
  } else if field.is_list() {
    let array_type = "Array[\{field_type}]"
    declaration_type = array_type
    constructor_type = array_type
    default_expr = "[]"
  } else if field.is_optional() {
    declaration_type = "\{field_type}?"
    constructor_name = "\{field_name}?"
    default_expr = "None"
  } else if field.is_message() || field.is_enum() {
    declaration_type = "\{field_type} "
  }
  if field.default_value() is Some(default_value) {
    let mut field_default_value = default_value
    if field.type_ is Some(TYPE_STRING) {
      field_default_value = "\"\{field_default_value}\""
    } else if field.is_enum() {
      field_default_value = "\{field_type}::\{default_value}"
    }
    if field.is_optional() {
      field_default_value = "Some(\{field_default_value})"
    }
    default_expr = field_default_value
  }
  {
    field_name,
    declaration_type,
    constructor_name,
    constructor_type,
    default_expr,
  }
}
