#!/bin/sh

#add route-policy
src=$(ip addr show tun0 | grep 'inet ' | sed 's/^.*inet //g' | sed 's/\/16.*$//g')
gw=$(ip addr show tun0 | grep 'inet ' | cut -d' ' -f6 | cut -d'.' -f1-2).0.1
ip route add default via $gw dev tun0 src $src table 100 
ip rule add from all fwmark 1 table 100
#ip route add 8.8.8.8 via $gw dev tun0 src $src

#check and add rules of mangle     
DATE=`date +%Y-%m-%d-%H:%M:%S`
iptables -t mangle -C PREROUTING -m set ! --match-set chnroute dst -j MARK --set-mark 1
if [ $? = 0 ]; then
        echo "$DATE: The PREROUTING of mangle rules alread exist" 
        iptables -t mangle -C OUTPUT -m set ! --match-set chnroute dst -j MARK --set-mark 1
        if [ $? = 0 ]; then
                echo "$DATE: The OUTPUT of mangle rules alread exist"
                exit 0
        else
                iptables -t mangle -I OUTPUT -m set ! --match-set chnroute dst -j MARK --set-mark 1
                echo "$DATE: Add OUTPUT of mangle rules"
                exit 0
        fi
else
        iptables -t mangle -I PREROUTING -m set ! --match-set chnroute dst -j MARK --set-mark 1
        echo "$DATE: Add PREROUTING of mangle rules"

        iptables -t mangle -C OUTPUT -m set ! --match-set chnroute dst -j MARK --set-mark 1
        if [ $? = 0 ]; then
                echo "$DATE: The OUTPUT rules of mangle alread exist"
                exit 0
        else
                iptables -t mangle -I OUTPUT -m set ! --match-set chnroute dst -j MARK --set-mark 1
                echo "$DATE: Add OUTPUT of mangle rules"
                exit 0
        fi
fi
