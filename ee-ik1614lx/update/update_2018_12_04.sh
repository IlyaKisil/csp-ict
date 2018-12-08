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

Notes:
    Originally, \$back_up_dir was defined in the original 'csp_ict_update.sh' script.
    But this update modifies 'csp_ict_update.sh' and this variable can no longer be
    used.

Usage: $_FILE_NAME [-h|--help]

Examples:
    $_FILE_NAME

Options:
    -h|--help
        Show this message.

Author:
    Ilya Kisil <ilyakisil@gmail.com>

Report bugs to ilyakisil@gmail.com.

HELP_USAGE
}

# Utility functions


# Default values for variables
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
        *)
            # Skip unknown option
            ;;
    esac
    shift
done

# Define new variables with respect to the parsed arguments


#--------          MAIN (preparation)          --------#
# Infer user name from user home
USER_NAME="$(echo ${HOME} | awk -F/ '{ print $NF }')"

if [ -z $EE_IK1614LX_HOME ] || [ -z $USER_NAME ] || [ -z $CSP_ICT_HOME ]; then
    echo "ERROR: Missing some required variables."  >&2
    exit 1
fi
JUPYTER_PORTS_FILE="${EE_IK1614LX_HOME}/allowed_users_info.csv"


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

mkdir -p $back_up_dir

echo "Updating [${HOME}/bin/csp_ict_update.sh]"
mv ${HOME}/bin/csp_ict_update.sh ${back_up_dir}/csp_ict_update.sh
cp $CSP_ICT_HOME/scripts/csp_ict_update.sh ${HOME}/bin/csp_ict_update.sh

echo "Updating [${HOME}/.tmux-local.conf]"
mv ${HOME}/.tmux-local.conf ${back_up_dir}/.tmux-local.conf
cp $CSP_ICT_HOME/dotfiles/tmux/tmux-local-ee-ik1614lx.conf ${HOME}/.tmux-local.conf

echo "Updating [${HOME}/.zshrc]"
mv ${HOME}/.zshrc ${back_up_dir}/.zshrc
cp $CSP_ICT_HOME/dotfiles/zsh/zshrc ${HOME}/.zshrc

echo "Updating [${HOME}/bin/start_jupyter.sh]"
mv ${HOME}/bin/start_jupyter.sh ${back_up_dir}/start_jupyter.sh
cp $CSP_ICT_HOME/scripts/start_jupyter.sh ${HOME}/bin/start_jupyter.sh

echo "Updating [${HOME}/.zshrc-local]"
mv ${HOME}/.zshrc-local ${back_up_dir}/.zshrc-local
cp $CSP_ICT_HOME/dotfiles/zsh/zshrc-local-ee-ik1614lx ${HOME}/.zshrc-local

echo "Set default ports for Jupyter Lab and Notebook in [${HOME}/.zshrc-local]"
JL_PORT=`cat $JUPYTER_PORTS_FILE | grep $USER_NAME | awk -F, '{ print $2 }'`
if [ -z ${JL_PORT} ]; then
    JL_PORT="8888"
fi
JN_PORT=$(( $JL_PORT + 1 ))
sed -i "s|__JUPYTER_LAB_PORT__|$JL_PORT|g" $HOME/.zshrc-local
sed -i "s|__JUPYTER_NOTEBOOK_PORT__|$JN_PORT|g" $HOME/.zshrc-local

