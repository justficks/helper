[На главную](./index.md) | [Предыдущий шаг](4-step.md) | [Следующий шаг](6-step.md)

# Slave -> Master. Отработка ситуации, когда сдох **a_server** и база **pg_one_master** больше недоступна

Переходи на сервер со Slave базой. Есть два варианта:

## Первый "pg_ctl promote":

```
su postgres -c "pg_ctl -D /media/vault.sql/one promote"
```

## Второй "select pg_promote();":

Открываем psql консоль:

```
su postgres -c "psql -p 5433"
```

(psql) делаем слэйв мастером

```
select pg_promote();
```
