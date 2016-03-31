#!/usr/bin/env bash
set -e

[ -z "$GENGHIS_INSTALL_PATH" ] && GENGHIS_INSTALL_PATH="/var/www/html/genghis.php"


BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source "$BASEDIR/../debian-7/genghis.sh"
