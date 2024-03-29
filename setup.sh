

#!/bin/bash

#https://devopscube.com/install-configure-prometheus-linux/
#https://prometheus.io/download/

sudo apt-get update -y

wget https://github.com/prometheus/prometheus/releases/download/v2.51.0/prometheus-2.51.0.linux-amd64.tar.gz


tar -xvf prometheus-2.51.0.linux-amd64.tar.gz


mv prometheus-2.51.0.linux-amd64  prometheus-files


sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus


sudo cp prometheus-files/prometheus /usr/local/bin/
sudo cp prometheus-files/promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool


sudo cp -r prometheus-files/consoles /etc/prometheus
sudo cp -r prometheus-files/console_libraries /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries


sudo mkdir -p /etc/prometheus

# Create the Prometheus configuration file
sudo touch /etc/prometheus/prometheus.yml

echo "global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']" > /etc/prometheus/prometheus.yml



sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml



echo "[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
    --config.file /etc/prometheus/prometheus.yml \\
    --storage.tsdb.path /var/lib/prometheus/ \\
    --web.console.templates=/etc/prometheus/consoles \\
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/prometheus.service > /dev/null


sudo systemctl daemon-reload
sudo systemctl start prometheus

sudo systemctl status prometheus
