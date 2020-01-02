.. _leccion-7:

Lesson 7
========

*Lesson 7: Collaborating via GitHub*

.. contents:: Table of Contents 

Cloning a repository
--------------------

Hasta este momento solo hemos creado nuestros proyectos localmente y le hemos hecho ``push`` hacia GitHub. Pero es más común que trabajemos en proyectos que alguien más haya iniciado:

Un usuario distinto al nuestro ha creado su repositorio:

.. code-block:: bash

    $ git status
    fatal: not a git repository (or any of the parent directories): .git

    $ mkdir clone_me
    $ cd clone_me/
    $ touch index.html
    $ git init
    Initialized empty Git repository in /home/user/Documents/gittests/clone_me/.git/

    $ git add .
    $ git commit -m "Added home page"
    [master (root-commit) 9568a2a] Added home page
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 index.html

El usuario, desde GitHub creó un repositorio con el mismo nombre ``clone_me`` y lo añadió a su repositorio local de Git creado. Presionar el botón :guilabel:`+`, opción :guilabel:`New Repository`, usar el nombre ``clone_me`` y clic en el botón :guilabel:`Create repository`:

.. figure:: images/lesson7/github-new-repo1.png
    :align: center

    GitHub - create new repository ``clone_me``

En el terminal, el usuario ejecutó:

.. code-block:: bash

    $ git remote add origin https://github.com/mogago/clone_me.git
    $ git push -u origin master

Desde un lugar que no sea un directorio Git haremos una copia local de este repositorio externo:

.. code-block:: bash

    $ cd ..
    $ mkdir student
    $ cd student/
    $ git status
    fatal: not a git repository (or any of the parent directories): .git

    $ git clone https://github.com/mogago/clone_me
    Cloning into 'clone_me'...
    remote: Enumerating objects: 3, done.
    remote: Counting objects: 100% (3/3), done.
    remote: Total 3 (delta 0), reused 3 (delta 0), pack-reused 0
    Unpacking objects: 100% (3/3), done.

Ahora tenemos nuestra propia copia del repositorio y podemos hacer cualquier cambio localmente. Veamos el log:

.. code-block:: bash

    $ cd clone_me/
    $ git lg
    * 9568a2a (HEAD -> master, origin/master, origin/HEAD) Added home page

    $ touch about.html
    $ git add .
    $ git commit -m "Added about as page"
    [master f76a9a0] Added about as page
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 about.html

Pero si ahora tratamos de hacer ``git push`` obtendremos un error de autenticación porque somos un usuario distinto. No somo invitados como colaboradores a este proyecto.

El primer uso de cloning es tener una copia a la cual podemos hacerle cambios localmente.

Forking a repository
--------------------

¿Qué pasa si hay un proyecto al que no tenemos acceso de hacer ``push`` pero queremos contribuir al proyecto?: creamos un **fork**.

.. code-block:: bash

    $ git status
    fatal: not a git repository (or any of the parent directories): .git

    $ git init fork_me
    Initialized empty Git repository in /home/gabriel/Documents/gittests/fork_me/.git/

    $ cd fork_me/
    $ touch index.html
    $ git add .
    $ git commit -m "Added home page to forkable repo"
    [master (root-commit) 70b87af] Added home page to forkable repo
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 index.html

En GitHub:

.. figure:: images/lesson7/github-new-repo2.png
    :align: center

    GitHub - create new repository ``fork_me``

En el terminal:

.. code-block:: bash

    $ git remote add origin https://github.com/mogago/fork_me.git
    $ git push -u origin master

Desde una ventan en incógnito sin loguearnos o usando un usuario distinto acceder al URL: https://github.com/mogago/fork_me.git

.. Note::

    ¿Cuál es la diferencia entre clone y fork?. Es como la pregunta ¿usar merge o rebase?, siempre harás merge pero la pregunta es si harás rebase primero. Es similiar con cloning y forking.

