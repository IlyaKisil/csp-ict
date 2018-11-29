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

NVM_INSTALL_HOME="${USER_HOME}/.nvm"
NODEJS_VERSION=`cat "${EE_IK1614LX_SETUP_HOME}/default_nodejs_version.txt"`


echo "`INFO $_FILE_NAME` Configuring local installation of nodejs in [${NVM_INSTALL_HOME}]"


echo "`INFO $_FILE_NAME` Installing NodeJS Version Manager (NVM)"

if [[ ! -d $NVM_INSTALL_HOME/ ]]; then
    mkdir $NVM_INSTALL_HOME
fi
env NVM_DIR="${NVM_INSTALL_HOME}" PROFILE="/dev/null" bash $CSP_ICT_HOME/software/nvm/install.sh


echo "`INFO $_FILE_NAME` Installing NodeJS ${NODEJS_VERSION} with NVM"
source $NVM_INSTALL_HOME/nvm.sh
nvm install $NODEJS_VERSION


