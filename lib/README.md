# protobuf runtime

This directory contains the MoonBit Protobuf runtime library, providing essential support for Protobuf message serialization and deserialization.

## Directory Structure

- `src/`
  - `reader.mbt` / `writer.mbt`: Basic read/write interfaces
  - `async_reader.mbt` / `async_writer.mbt`: Asynchronous read/write interfaces
  - `json_utils.mbt`: JSON utilities
  - `proto.mbt`: Protobuf traits definitions
  - `types.mbt`: Type definitions
  - `sizeof.mbt`: Message size calculation
  - `reader_impl.mbt` / `writer_impl.mbt`: Implementation reader/writer
  - `reader_test.mbt` / `writer_test.mbt`: Test cases