#!/usr/bin/env python3
from __future__ import annotations

import base64
import math
import subprocess
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parent.parent
PROTO_DIR = ROOT / "lib" / "test" / "proto"
OUT_DIR = ROOT / "lib" / "test"


def run_protoc(proto_name: str, message: str, textproto: str) -> bytes:
    proto_path = PROTO_DIR / proto_name
    cmd = [
        "protoc",
        f"--proto_path={PROTO_DIR}",
        f"--encode={message}",
        str(proto_path),
    ]
    result = subprocess.run(
        cmd,
        input=textproto.encode("utf-8"),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
    )
    return result.stdout


def b64(data: bytes) -> str:
    return base64.b64encode(data).decode("ascii")


def textproto_string_literal(value: str) -> str:
    escaped = value.encode("unicode_escape").decode("ascii")
    escaped = escaped.replace('"', "\\\"")
    return f'"{escaped}"'


def textproto_bytes_literal(value: bytes) -> str:
    escaped = "".join(f"\\x{b:02x}" for b in value)
    return f'"{escaped}"'


def moon_string_literal(value: str) -> str:
    escaped = (
        value.replace("\\", "\\\\")
        .replace('"', "\\\"")
        .replace("\n", "\\n")
        .replace("\r", "\\r")
        .replace("\t", "\\t")
    )
    return f'"{escaped}"'


def moon_bytes_literal(value: bytes) -> str:
    if not value:
        return 'b""'
    escaped = "".join(f"\\x{b:02x}" for b in value)
    return f'b"{escaped}"'


def moon_int(value: int) -> str:
    return str(value)


def moon_int64(value: int) -> str:
    return f"{value}L"


def moon_uint(value: int) -> str:
    return f"{value}U"


def moon_uint64(value: int) -> str:
    return f"{value}UL"


def moon_array(items: Iterable[str]) -> str:
    items = list(items)
    if not items:
        return "[]"
    return "[" + ", ".join(items) + "]"

def normalize_exponent(text: str) -> str:
    if "e" not in text and "E" not in text:
        return text
    head, exp = text.replace("E", "e").split("e", 1)
    sign = ""
    if exp.startswith(("+", "-")):
        sign = exp[0]
        exp = exp[1:]
    exp = exp.lstrip("0")
    if exp == "":
        exp = "0"
    return f"{head}e{sign}{exp}"


def float_literal(value: float) -> str:
    if math.isnan(value):
        return "nan"
    if math.isinf(value):
        return "-inf" if value < 0 else "inf"
    text = f"{value:.17g}"
    return normalize_exponent(text)


def float_bits_from_encoded(data: bytes) -> int:
    if len(data) < 5:
        raise ValueError("float encoding too short")
    return int.from_bytes(data[1:5], "little")


def double_bits_from_encoded(data: bytes) -> int:
    if len(data) < 9:
        raise ValueError("double encoding too short")
    return int.from_bytes(data[1:9], "little")


