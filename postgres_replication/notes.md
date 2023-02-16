Пример файла postgresql.conf

```conf
password_encryption = md5
logging_collector = on
log_timezone = 'Asia/Novosibirsk'
datestyle = 'iso, dmy'
timezone = 'Asia/Novosibirsk'
lc_messages = 'ru_RU.UTF-8'
lc_monetary = 'ru_RU.UTF-8'
lc_numeric = 'ru_RU.UTF-8'
lc_time = 'ru_RU.UTF-8'
default_text_search_config = 'pg_catalog.russian'

# Settings for extensions
work_mem = 256MB
maintenance_work_mem = 256MB
max_files_per_process = 10000
max_parallel_workers_per_gather = 0
max_parallel_maintenance_workers = 2 # Количество CPU/4, минимум 2, максимум 6
commit_delay = 1000
checkpoint_timeout = 15min
from_collapse_limit = 8
join_collapse_limit = 8
autovacuum_max_workers = 2
vacuum_cost_limit = 200 # 100* autovacuum_max_workers
autovacuum_naptime = 20s
autovacuum_vacuum_scale_factor = 0.01
autovacuum_analyze_scale_factor = 0.005
escape_string_warning = off
standard_conforming_strings = off
shared_preload_libraries = 'online_analyze, plantuner'
online_analyze.threshold = 50
online_analyze.scale_factor = 0.1
online_analyze.enable = on
online_analyze.verbose = off
online_analyze.min_interval = 10000
online_analyze.table_type = 'temporary'
plantuner.fix_empty_table = on

# Custom from https://postgrespro.ru/docs/postgrespro/12/config-one-c
max_connections = 1000
temp_buffers = 32MB
max_locks_per_transaction = 256
standard_conforming_strings = off
escape_string_warning = off
effective_cache_size = 3000MB

# Custom main
listen_addresses = '*'
port = 5432
wal_level = replica
wal_log_hints = on
hot_standby = on

archive_mode = on
archive_command = 'cp -i %p /media/vault.sql/1/archive/%f'

#synchronous_commit = on
#synchronous_standby_names = '*'

min_wal_size = 1GB
max_wal_size = 4GB
```