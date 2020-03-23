.. _kstemplates1:

Kickstart Templates 1
=====================

.. contents:: Table of Contents

- Referencia 1: `Red Hat Docs - KICKSTART SYNTAX REFERENCE`_

.. _`Red Hat Docs - KICKSTART SYNTAX REFERENCE`: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/installation_guide/sect-kickstart-syntax

Archivo Kickstart - Configuración mínima
----------------------------------------

Archivo Kickstart con una configuración mínima para lograr una instalación de CentOS 7 totalmente desatendida:

.. code-block:: cfg

    install
    cdrom
    bootloader --location=mbr
    keyboard --vckeymap=latam --xlayouts='latam','us'
    rootpw --iscrypted $1$WUDGBrnr$Bq8p.jk4ikcEr2JYJRMwE0
    lang en_US.UTF-8 --addsupport=es_US.UTF-8
    clearpart --all --initlabel
    part / --fstype="ext4" --grow --ondisk=sda --size=1
    timezone America/Lima
    reboot

    %packages
    %end

- ``install`` - (optional). Modo de instalación. Debe ir acompañado en otra línea del tipo de instalación: ``cdrom``, ``harddrive``, ``nfs``, ``liveimg``, ``url`` (FTP, HTTP, HTTPS).
- ``cdrom`` - instalar desde el primer disco óptico en el sistema.
- ``bootloader`` - (required). Especifica cómo debe instalarse el boot loader
    - ``--location=`` - especifica donde es escrito el boot record
        - ``mbr`` - (default). Depende de si el drive usa el Master Boot Record (MBR) o un esquema GUID Partition Tables (GPT). En un disco con formato GTP, essta opción instala la etapa 1.5 del boot loader en la particion de arranque BIOS. En un disco con formato MBR, la etapa 1.5 es instalada en un espacio vacío entre el MBR y la primera partición.

.. code-block:: cfg

    bootloader --location=mbr --append="hdd=ide-scsi ide=nodma"

- ``keyboard`` - (required). Configura uno o más keyboard layouts para el sistema.
    - ``vckeymap`` - especifica un ``VConsole`` keymap que se debe usar.
    - ``--xlayouts`` - especifica una lista de X layouts que deben ser usados.

.. code-block:: cfg

    keyboard --xlayouts=us,'cz (qwerty)' --switch=grp:alt_shift_toggle

- ``rootpw`` - (required). Configura la contraseña root con el argumento de la contraseña
    - ``--iscrypted`` - si esta opción está presente se asume que el argumento de la contraseña ya está encriptado.

.. code-block:: cfg

    rootpw [--iscrypted|--plaintext] [--lock] password

- ``lang`` - (required). Establece el lenguaje a usar durante la instalación y el lenguaje usado por defecto en el sistema instalado.
    - ``--addsupport=`` - añadir soporte de lenguajes adicionales. Podemos listar varios separados por comas.

.. code-block:: cfg

    lang en_US --addsupport=cs_CZ,de_DE,en_UK

- ``clearpart`` - (optional). Remueve las particiones del sistema, previo a la creación de nuevas particiones. Por defecto ninguna partición es eliminada.
    - ``--all`` - elimina todas las particiones del sistema. Se eliminarán todos los discos que puedan ser alcanzados por el instalador, incluyendo cualquier almacenamiento conectado por red.
    - ``--initlabel`` - inicializa un disco discos, creando un disk label por defecto para todos los discos en su arquitectura respectiva (p.ej. msdos para x86) que hayan sido designados para formatear. Ya que ``--initlabel`` puede ver todos los discos, es importante asegurarse que solo los drivers que serán formateadas se encuentran conectados.

- ``part`` - (o ``partiton``). (required). Crea una partición en el sistema. Todas las particiones creadas son formateadas, como parte del proceso de instalación, excepto que se indique lo contrario (con ``--noformat`` y ``--onpart``).
    - ``--fstype=`` - configura el tipo de file system para la partición. Valores posibles: ``xfs``, ``ext2``, ``ext3``, ``ext4``, ``swap``, ``vfat``, ``efi`` y ``biosboot``.
    - ``--grow`` - le indica al volumen lógico que crezca para rellenar el espacio disponible (si existe), o hasta la configuración de tamaño máximo, si se especifica uno. Un tamaño mínimo debe ser especificado usando la opción ``--percent=`` o ``--size=``.
    - ``--ondisk=`` - (o ``--ondrive=``). Crea una partición (especificada por el comando part) en un disco existente. Este comando siempre crea una partición.
    - ``--size=`` - tamaño del volumen lógico en MiB. No podemos usar esta opción junto con ``--percent=``

