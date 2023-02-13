[На главную](./index.md) | [Предыдущий шаг](2-step.md) | [Следующий шаг](4-step.md)

# Настройка репликации **pg_one_master** в базу **pg_one_slave** на **b-server**

Подразумевается, что уже запущено два инстанса PostgreSQL для выполнения дальнейшей работы на обоих серверах.

Директория с файлами баз данных:

- **a_server** - /media/vault.sql/1 - **pg_one_master**
- **b_server** - /media/vault.sql/1 - **pg_one_slave**

---

## Этап 1.1 Подготовка **a_server**. Настройка postgresql.conf

Настраиваем мастера на работу с репликой + архивирование WAL журналов. Архивирование необходимо для надежности, так как может быть ситуация, когда мастер удалит один из журналов, который ещё не успел примениться на slave-е.

Открываем postgresql.conf:

```
nano /media/vault.sql/1/postgresql.conf
```

И добавляем следующие настройки:

```
listen_addresses = '*'
port = 5432
wal_level = replica
wal_log_hints = on
archive_mode = on
archive_command = 'cp -i %p /media/vault.sql/1/archive/%f'
max_wal_senders = 100
hot_standby = on
```

Создаем папку archive и даем ей права postgres пользователя:

```
mkdir /media/vault.sql/1/archive & chown postgres:postgres /media/vault.sql/1/archive & chmod 0700 /media/vault.sql/1/archive
```

---

## Этап 1.2 Подготовка **a_server**. pg_hba.conf и user replicator

Редактируем файл pg_hba.conf. Указываем функцию репликации (replication), пользователь который будет её производить (replicator) и ip второго сервера (20.20.20.20), где будет крутиться slave этой базы

```
echo "host replication replicator 10.8.1.52/32 md5" >> /media/vault.sql/1/pg_hba.conf
```

На будущее, добаляем в pg_hba.conf текущий ip сервера:

```
echo "host replication replicator 10.8.1.62/32 md5" >> /media/vault.sql/1/pg_hba.conf
```

Открываем psql:

```
su postgres -c "psql"
```

(psql) Создаем пользователя базы данных, который будет отвечать только за репликацию:

```
CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'secret';
```

(psql) Обновляем наши доработки:

```
select pg_reload_conf();
```

(psql) Выходим из оболочки psql:

```
\q
```

---

## Этап 1.3 Подготовка **a_server**. Перезагрузка базы и проверка

Останавливаем базу:

```
su postgres -c "pg_ctl -D /media/vault.sql/1 stop"
```

Запускаем заново:

```
su postgres -c "pg_ctl -D /media/vault.sql/1 start"
```

Через некоторое время, в папке /media/vault.sql/1/archive должны повиться файлы WAL журналов:

```
ls /media/vault.sql/1/archive
```

---

## Этап 2. Подготовка **b_server** и запуск репликации

Открываем **b_server**:

```
ssh b_server
```

На сервере должна быть установлена утилита pg_basebackup такой же версии и подготовлена пустая директория, куда будет размещена копия с мастера (+ права на эту директории должны быть у пользователя postgres):

```
mkdir -p /media/vault.sql/1 & chown postgres:postgres /media/vault.sql/1 && chmod 0700 /media/vault.sql/1
```

### Копируем мастер базу

```
su postgres -c "pg_basebackup -h 10.8.1.52 -U replicator -p 5432 -D /media/vault.sql/1 -R -P"
```

-R — будет создан автоматически файл standby.signal и заполнен файл postgresql.auto.conf с информацией о подключении к мастеру

-P — примерный прогресс-бар

### Запускаем slave инстанс

```
su postgres -c "pg_ctl -D /media/vault.sql/1 start"
```

---

[На главную](./index.md) | [Предыдущий шаг](2-step.md) | [Следующий шаг](4-step.md)
