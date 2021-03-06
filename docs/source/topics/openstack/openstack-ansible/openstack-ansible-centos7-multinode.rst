OpenStack-Ansible CentOS 7 Multinode
====================================

.. contents:: Table of Contents

Prepare the deployment host
---------------------------

Referencia: `OpenStack-Ansible Prepare the deployment host`_

Cuando instalamos OpenStack en un entorno de producción, se recomienda usar un host de despliegue separado que contenga Ansible y orqueste la instalación OpenStack-Ansible (OSA) en los target hosts. En un entorno de prueba, se recomienda usar uno de los infrastructure target hosts como el deployment host.

Configuring the operating system
''''''''''''''''''''''''''''''''

Configurar al menos una interfaz de red para que acceda a Internet o a repositorios locales.

- Verificar la versión de kernel actual:

.. code-block:: bash

    sudo -i
    uname -mrs

- Verificar los kernels instalados en el sistema (el kernel subrayado es el que está en uso):

.. code-block:: bash

    yum list installed kernel

- Actualizar los paquetes y kernel del sistema:

.. code-block:: bash

    yum upgrade -y

- Reiniciar el sistema para cambiar el kernel

.. code-block:: bash

    reboot

- Verificar la versión de kernel actualizada

.. code-block:: bash

    sudo -i
    uname -mrs

- Verificar los kernels instalados en el sistema (el kernel subrayado es el que está en uso):

.. code-block:: bash

    yum list installed kernel

- Instalar el rpm de OpenStack Train de RDO:

.. code-block:: bash

    yum install -y https://rdoproject.org/repos/openstack-train/rdo-release-train.rpm

- Instalar paquetes de software adicionales:

.. code-block:: bash

    yum install -y vim ntp ntpdate openssh-server python-devel sudo '@Development Tools'

- Instalar Git:

.. Note::

    La instalación de ``git`` en CentOS 7, con los repositorios predeterminados, instalará una version antigua de Git, por ejemplo v1.8:

    .. code-block:: bash

        yum install -y git

Referencia: `Instalar Git 2.X en CentOS 7`_

.. _Instalar Git 2.X en CentOS 7: https://linuxize.com/post/how-to-install-git-on-centos-7/

- Para instalar Git 2.X primero debemos habilitar el repositorio Wandisco GIT, para esto, creamos un nuevo archivo de configuración de repositorio YUM:

.. code-block:: bash

    cat << EOF > /etc/yum.repos.d/wandisco-git.repo
    [wandisco-git]
    name=Wandisco GIT Repository
    baseurl=http://opensource.wandisco.com/centos/7/git/\$basearch/
    enabled=1
    gpgcheck=1
    gpgkey=http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
    EOF

- Importamos las llaves GPG del repositorio:

.. code-block:: bash

    rpm --import http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco

- Ahora que hemos agregado el repositorio, podemos instalar la última versión de Git:

.. code-block:: bash

    yum install -y git

- Revisar la versión de git (2.X)

.. code-block:: bash

    git --version

- Configurar NTP para que se sincronce con una fuente de tiempo correcta.

.. code-block:: bash

    # Instalar el programa chrony:
    yum install -y chrony

    # Reiniciar el servicio de NTP:
    systemctl restart chronyd.service

    # Verificar sincronización de relojes
    chronyc sources

- Por defecto, ``firewalld``  está habilitado en la mayoría de sistemas CentOS y su conjunto de reglas predeterminadas previene que algunos componentes de OpenStack se comuniquen apropiadamente. Parar el servicio ``firewalld`` y enmascararla para prevenirla de iniciar:

.. code-block:: bash

    systemctl stop firewalld
    systemctl mask firewalld

Configure SSH keys
''''''''''''''''''

Ansible usa SSH con autenticación de llave pública para conectar el deployment host y los target hosts. Para reducir la interacción del usuario durante las operaciones de Ansible, no incluir passphrases con key pairs. Sin embargo, si se requiere un passphrase, considerar usar los comandos ``ssh-agent`` y ``ssh-add`` para almacenar temporalmente el passphrase antes de realizar operaciones de Ansible.

1. Copiar los contenidos de la llave pública en el deployment host al archivo ``/root/.ssh/authorized_keys`` en cada target host.

.. code-block:: bash

    ssh-keygen -t rsa -b 4096 -C "root@adh"

.. code-block:: bash

    ssh-copy-id root@172.29.236.101
    ssh-copy-id root@172.29.236.104

