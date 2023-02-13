[На главную](./index.md) | [Предыдущий шаг](1-step.md) | [Следующий шаг](3-step.md)

# Создание мастер базы PostgreSQL **pg_one_master** на сервер **a_server**

Создаем папку где будут храниться файлы базы:

```
mkdir -p /media/vault.sql/1
```

Указываем владельцем пользователя postgres:

```
chown postgres:postgres /media/vault.sql/1 & chmod 0700 /media/vault.sql/1
```

Начинаем выполнять команды от пользователя postgres

```
su postgres
```

Инициализируем базу данных:

```
pg_ctl init -D /media/vault.sql/1
```

Выходим из под postgres пользователя

```
exit
```

Запускаем инстанс базы:

```
su postgres -c "pg_ctl -D /media/vault.sql/1 start"
```

---

[На главную](./index.md) | [Предыдущий шаг](1-step.md) | [Следующий шаг](3-step.md)
