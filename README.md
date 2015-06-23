# README #

## Это прекрасное тестовое задание для компании Kosmos ##

### Части системы ###

* vk-server.coffee - эмулятор vk.service.api
* delivery-service.coffee - сервис доставки сообщений
* create-db.coffee - скрипт для создания и заполнения базы данных

### vk-server.coffee ###

Эмулятор сервиса доставки уведомлений вконтакте.

Настройки находятся в config/vk.yml

*  requestsPerSecond - количество ответов сервера в секунду, по умолчанию 3 

*  fatalChance - шанс, что в ответ сервер выдаст фатальную ошибку, по умолчанию 0.01%

*  blockChance - шанс, что у пользователя будет заблокированы уведомления, по умалчанию 20%

### create-db.coffee ###


Скрипт для создания и заполнения базы данных. Параметры заполнения регулируются в config/seed.yml

* usersCount - по уполчанию равен 1200, не стоит ставить число намного больше 1500

* names - имена пользователей

Для настройки подключения к базе используется файл config/database.yml

### delivery-service.coffee ###

Основной скрипт для доставки уведомлений. Сервис пишет лог в logs/logger.log 
