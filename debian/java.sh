#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive

# auto accept license
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections

echo ">>> Add PPA containing oracle java packages"
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

apt-get update > /dev/null

echo ">>> Installing java"
apt-get install -qq oracle-java8-installer 2> /dev/null
apt-get install -qq oracle-java8-set-default