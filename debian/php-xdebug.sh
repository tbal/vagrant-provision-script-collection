#!/usr/bin/env bash
set -e

[ -z "$XDEBUG_CONFIG_FILE"   ] && XDEBUG_CONFIG_FILE="/etc/php5/conf.d/xdebug.ini"
[ -z "$XDEBUG_CONFIG_PARAMS" ] && XDEBUG_CONFIG_PARAMS="xdebug.remote_enable=true xdebug.remote_connect_back=1 xdebug.max_nesting_level=500"


echo ">>> Installing xdebug"
apt-get install -qq php5-xdebug


echo ">>> Setting xdebug configuration"
mkdir -p $(dirname "$XDEBUG_CONFIG_FILE")
touch $XDEBUG_CONFIG_FILE

for XDEBUG_CONFIG_PARAM in $XDEBUG_CONFIG_PARAMS; do
    grep -q "$XDEBUG_CONFIG_PARAM" $XDEBUG_CONFIG_FILE || echo "$XDEBUG_CONFIG_PARAM" >> $XDEBUG_CONFIG_FILE
done

echo $XDEBUG_CONFIG_PARAMS | sed 's/ /\n/g'