#!/bin/bash

install_to_all=/usr/bin/
install_to_local=/home/$USER/.local/bin/

read -p "install local or all (default local): " installation

if [ -z "${installation// }" ]; then
    installation=local
fi

if [ $installation == "local" ]; then
    read -p "installation directory (default $install_to_local): " directory

    if [ -z "${directory// }" ]; then
       directory=$install_to_local
    fi

    cp husky.sh $directory/husky && chmod u+x $directory/husky
elif [ $installation == "all" ]; then
    read -p "installation directory (default $install_to_all): " directory

    if [ -z "${directory// }" ]; then
        directory=$install_to_all
    fi

    cp husky.sh $directory/husky && chmod a+x $directory/husky
else
    echo "Error: invalid input"
fi


