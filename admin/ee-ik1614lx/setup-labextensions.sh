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
DEFAULT_VENV_NAME=`cat "${EE_IK1614LX_SETUP_HOME}/default_venv_name.txt"`
DEFAULT_VENT_REQUIREMENTS="${EE_IK1614LX_SETUP_HOME}/default_venv_requirements.txt"


echo "`INFO $_FILE_NAME` Configuring jupyterlab extensions for default virtual environment."

source ${ANACONDA_INSTALL_HOME}/bin/activate $DEFAULT_VENV_NAME
jupyter labextension install @jupyterlab/toc --no-build
jupyter labextension install @jupyter-widgets/jupyterlab-manager@0.38 --no-build
jupyter labextension install @jupyterlab/plotly-extension@0.17 --no-build
jupyter lab clean
jupyter lab build

source ${ANACONDA_INSTALL_HOME}/bin/deactivate
