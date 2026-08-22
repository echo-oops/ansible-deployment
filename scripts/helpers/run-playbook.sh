#!/usr/bin/env bash
# Wrapper to run ansible-playbook with common checks and options
# Usage examples:
#   ./run-playbook.sh -i inventory/staging.yml playbooks/site.yml
#   ./run-playbook.sh --vault-password-file /path/to/vault pass playbooks/deploy.yml -i inventory/production.yml --tags nginx
#
# Features:
# - checks for ansible-playbook binary
# - ensures inventory exists (if provided)
# - supports passing vault password file or using ANSIBLE_VAULT_PASSWORD env
# - prints final command before execution
# - exits with ansible-playbook exit code

set -euo pipefail

ANSIBLE_PLAYBOOK_BIN="${ANSIBLE_PLAYBOOK_BIN:-ansible-playbook}"
VAULT_PW_FILE=""
INVENTORY=""
EXTRA_ARGS=()

usage() {
  cat <<EOF
Usage: $0 [--vault-password-file FILE] [-i INVENTORY] [--] ansible-playbook-args...
Examples:
  $0 -i inventory/staging.yml playbooks/site.yml
  $0 --vault-password-file /tmp/vault.pass -i inventory/production.yml playbooks/deploy.yml --tags nginx
EOF
}

# parse simple options until first non-option (playbook path)
while [[ $# -gt 0 ]]; do
  case "$1" in
    --vault-password-file)
      VAULT_PW_FILE="$2"; shift 2;;
    -i|--inventory)
      INVENTORY="$2"; shift 2;;
    --help)
      usage; exit 0;;
    --)
      shift; EXTRA_ARGS+=("$@"); break;;
    *)
      EXTRA_ARGS+=("$1"); shift;;
  esac
done

if ! command -v "$ANSIBLE_PLAYBOOK_BIN" >/dev/null 2>&1; then
  echo "Error: ansible-playbook not found. Install Ansible first."
  exit 10
fi

if [[ -n "$INVENTORY" && ! -f "$INVENTORY" ]]; then
  echo "Warning: inventory file '$INVENTORY' not found."
  # do not exit — allow dynamic inventory or other usage, but warn
fi

CMD=("$ANSIBLE_PLAYBOOK_BIN")
if [[ -n "$INVENTORY" ]]; then
  CMD+=("-i" "$INVENTORY")
fi

# Vault handling: prefer explicit file, else ANSIBLE_VAULT_PASSWORD env
if [[ -n "$VAULT_PW_FILE" ]]; then
  if [[ ! -f "$VAULT_PW_FILE" ]]; then
    echo "Error: vault password file '$VAULT_PW_FILE' not found."
    exit 11
  fi
  CMD+=("--vault-password-file" "$VAULT_PW_FILE")
elif [[ -n "${ANSIBLE_VAULT_PASSWORD:-}" ]]; then
  # create a temporary file with the password to pass to ansible-playbook
  tmp_vault_file=$(mktemp)
  echo -n "$ANSIBLE_VAULT_PASSWORD" > "$tmp_vault_file"
  chmod 600 "$tmp_vault_file"
  CMD+=("--vault-password-file" "$tmp_vault_file")
  # ensure cleanup
  trap 'rm -f "$tmp_vault_file"' EXIT
fi

# append remaining args (playbook path, extra-vars, tags, etc.)
CMD+=("${EXTRA_ARGS[@]}")

echo "Running: ${CMD[*]}"
# run and capture exit code
"${CMD[@]}"
rc=$?

if [[ ${rc} -ne 0 ]]; then
  echo "ansible-playbook exited with code ${rc}"
else
  echo "ansible-playbook completed successfully"
fi

exit ${rc}
