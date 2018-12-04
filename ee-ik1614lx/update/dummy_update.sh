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
    [-h=|--home=<HOME_DIR>]

Examples:
    $_FILE_NAME --bak=/my/backup/dir --log=my/log/dir --home=/my/home/dir
    
Options:
    -h|--help
        Show this message.

    -b=|--bak=<BACKUP_DIR>
        Backup directory for files that are affected by this update

    -l=|--log=<LOG_DIR>
        Log directory for the execution of this update

    -h=|--home=<HOME_DIR>
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
USER_HOME=""

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
        -h=*|--home=*)
            USER_HOME="${arg#*=}"
            ;;
        *)
            # Skip unknown option
            ;;
    esac
    shift
done

# Define new variables with respect to the parsed arguments


#--------          MAIN (preparation)          --------#
if [ -z ${LOG_DIR} ] || [ -z ${BACKUP_DIR} ] || [ -z ${USER_HOME} ]; then
    echo "ERROR: User's [home], [log] or [backup] directories have not been specified. Cannot proceed." >&2
    exit 1
fi


#--------          MAIN (execution)          --------#
echo ""
echo "INFO: We hope you will enjoy this dummy update which does absolutely nothing."
echo ""
echo "If there were any changes then:"
printf "1) Backup copy would have been saved in:\n"
printf "\t ${BACKUP_DIR} \n"
printf "2) Log of the updates would have been saved in:\n"
printf "\t ${LOG_DIR} \n"
printf "3) All changes to files would have been done with respect to:\n"
printf "\t ${USER_HOME} \n"
