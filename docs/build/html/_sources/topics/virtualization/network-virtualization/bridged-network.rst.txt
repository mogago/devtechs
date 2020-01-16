Bridged Network
===============

.. contents:: Table of Contents

Usando una **Bridged Network** podemos lograr que una VM sea vista por la red como un dispositivo más, sin depender del host donde se encuentra. Es decir, con una **interfaz bridge** la VM podrá pertenecer al mismo segmento de red que el host y tener una IP dentro de ella.

.. figure:: images/bridged-network/bridged-network.png
    :align: center

    Esquema de Bridged Network

Host configuration
------------------

Método 1 - Usando ``iproute2``
''''''''''''''''''''''''''''''

En el **host** (máquina física) debemos realizar el siguiente procedimiento:

- Crear el bridge con ``ip link``:

.. code-block:: bash

    $ sudo ip link add name br0 type bridge

.. code-block:: bash

    $ ip link

    31: br0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default qlen 1000
        link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff

- Prender la interfaz del bridge

.. code-block:: bash

    $ sudo ip link set dev br0 up

.. code-block:: bash

    $ ip link

    31: br0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default qlen 1000
        link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff

- Prender la interfaz física que asociaremos al bridge (sin ninguna configuración/IP):

.. Important::

    La interfaz física no deberá tener asignada una IP y no deberá estar siendo usada por otro bridge. **Recomendación**: en una laptop podemos tener la salida a internet por la interfaz inalámbrica y usar la interfaz cableada para asociarla al bridge.

.. code-block:: bash

    $ sudo ip link set dev enp3s0 up

- Asociar la interfaz física (``enp3s0``) al bridge creado (``br0``):

.. code-block:: bash

    $ sudo ip link set dev enp3s0 master br0

.. code-block:: bash

    $ ip link

    2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master br0 state UP mode DEFAULT group default qlen 1000
        link/ether 08:9e:01:54:38:4c brd ff:ff:ff:ff:ff:ff

- Para remover la configuración realizada usar:

.. code-block:: bash

    # Desasociar la interfaz al bridge:
    $ sudo ip link set dev enp3s0 nomaster
    # Eliminar el bridge:
    $ sudo ip link delete br0

Método 2 - Usando ``bridge-utils``
''''''''''''''''''''''''''''''''''

- Crear un nuevo bridge:

.. code-block:: bash

    $ sudo brctl addbr br0

- Añadir la interfaz física al bridge:

.. code-block:: bash

    $ sudo brctl addif br0 enp3s0

- Verificar el bridge y las intefaces conectadas a él:

.. code-block:: bash

    $ brctl show
    bridge name	bridge id		    STP enabled	interfaces
    br2		    8000.94c691b241ed	no		    enp3s0

- Prender el bridge:

.. code-block:: bash
    
    $ sudo ip link set dev br0 up

.. code-block:: bash

    $ ip link

    2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master br0 state UP mode DEFAULT group default qlen 1000
        link/ether 94:c6:91:b2:41:ed brd ff:ff:ff:ff:ff:ff

    23: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
        link/ether 94:c6:91:b2:41:ed brd ff:ff:ff:ff:ff:ff
        inet6 fe80::96c6:91ff:feb2:41ed/64 scope link 
        valid_lft forever preferred_lft forever

- Para remover la configuración utilizada:

.. code-block:: bash

    # Apagar la interfaz del bridge:
    $ sudo ip link set dev br0 down
    # Eliminar el bridge:
    $ sudo brctl delbr br0

Método 3 - Usando ``virt-manager``
''''''''''''''''''''''''''''''''''

- Abrir ``virt-manager``, ir a la pestaña :guilabel:`Edit`, opción :guilabel:`Connection Details` :

.. figure:: images/bridged-network/bridge-kvm-1.png
    :align: center

    ``virt-manager`` - Bridged Network - Step 1

- En la nueva ventana, clic en el botón :guilabel:`+`:

.. figure:: images/bridged-network/bridge-kvm-2.png
    :align: center

    ``virt-manager`` - Bridged Network - Step 2

