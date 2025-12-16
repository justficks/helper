# OpenVPN Server Setup

## Installation

1. Create `docker-compose.yml`:

```yaml
version: "3"
services:
  openvpn:
    image: kylemanna/openvpn
    container_name: openvpn
    cap_add:
      - NET_ADMIN
    network_mode: host
    restart: always
    volumes:
      - ./data/conf:/etc/openvpn
```

2. Generate config (replace `YOUR_SERVER_IP`):

```bash
docker compose run --rm openvpn ovpn_genconfig -u udp://YOUR_SERVER_IP -s 10.11.11.0/24
```

3. Initialize PKI (save CA password to secure location. Other questions not required):

```bash
docker compose run --rm openvpn ovpn_initpki
```

4. Enable client-to-client communication. Edit `data/conf/openvpn.conf`, add:

```
client-to-client
```

5. Start server:

```bash
docker compose up -d
```

## Client Management

Create client:

```bash
./create_client.sh username
./create_client.sh username 10.11.11.50  # with static IP
```

Configs saved to `configs/` directory.

## Client Connection (Linux)

```bash
sudo apt install openvpn
sudo cp username.ovpn /etc/openvpn/client/username.conf
sudo systemctl enable openvpn-client@username
sudo systemctl start openvpn-client@username
```

Check status:

```bash
sudo systemctl status openvpn-client@username
```

## Split Tunnel (VPN traffic only)

Remove line from `username.ovpn`:

```
redirect-gateway def1
```

## Network Access

- VPN server IP: `10.11.11.1`
- Clients can ping each other
- Host can ping all clients (via `tun0` interface created by host network mode)
