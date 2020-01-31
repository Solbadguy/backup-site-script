#!/bin/bash
# Будет отображаться "От кого"
FROM=my@server.ru
# Кому
MAILTO=email@yandex.ru
# Тема письма
NAME=$1
# Тело письма
BODY=$2
# Скрипт легко адаптируется для любых почтовых серверов
SMTPSERVER=smtp.yandex.ru
# Логин и пароль от учетной записи
SMTPLOGIN=name@gmail.com
SMTPPASS=superpassword

# Отправляем письмо
/usr/bin/sendEmail -f $FROM -t $MAILTO -o message-charset=utf-8  -u $NAME -m $BODY -s $SMTPSERVER -o tls=yes -xu $SMTPLOGIN -xp $SMTPPASS
