Пример файла srv1cv83.service

```bash
[Unit]
Description=1C:Enterprise Server 8.3 (8.3.22.1704) (%I)
Requires=network.target

[Service]
# 1C:Enterprise server keytab file.
# default - usr1cv83.keytab file in 1C:Enterprise server
#           installation directory
#
Environment=SRV1CV8_KEYTAB=/opt/1cv8/x86_64/8.3.22.1704/usr1cv8.keytab

# Cluster agent main port
Environment=SRV1CV8_PORT=1540

# Cluster main port for default cluster.
# This port is used by the cluster agent to address
# the central server. Cluster port is also specified
# as the IP port of the working server.
Environment=SRV1CV8_REGPORT=1541

# Port range for connection pool
# example values:
#   45:49
#   45:67,70:72,77:90
Environment=SRV1CV8_RANGE=1560:1591

# 1C:Enterprise server configuration debug mode
# empty value - off
# -debug - on
Environment=SRV1CV8_DEBUG=

# Path to directory with cluster data
Environment=SRV1CV8_DATA=/media/vault.sql/1c
#Environment=SRV1CV8_DATA=/home/usr1cv8/.1cv8/1C/1cv8

# Security level:
# 0 - default - unprotected connections
# 1 - protected connections only for the time of user
#     authentication
# 2 - permanently protected connections
Environment=SRV1CV8_SECLEV=0

# Check period for connection loss detector, milliseconds
Environment=SRV1CV8_PINGPERIOD=1000

# Response timeout for connection loss detector, milliseconds
Environment=SRV1CV8_PINGTIMEOUT=5000
Environment=TMPDIR=/media/vault.sql/1c-tmp

Type=simple
User=usr1cv8
Group=grp1cv8

ExecStart=/opt/1cv8/x86_64/8.3.22.1704/ragent \
                        -d ${SRV1CV8_DATA} \
                        -port ${SRV1CV8_PORT} \
                        -regport ${SRV1CV8_REGPORT} \
                        -range ${SRV1CV8_RANGE} \
                        -seclev ${SRV1CV8_SECLEV} \
                        -pingPeriod ${SRV1CV8_PINGPERIOD} \
                        -pingTimeout ${SRV1CV8_PINGTIMEOUT} \
                        $SRV1CV8_DEBUG

Restart=always
RestartSec=1

[Install]
DefaultInstance=default
WantedBy=multi-user.target
```