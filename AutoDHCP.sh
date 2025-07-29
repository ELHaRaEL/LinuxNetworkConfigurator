#!/bin/bash

LanInterface=$(grep "LanInterface=" Config | sed 's/LanInterface=//')
LanProfile=$(grep "LanProfileAuto=" Config | sed 's/LanProfileAuto=//')
DNS1=$(grep "DNS1=" Config | sed 's/DNS1=//')
DNS2=$(grep "DNS2=" Config | sed 's/DNS2=//')

if nmcli device status | grep -q $LanInterface ; then
    echo "Found interface "$LanInterface
    echo 'Set profile: '$LanProfile;echo;
else 
    echo "Does not find interface "$LanInterface    
    echo "Enter to exit."
    read
    exit 1
fi



nmcli -t -f NAME connection show --active | grep -q $LanProfile
if [ $? -eq 0 ]; then
    nmcli connection down $LanProfile
fi 
sudo ip addr flush dev $LanInterface 

nmcli connection modify $LanProfile ipv6.method disabled
nmcli connection modify $LanProfile ipv4.addresses ""
nmcli connection modify $LanProfile ipv4.gateway ""
nmcli connection modify $LanProfile ipv4.dns ""
nmcli connection modify $LanProfile ipv4.method auto
nmcli connection modify $LanProfile +ipv4.dns $DNS1,$DNS2
nmcli connection up $LanProfile

echo;echo;

echo "Network Manager Profile:                "$LanProfile;echo;
nmcli connection show $LanProfile | awk '/ipv4.method/'
nmcli connection show $LanProfile | awk '/IP4.ADDRESS/'
nmcli connection show $LanProfile | awk '/IP4.GATEWAY/'
nmcli connection show $LanProfile | awk '/IP4.DNS/'
nmcli connection show $LanProfile | awk '/ subnet_mask/'

echo;

InterfaceLinkSpeed=$(cat /sys/class/net/$LanInterface/speed);
InterfaceLinkOperstate=$(cat /sys/class/net/$LanInterface/operstate);
echo;echo "Interface:                              "$LanInterface"    "$InterfaceLinkOperstate"      "$InterfaceLinkSpeed"Mb/s";echo "     ";
ip address show $LanInterface | grep -oE 'inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
ip address show $LanInterface | grep -oE 'netmask [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
ip address show $LanInterface | grep -oE 'broadcast [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
echo 
echo "inet6:"
ip address show $LanInterface | grep -oE 'inet6 [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
echo
echo "Enter to exit"
read 
exit
