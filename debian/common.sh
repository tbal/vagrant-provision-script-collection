#!/usr/bin/env bash
set -e

TIMEZONE="Europe/Berlin"
echo ">>> Setting Timezone to $TIMEZONE"
echo "$TIMEZONE" | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata


COMMON_PACKAGES="vim curl htop tree"
echo ">>> Installing packages: $COMMON_PACKAGES"
apt-get install -qq $COMMON_PACKAGES