2. Probar la autenticación de llave pública desde el deployment host a cada target host usando SSH para conectarnos al target host desde el deployment host. Si podemos conectarnos y obtener el shell sin autenticarnos, está funcionando. SSH provee un shell sin pedirnos una contraseña.

.. code-block:: bash

    ssh root@172.29.236.101 hostname
    cc
    ssh root@172.29.236.104 hostname
    cn

Configure the network
'''''''''''''''''''''

Los despliegues de Ansible fallan si el deployment server no puede usar SSH para conectase a los contenedores.

Configurar el **deployment host** (donde es ejecutado Ansible) para que esté **en la misma red capa 2 como la red designada para la administración de contenedores**. Por defecto, esta es la red ``br-mgmt``. Esta configuración reduce la probabilidad de falla causada por problemas de conectividad.

Seleccionar una dirección IP del siguiente ejemplo de rango para asignarlo al deployment host:

.. code-block:: text

    Container management (br-mgmt network): 172.29.236.0/22 (VLAN 10)

Install the source and dependencies
'''''''''''''''''''''''''''''''''''

Referencia: `Setting up OpenStack-Ansible All-In-One on a Centos 7 system`_

.. _Setting up OpenStack-Ansible All-In-One on a Centos 7 system: https://stafwag.github.io/blog/blog/2019/01/21/settinp-up-openstack-ansible-all-in-one-on-a-centos-7-system/

- El script de boostrap de OpenStack-Ansible descargará e instalará su propia versión de Ansible y creará un link a ``/usr/local/bin``. Por lo cual, ``/usr/local/bin`` debe estar en nuestra variable ``$PATH``. En CentOS 7, la variable ``$PATH`` no contiene esta dirección, así que la debemos agregar:

.. code-block:: bash

    export PATH=/usr/local/bin:$PATH

- Clonar el repositorio OpenStack-Ansible y cambiar al directorio raíz del repo:

.. code-block:: bash

    git clone https://opendev.org/openstack/openstack-ansible /opt/openstack-ansible

    cd /opt/openstack-ansible

Luego, deberemos cambiar al branch/tag desde el cual se implementará. Desplegar desde el head de un branch puede resultar en un build inestable. Para un build de prueba (no para un build de producción) es usualmente mejor hacer checkout de la última versión tagueada.

- Listar tags

.. code-block:: bash

    git tag -l

- Checkout del branch estable y encontrar el último tag:

.. code-block:: bash

    git checkout stable/train
    git describe --abbrev=0 --tags

- Checkout del último tag:

.. code-block:: bash

    git checkout 20.1.0

- Boostrap de Ansible y roles de Ansible para el entorno de desarrollo (Duración: 8:00 - 12:00 min):

.. code-block:: bash

    scripts/bootstrap-ansible.sh

- Probar que se pueda ejecutar el comando openstack-ansible (debemos tener la ruta ``/usr/local/bin`` en nuestra variable ``$PATH``):

.. code-block:: bash

    openstack-ansible --version

Prepare the target hosts
------------------------

Referencia: `OpenStack-Ansible Prepare the target hosts`_

Configuring the operating system
''''''''''''''''''''''''''''''''

- Verificar la versión de kernel actual:

.. code-block:: bash

    sudo -i
    uname -mrs

- Verificar los kernels instalados en el sistema (el kernel subrayado es el que está en uso):

.. code-block:: bash

    yum list installed kernel

- Actualizar los paquetes y kernel del sistema:

.. code-block:: bash

    yum upgrade -y

- Deshabilitar SELinux. Editar ``/etc/sysconfig/selinux``, asegurarnos de cambiar ``SELINUX=enforcing`` a ``SELINUX=disabled``:

.. code-block:: bash

    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
    sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/sysconfig/selinux

- Reiniciar el sistema para cambiar el kernel

.. code-block:: bash

    reboot

.. Note::

    Debemos tener una versión de kernel ``3.10`` o superior.

- Verificar la versión de kernel actualizada

.. code-block:: bash

    sudo -i
    uname -mrs

- Verificar los kernels instalados en el sistema (el kernel subrayado es el que está en uso):

.. code-block:: bash

    yum list installed kernel

- Instalar paquetes de software adicionales:

.. code-block:: bash

    yum install -y bridge-utils iputils lsof lvm2 chrony openssh-server sudo tcpdump python

