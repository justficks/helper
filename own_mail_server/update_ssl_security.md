## Обновление SSL сертификатов для почтового сервера

### Первый этап:

Пересоздаем сертификаты через certbot/cloudlare-dns.

Там будет один вопрос на который нужно будет ответить:

1. Сертификаты уже существуют. Оставить всё как есть?
2. Перезаписать сертификаты?

Мы соотвественно выбираем 2 вариант.

```bash
sudo docker run -it --rm --name certbot \
  -v "./cloudflare/certs:/etc/letsencrypt" \
  -v "./cloudflare/logs:/var/log/letsencrypt" \
  -v "./cloudflare/cloudflare.ini:/run/secrets" \
  certbot/dns-cloudflare:latest certonly --dns-cloudflare \
  --dns-cloudflare-credentials /run/secrets/cloudflare-api-token \
  --email forma@gmail.com \
  --agree-tos --no-eff-email \
  -d mail.qumail.org
```

---

### Второй этап:

Нужно перезагрузить docker-mailserver

```bash
sudo docker-compose up --build mailserver
```

---

- Если что-то идет не так с сертификатами, то просто удаляем папку ./cloudflare/certs и выполняем всё заново
- Ещё возможы ошибки при запуске certbot из-за путей. Возможно нужно будет указать абсолютный путь в -v /home/adm1/docker/mailserver/cloudflare/certs и т.д.
- Если что, то файлы создаются от root пользователя и видны только ему. Тоесть если ты сидишь через vscode remote ssh, то не увидишь созданные файлы. Нужно явно проверить через ls -la:

```
/cloudflare/certs/live# ls -la
total 16
drwx------ 3 root root 4096 Jul 12 10:49 .
drwxr-xr-x 7 root root 4096 Jul 12 10:49 ..
-rw-r--r-- 1 root root  740 Jul 12 10:49 README
drwxr-xr-x 2 root root 4096 Jul 12 10:49 mail.qumail.org
```
