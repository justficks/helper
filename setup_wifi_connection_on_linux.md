## Настройка работы ПК с Ubuntu Server (linux) через wifi usb adapter (REALTEK RTL8811CU)

Если произошло крупное обновление linux после apt update && apt upgrade, то возможна ошибка с пропажей нужного нам wifi интерфейса (Команда "ip a" больше не показывает "3: wlxa0d76831406d"). Дла решения, нужно скачать, скомпилировать и установить исходники драйвера заново

---

Для запуска работы сервера по WiFi нужно установить драйвер для USB-WiFI адаптера и указать название сети wifi и пароль.

- Исходная статья установки драйвера [https://github.com/brektrou/rtl8821CU](https://github.com/brektrou/rtl8821CU)

---

1. Подключаемся к серверу. Для первоначальной установки нам понадобиться интернет соединение. Воткни провод в сервак
2. Смотрим текущие интерфейсы соединений:

```bash
ip a
```

3. По дефолту должны быть показаны только два интерфейса:

```bash
1: lo:  ...
2: enp4s0: ...
```

4. Если у вас уже есть третий интерфейса типа wlan0 или wlxa0d76831406d, то кажется у вас всё хорошо и можно переходить к шагу с настройкой подключения к wifi минуя установку драйвера
5. Инача вы счастливик, и у вас есть два варианта установки драйвер исходя из [этой инструкции](https://github.com/brektrou/rtl8821CU):
   1. Предподготовка (скорее всего нужна для обоих вариантов ниже)
   2. Установка при помощи dkms
   3. Установка из исходников
   4. Проверка
6. Настраиваем сервер на работу с WiFi

### 5.1 Предподготовка:

- Устанавливаем инструменты для сборки:

```bash
sudo apt install -y make gcc bc git
```

- Скачиваем нужные нам исходные файлы:

```bash
mkdir -p ~/build
cd ~/build
git clone https://github.com/brektrou/rtl8821CU.git
```

### 5.2 Установка при помощи dkms:

- Устанавливаем dkms:

```bash
sudo apt-get install dkms
```

- Запускаем скрипт установки драйвера:

```bash
cd ~/build/rtl8821CU
./dkms-install.sh
```

- Переходим к пункту 5.4

### 5.3 Установка из исходников

- Собираем\билдим исходники:

```bash
cd ~/build/rtl8821CU
make
sudo make install
```

### 5.4 Проверка

- Если всё ок, то перезагружаем систему через reboot
- Смотрим появление нужного нам интерфейса через команду "ip a"
- Должно вывести:

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

### 6. Настраиваем сервер на работу с WiFi (настройка netplan)

- Переходим в директорию /etc/netplan/

```bash
cd /etc/netplan/
```

- Там должен быть файл .yaml. В моем случае - это 00-installer-config.yaml
- Редактируем его:

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

- Вносим настройки:

```yaml
# This is the network config written by 'subiquity'
network:
  version: 2
  renderer: networkd
  wifis:
    wlxa0d76831406d:
      dhcp4: true
      access-points:
        "TP-Link_XXX": # <-- Название WiFI сети
          password: "12345678" # <-- Пароль
  ethernets:
    enp4s0:
      dhcp4: true
      optional: true # <-- Этот параметр нужен для того, чтобы не ждать несколько минут при включении, если вдруг у нас нет воткнутого Ethetnet кабеля и интернет не фурычит
```

- Применяем настройки:

```bash
sudo netplan apply
```

---

### Далее настраиваем wpa_supplicant:

Источник: https://www.youtube.com/watch?v=bhvcIni71T8

```bash
wpa_passphrase "TP-Link" 12345678

# Output:
#
# network={
# 	ssid="TP-Link"
# 	#psk="12345678"
# 	psk=osadif1j9280fj10928fj8037hjf8qsodjf08q8jwf80qw7jfq80
# }
```

```bash
nano /etc/wpa_supplicant/ssid.conf

# Вносим в файл:
#
# ctrl_interface=/run/wpa_supplicant
# update_config=1
# network={
# 	ssid="TP-Link"
# 	#psk="12345678"
# 	psk=osadif1j9280fj10928fj8037hjf8qsodjf08q8jwf80qw7jfq80
# }
```

```bash
killall wpa_supplicant
```

```bash
wpa_supplicant -B -i wlxa0d76831406d -C /etc/wpa_supplicant/ssid.conf
```

```bash
dhclient -v wlxa0d76831406d
```

- И перезагружаем сервер через reboot
