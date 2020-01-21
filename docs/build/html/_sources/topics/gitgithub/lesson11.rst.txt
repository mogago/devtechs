Lesson 11
=========

*Lesson 11: How to undo almost everything using Git*

.. contents:: Table of Contents

Private versus public history and git revert
--------------------------------------------

Veamos ahora cómo deshacer casi todo usando Git. La primera área que cubriremos es la diferencia entre historial público y privado, y qué comando debemos usar.

El historial público es aquel historial al que le hemos hecho ``push`` hacia Git en un repositorio en el que al menos una persona tiene acceso, ya sea un colaborador o un proyecto público. Tan pronto hemos creado un proyecto público debemos asumir que alguien más tiene nuestro código fuente.

Como regla de oro, solo hay una forma en la que queremos cambiar el historial público, será a través del comando ``git revert``. Lo que hace este comando es tomar un ``commit`` existente y añade un ``commit`` que hace exactamente lo contrario: deshacer nuestro trabajo. Veamos un ejemplo:

.. code-block:: bash

    $ git init undoing
    Initialized empty Git repository in /home/user/Documents/gittests/undoing/.git/

    $ cd undoing/
    $ touch index.html
    $ git add .
    $ git commit -m "Added home page"
    [master (root-commit) 29519be] Added home page
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 index.html

    $ touch badidea.html
    $ git add .
    $ git commit -m "Bad idea"
    [master 4e9acd9] Bad idea
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 badidea.html

    $ git lg
    * 4e9acd9 (HEAD -> master) Bad idea
    * 29519be Added home page

Creemos el repositorio en GitHub:

.. figure:: images/lesson11/github-new-repo1.png
    :align: center

    GitHub - Creating a repo

En el terminal agregamos un remote:

.. code-block:: bash

    $ git remote add origin https://github.com/mogago/undoing.git
    $ git push -u origin master
    Username for 'https://github.com': mogago
    Password for 'https://mogago@github.com': 
    Counting objects: 5, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (3/3), done.
    Writing objects: 100% (5/5), 429 bytes | 429.00 KiB/s, done.
    Total 5 (delta 0), reused 0 (delta 0)
    To https://github.com/mogago/undoing.git
     * [new branch]      master -> master
    Branch 'master' set up to track remote branch 'master' from 'origin'.

Ahora tenemos historial público, por ejemplo veremos los ``commits``: 

.. figure:: images/lesson11/github-new-repo2.png
    :align: center

    GitHub - Commits

Si hemos compartido públicamente algo que no deseamos que lo sea, podemos usar varios comandos para borrar esos commits o cambiarlos. Sin embargo, tan pronto como hemos compartido esa información con el mundo, debemos usar ``git revert`` con el identificador hash SHA1 del ``commit``:

.. code-block:: bash

    $ git revert 4e9acd90b9d191414f2fe4a8f16f768125ed7287

        Revert "Bad idea"
        This reverts commit 4e9acd90b9d191414f2fe4a8f16f768125ed7287.

Se abrirá un editor de texto para agregar un mensaje al ``commit`` de revertir el cambio. Hagamos ``push`` y veamos el log:

.. code-block:: bash

    $ git push

    $ git lg
    * c76cba8 (HEAD -> master) Revert "Bad idea"
    * 4e9acd9 (origin/master) Bad idea
    * 29519be Added home page

Tenemos dos ``commits``, no es bueno pero al menos es seguro. Esto significa que si cualquier otra persona descarga una copia del repositorio no tendrán problemas porque tendrán un ``commit`` que ocasiona el problema y otro ``commit`` posterior que lo arregla.

Lo importante es que eliminado el problema de borrar ese código problemático (``badidea.html``):

.. code-block:: bash

    $ ls
    index.html

Don't push too often
--------------------

Si estamos trabajando con cosas que no le hemos hecho ``push``, hay muchas otras formas que podemos usar para reescribir el historial. Debido a esta distinción entre historial público y privado, cambia drásticamente la forma de trabajo con Git y GitHub.

Experiencia: antes mi manera de trabajo era escribir un poco de código y hacía ``add``, ``commit``, ``push``. Luego escribía más código y hacía ``add``, ``commit``, ``push``. Haciendo ``push``  a GitHub cada 5-10 minutos. Ahora trabajo de forma diferente porque hay varias herramientas que se pueden usar para limpiar el historial. Ahora escribo código y solo hago ``add``, ``commit``, desarrollo más código y  hago ``add``, ``commit``, pero no hago ``push``. Puedo seguir haciendo un commit cada 5 minutos pero hago mucho menos ``push`` a GitHub. La ventaja de esto es que antes de hacer ``push`` a los cambios, puedo ver lo ``commits`` realizados y limpiar el historial.

