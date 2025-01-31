#!/usr/bin/env python

# Default build file used
import os
import platform
import sys
import logging
import subprocess
import time
import shutil
import traceback

EXAMPLE_SRC_LOCATION = "example/main.dart"
EXAMPLE_TARGET = "exe"

# ephemeral stuffs
logger = logging.getLogger("BigDouble_PyBuilder")


def __run_cmd__(
    name: str,
    curr_dir: str,
    invokes: list[str],
    std_err: int = subprocess.STDOUT,
    std_out: int = subprocess.PIPE,
) -> int:
    logger.info(f"{name} @@ {curr_dir}")
    start_build_time: float = time.time()
    logger.info(f"{name} invoked at {time.ctime(start_build_time)}")
    build_context: subprocess.CompletedProcess[str] = subprocess.run(
        invokes,
        cwd=os.path.join(os.getcwd(), curr_dir),
        stderr=std_err,
        stdout=std_out,
        text=True,
    )
    # might need to finish some encoding issues with the output
    logger.info(
        f"{name} @@ TOOK: {time.time()-start_build_time} {curr_dir}\nOUTPUT [{build_context.returncode}]\n{build_context.stdout}"
    )
    return build_context.returncode


if __name__ == "__main__":
    start_build_time = time.time()
    formatter = logging.Formatter(
        "%(asctime)s | %(name)s | %(levelname)s $ %(message)s"
    )
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.DEBUG)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    logger.setLevel(logging.DEBUG)
    logger.info(f"Started at {start_build_time}")
    __run_cmd__(
        "DART_BUILD",
        ".",
        invokes=["dart.bat", "compile", EXAMPLE_TARGET, EXAMPLE_SRC_LOCATION],
    )
    logger.info(f"Build artifact located next to {EXAMPLE_SRC_LOCATION}")
    logger.info(f"Finished building in {time.time() - start_build_time}")
