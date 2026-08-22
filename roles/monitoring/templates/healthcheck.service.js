[Unit]
Description=Simple monitoring healthcheck service
After=network.target

[Service]
Type=simple
ExecStart=/opt/monitoring/healthcheck.sh
Restart=on-failure
User=root
