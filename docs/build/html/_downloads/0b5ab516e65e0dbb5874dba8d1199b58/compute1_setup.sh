#! /bin/sh

export LANG=en_US.utf-8
export LC_ALL=en_US.utf-8

# Remove 127.0.1.1 controller, if present
cat << EOF > /etc/hosts
127.0.0.1 localhost
10.1.1.11 controller
10.1.1.31 compute1
10.1.1.32 compute2
10.1.1.41 block1
EOF

# Cambio de enp0sX a ethY (requiere reinicio)

## Ubuntu 18
#sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/g' /etc/default/grub
#update-grub

## CentOS 7
sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 /g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

# Configuración de interfaz red (Host-only adapter)
cat <<- EOF > /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE="eth1"
TYPE="Ethernet"
ONBOOT="yes"
BOOTPROTO="none"
IPADDR="10.1.1.31"
NETMASK="255.255.255.0"
EOF

# Reinicio de interfaz de red (Host-only adapter)
ifdown eth1
ifup eth1

# Configuración de interfaz red (Bridged adapter)
cat <<- EOF > /etc/sysconfig/network-scripts/ifcfg-eth3
DEVICE="eth3"
TYPE="Ethernet"
ONBOOT="yes"
BOOTPROTO="none"
IPADDR="192.168.1.131"
NETMASK="255.255.255.0"
EOF

# Reinicio de interfaz de red (Bridged adapter)
ifdown eth3
ifup eth3

# Reiniciar el sistema
reboot
