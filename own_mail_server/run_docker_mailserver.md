[Назад](./create_ssl_security.md) - [На главную](../README.md) - [Следующий шаг](./setup_dns_in_cloudflare.md)

## Запуск docker-mailserver

Созадем файл в папке /root/docker/mail/docker-compose.yml
```yml
services:
  mailserver:
    image: docker.io/mailserver/docker-mailserver:latest
    container_name: mailserver
    # If the FQDN for your mail-server is only two labels (eg: example.com),
    # you can assign this entirely to `hostname` and remove `domainname`.
    hostname: mail.domain.com
    domainname: domain.com
    ports:
      - "25:25"    # SMTP  (explicit TLS => STARTTLS)
      - "143:143"  # IMAP4 (explicit TLS => STARTTLS)
      - "465:465"  # ESMTP (implicit TLS)
      - "587:587"  # ESMTP (explicit TLS => STARTTLS)
      - "993:993"  # IMAP4 (implicit TLS)
    volumes:
      - ./dms/mail-data/:/var/mail/
      - ./dms/mail-state/:/var/mail-state/
      - ./dms/mail-logs/:/var/log/mail/
      - ./dms/config/:/tmp/docker-mailserver/
      - /etc/localtime:/etc/localtime:ro
      # Прокидываем сгенерированный на предыдущем шаге сертификат
      - ./acme.sh/domain.com_ecc/fullchain.cer:/etc/ssl/fullchain.cer:ro 
      # Прокидываем сгенерированный на предыдущем шаге ключ сертификата
      - ./acme.sh/domain.com_ecc/domain.com.key:/etc/ssl/domain.com.key:ro
    environment:
      - SSL_TYPE=manual
      - SSL_CERT_PATH=/etc/ssl/fullchain.pem
      - SSL_KEY_PATH=/etc/ssl/privkey.pem
      - ENABLE_SPAMASSASSIN=1
      - SPAMASSASSIN_SPAM_TO_INBOX=1
      - ENABLE_CLAMAV=1
      - ENABLE_FAIL2BAN=1
      - ENABLE_POSTGREY=1
    restart: always
    stop_grace_period: 1m
    cap_add:
      - NET_ADMIN
```

Скачиваем файл управления в /root/docker/mail/. Через него мы будем создавать первого юзера и последующих:
```
wget https://raw.githubusercontent.com/docker-mailserver/docker-mailserver/master/setup.sh
```

Запускаем mailserver:
```
docker-compose up
```

Далее в течении 2 минут нам необходимо создать нового пользователя:
```
./setup.sh email add adm@domain.com password
```

С установкой всё. Посмотрите логи. Там их много, но не должно быть каких-нибудь красных строк с ошибками. Там уж разбираться придется вам.

---

[Следующий шаг](./setup_dns_in_cloudflare.md)
