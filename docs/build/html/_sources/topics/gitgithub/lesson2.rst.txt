Lesson 2
========

*Lesson 2: Getting Started with Git*

.. contents:: Table of Contents 

Lesson 2: Getting Started with Git

Creating your first Git repository
----------------------------------

Inicialmente al tipear el comando ``git status`` un error nos indica que no estamos en un repositorio:

.. code-block:: bash

    $ git status
    fatal: not a git repository (or any of the parent directories): .git

Para crear un nuevo repositorio en Git llamado ``app1`` usamos:

.. code-block:: bash

    $ git init app1
    Initialized empty Git repository in /home/user/app1/.git/

No hemos necesitado conexión a Internet para que este comando funcione. Hemos creado una **copia local** de un repositorio. Podemos usar branches, tags, ver el historial con esta copia de Git. Luego podemos decidir compartirlo con un grupo, y es ahí donde necesitamos conectarnos a un servidor remoto como **Github**.

Podemos cambiar el directorio a nuestro repositorio creado y ver su estado:

.. code-block:: bash

    $ cd app1/

    $ git status
    On branch master

    No commits yet

    nothing to commit (create/copy files and use "git add" to track)

- ``On branch master`` - nos dice que estamos en el branch master (branch por defecto).
- ``No commits yet`` - nos dice que hemos creado un repositorio pero no hemos guardado, todavía no hemos hecho nuestro "Initial commit".
- ``nothing to commit`` - nos dice que no hay nada para hacerle commit. No hay archivos que podamos añadir al historial.

Committing in Git
-----------------

En Git se tiene la idea de pensamiento en 3 etapas (3 stage thinking):

.. figure:: images/lesson2/git-stages.png
    :align: center

    3 stage thinking de Git

----

.. figure:: images/lesson2/git-staging-diagram.png
    :align: center

    3 stage thinking de Git diagram

Crear un archivo de prueba sin contenido:

.. code-block:: bash

    $ touch index.html

Veamos el estado del repositorio:

.. code-block:: bash

    $ git status
    On branch master

    No commits yet

    Untracked files:
    (use "git add <file>..." to include in what will be committed)

            index.html

    nothing added to commit but untracked files present (use "git add" to track)

Todavía no hemos hecho un ``commit``, es decir, no hemos guardado nada en el historial.

Nos ha salido un mensaje de ``Untracked files``. Es decir, existen archivos que no hemos notificado a Git dentro del repo. Hay 2 cosas que le diremos que haga:

1. Le diremos que agregue el archivo a "**staging area**". Y usamos el comando ``git add``:

- Una opción es añadir solamente el archivo ``index.html``:

.. code-block:: bash

    $ git add index.html

- Otra opción es agregar todos los archivos al repositorio usando un punto (``.``):

.. code-block:: bash

    $ git add .

Una vez que hayamos puesto cualquiera de los dos comandos anteriores, veremos que Git nos dice que está listo para guardar el archivo en historial:

.. code-block:: bash

    $ git status
    On branch master

    No commits yet

    Changes to be committed:
    (use "git rm --cached <file>..." to unstage)

            new file:   index.html

Esta sección de "staging area" es como una página web de compras, donde ponemos objetos en el carrito de compras, pero esto no quiere decir que nos lo vayan a enviar. La página esperará hasta que hagamos clic en el botón de comprar. Podemos agregar o quitar productos, esto nos permite hacer cambios antes de la compra. Para el "staging area" en Git es similar.

Creemos otro archivo de prueba:

.. code-block:: bash

    $ touch index.css

Veamos el estado del repositorio:

.. code-block:: bash

    $ git status
    On branch master

    No commits yet

    Changes to be committed:
    (use "git rm --cached <file>..." to unstage)

            new file:   index.html

    Untracked files:
    (use "git add <file>..." to include in what will be committed)

            index.css

Agreguemos el nuevo archivo que está "Untracked":

.. code-block:: bash

    $ git add .

Y vemos que tenemos los dos archivos agregados al repositorio:

.. code-block:: bash

    $ git status
    On branch master

    No commits yet

    Changes to be committed:
    (use "git rm --cached <file>..." to unstage)

            new file:   index.css
            new file:   index.html

2. El siguiente paso es hacer el ``commit``:

Cuando hagamos un ``commit`` se hará un ``commit`` de ambos archivos juntos:

.. code-block:: bash

    $ git commit -m "Added home page"

    [master (root-commit) 49ab535] Added home page
    2 files changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 index.css
    create mode 100644 index.html

Con el parámetro ``-m`` se agrega un mensaje al ``commit``.

.. code-block:: bash

    $ git status
    On branch master
    nothing to commit, working tree clean

El mensaje nos dice que cualquier trabajo que hemos hecho se ha guardado satisfactoriamente en Git, o en el historial. Podremos volver a este punto en el tiempo.

Generalmente este mensaje es lo que queremos ver al correr ``git status``, sin importar el branch donde estemos trabajando.

Understanding Git Commit
------------------------

Al hacer nuestro primer ``commit`` obtuvimos el siguiente mensaje:

.. code-block:: bash

    $ git commit -m "Added home page"

    [master (root-commit) 49ab535] Added home page
    2 files changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 index.css
    create mode 100644 index.html

- ``master`` - nos dice que estamos en el branch ``master``.
- ``root-commit`` - es el primer ``commit``. Solo lo veremos una vez por proyecto.
- ``49ab535`` - son los primeros dígitos del "**commit HASH**", es decir, el identificador único del ``commit``.

