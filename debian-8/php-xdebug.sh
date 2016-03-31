#!/usr/bin/env bash
set -e

[ -z "$XDEBUG_CONFIG_FILE"  ] && XDEBUG_CONFIG_FILE="/etc/php5/mods-available/xdebug-vpsc.ini"


BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source "$BASEDIR/../debian-7/php-xdebug.sh"


echo ">>> Enabling xdebug php settings"
php5enmod xdebug-vpsc
