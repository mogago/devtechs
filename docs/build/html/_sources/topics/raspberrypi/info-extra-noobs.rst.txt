Información extra de NOOBS
==========================

.. contents:: Table of Contents

NOOBS's Command Line Interface
------------------------------

- Entrar a la interfaz de línea de comandos de NOOBS con: :guilabel:`Alt+FN+F2`
- Regresar a la interfaz gráfica de NOOBS con: :guilabel:`Alt+FN+F1`
- Credenciales de usuario (NOOBS): user:pass = ``root:raspberry``
- Apagar NOOBS: ``poweroff -f``

Tomar capturas de pantalla en NOOBS
-----------------------------------

Cuando se enciende el Raspberry Pi con un tarjeta SD que tiene instalado NOOBS, no se tiene ningún programa que permita tomar capturas de pantalla o usar otras funcionalidades. Para tomar capturas podemos usar VNC desde otra PC en la misma red que el Raspberry Pi y ver su pantalla.

Solución basada en un `Foro de Raspberry Pi para activar VNC en NOOBS`_ y una `guía de GitHub para usar PINN con VNC`_.

.. _Foro de Raspberry Pi para activar VNC en NOOBS: https://www.raspberrypi.org/forums/viewtopic.php?t=167492
.. _guía de GitHub para usar PINN con VNC: https://github.com/procount/pinn/blob/master/README_PINN.md#how-to-use-pinn-headlessly-vnc

1. Editar el archivo ``recovery.cmdline`` de los archivos copiados a la tarjeta micro SD para la instalación de NOOBS. Al final de la primera y única línea ingresar ``vncinstall forcetrigger``.

- ``vncinstall`` inhabilita la capacidad de ver una interfaz gráfica con la pantalla conectada al Rasberry Pi, solo permite verla a través de un usuario conectado por VNC al Raspberry Pi.
- ``forcetrigger`` fuerza a usar VNC para la instalación; eliminarlo una vez esta acabe.

2. Insertar la tarjeta micro SD al Raspberry Pi y encenderlo (procurar que esté conectado mediante cable Ethernet a un servidor DHCP para que pueda recibir una IP). En el monitor solo saldrá:

.. code-block:: bash

    ip: SIOCGIFFLAGS: No such device
    Starting system message bus: done

3. Entrar a la línea de comandos de NOOBS (``Alt+FN+F2``) y verificar que tiene una ip (``ip address``). De no ser así, asignarle una IP dentro de la red.

4. Instalar VNC Viewer en una PC con Windows o Linux que esté dentro de la misma red que el Raspberry Pi. (`Descargar VNC`_).

.. _Descargar VNC: https://www.realvnc.com/en/connect/download/viewer/

5. Conectarnos desde el programa VNC insertando la IP del Raspberry Pi:

.. figure:: images/installing-os-with-noobs/noobs-cli-1.png
    :align: center

    Conexión remota al Raspberry Pi desde VNC

.. figure:: images/installing-os-with-noobs/noobs-cli-2.png
    :align: center

    Conexión remota al Raspberry Pi desde VNC

Luego de instalar el sistema operativo y reiniciar el Raspberry Pi debemos remover  las opciones ``vncinstall`` y ``forcetrigger``, ya que de no hacerlo volverá a aparecer la pantalla con el mensaje:

.. code-block:: bash

    ip: SIOCGIFFLAGS: No such device
    Starting system message bus: done

Insertar la tarjeta micro SD en la PC, abrir la partición RECOVERY y editar el archivo ``recovery.cmdline``. Quitar las opciones ``vncinstall`` y ``forcetrigger`` de la línea.

Para volver al modo recovery cuando queramos se debe mantener presionada la tecla Shift cuando es Rasberry Pi está prendiendo. Podemos seleccionar y cambiar nuestro sistema operativo pero toda la data del usuario se perderá.

.. figure:: images/installing-os-with-noobs/noobs-cli-3.jpeg
    :align: center

    Ingresar al modo recovery

Configuración inicial de Raspbian (post instalación)
----------------------------------------------------

.. figure:: images/installing-os-with-noobs/raspbian-initial.config-01.png
    :align: center

    Proceso de Configuración inicial de Raspbian

.. figure:: images/installing-os-with-noobs/raspbian-initial.config-02.png
    :align: center

    Proceso de Configuración inicial de Raspbian

