[Назад](./setup_dns_in_cloudflare.md) - [На главную](../README.md)

## Взаимодействие с собственным почтовым сервером

Существет множество способов взаимодействия. Например:
- thunderbird, outlook - это нативные почтовые клиенты. При добавлении аккаунта, в случае если всё прошло нормально, приложение само определит входные точки в почтовый сервер и всё будет работать.
- Веб клиенты, например: https://cypht.org

Для создания новых пользователей или алиасов выполняется путем запуска скрипта setup.sh:
```
./setup.sh email add newAccount@domain.com password
```