Despliegue automatizado de VMs con ``oz``
=========================================

.. contents:: Table of Contents

Introducción a ``oz``
---------------------

``oz`` es un conjunto de programas útiles para crear VMs **JEOS (Just Enough Operating System)** con una mínima entrada del guest. La entrada mínima por parte del usuario será: nombre del guest y detalles de SO como arquitectura, URL para el OS tree o ISO y contraseña root. Todos estos atributos pueden definirse en un archivo XML simple llamado `TDL (Template Definition Language)`_.


La plantilla TDL empleada contendrá los siguientes parámetros:

- La ISO o URI en la que la imagen estará basada
- Tamaño de disco
- Los paquetes extra a instalar
- Los comandos a ejecutar luego de que la imagen es creada
- Los archivos a ser introducidos luego de que la imagen es creada

En resumen, el archivo TDL describe al SO que el usuario quiere instalar, de dónde obtener el medio de instalación y cualquier paquete adicional o acción que el usuario desee se realice en el SO. Ver `ejemplos de TDL y usos`_.

Con este grupo de herramientas es posible instalar una variedad de SOs. A bajo nivel usa componentes de infraestructura de virtualización conocidos como ``qemu/kvm``, ``libvirt`` y ``libguestfs``. Para la instalación de SOs se emplean un conjunto de archivos predefinidos **kickstart** para sistemas basados en Red Hat, archivos **preseed** para sistemas basados en Debian y archivos **XML** para instalaciones de Windows automatizadas.

Las imágenes del SO compatible con ``oz`` debe estar diseñado para una arquitectura de CPU **i386** o **x86_64**. Y puede ser Debian, Fedora, FreeBSD, Mandrake, OpenSUSE, RHEL, CentOS, Ubuntu y Windows.

.. code-block:: bash

    $ oz-install -h

    Currently supported architectures are:
        i386, x86_64
    Currently supported operating systems are:
        Debian: 5, 6, 7, 8
        Fedora Core: 1, 2, 3, 4, 5, 6
        Fedora: 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26
        FreeBSD: 10, 11
        Mageia: 2, 3, 4, 4.1, 5
        Mandrake: 8.2, 9.0, 9.1, 9.2, 10.0, 10.1
        Mandriva: 2005, 2006.0, 2007.0, 2008.0
        OpenSUSE: 10.3, 11.0, 11.1, 11.2, 11.3, 11.4, 12.1, 12.2, 12.3, 13.1, 13.2, 42.1, 42.2
        RHEL 2.1: GOLD, U2, U3, U4, U5, U6
        RHEL 7: Beta, 0, 1, 2
        RHEL/CentOS 3: GOLD, U1, U2, U3, U4, U5, U6, U7, U8, U9
        RHEL/CentOS/Scientific Linux 4: GOLD, U1, U2, U3, U4, U5, U6, U7, U8, U9
        RHEL/OL/CentOS/Scientific Linux{,CERN} 5: GOLD, U1, U2, U3, U4, U5, U6, U7, U8, U9, U10, U11
        RHEL/OL/CentOS/Scientific Linux{,CERN} 6: 0, 1, 2, 3, 4, 5, 6, 7, 8
        RHL: 7.0, 7.1, 7.2, 7.3, 8, 9
        Ubuntu: 5.04, 5.10, 6.06[.1,.2], 6.10, 7.04, 7.10, 8.04[.1,.2,.3,.4], 8.10, 9.04, 9.10, 10.04[.1,.2,.3], 10.10, 11.04, 11.10, 12.04[.1,.2,.3,.4,.5], 12.10, 13.04, 13.10, 14.04[.1,.2,.3,.4,.5], 14.10, 15.04, 15.10, 16.04[.1], 16.10, 17.04
        Windows: 2000, XP, 2003, 7, 2008, 2012, 8, 8.1, 2016, 10

Para comenzar a usar ``oz`` con el fin de crear VMs y desplegarlas de forma automatizada sigamos los siguientes pasos:

Usando ``oz``
-------------

1. Instalar ``oz``:

- Con ``apt``: ``sudo apt-get install oz``
- Con ``yum``: ``sudo yum install -y oz``

2. Obtener un archivo ISO (local, HTTP, FTP) con el medio de instalación del SO deseado o una URL con el tree OS para obtener el SO a través de Internet.
3. Crear nuestro archivo TDL (formato ``.tdl``) con la descripción personalizada del SO que vamos a instalar:

.. code-block:: xml

    <template>
    <name>centos7</name>
    <os>
        <name>CentOS-7</name>
        <version>7</version>
        <arch>x86_64</arch>
        <install type='iso'>
            <iso>http://mirror.unimagdalena.edu.co/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-Minimal-1908.iso</iso>
        </install>
    </os>
    <description>CentOS 7 x86_64 template</description>
    </template>

- ``/template/name`` es un nombre definido por el usuario. Puede ser cualquiera pero debe ser único entre todos los TDLs que deseemos construir.
- ``/template/os/name``, ``/template/os/version`` y ``/template/os/arch`` es el nombre, versión y arquitectura del SO que deseamos instalar, respectivamente.
- ``/template/os/install`` le dice a ``oz`` de dónde obtener el medio de instalación. En este caso usamos un archivo ``iso``, entonces necesitamos un elemento ISO en el archivo XML apuntando al medio de instalación ISO.
- ``/template/description`` es un parámetro  opcional que describe esta plantilla

4. Una vez hayamos guardado nuestro archivo ``.tdl`` ejecutaremos el sigueinte comando:

.. code-block:: bash

    # sudo oz-install /path/to/tdl-file.tdl
    $ sudo oz-install -u -d3 ~/Downloads/my-centos7-template.tdl

Sintáxis:

- ``-u``: Customize  the  image after installation.  This generally installs additional packages onto the  disk  image  after installation.
- ``-d``: loglevel. Turn on debugging output to level loglevel.  Log levels:
    - 0 - errors only (this is the default)
    - 1 - errors and warnings
    - 2 - errors, warnings, and information
    - 3 - all messages
    - 4 - all messages, prepended with the level and classname

Si hemos corrido ``oz-install`` con el modo de debugueo (``-d``) y con valor ``3`` veremos todo el log del proceso (`Log de oz-install`_):

- Primero descargará el archivo ``.iso`` que hemos especificado en la URL. La dirección de descarga por defecto será ``/var/lib/oz/isos/``.
- Luego comenzará a escanear los archivos que tiene el instalador
- Comenzará el proceso de instalación. Ahora podremos ver el porcentaje de avance.
- Luego se genera imagen de disco bajo la ruta /var/lib/libvirt/image con formato ``.dsk``.
- También se habrá creado el archivo XML que puede usarse para iniciar el guest inmediatamente.

5. El archivo XML creado estará en el mismo directorio donde está nuestra plantilla TDL. Usar el archivo XML para definir el guest (``virsh define``) y crear la VM (``virsh start``):

.. code-block:: bash

    # virsh define <XML-file>
    $ virsh define centos7Jan_09_2020-18\:19\:42
    
    Domain centos7 defined from centos7Jan_09_2020-18:19:42

    # virsh start <domain>
    $ virsh start centos7

6. Abrir una consola de nuestra VM con ``virt-viewer`` o ``virt-manager``:

.. code-block:: bash

    $ virt-viewer centos7

Archivo de configuración de ``oz``
----------------------------------

El archivo ``/etc/oz/oz.cfg`` es el archivo de configuración de ``oz`` para la creación de VMs. El contenido por defecto es el siguiente:

.. code-block:: cfg

    [paths]
    output_dir = /var/lib/libvirt/images
    data_dir = /var/lib/oz
    screenshot_dir = /var/lib/oz/screenshots
    # sshprivkey = /etc/oz/id_rsa-icicle-gen

    [libvirt]
    uri = qemu:///system
    image_type = raw
    # type = kvm
    # bridge_name = virbr0
    # cpus = 1
    # memory = 1024

    [cache]
    original_media = yes
    modified_media = no
    jeos = no

    [icicle]
    safe_generation = no

    [timeouts]
    install = 1200
    inactivity = 300
    boot = 300
    shutdown = 90

Como vemos, aquí podemos establecer varios parámetros de configuración para la creación de VMs. Algunos importantes son:

- ``output_dir``: ruta de almancenamiento de las imágenes posterior a su creación. (``/var/lib/libvirt/images`` por defecto).
- ``bridge_name``: bridge al cual se conectará la VM (``vibr0`` por defecto).
- ``cpus``: cantidad de CPUs asignados a la VM
- ``memoria``: memoria RAM asignada a la VM

El resto de directivas las podemos encontrar en `oz-customize`_.

