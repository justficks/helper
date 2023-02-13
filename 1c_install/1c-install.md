[< Назад на главную](README.md)

# Установка сервера взаимодействия 1с на линукс

_**Описывать получение установочного образа не буду. Ищите как хотите :)**_

1. Распаковываем архив с файлами (если это необходимо):

```
tar -xzvf server64_8_3_21_1484.tar.gz
```

2. Запускаем процесс установки:

```
./setup-full-8.3.21.1484-x86_64.run
```

Отмечаем следующие пункты:

```
Сервер 1С:Предприятия 8 [y/N] : y

Модули расширения веб-сервера [y/N] : y

Администрирование сервера 1С:Предприятия [y/N] : y

Интерфейсы на различных языках - Русский [Y/n] :Y

Дополнительные функции администрирования [y/N] : y

Дополнительно - Liberica JRE [y/N] : y
```

3. Создаем ссылку на сервис для системы(1):

```
sudo ln -s /opt/1cv8/x86_64/8.3.21.1484/srv1cv8-8.3.21.1484@.service /etc/init.d/srv1cv83
```

3. Создаем ссылку на сервис для системы(2):
```
cp /opt/1cv8/x86_64/8.3.21.1484/srv1cv8-8.3.21.1484@.service /lib/systemd/system/srv1cv8.service
```

4. Обновляем демона, чтобы система увидела файл запуска:

```
systemctl daemon-reload
```

5. Говорим, чтобы сервис стартовал при запуске системы:

```
systemctl enable srv1cv8.service
```

6. Запускаем сервис:

```
systemctl start srv1cv8.service
```

7. Проверяем статус запуска. Всё должно быть без ошибок:

```
systemctl status srv1cv8.service
```