[На главную](README.md)

## Установка node_exporter на openwrt

**! Доступ к метрикам предоставляется для другого сервера в одной сети vpn**

---

Подгружаем свежие пакеты openwrt

```
opkg update
```

Устанавливаем необходимые зависимости

```
opkg install prometheus-node-exporter-lua \
prometheus-node-exporter-lua-nat_traffic \
prometheus-node-exporter-lua-netstat \
prometheus-node-exporter-lua-openwrt \
prometheus-node-exporter-lua-wifi \
prometheus-node-exporter-lua-wifi_stations
```

---

Определяем интерфейс на котором будет доступ к метрикам. В нашем случае это wireguard "wg0"

```
ip addr
```

Выводиться следующее. Как раз по этому ip 10.8.1.2 нам и необходим доступ

```
11: wg0: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc noqueue state UNKNOWN group default qlen 1000
    link/none
    inet 10.8.1.2/32 brd 255.255.255.255 scope global wg0
       valid_lft forever preferred_lft forever
```

---

Редактируем файл конфига

```
vim /etc/config/prometheus-node-exporter-lua
```

Для начала редактирования нажимаем на i и исправляем файл на

```
config prometheus-node-exporter-lua 'main'
        option listen_ipv6 '0'
        option listen_port '9100'
        option listen_interface 'wg0'
```

Чтобы выйти и сохранить изменения нажимаем Esc,
далее пишем :wq! и нажимаем Enter

---

Перезагружаем сервис

```
/etc/init.d/prometheus-node-exporter-lua restart
```

---

Команды для проверки

```
netstat -tulpn | grep 9100
# Вывод -> tcp 0 0 10.8.1.2:9100 0.0.0.0:* LISTEN 9456/uhttpd

curl 10.8.1.2:9100/metrics
# Выведет все текущие метрики. Их будет много
```
