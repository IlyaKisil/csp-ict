#!/usr/bin/env bash

set -e

function help() {

local _FILE_NAME
_FILE_NAME=`basename $0`

cat << HELP_USAGE

Description:
    This script is used for testing of applying updates to the
    'csp-mandic' member.

Usage: $_FILE_NAME [-h|--help] [-b=|--bak=<BACKUP_DIR>] [-l=|--log=<LOG_DIR>]

Examples:
    $_FILE_NAME --bak=/my/backup/dir --log=/my/log/dir
    
Options:
    -h|--help
        Show this message.

    -b=|--bak=<BACKUP_DIR>
        Backup directory for files that are affected by this update

    -l=|--log=<LOG_DIR>
        Log directory for the execution of this update

Author:
    Ilya Kisil <ilyakisil@gmail.com>

Report bugs to ilyakisil@gmail.com.

HELP_USAGE
}

# Utility functions


# Default values for variables
BACKUP_DIR=""
LOG_DIR=""

# Parse arguments
for arg in "$@"; do
    case $arg in
        -h|--help)
            help
            exit
            ;;
        -b=*|--bak=*)
            BACKUP_DIR="${arg#*=}"
            ;;
        -l=*|--log=*)
            LOG_DIR="${arg#*=}"
            ;;
        *)
            # Skip unknown option
            ;;
    esac
    shift
done

# Define new variables with respect to the parsed arguments


#--------          MAIN          --------#
echo "Hello. I hope you will enjoy this dummy update which does absolutely nothing."
echo "If there were any changes then:"
echo ""
printf "1) Backup copy would have been saved in:\n"
printf "\t ${BACKUP_DIR} \n"
printf "2) Log of the updates would have been saved in:\n"
printf "\t ${LOG_DIR} \n"
