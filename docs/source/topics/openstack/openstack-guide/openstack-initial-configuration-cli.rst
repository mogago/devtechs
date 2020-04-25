Configuración inicial de OpenStack
----------------------------------

.. contents:: Table of Contents

Usar credenciales de usuario
''''''''''''''''''''''''''''

En el CLI, usar las credenciales del usuario ``admin``

.. code-block:: bash

    '#' cd /root/
    '#' source keystonerc_admin

Crear un nuevo proyecto
'''''''''''''''''''''''

.. code-block:: bash

    '#' openstack project create --description "for testing purposes" testproject

    +-------------+----------------------------------+
    | Field       | Value                            |
    +-------------+----------------------------------+
    | description | for testing purposes             |
    | domain_id   | default                          |
    | enabled     | True                             |
    | id          | 99d8a6cd24734f2aa3fe70140fbdbd64 |
    | is_domain   | False                            |
    | name        | testproject                      |
    | parent_id   | default                          |
    | tags        | []                               |
    +-------------+----------------------------------+

Creación de un usuario asignado a un proyecto
'''''''''''''''''''''''''''''''''''''''''''''

1. Crear un usuario y añadirlo a un proyecto al momento de ser creado:

.. code-block:: bash

    '#' openstack user create --project testproject --password-prompt testuser1

    User Password:
    Repeat User Password:
    +---------------------+----------------------------------+
    | Field               | Value                            |
    +---------------------+----------------------------------+
    | default_project_id  | 99d8a6cd24734f2aa3fe70140fbdbd64 |
    | domain_id           | default                          |
    | enabled             | True                             |
    | id                  | 6643474fffb548b4bd4fb3d6a09d9ecd |
    | name                | testuser1                        |
    | options             | {}                               |
    | password_expires_at | None                             |
    +---------------------+----------------------------------+

2. Asignar los roles ``_member_`` y ``admin`` al usuario creado:

.. code-block:: bash

    '#' openstack role add --project testproject --user testuser1 _member_

    '#' openstack role assignment list --project testproject --user testuser1

    +----------------------------------+----------------------------------+-------+----------------------------------+--------+-----------+
    | Role                             | User                             | Group | Project                          | Domain | Inherited |
    +----------------------------------+----------------------------------+-------+----------------------------------+--------+-----------+
    | 75dbe014bfa54197890b46a034f4661e | 6643474fffb548b4bd4fb3d6a09d9ecd |       | 99d8a6cd24734f2aa3fe70140fbdbd64 |        | False     |
    +----------------------------------+----------------------------------+-------+----------------------------------+--------+-----------+

.. Important::

    Si queremos que nuestro usuario tenga permisos de administrador, ejecutar la siguiente línea:

    .. code-block:: bash

        '#' openstack role add --project testproject --user testuser1 admin

Creación de credenciales CLI para un usuario
''''''''''''''''''''''''''''''''''''''''''''

.. code-block:: bash
    :emphasize-lines: 5,6,9,11

    '#' cp keystonerc_admin keystonerc_testuser1

    '#' cat <<- EOF > keystonerc_testuser1
    unset OS_SERVICE_TOKEN
        export OS_USERNAME=testuser1
        export OS_PASSWORD=testuser1
        export OS_REGION_NAME=RegionOne
        export OS_AUTH_URL=http://192.168.1.100:5000/v3
        export PS1='[\u@\h \W(testuser1)]\$ '

    export OS_PROJECT_NAME=testproject
    export OS_USER_DOMAIN_NAME=Default
    export OS_PROJECT_DOMAIN_NAME=Default
    export OS_IDENTITY_API_VERSION=3
    EOF

Creación de un flavor
'''''''''''''''''''''

Nuevo flavor llamado ``m1.tiniest`` con id ``10``, RAM de 128 MB y 1GB de almacenamiento:

.. code-block:: bash

    '#' openstack flavor create --id 10 --ram 128 --disk 1 --public m1.tiniest

    +----------------------------+------------+
    | Field                      | Value      |
    +----------------------------+------------+
    | OS-FLV-DISABLED:disabled   | False      |
    | OS-FLV-EXT-DATA:ephemeral  | 0          |
    | disk                       | 1          |
    | id                         | 10         |
    | name                       | m1.tiniest |
    | os-flavor-access:is_public | True       |
    | properties                 |            |
    | ram                        | 128        |
    | rxtx_factor                | 1.0        |
    | swap                       |            |
    | vcpus                      | 1          |
    +----------------------------+------------+

    '#' openstack flavor list

    +----+------------+-------+------+-----------+-------+-----------+
    | ID | Name       |   RAM | Disk | Ephemeral | VCPUs | Is Public |
    +----+------------+-------+------+-----------+-------+-----------+
    | 1  | m1.tiny    |   512 |    1 |         0 |     1 | True      |
    | 10 | m1.tiniest |   128 |    1 |         0 |     1 | True      |
    | 2  | m1.small   |  2048 |   20 |         0 |     1 | True      |
    | 3  | m1.medium  |  4096 |   40 |         0 |     2 | True      |
    | 4  | m1.large   |  8192 |   80 |         0 |     4 | True      |
    | 5  | m1.xlarge  | 16384 |  160 |         0 |     8 | True      |
    +----+------------+-------+------+-----------+-------+-----------+

Crear una imagen
''''''''''''''''

1. Descargar la imagen:

.. code-block:: bash

    '#' mkdir /root/images
    '#' curl -o /root/images/cirros-0.4.0-x86_64-disk.img -L http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img

.. Note::

    Usar la opción ``-L`` de ``curl`` para rehacer el pedido en la ubicación indicada.

    - Referencia 1: `Comando curl no descarga el archivo`_
    - Referencia 2: `Descargar con curl usando -L para seguir los redirects`_

.. _Comando curl no descarga el archivo: https://stackoverflow.com/questions/27458797/curl-command-doesnt-download-the-file-linux-mint
.. _Descargar con curl usando -L para seguir los redirects: https://stackoverflow.com/questions/5746325/how-do-i-download-a-tarball-from-github-using-curl

.. Note::

    Con ``wget``:

    .. code-block:: bash

        '#' yum install -y wget
        '#' wget -P /root/images http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img

2. Crear una imagen pública con los requerimientos mínimos de almacenamiento y memoria RAM para el uso de esa imagen:

.. code-block:: bash

    '#' openstack image create --min-disk 1 --min-ram 128 --public --disk-format qcow2 --file /root/images/cirros-0.4.0-x86_64-disk.img cirros

    +------------------+------------------------------------------------------+
    | Field            | Value                                                |
    +------------------+------------------------------------------------------+
    | checksum         | 443b7623e27ecf03dc9e01ee93f67afe                     |
    | container_format | bare                                                 |
    | created_at       | 2020-02-11T02:53:24Z                                 |
    | disk_format      | qcow2                                                |
    | file             | /v2/images/56dd3671-de42-40db-9637-7c5bef599d11/file |
    | id               | 56dd3671-de42-40db-9637-7c5bef599d11                 |
    | min_disk         | 1                                                    |
    | min_ram          | 128                                                  |
    | name             | cirros                                               |
    | owner            | 99d8a6cd24734f2aa3fe70140fbdbd64                     |
    | protected        | False                                                |
    | schema           | /v2/schemas/image                                    |
    | size             | 12716032                                             |
    | status           | active                                               |
    | tags             |                                                      |
    | updated_at       | 2020-02-11T02:53:24Z                                 |
    | virtual_size     | None                                                 |
    | visibility       | public                                               |
    +------------------+------------------------------------------------------+

    '#' openstack image list

    +--------------------------------------+--------+--------+
    | ID                                   | Name   | Status |
    +--------------------------------------+--------+--------+
    | 2995472e-5c8b-4828-af2c-0104b24db391 | cirros | active |
    +--------------------------------------+--------+--------+

Ver configuración de red
''''''''''''''''''''''''

Comprobar que tenemos los agentes de red necesarios para la gestión de redes con OpenStack:

.. code-block:: bash

    '#' openstack network agent list

    +--------------------------------------+--------------------+-----------------------------+-------------------+-------+-------+---------------------------+
    | ID                                   | Agent Type         | Host                        | Availability Zone | Alive | State | Binary                    |
    +--------------------------------------+--------------------+-----------------------------+-------------------+-------+-------+---------------------------+
    | 1755e383-779d-430e-836c-d5ab6300247e | Open vSwitch agent | controllernode1.localdomain | None              | :-)   | UP    | neutron-openvswitch-agent |
    | 72d25877-3746-4ebd-bda7-586bd5ee2ddf | Open vSwitch agent | computenode1.localdomain    | None              | :-)   | UP    | neutron-openvswitch-agent |
    | ffe83ae4-da2a-411a-a535-8f1fdbf06e60 | Open vSwitch agent | computenode2.localdomain    | None              | :-)   | UP    | neutron-openvswitch-agent |
    | 4aff7724-1a9e-42b7-aad3-142fd5c1d736 | DHCP agent         | controllernode1.localdomain | nova              | :-)   | UP    | neutron-dhcp-agent        |
    | 8a45485e-f1d8-46ff-a0e4-440f98f377fc | Metering agent     | controllernode1.localdomain | None              | :-)   | UP    | neutron-metering-agent    |
    | f533494b-9071-4159-ae80-12ae96534c77 | L3 agent           | controllernode1.localdomain | nova              | :-)   | UP    | neutron-l3-agent          |
    | fc03ca4e-a5e4-469b-bbb8-9253248e40a6 | Metadata agent     | controllernode1.localdomain | None              | :-)   | UP    | neutron-metadata-agent    |
    +--------------------------------------+--------------------+-----------------------------+-------------------+-------+-------+---------------------------+

.. Note::

    Por cada Nodo contamos con un agente Open vSwitch (controller node, compute node 1 y compute node 2)

Podemos verificar el estado de cada servicio usando el binario de la tabla así como del proceso ``neutron-server`` en sí:

.. code-block:: bash

    '#' systemctl status neutron-server neutron-openvswitch-agent neutron-dhcp-agent neutron-metering-agent neutron-l3-agent neutron-metadata-agent

- Ver los OVS bridges que tenemos creados y los puertos conectados:

.. code-block:: bash

    '#' ovs-vsctl show

    496c7134-8b33-4aa9-b752-ab503fccd5d6
        Manager "ptcp:6640:127.0.0.1"
            is_connected: true
        Bridge br-int
            Controller "tcp:127.0.0.1:6633"
                is_connected: true
            fail_mode: secure
            Port br-int
                Interface br-int
                    type: internal
            Port patch-tun
                Interface patch-tun
                    type: patch
                    options: {peer=patch-int}
            Port int-br-ex
                Interface int-br-ex
                    type: patch
                    options: {peer=phy-br-ex}
        Bridge br-tun
            Controller "tcp:127.0.0.1:6633"
                is_connected: true
            fail_mode: secure
            Port br-tun
                Interface br-tun
                    type: internal
            Port "vxlan-0a0a0a66"
                Interface "vxlan-0a0a0a66"
                    type: vxlan
                    options: {df_default="true", egress_pkt_mark="0", in_key=flow, local_ip="192.168.1.100", out_key=flow, remote_ip="10.10.10.102"}
            Port patch-int
                Interface patch-int
                    type: patch
                    options: {peer=patch-tun}
            Port "vxlan-0a0a0a65"
                Interface "vxlan-0a0a0a65"
                    type: vxlan
                    options: {df_default="true", egress_pkt_mark="0", in_key=flow, local_ip="192.168.1.100", out_key=flow, remote_ip="10.10.10.101"}
        Bridge br-ex
            Controller "tcp:127.0.0.1:6633"
                is_connected: true
            fail_mode: secure
            Port br-ex
                Interface br-ex
                    type: internal
            Port phy-br-ex
                Interface phy-br-ex
                    type: patch
                    options: {peer=int-br-ex}
            Port "enp0s3"
                Interface "enp0s3"
        ovs_version: "2.11.0"

.. Note::

    Los bridges creados por defecto al instalar OpenStack son ``br-int`` (integration bridge), ``br-tun`` (tunnel bridge), y ``br-ex`` (external bridge).

Crear una red y una subred internas
'''''''''''''''''''''''''''''''''''

