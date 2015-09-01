#!/usr/bin/env bash
set -e

###
# NOTICE: Executes existing installation script for debian with specific sources list line for Ubuntu.
##

[ -z "$MONGODB_VERSION"           ] && MONGODB_VERSION="3.0"
[ -z "$MONGODB_SOURCES_LIST_LINE" ] && MONGODB_SOURCES_LIST_LINE="deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/${MONGODB_VERSION} multiverse"


BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source "$BASEDIR/../debian/mongodb.sh"
