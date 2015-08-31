#!/usr/bin/env bash
set -e

[ -z "$GENGHIS_SOURCE_URL"   ] && GENGHIS_SOURCE_URL="https://github.com/bobthecow/genghis/raw/master/genghis.php"
[ -z "$GENGHIS_INSTALL_PATH" ] && GENGHIS_INSTALL_PATH="/var/www/genghis.php"


echo ">>> Installing Genghis"

# install curl temporary if missing
CURL_UNINSTALL=0
if [ ! $(which curl) ]; then
    echo "curl required for installing Genghis. Temporary installing curl ..."
    apt-get install -qq curl > /dev/null 2>&1
    CURL_UNINSTALL=1
fi

# download genghis to target install directory
mkdir -p `dirname "$GENGHIS_INSTALL_PATH"`
curl -f -L -o "$GENGHIS_INSTALL_PATH" $GENGHIS_SOURCE_URL
echo "Installed Genghis to ${GENGHIS_INSTALL_PATH}."

# uninstall previously temporary installed curl
if [ "$CURL_UNINSTALL" -eq 1 ]; then
    apt-get purge -qq curl > /dev/null 2>&1
    echo "Removed curl."
fi