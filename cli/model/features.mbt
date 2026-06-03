///|
fn known_feature_field_presence(
  features : @protobuf.FeatureSet?,
) -> @protobuf.FeatureSet_FieldPresence? {
  match features {
    Some(
      { field_presence: Some(@protobuf.FeatureSet_FieldPresence::EXPLICIT), .. }
    ) => Some(@protobuf.FeatureSet_FieldPresence::EXPLICIT)
    Some(
      { field_presence: Some(@protobuf.FeatureSet_FieldPresence::IMPLICIT), .. }
    ) => Some(@protobuf.FeatureSet_FieldPresence::IMPLICIT)
    Some(
      {
        field_presence: Some(
          @protobuf.FeatureSet_FieldPresence::LEGACY_REQUIRED
        ),
        ..,
      }
    ) => Some(@protobuf.FeatureSet_FieldPresence::LEGACY_REQUIRED)
    _ => None
  }
}

///|
fn known_feature_repeated_field_encoding(
  features : @protobuf.FeatureSet?,
) -> @protobuf.FeatureSet_RepeatedFieldEncoding? {
  match features {
    Some(
      {
        repeated_field_encoding: Some(
          @protobuf.FeatureSet_RepeatedFieldEncoding::PACKED
        ),
        ..,
      }
    ) => Some(@protobuf.FeatureSet_RepeatedFieldEncoding::PACKED)
    Some(
      {
        repeated_field_encoding: Some(
          @protobuf.FeatureSet_RepeatedFieldEncoding::EXPANDED
        ),
        ..,
      }
    ) => Some(@protobuf.FeatureSet_RepeatedFieldEncoding::EXPANDED)
    _ => None
  }
}

///|
fn known_feature_enum_type(
  features : @protobuf.FeatureSet?,
) -> @protobuf.FeatureSet_EnumType? {
  match features {
    Some({ enum_type: Some(@protobuf.FeatureSet_EnumType::OPEN), .. }) =>
      Some(@protobuf.FeatureSet_EnumType::OPEN)
    Some({ enum_type: Some(@protobuf.FeatureSet_EnumType::CLOSED), .. }) =>
      Some(@protobuf.FeatureSet_EnumType::CLOSED)
    _ => None
  }
}

///|
fn Field::field_presence_feature_behavior(
  self : Field,
) -> @protobuf.FeatureSet_FieldPresence {
  if self.desc.label is Some(LABEL_REQUIRED) {
    return @protobuf.FeatureSet_FieldPresence::LEGACY_REQUIRED
  }
  if self.desc.proto3_optional is Some(true) {
    return @protobuf.FeatureSet_FieldPresence::EXPLICIT
  }
  if self.options is Some({ features, .. }) {
    if known_feature_field_presence(features) is Some(presence) {
      return presence
    }
  }
  if self.parent.file is Some(file) {
    file.field_presence_feature_behavior()
  } else if self.desc.label is Some(LABEL_OPTIONAL) {
    @protobuf.FeatureSet_FieldPresence::EXPLICIT
  } else {
    @protobuf.FeatureSet_FieldPresence::IMPLICIT
  }
}

///|
fn Field::presence_behavior(self : Field) -> @protobuf.FeatureSet_FieldPresence {
  if self.is_list() {
    return @protobuf.FeatureSet_FieldPresence::IMPLICIT
  }
  let presence = self.field_presence_feature_behavior()
  if presence == @protobuf.FeatureSet_FieldPresence::LEGACY_REQUIRED {
    return @protobuf.FeatureSet_FieldPresence::LEGACY_REQUIRED
  }
  if self.is_message() || self.is_oneof() {
    return @protobuf.FeatureSet_FieldPresence::EXPLICIT
  }
  presence
}

///|
fn Field::repeated_field_encoding_feature_behavior(
  self : Field,
) -> @protobuf.FeatureSet_RepeatedFieldEncoding {
  if self.options is Some({ features, .. }) {
    if known_feature_repeated_field_encoding(features) is Some(encoding) {
      return encoding
    }
  }
  match self.desc.options {
    Some({ packed: Some(true), .. }) =>
      return @protobuf.FeatureSet_RepeatedFieldEncoding::PACKED
    Some({ packed: Some(false), .. }) =>
      return @protobuf.FeatureSet_RepeatedFieldEncoding::EXPANDED
    _ => ()
  }
  if self.parent.file is Some(file) {
    file.repeated_field_encoding_feature_behavior()
  } else {
    @protobuf.FeatureSet_RepeatedFieldEncoding::EXPANDED
  }
}

