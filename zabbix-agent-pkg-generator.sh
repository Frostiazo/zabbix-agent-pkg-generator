#!/bin/bash
#
# Script to generate debian packages dynamically
#
# TODO: check with regexp if the parameters are well formed IPs or DNS names

BASE_FOLDER="zabbix-agent-static-amd64"
TEMP_FOLDER=".temp"
PKG_NAME="zabbix-agent-2.0.6.deb"
CONF_FILE="/usr/share/zabbix-agent/zabbix_agentd.conf"

default_config=false

print_help() {
    echo "Usage: $0 [OPCIONES]"
    echo "      -s  | --server          SERVER"
    echo "      -sa | --server-active   SERVER_IP[:PORT]"
    echo "      -t  | --timeout         SECONDS (1-30)"
    echo "      -ra | --refresh-active  SECONDS (60-3600)" 
    echo "      -h  | --help" 
}

if [ -f $PKG_NAME ]; then
    rm -f $PKG_NAME
fi

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
        -t|--timeout)
            if [ $2 != "" -a $2 -ge 1 -a $2 -le 30 ]; then
                timeout=$2
                shift 2
            else
                echo "Value for Timeout incorrect or missing"
                exit 1
            fi
        ;;
        -ra|--refresh-active)
            if [ $2 != "" -a $2 -ge 60 -a $2 -le 3600 ]; then
                refresh_active=$2
                shift 2
            else 
                echo "Value for RefreshActiveChecks incorrect or missing"
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
    if [ -n $timeout ]; then
        sed "s/^Timeout=.*/Timeout=$timeout/g" -i $TEMP_FOLDER$CONF_FILE
    fi
    if [ -n $refresh_active ]; then
        sed "s/^RefreshActiveChecks=.*/RefreshActiveChecks=$refresh_active/g" -i $TEMP_FOLDER$CONF_FILE
    fi 
fi 

# Build the package and delete the temp folder
dpkg -b $TEMP_FOLDER $PKG_NAME 
rm -rf $TEMP_FOLDER
