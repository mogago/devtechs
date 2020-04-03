Conectarse por SSH a Windows 10 (OpenSSH server)
================================================

.. contents:: Table of Contents

Instalación de OpenSSH Server
'''''''''''''''''''''''''''''

Tenemos 2 opciones para instalar OpenSSH Server, desde un entorno gráfico o con la línea de comandos.

Opción 1 - Usando interfaz gráfica
""""""""""""""""""""""""""""""""""

1. Abrir el programa :guilabel:`Aplicaciones y características` de Windows y elegir la opción :guilabel:`Características opcionales`:

.. figure:: images/ssh_into_windows_openssh_server/install_openssh_server_gui_1.png
    :align: center

    Opción :guilabel:`Características opcionales` del programa :guilabel:`Aplicaciones y características`

2. Clic en :guilabel:`+ Agregar una característica`:

.. figure:: images/ssh_into_windows_openssh_server/install_openssh_server_gui_2.png
    :align: center

    Opción :guilabel:`+ Agregar una característica`

3. Buscar :guilabel:`Servidor de OpenSSH` y clic en :guilabel:`Instalar`:

.. figure:: images/ssh_into_windows_openssh_server/install_openssh_server_gui_3.png
    :align: center

    En la característica :guilabel:`Servidor de OpenSSH`, opción :guilabel:`Instalar`:

4. Comprobar que hemos agregado correctamente el :guilabel:`Servidor de OpenSSH`:

.. figure:: images/ssh_into_windows_openssh_server/install_openssh_server_gui_4.png
    :align: center

    Comprobar que está instalado el :guilabel:`Servidor de OpenSSH`:

Opción 2 - Usando Powershell
""""""""""""""""""""""""""""

Abrir el programa **Powershell** como administrador. Y ejecutar los siguientes comandos:

.. code-block:: powershell

    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    Set-Service -Name ssh-agent -StartupType 'Automatic'
    Set-Service -Name sshd -StartupType 'Automatic'
    Get-Service ssh* | Start-Service

Abrir el archivo ``sshd_config`` con un editor de texto
'''''''''''''''''''''''''''''''''''''''''''''''''''''''

- Con un editor de texto editar el archivo ``sshd_config``:

Usando Visual Studio Code
"""""""""""""""""""""""""

- Abrir **Powershell** en modo administrador y ejecutar los siguiente comandos:

.. code-block:: bat

    cd C:\ProgramData\ssh\
    code sshd_config

Usando Bloc de Notas
""""""""""""""""""""

- Abrir **Powershell** en modo administrador y ejecutar los siguiente comandos:

.. code-block:: bat

    cd C:\ProgramData\ssh\
    notepad sshd_config

Usando WSL
""""""""""

- Abrir un terminal de Linux como administrador y ejeutar los siguientes comandos:

.. code-block:: bash

    sudo su
    cd /mnt/c/ProgramData/ssh/

.. code-block:: bash

    vim sshd_config

Configuración del servidor OpenSSH
''''''''''''''''''''''''''''''''''

.. code-block:: text

    Port 2233
    PasswordAuthentication yes
    #PermitEmptyPasswords yes

.. Note::

    En caso, el usuario de Windows no tenga una contraseña establecida; en primer lugar, probar usando como contraseña el nombre de usuario. En caso no funcione, habilitar la línea ``PermitEmptyPasswords yes`` en el archivo ``sshd_config`` y reiniciar el servicio de SSH. Con esta última opción se habilita las conexiones SSH para usuario que no tiene contraseña.

