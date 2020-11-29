#!/bin/bash

##############################################
## Update to new lighthouse version from tags 
##############################################

#global vars
blue="\e[1;34m"
reset="\e[0m"

# permission checks
stat_beacon=$(stat -c "%a %U %G" /var/lib/lighthouse/beacon)
stat_validators=$(stat -c "%a %U %G" /var/lib/lighthouse/validators)
stat_git=$(stat -c "%a %U %G" ~/git/lighthouse)
echo "Check data..."
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
    read -p "$(echo -e "${blue}Start to get latest release sources with git fetch --tags?${reset}")" yn
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
    read -p "$(echo -e "${blue}Found Release $tag, call git checkout $tag?${reset}")" yn
    case $yn in
        [Yy]* ) git checkout $tag; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo "'git checkout $tag' executed"

# build sources
while true; do
    read -p "$(echo -e "${blue}Try to build lighthouse $tag with make?${reset}")" yn
    case $yn in
        [Yy]* ) make; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# check services
echo "Services found:"
for i in $(ls /etc/systemd/system/lighthouse*); do
    basename $i
done

# stop services to replace binary
while true; do
    read -p "$(echo -e "${blue}Stop lighthouse services?${reset}")" yn
    case $yn in
        [Yy]* ) sudo systemctl stop lighthouse-beacon.service; sudo systemctl stop lighthouse-validators.service; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# replace binary
while true; do
    read -p "$(echo -e "${blue}Replace new lighthouse binary" $tag "in /usr/local/bin now?${reset}")" yn
    case $yn in
        [Yy]* ) sudo cp $HOME/.cargo/bin/lighthouse /usr/local/bin/lighthouse; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo -e "binary replaced in /usr/local/bin"

# start services
while true; do
    read -p "$(echo -e "${blue}Start lighthouse services?${reset}")" yn
    case $yn in
        [Yy]* ) sudo systemctl start lighthouse-beacon.service; sudo systemctl start lighthouse-validators.service; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
systemctl list-units --type=service --state=running | grep lighthouse
echo "Job Done"