def simple_cases():
    cases = []

    int32_values = [
        0,
        1,
        -1,
        2,
        -2,
        42,
        -42,
        1000,
        -1000,
        12345,
        -12345,
        127,
        128,
        255,
        256,
        16383,
        16384,
        2097151,
        2097152,
        268435455,
        268435456,
        1000000000,
        -1000000000,
        123456789,
        -123456789,
        2147483647,
        -2147483648,
        -128,
        -129,
        -16384,
    ]

    int64_values = [
        0,
        1,
        -1,
        2,
        -2,
        42,
        -42,
        1000,
        -1000,
        12345,
        -12345,
        127,
        128,
        255,
        256,
        16383,
        16384,
        2097151,
        2097152,
        268435455,
        268435456,
        34359738367,
        34359738368,
        4398046511103,
        4398046511104,
        562949953421311,
        562949953421312,
        72057594037927935,
        72057594037927936,
        9007199254740991,
        -9007199254740991,
        987654321012345,
        -987654321012345,
        9223372036854775807,
        -9223372036854775808,
    ]

    uint32_values = [
        0,
        1,
        42,
        127,
        128,
        255,
        256,
        1024,
        65535,
        65536,
        16383,
        16384,
        2097151,
        2097152,
        268435455,
        268435456,
        3000000000,
        4000000000,
        4294967295,
    ]

    uint64_values = [
        0,
        1,
        42,
        127,
        128,
        255,
        256,
        16383,
        16384,
        2097151,
        2097152,
        268435455,
        268435456,
        34359738367,
        34359738368,
        4398046511103,
        4398046511104,
        562949953421311,
        562949953421312,
        72057594037927935,
        72057594037927936,
        9007199254740992,
        10000000000000000000,
        18446744073709551615,
    ]

    sint32_values = [
        0,
        -1,
        1,
        -2,
        2,
        63,
        -63,
        64,
        -64,
        1024,
        -1024,
        8191,
        -8191,
        8192,
        -8192,
        123456,
        -123456,
        2147483647,
        -2147483648,
    ]

    sint64_values = [
        0,
        -1,
        1,
        -2,
        2,
        63,
        -63,
        64,
        -64,
        1024,
        -1024,
        8191,
        -8191,
        8192,
        -8192,
        123456789,
        -123456789,
        987654321012345,
        -987654321012345,
        9223372036854775807,
        -9223372036854775808,
    ]

    bool_values = [False, True]

    enum_values = [
        "SIMPLE_ENUM_ZERO",
        "SIMPLE_ENUM_ONE",
        "SIMPLE_ENUM_TWO",
        "SIMPLE_ENUM_MAX",
    ]

    fixed32_values = [
        0,
        1,
        305419896,
        2147483647,
        2147483648,
        4294967295,
        3735928559,
        3405691582,
    ]

    fixed64_values = [
        0,
        1,
        81985529216486895,
        9223372036854775807,
        9223372036854775808,
        18446744073709551615,
        1311768467750121217,
        16045690984833335023,
    ]

    sfixed32_values = [
        0,
        1,
        -1,
        123456789,
        -123456789,
        2147483647,
        -2147483648,
        -1000000000,
    ]

    sfixed64_values = [
        0,
        1,
        -1,
        987654321012345,
        -987654321012345,
        9223372036854775807,
        -9223372036854775808,
        -1000000000000000000,
    ]

    float_values = [
        "0.0",
        "-1.0",
        "1.5",
        "-2.25",
        "3.1415927",
        "1e-20",
        "1e20",
        "nan",
        "inf",
        "-inf",
    ]

    double_values = [
        "0.0",
        "-1.0",
        "1.5",
        "-2.25",
        "3.141592653589793",
        "1e-300",
        "1e300",
        "nan",
        "inf",
        "-inf",
    ]

    bytes_values = [
        b"",
        b"\x00",
        b"\x01\x02",
        b"\x00\xff",
        b"\x00\xff\x10\x20",
        bytes(range(5)),
        bytes(range(16)),
        b"\xde\xad\xbe\xef",
        b"\x00" * 8,
        b"\xab" * 12,
    ]

    string_values = [
        "",
        "a",
        "hello",
        "with spaces",
        "symbols !@#$%^&*()_+{}|:<>?[]\\;',./",
        "line\nbreak",
        "tab\tindent",
        "unicode 中文",
        "mixed 123",
        "slashes \\\\ path",
    ]

    simple_specs = [
        {
            "name": "int32",
            "proto": "simple.proto",
            "message": "codec.simple.Int32Value",
            "wire_type": 0,
            "read": "@protobuf.read_int32()",
            "write": "@protobuf.write_int32",
            "values": int32_values,
            "moon_type": "Int",
            "format": moon_int,
            "textproto": lambda v: f"value: {v}",
        },
        {
            "name": "int64",
            "proto": "simple.proto",
            "message": "codec.simple.Int64Value",
            "wire_type": 0,
            "read": "@protobuf.read_int64()",
            "write": "@protobuf.write_int64",
            "values": int64_values,
            "moon_type": "Int64",
            "format": moon_int64,
            "textproto": lambda v: f"value: {v}",
        },
        {
            "name": "uint32",
            "proto": "simple.proto",
            "message": "codec.simple.UInt32Value",
            "wire_type": 0,
            "read": "@protobuf.read_uint32()",
            "write": "@protobuf.write_uint32",
            "values": uint32_values,
            "moon_type": "UInt",
            "format": moon_uint,
            "textproto": lambda v: f"value: {v}",
        },
        {
            "name": "uint64",
            "proto": "simple.proto",
            "message": "codec.simple.UInt64Value",
            "wire_type": 0,
            "read": "@protobuf.read_uint64()",
            "write": "@protobuf.write_uint64",
            "values": uint64_values,
            "moon_type": "UInt64",
            "format": moon_uint64,
            "textproto": lambda v: f"value: {v}",
        },
        {
            "name": "sint32",
            "proto": "simple.proto",
            "message": "codec.simple.SInt32Value",
            "wire_type": 0,
            "read": "@protobuf.read_sint32()",
            "write": "@protobuf.write_sint32",
            "values": sint32_values,
            "moon_type": "Int",
            "format": moon_int,
            "textproto": lambda v: f"value: {v}",
            "unwrap": ".0",
        },
        {
            "name": "sint64",
            "proto": "simple.proto",
            "message": "codec.simple.SInt64Value",
            "wire_type": 0,
            "read": "@protobuf.read_sint64()",
            "write": "@protobuf.write_sint64",
            "values": sint64_values,
            "moon_type": "Int64",
            "format": moon_int64,
            "textproto": lambda v: f"value: {v}",
            "unwrap": ".0",
        },
        {
            "name": "bool",
            "proto": "simple.proto",
            "message": "codec.simple.BoolValue",
            "wire_type": 0,
            "read": "@protobuf.read_bool()",
            "write": "@protobuf.write_bool",
            "values": bool_values,
            "moon_type": "Bool",
            "format": lambda v: "true" if v else "false",
            "textproto": lambda v: f"value: {'true' if v else 'false'}",
        },
        {
            "name": "enum",
            "proto": "simple.proto",
            "message": "codec.simple.EnumValue",
            "wire_type": 0,
            "read": "@protobuf.read_enum()",
            "write": "@protobuf.write_enum",
            "values": enum_values,
            "moon_type": "UInt",
            "format": lambda v: moon_uint(
                {
                    "SIMPLE_ENUM_ZERO": 0,
                    "SIMPLE_ENUM_ONE": 1,
                    "SIMPLE_ENUM_TWO": 2,
                    "SIMPLE_ENUM_MAX": 2147483647,
                }[v]
            ),
            "textproto": lambda v: f"value: {v}",
            "unwrap": ".0",
            "wrap": "@protobuf.Enum",
        },
        {
            "name": "fixed32",
            "proto": "simple.proto",
            "message": "codec.simple.Fixed32Value",
            "wire_type": 5,
            "read": "@protobuf.read_fixed32()",
            "write": "@protobuf.write_fixed32",
            "values": fixed32_values,
            "moon_type": "UInt",
            "format": moon_uint,
            "textproto": lambda v: f"value: {v}",
        },
        {
            "name": "fixed64",
            "proto": "simple.proto",
            "message": "codec.simple.Fixed64Value",
            "wire_type": 1,
            "read": "@protobuf.read_fixed64()",
            "write": "@protobuf.write_fixed64",
            "values": fixed64_values,
            "moon_type": "UInt64",
            "format": moon_uint64,
            "textproto": lambda v: f"value: {v}",
        },
        {
            "name": "sfixed32",
            "proto": "simple.proto",
            "message": "codec.simple.SFixed32Value",
            "wire_type": 5,
            "read": "@protobuf.read_sfixed32()",
            "write": "@protobuf.write_sfixed32",
            "values": sfixed32_values,
            "moon_type": "Int",
            "format": moon_int,
            "textproto": lambda v: f"value: {v}",
        },
        {
            "name": "sfixed64",
            "proto": "simple.proto",
            "message": "codec.simple.SFixed64Value",
            "wire_type": 1,
            "read": "@protobuf.read_sfixed64()",
            "write": "@protobuf.write_sfixed64",
            "values": sfixed64_values,
            "moon_type": "Int64",
            "format": moon_int64,
            "textproto": lambda v: f"value: {v}",
        },
        {
            "name": "float",
            "proto": "simple.proto",
            "message": "codec.simple.FloatValue",
            "wire_type": 5,
            "read": "@protobuf.read_float()",
            "write": "@protobuf.write_float",
            "values": float_values,
            "moon_type": "UInt",
            "format": moon_uint,
            "textproto": lambda v: f"value: {v}",
            "float_bits": True,
        },
        {
            "name": "double",
            "proto": "simple.proto",
            "message": "codec.simple.DoubleValue",
            "wire_type": 1,
            "read": "@protobuf.read_double()",
            "write": "@protobuf.write_double",
            "values": double_values,
            "moon_type": "UInt64",
            "format": moon_uint64,
            "textproto": lambda v: f"value: {v}",
            "double_bits": True,
        },
        {
            "name": "bytes",
            "proto": "simple.proto",
            "message": "codec.simple.BytesValue",
            "wire_type": 2,
            "read": "@protobuf.read_bytes()",
            "write": "@protobuf.write_bytes",
            "values": bytes_values,
            "moon_type": "Bytes",
            "format": moon_bytes_literal,
            "textproto": lambda v: f"value: {textproto_bytes_literal(v)}",
        },
        {
            "name": "string",
            "proto": "simple.proto",
            "message": "codec.simple.StringValue",
            "wire_type": 2,
            "read": "@protobuf.read_string()",
            "write": "@protobuf.write_string",
            "values": string_values,
            "moon_type": "String",
            "format": moon_string_literal,
            "textproto": lambda v: f"value: {textproto_string_literal(v)}",
        },
    ]

    for spec in simple_specs:
        entries = []
        for value in spec["values"]:
            textproto = spec["textproto"](value)
            encoded = run_protoc(spec["proto"], spec["message"], textproto + "\n")
            if spec.get("float_bits"):
                expected = float_bits_from_encoded(encoded)
            elif spec.get("double_bits"):
                expected = double_bits_from_encoded(encoded)
            else:
                expected = value
            entries.append((b64(encoded), expected))
        cases.append({"spec": spec, "entries": entries})
    return cases


