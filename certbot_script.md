## Скрипт запуска docker контейнера для генерации сертификатов через cloudflare API

```bash
#!/bin/bash

DOMAINS=("mail.domain1.org" "mail.domain1.ru")
LOGFILE="/path/to/logfile/run_certbot.log"
TELEGRAM_TOKEN="your_telegram_token"
TELEGRAM_CHAT_ID="your_telegram_chat_id"
PATH_CERTS="/path/to/certs"
PATH_CLOUDFLARE_INI="/path/to/cloudflare.ini"
EMAIL="your_cloudflare_email"

function send_telegram {
    curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d chat_id=$TELEGRAM_CHAT_ID -d text="$1"
}

if [ "$1" = "gen" ]; then
    for domain in "${DOMAINS[@]}"; do
        echo "Генерация сертификата для $domain" | tee -a "$LOGFILE"
        docker run -it --rm --name certbot \
            -v "$PATH_CERTS:/etc/letsencrypt" \
            -v "$PATH_CLOUDFLARE_INI:/cloudflare.ini" \
            certbot/dns-cloudflare certonly \
            --dns-cloudflare \
            --dns-cloudflare-credentials /cloudflare.ini \
            -email "$EMAIL" --agree-tos --no-eff-email --force-renewal \
            --dns-cloudflare-propagation-seconds 20 \
            -d "$domain" 2>&1 | tee -a "$LOGFILE"
    done
elif [ "$1" = "renew" ]; then
    echo "Обновление всех сертификатов" | tee -a "$LOGFILE"
    docker run -it --rm --name certbot \
        -v "$PATH_CERTS:/etc/letsencrypt" \
        -v "$PATH_CLOUDFLARE_INI:/cloudflare.ini" \
        certbot/dns-cloudflare renew \
        --dns-cloudflare \
        --dns-cloudflare-credentials /cloudflare.ini 2>&1 | tee -a "$LOGFILE"
else
    echo "Неверный аргумент. Используйте 'gen' для создания или 'renew' для обновления."
    exit 1
fi


if [ -s $LOGFILE ]; then
    send_telegram "Выполнение run_certbot.sh завершено. Логи: $(cat $LOGFILE)"
else
    send_telegram "После выполнения run_certbot.sh не был найден файл логов после выполнения скрипта"
fi

```