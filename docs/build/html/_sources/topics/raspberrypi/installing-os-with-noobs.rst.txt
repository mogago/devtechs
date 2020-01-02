Instalando un Sistema Operativo con NOOBS
=========================================

Links útiles:

- `Raspberry Pi Documentation`_
- `Installation`_: Installing an operating system on your Raspberry Pi
- `NOOBS Documentation`_

.. _Raspberry Pi Documentation: https://www.raspberrypi.org/documentation/ 
.. _Installation: https://www.raspberrypi.org/documentation/installation/
.. _NOOBS Documentation: https://www.raspberrypi.org/documentation/installation/noobs.md 

.. contents:: Table of Contents

Introducción
------------

La manera más sencilla de instalar un sistema operativo (SO) en el Raspberry Pi es a través de NOOBS.

**NOOBS (New Out Of Box Software)** es un administrador para la instalación de SOs en Raspberry Pi. Este software incluye los siguientes SOs:

- Raspbian
- LibreELEC
- OSMC
- Recalbox
- Lakka
- RISC OS
- Screenly OSE
- Windows 10 IoT Core
- TLXOS

Existen 2 versiones de NOOBS: la versión offline e instalación por red (NOOBS) y la versión únicamente de instalación por red (NOOBS Lite). La diferencia es que la versión offline tiene el SO Raspbian incluido. Instalar otro SO o instalar Raspbian con NOOBS Lite requiere que contemos con conexión a Internet.

Prerequisitos
-------------

- Una PC con Windows o Linux.
- Un Raspberry Pi con monitor, mouse, teclado y conexión a Internet (alámbrica o inalámbrica).
- Una tarjeta micro SD clase 4 o clase 10 vacía de 8GB o más de almacenamiento.

.. Danger::

    Se formateará la tarjeta, por lo que se perderán todos los archivos que estén guardados en la memoria.

- Un adaptador o lector de tarjetas micro SD que permita conectar la tarjeta a la computadora.

Objetivos
---------

- Aprender el funcionamiento básico de NOOBS.
- Instalar un sistema operativo en el Raspberry Pi usando NOOBS.

Obtener NOOBS
-------------

Se puede obtener NOOBS descargando el archivo correspondiente desde la `página de descargas de Raspberry Pi`_. Podrás elegir la versión de NOOBS que prefieras y descargarla. O puedes dirigirte directamente a las `versiones de NOOBS disponibles`_.

.. _página de descargas de Raspberry Pi: https://www.raspberrypi.org/downloads/
.. _versiones de NOOBS disponibles: https://www.raspberrypi.org/downloads/noobs/

En este tutorial descargaré el archivo ZIP de la versión NOOBS Lite. 

.. figure:: images/installing-os-with-noobs/noobs.png
    :align: center

    Versiones de NOOBS

Necesitarás una tarjeta micro SD de 8 GB o más de almacenamiento para guardar los archivos de instalación. Esta se deberá formatear como FAT o FAT32. En mi caso usaré una tarjeta de 16GB.

Para tarjetas micro SD de 64 GB o más de almacenamiento se deberá formatear exclusivamente como FAT32. Detalles: `formatting an SDXC card for use with NOOBS`_.

.. _formatting an SDXC card for use with NOOBS: https://www.raspberrypi.org/documentation/installation/sdxc_formatting.md

Formateo de tarjeta Micro SD (en Windows)
-----------------------------------------

.. Note::

    Procedimiento para sistemas operativos Windows

1. En Windows se puede usar el programa de formateo de la SD Association con el fin de formatear la tarjeta micro SD. Descarga e instala el programa **SD Card Formatter** (`Link de descarga de SD Card Formatter`_).
2. Una vez instalado el programa SD Card Formatter, ingresa la tarjeta micro SD en la lectora de la PC (si tu PC no tiene lectora micro SD puedes usar un adaptador de micro SD a SD o a USB  para que la PC lea la tarjeta).
3. Abre el programa SD Card Formatter y selecciona la unidad correspondiente a la tarjeta e ingrésale un nombre que la identifique en la sección *Volume label*. Dale clic en :guilabel:`Format` y espera que el proceso de formateo acabe.

.. _Link de descarga de SD Card Formatter: https://www.sdcard.org/downloads/formatter/

.. figure:: images/installing-os-with-noobs/sd-format-1.png
    :align: center

    SD Card Formatter - Formateo de la tarjeta SD - Paso 1

4. Confirma el mensaje de advertencia. Clic en :guilabel:`Sí`.

.. Danger::

    TODA TU INFORMACIÓN SERÁ BORRADA DE LA MEMORIA MICRO SD

