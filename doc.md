# Краткое описание серверной части

- Flight framework (на сервере) - обеспечивает роутинг запросов к остальному коду на php

Все запросы попадают в роутинг фреймворка после чего работает обычный код php


# Краткое описание клиентской части

- Vuejs framework (на клиенте) - обеспечивает работу всего, что происходит на странице
- Muicss framework (на клиенте) - стили о оформление элементов на странице
- Yandex Map framework (на клиенте)

Всё что есть интерактивного на странице приводится в движение фреймворком Vue.js.


# Список основной структуры файлов

```
├── app.php  -  основной php код на стороне сервера
├── assets   -  каталог с файлами css/js/img и т.п.
├── assets_src  -  каталог с исходными файлами для компиляции css/js/img и т.п.
│   ├── coffee
│   │   └── app.coffee  -  основной coffee код на стороне клиента, компилируется в javascript
│   ├── img  -  каталог с иконками для обозначения датчиков на карте
│   │   ├── blue.png
│   │   ├── gray.png
│   │   ├── green.png
│   │   ├── logo.png
│   │   ├── red.png
│   │   └── yellow.png
│   └── sass  -  основной sass код для генерации css стилей
│       └── style.sass
├── composer.json  -  зависимости php кода на сервере
├── config.php  -  вспомогательный php файл с настройками
├── daemon.php  -  php код обеспечивающий работу службы обновления данных на карте, работает в фоне
├── daemon_run.sh  -  вспомогательный sh код обеспечивающий запуск службы обновления данных на карте
├── database.php  -  php код обеспечивающий работу хранения данных в базе sql
├── index.php  -  вспомогательный файл обеспечивающий запуск основного кода в `app.php`
├── tmp  -  каталог для хранения временных файлов
└── views  -  каталог с представлениями страниц, содержит в себе html разметку страниц
    ├── layout.tpl  -  основной слой, обеспечивает базовое оформление страниц с подключеными js и css библиотеками
    ├── vue_auth.tpl  -  файлы для vue клиентской части
    ├── vue_filter.tpl  -  файлы для vue клиентской части
    ├── vue_panel.tpl  -  файлы для vue клиентской части
    └── vue_tools.tpl  -  файлы для vue клиентской части

```


---


# app.php

```
function json_response($status, $data, $errors = [], $messages = [], $v = "")
```
Функция для ответа в формате `json`.

- $status - статус ответа
- $data - данные тела ответа
- $errors - массив с описанием ошибок
- $messages - массив с описанием сообщений


```
function html_response($layout, $data)
```
Функция для ответа в формате `html`

- $layout - название основного слоя для представления (обычно `layout`)
- $data - данные для генерации `html`. В `$data` обязательный параметр `view` в котором должно быть название для представления


```
function gen_paginations($total_rows, $count, $page, $length)
```
Функция генерации данных пагинации страниц

- $total_rows - всего количество записей (например 1000)
- $count - необходимое количество записей для одной страницы (например 50)
- $page - номер страницы запрашиваемый для отображения
- $length - необходимое количество кнопок пагинации (например 11), количество должно быть нечётным


```
function balloonContentHeaderGenerator($row)
```
Функция генерации `html` кода для заголовка `balloon` метки на yandex карте

- $row - объект записи в базе с параметрами датчика


```
function balloonContentBodyGenerator($row)
```
Функция генерации `html` кода для тела `balloon` метки на yandex карте


```
function presetGenerator($row)
```
Функция генерации `preset` поля для метки на yandex карте

- $row - объект записи в базе с параметрами датчика


```
function presetImgGenerator($row, $check_dogovor=false)
```
Функция генерации `iconImageHref` поля для метки на yandex карте

- $row - объект записи в базе с параметрами датчика
- $check_dogovor - делать ли проверку на наличие или отсутствие договора относительно датчика


```
function rowObjectGenerator($row, $check_dogovor=false, $without_state=false, $without_iscompany=false)
```
Функция генерации параметров объекта датчика для yandex карты

- $row - объект записи в базе с параметрами датчика
- $check_dogovor - делать ли проверку на наличие или отсутствие договора относительно датчика
- $without_state - учитываеть или не учитывать параметр `state_id` при генерации параметров датчика для yandex карты
- $without_iscompany - учитывать или не учитывать параметр `iscompany` при генерации параметров датчика для yandex карты


```
function rowCompanyGenerator($row)
```
Функция генерации параметров объекта компании для yandex карты

