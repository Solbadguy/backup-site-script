#!/bin/sh
#-------------------------------------------------------------
#############  Задаем переменные  ###################
#-------------------------------------------------------------
# Текущая дата в формате 2015-09-29_04-10
#-------------------------------------------------------------
date_time=`date +"%Y-%m-%d_%H-%M"`
#-------------------------------------------------------------
echo "Начал работу в `date`." > /root/scripts/log
#-------------------------------------------------------------
#############  Монтируем хранилище  #############
#-------------------------------------------------------------
sshfs SFTPUNAME@SFTPSERVER:/ /root/STORAGE/
#-------------------------------------------------------------
#############  Информацию о РК после ротации  #############
#-------------------------------------------------------------
LS1after=`ls -lh /root/STORAGE/1C/ | awk '{print $9}'`
LS2after=`ls -lh /root/STORAGE/SITE/NetLab/ | awk '{print $9}'`
LS3after=`ls -lh /root/STORAGE/SITE/Resurs/ | awk '{print $9}'`
#-------------------------------------------------------------
##############  Удаляем архивы старше 50 дней  #############
#-------------------------------------------------------------
find /root/STORAGE/FOLDER1 -type f -mtime +50 -exec rm {} \;
echo 'РК 1C старше 50 дней были удалены c StorageBox -a.' >> /root/scripts/log
find /root/STORAGE/FOLDER1 -type d -empty -delete
#-------------------------------------------------------------
find /root/STORAGE/FOLDER2 -type f -mtime +50 -exec rm {} \;
echo 'РК сайтов старше 50 дней были удалены c StorageBox -a.' >> /root/scripts/log
find /root/STORAGE/FOLDER2 -type d -empty -delete
#-------------------------------------------------------------
##############  Информацию о размере диска  ##############
#-------------------------------------------------------------
DF=`df -h /root/STORAGE/ | awk '{print $5}'`
#-------------------------------------------------------------
##############  Просмотр лога РК  ##############
#-------------------------------------------------------------
log_bk=`eval "cat /root/scripts/log"`
#-------------------------------------------------------------
##############  Отправим сообщение в Телеграм  ##############
#-------------------------------------------------------------
curl "https://api.telegram.org/botNUMBER:TOKEN/sendMessage" -d "chat_id=NUMBER&text= **РК старше 50 дней были удалены со стореджа.** %0AДИСК: $DF  %0AСПИСОК РК: %0A1C $LS1after %0ASite-Netlab $LS2after %0ASite-Resurs $LS3after %0AЛистинг: $log_bk"

#-------------------------------------------------------------
############## Размонтируем удаленное хранилище  #############
#-------------------------------------------------------------
umount /root/STORAGE/
#-------------------------------------------------------------
