# Protobuf <-> MoonBit Mapping

This page describes how the mapping between protobuf type system and is done.

- [Basic Types](#basic-types)
- [Oneof fields](#oneof-fields)
- [Field rules](#field-rules)
- [Default values](#default-values)
- [Message](#message)
- [Enumerations](#enumerations)
- [File name](#file-name)
- [Package](#package)
- [Extensions](#extensions)
- [Nested Types](#nested-types)
- [Maps](#maps)
- [Services](#services)

## [Basic Types](https://developers.google.com/protocol-buffers/docs/proto#scalar)

| .proto type | MoonBit Type |
| ----------- | ------------ |
| double      | Double       |
| float       | Float        |
| int32       | Int          |
| int64       | Int64        |
| uint32      | UInt         |
| uint64      | UInt64       |
| sint32      | Int          |
| sint64      | Int64        |
| fixed32     | UInt         |
| fixed64     | UInt64       |
| sfixed32    | UInt         |
| sfixed64    | UInt64       |
| bool        | Bool         |
| string      | String       |
| bytes       | Bytes        |

## [Oneof](https://developers.google.com/protocol-buffers/docs/proto#oneof)

`oneof` fields are encoded as MoonBit `Enum` (tagged union or algebraic data types). The enum's name is the concatenation of the enclosing message name and the `oneof` field name.

A `OneofNone` variant is added to the enum to represent the case where none of the `oneof` fields are set.

## [Optinoal](https://developers.google.com/protocol-buffers/docs/proto#specifying-field-rules)

`optional` field will generate `Option` type in MoonBit

## [Repeated] and [Packed](https://developers.google.com/protocol-buffers/docs/proto#repeated)

`repeated` field will generate MoonBit `Array`.

## [Default values](https://developers.google.com/protocol-buffers/docs/proto#optional)

`protoc-gen-mbt` will derive default trait for struct and enum, or use default value for builtin type.

## [Message](https://developers.google.com/protocol-buffers/docs/proto#simple)

Message are compiled to MoonBit `Struct` with all fields immutable, while `oneof` fields are compiled to MoonBit `Enum`.

### Recursive message

Recursive message are supported and compiled to recursive `Struct` in MoonBit. For instance the following protobuf:

```Javascript
message IntList {
    message Nil  {  }
    message Cons {
        int32   value = 1;
        IntList next  = 2;
    }
    oneof t {
        Cons cons = 1;
        Nil  nil  = 2;
    }
}
```

Will compile to the following MoonBit type:

```MoonBit
struct IntListCons {
  value : Int;
  next : IntList;
}

struct IntListNil { }

enum IntListT {
  Cons(IntListCons);
  Nil(IntListNil);
}

struct IntList {
  t : IntListT;
}
```

## Enumerations

Enumerations will map to MoonBit `Enum`

Example:

```Javascript
enum Corpus {
    UNIVERSAL = 0;
    WEB = 1;
    IMAGES = 2;
    LOCAL = 3;
    NEWS = 4;
    PRODUCTS = 5;
    VIDEO = 6;
  }
```

Will generate:

```MoonBit
enum Corpus {
  Universal
  Web
  Images
  Local
  News
  Products
  Video
}
```

## [Package](https://developers.google.com/protocol-buffers/docs/proto#packages)

TODO:
Seperated by folder and moon.pkg.json

## [Extensions and Custom Options](https://developers.google.com/protocol-buffers/docs/proto#extensions)

Extensions and Custom Options are **ignored**.

> NOTE: Extension declarations are mostly used in proto2, as proto3 does not support extensions at this time (except for declaring custom options).

## [Nested Types](https://developers.google.com/protocol-buffers/docs/proto#nested)

Nested types are fully supported and generate records which name is the concatenation of the inner and outer messages.

For example:

```Javascript
message ma {
  message mb {
    int32 bfield = 1;
  }
  mb bfield = 1;
}
```

Willl generate:

```MoonBit
struct maMb {
  bfield : Int;
}

struct ma {
  bfield : maMb;
}
```

## [Maps](https://developers.google.com/protocol-buffers/docs/proto#maps)

Maps are fully supported and will map to MoonBit `Map`

For example, a `map<a, b> = 1` Protobuf field will generate an MoonBit : `Map[a, b]`.

**example:**

```Javascript
message M {
  map<string, string> s2s = 1;
}
```

will generate

```MoonBit
struct M {
  s2s : Map[String, String];
}
```

## Services

[Services](https://developers.google.com/protocol-buffers/docs/proto#services) is currently **NOT** supported.
