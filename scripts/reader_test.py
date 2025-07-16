#!/usr/bin/env python3
"""
Reader test runner for MoonBit protobuf code generator.

This script tests the protobuf reader functionality by:
1. Generating MoonBit code from a proto file
2. Building and running test binaries
3. Verifying the generated code works correctly
"""

import argparse
import json
import shutil
import sys
from pathlib import Path
from typing import Optional

# Import common functions
from common import (
    verify_tool, build_plugin,
    build_protoc_command, run_command
)

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
        """
    )

    parser.add_argument(
        "--include-path", "-I",
        metavar="PATH",
        help="Additional proto include path for protoc"
    )

    return parser.parse_args()


def verify_required_tools():
    """Verify that all required tools are available."""
    tools = [
        ("protoc", "--version"),
        ("moon", "version"),
        ("go", "version")
    ]

    print("Verifying required tools...")
    for tool, version_flag in tools:
        if not verify_tool(tool, version_flag):
            sys.exit(1)

    print("All required tools are available")


def generate_moonbit_code(include_path: Optional[str] = None):
    """Generate MoonBit code from proto file."""
    print("Generating MoonBit code from proto file...")

    # Build and execute protoc command
    protoc_cmd = build_protoc_command(
        proto_dir=READER_DIR,
        output_dir=READER_DIR,
        project_name="gen",
        project_root=PROJECT_ROOT,
        proto_files="input.proto",
        include_path=include_path
    )

    run_command(protoc_cmd, description="Generate MoonBit code from proto")
    print("MoonBit code generated successfully")


def fix_generated_deps():
    """Fix the deps path in the generated moon.mod.json file."""
    gen_mod_json = READER_DIR / "gen" / "moon.mod.json"

    print("Fixing deps path in generated moon.mod.json...")

    if not gen_mod_json.exists():
        print(f"Generated module file not found: {gen_mod_json}")
        sys.exit(1)

    # Try to use jq if available, otherwise create the file manually
    try:
        # Read the existing JSON file
        with open(gen_mod_json, 'r') as f:
            module_config = json.load(f)

        # Update the deps section
        module_config['deps']["moonbit-community/protobuf/lib"] = {
            "path": "../../../lib"
        }

        # Write the updated JSON back to the file
        with open(gen_mod_json, 'w') as f:
            json.dump(module_config, f, indent=2)

        print("Updated deps path in moon.mod.json")

    except (FileNotFoundError):
        print("File not available, creating moon.mod.json manually...")

        module_config = {
            "name": "username/gen",
            "version": "0.1.0",
            "readme": "",
            "repository": "",
            "license": "",
            "keywords": [],
            "description": "",
            "source": "src",
            "deps": {
                "moonbit-community/protobuf/lib": {
                    "path": "../../../lib"
                }
            }
        }

        with open(gen_mod_json, 'w') as f:
            json.dump(module_config, f, indent=2)

        print("Created moon.mod.json manually")


def build_go_binary(go_gen_cli_dir: Path, bin_dir: Path):
    """Build the Go binary for testing."""
    print("Building Go binary...")

    # Ensure bin directory exists
    bin_dir.mkdir(parents=True, exist_ok=True)

    go_cmd = [
        "go", "run", "main.go",
        "-o", str(bin_dir)
    ]

    run_command(go_cmd, cwd=go_gen_cli_dir, description="Build Go binary")
    print("Go binary built successfully")


def run_reader_test(runner_dir: Path):
    """Run the actual reader test using moon test."""
    print("Running reader test...")

    run_command(
        ["moon", "test"],
        cwd=runner_dir,
        description="Run reader test"
    )
    print("Reader test passed")


def cleanup_generated_files(reader_dir: Path, bin_dir: Path):
    """Clean up generated files and directories."""
    print("Cleaning up generated files...")

    cleanup_dirs = [
        reader_dir / "gen",
        bin_dir
    ]

    for dir_path in cleanup_dirs:
        if dir_path.exists():
            shutil.rmtree(dir_path)
            print(f"Removed {dir_path}")


def main():
    """Main function to orchestrate the reader test."""
    args = parse_arguments()

    print("Starting MoonBit protobuf reader test")
    print(f"Project root: {PROJECT_ROOT}")

    try:
        # Step 1: Verify tools
        verify_required_tools()

        # Step 2: Build plugin
        build_plugin(PROJECT_ROOT)

        # Step 3: Generate MoonBit code
        generate_moonbit_code(args.include_path)

        # Step 4: Fix deps path
        fix_generated_deps()

        # Step 5: Build Go binary
        build_go_binary(GO_GEN_CLI_DIR, BIN_DIR)

        # Step 6: Run the test
        run_reader_test(RUNNER_DIR)

        # Step 7: Clean up
        cleanup_generated_files(READER_DIR, BIN_DIR)

        print("Reader test completed successfully!")

    except KeyboardInterrupt:
        print("\nTest interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