def render_simple_test(cases) -> str:
    lines = [
        "// Code generated by scripts/gen_codec_tests.py. DO NOT EDIT.",
        "",
    ]
    for item in cases:
        spec = item["spec"]
        name = spec["name"]
        wire_type = spec["wire_type"]
        moon_type = spec["moon_type"]
        unwrap = spec.get("unwrap", "")
        wrap = spec.get("wrap", "")
        read_expr = f"reader |> {spec['read']}"
        if unwrap:
            read_expr = f"({read_expr}){unwrap}"

        if spec.get("float_bits"):
            lines.extend(
                [
                    f"fn decode_{name}_bits(b64 : String) -> {moon_type} raise {{",
                    "  let bytes = @protobuf.base64_decode(b64)",
                    "  let reader = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader",
                    "  let (tag, wire_type) = reader |> @protobuf.read_tag()",
                    "  assert_eq(tag, 1U)",
                    f"  assert_eq(wire_type, {wire_type}U)",
                    f"  let value = {read_expr}",
                    "  value.reinterpret_as_uint()",
                    "}",
                    "",
                    f"fn encode_{name}_bits(bits : {moon_type}) -> String raise {{",
                    "  let writer = @buffer.new()",
                    f"  writer |> @protobuf.write_tag((1U, {wire_type}U))",
                    "  let value = Float::reinterpret_from_int(bits.reinterpret_as_int())",
                    f"  writer |> {spec['write']}(value)",
                    "  writer.to_bytes() |> @protobuf.base64_encode",
                    "}",
                    "",
                    "///|",
                    f"test \"simple/{name}\" {{",
                    f"  let cases : Array[(String, {moon_type})] = [",
                ]
            )
        elif spec.get("double_bits"):
            lines.extend(
                [
                    f"fn decode_{name}_bits(b64 : String) -> {moon_type} raise {{",
                    "  let bytes = @protobuf.base64_decode(b64)",
                    "  let reader = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader",
                    "  let (tag, wire_type) = reader |> @protobuf.read_tag()",
                    "  assert_eq(tag, 1U)",
                    f"  assert_eq(wire_type, {wire_type}U)",
                    f"  let value = {read_expr}",
                    "  value.reinterpret_as_uint64()",
                    "}",
                    "",
                    f"fn encode_{name}_bits(bits : {moon_type}) -> String raise {{",
                    "  let writer = @buffer.new()",
                    f"  writer |> @protobuf.write_tag((1U, {wire_type}U))",
                    "  let value = Int64::reinterpret_as_double(bits.reinterpret_as_int64())",
                    f"  writer |> {spec['write']}(value)",
                    "  writer.to_bytes() |> @protobuf.base64_encode",
                    "}",
                    "",
                    "///|",
                    f"test \"simple/{name}\" {{",
                    f"  let cases : Array[(String, {moon_type})] = [",
                ]
            )
        else:
            lines.extend(
                [
                    f"fn decode_{name}(b64 : String) -> {moon_type} raise {{",
                    "  let bytes = @protobuf.base64_decode(b64)",
                    "  let reader = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader",
                    "  let (tag, wire_type) = reader |> @protobuf.read_tag()",
                    "  assert_eq(tag, 1U)",
                    f"  assert_eq(wire_type, {wire_type}U)",
                    f"  {read_expr}",
                    "}",
                    "",
                    f"fn encode_{name}(value : {moon_type}) -> String raise {{",
                    "  let writer = @buffer.new()",
                    f"  writer |> @protobuf.write_tag((1U, {wire_type}U))",
                ]
            )
            if wrap:
                lines.append(f"  writer |> {spec['write']}({wrap}(value))")
            else:
                lines.append(f"  writer |> {spec['write']}(value)")
            lines.extend(
                [
                    "  writer.to_bytes() |> @protobuf.base64_encode",
                    "}",
                    "",
                    "///|",
                    f"test \"simple/{name}\" {{",
                    f"  let cases : Array[(String, {moon_type})] = [",
                ]
            )

        for b64_value, expected in item["entries"]:
            if spec.get("float_bits") or spec.get("double_bits"):
                expected_literal = spec["format"](expected)
            else:
                expected_literal = spec["format"](expected)
            lines.append(f"    (\"{b64_value}\", {expected_literal}),")

        lines.extend(
            [
                "  ]",
                "  for case in cases {",
                "    let (b64, expected) = case",
            ]
        )

        if spec.get("float_bits"):
            lines.extend(
                [
                    f"    assert_eq(decode_{name}_bits(b64), expected)",
                    f"    assert_eq(encode_{name}_bits(expected), b64)",
                ]
            )
        elif spec.get("double_bits"):
            lines.extend(
                [
                    f"    assert_eq(decode_{name}_bits(b64), expected)",
                    f"    assert_eq(encode_{name}_bits(expected), b64)",
                ]
            )
        else:
            lines.extend(
                [
                    f"    assert_eq(decode_{name}(b64), expected)",
                    f"    assert_eq(encode_{name}(expected), b64)",
                ]
            )

        lines.extend(["  }", "}", ""])

    return "\n".join(lines)