- Añadir los módulos de kernel apropiados al archivo ``/etc/modules-load.d`` para habiliar VLAN e interfaces bond:

.. code-block:: bash

    echo 'bonding' >> /etc/modules-load.d/openstack-ansible.conf
    echo '8021q' >> /etc/modules-load.d/openstack-ansible.conf

- Configurar NTP en ``/etc/chrony.conf`` para que se sincronce con una fuente de tiempo correcta.

.. code-block:: bash

    # Instalar el programa chrony:
    yum install -y chrony

    # Reiniciar el servicio de NTP:
    systemctl restart chronyd.service

    # Verificar sincronización de relojes
    chronyc sources

- (Opcional) Reducir el nivel de log del kernel cambiando el valor ``printk`` en nuestro ``sysctls``:

.. code-block:: bash

    echo "kernel.printk='4 1 7 4'" >> /etc/sysctl.conf

- Reiniciar el host para activar los cambios y usar el nuevo kernel

Configure SSH keys
''''''''''''''''''

Ansible usa SSH para conectar el deployment host a los target host.

1. Copiar los contenidos de la llave pública en el deployment host al archivo ``/root/.ssh/authorized_keys`` en cada target host.
2. Probar la autenticación de llave pública desde el deployment host a cada target host usando SSH para conectarnos al target host desde el deployment host. Si podemos conectarnos y obtener el shell sin autenticarnos, está funcionando. SSH provee un shell sin pedirnos una contraseña.

.. Note::

    Estos pasos se han realizado en el deployment host (`Prepare the deployment host`_)

.. Important::

    Los depliegues OpenStack-Ansible requieren la presencia de un archivo ``/root/.ssh/id_rsa.pub`` en el deployment host. Los contenidos de este archivo se insertan en un archivo ``authorized_keys`` para los contenedores, lo cual es un paso necesario para los Ansible playbooks. Podemos sobreescribir este comportamiento configurando la variable ``lxc_container_ssh_key`` con la llave pública para el contenedor.

Configuring the storage
'''''''''''''''''''''''

Logical Volume Manager (LVM) habilita a un único dispositivo ser dividido en múltiples volúmenes lógicos que aparecen como un dispositivo de almacenamiento físico al sistema operativo. El servicio de **Block Storage (Cinder)**, y **LXC containers** que corren opcionalmente la infraestructura de OpenStack, opcionalmente pueden usar LVM para su almacenamiento de datos.

.. Note::

    OpenStack-Ansible configura LVM automáticamente en los nodos, y sobreescribe cualquier configuración LVM. Si tenemos una configuración LVM personalizada, editar el archivo de configuración generado como se necesite.

1. Para usar el servicio de Block Storage (cinder), crear un LVM volume group llamado ``cinder-volumes`` en el storage host. Especificar un tamaño de metadata de 2048 cuando creamos el volumen físico. Por ejemplo:

.. code-block:: bash

    pvcreate --metadatasize 2048 physical_volume_device_path
    vgcreate cinder-volumes physical_volume_device_path

2. Opcionalmente, crear un LVM volume group llamado ``lxc`` para container file systems si deseamos usar LXC con LVM. Si el ``lxc`` volume group no existe, los cotenedores serán instalados automáticamente en el file system bajo ``/var/lib/lxc`` por defecto.

Configuring the network
'''''''''''''''''''''''

OpenStack-Ansible usa **bridges** para conectar **interfaces de red físicas y lógicas** en el **host** a **interfaces de red virtuales** dentro de **contenedores**. Los target hosts deben ser configurados con los siguientes network bridges:

+-------------------+-------------------------+--------------------------------------------+
| Nombre del Bridge | Mejor configurado en    | Con IP estática                            |
+-------------------+-------------------------+--------------------------------------------+
| br-mgmt           | En cada nodo            | Siempre                                    |
+-------------------+-------------------------+--------------------------------------------+
| br-storage        | En cada nodo de storage | Cuando el componente se despliega en metal |
+-------------------+-------------------------+--------------------------------------------+
| br-storage        | En cada nodo de compute | Siempre                                    |
+-------------------+-------------------------+--------------------------------------------+
| br-vxlan          | En cada nodo de network | Cuando el componente se despliega en metal |
+-------------------+-------------------------+--------------------------------------------+
| br-vxlan          | En cada nodo de compute | Siempre                                    |
+-------------------+-------------------------+--------------------------------------------+
| br-vlan           | En cada nodo de network | Nunca                                      |
+-------------------+-------------------------+--------------------------------------------+
| br-vlan           | En cada nodo de compute | Nunca                                      |
+-------------------+-------------------------+--------------------------------------------+

