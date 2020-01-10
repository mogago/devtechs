Creando VMs con ``virt-install``
================================

.. contents:: Table of Contents 

``virt-install`` es una herramienta de línea de comandos con la cual podemos crear guest VMs e instalar un SO dentro de ellas. Puede usarse dentro de un script para automatizar la creación de VMs o trabajar con la herramienta interactivamente. Además, podemos iniciar la instalación de SOs en las VMs de manera *unattended* a través de archivos **kickstart**.

``virt-install`` abrirá una ventana ``virt-viewer`` una vez que se haya creado la VM para acceder a la misma.

.. Note::

    Se requiere de privilegio root para ejecutar algunos parámetros con ``virt-install``.

Opciones principales del comando ``virt-install``
-------------------------------------------------

Ver la guía de ayuda de ``virt-install``:

.. code-block:: bash

    $ virt-install --help

Ver una lista completa de opciones para un argumento:

.. code-block:: bash

    # virt-install --option=?
    $ virt-install --disk=?
        
        --disk options:
            address.base
            address.bus
            address.controller
        # ...

Opciones generales
''''''''''''''''''

- ``-- name``: nombre de la VM.
- ``-- memory``: cantidad de RAM para asignar al guest (en MiB).

Almacenamiento guest
''''''''''''''''''''

Usar una de las siguientes 2 opciones:

- ``-- disk``: configuración del almacenamiento de la VM. (``--disk none`` crea la VM sin espacio de disco).
- ``-- filesystem``: ruta del filesystem para la VM guest.

Método de instalación
'''''''''''''''''''''

Usar uno de los siguientes métodos:

- ``-- location``: ubicación del medio de instalación.
- ``-- cdrom``: archivo o dispositivo usado como cd-rom virtual. Puede ser la ruta a una imagen ISO o a una URL de donde extraer la imagen ISO. Pero no puede ser un dispositivo CD-ROM físico del host.
- ``-- pxe``: usar el protocolo de booteo PXE para cargar el initial ramdisk y el kernel al iniciar la instlación del guest.
- ``-- import``: no realiza la instalación del SO y construye el guest a partir de una imagen de disco existente. El inicio usado para el booteo sera el primer dispositivo pasado por la opción ``disk`` o ``filesystem``.
- ``-- boot``: configuración de arranque de la VM luego de la instalación. Esta opción permite especificar un orden de arranque de dispositivos, arrancar siempre del kernel e initrd con argumentos opcionales de kernel y habilitar un menú de arranque de la BIOS.

Ejemplos de creación de VMs
---------------------------

Usando una imagen ISO
'''''''''''''''''''''

Crear una VM desde una imagen ISO:

.. code-block:: bash

    $ sudo virt-install \
    --name ubuntu18-desktop-guest-1 \
    --memory 2048 \
    --vcpus 2 \
    --disk size=10 \
    --cdrom ~/Downloads/ubuntu-18.04.2-live-server-amd64.iso \
    --os-variant ubuntu18.04

El argumento ``--cdrom`` debe especificar la ruta a la imagen ``.iso``.

Importando una imagen de disco
''''''''''''''''''''''''''''''

Crear una VM de una imagen de disco importada:

.. code-block:: bash

    $ sudo virt-install \
    --name centos7-guest-1 \
    --memory 1024 \
    --vcpus 1 \
    --disk ~/Downloads/centos7-min0.qcow2 \
    --import \
    --os-variant centos7.0

El argumento ``--disk`` debe especificar la ruta a la imagen de la VM (en este caso es formato ``.qcow2``).

Importando una imagen de red
''''''''''''''''''''''''''''

Crear una VM de una imagen de disco importada de internet:

.. code-block:: bash

    $ sudo virt-install \
    --name ubuntu18-guest-2 \
    --memory 2048 \
    --vcpus 2 \
    --disk size=8 \
    --location http://archive.ubuntu.com/ubuntu/dists/bionic/main/installer-i386/ \
    --os-variant ubuntu18.04

El argumento ``--location`` define la ruta del árbol de instalación del SO.

Usando un servidor PXE
''''''''''''''''''''''

