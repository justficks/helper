### Смена пароля пользователя admin в Grafana

Просто отправляем запрос:
```
PUT https://admin:yourOldPassword@grafana.domain.org/api/user/password
```
В body передаем:
```
{
   "oldPassword": "yourOldPassword",
   "newPassword":"yourNewPassword"
}
```