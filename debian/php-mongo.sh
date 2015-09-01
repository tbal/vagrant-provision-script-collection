#!/usr/bin/env bash
set -e

echo ">>> Installing php mongo extension from wheezy-backports"

echo "deb http://http.debian.net/debian wheezy-backports main" > /etc/apt/sources.list.d/wheezy-backports.list \
&& apt-get update \
&& apt-get install -t wheezy-backports -qq php5-mongo