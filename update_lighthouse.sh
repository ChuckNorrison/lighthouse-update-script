#!/bin/bash

##############################################
## Update to new lighthouse version from tags 
##############################################

# permission checks
stat_beacon=$(stat -c "%a %U %G" /var/lib/lighthouse/beacon)
stat_validators=$(stat -c "%a %U %G" /var/lib/lighthouse/validators)
stat_git=$(stat -c "%a %U %G" ~/git/lighthouse)
echo "stat_beacon: $stat_beacon"
echo "stat_validators: $stat_validators"
echo "stat_git: $stat_git"

res=0
if [[ $stat_beacon != *"lighthousebeacon"* ]]; then
  echo "beacon folder not found or permissions wrong (/var/lib/lighthouse/beacon) - FAIL"
  let res++
fi
if [[ $stat_validators != *"lighthousevalidator"* ]]; then
  echo "validators folder not found or permissions wrong (/var/lib/lighthouse/validators) - FAIL"
  let res++
fi
if [[ ! -d ~/git/lighthouse ]]; then
  echo "git folder not found (~/git/lighthouse) - FAIL"
  let res++
fi

if [[ $res != 0 ]]; then
  echo "Errors in data structure found. Check your folders if exists and permissions are set."
  exit
fi

while true; do
    read -p "Start lighthouse update script?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# get last release source from github
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

# build sources
while true; do
    read -p "Try to build lighthouse $tag?" yn
    case $yn in
        [Yy]* ) make; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo "'make' executed"

# update binary
while true; do
    read -p "Replace new binary $tag in /usr/local/bin now?" yn
    case $yn in
        [Yy]* ) sudo cp $HOME/.cargo/bin /usr/local/bin; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo "binary replaced"

# restart services
while true; do
    read -p "Restart lighthouse?" yn
    case $yn in
        [Yy]* ) sudo systemctl restart lighthouse-beacon.service; sudo systemctl restart lighthouse-validators.service; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo "Job Done"
