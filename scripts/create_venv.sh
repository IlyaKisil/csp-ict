#!/bin/bash

# Author: Ilya Kisil <ilyakisil@gmail.com>


VENV_NAME="$1"

conda create --name ${VENV_NAME} python=3.6.5

source activate $VENV_NAME

python -m ipykernel install --user --name ${$VENV_NAME} --display-name ${$VENV_NAME}

source deactivate $VENV_NAME