///|
fn Field::repeated_field_encoding_behavior(
  self : Field,
) -> @protobuf.FeatureSet_RepeatedFieldEncoding {
  if !self.is_list() || !self.is_packable_scalar() {
    return @protobuf.FeatureSet_RepeatedFieldEncoding::EXPANDED
  }
  self.repeated_field_encoding_feature_behavior()
}

///|
pub fn Field::is_pack(self : Field) -> Bool {
  self.repeated_field_encoding_behavior() ==
  @protobuf.FeatureSet_RepeatedFieldEncoding::PACKED
}

///|
pub fn Field::is_optional(self : Field) -> Bool {
  self.presence_behavior() == @protobuf.FeatureSet_FieldPresence::EXPLICIT
}

///|
pub fn Field::has_implicit_presence(self : Field) -> Bool {
  self.presence_behavior() == @protobuf.FeatureSet_FieldPresence::IMPLICIT
}

///|
fn Package::field_presence_feature_behavior(
  self : Package,
) -> @protobuf.FeatureSet_FieldPresence {
  if self.options is Some({ features, .. }) {
    if known_feature_field_presence(features) is Some(presence) {
      return presence
    }
  }
  match self.syntax {
    Proto3 => @protobuf.FeatureSet_FieldPresence::IMPLICIT
    Proto2 | Editions => @protobuf.FeatureSet_FieldPresence::EXPLICIT
  }
}

///|
fn Package::repeated_field_encoding_feature_behavior(
  self : Package,
) -> @protobuf.FeatureSet_RepeatedFieldEncoding {
  if self.options is Some({ features, .. }) {
    if known_feature_repeated_field_encoding(features) is Some(encoding) {
      return encoding
    }
  }
  match self.syntax {
    Proto3 | Editions => @protobuf.FeatureSet_RepeatedFieldEncoding::PACKED
    Proto2 => @protobuf.FeatureSet_RepeatedFieldEncoding::EXPANDED
  }
}

///|
fn Package::feature_enum_type(self : Package) -> @protobuf.FeatureSet_EnumType? {
  if self.options is Some({ features, .. }) {
    known_feature_enum_type(features)
  } else {
    None
  }
}

///|
fn Enum::own_feature_enum_type(self : Enum) -> @protobuf.FeatureSet_EnumType? {
  if self.options is Some({ features, .. }) {
    known_feature_enum_type(features)
  } else {
    None
  }
}

///|
fn Enum::file_package(self : Enum) -> Package? {
  if self.file is Some(file) {
    Some(file)
  } else if self.parent is Some(parent) {
    parent.file
  } else {
    None
  }
}

///|
fn Enum::feature_enum_type(self : Enum) -> @protobuf.FeatureSet_EnumType? {
  if self.own_feature_enum_type() is Some(enum_type) {
    Some(enum_type)
  } else if self.file_package() is Some(file) {
    file.feature_enum_type()
  } else {
    None
  }
}

///|
fn Enum::openness(self : Enum) -> @protobuf.FeatureSet_EnumType {
  match self.feature_enum_type() {
    Some(@protobuf.FeatureSet_EnumType::OPEN) =>
      @protobuf.FeatureSet_EnumType::OPEN
    Some(@protobuf.FeatureSet_EnumType::CLOSED) =>
      @protobuf.FeatureSet_EnumType::CLOSED
    _ =>
      match self.file_package() {
        Some({ syntax: Proto2, .. }) => @protobuf.FeatureSet_EnumType::CLOSED
        Some({ syntax: Proto3 | Editions, .. }) =>
          @protobuf.FeatureSet_EnumType::OPEN
        None => @protobuf.FeatureSet_EnumType::CLOSED
      }
  }
}

///|
pub fn Enum::is_open(self : Enum) -> Bool {
  self.openness() == @protobuf.FeatureSet_EnumType::OPEN
}
