#!/usr/bin/env python3
import json
import os
import sys
import tomllib
from pathlib import Path
from logger import get_logger

logger = get_logger(__name__)


def moon_work_env(work_file: Path) -> dict[str, str]:
    env = os.environ.copy()
    env["MOON_WORK"] = str(work_file.resolve())
    return env


def update_lib_deps(project_root: Path, gen_mod_json_dir: Path) -> None:
    gen_mod_json = gen_mod_json_dir / "moon.mod.json"
    logger.info("Fixing protobuf dependency in generated moon.mod.json...")

    if not gen_mod_json.exists():
        logger.error(f"Generated module file not found: {gen_mod_json}")
        sys.exit(1)

    with open(gen_mod_json, "r") as f:
        module_config = json.load(f)

    with open(project_root / "lib" / "moon.mod", "rb") as f:
        lib_config = tomllib.load(f)

    module_config["deps"]["moonbitlang/protobuf"] = lib_config["version"]

    with open(gen_mod_json, "w") as f:
        json.dump(module_config, f, indent=2)

    logger.info(f"Updated protobuf dependency in {gen_mod_json_dir}")
