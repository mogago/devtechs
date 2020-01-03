Programas instalados
====================

.. contents:: Table of Contents

Verificar la versión de Raspbian
--------------------------------

.. code-block:: bash

    $ cat /etc/os-release

    PRETTY_NAME="Raspbian GNU/Linux 10 (buster)"
    NAME="Raspbian GNU/Linux"
    VERSION_ID="10"
    VERSION="10 (buster)"
    VERSION_CODENAME=buster
    ID=raspbian
    ID_LIKE=debian
    HOME_URL="http://www.raspbian.org/"
    SUPPORT_URL="http://www.raspbian.org/RaspbianForums"
    BUG_REPORT_URL="http://www.raspbian.org/RaspbianBugs"

Verificar arquitectura del sistema
----------------------------------

.. code-block:: bash

    $ uname -a
    Linux raspberrypi 4.19.75-v7+ #1270 SMP Tue Sep 24 18:45:11 BST 2019 armv7l GNU/Linux

El sistema tiene una arquitectura ``armv7 32 bits``.

Instalar software-properties-common
-----------------------------------

.. code-block:: bash

    $ sudo add-apt-repository
    sudo: add-apt-repository: command not found

    $ sudo apt-get install software-properties-common

Instalar Visual Studio Code
---------------------------

Basado en: `Installing VS Code on Raspbian buster`_

.. _Installing VS Code on Raspbian buster: https://www.raspberrypi.org/forums/viewtopic.php?t=191342

1. Instalar GPG key

.. code-block:: bash

    $ sudo wget -qO - https://packagecloud.io/headmelted/codebuilds/gpgkey | sudo apt-key add -;
    OK

2. Añadir source repository

.. code-block:: bash

    $ sudo nano /etc/apt/sources.list

... y añadir:

.. code-block:: bash

    deb https://packagecloud.io/headmelted/codebuilds/raspbian/ jessie main

.. Note::

    Usar la versión ``jessie`` de Raspbian aún cuando tengamos la versión buster.

3. Instalar VS Code (code-oss)

.. code-block:: bash

    $ sudo apt-get update
    $ sudo apt-get install code-oss

Ejecutar ``sudo apt-get update`` es esencial para que funcione

4. Ejecutar VS Code (code-oss)

.. code-block:: bash

    $ code-oss

5. Versión de VS Code

.. code-block:: bash

    $ code-oss -version

Instalar Teamviewer
-------------------

Basado en: `How to Install Teamviewer on Raspberry Pi 2/3/4 Within a Minute`_

.. _`How to Install Teamviewer on Raspberry Pi 2/3/4 Within a Minute`: https://www.techrrival.com/install-teamviewer-raspberry-pi/

1. Descargar de la `página web oficial de descargas de Teamviewer para Linux`_, la versión de Teamviewer para Raspbian con **arquitectura armv7 32bit**.

.. _página web oficial de descargas de Teamviewer para Linux: http://teamviewer.com/en-us/download/linux

2. Instalar el paquete ``.deb``. Se tendrá varias dependencias faltantes: 

.. code-block:: bash

    $ sudo dpkg -i ~/Downloads/teamviewer-host_15.1.3937_armhf.deb

3. Para descargar las dependencias ejecutar:

.. code-block:: bash
    
    $ sudo apt-get update

4. Instalar las dependencias:

.. code-block:: bash

    $ sudo apt-get -f install

Instalar redshift
-----------------

1. Instalar redshift

.. code-block:: bash

    $ sudo apt-get install redshift

2. Ejecutar el siguiente comando:

.. code-block:: bash

    $ sudo raspi-config

Ir a :guilabel:`Advanced Options`, luego :guilabel:`GL Driver` y seleccionar :guilabel:`G3 GL (FUll KMS)`.

3. Al hacer el cambio pedirá reiniciar el sistema. Aceptar.

4. Comprobar que redshift funcione ejecutando en el terminal:

.. code-block:: bash

    $ redshift -O 3500

5. Regresar a un modo normal: ``-x     Reset mode (remove adjustment from screen)``

.. code-block:: bash
    
    $ redshift -x

Instalar aplicación para screenshots
------------------------------------

Scrot es una aplicación de línea de comandos para tomar capturas de pantallas en un Raspberry Pi.

Generalmente Scrot ya viene instalado con Raspbian, de no ser el caso, instalarlo con:

.. code-block:: bash

    $ sudo apt-get install scrot

Tenemos varias opciones de uso para capturar la pantalla:

1. Tomar una captura instantánea a toda la pantalla:

.. code-block:: bash

    $ scrot

2. Tomar una captura con delay:

.. code-block:: bash

    # Delay de 3 segundos:
    $ scrot -d 3

Agregar un contandor al terminal:

.. code-block:: bash

    $ scrot -c -d 3

3. Tomar captura solo a la aplicación actual (se agrega un delay para poder cambiar a la ventana deseada):

.. code-block:: bash

    $ scrot -u -d 3

4. Tomar una captura a solo un área seleccionada:

.. code-block:: bash

    $ scrot -s

5. Ejecutar una aplicación sobre la imagen guardada:

.. code-block:: bash

    # Abrir la imagen con el visor de imágenes por defecto de Raspbian
    $ scrot -e gpicview
