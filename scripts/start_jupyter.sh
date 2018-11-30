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
	$_FILE_NAME -p=8000
	$_FILE_NAME --port=8000

Options:
    -h|--help
        Show this message.

    -p=|--port=<port>
    	Use port for starting/connecting to. Default is '8888'.

Author:
    Ilya Kisil <ilyakisil@gmail.com>

Report bugs to ilyakisil@gmail.com.

HELP_USAGE
}


# Default value for variables
port="8888"


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

# TODO: need some sort of convention for port selection for remote users