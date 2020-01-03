Configuración de passwordless SSH login
=======================================

Basado en: `How to Setup Passwordless SSH Login`_

.. _How to Setup Passwordless SSH Login: https://linuxize.com/post/how-to-setup-passwordless-ssh-login/

.. Note::

    - [PC1] : SSH client
    - [PC2] : SSH server

1. [PC1] Verificar si hay pares de llaves SSH existentes en el cliente:

.. code-block:: bash

    $ ls -al ~/.ssh/id_*.pub

Si existe un par de llaves podemos saltarnos el siguiente paso o generar un nuevo par de llaves.

Si el comando no devuelve ningún resultado, significa que no existen llaves SSH en el cliente y podemos seguir con el siguiente paso para la generación del par de llaves.

2. [PC1] Generar un nuevo par de llaves SSH:

El siguiente comando generará un nuevo par de llaves SSH de 4096 bits para el usuario ``user`` del dominio ``domain``:
   
.. code-block:: bash

    $ ssh-keygen -t rsa -b 4096 -C "user@domain"

Por ejemplo:

.. code-block:: bash

    $ ssh-keygen -t rsa -b 4096 -C "user1@localhost.localdomain"

    Generating public/private rsa key pair.
    Enter file in which to save the key (/home/user1/.ssh/id_rsa): 
    Created directory '/home/user1/.ssh'.
    Enter passphrase (empty for no passphrase): 
    Enter same passphrase again: 
    Your identification has been saved in /home/user1/.ssh/id_rsa.
    Your public key has been saved in /home/user1/.ssh/id_rsa.pub.
    The key fingerprint is:
    SHA256:4v7tURAq6CMnhX3YI2yVLlensvMGMjFANEop5LVThAo user1@localhost.localdomain
    The key s randomart image is:
    +---[RSA 4096]----+
    |.==.oo..  .      |
    |Eoo*o=. ....     |
    |+.o+O.=..o.      |
    | . +=o+o.  .     |
    |  o +=.oS   .    |
    |   +oo+.   .     |
    |     o.+  .      |
    |     .  o. .     |
    |      .o..o      |
    +----[SHA256]-----+

Se eligió el nombre y ubicación por defecto.  
Se ha usado SSH sin ningún passphrase, ya que, a pesar de que da una capa extra de seguridad no permite hacer procesos automatizados.

Para asegurarnos que las llaves SSH se han generado podemos listar las llaves pública y privada con:

.. code-block:: bash

    $ ls ~/.ssh/id_*
    /home/user1/.ssh/id_rsa  /home/user1/.ssh/id_rsa.pub

3. [PC1] Copiar la llave pública al servidor PC2.

Una vez que hemos generado el par de llaves SSH, para iniciar sesión en el servidor sin ninguna contraseña debemos copiar la llave pública al servidor que queremos manejar.

La forma más sencilla de copiar la llave pública al servidor es usando el comando ``ssh-copy-id``.

.. code-block:: bash

    $ ssh-copy-id remote_username@server_ip_address

Por ejemplo:

.. code-block:: bash

    $ ssh-copy-id user1@192.168.122.158

    /bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/user1/.ssh/id_rsa.pub"
    The authenticity of host '192.168.122.158 (192.168.122.158)' can t be established.
    ECDSA key fingerprint is SHA256:OxiFa4EyYuNC6L0+vnMVZ59XYLKek7bAg91jhrbHVoc.
    ECDSA key fingerprint is MD5:2d:48:e3:03:18:49:0c:fd:3a:7b:ca:6b:65:b8:66:4e.
    Are you sure you want to continue connecting (yes/no)? yes
    /bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
    /bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
    user1@192.168.122.158 s password:

    Number of key(s) added: 1

    Now try logging into the machine, with:   "ssh 'user1@192.168.122.158'"
    and check to make sure that only the key(s) you wanted were added.

Se pidió ingresar la contraseña del usuario remoto al que nos intentamos conectar.

Una vez que el usuario se haya autenticado, la llave pública será añadida al archivo del usuario remoto ``authorized_keys`` y la conexión se cerrará.

Si por algún motivo la utilidad ``ssh-copy-id`` no está disponible en nuestra máquina local podemos copiar manualmente la llave pública con:

.. code-block:: bash

    $ cat ~/.ssh/id_rsa.pub | ssh remote_username@server_ip_address "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

4. [PC1] Conectarnos a nuestro servidor usando las llaves SSH.

La conexión SSH debería dejarnos conectar al servidor remoto sin pedirnos ninguna contraseña.

.. code-block:: bash

    $ ssh remote_username@server_ip_address

Por ejemplo:

.. code-block:: bash

    $ ssh user1@192.168.122.158
