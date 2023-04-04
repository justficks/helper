## Настройка работы ПК с Ubuntu Server (linux) через wifi usb adapter (REALTEK RTL8811CU)

Прежде всего необходимо установить драйвера для wifi usb адаптера:
В моем случае инструкция и драйвера тут: https://github.com/brektrou/rtl8821CU.
Вроде как шаги такие:

- Устанавливаем make, gcc, bc, git (и ещё linux sources, но они уже были у меня остановленны)

```bash
sudo apt install -y make gcc bc git
```

- Скачиваем нужные нам исходные файлы:

```bash
mkdir -p ~/build
cd ~/build
git clone https://github.com/brektrou/rtl8821CU.git
```

- dkms возможно нужен, возможно нет, так и не понял. Попробуйте без него, если ошибки, до установите как в инструкции к драйверу
- Собираем\билдим исходники:

```bash
cd ~/build/rtl8821CU
make
sudo make install
```

- В конечном счете при команде "ip a" мы должны увидеть что-то подобное (должен определиться wifi интерфейс):

```
...
3: wlxa0d76831406d: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether a0:d7:68:31:40:6d brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.105/24 metric 600 brd 192.168.1.255 scope global dynamic wlxa0d76831406d
       valid_lft 83419sec preferred_lft 83419sec
    inet6 fe80::a2d7:68ff:fe31:406d/64 scope link
       valid_lft forever preferred_lft forever
...
```

---

### Настраиваем netplan:

- Переходим в директорию /etc/netplan/

```bash
cd /etc/netplan/
```

- В моем случае там один файл: 00-installer-config.yaml
- Меняем содержимое на вот это:

```yaml
network:
  ethernets:
    enp4s0:
      dhcp4: true
      optional: true # <-- Этот параметр нужен для того, чтобы не ждать несколько минут при включении, если вдруг у нас нет воткнутого Ethetnet кабеля и интернет не фурычит
  version: 2
  wifis:
    wlxa0d76831406d:
      optional: true
      dhcp4: true
      dhcp6: true
      access-points:
        "TP-Link_5G": # <-- Имя WiFi сети
          password: "12345678" # <-- Пароль WiFi сети
```

- Применяем настройки:

```bash
sudo netplan apply
```

---

### Возможно и без этого работало бы, но этот шаг я тоже делал

Вот ссылка на видео: https://www.youtube.com/watch?v=bhvcIni71T8
