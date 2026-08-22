#!/usr/bin/env bash
# Check required tools for development and testing
# Usage: ./check-env.sh
# Checks: ansible, ansible-playbook, molecule, docker, python3, pip, ansible-lint, yamllint

set -euo pipefail

REQUIRED_CMDS=(ansible ansible-playbook python3 pip3)
OPTIONAL_CMDS=(molecule docker ansible-lint yamllint)

echo "Checking required commands..."
missing=0
for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "  MISSING: $cmd"
    missing=$((missing+1))
  else
    echo "  OK: $cmd -> $(command -v $cmd)"
  fi
done

echo
echo "Checking optional commands (recommended)..."
for cmd in "${OPTIONAL_CMDS[@]}"; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "  Not found: $cmd (recommended)"
  else
    echo "  OK: $cmd -> $(command -v $cmd)"
  fi
done

if [[ $missing -gt 0 ]]; then
  echo
  echo "One or more required commands are missing. Please install them before proceeding."
  echo "Example (Debian/Ubuntu):"
  echo "  sudo apt update && sudo apt install -y python3 python3-pip"
  echo "  python3 -m pip install --user ansible"
  exit 10
fi

echo
echo "Environment looks OK."
exit 0
