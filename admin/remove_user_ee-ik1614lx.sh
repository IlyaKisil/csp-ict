#!/usr/bin/env bash

set -e

function help() {

local _FILE_NAME
_FILE_NAME=`basename $0`

cat << HELP_USAGE

Description:
    Withdraw access to 'ee-ik1614lx' for a specified user.
    This script should revert process of adding meta information about user.
    Requires 'sudo' privileges

Usage: $_FILE_NAME [-h|--help] [-u=|--user=<USER>]

Examples:
    $_FILE_NAME -u=ik1614
    $_FILE_NAME --user=am5113

Options:
    -h|--help
        Show this message.

    -u=|--user=<USER>
        Defines user name, whose access will be withdrawn.

Author:
    Ilya Kisil <ilyakisil@gmail.com>

Report bugs to ilyakisil@gmail.com.

HELP_USAGE
}

### Default value for variables
user=""

# Parse arguments
for arg in "$@"; do
    case $arg in
        -h|--help)
            help
            exit
            ;;
        -u=*|--user=*)
            user="${arg#*=}"
            ;;
        *)
            # Skip unknown option
            ;;
    esac
    shift
done

### Define new variables with respect to the parsed arguments


##############################################
###--------          MAIN          --------###
##############################################

source /hdd/csp-ict/ee-ik1614lx/variables.sh

if [[ $EUID -ne 0 ]]; then
   echo "ERROR: This script must be run as root" >&2
   exit 1
fi

if [ -z $EE_IK1614LX_HOME ]; then
    echo "ERROR: Missing some required variables."
    exit 1
fi

### Check if user name has been specified
if [ -z "$user" ]; then
    echo "ERROR: User name has not been specified." >&2
    echo "Use '-h' to get help." >&2
    exit 1
fi

### Remove user information from the local 'passwd'

### Remove user from the 'csp-mandic' group so he would not be able to ssh and access shared files

### Remove user from the 'docker' group

### Remove user the allowed users file


### Remove Trash bin associated with a user
# TODO: At the moment trash bin for a user is not created so there is nothing to remove

