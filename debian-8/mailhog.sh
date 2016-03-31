#!/usr/bin/env bash
set -e

[ -z "$MAILHOG_PHP_CONFIG_FILE"  ] && MAILHOG_PHP_CONFIG_FILE="/etc/php5/mods-available/mailhog.ini"


BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source "$BASEDIR/../debian-7/mailhog.sh"


echo ">>> Enabling mailhog php settings"
php5enmod mailhog
