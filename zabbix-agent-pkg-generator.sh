#!/bin/bash
#
# Script to generate debian packages dynamically
#
# TODO: check with regexp if the parameters are well formed IPs or DNS names

CONF_GENERATOR="zabbix-agent-config-generator.sh"
BASE_FOLDER="zabbix-agent-static-amd64"
TEMP_FOLDER=".temp"
PKG_NAME="zabbix-agent-2.0.6.deb"
CONF_FILE="/usr/share/zabbix-agent/zabbix_agentd.conf"

default_config=false

if [ -f $PKG_NAME ]; then
    rm -f $PKG_NAME
fi

# Parse params
if [ $# -eq 0 ]; then
    default_config=true
fi

# Create temp folder and modify configuration file 
if [ -d $TEMP_FOLDER ]; then
    rm -rf $TEMP_FOLDER
fi
cp -rp $BASE_FOLDER $TEMP_FOLDER

if [ $default_config = true ]; then
    echo "Creating package with default configuration"
else 
    # Run the script to modify the configuration file
    /bin/bash $CONF_GENERATOR $TEMP_FOLDER$CONF_FILE $@    
    if [ $? -ne 0 ]; then
        echo "Error while executing $CONF_GENERATOR script" 
        exit 1
    fi
fi 

# Build the package and delete the temp folder
dpkg -b $TEMP_FOLDER $PKG_NAME 
rm -rf $TEMP_FOLDER
