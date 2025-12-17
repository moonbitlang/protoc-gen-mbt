#!/usr/bin/env python3
import json
import sys
from pathlib import Path
from logger import get_logger

logger = get_logger(__name__)


def update_lib_deps(project_root: Path, gen_mod_json_dir: Path) -> None:
    gen_mod_json = gen_mod_json_dir / "moon.mod.json"
    logger.info("Fixing deps path in generated moon.mod.json...")

    if not gen_mod_json.exists():
        logger.error(f"Generated module file not found: {gen_mod_json}")
        sys.exit(1)

    with open(gen_mod_json, "r") as f:
        module_config = json.load(f)

    relative_path = (
        (project_root / "lib").relative_to(gen_mod_json_dir, walk_up=True).as_posix()
    )
    module_config["deps"]["moonbitlang/protobuf"] = {"path": relative_path}

    with open(gen_mod_json, "w") as f:
        json.dump(module_config, f, indent=2)

    logger.info(f"Updated deps path in {gen_mod_json_dir}")
