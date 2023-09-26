#!/bin/sh

iptables -t mangle -C PREROUTING -m set ! --match-set chnroute dst -j MARK --set-mark 1
if [ $? = 0 ]; then
        echo "------------the PREROUTING rules alread exist"
        iptables -t mangle -C OUTPUT -m set ! --match-set chnroute dst -j MARK --set-mark 1
        if [ $? = 0 ]; then
                echo "------------the OUTPUT rules alread exist"
                exit 0
        else
                iptables -t mangle -I OUTPUT -m set ! --match-set chnroute dst -j MARK --set-mark 1
                echo "------------add OUTPUT  rules------------------"
        fi
else
        iptables -t mangle -I PREROUTING -m set ! --match-set chnroute dst -j MARK --set-mark 1
        echo "------------add PREROUTING rules------------------"

        iptables -t mangle -C OUTPUT -m set ! --match-set chnroute dst -j MARK --set-mark 1
        if [ $? = 0 ]; then
                echo "------------the OUTPUT rules alread exist"
                exit 0
        else
                iptables -t mangle -I OUTPUT -m set ! --match-set chnroute dst -j MARK --set-mark 1
                echo "------------add OUTPUT  rules------------------"
        fi
fi

src=$(ip addr show tun0 | grep 'inet ' | sed 's/^.*inet //g' | sed 's/\/16.*$//g')
ip route add default via 172.16.0.1 dev tun0 src $src table 100 
ip rule add from all fwmark 1 table 100
