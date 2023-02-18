#!/bin/bash

echo "Generate config, CA, and certs if config doesn't exist..."
if [ ! -f /home/taky/taky.conf ]; then
takyctl setup --host taky --public-ip $PUBLIC_IP --user taky /tmp/taky #because taky won't create files in a folder that exists
mv /tmp/taky/* /home/taky
rm -r /home/taky/dp-user

cat > /home/taky/taky.conf << EOF
[taky]
hostname = taky
node_id = TAKY
bind_ip = 0.0.0.0
public_ip = $PUBLIC_IP
redis = redis://taky_redis:6379
root_dir = /home/taky

[cot_server]
port = 8089
mon_port = 8088
cot_log = true
log_cot = /home/taky/logs
max_persist_ttl = -1

[dp_server]
upload_path = /home/taky/uploads

[ssl]
enabled = true
client_cert_required = true
ca = /home/taky/ssl/ca.crt
ca_key = /home/taky/ssl/ca.key
server_p12 = /home/taky/ssl/server.p12
server_p12_pw = atakatak
cert = /home/taky/ssl/server.crt
key = /home/taky/ssl/server.key
cert_db = /home/taky/ssl/cert-db.txt
EOF

echo "Build client example files..."
takyctl build_client atak1
takyctl build_client --is_itak itak1
mv *.zip clients
fi

echo "Finished! Run container."
exec "$@"
