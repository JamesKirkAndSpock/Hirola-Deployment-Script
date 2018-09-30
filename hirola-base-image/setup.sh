#!/usr/bin/env bash

set -o errexit
set -o pipefail
# set -o nounset
# set -o xtrace

install_dependencies () {
    sudo apt-get -y upgrade
    sudo apt-get -y update
    sudo apt-get install -y python3-pip
    sudo apt-get install -y python-virtualenv
    sudo apt-get install memcached
    sudo apt-get install -y nginx
}

main () {
    install_dependencies
}

main "$@"
