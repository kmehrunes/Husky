#!/bin/bash

function usage() {
    echo "You can use husky in one of the following ways: "
    echo "1. set up the current directory"
    echo "   husky init"
    echo "2. view the current deployment scenario"
    echo "   husky view"
    echo "3. deploy"
    echo "   husky run <one or more project directories>"
}

if [ $# -lt 1 ]; then
    usage;
    exit 1;
fi

current_dir_name=${PWD##*/}

function init() {

    ## check if there are already build and deploy files
    if [ -e husky.info ] || [ -e husky.build ] || [ -e husky.deploy ]; then
        echo "There is already deployment information in this directory."
        echo "Run 'husky clean' to remove it"
        exit 1
    fi

    ## get the remote server IP or hostnam
    read -p "remote server (hostname or IP): " server

    if [[ -z "${server// }" ]]; then
        echo "Error: server cannot be empty"
        exit 1
    fi

    ## get the rest of the information
    read -p "remote username (default $USER): " user
    read -p "local build directory (default ./deployables): " build
    read -p "remote directory (default home directory of the remote user): " directory

    if [[ -z "${user// }" ]]; then
        user=$USER
    fi

    if [[ -z "${build// }" ]]; then
        build="deployables/"
    fi

    if [[ -z "${directory// }" ]]; then
        directory="/home/$user/deployables/$current_dir_name"
    fi

    ## create the files
    touch husky.info
    touch husky.build
    touch husky.deploy

    ## write the information
    echo "server=$server" > husky.info
    echo "user=$user" >> husky.info
    echo "build=$build" >> husky.info
    echo "directory=$directory" >> husky.info

    echo "#!/bin/bash" > husky.build
    echo "# Enter your production build commands here" >> husky.build

    echo "#!/bin/bash" > husky.deploy
    echo "# Enter your production deployment commands here" >> husky.deploy
    echo "# The commands in this file will be executed on the remote server, in the remote directory so be careful with your file paths" >> husky.deploy

    ## done
    echo "Finished setting up deployment information"
    echo "Put the build commands in husky.build (make sure that they're written to deployables)"
}

function clean() {
    ## removes Husky files
    if [ -e husky.info ]; then
        rm husky.info
    fi

    if [ -e husky.build ]; then
        rm husky.build
    fi

    if [ -e husky.deploy ]; then
        rm husky.deploy
    fi
}

function view() {
    if [ ! -e husky.info ]; then
        echo "Error: missing husky.info file"
        echo "Run 'husky init' to set it up"
        exit 1
    fi

    if [ ! -e husky.build ]; then
        echo "Error: Missing husky.build file"
        echo "Run 'husky init' to set it up"
        exit 1
    fi

    if [ ! -e husky.deploy ]; then
        echo "Error: Missing husky.deploy file"
        echo "Run 'husky init' to set it up"
        exit 1
    fi

    echo "Build and deployment information"
    cat husky.info
    echo
    echo "Build commands"
    cat husky.build
}

if [ $# -eq 1 ]; then
    if [ $1 == "init" ]; then
        init
        exit 0
    elif [ $1 == "view" ]; then
        view
        exit 0
    elif [ $1 == "clean" ]; then
        clean
        exit 0
    elif [ $1 != "run" ]; then
        usage
        exit 1
    fi
fi

## ---- all that happens here is for 'run' ---- ##

CONFIG="husky.info"
SERVER_KEY="server"
USER_KEY="user"
BUILD_KEY="build"
DIR_KEY="directory"

# Usage: get_property FILE KEY
function get_property
{
    grep "^$2=" "$1" | cut -d'=' -f2
}

function build() {
    echo "Building .."
    bash husky.build
}

function deploy() {
    echo "Deploying .."
    config=husky.info
    server=$(get_property $CONFIG $SERVER_KEY)
    user=$(get_property $CONFIG $USER_KEY)
    build=$(get_property $CONFIG $BUILD_KEY)
    remote=$(get_property $CONFIG $DIR_KEY)

    echo "This is the last modification information in $build"
    stat $build/* | grep -e "File: " -e "Modify: "

    echo

    read -p "Confirm deployment (y=yes, anything else=no)? " answer
    if [ $answer == "y" -o $answer == "Y" ]; then
        scp $build/* "$user@$server:$remote"
        ssh $user@$server "cd $remote && bash -s " < husky.deploy
    fi
}


# run in the current directory
if [ $# -eq 1 ]; then
    build
    deploy
    exit
fi

# run in the following directory
current_dir=$PWD
for arg in ${@:2}; do
    if cd $arg/ ; then
        build
        deploy
        cd $current_dir
    fi
done