def middle_cases():
    ids = [
        0,
        1,
        -1,
        2,
        -2,
        127,
        128,
        1024,
        -1024,
        16384,
        -16384,
        2147483647,
        -2147483648,
    ]
    values_cases = [
        [],
        [0],
        [1, 2, 3],
        [-1, -2],
        [127, 128, 129],
        [1024, 2048],
        [-1024, 1024],
        [2147483647],
        [-2147483648],
        [1000, -1000],
        [0, 0, 0],
    ]
    packed_cases = [
        [],
        [0],
        [1, -1],
        [63, -63, 64, -64],
        [8191, -8191, 8192, -8192],
        [123456],
        [-123456],
        [-2147483648, 2147483647],
        [5, 6, 7, 8],
    ]
    labels = [
        "",
        "alpha",
        "beta",
        "gamma",
        "delta",
        "with space",
        "symbols-!@#",
        "path\\\\slash",
    ]
    data_cases = [
        b"",
        b"\x00",
        b"\x01\x02",
        b"\xff",
        b"\x00\xff\x10\x20",
        bytes(range(5)),
        bytes(range(16)),
        b"\xde\xad\xbe\xef",
        b"\xab" * 8,
    ]
    nested_cases = [
        None,
        {"count": 0, "flag": False, "note": ""},
        {"count": 1, "flag": True, "note": "n"},
        {"count": -1, "flag": True, "note": "neg"},
        {"count": 123456789, "flag": False, "note": "note"},
        {"count": 9223372036854775807, "flag": True, "note": "max"},
        {"count": -9223372036854775808, "flag": False, "note": "min"},
    ]
    statuses = [
        None,
        "STATUS_UNSPECIFIED",
        "STATUS_OK",
        "STATUS_FAIL",
    ]
    tags_cases = [
        [],
        ["a"],
        ["x", "y"],
        ["tag-one", "tag-two", "tag-three"],
        ["dup", "dup"],
        ["edge"],
        ["m1", "m2", "m3", "m4"],
    ]
    cases = [
        {
            "id": 0,
            "values": [],
            "packed_values": [],
            "label": "",
            "data": b"",
            "nested": None,
            "status": None,
            "tags": [],
        },
        {
            "id": 1,
            "values": [1],
            "packed_values": [0],
            "label": "nested-empty",
            "data": b"\x00",
            "nested": {"count": 0, "flag": False, "note": ""},
            "status": "STATUS_OK",
            "tags": ["a"],
        },
        {
            "id": -1,
            "values": [-1, -2],
            "packed_values": [-1],
            "label": "neg",
            "data": b"\xff",
            "nested": {"count": -1, "flag": True, "note": "neg"},
            "status": "STATUS_FAIL",
            "tags": ["neg"],
        },
        {
            "id": 2147483647,
            "values": [2147483647],
            "packed_values": [-2147483648, 2147483647],
            "label": "max",
            "data": b"\x00\xff",
            "nested": {"count": 9223372036854775807, "flag": True, "note": "max"},
            "status": "STATUS_OK",
            "tags": ["edge"],
        },
        {
            "id": -2147483648,
            "values": [-2147483648],
            "packed_values": [0, 1],
            "label": "min",
            "data": b"\x10\x20\x30",
            "nested": {"count": -9223372036854775808, "flag": False, "note": "min"},
            "status": "STATUS_FAIL",
            "tags": ["edge", "min"],
        },
        {
            "id": 42,
            "values": [],
            "packed_values": [123456],
            "label": "tags-only",
            "data": b"",
            "nested": None,
            "status": "STATUS_OK",
            "tags": ["t1", "t2", "t3"],
        },
    ]
    total = 80
    for i in range(total):
        cases.append(
            {
                "id": ids[i % len(ids)],
                "values": values_cases[(i * 3) % len(values_cases)],
                "packed_values": packed_cases[(i * 5) % len(packed_cases)],
                "label": labels[(i * 7) % len(labels)],
                "data": data_cases[(i * 11) % len(data_cases)],
                "nested": nested_cases[(i * 13) % len(nested_cases)],
                "status": statuses[(i * 17) % len(statuses)],
                "tags": tags_cases[(i * 19) % len(tags_cases)],
            }
        )

    output = []
    for case in cases:
        lines = []
        lines.append(f"id: {case['id']}")
        for value in case["values"]:
            lines.append(f"values: {value}")
        for value in case["packed_values"]:
            lines.append(f"packed_values: {value}")
        if case["label"]:
            lines.append(f"label: {textproto_string_literal(case['label'])}")
        if case["data"]:
            lines.append(f"data: {textproto_bytes_literal(case['data'])}")
        if case["nested"] is not None:
            nested = case["nested"]
            lines.append("nested {")
            lines.append(f"  count: {nested['count']}")
            lines.append(f"  flag: {'true' if nested['flag'] else 'false'}")
            lines.append(f"  note: {textproto_string_literal(nested['note'])}")
            lines.append("}")
        if case["status"] is not None:
            lines.append(f"status: {case['status']}")
        for tag in case["tags"]:
            lines.append(f"tags: {textproto_string_literal(tag)}")
        textproto = "\n".join(lines) + "\n"
        encoded = run_protoc("middle.proto", "codec.middle.Middle", textproto)
        output.append((b64(encoded), case))
    return output


