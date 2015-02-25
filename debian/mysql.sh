#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive

if [ ! -z "$MYSQL_ROOT_PASSWORD" ]; then
    echo "mysql-server mysql-server/root_password select "$MYSQL_ROOT_PASSWORD"" | debconf-set-selections
    echo "mysql-server mysql-server/root_password_again select "$MYSQL_ROOT_PASSWORD"" | debconf-set-selections
fi

echo ">>> Installing mysql-server and mysql-client"
apt-get install -qq mysql-server mysql-client

# force restart to avoid the following connection problem:
#   ERROR 2002 (HY000): Can’t connect to local MySQL server through socket ‘/var/run/mysqld/mysqld.sock’ (2)
/etc/init.d/mysql restart
