#!/usr/bin/env bash
set -e

[ -z "$SKIP_DB_SETUP"      ] && SKIP_DB_SETUP=0
[ -z "$TYPO3_DB_NAME"      ] && TYPO3_DB_NAME="typo3"
[ -z "$TYPO3_DB_USER"      ] && TYPO3_DB_USER="typo3"
[ -z "$TYPO3_DB_PASSWORD"  ] && TYPO3_DB_PASSWORD="typo3"
[ -z "$APACHE_USER"        ] && APACHE_USER="vagrant"
[ -z "$APACHE_GROUP"       ] && APACHE_GROUP="www-data"
[ -z "$SKIP_VHOST_SETUP"   ] && SKIP_VHOST_SETUP=0
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
if [ "$SKIP_DB_SETUP" -ne 1 ]; then
    echo ">>> Creating mysql database '$TYPO3_DB_NAME' and user '$TYPO3_DB_USER'"
    if [ -d "/var/lib/mysql/$TYPO3_DB_NAME" ]; then
        echo "Database already exists. We expect that the user also already exists (without checking further)."
    else
        MYSQL_QUERY="CREATE DATABASE \`$TYPO3_DB_NAME\` CHARACTER SET utf8; \
            CREATE USER \`$TYPO3_DB_USER\`@'%' IDENTIFIED BY '$TYPO3_DB_PASSWORD'; \
            GRANT USAGE ON *.* TO \`$TYPO3_DB_USER\`@'%' IDENTIFIED BY '$TYPO3_DB_PASSWORD'; \
            GRANT ALL PRIVILEGES ON \`$TYPO3_DB_NAME\`.* TO \`$TYPO3_DB_USER\`@'%';"

        if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
            mysql -uroot -e "$MYSQL_QUERY"
        else
            mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "$MYSQL_QUERY"
        fi
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
if [ "$SKIP_VHOST_SETUP" -ne 1 ]; then
    echo ">>> Linking projects apache vhost config if it exists"
    VHOST_LINK_DESTINATION="/etc/apache2/sites-enabled/${PROJECT_VHOST_NAME}.conf"
    [ -f "$PROJECT_VHOST_FILE" ] && [ ! -f "$VHOST_LINK_DESTINATION" ] \
        && ln -fs "$PROJECT_VHOST_FILE" "$VHOST_LINK_DESTINATION"
fi


# stop apache
service apache2 stop


# overwrite apache2 run user setting
sed -i "s/APACHE_RUN_USER=.*$/APACHE_RUN_USER=$APACHE_USER/g" /etc/apache2/envvars

# overwrite apache2 run group setting
sed -i "s/APACHE_RUN_GROUP=.*$/APACHE_RUN_GROUP=$APACHE_GROUP/g" /etc/apache2/envvars

# change apache2 lock dir owner
chown $APACHE_USER /var/lock/apache2/


# start apache
service apache2 start
