#!/usr/bin/env bash

set -e

function help() {

local _FILE_NAME
_FILE_NAME=`basename $0`

cat << HELP_USAGE

Description:
    This script starts a Jupyter Lab.

Usage: $_FILE_NAME [-h|--help] [-p=|--port=<port>]

Examples:
	$_FILE_NAME
	$_FILE_NAME -p=9000
	$_FILE_NAME --port=9000

Options:
    -h|--help
        Show this message.

    -p=|--port=<port>
    	Use port for starting/connecting to.
    	It is advised to use value '>=9000'.

    	Defaults to the value of \$JUPYTER_LAB_PORT
    	or '8888' if this env variable doesn't exist.

Author:
    Ilya Kisil <ilyakisil@gmail.com>

Report bugs to ilyakisil@gmail.com.

HELP_USAGE
}


# Default value for variables
if [ ! -z $JUPYTER_LAB_PORT ];then
    port="${JUPYTER_LAB_PORT}"
else
    port="8888"
fi

# Parse arguments
for arg in "$@"; do
    case $arg in
        -h|--help)
            help
            exit
            ;;
        -p=*|--port=*)
            port="${arg#*=}"
            ;;
        *)
            # Skip unknown option
            ;;
    esac
    shift
done


printf "Starting Jupyter Lab for remote use\n"
# Locally define $SHELL, so that terminals opened in JupyterLab would use zsh
env SHELL="`which zsh`" jupyter lab --no-browser --port="${port}"