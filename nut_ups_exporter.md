[На главную](README.md)

## Установка nut и nut_exporter для мониторинга UPS

---

---

### Установка nut и его настройка

Устанавливаем nut:

```
apt install nut
```

---

Убеждаемся что nut видит ИБП:

```
nut-scanner -U
```

---

Вывелось следующее:

```
IPMI library not found. IPMI search disabled.
Scanning USB bus.
[nutdev1]
	driver = "usbhid-ups"
	port = "auto"
	vendorid = "0D9F"
	productid = "0004"
	product = "HID UPS Battery"
	serial = "004-0D9F-000"
	vendor = "POWERCOM Co.,LTD"
	bus = "001"
```

---

Редактируем файл nut.conf

```
nano /etc/nut/nut.conf
```

Вставляем следующее содержимое:

```
MODE=netserver
```

---

Редактируем файл ups.conf

```
nano /etc/nut/ups.conf
```

Вставляем следующее содержимое:

```
pollinterval = 1
maxretry = 3

[powercom]
	driver = usbhid-ups
	port = auto
	desc = "Powercom Smart"
	vendorid = 0D9F
	productid = 0004
	serial = 004-0D9F-000
```

---

Редактируем файл upsd.conf

```
nano /etc/nut/upsd.conf
```

Вставляем следующее содержимое:

```
LISTEN 127.0.0.1 3493
```

---

Редактируем файл upsd.users

```
nano /etc/nut/upsd.users
```

Вставляем следующее содержимое:

```
[admin]
	password = passwd
	actions = SET
	instcmds = ALL

[upsmon]
	password  = passwd
	upsmon master
```

---

Редактируем файл upsmon.conf

```
nano /etc/nut/upsmon.conf
```

Вставляем следующее содержимое:

```
# Default
MINSUPPLIES 1
SHUTDOWNCMD "/sbin/shutdown -h +0"
POLLFREQ 5
POLLFREQALERT 5
HOSTSYNC 15
DEADTIME 15
POWERDOWNFLAG /etc/killpower
RBWARNTIME 43200
NOCOMMWARNTIME 300
FINALDELAY 5

# Custom
RUN_AS_USER root
MONITOR powercom@localhost 1 admin passwd master
```

---

Перезагружаем сервисы для применения наших настроек:

```
systemctl restart nut-server.service
```

```
systemctl restart nut-client.service
```

```
systemctl restart nut-monitor.service
```

---

### Установка nut_exporter и его настройка

Скачиваем последний релиз nut_exporter

```
wget https://github.com/DRuggeri/nut_exporter/releases/download/v2.5.3/nut_exporter-v2.5.3-linux-amd64
```

Распаковка

```
tar xvfz nut_exporter-v2.5.3-linux-amd64.tar.gz
```

Закидываем nut_exporter в /usr/local/bin

```
mv nut_exporter /usr/local/bin
```

---

Создаем nut_exporter.service

```
nano /etc/systemd/system/nut_exporter.service
```

Вставляем след содержимое

```
[Unit]
Description=Prometheus Nut Exporter
After=network.target

[Service]
Type=simple
Restart=always
User=root
Group=root
ExecStart=/usr/local/bin/nut_exporter

[Install]
WantedBy=multi-user.target
```

Запускаем

```
systemctl start nut_exporter.service
```

Проверяем статус

```
systemctl status nut_exporter.service
```

Подрубаем включение после старта сервера

```
systemctl enable nut_exporter.service
```
