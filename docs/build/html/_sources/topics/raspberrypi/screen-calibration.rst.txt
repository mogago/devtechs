Calibración de pantalla táctil
==============================

Para la calibración de la pantalla se usa un programa llamado **xinput calibrator**.

.. contents:: Table of Contents

Instalación de paquetes
-----------------------

.. code-block:: bash

    $ cd Elecrow-LCD35
    $ sudo dpkg -i -B xinput-calibrator_0.7.5-1_armhf.deb

Calibración
-----------

Luego de instalar este paquete se creará una opción llamada :guilabel:`Calibrate Touchscreen`.

Para entrar ir a :menuselection:`Menú --> Preferencias --> Calibrate Touchscreen`.

.. figure:: images/screen-calibration/menu-selection.png
    :align: center

    Menú - Preferencias

Se puede entrar a este menú solo cuando se reconoce un dispositivo que pueda ser configurado. Por lo tanto cambiar de modo a **pantalla 3.5"**.

.. code-block:: bash

    $ cd ~/Elecrow-LCD35
    $ sudo ./Elecrow-LCD35

Usar :guilabel:`Calibrate Touchscreen` para calibrar la pantalla táctil. Una vez acabada la calibración, se generará un archivo con la siguiente ruta: ``/etc/X11/xorg.conf.d/99-calibration.conf``

Opcionalmente podemos copiar esta configuración en un archivo distinto: ``cp /etc/X11/xorg.conf.d/99-calibration.conf ~/Documents/files/99-calibration.conf``

.. code-block:: bash

    # --- added by elecrow-pitft-setup sáb jun  1 19:13:04 -05 2019 ---
    Section "InputClass"
        Identifier	"calibration"
        MatchProduct	"ADS7846 Touchscreen"
        Option	"Calibration"	"3917 250 242 3863"
        Option	"SwapAxes"	"1"
    EndSection
    # --- end elecrow-pitft-setup sáb jun  1 19:13:04 -05 2019 ---
