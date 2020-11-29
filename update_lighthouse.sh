#!/bin/bash

##############################################
## Update to new lighthouse version from tags 
##############################################

cd ~/git/lighthouse
git fetch --tags
tag=$(git describe --tags `git rev-list --tags --max-count=1`)

while true; do
    read -p "Found Release $tag. Checkout?" yn
    case $yn in
        [Yy]* ) git checkout $tag; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo "'git checkout $tag' executed"

while true; do
    read -p "Try to build lighthouse $tag?" yn
    case $yn in
        [Yy]* ) make; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo "'make' executed"

while true; do
    read -p "Replace new binary $tag in /usr/local/bin now?" yn
    case $yn in
        [Yy]* ) sudo cp $HOME/.cargo/bin /usr/local/bin; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo "binary replaced"

while true; do
    read -p "Restart lighthouse?" yn
    case $yn in
        [Yy]* ) sudo systemctl restart lighthouse-beacon.service; sudo systemctl restart lighthouse-validators.service; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo "Job Done"
