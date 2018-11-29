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

# This user (ik1614) MUST specify for which user this setup should be performed
if [ $USER_NAME == "ik1614" ] ; then
    echo "`ERROR $_FILE_NAME` Can not perform setup for [ik1614]"
    error_exit
fi

USER_HOME="$(echo `getent passwd ${USER_NAME}` | awk -F: '{ print $6 }')"

# Need to specify path to jupyter executable since at setup time it defaults to system-wide location
JUPYTER_EXEC="${USER_HOME}/Miniconda3/bin/jupyter"

# Double check that the extensions will be installed in the USER's home directory
BASE_KERNEL_HOME=`$JUPYTER_EXEC kernelspec list`
if [[ ! $BASE_KERNEL_HOME == *"${USER_HOME}"* ]]; then
    error_exit
fi

echo "`INFO $_FILE_NAME` Configuring jupyterlab extensions for default virtual environment."
$JUPYTER_EXEC labextension install @jupyterlab/toc --no-build
$JUPYTER_EXEC labextension install @jupyter-widgets/jupyterlab-manager@0.38 --no-build
$JUPYTER_EXEC labextension install @jupyterlab/plotly-extension@0.17 --no-build
$JUPYTER_EXEC lab clean
$JUPYTER_EXEC lab build
$JUPYTER_EXEC labextension list
