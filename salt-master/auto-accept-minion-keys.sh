#!/bin/bash

if [ -z "$1" ]
  then
    echo "./$0 <seconds-to-auto-accept> &"
    exit 1
fi

seconds=$1
tmp_config="/etc/salt/master.d/auto-accept-minion-keys.conf"

# register disable_auto_accept function when complete or aborting.
trap disable_auto_accept 0 1 2 3 15

function enable_auto_accept() {
    echo "auto_accept: True" > $tmp_config
    service salt-master restart
    echo "enabled auto_accept of minion keys."  
}

function disable_auto_accept() {
    rm $tmp_config
    service salt-master restart
    echo "disabled auto_accept of minion keys."  
}

enable_auto_accept
echo "sleeping for $seconds ... please create new minions in another window."
sleep $seconds
