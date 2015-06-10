#!/bin/sh

HOSTS="192.168.206.151,192.168.206.152"

function pre_install() {
    # Prepare install folder
    dt=`date +%Y%m%d_%H%M%S`
    mkdir hainstall_$dt
    cp ha_kvm.yml hainstall_$dt
   
    # Passwordless ssh connection to dest hosts
    if [ ! -e ~/.ssh/id_rsa ]; then
        ssh-keygen -t rsa -q -N "" -f ~/.ssh/id_rsa
    fi
    hosts=(${HOSTS//,/ })
    for host in ${hosts[@]}; do
        echo "$host  ansible_ssh_user=root" >> hainstall_$dt/hosts
        ssh-copy-id root@$host
    done
}


function install() {
    ansible-playbook -i hainstall_$dt/hosts ymls/nfsclient.yml
    ansible-playbook -i hainstall_$dt/hosts ymls/pacemaker.yml
    ansible-playbook -i hainstall_$dt/hosts ymls/hypervisor.yml
}


pre_install

