#!/usr/bin/env bash

# Using Debian Wheezy 7.x

apt-get update

# provisioning is unattended, set non-interactive mode
export DEBIAN_FRONTEND=noninteractive


# set german keyboard layout
#sed -i "s/XKBLAYOUT=.*$/XKBLAYOUT=\"de\"/" /etc/default/keyboard
#echo "console-setup console-setup/codeset47 select . Combined - Latin; Slavic Cyrillic; Greek" | debconf-set-selections
#echo "console-setup console-setup/fontface47 select Fixed" | debconf-set-selections
#echo "console-setup console-setup/fontsize-text47 select 16" | debconf-set-selections
#dpkg-reconfigure --frontend noninteractive console-setup
#[ -f /etc/init.d/keyboard-setup ] && /etc/init.d/keyboard-setup restart


# set correct timezone
echo "Europe/Berlin" | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata



# set german mirrors
#sed -i "s/\(\/\|\.\)us\./\1de\./g" /etc/apt/sources.list

# add additional repositories to aptitute package sources
#if [ "$USING_UBUNTU" != "1" ]; then
#    TEMP_IFS=$IFS
#IFS="
#"
#    for ADD_APT_SOURCES_ENTRY in $ADD_APT_SOURCES_ENTRIES; do
#        grep -q "$ADD_APT_SOURCES_ENTRY" /etc/apt/sources.list || echo "$ADD_APT_SOURCES_ENTRY" >> /etc/apt/sources.list
#    done
#    IFS=$TEMP_IFS
#fi

# update package list
#apt-get update --fix-missing

# nice to have tools
apt-get install -qq -y htop vim curl



# set installation selections for mysql-server
#echo "mysql-server mysql-server/root_password select $DB_ROOT_PASSWD" | debconf-set-selections
#echo "mysql-server mysql-server/root_password_again select $DB_ROOT_PASSWD" | debconf-set-selections

# install typical LAMP environment
apt-get install -qq -y apache2 mysql-server mysql-client imagemagick php5 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-mysql
# php-apc
# php5-suhosin



# install postfix
# TODO/FIXME: postfix/sendmail: http://serverfault.com/questions/243638/automate-postfix-instalaltion-with-debconf-set-selections

#echo "postfix postfix/mailname string fette.lmt.dev" | debconf-set-selections
#echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
#apt-get install -qq -y postfix

# fix postfix connection timeouts caused by nameserver unable to resolv mx records
# see: https://www.virtualbox.org/ticket/11540
# FIXME: kills local name resolution
#sed -i -e "1i nameserver 8.8.8.8" /etc/resolv.conf



# xdebug
apt-get install -qq -y php5-xdebug
XDEBUG_CONFIG_FILE=/etc/php5/conf.d/xdebug.ini
XDEBUG_CONFIG_PARAMS="xdebug.remote_enable=true xdebug.remote_connect_back=1 xdebug.max_nesting_level=500"
for CONFIG_PARAM in $XDEBUG_CONFIG_PARAMS; do
    [ -f $XDEBUG_CONFIG_FILE ] && grep -q "$CONFIG_PARAM" $XDEBUG_CONFIG_FILE || echo "$CONFIG_PARAM" >> $XDEBUG_CONFIG_FILE
done


# remove anonymous mysql accounts (usually on ubuntu)
#mysql -uroot -p$DB_ROOT_PASSWD -e "DROP USER ''@'localhost'; \
#    DROP USER ''@'`cat /etc/hostname`';"



# set installation selections for phpmyadmin
#echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
#echo "phpmyadmin phpmyadmin/app-password-confirm password $DB_ROOT_PASSWD" | debconf-set-selections
#echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DB_ROOT_PASSWD" | debconf-set-selections
#echo "phpmyadmin phpmyadmin/mysql/app-pass password $DB_ROOT_PASSWD" | debconf-set-selections
#echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections

# install phpmyadmin
#apt-get install -y phpmyadmin



# install java
#if [ ! `which java || exit 1` ]; then
#    if [ "$USING_UBUNTU" = "1" ]; then
#        apt-get install -qq -y python-software-properties
#        add-apt-repository -y ppa:webupd8team/java
#        apt-get update
#
#        echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
#        echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections
#        apt-get install -qq -y -q oracle-java6-installer
#
#        JAVA_HOME=/usr/lib/jvm/java-6-oracle
#    else
#        echo "sun-java6-jre shared/accepted-sun-dlj-v1-1 boolean true" | debconf-set-selections
#        apt-get install -qq -y sun-java6-jre
#
#        JAVA_HOME=/usr/lib/jvm/java-6-sun
#    fi
#
#    # persist JAVA_HOME
#    grep -q "JAVA_HOME" /etc/profile || echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile
#    source /etc/profile
#fi


# enable common used php mods
php5enmod curl mcrypt



# set run user/group to vagrant as our application is mounted by vagrant user+group
#/etc/init.d/apache2 stop
#sed -i "s/=www-data/=$HTTPD_USER/" /etc/apache2/envvars

# Fix message: /var/lock/apache2 already exists but is not a directory owned by vagrant.
#chown $HTTPD_USER /var/lock/apache2/

# disable default apache vhost
#a2dissite default

# enable common used apache modules
a2enmod rewrite expires



