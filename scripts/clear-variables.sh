#!/usr/bin/env bash

# Clear The Old Environment Variables

sed -i '/# Set Homestead Environment Variable/,+1d' /home/vagrant/.profile
sed -i '/env\[.*/,+1d' /etc/opt/remi/php56/php-fpm.conf
sed -i '/env\[.*/,+1d' /etc/opt/remi/php70/php-fpm.conf
sed -i '/env\[.*/,+1d' /etc/opt/remi/php71/php-fpm.conf
