Redes virtuales con Libvirt
===========================

.. contents:: Table of Contents

Podemos crear distintos tipos de redes virtuales con ``libvirt`` a través de dos herramientas distintas pero con resultados iguales. Una herramienta con interfaz gráfica para conseguir este objetivo es ``virt-manager`` la otra con interfaz de línea de comandos es ``virsh``. Algunas de las redes virtuales que podemos crear con ``libvirt`` son:

- `Red virtual Isolated`_
- `Red virtual Routed`_
- `Red virtual NATed`_
- Red virtual bridged 

El procedimiento general para crear una red virtual en ``virt-manager`` es entrar al programa, ir a :guilabel:`Edit` | :guilabel:`Connection details` | :guilabel:`Virtual Networks` | Clic en el signo :guilabel:`+`. Luego solo deberemos seguir el wizard de creación.

.. figure:: images/virt-manager-virtual-networks-tab.png
    :align: center

    ``virt-manager`` - Virtual Networks Tab

Por otro lado, los pasos generales para crear una red virtual en ``virsh`` serán escribir en un archivo XML las características que definan la red deseada y luego simplemente crearla en base a este archivo.

Red virtual Isolated
--------------------

Red cerrada para las VMs. Solo las VMs agregadas a esta red pueden comunicarse unas con otras. El host también podrá comunicarse con las VMs a añadidas a la red. El tráfico no pasará fuera del host, ni podrán recibir tráfico de fuera del host. Agregar una nueva interfaz a una VM es proceso simple que puede realizarse con ``virt-manager`` o ``virsh``:

.. figure:: images/mode_isolated.png
    :align: center

    `Isolated mode - Libvirt Wiki`_

Usando ``virt-manager``
'''''''''''''''''''''''

Los pasos para crear una red virtual aislada con ``virt-manager`` son los siguientes:

1. Ingresar un nombre para la red virtual:

.. figure:: images/virt-manager-isolated-step1.png
    :align: center

    ``virt-manager`` - Isolated virtual network - step 1

2. No realizaremos configuración IPv4:

.. figure:: images/virt-manager-isolated-step2.png
    :align: center

    ``virt-manager`` - Isolated virtual network - step 2

3. No haremos una configuración para IPv6:

.. figure:: images/virt-manager-isolated-step3.png
    :align: center

    ``virt-manager`` - Isolated virtual network - step 3

4. Solo mantener seleccionada la opción :guilabel:`Isoated virtual network` y dejar :guilabel:`DNS Domain Name` en blanco. Clic en :guilabel:`Finish` para crear la red virtual aislada:

.. figure:: images/virt-manager-isolated-step4.png
    :align: center

    ``virt-manager`` - Isolated virtual network - step 4

5. Revisar los detalles de la red virtual creada en la pestaña :guilabel:`Virtual Networks`:

.. figure:: images/virt-manager-virtual-network-isolated.png
    :align: center

    ``virt-manager`` - Isolated virtual network creada

Usando ``virsh``
''''''''''''''''

Para crear una red virtual isolated con ``virsh`` realizaremos los siguientes pasos:

1. Crear un archivo XML con el contenido que defina la red:

.. code-block:: bash

    $ cat isolated.xml 

.. code-block:: xml

    <network>
            <name>isolated</name>
    </network>

Según la sintáxis:

- ``<network>``: define la red virtual
- ``<name>``: define el nombre de la red virtual

2. Guardar el archivo XML. Para crear una red usando el archivo XML, usar la opción ``net-define`` del comando ``virsh`` seguido por la ruta del archivo XML:

.. code-block:: bash

    $ virsh net-define isolated.xml
    
    Network isolated defined from isolated.xml

3. Una vez que hemos definido una red con ``net-define``, el archivo de configuración será guardado en ``/etc/libvirt/qemu/networks/`` como un archivo XML con el mismo nombre que nuestra red virtual:

.. code-block:: bash

    $ sudo cat /etc/libvirt/qemu/networks/isolated.xml 

.. code-block:: xml

    <!--
    WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
    OVERWRITTEN AND LOST. Changes to this xml configuration should be made using:
    virsh net-edit isolated
    or other application using the libvirt API.
    -->

    <network>
        <name>isolated</name>
        <uuid>13fd5536-cad8-43a3-a066-91243719f95b</uuid>
        <bridge name='virbr1' stp='on' delay='0'/>
        <mac address='52:54:00:c4:d1:d7'/>
    </network>

