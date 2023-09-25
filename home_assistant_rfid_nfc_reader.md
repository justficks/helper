## Подключение rfid\nfc считывателя ESP8266 D1 Mini + PN532 NFC Reader

Ссылочки:

- [Головной источник](https://github.com/adonno/tagreader/tree/master)
- [ESPHome WEB](https://web.esphome.io)
- [Видео №1 (немного бесполезное)](https://www.youtube.com/watch?v=16Es-JRaeGg)
- [Видео №2](https://www.youtube.com/watch?v=5Xo8yc4tQYc&t=609s)

---

Этапы:

- Подключаем устройство к компу через micro-usb.
- Заходим на [ESPHome WEB](https://web.esphome.io)
- Подключаем и настраиваем wifi на устройстве, чтобы оно было подключено к одной и той же сети с HA
- Переходим в настройки HA - AddOn - Добавляем ESPHome
- В течении нескольких секунд, датчик должен определиться в системе
- Переходим в панель управления ESPHome
- Подтверждаем подключение считывателя "ADOPT"
- Нажимаем на "Edit"
- И вносим вот такую конфигурацию:

```yaml
wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password
  # without static IP I can't to load new config to device
  manual_ip:
    static_ip: 10.1.1.186
    gateway: 10.1.1.1
    subnet: 255.255.255.0
  # Enable fallback hotspot (captive portal) in case wifi connection fails
  ap:
    ssid: "Esphome-Web-60496E"
    password: "BtfrHA8bityc"

# Enable the captive portal for inital WiFi setup
captive_portal:

improv_serial:

substitutions:
  name: tagreader
  friendly_name: TagReader

esphome:
  name: $name
  platform: ESP8266
  board: d1_mini
  name_add_mac_suffix: true
  on_boot:
    priority: -10
    then:
      - wait_until:
          api.connected:
      - logger.log: API is connected!

# Define buttons for writing tags via HA
button:
  - platform: template
    name: Write Tag Random
    id: write_tag_random
    # Optional variables:
    icon: "mdi:pencil-box"
    on_press:
      then:
        - lambda: |-
            static const char alphanum[] = "0123456789abcdef";
            std::string uri = "https://www.home-assistant.io/tag/";
            for (int i = 0; i < 8; i++)
              uri += alphanum[random_uint32() % (sizeof(alphanum) - 1)];
            uri += "-";
            for (int j = 0; j < 3; j++) {
              for (int i = 0; i < 4; i++)
                uri += alphanum[random_uint32() % (sizeof(alphanum) - 1)];
              uri += "-";
            }
            for (int i = 0; i < 12; i++)
              uri += alphanum[random_uint32() % (sizeof(alphanum) - 1)];
            auto message = new nfc::NdefMessage();
            message->add_uri_record(uri);
            ESP_LOGD("tagreader", "Writing payload: %s", uri.c_str());
            id(pn532_board).write_mode(message);
  - platform: template
    name: Clean Tag
    id: clean_tag
    icon: "mdi:nfc-variant-off"
    on_press:
      then:
        - lambda: "id(pn532_board).clean_mode();"
  - platform: template
    name: Cancel writing
    id: cancel_writing
    icon: "mdi:pencil-off"
    on_press:
      then:
        - lambda: "id(pn532_board).read_mode();"

  - platform: restart
    name: "${friendly_name} Restart"
    entity_category: config

# Enable logging
logger:

# Enable Home Assistant API
api:
  encryption:
    key: "OX2k7f27RtgbA7+1AGAPi8mAPh4T57XuzSIZytTdty0="
  services:
    - service: write_tag_id
      variables:
        tag_id: string
      then:
        - lambda: |-
            auto message = new nfc::NdefMessage();
            std::string uri = "https://www.home-assistant.io/tag/";
            uri += tag_id;
            message->add_uri_record(uri);
            id(pn532_board).write_mode(message);

# Enable OTA upgrade
ota:

i2c:
  scan: False
  frequency: 400kHz

globals:
  - id: source
    type: std::string
  - id: url
    type: std::string
  - id: info
    type: std::string

pn532_i2c:
  id: pn532_board
  on_tag:
    - delay: 0.15s # to fix slow component
    - lambda: |-
        id(source)="";
        id(url)="";
        id(info)="";
        if (tag.has_ndef_message()) {
          auto message = tag.get_ndef_message();
          auto records = message->get_records();
          for (auto &record : records) {
            std::string payload = record->get_payload();
            std::string type = record->get_type();
            size_t hass = payload.find("https://www.home-assistant.io/tag/");
            size_t applemusic = payload.find("https://music.apple.com");
            size_t spotify = payload.find("https://open.spotify.com");
            size_t sonos = payload.find("sonos-2://");

            if (type == "U" and hass != std::string::npos ) {
              ESP_LOGD("tagreader", "Found Home Assistant tag NDEF");
              id(source)="hass";
              id(url)=payload;
              id(info)=payload.substr(hass + 34);
            }
            else if (type == "U" and applemusic != std::string::npos ) {
              ESP_LOGD("tagreader", "Found Apple Music tag NDEF");
              id(source)="amusic";
              id(url)=payload;
            }
            else if (type == "U" and spotify != std::string::npos ) {
              ESP_LOGD("tagreader", "Found Spotify tag NDEF");
              id(source)="spotify";
              id(url)=payload;
            }
            else if (type == "U" and sonos != std::string::npos ) {
              ESP_LOGD("tagreader", "Found Sonos app tag NDEF");
              id(source)="sonos";
              id(url)=payload;
            }
            else if (type == "T" ) {
              ESP_LOGD("tagreader", "Found music info tag NDEF");
              id(info)=payload;
            }
            else if ( id(source)=="" ) {
              id(source)="uid";
            }
          }
        }
        else {
          id(source)="uid";
        }

    - if:
        condition:
          lambda: 'return ( id(source)=="uid" );'
        then:
          - homeassistant.tag_scanned: !lambda |-
              ESP_LOGD("tagreader", "No HA NDEF, using UID");
              return x;
        else:
          - if:
              condition:
                lambda: 'return ( id(source)=="hass" );'
              then:
                - homeassistant.tag_scanned: !lambda "return id(info);"
              else:
                - homeassistant.event:
                    event: esphome.music_tag
                    data:
                      reader: !lambda |-
                        return App.get_name().c_str();
                      source: !lambda |-
                        return id(source);
                      url: !lambda |-
                        return id(url);
                      info: !lambda |-
                        return id(info);
  on_tag_removed:
    then:
      - homeassistant.event:
          event: esphome.tag_removed

binary_sensor:
  - platform: status
    name: "${friendly_name} Status"
    entity_category: diagnostic

text_sensor:
  - platform: version
    hide_timestamp: true
    name: "${friendly_name} ESPHome Version"
    entity_category: diagnostic
  - platform: wifi_info
    ip_address:
      name: "${friendly_name} IP Address"
      icon: mdi:wifi
      entity_category: diagnostic
    ssid:
      name: "${friendly_name} Connected SSID"
      icon: mdi:wifi-strength-2
      entity_category: diagnostic
```
