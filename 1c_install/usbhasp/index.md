## Инструкция по установке usbhasp на linux

- Разорхивируем ubshasp-installer.7z (На счет пароля пишем мне)

- На выходе получаем файлы:

  - keydumps.7z
  - usbhasp.tar.gz
  - readme.txt

- Разорхивируем usbhasp.tar.gz:

```
tar -xzvf ./usbhasp.tar.gz
```

- Устанавливаем:

```
sudo ./usbhasp/install.sh
```

- Удаляем лишнее:

```
rm -rf ./usbhasp/
rm -f ./usbhasp.tar.gz
```

- Кладём нужные ключи в папку /etc/usbhaspd/keys/

- Перезапускаем service:

```
systemctl restart usbhaspd
```

- Получаем информацию:

```
usbhaspinfo
```