``libvirt`` añadió el resto de parámetros requeridos, podremos agregarlos nosotros en el archivo XML cuando lo necesitemos al momento de crear el bridge.

Como vemos en el comentario del archivo, cualquier cambio para editar la red virtual deberá ser a través de ``virsh net-edit`` u otra aplicación que usa la API de ``libvirt``.

Red virtual Routed
------------------

En **modo routed**, la red virtual es conectada a la red física usando las rutas IP especificadas en el hypervisor. Estas rutas IP son usadas para enrutar el tráfico desde las VMs a la red conectada al hypervisor. La clave será configurar la ruta IP correcta en nuestro dispositivo router o gateway para que el paquete de respuesta alcance de vuelta al hypervisor. Si no existen rutas definidas, el paquete de respuesta nunca alcanzará al host.

En este modo todas las VMs están en una subred enrutada a través del switch virtual. Hasta este punto, los otros hosts en la red física no conocen que esta red existe o cómo llegar a ella. Por lo tanto, es necesario configurar rutas estáticas en la red física. En la siguiente gráfica el host actúa como router, permitiendo que equipos externos puedan comunicarse con la VM:

.. figure:: images/mode_routed.png
    :align: center

    `Routed mode - Libvirt Wiki`_

Usando ``virt-manager``
'''''''''''''''''''''''

Los pasos para crear una red modo routed usando ``virt-manager`` serán los siguientes:

1. Ingresar un nombre para la red virtual:

.. figure:: images/virt-manager-routed-step1.png
    :align: center

    ``virt-manager`` - Routed virtual network - step 1

2. En la siguiente pantalla habilitar IPv4 (:guilabel:`Enable IPv4 network address space definition`) y :guilabel:`DHCP` (:guilabel:`Enable DHCPv4`). Deshabilitar :guilabel:`Static Route`.

Definimos ``10.10.10.0/24`` como nuestra red. ``libvirt`` asignará automáticamente un gateway para nuestra red. Usualmente será la primera IP en el rango definido (``10.10.10.1`` en nuestro caso) y será asignado a la interfaz bridge. Podemos definir el rango DHCP según deseemos:

.. figure:: images/virt-manager-routed-step2.png
    :align: center

    ``virt-manager`` - Routed virtual network - step 2

3. No haremos una configuración para IPv6:

.. figure:: images/virt-manager-isolated-step3.png
    :align: center

    ``virt-manager`` - Routed virtual network - step 3

4. En el último paso, seleccionar la opción :guilabel:`Forwarding to physical network` y seleccionar la **interfaz host** donde deseamos que el tráfico sea **reenviado (forward)** desde la red virtual. Y seleccionar el :guilabel:`Mode` como :guilabel:`Routed`

.. figure:: images/virt-manager-routed-step4.png
    :align: center

    ``virt-manager`` - Routed virtual network - Step 4

5. Revisar los detalles de la red virtual creada en la pestaña :guilabel:`Virtual Networks`:

.. figure:: images/virt-manager-virtual-network-routed.png
    :align: center

    ``virt-manager`` - Routed virtual network creada

Usando ``virsh``
''''''''''''''''

Para crear una red virtual routed con ``virsh`` realizaremos los siguientes pasos:

1. Crear un archivo XML con el contenido que defina la red:

.. code-block:: bash

    $ cat routed.xml 

.. code-block:: xml

    <network>
        <name>routed</name>
        <forward dev='wlp2s0' mode='route'>
            <interface dev='wlp2s0' />
        </forward>
        <ip address='192.168.10.1' netmask='255.255.255.0'>
            <dhcp>
                <range start='192.168.10.128' end='192.168.10.254'/>
            </dhcp>
        </ip>
    </network>

Según la sintáxis:

- ``<network>``: define la red virtual
- ``<name>``: define el nombre de la red virtual
- ``<forward>``: configura el modo y el dispositivo de forwarding
- ``<ip>``: configura la dirección de red
- ``<dhcp><range>``: configura el rango DHCP de direcciones IP

2. Guardar el archivo XML. Para crear una red usando el archivo XML, usar la opción ``net-define`` del comando ``virsh`` seguido por la ruta del archivo XML:

.. code-block:: bash

    $ virsh net-define routed.xml
    
    Network routed defined from routed.xml

3. Una vez que hemos definido una red con ``net-define``, el archivo de configuración será guardado en ``/etc/libvirt/qemu/networks/`` como un archivo XML con el mismo nombre que nuestra red virtual:

