#!/usr/bin/env bash

set -e

function help() {

local _FILE_NAME
_FILE_NAME=`basename $0`

cat << HELP_USAGE

Description:
    This script can be used for applying future updates to the
    overall configuration.

Usage: $_FILE_NAME [-h|--help] [-f=|--file=<file_name>]

Examples:
    $_FILE_NAME -f=my_value
    $_FILE_NAME --file_name=my_value
    
Options:
    -h|--help
        Show this message.

    -f=|--file=<file_name>
        Name of the source file to be executed.

Author:
    Ilya Kisil <ilyakisil@gmail.com>

Report bugs to ilyakisil@gmail.com.

HELP_USAGE
}

# Default value for variables
file_name="dummy_update.sh"

# Parse arguments
for arg in "$@"; do
    case $arg in
        -h|--help)
            help
            exit
            ;;
        -f=*|--file=*)
            file_name="${arg#*=}"
            ;;
        *)
            # Skip unknown options
            ;;
    esac
    shift
done

if [ -z ${file_name} ]; then
    echo "ERROR: File name has not been specified" >&2
    echo "Use '-h' to get help." >&2
    exit
fi

# This variable should be correctly specified in the ~/.zshrc
if [ -z $EE_IK1614LX_UPDATE_HOME ]; then
    echo "ERROR: Missing some required environment variables." >&2
    exit
fi

UPDATE_FILE_PATH=${EE_IK1614LX_UPDATE_HOME}/${file_name}.sh

if [ ! -f ${UPDATE_FILE_PATH} ]; then
    echo "ERROR: Requested update file does not exist." >&2
    echo "Contact CSP-ICT administrator." >&2
    exit
fi

echo "INFO: Applying update from $UPDATE_FILE_PATH"
source ${UPDATE_FILE_PATH}
