#!/usr/bin/env python3
"""
Reader test runner for MoonBit protobuf code generator.

This script tests the protobuf reader functionality by:
1. Generating MoonBit code from a proto file
2. Building and running test binaries
3. Verifying the generated code works correctly
"""

import argparse
import sys
from pathlib import Path
from typing import Optional

# Import common functions
from common import build_plugin, build_protoc_command, run_command, update_lib_deps


from logger import get_logger

logger = get_logger(__name__)

# Project paths as constants
SCRIPT_DIR = Path(__file__).parent.absolute()
PROJECT_ROOT = SCRIPT_DIR.parent
READER_DIR = PROJECT_ROOT / "test" / "reader"
BIN_DIR = READER_DIR / "bin"
GO_GEN_CLI_DIR = PROJECT_ROOT / "test" / "go-gen" / "cli"
RUNNER_DIR = PROJECT_ROOT / "test" / "reader" / "runner"


def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Run reader test for MoonBit protobuf generator",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                           Run reader test
  %(prog)s --include-path /usr/include       Use custom include path for protobuf
        """,
    )

    parser.add_argument(
        "--include-path",
        "-I",
        metavar="PATH",
        help="Additional proto include path for protoc",
    )

    parser.add_argument(
        "--update",
        "-U",
        action="store_true",
        help="Update test snapshots/expectations",
    )

    return parser.parse_args()


def generate_moonbit_code(include_path: Optional[str] = None) -> None:
    """Generate MoonBit code from proto file."""
    logger.info("Generating MoonBit code from proto file...")

    for proto_file in READER_DIR.glob("*.proto"):
        protoc_cmd = build_protoc_command(
            proto_dir=READER_DIR,
            output_dir=READER_DIR,
            project_name=f"gen_{proto_file.name.split('.')[0]}",
            project_root=PROJECT_ROOT,
            proto_files=proto_file.name,
            include_path=include_path,
        )

        run_command(protoc_cmd, description="Generate MoonBit code from proto")
        update_lib_deps(PROJECT_ROOT, READER_DIR /
                        f"gen_{proto_file.name.split('.')[0]}")
        run_command(["moon", "fmt"], cwd=READER_DIR /
                    f"gen_{proto_file.name.split('.')[0]}")
        logger.info("MoonBit code generated successfully")


def build_go_binary(go_gen_cli_dir: Path, bin_dir: Path):
    """Build the Go binary for testing."""
    logger.info("Building Go binary...")

    # Ensure bin directory exists
    bin_dir.mkdir(parents=True, exist_ok=True)

    go_cmd = ["go", "run", "main.go", "p2_cases.go", "p3_cases.go", "-o", str(bin_dir)]

    run_command(go_cmd, cwd=go_gen_cli_dir, description="Build Go binary")
    logger.info("Go binary built successfully")


def run_reader_test(runner_dir: Path, update_mode: bool = False):
    """Run the actual reader test using moon test."""
    logger.info("Running reader test...")

    
    command = ["moon", "test"]
    if update_mode:
        command.append("--update")

    run_command(command, cwd=runner_dir,
                description="Run reader test")
    logger.info("Reader test passed")


def main():
    """Main function to orchestrate the reader test."""
    args = parse_arguments()

    logger.info("Starting MoonBit protobuf reader test")
    logger.info(f"Project root: {PROJECT_ROOT}")

    try:
        # Step 1: Build plugin
        build_plugin(PROJECT_ROOT)

        # Step 2: Generate MoonBit code
        generate_moonbit_code(args.include_path)

        # Step 3: Build Go binary
        build_go_binary(GO_GEN_CLI_DIR, BIN_DIR)

        # Step 4: Run the test
        run_reader_test(RUNNER_DIR, args.update)

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
