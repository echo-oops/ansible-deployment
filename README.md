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


Вспомогательные скрипты
В scripts/helpers/ есть утилиты:

run-playbook.sh — обёртка для запуска ansible-playbook с поддержкой vault.

build_artifact.sh — упаковка приложения в tar.gz.

vault-decrypt.sh — безопасная работа с ansible-vault в CI.

check-env.sh — проверка наличия необходимых инструментов.

cleanup.sh — очистка артефактов и molecule окружений.
