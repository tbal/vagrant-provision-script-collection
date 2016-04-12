#!/usr/bin/env bash
set -e

[ -z "$TOMCAT_VERSION" ] && TOMCAT_VERSION=8


BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source "$BASEDIR/../debian-7/solr-tomcat.sh"
