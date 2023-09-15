#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <url to android like 192.168.1.60:5555>"
    exit 1
fi

host="$1"

adb disconnect
adb connect $host
adb -s $host root
sleep 3
adb -s $host shell 'sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = \"android_id\";"'

printf "\\nПолученный id нужно ввести сюда: https://www.google.com/android/uncertified\\n"
printf "\\nЖдём 20-30 минут и перезагружаем контейнер\\n\\n"
