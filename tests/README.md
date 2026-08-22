# tests

Папка с тестами для ролей Ansible.

Содержит:
- Molecule scenario для роли `application` (Docker driver).
- Testinfra тесты для проверки состояния сервиса и порта.
- Пример конфигурации ansible-lint в tests/lint/ansible-lint.yml.

Как запускать локально (предполагается, что установлены: docker, molecule, ansible, pytest, testinfra):
1. Убедитесь, что Docker запущен.
2. Перейдите в папку с molecule сценарием:
   cd tests/molecule
3. Запустите тесты:
   molecule test -s default
   или
   molecule converge -s default
   molecule verify -s default
   molecule destroy -s default

Примечания:
- Сценарий использует образ с предустановленным Ansible для упрощения.
- Если CI запускает Molecule, убедитесь, что runner имеет доступ к Docker (self-hosted runner или DinD).
- При необходимости адаптируйте `molecule.yml` под локальные ограничения (proxy, сеть).