- ``timezone`` - (required). Configura la zona horaria.
- ``reboot`` - (optional). Reinicia luego de que la instalación es completada satisfactoriamente. Esta opción es equivalente a ejecutar el comando ``shutdown -r``.
- ``%packages`` - Usar este comando para iniciar una sección en Kickstart que describa los paquetes de software a ser instalados. Podemos especificar paquetes por environmet (``@^``), group (``@``), o por sus nombres de paquete. El ``Core`` group siempre es seleccionado por defecto, cuando se usa esta sección ``%packages``, por lo que no es obligatorio especificarlo.

.. Note::

    Verificar el nombre con el cual son creados los discos, para planear las particiones. En VirtualBox los discos se crean con el formato de nombre ``sdx`` (``--ondisk=sda``), pero en virt-manager los discos se crean con el formato de nombre ``vdx`` (``--ondisk=vda``). (x=a,b,c,d,...)

Archivo Kickstart - Creación de usuario
---------------------------------------

Archivo Kickstart con la funcionalidad para crear un nuevo usuario:

.. code-block:: cfg

    install
    cdrom
    bootloader --location=mbr
    keyboard --vckeymap=latam --xlayouts='latam','us'
    rootpw --iscrypted $1$WUDGBrnr$Bq8p.jk4ikcEr2JYJRMwE0
    lang en_US.UTF-8 --addsupport=es_US.UTF-8
    clearpart --all --initlabel
    part / --fstype="ext4" --grow --ondisk=sda --size=1
    timezone America/Lima
    reboot

    user --name=user1 --groups=wheel --iscrypted --password=$1$WUDGBrnr$Bq8p.jk4ikcEr2JYJRMwE0

    %packages
    %end

- ``user`` - (optional). Crear un nuevo usuario en el sistema.
    - ``--name=`` - (required). Provee el nombre del usuario.
    - ``--groups=`` - En adición al grupo por defecto, una lista separada por comas de nombre de grupos a los que el usuario debe pertenecer. Los grupos deben existir antes que la cuenta de usuario sea creada.
    - ``--homedir=`` - El directorio home del usuario. Si no es provisto, por defecto se usará ``/home/username``.
    - ``--password=`` - La contraseña del nuevo usuario. Si no es provista, la cuenta será bloqueada por defecto.
    - ``--iscrypted`` - si esta opción está presente se asume que el argumento de la contraseña ya está encriptado.

.. code-block:: cfg

    user --name=username [options]

.. Note::

    Podemos usar una contraseña con HASH MD5, SHA256 o SHA512. El instalador comprenderá el tipo de HASH que se está usando según la longitud de caracteres este. Por ejemplo, estos dos líneas usan un HASH SHA512 y MD5 respectivamente, pero tienen el mismo resultado:

    .. code-block:: cfg

        user --name=user1 --groups=wheel --iscrypted --password=$6$KnYe93Ga4BpTVh8i$bGNPmIEGhgCUTx9i3wpZvxx6ZS3OP0t7tw4UxCK67dtDftIjaKVMqlE8rwhdwCR9Pq1g.OsyQXQyMv2DUHvjc0
        user --name=user1 --groups=wheel --iscrypted --password=$1$WUDGBrnr$Bq8p.jk4ikcEr2JYJRMwE0

Archivo Kickstart - Static network configuration
------------------------------------------------

Archivo Kickstart con la funcionalidad para configurar la red:

