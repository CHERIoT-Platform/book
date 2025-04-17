#!/bin/bash
apt update
echo | apt-get install -y software-properties-common
add-apt-repository -y ppa:sile-typesetter/sile
apt update
echo | apt install -y git luarocks make sile
