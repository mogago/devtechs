Opciones de Kickstart - pre-installation script
===============================================

.. contents:: Table of Contents 

- Referencia 1: `Red Hat Docs - KICKSTART SYNTAX REFERENCE - Pre-installation Script`_
- Referencia 2: `CentOS 7 Docs - Kickstart Installations - Pre-installation Script`_
- Referencia 3: `Red Hat Docs - PRE-INSTALLATION SCRIPT`_
- Referencia 4: `What commands are available in the pre section of a Kickstart file on CentOS`_
- Referencia 5: `Pre-installation Script Example`_

.. _Red Hat Docs - KICKSTART SYNTAX REFERENCE - Pre-installation Script: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/installation_guide/sect-kickstart-syntax#sect-kickstart-preinstall
.. _CentOS 7 Docs - Kickstart Installations - Pre-installation Script: https://docs.centos.org/en-US/centos/install-guide/Kickstart2/#sect-kickstart-preinstall
.. _Red Hat Docs - PRE-INSTALLATION SCRIPT: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/installation_guide/s1-kickstart2-preinstallconfig
.. _What commands are available in the pre section of a Kickstart file on CentOS: https://unix.stackexchange.com/questions/131690/what-commands-are-available-in-the-pre-section-of-a-kickstart-file-on-centos
.. _Pre-installation Script Example: http://web.mit.edu/rhel-doc/4/RH-DOCS/rhel-sag-en-4/s1-kickstart2-preinstallconfig.html

El script ``%pre`` se corre en el sistema inmediatamente luego de que el archivo Kickstart haya analizado la sintáxis (parsed), pero antes que comience la instalación. Esta sección debe ser colocada al final del archivo kickstart, luego de los comandos de kickstart comunes; y debe comenzar con el comando ``%pre`` y acabar con ``%end``. Si nuestro archivo kickstart incluye también una sección ``%post``, el orden de las secciones ``%pre`` y ``%post`` no es relevante.

El script ``%pre`` puede usarse para la activación y configuración de dispositivos de networking y storage. También es posible correr scripts, usando intérpretes disponibles en el entorno de instalación. Añadir un script ``%pre`` puede ser útil si tenemos networking o almacenamiento que necesita una configuración especial previa a la instalación, o tener un script que, por ejemplo, configura parámetros de logging o variables de entorno adicionales.

Podemos acceder a parámetros de red en la sección ``%pre``; sin embargo, el *name service* no ha sido configurado hasta este punto. Por lo cual, solo funcionarán direcciones IP, no URLs.

.. Note::

    A diferencia del post-installation script, el pre-installation script no corre en el entorno ``chroot``.

Las siguientes opciones pueden usarse para cambiar el comportamiento de pre-installation scripts. Para usar una opción adjuntarlo en la línea de ``%pre`` al inicio del script. Por ejemplo:

.. code-block:: cfg

    %pre --interpreter=/usr/bin/python
    --- Python script omitted --
    %end

- ``--interpreter=`` - Permite especificar un lenguaje de scripting distinto, como Python. Cualquier lenguaje de scripting disponible en el sistema puede ser usado; en la mayoría de los casos, estos son ``/usr/bin/sh``, ``/usr/bin/bash``, ``/usr/bin/python``.
- ``erroronfail`` - Mostrar un error y detener la instalación si el script falla. El mensaje de error nos dirigirá a donde la causa del fallo se ha registrado.
- ``--log=`` - Guardar el output del script en el archivo de log especificado. Por ejemplo:

.. code-block:: cfg

    %pre --log=/mnt/sysimage/root/ks-pre.log

Comandos disponibles para ser usados en pre-installation script:

- Referencia 3: `Red Hat Docs - PRE-INSTALLATION SCRIPT`_
- Referencia 4: `What commands are available in the pre section of a Kickstart file on CentOS`_

