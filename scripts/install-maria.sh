#!/usr/bin/env bash
# Check If MariaDB Has Been Installed
MariaDBInstalled=$(yum info MariaDB-server | grep Repo | awk '{ print $3 }')
if [ ${MariaDBInstalled} == 'installed' ]
then
    echo "MariaDB already installed."
    exit 0
fi

touch /home/vagrant/.maria

# Remove MySQL
yum erase -y -q mysql-community-client mysql-community-common mysql-community-libs mysql-community-libs-compat mysql-community-server mysql57-community-release

rm -rf /var/lib/mysql
rm -rf /var/lib/mysql-files
rm -rf /var/lib/mysql-keyring
rm -rf /var/log/mysqld.log
rm -rf /etc/my.cnf
rm -rf /etc/my.cnf.d
rm -rf /home/vagrant/.my.cnf
rm -rf /home/vagrant/.mysql_history
echo "MySQL uninstalled."

# Add MariaDB GPG Key
rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB

# Add MariaDB YUM Repository
touch /etc/yum.repos.d/MariaDB.repo

echo '# MariaDB 10.2 CentOS repository list - created 2017-09-04 03:34 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.2/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1' >> /etc/yum.repos.d/MariaDB.repo
echo "MariaDB YUM Repository installed."

# Install MariaDB
yum -y -q install MariaDB-server MariaDB-client
echo "MariaDB installed."

# Start MariaDB & Set auto-start on system boot
systemctl start mariadb.service
systemctl enable mariadb.service
echo "MariaDB started & auto-start on system boot set."

# Configure and Secure MariaDB
mysql --user=root <<_EOF_
UPDATE mysql.user SET Password=PASSWORD('secret') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_
systemctl restart mariadb.service
echo "MariaDB Configured and Secured."

# Configure MariaDB Remote Access
sudo mysql --user=root --password='secret' -e "GRANT ALL ON *.* TO root@'0.0.0.0' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
sudo mysql --user=root --password='secret' -e "CREATE USER 'homestead'@'0.0.0.0' IDENTIFIED BY 'secret';"
sudo mysql --user=root --password='secret' -e "GRANT ALL ON *.* TO 'homestead'@'0.0.0.0' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
sudo mysql --user=root --password='secret' -e "GRANT ALL ON *.* TO 'homestead'@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
sudo mysql --user=root --password='secret' -e "FLUSH PRIVILEGES;"
systemctl restart mariadb.service
echo "MariaDB Remote Access Configured."