def render_middle_test(cases) -> str:
    lines = [
        "// Code generated by scripts/gen_codec_tests.py. DO NOT EDIT.",
        "",
        "struct MiddleDecoded {",
        "  id : Int",
        "  values : Array[Int]",
        "  packed_values : Array[Int]",
        "  label : String",
        "  data : Bytes",
        "  nested : (Int64, Bool, String)?",
        "  status : UInt",
        "  tags : Array[String]",
        "}",
        "",
        "struct MiddleCase {",
        "  b64 : String",
        "  id : Int",
        "  values : Array[Int]",
        "  packed_values : Array[Int]",
        "  label : String",
        "  data : Bytes",
        "  nested : (Int64, Bool, String)?",
        "  status : UInt",
        "  tags : Array[String]",
        "}",
        "",
        "fn decode_middle_nested(bytes : Bytes) -> (Int64, Bool, String) raise {",
        "  let reader = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader",
        "  let mut count = 0L",
        "  let mut flag = false",
        "  let mut note = \"\"",
        "  while true {",
        "    let tag_result = try { reader |> @protobuf.read_tag() } catch { _ => None } noraise { v => Some(v) }",
        "    match tag_result {",
        "      Some((tag, wire_type)) =>",
        "        match tag {",
        "          1 => count = reader |> @protobuf.read_int64()",
        "          2 => flag = reader |> @protobuf.read_bool()",
        "          3 => note = reader |> @protobuf.read_string()",
        "          _ => reader |> @protobuf.read_unknown(wire_type)",
        "        }",
        "      None => break",
        "    }",
        "  }",
        "  (count, flag, note)",
        "}",
        "",
        "fn decode_middle(b64 : String) -> MiddleDecoded raise {",
        "  let bytes = @protobuf.base64_decode(b64)",
        "  let reader = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader",
        "  let mut id = 0",
        "  let values : Array[Int] = []",
        "  let packed_values : Array[Int] = []",
        "  let mut label = \"\"",
        "  let mut data = b\"\"",
        "  let mut nested : (Int64, Bool, String)? = None",
        "  let mut status = 0U",
        "  let tags : Array[String] = []",
        "  while true {",
        "    let tag_result = try { reader |> @protobuf.read_tag() } catch { _ => None } noraise { v => Some(v) }",
        "    match tag_result {",
        "      Some((tag, wire_type)) =>",
        "        match tag {",
        "          1 => id = reader |> @protobuf.read_int32()",
        "          2 => values.push(reader |> @protobuf.read_int32())",
        "          3 => {",
        "            let packed = reader",
        "              |> @protobuf.read_packed(",
        "                fn(r) { r |> @protobuf.read_sint32() },",
        "                None,",
        "              )",
        "            for value in packed {",
        "              packed_values.push(value.0)",
        "            }",
        "          }",
        "          4 => label = reader |> @protobuf.read_string()",
        "          5 => data = reader |> @protobuf.read_bytes()",
        "          6 => nested = reader |> @protobuf.read_bytes() |> decode_middle_nested() |> Some",
        "          7 => status = (reader |> @protobuf.read_enum()).0",
        "          8 => tags.push(reader |> @protobuf.read_string())",
        "          _ => reader |> @protobuf.read_unknown(wire_type)",
        "        }",
        "      None => break",
        "    }",
        "  }",
        "  { id, values, packed_values, label, data, nested, status, tags }",
        "}",
        "",
        "fn encode_middle_nested(value : (Int64, Bool, String)) -> Bytes raise {",
        "  let (count, flag, note) = value",
        "  let writer = @buffer.new()",
        "  if count != 0L {",
        "    writer |> @protobuf.write_tag((1U, 0U))",
        "    writer |> @protobuf.write_int64(count)",
        "  }",
        "  if flag {",
        "    writer |> @protobuf.write_tag((2U, 0U))",
        "    writer |> @protobuf.write_bool(flag)",
        "  }",
        "  if note != \"\" {",
        "    writer |> @protobuf.write_tag((3U, 2U))",
        "    writer |> @protobuf.write_string(note)",
        "  }",
        "  writer.to_bytes()",
        "}",
        "",
        "fn encode_middle(case : MiddleCase) -> String raise {",
        "  let writer = @buffer.new()",
        "  if case.id != 0 {",
        "    writer |> @protobuf.write_tag((1U, 0U))",
        "    writer |> @protobuf.write_int32(case.id)",
        "  }",
        "  for value in case.values {",
        "    writer |> @protobuf.write_tag((2U, 0U))",
        "    writer |> @protobuf.write_int32(value)",
        "  }",
        "  if case.packed_values.length() > 0 {",
        "    let packed_writer = @buffer.new()",
        "    for value in case.packed_values {",
        "      packed_writer |> @protobuf.write_sint32(value)",
        "    }",
        "    writer |> @protobuf.write_tag((3U, 2U))",
        "    writer |> @protobuf.write_bytes(packed_writer.to_bytes())",
        "  }",
        "  if case.label != \"\" {",
        "    writer |> @protobuf.write_tag((4U, 2U))",
        "    writer |> @protobuf.write_string(case.label)",
        "  }",
        "  if case.data.length() > 0 {",
        "    writer |> @protobuf.write_tag((5U, 2U))",
        "    writer |> @protobuf.write_bytes(case.data)",
        "  }",
        "  if case.nested is Some(value) {",
        "    writer |> @protobuf.write_tag((6U, 2U))",
        "    writer |> @protobuf.write_bytes(encode_middle_nested(value))",
        "  }",
        "  if case.status != 0U {",
        "    writer |> @protobuf.write_tag((7U, 0U))",
        "    writer |> @protobuf.write_enum(@protobuf.Enum(case.status))",
        "  }",
        "  for tag in case.tags {",
        "    writer |> @protobuf.write_tag((8U, 2U))",
        "    writer |> @protobuf.write_string(tag)",
        "  }",
        "  writer.to_bytes() |> @protobuf.base64_encode",
        "}",
        "",
        "///|",
        "test \"middle/messages\" {",
        "  let cases : Array[MiddleCase] = [",
    ]

    for b64_value, case in cases:
        nested = "None"
        if case["nested"] is not None:
            nested_value = case["nested"]
            nested = (
                "Some(("
                + ", ".join(
                    [
                        moon_int64(nested_value["count"]),
                        "true" if nested_value["flag"] else "false",
                        moon_string_literal(nested_value["note"]),
                    ]
                )
                + "))"
            )
        lines.append("    {")
        lines.append(f"      b64: \"{b64_value}\",")
        lines.append(f"      id: {moon_int(case['id'])},")
        lines.append(
            f"      values: {moon_array(moon_int(v) for v in case['values'])},"
        )
        lines.append(
            f"      packed_values: {moon_array(moon_int(v) for v in case['packed_values'])},"
        )
        lines.append(f"      label: {moon_string_literal(case['label'])},")
        lines.append(f"      data: {moon_bytes_literal(case['data'])},")
        lines.append(f"      nested: {nested},")
        status_value = 0
        if case["status"] is not None:
            status_value = {
                "STATUS_UNSPECIFIED": 0,
                "STATUS_OK": 1,
                "STATUS_FAIL": 2,
            }[case["status"]]
        lines.append(f"      status: {moon_uint(status_value)},")
        lines.append(
            f"      tags: {moon_array(moon_string_literal(tag) for tag in case['tags'])},"
        )
        lines.append("    },")

    lines.extend(
        [
            "  ]",
            "  for case in cases {",
            "    let decoded = decode_middle(case.b64)",
            "    assert_eq(decoded.id, case.id)",
            "    assert_eq(decoded.values, case.values)",
            "    assert_eq(decoded.packed_values, case.packed_values)",
            "    assert_eq(decoded.label, case.label)",
            "    assert_eq(decoded.data, case.data)",
            "    assert_eq(decoded.nested, case.nested)",
            "    assert_eq(decoded.status, case.status)",
            "    assert_eq(decoded.tags, case.tags)",
            "    assert_eq(encode_middle(case), case.b64)",
            "  }",
            "}",
            "",
        ]
    )

    return "\n".join(lines)