En las siguientes secciones se verán algunos comando para limpiar el historial.

Git commit --ammend
-------------------

Uno de los comandos más fáciles es ``git commit --ammend``. Veamos un ejemplo:

.. code-block:: bash

    $ ls
    index.html
    $ touch about.html
    $ git add .
    $ git commit -m "Added about us page dasndksajdnjksa"
    [master c425487] Added about us page dasndksajdnjksa
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 about.html
    
    $ git lg
    * c425487 (HEAD -> master) Added about us page dasndksajdnjksa
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page

En este caso hemos cometido un error al escribir el mensaje del ``commit``. Esto claramente se ve mal. Siempre y cuando sea el último ``commit``, podemos arreglarlo con:

.. code-block:: bash

    $ git commit --amend

        Added about us page

    $ git lg
    * c9d0d2a (HEAD -> master) Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page

Al haber ejecutado el comando ``git commit --amend`` nos retorna a un editor de texto en el que podemos editar el mensaje del ``commit``. Notar que el hash del ``commit`` cambiará, pues es otra hora y otro mensaje.

Otro uso de este comando es cuando no hacemos ``commit`` a todo lo que queríamos. Veamos el ejemplo:

.. code-block:: bash

    $ touch contact.html
    $ vi index.html 
    $ cat index.html 
    link to contact us page

    $ git s
    M index.html
    ?? contact.html

    $ git commit -am "Added contact us page"
     [master 7e762db] Added contact us page
     1 file changed, 1 insertion(+)

    $ git s
    ?? contact.html

    $ git lg
    * 7e762db (HEAD -> master) Added contact us page
    * c9d0d2a Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page

    $ git show 7e762db
    commit 7e762dbdca91e202b3bfd3d8461bd68948bf3d58 (HEAD -> master)
    Author: Nombre Apellido <newuser1@mail.com>
    Date:   Wed Jan 1 23:33:41 2020 -0500

        Added contact us page

    diff --git a/index.html b/index.html
    index e69de29..79cfe97 100644
    --- a/index.html
    +++ b/index.html
    @@ -0,0 +1 @@
    +link to contact us page

En este caso, el ``commit -am`` lo ha tomado solo el archivo modificado, pues el otro no ha sido añadido con ``git add``. Nuestro ``commit`` indica que hemos agregado la página de contacto pero esta no está siendo trackeada por Git, como lo indica el estado del repositorio.

Para solucionar esto ejecutaremos:

.. code-block:: bash

    $ git add .
    $ git s
    A  contact.html
    $ git commit --amend
    [master 94ffa02] Added contact us page
     Date: Wed Jan 1 23:33:41 2020 -0500
     2 files changed, 1 insertion(+)
     create mode 100644 contact.html

    Added contact us page

    # Please enter the commit message for your changes. Lines starting
    # with '#' will be ignored, and an empty message aborts the commit.
    #
    # Date:      Wed Jan 1 23:33:41 2020 -0500
    #
    # On branch master
    # Your branch is ahead of 'origin/master' by 2 commits.
    #   (use "git push" to publish your local commits)
    #
    # Changes to be committed:
    #       new file:   contact.html
    #       modified:   index.html

``git commit --amend`` también sirve para agregar un archivo que se nos olvidó poner en el ``commit``.

.. code-block:: bash

    $ git lg
    * 94ffa02 (HEAD -> master) Added contact us page
    * c9d0d2a Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page

    $ git show 94ffa02
    commit 94ffa02184f7d4e69d0086c82f1738507bf507c6 (HEAD -> master)
    Author: Gabriel <newuser1@mail.com>
    Date:   Wed Jan 1 23:33:41 2020 -0500

        Added contact us page

    diff --git a/contact.html b/contact.html
    new file mode 100644
    index 0000000..e69de29
    diff --git a/index.html b/index.html
    index e69de29..79cfe97 100644
    --- a/index.html
    +++ b/index.html
    @@ -0,0 +1 @@
    +link to contact us page

    $ git s
    $

Git reset
---------

Si tenemos un ``commit`` antiguo que debemos arreglar no podemos usar ``git commit --amend`` porque solo funciona en el último ``commit``. Lo que debemos hacer es usar ``git reset``. Veamos los varios modos que tiene este comando, cuándo y cómo usarlos.