# enable project specific apache modules
a2enmod headers


# FIXME TEST DUMMY
/etc/init.d/apache2 restart
exit


# git it
apt-get install -qq -y git-core

if [ ! -f /home/vagrant/.ssh/id_rsa.pub ]; then
    su - $HTTPD_USER -c "mkdir ~/.ssh/ 2> /dev/null"

    if [ -d "/hosthome" ]; then
        su - $HTTPD_USER -c "cp /hosthome/.ssh/id_rsa{,.pub} ~/.ssh/"
    else
        su - $HTTPD_USER -c "cp /vagrant/.ssh/id_rsa{,.pub} ~/.ssh/ && chmod 600 ~/.ssh/id_rsa{,.pub}"
    fi
fi

if [ ! -f /home/vagrant/.gitconfig ]; then
    if [ -d "/hosthome" ]; then
        su - $HTTPD_USER -c "ln -s /hosthome/.gitconfig ~/.gitconfig"
    else
        su - $HTTPD_USER -c "ln -s /vagrant/.gitconfig ~/.gitconfig"
    fi
fi

if [ ! -d "$PROJECT_DIR/.git" ]; then
    su - $HTTPD_USER -c "mkdir -p $PROJECT_DIR"
    # TODO: determine Host by parsing $GIT_PROJECT_URL and using string between @ and :
    su - $HTTPD_USER -c "echo -e \"Host gitlab.cosmocode.de\n\tStrictHostKeyChecking no\n\" >> ~/.ssh/config"
    su - $HTTPD_USER -c "git clone $GIT_PROJECT_URL -b $GIT_PROJECT_BRANCH $PROJECT_DIR"
fi


# setup project specific configuration
[ -f $PROJECT_DIR/conf/httpd-vhost.conf ] || su - $HTTPD_USER -c "cp $PROJECT_DIR/conf/httpd-vhost.vagrant.conf $PROJECT_DIR/conf/httpd-vhost.conf"
[ -f $PROJECT_DIR/conf/typo3_constants_env.ts ] || su - $HTTPD_USER -c "cp $PROJECT_DIR/conf/typo3_constants_env.vagrant.ts $PROJECT_DIR/conf/typo3_constants_env.ts"
[ -f $PROJECT_DIR/htdocs/typo3conf/localconf_env.php ] || su - $HTTPD_USER -c "cp $PROJECT_DIR/htdocs/typo3conf/localconf_env.vagrant.php $PROJECT_DIR/htdocs/typo3conf/localconf_env.php"

# substitute placeholders
sed -i "s,SETME-PROJDIR,$PROJECT_DIR," $PROJECT_DIR/conf/httpd-vhost.conf


# enable project vhost
ln -fs $PROJECT_DIR/conf/httpd-vhost.conf /etc/apache2/sites-enabled/www


if [ ! -d /var/lib/mysql/$DB_NAME ]; then
    # add project specific mysql database and user
    mysql -uroot -p$DB_ROOT_PASSWD -e "CREATE DATABASE $DB_NAME CHARACTER SET utf8; \
        CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWD'; \
        GRANT USAGE ON *.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWD'; \
        GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"

    # import database
    if [ -f /vagrant/db.last.full.sql.gz ]; then
        echo "Important Database.."
        gunzip < /vagrant/db.last.full.sql.gz | mysql -u$DB_USER -p$DB_PASSWD $DB_NAME
        echo "Done."
    fi
fi

# extract content files
if [ -f /vagrant/fs.last.full.tgz ]; then
    echo "Extracting content files.."
    su - $HTTPD_USER -c "cd $PROJECT_DIR && tar -xvkzf /vagrant/fs.last.full.tgz"
    echo "Done."
fi

# set domain records
mysql -u$DB_USER -p$DB_PASSWD $DB_NAME -e "\
    UPDATE sys_domain SET domainName='fette.lmt.dev'    WHERE domainName='www.fette-compacting.de'; \
    UPDATE sys_domain SET domainName='en.fette.lmt.dev' WHERE domainName='www.fette-compacting.com'; \
    UPDATE sys_domain SET domainName='group.lmt.dev'    WHERE domainName='www.lmt-group.de'; \
    UPDATE sys_domain SET domainName='en.group.lmt.dev' WHERE domainName='www.lmt-group.com'; \
    UPDATE sys_domain SET domainName='tools.lmt.dev'    WHERE domainName='www.lmt-tools.de'; \
    UPDATE sys_domain SET domainName='en.tools.lmt.dev' WHERE domainName='www.lmt-tools.com';"

# set project cron
if [ ! "`crontab -l -u $HTTPD_USER | grep dispatch`" ]; then
    { crontab -l -u $HTTPD_USER; echo "*/5 * * * * $PROJECT_DIR/htdocs/typo3/cli_dispatch.phpsh scheduler"; } | crontab -u $HTTPD_USER -
    crontab -l -u $HTTPD_USER
fi



# (re)start apache
/etc/init.d/apache2 restart

# (re)start solr
su - $HTTPD_USER -c "export SOLR_USER=$HTTPD_USER && export SOLR_ARGS=\"-Xms${SOLR_MEM}m -Xmx${SOLR_MEM}m\" && $PROJECT_DIR/bin/solr.sh restart"
