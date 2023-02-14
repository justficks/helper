[< Назад на главную](README.md)

# Установка правильной локали linux

```
dpkg-reconfigure locales
```
- Пикаем "en_US.UTF-8 UTF-8" & "ru_RU.UTF-8 UTF-8"
! Важно выбрать именно два этих пункта. Без en_US в постгрес будут постоянно ошибки "неверное значение для параметра "lc_messages": "en_US.UTF-8""

- Выбираем этот пункт с помощью пробела

- Жмакаем Enter

- Опять наводимся на ru_RU и вновь на Enter

![image](https://user-images.githubusercontent.com/36725599/199390700-bf41c616-3589-4e21-9a4e-3b64a1998312.png)

Всё. Готово