Para una referencia detallada sobre cómo implementar el host y container networking, ir a `OpenStack-Ansible Architecture - Container networking`_

Para ejemplos de casos de uso, ir a `OpenStack-Ansible User Guide`_

Host network bridges information
''''''''''''''''''''''''''''''''

- LXC internal ``lxcbr0``
    - El bridge ``lxcbr0`` es requerido para LXC, pero OpenStack-Ansible lo configura automáticamente. Provee conectividad externa (generalmente Internet) a los contenedores con dnsmasq (DHCP/DNS) + NAT.
    - Este bridge no se conecta directamente a ninguna interfaz física o lógica en el host, pues iptables maneja la conectividad. El bridge se conecta a ``eth0`` en cada contenedor.
    - La red de contenedor a la que el bridge se conecta es configurable en el archivo ``openstack_user_config.yml`` en el diccionario ``provider_networks``.
- Container management: ``br-mgmt``
    - El ``br-mgmt`` provee administración y comunicación entre la infraestructura y servicios de OpenStack.
    - El bridge se conecta a una interfaz física o lógica, generalmente una subinterfaz VLAN ``bond0``. También se conecta a ``eth1`` en cada contenedor.
    - La interfaz de red del contenedor a la que se conecta el bridge es configurable en el archivo ``openstack_user_config.yml``.
- Storage: ``br-storage``
    - El bridge ``br-storage`` provee acceso segregado a dispositivos Block Storage entre servicios servicios de OpenStack y dispositivos Block Storage.
    - El bridge se conecta a una interfaz física o lógica, generalmente una subinterfaz VLAN ``bond0``. También se conecta a ``eth2`` en cada contenedor asociado.
    - La interfaz de red del contenedor a la que se conecta el bridge es configurable en el archivo ``openstack_user_config.yml``.
- OpenStack Networking tunnel: ``br-vxlan``
    - El bridge ``br-vxlan`` es **requerido si** el entorno es configurado para que permita a proyectos crear redes virtuales usando VXLAN. Provee la interfaz para **redes de túneles virtuales (VXLAN)**.
    - El bridge se conecta a una interfaz física o lógica, generalmente una subinterfaz VLAN ``bond1``. También se conecta a ``eth10`` en cada contenedor asociado.
    - La interfaz de red del contenedor a la que se conecta el bridge es configurable en el archivo ``openstack_user_config.yml``.
- OpenStack Networking provider: ``br-vlan``
    - El bridge ``br-vlan`` provee infraestructura para **redes VLAN tagged** o **flat (sin VLANT tag)**.
    - El bridge se conecta a una interfaz física o lógica, generalmente una subinterfaz VLAN ``bond1``. Se conecta a ``eth11`` para redes tipo VLAN en cada contenedor asociado. No se le asigna una dirección IP porque maneja solo conectividad capa 2.
    - La interfaz de red del contenedor a la que se conecta el bridge es configurable en el archivo ``openstack_user_config.yml``.

Configure the deployment
------------------------

Referencia: `OpenStack-Ansible Configure the deployment`_

Ansible referencia algunos archivos que contienen directivas de configuración obligatorias y opcionales. Antes de poder correr los Ansible playbooks, modificar estos archivos para definir el entorno del target. Algunas tareas de configuración incluyen:

- Target host networking para definir las interfaces bridge y redes.
- Una lista de target hosts en los cuales instalar el software.
- Relaciones de redes virtuales y físicas para OpenStack Networking (neutron).
- Contraseñas para todos los servicios.

