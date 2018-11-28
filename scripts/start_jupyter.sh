#!/bin/bash

usage()
{
echo "*****************************************************"
cat << EOF
usage: $0 [-h] [-p port]
This script starts a jupyter lab.
TYPICAL USE:
	$0
	This will start a jupyter lab with automatic selection of the port
BASIC OPTIONS:
   -h			Show this message
   -p [port]	Use port for starting/connecting to, Default is '8888'
By Ilya Kisil <ilyakisil@gmail.com>
EOF
echo "*****************************************************"
}


use_venv=0
port="8888"
while getopts ":p:h" OPTION
do
    case $OPTION in
        h)
            usage
            exit
            ;;
		p)
			port="${OPTARG:r}"
			;;
        \?)
			echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
     esac
done


printf "Starting Jupyter Lab for remote use\n"
# Locally define $SHELL, so that terminals opened in JupyterLab would use zsh
env SHELL="`which zsh`" jupyter lab --no-browser --port="${port}"
