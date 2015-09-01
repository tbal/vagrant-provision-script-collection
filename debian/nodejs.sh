#!/usr/bin/env bash
set -e

[ -z "$NODEJS_VERSION"    ] && NODEJS_VERSION="0.12"
[ -z "$NODEJS_SOURCE_URL" ] && NODEJS_SOURCE_URL="https://deb.nodesource.com/setup_${NODEJS_VERSION}"
[ -z "$NODEJS_UPDATE_NPM" ] && NODEJS_UPDATE_NPM=1


echo ">>> Installing Node.js using source script $NODEJS_SOURCE_URL"

# install curl temporary if missing
CURL_UNINSTALL=0
if [ ! $(which curl) ]; then
    echo "curl required for installing Node.js. Temporary installing curl ..."
    apt-get install -qq curl > /dev/null 2>&1
    CURL_UNINSTALL=1
fi

if [ ! `which nodejs || exit 1` ]; then
    curl -sL "$NODEJS_SOURCE_URL" | bash -
    apt-get install -qq nodejs

    echo "Done."
else
    echo "Node.js is already installed.";
fi

# npm gets updated more frequently than Node.js, make sure it's the latest version
if [ "$NODEJS_UPDATE_NPM" -eq "1" ]; then
    echo ">>> Updating npm"
    npm install npm -g
fi

# uninstall previously temporary installed curl
if [ "$CURL_UNINSTALL" -eq 1 ]; then
    apt-get purge -qq curl > /dev/null 2>&1
    echo "Removed curl."
fi