def difficult_cases():
    big_values = [
        0,
        1,
        127,
        128,
        16384,
        4294967295,
        4294967296,
        9223372036854775808,
        18446744073709551615,
        1234567890123456789,
    ]
    zigzag_values = [
        0,
        1,
        -1,
        2,
        -2,
        63,
        -63,
        64,
        -64,
        123456,
        -123456,
        2147483647,
        -2147483648,
    ]
    ratio_values = [
        0.0,
        1.5,
        -3.5,
        0.125,
        3.14159,
        1e-9,
        1e6,
        -2.25,
    ]
    scores_cases = [
        [],
        [0.0],
        [1.25, -2.5],
        [0.0, 99.5],
        [1e-3, 1e3],
        [-1.0, -2.0, -3.0],
        [123.456, 789.012],
        [0.125, 0.25, 0.5, 1.0],
    ]
    items_cases = [
        [],
        [
            {"name": "a", "raw": b"\x01", "code": 1},
        ],
        [
            {"name": "first", "raw": b"\xff\x00", "code": 0x123456789ABCDEF0},
        ],
        [
            {"name": "x", "raw": b"", "code": 0},
            {"name": "y", "raw": b"\x10\x20", "code": 999},
        ],
        [
            {"name": "big", "raw": bytes(range(4)), "code": 18446744073709551615},
        ],
        [
            {"name": "empty-raw", "raw": b"", "code": 42},
        ],
        [
            {"name": "mix", "raw": b"\x00\xff", "code": 0x0F0E0D0C0B0A0908},
            {"name": "tail", "raw": bytes(range(8)), "code": 7},
        ],
    ]
    counts_cases = [
        [],
        [("a", 1), ("b", 2)],
        [("max", 2147483647)],
        [("x", -1), ("y", 7)],
        [("dup", 1), ("dup", 2)],
        [("zero", 0)],
        [("neg", -2147483648), ("pos", 2147483647)],
    ]
    choices = [
        ("hello", None),
        (None, 42),
        ("world", None),
        (None, 0),
        ("choice text", None),
        (None, -1),
    ]
    payload_cases = [
        b"",
        b"\xff",
        b"\x00\x01",
        b"\x10\x20\x30",
        b"\x00\xff\x10\x20",
        bytes(range(8)),
    ]
    cases = [
        {
            "big": 0,
            "zigzag": 0,
            "ratio": 0.0,
            "scores": [],
            "items": [],
            "counts": [],
            "choice_text": None,
            "choice_number": None,
            "payload": b"",
        },
        {
            "big": 1,
            "zigzag": -1,
            "ratio": 1.5,
            "scores": [1.25, -2.5],
            "items": [
                {"name": "a", "raw": b"\x01", "code": 1},
            ],
            "counts": [("a", 1), ("b", 2)],
            "choice_text": "hello",
            "choice_number": None,
            "payload": b"\x00\x01",
        },
        {
            "big": 18446744073709551615,
            "zigzag": 123456,
            "ratio": -3.5,
            "scores": [0.0, 99.5],
            "items": [
                {"name": "first", "raw": b"\xff\x00", "code": 0x123456789ABCDEF0},
            ],
            "counts": [("max", 2147483647)],
            "choice_text": None,
            "choice_number": 0,
            "payload": b"\xff",
        },
        {
            "big": 9223372036854775808,
            "zigzag": -2147483648,
            "ratio": 2.0,
            "scores": [],
            "items": [
                {"name": "x", "raw": b"", "code": 0},
                {"name": "y", "raw": b"\x10\x20", "code": 999},
            ],
            "counts": [("dup", 1), ("dup", 2)],
            "choice_text": "world",
            "choice_number": None,
            "payload": b"\x10\x20\x30",
        },
        {
            "big": 999,
            "zigzag": -999,
            "ratio": 3.14159,
            "scores": [1e-3, 1e3],
            "items": [
                {"name": "mix", "raw": b"\x00\xff", "code": 0x0F0E0D0C0B0A0908},
                {"name": "tail", "raw": bytes(range(8)), "code": 7},
            ],
            "counts": [("alpha", 100), ("beta", 200), ("gamma", 300)],
            "choice_text": None,
            "choice_number": 2147483647,
            "payload": b"\x00\xff\x10\x20",
        },
        {
            "big": 1234567890123456789,
            "zigzag": 12345,
            "ratio": 1e-9,
            "scores": [123.456, 789.012],
            "items": [
                {"name": "m", "raw": b"\x01\x02\x03", "code": 123456789},
            ],
            "counts": [("k", -2147483648)],
            "choice_text": None,
            "choice_number": -1,
            "payload": b"\x7f",
        },
    ]
    total = 70
    for i in range(total):
        choice_text, choice_number = choices[(i * 17) % len(choices)]
        cases.append(
            {
                "big": big_values[i % len(big_values)],
                "zigzag": zigzag_values[(i * 3) % len(zigzag_values)],
                "ratio": ratio_values[(i * 5) % len(ratio_values)],
                "scores": scores_cases[(i * 7) % len(scores_cases)],
                "items": items_cases[(i * 11) % len(items_cases)],
                "counts": counts_cases[(i * 13) % len(counts_cases)],
                "choice_text": choice_text,
                "choice_number": choice_number,
                "payload": payload_cases[(i * 19) % len(payload_cases)],
            }
        )

    output = []
    for case in cases:
        lines = []
        lines.append(f"big: {case['big']}")
        lines.append(f"zigzag: {case['zigzag']}")
        lines.append(f"ratio: {float_literal(case['ratio'])}")
        for score in case["scores"]:
            lines.append(f"scores: {float_literal(score)}")
        for item in case["items"]:
            lines.append("items {")
            lines.append(f"  name: {textproto_string_literal(item['name'])}")
            if item["raw"] is not None:
                lines.append(f"  raw: {textproto_bytes_literal(item['raw'])}")
            lines.append(f"  code: {item['code']}")
            lines.append("}")
        for key, value in case["counts"]:
            lines.append("counts {")
            lines.append(f"  key: {textproto_string_literal(key)}")
            lines.append(f"  value: {value}")
            lines.append("}")
        if case["choice_text"] is not None:
            lines.append(f"text: {textproto_string_literal(case['choice_text'])}")
        if case["choice_number"] is not None:
            lines.append(f"number: {case['choice_number']}")
        if case["payload"]:
            lines.append(f"payload: {textproto_bytes_literal(case['payload'])}")

        textproto = "\n".join(lines) + "\n"
        encoded = run_protoc("difficult.proto", "codec.difficult.Difficult", textproto)
        output.append((b64(encoded), case))
    return output


