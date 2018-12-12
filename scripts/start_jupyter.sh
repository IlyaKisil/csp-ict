#!/usr/bin/env bash

set -e

function help() {

local _FILE_NAME
_FILE_NAME=`basename ${BASH_SOURCE[0]}`

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


### Default value for variables
# User interface for jupyter ('lab|notebook')
UI="lab"

# Exposed port on the local server
default_port="8888"

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
            UI="notebook"
            ;;
        *)
            # Skip unknown option
            ;;
    esac
    shift
done

### Define new variables with respect to the parsed arguments


##########################################
#--------          MAIN          --------#
##########################################

# Use zsh as shell for terminals if it exists
if [ ! -z "${SHELL##*zsh*}" ] && [ -x "$(command -v zsh)" ]; then
    SHELL_PATH=`which zsh`
else
    SHELL_PATH=$SHELL
fi

# Infer which port to use based on ENV variables
if [ -z $port ]; then
    if [[ $UI == "lab" ]] && [ ! -z $JUPYTER_LAB_PORT ]; then
        port=$JUPYTER_LAB_PORT
    elif [[ $UI == "notebook" ]] && [ ! -z $JUPYTER_NOTEBOOK_PORT ]; then
        port=$JUPYTER_NOTEBOOK_PORT
    else
        port=$default_port
    fi
fi

printf "Starting Jupyter ${UI^} for remote use \n\n"
env SHELL=$SHELL_PATH jupyter ${UI} --no-browser --port="${port}"
