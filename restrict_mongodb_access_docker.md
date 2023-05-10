## Ограничение доступа к базе данных MongoDB

При такой реализации, доступ к базе данных только из локальной сети или с определенного IP адреса

- Смотрим правила:

```bash
iptables -L --line-numbers
```

В моем случае вывод следующий:

```
...
Chain DOCKER (4 references)
num  target     prot opt source               destination
1    ACCEPT     tcp  --  anywhere             172.20.0.9           tcp dpt:9090
2    ACCEPT     udp  --  anywhere             172.19.0.3           udp dpt:51820
3    ACCEPT     tcp  --  anywhere             172.20.0.5           tcp dpt:https
4    ACCEPT     tcp  --  anywhere             172.20.0.5           tcp dpt:http
5    ACCEPT     tcp  --  anywhere             172.20.0.3           tcp dpt:27017
...
```

- Удаляем текущее правило с доступом from anywhere (5 - это номер правила):

```bash
iptables -D DOCKER 5
```

- Добавляем доступ только для определенного IP адреса:

```bash
iptables -A DOCKER -p tcp -m tcp --dport 27017 -s your_ip_here -j ACCEPT
```

- Сохраняем конфигурацию:

```bash
iptables-save
```
