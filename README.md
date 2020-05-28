# v2ray-install
Автоматическая установка сервера Shadowsocks с плагином v2ray

Данный скрипт автоматически установит Shadowsocks с плагином v2ray, вам лишь потребуется ввести пароль для доступа к серверу, порт, на котором он будет работать, предпочтительный метод шифрования и DNS сервер.
Если вы хотите всё настроить сами - следуйте гайду, расположенному ниже.

# Настройка сервера
Для начала - купите сервер. Где искать - думайте сами, но главное - это не подходит для слабых VPS, и уж тем более с OpenVZ виртуализацией.

Затем нам нужно обновить систему и установить сам Shadowsocks:

```sh
$ sudo apt update && sudo apt upgrade -y
$ sudo apt install shadowsocks-libev
```

Теперь нам нужен плагин: идём на [страницу релизов](https://github.com/shadowsocks/v2ray-plugin/releases), копируем ссылку для нашей архитектуры и скачиваем командой wget:

```sh
$ sudo wget https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.0/v2ray-plugin-linux-amd64-v1.3.0.tar.gz
```

Распаковываем и переносим в удобное место:

```sh
$ sudo tar -xf v2ray-plugin-linux-amd64-v1.3.0.tar.gz
$ sudo mv v2ray-plugin-linux-amd64 /etc/shadowsocks-libev/v2ray-plugin
```

Разрешаем плагину использовать привелигированные порты:

```sh
$ sudo  setcap 'cap_net_bind_service=+eip' /etc/shadowsocks-libev/v2ray-plugin
```

Теперь создаём конфигурационный файл v2ray.json:

```sh
$ sudo nano /etc/shadowoscks-libev/v2ray.json
```

И вставляем в него следующее:

```
{
  "server":"0.0.0.0",
	"server_port":ваш_порт,
	"password":"ваш_пароль",
	"local_port":1080,
	"timeout":300,
	"method":"ваш_метод_шифрования",
	"fast_open":true,
	"reuse_port":true,
	"plugin":"/etc/shadowsocks-libev/v2ray-plugin",
	"plugin_opts":"server",
	"nameserver":"ваш_dns"
}
```
Меняем значения на предпочтительные вам, сохраняем (Ctrl-O,Enter), выходим (Ctrl-X).

Теперь приступим к созданию сервиса ss-v2ray.service.

Создаём файл:

```sh
$ sudo nano /etc/systemd/system/ss-v2ray.service
```

В него вставляем это:

```[Unit]
Description=Shadowsocks-libev with V2RAY-websocket obfuscation
Documentation=man:shadowsocks-libev(8)
After=network.target

[Service]
Type=simple
User=nobody
Group=nogroup
LimitNOFILE=51200
ExecStart=/usr/bin/ss-server -c /etc/shadowsocks-libev/v2ray.json

[Install]
WantedBy=multi-user.target
```

Сохраняем и выходим.

Включаем и запускаем наш сервис:

```sh
$ sudo systemctl enable ss-v2ray.service && sudo systemctl restart ss-v2ray.service
```

Проверяем статус:

```sh
$ sudo systemctl status ss-v2ray
```

Всё готово!
Приступим к настройке клиента

# Настройка клиента

## Windows

Скачиваем с [официального сайта](https://shadowsocks.org/en/download/clients.html) клиент под Windows, и распаковываем его в корень C (или куда вам там удобно).
Затем с того же сайта, с которого мы скачивали плагин, скачиваем версию плагина для Windows. Переименовываем распакованный плагин в v2ray.exe, и кидаем рядом с Shadowsocks в корень каталога.

Запускаем Shadowsocks, и в настройках указываем данные для доступа (сами разберётесь, куда и что вводить), в поле Плагин вводим v2ray, а в поле Опции плагина вводим host=любой.сайт. Так v2ray будет делать вид, что ходит на этот сайт.

## Linux

Повторяем все действия по настройке сервера до создания файла v2ray.json. Вместо него редактируем config.json:

```sh
sudo nano /etc/shadowsocks-libev/config.json
```

В него вставляем всё то же, что вставляли на сервере в файл v2ray.json, только строку "plugin_opts" приводим к виду:

```
  "plugin_opts":"host=ваш.сайт",
```

Создаём сервис:

```sh
$ sudo nano /etc/systemd/system/ss-local.service
```

В него вставляем это:

```
[Unit]
Description=Daemon to start Shadowsocks Client
Wants=network-online.target
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/ss-local -c /etc/shadowsocks-libev/config.json

[Install]
WantedBy=multi-user.target
```

Сохраняем, выходим.

Включаем и перезапускаем сервис

```sh
$ sudo systemctl daemon-reload && sudo systemctl enable ss-local.service && sudo systemctl restart ss-local.service
```

## Andorid

Скачиваем клиент из Google Play (скачивайте с зелёной иконкой, там нет рекламы) и плагин.
Настройка не отличается от Windows, но если вам лень всё вводить, а на ПК всё настроено, просто в трее нажмите на значок Shadowsocks и выберите "Серверы" -> "Поделится конфигурацией сервера", а на телефоне нажмите на троеточие и выберите "Сканировать QR-код"


