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

A `NotSet` variant is added to the enum to represent the case where none of the `oneof` fields are set.

## [Optinoal](https://developers.google.com/protocol-buffers/docs/proto#specifying-field-rules)

`optional` field will generate `Option` type in MoonBit

## [Repeated] and [Packed](https://developers.google.com/protocol-buffers/docs/proto#repeated)

`repeated` field will generate MoonBit `Array`.

## [Default values](https://developers.google.com/protocol-buffers/docs/proto#optional)

`protoc-gen-mbt` will derive default trait for struct and enum, or use default value for builtin type.

## [Message](https://developers.google.com/protocol-buffers/docs/proto#simple)

Message are compiled to MoonBit `Struct` with all fields immutable, while `oneof` fields are compiled to MoonBit `Enum` as explained above.

### Recursive message

Recursive message are supported and compiled to recursive `Struct` in MoonBit. For instance the following protobuf:

```protobuf
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

```moonbit
struct IntListCons {
  mut value : Int
  mut next : IntList
}

struct IntListNil { }

enum IntListT {
  Cons(IntListCons)
  Nil(IntListNil)
}

struct IntList {
  mut t : IntListT
}
```

## Enumerations

Enumerations will map to a type `Enum`, which is essentially `UInt`.

Example:

```protobuf
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

```moonbit
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

with `to_enum`.

## [Package](https://developers.google.com/protocol-buffers/docs/proto#packages)

TODO:
Seperated by folder and moon.pkg.json

## [Extensions and Custom Options](https://developers.google.com/protocol-buffers/docs/proto#extensions)

Extensions and Custom Options are **ignored**.

> NOTE: Extension declarations are mostly used in proto2, as proto3 does not support extensions at this time (except for declaring custom options).

## [Nested Types](https://developers.google.com/protocol-buffers/docs/proto#nested)

Nested types are fully supported and generate records which name is the concatenation of the inner and outer messages.

For example:

```protobuf
message ma {
  message mb {
    int32 bfield = 1;
  }
  mb bfield = 1;
}
```

Willl generate:

```moonbit
struct maMb {
  mut bfield : Int;
}

struct ma {
  mut bfield : maMb;
}
```

## [Maps](https://developers.google.com/protocol-buffers/docs/proto#maps)

Maps are fully supported and will map to MoonBit `Map`

For example, a `map<a, b> = 1` Protobuf field will generate an MoonBit : `Map[a, b]`.

**example:**

```protobuf
message M {
  map<string, string> s2s = 1;
}
```

will generate

```moonbit
struct M {
  mut s2s : Map[String, String]
}
```

## Services

[Services](https://developers.google.com/protocol-buffers/docs/proto#services) generate a **trait** (server-side interface) and a **service descriptor** (metadata for runtime routing).

For example:

```protobuf
package greet;

service Greeter {
  rpc SayHello (HelloRequest) returns (HelloReply);
  rpc StreamHello (HelloRequest) returns (stream HelloReply);
}
```

Will generate:

```moonbit
pub(open) trait GreeterService {
  say_hello(Self, HelloRequest) -> HelloReply raise
  // stream_hello is a server streaming method and is not included in the trait
}
pub let greeter_service_descriptor : @protobuf.ServiceDescriptor = {
  name: "Greeter",
  full_name: "greet.Greeter",
  methods: [
    {
      name: "SayHello",
      full_name: "/greet.Greeter/SayHello",
      client_streaming: false,
      server_streaming: false,
    },
    {
      name: "StreamHello",
      full_name: "/greet.Greeter/StreamHello",
      client_streaming: false,
      server_streaming: true,
    },
  ],
}
```

- **Trait**: Only unary (non-streaming) methods are included. Streaming methods are omitted with a comment.
- **Descriptor**: All methods are included with full metadata (name, full path, streaming flags).
- **Method names** in the trait use `snake_case` (e.g., `SayHello` becomes `say_hello`).
- **Descriptor variable** uses `snake_case` service name with `_service_descriptor` suffix.
