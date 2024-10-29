# MoonBit protobuf generator

## Known Issues

- Some `repeated` fields in `MessageWrite` (`packed repeated`) are incorrect
- `map` is not supported.
- `oneof` in `MessageWrite` haven't been implemented
- `self` message (message referencing itself) in `MessageWrite` haven't been implemented
    - Needs `get_size` support in `MessageWrite` Trait


## Supported

- Structure definition: See also [spec](doc/spec.md)
- `MessageRead` trait (serialization)
- Trivial `MessageWrite` trait (primitive type deserialization)



## Developing

```sh
# export PATH="$PATH:$(pwd)"

go build . && protoc --mbt_out=. --mbt_opt=paths=source_relative \
src/test/input.proto
```

It will generated `input_pb.mbt` file in the same directory as the input file.

### Structure

- `src/lib`
    - `reader.mbt`: `MessageRead` implementation
    - `writer.mbt`: `MessageWrite` implementation
    - `sizeof.mbt`: used when calculating size of the message

- `main.go`
    - The main entry point for the protoc plugin

## Reference

- https://github.com/tafia/quick-protobuf