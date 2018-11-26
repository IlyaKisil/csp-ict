#!/usr/bin/env bash

# Author: Ilya Kisil <ilyakisil@gmail.com>

local _FILE_NAME
_FILE_NAME=`basename ${BASH_SOURCE[0]}`


USER_NAME=$1
USER_HOME="$(echo `getent passwd ${USER_NAME}` | awk -F: '{ print $6 }')"

ANACONDA_INSTALL_HOME="${USER_HOME}/Miniconda3"
DEFAULT_VENV_NAME="py36"
DEFAULT_VENT_REQUIREMENTS="${EE_IK1614LX_SETUP_HOME}/default_venv_requirements.txt"

echo "`INFO $_FILE_NAME` Configuring local installation of miniconda in [${ANACONDA_INSTALL_HOME}]."

bash $CSP_ICT_HOME/software/miniconda/install.sh -b -p ${ANACONDA_INSTALL_HOME}

echo "`INFO $_FILE_NAME` Configuring default virtual environment."
${ANACONDA_INSTALL_HOME}/bin/conda update conda \
                                          --yes \
                                          --quiet

${ANACONDA_INSTALL_HOME}/bin/conda create --name $DEFAULT_VENV_NAME \
                                          --file $DEFAULT_VENT_REQUIREMENTS \
                                          --yes \
                                          --quiet

# TODO: Configure jupyterlab and relevant extensions