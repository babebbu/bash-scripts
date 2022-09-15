#!/bin/bash

read -p 'Database Name (Enter name of database to create, Enter * to bypass database creation): ' DB_NAME
read -p 'Database User: ' DB_USER
read -p -s 'Database Password: ' DB_PASS
read -p -s 'Confirm Password: ' CONFIRM_PASS

if [[ "$DB_PASS" != "$DB_PASS" ]]; then
    echo "Input Password Mismatched"
    exit
fi

echo "Installing MariaDB Server"
apt install mariadb-server -y

MARIADB_CONFIG_PATH=/etc/mysql/mariadb.conf.d/99-custom.conf
touch $MARIADB_CONFIG_PATH

CONFIG_LINES=(
    "[mysqld]"
    "bind-address = 0.0.0.0"
    "default-storage-engine = innodb"
    "innodb_file_per_table = on"
    "character-set-server = utf8mb4"
    "collation-server = utf8mb4_unicode_ci"
)

for line in "${CONFIG_LINES[@]}"
do
    echo $line >> $MARIADB_CONFIG_PATH
done

systemctl restart mariadb
systemctl enable mariadb

if [[ "$CREATE_DATABASE" != "*" ]]; then
  mysql --execute "CREATE DATABASE ${DB_NAME}"
fi

mysql --execute "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';"
mysql --execute "FLUSH PRIVILEGES;"

echo "Installation Complete"
