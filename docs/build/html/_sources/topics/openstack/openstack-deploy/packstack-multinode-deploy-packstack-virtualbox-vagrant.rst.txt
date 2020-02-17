Despliegue de OpenStack Multinode con Packstack, VirtualBox y Vagrant
---------------------------------------------------------------------

.. contents:: Table of Contents

Prerequisitos del sistema
'''''''''''''''''''''''''

Desde nuestro sistema Operativo (Windows, macOS, Linux) debemos tener instaladas los siguientes programas:

- VirtualBox
- Vagrant

Este escenario de OpenStack que será desplegado consta de 3 VMs: un controller node y dos compute nodes. Se requiere al menos 12 GB de RAM y 4 CPUs

Configuración de VirtualBox
'''''''''''''''''''''''''''

Host-only Network Adapter
"""""""""""""""""""""""""

1. Crear un Host-only Network Adapter haciendo clic en el botón :guilabel:`Global Tools`, :guilabel:`Host Network Manager`. Clic en el botón :guilabel:`Create`:

.. figure:: images/packstack-multinode-deploy-packstack-virtualbox-vagrant/Windows-VirtualBox-HostNetworkManager-Create-Adapter-1.png
    :align: center

    Windows - VirtualBox v5.2 - Crear un nuevo adaptador

.. figure:: images/packstack-multinode-deploy-packstack-virtualbox-vagrant/Linux-VirtualBox-HostNetworkManager-Create-Adapter-1.png
    :align: center

    Linux - VirtualBox v6.0 - Crear un nuevo adaptador

2. Se creará un adaptador con un nombre predefinido al cual podremos editar la dirección IPv4 respectiva. En este caso no será necesario activar la opción de DHCP:

.. figure:: images/packstack-multinode-deploy-packstack-virtualbox-vagrant/Windows-VirtualBox-HostNetworkManager-Create-Adapter-2.png
    :align: center

    Windows - VirtualBox v5.2 - Configuración del adaptador

.. figure:: images/packstack-multinode-deploy-packstack-virtualbox-vagrant/Linux-VirtualBox-HostNetworkManager-Create-Adapter-2.png
    :align: center

    Linux - VirtualBox v6.0 - Configuración del adaptador

.. Note::

    Sobre el adaptador de red creado:

    - El adaptador pertenece a la red de management
    - La dirección IP del adaptador es el Host-side de la red

NAT Provider Network
""""""""""""""""""""

1. Clic en :guilabel:`Preferences` (:guilabel:`Ctrl + G`):

.. figure:: images/packstack-multinode-deploy-packstack-virtualbox-vagrant/Windows-VirtualBox-Preferences.png
    :align: center

    Windows - VirtualBox v5.2 - Clic en opción :guilabel:`Preferences`

.. figure:: images/packstack-multinode-deploy-packstack-virtualbox-vagrant/Linux-VirtualBox-Preferences.png
    :align: center

    Linux - VirtualBox v6.0 - Clic en opción :guilabel:`Preferences`

2. En la sección :guilabel:`Network`, seleccionar el botón de creación de una nueva red:

.. figure:: images/packstack-multinode-deploy-packstack-virtualbox-vagrant/Windows-VirtualBox-Preferences-Network.png
    :align: center

    Windows - VirtualBox v5.2 - Clic en sección :guilabel:`Network`

.. figure:: images/packstack-multinode-deploy-packstack-virtualbox-vagrant/Linux-VirtualBox-Preferences-Network.png
    :align: center

    Linux - VirtualBox v6.0 - Clic en sección :guilabel:`Network`

3. Nombrar y definir un rango para la red NAT. También podemos dar soporte DHCP:

.. figure:: images/packstack-multinode-deploy-packstack-virtualbox-vagrant/Windows-VirtualBox-Create-Provider-Network.png
    :align: center

    Windows - VirtualBox v5.2 - Definir propiedades de la red

.. figure:: images/packstack-multinode-deploy-packstack-virtualbox-vagrant/Linux-VirtualBox-Create-Provider-Network.png
    :align: center

    Linux - VirtualBox v6.0 - Definir propiedades de la red

Definición del archivo ``Vagrantfile``
''''''''''''''''''''''''''''''''''''''

El archivo ``Vagrantfile`` se define de la siguiente forma:

.. code-block:: bash

    # -*- mode: ruby -*-
    # vi: set ft=ruby :
    servers=[
    {
        :hostname => "compute1",
        :box => "geerlingguy/centos7",
        :ram => 2048,
        :cpu => 1,
        :script => "sh /vagrant/compute1_setup.sh"
    },
    {
        :hostname => "compute2",
        :box => "geerlingguy/centos7",
        :ram => 2048,
        :cpu => 1,
        :script => "sh /vagrant/compute2_setup.sh"
    },
    {
        :hostname => "packstack",
        :box => "geerlingguy/centos7",
        :ram => 8192,
        :cpu => 2,
        :script => "sh /vagrant/packstack_setup.sh"
    }
    ]
    # All Vagrant configuration is done below. The "2" in Vagrant.configure
    # configures the configuration version (we support older styles for
    # backwards compatibility). Please don't change it unless you know what
    # you're doing.
    Vagrant.configure("2") do |config|
    servers.each do |machine|
        config.vm.define machine[:hostname] do |node|
        node.vm.box = machine[:box]
        node.vm.hostname = machine[:hostname]
        node.vm.provider "virtualbox" do |vb|
            vb.customize ["modifyvm", :id, "--memory", machine[:ram], "--cpus", machine[:cpu]]
            vb.customize ["modifyvm", :id, "--nic2", "hostonly", "--hostonlyadapter2", "VirtualBox Host-Only Ethernet Adapter #2"]
        end
        node.vm.provision "shell", inline: machine[:script], privileged: true, run: "once"
        end
    end
    end


Definición de archivos de configuración de nodos
''''''''''''''''''''''''''''''''''''''''''''''''

En el mismo directorio donde tenemos almacenado el archivo ``Vagrantfile`` guardaremos los scrips ``.sh`` que se correrán cuando Vagrant lance las VMs en su respectivo nodo:

Controller (``packstack_setup.sh``)
"""""""""""""""""""""""""""""""""""

.. code-block:: bash

    #! /bin/sh

    export LANG=en_US.utf-8
    export LC_ALL=en_US.utf-8

    sed -i -e 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/fastestmirror.conf

    cat <<- EOF > /etc/sysconfig/network-scripts/ifcfg-enp0s8
    DEVICE="enp0s8"
    DEFROUTE="no"
    BOOTPROTO="static"
    IPADDR="10.0.0.20"
    NETMASK="255.255.255.0"
    DNS1="8.8.8.8"
    TYPE="Ethernet"
    ONBOOT=yes
    EOF

    ifdown enp0s8
    ifup enp0s8

    cat <<- EOF > /etc/hosts
    127.0.0.1 localhost
    10.0.0.20 packstack
    10.0.0.21 compute1
    10.0.0.22 compute2
    EOF

    echo 'centos' >/etc/yum/vars/contentdir

    systemctl disable firewalld
    systemctl stop firewalld
    systemctl disable NetworkManager
    systemctl stop NetworkManager
    systemctl enable network
    systemctl start network

    yum install -y centos-release-openstack-queens
    yum update -y
    yum install -y openstack-packstack

    cat <<- EOF > /home/vagrant/run-packstack.sh
    export LANG=en_US.utf-8
    export LC_ALL=en_US.utf-8
    echo "Running 'ssh vagrant@compute1'"
    echo "The password is 'vagrant'"
    ssh vagrant@compute1 echo "OK"
    echo "Running 'ssh vagrant@compute2'"
    echo "The password is 'vagrant'"
    ssh vagrant@compute2 echo "OK"
    echo "Running packstack with options"
    echo "The 'root' password is 'vagrant'"
    packstack --install-hosts="10.0.0.20","10.0.0.21","10.0.0.22" --os-heat-install=y --os-heat-cfn-install=y --os-neutron-lbaas-install=y --keystone-admin-passwd="openstack" --keystone-demo-passwd="openstack"
    EOF

    chown vagrant:vagrant /home/vagrant/run-packstack.sh

Compute 1 (``compute1_setup.sh``)
"""""""""""""""""""""""""""""""""

.. code-block:: bash

    #! /bin/sh

    export LANG=en_US.utf-8
    export LC_ALL=en_US.utf-8

    sed -i -e 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/fastestmirror.conf
    echo 'centos' >/etc/yum/vars/contentdir

    cat <<- EOF > /etc/sysconfig/network-scripts/ifcfg-enp0s8
    DEVICE="enp0s8"
    DEFROUTE="no"
    BOOTPROTO="static"
    IPADDR="10.0.0.21"
    NETMASK="255.255.255.0"
    DNS1="8.8.8.8"
    TYPE="Ethernet"
    ONBOOT=yes
    EOF

    ifdown enp0s8
    ifup enp0s8

    cat <<- EOF > /etc/hosts
    127.0.0.1 localhost
    10.0.0.20 packstack
    10.0.0.21 compute1
    10.0.0.22 compute2
    EOF

    systemctl disable firewalld
    systemctl stop firewalld
    systemctl disable NetworkManager
    systemctl stop NetworkManager
    systemctl enable network
    systemctl start network

Compute 2 (``compute2_setup.sh``)
"""""""""""""""""""""""""""""""""

.. code-block:: bash

    #! /bin/sh

    export LANG=en_US.utf-8
    export LC_ALL=en_US.utf-8

    sed -i -e 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/fastestmirror.conf
    echo 'centos' >/etc/yum/vars/contentdir

    cat <<- EOF > /etc/sysconfig/network-scripts/ifcfg-enp0s8
    DEVICE="enp0s8"
    DEFROUTE="no"
    BOOTPROTO="static"
    IPADDR="10.0.0.22"
    NETMASK="255.255.255.0"
    DNS1="8.8.8.8"
    TYPE="Ethernet"
    ONBOOT=yes
    EOF

    ifdown enp0s8
    ifup enp0s8

    cat <<- EOF > /etc/hosts
    127.0.0.1 localhost
    10.0.0.20 packstack
    10.0.0.21 compute1
    10.0.0.22 compute2
    EOF

    systemctl disable firewalld
    systemctl stop firewalld
    systemctl disable NetworkManager
    systemctl stop NetworkManager
    systemctl enable network
    systemctl start network

Correr el entorno Vagrant de máquinas virtuales
'''''''''''''''''''''''''''''''''''''''''''''''