Supongamos que estamos desarrollando una página e-commerce:

.. code-block:: bash

    $ touch categories.html categories.css products.html products.css
    $ git s
    ?? categories.css
    ?? categories.html
    ?? products.css
    ?? products.html

Supongamos que como desarrolladores inexpertos decidimos hacer un ``commit`` para las páginas ``html`` y otro para las ``css``:

.. code-block:: bash

    $ git add *.html
    $ git commit -m "Added new pages to the site"
    [master 2079fef] Added new pages to the site
    2 files changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 categories.html
    create mode 100644 products.html

    $ git add .
    $ git commit -m "Styled new pages"
    [master a03eaf5] Styled new pages
    2 files changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 categories.css
    create mode 100644 products.css

    $ git lg
    * a03eaf5 (HEAD -> master) Styled new pages
    * 2079fef Added new pages to the site
    * 94ffa02 Added contact us page
    * c9d0d2a Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page

Esta forma de trabajo no es buena porque no describimos con qué páginas estamos trabajando en los ``commits``. El propósito de ``git reset`` es eliminar ``commits``. Hay 3 niveles de ``git reset``:

1. ``git reset --soft``: deja los archivos del ``commit`` en el staging area para que se les pueda aplicar un ``commit`` nuevamente.
2. ``git reset --hard``: no solo va a eliminar los ``commit``, sino que eliminará todo nuestros archivos involucrados en el ``commit``.
3. ``git reset --mixed`` o ``git reset``: opción por defecto. Elimina los ``commits``, limpia la staging area pero deja los archivos en el directorio de trabajo, para que puedan ser agregados y hacerles ``commit`` nuevamente.

Para este caso que deseamos eliminar los dos últimos commits podemos usar el último caso:

.. code-block:: bash

    $ git reset HEAD~2
    $ git s
    ?? categories.css
    ?? categories.html
    ?? products.css
    ?? products.html

    $ git add ca*
    $ git commit -m "Added categories page"
    [master 8943c44] Added categories page
    2 files changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 categories.css
    create mode 100644 categories.html

    $ git add .
    $ git commit -m "Added products page"
    [master 3d2c3e0] Added products page
    2 files changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 products.css
    create mode 100644 products.html

    $ git lg
    * 3d2c3e0 (HEAD -> master) Added products page
    * 8943c44 Added categories page
    * 94ffa02 Added contact us page
    * c9d0d2a Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page

Si ahora deseamos menos granularidad en los ``commits`` y transformar los últimos dos ``commits`` en uno solo podríamos usar:

.. code-block:: bash

    $ git commit -m "Added e-commerce page"
    [master c1d6629] Added e-commerce page
    4 files changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 categories.css
    create mode 100644 categories.html
    create mode 100644 products.css
    create mode 100644 products.html
    $ git lg
    * c1d6629 (HEAD -> master) Added e-commerce page
    * 94ffa02 Added contact us page
    * c9d0d2a Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page

Si ahora deseamos eliminar todo rastro de trabajo y los ``commits`` usaremos:

.. code-block:: bash

    $ git reset --hard HEAD~1
    HEAD is now at 94ffa02 Added contact us page

    $ ls
    about.html  contact.html  index.html

    $ git lg
    * 94ffa02 (HEAD -> master) Added contact us page
    * c9d0d2a Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home pag

Introducing the reflog
----------------------

Veremos cómo usar reflog para traer archivos de vuelta. Reflog no trabaja en cualquier situación, solo mantiene seguimiento de todas las cosas que hacemos en Git. Si estamos en la misma PC, no hemos corrido el recolector de basura en Git y estamos buscando un cambio de los últimos 30 días podremos usar Reflog para recuperar archivos de vuelta. Veamos un ejemplo:

.. code-block:: bash

    $ git reflog
    94ffa02 (HEAD -> master) HEAD@{0}: reset: moving to HEAD~1
    c1d6629 HEAD@{1}: commit: Added e-commerce page
    94ffa02 (HEAD -> master) HEAD@{2}: reset: moving to HEAD~2
    3d2c3e0 HEAD@{3}: commit: Added products page
    8943c44 HEAD@{4}: commit: Added categories page
    94ffa02 (HEAD -> master) HEAD@{5}: reset: moving to HEAD~2
    a03eaf5 HEAD@{6}: commit: Styled new pages
    2079fef HEAD@{7}: commit: Added new pages to the site
    94ffa02 (HEAD -> master) HEAD@{8}: commit (amend): Added contact us page
    7e762db HEAD@{9}: commit: Added contact us page
    c9d0d2a HEAD@{10}: commit (amend): Added about us page
    c42641d HEAD@{11}: commit (amend): Added about us page
    c425487 HEAD@{12}: commit: Added about us page dasndksajdnjksa
    c76cba8 (origin/master) HEAD@{13}: revert: Revert "Bad idea"
    4e9acd9 HEAD@{14}: commit: Bad idea
    29519be HEAD@{15}: commit (initial): Added home page

