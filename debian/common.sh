#!/usr/bin/env bash
set -e

[ -z "$TIMEZONE" ] && TIMEZONE="Europe/Berlin"
echo ">>> Setting Timezone to $TIMEZONE"
echo "$TIMEZONE" | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata


[ -z "$COMMON_PACKAGES" ] && COMMON_PACKAGES="vim curl htop tree"
echo ">>> Installing packages: $COMMON_PACKAGES"
apt-get install -qq $COMMON_PACKAGES
