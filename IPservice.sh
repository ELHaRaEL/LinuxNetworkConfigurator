#!/bin/bash

LanInterface=$(grep "LanInterface=" Config | sed 's/LanInterface=//')
LanProfile=$(grep "LanProfile=" Config | sed 's/LanProfile=//')
DNS1=$(grep "DNS1=" Config | sed 's/DNS1=//')
DNS2=$(grep "DNS2=" Config | sed 's/DNS2=//')


FileWithIps="IPservice.txt"
declare -a tablename
declare -a tableip

function showIPs 
{

while IFS=: read -r name address_ip; do
    tablename+=("$name")
    tableip+=("$address_ip")
done < $FileWithIps

for ((i = 0; i < ${#tableip[@]}; i+=1)); do
    name="${tablename[i]}"
    address_ip="${tableip[i]}"
   printf " %3s.  %11s \t\t\t %s \n"   "$[i+1]"  "${tableip[i]}" "${tablename[i]}"

done

}



if [ ! -e $FileWithIps ]; then
    echo "Plik $FileWithIps nie istnieje."
    exit 1
fi

echo;echo
showIPs 
echo;



while true; do
    read -p "Number: " number

    if [[ "$number" -ge 1 && "$number" -le ${#tableip[@]} ]]; then
        echo 
        echo "${tablename[$[number-1]]}"
        echo "${tableip[$[number-1]]}"
        echo
            if nmcli device status | grep -q $LanInterface ; then
               echo "Found interface       "$LanInterface
               echo 'Set profle:           '$LanProfile;echo;
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
        newaddresses=$(echo "${tableip[$number-1]}" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')
        nmcli connection modify $LanProfile ipv6.method disabled
        nmcli connection modify $LanProfile ipv4.method manual 
        nmcli connection modify $LanProfile ipv4.addresses "$newaddresses/24"
        nmcli connection modify $LanProfile ipv4.gateway 255.255.255.0
        nmcli connection modify $LanProfile ipv4.dns $DNS1,$DNS2
        nmcli connection up $LanProfile
        echo;
        echo "Network Manager Profile:                "$LanProfile;echo;
        nmcli connection show $LanProfile | awk '/ipv4.address/'
        nmcli connection show $LanProfile | awk '/ipv4.gateway/'
        nmcli connection show $LanProfile | awk '/ipv4.dns:/'
        echo;echo;
        InterfaceLinkSpeed=$(cat /sys/class/net/$LanInterface/speed);
        InterfaceLinkOperstate=$(cat /sys/class/net/$LanInterface/operstate);
        echo;echo "Interface:                              "$LanInterface"    "$InterfaceLinkOperstate"      "$InterfaceLinkSpeed"Mb/s";echo "     ";
        ip address show $LanInterface | grep -oE 'inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
        ip address show $LanInterface | grep -oE 'netmask [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
        ip address show $LanInterface | grep -oE 'broadcast [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
        echo;echo "inet6:"
        ip address show $LanInterface | grep -oE 'inet6 [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
        echo;echo;
        echo "Set:   ${tablename[$[number-1]]}"
        echo;echo "Enter to exit"
        read 
        exit

        break 
    else
        echo "Enter a number in the range <1,${#tableip[@]}>. Try again."
    fi
done

