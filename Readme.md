Запускаем кластер репликасет монг
как описано в официальной доке
https://docs.mongodb.com/manual/tutorial/deploy-replica-set-with-keyfile-access-control/#deploy-repl-set-with-auth

Пошагово.
0. На трех машинах должен быть установлен консул с регистратором из этого репозитория
 https://github.com/terbooter/consul
1. Делаем git clone этот репозиторий
2. Переименовываем .dockerenv.EXAMPLE в .dockerenv
3. Генерим рандомный ключ и ипшем его в переменную окружения MONGO_KEY
4. Задаем переменную среды SERVICE_NAME которую понимает регистратор для каждой ноды свой (mongo0, mongo1, mongo2)
mongo0 запускается с приоритетом 2, остальный с приоритетом 1
5. Запускаем как обычно `docker-compose up`
5. На втором сервере повторяем все тоже самое, но ключ не генерим а копируем с первого сервера, SERVICE_NAME задаем mongo1 
6. Повторяем на третьем сервере то же что и на втором, SERVICE_NAME задаем mongo2
7. Входим внутрь контейнера на хосте с mongo0
```
docker exec -it mongo_mongo_1 bash
```
8. Запускаем mongo shell скрипт инициализирующий реплику (см доку)
```
mongo < /js/init_rs.js
```
Проверяем, что репликасет инициализовалась и мы в PRIMARY
Для этого запускаем монго шелл
```
root@cacc5b6cf03c:/# mongo
MongoDB shell version: 3.2.7
connecting to: test
rs0:PRIMARY> exit
bye
```
9. Запускаем mongo shell скрипт создающий root юзера
```
mongo < /js/add_root_user.js
```
10. Для того чтобы войти по рутом запускаем скрипт `/mongo.sh`

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