Deploy mongo replicaset of 3 nodes

Данная инструкция создана по мотивам официальной доки
https://docs.mongodb.com/manual/tutorial/deploy-replica-set-with-keyfile-access-control/#deploy-repl-set-with-auth

#Step by step
* На трех машинах должен быть установлен консул с регистратором из этого репозитория
 https://github.com/terbooter/consul
* Заходим по ssh на первую машину
* Делаем `git clone` этого репозитория
* Переименовываем .dockerenv.EXAMPLE в .dockerenv
* Генерим рандомный ключ и пишем его в переменную окружения MONGO_KEY
Для этого используем команду
```
openssl rand -base64 40
```
Длина ключа должна быть от 6 до 1024 символов
[подробнее в доке](https://docs.mongodb.com/v3.2/tutorial/enforce-keyfile-access-control-in-existing-replica-set/#create-a-keyfile)
Скрипт запуска автоматически создаст keyfile и запишет туда значение переменной окружения `MONGO_KEY` 
* Задаем переменную среды SERVICE_NAME которую понимает регистратор для каждой ноды свой (mongo0, mongo1, mongo2)
mongo0 запускается с приоритетом 2, остальные с приоритетом 1
* Запускаем как обычно `docker-compose up`
* На втором сервере повторяем все тоже самое, но ключ не генерим а копируем с первого сервера, SERVICE_NAME задаем mongo1 
* Повторяем на третьем сервере то же что и на втором, SERVICE_NAME задаем mongo2
В конце этого шага у нас есть три экземпляра монг запущенных на трех разных машинах.
* Входим внутрь контейнера на хосте с mongo0
```
docker exec -it mongo_mongo_1 bash
```
* Запускаем mongo shell скрипт инициализирующий реплику (см доку)
```
mongo < /js/init_rs.js
```
* Проверяем, что репликасет инициализовалась и мы в PRIMARY
Для этого запускаем монго шелл
```
root@cacc5b6cf03c:/# mongo
MongoDB shell version: 3.2.7
connecting to: test
rs0:PRIMARY> exit
bye
```
Если видим строку `rs0:PRIMARY` то данный сервер -  primary
* Запускаем bash скрипт создающий root юзера
```
/add_root_user.sh
```
Этот скрипт создает еще один скрипт для запуска mongo shell под root юзером 
* Для того чтобы войти под рутом запускаем скрипт `/mongo.sh`
* Удобный десктопный клиент для монги - MongoChef


#TODO
Монга выдает ворнинг. 
```
** WARNING: /sys/kernel/mm/transparent_hugepage/enabled is 'always'.
**        We suggest setting it to 'never'
```

Чтобы его исправить нужно произвести настройку на хосте. В контейнере этого настроить нельзя.
Ниже скрипт шпаргалка
```
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

if test -f /sys/kernel/mm/transparent_hugepage/khugepaged/defrag; then
  echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag
fi
if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
  echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi
if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
  echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi

exit 0
```