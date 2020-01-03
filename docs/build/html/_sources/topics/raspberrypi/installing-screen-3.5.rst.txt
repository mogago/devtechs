Instalar pantalla táctil 3.5'
=============================

Para la instalación de la pantalla táctil se usa un programa llamado **Elecrow**.

.. contents:: Table of Contents

Obtener paquetes
----------------

.. code-block:: bash

    $ cd ~ 
    $ git clone https://github.com/Elecrow-keen/Elecrow-LCD35.git

Cambiar a modo pantalla 3.5'
----------------------------

Este modo deja initulizable la pantalla HDMI.

.. code-block:: bash

    $ cd ~/Elecrow-LCD35
    $ sudo ./Elecrow-LCD35

Cambiar a modo pantalla HDMI
----------------------------

Este modo deja initulizable la pantalla táctil 3.5'.

.. code-block:: bash

    $ cd ~/Elecrow-LCD35
    $ sudo ./Elecrow-LCD35 hdmi

Scripts para automatizar cambio de modos
----------------------------------------

Script ``mini-screen-mode.sh``
''''''''''''''''''''''''''''''

.. code-block:: bash

    #!/bin/bash

    cd ~/Programs/Elecrow-LCD35
    sudo ./Elecrow-LCD35 hdmi

Script ``hdmi-mode.sh``
'''''''''''''''''''''''

.. code-block:: bash

    #!/bin/bash

    cd ~/Programs/Elecrow-LCD35
    sudo ./Elecrow-LCD35

Links útiles
------------

- `Tutorial - 3.5 Inch 480x320 TFT Display with Touch Screen for Raspberry Pi`_
- `Elecrow-LCD35 GitHub repository`_
- `Switching back to HDMI output - GitHub issue`_

.. _Tutorial - 3.5 Inch 480x320 TFT Display with Touch Screen for Raspberry Pi: https://www.elecrow.com/wiki/index.php?title=3.5_Inch_480x320_TFT_Display_with_Touch_Screen_for_Raspberry_Pi
.. _Elecrow-LCD35 GitHub repository: https://github.com/Elecrow-RD/Elecrow-LCD35
.. _Switching back to HDMI output - GitHub issue: https://github.com/Elecrow-RD/Elecrow-LCD35/issues/1