En el terminal, cambiar de directorio al lugar donde tenemos almacenado el archivo ``Vagrantfile`` y los scripts ``.sh`` de los nodos. Luego, desplegar las máquinas virtuales con ``vagrant up``:

.. code-block:: bash

    $ cd multinode-packstack-vagrant

    $ vagrant up

Comenzará la configuración y despliegue de máquinas virtuales en VirtualBox conforme se ha especificado en el archivo ``Vagrantfile``, luego se correrán automáticamente los scripts ``.sh`` que se ha definido para cada VM:

.. figure:: images/packstack-multinode-deploy-packstack-virtualbox-vagrant/vagrant-deploy-virtualbox-vms.png
    :align: center

    VirtualBox - VMs desplegadas por Vagrant

Instalación de OpenStack con Packstack
''''''''''''''''''''''''''''''''''''''

Ubicándonos el mismo directorio donde tenemos el archivo ``Vagrantfile`` entraremos al terminal de la VM ``packstack`` con el siguiente comando:

.. code-block:: bash

    $ vagrant ssh packstack

Dentro del terminal de esta VM correremos el archivo ``run-packstack.sh`` que se encuentra en el directorio ``/home/vagrant/`` y fue definido el el script ``packstack_setup.sh``:

.. code-block:: bash

    $ . run-packstack.sh

