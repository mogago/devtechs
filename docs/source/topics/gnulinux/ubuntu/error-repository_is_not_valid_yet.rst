Solucionar error ``repository is not valid yet``
================================================

.. contents:: Table of Contents

Cuando deseamos actualizar los paquetes podemos obtener el siguiente error: *Release file for [...] is not valid yet (invalid for another [...]). Updates for this repository will not be applied."*

Descripción del error
---------------------

.. code-block:: bash

    $ sudo apt update

    Get:1 http://pe.archive.ubuntu.com/ubuntu bionic-updates InRelease [88.7 kB]    
    E: Release file for http://pe.archive.ubuntu.com/ubuntu/dists/bionic-updates/InRelease is not valid yet (invalid for another 8d 3h 23min 37s). Updates for this repository will not be applied.

Este error nos indica que el **release file** no es válido aún. La causa de esto es que nuestra hora del sistema está atrasada respecto a la hora del release file. Verifiquemos esto con los siguientes comandos:

- Hora del sistema:

.. code-block:: bash

    $ timedatectl
                          Local time: Sun 2020-03-29 11:30:26 UTC
                      Universal time: Sun 2020-03-29 11:30:26 UTC
                            RTC time: Sun 2020-03-29 10:51:01
                           Time zone: Etc/UTC (UTC, +0000)
           System clock synchronized: no
    systemd-timesyncd.service active: yes
                     RTC in local TZ: no

- Hora del release file:

.. code-block:: bash

    $ sudo head -14 /var/lib/apt/lists/partial/pe.archive.ubuntu.com_ubuntu_dists_bionic-updates_InRelease

    -----BEGIN PGP SIGNED MESSAGE-----
    Hash: SHA512

    Origin: Ubuntu
    Label: Ubuntu
    Suite: bionic-updates
    Version: 18.04
    Codename: bionic
    Date: Mon, 06 Apr 2020 14:42:02 UTC
    Architectures: amd64 arm64 armhf i386 ppc64el s390x
    Components: main restricted universe multiverse
    Description: Ubuntu Bionic Updates
    MD5Sum:
     e8b27420ceea0481a7c733eca0463406         50695339 Contents-armhf.gz
    
.. Note::

    Los release files son encontrados bajo el directorio ``/var/lib/apt/lists/partial/``

Como se ve, la hora de nuestro sistema (``Local time: Sun 2020-03-29 11:30:26 UTC``) está retrasada respecto a la del repository file (``Date: Mon, 06 Apr 2020 14:42:02 UTC``).

.. Important::

    La diferencia de tiempo puede causarse debido a que hemos iniciado nuestro sistema desde un snapshot, haciendo la hora figure sea la hora en que se tomó la snapshot.

Solución del error
------------------

Para solucionar el error debemos sincronizar el reloj del sistema con time servers. Con este fin, podemos usar la herramienta ``chrony``:

- Instalar ``chrony``:

.. code-block:: bash

    $ sudo apt install chrony

- Sincronizar el tiempo del sistema:

.. code-block:: bash

    $ sudo chronyd -q

    2020-03-29T11:51:27Z chronyd version 3.2 starting (+CMDMON +NTP +REFCLOCK +RTC +PRIVDROP +SCFILTER +SECHASH +SIGND +ASYNCDNS +IPV6 -DEBUG)
    2020-03-29T11:51:27Z Frequency 1.101 +/- 2.384 ppm read from /var/lib/chrony/chrony.drift
    2020-03-29T11:51:35Z System clock wrong by 709923.800611 seconds (step)
    2020-04-06T17:03:39Z chronyd exiting

.. Note::

    Podemos ver cuánto varía el tiempo de nuestro sistema con el del servidor de internet:

    .. code-block:: bash

        $ sudo chronyd -Q

        2020-04-06T17:04:07Z chronyd version 3.2 starting (+CMDMON +NTP +REFCLOCK +RTC +PRIVDROP +SCFILTER +SECHASH +SIGND +ASYNCDNS +IPV6 -DEBUG)
        2020-04-06T17:04:07Z Disabled control of system clock
        2020-04-06T17:04:07Z Frequency 1.101 +/- 2.384 ppm read from /var/lib/chrony/chrony.drift
        2020-04-06T17:04:15Z System clock wrong by -0.005141 seconds (ignored)
        2020-04-06T17:04:15Z chronyd exiting

Referencias
-----------

- `How to deal with repository is not valid yet error`_
- `Keep Your Clock Sync with Internet Time Servers in Ubuntu 18.04`_

.. _How to deal with repository is not valid yet error: https://blog.sleeplessbeastie.eu/2019/11/15/how-to-deal-with-repository-is-not-valid-yet-error/
.. _Keep Your Clock Sync with Internet Time Servers in Ubuntu 18.04: https://vitux.com/keep-your-clock-sync-with-internet-time-servers-in-ubuntu/