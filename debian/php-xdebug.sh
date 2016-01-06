#!/usr/bin/env bash
set -e

# install net-tools temporary if missing
NETTOOLS_UNINSTALL=0
if [ ! $(which netstat) ]; then
    echo "netstat required for determining xdebug.remote_host value. Temporary installing net-tools ..."
    apt-get install -qq net-tools > /dev/null 2>&1
    NETTOOLS_UNINSTALL=1
fi


[ -z "$XDEBUG_IDEKEY"        ] && XDEBUG_IDEKEY="IDEA"
[ -z "$XDEBUG_ENV_FILE"      ] && XDEBUG_ENV_FILE="/etc/profile.d/xdebug.sh"
[ -z "$XDEBUG_ENV_PARAMS"    ] && XDEBUG_ENV_PARAMS="PHP_IDE_CONFIG=\"serverName=\${DOMAINS%% *}\" XDEBUG_CONFIG=\"idekey=${XDEBUG_IDEKEY}\""
[ -z "$XDEBUG_CONFIG_FILE"   ] && XDEBUG_CONFIG_FILE="/etc/php5/conf.d/xdebug.ini"
[ -z "$XDEBUG_CONFIG_PARAMS" ] && XDEBUG_CONFIG_PARAMS="
xdebug.remote_enable=true
xdebug.remote_autostart=0
xdebug.remote_connect_back=0
xdebug.max_nesting_level=500
xdebug.remote_host=$(netstat -rn | awk '{print $2;}' | sed -n '3p')
xdebug.idekey=${XDEBUG_IDEKEY}"


# uninstall previously temporary installed net-tools
if [ "$NETTOOLS_UNINSTALL" -eq 1 ]; then
    apt-get purge -qq net-tools > /dev/null 2>&1
    echo "Removed net-tools."
fi



echo ">>> Installing xdebug"
apt-get install -qq php5-xdebug


echo ">>> Setting xdebug configuration"
mkdir -p $(dirname "$XDEBUG_CONFIG_FILE")
touch $XDEBUG_CONFIG_FILE

for XDEBUG_CONFIG_PARAM in $XDEBUG_CONFIG_PARAMS; do
    grep -q "$XDEBUG_CONFIG_PARAM" $XDEBUG_CONFIG_FILE || echo "$XDEBUG_CONFIG_PARAM" >> "$XDEBUG_CONFIG_FILE"
done

echo $XDEBUG_CONFIG_PARAMS | sed 's/ /\n/g'


echo ">>> Setting xdebug environment variables"
echo "export $XDEBUG_ENV_PARAMS" > "$XDEBUG_ENV_FILE"
echo $XDEBUG_ENV_PARAMS

echo ">>> Adding alias command 'curl_xdebug' for xdebug enabled curl requests"
echo "alias curl_xdebug=\"curl -b \\\"XDEBUG_SESSION=${XDEBUG_IDEKEY}\\\"\"" >> "$XDEBUG_ENV_FILE"
