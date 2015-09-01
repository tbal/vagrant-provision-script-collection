#!/usr/bin/env bash
set -e

echo ">>> Updating apt package index"
apt-get update > /dev/null

# Fixes error "There is no public key available for the following key IDs:" on Debian Wheezy
apt-get install debian-archive-keyring
apt-get update > /dev/null

echo "Done."
