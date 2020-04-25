OpenStack Train - Manual Install - CentOS7 - VirtualBox
=======================================================

.. contents:: Table of Contents

**Resumen**: El siguiente procedimiento consiste en la instalación de OpenStack versión Train en máquinas virtuales de VirtualBox con sistema operativo CentOS 7. Para la automatización del despliegue de máquinas virtuales usamos la herramienta Vagrant. El resto del proceso, que consiste en la instalación de herramientas y servicios de OpenStack, se hará manualmente.

**Topología**: La topología consta de 3 nodos: 1 nodo controller, 1 nodo compute y 1 nodo block.

Scripts y pasos para el despliegue
----------------------------------

Los siguientes scripts contienen los  pasos y comandos usados a lo largo de esta guía:

- Vagrantfile: :download:`Descargar Vagrantfile <extra/Vagrantfile>`
- Script de controller: :download:`Descargar controller_setup.sh <extra/controller_setup.sh>`
- Script de compute1: :download:`Descargar compute1_setup.sh <extra/compute1_setup.sh>`
- Script de block1: :download:`Descargar block1_setup.sh <extra/block1_setup.sh>`
- Archivo de pasos para desplegar el entorno: :download:`Descargar environment-install.sh <extra/environment-install.sh>`
- Archivo de pasos para instalar servicios de OpenStack: :download:`Descargar openstack-train-centos-services-install.sh <extra/openstack-train-centos-services-install.sh>`

Definición del archivo ``Vagrantfile``
--------------------------------------

