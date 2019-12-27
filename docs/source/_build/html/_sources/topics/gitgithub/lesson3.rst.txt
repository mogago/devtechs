Lesson 3
========

*Lesson 3: Getting Started with GitHub*

.. contents:: Table of Contents 


Creating a repository on GitHub
-------------------------------

Luego de haber hecho nuestros ``commits`` localmente necesitaremos tener un backup de nuestros archivos.

Entrar a nuestra cuenta de `GitHub`_:

.. _GitHub: https://github.com/

En la esquina superior derecha, clic en el ícono :guilabel:`+`. Elegir la opción :guilabel:`New repository`:

.. figure:: images/lesson3/GitHub_create-new-repository1.png
    :align: center

    GitHub - create new repository - Paso 1

Normalmente pondremos el nombre al repositorio igual al que hemos estado trabajando localmente:

.. figure:: images/lesson3/GitHub_create-new-repository2.png
    :align: center

    GitHub - create new repository - Paso 2

Mantendremos este repositorio de forma pública, permitiendo que todos puedan acceder al repositorio.

Si fuéramos administradores no-técnicos y solo quisieramos crear un repositorio en GitHub que los desarrolladores puedan usar, podemos inicializar el repositorio con archivo ``README``, de forma que no hagamos ninguna tarea en la línea de comandos. Este no es el caso.

Finalmente, clic en el botón :guilabel:`Create Repository`:

.. figure:: images/lesson3/GitHub_create-new-repository3.png
    :align: center

    GitHub - create new repository - Paso 3

Uploading your repo to Github
-------------------------------

Ocasionalmente tendremos que usar SSH. Primero deberemos crear llaves SSH.

.. figure:: images/lesson3/Github_mode-SSH.png
    :align: center

    GitHub - mode SSH

En esta guía usaremos HTTPS. Seleccionar este botón:

.. figure:: images/lesson3/Github_mode-HTTPS.png
    :align: center

    GitHub - mode HTTPS

En la parte inferior nos muestran comandos para subir (``push``) un repositorio existente a GitHub. Copiar y pegar ambas líneas en el terminal:

.. code-block:: bash

    $ git remote add origin https://github.com/mogago/app1.git
    
    $ git push -u origin master

    Username for 'https://github.com': mogago
    Password for 'https://mogago@github.com': 
    Counting objects: 7, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (6/6), done.
    Writing objects: 100% (7/7), 651 bytes | 651.00 KiB/s, done.
    Total 7 (delta 1), reused 0 (delta 0)
    remote: Resolving deltas: 100% (1/1), done.
    To https://github.com/mogago/app1.git
    * [new branch]      master -> master
    Branch 'master' set up to track remote branch 'master' from 'origin'.

Si actualizamos nuestra página en GitHub veremos que los archivos se de nuestro repositorio local han sido subidos:

.. figure:: images/lesson3/Github_repo_pushed.png
    :align: center

    GitHub - repo pushed

Creating a repository after starting to code
--------------------------------------------

Creemos un nuevo repositorio. Primero iremos un directorio hacia arriba, comprobar que no estamos en un repositorio de Git y crear un directorio:

.. code-block:: bash

    $ cd ..

    $ git status
    fatal: not a git repository (or any of the parent directories): .git

    $ mkdir web2

Esta vez haremos algo diferente. Idealmente haríamos ``git init web2`` y estaría listo. Pero generalmente la persona comenzaría a crear código:

.. code-block:: bash

    $ cd web2/
    $ touch index.html index.css

En este punto intentaríamos agregar los archivos a Git. Pero no funcionará porque no hemos creado un repositorio:

.. code-block:: bash

    $ git add .
    fatal: not a git repository (or any of the parent directories): .git

Lo que podemos hacer es ir al directorio que queremos inicializar y usar el comando `git init`:

.. code-block:: bash

    $ git init
    Initialized empty Git repository in /home/user/Documents/web2/.git/

    $ git status
    On branch master

    No commits yet

    Untracked files:
    (use "git add <file>..." to include in what will be committed)

            index.css
            index.html

    nothing added to commit but untracked files present (use "git add" to track)

Luego podremos agregar los archivos y hacer un ``commit``. Por el momento los eliminaremos para tener un repositorio de Git sin archivos:

.. code-block:: bash

    $ rm index.*
    $ git s
