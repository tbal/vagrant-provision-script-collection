#!/usr/bin/env bash
set -e

[ -z "$COMPOSER_INSTALLER_URL" ] && COMPOSER_INSTALLER_URL="https://getcomposer.org/installer"
[ -z "$COMPOSER_INSTALL_DIR"   ] && COMPOSER_INSTALL_DIR="/usr/local/bin"


echo ">>> Installing Composer"

# install curl temporary if missing
CURL_UNINSTALL=0
if [ ! $(which curl) ]; then
    echo "curl required for installing Composer Temporary installing curl ..."
    apt-get install -qq curl > /dev/null 2>&1
    CURL_UNINSTALL=1
fi

# download and run installer script
curl -sS ${COMPOSER_INSTALLER_URL} | php -- --install-dir="${COMPOSER_INSTALL_DIR}" --filename=composer
echo "Installed Composer to ${COMPOSER_INSTALL_DIR}."

# uninstall previously temporary installed curl
if [ "$CURL_UNINSTALL" -eq 1 ]; then
    apt-get purge -qq curl > /dev/null 2>&1
    echo "Removed curl."
fi
