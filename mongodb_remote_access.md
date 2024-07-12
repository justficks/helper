1. Заходим на сервер по SSH
2. Получаем ip контейнер с mongodb database:
```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cetkincenter_mongo
```
3. В локальном терминале прокидываем 27017 порт
```bash
ssh -NL 27017:172.21.0.8:27017 job-s1
```
4. Подключаемся к базе через MongoDB compass по localhost