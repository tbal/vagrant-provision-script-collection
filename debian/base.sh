#!/usr/bin/env bash

echo ">>> Updating apt package index"
apt-get update


TIMEZONE="Europe/Berlin"
echo ">>> Setting Timezone to $TIMEZONE"
echo "$TIMEZONE" | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata


PACKAGES="vim curl htop tree"
echo ">>> Installing packages: $PACKAGES"
apt-get install -qq $PACKAGES