Agregar una regla al Firewall de Windows
''''''''''''''''''''''''''''''''''''''''

- Abrir el puerto ``2233`` en el firewall de Windows:

1. En el barra de navegación de Windows, abrir el programa :guilabel:`WF.msc` Seleccionar la opción :guilabel:`Reglas de entrada` en la barra izquierda:

.. figure:: images/ssh_into_windows_openssh_server/new_windows_ssh_firewall_rule_1.png
    :align: center

    Abrir el programa :guilabel:`WF.msc` de Windows, :guilabel:`Reglas de entrada`

2. Seleccionar la opción :guilabel:`Nueva regla...` en la barra derecha:

.. figure:: images/ssh_into_windows_openssh_server/new_windows_ssh_firewall_rule_2.png
    :align: center

    Seleccionar la opción :guilabel:`Nueva regla...`

3. Seleccionar el tipo de regla :guilabel:`Puerto`:

.. figure:: images/ssh_into_windows_openssh_server/new_windows_ssh_firewall_rule_3.png
    :align: center

    Tipo de regla: :guilabel:`Puerto`

4. Aplicar la regla a :guilabel:`TCP` y usar la opción :guilabel:`Puertos locales específicos:` y escribir :guilabel:`2233`:

.. figure:: images/ssh_into_windows_openssh_server/new_windows_ssh_firewall_rule_4.png
    :align: center

    Aplicar la regla a :guilabel:`TCP`, :guilabel:`Puertos locales específicos:` :guilabel:`2233`

5. Elegir la opción :guilabel:`Permitir la conexión`:

.. figure:: images/ssh_into_windows_openssh_server/new_windows_ssh_firewall_rule_5.png
    :align: center

    Seleccionar :guilabel:`Permitir la conexión`

6. Aplicar la regla sobre todas las opciones: :guilabel:`Dominio`, :guilabel:`Privado`, :guilabel:`Público`

.. figure:: images/ssh_into_windows_openssh_server/new_windows_ssh_firewall_rule_6.png
    :align: center

    Seleccionar :guilabel:`Permitir la conexión`

7. Dar un nombre y descripción a la nueva regla de firewall creada:

.. figure:: images/ssh_into_windows_openssh_server/new_windows_ssh_firewall_rule_7.png
    :align: center

    Nombre y descripción de la regla de firewall

Reiniciar el servicio de SSH
''''''''''''''''''''''''''''

.. code-block:: powershell

    Restart-Service sshd

- Verificar que se encuentre escuchando en el puerto ``2233``:

.. code-block:: bat

    netstat -aon | findstr "2233"
      TCP    0.0.0.0:2233           0.0.0.0:0              LISTENING       9972
      TCP    [::]:2233              [::]:0                 LISTENING       9972

Conexión remota por SSH
'''''''''''''''''''''''

- Desde un equipo remoto conectarnos por SSH al sistema Windows usando un terminal o PuTTY, apuntando a la IP del sistema Windows y el puerto ``2233``. Por ejemplo para conectarnos por SSH desde un terminal de Linux usamos:

.. code-block:: bash

    $ ssh usuario@192.168.1.8 -p 2233

    usuario@192.168.1.8 s password: 
    Microsoft Windows [Versión 10.0.18362.720]
    (c) 2019 Microsoft Corporation. Todos los derechos reservados.

    usuario@DESKTOP-PTFJ9SQ C:\Users\usuario>

Referencias
'''''''''''

- `Instalación y configuración de OpenSSH Server en Windows Server 2019`_
- `How To Install OpenSSH On Windows 10`_
- `OpenSSH windows 10 user s password not configured`_
- `PowerShell remoting over SSH`_
- `OpenSSH Key Management`_

.. _Instalación y configuración de OpenSSH Server en Windows Server 2019: https://www.youtube.com/watch?v=6FVKHv_0IPA
.. _How To Install OpenSSH On Windows 10: https://www.addictivetips.com/windows-tips/install-openssh-on-windows-10/
.. _OpenSSH windows 10 user s password not configured: https://security.stackexchange.com/questions/154478/openssh-windows-10-users-password-not-configured
.. _PowerShell remoting over SSH: https://docs.microsoft.com/en-us/powershell/scripting/learn/remoting/ssh-remoting-in-powershell-core?view=powershell-7
.. _OpenSSH Key Management: https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement
