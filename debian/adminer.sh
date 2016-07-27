#!/usr/bin/env bash
set -e

[ -z "$ADMINER_VERSION"     ] && ADMINER_VERSION="4.1.0"
[ -z "$ADMINER_INSTALL_DIR" ] && ADMINER_INSTALL_DIR="/var/www/adminer"
[ -z "$ADMINER_SKIN_URL"    ] && ADMINER_SKIN_URL="https://raw.github.com/vrana/adminer/master/designs/pepa-linha/adminer.css"

# remove trailing slash if set
ADMINER_INSTALL_DIR="$(echo "$ADMINER_INSTALL_DIR" | sed 's/\/$//g')"


echo ">>> Installing adminer $ADMINER_VERSION"

# install curl temporary if missing
CURL_UNINSTALL=0
if [ ! $(which curl) ]; then
    echo "curl required for installing adminer. Temporary installing curl ..."
    apt-get install -qq curl > /dev/null 2>&1
    CURL_UNINSTALL=1
fi

# download adminer and it's skin to target install directory
mkdir -p "$ADMINER_INSTALL_DIR"
curl -f -L -o "${ADMINER_INSTALL_DIR}/index.php" \
     "http://www.adminer.org/static/download/${ADMINER_VERSION}/adminer-${ADMINER_VERSION}.php"
curl -f -L -o "${ADMINER_INSTALL_DIR}/adminer.css" "$ADMINER_SKIN_URL"
echo "Installed adminer to ${ADMINER_INSTALL_DIR}/."

# uninstall previously temporary installed curl
if [ "$CURL_UNINSTALL" -eq 1 ]; then
    apt-get purge -qq curl > /dev/null 2>&1
    echo "Removed curl."
fi
