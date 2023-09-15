#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <url to android like 192.168.1.60:5555>"
    exit 1
fi

host="$1"

adb disconnect
adb connect $host
adb -s $host root
adb -s $host remount
adb -s $host shell "rm -rf system/priv-app/PackageInstaller"
adb -s $host push system /
adb -s $host shell "pm grant com.google.android.gms android.permission.ACCESS_COARSE_LOCATION"
adb -s $host shell "pm grant com.google.android.gms android.permission.ACCESS_FINE_LOCATION"
adb -s $host shell "pm grant com.google.android.setupwizard android.permission.READ_PHONE_STATE"
adb -s $host shell "pm grant com.google.android.setupwizard android.permission.READ_CONTACTS"
adb reboot

printf "\\nТеперь перезагружай контейнер и подключись через: scrcpy -s $host. Там должны появиться уведомления с ошибками типа This device isn't Play protect\\n\\n"