.. figure:: images/installing-os-with-noobs/sd-format-2.png
    :align: center

    SD Card Formatter - Formateo de la tarjeta SD - Paso 2

5. Aparecerá un resumen con las nuevas propiedades de la tarjeta. Clic en :guilabel:`Aceptar`.

.. figure:: images/installing-os-with-noobs/sd-format-3.png
    :align: center

    SD Card Formatter - Formateo de la tarjeta SD - Paso 3

Formateo de tarjeta Micro SD (en Linux)
---------------------------------------

.. Note::

    Procedimiento para sistemas operativos Linux

Basado en: `NOOBS For Raspberry Pi (Rants and Raves)`_

.. _NOOBS For Raspberry Pi (Rants and Raves): http://qdosmsq.dunbar-it.co.uk/blog/2013/06/noobs-for-raspberry-pi/

1. En Linux, el primer paso será reconocer cuál es tu dispositivo micro SD en la PC. Corre el siguiente comando en un terminal (todavía no insertes tu memoria micro SD):

.. code-block:: bash

    $ sudo fdisk -l

Se listarán todos los dispositivos montados y no montados en la computadora. Luego insertar la memoria micro SD a la PC y ejecuta el mismo comando de nuevo. Compara los dos listados y ve qué dispositivo nuevo ha sido agregado. En mi caso es el siguiente:

.. code-block:: bash

    Disk /dev/sdb: 14,5 GiB, 15523119104 bytes, 30318592 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0xe72674a9

    Device     Boot Start      End  Sectors  Size Id Type
    /dev/sdb1        2048 30316543 30314496 14,5G  c W95 FAT32 (LBA)

2. Ahora que conocemos qué dispositivo es nuestra micro SD debemos borrar todas las particiones y archivos existentes dentro de ella. De esta forma, luego podremos crear la única partición que necesitamos. Para esto, usaremos la herramienta fdisk de esta forma:

.. code-block:: bash

    $ sudo fdisk /dev/{nombre_del_dispositivo}

Cambia ``{nombre_del_dispositivo}`` según tu caso. En mi caso, ejecutaré el comando: ``sudo fdisk /dev/sdb``

.. code-block:: bash

    $ sudo fdisk /dev/sdb

    Welcome to fdisk (util-linux 2.31.1).                              
    Changes will remain in memory only, until you decide to write them.
    Be careful before using the write command.


    Command (m for help):

3. Primero lista las particiones de tu tarjeta micro SD usando la opción :guilabel:`p`: 

.. code-block:: bash

    Command (m for help): p 
    Disk /dev/sdb: 14,5 GiB, 15523119104 bytes, 30318592 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0xe72674a9

    Device     Boot Start      End  Sectors  Size Id Type
    /dev/sdb1        2048 30316543 30314496 14,5G  c W95 FAT32 (LBA)

    Command (m for help):

4. Ahora, asegúrate de borrar cada partición que tenga tu tarjeta micro SD usando la opción :guilabel:`d`. Luego comprueba que ya no exista usando la opción :guilabel:`p` nuevamente:

.. Danger::

    TODA TU INFORMACIÓN SERÁ BORRADA DE LA MEMORIA MICRO SD

.. code-block:: bash

    Command (m for help): d
    Selected partition 1                                               
    Partition 1 has been deleted.                                      
                                                                    
    Command (m for help): p                                            
    Disk /dev/sdb: 14,5 GiB, 15523119104 bytes, 30318592 sectors       
    Units: sectors of 1 * 512 = 512 bytes                              
    Sector size (logical/physical): 512 bytes / 512 bytes              
    I/O size (minimum/optimal): 512 bytes / 512 bytes                  
    Disklabel type: dos                                                
    Disk identifier: 0xe72674a9                                        
                                                                    
    Command (m for help):

5. Seguido a esto crearemos una nueva partición usando la opción :guilabel:`n`. Presionar :guilabel:`Enter` a todas las opciones que aparezcan para que tomen los valores por defecto:

.. code-block:: bash

    Command (m for help): n
    Partition type
        p   primary (0 primary, 0 extended, 4 free)
        e   extended (container for logical partitions)
    Select (default p): p
    Partition number (1-4, default 1): 1
    First sector (2048-30318591, default 2048): 
    Last sector, +sectors or +size{K,M,G,T,P} (2048-30318591, default 30318591): 

    Created a new partition 1 of type 'Linux' and of size 14,5 GiB.
    Partition #1 contains a vfat signature.

    Do you want to remove the signature? [Y]es/[N]o: y

    The signature will be removed by a write command.

Obtendremos una nueva partición para nuestra tarjeta micro SD. Vuelve a comprobar con la opción :guilabel:`p`:

