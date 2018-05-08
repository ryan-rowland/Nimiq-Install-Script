#!/bin/bash
################################################################################
# Author:  Bhlynd
# Program: Install Nimiq on Ubuntu
# Flavor: Porky Pool (https://www.porkypool.com)
################################################################################
output() {
    printf "\E[0;33;40m"
    echo $1
    printf "\E[0m"
}

displayErr() {
    echo
    echo $1;
    echo
    exit 1;
}

    output " "
    output "Make sure you double check before hitting enter! Only one shot at these!"
    output "You will find examples in the brackets."
    output " "
    read -e -p "Enter the pool URL: " -i "us-east.porkypool.com:8444" POOL
    read -e -p "Enter the miner CPU threads: " -i $(getconf _NPROCESSORS_ONLN) THREADS
    read -e -p "Enter your wallet address: " WALLET
    read -e -p "Enter device name: " EXTRADATA
    read -e -p "Enter statistics interval in seconds: " -i "10" STATISTICS
    
    output " "
    output "Making sure everything is up to date."
    output " "
    sleep 3
    
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt-get -y update 
    sudo apt-get -y upgrade
    sudo apt-get -y autoremove
    
    output " "
    output "Adding nodejs sources."
    output " "
    sleep 3
    
    curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash - 
    
    output " "
    output "Installing required dependencies."
    output " "
    sleep 3
    
    sudo apt-get install -y git build-essential python2.7 python-dev nodejs unzip
	
    output " "
    output "Downloading Nimiq core."
    output " "
    sleep 3

    git clone https://github.com/nimiq-network/core.git

    output " "
    output "Building Nimiq core client."
    output " "
    sleep 3

    cd core
    sudo npm install -g gulp
    npm install
    gulp build-node
    sudo npm install -g node-gyp
    cd node_modules/node-lmdb
    node-gyp rebuild

    output " "
    output "Building launch scripts."
    output " "
    sleep 3

    cd ..
    echo '#!/bin/bash
    SCRIPT_PATH=$(dirname "$0")/core
    $SCRIPT_PATH/clients/nodejs/nimiq "$@"' > miner
    chmod u+x miner
 
    echo '#!/bin/bash
    UV_THREADPOOL_SIZE='"${THREADS}"' ./miner --dumb --pool='"${POOL}"' --miner='"${THREADS}"' --wallet-address="'"${WALLET}"'" --extra-data="'"${EXTRADATA}"'" --statistics='"${STATISTICS}"'' > start
    chmod u+x start

    output " "
    output "You can start the miner by typing ./start"
    output "If you need to change any settings, you can do so inside the ./start file."
    output " "
    sleep 3
