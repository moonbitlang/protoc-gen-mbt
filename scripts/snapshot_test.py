#!/usr/bin/env python3
import argparse
import subprocess
import sys
from pathlib import Path
from typing import List, Optional

from common import update_lib_deps
from workflow import ProjectConfig, CommandRunner, WorkflowExecutor
from logger import get_logger

logger = get_logger(__name__)

SCRIPT_DIR = Path(__file__).parent.absolute()
PROJECT_ROOT = SCRIPT_DIR.parent
TEST_PROTO_DIR = PROJECT_ROOT / "test" / "snapshots"


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Run snapshot tests for MoonBit protobuf generator",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                           Run snapshot tests (compare only)
  %(prog)s -I /opt/protobuf/include  Add extra protobuf include path
""",
    )
    parser.add_argument(
        "--include-path",
        "-I",
        metavar="PATH",
        help="Additional protoc include path",
    )
    return parser.parse_args()


def find_proto_directories() -> List[Path]:
    proto_dirs = sorted({p.parent for p in TEST_PROTO_DIR.rglob("*.proto")})
    if not proto_dirs:
        logger.error(f"No .proto files found in {TEST_PROTO_DIR}")
        sys.exit(1)
    return proto_dirs


def generate_code(executor: WorkflowExecutor, proto_dirs: List[Path], include_path: Optional[str]) -> None:
    for proto_dir in proto_dirs:
        proto_dir.mkdir(exist_ok=True)
        proto_files = [p.name for p in proto_dir.glob("*.proto")]
        if not proto_files:
            logger.error(f"No proto files found in {proto_dir}")
            sys.exit(1)

        for proto_file in proto_files:
            try:
                executor.run_protoc(
                    proto_dir,
                    proto_dir,
                    "__snapshot",
                    [proto_file],
                    include_path=include_path,
                )
                update_lib_deps(PROJECT_ROOT, proto_dir / "__snapshot")
            except Exception as e:
                logger.error(f"Failed for {proto_dir.name}/{proto_file}: {e}")
                sys.exit(1)
            try:
                executor.moon.check(proto_dir / "__snapshot")
            except Exception as e:
                logger.warning(f"moon check failed for {proto_dir.name}/{proto_file}: {e}")

    logger.info("Code generation completed")


def main():
    args = parse_arguments()

    logger.info(f"Working directory: {Path.cwd()}")
    logger.info(f"Script directory: {SCRIPT_DIR}")
    logger.info(f"Project root: {PROJECT_ROOT}")

    config = ProjectConfig(PROJECT_ROOT)
    runner = CommandRunner(logger)
    executor = WorkflowExecutor(config, runner)

    executor.build_plugin()

    proto_dirs = find_proto_directories()
    generate_code(executor, proto_dirs, args.include_path)

    try:
        git_diff = subprocess.run(
            ["git", "diff", "--name-only", "test/snapshots"],
            check=False,
            capture_output=True,
            text=True,
        )
        if git_diff.stdout.strip():
            logger.warning("Changes detected in snapshots via git diff:")
            for changed_file in git_diff.stdout.strip().split("\n"):
                logger.info(f"  - {changed_file}")
            logger.error("Snapshot test failed - differences detected")
            sys.exit(1)
        else:
            logger.info("All snapshots match")
    except subprocess.SubprocessError as e:
        logger.warning(f"Failed to run git diff: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
