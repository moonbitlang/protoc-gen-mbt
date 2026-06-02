#!/usr/bin/env python3
from __future__ import annotations

import argparse
import logging
import os
import subprocess
import sys
from pathlib import Path
from typing import Mapping, Sequence


ROOT = Path(__file__).resolve().parents[1]
CLI_DIR = ROOT / "cli"
PLUGIN_DIR = ROOT / "plugin"
READER_DIR = ROOT / "test" / "reader"
SNAPSHOT_DIR = ROOT / "test" / "snapshots"
PLUGIN_EXE = (
    ROOT
    / "_build"
    / "native"
    / "debug"
    / "build"
    / "moonbitlang"
    / "protoc-gen-mbt"
    / "protoc-gen-mbt.exe"
)

logger = logging.getLogger(__name__)


def configure_logging() -> None:
    logging.basicConfig(
        format="%(levelname)s: %(message)s",
        level=logging.INFO,
        stream=sys.stdout,
    )


def run(
    command: Sequence[str],
    *,
    cwd: Path | None = None,
    env: Mapping[str, str] | None = None,
    description: str | None = None,
    check: bool = True,
) -> subprocess.CompletedProcess[str]:
    if description:
        logger.info("%s...", description)
    logger.info("$ %s", " ".join(command))

    result = subprocess.run(
        command,
        cwd=cwd,
        env=env,
        text=True,
        capture_output=True,
        check=False,
    )
    if check and result.returncode != 0:
        print_output(result)
        raise subprocess.CalledProcessError(
            result.returncode,
            command,
            output=result.stdout,
            stderr=result.stderr,
        )
    if result.returncode == 0 and result.stdout:
        logger.info(result.stdout.rstrip())
    return result


def moon(
    args: Sequence[str],
    *,
    cwd: Path | None = None,
    env: Mapping[str, str] | None = None,
    description: str | None = None,
    check: bool = True,
) -> subprocess.CompletedProcess[str]:
    return run(["moon", *args], cwd=cwd, env=env, description=description, check=check)


def print_output(result: subprocess.CompletedProcess[str]) -> None:
    for name, text in (("STDOUT", result.stdout), ("STDERR", result.stderr)):
        if text:
            print(f"=== {name} ===")
            print(text)
            print("==============")


def moon_work_env(work_file: Path) -> dict[str, str]:
    return {**os.environ, "MOON_WORK": str(work_file.resolve())}


def build_plugin() -> None:
    moon(
        ["build", "--target", "native"],
        cwd=CLI_DIR,
        description="Building protoc-gen-mbt plugin",
    )
    if not PLUGIN_EXE.exists():
        raise RuntimeError(f"plugin binary not found: {PLUGIN_EXE}")
    logger.info("Plugin built successfully at %s", PLUGIN_EXE)


def run_protoc(
    *,
    proto_dir: Path,
    output_dir: Path,
    project_name: str,
    proto_files: Sequence[str],
    username: str = "username",
    include_path: str | None = None,
) -> None:
    proto_paths = [f"--proto_path={proto_dir}"]
    if include_path:
        proto_paths.append(f"--proto_path={include_path}")

    run(
        [
            "protoc",
            f"--plugin=protoc-gen-mbt={PLUGIN_EXE}",
            *proto_paths,
            f"--mbt_out={output_dir}",
            "--mbt_opt="
            f"paths=source_relative,project_name={project_name},username={username}",
            *proto_files,
        ],
        description=f"Generating {project_name} with protoc",
    )


def generate_plugin(_: argparse.Namespace) -> None:
    if not (PLUGIN_DIR / "plugin.proto").exists():
        raise RuntimeError(f"plugin.proto not found: {PLUGIN_DIR / 'plugin.proto'}")

    logger.info("Project root: %s", ROOT)
    build_plugin()
    run_protoc(
        proto_dir=PLUGIN_DIR,
        output_dir=ROOT,
        project_name="plugin",
        proto_files=["plugin.proto", "google/protobuf/descriptor.proto"],
        username="moonbitlang",
    )
    moon(
        ["fmt", "moon.mod.json"],
        cwd=PLUGIN_DIR,
        description="Converting generated module config",
    )
    moon(
        ["-C", str(PLUGIN_DIR), "add", "moonbitlang/async@0.18.0"],
        cwd=ROOT,
        description="Adding async dependency to plugin module",
    )
    for args, description in (
        (["check", "--target", "native"], "Running moon check (native)"),
        (["test", "--target", "native"], "Running moon test (native)"),
        (["fmt"], "Running moon fmt"),
        (["info", "--target", "native"], "Running moon info (native)"),
    ):
        moon(args, cwd=PLUGIN_DIR, description=description)
    logger.info("Plugin code generation completed successfully.")


