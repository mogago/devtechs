Opciones de Kickstart - post-installation script
================================================

.. contents:: Table of Contents 

- Referencia 1: `Red Hat Docs - KICKSTART SYNTAX REFERENCE - Post-installation Script`_

.. _Red Hat Docs - KICKSTART SYNTAX REFERENCE - Post-installation Script: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/installation_guide/sect-kickstart-syntax#sect-kickstart-postinstall

Tenemos la posibilidad de añadir comandos para correr en el sistema una vez que la instalación se ha completado, pero antes que el sistema sea reiniciado por primera vez. Esta sección debe ser colocada al final del archivo kickstart, luego de los comandos de kickstart comunes; y debe comenzar con el comando ``%post`` y acabar con ``%end``. Si nuestro archivo kickstart incluye también una sección ``%pre``, el orden de las secciones ``%pre`` y ``%post`` no es relevante.

Esta sección es útil para funciones, como instalar software adicional o configurar un name server adicional. El post-install script corre en un **chroot environment**, por tanto, realizar tareas como copiar scripts o paquetes RPM del medio de instalación no funcionan por defecto. Podemos cambiar este comportamiento usando la opción ``--nochroot``. Además, en el entorno chroot, la mayoría de comandos ``systemctl`` se negarán a realizar cualquier acción.

.. Important::

    Si configuramos la red con información IP estática, incluyendo un name server, podemos acceder a la red y resolver direcciones IP en la sección ``%post``. Si hemos configurado la red para DHCP, el archivo ``/etc/resolv.conf`` no ha sido completado cuando la instalación ejecute la sección ``%post``. Podemos acceder la red, pero no podemos resolver direcciones IP. Por tanto, si estamos usando DHCP, debemos especificar direcciones IP en la sección ``%post``.

Las siguientes opciones pueden usarse para cambiar el comportamiento de post-installation scripts. Para usar una opción, adjuntarlo en la línea de ``%post`` al inicio del script. Por ejemplo:

.. code-block:: cfg

    %post --interpreter=/usr/bin/python
    --- Python script omitted --
    %end

- ``--interpreter=`` - Permite especificar un lenguaje de scripting distinto, como Python. Cualquier lenguaje de scripting disponible en el sistema puede ser usado; en la mayoría de los casos, estos son ``/usr/bin/sh``, ``/usr/bin/bash``, ``/usr/bin/python``.
-  ``--nochroot`` - Pemite especificar comandos que deseamos sen ejecutados fuera del entorno chroot.

Por ejemplo, para copiar el archivo ``/etc/resolv.conf`` al file system que acaba de ser instalado usamos:

.. code-block:: cfg

    %post --nochroot
    cp /etc/resolv.conf /mnt/sysimage/etc/resolv.conf
    %end

- ``erroronfail`` - Mostrar un error y detener la instalación si el script falla. El mensaje de error nos dirigirá a donde la causa del fallo se ha registrado.
- ``--log=`` - Guardar el output del script en el archivo de log especificado. Por ejemplo:

.. code-block:: cfg

    %post --log=/mnt/sysimage/root/ks-post.log

con ``--nochroot``:

.. code-block:: cfg

    %post --nochroot --log=/mnt/sysimage/root/ks-post.log

