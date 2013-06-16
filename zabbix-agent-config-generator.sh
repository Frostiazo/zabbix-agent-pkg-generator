#!/bin/bash
#
# Script to modify config file for zabbix agents
#

print_help() {
    echo "Usage: $0 CONFIG_FILE [OPCIONES]"
    echo "                      -s  | --server          SERVER"
    echo "                      -sa | --server-active   SERVER_IP[:PORT]"
    echo "                      -t  | --timeout         SECONDS (1-30)"
    echo "                      -ra | --refresh-active  SECONDS (60-3600)" 
    echo "       $0 [-h|--help]" 
}


if [ $# -eq 0 ]; then
    echo "No arguments passed"
    exit 1
fi

if [ $1 = "-h" -o $1 = "--help" ]; then
    print_help
    exit 0
fi

if [ ! -f $1 ]; then
    echo "First argument isn't a valid file"
    exit 1
fi

CONF_FILE=$1
shift 1


# Extract configuration parameters from arguments
while [ $# -gt 0 ]; do
    case $1 in 
        -s|--server)
            if [ -n "$2" ]; then
                server=$2 
                shift 2
            else
                echo "Missing Server IP" 
                exit 1
            fi 
        ;;
        -sa|--server-active)
            if [ -n "$2" ]; then
                server_active=$2
                shift 2
            else
                echo "Missing ServerActive IP"
                exit 1
            fi
        ;;
        -t|--timeout)
            if [ -n "$2" -a $2 -ge 1 -a $2 -le 30 ]; then
                timeout=$2
                shift 2
            else
                echo "Value for Timeout incorrect or missing"
                exit 1
            fi
        ;;
        -ra|--refresh-active)
            if [ -n "$2" -a $2 -ge 60 -a $2 -le 3600 ]; then
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


# Modify configuration file with the parameters passed as arguments
if [ -n "$server" ]; then
    sed "s/^Server=.*/Server=$server/g" -i $CONF_FILE
fi
if [ -n "$server_active" ]; then
    sed "s/^ServerActive=.*/ServerActive=$server_active/g" -i $CONF_FILE
fi   
if [ -n "$timeout" ]; then
    sed "s/^Timeout=.*/Timeout=$timeout/g" -i $CONF_FILE
fi
if [ -n "$refresh_active" ]; then
    sed "s/^RefreshActiveChecks=.*/RefreshActiveChecks=$refresh_active/g" -i $CONF_FILE
fi 