Link: `Create and manage networks - Openstack Docs`_

.. _Create and manage networks - Openstack Docs: https://docs.openstack.org/ocata/user-guide/cli-create-and-manage-networks.html

1. Crear una red:

.. code-block:: bash

    '#' source keystonerc_testuser1

    '#' openstack network create intnet

    +---------------------------+--------------------------------------+
    | Field                     | Value                                |
    +---------------------------+--------------------------------------+
    | admin_state_up            | UP                                   |
    | availability_zone_hints   |                                      |
    | availability_zones        |                                      |
    | created_at                | 2020-02-10T23:19:50Z                 |
    | description               |                                      |
    | dns_domain                | None                                 |
    | id                        | 2cf9c274-8592-476b-bde5-41e930e01577 |
    | ipv4_address_scope        | None                                 |
    | ipv6_address_scope        | None                                 |
    | is_default                | False                                |
    | is_vlan_transparent       | None                                 |
    | mtu                       | 1450                                 |
    | name                      | intnet                               |
    | port_security_enabled     | True                                 |
    | project_id                | 99d8a6cd24734f2aa3fe70140fbdbd64     |
    | provider:network_type     | vxlan                                |
    | provider:physical_network | None                                 |
    | provider:segmentation_id  | 84                                   |
    | qos_policy_id             | None                                 |
    | revision_number           | 2                                    |
    | router:external           | Internal                             |
    | segments                  | None                                 |
    | shared                    | False                                |
    | status                    | ACTIVE                               |
    | subnets                   |                                      |
    | tags                      |                                      |
    | updated_at                | 2020-02-10T23:19:50Z                 |
    +---------------------------+--------------------------------------+

La red creada usará algunos parámetros por defecto:

- ``provider:network_type``: ``vxlan`` - El tipo de red por defecto es VXLAN
- ``provider:physical_network``: ``None`` - La red virtual no se implementará sobre una red física
- ``router:external``: ``Internal`` - Configurar esta red como interna

2. Crear una subred asociada a la red creada:

.. code-block:: bash

    '#' openstack subnet create subnet1 --subnet-range 10.5.5.0/24 --dns-nameserver 8.8.8.8 --network intnet

    +-------------------+--------------------------------------+
    | Field             | Value                                |
    +-------------------+--------------------------------------+
    | allocation_pools  | 10.5.5.2-10.5.5.254                  |
    | cidr              | 10.5.5.0/24                          |
    | created_at        | 2020-02-10T23:44:17Z                 |
    | description       |                                      |
    | dns_nameservers   | 8.8.8.8                              |
    | enable_dhcp       | True                                 |
    | gateway_ip        | 10.5.5.1                             |
    | host_routes       |                                      |
    | id                | 8168b012-2c3c-4114-8145-963dd6646793 |
    | ip_version        | 4                                    |
    | ipv6_address_mode | None                                 |
    | ipv6_ra_mode      | None                                 |
    | name              | subnet1                              |
    | network_id        | 2cf9c274-8592-476b-bde5-41e930e01577 |
    | prefix_length     | None                                 |
    | project_id        | 99d8a6cd24734f2aa3fe70140fbdbd64     |
    | revision_number   | 0                                    |
    | segment_id        | None                                 |
    | service_types     |                                      |
    | subnetpool_id     | None                                 |
    | tags              |                                      |
    | updated_at        | 2020-02-10T23:44:17Z                 |
    +-------------------+--------------------------------------+

- La subred creada tiene el ID de la red ``intnet`` asociada a ella.
- Cuenta con un pool de direcciones reservadas para asignar: ``10.5.5.2-10.5.5.254``
- Se estableció como servidor DNS la IP ``8.8.8.8``

Link del comando: `subnet - Openstack Docs`_

.. _subnet - Openstack Docs: https://docs.openstack.org/python-openstackclient/pike/cli/command-objects/subnet.html

Además se han configurado unas opciones en la subred por defecto:

- Se establece como su gateway IP a la primera dirección IP del rango CIDR: ``10.5.5.1``
- ``dhcp`` está habilitado, por tanto se creó un namespace DHCP con una interfaz ``tap`` a la que se le agregó una IP dentro de la subred (Generalmente la IP ``.2``). Además, este namespace tiene su interfaz conectada al bridge ``br-int``:

.. code-block:: bash

    '#' ip netns
    
    qdhcp-2cf9c274-8592-476b-bde5-41e930e01577 (id: 0)

    '#' ip netns exec qdhcp-2cf9c274-8592-476b-bde5-41e930e01577 ip addr

    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
            valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host 
            valid_lft forever preferred_lft forever
    13: tapa2009c32-11: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN group default qlen 1000
        link/ether fa:16:3e:51:a7:89 brd ff:ff:ff:ff:ff:ff
        inet 10.5.5.2/24 brd 10.5.5.255 scope global tapa2009c32-11
            valid_lft forever preferred_lft forever
        inet6 fe80::f816:3eff:fe51:a789/64 scope link 
            valid_lft forever preferred_lft forever

    '#' ovs-vsctl show

    496c7134-8b33-4aa9-b752-ab503fccd5d6
        Manager "ptcp:6640:127.0.0.1"
            is_connected: true
        Bridge br-int
            Controller "tcp:127.0.0.1:6633"
                is_connected: true
            fail_mode: secure
            Port "tapa2009c32-11"
                tag: 3
                Interface "tapa2009c32-11"
                    type: internal
            Port br-int
                Interface br-int
                    type: internal
            Port patch-tun
                Interface patch-tun
                    type: patch
                    options: {peer=patch-int}
            Port int-br-ex
                Interface int-br-ex
                    type: patch
                    options: {peer=phy-br-ex}
        ...

.. Important::

    Los namespaces proveen aislamiento de tráfico en Neutron. Para cada nuevo servidor DHCP, se crea un nuevo namespace. Así podemos diferenciar el tráfico entre distintos proyectos.
    
    Si se agregaran más subredes con ``dhcp`` habilitado dentro de la misma red, se agregaría una IP extra a la misma interfaz ``tap`` del mismo namespace DHCP.

    .. code-block:: bash

        '#' ip netns exec qdhcp-2cf9c274-8592-476b-bde5-41e930e01577 ip addr

        1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
            link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
            inet 127.0.0.1/8 scope host lo
                valid_lft forever preferred_lft forever
            inet6 ::1/128 scope host 
                valid_lft forever preferred_lft forever
        12: tapfbe9d2c4-80: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN group default qlen 1000
            link/ether fa:16:3e:05:dd:2e brd ff:ff:ff:ff:ff:ff
            inet 10.5.7.2/24 brd 10.5.7.255 scope global tapfbe9d2c4-80
                valid_lft forever preferred_lft forever
            inet 10.5.8.2/24 brd 10.5.8.255 scope global tapfbe9d2c4-80
                valid_lft forever preferred_lft forever
            inet6 fe80::f816:3eff:fe05:dd2e/64 scope link 
                valid_lft forever preferred_lft forever

