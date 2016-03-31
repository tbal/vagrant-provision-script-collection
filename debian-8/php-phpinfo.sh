#!/usr/bin/env bash
set -e

[ -z "$PHPINFO_DESTINATION_DIR" ] && PHPINFO_DESTINATION_DIR="/var/www/html"


BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source "$BASEDIR/../debian-7/php-phpinfo.sh"
