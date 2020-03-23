PXE + Kickstart
===============

.. contents:: Table of Contents  

Documentación para habilitar el uso de un archivo Kickstart en un arranque e instalación de sistema operativo CentOS 7 por PXE. La función del archivo Kickstart será automatizar todo el proceso de instalación de CentOS 7 según los parámetros definidos, logrando un sistema operativo personalizado.

Esta documentación requiere haber realizado los pasos de la documentación previa para habilitar un servidor PXE: :ref:`pxeinstall`

Creación del archivo Kickstart
------------------------------

El archivo Kickstart será pasado al cliente PXE través de FTP, por tanto debemos crear el archivo kickstart en el directorio público de FTP:

.. code-block:: bash

    $ sudo vi /var/ftp/pub/centos7/centos7-ks.cfg

.. code-block:: cfg

    install
    url --url="ftp://192.168.8.8/pub/centos7"
    bootloader --location=mbr
    keyboard --vckeymap=latam --xlayouts='latam','us'
    rootpw --iscrypted $1$WUDGBrnr$Bq8p.jk4ikcEr2JYJRMwE0
    lang en_US.UTF-8 --addsupport=es_US.UTF-8
    clearpart --all --initlabel
    part / --fstype="ext4" --grow --ondisk=sda --size=1
    timezone America/Lima
    text
    reboot

    %packages
    %end

Podemos personalizar nuestro archivo Kickstart según nuestras preferencias. Podemos guiarnos de las siguientes plantillas: :ref:`kstemplates1`

.. Note::

    Verificar el nombre con el cual son creados los discos, para planear las particiones. En VirtualBox los discos se crean con el formato de nombre ``sdx`` (``--ondisk=sda``), pero en virt-manager los discos se crean con el formato de nombre ``vdx`` (``--ondisk=vda``). (x=a,b,c,d,...)

Edición del menú PXE boot
-------------------------

- Para clientes con sistemas basados en BIOS:

.. code-block:: bash

    $ sudo vi /var/lib/tftpboot/pxelinux.cfg/default

Editar la línea de append, agregando la ruta de kickstart:

.. code-block:: cfg

    default menu.c32
    prompt 0
    timeout 30
    menu title PXE Boot CentOS 7
    label Instalar CentOS 7 (Minimal)
    kernel /networkboot/centos7/vmlinuz
    append initrd=/networkboot/centos7/initrd.img inst.repo=ftp://192.168.8.8/pub/centos7 ks=ftp://192.168.8.8/pub/centos7/centos7-ks.cfg

- Para clientes con sistemas basados en UEFI:

.. code-block:: bash

    $ sudo vi /var/lib/tftpboot/grub.cfg

.. code-block:: cfg

    set timeout=60

    menuentry 'Instalar CentOS 7 (Minimal)' {
            linuxefi /networkboot/centos7/vmlinuz inst.repo=ftp://192.168.8.8/pub/centos7/ inst.ks=ftp://192.168.8.8/pub/centos7/centos7-ks.cfg
            initrdefi /networkboot/centos7/initrd.img
    }

Reiniciar los servicios
-----------------------

Finalmente, reiniciamos los servicios de DHCP, TFTP y FTP:

.. code-block:: bash

    $ ./restart_pxe_services.sh

Instalación de CentOS 7 usando PXE + Kickstart
----------------------------------------------

El último paso será arrancar una VM como PXE client, tal como se realizó en la documentación previa: :ref:`pxecentosinstaller`. La diferencia es que ahora pasaremos un archivo Kickstart para automatizar la instalación del sistema operativo CentOS 7:

.. raw:: html

    <div style="text-align: center; margin-bottom: 2em;">
    <iframe width="100%" height="350" src="https://www.youtube.com/embed/w8xb5fPK_W0?rel=0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
    </div>

.. Note::

    En el archivo Kickstart hemos usado el parámetro ``text``, con el fin de que la instalación no se realice en forma gráfica sino mostrando solo texto.
