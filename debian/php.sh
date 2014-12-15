#!/usr/bin/env bash
set -e

echo ">>> Installing php"
apt-get install -qq php5 php5-cli libapache2-mod-php5
