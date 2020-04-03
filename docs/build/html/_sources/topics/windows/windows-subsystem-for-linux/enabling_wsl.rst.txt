Enabling Windows Subsystem for Linux
====================================

.. contents:: Table of Contents

Enable WSL
''''''''''

Podemos habilitar el **Windows Subsystem for Linux (WSL)** desde la interfaz gráfica o usando comandos en Powershell.

Option 1 - Windows Features dialog
""""""""""""""""""""""""""""""""""

En la barra de navegación de Windows, buscar :guilabel:`Características de Windows` y abrir el programa :guilabel:`Activar o desactivar las características de Windows`. Activar la opción :guilabel:`Subsistema de Windows para Linux` (:guilabel:`Windows Subsystem for Linux`). Presionar :guilabel:`Aceptar`

.. figure:: images/enabling_wsl/enable_wsl_windows_features.png
    :align: center

    Habilitando WSL en :guilabel:`Características de Windows`

Luego nos saldrá una opción para reiniciar Windows, aceptarla.

Option 2 - PowerShell
"""""""""""""""""""""

Abrir :guilabel:`PowerShell` con la opción :guilabel:`Ejecutar como Administrador` y ejecutar el siguiente comando:

.. code-block:: powershell

    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

.. figure:: images/enabling_wsl/enable_wsl_powershel.png
    :align: center

    Habilitando WSL en :guilabel:`Powershell`

Luego de correr el comando debemos reiniciar el sistema, aceptando con :guilabel:`Y`.

Check
'''''

Luego de haber reiniciado Windows, podemos comprobar que hemos instalado correctamente WSL corriendo el comando ``wsl`` en el terminal:

.. figure:: images/enabling_wsl/wsl_check.png
    :align: center

    Check WSL

Install your Linux Distribution of Choice
'''''''''''''''''''''''''''''''''''''''''

Option 1 - Download and install from the Microsoft Store
""""""""""""""""""""""""""""""""""""""""""""""""""""""""

La opción más sencilla es buscar la distribución de nuestra preferencia en el Microsoft Store e instalarla:

.. figure:: images/enabling_wsl/wsl_distro_microsoft_store.png
    :align: center

    Instalar Ubuntu 18.04 Distro para WSL


Option 2 - Download and install from the Command-Line/Script
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Otra opción será usar el programa :guilabel:`Powershell`:

- Descargar la distribución por línea de comandos:

.. code-block:: bat

    cd .\Desktop\
    Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile Ubuntu.appx -UseBasicParsing
    
.. Note::

    Ver lista de distros disponibles para descargar en formato ``.appx``: `Downloading distros`_

- Instalar la distro:

.. code-block:: powershell

    Add-AppxPackage .\Ubuntu.appx

Initializing a newly installed distro
'''''''''''''''''''''''''''''''''''''

Initializing from Ubuntu terminal
"""""""""""""""""""""""""""""""""

- Abrir en el navegador de Windows el programa con el nombre de la aplicación instalada. Por ejemplo, en este caso :guilabel:`Ubuntu`

.. figure:: images/enabling_wsl/wsl_distro_installed.png
    :align: center

    Iniciar el programa de la distro instalada

- Comenzará la configuración inicial y nos pedirá crear un usuario con contraseña:

.. figure:: images/enabling_wsl/wsl_distro_user_created.png
    :align: center

    Iniciar el programa de la distro instalada

Initializing from Powershell
""""""""""""""""""""""""""""

Podemos iniciar el **Windows Subsystem for Linux (WSL)** desde el **Powershell** o la línea de comandos **CMD** de Windows usando el comando ``wsl``:

.. figure:: images/enabling_wsl/wsl_start_from_powershell.png
    :align: center

    Iniciar el programa de la distro instalada desde Powershell

Referencias
'''''''''''

- `Windows Subsystem for Linux Documentation`_
- `Windows Subsystem for Linux Installation Guide for Windows 10`_
- `Enable WSL`_
- `Manually download Windows Subsystem for Linux distro packages`_
- `Downloading distros`_
- `Initializing a newly installed distro`_
- `How to Remove Windows 10s Bash Tools Completely`_

.. _Windows Subsystem for Linux Documentation: https://docs.microsoft.com/en-us/windows/wsl/about
.. _Windows Subsystem for Linux Installation Guide for Windows 10: https://docs.microsoft.com/en-us/windows/wsl/install-win10
.. _Enable WSL: https://code.visualstudio.com/remote-tutorials/wsl/enable-wsl
.. _Manually download Windows Subsystem for Linux distro packages: https://docs.microsoft.com/en-us/windows/wsl/install-manual
.. _Downloading distros: https://docs.microsoft.com/en-us/windows/wsl/install-manual#downloading-distros
.. _Initializing a newly installed distro: https://docs.microsoft.com/en-us/windows/wsl/initialize-distro
.. _How to Remove Windows 10s Bash Tools Completely: https://www.howtogeek.com/261188/how-to-uninstall-or-reinstall-windows-10s-ubuntu-bash-shell/