## Установка google services в контейнеры redroid (Android emulator) для получения push уведомлений

Источники:

1. https://github.com/remote-android/redroid-doc
2. https://ivonblog.com/en-us/posts/redroid-android-docker/

---

Желательно запускать контейнеры через docker-compose, так как иначе после adb reboot и нового запуска контейнера, изменения которые мы вносили в файловую систему не сохраняются. Ниже пример docker-compose.yml

```yaml
version: "3"
services:
  redroid1:
    image: redroid/redroid:11.0.0-latest
    tty: true
    privileged: true
    ports:
      - 5555:5555
    volumes:
      - ./android/5555:/data

  redroid2:
    image: redroid/redroid:11.0.0-latest
    tty: true
    privileged: true
    ports:
      - 5556:5555 # Левый - это порт на ружу (в интернет), а правый - это порт открытый в контейнере. Таким образом происходит перенаправление с порта 5556 на хосте на порт 5555 в контейнере
    volumes:
      - ./android/5556:/data

  redroid3:
    image: redroid/redroid:11.0.0-latest
    tty: true
    privileged: true
    ports:
      - 5557:5555
    volumes:
      - ./android/5557:/data
```

---

Инструкция:

- Скачиваем нужный образ c https://opengapps.org. В нашем случае - это platform: x86_64, android: 11, variant: pico

```bash
curl -o opengapps_x86_64_11_pico.zip "https://master.dl.sourceforge.net/project/opengapps/x86_64/20220503/open_gapps-x86_64-11.0-pico-20220503.zip?viasf=1"
```

- В этом архиве содержиться множество файлов и нам нужно их привести к правильной структуре (которая описанна в источнике №2). Для этого запускаем скрипт create_system_dir.sh:

```bash
./create_system_dir.sh opengapps_x86_64_11_pico.zip
```

! Скрипт использует rsync, который необходимо предварительно установить

- После выполнения скрипта, создасться директория system, в которой должна быть следующая структура файлов и директорий:

```
system
├── app
│   ├── GoogleCalendarSyncAdapter
│   │   └── GoogleCalendarSyncAdapter.apk
│   ├── GoogleContactsSyncAdapter
│   │   └── GoogleContactsSyncAdapter.apk
│   ├── GoogleExtShared
│   │   └── GoogleExtShared.apk
│   └── GoogleTTS
│       └── GoogleTTS.apk
├── etc
│   ├── default-permissions
│   │   ├── default-permissions.xml
│   │   └── opengapps-permissions-q.xml
│   ├── permissions
│   │   ├── com.google.android.dialer.support.xml
│   │   ├── com.google.android.maps.xml
│   │   ├── com.google.android.media.effects.xml
│   │   ├── privapp-permissions-google.xml
│   │   └── split-permissions-google.xml
│   ├── preferred-apps
│   │   └── google.xml
│   └── sysconfig
│       ├── dialer_experience.xml
│       ├── google-hiddenapi-package-whitelist.xml
│       ├── google.xml
│       ├── google_build.xml
│       └── google_exclusives_enable.xml
├── framework
│   ├── com.google.android.dialer.support.jar
│   ├── com.google.android.maps.jar
│   └── com.google.android.media.effects.jar
├── priv-app
│   ├── AndroidAutoPrebuiltStub
│   │   └── AndroidAutoPrebuiltStub.apk
│   ├── AndroidMigratePrebuilt
│   │   └── AndroidMigratePrebuilt.apk
│   ├── CarrierSetup
│   │   └── CarrierSetup.apk
│   ├── ConfigUpdater
│   │   └── ConfigUpdater.apk
│   ├── GoogleBackupTransport
│   │   └── GoogleBackupTransport.apk
│   ├── GoogleExtServices
│   │   └── GoogleExtServices.apk
│   ├── GoogleFeedback
│   │   └── GoogleFeedback.apk
│   ├── GoogleOneTimeInitializer
│   │   └── GoogleOneTimeInitializer.apk
│   ├── GooglePackageInstaller
│   │   └── GooglePackageInstaller.apk
│   ├── GooglePartnerSetup
│   │   └── GooglePartnerSetup.apk
│   ├── GoogleRestore
│   │   └── GoogleRestore.apk
│   ├── GoogleServicesFramework
│   │   └── GoogleServicesFramework.apk
│   ├── Phonesky
│   │   └── Phonesky.apk
│   ├── PrebuiltGmsCore
│   │   └── PrebuiltGmsCore.apk
│   └── SetupWizard
│       └── SetupWizard.apk
└── product
    └── overlay
        └── PlayStoreOverlay.apk
```

- Желательно её сравнить с вашей

```bash
tree system
```

- Далее запускаем step1.sh, который загрузит и подготовит android контейнер:

```bash
./step1.sh 192.168.1.60:5555
```

! 192.168.1.60:5555 - это ip адрес, через который доступен запущенный android контейнер

- Далее перезагружаем контейнер, чтобы изменения вступили в силу:

```bash
sudo docker-compose down redroid1
sudo docker-compose up redroid1
```

- Подключаемся к андроиду через scrcpy для проверки:

```bash
scrcpy -s 192.168.1.60:5555
```

- Сразу после подключения там периодически будут валиться ошибки типа "This device isn't Play protect". И это нормально, так как мы ещё не зарегестрировали наше устройство в google.

- Для регистрации устройства нам нужно узнать id андроида:

```bash
./step2.sh 192.168.1.60:5555
```

- После выполнения будет строка содержащая нужное нам число:

```
android_id|42927634294921963562
```

- Переходим на сайт гугла https://www.google.com/android/uncertified, вводим 42927634294921963562 и нажимаем на кнопку "Зарегестрировать".

- После этого ждем 20-30 минут и перезагружаем контейнер. И собственно всё готово
