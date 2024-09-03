Генерация сертификатов для сервера
```bash
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr
openssl x509 -req -in server.csr -signkey server.key -out server.crt -days 365
```

Генерация CA сертификатов
```bash
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt
```


```bash
# Генерируем приватный ключ клиента
openssl genrsa -out employee.key 2048

# Создаем CSR (Certificate Signing Request) для клиента
openssl req -new -key employee.key -out employee.csr

# Подписываем CSR с использованием CA и генерируем клиентский сертификат
openssl x509 -req -in employee.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out employee.crt -days 365 -sha256

# Созданик .pfx - требует обязательный пароль 123456
openssl pkcs12 -export -legacy -out employee.pfx -inkey employee.key -in employee.crt -certfile ca.crt
```

Пример nginx.conf
```nginx
server {
    listen 80;
    
    # Редирект всех HTTP запросов на HTTPS
    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name _;  # Доступ по ip
    
    # Путь к сертификату сервера и его закрытому ключу
    ssl_certificate /etc/nginx/ssl/server.crt;    # Путь к сертификату сервера
    ssl_certificate_key /etc/nginx/ssl/server.key; # Путь к закрытому ключу сервера

    # Включение и настройка проверки клиентских сертификатов
    ssl_verify_client on;  # Требуется проверка клиентского сертификата
    ssl_client_certificate /etc/nginx/ssl/ca.crt;  # Путь к корневому сертификату CA
    ssl_verify_depth 2;

    # Настройки для статических файлов (Vue.js)
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Проксирование запросов на Node.js REST API
    location ^~ /api/ {
        proxy_pass http://backend:3049/;  # URL вашего Node.js бэкенда
    }
}
```