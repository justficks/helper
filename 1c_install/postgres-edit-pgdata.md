[< Назад на главную](README.md)

# Перенос папки с данными PostgresSql в другую папку

Здесь нужно запомнить одну важную вещь. Нас интересует переменная PGDATA.

В моем случае, она инициализируется из скрипта /etc/init.d/postgrespro-1c-14.

Далле, нужно разобраться в самом скрипте. У меня переменная PGDATA достается из файла /etc/default/postgrespro-1c-14 в виде:

```
PGDATA=/path/to/data/directory
```

---

Описание решения в моем случае:

```
# Подключаемся к psql
sudo su postgres psql

# Смотрим текущую директорию с данными:
postgres=# show data_directory;

# Всё. Пока что этих данных нам достаточно. Выходим:
postgres=# \q

# Останавливаем службу пострес:
systemctl stop postgrespro-1c-14

# Переносим текущие данные постгрес в нужную директорию (Обязательно нужно сохранить права для пользователя postgres)
rsync -av /opt/pgpro /somedisk/new/pgpro/directory

# Меняем переменную PGDATA в файле /etc/default/postgrespro-1c-14 на нужную нам директорию
PGADATA=/somedisk/new/pgpro/directory

# Запускаем postgres:
systemctl start postgrespro-1c-14

# И проверяем настройки:
sudo su postgres psql
postgres=# show data_directory;
```
