#!/usr/bin/env bash

set -e

function help() {

local _FILE_NAME
_FILE_NAME=`basename $0`

cat << HELP_USAGE

Description:
    This script starts a Jupyter Lab or Jupyter Notebook.

Usage: $_FILE_NAME [-h|--help] [-p=|--port=<port>] [-n|--notebook]

Examples:
	$_FILE_NAME
	$_FILE_NAME -p=9000
	$_FILE_NAME -n --port=9000

Options:
    -h|--help
        Show this message.

    -p=|--port=<port>
    	Use port for starting/connecting to.
    	It is advised to use value '>=10000'.

    	Defaults to the values:
        1) \$JUPYTER_LAB_PORT for Jupyter Lab
        2) \$JUPYTER_NOTEBOOK_PORT for Jupyter Notebook
    	3) '8888' if these env variables do not exist

    -n|--notebook
        Start Jupyter Notebook instead of Jupyter Lab.

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
start_type=0

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
        -n|--notebook)
            start_type=1
            ;;
        *)
            # Skip unknown option
            ;;
    esac
    shift
done


if [[ ($start_type == 0) ]]; then

	printf "Starting Jupyter Lab for remote use\n"

    if [ ! -z $JUPYTER_LAB_PORT ];then
        port="${JUPYTER_LAB_PORT}"
    fi

	# Locally define $SHELL, so that terminals opened in JupyterLab would use zsh
    env SHELL="`which zsh`" jupyter lab --no-browser --port="${port}"

elif [[ ($start_type == 1) ]]; then

	printf "Starting Jupyter Notebook for remote use\n"

	if [ ! -z $JUPYTER_NOTEBOOK_PORT ];then
        port="${JUPYTER_NOTEBOOK_PORT}"
    fi

	jupyter notebook --no-browser --port=${port}
fi