#! /bin/bash
./build_pack.sh $1

apt-get install apache2 -y

echo Coping files
cp -a ./www/. /var/www/html

echo allow setting headers

a2enmod headers
service apache2 restart
echo done