- $row - объект записи в базе с параметрами компании


```
function check_auth()
```
Функция проверки наличия аутентификации пользователя


```
function check_enabled_user($user)
```
Функция проверки состояние пользователя по полю `enabled`

- $user - объект записи в базе с параметрами пользователя


```
function check_role($user, $role)
```
Функция проверки роли пользователя для контроля прав авторизации

- $user - объект записи в базе с параметрами пользователя
- $role - требуемая роль для проверки на её наличие у пользователя


```
function preset_role($user)
```
Вспомогательная функция для добавления текстового поля `role` к объекту пользователя

- $user - объект записи в базе с параметрами пользователя


```
function preset_company($user)
```
Вспомогательная функция для добавления текстового поля `company` к объекту пользователя

- $user - объект записи в базе с параметрами пользователя


```
function response_404()
```
Вспомогательная функция для ответа 404


```
function daemon_start()
```
Функция старта службы автоматического сбора и обновления данных датчиков в базе


```
function daemon_stop()
```
Функция остановки службы автоматического сбора и обновления данных датчиков в базе


```
function daemon_status()
```
Функция проверки состояния службы автоматического сбора и обновления данных датчиков в базе


```
Flight::route('GET /', function()
```
Роутинг обеспечивающий ответ основной страницы

- $layout - layout.tpl
- $view - index.tpl
- format - html


```
Flight::route('GET /data', function()
```
Роутинг обеспечивающий данными объектов датчиков для yandex карт

- format - json


```
Flight::route('GET /data/@type/@last', function($type, $last)
```
Роутинг обеспечивающий получение новых данных датчиков для yandex карт

- $type - тип данных (обычно `objects`)
- $last - `id` самой актуальной записи
- format - json


```
Flight::route('GET /getDataById/@id', function($id)
```
Роутинг обеспечивающий получение данных объекта относительно его `id` записи

- $id - `id` записи объекта датчика в базе
- format - json


```
Flight::route('GET /companies', function()
```
Роутинг обеспечивающий получение данных компаний для yandex карт

- format - json


```
Flight::route('GET /dogovors', function()
```
Роутинг обеспечивающий получение данных датчиков (у которых отсутствует договор) для yandex карт

- format - json


```
Flight::route('GET /stats', function()
```
Роутинг обеспечивающий получение общей статистики датчиков и другой информации в базе

- format - json


```
Flight::route('GET /filters', function()
```
Роутинг обеспечивающий получение данных для применения в фильтрах. Собираются и отдаются данные справочников.

- format - json


```
Flight::route('POST /templates', function()
```
Роутинг обеспечивающий получение html разметки для Vue.js компонентов

- format - json


```
Flight::route('POST /auth/login', function()
```
Роутинг обеспечивающий аутентификацию пользовательской учётной записи

- format - json


```
Flight::route('POST /auth/logout', function()
```
Роутинг обеспечивающий деаутентификацию пользовательской учётной записи

- format - json


```
Flight::route('POST /auth/check', function()
```
Роутинг обеспечивающий проверки состояния аутентификации учётной записи

- format - json


```
Flight::route('POST /auth/reg', function()
```
Роутинг обеспечивающий регистрацию учётной записи

- format - json


```
Flight::route('POST /api', function()
```
Роутинг обеспечивающий обращения к api серверной части

- format - json


```
Flight::route('POST /search/by/name', function()
```
Роутинг обеспечивающий поиск объекта датчика по названию привязанной к нему организации

- format - json


```
Flight::route('GET /daemon/@command', function($command)
```
Роутинг обеспечивающий управление состоянием службы автоматического получения и обновления данных датчиков. Служба запрашивает данные в CouchDB и сохраняет их к SQL базе.

- $command - команда управления службой, может быть `start`, `stop`, `status`
- format - html


```
Flight::route('GET /page/@name', function($name)
```
Роутинг обеспечивающий работу различных страниц,таких как `контакты`, `инструкция` и т.п.

- format - html

```
Flight::map('notFound', function()
```
Роутинг обеспечивающий ответ 404 статуса в случае если роутинг обращения не соответствовал ни одному из вариантов

- format - html


---


# config.php

Файл с настройками

- yanmapapi - ключ для доступа к api yandex карт
- couchdb - параметры доступа к сырым данным датчиков в базе `couchdb`


---


# daemon.php

```
function _log($msg)
```
Функция логирования

