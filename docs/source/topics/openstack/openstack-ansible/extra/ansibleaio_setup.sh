#! /bin/sh

export LANG=en_US.utf-8
export LC_ALL=en_US.utf-8

# Aumentar espacio de particion root '/' del sistema CentOS (mínimo 50 GB libres)
# https://medium.com/@kanrangsan/how-to-automatically-resize-virtual-box-disk-with-vagrant-9f0f48aa46b3
parted /dev/sda resizepart 2 100%
pvresize /dev/sda2
lvextend -l +100%FREE /dev/centos/root
xfs_growfs /dev/centos/root

# Remove 127.0.1.1 ansibleaio, if present
cat << EOF > /etc/hosts
127.0.0.1 localhost
10.1.1.11 ansibleaio
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
IPADDR="10.1.1.11"
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
IPADDR="192.168.1.111"
NETMASK="255.255.255.0"
EOF

# Reinicio de interfaz de red (Bridged adapter)
ifdown eth3
ifup eth3

# Reiniciar el sistema
reboot
