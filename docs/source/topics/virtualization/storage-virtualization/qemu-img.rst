.. _qemuimg:

Imágenes de disco con ``qemu-img``
==================================

.. contents:: Table of Contents

``qemu-img`` es una herramienta de QEMU para crear, convertir y administrar imágenes de disco de forma offlline. Soporta todos los formatos que usa QEMU.

.. Warning::

    No usar ``qemu-img`` para modificar imágenes si están siendo usadas por una VM u otro proceso, pues dañaría la imagen.

Tipos de imágenes
-----------------

QEMU soporta diversos tipos de imágenes, siendo **qcow2** el nativo y más flexible. Qcow2 soporta copy on write, encriptación, compresión y snapshots de VMs.

Algunos de los formatos máx comúnes son:

- **raw**: el formato raw es una imagen binaria plana de una images de disco y es muy portable. El filesystems que soportan *sparse files*, las imágenes en este formato solo usan el espacio usado por los datos grabados en ella.
- **cow**: el formato copy-on-write solo es soportado por razones históricas.
- **qcow**: el antiguo formato **QEMU copy-on-write**, también es soportado por razones históricas.
- **qcow2**: formato **QEMU copy-on-write** con distintos features especiales: tomar múltiples snapshots, imágenes pequeñas en el filesystem que no soportan sparse files, encriptación AES opcional y compresión zlib opcional.
- **vmdk**: formato de imagen de VMware
- **vdi**: formato de imagen de VirtuaBox
- **vhdx**: formato de imagen de Hyper-V
- **vpc**: formato de imagen legacy de Hyper-V

.. Note::

    Formatos soportados por ``qemu-img``:
    
    .. code-block:: bash

        $ qemu-img --help | grep Supported
        Supported formats: blkdebug blkreplay blkverify bochs cloop dmg file ftp ftps 
        host_cdrom host_device http https iscsi iser luks nbd null-aio null-co parallels 
        qcow qcow2 qed quorum raw rbd replication sheepdog throttle vdi vhdx vmdk vpc vvfat



Crear una imagen
----------------

Con el comando ``qemu-img`` de QEMU podemos crear un imagen de disco vacía donde podremos almacenar nuestro SO guest.

- Por defecto, el parámetro ``create`` de ``qemu-img`` creará una imagen con formato raw:

.. code-block:: bash

    $ qemu-img create disk1.img 1G

Se ha creado una imagen de disco con formato raw de ``1G`` de tamaño con el nombre ``disk1.img``.

- Podemos especificar que use el formato nativo de QEMU (``qcow2``) con el parámetro ``-f``:

.. code-block:: bash

    $ qemu-img create -f qcow2 disk2.qcow2 1G

Se ha creado una imagen de disco con formato qcow2 de ``1G`` de tamaño con el nombre ``disk2.img``.

Obtener información de una imagen
---------------------------------

Para ver los datos de una imagen de disco podemos usar la opción ``info`` del comando ``qemu-img``:

.. code-block:: bash

    $ qemu-img info disk1.img

    image: disk1.img
    file format: raw
    virtual size: 1.0G (1073741824 bytes)
    disk size: 0

.. code-block:: bash

    $ qemu-img info disk2.img 

    image: disk2.img
    file format: qcow2
    virtual size: 1.0G (1073741824 bytes)
    disk size: 196K
    cluster_size: 65536
    Format specific information:
        compat: 1.1
        lazy refcounts: false
        refcount bits: 16
        corrupt: false

Convertir formato de imagen
---------------------------

Podemos realizar conversión del formato de imágenes con la opción ``convert`` del comando ``qemu-img`` junto con los parámetros ``-f``, que indica el formato del archivo de entrada y ``-O``, que indica el formato del archivo de salida.

- Convertir una imagen de formato ``raw`` a ``qcow2``:

.. code-block:: bash

    $ qemu-img convert -f raw -O qcow2 disk1.img disk1converted.qcow2

    $ qemu-img info disk1converted.qcow2
    image: disk1converted.qcow2
    file format: qcow2
    virtual size: 1.0G (1073741824 bytes)
    disk size: 196K
    cluster_size: 65536
    Format specific information:
        compat: 1.1
        lazy refcounts: false
        refcount bits: 16
        corrupt: false

- Convertir una imagen de formato ``qcow2`` a ``raw``:

.. code-block:: bash

    $ qemu-img convert -f qcow2 -O raw disk2.qcow2 disk2converted.img

    $ qemu-img info disk2converted.img
    image: disk2converted.img
    file format: raw
    virtual size: 1.0G (1073741824 bytes)
    disk size: 0

Recortar y comprimir imágenes
-----------------------------

Podemos decrementar el tamaño de imágenes con formato qcow2 gracias a la opción ``convert`` del comando ``qemu-img``. Durante la conversión de imagen, los sectores vacios son detectados y suprimidos de la imagen destino.

- Recortar una imagen qcow2 sin compresión (archivo más grande, menor tiempo de procesamiento)

.. code-block:: bash

    $ sudo qemu-img convert -O qcow2 source.qcow2 shrunk.qcow2

- Recortar una imagen qcow2 con compresión (``-c``) (archivo más pequeño, mayor tiempo de procesamiento)

.. code-block:: bash

    $ sudo qemu-img convert -O qcow2 -c source.qcow2 shrunk.qcow2

Referencias
-----------

- `qemu-img - Manpage Debian`_
- `qemu-img - Wikibooks`_
- `Convert qcow2 to raw image and raw to qcow2 image`_
- `How to shrink OpenStack qcow2 image using qemu-img`_

.. _qemu-img - Manpage Debian: https://manpages.debian.org/testing/qemu-utils/qemu-img.1.en.html
.. _qemu-img - Wikibooks: https://en.wikibooks.org/wiki/QEMU/Images#Creating_an_image
.. _Convert qcow2 to raw image and raw to qcow2 image: http://www.tuxfixer.com/convert-qcow2-to-raw-image-raw-to-qcow2-image/
.. _How to shrink OpenStack qcow2 image using qemu-img: http://www.tuxfixer.com/how-to-shrink-openstack-qcow2-image-with-qemu-img/