.. code-block:: bash

    $ sudo cat /etc/libvirt/qemu/networks/routed.xml

.. code-block:: xml

    <!--
    WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
    OVERWRITTEN AND LOST. Changes to this xml configuration should be made using:
    virsh net-edit routed
    or other application using the libvirt API.
    -->

    <network>
    <name>routed</name>
    <uuid>43d8bf8b-3558-4ed0-85d3-66b8de7783ff</uuid>
    <forward dev='wlp2s0' mode='route'>
        <interface dev='wlp2s0'/>
    </forward>
    <bridge name='virbr2' stp='on' delay='0'/>
    <mac address='52:54:00:76:20:86'/>
    <ip address='192.168.10.1' netmask='255.255.255.0'>
        <dhcp>
            <range start='192.168.10.128' end='192.168.10.254'/>
        </dhcp>
    </ip>
    </network>

Red virtual NATed
-----------------

El **modo NATed** es el modo comúnmente usado en virtual networking cuando deseamos configurar un ambiente de pruebas en una máquina. Bajo este modo las VMs pueden comunicarse con el mundo exterior sin usar ninguna configuración adicional. También es posible la comunicación entre el hypervisor y las VMs. La gran desventaja de esta red virtual es que ninguno de los sistemas del exterior del hypervisor pueden llegar a las VMs.

La red virtual NATed es creada con ayuda de **iptables**, específicamente usando la opción **masquerading**. Entonces, si paramos el servicio de ``iptables`` mientras las VMs están siendo usadas puede ocasionar una error de red en las VMs.

.. figure:: images/mode_routed.png
    :align: center

    `NATed mode - Libvirt Wiki`_

Usando ``virt-manager``
'''''''''''''''''''''''

Los pasos para crear una red virtual en modo NATed a través de ``virt-manager`` son similares al modo Routed, a excepción del último paso:

1. Ingresar un nombre para la red virtual:

.. figure:: images/virt-manager-nated-step1.png
    :align: center

    ``virt-manager`` - NATed virtual network - step 1

2. En la siguiente pantalla habilitar IPv4 (:guilabel:`Enable IPv4 network address space definition`) y :guilabel:`DHCP` (:guilabel:`Enable DHCPv4`). Deshabilitar :guilabel:`Static Route`.

Definimos ``192.168.120.0`` como nuestra red. ``libvirt`` asignará automáticamente un gateway para nuestra red. Usualmente será la primera IP en el rango definido (``192.168.120.1`` en nuestro caso) y será asignado a la interfaz bridge. Podemos definir el rango DHCP según deseemos:

.. figure:: images/virt-manager-nated-step2.png
    :align: center

    ``virt-manager`` - NATed virtual network - step 2

3. No haremos una configuración para IPv6:

.. figure:: images/virt-manager-isolated-step3.png
    :align: center

    ``virt-manager`` - NATed virtual network - step 3

4. En el último paso, seleccionar la opción :guilabel:`Forwarding to physical network` y seleccionar la **interfaz host** hacia donde deseamos que el tráfico sea **NATeado** desde la red virtual. Y seleccionar el :guilabel:`Mode` como :guilabel:`NAT`

.. figure:: images/virt-manager-nated-step4.png
    :align: center

    ``virt-manager`` - NATed virtual network - step 3

5. Revisar los detalles de la red virtual creada en la pestaña :guilabel:`Virtual Networks`:

.. figure:: images/virt-manager-virtual-network-nated.png
    :align: center

    ``virt-manager`` - NATed virtual network creada

Siguientes pasos con ``virsh``
------------------------------

Crear una red temporal con ``virsh``
''''''''''''''''''''''''''''''''''''

``virsh net-create`` es similar a ``virsh net-define``. La diferencia es que no creará una **red virtual persistent**, en cambio, una vez que sea destruida será removida.

Listar redes con ``virsh``
''''''''''''''''''''''''''

Una vez que la red se ha creado podemos listar todas las redes usando el comando ``net-list``:

.. code-block:: bash

    $ virsh net-list --all

    Name                 State      Autostart     Persistent
    ----------------------------------------------------------
    default              active     yes           yes
    isolated             inactive   no            yes

Iniciar una red con ``virsh``
'''''''''''''''''''''''''''''

Para iniciar una red virtual usamos ``virsh net-start``:

.. code-block:: bash

    $ virsh net-start routed
    
    Network routed started

