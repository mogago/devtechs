Proceso de instalación manual de OpenStack
------------------------------------------

.. contents:: Table of Contents

Documentación oficial de OpenStack
''''''''''''''''''''''''''''''''''

- `OpenStack Documentation - Train Release`_
- `OpenStack Installation Guide (any release)`_: The following guide provides information about getting started, setting up your environment, and launching your instance.
- `OpenStack Train Installation Guides`_: These documents cover installation procedures for OpenStack services.
- `Install OpenStack services`_

.. _OpenStack Installation Guide (any release): https://docs.openstack.org/install-guide/
.. _OpenStack Documentation - Train Release: https://docs.openstack.org/train/
.. _OpenStack Train Installation Guides: https://docs.openstack.org/train/install/
.. _Install OpenStack services: https://docs.openstack.org/install-guide/openstack-services.html

OpenStack Environment (any release)
"""""""""""""""""""""""""""""""""""

- `Environment`_
    - `Security`_
    - `Host networking`_
        - `Host networking - Controller node`_
        - `Host networking - Compute node`_
        - `Host networking - Block storage node (Optional)`_
        - `Host networking - Verify connectivity`_
    - `Network Time Protocol (NTP)`_
        - `NTP - Controller node`_
        - `NTP - Other nodes`_
        - `NTP - Verify operation`_
    - `OpenStack packages`_
        - `OpenStack packages for SUSE`_
        - `OpenStack packages for RHEL and CentOS`_
        - `OpenStack packages for Ubuntu`_
    - `SQL database`_
        - `SQL database for SUSE`_
        - `SQL database for RHEL and CentOS`_
        - `SQL database for Ubuntu`_
    - `Message queue`_
        - `Message queue for SUSE`_
        - `Message queue for RHEL and CentOS`_
        - `Message queue for Ubuntu`_
    - `Memcached`_
        - `Memcached for SUSE`_
        - `Memcached for RHEL and CentOS`_
        - `Memcached for Ubuntu`_
    - `Etcd`_
        - `Etcd for SUSE`_
        - `Etcd for RHEL and CentOS`_
        - `Etcd for Ubuntu`_

.. _Environment: https://docs.openstack.org/install-guide/environment.html
.. _Security: https://docs.openstack.org/install-guide/environment-security.html
.. _Host networking: https://docs.openstack.org/install-guide/environment-networking.html
.. _Host networking - Controller node: https://docs.openstack.org/install-guide/environment-networking-controller.html
.. _Host networking - Compute node: https://docs.openstack.org/install-guide/environment-networking-compute.html
.. _Host networking - Block storage node (Optional): https://docs.openstack.org/install-guide/environment-networking-storage-cinder.html
.. _Host networking - Verify connectivity: https://docs.openstack.org/install-guide/environment-networking-verify.html
.. _Network Time Protocol (NTP): https://docs.openstack.org/install-guide/environment-ntp.html
.. _NTP - Controller node: https://docs.openstack.org/install-guide/environment-ntp-controller.html
.. _NTP - Other nodes: https://docs.openstack.org/install-guide/environment-ntp-other.html
.. _NTP - Verify operation: https://docs.openstack.org/install-guide/environment-ntp-verify.html
.. _OpenStack packages: https://docs.openstack.org/install-guide/environment-packages.html
.. _OpenStack packages for SUSE: https://docs.openstack.org/install-guide/environment-packages-obs.html
.. _OpenStack packages for RHEL and CentOS: https://docs.openstack.org/install-guide/environment-packages-rdo.html
.. _OpenStack packages for Ubuntu: https://docs.openstack.org/install-guide/environment-packages-ubuntu.html
.. _SQL database: https://docs.openstack.org/install-guide/environment-sql-database.html
.. _SQL database for SUSE: https://docs.openstack.org/install-guide/environment-sql-database-obs.html
.. _SQL database for RHEL and CentOS: https://docs.openstack.org/install-guide/environment-sql-database-rdo.html
.. _SQL database for Ubuntu: https://docs.openstack.org/install-guide/environment-sql-database-ubuntu.html
.. _Message queue: https://docs.openstack.org/install-guide/environment-messaging.html
.. _Message queue for SUSE: https://docs.openstack.org/install-guide/environment-messaging-obs.html
.. _Message queue for RHEL and CentOS: https://docs.openstack.org/install-guide/environment-messaging-rdo.html
.. _Message queue for Ubuntu: https://docs.openstack.org/install-guide/environment-messaging-ubuntu.html
.. _Memcached: https://docs.openstack.org/install-guide/environment-memcached.html
.. _Memcached for SUSE: https://docs.openstack.org/install-guide/environment-memcached-obs.html
.. _Memcached for RHEL and CentOS: https://docs.openstack.org/install-guide/environment-memcached-rdo.html
.. _Memcached for Ubuntu: https://docs.openstack.org/install-guide/environment-memcached-ubuntu.html
.. _Etcd: https://docs.openstack.org/install-guide/environment-etcd.html
.. _Etcd for SUSE: https://docs.openstack.org/install-guide/environment-etcd-obs.html
.. _Etcd for RHEL and CentOS: https://docs.openstack.org/install-guide/environment-etcd-rdo.html
.. _Etcd for Ubuntu: https://docs.openstack.org/install-guide/environment-etcd-ubuntu.html

OpenStack Services (Train)
""""""""""""""""""""""""""

Instalar los servicios de OpenStack respetando el siguiente orden:

- `Keystone Installation`_
- `Glance Installation`_
- `Placement Installation`_
- `Nova Installation`_
- `Neutron Installation`_
- `Cinder Installation`_
- `Horizon Installation`_

.. _Keystone Installation: https://docs.openstack.org/keystone/train/install/
.. _Glance Installation: https://docs.openstack.org/glance/train/install/
.. _Placement Installation: https://docs.openstack.org/placement/train/install/
.. _Nova Installation: https://docs.openstack.org/nova/train/install/
.. _Neutron Installation: https://docs.openstack.org/neutron/train/install/
.. _Cinder Installation: https://docs.openstack.org/cinder/train/install/
.. _Horizon Installation: https://docs.openstack.org/horizon/train/install/

Archivos de configuración
'''''''''''''''''''''''''

A continuación se presenta una lista de archivos que deben ser configurados en el proceso de instalación de OpenStack y sus servicios:

- Environment
    - Security, Networking, Install Linux Utilities: ``/etc/hosts``, ``/etc/default/grub``, ``/etc/netplan/50-cloud-init.yaml``
    - NTP: ``/etc/chrony/chrony.conf``
    - SQL Database: ``/etc/mysql/mariadb.conf.d/99-openstack.cnf``
    - Memcached: ``/etc/memcached.conf``
    - Etcd: ``/etc/default/etcd``, ``/etc/etcd/etcd.conf.yml``, ``/lib/systemd/system/etcd.service``
- Keystone
    - ``/etc/keystone/keystone.conf`` [``controller``]
    - ``/etc/apache2/apache2.conf`` [``controller``]
    - ``~/admin-openrc`` [``controller``]
    - ``~/demo-openrc`` [``controller``]
- Glance
    - ``/etc/glance/glance-api.conf`` [``controller``]
    - ``/etc/glance/glance-registry.conf`` [``controller``]
- Nova
    - ``/etc/nova/nova.conf`` [``controller``]
    - ``/etc/nova/nova.conf`` [``compute``]
    - ``/etc/nova/nova-compute.conf`` [``compute``]
- Neutron
    - ``/etc/neutron/neutron.conf`` [``controller``]
    - ``/etc/neutron/plugins/ml2/ml2_conf.ini`` [``controller``]
    - ``/etc/neutron/plugins/ml2/linuxbridge_agent.ini`` [``controller``]
    - ``/etc/neutron/l3_agent.ini`` [``controller``]
    - ``/etc/neutron/dhcp_agent.ini`` [``controller``]
    - ``/etc/neutron/metadata_agent.ini`` [``controller``]
    - ``/etc/nova/nova.conf`` [``controller``]
    - ``/etc/neutron/neutron.conf`` [``compute``]
    - ``/etc/neutron/plugins/ml2/linuxbridge_agent.ini`` [``compute``]
    - ``/etc/nova/nova.conf`` [``compute``]
- Cinder
    - ``/etc/cinder/cinder.conf`` [``block``]
    - ``/etc/cinder/cinder.conf`` [``controller``]
    - ``/etc/nova/nova.conf`` [``controller``]
- Horizon
    - ``/etc/openstack-dashboard/local_settings.py`` [``controller``]
    - ``/etc/apache2/conf-available/openstack-dashboard.conf`` [``controller``]
    