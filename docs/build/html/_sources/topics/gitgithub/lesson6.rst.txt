Lesson 6
========

*Lesson 6: Git Internals*

.. contents:: Table of Contents 

Introducing Git under the hood
------------------------------

En esta sección veremos Git y GitHub a bajo nivel (under the hood). Nos servirá para entender varias cosas que hacemos con Git y por qué trabajan de la forma en que lo hacen.

Creating the first commit
-------------------------

Crear el siguiente archivo en un nuevo repositorio:

.. code-block:: bash

    $ git init app2
    Initialized empty Git repository in /home/user/Documents/gittests/app2/.git/

    $ cd app2
    $ vi index.html

        hello world
    
    $ git s
    ?? index.html

según el estado tenemos un archivo sin trackear. Hagamos un ``commit`` de ese archivo:

.. code-block:: bash

    $ git add .
    $ git commit -m "Added home page"
    [master (root-commit) 6c4de50] Added home page
     1 file changed, 1 insertion(+)
     create mode 100644 index.html
    
Exploring the object store
--------------------------

En el directorio de trabajo actual abramos el directorio oculto ``.git``:

.. code-block:: bash

    $ ls -a
    .  ..  .git  index.html

    $ ls -a .git/
    .   branches        config       HEAD   index  logs     refs
    ..  COMMIT_EDITMSG  description  hooks  info   objects

Veamos los elementos dentro del subdirectorio ``.git/objects``

.. code-block:: bash

    $ ls .git/objects/
    3b  6c  ff  info  pack

    $ tree .git/objects/
    .git/objects/
    ├── 3b
    │   └── 18e512dba79e4c8300dd08aeb37f8e728b8dad
    ├── 6c
    │   └── 4de5016bf89390a661676c855d82005b88c448
    ├── ff
    │   └── 46f55ec679bb30e1b2291bf56558ec435b1df3
    ├── info
    └── pack

    5 directories, 3 files

Se han creado 3 nuevos directorios en en este subdirectorio: ``3b``, ``6c``, ``ff``. Aquí es donde Git guarda todos sus objetos. Si ponemos un archivo en control de versiones con Git estará en este directorio, si tenemos un filename en el directorio estará aquí, si creamos un ``commit`` será puesto también en el directorio de objetos.

Tenemos 3 archivos, pudiendo concatenar los nombres del directorio y el nombre del archivo para obtener el hash SHA-1. Por ejemplo, en este caso los 3 objetos serían:

- ``3b 18e512dba79e4c8300dd08aeb37f8e728b8dad``
- ``6c 4de5016bf89390a661676c855d82005b88c448``
- ``ff 46f55ec679bb30e1b2291bf56558ec435b1df3``

cat-file to explore object contents
-----------------------------------

Veamos qué son estos 3 objetos. Usaremos un comando a bajo nivel ``git cat-file -p`` para ver qué contiene dentro un objeto en el git object store. Es suficiente dar 4 caracteres del objeto para obtener la información:

.. code-block:: bash

    $ git cat-file -p 3b18
    hello world

    $ git cat-file -p 3b18e512dba79e4c8300dd08aeb37f8e728b8dad
    hello world

Esto quiere decir que si en otra PC escribiéramos en el archivo ``index.html`` los caracteres ``hello world`` también tendríamos un objeto con el mismo identificador ``3b18...``. La razón de esto es porque Git usa un algoritmo hash SHA-1.

Probemos con el ultimo directorio:

.. code-block:: bash

    $ git cat-file -p ff46
    100644 blob 3b18e512dba79e4c8300dd08aeb37f8e728b8dad    index.html

Los contenidos del primer respositorio eran sobre el contenido del archivo ``index.html`` (content store) pero no decían nada sobre el nombre del archivo. Esto es útil porque si tuviese otro archivo con exactamente el mismo contenido pero con otro nombre y otro directorio no tendría que tenerlo duplicado.