Crear un router
'''''''''''''''

1. Crear un router sin interfaces conectadas a él:

.. code-block:: bash

    '#' openstack router create R1

    +-------------------------+--------------------------------------+
    | Field                   | Value                                |
    +-------------------------+--------------------------------------+
    | admin_state_up          | UP                                   |
    | availability_zone_hints |                                      |
    | availability_zones      |                                      |
    | created_at              | 2020-02-11T00:08:40Z                 |
    | description             |                                      |
    | distributed             | False                                |
    | external_gateway_info   | None                                 |
    | flavor_id               | None                                 |
    | ha                      | False                                |
    | id                      | d4cb763e-8578-484d-be6a-6d7da165e161 |
    | name                    | R1                                   |
    | project_id              | 99d8a6cd24734f2aa3fe70140fbdbd64     |
    | revision_number         | 1                                    |
    | routes                  |                                      |
    | status                  | ACTIVE                               |
    | tags                    |                                      |
    | updated_at              | 2020-02-11T00:08:40Z                 |
    +-------------------------+--------------------------------------+

2. Conectar el router con una subred:

.. code-block:: bash

    '#' openstack router add subnet R1 subnet1

- Comprobar cambios de configuración:

.. code-block:: bash
    :emphasize-lines: 21-24

    '#' ovs-vsctl show

    496c7134-8b33-4aa9-b752-ab503fccd5d6
        Manager "ptcp:6640:127.0.0.1"
            is_connected: true
        Bridge br-int
            Controller "tcp:127.0.0.1:6633"
                is_connected: true
            fail_mode: secure
            Port "tapa2009c32-11"
                tag: 3
                Interface "tapa2009c32-11"
                    type: internal
            Port br-int
                Interface br-int
                    type: internal
            Port patch-tun
                Interface patch-tun
                    type: patch
                    options: {peer=patch-int}
            Port "qr-4c7615a5-dd"
                tag: 3
                Interface "qr-4c7615a5-dd"
                    type: internal
            Port int-br-ex
                Interface int-br-ex
                    type: patch
                    options: {peer=phy-br-ex}

    '#' ip netns

    qrouter-d4cb763e-8578-484d-be6a-6d7da165e161 (id: 1)
    qdhcp-2cf9c274-8592-476b-bde5-41e930e01577 (id: 0)

    '#' openstack router show R1

    +-------------------------+--------------------------------------------------------------------------------------------------------------------------------------+
    | Field                   | Value                                                                                                                                |
    +-------------------------+--------------------------------------------------------------------------------------------------------------------------------------+
    | admin_state_up          | UP                                                                                                                                   |
    | availability_zone_hints |                                                                                                                                      |
    | availability_zones      | nova                                                                                                                                 |
    | created_at              | 2020-02-11T00:08:40Z                                                                                                                 |
    | description             |                                                                                                                                      |
    | distributed             | False                                                                                                                                |
    | external_gateway_info   | None                                                                                                                                 |
    | flavor_id               | None                                                                                                                                 |
    | ha                      | False                                                                                                                                |
    | id                      | d4cb763e-8578-484d-be6a-6d7da165e161                                                                                                 |
    | interfaces_info         | [{"subnet_id": "8168b012-2c3c-4114-8145-963dd6646793", "ip_address": "10.5.5.1", "port_id": "4c7615a5-dd19-43d8-833f-37e3505b8175"}] |
    | name                    | R1                                                                                                                                   |
    | project_id              | 99d8a6cd24734f2aa3fe70140fbdbd64                                                                                                     |
    | revision_number         | 2                                                                                                                                    |
    | routes                  |                                                                                                                                      |
    | status                  | ACTIVE                                                                                                                               |
    | tags                    |                                                                                                                                      |
    | updated_at              | 2020-02-11T00:10:29Z                                                                                                                 |
    +-------------------------+--------------------------------------------------------------------------------------------------------------------------------------+

    '#' ip netns exec qrouter-d4cb763e-8578-484d-be6a-6d7da165e161 ip addr

    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
            valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host 
            valid_lft forever preferred_lft forever
    14: qr-4c7615a5-dd: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN group default qlen 1000
        link/ether fa:16:3e:80:07:21 brd ff:ff:ff:ff:ff:ff
        inet 10.5.5.1/24 brd 10.5.5.255 scope global qr-4c7615a5-dd
            valid_lft forever preferred_lft forever
        inet6 fe80::f816:3eff:fe80:721/64 scope link 
            valid_lft forever preferred_lft forever

.. Note::

    Luego de conectar el router a la subred interna, se ha creado una interfaz en el router con una IP dentro de la subred conectada. Además, el OVS bridge ``br-int`` tiene un nuevo puerto con esta interfaz conectada.

3. Establecer el gateway para nuestro router:

.. code-block:: bash

    # Con Neutron (deprecated): neutron router-gateway-set R1 external_network
    '#' openstack router set R1 --external-gateway external_network

- Comprobar cambios de configuración:

.. code-block:: bash
    :emphasize-lines: 17-20

    '#' ovs-vsctl show

    496c7134-8b33-4aa9-b752-ab503fccd5d6
        Manager "ptcp:6640:127.0.0.1"
            is_connected: true
        Bridge br-int
            Controller "tcp:127.0.0.1:6633"
                is_connected: true
            fail_mode: secure
            Port "tapa2009c32-11"
                tag: 3
                Interface "tapa2009c32-11"
                    type: internal
            Port br-int
                Interface br-int
                    type: internal
            Port "qg-e364542a-a5"
                tag: 4
                Interface "qg-e364542a-a5"
                    type: internal
            Port patch-tun
                Interface patch-tun
                    type: patch
                    options: {peer=patch-int}
            Port "qr-4c7615a5-dd"
                tag: 3
                Interface "qr-4c7615a5-dd"
                    type: internal
            Port int-br-ex
                Interface int-br-ex
                    type: patch
                    options: {peer=phy-br-ex}

    '#' openstack router show R1

    +-------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Field                   | Value                                                                                                                                                                                     |
    +-------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | admin_state_up          | UP                                                                                                                                                                                        |
    | availability_zone_hints |                                                                                                                                                                                           |
    | availability_zones      | nova                                                                                                                                                                                      |
    | created_at              | 2020-02-11T00:08:40Z                                                                                                                                                                      |
    | description             |                                                                                                                                                                                           |
    | distributed             | False                                                                                                                                                                                     |
    | external_gateway_info   | {"network_id": "f5dad5c1-bba9-41c5-844f-bd19a6a124aa", "enable_snat": true, "external_fixed_ips": [{"subnet_id": "a6ae14ab-2287-4d0d-b8eb-0f503792f32c", "ip_address": "192.168.1.151"}]} |
    | flavor_id               | None                                                                                                                                                                                      |
    | ha                      | False                                                                                                                                                                                     |
    | id                      | d4cb763e-8578-484d-be6a-6d7da165e161                                                                                                                                                      |
    | interfaces_info         | [{"subnet_id": "8168b012-2c3c-4114-8145-963dd6646793", "ip_address": "10.5.5.1", "port_id": "4c7615a5-dd19-43d8-833f-37e3505b8175"}]                                                      |
    | name                    | R1                                                                                                                                                                                        |
    | project_id              | 99d8a6cd24734f2aa3fe70140fbdbd64                                                                                                                                                          |
    | revision_number         | 4                                                                                                                                                                                         |
    | routes                  |                                                                                                                                                                                           |
    | status                  | ACTIVE                                                                                                                                                                                    |
    | tags                    |                                                                                                                                                                                           |
    | updated_at              | 2020-02-11T00:53:20Z                                                                                                                                                                      |
    +-------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

    '#' ip netns exec qrouter-d4cb763e-8578-484d-be6a-6d7da165e161 ip addr

    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
        valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host 
        valid_lft forever preferred_lft forever
    14: qr-4c7615a5-dd: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN group default qlen 1000
        link/ether fa:16:3e:80:07:21 brd ff:ff:ff:ff:ff:ff
        inet 10.5.5.1/24 brd 10.5.5.255 scope global qr-4c7615a5-dd
        valid_lft forever preferred_lft forever
        inet6 fe80::f816:3eff:fe80:721/64 scope link 
        valid_lft forever preferred_lft forever
    15: qg-e364542a-a5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default qlen 1000
        link/ether fa:16:3e:be:4c:9a brd ff:ff:ff:ff:ff:ff
        inet 192.168.1.151/24 brd 192.168.1.255 scope global qg-e364542a-a5
        valid_lft forever preferred_lft forever
        inet6 2800:200:e840:2918:f816:3eff:febe:4c9a/64 scope global mngtmpaddr dynamic 
        valid_lft 3598sec preferred_lft 3598sec
        inet6 fe80::f816:3eff:febe:4c9a/64 scope link 
        valid_lft forever preferred_lft forever

.. Note::

    Luego de establecer el gateway para nuestro router se crea una nueva interfaz en el router y se le asigna una IP dentro del rango de IPs a la subred que tiene como gateway (red externa en este caso). Viendo la información del router vemos que se trata de un SNAT.

Listar las redes y subredes creadas
'''''''''''''''''''''''''''''''''''

- Podemos ver que contamos con una red interna y otra externa:

.. code-block:: bash

    '#' openstack network list

    +--------------------------------------+------------------+--------------------------------------+
    | ID                                   | Name             | Subnets                              |
    +--------------------------------------+------------------+--------------------------------------+
    | 2cf9c274-8592-476b-bde5-41e930e01577 | intnet           | 8168b012-2c3c-4114-8145-963dd6646793 |
    | f5dad5c1-bba9-41c5-844f-bd19a6a124aa | external_network | a6ae14ab-2287-4d0d-b8eb-0f503792f32c |
    +--------------------------------------+------------------+--------------------------------------+

- Para cada red creada se le ha asignado una subred:

.. code-block:: bash

    '#' openstack subnet list

    +--------------------------------------+---------------+--------------------------------------+----------------+
    | ID                                   | Name          | Network                              | Subnet         |
    +--------------------------------------+---------------+--------------------------------------+----------------+
    | 8168b012-2c3c-4114-8145-963dd6646793 | subnet1       | 2cf9c274-8592-476b-bde5-41e930e01577 | 10.5.5.0/24    |
    | a6ae14ab-2287-4d0d-b8eb-0f503792f32c | public_subnet | f5dad5c1-bba9-41c5-844f-bd19a6a124aa | 192.168.1.0/24 |
    +--------------------------------------+---------------+--------------------------------------+----------------+

