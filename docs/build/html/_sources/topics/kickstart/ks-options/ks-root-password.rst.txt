Opciones de Kickstart - contraseña root
=======================================

.. contents:: Table of Contents

- Referencia 1: `Red Hat Docs - KICKSTART SYNTAX REFERENCE`_
- Referencia 2: `Generate Password Hash in Linux`_

.. _`Red Hat Docs - KICKSTART SYNTAX REFERENCE`: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/installation_guide/sect-kickstart-syntax
.. _`Generate Password Hash in Linux`: https://www.shellhacks.com/linux-generate-password-hash/

Para establecer una contraseña encriptada para root usamos la siguiente línea en el archivo kickstart:

.. code-block:: cfg

    rootpw --iscrypted $1$WUDGBrnr$Bq8p.jk4ikcEr2JYJRMwE0

Crear una contraseña encriptada
-------------------------------

Podemos usar Python con el fin de generar una contraseña encriptada:

.. code-block:: bash

    $ python -c 'import crypt,getpass;pw=getpass.getpass();print(crypt.crypt(pw) if (pw==getpass.getpass("Confirm: ")) else exit())'

Este comando genera un hash SHA512 de nuestra contraseña usando un SALT aleatorio.

Si obtenemos algún error con el comando anterior tenemos otras opciones:

- Generar una contraseña hash MD5:

.. code-block:: bash

    $ python -c "import random,string,crypt; randomsalt = ''.join(random.sample(string.ascii_letters,8)); print crypt.crypt('MySecretPassword', '\$1\$%s\$' % randomsalt)"

- Generar una contraseña hash SHA-256:

.. code-block:: bash

    $ python -c "import random,string,crypt; randomsalt = ''.join(random.sample(string.ascii_letters,8)); print crypt.crypt('MySecretPassword', '\$5\$%s\$' % randomsalt)"

- Generar una contraseña hash SHA-512:

.. code-block:: bash

    $ python -c "import random,string,crypt; randomsalt = ''.join(random.sample(string.ascii_letters,8)); print crypt.crypt('MySecretPassword', '\$6\$%s\$' % randomsalt)"

.. Note::

    Cambiar ``MySecretPassword`` por nuestra contraseña que deseamos establecer.

