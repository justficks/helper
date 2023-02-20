[На главную](README.md)

## Бэкап полностью действующей графаны
___Используем [docker-grafana-backup-tool](https://hub.docker.com/r/ysde/docker-grafana-backup-tool)___

---
### Получаем api токен
- Открываем графану
- Настройки > API Keys > New API Key
- Вводим: 
    - Key name: backup
    - Role: Admin
- Сохраняем ключ

---
### Создаем .env файл на сервере
```
GRAFANA_TOKEN=yourTokenBefore
GRAFANA_URL=https://grafana.domain.com
GRAFANA_ADMIN_ACCOUNT=admin
GRAFANA_ADMIN_PASSWORD=adminpass
VERIFY_SSL=false

# Строки ниже нужны для обртных действий. Загрузки бэкапов в чистую базу графаны
# RESTORE=true
# ARCHIVE_FILE=202302200551.tar.gz
```
---
### Создаем script.sh для запуска основной части
```bash
#!/bin/bash

backups_folder=$PWD/backups

mkdir $backups_folder
sudo chown 1337:1337 $backups_folder

docker run --user $(id -u):$(id -g) --rm --name grafana-backup-tool \
    -v $backups_folder:/opt/grafana-backup-tool/_OUTPUT_ \
    --env-file .env \
    ysde/docker-grafana-backup-tool
```

---
### Делаем файл исполняемым
```
sudo chmod +x script.sh
```

---
### Запускаем получение бэкапов
```
./script.sh
```