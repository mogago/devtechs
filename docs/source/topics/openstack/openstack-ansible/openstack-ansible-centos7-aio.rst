OpenStack-Ansible CentOS 7 AIO
==============================

.. contents:: Table of Contents

Referencia: `OpenStack-Ansible - Quickstart AIO`_

.. _OpenStack-Ansible - Quickstart AIO: https://docs.openstack.org/openstack-ansible/train/user/aio/quickstart.html

Despliegues All-in-one (AIO) son una buena forma de realizar un despliegue OpenStack-Ansible para:

- entornos de desarrollo
- una visión de cómo trabajan juntos los servicios de OpenStack
- un despliegue de laboratorio simple

Sin embargo, despliegues AIO no son recomendados entornos de producción, son buenos para entornos de prueba de concepto.

Recursos de servidor mínimos:

- 8 vCPUs
- 50 GB libres de espacio de disco en la partición root
- 8 GB RAM

Recursos de servidor recomendados:

- CPU/motherboard que soporte hardware-assisted virtualization
- 8 CPU cores
- 80 GB libres de espacio de disco en la partición root o 60GB+ en un disco secundario vacío. Usar un disco secundario requiere usar el parámetro ``bootstrap_host_data_disk_device``

Es posible realizar AIO builds en una máquina virtual para demostraciones y evaluación, pero nuestras VMs rendirán pobremente, excepto que activemos nested virtualization. Para cargas de trabajo de producción, se recomienda múltiples nodos para roles específicos.

Despliegue con Vagrant
----------------------

Con el archivo Vagrantfile podremos desplegar una VM con la configuración inicial para desplegar OpenStack-Ansible AIO:

- Vagrantfile: :download:`Descargar Vagrantfile <extra/Vagrantfile_ansibleaio>`
- Script de ansibleaio: :download:`Descargar ansibleaio_setup.sh <extra/ansibleaio_setup.sh>`

Overview
--------

Hay 4 pasos para lograr correr un entorno AIO:

- Preparar el host
- Boostrap de Ansible y los roles requeridos
- Boostrap de la configuración AIO
- Correr los playbooks

Prepare the host
----------------

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

Bootstrap Ansible and the required roles
----------------------------------------

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

- Boostrap de Ansible y roles de Ansible para el entorno de desarrollo (Duración: 8:30 - 12:00 min):

.. code-block:: bash

    scripts/bootstrap-ansible.sh

- Probar que se pueda ejecutar el comando openstack-ansible:

.. code-block:: bash

    openstack-ansible

Bootstrap the AIO configuration
-------------------------------

Para que todos los servicios corran, el host debe estar preparado con el particionamiento de disco, paquetes, configuración de red y configuraciones para el OpenStack Deployment correctos.

Por defecto, los bootstrap scripts de AIO despliegan un conjunto base de servicios OpenStack con valores predeterminados razonables con el propósito de un gate check, sistema de despliegue o sistema de pruebas.

El bootstrap script está pre-configurado para pasar la variable de entorno ``BOOTSTRAP_OPTS`` como una opción adicional para al proceso bootstrap.

- Para el escenario AIO predeterminado, la preparación de configuración AIO es completada ejecutando (Duración: 2:00 min):

.. code-block:: bash

    scripts/bootstrap-aio.sh

.. Note::

    Entre todas los cambios hechos luego de ejecutar este script, se cambiará el hostname a ``aio1``. Además se editará el parámetro ``PasswordAuthentication`` del archivo ``/etc/ssh/sshd_config``, impidiendo conexiones SSH mediante contraseñas.

    Para volver a permitir la conexión por SSH al sistema ejecutar:

    .. code-block:: bash

        sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
        systemctl restart sshd

.. Note::

    - Para añadir OpenStack Services encima de los servicios boostrap-aio predeterminados para el escenario aplicable, copiar los archivos ``conf.d`` con la extensión ``.aio`` a ``/etc/openstack_deploy`` y luego renombrarlos a archivo ``.yml``. Por ejemplo, para habiltar el servicio de OpenStack Telemetry, ejecutar:

    .. code-block:: bash

        cd /opt/openstack-ansible/

        cp etc/openstack_deploy/conf.d/{aodh,gnocchi,ceilometer}.yml.aio /etc/openstack_deploy/conf.d/

        for f in $(ls -1 /etc/openstack_deploy/conf.d/*.aio); do mv -v ${f} ${f%.*}; done

    - También es posible hacer esto (y cambiar otros valores predeterminados) durante la ejecución inicial del boostrap script cambiando la variable de entorno SCENARIO antes de correr el script. La palabra clave 'aio' asegurará que un conjunto de servicios básicos de OpenStack (cinder, glance, horizon, neutron, nova) sean desplegados. Las palabras claves 'lxc' y 'nspawn' pueden usarse para configurar el container back-end, mientras que la palabra 'metal' desplegará todos los servicios sin contenedores. Para implementar cualquier otro servicio, añadir el nombre del archivo ``conf.d``, sin la extensión ``.yml.aio`` en la variable de entorno SCENARIO. Cada palabra clave debe ser limitada por un guión bajo. Por ejemplo, lo siguiente implementará un AIO con barbican, cinder, glance, horizon, neutron y nova. Configurará el almacenamiento de Cinder con Ceph back-end y usará LXC como el container back-end.

    .. code-block:: bash

        export SCENARIO='aio_lxc_barbican_ceph'

        scripts/bootstrap-aio.sh

.. Note::

    Si las palabras clave 'metal' y 'aio' son usadas juntas, horizon no será desplegado porque haproxy y horizon entrarán en conflicto en los mismos puertos de escucha.

- Para añadir cualquier sobreescritura global, sobre los valores por defecto del escenario pertinente, editar ``/etc/openstack_deploy/user_variables.yml``. Para poder comprender las varios formas que podemos sobreescribir el comportamiento por defecto establecido en los roles, playbooks y variables de group, ir a `OpenStack-Ansible - Overriding default configuration`

.. _OpenStack-Ansible - Overriding default configuration: https://docs.openstack.org/openstack-ansible/train/reference/configuration/using-overrides.html

Run playbooks
-------------

- Finalmente correr los playbooks ejecutando:

.. code-block:: bash

    cd /opt/openstack-ansible/playbooks

    openstack-ansible setup-hosts.yml
    # Duración: 22:30 min

    openstack-ansible setup-infrastructure.yml
    # Duración: 13:30 min

    openstack-ansible setup-openstack.yml
    # Duración: 1:25:00 horas

.. Note::

    El proceso de instalación tomará un tiempo para que complete pero aquí hay algunos estimados:

    - Almacenamiento Bare metal con almacenamiento SSD: ~ 30-50 minutos
    - Máquinas virtuale con almacenamiento SSD: ~ 45-60 minutos
    - Sistemas con discos duros tradicionales: ~ 90-120 minutos

- Una vez que los playbooks han sido ejecutados completamente, es posible experimentar con varios cambios de configuración en ``/etc/openstack_deploy/user_variables.yml`` y solo correr playbooks individuales. Por ejemplo, para correr el playbook para el servicio de Keytone, ejecutar:

.. code-block:: bash

    cd /opt/openstack-ansible/playbooks
    
    openstack-ansible os-keystone-install.yml
