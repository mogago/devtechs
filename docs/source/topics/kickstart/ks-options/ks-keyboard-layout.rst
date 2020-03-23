Opciones de Kickstart- distribución de teclado
==============================================

.. contents:: Table of Contents

- Referencia 1: `How To Change The System Keyboard Layout`_
- Referencia 2: `Red Hat Docs - CHANGING THE KEYBOARD LAYOUT`_
- Referencia 3: `What is VC keymap`_

.. _How To Change The System Keyboard Layout: https://www.osetc.com/en/centos-7-rhel-7-how-to-change-the-system-keyboard-layout.html
.. _Red Hat Docs - CHANGING THE KEYBOARD LAYOUT: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/s1-changing_the_keyboard_layout
.. _What is VC keymap: https://unix.stackexchange.com/questions/296101/what-is-vc-keymap

Parámetros kickstart - keyboard
-------------------------------

Usando los siguientes parámetros en el archivo kickstart para la distribución del teclado:

.. code-block:: cfg

    keyboard --vckeymap=latam --xlayouts='latam','us'

Obtendremos el siguiente resultado:

.. code-block:: bash

    $ localectl status

    System Locale: LANG=en_US.UTF-8
        VC Keymap: latam
       X11 Layout: latam,us
      X11 Variant: ,

En el anterior output vemos la configuración del keyboard layout para la consola virtual y el X11 window system.

.. Note::

    Usando los siguientes parámetros en el archivo kickstart para la distribución del teclado:

    .. code-block:: cfg

        keyboard --vckeymap=latam

    Obtendremos el siguiente resultado:

    .. code-block:: bash

        $ localectl status

        System Locale: LANG=en_US.UTF-8
            VC Keymap: latam
           X11 Layout: us

Listar keymaps
--------------

Para listar todos los keymaps disponibles podemos hacerlo de 2 formas:

1. Con el comando ``localectl``:

.. code-block:: bash

    $ localectl list-keymaps | grep latam

    latam
    latam-deadtilde
    latam-dvorak
    latam-nodeadkeys
    latam-sundeadkeys

2. Listando el directorio ``/usr/lib/kbd/keymaps/xkb/`` (para usar un layout de esta lista debemos quitarle la última parte ``.map.gz``):

.. code-block:: bash

    $ ls /usr/lib/kbd/keymaps/xkb/ | grep latam

    latam.map.gz
    latam-deadtilde.map.gz
    latam-dvorak.map.gz
    latam-nodeadkeys.map.gz
    latam-sundeadkeys.map.gz

Cambiar el keyboard layout
--------------------------

Para cambiar el keyboard layout usaremos la herramienta ``localectl`` tanto para **VC Keymap** como para **X11 window system**:

- Para cambiar el keyboard layout de **VC Keymap**:

.. code-block:: bash

    $ localectl set-keymap us

    $ localectl status

    System Locale: LANG=en_US.UTF-8
        VC Keymap: us
       X11 Layout: us
        X11 Model: pc105+inet
      X11 Options: terminate:ctrl_alt_bksp

- Para cambiar el keyboard layout de **X11 window system**

.. code-block:: bash

    $ localectl set-x11-keymap latam

    $ localectl status

    System Locale: LANG=en_US.UTF-8
        VC Keymap: latam
       X11 Layout: latam

.. Note::

    Como vemos, al cambiar el keyboard layout usando ``set-x11-keymap`` hemos cambiado tanto la distribución de **VC Keymap** como de **X11 window system**. Para cambiar exclusivamente el keyboard layout de X11 window system usamos el parámetro ``--no-convert``:

    .. code-block:: bash

        $ localectl --no-convert set-x11-keymap us

        $ localectl status

        System Locale: LANG=en_US.UTF-8
            VC Keymap: latam
           X11 Layout: us

