.. _addstorageguests:

Agregar dispositivos de almacenamiento a Guests
===============================================

.. contents:: Table of Contents

Podemos añadir dispositivos de almacenamiento a las VMs usando ``virsh`` o ``virt-manager``

Agregando almacenamiento con ``virt-manager``
---------------------------------------------

1. Abrir ``virt-manager`` y seleccionar la máquina virtual a la que deseamos agregarle el volumen de almacenamiento:

.. figure:: images/add-storage-guests/vm-list.png
    :align: center

    ``virt-manager`` - Lista de VMs

Clic derecho en nuestra VM | :guilabel:`Open` | :guilabel:`Show virtual hardware details` | :guilabel:`+ Add Hardware`

.. figure:: images/add-storage-guests/virtual-hardware-details.png
    :align: center

    ``virt-manager`` - Show virtual hardware details

2. En la ventana de "Add New Virtual Hardware", tenemos dos opciones:

- Seleccionar :guilabel:`Create a disk image for the virtual machine` para crear rápidamente un nuevo disco:

.. figure:: images/add-storage-guests/add-new-virtual-hardware-create-1.png
    :align: center

    ``virt-manager`` - Add new virtual hardware - Crear un nuevo disco

Al hacer clic en :guilabel:`Finish` se habrá el nuevo dispositivo de almacenamiento:

.. figure:: images/add-storage-guests/add-new-virtual-hardware-create-1.png
    :align: center

    ``virt-manager`` - Nuevo Virtual Disk

- Seleccionar :guilabel:`Select or create custom storage` para crear o seleccionar un almacenamiento personalizado:

.. figure:: images/add-storage-guests/add-new-virtual-hardware-select.png
    :align: center

    ``virt-manager`` - Add new virtual hardware - Seleccionar o crear un almacenamiento personalizado

Si hacemos clic en :guilabel:`Manage` podemos crear un nuevo pool/volumen o seleccionar un volumen existente. Clic en :guilabel:`Choose Volume`.

.. figure:: images/add-storage-guests/choose-storage.png
    :align: center

    ``virt-manager`` - Seleccionar/crear almacenamiento

Agregando almacenamiento con ``virsh``
--------------------------------------

``virsh`` provee la opción ``attach-disk`` para conectar un nuevo dispositivo de disco a una VM. Hay muchos parámetros que provee esta opción:

.. code-block:: bash

    attach-disk domain source target [[[--live] [--config] |
    [--current]] | [--persistent]] [--targetbus bus] [--driver
    driver] [--subdriver subdriver] [--iothread iothread] [--cache
    cache] [--io io] [--type type] [--mode mode] [--sourcetype
    sourcetype] [--serial serial] [--wwn wwn] [--rawio] [--address
    address] [--multifunction] [--print-xml]

Lo siguiente es suficiente para realizar una conexión de un disco en caliente a una VM:

.. code-block:: bash

    $ virsh attach-disk centos7.0 /var/lib/libvirt/images/virtual-disk.img vdc --live --config

- ``centos7.0`` es la VM a la que conectaremos el disco.
- ``/var/lib/libvirt/images/virtual-disk.img`` es la ruta a la imagen de disco.
- ``vdb`` es el nombre del disco objetivo que será visible en el SO guest.
- ``--live`` significa que la acción se realizará mientras está corriendo la VM.
- ``--config`` significa que la conexión del disco será permanente luego de un reinicio.

Usar el comando ``virsh domblklist`` para identificar cuántos vDisks están conectados a una VM:

.. code-block:: bash

    $ virsh domblklist centos7.0 --details

    Type       Device     Target     Source
    ------------------------------------------------
    file       disk       vda        /var/lib/libvirt/images/centos7-guest-temp.qcow2
    file       disk       vdb        /var/lib/libvirt/images/thinprovisioned-disk.img

Significa que los dos vDisks conectados a la VM son imágenes de archivos. Son visibles al SO guest como ``vda`` y ``vdb``. En la última columna se ve la ruta de la imagen de disco en el sistema host.

.. Note::

    Otra opción para añadir un dispositivo de almacenamiento con ``virsh`` es a través de un archivo XML:

    .. code-block:: xml

        <disk type='file' device='disk>'>
            <driver name='qemu' type='raw' cache='none'/>
            <source file='/var/lib/libvirt/images/FileName.img'/>
            <target dev='vdb' bus='virtio'/>
        </disk> 
    
    .. code-block:: bash

        $ virsh attach-disk --config Guest1 ~/NewStorage.xml

Eliminando almacenamiento con ``virsh``
---------------------------------------

Para eliminar un dispositivo de almacenamiento de una VM (``guest1``) con ``virsh`` usamos el comando:

.. code-block:: bash

    $ virsh detach-disk guest1 vdb

Referencias
-----------

- `Adding Storage Devices to Guests`_

.. _Adding Storage Devices to Guests: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/storage_vols#sect-Storage_Volumes-Adding_storage_devices_to_guests