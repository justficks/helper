[На главную](README.md)

1. Подключаемся к серверу
2. Заходим [официальный репозиторий github prometheus/node_exporter](https://github.com/prometheus/node_exporter/releases/tag/v1.5.0)
3. Копируем ссылку на скачиваени последнего релиза под amd. Пример:

```
https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.darwin-amd64.tar.gz
```

4. На сервере выполняем команду (для получения архива с исполняемыми файлами):

```
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
```

5. Распаковка:

```
tar xvfz node_exporter-1.5.0.linux-amd64.tar.gz
```

6. Копируем бинарник node_export в /usr/local/bin:

```
cp node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin
```

7. Создаем node_exporter.service:

```
nano node_exporter.service
```

8. Просписываем следующий текст:

```
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
Type=simple
Restart=always
User=root
Group=root
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

9. Копируем .service в системный каталог сервисов:

```
cp node_exporter.service /etc/systemd/system
```

10. Копируем бинарник node_exporter в нужную директорию:

```
cp ./node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/node_exporter
```

11. Запускаем:

```
systemctl start node_exporter.service
```

12. Проверяем статус:

```
systemctl status node_exporter.service
```

13. Если всё в порядке и статус сервиса active, то включаем автозапуск node_exporter вместе с системой:

```
systemctl enable node_exporter.service
```

14. После запуска, node_exporter шарит 9100 порт. И после команды:

```
netstat -tulpn | grep 9100
```

Должна выдать следующую строку:

```
tcp6 0 0 :::9100 :::* LISTEN 65510/node_exporter
```

15. Последняя проверка - это http запрос на получение метрик:

```
http://serverip:9100/metrics
```
