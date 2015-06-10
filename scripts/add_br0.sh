#!/bin/sh

ip link show br0 >/dev/null
if [ $? -eq 0 ]; then
    echo "br0 already exists"
    exit 0
fi
    
interface=$(ip link show  | grep -v '^\s' | cut -d':' -f2 | sed 's/ //g' | grep -v lo | head -1)
address=$(ip addr show label $interface scope global | awk '$1 == "inet" { print $2,$4}')
ip=$(echo $address | awk '{print $1 }')
ip=${ip%%/*}
broadcast=$(echo $address | awk '{print $2 }')
netmask=$(route -n |grep 'U[ \t]' | grep -v '^169' | head -n 1 | awk '{print $3}')
gateway=$(route -n | grep 'UG[ \t]' | awk '{print $2}')
hostname=`hostname`

cat > /etc/sysconfig/network-scripts/ifcfg-br0 <<EOF
DEVICE="br0"
BOOTPROTO=static
IPADDR=$ip
NETMASK=$netmask
GATEWAY=$gateway
ONBOOT=yes
TYPE=Bridge
EOF

cat > /etc/sysconfig/network-scripts/ifcfg-$interface <<EOF
DEVICE="$interface"
ONBOOT="yes"
BRIDGE=br0
EOF
