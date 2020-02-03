#!/bin/sh
echo "Начал работу в `date`." > log
#-------------------------------------------------------------
#############  Задаем переменные  ###################
#-------------------------------------------------------------
# Текущая дата в формате 2015-09-29_04-10
#-------------------------------------------------------------
date_time=`date +"%Y-%m-%d_%H-%M"`
#-------------------------------------------------------------
#Создание папки с текущей датой
#-------------------------------------------------------------
mkdir /root/BACKUP/$date_time
#-------------------------------------------------------------
# проверка существования каталога
#-------------------------------------------------------------
if ! [ -d /root/BACKUP/$date_time ]; then
echo 'Директория для РК НЕ создана.' >> log
fi
echo 'Директория для РК: OK.' >> log
#-------------------------------------------------------------
# Куда размещаем backup
#-------------------------------------------------------------
bk_dir=/root/BACKUP/$date_time
#-------------------------------------------------------------
# Директория для архива
#-------------------------------------------------------------
inf_dir='/var/www/'
#-------------------------------------------------------------
# Название непосредственно директории с файлами
#-------------------------------------------------------------
dir_to_bk='/var/www/'
#-------------------------------------------------------------
##############  Создаем РК БД   #############
#-------------------------------------------------------------
# Доступы к БД Site1
#-------------------------------------------------------------
user='user1'
password='pass1'
bd_name='bd1'
#-------------------------------------------------------------
#Доступы к БД Site2
#-------------------------------------------------------------
user2='user2'
password2='pass2'
bd_name2='bd2'
#-------------------------------------------------------------
#Доступы к БД Site3
#-------------------------------------------------------------
user3='user3'
password3='pass3'
bd_name3='bd3'
#-------------------------------------------------------------
##############  Создание архива исходников  #############
#-------------------------------------------------------------
tar -czvf $bk_dir/all_sites_$date_time.tar.gz -C $inf_dir $dir_to_bk
#-------------------------------------------------------------
#Проверяем наличие файла бэкапа
#-------------------------------------------------------------
if ! [ -f /$bk_dir/all_sites_$date_time.tar.gz  ]; then
echo 'Архив с РК не существует.' >> log
else
echo 'Архив с РК: OK.' >> log
fi
#-------------------------------------------------------------
##############  Выгружаем базы данных    #############
#-------------------------------------------------------------
#mysqldump -u$bd_name -u$user -p$password 
mysqldump -u$user -p$password $bd_name | gzip -c > $bk_dir/$bd_name-mysql-$date_time.sql.gz
#-------------------------------------------------------------
#Проверяем наличие выгрузки бд Site1
#-------------------------------------------------------------
if ! [ -f /$bk_dir/$bd_name-mysql-$date_time.sql.gz  ]; then
echo 'Дамп БД сайта $bd_name не существует.' >> log
else
echo 'БД $bd_name OK.' >> log
fi
#-------------------------------------------------------------
#Site2
#-------------------------------------------------------------
mysqldump -u$user2 -p$password2 $bd_name2 | gzip -c > $bk_dir/$bd_name2-mysql-$date_time.sql.gz
#-------------------------------------------------------------
#Проверяем наличие выгрузки БД сайта Site2
#-------------------------------------------------------------
if ! [ -f /$bk_dir/$bd_name2-mysql-$date_time.sql.gz ]; then
echo 'Дамп БД сайта $bd_name2 не существует.' >> log
else
echo 'БД $bd_name2: OK.' >> log
fi
#-------------------------------------------------------------
#Site3
#-------------------------------------------------------------
mysqldump -u$user3 -p$password3 $bd_name3 | gzip -c > $bk_dir/$bd_name3_bd-mysql-$date_time.sql.gz
#-------------------------------------------------------------
#Проверяем наличие выгрузки БД сайта Site3
#-------------------------------------------------------------
if ! [ -f /$bk_dir/$bd_name3-mysql-$date_time.sql.gz ]; then
echo 'Дамп БД сайта $bd_name3 не существует.' >> log
else
echo 'БД $bd_name3: OK.' >> log
fi
#-------------------------------------------------------------
#Копируем файлы на storage
#-------------------------------------------------------------
scp -r /root/BACKUP/$date_time username@servername:/SITE/
echo 'Папка с РК была скопирована.' >> log
#-------------------------------------------------------------
##############  Удаляем архивы старше 3-х дней  #############
#-------------------------------------------------------------
find $bk_dir/ -type f -mtime +3 -exec rm {} \;
find $bk_dir/ -type d -empty -delete
echo 'Старые РК были удалены.' >> log
#-------------------------------------------------------------
##############  Уведомление на почту   #############
#-------------------------------------------------------------
# Создадим переменные с необходимой информацией. 
# Допустим конечная папка примонтирована к отдельному диску
# Узнаем размер занимаемого места созданным бэкапом
#-------------------------------------------------------------
DU=`du -sh /root/BACKUP/ | awk '{print $1}'`
#-------------------------------------------------------------
# И информацию о размере диска
#-------------------------------------------------------------
DF=`df -hT / | awk '{print $5}'`
LS=`ls -lh /root/BACKUP/| awk '{print $9}'`
#-------------------------------------------------------------
# Просмотр лога РК
#-------------------------------------------------------------
log_bk=`eval "cat /root/scripts/log"`
#-------------------------------------------------------------
# Отправляем письмо с информацией
#-------------------------------------------------------------
bash sendemail.sh "Бэкап сайтов выполнен!" "РЕЗЕРВНЫМИ КОПИЯМИ ЗАНЯТО: \n $DU \n \n НА ДИСКЕ ДОСТУПНО: \n $DF \n \n СПИСОК РК: $LS \n \n Листинг: \n $log_bk"
#-------------------------------------------------------------
# Отправляем сообщение в Телеграм
#-------------------------------------------------------------
curl "https://api.telegram.org/bot<Token>/sendMessage" -d "chat_id=<ChatID>&text= **Бэкап сайтов выполнен!** %0AРЕЗЕРВНЫМИ КОПИЯМИ ЗАНЯТО: $DU %0AДИСК: $DF  %0AСПИСОК РК: $LS %0AЛистинг: $log_bk"

