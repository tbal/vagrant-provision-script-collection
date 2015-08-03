#!/usr/bin/env bash
set -e

[ -z "$TOMCAT_VERSION"                   ] && TOMCAT_VERSION=7
[ -z "$SOLR_TOMCAT_PROJECT_ROOT_DIR"     ] && SOLR_TOMCAT_PROJECT_ROOT_DIR="/vagrant/"
[ -z "$SOLR_TOMCAT_INSTALL_SCRIPT"       ] && SOLR_TOMCAT_INSTALL_SCRIPT="${SOLR_TOMCAT_PROJECT_ROOT_DIR}htdocs/typo3conf/ext/solr/Resources/Shell/install-solr-existing-tomcat.sh"
[ -z "$SOLR_TOMCAT_INSTALL_DIR"          ] && SOLR_TOMCAT_INSTALL_DIR="/opt/solr-tomcat/"
[ -z "$SOLR_TOMCAT_ENABLE_REMOTE_ACCESS" ] && SOLR_TOMCAT_ENABLE_REMOTE_ACCESS=0 # 0=localhost only, 1=remote access allowed
[ -z "$SOLR_LANGUAGES"                   ] && SOLR_LANGUAGES="german" # separated by whitespace, see EXT:solr for supported languages
[ -z "$SOLR_CORES_CONFIG_FILE"           ] && SOLR_CORES_CONFIG_FILE="${SOLR_TOMCAT_PROJECT_ROOT_DIR}conf/solr-cores.xml"
[ -z "$SOLR_LOG_DIR"                     ] && SOLR_LOG_DIR="${SOLR_TOMCAT_PROJECT_ROOT_DIR}logs/"


echo ">>> Installing tomcat"
apt-get install -y tomcat${TOMCAT_VERSION}

echo ">>> Setting correct JAVA_HOME environment variable for tomcat"
sed -i "s,\(#\| \)*JAVA_HOME=.*$,JAVA_HOME=$(readlink -f /usr/bin/javac | sed 's:/bin/javac::'),g" /etc/default/tomcat${TOMCAT_VERSION}

if ! grep -q "CATALINA_OUT=" /etc/default/tomcat${TOMCAT_VERSION} > /dev/null; then
    echo ">>> Disabling logging to catalina.out log file (too noisy, gets very big in short time)"
    grep -q "CATALINA_OUT=" /etc/default/tomcat${TOMCAT_VERSION} || echo "CATALINA_OUT=/dev/null" >> /etc/default/tomcat${TOMCAT_VERSION}
fi


echo ">>> Installing solr using EXT:solr installation script"

# install unzip temporary if missing
UNZIP_UNINSTALL=0
if [ ! "$(dpkg -l unzip > /dev/null 2>&1)" ]; then
    echo "unzip required for installing solr/tomcat via EXT:solr installation script. Temporary installing unzip ..."
    apt-get install -qq unzip > /dev/null 2>&1
    UNZIP_UNINSTALL=1
fi

# run installation script
echo "Running ${SOLR_TOMCAT_INSTALL_SCRIPT} (languages: ${SOLR_LANGUAGES}) ..."
# do some adjustments on install script for better output
cat $SOLR_TOMCAT_INSTALL_SCRIPT \
| sed -e "s/tomcat6/tomcat${TOMCAT_VERSION}/g" -e 's/clear//g' -e 's/unzip -q/unzip -oq/g' -e 's/wget /wget -N /g' -e 's/ | progressfilt//g' \
> /tmp/install-solr-tomcat.sh \
&& chmod +x /tmp/install-solr-tomcat.sh

# actually run the install script and check if it failed
set +e
/tmp/install-solr-tomcat.sh ${SOLR_LANGUAGES}
CHECK=$?
set -e
SOLR_TOMCAT_INSTALL_SCRIPT_ERROR=0
if [ $CHECK -ne "0" ]; then
    # install script failed
    SOLR_TOMCAT_INSTALL_SCRIPT_ERROR=1
fi

rm /tmp/install-solr-tomcat.sh

# uninstall previously temporary installed unzip
if [ "$UNZIP_UNINSTALL" -eq 1 ]; then
    apt-get purge -qq unzip > /dev/null 2>&1
    echo "Removed unzip."
fi

if [ "$SOLR_TOMCAT_INSTALL_SCRIPT_ERROR" -eq 1 ]; then
    echo "An error occured during install script execution. Aborting."
    exit 1
fi


echo ">>> Using solr cores config from file ${SOLR_CORES_CONFIG_FILE}"
cp ${SOLR_CORES_CONFIG_FILE} ${SOLR_TOMCAT_INSTALL_DIR}solr/solr.xml


echo ">>> Changing solr log output directory to ${SOLR_LOG_DIR}"
sed -i "s,solr\.log=.*$,solr.log=${SOLR_LOG_DIR},g" /usr/share/tomcat${TOMCAT_VERSION}/lib/log4j.properties


if [ "$SOLR_TOMCAT_ENABLE_REMOTE_ACCESS" -eq "1" ]; then
    echo ">>> Setting solr (actually tomcat) to allow remote access"
    ADDRESS="0.0.0.0"
else
    echo ">>> Setting solr (actually tomcat) to allow access from localhost only"
    ADDRESS="127.0.0.1"
fi
if grep -qi "address=" /var/lib/tomcat${TOMCAT_VERSION}/conf/server.xml > /dev/null; then
    sed -i "s/address=\".*\"/address=\"${ADDRESS}\"/g" /var/lib/tomcat${TOMCAT_VERSION}/conf/server.xml
else
    sed -i "s/\(port=\"8080\"\)/\1 address=\"${ADDRESS}\"/g" /var/lib/tomcat${TOMCAT_VERSION}/conf/server.xml
fi


echo ">>> Restarting tomcat to apply changed settings"
/etc/init.d/tomcat${TOMCAT_VERSION} restart
