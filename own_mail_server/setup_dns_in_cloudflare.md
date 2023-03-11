[Назад](./run_docker_mailserver.md) - [На главную](../README.md) - [Следующий шаг](./interact_with_mailserver.md)

## Настройка dns записей cloudflare

Создаем следующие записи:
- A domain.com ip_your_server (proxy or not)
- A mail ip_your_server (DNS only)
- MX domain.com mail.domain.com priotity=10
- TXT _dmarc (v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s;)
- TXT domain.com (v=spf1 mx -all)

Дополнительно нам понадобиться ещё одна dns запись (DKIM). Генерировать мы её будет вот так:
```
./setup.sh config dkim
```

Вывод будет такой:
```
mail._domainkey	IN	TXT	( "v=DKIM1; h=sha256; k=rsa; "
	  "p=datadata+data"
	  "datadata+data"
	  "datadata+data" )  ; ----- DKIM key mail for domain.com

Если что, эти данные будут находиться в файле /root/docker/mail/dms/config/opendkim/keys/domain.com/mail.txt
```

Из этих данных, нам нужно получить следующее (то есть удалить лишние двойные ковычки):
```
v=DKIM1; h=sha256; k=rsa; p=datadata+datadatadata+datadatadata+data
```
И добавляем последнюю запись в dns cloudflare:
- TXT mail._domainkey (v=DKIM1; h=sha256; k=rsa; p=datadata+datadatadata+datadatadata+data)

---

Всё, остался последний шаг и это проверка. Переводим на этот [сайт](https://developers.cloudflare.com/dns/manage-dns-records/how-to/email-records/) и вбиваем domain.com. Все пункты должны быть зелеными.

---

[Следующий шаг](./interact_with_mailserver.md)