Editar el security group de un proyecto
'''''''''''''''''''''''''''''''''''''''

1. Obtener el ID del security group de un proyecto:

- Listar proyectos:

.. code-block:: bash

    '#' openstack project list

    +----------------------------------+-------------+
    | ID                               | Name        |
    +----------------------------------+-------------+
    | 0c2bc29526f4465c95b8eaefcfae7b7c | admin       |
    | 99d8a6cd24734f2aa3fe70140fbdbd64 | testproject |
    | ed14e8f780b84664accc6aa2d6673624 | services    |
    +----------------------------------+-------------+

- Ver el ID del security group según el ID del proyecto:

.. code-block:: bash

    '#' openstack security group list

    +--------------------------------------+---------+------------------------+----------------------------------+
    | ID                                   | Name    | Description            | Project                          |
    +--------------------------------------+---------+------------------------+----------------------------------+
    | 2bc3934c-debf-4477-917c-9f01e23e366e | default | Default security group |                                  |
    | 3a9e73cd-0608-49bf-b295-94b987a920ec | default | Default security group | 99d8a6cd24734f2aa3fe70140fbdbd64 |
    | 7e145dac-5186-4b0c-afad-a6766d3818a7 | default | Default security group | 0c2bc29526f4465c95b8eaefcfae7b7c |
    +--------------------------------------+---------+------------------------+----------------------------------+

Relacionando el ID del proyecto ``testproject`` vemos que el ID del security group relacionado es ``3a9e73cd-0608-49bf-b295-94b987a920ec``

2. Añadir una regla al security group que permita el tráfico ICMP y SSH hacia las instancias del proyecto:

- Regla para ICMP: permite todo el tráfico entrante ICMP a la instancia desde cualquier IP:

.. code-block:: bash

    '#' openstack security group rule create --remote-ip 0.0.0.0/0 --protocol icmp --ingress 3a9e73cd-0608-49bf-b295-94b987a920ec

    +-------------------+--------------------------------------+
    | Field             | Value                                |
    +-------------------+--------------------------------------+
    | created_at        | 2020-02-11T01:46:21Z                 |
    | description       |                                      |
    | direction         | ingress                              |
    | ether_type        | IPv4                                 |
    | id                | c0eb2ead-fad7-4400-8958-dcf6d43698c7 |
    | name              | None                                 |
    | port_range_max    | None                                 |
    | port_range_min    | None                                 |
    | project_id        | 99d8a6cd24734f2aa3fe70140fbdbd64     |
    | protocol          | icmp                                 |
    | remote_group_id   | None                                 |
    | remote_ip_prefix  | 0.0.0.0/0                            |
    | revision_number   | 0                                    |
    | security_group_id | 3a9e73cd-0608-49bf-b295-94b987a920ec |
    | updated_at        | 2020-02-11T01:46:21Z                 |
    +-------------------+--------------------------------------+

- Regla para SSH: permite todo el tráfico entrante SSH (puerto 22, TCP) a la instancia desde cualquier IP:

.. code-block:: bash

    '#' openstack security group rule create --remote-ip 0.0.0.0/0 --dst-port 22 --protocol tcp --ingress 3a9e73cd-0608-49bf-b295-94b987a920ec

    +-------------------+--------------------------------------+
    | Field             | Value                                |
    +-------------------+--------------------------------------+
    | created_at        | 2020-02-11T01:46:40Z                 |
    | description       |                                      |
    | direction         | ingress                              |
    | ether_type        | IPv4                                 |
    | id                | 6aaffa9a-932b-432f-aa4e-bacb646fecb3 |
    | name              | None                                 |
    | port_range_max    | 22                                   |
    | port_range_min    | 22                                   |
    | project_id        | 99d8a6cd24734f2aa3fe70140fbdbd64     |
    | protocol          | tcp                                  |
    | remote_group_id   | None                                 |
    | remote_ip_prefix  | 0.0.0.0/0                            |
    | revision_number   | 0                                    |
    | security_group_id | 3a9e73cd-0608-49bf-b295-94b987a920ec |
    | updated_at        | 2020-02-11T01:46:40Z                 |
    +-------------------+--------------------------------------+

Crear una instancia (1)
'''''''''''''''''''''''

1. Crear una instancia seleccionando la imagen, el flavor, la red a la cual deseemos que se conecte nuestra VM y el nombre de la instancia:

.. code-block:: bash

    '#' openstack server create --image cirros --flavor 10 --nic net-id=2cf9c274-8592-476b-bde5-41e930e01577 inst1

    +-------------------------------------+-----------------------------------------------+
    | Field                               | Value                                         |
    +-------------------------------------+-----------------------------------------------+
    | OS-DCF:diskConfig                   | MANUAL                                        |
    | OS-EXT-AZ:availability_zone         |                                               |
    | OS-EXT-SRV-ATTR:host                | None                                          |
    | OS-EXT-SRV-ATTR:hypervisor_hostname | None                                          |
    | OS-EXT-SRV-ATTR:instance_name       |                                               |
    | OS-EXT-STS:power_state              | NOSTATE                                       |
    | OS-EXT-STS:task_state               | scheduling                                    |
    | OS-EXT-STS:vm_state                 | building                                      |
    | OS-SRV-USG:launched_at              | None                                          |
    | OS-SRV-USG:terminated_at            | None                                          |
    | accessIPv4                          |                                               |
    | accessIPv6                          |                                               |
    | addresses                           |                                               |
    | adminPass                           | S43XAdqjgaYV                                  |
    | config_drive                        |                                               |
    | created                             | 2020-02-11T02:53:57Z                          |
    | flavor                              | m1.tiniest (10)                               |
    | hostId                              |                                               |
    | id                                  | 1265b4c2-d15f-4279-9148-24454ee294ef          |
    | image                               | cirros (56dd3671-de42-40db-9637-7c5bef599d11) |
    | key_name                            | None                                          |
    | name                                | inst1                                         |
    | progress                            | 0                                             |
    | project_id                          | 99d8a6cd24734f2aa3fe70140fbdbd64              |
    | properties                          |                                               |
    | security_groups                     | name='default'                                |
    | status                              | BUILD                                         |
    | updated                             | 2020-02-11T02:53:57Z                          |
    | user_id                             | 6643474fffb548b4bd4fb3d6a09d9ecd              |
    | volumes_attached                    |                                               |
    +-------------------------------------+-----------------------------------------------+

2. Despues de un momento, veremos que el estado de la VM se encuentra en activo y tiene asignada una dirección IP:

.. code-block:: bash

    '#' openstack server show inst1

    +-------------------------------------+----------------------------------------------------------+
    | Field                               | Value                                                    |
    +-------------------------------------+----------------------------------------------------------+
    | OS-DCF:diskConfig                   | MANUAL                                                   |
    | OS-EXT-AZ:availability_zone         | nova                                                     |
    | OS-EXT-SRV-ATTR:host                | controllernode1.localdomain                              |
    | OS-EXT-SRV-ATTR:hypervisor_hostname | controllernode1.localdomain                              |
    | OS-EXT-SRV-ATTR:instance_name       | instance-00000002                                        |
    | OS-EXT-STS:power_state              | Running                                                  |
    | OS-EXT-STS:task_state               | None                                                     |
    | OS-EXT-STS:vm_state                 | active                                                   |
    | OS-SRV-USG:launched_at              | 2020-02-11T02:54:03.000000                               |
    | OS-SRV-USG:terminated_at            | None                                                     |
    | accessIPv4                          |                                                          |
    | accessIPv6                          |                                                          |
    | addresses                           | intnet=10.5.5.3                                          |
    | config_drive                        |                                                          |
    | created                             | 2020-02-11T02:53:57Z                                     |
    | flavor                              | m1.tiniest (10)                                          |
    | hostId                              | e122795a13958abb7b13d1f480d04f15b58d09d04ae475133c0005a2 |
    | id                                  | 1265b4c2-d15f-4279-9148-24454ee294ef                     |
    | image                               | cirros (56dd3671-de42-40db-9637-7c5bef599d11)            |
    | key_name                            | None                                                     |
    | name                                | inst1                                                    |
    | progress                            | 0                                                        |
    | project_id                          | 99d8a6cd24734f2aa3fe70140fbdbd64                         |
    | properties                          |                                                          |
    | security_groups                     | name='default'                                           |
    | status                              | ACTIVE                                                   |
    | updated                             | 2020-02-11T02:54:03Z                                     |
    | user_id                             | 6643474fffb548b4bd4fb3d6a09d9ecd                         |
    | volumes_attached                    |                                                          |
    +-------------------------------------+----------------------------------------------------------+

3. Podemos conectarnos a la nueva instancia creada por SSH:

.. code-block:: bash

    '#' ip netns exec qrouter-d4cb763e-8578-484d-be6a-6d7da165e161 ssh cirros@10.5.5.3

    The authenticity of host '10.5.5.3 (10.5.5.3)' can't be established.
    ECDSA key fingerprint is SHA256:NcjHkAHTVvp9GRDizktzGg5mlQJnjyCXA7ohVsVV9yM.
    ECDSA key fingerprint is MD5:2c:4f:d8:42:93:d3:fa:fe:16:1c:c8:fa:0c:ad:60:12.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added '10.5.5.3' (ECDSA) to the list of known hosts.
    cirros@10.5.5.3's password:

    $ whoami
    cirros

    $ ip addr
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
           valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host 
           valid_lft forever preferred_lft forever
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc pfifo_fast qlen 1000
        link/ether fa:16:3e:07:1d:bb brd ff:ff:ff:ff:ff:ff
        inet 10.5.5.3/24 brd 10.5.5.255 scope global eth0
           valid_lft forever preferred_lft forever
        inet6 fe80::f816:3eff:fe07:1dbb/64 scope link 
           valid_lft forever preferred_lft forever

