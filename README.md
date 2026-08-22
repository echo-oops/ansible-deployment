# Ansible Deployment

Учебный проект, демонстрирующий практическую автоматизацию развертывания приложения с помощью **Ansible**. Репозиторий содержит готовую структуру ролей и плейбуков, сценарии тестирования (Molecule / Testinfra), CI‑pipeline (GitHub Actions) и вспомогательные скрипты для локальной разработки и деплоя.

---

## Краткое описание проекта

**Цель:** показать, как организовать идемпотентный, тестируемый и воспроизводимый процесс подготовки серверов и развертывания приложения с минимальным вмешательством оператора.

**Что даёт проект сразу:**
- Набор Ansible ролей: `common`, `users`, `packages`, `nginx`, `application`, `firewall`, `monitoring`.  
- Playbooks: `setup.yml`, `deploy.yml`, `site.yml`, `rollback.yml`.  
- Inventory примеры для `staging` и `production`.  
- Тестирование ролей через Molecule и Testinfra.  
- CI workflow для lint → syntax → molecule → (опционально) deploy.  
- Утилиты в `scripts/helpers` для сборки артефакта, запуска playbook и работы с Vault.  
- Документация и демонстрационный план.

---

## Реализация — принципы и подход

**Ключевые принципы:**
- **Идемпотентность.** Все операции выполняются через встроенные модули Ansible (`user`, `package`, `git`, `template`, `systemd`, `file`, `authorized_key`) или снабжены условиями/`creates` для shell/command.  
- **Модульность.** Логика разбита на роли; каждая роль имеет `tasks`, `handlers`, `defaults`, `templates`, `meta`.  
- **Параметризация.** Значения по умолчанию в `roles/*/defaults`, окружения и переопределения в `group_vars` и `host_vars`.  
- **Тестируемость.** Molecule + Testinfra для интеграционных проверок ролей; CI запускает те же проверки.  
- **Безопасность.** Секреты шифруются через Ansible Vault; CI использует защищённые секреты (GitHub Secrets).

**Типичный workflow оператора:**
1. Настроить `inventory` и `group_vars`/`host_vars`.  
2. Запустить подготовку:
   ```bash
   ansible-playbook -i inventory/staging.yml playbooks/setup.yml

Запустить деплой:
ansible-playbook -i inventory/staging.yml playbooks/deploy.yml


Структура проекта

ansible-deployment/
├── .github/                 # CI workflows
├── inventory/               # staging.yml, production.yml
├── group_vars/              # all.yml, web.yml, app.yml
├── host_vars/               # host-specific vars
├── playbooks/               # site.yml, setup.yml, deploy.yml, rollback.yml
├── roles/                   # common, users, packages, nginx, application, firewall, monitoring
├── scripts/                 # helper scripts
│   └── helpers/
├── tests/                   # molecule scenarios and tests
├── docs/                    # architecture.md, demo-plan.md
├── ansible.cfg
├── requirements.yml
├── .ansible-lint
├── .gitignore
└── README.md


Ключевые директории и файлы

inventory/ — YAML inventory для staging и production; группы web, app, db.

group_vars/ — переменные для групп (all.yml, web.yml, app.yml). Секреты — в Vault.

host_vars/ — переменные для отдельных хостов (IP, специфичные настройки).

roles/ — роли с tasks, handlers, templates, defaults, meta.

playbooks/ — orchestration: site.yml вызывает setup и deploy; rollback.yml — откат.

scripts/helpers/ — утилиты: run-playbook.sh, build_artifact.sh, vault-decrypt.sh, check-env.sh, cleanup.sh.

tests/molecule/ — Molecule scenario для роли application и Testinfra тесты.

.github/workflows/ci.yml — CI pipeline.


Установка зависимостей

# 1. Клонировать репозиторий
git clone <repo-url>
cd ansible-deployment

# 2. Создать виртуальное окружение
python3 -m venv .venv
source .venv/bin/activate

# 3. Обновить pip и установить основные инструменты
python -m pip install --upgrade pip
pip install ansible ansible-lint yamllint

# 4. Для тестирования ролей (Molecule + Testinfra)
pip install "molecule[docker]" testinfra pytest


Вспомогательные скрипты
В scripts/helpers/ есть утилиты:

run-playbook.sh — обёртка для запуска ansible-playbook с поддержкой vault.

build_artifact.sh — упаковка приложения в tar.gz.

vault-decrypt.sh — безопасная работа с ansible-vault в CI.

check-env.sh — проверка наличия необходимых инструментов.

cleanup.sh — очистка артефактов и molecule окружений.