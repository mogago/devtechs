.. _newdiskdd:

======================================
Creando una imagen de disco con ``dd``
======================================

``dd`` es una herramienta para convertir y copiar archivos.

En SOs Unix-like, drivers de dispositivos para hardware (como discos duros) y archivos de dispositivos especiales (como ``/dev/zero`` o ``/dev/random``) aparecen en el filesystem como archivos normales. ``dd`` puede leer y/o escribir desde/en esos archivos, siempre que la función se implemente en su driver respectivo.

Gracias a este funcionamiento, ``dd`` puede usarse para tareas como respaldar del sector de arranque de un disco duro, obtener una cantidad fija de datos aleatorios. También se puede realizar conversiones de datos según son copiados.

Por defecto, ``dd`` lee de un archivo input file (``if``) y escribe en un output file (``of``). Un **bloque (block)** es la unidad de medida de bytes que son leídos y escritos o convertidos de una sola vez; para especificar el tamaño del bloque se usa la opción ``bs``.

En este caso se usará ``dd`` para crear una imagen de disco vacía desde el directorio ``/dev/zero``:

- Creando un disco preallocated:

.. code-block:: bash

    $ dd if=/dev/zero of=disk1.img bs=1G count=10

    0+0 records in
    10+0 records out
    10737418240 bytes (11 GB, 10 GiB) copied, 27,016 s, 397 MB/s

    $ qemu-img info disk1.img
    image: disk1.img
    file format: raw
    virtual size: 10G (10737418240 bytes)
    disk size: 10G

- Creando un disco thin-provisioned:

Con la opción ``seek`` logramos que la imagen de disco creada sea thin-provisioned.

.. code-block:: bash

    $ dd if=/dev/zero of=disk2.img bs=1G seek=10 count=0

    0+0 records in
    0+0 records out
    0 bytes copied, 0,000124988 s, 0,0 kB/s

    $ qemu-img info disk2.img
    image: disk2.img
    file format: raw
    virtual size: 10G (10737418240 bytes)
    disk size: 0

Referencias
-----------

- `dd (Unix) - Wikipedia`_

.. _`dd (Unix) - Wikipedia`: https://en.wikipedia.org/wiki/Dd_(Unix)