Asignar una Floating IP a una instancia
'''''''''''''''''''''''''''''''''''''''

Dentro de nuestra red y subred pública, crearemos una Floating IP para poder asignársela a la instancia:

1. Listar IDs de Redes y Subredes:

.. code-block:: bash

    '#' openstack network list

    +--------------------------------------+------------------+--------------------------------------+
    | ID                                   | Name             | Subnets                              |
    +--------------------------------------+------------------+--------------------------------------+
    | 2cf9c274-8592-476b-bde5-41e930e01577 | intnet           | 8168b012-2c3c-4114-8145-963dd6646793 |
    | f5dad5c1-bba9-41c5-844f-bd19a6a124aa | external_network | a6ae14ab-2287-4d0d-b8eb-0f503792f32c |
    +--------------------------------------+------------------+--------------------------------------+

    '#' openstack subnet list

    +--------------------------------------+---------------+--------------------------------------+----------------+
    | ID                                   | Name          | Network                              | Subnet         |
    +--------------------------------------+---------------+--------------------------------------+----------------+
    | 8168b012-2c3c-4114-8145-963dd6646793 | subnet1       | 2cf9c274-8592-476b-bde5-41e930e01577 | 10.5.5.0/24    |
    | a6ae14ab-2287-4d0d-b8eb-0f503792f32c | public_subnet | f5dad5c1-bba9-41c5-844f-bd19a6a124aa | 192.168.1.0/24 |
    +--------------------------------------+---------------+--------------------------------------+----------------+

2. Reservar una IP flotante dentro de la subred pública seleccionada:

.. code-block:: bash

    '#' openstack floating ip create --subnet a6ae14ab-2287-4d0d-b8eb-0f503792f32c f5dad5c1-bba9-41c5-844f-bd19a6a124aa

    +---------------------+--------------------------------------+
    | Field               | Value                                |
    +---------------------+--------------------------------------+
    | created_at          | 2020-02-11T03:28:04Z                 |
    | description         |                                      |
    | fixed_ip_address    | None                                 |
    | floating_ip_address | 192.168.1.152                        |
    | floating_network_id | f5dad5c1-bba9-41c5-844f-bd19a6a124aa |
    | id                  | 3ef31d8b-4918-473e-9696-f3820230d393 |
    | name                | 192.168.1.152                        |
    | port_id             | None                                 |
    | project_id          | 99d8a6cd24734f2aa3fe70140fbdbd64     |
    | qos_policy_id       | None                                 |
    | revision_number     | 0                                    |
    | router_id           | None                                 |
    | status              | DOWN                                 |
    | subnet_id           | a6ae14ab-2287-4d0d-b8eb-0f503792f32c |
    | updated_at          | 2020-02-11T03:28:04Z                 |
    +---------------------+--------------------------------------+

.. Note::

    Se ha reservado la IP flotante ``192.168.1.152``, pues la subred ``public_subnet`` tiene reservado el pool de asignación ``192.168.1.150-192.168.1.200``.

    .. code-block:: bash

        '#' openstack ip availability list
        
        +--------------------------------------+------------------+-----------+----------+
        | Network ID                           | Network Name     | Total IPs | Used IPs |
        +--------------------------------------+------------------+-----------+----------+
        | f5dad5c1-bba9-41c5-844f-bd19a6a124aa | external_network |        51 |        2 |
        | 2cf9c274-8592-476b-bde5-41e930e01577 | intnet           |       253 |        3 |
        +--------------------------------------+------------------+-----------+----------+

3. Asignar la Floating IP a la instancia:

.. code-block:: bash

    '#' openstack server add floating ip inst1 192.168.1.152

4. Podemos probar conectividad a esta instancia desde cualquier máquina de nuestra red física local:

.. code-block:: bash

    $ ping 192.168.1.152
    PING 192.168.1.152 (192.168.1.152) 56(84) bytes of data.
    64 bytes from 192.168.1.152: icmp_seq=1 ttl=63 time=48.0 ms
    ^C
    --- 192.168.1.152 ping statistics ---
    1 packets transmitted, 1 received, 0% packet loss, time 0ms
    rtt min/avg/max/mdev = 48.024/48.024/48.024/0.000 ms

    $ ssh cirros@192.168.1.152
    The authenticity of host '192.168.1.152 (192.168.1.152)' can't be established.
    ECDSA key fingerprint is SHA256:NcjHkAHTVvp9GRDizktzGg5mlQJnjyCXA7ohVsVV9yM.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added '192.168.1.152' (ECDSA) to the list of known hosts.
    cirros@192.168.1.152's password:

    $ whoami
    cirros

    $ ip addr
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
           valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host 
           valid_lft forever preferred_lft forever
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc pfifo_fast qlen 1000
        link/ether fa:16:3e:07:1d:bb brd ff:ff:ff:ff:ff:ff
        inet 10.5.5.3/24 brd 10.5.5.255 scope global eth0
           valid_lft forever preferred_lft forever
        inet6 fe80::f816:3eff:fe07:1dbb/64 scope link 
           valid_lft forever preferred_lft forever

Crear un key pair
'''''''''''''''''

1. Crear un nuevo key pair:

.. code-block:: bash

    #create a keypair named mykeypair and copy to mykeypair.key file
    '#' openstack keypair create mykeypair >> mykeypair.key

Hemos creado un key pair llamado ``mykeypair`` y hemos guardado la llave en el archivo llamado ``mykeypair.key``:

Crear un security group
'''''''''''''''''''''''

Link: `Configure access and security for instances - Openstack Docs`_

.. _Configure access and security for instances - Openstack Docs: https://docs.openstack.org/ocata/user-guide/cli-nova-configure-access-security-for-instances.html

1. Crear un security group con un nombre y descripción específicos:

.. code-block:: bash

    '#' openstack security group create testsecgroup --description "Security Group Test"

    +-----------------+-------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Field           | Value                                                                                                                                                 |
    +-----------------+-------------------------------------------------------------------------------------------------------------------------------------------------------+
    | created_at      | 2020-02-11T04:29:20Z                                                                                                                                  |
    | description     | Security Group Test                                                                                                                                   |
    | id              | 6db48e49-c56d-450c-8692-faa0bad3c081                                                                                                                  |
    | name            | testsecgroup                                                                                                                                          |
    | project_id      | 99d8a6cd24734f2aa3fe70140fbdbd64                                                                                                                      |
    | revision_number | 2                                                                                                                                                     |
    | rules           | created_at='2020-02-11T04:29:20Z', direction='egress', ethertype='IPv6', id='632c1a1f-a6ce-45d1-bf50-0dfc4018467e', updated_at='2020-02-11T04:29:20Z' |
    |                 | created_at='2020-02-11T04:29:20Z', direction='egress', ethertype='IPv4', id='d663e37a-0a80-44ba-b557-ad7715afd0ff', updated_at='2020-02-11T04:29:20Z' |
    | updated_at      | 2020-02-11T04:29:20Z                                                                                                                                  |
    +-----------------+-------------------------------------------------------------------------------------------------------------------------------------------------------+

2. Crear reglas para el nuevo security group:

- Permitir conexiones SSH remotas:

.. code-block:: bash

    '#' openstack security group rule create testsecgroup --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0

    +-------------------+--------------------------------------+
    | Field             | Value                                |
    +-------------------+--------------------------------------+
    | created_at        | 2020-02-11T04:36:55Z                 |
    | description       |                                      |
    | direction         | ingress                              |
    | ether_type        | IPv4                                 |
    | id                | fb4a6bb5-646d-4f02-a7cc-c01d460fb277 |
    | name              | None                                 |
    | port_range_max    | 22                                   |
    | port_range_min    | 22                                   |
    | project_id        | 99d8a6cd24734f2aa3fe70140fbdbd64     |
    | protocol          | tcp                                  |
    | remote_group_id   | None                                 |
    | remote_ip_prefix  | 0.0.0.0/0                            |
    | revision_number   | 0                                    |
    | security_group_id | 6db48e49-c56d-450c-8692-faa0bad3c081 |
    | updated_at        | 2020-02-11T04:36:55Z                 |
    +-------------------+--------------------------------------+

- Permitir tráfico ICMP entrante:

.. code-block:: bash

    '#' openstack security group rule create testsecgroup --protocol icmp

    +-------------------+--------------------------------------+
    | Field             | Value                                |
    +-------------------+--------------------------------------+
    | created_at        | 2020-02-11T04:42:00Z                 |
    | description       |                                      |
    | direction         | ingress                              |
    | ether_type        | IPv4                                 |
    | id                | c37a0ee4-7760-4e3f-9f24-d59076e6c1b8 |
    | name              | None                                 |
    | port_range_max    | None                                 |
    | port_range_min    | None                                 |
    | project_id        | 99d8a6cd24734f2aa3fe70140fbdbd64     |
    | protocol          | icmp                                 |
    | remote_group_id   | None                                 |
    | remote_ip_prefix  | 0.0.0.0/0                            |
    | revision_number   | 0                                    |
    | security_group_id | 6db48e49-c56d-450c-8692-faa0bad3c081 |
    | updated_at        | 2020-02-11T04:42:00Z                 |
    +-------------------+--------------------------------------+

3. Ver detalles del security group y de las reglas dentro del grupo:

.. code-block:: bash
    :emphasize-lines: 8,21

    '#' openstack security group list

    +--------------------------------------+--------------+------------------------+----------------------------------+
    | ID                                   | Name         | Description            | Project                          |
    +--------------------------------------+--------------+------------------------+----------------------------------+
    | 2bc3934c-debf-4477-917c-9f01e23e366e | default      | Default security group |                                  |
    | 3a9e73cd-0608-49bf-b295-94b987a920ec | default      | Default security group | 99d8a6cd24734f2aa3fe70140fbdbd64 |
    | 6db48e49-c56d-450c-8692-faa0bad3c081 | testsecgroup | Security Group Test    | 99d8a6cd24734f2aa3fe70140fbdbd64 |
    | 7e145dac-5186-4b0c-afad-a6766d3818a7 | default      | Default security group | 0c2bc29526f4465c95b8eaefcfae7b7c |
    | a2475e5d-a9dd-4ee1-a60f-2c2a15f1f299 | default      | Default security group | ed14e8f780b84664accc6aa2d6673624 |
    +--------------------------------------+--------------+------------------------+----------------------------------+

    '#' openstack security group rule list testsecgroup

    +--------------------------------------+-------------+-----------+------------+-----------------------+
    | ID                                   | IP Protocol | IP Range  | Port Range | Remote Security Group |
    +--------------------------------------+-------------+-----------+------------+-----------------------+
    | 632c1a1f-a6ce-45d1-bf50-0dfc4018467e | None        | None      |            | None                  |
    | c37a0ee4-7760-4e3f-9f24-d59076e6c1b8 | icmp        | 0.0.0.0/0 |            | None                  |
    | d663e37a-0a80-44ba-b557-ad7715afd0ff | None        | None      |            | None                  |
    | fb4a6bb5-646d-4f02-a7cc-c01d460fb277 | tcp         | 0.0.0.0/0 | 22:22      | None                  |
    +--------------------------------------+-------------+-----------+------------+-----------------------+

    '#' openstack security group rule show fb4a6bb5-646d-4f02-a7cc-c01d460fb277

    +-------------------+--------------------------------------+
    | Field             | Value                                |
    +-------------------+--------------------------------------+
    | created_at        | 2020-02-11T04:36:55Z                 |
    | description       |                                      |
    | direction         | ingress                              |
    | ether_type        | IPv4                                 |
    | id                | fb4a6bb5-646d-4f02-a7cc-c01d460fb277 |
    | name              | None                                 |
    | port_range_max    | 22                                   |
    | port_range_min    | 22                                   |
    | project_id        | 99d8a6cd24734f2aa3fe70140fbdbd64     |
    | protocol          | tcp                                  |
    | remote_group_id   | None                                 |
    | remote_ip_prefix  | 0.0.0.0/0                            |
    | revision_number   | 0                                    |
    | security_group_id | 6db48e49-c56d-450c-8692-faa0bad3c081 |
    | updated_at        | 2020-02-11T04:36:55Z                 |
    +-------------------+--------------------------------------+

Crear una instancia (2)
'''''''''''''''''''''''

