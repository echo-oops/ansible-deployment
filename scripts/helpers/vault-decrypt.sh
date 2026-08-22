#!/usr/bin/env bash
# Helper to edit or decrypt an Ansible Vault file in a safe way.
# Usage:
#   ./vault-decrypt.sh edit path/to/vault.yml
#   ./vault-decrypt.sh view path/to/vault.yml
#   ./vault-decrypt.sh decrypt path/to/vault.yml /tmp/plain.yml
#
# Behavior:
# - Uses ANSIBLE_VAULT_PASSWORD_FILE if provided
# - Otherwise uses ANSIBLE_VAULT_PASSWORD env var (temporary file)
# - For 'edit' opens ansible-vault edit
# - For 'view' prints decrypted content to stdout
# - For 'decrypt' writes decrypted content to specified output file (useful in CI)
#
# Security note: avoid leaving plaintext files on disk. Use in CI only with care.

set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 <action> <vault_file> [output_file]
Actions:
  edit    - open file with 'ansible-vault edit'
  view    - print decrypted content to stdout
  decrypt - write decrypted content to output_file (useful in CI)
Environment:
  ANSIBLE_VAULT_PASSWORD_FILE - path to vault password file (preferred)
  ANSIBLE_VAULT_PASSWORD      - vault password in env (less secure)
EOF
}

if [[ $# -lt 2 ]]; then
  usage
  exit 2
fi

ACTION="$1"
VAULT_FILE="$2"
OUT_FILE="${3:-}"

if [[ ! -f "$VAULT_FILE" ]]; then
  echo "Error: vault file '$VAULT_FILE' not found."
  exit 3
fi

ANSIBLE_VAULT_CMD="${ANSIBLE_VAULT_CMD:-ansible-vault}"

if ! command -v "$ANSIBLE_VAULT_CMD" >/dev/null 2>&1; then
  echo "Error: ansible-vault not found. Install Ansible."
  exit 4
fi

# Determine password file handling
VAULT_PW_ARG=()
tmp_pw_file=""
if [[ -n "${AN SIBLE_VAULT_PASSWORD_FILE:-}" ]]; then
  # note: guard against accidental variable name with space; prefer ANSIBLE_VAULT_PASSWORD_FILE
  :
fi

if [[ -n "${ANSIBLE_VAULT_PASSWORD_FILE:-}" ]]; then
  if [[ ! -f "$ANSIBLE_VAULT_PASSWORD_FILE" ]]; then
    echo "Error: ANSIBLE_VAULT_PASSWORD_FILE is set but file not found: $ANSIBLE_VAULT_PASSWORD_FILE"
    exit 5
  fi
  VAULT_PW_ARG=(--vault-password-file "$ANSIBLE_VAULT_PASSWORD_FILE")
elif [[ -n "${ANSIBLE_VAULT_PASSWORD:-}" ]]; then
  tmp_pw_file=$(mktemp)
  echo -n "$ANSIBLE_VAULT_PASSWORD" > "$tmp_pw_file"
  chmod 600 "$tmp_pw_file"
  VAULT_PW_ARG=(--vault-password-file "$tmp_pw_file")
  trap 'rm -f "$tmp_pw_file"' EXIT
else
  # no password provided; rely on interactive prompt
  VAULT_PW_ARG=()
fi

case "$ACTION" in
  edit)
    echo "Opening vault file for edit: $VAULT_FILE"
    "$ANSIBLE_VAULT_CMD" edit "${VAULT_PW_ARG[@]}" "$VAULT_FILE"
    ;;
  view)
    echo "Decrypting and printing: $VAULT_FILE"
    "$ANSIBLE_VAULT_CMD" view "${VAULT_PW_ARG[@]}" "$VAULT_FILE"
    ;;
  decrypt)
    if [[ -z "$OUT_FILE" ]]; then
      echo "Error: decrypt requires output file path."
      usage
      exit 6
    fi
    echo "Decrypting $VAULT_FILE -> $OUT_FILE"
    "$ANSIBLE_VAULT_CMD" view "${VAULT_PW_ARG[@]}" "$VAULT_FILE" > "$OUT_FILE"
    chmod 600 "$OUT_FILE"
    echo "Decrypted file written to $OUT_FILE (remove it after use!)"
    ;;
  *)
    echo "Unknown action: $ACTION"
    usage
    exit 7
    ;;
esac

exit 0