Configurar auto-start de una red con ``virsh``
''''''''''''''''''''''''''''''''''''''''''''''

Para activar **auto-start** de una red virtual usamos ``virsh net-autostart``:

.. code-block:: bash

    $ virsh net-autostart routed
    
    Network routed marked as autostarted

Agregar una interfaz de red virtual a una VM
--------------------------------------------

Para usar una red virtual que hemos creado debemos asociar la interfaz de red virtual de una VM al bridge de la red virtual creada.

Usando ``virt-manager``
'''''''''''''''''''''''

Podemos agregar una nueva interfaz virtual (o NIC virtual o vNIC) a una VM en ``virt-manager`` haciendo clic derecho en la VM | :guilabel:`Open` | :guilabel:`Show virtual hardware details` | :guilabel:`+ Add Hardware` | :guilabel:`Network` | en :guilabel:`Network source` elegir la red a la que deseamos conectar nuestra VM. La dirección MAC será generada or ``libvirt`` y el :guilabel:`Device model` como ``virtio``. Clic en :guilabel:`Finish`.

.. Note::

    Los dispositivos ``virtio`` están disponibles desde la versión de kernel de Linux 2.6.25.

.. figure:: images/virt-manager-new-interface.png
    :align: center

    ``virt-manager`` - Crear nueva interfaz de red virtual

Usando ``virsh``
''''''''''''''''

Para agregar una nueva interfaz virtual (o NIC virtual o vNIC) a una VM usando ``virsh`` sigamos los siguientes pasos:

1. Obtener el nombre de dominio de la VM (en este caso llamada ``centos7.0``) y usar el comando ``virsh attach-interface`` con ciertos parámetros:

.. code-block:: bash

    $ virsh attach-interface --domain centos7.0 --source isolated --type network --model virtio --config --live
    
    Interface attached successfully

Hemos conectado un interfaz virtual modelo ``virtio`` a la VM. La intefaz está usando un red virtual aislada. Hay dos opciones nuevas usadas en este comando:

- ``--config``: hace que el cambio sea persistente en la VM (es decir, no se borrará la próxima vez que arranquemos la VM). Quitar esta opción si queremos que el cambio sea temporal hasta el próximo arranque de la VM.
- ``--live``: informará a ``libvirt`` que estamos añadiendo la NIC a una VM que está corriendo. Quitar ``--live`` si la VM no está corriendo.

.. Note::

    Una opción extra es ``--mac`` que puede usarse para añadir una dirección MAC personalizada.

2. Veamos las interfaces añadidas a la VM con ``virsh domiflist``:

.. code-block:: bash

    $ virsh domiflist centos7.0
    Interface  Type       Source     Model       MAC
    -------------------------------------------------------
    vnet0      network    default    virtio      52:54:00:a9:f4:12
    vnet1      network    isolated   virtio      52:54:00:18:e3:75

3. Para eliminar la interfaz añadida a la VM usando ``virsh detach-interface``.

.. code-block:: bash

    $ sudo virsh detach-interface --domain centos7.0-2 --type network --mac 52:54:00:18:e3:75 --config --live

.. Caution::

    Tener cuidado al usar el parámetro ``--live`` al momento de quitar una interfaz de red virtual pues podría perder conectividad de red.

Ver propiedades de la red
-------------------------

Para ver las propiedades de una red virtual que hemos creados tenemos distintas opciones , ya sea por ``virt-manager`` o ``virsh``.

Por ejemplo cuando nosotros creamos una red virtual, por debajo, se crea un bridge. Si queremos ver el nombre del bridge creado usaremos cualquiera de estas opciones:

Propiedades de red con ``virt-manager``
'''''''''''''''''''''''''''''''''''''''

- ``virt-manager``: :guilabel:`Connection details` | :guilabel:`Virtual Networks` | sección :guilabel:`Device` de la red seleccionada.

Propiedades de red con ``virsh net-dumpxml``
''''''''''''''''''''''''''''''''''''''''''''

Cuando generamos una red con ``virsh`` en base al archivo XML que hemos creado, ``libvirt`` crea su propio archivo XML en la dirección ``/etc/libvirt/qemu/networks/`` con el mismo nombre de nuestra red virtual y parámetros adicionales para generar la red.

Usar el comando ``virsh net-dumpxml`` para obtener detalles de la red y el Linux bridge asociado:

.. code-block:: bash

    $ virsh net-dumpxml isolated