.. code-block:: bash

    # -*- mode: ruby -*-
    # vi: set ft=ruby :
    servers=[
    {
        :hostname => "controller",
        :box => "geerlingguy/centos7",
        :ram => 6144,
        :cpu => 2,
        :script => "sh /vagrant/controller_setup.sh"
    },
    {
        :hostname => "compute1",
        :box => "geerlingguy/centos7",
        :ram => 3072,
        :cpu => 1,
        :script => "sh /vagrant/compute1_setup.sh"
    },
    {
        :hostname => "block1",
        :box => "geerlingguy/centos7",
        :ram => 3072,
        :cpu => 1,
        :script => "sh /vagrant/block1_setup.sh"
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
            vb.customize ["modifyvm", :id, "--nic3", "natnetwork", "--nat-network3", "ProviderNetwork1", "--nicpromisc3", "allow-all"]
            vb.customize ['modifyvm', :id, '--nic4', "bridged", '--bridgeadapter4', "Realtek PCIe GBE Family Controller"]
            #vb.customize ["modifyvm", :id, "--nic4", "natnetwork", "--nat-network4", "NatNetwork1"]
        end
        node.vm.provision "shell", inline: machine[:script], privileged: true, run: "once"
        end
    end
    end

Definición de scripts de configuración de nodos
-----------------------------------------------

Script de ``controller``
''''''''''''''''''''''''

.. code-block:: bash

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


Script de ``compute1``
''''''''''''''''''''''

.. code-block:: bash

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

Script de ``block1``
''''''''''''''''''''

.. code-block:: bash

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
    IPADDR="10.1.1.41"
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
    IPADDR="192.168.1.141"
    NETMASK="255.255.255.0"
    EOF

    # Reinicio de interfaz de red (Bridged adapter)
    ifdown eth3
    ifup eth3

    # Reiniciar el sistema
    reboot

Instalación y configuración de herramientas de entorno
------------------------------------------------------

Verificación previa
'''''''''''''''''''

Verificar que el servicio de firewall esté desactivado:
    
.. code-block:: bash

    # Verificar que el servicio de firewall esté desactivado
    systemctl status firewalld
    sudo firewall-cmd --state

- https://docs.openstack.org/install-guide/environment-networking-controller.html
- https://docs.openstack.org/install-guide/environment-networking-compute.html
- https://docs.openstack.org/install-guide/environment-networking-storage-cinder.html

Network Time Protocol (NTP)
'''''''''''''''''''''''''''

- https://docs.openstack.org/install-guide/environment-ntp.html

.. admonition:: Nodo(s)

    CONTROLLER

- https://docs.openstack.org/install-guide/environment-ntp-controller.html

.. code-block:: bash

    # Instalar el programa chrony:
    sudo -i
    yum install -y chrony

    # Editar el archivo de configuración de chrony:
    cat << EOF >> /etc/chrony.conf
    allow 10.1.1.0/24
    EOF

    # Reiniciar el servicio de NTP:
    systemctl restart chronyd.service

.. admonition:: Nodo(s)

    COMPUTE, BLOCK
    
- https://docs.openstack.org/install-guide/environment-ntp-other.html

.. code-block:: bash

    # Instalar el programa chrony:
    sudo -i
    yum install -y chrony

    # Configurar el nodo controller como servidor NTP:
    cat << EOF >> /etc/chrony.conf
    server controller iburst
    EOF

    # Comentar las líneas con los otros servidores NTP:
    sed -i 's/server 0.centos.pool.ntp.org iburst/#server 0.centos.pool.ntp.org iburst/g' /etc/chrony.conf
    sed -i 's/server 1.centos.pool.ntp.org iburst/#server 1.centos.pool.ntp.org iburst/g' /etc/chrony.conf
    sed -i 's/server 2.centos.pool.ntp.org iburst/#server 2.centos.pool.ntp.org iburst/g' /etc/chrony.conf
    sed -i 's/server 3.centos.pool.ntp.org iburst/#server 3.centos.pool.ntp.org iburst/g' /etc/chrony.conf

    # Reiniciar el servicio de NTP:
    systemctl restart chronyd.service

.. admonition:: Nodo(s)

    ALL

- https://docs.openstack.org/install-guide/environment-ntp-verify.html

.. code-block:: bash

    # Verificar que el nodo controller se sincronice con servidores externos y los demás nodos se sincronicen con el controller:
    chronyc sources

Environment packages
''''''''''''''''''''

- https://docs.openstack.org/install-guide/environment-packages-rdo.html

.. admonition:: Nodo(s)

    ALL

.. code-block:: bash

    # Verificar la versión de kernel actual
    uname -mrs
    # Verificar los kernels instalados en el sistema (el kernel subrayado es el que está en uso)
    yum list installed kernel

    # Habilitar el repositorio de OpenStack Train
    yum install -y centos-release-openstack-train

    # Actualizar los paquetes
    yum update -y

    # Verificar si se ha descargado un kernel más nuevo:
    yum list installed kernel

    # Upgrade de los paquetes:
    yum upgrade -y

    # Reiniciar el sistema en caso se haya descargado un nuevo kernel:
    reboot

    # Verificar que estamos usando el nuevo kernel descargado:
    sudo -i
    uname -mrs

    # Instalar el cliente de OpenStack (No existe python3-openstackclient en yum)
    yum install -y python-openstackclient

    # Instalar el paquete para SELinux
    yum install -y openstack-selinux

    # Instalar otros paquetes adicionales
    yum install -y crudini vim curl

SQL Database
''''''''''''

- https://docs.openstack.org/install-guide/environment-sql-database-rdo.html

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Instalar la base de datos SQL, en nuestro caso ``mariadb``:
    yum install -y mariadb mariadb-server python2-PyMySQL

    # Crear y editar el archivo de configuración de MariaDB:
    cat << EOF > /etc/my.cnf.d/openstack.cnf
    [mysqld]
    bind-address = 10.1.1.11

    default-storage-engine = innodb
    innodb_file_per_table = on
    max_connections = 4096
    collation-server = utf8_general_ci
    character-set-server = utf8
    EOF

    # Habilitar e iniciar el servicio de base de datos:
    systemctl enable mariadb.service
    systemctl start mariadb.service

    # Asegurar el servicios de base de datos:
    mysql_secure_installation

    # Enter current password for root (enter for none):
    # Set root password? [Y/n]
    # New password: openstack
    # Re-enter new password: openstack
    # Remove anonymous users? [Y/n]
    # Disallow root login remotely? [Y/n] n
    # Remove test database and access to it? [Y/n]
    # Reload privilege tables now? [Y/n]

Message Queue - RabitMQ
'''''''''''''''''''''''

- https://docs.openstack.org/install-guide/environment-messaging-rdo.html

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Instalar el paquete de RabbitMQ:
    yum -y install rabbitmq-server

    # Habilitar e iniciar el servicio de cola de mensajería:
    systemctl enable rabbitmq-server.service
    systemctl start rabbitmq-server.service

    # Añadir el usuario a RabbitMQ (rabbitmqctl add_user openstack RABBIT_PASS):
    rabbitmqctl add_user openstack openstack

    # Configurar los permisos para el usuario openstack:
    rabbitmqctl set_permissions openstack ".*" ".*" ".*"

Memcached
'''''''''

- https://docs.openstack.org/install-guide/environment-memcached-rdo.html

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Instalar el paquete de Memcached:
    yum install -y memcached python-memcached

    # Cambiar '-l 127.0.0.1' por '-l 10.1.1.11' en el archivo /etc/sysconfig/memcached
    sed -i 's/-l 127.0.0.1/-l 10.1.1.11/g' /etc/sysconfig/memcached

    # Habilitar e iniciar el servicio Memcached
    systemctl enable memcached.service
    systemctl start memcached.service

Etcd
''''

- https://docs.openstack.org/install-guide/environment-etcd-rdo.html

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Instalar el paquete de etcd:
    yum install -y etcd

    # Editar el archivo /etc/etcd/etcd.conf
    cat << EOF >> /etc/etcd/etcd.conf
    #[Member]
    ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
    ETCD_LISTEN_PEER_URLS="http://10.1.1.11:2380"
    ETCD_LISTEN_CLIENT_URLS="http://10.1.1.11:2379"
    ETCD_NAME="controller"
    #[Clustering]
    ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.1.1.11:2380"
    ETCD_ADVERTISE_CLIENT_URLS="http://10.1.1.11:2379"
    ETCD_INITIAL_CLUSTER="controller=http://10.1.1.11:2380"
    ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"
    ETCD_INITIAL_CLUSTER_STATE="new"
    EOF

    # Habilitar e iniciar el servicio etcd
    systemctl enable etcd
    systemctl start etcd

Instalación de servicios de OpenStack
-------------------------------------

Install and Configure Keystone
''''''''''''''''''''''''''''''

- https://docs.openstack.org/keystone/train/install/keystone-install-rdo.html

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Conectarnos al servidor de base de datos como usuario root:
    mysql -u root --password=openstack

    # Crear la base de datos de keystone:
    CREATE DATABASE keystone;
    # Brindar el acceso apropiado a la base de datos de keystone:
    GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'openstack';
    GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'openstack';
    EXIT;

    # Instalar los paquetes de Keystone (además de crudini para la configuración de archivos):
    yum install -y openstack-keystone httpd mod_wsgi crudini

    # Editar el archivo /etc/keystone/keystone.conf:
    crudini --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:openstack@controller/keystone
    # Comentar cualquier otra opción en la sección [database]

    # Configurar el proveedor de token Fernet:
    crudini --set /etc/keystone/keystone.conf token provider fernet

    # Poblar la base de datos del Identity service:
    su -s /bin/sh -c "keystone-manage db_sync" keystone

    # Poblar los repositorios de Fernet:
    keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
    keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

    # Bootstrap del Identity service:
    keystone-manage bootstrap --bootstrap-password openstack --bootstrap-admin-url http://controller:5000/v3/ --bootstrap-internal-url http://controller:5000/v3/ --bootstrap-public-url http://controller:5000/v3/ --bootstrap-region-id RegionOne

    # Configurr el servidor Apache HTTP:
    cat << EOF >> /etc/httpd/conf/httpd.conf
    ServerName controller
    EOF
    # Verificar que no exista otra entrada ServerName en el documento

    # Crear un link simbólico al archivo /usr/share/keystone/wsgi-keystone.conf:
    ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/

    # Habilitar e iniciar el servicio http
    systemctl enable httpd.service
    systemctl start httpd.service

Create OpenStack Client Environment Scripts
'''''''''''''''''''''''''''''''''''''''''''
- https://docs.openstack.org/keystone/train/install/keystone-install-rdo.html#finalize-the-installation
- https://docs.openstack.org/keystone/train/install/keystone-openrc-rdo.html

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Crear el archivo admin-openrc en el directorio home del usuario
    su -s /bin/sh -c 'cat << EOF > /home/vagrant/admin-openrc
    export OS_USERNAME=admin
    export OS_PASSWORD=openstack
    export OS_PROJECT_NAME=admin
    export OS_USER_DOMAIN_NAME=Default
    export OS_PROJECT_DOMAIN_NAME=Default
    export OS_AUTH_URL=http://controller:5000/v3
    export OS_IDENTITY_API_VERSION=3
    export OS_IMAGE_API_VERSION=2
    EOF' vagrant

    # Crear el archivo demo-openrc en el directorio home del usuario
    su -s /bin/sh -c 'cat << EOF > /home/vagrant/demo-openrc
    export OS_USERNAME=demo
    export OS_PASSWORD=openstack
    export OS_PROJECT_NAME=demo
    export OS_USER_DOMAIN_NAME=Default
    export OS_PROJECT_DOMAIN_NAME=Default
    export OS_AUTH_URL=http://controller:5000/v3
    export OS_IDENTITY_API_VERSION=3
    export OS_IMAGE_API_VERSION=2
    EOF' vagrant

    # Verificar la operación de Keystone:
    . /home/vagrant/admin-openrc
    openstack token issue

Create Projects, Users and Roles
''''''''''''''''''''''''''''''''

- https://docs.openstack.org/keystone/train/install/keystone-users-rdo.html
- https://docs.openstack.org/keystone/train/install/keystone-verify-rdo.html

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Crear un nuevo dominio (por defecto existe el dominio default del paso keystone-manage bootstrap):
    openstack domain create --description "An Example Domain" example

    # Crear un proyecto service:
    openstack project create --domain default --description "Service Project" service

    # Crear un proyecto sin privilegios para tareas no administrativas:
    openstack project create --domain default --description "Demo Project" demo

    # Crear un usuario sin privilegios para tareas no administrativas:
    openstack user create --domain default --password openstack demo

    # Crear un rol usuario
    openstack role create user

    # Asignar el rol user al usuario demo del proyecto demo:
    openstack role add --project demo --user demo user

    # Listar usuarios:
    openstack user list

    # Verificar la funcionalidad del usuario demo:
    . /home/vagrant/demo-openrc
    openstack token issue

Install & Configure Glance
''''''''''''''''''''''''''

- https://docs.openstack.org/glance/train/install/install-rdo.html

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Conectarnos al servidor de base de datos como usuario root:
    mysql -u root --password=openstack

    # Crear la base de datos de glance:
    CREATE DATABASE glance;

    # Brindar el acceso apropiado a la base de datos de glance:
    GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'openstack';
    GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'openstack';
    EXIT;

    # Crear un usuario glance:
    . /home/vagrant/admin-openrc
    openstack user create --domain default --password openstack glance

    # Añadir el rol admin al usuario glance:
    openstack role add --project service --user glance admin

    # Crear el servicio glance:
    openstack service create --name glance --description "OpenStack Image" image

    # Crear los Glance Service Endpoints (public, internal, admin):
    openstack endpoint create --region RegionOne image public http://controller:9292
    openstack endpoint create --region RegionOne image internal http://controller:9292
    openstack endpoint create --region RegionOne image admin http://controller:9292

    # Instalar el paquete de glance:
    yum update -y
    yum install -y openstack-glance

    # Configure database access for glance
    crudini --set /etc/glance/glance-api.conf database connection mysql+pymysql://glance:openstack@controller/glance

    # Configurar el acceso a Identity Service:
    crudini --set /etc/glance/glance-api.conf keystone_authtoken www_authenticate_uri http://controller:5000
    crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_url http://controller:5000
    crudini --set /etc/glance/glance-api.conf keystone_authtoken memcached_servers controller:11211
    crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_type password
    crudini --set /etc/glance/glance-api.conf keystone_authtoken project_domain_name default
    crudini --set /etc/glance/glance-api.conf keystone_authtoken user_domain_name default
    crudini --set /etc/glance/glance-api.conf keystone_authtoken project_name service
    crudini --set /etc/glance/glance-api.conf keystone_authtoken username glance
    crudini --set /etc/glance/glance-api.conf keystone_authtoken password openstack
    crudini --set /etc/glance/glance-api.conf paste_deploy flavor keystone

    # Configure Glance to store Images on Local Filesystem
    crudini --set /etc/glance/glance-api.conf glance_store stores "file,http"
    crudini --set /etc/glance/glance-api.conf glance_store default_store file
    crudini --set /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/

    # Poblar la base de datos de Image Service:
    su -s /bin/sh -c "glance-manage db_sync" glance

    # Habilitar e iniciar el servicio de glance
    systemctl enable openstack-glance-api.service
    systemctl start openstack-glance-api.service

    # Glance Registry Service and its APIs have been DEPRECATED in the Queens release

Download & Create Test Images
'''''''''''''''''''''''''''''

- https://docs.openstack.org/glance/train/install/verify.html

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Descargar la imagen de CirrOS:
    wget http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img

    # Crear una nueva imagen:
    . /home/vagrant/admin-openrc
    openstack image create cirros4.0 --file cirros-0.4.0-x86_64-disk.img --disk-format qcow2 --container-format bare --public

    # Listar nuestras imágenes:
    openstack image list

Placement service - Install and configure Placement
'''''''''''''''''''''''''''''''''''''''''''''''''''

- https://docs.openstack.org/placement/train/install/install-rdo.html

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Conectarnos al servidor de base de datos como usuario root:
    mysql -u root --password=openstack

    # Crear la base de datos de placement:
    CREATE DATABASE placement;

    # Brindar el acceso apropiado a la base de datos de placement:
    GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY 'openstack';
    GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY 'openstack';
    EXIT;

    # Crear un usuario placement y añadir el rol admin al usuario placement:
    . /home/vagrant/admin-openrc
    openstack user create --domain default --password openstack placement
    openstack role add --project service --user placement admin

    # Crear la entrada de Placement API en el catálogo de servicios:
    openstack service create --name placement --description "Placement API" placement

    # Crear los Placement API service endpoints:
    openstack endpoint create --region RegionOne placement public http://controller:8778
    openstack endpoint create --region RegionOne placement internal http://controller:8778
    openstack endpoint create --region RegionOne placement admin http://controller:8778
    # NOTE: Depending on your environment, the URL for the endpoint will vary by port (possibly 8780 instead of 8778, or no port at all) and hostname. You are responsible for determining the correct URL.

    # Instalar paquetes:
    yum install -y openstack-placement-api python-pip

    # Editar el archivo /etc/placement/placement.conf:
    crudini --set /etc/placement/placement.conf placement_database connection mysql+pymysql://placement:openstack@controller/placement

    crudini --set /etc/placement/placement.conf api auth_strategy keystone

    crudini --set /etc/placement/placement.conf keystone_authtoken auth_url http://controller:5000/v3
    crudini --set /etc/placement/placement.conf keystone_authtoken memcached_servers controller:11211
    crudini --set /etc/placement/placement.conf keystone_authtoken auth_type password
    crudini --set /etc/placement/placement.conf keystone_authtoken project_domain_name Default
    crudini --set /etc/placement/placement.conf keystone_authtoken user_domain_name Default
    crudini --set /etc/placement/placement.conf keystone_authtoken project_name service
    crudini --set /etc/placement/placement.conf keystone_authtoken username placement
    crudini --set /etc/placement/placement.conf keystone_authtoken password openstack
    # Comentar cualquier otro parámetro en la sección [keystone_authtoken]

    # Poblar la base de datos placement:
    su -s /bin/sh -c "placement-manage db sync" placement
    # El comando anterior no retorna ningún outut

    # Reiniciar el servicio httpd:
    systemctl restart httpd memcached

    # Ver errores del log de Placement:
    tail -f /var/log/placement/placement-api.log | grep -i error &

Placement service - Verify Installation
'''''''''''''''''''''''''''''''''''''''

- https://docs.openstack.org/placement/train/install/verify.html

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Realizar revisión de estados para ver que todo esté en orden:
    . /home/vagrant/admin-openrc
    placement-status upgrade check

    # Correr algunos comandos sobre el placement API:
    pip install osc-placement
    openstack --os-placement-api-version 1.2 resource class list --sort-column name
    openstack --os-placement-api-version 1.6 trait list --sort-column name

Nova service - Install and configure controller node
''''''''''''''''''''''''''''''''''''''''''''''''''''

- https://docs.openstack.org/nova/train/install/controller-install-rdo.html

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Conectarnos al servidor de base de datos como usuario root:
    mysql -u root --password=openstack

    # Crear las bases de datos:
    CREATE DATABASE nova_api;
    CREATE DATABASE nova;
    CREATE DATABASE nova_cell0;

    # Brindar el acceso apropiado a la base de datos de Nova:
    GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'openstack';
    GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'openstack';
    GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'openstack';
    GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'openstack';
    GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY 'openstack';
    GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY 'openstack';
    EXIT;

    # Crear un usuario nova y añadir el rol admin al usuario:
    . /home/vagrant/admin-openrc
    openstack user create --domain default --password openstack nova
    openstack role add --project service --user nova admin

    # Crear el servicio de Nova:
    openstack service create --name nova --description "OpenStack Compute" compute

    # Crear los Compute API Endpoints (public, internal, admin):
    openstack endpoint create --region RegionOne compute public http://controller:8774/v2.1
    openstack endpoint create --region RegionOne compute internal http://controller:8774/v2.1
    openstack endpoint create --region RegionOne compute admin http://controller:8774/v2.1

    # Instalar los paquetes de Nova Controller:
    yum install -y openstack-nova-api openstack-nova-conductor openstack-nova-novncproxy openstack-nova-scheduler

    # Editar el archivo /etc/nova/nova.conf:
    crudini --set /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata

    crudini --set /etc/nova/nova.conf api_database connection mysql+pymysql://nova:openstack@controller/nova_api
    crudini --set /etc/nova/nova.conf database connection mysql+pymysql://nova:openstack@controller/nova
    crudini --set /etc/nova/nova.conf DEFAULT transport_url rabbit://openstack:openstack@controller:5672/
    # En Stein: transport_url = rabbit://openstack:RABBIT_PASS@controller

    crudini --set /etc/nova/nova.conf api auth_strategy keystone

    crudini --set /etc/nova/nova.conf keystone_authtoken www_authenticate_uri http://controller:5000/
    # En Stein: www_authenticate_uri no está presente
    crudini --set /etc/nova/nova.conf keystone_authtoken auth_url http://controller:5000/
    # En Stein: auth_url = http://controller:5000/v3
    crudini --set /etc/nova/nova.conf keystone_authtoken memcached_servers controller:11211
    crudini --set /etc/nova/nova.conf keystone_authtoken auth_type password
    crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_name default
    crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_name default
    crudini --set /etc/nova/nova.conf keystone_authtoken project_name service
    crudini --set /etc/nova/nova.conf keystone_authtoken username nova
    crudini --set /etc/nova/nova.conf keystone_authtoken password openstack

    crudini --set /etc/nova/nova.conf DEFAULT my_ip 10.1.1.11
    crudini --set /etc/nova/nova.conf DEFAULT use_neutron true
    crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver

    crudini --set /etc/nova/nova.conf vnc enabled true
    crudini --set /etc/nova/nova.conf vnc server_listen 10.1.1.11
    crudini --set /etc/nova/nova.conf vnc server_proxyclient_address 10.1.1.11

    crudini --set /etc/nova/nova.conf glance api_servers http://controller:9292

    crudini --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp

    crudini --set /etc/nova/nova.conf placement region_name RegionOne
    crudini --set /etc/nova/nova.conf placement project_domain_name Default
    crudini --set /etc/nova/nova.conf placement project_name service
    crudini --set /etc/nova/nova.conf placement auth_type password
    crudini --set /etc/nova/nova.conf placement user_domain_name Default
    crudini --set /etc/nova/nova.conf placement auth_url http://controller:5000/v3
    crudini --set /etc/nova/nova.conf placement username placement
    crudini --set /etc/nova/nova.conf placement password openstack

    # Revisar si este parámetro se encuentra en el archivo de configuración. De ser el caso, removerlo:
    crudini --del /etc/nova/nova.conf DEFAULT log_dir

    # Poblar la base de datos nova-api:
    su -s /bin/sh -c "nova-manage api_db sync" nova

    # Register cell0 Database:
    su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova

    # Create cell1 Cell:
    su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova

    # Populate nova Database:
    su -s /bin/sh -c "nova-manage db sync" nova

    # Verificar que cell0 y cell1 han sido registradas correctamente:
    su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova

    # Habilitar e iniciar servicios de Nova:
    systemctl enable openstack-nova-api.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service
    systemctl start openstack-nova-api.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service

Nova service - Install and configure a compute node
'''''''''''''''''''''''''''''''''''''''''''''''''''

- https://docs.openstack.org/nova/train/install/compute-install-rdo.html

.. admonition:: Nodo(s)

    COMPUTE

.. code-block:: bash

    # Instalar los paquetes de Nova (además de crudini para la configuración de archivos):
    yum install -y openstack-nova-compute crudini

    # Editar el archivo /etc/nova/nova.conf:
    crudini --set /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata

    # Configurar acceso a RabbitMQ:
    crudini --set /etc/nova/nova.conf DEFAULT transport_url rabbit://openstack:openstack@controller

    # Configurar el acceso a Identity Service:
    crudini --set /etc/nova/nova.conf api auth_strategy keystone

    crudini --set /etc/nova/nova.conf keystone_authtoken www_authenticate_uri http://controller:5000/
    # En Stein: www_authenticate_uri no está presente
    crudini --set /etc/nova/nova.conf keystone_authtoken auth_url http://controller:5000/
    # En Stein: auth_url = http://controller:5000/v3
    crudini --set /etc/nova/nova.conf keystone_authtoken memcached_servers controller:11211
    crudini --set /etc/nova/nova.conf keystone_authtoken auth_type password
    crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_name default
    crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_name default
    crudini --set /etc/nova/nova.conf keystone_authtoken project_name service
    crudini --set /etc/nova/nova.conf keystone_authtoken username nova
    crudini --set /etc/nova/nova.conf keystone_authtoken password openstack
    # Comentar cualquier otro parámetro en la sección [keystone_authtoken]

    # Reemplazar IP por la del compute node que se está configurando:
    crudini --set /etc/nova/nova.conf DEFAULT my_ip 10.1.1.31
    crudini --set /etc/nova/nova.conf DEFAULT use _neutron true
    crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver

    crudini --set /etc/nova/nova.conf vnc enabled true
    crudini --set /etc/nova/nova.conf vnc server_listen 0.0.0.0
    # Reemplazar IP por la del compute node que se está configurando:
    crudini --set /etc/nova/nova.conf vnc server_proxyclient_address 10.1.1.31
    crudini --set /etc/nova/nova.conf vnc novncproxy_base_url http://10.1.1.11:6080/vnc_auto.html

    crudini --set /etc/nova/nova.conf glance api_servers http://controller:9292

    crudini --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp

    crudini --set /etc/nova/nova.conf placement region_name RegionOne
    crudini --set /etc/nova/nova.conf placement project_domain_name Default
    crudini --set /etc/nova/nova.conf placement project_name service
    crudini --set /etc/nova/nova.conf placement auth_type password
    crudini --set /etc/nova/nova.conf placement user_domain_name Default
    crudini --set /etc/nova/nova.conf placement auth_url http://controller:5000/v3
    crudini --set /etc/nova/nova.conf placement username placement
    crudini --set /etc/nova/nova.conf placement password openstack

    # Revisar si este parámetro se encuentra en el archivo de configuración. De ser el caso, removerlo:
    crudini --del /etc/nova/nova.conf DEFAULT log_dir

    # Determinar si nuestra computadora soporta aceleración de hardware para máquinas virtuales (si lo soporta el resultado será 1 o más):
    egrep -c '(vmx|svm)' /proc/cpuinfo

    # Para un setup con máquinas virtuales configurar:
    crudini --set /etc/nova/nova-compute.conf libvirt virt_type qemu

    # Habilitar e iniciar el servicio Compute:
    systemctl enable libvirtd.service openstack-nova-compute.service
    systemctl start libvirtd.service openstack-nova-compute.service
    # If the nova-compute service fails to start, check /var/log/nova/nova-compute.log. The error message AMQP server on controller:5672 is unreachable likely indicates that the firewall on the controller node is preventing access to port 5672. Configure the firewall to open port 5672 on the controller node and restart nova-compute service on the compute node.

Discover Compute Nodes and Finalize Nova Installation
'''''''''''''''''''''''''''''''''''''''''''''''''''''

- https://docs.openstack.org/nova/train/install/compute-install-rdo.html#add-the-compute-node-to-the-cell-database

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Comprobar que hay compute nodes en la base de datos:
    . /home/vagrant/admin-openrc
    openstack compute service list --service nova-compute

    # Descubrir compute hosts:
    su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova

    # Listar servicios de Compute:
    openstack compute service list

    # Ver errores del log de Nova:
    tail -f /var/log/nova/* | grep -i error &

Solución del error "Skipping removal of allocations for deleted instances: Failed to retrieve allocations for resource provider"
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Según las siguientes referencias:

- https://louky0714.tistory.com/entry/Openstack-Train-Error-Nova-Instance-fail-You-dont-have-permission-to-access-resourceproviderson-this-server
- http://www.programmersought.com/article/2585745102/
- https://blog.csdn.net/hutiewei2008/article/details/87971379
- https://ask.openstack.org/en/question/103325/ah01630-client-denied-by-server-configuration-usrbinnova-placement-api/

Seguimos el siguiente procedimiento:

1. Editar el archivo ``/etc/httpd/conf.d/00-placement-api.conf``

.. code-block:: bash

    vim /etc/httpd/conf.d/00-placement-api.conf

Añadir la siguiente sección (Probar al final del archivo o dentro de la sección ``<virtualhost *:8778="">``):

.. code-block:: text

    <Directory /usr/bin>
        <IfVersion >= 2.4>
            Require all granted
        </IfVersion>
        <IfVersion < 2.4>
            Order allow,deny
            Allow from all
        </IfVersion>
    </Directory>

2. Reiniciar servicios de Nova del controller node:

.. code-block:: bash

    systemctl restart openstack-nova-api.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service httpd

3. Reiniciar servicios de Nova del compute node:

.. code-block:: bash

    systemctl restart libvirtd.service openstack-nova-compute.service

.. Error::

    Log con el error:

    .. code-block:: text

        # ERROR:

        2020-04-23 04:41:07.504 19347 ERROR nova.compute.resource_tracker [req-1c29a29d-0f43-46c9-8255-d49f3ec1084b - - - - -] Skipping removal of allocations for deleted instances: Failed to retrieve allocations for resource provider 5a5ae2e2-063b-4311-9b24-23373417dc5b: <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
        2020-04-23 04:41:07.517 19347 ERROR nova.scheduler.client.report [req-1c29a29d-0f43-46c9-8255-d49f3ec1084b - - - - -] [None] Failed to retrieve resource provider tree from placement API for UUID 5a5ae2e2-063b-4311-9b24-23373417dc5b. Got 403: <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager [req-1c29a29d-0f43-46c9-8255-d49f3ec1084b - - - - -] Error updating resources for node compute1.: ResourceProviderRetrievalFailed: Failed to get resource provider with UUID 5a5ae2e2-063b-4311-9b24-23373417dc5b
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager Traceback (most recent call last):
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager   File "/usr/lib/python2.7/site-packages/nova/compute/manager.py", line 8673, in _update_available_resource_for_node
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager     startup=startup)
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager   File "/usr/lib/python2.7/site-packages/nova/compute/resource_tracker.py", line 887, in update_available_resource
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager     self._update_available_resource(context, resources, startup=startup)
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager   File "/usr/lib/python2.7/site-packages/oslo_concurrency/lockutils.py", line 328, in inner
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager     return f(*args, **kwargs)
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager   File "/usr/lib/python2.7/site-packages/nova/compute/resource_tracker.py", line 972, in _update_available_resource
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager     self._update(context, cn, startup=startup)
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager   File "/usr/lib/python2.7/site-packages/nova/compute/resource_tracker.py", line 1237, in _update
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager     self._update_to_placement(context, compute_node, startup)
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager   File "/usr/lib/python2.7/site-packages/retrying.py", line 68, in wrapped_f
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager     return Retrying(*dargs, **dkw).call(f, *args, **kw)
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager   File "/usr/lib/python2.7/site-packages/retrying.py", line 223, in call
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager     return attempt.get(self._wrap_exception)
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager   File "/usr/lib/python2.7/site-packages/retrying.py", line 261, in get
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager     six.reraise(self.value[0], self.value[1], self.value[2])
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager   File "/usr/lib/python2.7/site-packages/retrying.py", line 217, in call
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager     attempt = Attempt(fn(*args, **kwargs), attempt_number, False)
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager   File "/usr/lib/python2.7/site-packages/nova/compute/resource_tracker.py", line 1151, in _update_to_placement
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager     context, compute_node.uuid, name=compute_node.hypervisor_hostname)
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager   File "/usr/lib/python2.7/site-packages/nova/scheduler/client/report.py", line 858, in get_provider_tree_and_ensure_root
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager     parent_provider_uuid=parent_provider_uuid)
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager   File "/usr/lib/python2.7/site-packages/nova/scheduler/client/report.py", line 640, in _ensure_resource_provider
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager     rps_to_refresh = self.get_providers_in_tree(context, uuid)
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager   File "/usr/lib/python2.7/site-packages/nova/scheduler/client/report.py", line 503, in get_providers_in_tree
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager     raise exception.ResourceProviderRetrievalFailed(uuid=uuid)
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager ResourceProviderRetrievalFailed: Failed to get resource provider with UUID 5a5ae2e2-063b-4311-9b24-23373417dc5b
        2020-04-23 04:41:07.518 19347 ERROR nova.compute.manager

Install Network Service on Controller Node
''''''''''''''''''''''''''''''''''''''''''

- https://docs.openstack.org/neutron/train/install/controller-install-rdo.html
- https://docs.openstack.org/neutron/train/install/controller-install-option2-rdo.html

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Conectarnos al servidor de base de datos como usuario root:
    mysql -u root --password=openstack

    # Crear la base de datos de Neutron:
    CREATE DATABASE neutron;

    # Brindar el acceso apropiado a la base de datos de Neutron:
    GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'openstack';
    GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'openstack';
    EXIT;

    # Crear un usuario neutron y añadir el rol admin al usuario:
    . /home/vagrant/admin-openrc
    openstack user create --domain default --password openstack neutron
    openstack role add --project service --user neutron admin

    # Crear el servicio de Neutron:
    openstack service create --name neutron --description "OpenStack Networking" network

    # Crear los Compute API Endpoints (public, internal, admin):
    openstack endpoint create --region RegionOne network public http://controller:9696
    openstack endpoint create --region RegionOne network internal http://controller:9696
    openstack endpoint create --region RegionOne network admin http://controller:9696

.. code-block:: bash

    # Networking Option 2: Self-service networks

    # Instalar los paquetes de Neutron:
    yum install -y openstack-neutron openstack-neutron-ml2 openstack-neutron-linuxbridge ebtables

    # Configurar la base de datos SQL para Neutron:
    crudini --set /etc/neutron/neutron.conf database connection mysql+pymysql://neutron:openstack@controller/neutron
    # Configurar el acceso RabbitMQ para Neutron:
    crudini --set /etc/neutron/neutron.conf DEFAULT transport_url rabbit://openstack:openstack@controller

    # Habilitar el plug-in ML2, servicio de router, y overlaping de direcciones IP:
    crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
    crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router
    crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips true

    # Configurar el acceso a Identity service:
    crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone

    crudini --set /etc/neutron/neutron.conf keystone_authtoken www_authenticate_uri http://controller:5000
    crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://controller:5000
    crudini --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers controller:11211
    crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_type password
    crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name default
    crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name default
    crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name service
    crudini --set /etc/neutron/neutron.conf keystone_authtoken username neutron
    crudini --set /etc/neutron/neutron.conf keystone_authtoken password openstack
    # Comentar cualquier otro parámetro en la sección [keystone_authtoken]

    # Configurar Networking para que notifique a Compute de cambios en la topología de red:
    crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes true
    crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes true

    crudini --set /etc/neutron/neutron.conf nova auth_url http://controller:5000
    crudini --set /etc/neutron/neutron.conf nova auth_type password
    crudini --set /etc/neutron/neutron.conf nova project_domain_name default
    crudini --set /etc/neutron/neutron.conf nova user_domain_name default
    crudini --set /etc/neutron/neutron.conf nova region_name RegionOne
    crudini --set /etc/neutron/neutron.conf nova project_name service
    crudini --set /etc/neutron/neutron.conf nova username nova
    crudini --set /etc/neutron/neutron.conf nova password openstack

    # Configurar el lock path:
    crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp

    # Configurar el ML2 plug-in:

    # Enable flat, VLAN and VXLAN Networks
    crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers flat,vlan,vxlan

    # Enable VXLAN Self-service Networks
    crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types vxlan

    # Enable Linux Bridge and L2Population mechanisms
    crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers linuxbridge,l2population

    # Enable Port Security Extenstion Driver
    crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers port_security

    # Configure provider Virtual Network as flat Network
    crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks provider

    # Configure VXLAN Network Identifier Range for Self-service Networks
    crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges 1:1000

    # Enable ipset to increase efficiency of Security Group Rules
    crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset true

    # Configuar el Linux bridge agent:

    # Configure provider Virtual Network mapping to Physical Interface
    crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings provider:eth2

    # Enable VXLAN for Self-service Networks, configure IP address of the Management Interface handling VXLAN traffic
    crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan true
    crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip 10.1.1.11
    crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population true

    # Enable security groups and configure the Linux bridge iptables firewall driver
    crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group true
    crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

    # Configurar el agent L3:
    crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver linuxbridge

    # Configurar el agente DHCP:
    crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver linuxbridge
    crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
    crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata true

.. code-block:: bash

    # Configurar el agente metadata:
    crudini --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_host controller
    crudini --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret openstack

    # Configurar el Compute service para que use el Networking service:
    # En Stein: url = http://controller:9696 es un parámetro de configuración extra
    crudini --set /etc/nova/nova.conf neutron auth_url http://controller:5000
    crudini --set /etc/nova/nova.conf neutron auth_type password
    crudini --set /etc/nova/nova.conf neutron project_domain_name default
    crudini --set /etc/nova/nova.conf neutron user_domain_name default
    crudini --set /etc/nova/nova.conf neutron region_name RegionOne
    crudini --set /etc/nova/nova.conf neutron project_name service
    crudini --set /etc/nova/nova.conf neutron username neutron
    crudini --set /etc/nova/nova.conf neutron password openstack
    crudini --set /etc/nova/nova.conf neutron service_metadata_proxy true
    crudini --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret openstack

    # Finalizar la instalación:

    # Si no existe, crear un link simbólico /etc/neutron/plugin.ini apuntando al archivo /etc/neutron/plugins/ml2/ml2_conf.ini
    ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

    # Poblar la base de datos:
    su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

    # Reiniciar el servicio de Compute API:
    systemctl restart openstack-nova-api.service

    # Habilitat e iniciar los servicios de Networking:
    systemctl enable neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service
    systemctl start neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service

    # Para la opción de Networking 2, habilitamos e iniciamos también el servicio de L3:
    systemctl enable neutron-l3-agent.service
    systemctl start neutron-l3-agent.service

Install Neutron on Compute Node
'''''''''''''''''''''''''''''''

- https://docs.openstack.org/neutron/train/install/compute-install-rdo.html
- https://docs.openstack.org/neutron/train/install/compute-install-option2-rdo.html
- https://docs.openstack.org/neutron/train/install/verify-option2.html

.. admonition:: Nodo(s)

    COMPUTE

.. code-block:: bash

    # Instalar los componentes:
    yum install -y openstack-neutron-linuxbridge ebtables ipset

    # Configuar los componentes comúnes:

    # En la sección [database], comentar cualquier opción de conexión porque los compute nodes no acceden directamente a la base de datos.

    # Configurar acceso a RabbitMQ:
    crudini --set /etc/neutron/neutron.conf DEFAULT transport_url rabbit://openstack:openstack@controller

    # Configurar el acceso a Identity Service:
    crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
    crudini --set /etc/neutron/neutron.conf keystone_authtoken www_authenticate_uri http://controller:5000
    crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://controller:5000
    crudini --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers controller:11211
    crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_type password
    crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name default
    crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name default
    crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name service
    crudini --set /etc/neutron/neutron.conf keystone_authtoken username neutron
    crudini --set /etc/neutron/neutron.conf keystone_authtoken password openstack

    # Configurar el lock path:
    crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp

    # Configuar el Linux bridge agent:

    # Configure provider Virtual Network mapping to Physical Interface
    crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings provider:eth2

    # Enable VXLAN for Self-service Networks, configure IP address of the Management Interface handling VXLAN traffic
    crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan true
    # Reemplazar IP por la del compute node que se está configurando:
    crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip 10.1.1.31
    crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population true

    # Enable security groups and configure the Linux bridge iptables firewall driver
    crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group true
    crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

    # Configurar el Compute service para que use el Networking service:
    # En Stein: url = http://controller:9696 es un parámetro de configuración extra
    crudini --set /etc/nova/nova.conf neutron auth_url http://controller:5000
    crudini --set /etc/nova/nova.conf neutron auth_type password
    crudini --set /etc/nova/nova.conf neutron project_domain_name default
    crudini --set /etc/nova/nova.conf neutron user_domain_name default
    crudini --set /etc/nova/nova.conf neutron region_name RegionOne
    crudini --set /etc/nova/nova.conf neutron project_name service
    crudini --set /etc/nova/nova.conf neutron username neutron
    crudini --set /etc/nova/nova.conf neutron password openstack

    # Reiniciar el Compute service:
    systemctl restart openstack-nova-compute.service

    # Habilitar e iniciar el Linux bridge agent:
    systemctl enable neutron-linuxbridge-agent.service
    systemctl start neutron-linuxbridge-agent.service

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Verificar la operación de Neutron:
    . /home/vagrant/admin-openrc
    openstack extension list --network
    openstack network agent list

Block Storage service - Controller node
'''''''''''''''''''''''''''''''''''''''

- https://docs.openstack.org/cinder/train/install/cinder-controller-install-rdo.html

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Conectarnos al servidor de base de datos como usuario root:
    mysql -u root --password=openstack

    # Crear la base de datos de Cinder:
    CREATE DATABASE cinder;
    # Brindar el acceso apropiado a la base de datos de Cinder:
    GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'openstack';
    GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'openstack';
    EXIT;

    # Crear un usuario cinder y añadir el rol admin al usuario cinder:
    . /home/vagrant/admin-openrc
    openstack user create --domain default --password openstack cinder
    openstack role add --project service --user cinder admin

    # Crear los servicios cinderv2 y cinderv3:
    openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
    openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3

    # Crear los Cinder Service Endpoints (public, internal, admin):
    openstack endpoint create --region RegionOne volumev2 public http://controller:8776/v2/%\(project_id\)s
    openstack endpoint create --region RegionOne volumev2 internal http://controller:8776/v2/%\(project_id\)s
    openstack endpoint create --region RegionOne volumev2 admin http://controller:8776/v2/%\(project_id\)s
    openstack endpoint create --region RegionOne volumev3 public http://controller:8776/v3/%\(project_id\)s
    openstack endpoint create --region RegionOne volumev3 internal http://controller:8776/v3/%\(project_id\)s
    openstack endpoint create --region RegionOne volumev3 admin http://controller:8776/v3/%\(project_id\)s

    # Instalar el paquete de Cinder:
    yum install -y openstack-cinder

    # Configurar la base de datos SQL para Neutron:
    crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:openstack@controller/cinder
    # Configurar el acceso RabbitMQ para Neutron:
    crudini --set /etc/cinder/cinder.conf DEFAULT transport_url rabbit://openstack:openstack@controller

    # Configurar el acceso a Identity service:
    crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
    crudini --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://controller:5000
    crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:5000
    crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers controller:11211
    crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
    crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
    crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
    crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
    crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
    crudini --set /etc/cinder/cinder.conf keystone_authtoken password openstack

    # Configurar la dirección de la interfaz de administración del controller node:
    crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 10.1.1.11

    # Configurar el lock path:
    crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp

    # Poblar la base de datos de block storage:
    su -s /bin/sh -c "cinder-manage db sync" cinder

    # Configurar el Compute service para que use el Block Storage service:
    crudini --set /etc/nova/nova.conf cinder os_region_name RegionOne

    # Reiniciar el servicio de Compute API:
    systemctl restart openstack-nova-api.service

    # Habilitar e iniciar los servicios de Block Storage:
    systemctl enable openstack-cinder-api.service openstack-cinder-scheduler.service
    systemctl start openstack-cinder-api.service openstack-cinder-scheduler.service

Block Storage service - Storage node
''''''''''''''''''''''''''''''''''''

- https://docs.openstack.org/cinder/train/install/cinder-storage-install-rdo.html

.. admonition:: Nodo(s)

    BLOCK

.. Important::

    Agregar un nuevo disco por VirtualBox a la máquina virtual (sdb)

.. code-block:: bash

    # Instalar los paquetes LVM (lvm2 y device-mapper-persistent-data vienen instalados por defecto):
    yum install -y lvm2 device-mapper-persistent-data

    # Habilitar e iniciar el servicio de metada de LVM:
    systemctl enable lvm2-lvmetad.service
    systemctl start lvm2-lvmetad.service

    # Verificar que exista el disco sdb:
    fdisk -l

    # Crear el volumen físico LVM /dev/sdb:
    pvcreate /dev/sdb

    # Crear el LVM volume group:
    vgcreate cinder-volumes /dev/sdb

    # Editar el archivo de configuración LVM /etc/lvm/lvm.conf, para que incluya la siguiente línea:
    # Si usamos LVM en el disco de sistema operativo, añadimos el dispositivo al filtro (p. ej. /dev/sda)
    devices {
    ...
    filter = [ "a/sda/", "a/sdb/", "r/.*/"]

    # Instalar los paquetes de Cinder (además de crudini para la configuración de archivos):
    yum install -y openstack-cinder targetcli python-keystone crudini

    # Configurar la base de datos SQL para Neutron:
    crudini --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:openstack@controller/cinder
    # Configurar el acceso RabbitMQ para Neutron:
    crudini --set /etc/cinder/cinder.conf DEFAULT transport_url rabbit://openstack:openstack@controller

    # Configurar el acceso a Identity Service:
    crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
    crudini --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://controller:5000
    crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:5000
    crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers controller:11211
    crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
    crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
    crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
    crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
    crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
    crudini --set /etc/cinder/cinder.conf keystone_authtoken password openstack
    # Comentar cualquier otro parámetro en la sección [keystone_authtoken]

    crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 10.1.1.41

    # Configurar LVM Backend:
    crudini --set /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
    crudini --set /etc/cinder/cinder.conf lvm volume_group cinder-volumes
    crudini --set /etc/cinder/cinder.conf lvm target_protocol iscsi
    crudini --set /etc/cinder/cinder.conf lvm target_helper lioadm

    # Habilitar el LVM Backend:
    crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends lvm

    # Configurar la ubicación del Image service:
    crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers http://controller:9292

    # Configurar el lock path:
    crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp

    # Habilitar e inicar servicios de volumen Block storage:
    systemctl enable openstack-cinder-volume.service target.service
    systemctl start openstack-cinder-volume.service target.service

Verify Cinder operation
'''''''''''''''''''''''

- https://docs.openstack.org/cinder/train/install/cinder-verify.html

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Verificar la operación de Cinder:
    . /home/vagrant/admin-openrc

    # Listar los componentes del servicio:
    openstack volume service list

    # Crear un volumen:
    . /home/vagrant/demo-openrc
    openstack volume create --size 1 test-volume

    # Listar volúmenes:
    openstack volume list

.. admonition:: Nodo(s)

    BLOCK

.. code-block:: bash

    lvdisplay

Install and Configure Horizon Packages
''''''''''''''''''''''''''''''''''''''

- https://docs.openstack.org/horizon/train/install/install-rdo.html

.. admonition:: Nodo(s)

    CONTROLLER

.. code-block:: bash

    # Instalar paquetes:
    yum install -y openstack-dashboard

Editar el archivo ``/etc/openstack-dashboard/local_settings`` para que incluya:

.. code-block:: bash

    OPENSTACK_HOST = "controller"

    ALLOWED_HOSTS = ['*']

    SESSION_ENGINE = 'django.contrib.sessions.backends.cache'

    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
            'LOCATION': 'controller:11211',
        }
    }

    OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST

    OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True

    OPENSTACK_API_VERSIONS = {
        "identity": 3,
        "image": 2,
        "volume": 3,
    }

    OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "Default"

    OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"

    WEBROOT = '/dashboard/'

.. Error::

    **ERROR en OpenStack Dashboard**: En el navegador sale el mensaje: 'Not Found. The requested URL /auth/login/ was not found on this server'

    **SOLUCIÓN**:

    - https://louky0714.tistory.com/entry/Openstack-Train-Error-The-requested-URL-authlogin-was-not-found-on-this-server
    - https://www.youtube.com/watch?v=_sHkUn4fFe8

    Debemos agregar una línea extra al archivo ``/etc/openstack-dashboard/local_settings``:

    .. code-block:: text

        WEBROOT = '/dashboard/'

- Editar el archivo ``/etc/httpd/conf.d/openstack-dashboard.conf`` para incluir la siguiente línea, si no se encuentra:

.. code-block:: text

    WSGIApplicationGroup %{GLOBAL}

-  Reiniciar la configuración del web server:

.. code-block:: bash

    systemctl restart httpd.service memcached.service

- Ingresar desde un navegador al dashboard: http://10.1.1.11/dashboard/

Mostrar logs de servicios para troubleshooting de errores
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''

- Controller node (Placemente, Neutron):

.. code-block:: bash

    tail -f /var/log/placement/placement-api.log | grep -i error &
    tail -f /var/log/neutron/* | grep -i error &

- Compute node (Nova):

.. code-block:: bash

    tail -f /var/log/nova/* | grep -i error &

- Block node (Cinder):

.. code-block:: bash

    tail -f /var/log/cinder/* | grep -i error &

Primeras pasos con OpenStack
''''''''''''''''''''''''''''

.. code-block:: bash

    source /home/vagrant/admin-openrc
    openstack flavor create --id 1 --ram 512 --disk 1 --public m1.tiny
    openstack network create  --share --external --provider-physical-network provider --provider-network-type flat provider
    openstack subnet create --network provider --dns-nameserver 8.8.4.4 --subnet-range 203.0.113.0/24 provider

    source /home/vagrant/demo-openrc
    openstack network create private
    openstack subnet create private --subnet-range 192.168.100.0/24 --dns-nameserver 8.8.8.8 --network private
    openstack router create demo-nsrouter
    openstack router add subnet demo-nsrouter private
    openstack router set demo-nsrouter --external-gateway provider
    openstack network list
    openstack server create --image cirros4.0 --flavor 1 --nic net-id=6a5f05fb-048d-4b5f-8409-ff115d32ac84 inst1
