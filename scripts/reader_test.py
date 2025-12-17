#!/usr/bin/env python3
import argparse
import sys
import subprocess
from pathlib import Path
from typing import Optional

from common import update_lib_deps
from workflow import ProjectConfig, CommandRunner, WorkflowExecutor
from logger import get_logger

logger = get_logger(__name__)

SCRIPT_DIR = Path(__file__).parent.absolute()
PROJECT_ROOT = SCRIPT_DIR.parent
READER_DIR = PROJECT_ROOT / "test" / "reader"
BIN_DIR = READER_DIR / "bin"
RUNNER_DIR = READER_DIR / "runner"
GO_GEN_CLI_DIR = PROJECT_ROOT / "test" / "go-gen" / "cli"


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Run reader test for MoonBit protobuf generator",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                           Run reader test
  %(prog)s -I /usr/include           Add extra protobuf include path
        """,
    )
    parser.add_argument(
        "--include-path",
        "-I",
        metavar="PATH",
        help="Additional protoc include path",
    )
    parser.add_argument(
        "--update",
        "-U",
        action="store_true",
        help="Update test snapshots/expectations",
    )
    return parser.parse_args()


def generate_moonbit_code(executor: WorkflowExecutor, include_path: Optional[str] = None) -> None:
    logger.info("Generating MoonBit code from proto files...")
    for proto_file in READER_DIR.glob("*.proto"):
        project_name = f"gen_{proto_file.stem}"
        work_dir = READER_DIR / project_name
        executor.run_protoc(
            READER_DIR,
            READER_DIR,
            project_name,
            [proto_file.name],
            include_path=include_path,
        )
        update_lib_deps(PROJECT_ROOT, work_dir)
        executor.run_moon_workflow(work_dir, steps=["update", "install", "fmt"])
    logger.info("MoonBit code generated successfully")


def build_go_binary(runner: CommandRunner, go_gen_cli_dir: Path, bin_dir: Path):
    logger.info("Building Go binary...")
    bin_dir.mkdir(parents=True, exist_ok=True)
    runner.run(["go", "run", "main.go", "p2_cases.go", "p3_cases.go", "-o", str(bin_dir)], cwd=go_gen_cli_dir)
    runner.run(["go", "run", "main.go", "p2_cases.go", "p3_cases.go", "-f", "json", "-o", str(bin_dir)], cwd=go_gen_cli_dir)
    logger.info("Go binary built successfully")


def run_reader_test(executor: WorkflowExecutor, runner_dir: Path, update_mode: bool = False):
    logger.info("Running reader test...")
    if update_mode:
        try:
            executor.moon.test(runner_dir, target="all")
        except Exception as e:
            logger.warning(f"Initial test failed before update: {e}")
            executor.moon.test_update(runner_dir)
    else:
        executor.moon.test(runner_dir, target="all")
    logger.info("Reader test passed")


def main():
    args = parse_arguments()

    logger.info("Starting MoonBit protobuf reader test")
    logger.info(f"Project root: {PROJECT_ROOT}")

    try:
        config = ProjectConfig(PROJECT_ROOT)
        runner = CommandRunner(logger)
        executor = WorkflowExecutor(config, runner)

        executor.build_plugin()
        generate_moonbit_code(executor, args.include_path)
        build_go_binary(runner, GO_GEN_CLI_DIR, BIN_DIR)
        executor.moon.install(RUNNER_DIR)
        run_reader_test(executor, RUNNER_DIR, args.update)
        executor.moon.fmt(RUNNER_DIR)

        if args.update:
            logger.info("Reader test completed successfully with snapshots updated!")
        else:
            logger.info("Reader test completed successfully!")
    except KeyboardInterrupt:
        logger.warning("Test interrupted by user")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