- $msg - сообщение для записи в лог файл


```
function c_get_conn($dbname = null)
```
Функция для соединения с базой CouchDB

- $dbname - имя базы (коллекции) CouchDB


```
function c_objects($dbname, $limit=null, $decode = true)
```
Функция получения данных из коллекции CouchDB

- $dbname - имя базы (коллекции) CouchDB
- $limit - лимит получаемых объектов
- $decode - параметр для `json_decode`


```
function c_row($dbname, $seq_id, $limit=1, $decode=false)
```
Функция получения записи из коллекции CouchDB по курсору

- $dbname - имя базы (коллекции) CouchDB
- $seq_id - id курсора
- $limit - лимит получаемых объектов
- $decode - параметр для `json_decode`


```
function get_objects_state()
```
Функция получения/обновления состояния объектов датчиков


```
function get_objects()
```
Функция получения/обновления состояния объектов владельцев датчиков


```
function get_catalogs()
```
Функция получения/обновления состояния объектов адресов владельцев датчиков


---


# database.php

```
function check_schema_and_get_db($as_pdo=false, $db_file=null)
```
Функция проверки схемы sql базы и получения объекта доступа к базе sql

- as_pdo - формат получаемого объекта базы sql
- db_file - файл базы данных в случае sqlite базы


```
function get_db_orm($db_file=null)
```
Функция получения объекта базы sql c orm lessql

- $db_file - файл базы данных в случае sqlite базы


---


# index.php

Файл запуска основного app.php кода


---


# .htaccess

Файл правил htaccess, заворачивает все обращения к серверу на index.php


---

# app.coffee

```
DEBUG=false
TIMERS={}
TRIGGERS={}
```
Глобальные переменные

- DEBUG - отладка
- TIMERS - хранение таймеров отложенного запуска функций
- TRIGGERS - хранение триггеров


---


Основные компоненты Vue.js

- Bus
- tools_data_app
- auth_data_app
- panel_data_app
- menu_nav_data_app
- filter_panel_data_app


```
Bus
```
Компонент Vue.js для приёма и передачи event-ов между объектами


```
tools_data_app
```
Компонент Vue.js обеспечивающий работу вёрстки `vue_tools.tpl`


```
auth_data_app
```
Компонент Vue.js обеспечивающий работу вёрстки `vue_auth.tpl`


```
panel_data_app
```
Компонент Vue.js обеспечивающий работу вёрстки `vue_panel.tpl`


```
menu_nav_data_app
```
Компонент Vue.js обеспечивающий работу вёрстки `menu.tpl` и `menu_sidebar.tpl`


```
filter_panel_data_app
```
Компонент Vue.js обеспечивающий работу вёрстки `vue_filter.tpl`


---


Основные функции

```
getJsonData = (url, cb)
```
Функция для ajax запроса данных

- type - GET
- url - path запроса к серверу
- cb - callback функция вызова


---


```
postJsonData = (url, cb)
```
Функция для ajax запроса данных

- type - POST
- url - path запроса к серверу
- cb - callback функция вызова


---


```
postJsonWithData = (url, data, cb)
```
Функция для ajax запроса данных с телом запроса

- type - POST
- data - тело запроса
- cb - callback функция вызова


---


```
Filter
```
Функция для фильтрации объектов на yandex карте. Назначение функции - генерировать строку с условиями фильтрации для yandex карты. Условия фильтрации в виде строки применяются в функции `setFilter`.

Принцип работы функции `setFilter` описан в api yandex карт: https://tech.yandex.ru/maps/doc/jsapi/2.1/ref/reference/ObjectManager-docpage/#method_detail__setFilter

Например выполнение функции
```
filterApp = window.filterApp = Filter.new()
filterApp.add("and", "iscompany", "iscompany", "==", true)
filterApp.query()
```

Сгенерирует строку вида
```
'(properties.iscompany == true)'
```

После применения функции
```
ObjectManagerGroup.setFilter( filterApp.query() )
```
Объекты на карте будут отфильтрованы таким образом, что на карте останутся все объекты с параметром `true` в поле `iscompany`

**Filter** позволяет запоминать и компоновать множество различных параметров с различными условиями для их комплексного применения с функцией `setFilter`

---


```
main
```
Функция запускает основной клиентский код после загрузки контента страницы. В задачи функции `main` входят запуск компонентов Vue.js и подгрузка первоначальных параметров для этих компонентов.
