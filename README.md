# Linux Network Configurator
LAN Network Setup Scripts for technics (ip + nmcli)

# IP Configuration Scripts – Installation Guide
## 1. Grant sudo permissions

Check your system username:
```
echo $USER
```


Edit the sudoers file using:
```
sudo visudo
```
Add the following lines at the end, replacing username with your actual username:
```
username    ALL=NOPASSWD: /usr/sbin/ip
username    ALL=NOPASSWD: /usr/bin/systemctl restart networking
username    ALL=NOPASSWD: /usr/sbin/service networking restart
```
Save and close the file.

## 2. Configure your network interface

Check your current network interface name:
```
ip address show
```
Open the configuration file:
```
nano Config
```
Update the following values:
```
LanInterface=enp5s0        # Replace with your actual interface name
DNS1=1.1.1.1               # Replace with your preferred DNS
DNS2=8.8.8.8               # Replace with your preferred DNS
```
Save the file.

##  3. Create connection profiles

Run the initial setup script to generate Lan and AutoDHCP profiles:
```
./SetUp.sh
```
This will register profiles using nmcli.


## 4. Run available scripts

You can now use any of the following scripts to apply different configurations:
```
./AutoDHCP.sh
./IPService.sh
./Lan-\*.\*.\*.\*-Gateway-\*.\*.\*.\*.sh
./Lan-10.0.\*.\*.sh
./Lan-192.168.\*.\*.sh
./LanMercusys.sh
```

Each script sets a specific static IP, gateway, or DNS profile for your LAN connection.

