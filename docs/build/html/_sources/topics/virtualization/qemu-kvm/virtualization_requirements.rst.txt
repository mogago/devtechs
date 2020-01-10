Requerimientos de virtualización
================================

.. contents:: Table of Contents

Según la cantidad de VMs y la carga de trabajo que deseemos correr podemos determinar los requerimientos físicos del equipo encargado de la virtualización y el aprovisionamiento de recursos, es decir, el equipo que tendrá el **hypervisor QEMU/KVM**. En base a esto decidiremos cuántos CPUs, memoria RAM y almacenamiento se asigna a cada VM.

Requerimientos de CPU
---------------------

Marcas fabricantes de CPUs han integrado **extensiones de virtualización** dentro de sus procesadores de **arquitectura x86**. A través de estas extensiones, KVM emplea una tecnología llamada **hardware-accelarated virtualization**; que para CPUs de Intel recibe el nombre de **VT-x (Virtual Machine Extension)**, mientras que en AMD es llamado **AMD-V (AMD Virtualization)**. Gracias a esto, es posible ejecutar el código de un Sistema Operativo (SO) guest en el CPU del host directamente. `Referencia de virtualización x86`_.

.. _Referencia de virtualización x86: https://en.wikipedia.org/wiki/X86_virtualization#Intel_virtualization_(VT-x)

Desde un sistema Linux podemos descubrir si nuestros procesadores cuentan con esta tecnología buscando un flag especial que lo compruebe: para Intel VT-x es ``vmx`` y para AMD-V es ``svm``. Además si el CPU tiene una **arquitectura de 64 bits** veremos un flag extra de interés: ``lm``.

Para buscar los flags ejecutar:

.. code-block:: bash
    :emphasize-lines: 3,5

    $ grep --color -Ew 'svm|vmx|lm' /proc/cpuinfo
    flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat
    pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc
    arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq
    dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic popcnt
    tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm cpuid_fault epb pti ssbd ibrs ibpb
    stibp tpr_shadow vnmi flexpriority ept vpid fsgsbase smep erms xsaveopt dtherm ida arat
    pln pts md_clear flush_l1d

- ``svm``: CPU tiene AMD-V
- ``vmx``: CPU tiene VT-x
- ``lm``: soporte de 64-bit

En el ejemplo de arriba vemos los flags de ``vmx`` y ``lm``, significa que estamos empleando un procesador de 64-bits marca Intel en el host.

Otro componente necesario para tener un sistema de virtualización funcional son los módulos de kernel responsables de soportar virtualización. Estos módulos pueden encontrarse en un sistema Linux con la herramienta ``lsmod`` (`lsmod o loadble kernel modules`_):

.. _lsmod o loadble kernel modules: https://en.wikipedia.org/wiki/Lsmod

.. code-blocK:: bash

    $ lsmod | grep kvm

    kvm_intel             217088  0
    kvm                   610304  1 kvm_intel

En sistemas AMD veremos ``kvm_amd`` en vez de ``kvm_intel``.

En el caso que no aparezca algún módulo, deberemos cargarlo manualmenete con la herramienta de Linux ``modprobe``:

.. code-blocK:: bash

    $ modprobe kvm
    $ modprobe kvm_intel  # Intel processors
    $ modprobe kvm_amd    # AMD processors

Más información en `Three main components - KVM`_.

.. _Three main components - KVM: https://www.linux-kvm.org/page/Choose_the_right_kvm_%26_kernel_version

Instalando herramientas
-----------------------

Instalaremos varios programas útiles para la virtualización:

En UBUNTU/DEBIAN (con ``apt``)
''''''''''''''''''''''''''''''

.. code-blocK:: bash

    # QEMU/KVM, Virtual Machine Manager, Libvirt, bridge-utils (brctl)
    $ sudo apt-get install -y qemu-kvm virt-manager libvirt-bin bridge-utils

Mirando las dependencias de los paquetes instalados veremos que se han instalado otros paquetes importantes como: ``virt-viewer``, ``virtinst``, ``libvirt-daemon-system``, ``libvirt-clients``

Comandos útiles con ``apt``:

- Paquetes instalados: ``apt list --installed``
- Dependencia de paquetes: ``apt-cache depends vim``
- Dependencia de paquetes reversa: ``apt-cache rdepends vim`` (o para ver los que tenemos instalados ``apt-cache rdepends --installed vim``)

