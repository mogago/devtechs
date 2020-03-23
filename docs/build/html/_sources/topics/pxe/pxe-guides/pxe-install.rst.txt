.. _pxeinstall:

PXE Install
===========

.. contents:: Table of Contents 

Documentación con el proceso de instalación y configuración de herramientas para habilitar un servidor PXE. Este servidor permitará la instalación por red del sistema operativo CentOS 7 en clientes PXE.

Vagrantfile - PXE Server
------------------------

Archivo ``Vagrantfile`` para crear una VM con sistema operativo CentOS 7 usando Vagrant, a la cual se le instalará las herramientas para que funcione como servidor PXE. Los detalles de la VM creada en VirtualBox son los siguientes:

- Sistema operativo CentOS 7 con 4 GB de RAM, 2 vCPUs y 20 GB de almacenamiento
- Tiene 2 interfaces de red:
    - 1 interfaz conectada a NAT (creada por defecto por Vagrant): 10.0.2.15/24
    - 1 interfaz conectada a una red aislada: 192.168.8.8/24
- Pasamos un script para una configuración inicial: ``pxeserver_setup.sh``

.. code-block:: bash

    # -*- mode: ruby -*-
    # vi: set ft=ruby :
    servers=[
    {
        :hostname => "pxeserver",
        :box => "geerlingguy/centos7",
        :ram => 4096,
        :cpu => 2,
        :disk => "20GB",
        :script => "sh /vagrant/pxeserver_setup.sh"
    }
    ]

    Vagrant.configure("2") do |config|
    servers.each do |machine|
        config.vm.define machine[:hostname] do |node|
        node.vm.box = machine[:box]
        node.vm.hostname = machine[:hostname]
        node.vm.provider "virtualbox" do |vb|
            vb.customize ["modifyvm", :id, "--memory", machine[:ram], "--cpus", machine[:cpu]]
            #vb.customize ["modifyvm", :id, "--nic2", "hostonly", "--hostonlyadapter2", "vboxnet0"]
        end
        node.vm.provision "shell", inline: machine[:script], privileged: true, run: "once"
        end
    end
    
    config.vm.define "pxeserver" do |pxeserver|
        pxeserver.vm.network "private_network", ip: '192.168.8.8', virtualbox__intnet: true, adapter: 2
    end
    end

script ``pxeserver_setup.sh``:

.. code-block:: bash

    #! /bin/sh

    cat << EOF > /etc/sysconfig/network-scripts/ifcfg-enp0s8
    DEVICE="enp0s8"
    DEFROUTE="no"
    BOOTPROTO="static"
    IPADDR="192.168.8.8"
    NETMASK="255.255.255.0"
    DNS1="8.8.8.8"
    TYPE="Ethernet"
    ONBOOT=yes
    EOF

    ifdown enp0s8
    ifup enp0s8

Configuración de PXE Server
---------------------------