- :guilabel:`Interfaz type:` **Bridge**

.. figure:: images/bridged-network/bridge-kvm-3.png
    :align: center

    ``virt-manager`` - Bridged Network - Step 3

- Configurar la interfaz de red, especificando las interfaces que se conectarán al bridge:

.. figure:: images/bridged-network/bridge-kvm-4.png
    :align: center

    ``virt-manager`` - Bridged Network - Step 4

- Verificar que la interfaz se haya creado:

.. figure:: images/bridged-network/bridge-kvm-5.png
    :align: center

    ``virt-manager`` - Bridged Network - Step 5

- En una VM creada o que vayamos a crear se podrá elegir como :guilabel:`Network Source:` **Bridge br0: Host device enp3s0**

.. figure:: images/bridged-network/bridge-kvm-6.png
    :align: center

    ``virt-manager`` - Bridged Network - Step 6

Configuración final del host
----------------------------

- Iniciar la VM usando ``virt-install`` y el tag ``--network bridge=br0``:

.. code-block:: bash

    sudo virt-install --name=vc3 \
    --vcpus=2 \
    --memory=4096 \
    --network bridge=br0 \
    --disk path=/var/lib/libvirt/images/vc3.qcow2 \
    --import \
    --os-variant=ubuntu18.04 &

- Si abrimos la aplicación de ``virt-manager`` veremos que el nombre de la interfaz que posee la VM es: :guilabel:`Bridge br0: Host device vnet0`

- Luego de asociar la interfaz física al bridge se tendrá `problemas de conexión a internet desde el host`_. Esto se debe a que ahora la interfaz física es un puerto del switch y su configuración IP individual no importa.

.. _problemas de conexión a internet desde el host: https://superuser.com/questions/694661/losing-internet-access-when-creating-ethernet-bridge-for-openvpn

No tenemos conexión a Internet pues la interfaz ``br0`` no tiene IP. Por tanto, hay que remover la configuración IP de la interfaz física ``enp3s0`` y realizar una configuraración IP en el bridge ``br0``:

.. code-block:: bash

    # Remover configuración a interfaz física:
    $ sudo dhclient -r enp3s0
    # Agregar configuración a interfaz bridge:
    $ sudo dhclient -v br0

Guest configuration
-------------------

En el **guest** (VM) la configuración de red será automática según la red a la que se encuentre conectada nuestra interfaz física y el servidor DHCP que exista en la red:

.. code-block:: bash

    $ ip addr

    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
        valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host 
        valid_lft forever preferred_lft forever
    2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 52:54:00:3f:78:e2 brd ff:ff:ff:ff:ff:ff
        inet 192.168.1.24/24 brd 192.168.1.255 scope global dynamic ens3
        valid_lft 85847sec preferred_lft 85847sec
        inet6 2800:200:e840:125c:5054:ff:fe3f:78e2/64 scope global dynamic mngtmpaddr noprefixroute 
        valid_lft 3598sec preferred_lft 3598sec
        inet6 fe80::5054:ff:fe3f:78e2/64 scope link 
        valid_lft forever preferred_lft forever

Podremos crear varias VMs y el servidor DHCP dentro de la red le asignará una IP a cada una de ellas al momento de bootear la VM.

Referencias
-----------

- `Tutorial Youtube - Setting Up Network Bridge`_
- `Tutorial Network Bridge`_
- `Bridge Interface`_
- `Losing internet access on host with network bridge`_

.. _Tutorial Youtube - Setting Up Network Bridge: https://www.youtube.com/watch?v=Q1PebvpQUvI
.. _Tutorial Network Bridge: https://wiki.archlinux.org/index.php/Network_bridge
.. _Bridge Interface: https://developers.redhat.com/blog/2018/10/22/introduction-to-linux-interfaces-for-virtual-networking/#bridge
.. _Losing internet access on host with network bridge: https://superuser.com/questions/694661/losing-internet-access-when-creating-ethernet-bridge-for-openvpn