.. code-block:: cfg

    install
    cdrom
    bootloader --location=mbr
    keyboard --vckeymap=latam --xlayouts='latam','us'
    rootpw --iscrypted $1$WUDGBrnr$Bq8p.jk4ikcEr2JYJRMwE0
    lang en_US.UTF-8 --addsupport=es_US.UTF-8
    clearpart --all --initlabel
    part / --fstype="ext4" --grow --ondisk=sda --size=1
    timezone America/Lima
    reboot

    network --bootproto=static --device=00:11:22:33:44:55 --ip=10.1.1.5 --netmask=255.255.255.0 gateway=10.1.1.5 --nameserver=8.8.8.8 --hostname=centos7

    %packages
    %end

- ``network`` - (optional). Configura la información de red para el sistema objetivo y activa dispositivos de red en el entorno de instalación. El dispositivo especificado en el primer comando ``network`` es activado automáticamente. La activación del dispositivo también puede ser requerida explícitamente por la opción ``--activate``.
    - ``--activate`` - activa este dispositivo en el entorno de instalación. Si usamos la opción ``--activate`` en un dispositivo que ya ha sido activado (por ejemplo, una interfaz que hemos configurado con boot options para que el sistema pueda obtener el archivo Kickstart), el dispositivo es reactivado para usar los detalles especificados en el archivo Kickstart.
    - ``--bootproto=`` - Toma uno de los siguientes valores: ``dhcp`` (default), ``bootp``, ``ibft``, ``static``.
    - ``--device=`` - Especifica el dispositivo a ser configurado con el comando ``network``. Podemos especificar un dispositivo para que sea activado en cualquiera de las siguientes formas:
        - el nombre de dispositivo de la interfaz (p. ej. ``em1``)
        - la dirección MAC de la interfaz (p. ej. ``01:23:45:67:89:ab``)
    - ``--ip`` - dirección IPv4 del dispositivo.
    - ``--netmask`` - máscara de red para el sistema instalado.
    - ``--gateway`` - default gateway como única dirección IPv4.
    - ``--nameserver`` - DNS name server, como una dirección IP. Para especificar múltiples name servers, listarlos y separar cada dirección IP con comas.
    - ``--hostname`` - El host name del sistema instalado.

Archivo Kickstart - Pre-install script
--------------------------------------

Caso de uso para un pre-installation script:

Si hemos configurado una dirección IP y un hostname específicos para un cliente (según la MAC del cliente) en el servidor DHCP, podemos volver esta configuración estática. Es decir, los parámetros asignados por el servidor DHCP se mantendrán luego del reinicio del sistema, posterior a la instalación. El fin de este script es que la configuración de red asignada por el servidor DHCP se vuelva estática, aún cuando este servidor no esté activo y el cliente no pueda recibir una IP ni hostname.

Para volver estática la configuración asignada por el servidor DHCP se puede usar un pre-installation script en el archivo Kickstart para la instalación del cliente. Este pre-installation script obtiene IP y netmask del comando ``ip`` y el hostname del comando ``hostname`` y los almacena en variables. Luego se establece una entrada para el archivo kickstart que configure estáticamente la configuración de red.

