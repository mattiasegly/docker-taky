#!/bin/bash

echo "Checking if config exists..."
if [ ! -f /taky/taky.conf ]; then
echo "No config found..."

echo "Checking TAKY_MODE variable..."
if [ ! $TAKY_MODE = cot ]; then
echo "Only TAKY_MODE=cot is allowed to create config to prevent duplicates and conflicts..."

else
echo "Checking if variables exists..."
if [ -z "$TAKY_FQDN" ] || [ -z "$TAKY_IP" ]; then
echo "Missing variables TAKY_FQDN or TAKY_IP, set environment variables and restart..."

else
echo "Creating config, CA and certs..."
takyctl setup --host $TAKY_FQDN --public-ip $TAKY_IP --p12_pw ClearTextFTW --user taky /tmp/taky #because taky won't create files in a folder that exists
mv /tmp/taky/* /taky

cat > /taky/taky.conf << EOF
[taky]
hostname = $TAKY_FQDN
node_id = TAKY
bind_ip = 0.0.0.0
public_ip = $TAKY_IP
redis = redis://taky_redis:6379
root_dir = /taky

[cot_server]
port = 8089
mon_port = 8088
max_persist_ttl = -1

[dp_server]
upload_path = /taky/dp-user

[ssl]
enabled = true
client_cert_required = true
ca = /taky/ssl/ca.crt
ca_key = /taky/ssl/ca.key
server_p12 = /taky/ssl/server.p12
server_p12_pw = ClearTextFTW
cert = /taky/ssl/server.crt
key = /taky/ssl/server.key
cert_db = /taky/ssl/cert-db.txt
EOF

echo "Building client example files..."
takyctl build_client atak1
takyctl build_client atak2
takyctl build_client --is_itak itak1
takyctl build_client --is_itak itak2
mkdir /taky/examples
mv *.zip /taky/examples

echo "Config created..."
fi

echo ""
fi

else
echo "Config found..."
fi

exec "$@"
