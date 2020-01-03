Creación de un usuario
======================

.. contents:: Table of Contents

Creando el usuario
------------------

Forma 1 - usando ``adduser``
''''''''''''''''''''''''''''

.. Note::

    DEBIAN/UBUNTU

.. code-block:: bash

    root@ubuntudskt1:~'#' adduser user1

    Añadiendo el usuario user1 ...
    Añadiendo el nuevo grupo user1 (1001) ...
    Añadiendo el nuevo usuario user1 1001 con grupo user1 ...
    Creando el directorio personal /home/user1 ...
    Copiando los ficheros desde /etc/skel ...

    Introduzca la nueva contraseña de UNIX:
    Vuelva a escribir la nueva contraseña de UNIX:
    passwd: contraseña actualizada correctamente

    Cambiando la información de usuario para user1
    Introduzca el nuevo valor, o presione INTRO para el predeterminado
        Nombre completo []:
        Número de habitación []:
        Teléfono del trabajo []:
        Teléfono de casa []:
        Otro []:
    ¿Es correcta la información? [S/n] S

.. Note::

    RHEL/CENTOS

.. code-block:: bash

    [root@localhost ~]'#' adduser -md /home/user1 -s /bin/bash user1

.. code-block:: bash

    [root@localhost ~]'#' passwd user1

    Changing password for user user1.
    New password:
    Retype new password:
    passwd: all authentication tokens updated successfully.

Forma 2 - usando ``useradd``
''''''''''''''''''''''''''''

.. Note::

    DEBIAN/UBUNTU

.. code-block:: bash

    root@ubuntudskt1:~'#' useradd -md /home/user1 -s /bin/bash user1

.. code-block:: bash

    root@ubuntudskt1:~'#' passwd user1

    Introduzca la nueva contraseña de UNIX:
    Vuelva a escribir la nueva contraseña de UNIX:
    passwd: contraseña actualizada correctamente

.. Note::

    RHEL/CENTOS

.. code-block:: bash

    [root@localhost ~]'#' useradd -md /home/user1 -s /bin/bash user1

.. code-block:: bash

    [root@localhost ~]'#' passwd user1

    Changing password for user user1.
    New password:
    Retype new password:
    passwd: all authentication tokens updated successfully.

Dando permisos de ``sudo`` al usuario
-------------------------------------

.. Note::

    DEBIAN/UBUNTU

.. code-block:: bash

    root@ubuntudskt1:~'#' usermod -aG sudo user1

.. Note::

    RHEL/CENTOS

.. code-block:: bash

    [root@localhost ~]'#' usermod -aG wheel user1

Habilitando passwordless ``sudo`` al usuario
--------------------------------------------

.. Note::

    DEBIAN/UBUNTU = RHEL/CENTOS

Forma 1 - creando un archivo en el directorio ``/etc/sudoers.d``
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

.. code-block:: bash

    $ echo "user1 ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/user1

    [sudo] contraseña para user1:
    user1 ALL = (root) NOPASSWD:ALL

.. code-block:: bash

    $ sudo chmod 0440 /etc/sudoers.d/user1

Forma 2 - agregando una entrada archivo ``/etc/sudoers`` con ``visudo``
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

.. code-block:: bash

    $ sudo visudo -f /etc/sudoers
    [sudo] contraseña para user1:

.. code-block:: bash

    [...]
    #includedir /etc/sudoers.d
    user1 ALL=(ALL) NOPASSWD:ALL

Links útiles
------------

- `How To Create a Sudo User on Ubuntu`_
- `How To Create a Sudo User on CentOS`_

.. _How To Create a Sudo User on Ubuntu: https://www.digitalocean.com/community/tutorials/how-to-create-a-sudo-user-on-ubuntu-quickstart
.. _How To Create a Sudo User on CentOS: https://www.digitalocean.com/community/tutorials/how-to-create-a-sudo-user-on-centos-quickstart
