#!/usr/bin/env bash
set -e

[ -z "$PHPINFO_FILENAME"        ] && PHPINFO_FILENAME="phpinfo.php"
[ -z "$PHPINFO_DESTINATION_DIR" ] && PHPINFO_DESTINATION_DIR="/var/www"

echo ">>> Adding $PHPINFO_FILENAME to $PHPINFO_DESTINATION_DIR"
mkdir -p $PHPINFO_DESTINATION_DIR
echo "<?php phpinfo() ?>" > "$PHPINFO_DESTINATION_DIR/$PHPINFO_FILENAME"