.. code-block:: cfg

    install
    cdrom
    bootloader --location=mbr
    keyboard --vckeymap=latam --xlayouts='latam','us'
    rootpw --iscrypted $1$WUDGBrnr$Bq8p.jk4ikcEr2JYJRMwE0
    lang en_US.UTF-8 --addsupport=es_US.UTF-8
    clearpart --all --initlabel
    part / --fstype="ext4" --grow --ondisk=sda --size=1
    timezone America/Lima
    reboot

    # Incluir archivo generado en pre installation script
    %include /tmp/network.ks

    %packages
    %end

    %pre
    #!/bin/bash

    inet="$(ip addr show dev enp0s3 scope global | grep 'inet')"
    #echo "$inet"

    #ipdir="$(echo "$inet" | awk '{ print $2 }')"
    ipdir="$(echo "$inet" | cut -d ' ' -f 6)"
    #echo "$ipdir"

    ip="$(echo "$ipdir" | cut -d / -f1)"
    echo "$ip"

    netmaskCIDR="$(echo "$ipdir" | cut -d / -f2)"
    #echo "$netmaskCIDR"

    # ======TRANSFORMAR MASCARA DE CIDR A DECIMAL=======

    # Obtener 1's
    #for i in $( seq 1 $netmaskCIDR )
    for (( i=1; i<=$netmaskCIDR; i++ ))
    do
            unos+="1"
    done

    # Obtener 0's
    cidrceros=$(( 32-$netmaskCIDR ))

    #for i in $( seq 1 $cidrceros )
    for (( i=1; i<=$cidrceros; i++ ))
    do
            ceros+="0"
    done

    # Concatenar 1's con 0's
    binario="$unos$ceros"

    #echo $unos
    #echo $ceros
    #echo $binario

    # Separar cada 8 digitos
    oct1="$(echo "$binario" | cut -c 1-8)"
    oct2="$(echo "$binario" | cut -c 9-16)"
    oct3="$(echo "$binario" | cut -c 17-24)"
    oct4="$(echo "$binario" | cut -c 25-32)"

    #echo $oct1
    #echo $oct2
    #echo $oct3
    #echo $oct4

    # Transformar cada octeto de binario a decimal
    #for i in $( seq 1 8 )
    for i in {1..8}
    do
    #       echo $i
            peso=$(( 128/(2**$(( $i-1 ))) ))
    #       echo $peso

            # PRIMER OCTETO
            posicion="$(echo "$oct1" | cut -c $i)"
    #       echo $posicion
            valor=$(( $posicion*$peso ))
    #       echo $valor
            sum=$(( $sum+$valor ))

            # SEGUNDO OCTETO
            posicion2="$(echo "$oct2" | cut -c $i)"
            valor2=$(( $posicion2*$peso ))
            sum2=$(( $sum2+$valor2 ))

            # TERCER OCTETO
            posicion3="$(echo "$oct3" | cut -c $i)"
            valor3=$(( $posicion3*$peso ))
            sum3=$(( $sum3+$valor3 ))

            # CUARTO OCTETO
            posicion4="$(echo "$oct4" | cut -c $i)"
            valor4=$(( $posicion4*$peso ))
            sum4=$(( $sum4+$valor4 ))
    done

    #echo $sum
    #echo $sum2
    #echo $sum3
    #echo $sum4

    # Formar netmask
    netmask="$sum.$sum2.$sum3.$sum4"
    echo $netmask

    # Variable que almacena el hosntame
    hostn="$(hostname)"
    echo "$hostn"

    echo "network --bootproto=static --device=enp0s3 --ip=$ip --netmask=$netmask --hostname=$hostn" > /tmp/network.ks

    %end

- ``%include`` - (optional). Usar el comando ``%include /path/to/file`` para incluir los contenidos de otro archivo en el archivo Kickstart como si el contenido estuviera en la ubicación del comando ``%include`` en el archivo Kickstart.

.. Note::

    En este ejemplo, la línea ``%include /tmp/network.ks`` es reemplazada por ``network --bootproto=static --device=enp0s3 --ip=$ip --netmask=$netmask --hostname=$hostn``

.. Note::

    Usar el parámetro ``--bootproto=`` con valor ``static`` configura el parámetro ``BOOTPROTO="none"`` en el archivo ``/etc/sysconfig/network-scripts/ifcfg-enp0s3``, en lugar de ``BOOTPROTO="dhcp"`` (por defecto).

Archivo Kickstart - Post-install script
---------------------------------------

Caso de uso para un post-installation script:

Agregar una llave pública para habilitar Passwordless SSH hacia el cliente.

