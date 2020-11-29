# lighthouse-update-script
update your lighthouse client for eth2 stacking. 

This script will check your lighthouse folders and permissions
* Automatically retrieve informations of latest git release 
* Checkout the release from git
* Build from source
* Replace lighthouse binary in `/usr/local/bin`

## Initial Setup
This is the recommended way to setup your services and data folders.

### create new users without home dir and without shell permissions
* `sudo useradd --no-create-home --shell /bin/false lighthousebeacon`
* `sudo useradd --no-create-home --shell /bin/false lighthousevalidator`

### create folders with permissions
* `sudo mkdir -p /var/lib/lighthouse/beacon`
* `sudo mkdir -p /var/lib/lighthouse/validators`
* `sudo mkdir -p /var/lib/lighthouse/secrets`
* `sudo chown -R lighthousebeacon:lighthousebeacon /var/lib/lighthouse/beacon`
* `sudo chown -R lighthousevalidator:lighthousevalidator /var/lib/lighthouse/validators`
* `sudo chown -R lighthousevalidator:lighthousevalidator /var/lib/lighthouse/secrets`

### set root permission on the parent directory
* `sudo chown root:root /var/lib/lighthouse`

### get lighthouse sources from github
* `cd ~/git`
* `git clone https://github.com/sigp/lighthouse`

### usage
* `./update_lighthouse.sh`

## Conclusion

This script was updated based on this tutorial:\
https://agstakingco.gitbook.io/pyrmont-lighthouse-eth-2-0-staking-guide/

We like to run as a service and we dont want to use home directory. \
We want to use special permissions without shell access. 

This script will help to make sure everything is fine
