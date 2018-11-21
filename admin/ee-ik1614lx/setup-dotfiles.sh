#!/usr/bin/env bash

# Author: Ilya Kisil <ilyakisil@gmail.com>




manual(){
echo "====================================================="
cat << EOF
usage: `basename $0` user_name [-h?]

Setup dotfiles for the USER in the home directory specified
in the /etc/passwd

BASIC OPTIONS:
   -h         Show this message

By Ilya Kisil <ilyakisil@gmail.com>


EOF

show_outline

echo "====================================================="
}

show_outline(){
    echo ""
    echo "====================================================="
    echo "=====        Outline of what will happen        ====="
    echo "====================================================="
    echo ""

    echo "Preparation stage: "

    printf "Configuration stage: \n"
    printf "\t 1. Backup existing configuration (if exists) in: \n"
    printf "\t\t${GREEN}${BACKUP_DIR}${WHITE} \n"
    printf "\t 2. Clean existing configuration (if exists): \n"
    for name in "${CONFIG_FILES[@]}"
    do
        printf "\t\t${RED}$HOME/$name$WHITE\n"
    done
    printf "\t 3. Create new configuration for: \n"
    for name in "${CONFIG_FILES[@]}"
    do
        printf "\t\t$GREEN$HOME/$name$WHITE\n"
    done

#TODO: make use of functions green and red

}


##########################################
###--------   Default values   --------###
##########################################

_FILE_NAME=`basename ${BASH_SOURCE[0]}`

USER_NAME=$1

USER_UID="$(echo `getent passwd ${USER_NAME}` | awk -F: '{ print $3 }')"
USER_GID="$(echo `getent passwd ${USER_NAME}` | awk -F: '{ print $4 }')"
USER_HOME="$(echo `getent passwd ${USER_NAME}` | awk -F: '{ print $6 }')"



DATE=`date '+%Y-%m-%d'`
TIME=`date '+%H-%M-%S'`
OS=`uname`
COPY="cp -r"
BACKUP_HOME="${HOME}/.config_bak"
CONFIG_HOME="${HOME}/.config/csp-mandic-config"
CONFIG_SOURCE_FILE_NAME="bootstrap-config.sh"

declare -a CONFIG_FILES=(".gitconfig"
                         ".gitignore-global"
                         ".zshrc"
                         ".zshrc-local"
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


backup_config(){
    printf "\n`INFO $_FILE_NAME` Backing up an existing configuration.\n"

    BACKUP_DIR="${BACKUP_HOME}/csp_dotfiles_${DATE}_${TIME}"
    mkdir $BACKUP_DIR
    README="$BACKUP_DIR/README.md"

    printf "Backup of configuration existed on $DATE at $TIME:\n\n" > $README
    for name in "${CONFIG_FILES[@]}"
    do
        config_file="$HOME/$name"
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
        config_file="$HOME/$name"
        if [[ -f $config_file ]]; then
            rm $config_file
        elif [[ -d $config_file ]]; then
            rm $config_file
        elif [[ -L $config_file ]]; then
            rm $config_file
        fi
    done


}

git_bootstrap(){
    printf "\n`INFO $_FILE_NAME` Bootstrap of `green "GIT"` config files.\n"

    printf "\t 1) Creating `green ".gitconfig"`\n"
    $COPY $CONFIG_HOME/dotfiles/git/gitconfig $HOME/.gitconfig

    GETENTPASSWD="$(getent passwd ${USER})"

    # Set user name
    USER_NAME="$(echo ${GETENTPASSWD} | awk -F: '{ print $5 }')"
    sed -i "s|__USER_NAME__|$USER_NAME|g" $HOME/.gitconfig

    # Set user email
    USER_EMAIL="${USER}@ic.ac.uk"
    sed -i "s|__USER_EMAIL__|$USER_EMAIL|g" $HOME/.gitconfig

    printf "\t 2) Creating `green ".gitignore-global"`\n"
    $COPY $CONFIG_HOME/dotfiles/git/gitignore-global $HOME/.gitignore-global
}

tmux_bootstrap(){
    printf "\n`INFO $_FILE_NAME` Bootstrap of `green "TMUX"` config files.\n"

    printf "\t 1) Creating `green ".tmux.conf"`\n"
    $COPY $CONFIG_HOME/dotfiles/tmux/tmux.conf $HOME/.tmux.conf

    printf "\t 2) Creating local configuration for tmux in `green ".tmux-local.conf"`\n"
    $COPY $CONFIG_HOME/dotfiles/tmux/tmux-local.conf $HOME/.tmux-local.conf

    printf "\t 3) Cloning `green "Tmux plugin manager"`\n"
    if [[ -d $HOME/.tmux/plugins/tpm/ ]]; then
        echo -e "\t `WARNING $_FILE_NAME` Tmux Plugin Manager exists. Skipping this step."
    else
        git clone https://github.com/ICL-CSP/tpm.git $HOME/.tmux/plugins/tpm
    fi
    echo -e "Press `green "prefix + I"` in tmux session to install plugins."
}

zsh_bootstrap(){
    printf "\n`INFO $_FILE_NAME` Bootstrap of `green "ZSH"` config files.\n"

    printf "\t 1) Cloning `green "oh-my-zsh"`\n"
    if [[ -d $HOME/.oh-my-zsh/ ]]; then
        echo -e "\t `WARNING $_FILE_NAME` Oh-My-Zsh exists. Skipping this step."
    else
        git clone https://github.com/ICL-CSP/oh-my-zsh.git $HOME/.oh-my-zsh/
    fi

    printf "\t 2) Creating `green ".zshrc"`\n"
    $COPY $CONFIG_HOME/dotfiles/zsh/zshrc $HOME/.zshrc

    printf "\t 3) Creating local configuration for the zsh in `green ".zshrc-local"`\n"
    $COPY $CONFIG_HOME/dotfiles/zsh/zshrc-local $HOME/.zshrc-local

    printf "\t 4) Configuring local paths for the `green ".zshrc-local"`\n"
    # Use different separator, since $CONFIG_HOME contains '/' symbol:
    sed -i "s|__CONFIG_HOME__|$CONFIG_HOME|g" $HOME/.zshrc-local
}


##########################################
###--------        Main        --------###
##########################################
show_outline

printf "\nLet's get started? (y/n) "
answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
if echo "$answer" | grep -iq "^y" ;then
    echo -e "\nFingers crossed and start. `green ":-/"`"
else
    echo -e "\nQuitting, nothing was changed `red ":-("`\n"
    exit 0
fi

#backup_config
#clean_config
#git_bootstrap
#zsh_bootstrap
#tmux_bootstrap

printf "\n=======================================\n"
printf "=== `green 'Profile configuration completed'` ===\n"
printf "=======================================\n\n"