.. code-block:: cfg

    install
    cdrom
    bootloader --location=mbr
    keyboard --vckeymap=latam --xlayouts='latam','us'
    rootpw --iscrypted $1$WUDGBrnr$Bq8p.jk4ikcEr2JYJRMwE0
    lang en_US.UTF-8 --addsupport=es_US.UTF-8
    clearpart --all --initlabel
    part / --fstype="ext4" --grow --ondisk=sda --size=1
    timezone America/Lima
    reboot

    user --name=user1 --groups=wheel --iscrypted --password=$1$WUDGBrnr$Bq8p.jk4ikcEr2JYJRMwE0

    %post
    #---- Install our SSH key ----
    mkdir -m0700 /home/user1/.ssh/

    # SSH public key of PXE boot server (SSH client)
    cat <<EOF >/home/user1/.ssh/authorized_keys
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDblvZmYVA+ayprv7f25pS3+agpSGzDg0mlZxvxB1g46r7YSGiMDXphujEqE6FJAkecAClQq3uztTQhGYqOutU4KQmHZ+f/os22YrA+aM3blNHcwh+OAjpfcdLnYuAo5YjsAuJ5/1bI6+VOKN6BHQYNVxkkggkeYnrZwQUD0w054cAgpfMp2O7FJGJ5SXDKUR4w7y2gAEjOFe6X/ULpRR0FWGFrDsO894XKnEBh3D2lhrdGZURwKJCtsbWxfO4XOm8P7JHdQK8z1xgKsTaJLotReh8lbwPptlLPGF3QjD0kvab9jqm8MosdOR4N4CGyYldflDHZ3FoKvxMA2lIUoalkicNzqkGP7kBj3Nzd+83E8KWdPbbk32KLkuFNQiXe5vWje1PlxufUAfBv3DaiRCtWSO50ZhdK4oLKiaOfkMxATEW6zXDiBYA4nig4FtIqYDjYB+Ca7vkrqifwNzliYZpQfcgQqZXEVUQtlw4JM1T/xhByt/T6A3pOwMBrVEaClgOwQaz/LiVFfyolyhO9OzOzFNXSw+Z5zZ7hj68lkji0gbjbxHMXNrHPhCMjts9m7dss/LrYIpmNHpbUWwpL8OilS+vofkgESbpJNw+1/fPlwx0UIKiJ4hHQpqzaOcSsRXhmyrBj/T1HWUyxUv34gmTynFTLNsNVMgWfBQTeqPruPQ== user1@localhost.localdomain
    EOF

    # set permissions
    chmod 0600 /home/user1/.ssh/authorized_keys

    # fix up selinux context
    restorecon -R /home/user1/.ssh/

    # change owner from root to user1
    chown -R user1:user1 /home/user1/.ssh
    %end

Archivo Kickstart - Text mode install
-------------------------------------

Archivo Kickstart con una configuración mínima en modo texto, en lugar del modo gráfico:

.. code-block:: cfg

    install
    cdrom
    bootloader --location=mbr
    keyboard --vckeymap=latam --xlayouts='latam','us'
    rootpw --iscrypted $1$WUDGBrnr$Bq8p.jk4ikcEr2JYJRMwE0
    lang en_US.UTF-8 --addsupport=es_US.UTF-8
    clearpart --all --initlabel
    part / --fstype="ext4" --grow --ondisk=sda --size=1
    timezone America/Lima
    reboot

    text

    %packages
    %end

- ``text`` - (optional). Realizar la instalación con Kickstart en modo texto. Por defecto, las instalaciones se realizan en modo gráfico.

Archivo Kickstart - Medio pasado mediante URL
---------------------------------------------

Archivo Kickstart con un medio de instalación pasado mediante una URL. En este caso se usa el protocolo FTP para enviar el medio al destino:

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
    reboot

    %packages
    %end

- ``install`` - (optional). Modo de instalación. Debe ir acompañado en otra línea del tipo de instalación: ``cdrom``, ``harddrive``, ``nfs``, ``liveimg``, ``url`` (FTP, HTTP, HTTPS).
- ``--url=`` - la ubicación de donde instalar. Soporta protocolos ``HTTP``, ``HTTPS``, ``FTP`` y ``file``.

Archivo Kickstart - esquema de particiones personalizado
--------------------------------------------------------

Archivo Kickstart con un esquema de particiones más desarrollado. Un mismo disco de 8 GB será particionado en 3 partes:

    - partición 1 (``/``): 5 GB
    - partición 2: partición para swap del tamaño recomendado por el instalador
    - partición 3 (``/home``): ocupar el tamaño restante del disco

.. code-block:: cfg

    install
    cdrom
    bootloader --location=mbr
    keyboard --vckeymap=latam --xlayouts='latam','us'
    rootpw --iscrypted $1$WUDGBrnr$Bq8p.jk4ikcEr2JYJRMwE0
    lang en_US.UTF-8 --addsupport=es_US.UTF-8
    clearpart --all --initlabel
    part / --fstype="ext4" --ondisk=sda --asprimary --size=5120
    part /home --fstype="ext4" --grow --ondisk=sda --size=1
    part swap --fstype="swap" --recommended
    timezone America/Lima
    reboot

    %packages
    %end

