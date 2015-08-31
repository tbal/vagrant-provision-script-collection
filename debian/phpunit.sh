#!/usr/bin/env bash
set -e

[ -z "$PHPUNIT_PHAR_URL" ] && PHPUNIT_PHAR_URL="https://phar.phpunit.de/phpunit.phar"
[ -z "$PHPUNIT_BIN_PATH" ] && PHPUNIT_BIN_PATH="/usr/local/bin/phpunit"


echo ">>> Installing PHPUnit"

# install curl temporary if missing
CURL_UNINSTALL=0
if [ ! $(which curl) ]; then
    echo "curl required for installing PHPUnit. Temporary installing curl ..."
    apt-get install -qq curl > /dev/null 2>&1
    CURL_UNINSTALL=1
fi

if [ ! `which phpunit || exit 1` ]; then
    curl -s -o $PHPUNIT_BIN_PATH $PHPUNIT_PHAR_URL && \
    chmod +x $PHPUNIT_BIN_PATH

    echo "Done."
else
    echo "PHPUnit is already installed.";
fi

# uninstall previously temporary installed curl
if [ "$CURL_UNINSTALL" -eq 1 ]; then
    apt-get purge -qq curl > /dev/null 2>&1
    echo "Removed curl."
fi