def render_difficult_test(cases) -> str:
    lines = [
        "// Code generated by scripts/gen_codec_tests.py. DO NOT EDIT.",
        "",
        "struct DifficultDecoded {",
        "  big : UInt64",
        "  zigzag : Int",
        "  ratio : Double",
        "  scores : Array[Double]",
        "  items : Array[(String, Bytes, UInt64)]",
        "  counts : Array[(String, Int)]",
        "  choice_text : String?",
        "  choice_number : Int?",
        "  payload : Bytes",
        "}",
        "",
        "struct DifficultCase {",
        "  b64 : String",
        "  big : UInt64",
        "  zigzag : Int",
        "  ratio : Double",
        "  scores : Array[Double]",
        "  items : Array[(String, Bytes, UInt64)]",
        "  counts : Array[(String, Int)]",
        "  choice_text : String?",
        "  choice_number : Int?",
        "  payload : Bytes",
        "}",
        "",
        "fn decode_item(bytes : Bytes) -> (String, Bytes, UInt64) raise {",
        "  let reader = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader",
        "  let mut name = \"\"",
        "  let mut raw = b\"\"",
        "  let mut code = 0UL",
        "  while true {",
        "    let tag_result = try { reader |> @protobuf.read_tag() } catch { _ => None } noraise { v => Some(v) }",
        "    match tag_result {",
        "      Some((tag, wire_type)) =>",
        "        match tag {",
        "          1 => name = reader |> @protobuf.read_string()",
        "          2 => raw = reader |> @protobuf.read_bytes()",
        "          3 => code = reader |> @protobuf.read_fixed64()",
        "          _ => reader |> @protobuf.read_unknown(wire_type)",
        "        }",
        "      None => break",
        "    }",
        "  }",
        "  (name, raw, code)",
        "}",
        "",
        "fn decode_count(bytes : Bytes) -> (String, Int) raise {",
        "  let reader = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader",
        "  let mut key = \"\"",
        "  let mut value = 0",
        "  while true {",
        "    let tag_result = try { reader |> @protobuf.read_tag() } catch { _ => None } noraise { v => Some(v) }",
        "    match tag_result {",
        "      Some((tag, wire_type)) =>",
        "        match tag {",
        "          1 => key = reader |> @protobuf.read_string()",
        "          2 => value = reader |> @protobuf.read_int32()",
        "          _ => reader |> @protobuf.read_unknown(wire_type)",
        "        }",
        "      None => break",
        "    }",
        "  }",
        "  (key, value)",
        "}",
        "",
        "fn decode_difficult(b64 : String) -> DifficultDecoded raise {",
        "  let bytes = @protobuf.base64_decode(b64)",
        "  let reader = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader",
        "  let mut big = 0UL",
        "  let mut zigzag = 0",
        "  let mut ratio = 0.0",
        "  let scores : Array[Double] = []",
        "  let items : Array[(String, Bytes, UInt64)] = []",
        "  let counts : Array[(String, Int)] = []",
        "  let mut choice_text : String? = None",
        "  let mut choice_number : Int? = None",
        "  let mut payload = b\"\"",
        "  while true {",
        "    let tag_result = try { reader |> @protobuf.read_tag() } catch { _ => None } noraise { v => Some(v) }",
        "    match tag_result {",
        "      Some((tag, wire_type)) =>",
        "        match tag {",
        "          1 => big = reader |> @protobuf.read_uint64()",
        "          2 => zigzag = (reader |> @protobuf.read_sint32()).0",
        "          3 => ratio = reader |> @protobuf.read_double()",
        "          4 => {",
        "            let packed = reader",
        "              |> @protobuf.read_packed(",
        "                fn(r) { r |> @protobuf.read_double() },",
        "                Some(8U),",
        "              )",
        "            for score in packed {",
        "              scores.push(score)",
        "            }",
        "          }",
        "          5 => items.push(reader |> @protobuf.read_bytes() |> decode_item())",
        "          6 => counts.push(reader |> @protobuf.read_bytes() |> decode_count())",
        "          7 => choice_text = reader |> @protobuf.read_string() |> Some",
        "          8 => choice_number = reader |> @protobuf.read_int32() |> Some",
        "          9 => payload = reader |> @protobuf.read_bytes()",
        "          _ => reader |> @protobuf.read_unknown(wire_type)",
        "        }",
        "      None => break",
        "    }",
        "  }",
        "  { big, zigzag, ratio, scores, items, counts, choice_text, choice_number, payload }",
        "}",
        "",
        "fn encode_item(item : (String, Bytes, UInt64)) -> Bytes raise {",
        "  let (name, raw, code) = item",
        "  let writer = @buffer.new()",
        "  if name != \"\" {",
        "    writer |> @protobuf.write_tag((1U, 2U))",
        "    writer |> @protobuf.write_string(name)",
        "  }",
        "  if raw.length() > 0 {",
        "    writer |> @protobuf.write_tag((2U, 2U))",
        "    writer |> @protobuf.write_bytes(raw)",
        "  }",
        "  if code != 0UL {",
        "    writer |> @protobuf.write_tag((3U, 1U))",
        "    writer |> @protobuf.write_fixed64(code)",
        "  }",
        "  writer.to_bytes()",
        "}",
        "",
        "fn encode_count(entry : (String, Int)) -> Bytes raise {",
        "  let (key, value) = entry",
        "  let writer = @buffer.new()",
        "  if key != \"\" {",
        "    writer |> @protobuf.write_tag((1U, 2U))",
        "    writer |> @protobuf.write_string(key)",
        "  }",
        "  writer |> @protobuf.write_tag((2U, 0U))",
        "  writer |> @protobuf.write_int32(value)",
        "  writer.to_bytes()",
        "}",
        "",
        "fn encode_difficult(case : DifficultCase) -> String raise {",
        "  let writer = @buffer.new()",
        "  if case.big != 0UL {",
        "    writer |> @protobuf.write_tag((1U, 0U))",
        "    writer |> @protobuf.write_uint64(case.big)",
        "  }",
        "  if case.zigzag != 0 {",
        "    writer |> @protobuf.write_tag((2U, 0U))",
        "    writer |> @protobuf.write_sint32(case.zigzag)",
        "  }",
        "  if case.ratio != 0.0 {",
        "    writer |> @protobuf.write_tag((3U, 1U))",
        "    writer |> @protobuf.write_double(case.ratio)",
        "  }",
        "  if case.scores.length() > 0 {",
        "    let packed_writer = @buffer.new()",
        "    for score in case.scores {",
        "      packed_writer |> @protobuf.write_double(score)",
        "    }",
        "    writer |> @protobuf.write_tag((4U, 2U))",
        "    writer |> @protobuf.write_bytes(packed_writer.to_bytes())",
        "  }",
        "  for item in case.items {",
        "    writer |> @protobuf.write_tag((5U, 2U))",
        "    writer |> @protobuf.write_bytes(encode_item(item))",
        "  }",
        "  for entry in case.counts {",
        "    writer |> @protobuf.write_tag((6U, 2U))",
        "    writer |> @protobuf.write_bytes(encode_count(entry))",
        "  }",
        "  if case.choice_text is Some(value) {",
        "    writer |> @protobuf.write_tag((7U, 2U))",
        "    writer |> @protobuf.write_string(value)",
        "  }",
        "  if case.choice_number is Some(value) {",
        "    writer |> @protobuf.write_tag((8U, 0U))",
        "    writer |> @protobuf.write_int32(value)",
        "  }",
        "  if case.payload.length() > 0 {",
        "    writer |> @protobuf.write_tag((9U, 2U))",
        "    writer |> @protobuf.write_bytes(case.payload)",
        "  }",
        "  writer.to_bytes() |> @protobuf.base64_encode",
        "}",
        "",
        "///|",
        "test \"difficult/messages\" {",
        "  let cases : Array[DifficultCase] = [",
    ]

    for b64_value, case in cases:
        choice_text = "None"
        if case["choice_text"] is not None:
            choice_text = f"Some({moon_string_literal(case['choice_text'])})"
        choice_number = "None"
        if case["choice_number"] is not None:
            choice_number = f"Some({moon_int(case['choice_number'])})"
        lines.append("    {")
        lines.append(f"      b64: \"{b64_value}\",")
        lines.append(f"      big: {moon_uint64(case['big'])},")
        lines.append(f"      zigzag: {moon_int(case['zigzag'])},")
        lines.append(f"      ratio: {float_literal(case['ratio'])},")
        lines.append(
            f"      scores: {moon_array(float_literal(score) for score in case['scores'])},"
        )
        item_literals = []
        for item in case["items"]:
            item_literals.append(
                "("
                + ", ".join(
                    [
                        moon_string_literal(item["name"]),
                        moon_bytes_literal(item["raw"]),
                        moon_uint64(item["code"]),
                    ]
                )
                + ")"
            )
        lines.append(f"      items: {moon_array(item_literals)},")
        count_literals = []
        for key, value in case["counts"]:
            count_literals.append(
                "(" + ", ".join([moon_string_literal(key), moon_int(value)]) + ")"
            )
        lines.append(f"      counts: {moon_array(count_literals)},")
        lines.append(f"      choice_text: {choice_text},")
        lines.append(f"      choice_number: {choice_number},")
        lines.append(f"      payload: {moon_bytes_literal(case['payload'])},")
        lines.append("    },")

    lines.extend(
        [
            "  ]",
            "  for case in cases {",
            "    let decoded = decode_difficult(case.b64)",
            "    assert_eq(decoded.big, case.big)",
            "    assert_eq(decoded.zigzag, case.zigzag)",
            "    assert_eq(decoded.ratio, case.ratio)",
            "    assert_eq(decoded.scores, case.scores)",
            "    assert_eq(decoded.items, case.items)",
            "    assert_eq(decoded.counts, case.counts)",
            "    assert_eq(decoded.choice_text, case.choice_text)",
            "    assert_eq(decoded.choice_number, case.choice_number)",
            "    assert_eq(decoded.payload, case.payload)",
            "    assert_eq(encode_difficult(case), case.b64)",
            "  }",
            "}",
            "",
        ]
    )

    return "\n".join(lines)