En este último directorio obtenemos el nombre del archivo con detalles extra: 

- ``100644``: no es un archivo ejecutable
- ``blob``: binary large object
- ``3b18e512dba79e4c8300dd08aeb37f8e728b8dad``: contenidos del archivo descritos por este identificador
- ``index.html``: nombre del archivo

Este objeto es llamado **tree object**, que guarda el directorio con toda la información del nombre del archivo y qué objetos guarda el contenido de esos archivos en el directorio.

El otro objeto que tenemos y varía de PC en PC sin importar que sigamos los mismos pasos es el siguiente:

.. code-block:: bash

    $ git cat-file -p 6c4d
    tree ff46f55ec679bb30e1b2291bf56558ec435b1df3
    author Nombre Apellido <newuser1@mail.com> 1577681651 -0500
    committer Nombre Apellido <newuser1@mail.com> 1577681651 -0500

    Added home page

Este es el mensaje de ``commit`` que también vemos al momento de crear el ``commit`` o listar el log:

.. code-block:: bash

    $ git lg
    * 6c4de50 (HEAD -> master) Added home page

La razón de que sea diferente para cualquier PC es que tiene autores, correo, día, hora y mensaje del ``commit``.

The benefits of Git's use of SHA1 hashes
----------------------------------------

La ventaja de usar SHA1 nos da un nivel de seguridad. Si el hash SHA1 es el mismo todo será lo mismo para el caso del tree hash y el hash de los contenidos del archivo. Es decir, tenemos una consistencia garantizada en términos de qué contenidos es guardada dentro de los repositorios.

Git as a content store (how many new hashes)
--------------------------------------------

Agreguemos otro archivo:

.. code-block:: bash

    $ vi about.html
    hello world

    $ git add .
    $ git commit -m "Added about us page"
    [master 7c71072] Added about us page
     1 file changed, 1 insertion(+)
     create mode 100644 about.html

¿Cuántos nuevos objetos deberá haber?: podríamos suponer que 3 (contenidos del nuevo archivo, nuevo tree del directorio con 2 archivos en él y el nuevo commit).

Si listamos el directorio veremos que solo hay 2 nuevos:

.. code-block:: bash
    :emphasize-lines: 5,6,9,10

    $ tree .git/objects/
    .git/objects/
    ├── 3b
    │   └── 18e512dba79e4c8300dd08aeb37f8e728b8dad
    ├── 40
    │   └── 83ab857b34cf3ee53639f6ee188fa36e751c11
    ├── 6c
    │   └── 4de5016bf89390a661676c855d82005b88c448
    ├── 7c
    │   └── 71072f9f35c27abf0a39ba71414ca4e64540f6
    ├── ff
    │   └── 46f55ec679bb30e1b2291bf56558ec435b1df3
    ├── info
    └── pack

Veamos que hay en ellos:

.. code-block:: bash

    $ git cat-file -p 4083
    100644 blob 3b18e512dba79e4c8300dd08aeb37f8e728b8dad    about.html
    100644 blob 3b18e512dba79e4c8300dd08aeb37f8e728b8dad    index.html

Este es el nuevo tree que debería tener el mismo identificador en cualquier PC que haya creado los mismo archivos.

.. code-block:: bash

    $ git cat-file -p 7c71tree 4083ab857b34cf3ee53639f6ee188fa36e751c11
    parent 6c4de5016bf89390a661676c855d82005b88c448
    author Nombre Apellido <newuser1@mail.com> 1577716707 -0500
    committer Nombre Apellido <newuser1@mail.com> 1577716707 -0500

    Added about us page

Este objeto hace referencia al último ``commit``. No existe un sexto objeto porque nosotros sabemos qué pasa cuando le hacemos un hash SHA1 al string ``hello world``. Git ya calculó el hash SHA1 de ese texto anteriormente y al crear un nuevo archivo con exactamente el mismo contenido apuntará al mismo objeto. Git no necesita duplicar objetos en el **content store**.