.. Note::

    ¿Por qué no se usan números incrementales para los "commits": ``commit-1``, ``commit-2``, ``commit-3``, ... ?:

    La razón es que cuando trabajamos con Git estamos trabajando con un sistema de control distribuido. Si un repositorio estuviese colgado en Github y alguien descargara una copia, ambos estaríamos haciendo ``commits`` de nuestras propias copias del repositorio sin conectarnos a Internet. Git no tiene idea de quién hizo ``commit-3`` o ``commit-4`` porque varios tienen sus copias y hacen ``commit`` localmente. Por eso se usan **identificadores globales únicos**, un **HASH SHA-1** que identifican singularmente un ``commit``.

- ``2 files changed`` - pues hemos hecho ``commit`` a 2 archivos.
- ``0 insertions(+), 0 deletions(-)`` - esto es inusual, pero se debe a que los archivos están en blanco. Si hubiese 3 líneas de texto en un archivo y 2 en el otro archivo, tendríamos ``5 insertions`` y ``0 deletions``.
- ``create mode 100644`` - Solo podremos ver 3 números como este: 1 para links simbólicos, 1 para ejecutables y 1 para todo lo demás.
- ``create mode 100644 index.css`` - archivo agregado a historial.

The benefits of the staging area
--------------------------------

**¿Por qué tenemos que añadir archivos a "staging area" y luego hacer commit?**:

Porque Git está diseñado para ayudarnos a hacer un correcto control de versiones. Y una parte de hacer un buen control de versiones es hacer ``commits`` atómicos con sentido.

.. Tip:: Una de las mejores prácticas en Git y Github es escribir mejores mensajes de ``commit`` y ver qué archivos poner juntos. Los ``commits`` nos deben decir la historia del trabajo que hemos realizado.

Hagamos un ejemplo de cómo nos complicaría no tener una ``staging area``.

- Creemos varios archivos de prueba:

.. code-block:: bash

    $ touch about.html about.css contact.html contact.css

- Listar el contenido del directorio:

.. code-block:: bash

    $ ls
    about.css  about.html  contact.css  contact.html  index.css  index.html

- Ver el estado del repositorio:

.. code-block:: bash

    $ git status

    On branch master
    Untracked files:
    (use "git add <file>..." to include in what will be committed)

            about.css
            about.html
            contact.css
            contact.html

    nothing added to commit but untracked files present (use "git add" to track)

Vemos que tenemos a los 4 archivos agregados sin trackear.

- Usar el alias creado en la sección :ref:`aliases` de :ref:`leccion-1` para ver el estado del repositorio en modo silencioso (``git config --global alias.s "status -s"``):

.. code-block:: bash

    $ git s

    ?? about.css
    ?? about.html
    ?? contact.css
    ?? contact.html

``git status`` toma mucho espacio, es útil pero la mayoría de las veces sabemos el estado de los archivos. Así que podemos saber el estado de forma resumida con el modo silencioso.

Un color rojo de los signos de interrogación nos indica que los archivos no han sido agregados al ``staging area``. Doble signo de interrogación ``??`` nos indica que son archivos nuevos sin trackear.

- Podemos añadir al repositorio los 4 archivos en dos partes para mantener el orden (las páginas de ``about`` y ``contact``). Primero para la página ``about`` usamos:

.. code-block:: bash

    $ git add ab*

    $ git s
    A  about.css
    A  about.html
    ?? contact.css
    ?? contact.html

Habremos agregado 2 nuevo archivos (``about.css``, ``about.html``) al repositorio. Al ejecutar ``git s``, un color verde en las letras ``A`` nos indica que han sido ``staged``, es decir, agregados al repositorio.

- Luego hacemos un ``commit`` con un mensaje descriptivo:

.. code-block:: bash

    $ git commit -m "Added about us page"

    [master aa2d60c] Added about us page
    2 files changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 about.css
    create mode 100644 about.html

- Podemos hacer el mismo procedimiento para la página ``contact``:

.. code-block:: bash

    $  git s

    ?? contact.css
    ?? contact.html
    ```

.. code-block:: bash

    $ git add .

    $ git s
    A  contact.css
    A  contact.html

.. code-block:: bash

    $ git commit -m "Added contact us page"
    
    [master 4388cdf] Added contact us page
    2 files changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 contact.css
    create mode 100644 contact.html

Git log for viewing history
---------------------------

Podemos ver el historial usando el alias creado en la sección :ref:`aliases` de :ref:`leccion-1` (``git config --global alias.lg "log --oneline --all --graph --decorate"``)

- ``--oneline`` - imprime cada ``commit`` en una sola línea
- ``--decorate`` - nos da información de los HEAD de los branches.
- ``--graph`` - imprime estrellas al lado del identificador del `commit` que ayudan en el trabajo con branches.

Primero veamos el log con el comando por defecto:

.. code-block:: bash

    $ git log
    commit 4388cdfb26762db96df7fe845d09f6dbca7c5257 (HEAD -> master)
    Author: Nombre Apellido <newuser1@mail.com>
    Date:   Thu Sep 26 23:40:51 2019 -0500

        Added contact us page

    commit aa2d60c167b1d066771d871e14616f1ff89fcaef
    Author: Nombre Apellido <newuser1@mail.com>
    Date:   Thu Sep 26 23:38:36 2019 -0500

        Added about us page

    commit 49ab5355d7bc3e8ffed85cd6f9c7b491007ecfaa
    Author: Nombre Apellido <newuser1@mail.com>
    Date:   Wed Sep 25 23:23:45 2019 -0500

        Added home page

Si tuviesemos muchos más ``commits`` nos tomaría mucho tiempo leer todo. Así que podemos usar el alias:

.. code-block:: bash

    $ git lg

    * 4388cdf (HEAD -> master) Added contact us page
    * aa2d60c Added about us page
    * 49ab535 Added home page