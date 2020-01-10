Despliegue automatizado de VMs con ``virt-builder``
===================================================

.. contents:: Table of Contents

``virt-builder`` es una herramienta para un rápido despliegue de nuevas VMs. Además nos permite personalizar estas VMs a través de plantillas de SOs editables, ahorrándonos el tiempo de hacer una instalación del SOs guest desde cero.

Esta herramienta es provista por el paquete ``libguestfs-tools-c`` y puede ser instalado corriendo el comando:

- Con ``apt``: ``sudo apt-get install -y libguestfs-tools``
- Con ``yum``: ``sudo yum install -y libguestfs-tools-c``

.. Note::

    Por defecto, ``virt-builder`` descarga plantillas de SOs del repositorio ``http://libguestfs.org/download/builder/``, siendo necesario conexión a Internet. Sin embargo, también es posible crear un repositorio local para ``virt-builder``.

Por ejemplo para crear una VM de Centos 7.0 con 10 GB ejecutaremos:

.. code-block:: bash

    $ cd /var/lib/libvirt/images
    $ sudo virt-builder centos-7.0 --format raw --size 10G

    [ 1.0] Downloading: http://libguestfs.org/download/builder/centos-7.0.xz
    [ 2.0] Planning how to build this image
    [ 2.0] Uncompressing
    [ 14.0] Resizing (using virt-resize) to expand the disk to 10.0G
    [ 149.0] Opening the new disk
    [ 179.0] Setting a random seed
    [ 180.0] Setting passwords
    virt-builder: Setting random password of root to Ldm43dKj12Msalp1x
    [ 198.0] Finishing off
        Output file: centos-7.0.img
        Output size: 10.0G
        Output format: raw
        Total usable space: 8.1G
        Free space: 7.3G

Primero descargó la plantilla, la descomprimió, redimensionó la imagen del disco para que calce al tamaño dado, sembró datos de la plantilla a la imagen, la edito (configuró una contraseña aleatoria) y finalizó. Se ha creado una contraseña de root aleatoria y usa un espacio de disco mínimo expandible hasta 10 GB. La imagen se almacena en el directorio ``/var/lib/libvirt/images``.

Luego, ingresar el siguiente comando para crear la VM con ``virt-install``:

.. code-block:: bash

    $ sudo virt-install --name centos --ram 1028 --vcpus=2 --disk path=/var/lib/libvirt/images/centos-7.0.img --import

Hay muchas opciones disponibles con ``virt-builder``: instalación de software, configuración de hostname, edición de archivos, etc.

``virt-builder`` almacena en caché la plantilla descargada en el directorio home del usuario actual con la siguiente ruta: ``$HOME/.cache/virt-builder``. Podemos imprimir la información del directorio caché, incluyendo que guest están en caché corriendo:

.. code-block:: bash

    $ virt-builder --print-cache

    cache directory: /root/.cache/virt-builder
    centos-6                x86_64      no
    centos-7.0              x86_64      cached
    centos-7.1              x86_64      no
    cirros-0.3.1            x86_64      no
    debian-6                x86_64      no
    # ...

CentOS 7 se encuentra en caché. a siguiente vez que creemos una VM con este SO usará la plantilla en caché y creará la VM aún más rápido.

- Eliminar caché: ``virt-builder --delete-cache``
- Descargar todas las plantillas a caché local: ``virt-builder --cache-all-templates``

.. Note::

    virt-builder solo soporta guest de Linux, no posee soporte para guest de Windows.

**Referencias**:

- `virt-builder - Ubuntu manpages`_
- `virt-builder - Fedora`_

.. _virt-builder - Ubuntu manpages: http://manpages.ubuntu.com/manpages/bionic/man1/virt-builder.1.html
.. _virt-builder - Fedora: https://developer.fedoraproject.org/tools/virt-builder/about.html