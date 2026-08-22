# Архитектура проекта "Ansible Deployment"

## Краткое описание
Документ описывает архитектуру учебного проекта по автоматизации развертывания с использованием Ansible. Цель — показать, как организовать репозиторий, inventory, playbooks и роли, как взаимодействуют компоненты и как обеспечивается идемпотентность и тестируемость.

## Компоненты системы
1. **Git репозиторий**
   - Хранит исходники playbook'ов, ролей, inventory, документацию и CI-конфигурацию.
   - Источник правды для развертывания и тестов.

2. **CI/CD (GitHub Actions)**
   - Запускает линтеры, синтаксические проверки, Molecule‑тесты и (опционально) деплой в staging.
   - Использует секреты (SSH ключи, ansible-vault password) из GitHub Secrets.

3. **Ansible Controller (runner)**
   - Машина/контейнер, откуда запускаются playbook'и (локально или в CI).
   - Имеет доступ к inventory и ключам для SSH.

4. **Inventory**
   - Статический YAML (inventory/staging.yml, inventory/production.yml).
   - Группирует хосты по ролям: web, app, db.
   - Содержит переменные подключения (ansible_user, ansible_host, ansible_port).

5. **Roles**
   - Набор ролей: common, users, packages, nginx, application, firewall, monitoring.
   - Каждая роль идемпотентна и имеет структуру tasks/ handlers/ templates/ defaults/ vars/ meta/.

6. **Тестовая среда**
   - Molecule + Docker/Podman для локального тестирования ролей.
   - Testinfra для проверки состояния после converge.

7. **Секреты**
   - Ansible Vault для шифрования секретов в репозитории.
   - CI хранит пароль Vault и SSH ключи в защищённых переменных.

## Взаимодействие компонентов (схема)
Developer
│
▼
Git (repo)
│
▼
CI/CD (GitHub Actions)
│
├─ Lint (yamllint, ansible-lint)
├─ Syntax check (ansible-playbook --syntax-check)
├─ Molecule tests (molecule test)
└─ Deploy job (manual/protected)
│
▼
Ansible Controller (runner)
│
▼
Inventory (staging/production)
│
▼
Ansible Roles (common, users, packages, app, nginx)
│
┌──────┼──────┐
▼      ▼      ▼
web1   app1   db1



## Порядок выполнения ролей (рекомендация)
1. **common** — базовая подготовка ОС (timezone, ntp, sysctl, базовые пакеты).
2. **users** — создание пользователей и SSH ключей.
3. **packages** — установка системных пакетов и зависимостей.
4. **firewall** — базовая настройка firewall (открыть нужные порты).
5. **application** — клонирование кода, установка зависимостей приложения, systemd unit.
6. **nginx** — установка и конфигурация reverse proxy (если требуется).
7. **monitoring** — установка простых healthchecks/экспортеров.

> Примечание: порядок можно адаптировать под конкретный сценарий. Роли должны быть независимыми по возможности, зависимости указывать в meta/main.yml.

## Inventory и переменные
- **inventory/** содержит `staging.yml` и `production.yml`.
- **group_vars/** содержит `all.yml`, `web.yml`, `app.yml` с переменными окружения, путями, версиями приложения.
- **host_vars/** — для специфичных хостов (опционально).
- Секреты (пароли, ключи) — в зашифрованных файлах Vault, например `group_vars/production/vault.yml`.

## Идемпотентность и проверка состояния
- Использовать встроенные модули Ansible (`user`, `package`, `service`, `template`, `file`).
- Избегать `shell`/`command` без `creates`/`removes`/`changed_when`.
- Шаблоны (`template`) + `notify` handlers для перезапуска сервисов только при изменении.
- Для проверки результата использовать:
  - `ansible -m ping`
  - `ansible -m shell -a 'systemctl is-active myapp'`
  - Testinfra в Molecule для автоматических проверок.

## Тестирование
- **Lint**: yamllint, ansible-lint.
- **Syntax**: `ansible-playbook --syntax-check`.
- **Molecule**: сценарии create → converge → verify → destroy.
- **Testinfra**: проверки сервисов, файлов, портов.
- **Идемпотентность**: запуск converge дважды — второй проход должен показывать 0 изменений.

## CI/CD (кратко)
- Workflow: push/PR → lint → syntax → molecule → (manual deploy to staging).
- Для деплоя использовать self-hosted runner или защищённый job с доступом к SSH ключам.
- В CI хранить ANSIBLE_VAULT_PASSWORD и SSH_PRIVATE_KEY в secrets.

## Примеры команд
- Проверка inventory:
 - Запуск полного плейбука:
ansible-playbook -i inventory/staging.yml playbooks/site.yml

- Локальное тестирование роли:
cd roles/application
molecule test


## Замечания по расширению
- Поддержка нескольких дистрибутивов: добавить условные задачи в роли (when: ansible_os_family == 'Debian').
- Динамический inventory: интеграция с облачными провайдерами (AWS, GCP).
- Интеграция с AWX/Tower для управления запуском playbook'ов.

