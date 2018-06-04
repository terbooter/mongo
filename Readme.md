Deploy mongo replicaset of 3 nodes

This instruction based on official docs
https://docs.mongodb.com/manual/tutorial/deploy-replica-set-with-keyfile-access-control/#deploy-repl-set-with-auth

#Step by step
* 3 hosts should be with docker (Lets call this nodes mongo0, mongo1, mongo2)
* Login via SSH to first host
* Make `git clone` of this repo
* Rename .env.EXAMPLE into .env
* Generate random key using command
```
openssl rand -base64 40
```
* Copy that key to MONGO_KEY

Key length must be between 6 and 1024 characters long and must be the same for all members of the replica set.
[more about key in docs](https://docs.mongodb.com/v3.6/tutorial/enforce-keyfile-access-control-in-existing-replica-set/#create-a-keyfile)
boot script automatically will create keyfile and write `MONGO_KEY` value into it 

* Run mongo on mongo0 with priority 2, other with priority 1
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