Hay algunas implicancias para esto: es eficiente tener el mismo contenido del archivo a través del tiempo, en diferentes directorios o diferentes branches. Serán guardados como una sola referencia, y será eficiente en términos de espacio. Sin embargo, hay una desventaja, ¿qué pasa si cambio un caracter en el contenido del archivo?: cambia el hash SHA1 sin importar qué tan grande o pequeño es el cambio. Git irá creando copias y más copias de esos archivos con pequeñas diferencias. ¿Por qué no seguir el procedimiento de Subversion donde solo se almacenan los deltas?. Resulta que esta decisión de Git sí es inteligente.

La clave de que funcione este modo de trabajo en Git es por los **pack files**. Pensemos en los archivos zip; si tenemos 100 archivos que son similares y son todos archivos de texto los zipeamos antes de enviarlo a alguna persona, donde el trabajo de compresión puede realizar un buen trabajo tomando archivos similares y generando una archivo más pequeño. Esto es lo que hace Git a bajo nivel, hace una copia entera de cada modificación de un archivo y no representará un problema porque creará un paquete de ellos y los guardará oficialmente en disco.

.. Note::

    Una regla que debemos seguir es no guardar archivos binarios grandes en Git que frecuentemente estén cambiando. Desafortunadamente los programas de compresión no harán un buen trabajo comprimiendo archivos binarios con pequeñas modificaciones.

Understanding remotes and their configuration
---------------------------------------------

Hagamos una conexión a un servidor remoto. Tomemos estos archivos y hagámosle push a GitHub:

.. figure:: images/lesson3/GitHub_create-new-repository1.png
    :align: center

    GitHub - create new repository - Paso 1

.. figure:: images/lesson6/github-new-repo1.png
    :align: center

    GitHub - create new repository - Paso 2

.. figure:: images/lesson6/github-new-repo2.png
    :align: center

    GitHub - create new repository - Paso 3

Ya hemos creado nuestro repositorio. La última vez copiamos y pegamos los siguientes comandos sin pensar qué hacían, ahora veamos qué está ocurriendo:

.. figure:: images/lesson6/github-new-repo3.png
    :align: center

    GitHub - create new repository - Paso 4

En un terminal catalogar los contenidos del archivo ``config`` del directorio ``.git``, **este directorio es nuestro repositorio**. Si eliminamos este directorio, nuestro historial, branches, tags y más se irá con él incluyendo nuestro archivo de configuración local ``.git/confi``:

.. code-block:: bash

    $ cat .git/config
    [core]
            repositoryformatversion = 0
            filemode = true
            bare = false
            logallrefupdates = true

Así como vimos el archivo de configuración global de Git ``~/.gitconfig``, tenemos el archivo de configuración local de Git ``.git/config``.

Veamos que ocurre cuando agregamos un remote. Copiemos el archivo de GitHub a nuestro terminal:

.. code-block:: bash

    $ git remote add origin https://github.com/mogago/app2.git

Este comando indica que queremos agregar un lugar remoto donde podamos interactuar con nuestro repositorio de Git. Los remotes pueden ser engañosos porque se pueden configurar en otro directorio de nuestro disco duro, es decir, o debe ser realmente remoto a través de Internet, pero lo será la mayoría de las veces.

Llamamos a nuestro remote ``origin`` como alias que apunta a la dirección ``https://github.com/mogago/app2.git``. Veremos que nuestro configuración local tiene algo extra:

