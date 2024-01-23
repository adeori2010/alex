#!/bin/bash
# update software repositories
sudo apt update
# install available software updates
sudo apt upgrade -y
# install prerequisites
sudo apt install apt-utils arp-scan dnsutils net-tools python3 -y
# install web/db components
sudo apt install lighttpd php php-cgi php-fpm php-sqlite3 sqlite3 -y
# clean apt package cache
sudo apt clean
# download the latest release
wget -O ./pialert.tar https://github.com/pucherot/Pi.Alert/raw/main/tar/pialert_latest.tar
# create target directory
sudo mkdir /var/www/pialert
# create logs directory
sudo mkdir /var/log/pialert
# extract the downloaded tar to /var/www/pialert
sudo tar xf ./pialert.tar -C /var/www/pialert --strip-components=1
# set the owner of the pialert directory
sudo chown -R www-data:www-data /var/www/pialert
# update pialert path in conf file
sed -i 's/\/home\/pi\/pialert/\/var\/www\/pialert/' /var/www/pialert/config/pialert.conf
# update pialert path in cron jobs
sed -i 's/python ~\/pialert\/back\/pialert.py/python3 \/var\/www\/pialert\/back\/pialert.py/g' /var/www/pialert/install/pialert.cron
# update log paths for cron jobs
sed -i 's/~\/pialert\/log\//\/var\/log\/pialert\//g' /var/www/pialert/install/pialert.cron
# create cronjob schedule
(crontab -l 2>/dev/null; cat /var/www/pialert/install/pialert.cron) | sudo crontab -
# create symbolic link to pialert
sudo ln -s /var/www/pialert/front/ /var/www/html/pialert
# copy pialert lighttpd conf
sudo cp /var/www/pialert/install/pialert_front.conf /etc/lighttpd/conf-available
# enable the pialert conf
sudo ln -s /etc/lighttpd/conf-available/pialert_front.conf /etc/lighttpd/conf-enabled/pialert_front.conf
# enable lighttpd fastcgi
sudo lighttpd-enable-mod fastcgi-php
# restart lighttpd service
sudo systemctl restart lighttpd
