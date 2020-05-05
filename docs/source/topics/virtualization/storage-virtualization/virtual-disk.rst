.. _virtualdisk:

Creando un disco virtual
========================

.. contents:: Table of Contents 

Un disco duro virtual o Virtual Hard Disk (VHD) es un archivo contenedor que actúa similar a un disco duro físico. Un uso típico de un VHD es en VMs, para guardar SOs, sus aplicaciones y datos.

En este tutorial crearemos un VHD que será montado en el host.

1. Crear una imagen que contenga el volumen virtual

Una opción es usar el comando ``dd``. Más información en :ref:`poolswithlibvirt`.

En este caso crearemos una imagen de disco de 4GB usando bloques de 1GB:

.. code-block:: bash

    $ sudo dd if=/dev/zero of=/media/disk1.img bs=1G count=4

    4+0 records in
    4+0 records out
    4294967296 bytes (4,3 GB, 4,0 GiB) copied, 8,76525 s, 490 MB/s

2. Formatear el archivo de la imagen VHD

Utilizar la herramienta ``mkfs`` para formatear la imagen VHD con el formato ``ext4``:

.. code-block:: bash

    $ sudo mkfs -t ext4 /media/disk1.img

    mke2fs 1.44.1 (24-Mar-2018)
    Discarding device blocks: done                            
    Creating filesystem with 1048576 4k blocks and 262144 inodes
    Filesystem UUID: 7ec58ec5-313b-44b6-b3d2-a08d0a08b66e
    Superblock backups stored on blocks: 
            32768, 98304, 163840, 229376, 294912, 819200, 884736

    Allocating group tables: done                            
    Writing inode tables: done                            
    Creating journal (16384 blocks): done
    Writing superblocks and filesystem accounting information: done

3. Montar el la imagen disco formateada en un directorio

Para poder acceder a un volumen VHD, debemos montarlo en un directorio. Usaremos la herramienta ``mount``:

.. code-block:: bash

    $ sudo mkdir /mnt/vhd/
    $ sudo mount -t auto -o loop /media/disk1.img /mnt/vhd/

- ``-t``: tipo
- ``-o``: opciones

4. Volver permanente el montado

Para volver permanente el montado del filesystem del VHD luego de reiniciar el sistema, ingresar una nueva entrada en el archivo ``/etc/fstab``:

.. code-block:: bash

    /media/disk1.img  /mnt/vhd/  ext4    defaults        0  0

5. Comprobar que existe el filesystem del nuevo disco virtual junto con la dirección del directorio donde está montado

.. code-block:: bash

    $ df -hT

    Filesystem     Type      Size  Used Avail Use% Mounted on
    ...
    /dev/loop12    ext4      3,9G   16M  3,7G   1% /mnt/vhd

.. Note::

    Para eliminar el volumen VHD primero desmontar el filesystem VHD y luego eliminar el archivo de imagen

    .. code-block:: bash

        $ sudo umount /mnt/vhd/
        $ sudo rm /media/disk1.img
