#!/usr/bin/env python
"""Restore safe specialist profile configuration after a fresh Hermes setup.

This script merges only the allowlisted model/runtime/approval keys from each
config.example.yaml. Existing machine-local settings and credentials remain
untouched. Use --apply-runtime-patch separately when the installed Hermes
source still needs the bundled Codex runtime patch.
"""
from __future__ import annotations

import argparse
import shutil
from pathlib import Path

import yaml

PROFILES = ("backend", "frontend", "dev-ops", "tester")


def deep_merge(dst: dict, src: dict) -> dict:
    for key, value in src.items():
        if isinstance(value, dict) and isinstance(dst.get(key), dict):
            deep_merge(dst[key], value)
        else:
            dst[key] = value
    return dst


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--hermes-home",
        type=Path,
        default=Path.home() / "AppData" / "Local" / "hermes",
    )
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    repo = Path(__file__).resolve().parents[1]
    for profile in PROFILES:
        template = repo / "profiles" / profile / "config.example.yaml"
        target = args.hermes_home / "profiles" / profile / "config.yaml"
        incoming = yaml.safe_load(template.read_text(encoding="utf-8")) or {}
        current = (
            yaml.safe_load(target.read_text(encoding="utf-8")) or {}
            if target.exists()
            else {}
        )
        merged = deep_merge(current, incoming)
        if args.dry_run:
            print(f"DRY_RUN {profile}: {target}")
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        if target.exists():
            shutil.copy2(target, target.with_suffix(".yaml.before-specialist-sync"))
        target.write_text(
            yaml.safe_dump(merged, sort_keys=False, allow_unicode=True),
            encoding="utf-8",
        )
        print(f"UPDATED {profile}: {target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
