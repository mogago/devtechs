Opciones de Kickstart - selección de paquetes
=============================================

.. contents:: Table of Contents

- Referencia 1: `RHEL 7 Package Groups`_
- Referencia 2: `KICKSTART SYNTAX REFERENCE - Package Selection`_

.. _RHEL 7 Package Groups: https://www.certdepot.net/rhel7-get-started-package-groups/
.. _KICKSTART SYNTAX REFERENCE - Package Selection: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/installation_guide/sect-kickstart-syntax#sect-kickstart-packages

Core Package Group
------------------

.. code-block:: cfg

    %packages
    @core
    %end

``@core`` - 'Core' simple package group. Contiene aproximadamente 291 paquetes.

.. Note::

    Listar paquetes instalados en sistemas operativos basados en Red Hat:

    .. code-block:: bash

        $ rpm -qa
    
    Referencia: `Package list for Kickstart`_

.. _Package list for Kickstart: https://serverfault.com/questions/349769/package-list-for-kickstart

.. Note::

    The ``@Core`` package group is defined as a minimal set of packages needed for installing a working system.
    
    Referencia: `KICKSTART SYNTAX REFERENCE - Package Selection`_

Default Package Groups
----------------------

El grupo de paquetes ``Core`` es agregado por defecto cuando usamos el parámetro ``%packages`` en el archivo Kickstart. Por tanto, el siguiente bloque del archivo kickstart:

.. code-block:: cfg

    %packages
    %end

Es equivalente a usar el siguiente bloque en el archivo kickstart:

.. code-block:: cfg

    %packages
    @core
    %end

.. Note::

    The Core group is always selected - it is not necessary to specify it in the %packages section.
    
    Referencia: `KICKSTART SYNTAX REFERENCE - Package Selection`_

Minimal Install Environment Group
---------------------------------

.. code-block:: cfg

    %packages
    @^minimal
    %end

``@^minimal`` - 'Minimal install' environment group. Contiene el mandatory group ``core``, que a su vez se conforma de 291 paquetes.

Listar groups (Mandatory y Optional) que contiene el environment group 'Minimal install':

.. code-block:: bash

    '#' yum group info "Minimal Install"

    Loaded plugins: fastestmirror, langpacks
    Loading mirror speeds from cached hostfile
    ...
    Environment Group: Minimal Install
     Environment-Id: minimal
     Description: Basic functionality.
     Mandatory Groups:
       +core
     Optional Groups:
       +debugging

.. Note::

    El prefijo ``@^`` está reservado para environment groups

.. Important::

    If you are not sure what package should be installed, Red Hat recommends you to select the Minimal Install environment. Minimal install provides only the packages which are essential for running Red Hat Enterprise Linux 7. 

    Referencia: `KICKSTART SYNTAX REFERENCE - Package Selection`_
 
