#!/bin/bash

##############################################
## Update to new lighthouse version from tags 
##############################################

#global vars (tweak for your needs)
datadir="/var/lib/lighthouse"
gitdir="$HOME/git"
targetdir="/usr/local/bin"

blue="\e[1;34m"
green="\e[0;32m"
red="\e[0;31m"
reset="\e[0m"

# permission checks
stat_beacon=$(stat -c "%a %U %G" $datadir/beacon)
stat_validators=$(stat -c "%a %U %G" $datadir/validators)
stat_git=$(stat -c "%a %U %G" $gitdir/lighthouse)
echo "Check data..."
echo "stat_beacon: $stat_beacon"
echo "stat_validators: $stat_validators"
echo "stat_git: $stat_git"

res=0
if [[ $stat_beacon != *"lighthousebeacon"* ]]; then
  echo -e "${red}beacon folder not found or permissions wrong ($datadir/beacon) - FAIL${reset}"
  let res++
fi
if [[ $stat_validators != *"lighthousevalidator"* ]]; then
  echo -e "${red}validators folder not found or permissions wrong ($datadir/validators) - FAIL${reset}"
  let res++
fi
if [[ ! -d $gitdir ]]; then
  echo -e "${red}git folder not found ($gitdir/lighthouse) - FAIL${reset}"
  let res++
fi

if [[ $res != 0 ]]; then
  echo -e "${red}Errors in data structure found. Check your folders if exists and permissions are set.${reset}"
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
        [Yy]* ) make clean; make; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# check services
service_name_beacon=""
service_name_validator=""
for i in $(ls /etc/systemd/system/lighthouse*); do
    if [[ $i == *"beacon"* ]]; then
        service_name_beacon=$(basename $i)
    elif [[ $i == *"validator"* ]]; then
        service_name_validator=$(basename $i)
    fi
done
echo "Beacon service found: $service_name_beacon"
echo "Validator service found: $service_name_validator"

# stop services to replace binary
while true; do
    read -p "$(echo -e "${blue}Stop lighthouse services?${reset}")" yn
    case $yn in
        [Yy]* ) sudo systemctl stop $service_name_beacon; sudo systemctl stop $service_name_validator; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# replace binary
while true; do
    read -p "$(echo -e "${blue}Replace new lighthouse binary" $tag "in ${reset}${green}$targetdir${reset} ${blue}now?${reset}")" yn
    case $yn in
        [Yy]* ) sudo cp $HOME/.cargo/bin/lighthouse $targetdir/lighthouse; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo -e "binary replaced in $targetdir"

# start services
while true; do
    read -p "$(echo -e "${blue}Start lighthouse services?${reset}")" yn
    case $yn in
        [Yy]* ) sudo systemctl start $service_name_beacon; sudo systemctl start $service_name_validator; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
systemctl list-units --type=service --state=running | grep lighthouse
echo "Job Done"
