#!/usr/bin/env bash
set -e

[ -z "$ADMINER_INSTALL_DIR" ] && ADMINER_INSTALL_DIR="/var/www/html/adminer"


BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source "$BASEDIR/../debian-7/adminer.sh"
