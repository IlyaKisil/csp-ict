#!/usr/bin/env bash

# Author: Ilya Kisil <ilyakisil@gmail.com>

_FILE_NAME=`basename ${BASH_SOURCE[0]}`


USER_HOME=$1
ANACONDA_INSTALL_HOME="${USER_HOME}/Miniconda3"

echo "`INFO $_FILE_NAME` Configuring local installation of miniconda in [${ANACONDA_INSTALL_HOME}]."

#bash $CSP_ICT_HOME/software/miniconda/install.sh -b -p ${ANACONDA_INSTALL_HOME}

echo "`INFO $_FILE_NAME` Configuring default venv."
#${ANACONDA_INSTALL_HOME}/bin/conda update conda \
#                                          --yes \
#                                          --quiet

#${ANACONDA_INSTALL_HOME}/bin/conda create --name "py36" \
#                                          --file /etc/csp/anaconda/default_requirements.txt \
#                                          --yes \
#                                          --quiet

# TODO: Configure jupyterlab and relevant extensions