Buscaremos el hash del commit que deseemos recuperar, por ejemplo ``c1d6629 HEAD@{1}: commit: Added e-commerce page``, luego:

.. code-block:: bash

    $ git reset --hard c1d6629
    HEAD is now at c1d6629 Added e-commerce page

    $ git lg
    * c1d6629 (HEAD -> master) Added e-commerce page
    * 94ffa02 Added contact us page
    * c9d0d2a Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page

    $ ls
    about.html      categories.html  index.html    products.html
    categories.css  contact.html     products.css

Veremos que tenemos nuestro archivos y el ``commit`` de vuelta. Pero lo hicimos reiniciando ``--hard`` y esta no siempre es una opción.

Veamos cómo recuperar el historial si hemos hecho algunos ``commmits``:

.. code-block:: bash

    $ git reset --hard HEAD~1
    HEAD is now at 94ffa02 Added contact us page

    $ git lg
    * 94ffa02 (HEAD -> master) Added contact us page
    * c9d0d2a Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page

    $ touch test.html
    $ git add .
    $ git commit -m "Added a test file"
    [master 85c090e] Added a test file
    1 file changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 test.html

    $ git lg
    * 85c090e (HEAD -> master) Added a test file
    * 94ffa02 Added contact us page
    * c9d0d2a Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page

Ahora que hemos eliminado la funcionalidad de e-commerce y hemos creado un archivo ``test.html``, si deseamos volver a un punto de la historia donde recuperamos la funcionalidad de e-commerce, perderíamos el archivo ``test.html``. Esto no es conveniente, afortunadamente hay 2 formas de tener el commit de vuelta usando el reflog:

1. Mirar el reflog, copiar el hash del ``commit`` donde agregaba las páginas de e-commerce y usar ``cherry-pick``:

.. code-block:: bash

    $ git reflog
    85c090e (HEAD -> master) HEAD@{0}: commit: Added a test file
    94ffa02 HEAD@{1}: reset: moving to HEAD~1
    c1d6629 HEAD@{2}: reset: moving to c1d6629
    94ffa02 HEAD@{3}: reset: moving to HEAD~1
    c1d6629 HEAD@{4}: commit: Added e-commerce page
    94ffa02 HEAD@{5}: reset: moving to HEAD~2
    3d2c3e0 HEAD@{6}: commit: Added products page
    8943c44 HEAD@{7}: commit: Added categories page
    94ffa02 HEAD@{8}: reset: moving to HEAD~2
    a03eaf5 HEAD@{9}: commit: Styled new pages

    $ git cherry-pick c1d6629
    [master c5631c6] Added e-commerce page
     Date: Thu Jan 2 00:10:44 2020 -0500
     4 files changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 categories.css
     create mode 100644 categories.html
     create mode 100644 products.css
     create mode 100644 products.html

    $ git lg
    * c5631c6 (HEAD -> master) Added e-commerce page
    * 85c090e Added a test file
    * 94ffa02 Added contact us page
    * c9d0d2a Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page

Lo que hará será recuperar las páginas de e-commerce sobre mi trabajo actual sin borrarlo.

Si quisiera múltiples ``commits`` podría usar ``cherry-pick`` en cada uno pero más eficiente será crear un branch:

Borro el el último ``commit`` y hago checkout al punto en el tiempo en que estoy añadiendo las páginas de categories (``8943c44 HEAD@{7}: commit: Added categories page``) y products (``3d2c3e0 HEAD@{6}: commit: Added products page``):

.. code-block:: bash

    $ git reset --hard HEAD~1
    HEAD is now at 85c090e Added a test file
    $ git lg
    * 85c090e (HEAD -> master) Added a test file
    * 94ffa02 Added contact us page
    * c9d0d2a Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page

    $ git checkout 3d2c3e0
    Note: checking out '3d2c3e0'.

    You are in 'detached HEAD' state. You can look around, make experimental
    changes and commit them, and you can discard any commits you make in this
    state without impacting any branches by performing another checkout.

    If you want to create a new branch to retain commits you create, you may
    do so (now or later) by using -b with the checkout command again. Example:

        git checkout -b <new-branch-name>

    HEAD is now at 3d2c3e0 Added products page