def snapshot_test(args: argparse.Namespace) -> None:
    logger.info("Project root: %s", ROOT)
    build_plugin()

    proto_dirs = sorted({path.parent for path in SNAPSHOT_DIR.rglob("*.proto")})
    if not proto_dirs:
        raise RuntimeError(f"no .proto files found in {SNAPSHOT_DIR}")

    for proto_dir in proto_dirs:
        for proto_file in sorted(path.name for path in proto_dir.glob("*.proto")):
            run_protoc(
                proto_dir=proto_dir,
                output_dir=proto_dir,
                project_name="__snapshot",
                proto_files=[proto_file],
                include_path=args.include_path,
            )
            result = moon(
                ["check", "src", "--target", "native"],
                cwd=proto_dir / "__snapshot",
                env=moon_work_env(proto_dir / "moon.work"),
                description=f"Checking generated snapshot for {proto_dir}/{proto_file}",
                check=False,
            )
            if result.returncode != 0:
                logger.warning("moon check failed for %s/%s", proto_dir, proto_file)
                print_output(result)

    logger.info("Code generation completed")
    if args.update:
        logger.info("Snapshot test completed with snapshots updated.")
        return

    diff = run(
        ["git", "diff", "--name-only", "test/snapshots"],
        cwd=ROOT,
        description="Checking snapshot diff",
        check=False,
    )
    if diff.returncode != 0:
        print_output(diff)
        raise RuntimeError("failed to run git diff")

    changed = diff.stdout.splitlines()
    if changed:
        logger.warning("Changes detected in snapshots via git diff:")
        for path in changed:
            logger.info("  - %s", path)
        raise RuntimeError("snapshot test failed - differences detected")
    logger.info("All snapshots match")


def reader_test(args: argparse.Namespace) -> None:
    reader_env = moon_work_env(READER_DIR / "moon.work")
    runner_dir = READER_DIR / "runner"
    bin_dir = READER_DIR / "bin"
    go_gen_cli_dir = ROOT / "test" / "go-gen" / "cli"

    logger.info("Project root: %s", ROOT)
    build_plugin()

    logger.info("Generating MoonBit code from proto files...")
    proto_files = sorted(READER_DIR.glob("*.proto"))
    if not proto_files:
        raise RuntimeError(f"no .proto files found in {READER_DIR}")
    for proto_file in proto_files:
        project_name = f"gen_{proto_file.stem}"
        run_protoc(
            proto_dir=READER_DIR,
            output_dir=READER_DIR,
            project_name=project_name,
            proto_files=[proto_file.name],
            include_path=args.include_path,
        )
        moon(
            ["fmt", "src"],
            cwd=READER_DIR / project_name,
            env=reader_env,
            description=f"Formatting generated {project_name}",
        )
    logger.info("MoonBit code generated successfully")

    logger.info("Building Go binary...")
    bin_dir.mkdir(parents=True, exist_ok=True)
    for extra_args in ([], ["-f", "json"]):
        run(
            [
                "go",
                "run",
                "main.go",
                "p2_cases.go",
                "p3_cases.go",
                *extra_args,
                "-o",
                str(bin_dir),
            ],
            cwd=go_gen_cli_dir,
        )
    logger.info("Go binary built successfully")

    logger.info("Running reader test...")
    test_args = ["test", "src", "--target", "all"]
    if args.update:
        result = moon(
            test_args,
            cwd=runner_dir,
            env=reader_env,
            description="Running moon test (all)",
            check=False,
        )
        if result.returncode != 0:
            logger.warning("Initial reader test failed before update")
            print_output(result)
            moon(
                ["test", "src", "--target", "native", "--update"],
                cwd=runner_dir,
                env=reader_env,
                description="Updating reader test snapshots",
            )
    else:
        moon(
            test_args,
            cwd=runner_dir,
            env=reader_env,
            description="Running moon test (all)",
        )

    logger.info("Reader test passed")
    moon(
        ["fmt", "src"],
        cwd=runner_dir,
        env=reader_env,
        description="Formatting reader test runner",
    )
    if args.update:
        logger.info("Reader test completed successfully with snapshots updated.")
    else:
        logger.info("Reader test completed successfully.")


def add_test_options(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--include-path", "-I", metavar="PATH")
    parser.add_argument("--update", "-U", action="store_true")


def parse_args(argv: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run protoc-gen-mbt workflows")
    subcommands = parser.add_subparsers(required=True)

    generate = subcommands.add_parser(
        "generate-plugin",
        aliases=["generate_plugin"],
        help="regenerate plugin code from plugin.proto",
    )
    generate.set_defaults(handler=generate_plugin)

    reader = subcommands.add_parser(
        "reader-test",
        aliases=["reader_test"],
        help="run protobuf reader tests",
    )
    add_test_options(reader)
    reader.set_defaults(handler=reader_test)

    snapshot = subcommands.add_parser(
        "snapshot-test",
        aliases=["snapshot_test"],
        help="run snapshot generation tests",
    )
    add_test_options(snapshot)
    snapshot.set_defaults(handler=snapshot_test)

    return parser.parse_args(argv)


def main(argv: Sequence[str]) -> int:
    configure_logging()
    args = parse_args(argv)
    try:
        args.handler(args)
    except KeyboardInterrupt:
        logger.warning("Interrupted by user")
        return 1
    except Exception as exc:
        logger.error(exc)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
