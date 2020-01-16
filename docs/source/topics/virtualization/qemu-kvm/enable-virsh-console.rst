Habilitando ``virsh console``
=============================

La funcionalidad ``virsh console`` permite conectarnos desde la consola del host a la consola de la VM guest.

Al principio, cuando intentemos conectarnos al terminal del guest no tendremos repuesta:

.. code-block:: bash

    $ virsh console ubuntu18
    Connected to domain ubuntu18Escape character is ^]
    ...

Para habilitar la consola del guest seguir los siguientes pasos:

1. Desde la VM guest ejecutar:

.. code-block:: bash

    sudo systemctl enable serial-getty@ttyS0.service
    
    sudo systemctl start serial-getty@ttyS0.service

.. Note::

    Hasta aquí podría bastar para acceder a la consola con ``virsh console``.

2. En la VM, reemplazar las siguientes línea del archivo ``/etc/default/grub``:

::

    GRUB_CMDLINE_LINUX_DEFAULT="quiet"
    #GRUB_TERMINAL=console

Por las siguientes líneas:

::

    GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0"
    GRUB_TERMINAL="serial console"
 
3. En la VM, actualizar el guest con:

.. code-block:: bash

    $ sudo update-grub
  
4. En el host, acceder a la consola de la VM con:

.. code-block:: bash

    $ virsh console ubuntu18

O iniciar la VM con la consola adjunta:

.. code-block:: bash

    $ virsh start ubuntu18 --console
 

Referencias:

- `Solución - virsh VM console does not show any output`_

.. _Solución - virsh VM console does not show any output: https://serverfault.com/questions/364895/virsh-vm-console-does-not-show-any-output/705062#705062