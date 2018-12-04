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


#--------          MAIN          --------#
if [ -z ${LOG_DIR} ] || [ -z ${BACKUP_DIR} ] || [ -z ${USER_HOME} ]; then
    echo "ERROR: User's [home], [log] or [backup] directories have not been specified. Cannot proceed." >&2
    exit 1
fi

#echo "$LOG_DIR"
#echo "$BACKUP_DIR"
mkdir -p $BACKUP_DIR

# Update .zshrc
echo "Updating ${USER_HOME}/.zshrc"
mv ${USER_HOME}/.zshrc ${BACKUP_DIR}/.zshrc
cp $CSP_ICT_HOME/dotfiles/zsh/zshrc ${USER_HOME}/.zshrc

# Update .zshrc-local
echo "Updating ${USER_HOME}/.zshrc-local"
mv ${USER_HOME}/.zshrc-local ${BACKUP_DIR}/.zshrc-local
cp $CSP_ICT_HOME/dotfiles/zsh/zshrc-local-ee-ik1614lx ${USER_HOME}/.zshrc-local

# TODO: change __JUPYTER_LAB_PORT__
sed -i "s|__JUPYTER_LAB_PORT__|9999|g" $USER_HOME/.zshrc-local

# Update .tmux-local.conf
echo "Updating ${USER_HOME}/.tmux-local.conf"
mv ${USER_HOME}/.tmux-local.conf ${BACKUP_DIR}/.tmux-local.conf
cp $CSP_ICT_HOME/dotfiles/tmux/tmux-local-ee-ik1614lx.conf ${USER_HOME}/.tmux-local.conf

# Update start_jupyter.sh
echo "Updating ${USER_HOME}/bin/start_jupyter.sh"
mv ${USER_HOME}/bin/start_jupyter.sh ${BACKUP_DIR}/start_jupyter.sh
cp $CSP_ICT_HOME/scripts/start_jupyter.sh ${USER_HOME}/bin/start_jupyter.sh

# Update csp_ict_update.sh
echo "Updating ${USER_HOME}/bin/csp_ict_update.sh"
mv ${USER_HOME}/bin/csp_ict_update.sh ${BACKUP_DIR}/csp_ict_update.sh
cp $CSP_ICT_HOME/scripts/csp_ict_update.sh ${USER_HOME}/bin/csp_ict_update.sh
