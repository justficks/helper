# Счетчик воды в Home Assistant

- Добавляем переменную\state в configuration.yaml

```yaml
,,,

input_number:
  water_usage1:
    name: WaterUsage1
    min: 0
    max: 1000000
    step: 10
    icon: mdi:water

automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml

,,,
```

- Добавляем автоматизацию через GUI и редактируем файл automations.yaml

```yaml
,,,

- id: "1697614919148"
  alias: "Счетчик воды 1"
  description: ""
  trigger:
    - platform: state
      entity_id:
        - binary_sensor.tz3000_au1rjicn_ts0203_opening
      from: "on"
      to: "off"
  condition: []
  action:
    - service: input_number.set_value
      target:
        entity_id: input_number.water_usage1
      data:
        value: "{{ (states('input_number.water_usage1') | float + 10) }}"
  mode: single

,,,
```
