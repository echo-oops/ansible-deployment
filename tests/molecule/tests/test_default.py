import os
import socket
import pytest
import testinfra.utils.ansible_runner

# Получаем инвентори от Molecule
testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ.get('MOLECULE_INVENTORY_FILE')).get_hosts('all')


def test_app_service_running_and_enabled(host):
    """
    Проверяем, что systemd-сервис приложения существует, запущен и включён.
    Имя сервиса берём из переменной systemd_unit.name или application.name.
    """
    svc_name = host.ansible("debug", "msg={{ systemd_unit.name | default(application.name) }}")['msg']
    service = host.service(svc_name)
    assert service.is_enabled, "Service is not enabled"
    assert service.is_running, "Service is not running"


def test_app_port_listening(host):
    """
    Проверяем, что приложение слушает ожидаемый порт (application.port).
    """
    port = int(host.ansible("debug", "msg={{ application.port | default(8080) }}")['msg'])
    socket = host.socket("tcp://127.0.0.1:{}".format(port))
    assert socket.is_listening, "Application port {} is not listening".format(port)


def test_health_endpoint(host):
    """
    Проверяем HTTP health endpoint через localhost.
    """
    port = int(host.ansible("debug", "msg={{ application.port | default(8080) }}")['msg'])
    cmd = host.run("curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:{}/health".format(port))
    assert cmd.rc == 0
    assert cmd.stdout.strip() == "200"
