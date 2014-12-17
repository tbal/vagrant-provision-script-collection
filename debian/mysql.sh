#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive

if [ ! -z "$MYSQL_ROOT_PASSWORD" ]; then
    echo "mysql-server mysql-server/root_password select "$MYSQL_ROOT_PASSWORD"" | debconf-set-selections
    echo "mysql-server mysql-server/root_password_again select "$MYSQL_ROOT_PASSWORD"" | debconf-set-selections
fi

echo ">>> Installing mysql-server and mysql-client"
apt-get install -qq mysql-server mysql-client
