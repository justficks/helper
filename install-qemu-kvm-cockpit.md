- Установка Cockpit [Ref](https://cockpit-project.org/running):

```bash
sudo apt install -t ${VERSION_CODENAME}-backports cockpit
```

- Теперь можно подключаться к панель управления сервером через:

```
http://server_ip:9090
```

- Устанавливаем kvm [Ref](https://ubuntu.com/blog/kvm-hyphervisor):

```bash
sudo apt -y install bridge-utils cpu-checker libvirt-clients libvirt-daemon qemu qemu-kvm
```

- Проверяем включенную виртуализацию:

```bash
kvm-ok
```

- Должно выдать:

```
INFO: /dev/kvm exists
KVM acceleration can be used
```

- Если /dev/kvm NOT exists, то идем в интернет и смотрим как включить виртуализацию на вашем процессоре

- Доустанавливаем пакет управления виртуальными машинами:

```bash
sudo apt install cockpit-machines
sudo systemctl restart cockpit
```

- После успешной установки, в панеле управления сервером должна появиться вкладка "Virtual Machines"
