#!/bin/bash
##### For ubuntu #####

curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo apt-key add -
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | sudo tee /etc/apt/sources.list.d/tailscale.list

apt-get update
apt-get install tailscale
sudo apt-get install -y jq

# enable ip forwarding for advertising subnets
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

# working directory tailscale api responses
mkdir /tmp/tswd

# remove tailnet devices with the same name
curl 'https://api.tailscale.com/api/v2/tailnet/${tailnet}/devices' \
    -u "${tailscale_api_key}:" \
    --output /tmp/tswd/devices
jq -r '.[] | map(select(.hostname == "${prefix}-${tailnet_device_name}")) | map(.id) | join("\n")' /tmp/tswd/devices | sudo tee /tmp/tswd/ids 
    cat /tmp/tswd/ids | xargs -I{} \
        curl -X DELETE 'https://api.tailscale.com/api/v2/device/{}' \
        -u "${tailscale_api_key}:" 

# create auth key
curl -X POST \
    https://api.tailscale.com/api/v2/tailnet/${tailnet}/keys \
    -H "Content-Type: application/json"  \
    -u "${tailscale_api_key}:" \
    --data '{"capabilities": { "devices": { "create": {"reusable": false, "ephemeral": false } }} }' \
        | jq -r '.key' | sudo tee /tmp/tswd/auth_key

# enable tailscale daemon
systemctl enable --now tailscaled

# connect to tailscale
sudo tailscale up \
    --hostname ${prefix}-${tailnet_device_name} \
    --authkey=$(cat /tmp/tswd/auth_key) \
    --advertise-routes=${subnets_to_advertise} \
    --accept-routes \
    --accept-dns=false

# wait for log in connect to be complete
while : ; do tailscale ip -4 ; [[ $? -eq 1 ]] || break; sleep 3; done
curl 'https://api.tailscale.com/api/v2/tailnet/${tailnet}/devices' \
    -u "${tailscale_api_key}:" \
    | jq -r '.[] | map(select(.hostname == "${prefix}-${tailnet_device_name}")) | map(.id) | join("\n")' \
    | sudo tee /tmp/tswd/id

# disable key expiry
curl https://api.tailscale.com/api/v2/device/$(cat /tmp/tswd/id)/key \
    -H "Content-Type: application/json"  \
    -u "${tailscale_api_key}:" \
    --data-binary '{"keyExpiryDisabled": true, "preauthorized": true}'

# remove tailscale api key leaks 
sudo rm -rf /tmp/tswd
sudo sed -i -e '/tskey/d' /var/log/auth.log
sudo rm /var/lib/cloud/instance/user-data.txt \
        /var/lib/cloud/instance/user-data.txt.i \
        /var/lib/cloud/instances/i-*/scripts/part-001
sudo grep -r tskey /var | cut -d' ' -f3 | sudo xargs -I{} rm {}
