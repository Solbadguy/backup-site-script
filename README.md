# backup-site-script
 This is a simple script that dumps the mysql database, archives the site files, moves them to a separate folder, archives and sends them to the remote repository through SCP

-----
Necessary actions:

mkdir ~/BACKUP

apt install sendmail -y

apt install mailutils -y

------

Scripts can be stored in a separate folder or in the user's home folder, the main thing is that they are nearby

------
Let's make them executable:

chmod +x sendemail.sh

chmod +x backup-site.sh

------

We will send a test letter

./sendemail.sh TEST test-message!

------
After checking their work, I usually add the task to the crontab file.

------

Instead of email, you can use the functionality that Telegram offers us.

Read how to create such a notification at the link.

https://admin.netlab-kursk.ru/uchim-sistemu-dokladyvat-o-sobytiyax-v-telegram/
