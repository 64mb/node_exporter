#!/bin/bash

HOSTNAME=$1

hostnamectl set-hostname $HOSTNAME

useradd --no-create-home --shell /bin/false node_exporter

mkdir -p /tmp/node_exporter

if [ ! -f "/usr/local/bin/node_exporter" ]; then
    cd /tmp/node_exporter && wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
    cd /tmp/node_exporter && tar xvf node_exporter-1.0.1.linux-amd64.tar.gz
    cp /tmp/node_exporter/node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin
    chmod +x /usr/local/bin/node_exporter
    chown node_exporter:node_exporter /usr/local/bin/node_exporter
fi

systemctl stop node_exporter.service

mkdir -p /etc/node_exporter
mv /tmp/node_exporter/web.yml /etc/node_exporter/
# mv /tmp/node_exporter/ca.pem /etc/node_exporter/
# mv /tmp/node_exporter/server-cert.pem /etc/node_exporter/
# mv /tmp/node_exporter/server-key.pem /etc/node_exporter/

chown -R node_exporter:node_exporter /etc/node_exporter/
cp /tmp/node_exporter/node_exporter.service /etc/systemd/system/node_exporter.service

systemctl daemon-reload

systemctl start node_exporter.service
systemctl enable node_exporter.service

rm -rf /tmp/node_exporter
