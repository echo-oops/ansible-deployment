# Ansible Deployment — учебный проект

Кратко: репозиторий демонстрирует автоматизацию развертывания приложения с помощью Ansible, включает роли, playbooks, тесты (Molecule/Testinfra) и CI (GitHub Actions).

## Структура репозитория (основное)
ansible-deployment/
├── .github/
├── inventory/
├── group_vars/
├── host_vars/
├── playbooks/
├── roles/
├── scripts/
├── tests/
├── docs/
├── ansible.cfg
├── requirements.yml
├── .ansible-lint
├── .gitignore
└── README.md



## Быстрый старт (локально)
1. Клонируйте репозиторий:
   ```bash
   git clone <repo-url>
   cd ansible-deployment


Установите зависимости (рекомендуется виртуальное окружение):

python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install ansible ansible-lint yamllint
# Для тестов:
pip install "molecule[docker]" testinfra pytest


Установите коллекции/роли из requirements.yml (опционально):

ansible-galaxy collection install -r requirements.yml
ansible-galaxy role install -r requirements.yml

Проверка inventory:


GitHub Actions workflow находится в .github/workflows/ci.yml. Pipeline выполняет:

yamllint, ansible-lint

ansible syntax-check

molecule tests (для роли application)

опциональный deploy job (manual / protected)

Секреты и Vault
Не храните пароли и приватные ключи в репозитории.

Используйте ansible-vault для шифрования секретов:
ansible-vault create group_vars/production/vault.yml