Creo un branch en ese punto en el tiempo y puedo hacer merge o rebase con el branch ``master``:

.. code-block:: bash

    $ git checkout -b tmp
    Switched to a new branch 'tmp'
    $ git lg
    * 85c090e (master) Added a test file
    | * 3d2c3e0 (HEAD -> tmp) Added products page
    | * 8943c44 Added categories page
    |/  
    * 94ffa02 Added contact us page
    * c9d0d2a Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page
    $ git checkout tmp
    Already on 'tmp'

    $ git rebase master
    First, rewinding head to replay your work on top of it...
    Applying: Added categories page
    Applying: Added products page

    $ git lg
    * 7c7c945 (HEAD -> tmp) Added products page
    * d2a6ff4 Added categories page
    * 85c090e (master) Added a test file
    * 94ffa02 Added contact us page
    * c9d0d2a Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page

Tengo estos dos ``commits`` de vuelta sin haber perdido los cambios hechos en medio.

Rebase interactive
------------------

Limpiemos el repositorio:

.. code-block:: bash

    $ git checkout master 
    Switched to branch 'master'
    Your branch is ahead of 'origin/master' by 3 commits.
      (use "git push" to publish your local commits)

    $ git merge tmp
    Updating 85c090e..7c7c945
    Fast-forward
     categories.css  | 0
     categories.html | 0
     products.css    | 0
     products.html   | 0
     4 files changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 categories.css
     create mode 100644 categories.html
     create mode 100644 products.css
     create mode 100644 products.html

    $ git branch -d tmp
    Deleted branch tmp (was 7c7c945).
    $ git lg
    * 7c7c945 (HEAD -> master) Added products page
    * d2a6ff4 Added categories page
    * 85c090e Added a test file
    * 94ffa02 Added contact us page
    * c9d0d2a Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page

Imaginemos que hemos estado trabajando en el código por un rato y queremos limpiar el historial antes de hacerle ``push``. Lo que podemos hacer es ver los últimos commits y ejecutar:

.. code-block:: bash

    $ git lg
    * 7c7c945 (HEAD -> master) Added products page
    * d2a6ff4 Added categories page
    * 85c090e Added a test file
    * 94ffa02 Added contact us page
    * c9d0d2a Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page

    $ git rebase -i HEAD~5

    pick c9d0d2a Added about us page
    pick 94ffa02 Added contact us page
    pick 85c090e Added a test file
    pick d2a6ff4 Added categories page
    pick 7c7c945 Added products page

    # Rebase c76cba8..7c7c945 onto c76cba8 (5 commands)
    #
    # Commands:
    # p, pick = use commit
    # r, reword = use commit, but edit the commit message
    # e, edit = use commit, but stop for amending
    # s, squash = use commit, but meld into previous commit
    # f, fixup = like "squash", but discard this commit's log message
    # x, exec = run command (the rest of the line) using shell
    # d, drop = remove commit
    #
    # These lines can be re-ordered; they are executed from top to bottom.
    #
    # If you remove a line here THAT COMMIT WILL BE LOST.
    #
    # However, if you remove everything, the rebase will be aborted.
    #
    # Note that empty commits are commented out

Esto me permitirá realizar una serie de acciones a los ``commits`` seleccionados. Puedo borrarlos, reordenarlos o comprimirlos en menos ``commits``:

.. code-block:: bash

    $ git rebase -i HEAD~5

    pick c9d0d2a Added about us page
    pick 94ffa02 Added contact us page
    f 85c090e Added a test file
    pick d2a6ff4 Added categories page
    pick 7c7c945 Added products page

    $ git lg
    * 6681986 (HEAD -> master) Added products page
    * 7c963d9 Added categories page
    * b5ebb9c Added contact us page
    * c9d0d2a Added about us page
    * c76cba8 (origin/master) Revert "Bad idea"
    * 4e9acd9 Bad idea
    * 29519be Added home page

Vemos que hemos eliminado el ``commit`` de ``test.html``, pues le hemos merge a otro ``commit`` previo.

También podemos volver a redactar el primer ``commit`` y comprimir los demás:

.. code-block:: bash

    $ git rebase -i HEAD~4

    r c9d0d2a Added about us page
    f b5ebb9c Added contact us page
    f 7c963d9 Added categories page
    f 6681986 Added products page