Este script corre comandos de prueba ``ssh`` a las VMs de los compute nodes para compartir las llaves SSH (imprime el mensaje OK en cada VM) y luego corre el comando packstack con opciones para la instalación de OpenStack. Nos pedirá ingresar la contraseña del usuario root de las VMs de los compute nodes.

Pruebas en el entorno OpenStack desplegado
''''''''''''''''''''''''''''''''''''''''''

Luego de media hora aproximadamente, la instalación de OpenStack con Packstack habrá finalizado y podremos ingresar al Dashboard o al CLI de OpenStack:

.. Note::

    El Dashboard de OpenStack podría demorar un corto tiempo para arrancar la primera vez luego de haber instalado OpenStack.

Ahora realizaremos una prueba de despliegue desde el CLI:

.. Important::

    La imagen de CirrOS que se crea por defecto como ``demo`` al instalar Packstack tiene fallos pues tiene un tamaño reducido de 273 bytes. La causa de esto es que puede ser que se haya descargado sin la opción ``-L`` del comando ``curl``. Por lo tanto, crearemos nuestra propia imagen CirrOS:

La topología que se desea lograr es la siguiente:

.. figure:: images/packstack-multinode-deploy-packstack-virtualbox-vagrant/openstack-sample-topology.png
    :align: center

    OpenStack - Topología desplegada