Dos parámetros obligatorios que deben ingresarse para hacer una instalación con el protocolo de booteo PXE son ``--pxe`` y  ``--network`` especificando una red bridged.

Podemos crear una VM usando PXE con el siguiente comando:

.. code-block:: bash

    $ sudo virt-install \
    --name ubuntu18-guest-3 \
    --memory 2048 \
    --vcpus 2 \
    --disk size=8 \
    --network=bridge:br0 \
    --pxe \
    --os-variant ubuntu18.04

Usando un archivo kickstart
'''''''''''''''''''''''''''

Para SOs como Red Hat Enterprise Linux o CentOS podemos pasar un archivo kickstart para automatizar la instalación del SO al arrancar la VM:

.. code-block:: bash

    $ sudo virt-install \ 
    --name guest1-rhel7 \ 
    --memory 2048 \ 
    --vcpus 2 \ 
    --disk size=8 \ 
    --location http://example.com/path/to/os \ 
    --os-variant rhel7 \
    --initrd-inject /path/to/ks.cfg \ 
    --extra-args="ks=file:/ks.cfg console=tty0 console=ttyS0,115200n8" 

Los últimos dos parámetros ``--initrd-inject`` y ``--extra-args`` declaran que la VM usará un archivo kickstart para instalar el SO.

Configuración de red de la VM
-----------------------------

Cuando creamos una VM podemos especificar la red para la VM. A continuación se lista una serie de tipos de red que pueden ser usados para los guests:

Red default con NAT
'''''''''''''''''''

La red default usa un switch de red virtual NAT (network address translation) de ``libvirtd``.  El paquete ``libvirt-daemon-config-network`` debe estar instalado antes de crear una VM con la red default.

Para configurar una VM con red NAT usar el siguiente parámetro en el comando ``virt-install``:

.. code-block:: bash

    --network default \

.. Note::

    Cuando no se especifica un valor del parámetro ``--network``, por defecto se crea la VM con la red default con NAT.

Red bridged con DHCP
''''''''''''''''''''

Podemos configurar una red bridged con un servidor DHCP externo. Esta configuración es útil para casos en los que el host tiene una configuración de red estátoca y el guest requiere conectividad entrante y saliente con la LAN. También es útil para migraciones live de una VM.

Para establecer una red bridged con DHCP para la VM guest, debemos tener creado el bridge previamente y agregar el parámetro:

.. code-block:: bash

    # --network <bridge> \
    --network br0 \

Red bridged con dirección IP estática
'''''''''''''''''''''''''''''''''''''

Una red bridged también puede usarse para configurar una dirección IP estática en el guest. Para usar una red bridged con dirección IP estática en la VM usar:

.. code-block:: bash

    --network br0 \
    --extra-args "ip=192.168.1.2::192.168.1.1:255.255.255.0:test.example.com:eth0:none"

Sin red
'''''''

Para que nuestra VM no tenga una interfaz de red agregar:

.. code-block:: bash

    --network=none \

Referencias
-----------

- `Using qemu-img - RedHat Documents`_
- `Network Address Translation (NAT) with libvirt - RedHat Documents`_
- `Bridged Networking with Virtual Machine Manager - RedHat Documents`_
- `Bridged Networking with libvirt - RedHat Documents`_

.. _Using qemu-img - RedHat Documents: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/chap-Using_qemu_img
.. _Network Address Translation (NAT) with libvirt - RedHat Documents: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/chap-Network_configuration#sect-Network_configuration-Network_Address_Translation_NAT_with_libvirt
.. _Bridged Networking with Virtual Machine Manager - RedHat Documents: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-network_configuration-bridged_networking#sect-Network_configuration-Bridged_networking_with_virt_manager
.. _Bridged Networking with libvirt - RedHat Documents: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-network_configuration-bridged_networking#sect-Network_configuration-Bridged_networking_with_libvirt