.. code-block:: bash

    Command (m for help): p       
    Disk /dev/sdb: 14,5 GiB, 15523119104 bytes, 30318592 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0xe72674a9

    Device     Boot Start      End  Sectors  Size Id Type
    /dev/sdb1        2048 30318591 30316544 14,5G 83 Linux

    Filesystem/RAID signature on partition 1 will be wiped.

6. Ahora cambiaremos el tipo de partición de Linux a FAT32. Para esto usaremos la opción :guilabel:`t`:

Si quieres listar todos los formatos disponibles, usa la opción :guilabel:`L` primero:

.. code-block:: bash    
    :emphasize-lines: 16

    Command (m for help): t
    Selected partition 1
    Hex code (type L to list all codes): L

    0  Empty           24  NEC DOS         81  Minix / old Lin bf  Solaris        
    1  FAT12           27  Hidden NTFS Win 82  Linux swap / So c1  DRDOS/sec (FAT-
    2  XENIX root      39  Plan 9          83  Linux           c4  DRDOS/sec (FAT-
    3  XENIX usr       3c  PartitionMagic  84  OS/2 hidden or  c6  DRDOS/sec (FAT-
    4  FAT16 <32M      40  Venix 80286     85  Linux extended  c7  Syrinx         
    5  Extended        41  PPC PReP Boot   86  NTFS volume set da  Non-FS data    
    6  FAT16           42  SFS             87  NTFS volume set db  CP/M / CTOS / .
    7  HPFS/NTFS/exFAT 4d  QNX4.x          88  Linux plaintext de  Dell Utility   
    8  AIX             4e  QNX4.x 2nd part 8e  Linux LVM       df  BootIt         
    9  AIX bootable    4f  QNX4.x 3rd part 93  Amoeba          e1  DOS access     
    a  OS/2 Boot Manag 50  OnTrack DM      94  Amoeba BBT      e3  DOS R/O        
    b  W95 FAT32       51  OnTrack DM6 Aux 9f  BSD/OS          e4  SpeedStor      
    c  W95 FAT32 (LBA) 52  CP/M            a0  IBM Thinkpad hi ea  Rufus alignment
    e  W95 FAT16 (LBA) 53  OnTrack DM6 Aux a5  FreeBSD         eb  BeOS fs        
    f  W95 Ext'd (LBA) 54  OnTrackDM6      a6  OpenBSD         ee  GPT            
    10  OPUS            55  EZ-Drive        a7  NeXTSTEP        ef  EFI (FAT-12/16/
    11  Hidden FAT12    56  Golden Bow      a8  Darwin UFS      f0  Linux/PA-RISC b
    12  Compaq diagnost 5c  Priam Edisk     a9  NetBSD          f1  SpeedStor      
    14  Hidden FAT16 <3 61  SpeedStor       ab  Darwin boot     f4  SpeedStor      
    16  Hidden FAT16    63  GNU HURD or Sys af  HFS / HFS+      f2  DOS secondary  
    17  Hidden HPFS/NTF 64  Novell Netware  b7  BSDI fs         fb  VMware VMFS    
    18  AST SmartSleep  65  Novell Netware  b8  BSDI swap       fc  VMware VMKCORE 
    1b  Hidden W95 FAT3 70  DiskSecure Mult bb  Boot Wizard hid fd  Linux raid auto
    1c  Hidden W95 FAT3 75  PC/IX           bc  Acronis FAT32 L fe  LANstep        
    1e  Hidden W95 FAT1 80  Old Minix       be  Solaris boot    ff  BBT            

Si no deseas listar las opciones de formato, usa directamente la opción :guilabel:`b` para transformar la partición a formato FAT32:

.. code-block:: bash

    Command (m for help): t
    Selected partition 1
    Hex code (type L to list all codes): b
    Changed type of partition 'Linux' to 'W95 FAT32'.

De nuevo, comprueba que todo esté correcto con la opción :guilabel:`p`:

.. code-block:: bash

    Command (m for help): p
    Disk /dev/sdb: 14,5 GiB, 15523119104 bytes, 30318592 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0xe72674a9

    Device     Boot Start      End  Sectors  Size Id Type
    /dev/sdb1        2048 30318591 30316544 14,5G  b W95 FAT32

    Filesystem/RAID signature on partition 1 will be wiped.

7. Para acabar con la configuración de la partición y escribirla en la tarjeta micro SD usar la opción :guilabel:`w`:

.. code-block:: bash

    Command (m for help): w
    The partition table has been altered.
    Calling ioctl() to re-read partition table.
    Syncing disks.

8. Ahora que tenemos la partición creada debemos formatearla, ya que, únicamente fdisk sabe que es del tipo FAT32. Para formatear la partición usar:

.. Note::

    No usar el nombre del dispositivo sino de la partición

.. code-block:: bash

    $ sudo mkfs.vfat /dev/{nombre_de_la_partición}

    $ sudo mkfs.vfat /dev/sdb1
    mkfs.fat 4.1 (2017-01-24)

Instalar NOOBS (Windows)
------------------------

Extraer el archivo ``.zip`` y copiar todos los archivos a la tarjeta micro SD formateada. ¡! Copia los archivos directamente en el directorio raíz de la tarjeta (por ejemplo ``D:/``).

.. figure:: images/installing-os-with-noobs/copying-noobs-windows.png
    :align: center

    Copiar contenidos de NOOBS a la tarjeta micro SD

Instalar NOOBS (Linux, con interfaz gráfica)
--------------------------------------------

En primer lugar, saca la tarjeta micro SD de la PC y vuelve a insertarla para montarla en el sistema. Seguramente te aparezca un aviso para abrir el dispositivo con el navegador de archivos; de ser así, hazlo. Descomprime el archivo ``.zip`` de NOOBS descargado y copia todos los archivos directamente a la tarjeta micro SD.

.. figure:: images/installing-os-with-noobs/copying-noobs-linux.png
    :align: center

    Copiar contenidos de NOOBS a la tarjeta micro SD

Instalar NOOBS (Linux, con línea de comandos)
---------------------------------------------

1. En primer lugar, saca la tarjeta micro SD de la PC y vuelve a insertarla para montarla en el sistema. Para comprobar donde está montada la partición usar: 

.. code-block:: bash

    $ mount | grep -i /dev/{nombre_de_la_partición}
    $ mount | grep -i /dev/sdb1

2. Cambia a la ruta donde está montado tu partición y descomprime el archivo .zip de NOOBS descargado:

.. code-block:: bash

    $ cd /media/{ruta_de_la_partición_montada}
    $ unzip ~/Downloads/NOOBS_lite_v3_2.zip

3. Por último, desmonta la tarjeta micro SD con: 

.. code-block:: bash

    $ sudo umount /dev/{nombre_de_la_partición}

Instalar un SO usando NOOBS
---------------------------

1. Expulsa la tarjeta micro SD de la PC. Luego inserta la tarjeta micro SD al Raspberry Pi y encenderlo. En el primer arranque, se creará un partición llamada "RECOVERY". En ella se guardarán las distribuciones y archivos para el proceso de recuperación.
2. Una vez dentro de NOOBS, si no cuentas con una conexión cableada Ethernet a la que puedas conectar tu Raspberry, conéctate usando una red WiFi disponible.

.. figure:: images/installing-os-with-noobs/installing-os-with-noobs-1.png
    :align: center

    Proceso de instalación de un SO con NOOBS

Una vez cuentes con conexión a Internet puede seguir con el tutorial.

3. En la pantalla se verá todos los sistemas operativos que pueden ser instalados en la tarjeta micro SD. También puedes cambiar el idioma y teclado que se muestra. Selecciona el (o los) sistema(s) operativo(s) que desees instalar.

.. figure:: images/installing-os-with-noobs/installing-os-with-noobs-2.png
    :align: center

    Proceso de instalación de un SO con NOOBS

.. figure:: images/installing-os-with-noobs/installing-os-with-noobs-3.png
    :align: center

    Proceso de instalación de un SO con NOOBS

4. Una vez selecciones el sistema operativo que desees, que en mi caso es Raspbian Full, dale clic en el botón Install.

.. figure:: images/installing-os-with-noobs/installing-os-with-noobs-4.png
    :align: center

    Proceso de instalación de un SO con NOOBS

5. Acepta el mensaje de confirmación. Seguido a esto, comenzará la descarga del sistema operativo y su instalación.

.. figure:: images/installing-os-with-noobs/installing-os-with-noobs-5.png
    :align: center

    Proceso de instalación de un SO con NOOBS

.. figure:: images/installing-os-with-noobs/installing-os-with-noobs-6.png
    :align: center

    Proceso de instalación de un SO con NOOBS

6. Al acabar la instalación del sistema operativo acepta el mensaje de confirmación.

.. figure:: images/installing-os-with-noobs/installing-os-with-noobs-7.png
    :align: center

    Proceso de instalación de un SO con NOOBS

7. El Raspberry Pi reiniciará automáticamente y ahora arrancará con el sistema operativo que hemos instalado.

.. figure:: images/installing-os-with-noobs/installing-os-with-noobs-8.png
    :align: center

    Proceso de instalación de un SO con NOOBS
