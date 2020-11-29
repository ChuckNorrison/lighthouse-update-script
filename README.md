# lighthouse-update-script
update your lighthouse client for eth2 stacking. 

This script will check your lighthouse folders and permissions
* Automatically retrieve informations of latest git release 
* Checkout the release from git
* Build from source
* Replace lighthouse binary in `/usr/local/bin`

## create new users without home dir and without shell permissions
sudo useradd --no-create-home --shell /bin/false lighthousebeacon
sudo useradd --no-create-home --shell /bin/false lighthousevalidator

## create folders with permissions
sudo mkdir -p /var/lib/lighthouse/beacon
sudo mkdir -p /var/lib/lighthouse/validators
sudo mkdir -p /var/lib/lighthouse/secrets
sudo chown -R lighthousebeacon:lighthousebeacon /var/lib/lighthouse/beacon
sudo chown -R lighthousevalidator:lighthousevalidator /var/lib/lighthouse/validators
sudo chown -R lighthousevalidator:lighthousevalidator /var/lib/lighthouse/secrets

## set root permission just on this
sudo chown root:root /var/lib/lighthouse

## initial git clone
cd ~/git
git clone https://github.com/sigp/lighthouse

## usage
`./update_lighthouse.sh`