.. code-block:: xml

    <network>
        <name>isolated</name>
        <uuid>13fd5536-cad8-43a3-a066-91243719f95b</uuid>
        <bridge name='virbr1' stp='on' delay='0'/>
        <mac address='52:54:00:c4:d1:d7'/>
    </network>

Encontraremos que ``libvirt`` ha añadido unos cuantos parámetros adicionales:

- ``<uuid>``: un ID único de nuestro bridge
- ``<bridge>``: usado para definir los detalles del bridge. Nombre del bridge, estado de STP y Delay. Estos son los mismos comandos que podemos controlar usando el comando ``brctl`` (``stp`` configura el STP y ``setfd`` configura el DELAY).
- ``<mac>``: la dirección MAC del bridge asignada al momento de crearlo

Propiedades de red con ``virsh net-info``
'''''''''''''''''''''''''''''''''''''''''

.. code-block:: bash
    :emphasize-lines: 8

    $ virsh net-info routed

    Name:           routed
    UUID:           43d8bf8b-3558-4ed0-85d3-66b8de7783ff
    Active:         yes
    Persistent:     yes
    Autostart:      yes
    Bridge:         virbr2

Interfaces conectadas al bridge
'''''''''''''''''''''''''''''''

Ahora que conocemos el nombre del bridge veamos las interfaces conectadas a este:

.. code-block:: bash

    $ brctl show virbr1
    bridge name     bridge id               STP enabled     interfaces
    virbr1          8000.525400c4d1d7       yes             virbr1-nic
                                                            vnet1
                                                            vnet3

- La interfaz ``vibr1-nic`` es creada por ``libvirt`` cuando inicia el bridge ``virbr1``. El propósito de esta interfaz es proveer una dirección MAC consistente y confiable para el bridge ``virbr1``. El bridge copia la dirección MAC de la primera interfaz que es añadida al bridge. ``virbr1-nic`` siempre es la primera interfaz añadida al bridge por ``libvirt`` y no es eliminada hasta que se borre el bridge.
- ``vnet1`` y ``vnet3`` son las interfaces de red virtuales añadidas a sus respectivas VMs.

Editando una red virtual
------------------------

Editemos una red virtual modo routed y modifiquemos su configuración de enrutamiento para que los paquetes de las VMs sean reenviados a otra interfaz en el host según la reglas de rutas IP especificadas en el host.

Antes de editar la red virtual, primero debemos pararla:

.. code-block:: bash

    $ virsh net-destroy routed

    Network routed destroyed

Editar la red usando ``virsh net-edit``:

.. code-block:: bash

    $ virsh net-edit routed

    Network routed XML configuration edited.

Este comando hará una copia temporal del archivo de configuración usado por routed en ``/tmp`` y luego abrirá el editor de texto predeterminado. Editaremos la etiqueta ``<forward>``:

- Configuración antigua:

.. code-block:: xml

    <forward dev='wlp2s0' mode='route'>
        <interface dev='wlp2s0'/>
    </forward>

- Configuración nueva:

.. code-block:: xml

    <forward mode='route' />

Verificar la configuración con ``net-dumpxml``:

.. code-block:: bash

    $ virsh net-dumpxml routed

.. code-block:: xml

    <network>
    <name>routed</name>
    <uuid>43d8bf8b-3558-4ed0-85d3-66b8de7783ff</uuid>
    <forward mode='route'/>
    <bridge name='virbr2' stp='on' delay='0'/>
    <mac address='52:54:00:76:20:86'/>
    <ip address='192.168.10.1' netmask='255.255.255.0'>
        <dhcp>
            <range start='192.168.10.128' end='192.168.10.254'/>
        </dhcp>
    </ip>
    </network>

Luego de verificar la configuración, iniciar la red virtual con ``net-start``:

.. code-block:: bash

    $ virsh net-start routed

    Network routed started

Referencias
-----------

- `Isolated mode - Libvirt Wiki`_
- `Routed mode - Libvirt Wiki`_
- `NATed mode - Libvirt Wiki`_

.. _Isolated mode - Libvirt Wiki: https://wiki.libvirt.org/page/VirtualNetworking#Isolated_mode
.. _Routed mode - Libvirt Wiki: https://wiki.libvirt.org/page/VirtualNetworking#Routed_mode
.. _NATed mode - Libvirt Wiki: https://wiki.libvirt.org/page/VirtualNetworking#Network_Address_Translation_.28NAT.29