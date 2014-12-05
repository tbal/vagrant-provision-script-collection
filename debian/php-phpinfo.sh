#!/usr/bin/env bash

FILE_NAME="phpinfo.php"
DEST_DIR="/var/www"

echo ">>> Adding $FILE_NAME to $DEST_DIR"
mkdir -p $DEST_DIR
echo "<?php phpinfo() ?>" > "$DEST_DIR/$FILE_NAME"
