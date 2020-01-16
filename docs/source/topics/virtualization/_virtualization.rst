==============
Virtualization 
==============

MASTERING KVM VIRTUALIZATION:

- CH3: 
    - Revisión de los requerimientos para nuestro entorno de virtualización (Determining the right system requirements for your environment)
        - Búsqueda de flags: grep --color -Ew 'svm|vmx|lm' /proc/cpuinfo
        - Búsqueda de módulos KVM: lsmod | grep kvm
    - Instalación de los paquetes de virtualización (Setting up the environment)
        - Con yum: yum install qemu-kvm libvirt virt-install virt-manager -y
        - Con apt (investigar): apt-get install virt-manager
        - Instalación grupal: yum groupinstall "virtualization" -y
    - Inicializar los servicios: systemctl enable libvirtd && systemctl start libvirtd
    - Ver versión de libvirt: libvirtd --version
    - Verificar capacidades de virtualización del sistema:
        - virt-host-validate
        - virsh nodeinfo
        - virsh domcapabilities (virsh domcapabilities | grep -i max), (virsh domcapabilities | grep diskDevice -A 5)
    - Conexión en virt-manager (Hardware configuration examples)

Tutoriales:

1. Revisar los requerimientos para virtualización QEMU/KVM
2. Instalación de paquetes para virtualización QEMU/KVM (yum, apt) e iniciar servicios
3. Crear una conexión en virt-manager

- CH4:
    - polkit (Introducing virt-manager)
    - Virtual Network Tab: virt-manager
    - listado de redes con virsh (Virtual Network Tab): virsh net-list --all
    - detalle de red con virsh (Virtual Network Tab): ``virsh net-info default`` , ``virsh net-dumpxml default``
    - Comandos básicos de virsh: ``virsh net-destroy`` y ``virsh net-start``
    - Storage tab de ``virt-manager``
    - Creación de una VM con wizard de virt-manager (Creating a new virtual machine wizard)
        - Base de datos de SOs: libosinfo, sinfo-query
    - Método de instalación por red en virt-manager (The Network installation (HTTP, FTP, or NFS) method)
    - Método Instalación por PXE en virt-manager, con macvtap y bridge (Network Boot (PXE))
    - Método de Instalación con una imagen de disco existente (Importing an existing disk image)
    - Usando virt-install para la creación de una VM y configuración del SO guest. (Introducing ``virt-install``, Installing a Windows 7 Guest using the ``virt-install`` command)
        - comando ``qemu-img`` para crear un disco virtual
        - comando ``virt-install --prompt`` para una instalación interactiva de la VM.
    - Instalación y uso de ``virt-builder`` para personalizar un SO con plantillas. Uso junto ``virt-install`` para automatizar el proceso de despliegue de la VM (Introducing virt-builder)
        - uso ``virt-builder`` y  combinación con ``virt-install``
        - listar VMs con ``virsh list --all``
        - iniciar la VM con ``virsh start <vname>``
        - opciones de virt-builder y virt-builder --note <guest>
        - caché de virt-builder: ``virt-builder --print-cache``
        - eliminar caché: ``virt-builder --delete-cache``
        - descargar todas las plantillas a caché: ``virt-builder --cache-all-templates``
    - Creación de una VM usando ``oz`` (Introducing ``oz``): instalación de ``oz``, archivo TDL, ``oz-install`` para construir la imagen, virsh define + virsh start
        - Archivo de configuración para creación de VMs en ``oz``: ``/etc/oz/oz.cfg`` (The oz configuration file)
        - Crear una VM usando ``oz`` (Creating a virtual machine using ``oz``)

Tutoriales:

1. Creación de VMs usando ``virt-manager`` (métodos de medio: ISO, PXE, HTTP)
2. Ver detalles de red con ``virsh``
3. Creación de VMs usando ``virt-install`` (+ ``qemu-img`` para crear un disco virtual)
4. Creación de VMs usando ``virt-builder``
5. Creación de VMs usando ``oz``

(*) Falta complementar material de ``qemu-img``

- CH 5:

    NETWORKING:
    - Ejemplo de virtual Networking con Linux bridges e interfaces TAP (Virtual Networking)
    - Virtual Networking usando libvirt: con clientes ``virt-manager`` y ``virsh``
        - Isolated
        - Routed
        - NATed
        - Bridged

    STORAGE:
    - Unmanaged storage
    - Creación de un disco virtual (``dd``): discos preallocated y thin-provisioned
    - Información de una imagen (raw .img, qcow2, ...) con ``qemu-img info``
    - Conexión de un disco a una VM (Unmanaged storage):
        - usando ``virt-manager``: add new virtual hardware
        - usando ``virsh``: ``virsh attach disk`` (discos conectados a una VM: ``virsh domblklist``)
    - Managed storage (tipos de pools soportados por libvirt)
    - Administración y configuración de almacenamiento (pools):
        - con ``virt-manager``: Pestaña Storage de Connection Details.
        - con ``virsh``: listar pools (``virsh pool-list``), obtener información de un pool (``virsh pool-info``)
    - Creando pools de almacenamiento (XML de pools guardadas bajo ``/etc/libvirt/storage``):
        - Pool con almacenamiento basado en archivos
            - con ``virt-manager``: ``dir: Filesystem Directory``
            - con ``virsh``: ``virsh pool-define-as``, ``virsh pool-build``, ``virsh pool-start``
            - extra (start y autostart del pool): ``virsh pool-start``, ``virsh pool-autostart``
        - Pool con LVM Volume group
            - con ``virt-manager``: ``logical: LVM Volume Group``
            - con ``virsh``: ``virsh pool-define-as``, ``virsh pool-build``, ``virsh pool-start``
        - Pool con iSCSI
            - con ``virt-manager``: ``iscsi: iSCSI Target``
    - Creando una biblioteca de imágenes ISO:
        - con ``virsh``: ``virsh pool-define-as``, ``virsh pool-build``, ``virsh pool-start``
        - extra (actualizar contenidos del pool): ``virsh pool-refresh``
    - Eliminando un pool
        - con ``virt-manager``: Pestaña Storage de Connection Details.
        - con ``virsh``: ``virsh pool-destroy``, ``virsh pool-undefine``
    - Crear volúmenes de almacenamiento:
        - con ``virt-manager``: Pestaña Storage de Connection Details.
        - con ``virsh``: ``virsh vol-create-as``, ``virsh vol-info``
    - Eliminando un volumen
        - con ``virsh``: ``virsh vol-delete``

Tutoriales (almacenamiento):

1. Creación de volúmenes de almacenamiento con virt-manager y virsh

2. Unmanaged y Managed Storage en libvirt
    1.1 Unmanaged storage: crear un disco no asociado con libvirt y unirlo a una VM (métodos de creación de un volumen: virt-manager, virsh, qemu-img, dd
    1.2 Managed storage: creación, eliminación de pools (basado en archivos, LVM volume group): virt-manager, virsh

