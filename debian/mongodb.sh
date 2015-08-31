#!/usr/bin/env bash
set -e

[ -z "$MONGODB_VERSION"              ] && MONGODB_VERSION="3.0"
[ -z "$MONGODB_SOURCES_LIST_LINE"    ] && MONGODB_SOURCES_LIST_LINE="deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/${MONGODB_VERSION} main"
[ -z "$MONGODB_PORT"                 ] && MONGODB_PORT=27017 # default port = 27017
[ -z "$MONGODB_ENABLE_SMALLFILES"    ] && MONGODB_ENABLE_SMALLFILES=1
[ -z "$MONGODB_ENABLE_REMOTE_ACCESS" ] && MONGODB_ENABLE_REMOTE_ACCESS=0 # 0=localhost only, 1=remote access allowed
[ -z "$MONGODB_ENABLE_REST"          ] && MONGODB_ENABLE_REST=0 # port = default port + 1000 (e.g. 28017)
[ -z "$MONGODB_ENABLE_HTTPINTERFACE" ] && MONGODB_ENABLE_HTTPINTERFACE=0 # port = default port + 1000 (e.g. 28017) 


echo ">>> Installing MongoDB"

# install adduser temporary if missing
ADDUSER_UNINSTALL=0
if [ ! $(which adduser) ]; then
    echo "adduser required for installing mongodb. Temporary installing adduser ..."
    apt-get install -qq adduser > /dev/null 2>&1
    ADDUSER_UNINSTALL=1
fi


# import the public key
apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10

# create a source list file for MongoDB
echo "$MONGODB_SOURCES_LIST_LINE" | tee /etc/apt/sources.list.d/mongodb-org-3.0.list
apt-get update

# install the MongoDB packages
apt-get -qq install -y mongodb-org
echo "MongoDB installed."


# uninstall previously temporary installed adduser
if [ "$ADDUSER_UNINSTALL" -eq 1 ]; then
    apt-get purge -qq adduser > /dev/null 2>&1
    echo "Removed adduser."
fi


echo ">>> Changing MongoDB configuration"

echo "Backup default configuration file /etc/mongod.conf to /etc/mongod.default.conf before doing changes."
cp /etc/mongod.conf /etc/mongod.default.conf

# TODO: support for >=2.6 config format
set_setting_in_config() {
    NAME=$1
    VALUE=$2

    if grep -qi "$NAME" /etc/mongod.conf > /dev/null; then
        sed -i "s/#\? *${NAME} *= *.*$/${NAME} = ${VALUE}/g" /etc/mongod.conf
    else
        echo -e "\n${NAME} = ${VALUE}" >> /etc/mongod.conf
    fi
}

echo ">>> Setting Port to ${MONGODB_PORT} (default: 27017)."
set_setting_in_config "port" "${MONGODB_PORT}"

if [ "$MONGODB_ENABLE_SMALLFILES" -eq "1" ]; then
    echo "Enabling smallfiles"
    set_setting_in_config "smallfiles" "true"
else
    echo "Disabling smallfiles"
    set_setting_in_config "smallfiles" "false"
fi

if [ "$MONGODB_ENABLE_REMOTE_ACCESS" -eq "1" ]; then
    echo "Enabling remote access"
    set_setting_in_config "bind_ip" "0.0.0.0"
else
    echo "Disabling remote access (access from localhost only)"
    set_setting_in_config "bind_ip" "127.0.0.1"
fi

if [ "$MONGODB_ENABLE_REST" -eq "1" ]; then
    echo "Enabling REST interface (port = default port + 1000 (e.g. 28017))"
    set_setting_in_config "rest" "true"
else
    echo "Disabling REST interface"
    set_setting_in_config "rest" "false"
fi

if [ "$MONGODB_ENABLE_HTTPINTERFACE" -eq "1" ]; then
    echo "Enabling HTTP interface (port = default port + 1000 (e.g. 28017))"
    set_setting_in_config "httpinterface" "true"
else
    echo "Disabling HTTP interface"
    set_setting_in_config "httpinterface" "false"
fi

# restart MongoDB daemon after configuration changes
echo ">>> Restarting MongoDB daemon for configuration changes to take effect"
service mongod restart