#!/usr/bin/env python3
import os
from pathlib import Path


def moon_work_env(work_file: Path) -> dict[str, str]:
    env = os.environ.copy()
    env["MOON_WORK"] = str(work_file.resolve())
    return env
