#!/usr/bin/env bash
set -e

[ -z "$MAILCATCHER_PHP_CONFIG_FILE"  ] && MAILCATCHER_PHP_CONFIG_FILE="/etc/php5/mods-available/mailcatcher.ini"


BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source "$BASEDIR/../debian-7/mailcatcher.sh"


echo ">>> Enabling mailcatcher php settings"
php5enmod mailcatcher
