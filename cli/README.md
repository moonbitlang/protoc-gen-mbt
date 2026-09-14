# MoonBit protobuf generator

`protoc-gen-mbt` is a Protocol Buffers compiler plugin that generates MoonBit
messages, binary codecs, and optional JSON and asynchronous I/O support.

## Use with moonx

Install the [MoonBit toolchain](https://www.moonbitlang.com/download/) and
[protoc](https://github.com/protocolbuffers/protobuf/releases/tag/v33.0). Use `moonx`
to run the published generator on demand. Since `protoc` launches an executable
plugin, create a wrapper for your shell.

### macOS / Linux (POSIX shell)

```sh
cat > protoc-gen-mbt.sh <<'EOF'
#!/bin/sh
exec moonx moonbitlang/protoc-gen-mbt@0.2.0 "$@"
EOF
chmod +x protoc-gen-mbt.sh
```

Then generate code:

```sh
protoc --plugin=protoc-gen-mbt=./protoc-gen-mbt.sh \
  --mbt_out=. --mbt_opt=project_name=generated example.proto
```

### Windows (PowerShell)

Create a command wrapper in the current directory, then generate code:

```powershell
@'
@echo off
moonx moonbitlang/protoc-gen-mbt@0.2.0 %*
'@ | Set-Content -Path .\protoc-gen-mbt.cmd -Encoding ascii

protoc --mbt_out=. --mbt_opt=project_name=generated example.proto
```

Run `protoc` from the same directory so it can find `protoc-gen-mbt.cmd`.
Omit `--plugin` for this Windows wrapper. The project's CI uses protoc 33.0.

`project_name` names the generated module directory under `--mbt_out`. Generated
modules depend on `moonbitlang/protobuf@0.1.3`.

See the [project documentation](https://github.com/moonbitlang/protoc-gen-mbt#arguments)
for generator options and the
[supported features](https://github.com/moonbitlang/protoc-gen-mbt/blob/main/doc/spec.md).