Siempre clonaremos un repositorio si queremos una copia local en nuestra laptop donde podamos hacer cambios. La única pregunta es si primero haremos fork al repositorio. Veamos algunos casos:

- Si no queremos hacer contribuciones a un proyecto, no requerimos hacer fork para tener una copia del repositorio, solo basta hacer cloning.
- Si es un repositorio al que hemos sido añadidos como colaboradores, no necesitamos hacer fork, solo hacer cloning y hacer ``push`` de vuelta con nuestros cambios porque alguien nos agregó como colaborador.
- Si queremos contribuir a un proyecto del cual desconocemos quienes lo crearon, deberemos hacer **fork** de ese repositorio. Esto es, tomaremos su copia del repositorio de Github y haremos nuestra propia copia del repositorio también en GitHub. Es decir el mismo proyecto bajo nuestro nombre de usuario (``https://github.com/anotheruser/fork_me.git``). Luego podemos clonarlo, hacerle cambios y hacerle ``push`` a nuestra propia copia, nuestro fork del repositorio.

Desde otra cuenta de GitHub, entrar a la URL del creador del repositorio: https://github.com/mogago/fork_me.git y clic en la opción :guilabel:`Fork`:

.. figure:: images/lesson7/github-fork1.png
    :align: center

    GitHub - Fork de repositorio externo

Ahora veremos que hemos hecho un fork del repositorio en nuestra dashboard de GitHub:

.. figure:: images/lesson7/github-fork2.png
    :align: center

    GitHub - Fork de repositorio externo

Hagamos una copia local de nuestro repositorio, nuestro fork:

.. code-block:: bash

    $ cd ..
    $ cd student/
    $ git status
    fatal: not a git repository (or any of the parent directories): .git

    $ git clone https://github.com/externaluser/fork_me
    Cloning into 'fork_me'...
    remote: Enumerating objects: 3, done.
    remote: Counting objects: 100% (3/3), done.
    remote: Total 3 (delta 0), reused 3 (delta 0), pack-reused 0
    Unpacking objects: 100% (3/3), done.

    $ cd fork_me/

Con nuestra copia, creemos un archivo con nuestro nombre de usuario:

.. code-block:: bash

    $ git push
    Username for 'https://github.com': externaluser
    Password for 'https://externaluser@github.com': 
    Counting objects: 2, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (2/2), done.
    Writing objects: 100% (2/2), 272 bytes | 272.00 KiB/s, done.
    Total 2 (delta 0), reused 0 (delta 0)
    To https://github.com/externaluser/fork_me
        70b87af..241bd97  master -> master

Si vamos al repositorio original veremos que ninguno de nuestros cambios están aquí porque nuestros cambios se han hecho en el fork:

.. figure:: images/lesson7/github-fork3.png
    :align: center

    GitHub - Repositorio original

En los commits de GitHub veremos 2 commits en el fork. Un fork hecho por el creador original y otro hecho por nosotros en nuestra copia local.

Contributing via a pull request from a fork
-------------------------------------------

Una vez que he hecho fork de un repositorio, lo he clonado para tener una copia local, he hecho mis cambios y le he hecho ``push`` de vuelta a mi fork, ¿cómo haríamos para que nuestros cambios vayan al repositorio original?. Debemos usar un ``pull request``.

El propósito de un ``pull request`` es pedir o preguntar a personas en otros proyectos para que incorporen nuestros cambios.

Con el usuario que ha creado el fork ingresar a nuestro fork desde GitHub y clic en el botón :guilabel:`New pull request`:

.. figure:: images/lesson7/github-fork4.png
    :align: center

    GitHub - Repositorio original

Ya que este es un fork de otro proyecto, GitHub supone que lo que queremos hacer es tomar los cambios del ``master`` branch que hemos hecho en el fork del repositorio y hacer merge con el ``master`` branch del repositorio original. Clic en botón :guilabel:`Create pull request`:

.. figure:: images/lesson7/github-pull-request1.png
    :align: center

    GitHub - ``pull request``

Ahora deberemos ingresar un mensaje donde fundamentamos por qué deben incluir nuestro código en ese repositorio. Clic en botón :guilabel:`Create pull request`:

.. figure:: images/lesson7/github-pull-request2.png
    :align: center

    GitHub - Mensaje ``pull request``

Alguien que posea el proyecto podrá hacer merge con nuestros cambios.

Approving a pull request from a fork
------------------------------------

Ahora logueados como usuarios propietarios del repositorio podemos ver la lista de ``pull request``:

.. figure:: images/lesson7/github-pull-request3.png
    :align: center

    GitHub - Lista de peticiones de ``pull request``

.. figure:: images/lesson7/github-pull-request4.png
    :align: center

    GitHub - Aceptar petición ``pull request``

.. figure:: images/lesson7/github-pull-request5.png
    :align: center

    GitHub - Aceptar petición ``pull request``

Una vez que aceptemos los cambios de la petición ``pull request`` podemos hacer merge de este. Para hacer esto será igual que hacer merge de dos branches en la línea de comandos. Tomará la divergencia del historial si existe y nunca creará un fast forward merge. Clic en la opción :guilabel:`Merge pull request`:

Nos saldrá en la misma ventana un recuadro de texto para confierma el merge, editarlo según deseemos y clic en :guilabel:`Confirm merge`:

.. figure:: images/lesson7/github-pull-request6.png
    :align: center

    GitHub - Aceptar petición ``pull request``

En los archivos del repositorio externo veremos el archivo con el cual contribuyó el usuario externo:

.. figure:: images/lesson7/github-pull-request7.png
    :align: center

    GitHub - Petición ``pull request`` aceptada

Use cases for fork based collaboration
--------------------------------------

Hay 2 casos de uso principales de fork based ``pull request``:

1. Entorno de confianza: Si estamos trabajando con un equipo de personas que no conocemos. Aceptamos contribuciones que no conocemos personalmente.

2. Contribuidores ocasiones. En una compañía podría servir para no dar permisos totales a personas que no deseemos darles permisos dentro de nuestro repo.

Donde no funciona muy bien es con un grupo pequeño de personas que trabajan juntos regularmente. No es deseable que cada uno tenga su propio fork.

.. _colaboradores:

Single repo collaboration directly on master
--------------------------------------------

1. Nuevo repositorio en Git y GitHub.
2. Desde otro usuario distinto al creador del repositorio clonar el repositorio y agregar un archivo, commit y push. No podremos hacer push porque no somos colaboradores.
3. Agregar como colaborador desde GitHub al usuario que hizo fork del proyecto.
4. Si hacemos un push desde el creador del repo, antes que los colaboradores haga un repo no obtendremos error.
5. Si alguien hace push obtendrá error. Deberá hacer git pull primero. Pero para que no sea desordenado, usar --rebase.
6. Si nadie ha hecho un push, podremos hacer nuestro git push

Creemos otro proyecto. Desde el terminal:

.. code-block:: bash

    $ git init single_repo
    Initialized empty Git repository in /home/gabriel/Documents/gittests/single_repo/.git/

    $ cd single_repo/
    $ touch index.html
    $ git add .

    $ git commit -m "Added new home page"
    [master (root-commit) aa2d72f] Added new home page
    1 file changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 index.html

Desde GitHub:

.. figure:: images/lesson7/github-single_repo1.png
    :align: center

    GitHub - Creación de nuevo repo

En el terminal hacemos ``git push`` del repositorio local:

.. code-block:: bash

    $ git remote add origin https://github.com/mogago/single_repo.git
    $ git push -u origin master
    Username for 'https://github.com': mogago
    Password for 'https://mogago@github.com': 
    Counting objects: 3, done.
    Writing objects: 100% (3/3), 219 bytes | 219.00 KiB/s, done.
    Total 3 (delta 0), reused 0 (delta 0)
    To https://github.com/mogago/single_repo.git
    * [new branch]      master -> master
    Branch 'master' set up to track remote branch 'master' from 'origin'.

Hasta acá hemos hecho una configuración y creación básica de un repositorio Git/GitHub.

Desde otra cuenta diferente al creador del repositorio ireamos al URL del repo (https://github.com/mogago/single_repo), lo clonaremos y haremos un ``commit``. Sin embargo, no podremos hacer ``push`` a este repositorio porque no somos colaboradores.

Primero añadiremos como colaborador desde el usuario dueño del repositorio al otro usuario. En el repositorio de GitHub seleccionar la opción :guilabel:`Settings` de la barra superior, luego seleccionar la opción :guilabel:`Collaborators` de la barra lateral izquierda.

.. figure:: images/lesson7/github-single_repo2.png
    :align: center

    GitHub - Añadir Colaborador, opción :guilabel:`Settings`, :guilabel:`Collaborators`

Ingresar el nombre de usuario o correo del colaborador que deseemos agregar. Clic en :guilabel:`Add collaborator`

.. figure:: images/lesson7/github-single_repo3.png
    :align: center

    GitHub - Añadir colaborador, nombre de usuario

Se habrá enviado una invitación de colaboración al usuario externo:

.. figure:: images/lesson7/github-single_repo4.png
    :align: center

    GitHub - Añadir colaborador, invitación enviada

El usuario externo recibirá un correo con la invitación de colaboración mediante la URL: https://github.com/mogago/single_repo/invitations

.. figure:: images/lesson7/github-single_repo5.png
    :align: center

    GitHub - Aceptar invitación, opción :guilabel:`Accept invitation`

Clic en la opción :guilabel:`Accept invitation`. Ahora en el repositorio veremos el siguiente mensaje: ``You now have push access to the mogago/single_repo repository.``. Es decir, ahora podremos hacer ``push`` al repositorio.

Los dos colaboradores están trabajando en el mismo branch ``master`` y harán ``push`` a este branch.

Desde el usuario externo añadido como colaborador clonaremos el repositorio, haremos un ``commit`` y ``push``:

.. code-block:: bash

    $ git clone https://github.com/mogago/single_repo.git
    $ touch externaluser.txt
    $ git add .
    $ git commit -m "Added my name"
    [master f395a21] Added my name
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 externaluser.txt

    $ git push
    Username for 'https://github.com': andrtemdown
    Password for 'https://andrtemdown@github.com': 
    Counting objects: 2, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (2/2), done.
    Writing objects: 100% (2/2), 257 bytes | 257.00 KiB/s, done.
    Total 2 (delta 0), reused 0 (delta 0)
    To https://github.com/mogago/single_repo.git
        aa2d72f..f395a21  master -> master

Desde el usuario creador del repo tendremos problemas al hacer un ``push``:

.. code-block:: bash

    $ touch mogago.txt
    $ git add .
    $ git commit -m "Added my name mogago"
    [master b0c8a81] Added my name mogago
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 mogago.txt

    $ git push
    Username for 'https://github.com': mogago
    Password for 'https://mogago@github.com': 
    To https://github.com/mogago/single_repo.git
        ! [rejected]        master -> master (fetch first)
    error: failed to push some refs to 'https://github.com/mogago/single_repo.git'
    hint: Updates were rejected because the remote contains work that you do
    hint: not have locally. This is usually caused by another repository pushing
    hint: to the same ref. You may want to first integrate the remote changes
    hint: (e.g., 'git pull ...') before pushing again.
    hint: See the 'Note about fast-forwards' in 'git push --help' for details.

El ``push`` no funciona porque hay cambios en GitHub que nosotros no tenemos, por lo tanto primero debemos hacer ``git pull``. Sin embargo, con este comando será un poco desordenado, así que usaremos ``git pull --rebase`` desde el usuario creador del repo. Y luego ``git push`` para agregar nuestros cambios:

.. code-block:: bash

    $ git pull --rebase
    remote: Enumerating objects: 3, done.
    remote: Counting objects: 100% (3/3), done.
    remote: Compressing objects: 100% (2/2), done.
    remote: Total 2 (delta 0), reused 2 (delta 0), pack-reused 0
    Unpacking objects: 100% (2/2), done.
    From https://github.com/mogago/single_repo
    aa2d72f..f395a21  master     -> origin/master
    First, rewinding head to replay your work on top of it...
    Applying: Added my name mogago

    $ ls
    externaluser.txt  index.html  mogago.txt

    $ git push
    Username for 'https://github.com': mogago
    Password for 'https://mogago@github.com': 
    Counting objects: 2, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (2/2), done.
    Writing objects: 100% (2/2), 276 bytes | 276.00 KiB/s, done.
    Total 2 (delta 0), reused 0 (delta 0)
    To https://github.com/mogago/single_repo.git
        f395a21..31c9eb4  master -> master

Podemos ver que esta no es una buena forma de trabajo porque si fuesen más usuarios, todos estarían haciendo ``push`` sobre el mismo branch al mismo tiempo sobre el trabajo de otros. El problema es que no podremos hacer ``push`` sin antes haber hecho ``pull`` y obstaculiza el trabajo del grupo. Todos trabajando en ``master`` branch no funciona.

Single repo collaboration using feature branches
------------------------------------------------

Para solucionar el problema anterior, usaremos **feature branches**. Con feature branches, en lugar de que todos colaboremos directamente en el branch ``master``, todos construyamos nuestros feature branches por separado.

Usualmente en un proyecto real, cada feature branch será nombrado bajo el nombre del feature que deseemos construir. En este caso, podemos crear un brach con nuestro nombre de usuario.

Desde el usuario añadido como colaborador:

.. code-block:: bash

    $ git checkout -b externaluser
    Switched to a new branch 'externaluser'
    $ vi externaluser.txt
        Here is some text I added

    $ git commit -am "Added some great content to my file"
    [externaluser fb2938b] Added some great content to my file
    1 file changed, 1 insertion(+)
    $ git lg
    * fb2938b (HEAD -> externaluser) Added some great content to my file
    * f395a21 (origin/master, origin/HEAD, master) Added my name
    * aa2d72f Added new home page

En el log veremos que nuestro branch está un ``commit`` adelante del branch ``master`` y ``origin/master``. Lo siguiente que debemos hacer es un ``push`` de nuestro branch hacia GitHub. Para esto, configuraremos otro **default upstream** con nuestro **feature branch**:

.. code-block:: bash

    $ git push -u origin externaluser
    Username for 'https://github.com': andrtemdown
    Password for 'https://andrtemdown@github.com': 
    Counting objects: 8, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (5/5), done.
    Writing objects: 100% (8/8), 743 bytes | 743.00 KiB/s, done.
    Total 8 (delta 0), reused 0 (delta 0)
    remote: 
    remote: Create a pull request for 'externaluser' on GitHub by visiting:
    remote:      https://github.com/mogago/single_repo/pull/new/externaluser
    remote: 
    To https://github.com/mogago/single_repo.git
    * [new branch]      externaluser -> externaluser
    Branch 'externaluser' set up to track remote branch 'externaluser' from 'origin'.

En GitHub veremos que se ha creado un nuevo branch ``externaluser``:

.. figure:: images/lesson7/github-single_repo6.png
    :align: center

    GitHub - Nuevo branch

Con el creador del repositorio recuperaremos los cambios hechos por el usuario externo:

.. code-block:: bash

    $ git lg
    * 31c9eb4 (HEAD -> master, origin/master) Added my name mogago
    * f395a21 Added my name
    * aa2d72f Added new home page

    $ cat externaluser.txt 
    $ git checkout master 
    Already on 'master'
    Your branch is up to date with 'origin/master'.

    $ git pull
    remote: Enumerating objects: 5, done.
    remote: Counting objects: 100% (5/5), done.
    remote: Compressing objects: 100% (2/2), done.
    remote: Total 3 (delta 0), reused 3 (delta 0), pack-reused 0
    Unpacking objects: 100% (3/3), done.
    From https://github.com/mogago/single_repo
    * [new branch]      externaluser -> origin/externaluser
    Already up to date.

Notamos que se tiene un nuevo branch ``externaluser`` al haber hecho ``git pull``. Ahora veremos los cambios en el repositorio:

.. code-block:: bash

    $ git lg
    * fb2938b (origin/externaluser) Added some great content to my file
    | * 31c9eb4 (HEAD -> master, origin/master) Added my name mogago
    |/  
    * f395a21 Added my name
    * aa2d72f Added new home page

Contributing to another feature branch
--------------------------------------

Desde el usuario creador del repositorio podemos ver todos los branches con la opción ``branch -a``:

.. code-block:: bash

    $ git branch -a
    * master
    remotes/origin/externaluser
    remotes/origin/master

Con el mismo usuario creador del repositorio haremos checkout al branch creado por el usuario externo colaborador:

.. code-block:: bash

    $ git checkout externaluser 
    Branch 'externaluser' set up to track remote branch 'externaluser' from 'origin'.
    Switched to a new branch 'externaluser'

    $ git branch
    * externaluser
      master
    
    $ cat externaluser.txt 
    Here is some text I added

Veremos que tenemos un branch más agregado y podemos ver el contenido del archivo ``externaluser.txt``, hacerle cambios y contribuir.

.. Note::

    ¿Qué hemos hecho?: Tenemos un solo repositorio, cada colabordor está trabajando en un feature branch y cada uno puede bajar (``pull``) cualquier feature branch que se haya subido a GitHub (``push``), hacer checkout a esos branches y contribuir si deseamos.

Creating a pull request within a single repo
--------------------------------------------

En algún punto querremos crear un ``pull request``. Previamente vimos a ``pull request`` como una forma de pedir a una persona en otro proyecto agregue nuestro trabajo de nuestro fork del proyecto.

``pull request`` también se usa por varios equipos como la forma por defecto de colaborar en un nuevo feature. La forma en que funciona es que creamos un nuevo feature branch y le hacemos ``push`` hacia GitHub (como hemos visto en el tema anterior). Cuando hemos acabado con esto, creamos un ``pull request``. Ahora cualquiera en el equipo, puede comentarlo, interactuar y hacer cambios si lo necesita.

Creemos un ``pull request``. Desde el usuario añadido como colaborador en GitHub ir a la sección :guilabel:`Pull requests`, opción :guilabel:`New pull request`, comparar los branches ``master`` y ``externaluser``:

.. figure:: images/lesson7/github-single_repo7.png
    :align: center

    GitHub - Comparing changes

Seleccionar la opción :guilabel:`pull request`. Dar una descripción y clic en la opción :guilabel:`Create pull request`. El usuario creador del repositorio podrá interactuar con este ``pull request``.

Collaborating on a pull request
-------------------------------

Todos los colaboradores pueden hacer merge del ``pull request``. La idea es que el mismo usuario que ha realizado el ``pull request`` no haga el merge sin antes haber recibido feedback de su trabajo. Ya que es un repositorio público, cualquiera puede poner comentarios en la siguiente ventana:

.. figure:: images/lesson7/github-single_repo8.png
    :align: center

    GitHub - :guilabel:`Merge pull request`

Un ``pull request`` no apunta a un ``commit``, apunta a un branch. Si agregamos más cosas a un branch, añadirá más ``commits`` al pull request. Luego de que sintamos que el código está listo, algunos de los colaboradores hará merge del ``pull request``.

Merging in a pull request
-------------------------

Generalmente queremos asegurarnos que otros colaboradores haya aceptado nuestro trabajo y hacerle merge. ¿Quién hará el merge?: mejor será que quien ha creado el ``pull request`` haga el merge, habiendo recibido aceptación en su trabajo de otros colaboradores.
