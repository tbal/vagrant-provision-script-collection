#!/usr/bin/env bash

TIMEZONE="Europe/Berlin"
echo ">>> Setting Timezone to $TIMEZONE"
echo "$TIMEZONE" | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata


PACKAGES="vim curl htop tree"
echo ">>> Installing packages: $PACKAGES"
apt-get install -qq $PACKAGES
