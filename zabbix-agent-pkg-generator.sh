#!/bin/bash
#
# Script to generate debian packages dynamically
#
# TODO: check with regexp if the parameters are well formed IPs or DNS names

BASE_FOLDER="zabbix-agent-lucid-static-amd64"
TEMP_FOLDER=".temp"
PKG_NAME="zabbix-agent-2.0.6.deb"
CONF_FILE="/usr/share/zabbix-agent/zabbix_agentd.conf"

default_config=false

print_help() {
    echo "Usage: $0 [OPCIONES]"
    echo "      -s  | --server          SERVER"
    echo "      -sa | --server-active   SERVER_IP[:PORT]"
    echo "      -h  | --help" 
    
}

# Parse params
if [ $# -eq 0 ]; then
    default_config=true
fi

while [ $# -gt 0 ]; do
    case $1 in 
        -s|--server)
            if [ $2 != "" ]; then
                server=$2 
                shift 2
            else
                echo "Missing Server IP" 
                exit 1
            fi 
        ;;
        -sa|--server-active)
            if [ $2 != "" ]; then
                server_active=$2
                shift 2
            else
                echo "Missing ServerActive IP"
                exit 1
            fi
        ;;
        -h|--help)
            print_help
            exit 0
        ;;
        *)
            echo "Illegal argument $1! Exiting"
            exit 1
        ;;
    esac
done 

# Create temp folder and modify configuration file 
cp -r $BASE_FOLDER $TEMP_FOLDER

if [ $default_config = true ]; then
    echo "Creating package with default configuration"
else 
    if [ -n $server ]; then
        sed "s/^Server=.*/Server=$server/g" -i $TEMP_FOLDER$CONF_FILE
    fi
    if [ -n $server_active ]; then
        sed "s/^ServerActive=.*/ServerActive=$server_active/g" -i $TEMP_FOLDER$CONF_FILE
    fi   
fi 

# Build the package and delete the temp folder
dpkg -b $TEMP_FOLDER $PKG_NAME 
rm -rf $TEMP_FOLDER