Link: `Launch an instance on the provider network - Openstack Docs`_

.. _Launch an instance on the provider network - Openstack Docs: https://docs.openstack.org/mitaka/install-guide-ubuntu/launch-instance-provider.html

1. Ahora crearemos una instancia especificando un security group y un keypair:

.. code-block:: bash

    '#' openstack server create --image cirros --flavor 10 --key-name mykeypair --security-group testsecgroup --nic net-id=2cf9c274-8592-476b-bde5-41e930e01577 inst2

    +-------------------------------------+-----------------------------------------------+
    | Field                               | Value                                         |
    +-------------------------------------+-----------------------------------------------+
    | OS-DCF:diskConfig                   | MANUAL                                        |
    | OS-EXT-AZ:availability_zone         |                                               |
    | OS-EXT-SRV-ATTR:host                | None                                          |
    | OS-EXT-SRV-ATTR:hypervisor_hostname | None                                          |
    | OS-EXT-SRV-ATTR:instance_name       |                                               |
    | OS-EXT-STS:power_state              | NOSTATE                                       |
    | OS-EXT-STS:task_state               | scheduling                                    |
    | OS-EXT-STS:vm_state                 | building                                      |
    | OS-SRV-USG:launched_at              | None                                          |
    | OS-SRV-USG:terminated_at            | None                                          |
    | accessIPv4                          |                                               |
    | accessIPv6                          |                                               |
    | addresses                           |                                               |
    | adminPass                           | q2rGS9Hbw7nF                                  |
    | config_drive                        |                                               |
    | created                             | 2020-02-11T04:58:15Z                          |
    | flavor                              | m1.tiniest (10)                               |
    | hostId                              |                                               |
    | id                                  | e597bba0-7440-49e3-b5ee-f972c2f640ab          |
    | image                               | cirros (56dd3671-de42-40db-9637-7c5bef599d11) |
    | key_name                            | mykeypair                                     |
    | name                                | inst2                                         |
    | progress                            | 0                                             |
    | project_id                          | 99d8a6cd24734f2aa3fe70140fbdbd64              |
    | properties                          |                                               |
    | security_groups                     | name='6db48e49-c56d-450c-8692-faa0bad3c081'   |
    | status                              | BUILD                                         |
    | updated                             | 2020-02-11T04:58:15Z                          |
    | user_id                             | 6643474fffb548b4bd4fb3d6a09d9ecd              |
    | volumes_attached                    |                                               |
    +-------------------------------------+-----------------------------------------------+

2. Ver detalles de la instancia creada una vez que está activa:

.. code-block:: bash

    '#' openstack server show inst2

    +-------------------------------------+----------------------------------------------------------+
    | Field                               | Value                                                    |
    +-------------------------------------+----------------------------------------------------------+
    | OS-DCF:diskConfig                   | MANUAL                                                   |
    | OS-EXT-AZ:availability_zone         | nova                                                     |
    | OS-EXT-SRV-ATTR:host                | controllernode1.localdomain                              |
    | OS-EXT-SRV-ATTR:hypervisor_hostname | controllernode1.localdomain                              |
    | OS-EXT-SRV-ATTR:instance_name       | instance-00000003                                        |
    | OS-EXT-STS:power_state              | Running                                                  |
    | OS-EXT-STS:task_state               | None                                                     |
    | OS-EXT-STS:vm_state                 | active                                                   |
    | OS-SRV-USG:launched_at              | 2020-02-11T04:58:21.000000                               |
    | OS-SRV-USG:terminated_at            | None                                                     |
    | accessIPv4                          |                                                          |
    | accessIPv6                          |                                                          |
    | addresses                           | intnet=10.5.5.4                                          |
    | config_drive                        |                                                          |
    | created                             | 2020-02-11T04:58:15Z                                     |
    | flavor                              | m1.tiniest (10)                                          |
    | hostId                              | e122795a13958abb7b13d1f480d04f15b58d09d04ae475133c0005a2 |
    | id                                  | e597bba0-7440-49e3-b5ee-f972c2f640ab                     |
    | image                               | cirros (56dd3671-de42-40db-9637-7c5bef599d11)            |
    | key_name                            | mykeypair                                                |
    | name                                | inst2                                                    |
    | progress                            | 0                                                        |
    | project_id                          | 99d8a6cd24734f2aa3fe70140fbdbd64                         |
    | properties                          |                                                          |
    | security_groups                     | name='testsecgroup'                                      |
    | status                              | ACTIVE                                                   |
    | updated                             | 2020-02-11T04:58:21Z                                     |
    | user_id                             | 6643474fffb548b4bd4fb3d6a09d9ecd                         |
    | volumes_attached                    |                                                          |
    +-------------------------------------+----------------------------------------------------------+

3. Asignar un IP flotante a la instancia creada:

.. code-block:: bash

    '#' openstack floating ip create --subnet a6ae14ab-2287-4d0d-b8eb-0f503792f32c f5dad5c1-bba9-41c5-844f-bd19a6a124aa

    +---------------------+--------------------------------------+
    | Field               | Value                                |
    +---------------------+--------------------------------------+
    | created_at          | 2020-02-11T05:03:35Z                 |
    | description         |                                      |
    | fixed_ip_address    | None                                 |
    | floating_ip_address | 192.168.1.153                        |
    | floating_network_id | f5dad5c1-bba9-41c5-844f-bd19a6a124aa |
    | id                  | a4fc9dad-5e2a-4f56-ad0d-ae386b7238d1 |
    | name                | 192.168.1.153                        |
    | port_id             | None                                 |
    | project_id          | 99d8a6cd24734f2aa3fe70140fbdbd64     |
    | qos_policy_id       | None                                 |
    | revision_number     | 0                                    |
    | router_id           | None                                 |
    | status              | DOWN                                 |
    | subnet_id           | a6ae14ab-2287-4d0d-b8eb-0f503792f32c |
    | updated_at          | 2020-02-11T05:03:35Z                 |
    +---------------------+--------------------------------------+

.. code-block:: bash

    '#' openstack server add floating ip inst2 192.168.1.153

4. Conectarse a la instancia desde cualquier máquina dentro de la red local empleando la key pair:

- Primero debemos obtener el archivo con el contenido de la llave en la máquina que desea conectarse a la instancia. Por ejemplo, pasando por scp la llave desde el controller node a la máquina que se desea conectar:

.. code-block:: bash

    '#' scp mykeypair.key gabriel@192.168.1.9:/home/gabriel/Downloads

- Una vez que tengamos la llave localmente, cambiar los permisos del archivo:

.. code-block:: bash

    $ chmod 600 mykeypair.key

- Usar la llave para conectarnos a la instancia de forma **passwordless**:

.. code-block:: bash

    $ ssh -i mykeypair.key cirros@192.168.1.153

    $ whoami
    cirros

    $ ip addr
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
        valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host 
        valid_lft forever preferred_lft forever
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc pfifo_fast qlen 1000
        link/ether fa:16:3e:f5:21:35 brd ff:ff:ff:ff:ff:ff
        inet 10.5.5.4/24 brd 10.5.5.255 scope global eth0
        valid_lft forever preferred_lft forever
        inet6 fe80::f816:3eff:fef5:2135/64 scope link 
        valid_lft forever preferred_lft forever

    $ df -h
    Filesystem                Size      Used Available Use% Mounted on
    /dev                     51.2M         0     51.2M   0% /dev
    /dev/vda1               978.9M     24.0M    914.1M   3% /
    tmpfs                    55.2M         0     55.2M   0% /dev/shm
    tmpfs                    55.2M     92.0K     55.1M   0% /run

5. También podemos conectarnos a la instancia usando el navegador, ingresando la URL que aparece con el siguiente comando:

.. code-block:: bash

    '#' openstack console url show inst2

    +-------+------------------------------------------------------------------------------------+
    | Field | Value                                                                              |
    +-------+------------------------------------------------------------------------------------+
    | type  | novnc                                                                              |
    | url   | http://192.168.1.100:6080/vnc_auto.html?token=957c0893-e5f1-409f-a0b8-d3a833a09863 |
    +-------+------------------------------------------------------------------------------------+