Initial environment configuration
'''''''''''''''''''''''''''''''''

OpenStack-Ansible (OSA) depende de varios archivos que son usados para contruir un inventario para Ansible. Realizar la siguiente configuración en el deployment host:

1. Copiar los contenidos del directorio ``/opt/openstack-ansible/etc/openstack_deploy`` al directorio ``/etc/openstack_deploy``.

.. code-block:: bash

    cp -R /opt/openstack-ansible/etc/openstack_deploy /etc

2. Movernos al directorio ``/etc/openstack_deploy``.

.. code-block:: bash

    cd /etc/openstack_deploy

3. Copiar el archivo ``openstack_user_config.yml.example`` a ``/etc/openstack_deploy/openstack_user_config.yml``.

.. code-block:: bash

    cp openstack_user_config.yml.example /etc/openstack_deploy/openstack_user_config.yml

4. Revisar el archivo ``openstack_user_config.yml`` y realizar cambios al despliegue de nuestro entorno OpenStack.

.. code-block:: bash

    vim openstack_user_config.yml

.. Note::

    Este archivo está muy comentado con detalles sobre las diversas opciones. Ver `OpenStack-Ansible User Guide`_ y `OpenStack-Ansible Reference Guide`_ para más detalles.

La configuración en el archivo ``openstack_user_config.yml`` define qué hosts corren los contenedores y servicios desplegados por OpenStack-Ansible. Por ejemplo, los hosts listados en la sección ``shared-infra_hosts`` corren contenedores para muchos de los servicios compartidos que nuestro entorno OpenStack requiere. Algunos de estos servicios incluyen bases de datos, Memcached, y RabbitMQ. Muchos otros tipos de hosts contiene otros tipos de contenedores, y todos estos son listados en el archivo ``openstack_user_config.yml``.

Algunos servicios, como glance, heat, horizon, nova-infra, no son listados individualmente en el archivo de ejemplo al estar contenidos en los hosts de os-infra. Podemos especificar image-hosts o dashboard-hosts si queremos escalar de una manera específica.

Para ejemplos, ver `OpenStack-Ansible User Guide`_.

Para detalles sobre cómo es generado el inventario, de la configuración de entorno y la precendencia de variable, ver `OpenStack-Ansible Reference Guide`_, en la seccion de inventario.

5. Revisar el archivo ``user_variables.yml`` para configurar opciones globales y de despliegues de roles específicos. El archivo contiene algunas variables de ejemplos y comentario pero podemos obtener la lista completa de variables en cada documentación específica del rol.

.. code-block:: bash

    vim user_variables.yml

.. Note::

    Una variable importante es ``install_method``, la cual configura el método de instalación para los servicios de OpenStack. Los servicios pueden ser desplegados desde la fuente (por defecto) o de paquetes de distribución. Los despliegues basados en la fuente son más cercanos a instalaciones de OpenStack vanilla y permiten más cambios y personalizaciones. Del otro lado, despliegues basados en distros generalmente proveen una combinación de paquetes que han sido verificados por las mismas distribuciones. Sin embargos, esto significa que las actualizaciones son lanzadas con menos frecuencia y con retrasos potenciales. Aun más, este método puede ofrecernos menos oportunidades para personalizaciones de despliegues. La variable ``install_method`` es configurada durante el despliegue inicial y no podremos cambiarla, pues OpenStack-Ansible no puede convertirse de un método de instalación a otro. Como tal, es importante juzgar nuestras necesidades con los pros y contras de cada método antes de tomar una decisión. Notar que el método de instalación ``distro`` fue introducido en el ciclo Rocky, y como resutado, Ubuntu 16.04 no es soportado debido al hecho de que no hay paquetes de Rocky para este.

Installing additional services
''''''''''''''''''''''''''''''

Para instalar servicios adicionales, los archivos en ``etc/openstack_deploy/conf.d`` proveen ejemplos mostrando los host groups correctos para usar. Para añadir otro servicio: añadir el host group, asignarle hosts y luego ejecutar los playbooks.

Advanced service configuration
''''''''''''''''''''''''''''''

OpenStack-Ansible tiene muchas opciones que podemos usar para la configuración avanzada de servicios. Cada documentación de rol provee información sobre las opciones disponibles.

.. Important::

    Este paso es esencial para adaptar OpenStack-Ansible a nuestras necesidades y es generalmente pasado por alto por nuevos deployers. Hechar un vistazo a cada documentación de rol, guía de usuario y referenciarnos a estas si deseamos un cloud adaptada a nuestra necesidad.

Configuring service credentials
'''''''''''''''''''''''''''''''

Configurar credenciales para cada servicio en el archivo ``/etc/openstack_deploy/user_secrets.yml``. Considerar usar el feature Ansible Vault para incrementar la seguridad encriptando archivos que contengan credenciales.

.. code-block:: bash

    vi user_secrets.yml

Ajustar permisos en estos archivos para restringir acceso por usuario no-privilegiados.

La opción ``keystone_auth_admin_password`` configura la contraseña tenant ``admin`` tanto para el acceso OpenStack API y Dashboard.

Se recomienda usar el script ``pw-token-gen.py`` para generar valores aleatorios para las variables en cada archivo que contiene credenciales de servicio:

.. code-block:: bash

    cd /opt/openstack-ansible
    ./scripts/pw-token-gen.py --file /etc/openstack_deploy/user_secrets.yml

Para regenerar las contraseñas existentes, añadir el flag ``--regen``.

.. Warning::

    Los playbooks no soportan cambiar contraseñas en un entorno existente. Cambiar contraseñas y volver a correr los playbooks causará fallos que puedan malograr nuestro entorno OpenStack.

Run playbooks
-------------

Referencia: `OpenStack-Ansible Run playbooks`_

Los procesos de instalación requieren correr 3 playbooks:

- El playbook base de Ansible ``setup-hosts.yml`` prepara los target hosts para servicios de infraestructura y de OpenStack, construye y reinicia contenedores en target hosts, e instala componentes comúnes en contenedores de target hosts.
- El playbook de infraestructura de Ansible ``setup-infrastructure.yml`` instala servicios de infraestructura: Memcached, el servicio de repositorio, Galera, RabbitMQ, and rsyslog.
- El playbook de OpenStack ``setup-openstack.yml`` instala servicios de OpenStack, incluyendo Identity (keystone), Image (glance), Block Storage (cinder), Compute (nova), Networking (neutron), etc.

Checking the integrity of the configuration files
''''''''''''''''''''''''''''''''''''''''''''''''''

Antes de correr cualquier playbook, revisar la integridad de los archivos de configuración.

1. Asegurar que todos los archivos editados en el directorio ``/etc/openstack_deploy`` son compatibles con Ansible YAML.
2. Revisar la integridad de nuestros archivos YAML.

.. Note::

    Para revisar la sintáxis de nuestros archivo YAML podemos usar el `Programa YAML Lint`_.

    .. _Programa YAML Lint: http://www.yamllint.com/

3. Movernos al directorio ``/opt/openstack-ansible/playbooks`` y correr el comando:

.. code-block:: bash

    openstack-ansible setup-infrastructure.yml --syntax-check

4. Volver a revisar que toda la identación es correcta. Esto es importante porque la sintáxis de los archivos de configuración puede ser correcta sin ser significativa para OpenStack-Ansible.

Run the playbooks to install OpenStack
''''''''''''''''''''''''''''''''''''''

1. Movernos al directorio ``/opt/openstack-ansible/playbooks``.
2. Correr el playbook de configuración del host:

.. code-block:: bash

    openstack-ansible setup-hosts.yml

Confirmar la finalización satisfactoria con cero elementos inalcanzables o fallidos:

.. code-block:: text

    PLAY RECAP ********************************************************************
    ...
    deployment_host                :  ok=18   changed=11   unreachable=0    failed=0

3. Correr el playbook de configuración de la infraestructura:

.. code-block:: text

    openstack-ansible setup-infrastructure.yml

Confirmar la finalización satisfactoria con cero elementos inalcanzables o fallidos:

.. code-block:: text

    PLAY RECAP ********************************************************************
    ...
    deployment_host                : ok=27   changed=0    unreachable=0    failed=0

4. Correr los siguientes comandos para verificar el database cluster:

.. code-block:: bash

    ansible galera_container -m shell -a "mysql -h localhost -e 'show status like \"%wsrep_cluster_%\";'"

Output de ejemplo:

.. code-block:: bash

    node3_galera_container-3ea2cbd3 | success | rc=0 >>
    Variable_name             Value
    wsrep_cluster_conf_id     17
    wsrep_cluster_size        3
    wsrep_cluster_state_uuid  338b06b0-2948-11e4-9d06-bef42f6c52f1
    wsrep_cluster_status      Primary

    node2_galera_container-49a47d25 | success | rc=0 >>
    Variable_name             Value
    wsrep_cluster_conf_id     17
    wsrep_cluster_size        3
    wsrep_cluster_state_uuid  338b06b0-2948-11e4-9d06-bef42f6c52f1
    wsrep_cluster_status      Primary

    node4_galera_container-76275635 | success | rc=0 >>
    Variable_name             Value
    wsrep_cluster_conf_id     17
    wsrep_cluster_size        3
    wsrep_cluster_state_uuid  338b06b0-2948-11e4-9d06-bef42f6c52f1
    wsrep_cluster_status      Primary

El campo ``wsrep_cluster_size`` indica el número de nodos en el clúster y el campo ``wsrep_cluster_status`` indica que es primario.

5. Correr el playbook de configuración de OpenStack:

.. code-block:: bash

    openstack-ansible setup-openstack.yml

Confirmar la finalización satisfactoria con cero elementos inalcanzables o fallidos.

.. Note::

    Guardar el output de los comandos impresos en el terminal en un archivo, incluyendo mensajes de advertencia y errores (``2>&1``):

    .. code-block:: bash

        openstack-ansible setup-hosts.yml 2>&1 | tee /root/setup-hosts.log

Verifying OpenStack operation
-----------------------------

Referencia: `OpenStack-Ansible Verifying OpenStack operation`_

Para verificar la operación básica de OpenStack API y el Dashboard, realizar las siguientes tareas en un host de infraestructura.

Verify the API
''''''''''''''

El **utility container** provee un entorno CLI para configuraciones adicionales y pruebas.

1. Determinar el nombre del utility container:

.. code-block:: bash

    lxc-ls | grep utility

2. Acceder al utility container:

.. code-block:: bash

    lxc-attach -n infra1_utility_container-161a4084

3. Obtener las credenciales de tenant ``admin``:

.. code-block:: bash

    . ~/openrc

4. Listar los usuarios de openstack:

.. code-block:: bash

    openstack user list --os-cloud=default

Verifying the Dashboard (horizon)
'''''''''''''''''''''''''''''''''

