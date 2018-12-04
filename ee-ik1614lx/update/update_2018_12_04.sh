#!/usr/bin/env bash

set -e

function help() {

local _FILE_NAME
_FILE_NAME=`basename $0`

cat << HELP_USAGE

Description:
    Update for making 'start_jupyter.sh' and 'csp_ict_update.sh' more robust.
    Available from 2018-12-04.

    For more details, see associated info in README.md

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
declare -a AFFECTED_FILES=("~/.zshrc"
                            "~/.zshrc-local"
                            "~/.tmux-local.conf"
                            "~/bin/start_jupyter.sh"
                            "~/bin/csp_ict_update.sh"
                            )

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

# Infer user name from user home
USER_NAME="$(echo ${USER_HOME} | awk -F/ '{ print $NF }')"

if [ -z $EE_IK1614LX_DEFAULTS_HOME ] || [ -z $USER_NAME ] || [ -z $CSP_ICT_HOME ]; then
    echo "ERROR: Missing some required variables."  >&2
    exit 1
fi
JUPYTER_PORTS_FILE="${EE_IK1614LX_DEFAULTS_HOME}/default_jupyter_ports.txt"


#--------          MAIN (execution)          --------#
echo "INFO: This update will affect following existing files:"
for file in "${AFFECTED_FILES[@]}"
do
    printf "\t$file\n"
done

printf "Have you modified any of these files? (y/n) "

answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
if echo "$answer" | grep -iq "^y" ;then
    echo "INFO: Cannot proceed. Please contact CSP ICT administrator."
    exit 0
fi

mkdir -p $BACKUP_DIR

echo "Updating [${USER_HOME}/bin/csp_ict_update.sh]"
mv ${USER_HOME}/bin/csp_ict_update.sh ${BACKUP_DIR}/csp_ict_update.sh
cp $CSP_ICT_HOME/scripts/csp_ict_update.sh ${USER_HOME}/bin/csp_ict_update.sh

echo "Updating [${USER_HOME}/.tmux-local.conf]"
mv ${USER_HOME}/.tmux-local.conf ${BACKUP_DIR}/.tmux-local.conf
cp $CSP_ICT_HOME/dotfiles/tmux/tmux-local-ee-ik1614lx.conf ${USER_HOME}/.tmux-local.conf

echo "Updating [${USER_HOME}/.zshrc]"
mv ${USER_HOME}/.zshrc ${BACKUP_DIR}/.zshrc
cp $CSP_ICT_HOME/dotfiles/zsh/zshrc ${USER_HOME}/.zshrc

echo "Updating [${USER_HOME}/bin/start_jupyter.sh]"
mv ${USER_HOME}/bin/start_jupyter.sh ${BACKUP_DIR}/start_jupyter.sh
cp $CSP_ICT_HOME/scripts/start_jupyter.sh ${USER_HOME}/bin/start_jupyter.sh

echo "Updating [${USER_HOME}/.zshrc-local]"
mv ${USER_HOME}/.zshrc-local ${BACKUP_DIR}/.zshrc-local
cp $CSP_ICT_HOME/dotfiles/zsh/zshrc-local-ee-ik1614lx ${USER_HOME}/.zshrc-local

echo "Set default ports for Jupyter Lab and Notebook in [${USER_HOME}/.zshrc-local]"
JUPYTER_PORTS_FILE="${EE_IK1614LX_DEFAULTS_HOME}/default_jupyter_ports.txt"
JL_PORT=`cat $JUPYTER_PORTS_FILE | grep $USER_NAME | awk -F: '{ print $2 }'`
if [ -z ${JL_PORT} ]; then
    JL_PORT="8888"
fi
JN_PORT=$(( $JL_PORT + 1 ))
sed -i "s|__JUPYTER_LAB_PORT__|$JL_PORT|g" $USER_HOME/.zshrc-local
sed -i "s|__JUPYTER_NOTEBOOK_PORT__|$JN_PORT|g" $USER_HOME/.zshrc-local