El esquema de particiones generado a partir de este archivo Kickstart es el siguiente:

.. code-block:: bash

    $ lsblk

    NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
    sda      8:0    0     8G  0 disk 
    ├─sda1   8:1    0     5G  0 part /
    ├─sda2   8:2    0   2.2G  0 part /home
    └─sda3   8:3    0   820M  0 part [SWAP]
    sr0     11:0    1   942M  0 rom

Archivo Kickstart - configuración de seguridad
----------------------------------------------

Archivo Kickstart con una configuración personalizada del Firewall y SELinux del sistema:

.. code-block:: cfg

    install
    cdrom
    bootloader --location=mbr
    keyboard --vckeymap=latam --xlayouts='latam','us'
    rootpw --iscrypted $1$WUDGBrnr$Bq8p.jk4ikcEr2JYJRMwE0
    lang en_US.UTF-8 --addsupport=es_US.UTF-8
    clearpart --all --initlabel
    part / --fstype="ext4" --grow --ondisk=sda --size=1
    timezone America/Lima
    reboot

    firewall --disabled
    selinux --enforcing

    %packages
    %end

- ``firewall`` - (optional). Especificar la configuración de firewall para el sistema instalado.
    - ``--enabled`` - (o ``--enable``). Rechaza conexiones entrantes que no responden a solicitudes salientes, como respuestas DNS o solicitudes DHCP. Si se necesita el acceso a servicios que corren en esta máquina, podemos escoger permitir servicios específicos a través del firewall.
    - ``--disabled`` - (o ``--disable``). No configurar ninguna regla de iptables.

.. code-block:: cfg

    firewall --enabled|--disabled device [options]

.. Note::

    Revisar el estado del firewall con ``systemctl status firewalld`` y ver las reglas de iptables con ``sudo iptables -S``.

- ``selinux`` - (optional). Configura el estado de SELinux en los sistemas instalados. La política por defecto de SELinux es ``enforcing``.
    - ``--enforcing`` - Habilita SELinux con la política objetivo en estado ``enforcing``.
    - ``--permissive`` - Entrega precauciones basados en la política de SELinux, pero en realidad no hace cumplir (enforce) la política.
    - ``--disabled`` - Deshabilita SELinux completamente en el sistema.

.. code-block:: cfg

    selinux [--disabled|--enforcing|--permissive]

.. Note::

    Revisar las políticas de seguridad de SELinux con el comando ``getenforce`` o leyendo el archivo ``/etc/selinux/config``.

Archivo Kickstart - múltiples opciones
--------------------------------------

Archivo kickstart que agrupa distintos parámetros ya revisados en los anteriores ejemplos:

