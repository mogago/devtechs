==============
Virtualization 
==============

- QEMU/KVM
- Virtual Networks

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
