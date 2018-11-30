#!/usr/bin/env bash

# Author: Ilya Kisil <ilyakisil@gmail.com>

set -e


manual(){
echo "====================================================="
cat << EOF
usage: `basename $0` user_name [-h]

Setup dotfiles for the USER in the home directory specified
in the /etc/passwd

BASIC OPTIONS:
   -h         Show this message

By Ilya Kisil <ilyakisil@gmail.com>


EOF

show_outline

echo "====================================================="
}

##########################################
###--------   Default values   --------###
##########################################

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

if [ -z $CSP_ICT_HOME ]; then
    echo "`ERROR $_FILE_NAME` Missing some required variables."
    error_exit
fi


DATE=`date '+%Y-%m-%d'`
TIME=`date '+%H-%M-%S'`

USER_EMAIL="${USER_NAME}@ic.ac.uk"
USER_HOME="$(echo `getent passwd ${USER_NAME}` | awk -F: '{ print $6 }')"
BACKUP_HOME="${USER_HOME}/.csp_ict_update.bak"
BACKUP_DIR="${BACKUP_HOME}/dotfiles/${DATE}_${TIME}"

OS=`uname`
declare -a CONFIG_FILES=(".gitconfig"
                         ".gitignore-global"
                         ".zshrc"
                         ".zshrc-local"
                         ".config/zsh"
                         ".tmux.conf"
                         ".tmux-local.conf"
                         )

AUTO=0

while getopts "ha" OPTION;
do
	case $OPTION in
		h|\?)
			manual
            exit
			;;
        a)  AUTO=1
            ;;
	esac
done

#########################################
###--------     Functions     --------###
#########################################

show_outline(){
    echo ""
    echo "====================================================="
    echo "=====        Outline of what will happen        ====="
    echo "====================================================="
    echo ""

    echo "Preparation stage: "

    printf "Configuration stage: \n"
    printf "\t 1. Backup existing configuration (if exists) in: \n"
    printf "\t\t`green $BACKUP_DIR` \n"
    printf "\t 2. Clean existing configuration (if exists): \n"
    for name in "${CONFIG_FILES[@]}"
    do
        printf "\t\t`red $USER_HOME/$name` \n"
    done
    printf "\t 3. Create new configuration for: \n"
    for name in "${CONFIG_FILES[@]}"
    do
        printf "\t\t`green $USER_HOME/$name` \n"
    done
}

backup_config(){
    printf "\n`INFO $_FILE_NAME` Backing up an existing configuration.\n"

    mkdir -p $BACKUP_DIR
    README="$BACKUP_DIR/README.md"

    printf "Backup of configuration existed on $DATE at $TIME:\n\n" > $README
    for name in "${CONFIG_FILES[@]}"
    do
        config_file="$USER_HOME/$name"
        if [[ -L $config_file ]]; then
            printf "$config_file is a symlink. No need to backup \n" >> $README
        elif [[ -f $config_file ]]; then
            cp -r $config_file $BACKUP_DIR
            printf "Copying $config_file \n" >> $README
        elif [[ -d $config_file ]]; then
            cp -r $config_file $BACKUP_DIR
            printf "Copying $config_file \n" >> $README
        else
            printf "Config file $config_file does not exist \n" >> $README
        fi
    done
}

clean_config(){
    printf "\n`INFO $_FILE_NAME` Cleaning up an existing configuration.\n"

    for name in "${CONFIG_FILES[@]}"
    do
        config_file="$USER_HOME/$name"
        if [[ -f $config_file ]]; then
            rm $config_file
        elif [[ -d $config_file ]]; then
            rm -r $config_file
        elif [[ -L $config_file ]]; then
            rm $config_file
        fi
    done
}

git_bootstrap(){
    printf "\n`INFO $_FILE_NAME` Bootstrap of `green "GIT"` config files.\n"

    printf "\t 1) Creating `green ".gitconfig"`\n"
    cp $CSP_ICT_HOME/dotfiles/git/gitconfig $USER_HOME/.gitconfig

    # Set user name
    sed -i "s|__USER_NAME__|$USER_NAME|g" $USER_HOME/.gitconfig

    # Set user email
    sed -i "s|__USER_EMAIL__|$USER_EMAIL|g" $USER_HOME/.gitconfig

    printf "\t 2) Creating `green ".gitignore-global"`\n"
    cp $CSP_ICT_HOME/dotfiles/git/gitignore-global $USER_HOME/.gitignore-global
}

tmux_bootstrap(){
    printf "\n`INFO $_FILE_NAME` Bootstrap of `green "TMUX"` config files.\n"

    printf "\t 1) Creating `green ".tmux.conf"`\n"
    cp $CSP_ICT_HOME/dotfiles/tmux/tmux.conf $USER_HOME/.tmux.conf

    printf "\t 2) Creating local configuration for tmux in `green ".tmux-local.conf"`\n"
    cp $CSP_ICT_HOME/dotfiles/tmux/tmux-local.conf $USER_HOME/.tmux-local.conf

    printf "\t 3) Cloning `green "Tmux plugin manager"`\n"
    if [[ -d $USER_HOME/.tmux/plugins/tpm/ ]]; then
        echo -e "\t `WARNING $_FILE_NAME` Tmux Plugin Manager exists. Skipping this step."
    else
        git clone https://github.com/ICL-CSP/tpm.git $USER_HOME/.tmux/plugins/tpm
    fi
    echo -e "Press `green "prefix + I"` in tmux session to install plugins."
}

zsh_bootstrap(){
    printf "\n`INFO $_FILE_NAME` Bootstrap of `green "ZSH"` config files.\n"

    printf "\t 1) Cloning `green "oh-my-zsh"`\n"
    if [[ -d $USER_HOME/.oh-my-zsh/ ]]; then
        echo -e "\t `WARNING $_FILE_NAME` Oh-My-Zsh exists. Skipping this step."
    else
        git clone https://github.com/ICL-CSP/oh-my-zsh.git $USER_HOME/.oh-my-zsh/
    fi

    printf "\t 2) Creating `green ".zshrc"`\n"
    cp $CSP_ICT_HOME/dotfiles/zsh/zshrc $USER_HOME/.zshrc

    printf "\t 3) Creating local configuration for the zsh in `green ".zshrc-local"`\n"
    cp $CSP_ICT_HOME/dotfiles/zsh/zshrc-local $USER_HOME/.zshrc-local

    printf "\t 4) Copying custom theme and plugins for oh-my-zsh in `green "~/.config/zsh/"`\n"
    cp -r $CSP_ICT_HOME/dotfiles/zsh/custom $USER_HOME/.config/zsh/
}


##########################################
###--------        Main        --------###
##########################################
echo "`INFO $_FILE_NAME` Starting configuration of dotfiles."

show_outline

printf "\nLet's get started? (y/n) "
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
if echo "$answer" | grep -iq "^y" ;then
    echo -e "\nFingers crossed and start. `green ":-/"`"
else
    echo -e "\nQuitting, nothing was changed `red ":-("`\n"
    exit 0
    #    TODO: check if 'exit 0' works correctly when 'set -e' is used
fi

backup_config
clean_config
git_bootstrap
zsh_bootstrap
tmux_bootstrap

printf "\n=======================================\n"
printf "=== `green 'Profile configuration completed'` ===\n"
printf "=======================================\n\n"
