# Import common functions
import json
import os
from pathlib import Path
import subprocess
import sys
from typing import Any
from common import build_plugin, build_protoc_command, run_command, update_lib_deps

from logger import get_logger

logger = get_logger(__name__)


SCRIPT_DIR = Path(__file__).parent.absolute()
PROJECT_ROOT = SCRIPT_DIR.parent
PLUGIN_PROTO_DIR = PROJECT_ROOT / "plugin"
PLUGIN_OUT_DIR = PROJECT_ROOT


def main():
    logger.info(f"Working directory: {Path.cwd()}")
    logger.info(f"Script directory: {SCRIPT_DIR}")
    logger.info(f"Project root: {PROJECT_ROOT}")

    # 构建插件
    build_plugin(PROJECT_ROOT)

    # 切换到项目根目录
    os.chdir(PROJECT_ROOT)

    # 查找plugin.proto文件
    proto_file = PLUGIN_PROTO_DIR / "plugin.proto"
    if not proto_file.exists():
        logger.error(f"plugin.proto not found: {proto_file}")
        sys.exit(1)

    # 生成代码
    cmd = build_protoc_command(
        PLUGIN_PROTO_DIR,
        PLUGIN_OUT_DIR,
        "plugin",
        PROJECT_ROOT,
        [proto_file.name, "google/protobuf/descriptor.proto"],
        username="moonbit-community",
    )

    logger.info(f"Running protoc command: {' '.join(cmd)}")
    try:
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        update_lib_deps(PROJECT_ROOT, PLUGIN_PROTO_DIR)

        json_model: Any = {}
        with open(PLUGIN_PROTO_DIR / "moon.mod.json", "r") as f:
            json_model = json.load(f)
        json_model["deps"]["tonyfettes/uv"] = "0.10.1"
        with open(PLUGIN_PROTO_DIR / "moon.mod.json", "w") as f:
            json.dump(json_model, f, indent=2)


        pkg_json_path = PLUGIN_PROTO_DIR.joinpath("src", "google", "protobuf", "compiler", "moon.pkg.json")
        with open(pkg_json_path, "r") as f:
            json_model = json.load(f)
        import_list = [
            "tonyfettes/uv/async",
            "tonyfettes/encoding",
        ]
        
        json_model["test-import"] = import_list
        json_model["targets"] = {
            "top_test.mbt": ["native"]
        }
        with open(pkg_json_path, "w") as f:
            json.dump(json_model, f, indent=2)


        if result.stdout:
            logger.info(f"protoc stdout: {result.stdout}")
        if result.stderr:
            logger.info(f"protoc stderr: {result.stderr}")

        run_command(
            cmd=["moon", "check", "-C", PLUGIN_PROTO_DIR.as_posix(), "--target", "native,all"],
        )
        run_command(
            cmd=["moon", "test", "-C", PLUGIN_PROTO_DIR.as_posix(), "--target", "native"],
        )
        run_command(
            cmd=["moon", "fmt", "-C", PLUGIN_PROTO_DIR.as_posix()],
        )
        run_command(
            cmd=["moon", "info", "-C", PLUGIN_PROTO_DIR.as_posix(), "--target", "native"],
        )
    except subprocess.CalledProcessError as e:
        logger.error(f"Protoc failed: {e}")
        if e.stdout:
            logger.error(f"stdout: {e.stdout}")
        if e.stderr:
            logger.error(f"stderr: {e.stderr}")
        sys.exit(1)

    logger.info("Plugin code generation completed.")


if __name__ == "__main__":
    main()
