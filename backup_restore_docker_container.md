## Backup

1. Для начала получаем id необходимого нам контейнера:

```
docker ps
```

2. Делаем коммит:

```
docker commit -p containerId futureBackupFileName
```

3. Превращаем коммит в .tar файл:

```
docker save -o ~/backupFileName.tar futureBackupFileName
```

## Restore

1. Загружаем image бэкапа в докер:

```
docker image load -i backupFileName.tar
```

2. Смотрим с каким названием нужный нам image:

```
docker image ls
```

3. Запускаем контейнер:

```
docker run imageName --network="proxy"
```

## Соединение восстановленного бэкапа с docker-compose.yml

1. Запускаем.

```
docker image ls
```

2. Находим image который мы подгрузили из бэкапа
3. Меняем поле image в docker-compose.yml
