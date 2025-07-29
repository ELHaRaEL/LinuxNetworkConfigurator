#!/bin/bash

LanInterface=$(grep "LanInterface=" Config | sed 's/LanInterface=//')
LanProfile=$(grep "LanProfile=" Config | sed 's/LanProfile=//')
LanProfileAuto=$(grep "LanProfileAuto=" Config | sed 's/LanProfileAuto=//')

nmcli connection delete $LanProfile
nmcli connection delete $LanProfileAuto



nmcli connection add con-name $LanProfile ifname $LanInterface type ethernet
nmcli connection modify $LanProfile ipv6.method disabled
nmcli connection modify $LanProfile ipv4.addresses ""
nmcli connection modify $LanProfile ipv4.gateway ""
nmcli connection modify $LanProfile ipv4.dns ""



nmcli connection add con-name $LanProfileAuto ifname $LanInterface type ethernet
nmcli -t -f NAME connection show --active | grep -q $LanProfileAuto
if [ $? -eq 0 ]; then
    nmcli connection down $LanProfileAuto
fi 
sudo ip addr flush dev $LanInterface 
nmcli connection modify $LanProfileAuto ipv6.method disabled
nmcli connection modify $LanProfileAuto ipv4.addresses ""
nmcli connection modify $LanProfileAuto ipv4.gateway ""
nmcli connection modify $LanProfileAuto ipv4.dns ""
nmcli connection modify $LanProfileAuto ipv4.method auto
nmcli connection modify $LanProfileAuto +ipv4.dns 8.8.8.8,194.150.251.2
nmcli connection up $LanProfileAuto