Crear snapshot de una imagen
''''''''''''''''''''''''''''

Link: `Use snapshots to migrate instances - Openstack Docs`_

.. _Use snapshots to migrate instances - Openstack Docs: https://docs.openstack.org/nova/rocky/admin/migrate-instance-with-snapshot.html

Crear un snapshot de una imagen definida:

.. code-block:: bash

    '#' openstack server image create --name snap1 inst2

    +------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Field            | Value                                                                                                                                                                                                                                                                      |
    +------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | checksum         | None                                                                                                                                                                                                                                                                       |
    | container_format | None                                                                                                                                                                                                                                                                       |
    | created_at       | 2020-02-11T06:06:03Z                                                                                                                                                                                                                                                       |
    | disk_format      | None                                                                                                                                                                                                                                                                       |
    | file             | /v2/images/bc9fd276-2b21-44a0-aadc-fd971c2034aa/file                                                                                                                                                                                                                       |
    | id               | bc9fd276-2b21-44a0-aadc-fd971c2034aa                                                                                                                                                                                                                                       |
    | min_disk         | 1                                                                                                                                                                                                                                                                          |
    | min_ram          | 128                                                                                                                                                                                                                                                                        |
    | name             | snap1                                                                                                                                                                                                                                                                      |
    | owner            | 99d8a6cd24734f2aa3fe70140fbdbd64                                                                                                                                                                                                                                           |
    | properties       | base_image_ref='56dd3671-de42-40db-9637-7c5bef599d11', boot_roles='_member_,admin', image_type='snapshot', instance_uuid='e597bba0-7440-49e3-b5ee-f972c2f640ab', owner_project_name='testproject', owner_user_name='testuser1', user_id='6643474fffb548b4bd4fb3d6a09d9ecd' |
    | protected        | False                                                                                                                                                                                                                                                                      |
    | schema           | /v2/schemas/image                                                                                                                                                                                                                                                          |
    | size             | None                                                                                                                                                                                                                                                                       |
    | status           | queued                                                                                                                                                                                                                                                                     |
    | tags             |                                                                                                                                                                                                                                                                            |
    | updated_at       | 2020-02-11T06:06:03Z                                                                                                                                                                                                                                                       |
    | virtual_size     | None                                                                                                                                                                                                                                                                       |
    | visibility       | private                                                                                                                                                                                                                                                                    |
    +------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Podremos correr una nueva instancia desde este snapshot realizado. El snapshot creado es una imagen más del tipo ``image_type='snapshot'`` como se ve en la sección ``properties``:

.. code-block:: bash

    '#' openstack image list
    +--------------------------------------+--------+--------+
    | ID                                   | Name   | Status |
    +--------------------------------------+--------+--------+
    | 56dd3671-de42-40db-9637-7c5bef599d11 | cirros | active |
    | bc9fd276-2b21-44a0-aadc-fd971c2034aa | snap1  | active |
    +--------------------------------------+--------+--------+

Crear un volumen
''''''''''''''''

Link: `Block Storage - Openstack Docs`_

.. _Block Storage - Openstack Docs: https://docs.openstack.org/ocata/install-guide-ubuntu/launch-instance-cinder.html

Crear un volumen de 1 GB de tamaño llamado ``vol1``:

.. code-block:: bash

    '#' openstack volume create --size 1 vol1

    +---------------------+--------------------------------------+
    | Field               | Value                                |
    +---------------------+--------------------------------------+
    | attachments         | []                                   |
    | availability_zone   | nova                                 |
    | bootable            | false                                |
    | consistencygroup_id | None                                 |
    | created_at          | 2020-02-11T06:39:16.000000           |
    | description         | None                                 |
    | encrypted           | False                                |
    | id                  | 325a4a42-d640-43d8-affe-8d5efacee6a4 |
    | migration_status    | None                                 |
    | multiattach         | False                                |
    | name                | vol1                                 |
    | properties          |                                      |
    | replication_status  | None                                 |
    | size                | 1                                    |
    | snapshot_id         | None                                 |
    | source_volid        | None                                 |
    | status              | creating                             |
    | type                | iscsi                                |
    | updated_at          | None                                 |
    | user_id             | 6643474fffb548b4bd4fb3d6a09d9ecd     |
    +---------------------+--------------------------------------+

    '#' openstack volume list

    +--------------------------------------+------+-----------+------+-------------+
    | ID                                   | Name | Status    | Size | Attached to |
    +--------------------------------------+------+-----------+------+-------------+
    | 325a4a42-d640-43d8-affe-8d5efacee6a4 | vol1 | available |    1 |             |
    +--------------------------------------+------+-----------+------+-------------+

Conectar y montar un volumen a una instancia
'''''''''''''''''''''''''''''''''''''''''''''

1. Conectar el volumen ``vol1`` a la instancia ``inst2``:

.. code-block:: bash

    '#' openstack server add volume inst2 vol1

    '#' openstack volume list
    +--------------------------------------+------+--------+------+--------------------------------+
    | ID                                   | Name | Status | Size | Attached to                    |
    +--------------------------------------+------+--------+------+--------------------------------+
    | 325a4a42-d640-43d8-affe-8d5efacee6a4 | vol1 | in-use |    1 | Attached to inst2 on /dev/vdb  |
    +--------------------------------------+------+--------+------+--------------------------------+

Comprobamos que el disco se ha conectado a la instancia ``inst2`` bajo la ruta ``/dev/vdb``.

2. Dentro de la instancia formatearemos el volumen para que sea utilizable:

- Nos conectamos a la instancia y comprobamos que existe la ruta ``/dev/vdb`` dentro de la instancia:

.. code-block:: bash

    $ ssh -i mykeypair.key cirros@192.168.1.153

    $ ls /dev | grep vd
    vda
    vda1
    vda15
    vdb

- Formatear el volumen:

.. code-block:: bash

    $ sudo mkfs.ext4 /dev/vdb
    mke2fs 1.42.12 (29-Aug-2014)
    Creating filesystem with 262144 4k blocks and 65536 inodes
    Filesystem UUID: b4700792-4051-4657-91ed-9b07ca1153ae
    Superblock backups stored on blocks:
            32768, 98304, 163840, 229376

    Allocating group tables: done
    Writing inode tables: done
    Creating journal (8192 blocks): done
    Writing superblocks and filesystem accounting information: done

3. Montar el volumen formateado bajo un directorio:

.. code-block:: bash

    $ sudo mkdir /mydisk
    $ sudo mount /dev/vdb /mydisk/

    $ df -h
    Filesystem                Size      Used Available Use% Mounted on
    /dev                     51.2M         0     51.2M   0% /dev
    /dev/vda1               978.9M     24.0M    914.1M   3% /
    tmpfs                    55.2M         0     55.2M   0% /dev/shm
    tmpfs                    55.2M     92.0K     55.1M   0% /run
    /dev/vdb                975.9M      1.3M    907.4M   0% /mydisk

Comprobamos que el volumen con filesystem ``/dev/vdb`` y 1GB de almacenamiento se ha montado bajo el directorio ``/mydisk`` y ya es utilizable.

Crear backup de un volumen
''''''''''''''''''''''''''

Para crear un backup de un volumen que está siendo usado actualmente usamos la opción ``--force`` del comando ``openstack volume backup create``:

.. code-block:: bash

    '#' openstack volume backup create --name vol1backup1 --force vol1

    +-------+--------------------------------------+
    | Field | Value                                |
    +-------+--------------------------------------+
    | id    | d6638c79-7f32-4c88-bf65-c200f71c5279 |
    | name  | vol1backup1                          |
    +-------+--------------------------------------+

Podemos ver detalles del backup creado:

.. code-block:: bash

    '#' openstack volume backup show vol1backup1

    +-----------------------+--------------------------------------+
    | Field                 | Value                                |
    +-----------------------+--------------------------------------+
    | availability_zone     | nova                                 |
    | container             | volumebackups                        |
    | created_at            | 2020-02-11T07:16:26.000000           |
    | data_timestamp        | 2020-02-11T07:16:26.000000           |
    | description           | None                                 |
    | fail_reason           | None                                 |
    | has_dependent_backups | False                                |
    | id                    | d6638c79-7f32-4c88-bf65-c200f71c5279 |
    | is_incremental        | False                                |
    | name                  | vol1backup1                          |
    | object_count          | 22                                   |
    | size                  | 1                                    |
    | snapshot_id           | None                                 |
    | status                | available                            |
    | updated_at            | 2020-02-11T07:17:00.000000           |
    | volume_id             | 325a4a42-d640-43d8-affe-8d5efacee6a4 |
    +-----------------------+--------------------------------------+

.. Note::

    Los bakcups son guardados en archivos, por lo que se trata de objetos. Los backups se almacenan en Swift object storage, por defecto.

Crear snapshot de un volumen
''''''''''''''''''''''''''''

Para crear un snapshot de un volumen conectado a una instancia usamos la opción ``--force`` del comando. Seleccionamos cuál es el volumen al cual se le creará el snapshot con la opción ``--volume``. Nombramos al snapshot ``vol1snap1``:

.. code-block:: bash

    # Deprecated: openstack snapshot create --name snap1 --force vol1

    '#' openstack volume snapshot create --volume vol1 --force vol1snap1

    +-------------+--------------------------------------+
    | Field       | Value                                |
    +-------------+--------------------------------------+
    | created_at  | 2020-02-11T08:53:24.358788           |
    | description | None                                 |
    | id          | 9cbba900-465d-4ac4-b03f-ebe4dea15213 |
    | name        | vol1snap1                            |
    | properties  |                                      |
    | size        | 1                                    |
    | status      | creating                             |
    | updated_at  | None                                 |
    | volume_id   | 325a4a42-d640-43d8-affe-8d5efacee6a4 |
    +-------------+--------------------------------------+

