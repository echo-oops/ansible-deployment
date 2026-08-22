#!/usr/bin/env bash
# Simple artifact builder for a Python (Flask) app
# Usage:
#   ./build_artifact.sh --src /path/to/source --out /path/to/dist --name myapp.tar.gz
#
# This script:
# - validates inputs
# - creates a tar.gz archive of the application source (excluding virtualenv, .git, node_modules)
# - writes artifact to the output directory
#
# Designed for local use on controller before deploying with Ansible.

set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 --src SRC_DIR --out OUT_DIR [--name ARTIFACT_NAME]
Options:
  --src     Path to application source directory (required)
  --out     Path to output directory where artifact will be placed (required)
  --name    Artifact filename (default: app-<timestamp>.tar.gz)
  --help    Show this help
EOF
}

SRC_DIR=""
OUT_DIR=""
ART_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --src) SRC_DIR="$2"; shift 2;;
    --out) OUT_DIR="$2"; shift 2;;
    --name) ART_NAME="$2"; shift 2;;
    --help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 2;;
  esac
done

if [[ -z "$SRC_DIR" || -z "$OUT_DIR" ]]; then
  echo "Error: --src and --out are required."
  usage
  exit 2
fi

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Error: source directory '$SRC_DIR' does not exist."
  exit 3
fi

mkdir -p "$OUT_DIR"

timestamp=$(date +%Y%m%d%H%M%S)
if [[ -z "$ART_NAME" ]]; then
  ART_NAME="app-${timestamp}.tar.gz"
fi

ART_PATH="${OUT_DIR%/}/${ART_NAME}"

echo "Building artifact from '$SRC_DIR' -> '$ART_PATH'"

# Create a temporary directory for packaging to avoid including unwanted files
tmpdir=$(mktemp -d)
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

# Copy source to temp, excluding common unwanted dirs
rsync -a --delete \
  --exclude='.git' \
  --exclude='venv' \
  --exclude='env' \
  --exclude='node_modules' \
  --exclude='dist' \
  --exclude='*.pyc' \
  --exclude='__pycache__' \
  "$SRC_DIR"/ "$tmpdir"/

# Create tar.gz
tar -C "$tmpdir" -czf "$ART_PATH" .

echo "Artifact created: $ART_PATH"
ls -lh "$ART_PATH"
exit 0
