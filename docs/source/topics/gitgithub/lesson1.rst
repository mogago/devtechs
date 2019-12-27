.. _leccion-1:

Lesson 1
========

*Lesson 1: Configuring Git, Three Stage thinking*

.. contents:: Table of Contents

Three levels of configuration
-----------------------------

Hay 3 niveles de configuración en Git: Local, Global y System:

- La mayoría de las veces solo usaremos configuraciones a nivel global. **Global** configura cosas de todos los repositorios que usamos, logueados con nuestro usuario en nuestra PC.

- **Local** solo funciona específicamente en un solo repo. Es para hacer configuraciones específicas de solo ese repositorio en el que estamos trabajando (``--local``).

- El tercer nivel de configuración menos usado es la opción de configuración ``--system``. Es para cualquier otra persona que se loguee en nuestra computadora. Si tenemos múltiples personas logueandose en una misma computadora usando distintas cuentas de usuario, es ahí donde usaríamos una opción de configuración de nivel **System**.

Basic Configuration settings
----------------------------

El comando principal de configuración en Git es ``git config``.

Para realizar una configuración a nivel Global usamos: ``git config --global``. Por ejemplo:

.. code-block:: bash

    $ git config --global user.name

Este comando nos retorna el username si es que tenemos configurado alguno. Si no hay ningún username configurado no retornará nada.

Con el mismo comando podemos ingresar el nombre por el cual queremos ser conocidos:

.. code-block:: bash

    $ git config --global user.name "Nombre Apellido"

    $ git config --global user.name
    Nombre Apellido

Podemos usar el comando ``git config`` como *getter* para obtener información o como *setter* para configurar.

Podemos hacer lo mismo para el correo del usuario:

.. code-block:: bash

    $ git config --global user.email username@example.com

    $ git config --global user.email
    username@example.com

Podemos usar el comando ``git config`` para listar las configuraciones globales:

.. code-block:: bash

    $ git config --global --list
    user.name=Nombre Apellido
    user.email=username@example.com

Las configuraciones globales se guardan en un archivo `~/.gitconfig`:

.. code-block:: bash

    $ cat ~/.gitconfig
    [user]
            name = Nombre Apellido
            email = username@example.com

Podemos editar el archivo:

.. code-block:: bash

    $ vi ~/.gitconfig

Podemos listar toda la configuración global:

.. code-block:: bash

    $ git config --global --list
    user.name=Nombre Apellido
    user.email=newuser1@mail.com

La siguiente configuración sirve para colorear el output de ciertos comandos:

.. code-block:: bash
    
    $ git config --global color.ui true

.. Note::

    Si estamos usando una versión de Git 1.8.4 o más nueva esta opción estará por defecto.

Configuring line endings
------------------------

Una de las configuraciones más importantes es 'auto carriage return line feed'.

`STACKOVERFLOW - Carriage Return _ Linefeeds _ Form Feeds`_

.. _STACKOVERFLOW - Carriage Return _ Linefeeds _ Form Feeds: https://stackoverflow.com/questions/3091524/what-are-carriage-return-linefeed-and-form-feed

``autocrlf`` - Auto Carriage Return Line Feed

.. code-block:: bash

    # Linux/MAC
    $ git config --global core.autocrlf input

    # Windows
    $ git config --global core.autocrlf true

Cuando alguien está haciendo ``commit`` a un proyecto, y se ve como si hubiese cambiado todas las líneas en 2 archivos diferentes. Pero cuando vemos los archivos, el contenido parece el mismo. Lo que pudo haber pasado es que estaba usando un editor particular de Windows que agregaba caracteres escondidos: **Carriage Returns** y **Line Feeds**.

Esto es negativo porque se pensará que se han cambiado líneas en las que en realidad el editor no ha cambiado el código. Y tampoco sabremos los cambios que se han hecho realmente.

Por eso, es importante configurar el manejo de Auto Carriage Return Line Feed. La forma en que trabaja es que en la mayoría de sistemas **Linux/MAC** se tiene un Line Feed al final de cada línea y en **Windows** tenemos 2 caracteres escondidos: Line Feed y Carriage Return.

**En Linux:**

.. code-block:: bash

    # Linux/MAC
    $ git config --global core.autocrlf input

Cuando guardemos un archivo en git o en el repositorio, se eliminará todos los Carriage Returns y solo dejará Line Feeds. Esto es porque podemos haber descargado un archivo que proviene de Windows con caracteres Carriage Returns escondidos.

**En Windows:**

.. code-block:: bash

    # Windows
    $ git config --global core.autocrlf true

Para cualquier archivo que pongamos en un repositorio, se extraerán los Carriage Returns. Pero cuando extraigamos archivos del repo, pondrá los Carriage Return de vuelta, para poderlos editar en editores como Notepad.

.. _aliases:

Configuring aliases
-------------------

Los alias en Git permiten crear nuestros propios comandos, especificando varias opciones, de forma que facilite y agilice el trabajo.

- Creemos nuestro primer alias:

.. code-block:: bash

    $ git config --global alias.s "status -s"

El nombre del alias es ``s``. De forma que en el futuro cuando escribamos ``git s``, correrá el comando que está dentro de las comillas ``"status -s"``.  
Con el parámetro ``-s``, ``git status`` correrá en modo silencioso.

- Creemos otro alias:

.. code-block:: bash

    $ git config --global alias.lg "log --oneline --all --graph --decorate"

El alias llamdo ``lg`` correrá el comando ``git log`` con estas opciones:

- ``oneline`` - poner el output del historial o el log en una sola línea.
- ``--all`` - mostrar todos los branches. No solo el historial del branch donde estamos actualmente.
- ``--graph`` - queremos que se muestra en forma gráfica
- ``--decorate`` - mostrar información adicional.

---