1. Dentro de un navegador web, acceder al Dashboard usando la dirección IP del load balancer externo definido por la opción ``external_lb_vip_address`` en el archivo ``/etc/openstack_deploy/openstack_user_config.yml``. El Dashboard usa HTTPS en el puerto 443.
2. Autenticarse usando el nombre de usuario ``admin`` y la contraseña definida por la opción ``keystone_auth_admin_password`` en el archivo ``/etc/openstack_deploy/user_secrets.yml``.


Resumen de archivos del repositorio ``openstack-ansible/``
----------------------------------------------------------

- Archivos de configuración:
    - Configuration for OSA core services: ``openstack-ansible/etc/openstack_deploy/openstack_user_config.yml``
    - Optional servicie configuration: ``openstack-ansible/etc/openstack_deploy/conf.d/*``
        - aodh.yml.aio
        - aodh.yml.example
        - barbican.yml.aio
        - barbican.yml.example
        - blazar.yml.aio
        - ceilometer.yml.aio
        - ceilometer.yml.example
        - ceph.yml.aio
        - cinder.yml.aio
        - congress.yml.aio
        - designate.yml.aio
        - designate.yml.example
        - etcd.yml.aio
        - etcd.yml.example
        - glance.yml.aio
        - gnocchi.yml.aio
        - haproxy.yml.aio
        - haproxy.yml.example
        - heat.yml.aio
        - horizon.yml.aio
        - ironic.yml.aio
        - keystone.yml.aio
        - magnum.yml.aio
        - magnum.yml.example
        - manila.yml.aio
        - manila.yml.example
        - masakari.yml.aio
        - masakari.yml.example
        - mistral.yml.aio
        - mistral.yml.example
        - murano.yml.aio
        - murano.yml.example
        - neutron.yml.aio
        - nova.yml.aio
        - octavia.yml.aio
        - panko.yml.aio
        - panko.yml.example
        - placement.yml.aio
        - placement.yml.example
        - qdrouterd.yml.aio
        - rally.yml.aio
        - sahara.yml.aio
        - swift-remote.yml.sample
        - swift.yml.aio
        - swift.yml.example
        - tacker.yml.aio
        - trove.yml.aio
        - trove.yml.example
        - unbound.yml.aio
        - unbound.yml.example
    - Opciones globales y de despliegues de roles específicos: ``openstack-ansible/etc/openstack_deploy/user_variables.yml``
    - Credenciales para cada servicio: ``openstack-ansible/etc/openstack_deploy/user_secrets.yml``

- Archivos de ejecución (playbooks):
    - ``openstack-ansible/playbooks/setup-hosts.yml``
        - import_playbook: openstack-hosts-setup.yml
        - import_playbook: security-hardening.yml
        - import_playbook: containers-deploy.yml
    - ``openstack-ansible/playbooks/setup-infrastructure.yml``
        - import_playbook: unbound-install.yml
        - import_playbook: repo-install.yml
        - import_playbook: haproxy-install.yml
        - import_playbook: utility-install.yml
        - import_playbook: memcached-install.yml
        - import_playbook: galera-install.yml
        - import_playbook: qdrouterd-install.yml
        - import_playbook: rabbitmq-install.yml
        - import_playbook: etcd-install.yml
        - import_playbook: ceph-install.yml
        - import_playbook: rsyslog-install.yml
    - openstack-ansible/playbooks/setup-openstack.yml
        - import_playbook: os-keystone-install.yml
        - import_playbook: os-barbican-install.yml
        - import_playbook: os-placement-install.yml
        - import_playbook: os-glance-install.yml
        - import_playbook: os-cinder-install.yml
        - import_playbook: os-nova-install.yml
        - import_playbook: os-neutron-install.yml
        - import_playbook: os-heat-install.yml
        - import_playbook: os-horizon-install.yml
        - import_playbook: os-designate-install.yml
        - import_playbook: os-gnocchi-install.yml
        - import_playbook: os-swift-install.yml
        - import_playbook: os-ceilometer-install.yml
        - import_playbook: os-aodh-install.yml
        - import_playbook: os-panko-install.yml
        - import_playbook: os-ironic-install.yml
        - import_playbook: os-magnum-install.yml
        - import_playbook: os-trove-install.yml
        - import_playbook: os-sahara-install.yml
        - import_playbook: os-octavia-install.yml
        - import_playbook: os-tacker-install.yml
        - import_playbook: os-blazar-install.yml
        - import_playbook: os-masakari-install.yml
        - import_playbook: os-manila-install.yml
        - import_playbook: os-mistral-install.yml
        - import_playbook: os-murano-install.yml
        - import_playbook: ceph-rgw-install.yml
        - import_playbook: os-congress-install.yml
        - import_playbook: os-tempest-install.yml
        - import_playbook: os-rally-install.yml

Referencias
-----------

- `OpenStack-Ansible Reference Guide`_
- `OpenStack-Ansible User Guide`_
- `OpenStack-Ansible User Guide - Network architectures`_
- `OpenStack-Ansible User Guide - Test environment example`_
- `OpenStack-Ansible Architecture`_
- `OpenStack-Ansible Architecture - Container Networking`_
- `OpenStack-Ansible - Project Update`_

.. _OpenStack-Ansible Reference Guide: https://docs.openstack.org/openstack-ansible/train/reference/index.html
.. _OpenStack-Ansible User Guide: https://docs.openstack.org/openstack-ansible/train/user/index.html
.. _OpenStack-Ansible User Guide - Network architectures: https://docs.openstack.org/openstack-ansible/train/user/network-arch/example.html
.. _OpenStack-Ansible User Guide - Test environment example: https://docs.openstack.org/openstack-ansible/train/user/test/example.html
.. _OpenStack-Ansible Architecture: https://docs.openstack.org/openstack-ansible/train/reference/architecture/index.html
.. _OpenStack-Ansible Architecture - Container networking: https://docs.openstack.org/openstack-ansible/train/reference/architecture/container-networking.html
.. _OpenStack-Ansible - Project Update: https://www.youtube.com/watch?v=JZet1uNAr_o

Flujo de instalación de OpenStack-Ansible:

- `OpenStack-Ansible Prepare the deployment host`_
- `OpenStack-Ansible Prepare the target hosts`_
- `OpenStack-Ansible Configure the deployment`_
- `OpenStack-Ansible Run playbooks`_
- `OpenStack-Ansible Verifying OpenStack operation`_

.. _OpenStack-Ansible Prepare the deployment host: https://docs.openstack.org/project-deploy-guide/openstack-ansible/train/deploymenthost.html
.. _OpenStack-Ansible Prepare the target hosts: https://docs.openstack.org/project-deploy-guide/openstack-ansible/train/targethosts.html
.. _OpenStack-Ansible Configure the deployment: https://docs.openstack.org/project-deploy-guide/openstack-ansible/train/configure.html
.. _OpenStack-Ansible Run playbooks: https://docs.openstack.org/project-deploy-guide/openstack-ansible/train/run-playbooks.html
.. _OpenStack-Ansible Verifying OpenStack operation: https://docs.openstack.org/project-deploy-guide/openstack-ansible/train/verify-operation.html