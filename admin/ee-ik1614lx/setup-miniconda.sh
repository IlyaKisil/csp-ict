#!/usr/bin/env bash

# Author: Ilya Kisil <ilyakisil@gmail.com>

set -e

_FILE_NAME=`basename ${BASH_SOURCE[0]}`

if [ -z $1 ] ; then
    USER_NAME=$USER
else
    USER_NAME=$1
fi

if [ -z $USER_NAME ] ; then
    echo "`ERROR $_FILE_NAME` Don't known for which user this setup should be performed, cannot continue."
    error_exit
fi

USER_HOME="$(echo `getent passwd ${USER_NAME}` | awk -F: '{ print $6 }')"

ANACONDA_INSTALL_HOME="${USER_HOME}/Miniconda3"
DEFAULT_VENV_REQUIREMENTS="${EE_IK1614LX_SETUP_HOME}/default_venv_requirements.txt"

echo "`INFO $_FILE_NAME` Configuring local installation of miniconda in [${ANACONDA_INSTALL_HOME}]."
bash $CSP_ICT_HOME/software/miniconda/install.sh -b -p ${ANACONDA_INSTALL_HOME}

echo "`INFO $_FILE_NAME` Installing additional packages required by default."
${ANACONDA_INSTALL_HOME}/bin/conda install --file $DEFAULT_VENV_REQUIREMENTS \
                                           --yes \
                                           --quiet