Link del comando: `volumen snapshot - Openstack Docs`_

.. _volumen snapshot - Openstack Docs: https://docs.openstack.org/python-openstackclient/latest/cli/command-objects/volume-snapshot.html

Crear un contenedor
'''''''''''''''''''

1. Listemos las cuentas, bajo la cual se crearán los objetos:

.. code-block:: bash

    '#' openstack object store account show
    +------------+---------------------------------------+
    | Field      | Value                                 |
    +------------+---------------------------------------+
    | Account    | AUTH_99d8a6cd24734f2aa3fe70140fbdbd64 |
    | Bytes      | 0                                     |
    | Containers | 0                                     |
    | Objects    | 0                                     |
    +------------+---------------------------------------+

Las cuentas de Swift tienen contenedores y los contenedores tienen objetos dentro de sí.

2. Crear un contenedor:

.. code-block:: bash

    '#' openstack container create container1

    +---------------------------------------+------------+------------------------------------+
    | account                               | container  | x-trans-id                         |
    +---------------------------------------+------------+------------------------------------+
    | AUTH_99d8a6cd24734f2aa3fe70140fbdbd64 | container1 | tx3da04526eaac4deea9d15-005e427219 |
    +---------------------------------------+------------+------------------------------------+

Como vemos, el contenedor se ha creado bajo la cuenta antes listada.

3. Listar contenedores:

.. code-block:: bash

    '#' openstack container list

    +------------+
    | Name       |
    +------------+
    | container1 |
    +------------+

Crear un objeto
'''''''''''''''

Para crear un objeto en un contenedor debemos especificar el archivo que vamos a subir dentro del contenedor y el nombre de este contenedor.

Por ejemplo, para subir el archivo ``keystonerc_admin`` al contenedor ``container1`` creamos un objeto:

.. code-block:: bash

    '#' openstack object create container1 keystonerc_admin

    +------------------+------------+----------------------------------+
    | object           | container  | etag                             |
    +------------------+------------+----------------------------------+
    | keystonerc_admin | container1 | 75f5a62d38e6dcb7ba8ef259e8f71727 |
    +------------------+------------+----------------------------------+

Acceder a un objeto
'''''''''''''''''''

Podemos acceder a un objeto almacenado con Swift de múltiples formas. Por ejemplo, mediante un navegador o desde la línea de comandos:

1. Correr el comando ``swift tempurl``:

.. code-block:: bash

    '#' swift tempurl

    ...
    <key>               The secret temporary URL key set on the Swift cluster.
                        To set a key, run 'swift post -m
                        "Temp-URL-Key:b3968d0207b54ece87cccc06515a89d4"'

2. El comando ``swift tempurl`` nos dice que para configurar una llave URL temporal, primero debemos ejecutar:

.. code-block:: bash

    '#' swift post -m "Temp-URL-Key:b3968d0207b54ece87cccc06515a89d4"

Se ha generado la llave en el background.

3. Obtener el ID de la cuenta para formar la URL del objeto:

.. code-block:: bash

    '#' openstack object store account show

    +------------+-------------------------------------------------+
    | Field      | Value                                           |
    +------------+-------------------------------------------------+
    | Account    | AUTH_99d8a6cd24734f2aa3fe70140fbdbd64           |
    | Bytes      | 373                                             |
    | Containers | 1                                               |
    | Objects    | 1                                               |
    | properties | Temp-Url-Key='b3968d0207b54ece87cccc06515a89d4' |
    +------------+-------------------------------------------------+

4. Generar la URL temporal del objeto con el comando ``tempurl``:

.. code-block:: bash

    '#' swift tempurl get 1000 /v1/AUTH_99d8a6cd24734f2aa3fe70140fbdbd64/container1/keystonerc_admin b3968d0207b54ece87cccc06515a89d4

    /v1/AUTH_99d8a6cd24734f2aa3fe70140fbdbd64/container1/keystonerc_admin?temp_url_sig=83258744f90d5dee3fc8cf04235754447c16f7b9&temp_url_expires=1581417017

En el comando hemos indicamos lo siguiente:

- deseamos acceder al link por el método ``GET``
- el link debe estar activo por ``1000`` segundos
- la versión soportada por Swift es la ``v1``
- el ID de la cuenta es ``AUTH_99d8a6cd24734f2aa3fe70140fbdbd64``
- el objeto al que deseamos acceder es ``keystonerc_admin``
- la llave del URL temporal es ``b3968d0207b54ece87cccc06515a89d4``
  
5. Combinemos la ``tempURL`` con la información del hosts de Swift. Para obtener los datos restantes ejecutar:

.. code-block:: bash
    :emphasize-lines: 18

    '#' openstack endpoint list | grep swift | grep public

    | 4bb287495f014c7b97f455784fc1e448 | RegionOne | swift        | object-store | True    | public    | http://192.168.1.100:8080/v1/AUTH_%(tenant_id)s |

    '#' openstack endpoint show 4bb287495f014c7b97f455784fc1e448

    +--------------+-------------------------------------------------+
    | Field        | Value                                           |
    +--------------+-------------------------------------------------+
    | enabled      | True                                            |
    | id           | 4bb287495f014c7b97f455784fc1e448                |
    | interface    | public                                          |
    | region       | RegionOne                                       |
    | region_id    | RegionOne                                       |
    | service_id   | 43c335e18ef2446ca4171e16f82f0926                |
    | service_name | swift                                           |
    | service_type | object-store                                    |
    | url          | http://192.168.1.100:8080/v1/AUTH_%(tenant_id)s |
    +--------------+-------------------------------------------------+

Ahora sabemos más a detalle el formato de la URL (IP y puerto): ``http://192.168.1.100:8080/v1/AUTH_%(tenant_id)s``

6. Formar la URL completa y acceder desde el terminal o el navegador a esta dirección para descargar el objeto:

- Formato de URL: ``http://192.168.1.100:8080/`` + ``tempurl``
- URL: http://192.168.1.100:8080/v1/AUTH_99d8a6cd24734f2aa3fe70140fbdbd64/container1/keystonerc_admin?temp_url_sig=83258744f90d5dee3fc8cf04235754447c16f7b9&temp_url_expires=1581417017


Copiar llave pública al usuario ``admin``
'''''''''''''''''''''''''''''''''''''''''

1. Copiar el contenido de la llave pública del keypair ``keypair1``:

.. code-block:: bash

    '#' openstack keypair show --public-key keypair1

    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxmvWnlwsIFva/0NUdPGI9FyMAQj9UOS36YILnbVF6Zv+SYBJMUJfuim68yEQbNh1U5OcP0oAP2DpSUzIkEVqJTLeJ6tZiL0jT34sDslCmFZd3Md+u88r6MGz/Oavso9lUr3nx9//Caqc9YJiCghCAeF7M1Yp5RnaUz08jnibqJ8ayRxKlj9PXasLtRZcXPgqVySdokmZYvf8M6wXDq/U8Z0pfHsiWczfCgdfKw7CJA8D+HsnDH0iX92rsD94wbir43WklbOR2lrtb8IYF+vzyqhkogzQiFsbKMVIqNSklZcs0BkE7iT7lCpi5vTXryrawjrNNZeRZUR4Nkv/rVJz/ Generated-by-Nova

.. code-block:: bash

    '#' cat keypair1.pub

    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxmvWnlwsIFva/0NUdPGI9FyMAQj9UOS36YILnbVF6Zv+SYBJMUJfuim68yEQbNh1U5OcP0oAP2DpSUzIkEVqJTLeJ6tZiL0jT34sDslCmFZd3Md+u88r6MGz/Oavso9lUr3nx9//Caqc9YJiCghCAeF7M1Yp5RnaUz08jnibqJ8ayRxKlj9PXasLtRZcXPgqVySdokmZYvf8M6wXDq/U8Z0pfHsiWczfCgdfKw7CJA8D+HsnDH0iX92rsD94wbir43WklbOR2lrtb8IYF+vzyqhkogzQiFsbKMVIqNSklZcs0BkE7iT7lCpi5vTXryrawjrNNZeRZUR4Nkv/rVJz/ Generated-by-Nova

2. Cambiar de usuario a ``admin`` y crear el keypair:

.. code-block:: bash

    '#' source keystonerc_admin

    '#' openstack keypair create --public-key keypair1.pub keypair1

    +-------------+-------------------------------------------------+
    | Field       | Value                                           |
    +-------------+-------------------------------------------------+
    | fingerprint | 4a:ba:08:bc:b8:43:ec:8c:6c:9a:a9:6f:c0:f8:6f:3f |
    | name        | keypair1                                        |
    | user_id     | 913e33878304445a987b04f5ca4705a0                |
    +-------------+-------------------------------------------------+

Crear Host Aggregates
'''''''''''''''''''''

.. code-block:: bash

    '#' source keystonerc_admin
    
    '#' openstack aggregate create --zone controller1_zone controller1_aggregate

    '#' openstack aggregate add host controller1_aggregate controllernode1.localdomain

    '#' openstack aggregate create --zone compute1_zone compute1_aggregate

    '#' openstack aggregate create --zone compute2_zone compute2_aggregate

    '#' openstack aggregate add host compute2_aggregate computenode2.localdomain

.. Note::

    Ahora que hemos creado host aggregates y los hemos asociado a availability zones, podemos crear instancias en availability zones determinados sin necesidad de tener permisos de administrador:

    .. code-block:: bash

        '#' source keystonerc_testuser1

        '#' openstack server create --image cirros --flavor 10 --key-name project1_keypair1 --security-group project1_secgroup --availability-zone compute1_zone --nic net-id=e6760c1d-535b-4c0a-948d-5433e6d9fbec,v4-fixed-ip=10.10.10.203 instC

        '#' openstack server create --image cirros --flavor 10 --key-name project1_keypair1 --security-group project1_secgroup --availability-zone compute2_zone --nic net-id=e6760c1d-535b-4c0a-948d-5433e6d9fbec,v4-fixed-ip=10.10.10.204 instD