Instalación de herramientas
'''''''''''''''''''''''''''

El servidor PXE contará con servicios que deberán ser instalados en la VM:

- ``syslinux``: provee distintos bootloaders
- ``dhcp``: ofrece el servicio de DHCP que asignará IPs a todos los clientes conectados en la red interna y booteen usando PXE.
- ``tftp-server``: ofrece el servicio de TFTP (Trivial FTP) que proveerá los bootloaders necesarios (de syslinux) a los clientes PXE.
- ``vsftpd``: ofrece el servicio de FTP que compartirá el medio de instalación del Sistema Operativo (en nuestro caso CentOS 7) a los clientes PXE. Otras opciones a usarse podrían ser NFS o HTTP.

.. code-block:: bash

    $ sudo yum install -y syslinux dhcp tftp-server vsftpd

Instalar otras herramientas de utilidad:

.. code-block:: bash

    $ sudo yum install -y vim wget

Configuración del servicio DHCP
'''''''''''''''''''''''''''''''

El servicio DHCP será configurado con el archivo ``/etc/dhcp/dhcpd.conf``:

.. code-block:: bash

    sudo bash -c 'cat << EOF > /etc/dhcp/dhcpd.conf
    #DHCP configuration for PXE boot server
    ddns-update-style interim;
    ignore client-updates;
    authoritative;
    allow booting;
    allow bootp;
    allow unknown-clients;
    #DHCP pool
    subnet 192.168.8.0
    netmask 255.255.255.0
    {
    range 192.168.8.100 192.168.8.199;
    option domain-name-servers 192.168.8.2;
    option domain-name "midominio.com";
    option routers 192.168.8.2;
    option broadcast-address 192.168.8.255;
    default-lease-time 600;
    max-lease-time 7200;
    #PXE boot server
    next-server 192.168.8.8;
    filename "pxelinux.0";
    }
    # Static lease, fixed IP: hostname-MAC-IP
    host vm2-pxe-client
    {
    option host-name    "vm2.host";
    hardware ethernet   00:11:22:33:44:55;
    fixed-address       192.168.8.50;
    }
    EOF'

- Se tiene un pool de direcciones IP (192.168.8.100 - 192.168.8.199) que se pueden asignar a los cliente conectados a la red.
- Para una MAC específica se asignará un hostname e IP predeterminados. Esto es útil para controlar la asignación de IPs en los clientes PXE.

.. Note::

    Output redirection (e.g., >) is performed by bash, not by cat, while running with your UID. To run with root's UID use ``sudo bash -c``

Habilitación de servicios
'''''''''''''''''''''''''

Habilitaremos e iniciaremos los servicios de DHCP, TFTP y FTP:

.. code-block:: bash

    cat << EOF > enable_pxe_services.sh
    #!/bin/bash
    #DHCP
    systemctl start dhcpd.service && systemctl enable dhcpd.service
    #TFTP
    systemctl start tftp.service && systemctl enable tftp.service
    #FTP
    systemctl start vsftpd.service && systemctl enable vsftpd.service
    systemctl status dhcpd tftp vsftpd
    EOF

    chmod +x enable_pxe_services.sh
    sudo ./enable_pxe_services.sh

Configuración de servicios para habilitar PXE
'''''''''''''''''''''''''''''''''''''''''''''

- Copiar los bootloaders que provee ``syslinux`` a la carpeta TFTP:

.. code-block:: bash

    $ sudo cp -v /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
    $ sudo cp -v /usr/share/syslinux/menu.c32 /var/lib/tftpboot/
    $ sudo cp -v /usr/share/syslinux/mboot.c32 /var/lib/tftpboot/
    $ sudo cp -v /usr/share/syslinux/chain.c32 /var/lib/tftpboot/

- Crear los directorios necesarios para FTP y TFTP:

.. code-block:: bash

    $ sudo mkdir /var/lib/tftpboot/pxelinux.cfg
    $ sudo mkdir -p /var/lib/tftpboot/networkboot/centos7
    $ sudo mkdir /var/ftp/pub/centos7

- Descargar el ISO de CentOS 7 'Minimal ISO' usando ``wget`` con un mirror habilitado:

.. code-block:: bash

    $ wget http://mirror.unimagdalena.edu.co/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-Minimal-1908.iso

- Montar el ISO de CentOS 7:

.. code-block:: bash

    $ sudo mount -o loop CentOS-7-x86_64-Minimal-1908.iso /mnt/

- Copiar el contenido del ISO montado de CentOS al directorio que hemos creado:

.. code-block:: bash

    $ sudo cp -rf /mnt/* /var/ftp/pub/centos7

- Copiar el archivo de init RAM disk (``initrd``) y el archivo de kernel ``vmlinuz`` de CentOS al directorio de TFTP ``/var/lib/tftpboot/networkboot/centos7/``:

.. code-block:: bash

    $ sudo cp /var/ftp/pub/centos7/images/pxeboot/initrd.img /var/lib/tftpboot/networkboot/centos7/
    $ sudo cp /var/ftp/pub/centos7/images/pxeboot/vmlinuz /var/lib/tftpboot/networkboot/centos7/

- Crear el un archivo de configuracion del menú de PXE Boot:

.. code-block:: bash

    sudo bash -c 'cat << EOF > /var/lib/tftpboot/pxelinux.cfg/default
    default menu.c32
    prompt 0
    timeout 30
    menu title PXE Boot CentOS 7
    label Instalar CentOS 7 (Minimal)
    kernel /networkboot/centos7/vmlinuz
    append initrd=/networkboot/centos7/initrd.img inst.repo=ftp://192.168.8.8/pub/centos7
    EOF'

En esta entrada del menú de PXE Boot indicamos el **kernel** (``vmlinuz``), el **init RAM disk** (``initrd.img``) y el repositorio de donde se va a descargar los paquetes, en este caso localmente. El kernel y el initrd se pasan a través de **TFTP**, mientras que los archivos de repositorio se pasan mediante **FTP**. Además se añade una etiqueta que idenfique esta entrada para instalar CentOS en el menú.

- Reiniciar los servicios de DHCP, TFTP y FTP

.. code-block:: bash

    cat << EOF > restart_pxe_services.sh
    #!/bin/bash
    sudo systemctl restart dhcpd
    sudo systemctl restart tftp
    sudo systemctl restart vsftpd
    systemctl status dhcpd tftp vsftpd
    EOF

    chmod +x restart_pxe_services.sh
    ./restart_pxe_services.sh

Configuración de firewall (OPCIONAL)
''''''''''''''''''''''''''''''''''''

Si nuestro sistema tiene activo el servicio de firewall o tiene reglas de firewalls activadas debemos configurar ciertos servicios:

- Agregar reglas al firewall de los servicios:

.. code-block:: bash

    cat << EOF > firewall_pxe_services.sh
    #!/bin/bash
    #DHCP
    sudo firewall-cmd --permanent --add-service={dhcp,proxy-dhcp}
    #TFTP
    sudo firewall-cmd --permanent --add-service=tftp
    #FTP
    sudo firewall-cmd --permanent --add-service=ftp
    sudo firewall-cmd --reload
    sudo firewall-cmd --state
    systemctl status firewalld
    EOF

    chmod +x firewall_pxe_services.sh
    ./firewall_pxe_services.sh

- Agregar una regla de ``iptables`` para que no existan problemas de conexión del cliente PXE:

.. code-block:: bash

    $ sudo iptables -I INPUT -i enp0s8 -p udp --dport 67:68 --sport 67:68 -j ACCEPT

Script de automatización - Configuración de PXE Server
------------------------------------------------------

El siguiente script automatiza (agrupa) todos los pasos desarrollados en la sección anterior:

.. code-block:: bash

    sudo yum install -y syslinux dhcp tftp-server vsftpd
    sudo yum install -y vim wget

    sudo bash -c 'cat << EOF > /etc/dhcp/dhcpd.conf
    #DHCP configuration for PXE boot server
    ddns-update-style interim;
    ignore client-updates;
    authoritative;
    allow booting;
    allow bootp;
    allow unknown-clients;
    #DHCP pool
    subnet 192.168.8.0
    netmask 255.255.255.0
    {
    range 192.168.8.100 192.168.8.199;
    option domain-name-servers 192.168.8.2;
    option domain-name "midominio.com";
    option routers 192.168.8.2;
    option broadcast-address 192.168.8.255;
    default-lease-time 600;
    max-lease-time 7200;
    #PXE boot server
    next-server 192.168.8.8;
    filename "pxelinux.0";
    }
    # Static lease, fixed IP: hostname-MAC-IP
    host vm2-pxe-client
    {
    option host-name    "vm2.host";
    hardware ethernet   00:11:22:33:44:55;
    fixed-address       192.168.8.50;
    }
    EOF'

    cat << EOF > enable_pxe_services.sh
    #!/bin/bash
    #DHCP
    systemctl start dhcpd.service && systemctl enable dhcpd.service
    #TFTP
    systemctl start tftp.service && systemctl enable tftp.service
    #FTP
    systemctl start vsftpd.service && systemctl enable vsftpd.service
    systemctl status dhcpd tftp vsftpd
    EOF

    chmod +x enable_pxe_services.sh
    sudo ./enable_pxe_services.sh

    #cat << EOF > firewall_pxe_services.sh
    ##!/bin/bash
    ##DHCP
    #sudo firewall-cmd --permanent --add-service={dhcp,proxy-dhcp}
    ##TFTP
    #sudo firewall-cmd --permanent --add-service=tftp
    ##FTP
    #sudo firewall-cmd --permanent --add-service=ftp
    #sudo firewall-cmd --reload
    #sudo firewall-cmd --state
    #systemctl status firewalld
    #EOF
    #
    #chmod +x firewall_pxe_services.sh
    #./firewall_pxe_services.sh

    sudo cp -v /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
    sudo cp -v /usr/share/syslinux/menu.c32 /var/lib/tftpboot/
    sudo cp -v /usr/share/syslinux/mboot.c32 /var/lib/tftpboot/
    sudo cp -v /usr/share/syslinux/chain.c32 /var/lib/tftpboot/

    sudo mkdir /var/lib/tftpboot/pxelinux.cfg
    sudo mkdir -p /var/lib/tftpboot/networkboot/centos7
    sudo mkdir /var/ftp/pub/centos7

    wget http://mirror.unimagdalena.edu.co/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-Minimal-1908.iso
    sudo mount -o loop CentOS-7-x86_64-Minimal-1908.iso /mnt/

    sudo cp -rf /mnt/* /var/ftp/pub/centos7

    sudo cp /var/ftp/pub/centos7/images/pxeboot/initrd.img /var/lib/tftpboot/networkboot/centos7/
    sudo cp /var/ftp/pub/centos7/images/pxeboot/vmlinuz /var/lib/tftpboot/networkboot/centos7/

    sudo bash -c 'cat << EOF > /var/lib/tftpboot/pxelinux.cfg/default
    default menu.c32
    prompt 0
    timeout 30
    menu title PXE Boot CentOS 7
    label Instalar CentOS 7 (Minimal)
    kernel /networkboot/centos7/vmlinuz
    append initrd=/networkboot/centos7/initrd.img inst.repo=ftp://192.168.8.8/pub/centos7
    EOF'

    cat << EOF > restart_pxe_services.sh
    #!/bin/bash
    sudo systemctl restart dhcpd
    sudo systemctl restart tftp
    sudo systemctl restart vsftpd
    systemctl status dhcpd tftp vsftpd
    EOF

    chmod +x restart_pxe_services.sh
    ./restart_pxe_services.sh

    # sudo iptables -I INPUT -i enp0s8 -p udp --dport 67:68 --sport 67:68 -j ACCEPT

.. _pxecentosinstaller:

Instalando CentOS 7 en un cliente PXE
-------------------------------------

Para instalar CentOS 7 en un cliente PXE de VirtualBox configuraremos lo siguiente en una VM creada:

- Un mínimo de 2048 MB de RAM
- Boot order: primero Hard Disk y luego Network

.. figure:: images/pxe-install/virtualbox_pxeclient_system_tab.png
    :align: center

    VirtualBox - PXE Client - System Tab

- Una interfaz de red conectada en la misma red por donde el PXE server ofrece sus servicios de DHCP, FTP, TFTP:

.. figure:: images/pxe-install/virtualbox_pxeclient_network_tab.png
    :align: center

    VirtualBox - PXE Client - Network Tab

El arranque del instalador de CentOS 7 usando PXE se muestra en el siguiente video:

.. raw:: html

    <div style="text-align: center; margin-bottom: 2em;">
    <iframe width="100%" height="350" src="https://www.youtube.com/embed/NVsclkjFug4?rel=0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
    </div>

Los siguientes pasos consisten en seguir el proceso del instalador de CentOS 7. Hemos logrado el objetivo de proporcionar un medio de instalación por red con el método PXE. Mediante este, múltiples clientes PXE podrán conectarse al servidor PXE, a través de la red, y obtener los medios para instalar el sistema operativo CentOS 7.

A pesar de que hemos logrado brindar el instalador de CentOS 7 por red, sería útil automatizar la instalación del sistema operativo en sí. Este objetivo lo lograremos a través de archivos Kickstart.