.. code-block:: bash
    :emphasize-lines: 7-9

    $ cat .git/config
    [core]
            repositoryformatversion = 0
            filemode = true
            bare = false
            logallrefupdates = true
    [remote "origin"]
            url = https://github.com/mogago/app2.git
            fetch = +refs/heads/*:refs/remotes/origin/*

Ahora tendremos un ``remote "origin"`` con una URL y un **Refspecs**, que indica cómo conectar branches en el servidor remoto a los branches locales. Ahora podemos correr el último comando de GitHub:

.. code-block:: bash

    $ git push -u origin master

    Username for 'https://github.com': 
    Password for 'https://mogago@github.com':
    Counting objects: 5, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (3/3), done.
    Writing objects: 100% (5/5), 449 bytes | 449.00 KiB/s, done.
    Total 5 (delta 0), reused 0 (delta 0)
    To https://github.com/mogago/app2.git
    * [new branch]      master -> master
    Branch 'master' set up to track remote branch 'master' from 'origin'.

Si solo hubiésemos corrido ``git push origin master`` hubiese hecho push de una copia de todos nuestro cambios y la información de nuestro repositorio en el servidor remoto de GitHub. Específicamente tomaría todo el contenido del branch ``master`` y apuntará al branch ``master`` del servidor remoto. Pero usando ``git push -u`` no solo subimos los archivos a GitHub, también estamos configurando un **default upstream** (``-u``) para este branch:

Veamos el contenido de nuestro archivo de configuración local:

.. code-block:: bash
    :emphasize-lines: 10-12

    $ cat .git/config
    [core]
            repositoryformatversion = 0
            filemode = true
            bare = false
            logallrefupdates = true
    [remote "origin"]
            url = https://github.com/mogago/app2.git
            fetch = +refs/heads/*:refs/remotes/origin/*
    [branch "master"]
            remote = origin
            merge = refs/heads/master

Ahora tenemos 3 nuevas líneas que nos indican que para este repo, si estamos en el branch ``master``, cuando hagamos ``git push`` o ``git pull`` por defecto se debe conectar al servidor remote ``"origin"`` y que obtenga o entregue los contenidos del branch ``master``.

Si usáramos ``git pull`` sin indicar una dirección, por defecto sabrá que debe hacer pull de ``origin master``:

.. code-block:: bash

    $ git pull
    Already up to date.

Configuring your push default
-----------------------------

Hagamos ``git push``.

Antes de la versión de Git 2.0, el ``push`` default estaba configurado a 'matching'. Digamos que tenemos 2 branches locales ``master`` y ``feature1``. Si estamos en uno de estos branches, si hiciéramos ``git push`` haría push no solo de este branch si no también de todos los demás, por ejemplo del branch ``master``. Este modo se llama ``matching``.

Desde la versión Git 2.0 se cambió el push por defecto a ``simple``, es decir, si hacemos push en un branch solo hará push del branch donde nos encontramos.

.. Note::

    Para versiones anteriores a Git 2.0 cambiar el push por defecto a ``simple``:

    .. code-block:: bash
    
        $ git config --global push.default simple

Fetch versus pull
-----------------

Miremos las diferencias entre ``fetch`` y ``pull``. Comencemos creando un escenario.

En GitHub, actualizar la página web del repositorio. Se recomienda tener un archivo ``README``, así que lo crearemos, haciendo clic en el botón :guilabel:`Create new file`:

.. figure:: images/lesson6/github-new-file1.png
    :align: center

    GitHub - create new file - Paso 1

Crear el archivo ``README.md`` con el editor de GitHub integrado. Este archivo sirve para compartir información del proyecto en el home:

.. figure:: images/lesson6/github-new-file2.png
    :align: center

    GitHub - create new file - Paso 2

Dejemos el mensaje de commit por defecto y clic en el botón :guilabel:`Commit new file`:

.. figure:: images/lesson6/github-new-file3.png
    :align: center

    GitHub - create new file - Paso 3

Veremos el archivo ``README`` en el home del proyecto:

.. figure:: images/lesson6/github-new-file4.png
    :align: center

    GitHub - create new file - Paso 4

Veamos los branches:

.. code-block:: bash

    $ git branch 
    * master

Pero ahora usemos la opción ``-a``:

.. code-block:: bash

    $ git branch -a
    * master
      remotes/origin/master

Tenemos el branch local ``master`` pero también un branch denominado "**remote tracking branch**" (``remote/origin/master``).

Si vemos el log nos explicará por qué esta ahí y qué hace:

.. code-block:: bash

    $ git lg
    * 7c71072 (HEAD -> master, origin/master) Added about us page
    * 6c4de50 Added home page

Vemos que los branches ``origin/master`` y ``master`` están apuntando al mismo ``commit``.

.. Note::

    Cabe señalar que a pesar que vemos este branch remoto, Git no realiza una búsqueda por la red en Internet.

Este "remote tracking branch" es una copia local de todas las cosas que estaban en nuestro servidor remoto hasta la última vez que hablamos con él (le hicimos ``pull`` o clonamos el repositorio).

Algunas veces haremos checkout al branch ``origin/master`` para ver qué cambios están hanciendo en el servidor remoto y decir si lo pasamos a nuestro trabajo. Hay 2 formas en que podemos hacer esto:

1. Usualmente usamos ``git pull`` para obtener los cambios de GitHub y hacer merge en nuestro branch local ``master``:

.. code-block:: bash

    $ git pull

    remote: Enumerating objects: 4, done.
    remote: Counting objects: 100% (4/4), done.
    remote: Compressing objects: 100% (2/2), done.
    remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
    Unpacking objects: 100% (3/3), done.
    From https://github.com/mogago/app2
        7c71072..4423d0f  master     -> origin/master
    Updating 7c71072..4423d0f
    Fast-forward
     README.md | 4 ++++
     1 file changed, 4 insertions(+)
     create mode 100644 README.md

    $ git lg
    * 4423d0f (HEAD -> master, origin/master) Create README.md
    * 7c71072 Added about us page
    * 6c4de50 Added home page

Vemos que el log se habrá actualizado y tenemos un ``commit`` más y tanto ``origin/master`` y ``master`` están apuntando al nuevo ``commit``.

2. Hay otra cosa que podemos hacer de forma más granular. Podemos hacer "**fetch**" (extraer) y luego merge.

En GitHub, editemos el archivo ``README.md``:

.. figure:: images/lesson6/github-new-commit1.png
    :align: center

    GitHub - new commit

Clic en :guilabel:`Commit new file`:

.. figure:: images/lesson6/github-new-commit2.png
    :align: center

    GitHub - new commit

En GitHub veremos que tenemos 1 commit más, sin embargo en Git, seguiremos teniendo los mismos:

.. figure:: images/lesson6/github-new-commit3.png
    :align: center

    GitHub - new commit

.. code-block:: bash

    $  git lg
    * 4423d0f (HEAD -> master, origin/master) Create README.md
    * 7c71072 Added about us page
    * 6c4de50 Added home page

Ahora seamos más cuidadosos usando ``git fetch``. Esta es en realidad la operación de red. Cuando decimos ``git pull``, en realidad estamos corriendo 2 comandos: fetch y merge. Fetch para que obtenga la información de Internet y merge los cambios de ``origin/master`` a nuestro branch ``master``.

.. code-block:: bash

    $ git fetch

    remote: Enumerating objects: 5, done.
    remote: Counting objects: 100% (5/5), done.
    remote: Compressing objects: 100% (3/3), done.
    remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
    Unpacking objects: 100% (3/3), done.
    From https://github.com/mogago/app2
        4423d0f..6c53f4e  master     -> origin/master

    $ git lg
    * 6c53f4e (origin/master) Adding contributor guide to README.md
    * 4423d0f (HEAD -> master) Create README.md
    * 7c71072 Added about us page
    * 6c4de50 Added home page

``git fetch`` ha bajado los cambios desde Internet pero no ha hecho el merge en el branch ``master``.

Si quisiéramos ver qué contiene es guía de contribuidores podríamos hacer checkout a ``origin/master`` como cualquier otro branch:

.. code-block:: bash

    $ cat README.md 
        Web2
        ====

        Welcome to this greate new project


    $ git checkout origin/master 
    Note: checking out 'origin/master'.

    You are in 'detached HEAD' state. You can look around, make experimental
    changes and commit them, and you can discard any commits you make in this
    state without impacting any branches by performing another checkout.

    If you want to create a new branch to retain commits you create, you may
    do so (now or later) by using -b with the checkout command again. Example:

    git checkout -b <new-branch-name>

    HEAD is now at 6c53f4e Adding contributor guide to README.md

Veamos el contenido del ``README.md``

.. code-block:: bash

    $ cat README.md
        Web2
        ====

        Welcome to this greate new project

        Contributors Guide
        ==================

        Just fork the repo and send me a pull request

Si estamos contentos con el contenido del archivo nos queda hacer merge (tipo "fast forward") hacia el ``master``:

.. code-block:: bash

    $ git checkout master
    Previous HEAD position was 6c53f4e Adding contributor guide to README.md
    Switched to branch 'master'
    Your branch is behind 'origin/master' by 1 commit, and can be fast-forwarded.
      (use "git pull" to update your local branch) 

    $ git merge origin/master 
    Updating 4423d0f..6c53f4e
    Fast-forward
     README.md | 5 +++++
     1 file changed, 5 insertions(+)
    
Comprobemos que tenemos el archivo actualizado desde el branch ``master``:

.. code-block:: bash

    $ cat README.md 
        Web2
        ====

        Welcome to this greate new project

        Contributors Guide
        ==================

        Just fork the repo and send me a pull request
    
    $ git lg
    * 6c53f4e (HEAD -> master, origin/master) Adding contributor guide to README.md
    * 4423d0f Create README.md
    * 7c71072 Added about us page
    * 6c4de50 Added home page

Merge versus rebase on pull
---------------------------

La última cosa que veremos sobre fetching y mergin es: merging versus rebasing cuando hacemos ``pull``.

Acabamos de ver el caso que hacemos fetch y luego merge hacia el branch ``master``. ¿Qué hubiese pasado si hubiéramos tenido nuestro propio ``commit`` en el branch ``master``?

Volvamos a editar el archivo README.md desde GitHub con el mensaje de ``commit`` por defecto:

.. code-block:: md

    Web2
    ====

    Welcome to this greate new project

    Contributors Guide
    ==================

    Just fork the repo and send me a pull request

    Add more text

Veamos los commits en GitHub:

.. figure:: images/lesson6/github-new-commit4.png
    :align: center

    GitHub - new commit

Ahora localmente tenemos un ``commit`` menos:

.. code-block:: bash

    $ git lg
    * 6c53f4e (HEAD -> master, origin/master) Adding contributor guide to README.md
    * 4423d0f Create README.md
    * 7c71072 Added about us page
    * 6c4de50 Added home page

Hagamos fetch y veamos el log:

.. code-block:: bash

    $ git fetch
    remote: Enumerating objects: 5, done.
    remote: Counting objects: 100% (5/5), done.
    remote: Compressing objects: 100% (3/3), done.
    remote: Total 3 (delta 1), reused 0 (delta 0), pack-reused 0
    Unpacking objects: 100% (3/3), done.
    From https://github.com/mogago/app2
        6c53f4e..2d57fde  master     -> origin/master

    $ git lg
    * 2d57fde (origin/master) Update README.md
    * 6c53f4e (HEAD -> master) Adding contributor guide to README.md
    * 4423d0f Create README.md
    * 7c71072 Added about us page
    * 6c4de50 Added home page

Imaginemos que hagamos un ``commit`` localmente:

.. code-block:: bash

    $ vi index.html
        hello world
        welcome to our website!

    $ git commit -am "Added longer welcome to the home page"
    [master 1e4341a] Added longer welcome to the home page
     1 file changed, 1 insertion(+)
    
    $ git lg
    * 1e4341a (HEAD -> master) Added longer welcome to the home page
    | * 2d57fde (origin/master) Update README.md
    |/  
    * 6c53f4e Adding contributor guide to README.md
    * 4423d0f Create README.md
    * 7c71072 Added about us page
    * 6c4de50 Added home page

Antes hicimos un cambios en el branch ``origin/master`` desde GitHub, pero ahora hemos hecho un cambio localmente en nuestro branch ``master``. Encontrando una divergencia en el historial.

Si corriéramos ``git pull`` o ``git merge origin/master`` no haría un fast forward y tendríamos un mensaje de ``commit`` no aconsejable. Funciona pero está mal:

.. code-block:: bash

    $ git merge origin/master

        Merge remote-tracking branch 'origin/master'

        # Please enter a commit message to explain why this merge is necessary,
        # especially if it merges an updated upstream into a topic branch.
        #
        # Lines starting with '#' will be ignored, and an empty message aborts
        # the commit.
    
    Merge made by the 'recursive' strategy.
    README.md | 2 ++
    1 file changed, 2 insertions(+)

    $ git lg
    *   6a4c9da (HEAD -> master) Merge remote-tracking branch 'origin/master'
    |\  
    | * 2d57fde (origin/master) Update README.md
    * | 1e4341a Added longer welcome to the home page
    |/  
    * 6c53f4e Adding contributor guide to README.md
    * 4423d0f Create README.md
    * 7c71072 Added about us page
    * 6c4de50 Added home page

No es aconsejable porque no tenemos una información semática útil. Así que borremos el último ``commit``:

.. code-block:: bash

    $ git reset --hard HEAD~1
    HEAD is now at 1e4341a Added longer welcome to the home page

    $ git lg
    * 1e4341a (HEAD -> master) Added longer welcome to the home page
    | * 2d57fde (origin/master) Update README.md
    |/  
    * 6c53f4e Adding contributor guide to README.md
    * 4423d0f Create README.md
    * 7c71072 Added about us page
    * 6c4de50 Added home page

Hemos vuelto al punto de referencia anterior. Queremos juntar esas dos líneas de historia pero no queremos hacer merge, es decir, hacer que parezca como si viéramos cosa por cosa pero en realidad estamos haciendo más de una cosa al mismo tiempo. Esto lo haremos usando **rebase**.

En el branch ``master`` usamos rebase:

.. code-block:: bash

    $ git rebase origin/master 
    First, rewinding head to replay your work on top of it...
    Applying: Added longer welcome to the home page

    $ git lg
    * 42c4494 (HEAD -> master) Added longer welcome to the home page
    * 2d57fde (origin/master) Update README.md
    * 6c53f4e Adding contributor guide to README.md
    * 4423d0f Create README.md
    * 7c71072 Added about us page
    * 6c4de50 Added home page

Hemos cambiado la base del ``master`` a ``2d57fde``, como si no hubiéramos comenzado a programar localmente hasta que ``origin/master`` haya acabado su trabajo.

Ahora actualizaremos nuestro trabajo en el servidor remoto con ``push``:

.. code-block:: bash

    $ git push
    Username for 'https://github.com': mogago
    Password for 'https://mogago@github.com': 
    Counting objects: 3, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (2/2), done.
    Writing objects: 100% (3/3), 313 bytes | 313.00 KiB/s, done.
    Total 3 (delta 1), reused 0 (delta 0)
    remote: Resolving deltas: 100% (1/1), completed with 1 local object.
    To https://github.com/mogago/app2.git
        2d57fde..42c4494  master -> master

En lugar de usar fetch y merge podemos hacer un fetch y rebase en un solo comando:

.. code-block:: bash

    $ git pull --rebase