def bad_cases():
    cases = [
        {
            "name": "unknown_wire",
            "data": bytes([0x0E]),
            "expect": "Err(UnknownWireType(6))",
            "action": "read_tag",
        },
        {
            "name": "truncated_string",
            "data": bytes([0x0A, 0x02, 0x61]),
            "expect": "Err(EndOfStream)",
            "action": "read_string",
        },
        {
            "name": "invalid_string",
            "data": bytes([0x0A, 0x01, 0xC2]),
            "expect": "Err(InvalidString)",
            "action": "read_string",
        },
    ]
    output = []
    for case in cases:
        output.append(
            {
                "name": case["name"],
                "b64": b64(case["data"]),
                "expect": case["expect"],
                "action": case["action"],
            }
        )
    return output


def render_bad_test(cases) -> str:
    lines = [
        "// Code generated by scripts/gen_codec_tests.py. DO NOT EDIT.",
        "",
    ]
    for case in cases:
        lines.extend(
            [
                "///|",
                f"test \"bad/{case['name']}\" {{",
                f"  let bytes = @protobuf.base64_decode(\"{case['b64']}\")",
                "  let reader = @protobuf.BytesReader::from_bytes(bytes) as &@protobuf.Reader",
            ]
        )
        if case["action"] == "read_tag":
            lines.append(
                f"  inspect(try? (reader |> @protobuf.read_tag()), content=\"{case['expect']}\")"
            )
        else:
            lines.append("  let (tag, wire_type) = reader |> @protobuf.read_tag()")
            lines.append("  assert_eq(tag, 1U)")
            lines.append("  assert_eq(wire_type, 2U)")
            lines.append(
                f"  inspect(try? (reader |> @protobuf.read_string()), content=\"{case['expect']}\")"
            )
        lines.extend(["}", ""])
    return "\n".join(lines)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    simple = simple_cases()
    simple_text = render_simple_test(simple)
    (OUT_DIR / "codec_simple_test.mbt").write_text(simple_text, encoding="utf-8")

    middle = middle_cases()
    middle_text = render_middle_test(middle)
    (OUT_DIR / "codec_middle_test.mbt").write_text(middle_text, encoding="utf-8")

    difficult = difficult_cases()
    difficult_text = render_difficult_test(difficult)
    (OUT_DIR / "codec_difficult_test.mbt").write_text(difficult_text, encoding="utf-8")

    bad = bad_cases()
    bad_text = render_bad_test(bad)
    (OUT_DIR / "codec_bad_test.mbt").write_text(bad_text, encoding="utf-8")


if __name__ == "__main__":
    main()