Referencias
-----------

- `TDL (Template Definition Language)`_
- `ejemplos de TDL y usos`_
- `Download CentOS Linux ISO images`_
- `VM template creation with oz-install (with preseed)`_
- `Using OZ tool to create virtual guests (with minimal input)`_
- `oz-customize`_

.. _TDL (Template Definition Language): https://github.com/clalancette/oz/wiki/Oz-template-description-language
.. _ejemplos de TDL y usos: https://github.com/clalancette/oz/wiki/oz-examples
.. _Download CentOS Linux ISO images: https://wiki.centos.org/Download
.. _VM template creation with oz-install (with preseed): https://www.leaseweb.com/labs/2013/12/vm-template-creation-oz-install/
.. _Using OZ tool to create virtual guests (with minimal input): https://kashyapc.wordpress.com/2011/08/09/using-oz-tool-to-create-virtual-guests-with-minimal-input/
.. _oz-customize: https://github.com/clalancette/oz/wiki/oz-customize

Log de oz-install
-----------------

::

    $ sudo oz-install -u -d3 ~/Downloads/my-centos7-template.tdl

    Libvirt network without a forward element, skipping
    libvirt bridge name is virbr0
    Libvirt type is kvm
    Name: centos7, UUID: 50507349-dbd5-4fc5-8c54-7d6e6ea42de6
    MAC: 52:54:00:89:09:e6, distro: CentOS-7
    update: 7, arch: x86_64, diskimage: /var/lib/libvirt/images/centos7.dsk
    nicmodel: virtio, clockoffset: utc
    mousetype: ps2, disk_bus: virtio, disk_dev: vda
    icicletmp: /var/lib/oz/icicletmp/centos7, listen_port: 44993
    console_listen_port: 36931
    Original ISO path: /var/lib/oz/isos/CentOS-77x86_64-iso.iso
    Modified ISO cache: /var/lib/oz/isos/CentOS-77x86_64-iso-oz.iso
    Output ISO path: /var/lib/libvirt/images/centos7-iso-oz.iso
    ISO content path: /var/lib/oz/isocontent/centos7-iso
    Checking for guest conflicts with centos7
    Generating install media
    Fetching the original media
    Starting new HTTP connection (1): mirror.unimagdalena.edu.co:80
    http://mirror.unimagdalena.edu.co:80 "POST /centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-Minimal-1908.iso HTTP/1.1" 200 987758592
    Fetching the original install media from http://mirror.unimagdalena.edu.co/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-Minimal-1908.iso
    Starting new HTTP connection (1): mirror.unimagdalena.edu.co:80
    http://mirror.unimagdalena.edu.co:80 "GET /centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-Minimal-1908.iso HTTP/1.1" 200 987758592
    10240kB of 964608kB
    20480kB of 964608kB
    #..............
    962560kB of 964608kB
    964608kB of 964608kB
    Copying ISO contents for modification
    Setting up guestfs handle for centos7
    Adding ISO image /var/lib/oz/isos/CentOS-77x86_64-iso.iso
    Launching guestfs
    Mounting ISO
    Checking if there is enough space on the filesystem
    Extracting ISO contents
    Putting the kickstart in place
    Modifying isolinux.cfg
    Generating new ISO
    I: -input-charset not specified, using utf-8 (detected in locale settings)

    genisoimage 1.1.11 (Linux)
    Scanning /var/lib/oz/isocontent/centos7-iso
    Scanning /var/lib/oz/isocontent/centos7-iso/Packages
    Excluded: /var/lib/oz/isocontent/centos7-iso/Packages/TRANS.TBL
    Excluded: /var/lib/oz/isocontent/centos7-iso/TRANS.TBL
    Scanning /var/lib/oz/isocontent/centos7-iso/EFI
    Excluded: /var/lib/oz/isocontent/centos7-iso/EFI/TRANS.TBL
    Scanning /var/lib/oz/isocontent/centos7-iso/EFI/BOOT
    Excluded: /var/lib/oz/isocontent/centos7-iso/EFI/BOOT/TRANS.TBL
    Scanning /var/lib/oz/isocontent/centos7-iso/EFI/BOOT/fonts
    Excluded: /var/lib/oz/isocontent/centos7-iso/EFI/BOOT/fonts/TRANS.TBL
    Scanning /var/lib/oz/isocontent/centos7-iso/isolinux
    Excluded: /var/lib/oz/isocontent/centos7-iso/isolinux/TRANS.TBL
    Excluded by match: /var/lib/oz/isocontent/centos7-iso/isolinux/boot.cat
    Scanning /var/lib/oz/isocontent/centos7-iso/repodata
    Excluded: /var/lib/oz/isocontent/centos7-iso/repodata/TRANS.TBL
    Scanning /var/lib/oz/isocontent/centos7-iso/LiveOS
    Excluded: /var/lib/oz/isocontent/centos7-iso/LiveOS/TRANS.TBL
    Scanning /var/lib/oz/isocontent/centos7-iso/images
    Excluded: /var/lib/oz/isocontent/centos7-iso/images/TRANS.TBL
    Scanning /var/lib/oz/isocontent/centos7-iso/images/pxeboot
    Excluded: /var/lib/oz/isocontent/centos7-iso/images/pxeboot/TRANS.TBL
    Using RPM_G000.;1 for  /RPM-GPG-KEY-CentOS-Testing-7 (RPM-GPG-KEY-CentOS-7)
    Using PYTHO000.RPM;1 for  /var/lib/oz/isocontent/centos7-iso/Packages/python-pyudev-0.15-9.el7.noarch.rpm (python-pycurl-7.19.0-19.el7.x86_64.rpm)
    Using LIBGL000.RPM;1 for  /var/lib/oz/isocontent/centos7-iso/Packages/libglvnd-egl-1.0.1-0.8.git5baa1e5.el7.x86_64.rpm (libglvnd-glx-1.0.1-0.8.git5baa1e5.el7.x86_64.rpm)
    Using NETWO000.RPM;1 for  /var/lib/oz/isocontent/centos7-iso/Packages/NetworkManager-1.18.0-5.el7.x86_64.rpm (NetworkManager-team-1.18.0-5.el7.x86_64.rpm)
    #..............
    Using PCIUT000.RPM;1 for  /var/lib/oz/isocontent/centos7-iso/Packages/pciutils-3.5.1-3.el7.x86_64.rpm (pciutils-libs-3.5.1-3.el7.x86_64.rpm)
    Using CRYPT000.RPM;1 for  /var/lib/oz/isocontent/centos7-iso/Packages/cryptsetup-libs-2.0.3-5.el7.x86_64.rpm (cryptsetup-2.0.3-5.el7.x86_64.rpm)
    Using KERNE000.RPM;1 for  /var/lib/oz/isocontent/centos7-iso/Packages/kernel-tools-3.10.0-1062.el7.x86_64.rpm (kernel-tools-libs-3.10.0-1062.el7.x86_64.rpm)
    Using E2FSP000.RPM;1 for  /var/lib/oz/isocontent/centos7-iso/Packages/e2fsprogs-1.42.9-16.el7.x86_64.rpm (e2fsprogs-libs-1.42.9-16.el7.x86_64.rpm)
    Writing:   Initial Padblock                        Start Block 0
    Done with: Initial Padblock                        Block(s)    16
    Writing:   Primary Volume Descriptor               Start Block 16
    Done with: Primary Volume Descriptor               Block(s)    1
    Writing:   Eltorito Volume Descriptor              Start Block 17
    Size of boot image is 4 sectors -> No emulation
    Done with: Eltorito Volume Descriptor              Block(s)    1
    Writing:   Joliet Volume Descriptor                Start Block 18
    Done with: Joliet Volume Descriptor                Block(s)    1
    Writing:   End Volume Descriptor                   Start Block 19
    Done with: End Volume Descriptor                   Block(s)    1
    Writing:   Version block                           Start Block 20
    Done with: Version block                           Block(s)    1
    Writing:   Path table                              Start Block 21
    Done with: Path table                              Block(s)    4
    Writing:   Joliet path table                       Start Block 25
    Done with: Joliet path table                       Block(s)    4
    Writing:   Directory tree                          Start Block 29
    Done with: Directory tree                          Block(s)    48
    Writing:   Joliet directory tree                   Start Block 77
    Done with: Joliet directory tree                   Block(s)    33
    Writing:   Directory tree cleanup                  Start Block 110
    Done with: Directory tree cleanup                  Block(s)    0
    Writing:   Extension record                        Start Block 110
    Done with: Extension record                        Block(s)    1
    Writing:   The File(s)                             Start Block 111
    0.98% done, estimate finish Thu Jan  9 18:11:57 2020
    1.95% done, estimate finish Thu Jan  9 18:11:57 2020
    #..............
    98.63% done, estimate finish Thu Jan  9 18:12:00 2020
    99.60% done, estimate finish Thu Jan  9 18:12:00 2020
    Total translation table size: 124656
    Total rockridge attributes bytes: 55185
    Total directory bytes: 92160
    Path table size(bytes): 140
    Done with: The File(s)                             Block(s)    511779
    Writing:   Ending Padblock                         Start Block 511890
    Done with: Ending Padblock                         Block(s)    150
    Max brk space used ac000
    512040 extents written (1000 MB)


    Cleaning up old ISO data
    Generating 10GB diskimage for centos7
    Waiting for volume to be created, 90/90
    Running install for centos7
    Generate XML for guest centos7 with bootdev cdrom
    Generated XML:
    <domain type="kvm">
    <name>centos7</name>
    <memory>1048576</memory>
    <currentMemory>1048576</currentMemory>
    <uuid>50507349-dbd5-4fc5-8c54-7d6e6ea42de6</uuid>
    <clock offset="utc"/>
    <vcpu>1</vcpu>
    <features>
        <acpi/>
        <apic/>
        <pae/>
    </features>
    <os>
        <type>hvm</type>
        <boot dev="cdrom"/>
    </os>
    <on_poweroff>destroy</on_poweroff>
    <on_reboot>destroy</on_reboot>
    <on_crash>destroy</on_crash>
    <devices>
        <graphics type="vnc" port="-1"/>
        <interface type="bridge">
        <source bridge="virbr0"/>
        <mac address="52:54:00:89:09:e6"/>
        <model type="virtio"/>
        </interface>
        <input bus="ps2" type="mouse"/>
        <serial type="pty">
        <target port="0"/>
        </serial>
        <serial type="tcp">
        <source host="127.0.0.1" mode="bind" service="44993"/>
        <protocol type="raw"/>
        <target port="1"/>
        </serial>
        <disk device="disk" type="file">
        <target bus="virtio" dev="vda"/>
        <source file="/var/lib/libvirt/images/centos7.dsk"/>
        <driver type="raw" name="qemu"/>
        </disk>
        <disk device="cdrom" type="file">
        <source file="/var/lib/libvirt/images/centos7-iso-oz.iso"/>
        <target dev="hdc"/>
        </disk>
    </devices>
    </domain>

    Waiting for centos7 to finish installing, 1200/1200
    Waiting for centos7 to finish installing, 1190/1200
    #..............
    Waiting for centos7 to finish installing, 750/1200
    Waiting for centos7 to finish installing, 740/1200
    Waiting for centos7 to finish shutdown, 90/90
    Install of centos7 succeeded
    Generate XML for guest centos7 with bootdev hd
    Generated XML:
    <domain type="kvm">
    <name>centos7</name>
    <memory>1048576</memory>
    <currentMemory>1048576</currentMemory>
    <uuid>50507349-dbd5-4fc5-8c54-7d6e6ea42de6</uuid>
    <clock offset="utc"/>
    <vcpu>1</vcpu>
    <features>
        <acpi/>
        <apic/>
        <pae/>
    </features>
    <os>
        <type>hvm</type>
        <boot dev="hd"/>
    </os>
    <on_poweroff>destroy</on_poweroff>
    <on_reboot>destroy</on_reboot>
    <on_crash>destroy</on_crash>
    <devices>
        <graphics type="vnc" port="-1"/>
        <interface type="bridge">
        <source bridge="virbr0"/>
        <mac address="52:54:00:89:09:e6"/>
        <model type="virtio"/>
        </interface>
        <input bus="ps2" type="mouse"/>
        <serial type="pty">
        <target port="0"/>
        </serial>
        <serial type="tcp">
        <source host="127.0.0.1" mode="bind" service="44993"/>
        <protocol type="raw"/>
        <target port="1"/>
        </serial>
        <disk device="disk" type="file">
        <target bus="virtio" dev="vda"/>
        <source file="/var/lib/libvirt/images/centos7.dsk"/>
        <driver type="raw" name="qemu"/>
        </disk>
    </devices>
    </domain>

    Cleaning up after install
    Customizing image
    No additional packages, files, or commands to install, and icicle generation not requested, skipping customization
    Libvirt XML was written to centos7Jan_09_2020-18:19:42
