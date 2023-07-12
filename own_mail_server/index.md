[На главную](../README.md)

## Установка собственного mail сервера (docker-mailserver) на linux в связке с cloudflare

Этапы:

1. [Создание ssl сертификатов](./create_ssl_security.md)
2. [Запуск docker-mailserver](./run_docker_mailserver.md)
3. [Настройка dns записей cloudflare](./setup_dns_in_cloudflare.md)
4. [Взаимодействие с собственным почтовым сервером](./interact_with_mailserver.md)
5. [Обновление ssl сертификатов](./update_ssl_security.md)

Полезные ссылки:

- [Проверка настроек dns записей](https://dmarcian.com/domain-checker/)
- [Подобная Инструкция](https://www.tune-it.ru/web/sky/blog/-/blogs/11777224)
- [Пример настроек dns записей в cloudflare](https://developers.cloudflare.com/dns/manage-dns-records/how-to/email-records/)
- [Добавление других доменных имен](./add_second_domain.md)