Y los comandos que ejecutaremos en el nodo controller serán los siguientes:

.. code-block:: bash

    '#' source keystonerc_admin

    '#' cd /root

    '#' mkdir images
    '#' curl -o /root/images/cirros-0.4.0-x86_64-disk.img -L http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img
    '#' openstack image create --min-disk 1 --min-ram 128 --public --disk-format qcow2 --file /root/images/cirros-0.4.0-x86_64-disk.img cirros1

    '#' source keystonerc_demo

    '#' openstack network list

    +--------------------------------------+---------+--------------------------------------+
    | ID                                   | Name    | Subnets                              |
    +--------------------------------------+---------+--------------------------------------+
    | 0b01c7b4-27fd-4f5a-bfb9-c40726d6a66b | private | e4562283-1c3f-4ddd-86b0-52b9cd0b5d81 |
    | 7687d634-7b43-4877-9113-e68e068640fc | public  | c34775f8-b9ba-4a94-ad87-b57d7859ef4a |
    +--------------------------------------+---------+--------------------------------------+

    '#' openstack server create --image cirros1 --flavor 1 --min 2 --max 2 --nic net-id=0b01c 7b4-27fd-4f5a-bfb9-c40726d6a66b test

En este despliegue de prueba se han creado dos instancias al mismo tiempo y con las mismas características de forma que usen todos los recursos de un hypervisor al crear una instancia y para crear otra instancia se requiera usar el hypervisor del otro compute node. Logrando tener una instancia en cada compute node (o equivalentemente, cada instancia administrada por un hypervisor distinto).

.. figure:: images/packstack-multinode-deploy-packstack-virtualbox-vagrant/openstack-hypervisors-compute-nodes.png
    :align: center

    OpenStack - Uso de Hypervisors (Compute 1 y Compute 2)

.. figure:: images/packstack-multinode-deploy-packstack-virtualbox-vagrant/openstack-multinode-test-instances.png
    :align: center

    OpenStack - Instancias desplegadas

Podremos ingresar a la consola de cada instancia desde el dashboard y probar conectividad entre ellas:

.. figure:: images/packstack-multinode-deploy-packstack-virtualbox-vagrant/openstack-test-instance-test-1.png
    :align: center

    OpenStack - Consola ``test-1``

.. figure:: images/packstack-multinode-deploy-packstack-virtualbox-vagrant/openstack-test-instance-test-2.png
    :align: center

    OpenStack - Consola ``test-2``
