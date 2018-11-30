#!/usr/bin/env bash

set -e

function help() {

local _FILE_NAME
_FILE_NAME=`basename $0`

echo "*****************************************************"
cat << HELP_USAGE
USAGE: $_FILE_NAME [-h|--help]

This script is used for testing of applying updates to the
'csp-mandic' member

TYPICAL USE:
    $_FILE_NAME
    
BASIC OPTIONS:
    -h|--help
        Show this message.


By Ilya Kisil <ilyakisil@gmail.com>
HELP_USAGE
echo "*****************************************************"
}

# Parse arguments
for arg in "$@"; do
    case $arg in
        -h|--help)
            help
            exit
            ;;
        *)
            # Skip unknown option
            ;;
    esac
    shift
done


echo "Hello. I hope you will enjoy this dummy update which does absolutely nothing."