[< Назад на главную](README.md)

# Просмотр документации команда `./rac ./ras`:

```bash
./ras help
```

```bash
./ras cluster help
```

и т.д.

```bash
./rac help
```

```bash
./rac cluster help
```

и т.д.

---

Просмотр текущих кластеров:

```
./rac cluster list
```

Просмотр существующих информационных баз:

```
./rac infobase --cluster=CLUSTER_UID --cluster-user=admin --cluster-pwd=SECRET_PASSWORD_CLUSTER summary list
```

Удаление информационной базы:

```
./rac infobase --cluster=CLUSTER_ID --cluster-user=admin --cluster-pwd=CLUSTER_PASSWORD drop --infobase=INFOBASE_UUID
```