En CENTOS/RHEL (con ``yum``)
''''''''''''''''''''''''''''

.. code-block:: bash

    $ sudo yum install -y qemu-kvm virt-manager libvirt virt-install virt-viewer

`Comandos útiles con yum`_:

.. _Comandos útiles con yum: https://access.redhat.com/sites/default/files/attachments/rh_yum_cheatsheet_1214_jcs_print-1.pdf

- Paquetes instalados: ``yum list installed``
- Dependencia de paquetes: ``yum deplist nfs-utils``

.. Note:: 

    El paquete ``bridge-utils`` viene pre-instalado en algunas distribuciones como CentOS 7 (GNOME)

Iniciando servicios
-------------------

Habiendo instalado todos los paquetes de virtualización, habilitaremos el servicio de ``libvirtd``, que es el daemon de ``libvirt``:

.. code-block:: bash

    $ systemctl enable libvirtd && systemctl start libvirtd

``libvirt`` mostrará una API a clientes como ``virt-manager`` y ``virsh`` para poder comunicarse con ``qemu-kvm``.

.. Note::

    Para ver la versión de ``libvirt`` en uso ejecutar: ``libvirtd --version``

Validando capacidades del sistema
---------------------------------

A continuación se presentan dos herramientas útiles para verificar que nuestro sistema es apto para servir como virtualizador y ver sus capacidades:

Validando con ``virt-host-validate``
''''''''''''''''''''''''''''''''''''

La herramienta ``virt-host-validate`` ejecutará una series de pruebas para medir las capacidades del sistema y evaluar si el host está configurado correctamente para servir como un host de virtualización KVM.

.. code-block:: bash

    $ sudo virt-host-validate

    QEMU: Checking for hardware virtualization              : PASS
    QEMU: Checking if device /dev/vhost-net exists          : PASS
    QEMU: Checking if device /dev/net/tun exists            : PASS
    QEMU: Checking for cgroup 'memory' controller support   : PASS
    QEMU: Checking for cgroup 'cpu' controller support      : PASS
    LXC: Checking for Linux >= 2.6.26                       : PASS
    LXC: Checking for namespace user                        : PASS
    LXC: Checking for cgroup 'memory' controller support    : PASS

Si nuestro CPU no es capaz de realizar virtualización acelerada por hardware veremos un error en la revisión de pasos como se muestra en el siguiente ejemplo:

.. code-block:: bash
    :emphasize-lines: 2

    $ virt-host-validate

    QEMU: Checking for hardware virtualization              : FAIL (Only emulated CPUs are available, performance will be significantly limited)
    QEMU: Checking if device /dev/vhost-net exists          : PASS
    QEMU: Checking if device /dev/net/tun exists            : PASS
    QEMU: Checking for cgroup 'memory' controller support   : PASS
    QEMU: Checking for cgroup 'cpu' controller support      : PASS
    LXC: Checking for Linux >= 2.6.26                       : PASS
    LXC: Checking for namespace user                        : PASS
    LXC: Checking for cgroup 'memory' controller support    : PASS

El mensaje nos indica que solo estará disponible la emulación de CPU, y el rendimiento se verá afectado por esto. En otras palabras el sistema solo tiene soporte para ``qemu``, que es lento comparado con ``qemu-kvm``.

También se validan otros parámetros del sistema como:

- ``/dev/kvm``: facilita el acceso directo de la VMs al hardware (el usuario actual debe tener permisos de acceso)
- ``/dev/vhost-net``: sirve como la interface para configurar la instancia vhost-net.
- ``/dev/net/tun``: usado para crear **dispositivos tun/tap** para facilitar la conectividad de red a VMs.

.. Note::

    Asegurarnos que ``virt-host-validate`` pasa todas las pruebas satisfactoriamente para proceder con la creación de VMs.

Validando con ``virsh``
'''''''''''''''''''''''

Podemos usar ``virsh`` para obtener información sobre las características del host (CPU, memoria RAM) que obtendríamos normalmente usando comandos por separado con otras herramientas:

.. code-block:: bash

    $ virsh nodeinfo

    CPU model:           x86_64
    CPU(s):              4
    CPU frequency:       1296 MHz
    CPU socket(s):       1
    Core(s) per socket:  2
    Thread(s) per core:  2
    NUMA cell(s):        1
    Memory size:         8068236 KiB

Otro comando útil de ``virsh`` es ``virsh domcapabilities``. Este comando nos imprime un documento XML que describe las capacidades del dominio para el hypervisor al que estamos conectados. Dentro del archivo XML podemos extraer información como el número máximo de ``vcpu`` que se pueden otorgar a una VM:

.. code-block:: bash

    $ virsh domcapabilities | grep -i max
        <vcpu max='255'/>

En este host se pueden definir un máximo de 255 vcpus para una VM. También podemos obtener los tipos de dispositivos que se pueden emplear:

.. code-block:: bash

    $ virsh domcapabilities | grep diskDevice -A 5

        <enum name='diskDevice'>
            <value>disk</value>
            <value>cdrom</value>
            <value>floppy</value>
            <value>lun</value>
        </enum>

.. Note::

    ``virsh`` (**o virtualization shell**) es una herramienta de interfaz de línea de comandos para la administración de guest y el hypervisor. Emplea la API de administración ``libvirt`` y posee muchas funcionalidades que pueden clasificarse en:

    - Guest management commands (for example ``start``, ``stop``)
    - Guest monitoring commands (for example ``memstat``, ``cpustat``)
    - Host and hypervisors commands (for example ``capabilities``, ``nodeinfo``)
    - Virtual networking commands (for example ``net-list``, ``net-define``)
    - Storage management commands (for example ``pool-list``, ``pool-define``)
    - Snapshot commands (``create-snapshot-as``)

    Mayor referencia en:
    
    - `KVM-virsh - Ubuntu Help`_
    - `Managing guests using virsh - RedHat Virtualization Guide`_
    - `virsh - libvirt guide`_

    .. _KVM-virsh - Ubuntu Help: https://help.ubuntu.com/community/KVM/Virsh
    .. _Managing guests using virsh - RedHat Virtualization Guide: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/virtualization/chap-virtualization-managing_guests_with_virsh
    .. _virsh - libvirt guide: https://libvirt.org/manpages/virsh.html

