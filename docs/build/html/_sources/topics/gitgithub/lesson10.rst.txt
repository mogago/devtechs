Lesson 10
=========

*Lesson 10: Tags and Releases*

.. contents:: Table of Contents

Three types of tags
-------------------

¿Cómo lanzar features?, ¿cómo hacemos seguimiento de nuestros lanzamientos usando GitHub?. Para hacer esto creemos otro proyecto:

.. code-block:: bash

    $ git init app3
    $ touch index.html
    $ git add .
    $ git commit -m "Added home page"
    [master (root-commit) ebaf39d] Added home page
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 index.html

Generalmente, cuando lanzamos a producción, querremos crer un tag. La única excepción a esto es que si estamos corriendo despliegues continuos donde cada vez un ``commit`` termina en el branch ``master``, termina automáticamente en producción. En este caso no se requiere etiquetarlo porque sabemos que todos acabarán en producción.

Si estamos más lejos de una entrega continua, cada vez que hagamos push de master a producción podemos crear un tag. Hay tres tipos de tags en Git:

1. Lightweight tags: solo nos dirá que existe un tag para un commit en particular.

.. code-block:: bash

    $ git tag v1.0.0
    $ git lg
    * ebaf39d (HEAD -> master, tag: v1.0.0) Added home page

    $ git show v1.0.0
    commit ebaf39d20013c69e4d21544f74f5271d8d9ed1ad (tag: v1.0.0)
    Author: Nombre Apellido <newuser1@mail.com>
    Date:   Wed Jan 1 21:21:22 2020 -0500

        Added home page

    diff --git a/index.html b/index.html
    new file mode 100644
    index 0000000..e69de29

2. Annotated tags: (opción ``tag -a``), usamos un annotated tag versus un lightweight tag para mostrar quién hizo el tag, a cuándo y qué dijeron cuando hicieron el tag, a parte del último commit realizado.

Generalmente generamos este tag justo antes de pasar el proyecto a producción.

.. code-block:: bash

    $ touch index.css
    $ git add .
    $ git commit -m "Added stylesheet for homepage"
    [master 128d3cd] Added stylesheet for homepage
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 index.css

    $ git tag -a v1.0.1 -m  "Updated homepage to include stylesheet"
    $ git lg
    * 128d3cd (HEAD -> master, tag: v1.0.1) Added stylesheet for homepage
    * ebaf39d (tag: v1.0.0) Added home page

    $ git show v1.0.1
    tag v1.0.1
    Tagger: Nombre Apellido <newuser1@mail.com>
    Date:   Wed Jan 1 21:30:42 2020 -0500

    Updated homepage to include stylesheet

    commit 128d3cdd49d95e9b264d43ccf770ae28e18e9cd4 (HEAD -> master, tag: v1.0.1)
    Author: Nombre Apellido <newuser1@mail.com>
    Date:   Wed Jan 1 21:30:02 2020 -0500

        Added stylesheet for homepage

    diff --git a/index.css b/index.css
    new file mode 100644
    index 0000000..e69de29

El tag se aplica específicamente a un commit en espeífico, no a un branch.

3. Signed tags: (opción ``tag -s``), usado para tags criptográfico, donde se necesita más niveles de seguridad y confirmación de que fue la persona quien lo creó.

Release tags versus release branches
------------------------------------

Veamos con los tags encajan en un proceso de release. Cuando lanzamos algo a producción, seguremante lo etiquetaremos. Pero, ¿cómo decido entre release tags y release branches?:

Un buen punto de inicio es cuando solo tenemos release tags, a menos que necesitemos release branches. ¿Cuándo necesitamos un release branch?: si nuestro cliente está pagando para soportar branches de larga duración, es decir, dar soporte a la versión 1, 2, 3, ... del código.

Otro razón para usar release branches si tenemos un proceso manual y necesitamos hacer varios commits antes de lanzar a producción. Pero si no tenemos branches de larga duración, y no tenemos bugs o fallos, podemos usar un release tag.

[...]

Cherry pick for reusing code across long running release branches
-----------------------------------------------------------------

¿Cómo vamos a tratar long-runnning release branches?.

[...]

Git stash for reusing code
--------------------------

Hay otra forma de reusar pequeñas unidades de código: ``git stash``.

.. code-block:: bash

    $ git checkout master
    Already on 'master'

    $ vi index.html
    $ cat index.html 
    Add some new content

    $ git s
    M index.html

Podríamos estar haciendo varios cambios y modificaciones pero alguien necesita hacer un arreglo rápido o hacer un mismo cambio a múltiples branches.

Para mover nuestro trabajo hacia un lado haremos lo siguiente:

.. code-block:: bash

    $ git s
    $ git status
    On branch master
    nothing to commit, working tree clean
    $ git lg
    *   45b2ffb (refs/stash) WIP on master: 128d3cd Added stylesheet for homepage
    |\  
    | * 34d74a4 index on master: 128d3cd Added stylesheet for homepage
    |/  
    * 128d3cd (HEAD -> master, tag: v1.0.1) Added stylesheet for homepage
    * ebaf39d (tag: v1.0.0) Added home page

El estado del repositorio nos dice que estamos libres, pero en el log veremos un ``commit`` ``(refs/stash)`` que está siguiendo nuestro cambios.

Ahora podemos aplicar este trabajo a todos los release branches:

[...]

Pushing tags up to GitHub and using releases
--------------------------------------------

[...]