.. code-block:: cfg

    install
    url --url="ftp://192.168.8.8/pub/centos7"
    bootloader --location=mbr
    keyboard --vckeymap=latam --xlayouts='latam','us'
    rootpw --iscrypted $1$WUDGBrnr$Bq8p.jk4ikcEr2JYJRMwE0
    lang en_US.UTF-8 --addsupport=es_US.UTF-8
    clearpart --all --initlabel
    part / --fstype="ext4" --ondisk=sda --asprimary --size=5120
    part /home --fstype="ext4" --grow --ondisk=sda --size=1
    part swap --fstype="swap" --recommended
    timezone America/Lima
    reboot

    user --name=user1 --groups=wheel --iscrypted --password=$1$WUDGBrnr$Bq8p.jk4ikcEr2JYJRMwE0

    firewall --disabled
    selinux --enforcing

    text

    # Incluir archivo generado en pre installation script
    %include /tmp/network.ks

    %packages
    %end

    %pre
    #!/bin/bash

    inet="$(ip addr show dev enp0s3 scope global | grep 'inet')"
    #echo "$inet"

    #ipdir="$(echo "$inet" | awk '{ print $2 }')"
    ipdir="$(echo "$inet" | cut -d ' ' -f 6)"
    #echo "$ipdir"

    ip="$(echo "$ipdir" | cut -d / -f1)"
    echo "$ip"

    netmaskCIDR="$(echo "$ipdir" | cut -d / -f2)"
    #echo "$netmaskCIDR"

    # ======TRANSFORMAR MASCARA DE CIDR A DECIMAL=======

    # Obtener 1's
    #for i in $( seq 1 $netmaskCIDR )
    for (( i=1; i<=$netmaskCIDR; i++ ))
    do
            unos+="1"
    done

    # Obtener 0's
    cidrceros=$(( 32-$netmaskCIDR ))

    #for i in $( seq 1 $cidrceros )
    for (( i=1; i<=$cidrceros; i++ ))
    do
            ceros+="0"
    done

    # Concatenar 1's con 0's
    binario="$unos$ceros"

    #echo $unos
    #echo $ceros
    #echo $binario

    # Separar cada 8 digitos
    oct1="$(echo "$binario" | cut -c 1-8)"
    oct2="$(echo "$binario" | cut -c 9-16)"
    oct3="$(echo "$binario" | cut -c 17-24)"
    oct4="$(echo "$binario" | cut -c 25-32)"

    #echo $oct1
    #echo $oct2
    #echo $oct3
    #echo $oct4

    # Transformar cada octeto de binario a decimal
    #for i in $( seq 1 8 )
    for i in {1..8}
    do
    #       echo $i
            peso=$(( 128/(2**$(( $i-1 ))) ))
    #       echo $peso

            # PRIMER OCTETO
            posicion="$(echo "$oct1" | cut -c $i)"
    #       echo $posicion
            valor=$(( $posicion*$peso ))
    #       echo $valor
            sum=$(( $sum+$valor ))

            # SEGUNDO OCTETO
            posicion2="$(echo "$oct2" | cut -c $i)"
            valor2=$(( $posicion2*$peso ))
            sum2=$(( $sum2+$valor2 ))

            # TERCER OCTETO
            posicion3="$(echo "$oct3" | cut -c $i)"
            valor3=$(( $posicion3*$peso ))
            sum3=$(( $sum3+$valor3 ))

            # CUARTO OCTETO
            posicion4="$(echo "$oct4" | cut -c $i)"
            valor4=$(( $posicion4*$peso ))
            sum4=$(( $sum4+$valor4 ))
    done

    #echo $sum
    #echo $sum2
    #echo $sum3
    #echo $sum4

    # Formar netmask
    netmask="$sum.$sum2.$sum3.$sum4"
    echo $netmask

    # Variable que almacena el hosntame
    hostn="$(hostname)"
    echo "$hostn"

    echo "network --bootproto=static --device=enp0s3 --ip=$ip --netmask=$netmask --hostname=$hostn" > /tmp/network.ks

    %end

    %post
    #---- Install our SSH key ----
    mkdir -m0700 /home/user1/.ssh/

    # SSH public key of PXE boot server (SSH client)
    cat <<EOF >/home/user1/.ssh/authorized_keys
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgnCcOFXIm9hmohfEURM7cgE4usT2VbASeoRY4Y/VzxIIgigv8C9+N4Rf4s+uj/65oCys8fHJsC0KCQELl3ORDbBew6wT0YgPKU9D1NjXYXS4DTHy5pkLIVLN05Vs+cSyZphRB4ofuRYIhumJrGV7KwwkRw8cjOkIiSQBAvNZYU8fGP5Z7jBc26UgTcnTp8/9Sf94o+TgmjNI7cagQetJD+RbZmR3dW9I0pHYKddr/TIWRkozZWNyaycVsBpBjQfPUYojENCJBaASRAvR21KpqHcxBWczSh8bc6AInAOEO2IpuJiXxZUkDcNX0BmwZvwcE6DsK8QlfYOyUyXhPzOg1 vagrant@pxeserver
    EOF

    # set permissions
    chmod 0600 /home/user1/.ssh/authorized_keys

    # fix up selinux context
    restorecon -R /home/user1/.ssh/

    # change owner from root to user1
    chown -R user1:user1 /home/user1/.ssh
    %end