#!/usr/bin/env bash
# Cleanup helper for local development and molecule tests
# Usage:
#   ./cleanup.sh [--molecule] [--artifacts DIR]
#
# Options:
#   --molecule    Run 'molecule destroy' in roles that have molecule scenarios (if molecule installed)
#   --artifacts   Path to artifacts directory to remove (default: ./dist)
#
# WARNING: This script deletes files/directories. Review before running.

set -euo pipefail

DO_MOLECULE=false
ARTIFACTS_DIR="./dist"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --molecule) DO_MOLECULE=true; shift;;
    --artifacts) ARTIFACTS_DIR="$2"; shift 2;;
    --help) echo "Usage: $0 [--molecule] [--artifacts DIR]"; exit 0;;
    *) echo "Unknown arg: $1"; exit 2;;
  esac
done

echo "Cleanup started."

if [[ "$DO_MOLECULE" = true ]]; then
  if command -v molecule >/dev/null 2>&1; then
    echo "Running molecule destroy in roles/* (if scenarios exist)..."
    for role in ../roles/*; do
      if [[ -d "$role/molecule" ]]; then
        echo "Destroying molecule for role: $(basename "$role")"
        (cd "$role" && molecule destroy) || echo "molecule destroy failed for $(basename "$role")"
      fi
    done
  else
    echo "molecule not installed; skipping molecule destroy."
  fi
fi

if [[ -d "$ARTIFACTS_DIR" ]]; then
  echo "Removing artifacts directory: $ARTIFACTS_DIR"
  rm -rf "$ARTIFACTS_DIR"
else
  echo "Artifacts directory not found: $ARTIFACTS_DIR"
fi

echo "Cleanup completed."
exit 0