.. figure:: images/installing-os-with-noobs/raspbian-initial.config-03.png
    :align: center

    Proceso de Configuración inicial de Raspbian

.. figure:: images/installing-os-with-noobs/raspbian-initial.config-04.png
    :align: center

    Proceso de Configuración inicial de Raspbian

.. figure:: images/installing-os-with-noobs/raspbian-initial.config-05.png
    :align: center

    Proceso de Configuración inicial de Raspbian

.. figure:: images/installing-os-with-noobs/raspbian-initial.config-06.png
    :align: center

    Proceso de Configuración inicial de Raspbian

.. figure:: images/installing-os-with-noobs/raspbian-initial.config-07.png
    :align: center

    Proceso de Configuración inicial de Raspbian

.. figure:: images/installing-os-with-noobs/raspbian-initial.config-08.png
    :align: center

    Proceso de Configuración inicial de Raspbian

.. figure:: images/installing-os-with-noobs/raspbian-initial.config-09.png
    :align: center

    Proceso de Configuración inicial de Raspbian

.. figure:: images/installing-os-with-noobs/raspbian-initial.config-10.png
    :align: center

    Proceso de Configuración inicial de Raspbian

.. figure:: images/installing-os-with-noobs/raspbian-initial.config-11.png
    :align: center

    Proceso de Configuración inicial de Raspbian

.. figure:: images/installing-os-with-noobs/raspbian-initial.config-12.png
    :align: center

    Proceso de Configuración inicial de Raspbian

Extra - Tarjeta micro SD está protegida contra escritura
--------------------------------------------------------

ERROR:

- Cannot format write protected card

.. figure:: images/installing-os-with-noobs/sd-card-protected-1.png
    :align: center

    Cannot format write protected card

- El disco está protegido contra escritura

.. figure:: images/installing-os-with-noobs/sd-card-protected-2.png
    :align: center

    El disco está protegido contra escritura

SOLUCIÓN:

1. Ver que el Lock del adaptador SD - micro SD esté desbloqueado.
2. Probar con varios adapatadores SD.
3. Seguir el siguiente tutorial: `Cómo quitar la protección contra escritura de un USB en Windows`_

.. _Cómo quitar la protección contra escritura de un USB en Windows: https://www.xataka.com/basics/como-quitar-la-proteccion-contra-escritura-de-un-usb-en-windows

Links importantes
-----------------

- `NOOBS (New Out of Box Software) GitHub page`_: para una configuración más avanzada y completa de NOOBS y ver su código fuente visitar su página en GitHub.
- `PINN GitHub page`_: An easy enhanced Operating System installer for the Raspberry Pi
- `Projects Raspberry - Installing Raspbian with NOOBS`_
- `Getting started with NOOBS`_
- `Rasberry Forum screenshots on NOOBS`_
- `VNC to NOOBS GitHub issues`_
- `How to Take Raspberry Pi Screenshots With VNC`_
- `NOOBS credentials Stackexchange`_
- `Boot Multiple OSs`_: 3 Ways to Boot Multiple OSes on a Raspberry Pi

.. _NOOBS (New Out of Box Software) GitHub page: GitHub page https://github.com/raspberrypi/noobs
.. _PINN GitHub page: https://github.com/procount/pinn/blob/master/README_PINN.md
.. _Projects Raspberry - Installing Raspbian with NOOBS: https://projects.raspberrypi.org/en/projects/noobs-install
.. _Getting started with NOOBS: https://www.raspberrypi.org/help/noobs-setup/2/
.. _Rasberry Forum screenshots on NOOBS: https://www.raspberrypi.org/forums/viewtopic.php?t=59947
.. _VNC to NOOBS GitHub issues: https://github.com/raspberrypi/noobs/issues/116
.. _How to Take Raspberry Pi Screenshots With VNC: https://computers.tutsplus.com/tutorials/how-to-take-raspberry-pi-screenshots-with-vnc--cms-21739
.. _NOOBS credentials Stackexchange: https://raspberrypi.stackexchange.com/questions/8105/noobs-recovery-password
.. _Boot Multiple OSs: https://www.makeuseof.com/tag/how-to-install-multiple-oses-on-a-single-sd-card-for-raspberry-pi/
