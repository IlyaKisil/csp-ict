#!/usr/bin/env bash

# Author: Ilya Kisil <ilyakisil@gmail.com>

_FILE_NAME=`basename ${BASH_SOURCE[0]}`


USER_NAME=$1
USER_HOME="$(echo `getent passwd ${USER_NAME}` | awk -F: '{ print $6 }')"

ANACONDA_INSTALL_HOME="${USER_HOME}/Miniconda3"
DEFAULT_VENV_REQUIREMENTS="${EE_IK1614LX_SETUP_HOME}/default_venv_requirements.txt"

echo "`INFO $_FILE_NAME` Configuring local installation of miniconda in [${ANACONDA_INSTALL_HOME}]."
bash $CSP_ICT_HOME/software/miniconda/install.sh -b -p ${ANACONDA_INSTALL_HOME}

echo "`INFO $_FILE_NAME` Installing additional packages required by default."
${ANACONDA_INSTALL_HOME}/bin/conda install --file $DEFAULT_VENV_REQUIREMENTS \
                                           --yes \
                                           --quiet

