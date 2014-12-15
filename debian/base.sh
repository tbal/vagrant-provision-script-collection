#!/usr/bin/env bash
set -e

echo ">>> Updating apt package index"
apt-get update > /dev/null
echo "Done."
