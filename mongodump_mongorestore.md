```bash
docker exec mongo sh -c "mongodump --authenticationDatabase admin -u root -p MyPass1 --db nn --archive" > /tmp/file.dump
```

Мы сделали dump базы с именем "nn". Вдруг захотели импортировать её в локальную на своем компе. Но мы это уже делали и локально база nn уже существует. So, нам нужно импортировать базу под новым названием и ниже инструкция как это сделать:

```bash
docker exec -i mongo sh -c 'mongorestore --authenticationDatabase admin -u root -p MyPass2 --nsFrom=nn.* --nsTo=nnbackup.* --archive' < file.dump
```
