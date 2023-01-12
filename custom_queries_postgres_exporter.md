## Инструкция добавления кастомной метрики в postgres_exporter в docker

1. Настраиваем контейнер (в моем случае это docker-compose.yml):

```yml
postgres-exporter1:
  image: quay.io/prometheuscommunity/postgres-exporter:latest
  volumes:
    - ./postgres_exporter/custom-queries.yml:/custom-queries.yml
  environment:
    DATA_SOURCE_NAME: "postgresql://user:password@serverIp:5432/postgres?sslmode=disable"
    PG_EXPORTER_EXTEND_QUERY_PATH: "/custom-queries.yml"
  ports:
    - 9187:9187
  restart: always
```

2. Создаем файл ./postgres_exporter/custom-queries.yml со следующим содержимым:

```yml
pg_replication:
  query: "with q as(SELECT CASE WHEN state = 'streaming' THEN 1 ELSE 0 END as state FROM pg_stat_replication) select state from q union all select '0' where not exists(select 1 from q)"
  master: true
  metrics:
    - state:
        usage: "GAUGE"
        description: "Статус репликации"
```

3. Пересобираем контейнер и всё готово. В prometheus добавится дополнительная метрика pg_replication_state - которая показывает либо 0 (репликация отсутствует либо выключенна) либо 1 (репликация работает).
