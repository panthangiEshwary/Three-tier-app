#!/bin/bash
set -e

cd /opt/monitoring

echo "================================="
echo " Updating system & installing Docker"
echo "================================="

apt update -y
apt install -y docker.io docker-compose

systemctl enable --now docker

echo "================================="
echo " Detecting server IPs"
echo "================================="

PUBLIC_IP=$(curl -s ifconfig.me)
PRIVATE_IP=$(hostname -I | awk '{print $1}')    # Local EC2/VPC IP

echo "Public IP:  $PUBLIC_IP"
echo "Private IP: $PRIVATE_IP"

echo "================================="
echo " Creating .env file for Prometheus, Alertmanager & Node Exporter"
echo "================================="

cat <<EOF > .env
APP_IP=$PRIVATE_IP
NODE_EXPORTER_IP=$PRIVATE_IP
N8N_IP=$PUBLIC_IP
EOF

echo ".env file created:"
cat .env

echo "================================="
echo " Injecting N8N_IP into alertmanager.yml"
echo "================================="

sed -i "s|\${N8N_IP}|$PUBLIC_IP|g" alertmanager.yml

echo "================================="
echo " Injecting APP_IP & NODE_EXPORTER_IP into prometheus.yml"
echo "================================="

sed -i "s|\${APP_IP}|$PRIVATE_IP|g" prometheus.yml
sed -i "s|\${NODE_EXPORTER_IP}|$PRIVATE_IP|g" prometheus.yml

echo "================================="
echo " Starting Docker Compose"
echo "================================="

docker-compose down
docker-compose up -d --build

echo "================================="
echo " Monitoring Stack Running"
echo "================================="

echo "Prometheus:     http://$(curl -s ifconfig.me):9090"
echo "Alertmanager:   http://$(curl -s ifconfig.me):9093"
echo "Grafana:        http://$(curl -s ifconfig.me):3000"
echo "n8n:            http://$(curl -s ifconfig.me):5678"
