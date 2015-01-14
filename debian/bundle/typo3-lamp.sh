#!/usr/bin/env bash
set -e

[ -z "$TYPO3_DB_NAME"      ] && TYPO3_DB_NAME="typo3"
[ -z "$TYPO3_DB_USER"      ] && TYPO3_DB_USER="typo3"
[ -z "$TYPO3_DB_PASSWORD"  ] && TYPO3_DB_PASSWORD="typo3"
[ -z "$PROJECT_VHOST_FILE" ] && PROJECT_VHOST_FILE="/vagrant/conf/httpd-vhost.vagrant.conf"
[ -z "$PROJECT_VHOST_NAME" ] && PROJECT_VHOST_NAME="typo3"


BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

###
# BASE
##
source "$BASEDIR/../base.sh"
source "$BASEDIR/../common.sh"
source "$BASEDIR/../apache.sh"
source "$BASEDIR/../php.sh"
source "$BASEDIR/../mysql.sh"
source "$BASEDIR/../php-mysql.sh"


###
# TYPO3 SPECIFIC
##

# create mysql user and database
echo ">>> Creating mysql database '$TYPO3_DB_NAME' and user '$TYPO3_DB_USER'"
if [ -d "/var/lib/mysql/$TYPO3_DB_NAME" ]; then
    echo "Database already exists. We expect that the user also already exists (without checking further)."
else
    MYSQL_QUERY="CREATE DATABASE $TYPO3_DB_NAME CHARACTER SET utf8; \
        CREATE USER '$TYPO3_DB_USER'@'%' IDENTIFIED BY '$TYPO3_DB_PASSWORD'; \
        GRANT USAGE ON *.* TO '$TYPO3_DB_USER'@'%' IDENTIFIED BY '$TYPO3_DB_PASSWORD'; \
        GRANT ALL PRIVILEGES ON $TYPO3_DB_NAME.* TO '$TYPO3_DB_USER'@'%';"

    if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
        mysql -uroot -e "$MYSQL_QUERY"
    else
        mysql -uroot -p"$MYSQL_ROOT_USER" -e "$MYSQL_QUERY"
    fi
fi


# enable apache2 modules
echo ">>> Enabling apache2 modules"
a2enmod rewrite expires headers


# install additional packages
INSTALL_PHP_MODULES="imagemagick php5-curl php5-gd php5-mcrypt"
echo ">>> Installing additional packages required for TYPO3: $INSTALL_PHP_MODULES"
apt-get install -qq $INSTALL_PHP_MODULES


# link apache vhost
echo ">>> Linking projects apache vhost config if it exists"
VHOST_LINK_DESTINATION="/etc/apache2/sites-enabled/$PROJECT_VHOST_NAME"
[ -f "$PROJECT_VHOST_FILE" ] && [ ! -f "$VHOST_LINK_DESTINATION" ] \
    && ln -fs "$PROJECT_VHOST_FILE" "$VHOST_LINK_DESTINATION"


# restart apache
source "$BASEDIR/../apache-restart.sh"