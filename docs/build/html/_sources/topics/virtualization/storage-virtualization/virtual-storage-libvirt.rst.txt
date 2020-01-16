Almacenamiento virtual con Libvirt
==================================

.. contents:: Table of Contents

El almacenamiento virtual es abstraído del almacenamiento físico y es asignado a una VM. El almacenamiento es conectado a una VM usando drivers block device emulados o paravirtualizados.

Hay 2 conceptos básicos en la virtualización del almacenamiento: pools y volúmenes. Un **pool de almacenamiento** es una cantidad de almacenamiento reservado para uso de VMs. Los pools de almacenamiento son divididos en volúmenes de almacenamiento. Cada **volumen de almacenamiento** es asignado a una VM guest como un **block device** en un **bus guest**.

Los pools de almacenamiento son administrados usando ``libvirt``. La API de ``libvirt`` puede usarse para consultar la lista de volúmenes dentro de un pool de almacenamiento u obtener información sobre la capcacidad, asignación y almacenamiento disponible en el pool. También podemos consulatar información sobre la capacidad y asignación de un volumen que podrían ser diferentes si se trata de **volúmenes sparse (thin-provisioning)**.

Para pools de almacenamiento soportado, la API de ``libvirt`` puede emplearse para crear, clonar, redimensionar y eliminar volúmenes. También podemos subir, descargar o limpiar datos de volúmenes de almacenamiento. Una vez que un pool es iniciado, el volumen puede ser asignado a un guest usando el nombre del pool y del volumen en lugar de la ruta del host al volumen en el XML del dominio.

.. Important::

    Los pools de almacenamiento pueden ser parados (destroyed), removiendo la abstracción de los datos, pero manteniendo los datos intactos.

Procedimiento para la creación y asignación de almacenamiento
-------------------------------------------------------------

1. Crear pools de almacenamiento. Referencia: :ref:`poolswithlibvirt`
2. Crear volúmenes de almacenamiento. Referencia: :ref:`volumeswithlibvirt`
    
    - Creación de volúmenes con: :ref:`volumeswithlibvirt`
    - Creación de imágenes de disco con: :ref:`qemuimg`
    - Creación de imágenes de disco con: :ref:`newdiskdd`

3. Asignar dispositivos de almacenamiento a VMs. Referencia: :ref:`addstorageguests`

Teoría de almacenamiento virtualizado
-------------------------------------

El almacenamiento virtualizado suele dividir en dos tipos:

- **Unmanaged storage**: almacenamiento que no es controlado ni monitoreado directamente por ``libvirt`` y es usado con VMs. Es decir, usar cualquier archivo o bloque disponible en el sistema host como un disco virtual.
- **Managed storage**: almacenamiento controlado y monitoreado por ``libvirt`` en términos de pools y volúmenes de almacenamiento.

Discos virtuales
''''''''''''''''

Los discos usados para almacenamiento virtual y que son asignados a las VMs son llamados **discos virtuales**. Estos pueden ser de 2 tipos:

- **Preallocated**: un disco virtual preallocated tiene almacenamiento reservado del mismo tamaño que el disco virtual. Al momento de la creación del disco, se asigna todo el espacio requerido y se presenta a la VM sin una capa adicional en medio. Gracias a esto, el rendimiento es mejor que un disco thin-provisioned, pues no requiere asignación de almacenamiento extra durante su uso.
- **Thin-provisioned**: el espacio será asignado al volumen según se necesite. Esto nos permite realizar un overcommitment (sobre-dimensionamiento), bajo la suposición que que todos los discos no serán usados, permitiendo una asignación del recurso de almacenamiento más optimizada. El rendimiento en cargas intensivas de I/O, sin embargo, no es tan bueno como el de un disco pre-allocated.

**Información útil:**

* Para ver la creación de los 2 tipos de discos virtuales con el comando ``dd`` ir a: :ref:`newdiskdd`
* Para identificar qué método de asignación usa cierto disco virtual usar ``qemu-img info``. Más info: :ref:`qemuimg`
* Más información sobre la comparación de discos virtuales preallocated y thin-provisioned: `Understanding Virtual Disks - Red Hat Documentation`_

**Comparemos dos disco virtuales:**

El parámetro ``info`` del comando ``qemu-img`` muestra información sobre una imagen de disco virtual, incluyendo su ruta absoluta, formato de archivo, tamaño virtual y tamaño de disco. Mirando el tamaño de disco y el tamaño virtual, uno puede identificar qué política de asignación de disco está en uso. Veamos la información de los dos discos virtuales que creamos:

.. code-block:: bash

    $ sudo qemu-img info /var/lib/libvirt/images/preallocated-disk.img

    image: /var/lib/libvirt/images/preallocated-disk.img
    file format: raw
    virtual size: 10G (10737418240 bytes)
    disk size: 10G

    $ sudo qemu-img info /var/lib/libvirt/images/thinprovisioned-disk.img

    image: /var/lib/libvirt/images/thinprovisioned-disk.img
    file format: raw
    virtual size: 10G (10737418240 bytes)
    disk size: 0

Comparemos el parámetro ``disk size`` de cada disco. Nos muestra 10G para ``preallocated-disk.img``, mientras que para ``thinprovisioned-disk.img`` es ``0``. La diferencia es porque el segundo disco usa un formato thin-provisioned.

- ``virtual size``: espacio que el guest observa
- ``disk size``: espacio reservado en el host

Si ``virtual size`` es igual a ``disk size``, entonces el disco es preallocated. Si son diferentes el formato del disco es thin-provisioned.

Referencias
-----------

- `MANAGING STORAGE FOR VIRTUAL MACHINES - Red Hat Documentation`_
- `Understanding Virtual Disks - Red Hat Documentation`_

.. _Understanding Virtual Disks - Red Hat Documentation: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Virtualization/3.3/html/Administration_Guide/Understanding_virtual_disks.html
.. _MANAGING STORAGE FOR VIRTUAL MACHINES - Red Hat Documentation: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/chap-managing_virtual_storage