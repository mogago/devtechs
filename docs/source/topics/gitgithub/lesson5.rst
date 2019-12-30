Lesson 5
========

*Lesson 5: Branching, Merging, Rebasing*

.. contents:: Table of Contents 

Introducing Branching
---------------------

El propósito de un "**branch**" es permitirnos crear una línea independiente de trabajo. Trabajar con "branches" en Git es de forma local. Si chequear otro branch toma más de medio segundo o más, algo está mal probablemente, ya que, es una operación local.

Veamos "branches" en Git:

.. code-block:: bash

    $ git branch
    * master

Esto nos muestra que solo tenemos el "branch" por defecto, llamado ``master``. En Github podemos establecer otro "branches" como nuestro "branch" por defecto.

Generalmente el flujo de trabajo en Git es crear "**feature branches**" cada vez que creamos una nueva característica. Imaginemos que agregamos una característica de buscado a nuestra página web:

.. code-block:: bash

    $ git branch search

    $ git branch
    * master
    search

Hemos creado un nuevo "branch" llamdo ``search``. Podemos cambiar de "branch" con el siguiente comando:

.. code-block:: bash

    $ git checkout search
    Switched to branch 'search'

    $ git branch
    master
    * search

El color verde del nombre del "branch" y el asterisco a su costado nos dice que ahora  estamos en el branch ``search``.

.. code-block:: bash

    $ touch search.html search.css

    $ git add .

    $ git commit -m "Added search page"
    [search 54f68cb] Added search page
    2 files changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 search.css
    create mode 100644 search.html

.. Note::

    Hemos creado un ``commit`` que solo existe en el "branch" ``search``.

Si corremos el alias de log creado anteriormente:

.. code-block:: bash

    $ git lg
    * 54f68cb (HEAD -> search) Added search page
    * c8ee367 (master) Adding special log to show how log output should look
    * 1691860 Modified gitignore to allow special log to be committed
    * 3c8e5e3 Added log files to .gitignore
    * f1ebec7 Deleted stylesheet for contact us page
    * 4702c3a Deleted contact us page
    * 40afaa5 Renamed stylesheet for the home page
    * 57e910e Renamed home page to follow corporate guidelines
    * 4388cdf (origin/master) Added contact us page
    * aa2d60c Added about us page
    * 49ab535 Added home page

.. Tip::

    Debemos leer el log desde abajo hacia arriba.

La primera línea del log nos dice que estamos en el "branch" ``search`` (``HEAD -> search``). ``4388cdf (origin/master) Added contact us page`` es la última vez que hicimos ``push`` hacia el servidor ``origin`` a Github.

Las cosas que tenemos en el directorio de trabajo actual (``HEAD``) es la punta del "branch" ``search``. Y si listamos los archivos veremos:

.. code-block:: bash

    $ ls
    about.css   home.css  search.css   special.log
    about.html  home.htm  search.html  test.log

Si cambiamos de "branch" a ``master``:

.. code-block:: bash

    $ git checkout master
    Switched to branch 'master'
    Your branch is ahead of 'origin/master' by 7 commits.
    (use "git push" to publish your local commits)

Si vemos el directorio, habrá dos archivos menos:

.. code-block:: bash

    $ ls
    about.css  about.html  home.css  home.htm  special.log  test.log

En el log veremos lo siguiente:

.. code-block:: bash

    $ git lg
    * 54f68cb (search) Added search page
    * c8ee367 (HEAD -> master) Adding special log to show how log output should look
    * 1691860 Modified gitignore to allow special log to be committed
    * 3c8e5e3 Added log files to .gitignore
    * f1ebec7 Deleted stylesheet for contact us page
    * 4702c3a Deleted contact us page
    * 40afaa5 Renamed stylesheet for the home page
    * 57e910e Renamed home page to follow corporate guidelines
    * 4388cdf (origin/master) Added contact us page
    * aa2d60c Added about us page
    * 49ab535 Added home page

El log nos dice que estamos en el "branch" ``master`` como indica el texto ``(HEAD, master)``. Además, todo lo que está encima de esta línea no ha ocurrido aún en la historia. Es como si hubiésemos retrocedido en el tiempo o ido u otra línea de historia. Para nosotros todavía no ha ocurrido el trabajo en el "branch" ``serarch``.

Gracias a esto, distintos desarrolladores pueden trabajar al mismo tiempo, sobre diferentes características y luego solo unirlas en ``master`` cuando esté listo para poner el trabajo en producción.


Merging a branch
----------------

Imaginemos que hemos acabado con la página ``search``. Ahora lo que debemos hacer es traer de vuelta el trabajo al "branch" ``master``:

.. code-block:: bash

    $ git checkout master
    Already on 'master'
    Your branch is ahead of 'origin/master' by 7 commits.
    (use "git push" to publish your local commits)

    $ git merge search
    Updating c8ee367..54f68cb
    Fast-forward
    search.css  | 0
    search.html | 0
    2 files changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 search.css
    create mode 100644 search.html

Este comando traerá el trabajo que hemos hecho en el "branch" ``search`` al "branch" ``master``. Y ahora que vemos el directorio de trabajo del "branch" ``master`` tendrá los archivos creados por el "branch" ``search``:

.. code-block:: bash

    $ ls
    about.css   home.css  search.css   special.log
    about.html  home.htm  search.html  test.log

.. code-block:: bash

    $ git lg
    * 54f68cb (HEAD -> master, search) Added search page
    * c8ee367 Adding special log to show how log output should look
    * 1691860 Modified gitignore to allow special log to be committed
    * 3c8e5e3 Added log files to .gitignore
    * f1ebec7 Deleted stylesheet for contact us page
    * 4702c3a Deleted contact us page
    * 40afaa5 Renamed stylesheet for the home page
    * 57e910e Renamed home page to follow corporate guidelines
    * 4388cdf (origin/master) Added contact us page
    * aa2d60c Added about us page
    * 49ab535 Added home page

El log nos muestra que el "branch" ``master`` ha ido "fast forward". Este es el tipo de "merge" que se ha realizado. Tanto el "branch" ``search`` como ``master`` tienen el mismo ID de ``commit``. Es decir, ambos tienen integrada la funcionalidad de ``search``.

Una vez que hemos unido el "branch" ``search`` al "branch" ``master`` ya no necesitamos más al "branch" ``search``. Por lo que podemos eliminarlo:

.. code-block:: bash

    $ git branch -d search
    Deleted branch search (was 54f68cb).

    $ git branch
    * master

    $ git lg
    * 54f68cb (HEAD -> master) Added search page
    * c8ee367 Adding special log to show how log output should look
    * 1691860 Modified gitignore to allow special log to be committed
    * 3c8e5e3 Added log files to .gitignore
    * f1ebec7 Deleted stylesheet for contact us page
    * 4702c3a Deleted contact us page
    * 40afaa5 Renamed stylesheet for the home page
    * 57e910e Renamed home page to follow corporate guidelines
    * 4388cdf (origin/master) Added contact us page
    * aa2d60c Added about us page
    * 49ab535 Added home page

Eliminar el "branch" ``search`` no significa eliminar los archivos o ``commits`` que pasaron en ese "branch" solo eliminamos la etiqueta ``search`` del output del log.

Creating a fast forward merge
-----------------------------

Hay 2 tipos de "**merge**" que Git hará usualmente, aunque existen más: **fast forward** y **recursive**. Veremos estos dos tipos de "merge" y cómo o cuándo usarlos.

- **Fast forward merge**:

La última vez usamos ``git branch {new_branch}`` para crear un nuevo "branch" y luego ``git checkout {new_branch}`` para cambiar al "branch" creado. Una opción para hacer los dos comandos al mismo tiempo es usar:

.. code-block:: bash

    $ git checkout -b categories
    Switched to a new branch 'categories'

    $ git branch
    * categories
    master

Este comando ha creado un nuevo "branch" llamado ``categories`` y ha hecho "checkout" a ese "branch" automáticamente (es decir, hemos cambiado a ese "branch").

.. Tip::

    Buena práctica: crear un nuevo "branch" solo cuando se necesite. No crear varios "branch" que no serán usados próximamente.

Creemos un archivo de prueba y hagamos un ``commit``:

.. code-block:: bash

    $ touch categories.html

    $ git add .

    $ git commit -m "Added categories page"
    [categories e92fcca] Added categories page
    1 file changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 categories.html

Digamos que paralelamente otros estaban trabajando en otro "branch":

.. code-block:: bash

    $ git checkout master
    Switched to branch 'master'
    Your branch is ahead of 'origin/master' by 8 commits.
    (use "git push" to publish your local commits)

    $ git checkout -b products
    Switched to a new branch 'products'

Para crear un nuevo "branch" hemos partido del "branch" ``master`` pues lo estamos tomando como punto inicial.

En ese branch crearemos archivos de prueba:

.. code-block:: bash

    $ touch products.html

    $ git add .

    $ git commit -m "Added products page"
    [products e0b254d] Added products page
    1 file changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 products.html

Veamos el log:

.. code-block:: bash

    $ git lg
    * e0b254d (HEAD -> products) Added products page
    | * e92fcca (categories) Added categories page
    |/  
    * 54f68cb (master) Added search page
    * c8ee367 Adding special log to show how log output should look
    * 1691860 Modified gitignore to allow special log to be committed
    * 3c8e5e3 Added log files to .gitignore
    * f1ebec7 Deleted stylesheet for contact us page
    * 4702c3a Deleted contact us page
    * 40afaa5 Renamed stylesheet for the home page
    * 57e910e Renamed home page to follow corporate guidelines
    * 4388cdf (origin/master) Added contact us page
    * aa2d60c Added about us page
    * 49ab535 Added home page

Interpretemos el log:

- Vemos gráficamente que existe una división del ID ``54f68cb`` en dos partes: ``e92fcca`` y ``e0b254d``.
- A los 3 primeros ``commits`` se le han hecho ``push`` a Github. Las líneas de arriban indican ``commits`` que solo se han hecho localmente en el "branch" ``master``.
- Y en las últimas 2 líneas vemos otros 2 ``commits``: uno en la "branch" ``categories`` y el otro en el "branch" ``products``.

Cuando decidamos que hemos acabado con el desarrollo de ``products`` debemos unirlo ("merge") con el "branch" ``master``. Podemos hacerlo haciendo un "**fast forward merge**".

Hacemos ``checkout`` al "branch" ``master`` y hacemos "merge" del "branch" ``products``. Por defecto se hará un **"merge"  tipo Fast-forward**.

.. code-block:: bash

    $ git checkout master
    Switched to branch 'master'
    Your branch is ahead of 'origin/master' by 8 commits.
    (use "git push" to publish your local commits)

    $ git merge products
    Updating 54f68cb..e0b254d
    Fast-forward
    products.html | 0
    1 file changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 products.html

Como indica el output, se ha realizado un "merge" tipo fast forward. Y el log:

.. code-block:: bash

    $ git lg
    * e0b254d (HEAD -> master, products) Added products page
    | * e92fcca (categories) Added categories page
    |/  
    * 54f68cb Added search page
    * c8ee367 Adding special log to show how log output should look
    * 1691860 Modified gitignore to allow special log to be committed
    * 3c8e5e3 Added log files to .gitignore
    * f1ebec7 Deleted stylesheet for contact us page
    * 4702c3a Deleted contact us page
    * 40afaa5 Renamed stylesheet for the home page
    * 57e910e Renamed home page to follow corporate guidelines
    * 4388cdf (origin/master) Added contact us page
    * aa2d60c Added about us page
    * 49ab535 Added home page

En la primera línea vemos que el "branch" ``master`` ha saltado hacia adelante ("fast forward"), hacia el ``commit`` de ID ``e0b254d``. Es decir, se ha añadido el ``commit`` hecho en el "branch" ``products`` como si fuera parte del "branch" ``master``.

Eliminamos el "branch" ``products``:

.. code-block:: bash

    $ git branch -d products
    Deleted branch products (was e0b254d).

Introducing recursives merges
-----------------------------

- **Recursive merge**:

La razón por la cual pudimos hacer un "merge" ``fast forward`` fue porque no había diferencia en historia. Se puede pretender que los ``commits`` se hicieron directamente el "branch" ``master``, ya que, no habían cambios en este "branch".

En el log actual:

.. code-block:: bash

    $ git lg
    * e0b254d (HEAD -> master) Added products page
    | * e92fcca (categories) Added categories page
    |/  
    * 54f68cb Added search page
    * c8ee367 Adding special log to show how log output should look
    * 1691860 Modified gitignore to allow special log to be committed
    * 3c8e5e3 Added log files to .gitignore
    * f1ebec7 Deleted stylesheet for contact us page
    * 4702c3a Deleted contact us page
    * 40afaa5 Renamed stylesheet for the home page
    * 57e910e Renamed home page to follow corporate guidelines
    * 4388cdf (origin/master) Added contact us page
    * aa2d60c Added about us page
    * 49ab535 Added home page

Vemos que tenemos diferencias en historial de los "branches" ``master`` y ``categories``. El "branch" ``master`` tiene un ``commit`` que ``categories`` no tiene (``e0b254d``) y ``categories`` tiene un ``commit`` que ``master`` no tiene (``e92fcca``).

Para resolver esto, Git tendrá que hacer un "**recursive merge**" , que juntará dos líneas de historia distintas y creará un nuevo ``commit`` que unirá esos 2 trabajos.

Primero comprobemos que estamos en el "branch" ``master``:

.. code-block:: bash

    $ git branch
    categories
    * master

Luego ejecutar el comando ``git merge``. Este comando nos retorna a un editor de texto como ``nano`` donde podemos personalizar el mensaje de ``commit``. Salir del editor y ver el resultado del "merge":

.. code-block:: bash

    $ git merge categories

    Merge made by the 'recursive' strategy.
    categories.html | 0
    1 file changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 categories.html

En el log veremos:

.. code-block:: bash

    $ git lg
    *   3662531 (HEAD -> master) Merge branch 'categories'
    |\  
    | * 44409c8 (categories) Added categories page
    * | 7c5c668 Added products page
    |/  
    * 564baf7 Added search page
    * d71267c Adding special log to show how log output should look
    * 01f02ee Modified gitignore to allow special log to be committed
    * 1b59604 Added log files to .gitignore
    * ced7c37 Deleted stylesheet for contact us page
    * ffaef7d Deleted contact us page
    * 48b8639 Renamed stylesheet for the home page
    * faf6cf4 Renamed home page to follow corporate guidelines
    * 6c2ab19 (origin/master) Added contact us page
    * 49bfaa2 Added about us page
    * eaeaa56 Added home page

Como vemos en el ``commit`` más reciente notamos que se ha hecho un "merge" los cambios hechos en el "branch" ``master`` con los hechos en el "branch" ``categories``.

.. Tip::

    La regla de oro es que si tenemos dos "branches" distintos que tienen al menos un ``commit`` en cada uno, tendremos que hacer un "**recursive merge**".

.. Note::

    Los "recursive merge" nos dan más información en el log que los "fast forward merge". Viendo el log podemos ver los ``commits`` realizados en un "branch" distinto al branch ``master`` en el caso del "recursive merge".

'No fast forward' recursive merges
----------------------------------

Esta idea de agregar la página de ``products`` en un lado y la página de ``categories`` en otra puede resultar confuso. Veremos una forma de realizar "fast forward merges" pero sin la complejidad de ver registros en diferentes tiempos.

Primero eliminar el branch ``categories`` y luego usar el "**no fast forward**" para crear un "recursive mersh".

.. code-block:: bash

    $ git branch -d categories
    Deleted branch categories (was 44409c8).

    $ git lg
    *   3662531 (HEAD -> master) Merge branch 'categories'
    |\  
    | * 44409c8 Added categories page
    * | 7c5c668 Added products page
    |/  
    * 564baf7 Added search page
    * d71267c Adding special log to show how log output should look
    * 01f02ee Modified gitignore to allow special log to be committed
    * 1b59604 Added log files to .gitignore
    * ced7c37 Deleted stylesheet for contact us page
    * ffaef7d Deleted contact us page
    * 48b8639 Renamed stylesheet for the home page
    * faf6cf4 Renamed home page to follow corporate guidelines
    * 6c2ab19 (origin/master) Added contact us page
    * 49bfaa2 Added about us page
    * eaeaa56 Added home page

Ahora creemos una página ``my_account`` con un nuevo "branch" y realicemos algunos ``commits``:

.. code-block:: bash

    $ git checkout -b my_account
    Switched to a new branch 'my_account'

    $ touch account.html
    $ git add .
    $ git commit -m "Added my_account page"
    [my_account 33d2f6e] Added my_account page
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 account.html

    $ touch account.css
    $ git add .
    $ git commit -m "Styled my_account page"
    [my_account 0c3519b] Styled my_account page
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 account.css

Tenemos un historial parecido al anterior:

.. code-block:: bash

    $ git lg
    * 0c3519b (HEAD -> my_account) Styled my_account page
    * 33d2f6e Added my_account page
    *   3662531 (master) Merge branch 'categories'
    |\  
    | * 44409c8 Added categories page
    * | 7c5c668 Added products page
    |/  
    * 564baf7 Added search page
    * d71267c Adding special log to show how log output should look
    * 01f02ee Modified gitignore to allow special log to be committed
    * 1b59604 Added log files to .gitignore
    * ced7c37 Deleted stylesheet for contact us page
    * ffaef7d Deleted contact us page
    * 48b8639 Renamed stylesheet for the home page
    * faf6cf4 Renamed home page to follow corporate guidelines
    * 6c2ab19 (origin/master) Added contact us page
    * 49bfaa2 Added about us page
    * eaeaa56 Added home page

Podemos ver los últimos 2 ``commits`` que solo pertenecen al branch ``my_account``.

Cuando hayamos acabado con la sección ``my_account`` podríamos hacer un "merge" con el branch ``master`` y por defecto hará un "fast forward merge", pues no existen ``commits`` en ``master`` que no formen parte del historial del branch ``my_account``.

Sin embargo, queremos esa información adicional que nos indique que esos dos ``commits`` fueron realizados juntos como parte de un mismo "branch". Para lograr esto ejecutamos:

.. code-block:: bash

    $ git merge --no-ff my_account

    Merge branch 'my_account'

La opción ``--no-ff`` significa "no fast forward" nos permite decirle a Git que preserve la información adicional de los ``commits`` realizados en el "branch". Git puede pretender que estos ``commits`` se realizaron el ``master`` porque no han habido otros cambios, pero le decimos que no lo haga.

Este comando nos retorna a un editor de texto, pues si no es un "fast forward merge", será un "recursive merge", es decir, se necesita un ``commit`` para juntar el historial.

Veamos el log:

.. code-block:: bash

    $ git lg
    *   777cd1a (HEAD -> master) Merge branch 'my_account'
    |\  
    | * 0c3519b (my_account) Styled my_account page
    | * 33d2f6e Added my_account page
    |/  
    *   3662531 Merge branch 'categories'
    |\  
    | * 44409c8 Added categories page
    * | 7c5c668 Added products page
    |/  
    * 564baf7 Added search page
    * d71267c Adding special log to show how log output should look
    * 01f02ee Modified gitignore to allow special log to be committed
    * 1b59604 Added log files to .gitignore
    * ced7c37 Deleted stylesheet for contact us page
    * ffaef7d Deleted contact us page
    * 48b8639 Renamed stylesheet for the home page
    * faf6cf4 Renamed home page to follow corporate guidelines
    * 6c2ab19 (origin/master) Added contact us page
    * 49bfaa2 Added about us page
    * eaeaa56 Added home page

Al ver el log notamos que los ``commits`` con ID ``0c3519b`` y ``33d2f6e`` se realizaron juntos bajo un mismo "branch", aún cuando eliminemos el "branch":

.. code-block:: bash
    :emphasize-lines: 7,8

    $ git branch -d my_account 
    Deleted branch my_account (was 0c3519b).

    $ git lg
    *   777cd1a (HEAD -> master) Merge branch 'my_account'
    |\  
    | * 0c3519b Styled my_account page
    | * 33d2f6e Added my_account page
    |/  
    *   3662531 Merge branch 'categories'
    |\  
    | * 44409c8 Added categories page
    * | 7c5c668 Added products page
    |/  
    * 564baf7 Added search page
    * d71267c Adding special log to show how log output should look
    * 01f02ee Modified gitignore to allow special log to be committed
    * 1b59604 Added log files to .gitignore
    * ced7c37 Deleted stylesheet for contact us page
    * ffaef7d Deleted contact us page
    * 48b8639 Renamed stylesheet for the home page
    * faf6cf4 Renamed home page to follow corporate guidelines
    * 6c2ab19 (origin/master) Added contact us page
    * 49bfaa2 Added about us page
    * eaeaa56 Added home page

Resolving merge conflicts
-------------------------

Creemos un nuevo branch ``cart`` y realicemos ``commit`` con él:

.. code-block:: bash

    $ git checkout -b cartSwitched to a new branch 'cart'

    $ touch cart.html
    $ git add .
    $ git commit -m "Added shopping cart"
    [cart 230d74e] Added shopping cart
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 cart.html

Editemos el archivo ``home.htm`` simulando que creamos un link al shopping cart ``cart.html``:

.. code-block:: bash

    $ vi home.htm

    link to cart

Viendo el estado veremos que ha sido modificado el archivo ``home.htm``:

.. code-block:: bash

    $ git s
     M home.htm

Podemos usar el shortcut para hacer un ``commit`` a archivos modificados:

.. code-block:: bash

    $ git commit -am "Added link on home page to shopping cart"
    
    [cart 7b4c481] Added link on home page to shopping cart
     1 file changed, 1 insertion(+)

Ahora volviendo al branch ``master`` decidimos hacer un rediseño de la página ``home``:

.. Tip::

    No preocuparnos por nombres de "branch" largos, es mejor que este sea descriptivo.

.. code-block:: bash

    $ git checkout master
    Switched to branch 'master'
    Your branch is ahead of 'origin/master' by 14 commits.
      (use "git push" to publish your local commits)


    $ git checkout -b home_page_redisign
    Switched to a new branch 'home_page_redisign'

    $ git branch
      cart
    * home_page_redisign
      master

Desde este branch también editaremos el archivo ``home.htm``:

.. code-block:: bash

    $ vi home.htm

        Company logo
        Links:
        - Products
        - Categories

        Copyright 2014

Luego el estado será de modificado (``M``), por lo que podremos hacer ``commit`` directamente:

.. code-block:: bash

    $ git s
     M home.htm

    $ git commit -am "Implemented home page redesign"
    [home_page_redisign d2276e2] Implemented home page redesign
     1 file changed, 7 insertions(+)

Veamos el log:

.. code-block:: bash
    :emphasize-lines: 2,3,4

    $ git lg
    * d2276e2 (HEAD -> home_page_redisign) Implemented home page redesign
    | * 7b4c481 (cart) Added link on home page to shopping cart
    | * 230d74e Added shopping cart
    |/  
    *   777cd1a (master) Merge branch 'my_account'
    |\  
    | * 0c3519b Styled my_account page
    | * 33d2f6e Added my_account page
    |/  
    *   3662531 Merge branch 'categories'
    |\  
    | * 44409c8 Added categories page
    * | 7c5c668 Added products page
    |/  
    * 564baf7 Added search page
    * d71267c Adding special log to show how log output should look
    * 01f02ee Modified gitignore to allow special log to be committed
    * 1b59604 Added log files to .gitignore
    * ced7c37 Deleted stylesheet for contact us page
    * ffaef7d Deleted contact us page
    * 48b8639 Renamed stylesheet for the home page
    * faf6cf4 Renamed home page to follow corporate guidelines
    * 6c2ab19 (origin/master) Added contact us page
    * 49bfaa2 Added about us page
    * eaeaa56 Added home page

Tenemos una situación en la que se han realizado dos branches distintos con sus respectivos ``commits`` por separado. Ahora digamos que el rediseño de la página web ha finalizado y queremos hacer un merge con el branch ``master``:

.. code-block:: bash

    $ git checkout master
    Switched to branch 'master'
    Your branch is ahead of 'origin/master' by 14 commits.
      (use "git push" to publish your local commits)
    
    
    $ git merge --no-ff home_page_redisign
    
    Merge branch 'home_page_redesign'

    Merge made by the 'recursive' strategy.
     home.htm | 7 +++++++
     1 file changed, 7 insertions(+)

Se realizó un "fast forward merge" usando una estrategia "recursive merge" mediante ``--no-ff``. Ahora podemos eliminar el ``branch``:

.. code-block:: bash

    $ git branch -d home_page_redisign
    Deleted branch home_page_redisign (was d2276e2).

    $ git branch 
      cart
    * master

    $ git lg
    *   2bf9637 (HEAD -> master) Merge branch 'home_page_redesign'
    |\  
    | * d2276e2 Implemented home page redesign
    |/  
    | * 7b4c481 (cart) Added link on home page to shopping cart
    | * 230d74e Added shopping cart
    |/  
    *   777cd1a Merge branch 'my_account'
    |\  
    | * 0c3519b Styled my_account page
    | * 33d2f6e Added my_account page
    |/  
    *   3662531 Merge branch 'categories'
    |\  
    | * 44409c8 Added categories page
    * | 7c5c668 Added products page
    |/  
    * 564baf7 Added search page
    * d71267c Adding special log to show how log output should look
    * 01f02ee Modified gitignore to allow special log to be committed
    * 1b59604 Added log files to .gitignore
    * ced7c37 Deleted stylesheet for contact us page
    * ffaef7d Deleted contact us page
    * 48b8639 Renamed stylesheet for the home page
    * faf6cf4 Renamed home page to follow corporate guidelines
    * 6c2ab19 (origin/master) Added contact us page
    * 49bfaa2 Added about us page
    * eaeaa56 Added home page

Como vemos en el log, la funcionalidad del branch ``cart`` todavía no se le ha realizado un "merge", no existe una línea que vuelva a la izquierda, desde el ``commit`` ``7b4c481`` o ``230d74e``.

Supondremos que ocurrirá un problema porque en los dos branches hemos realizado cambios totalmente distintos a ``home.htm``, por lo que hemos creado deliberadamente una situación de conflicto en el "merge". Veamos que ocurre:

.. code-block:: bash
    
    $ git branch 
      cart
    * master

    $ git merge cart
    Auto-merging home.htm
    CONFLICT (content): Merge conflict in home.htm
    Automatic merge failed; fix conflicts and then commit the result.

Este merge no puede ser tipo "fast forward" porque hay cosas en ``master`` que no están en ``cart`` y hay cosas en ``cart`` que no están en ``master``.

El merge nos da un error al ``Auto-merging`` de ``home.htm``. Git hace un buen trabajo de "merging" automático; por ejemplo, si tenemos un cambio al principio del archivo y otro al final del archivo, Git no dará ningún error. Pero si dos personas hicieron cambios al mismo archivo en las mismas líneas, Git no sabrá que habrás hecho.

.. Tip::

    Para resolver el problema de merge usar ``git status``.

Veamos el estado del repositorio:

.. code-block:: bash

    $ git status

    On branch master
    Your branch is ahead of 'origin/master' by 16 commits.
    (use "git push" to publish your local commits)

    You have unmerged paths.
    (fix conflicts and run "git commit")
    (use "git merge --abort" to abort the merge)

    Changes to be committed:

            new file:   cart.html

    Unmerged paths:
        (use "git add <file>..." to mark resolution)

            both modified:   home.htm

Antes de hacer ``commit`` al archivo indicado debemos arreglar lo indicado en ``Unmerged paths``. Estos podrían ser múltiples archivos. Arreglamos este error de merge en Git y podremos generalizarlo para otros casos donde tengamos varios archivos.

En Git, para resolver un problema de merge solo necesitamos un editor de texto. Por ejemplo con ``vi``:

.. code-block:: bash

    <<<<<<< HEAD
    Company logo

    Links:
    - Products
    - Categories

    Copyright 2014
    =======
    link to cart
    >>>>>>> cart

Vemos que se ha insertado texto adicional al archivo ``home.htm``. ``<<<<<<< HEAD`` (**current change**) indica que en el master branch (``HEAD``) tenemos todo el contenido delimitado hasta el ``=======``, luego de este delimitador tenemos contenido realizado con otro branch indicado por ``>>>>>>> cart`` (**incoming change**). Es decir, tenemos 2 contenidos distintos en el mismo archivo.

Lo que debemos hacer es editar el archivo de forma que se vea como debería:

.. code-block:: bash

    Company logo

    Links:
    - Products
    - Categories
    - Cart

    Copyright 2014

.. Warning::

    Es importante notar que nosotros podríamos editar el archivo como deseemos, agregando o eliminado líneas. Pero NO debemos modificar cosas no relacionadas al branch al cual le estamos haciendo merge, pues en el ``commit`` estaríamos mintiendo.

Una vez hemos guardado los cambios del archivo, revisar el estado:

.. code-block:: bash

    $ git status
    On branch master
    Your branch is ahead of 'origin/master' by 16 commits.
    (use "git push" to publish your local commits)

    You have unmerged paths.
    (fix conflicts and run "git commit")
    (use "git merge --abort" to abort the merge)

    Changes to be committed:

            new file:   cart.html

    Unmerged paths:
        (use "git add <file>..." to mark resolution)

            both modified:   home.htm

Vemos que el estado no ha cambiado. Así que ahora debemos decirle a Git que hemos arreglado el conflicto.

.. code-block:: bash

    $ git add .

    $ git status
    On branch master
    Your branch is ahead of 'origin/master' by 16 commits.
    (use "git push" to publish your local commits)

    All conflicts fixed but you are still merging.
    (use "git commit" to conclude merge)

    Changes to be committed:

            new file:   cart.html
            modified:   home.htm

Para finalizar este merge debemos hacer un ``commit``. No usaremos la opción ``-m`` para ver que nos mande a un editor de texto y ver el mensaje por defecto del ``commit``:

.. code-block:: bash

    Merge branch 'cart'

    # Conflicts:
    #       home.htm
    #
    # It looks like you may be committing a merge.
    # If this is not correct, please remove the file
    #       .git/MERGE_HEAD
    # and try again.


    # Please enter the commit message for your changes. Lines starting
    # with '#' will be ignored, and an empty message aborts the commit.
    #
    # On branch master
    # Your branch is ahead of 'origin/master' by 16 commits.
    #   (use "git push" to publish your local commits)
    #
    # All conflicts fixed but you are still merging.
    #
    # Changes to be committed:
    #       new file:   cart.html
    #       modified:   home.htm
    #

Vemos que la primera línea es el mensaje de ``commit`` tradicional al hacer merge pero también tenemos información de los archivos en los que hubieron conflictos (``home.htm``). Podemos agregar información adicional a este mensaje:

.. code-block:: bash

    Merge branch 'cart'
    
    Conflicts:     
            home.htm

    Conflict in home.html between link to cart and new page design. Make link match the new page redesign and saved.

    $ git commit
    [master 82ae112] Merge branch 'cart'

Guardemos el mensaje de ``commit`` y vemos el log:

.. code-block:: bash

    $ git lg
    *   82ae112 (HEAD -> master) Merge branch 'cart'
    |\  
    | * 7b4c481 (cart) Added link on home page to shopping cart
    | * 230d74e Added shopping cart
    * |   2bf9637 Merge branch 'home_page_redesign'
    |\ \  
    | |/  
    |/|   
    | * d2276e2 Implemented home page redesign
    |/  
    *   777cd1a Merge branch 'my_account'
    |\  
    | * 0c3519b Styled my_account page
    | * 33d2f6e Added my_account page
    |/  
    *   3662531 Merge branch 'categories'
    |\  
    | * 44409c8 Added categories page
    * | 7c5c668 Added products page
    |/  
    * 564baf7 Added search page
    * d71267c Adding special log to show how log output should look
    * 01f02ee Modified gitignore to allow special log to be committed
    * 1b59604 Added log files to .gitignore
    * ced7c37 Deleted stylesheet for contact us page
    * ffaef7d Deleted contact us page
    * 48b8639 Renamed stylesheet for the home page
    * faf6cf4 Renamed home page to follow corporate guidelines
    * 6c2ab19 (origin/master) Added contact us page
    * 49bfaa2 Added about us page
    * eaeaa56 Added home page

Comprobamos que tenemos un ``commit`` con el merge al branch de ``cart``. Finalmente eliminamos este branch:

.. code-block:: bash

    $ git branch -d cart
    Deleted branch cart (was 7b4c481).

    $ git lg
    *   82ae112 (HEAD -> master) Merge branch 'cart'
    |\  
    | * 7b4c481 Added link on home page to shopping cart
    | * 230d74e Added shopping cart
    * |   2bf9637 Merge branch 'home_page_redesign'
    |\ \  
    | |/  
    |/|   
    | * d2276e2 Implemented home page redesign
    |/  
    *   777cd1a Merge branch 'my_account'

Another merge conflict example
------------------------------

Veamos otro ejemplo de conflicto con merges. Creemos una página de ``checkout`` con un nuevo branch:

.. code-block:: bash

    $ git checkout -b checkout_page
    Switched to a new branch 'checkout_page'

    $ touch checkout.html
    $ git add .
    $ git commit -m "Added checkout page"
    [checkout_page a1b7834] Added checkout page
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 checkout.html

Simulemos la creación de un link a esta página creada desde el home:

.. code-block:: bash

    $ vi home.htm

        Company logo

        Links:
        - Products
        - Categories
        - Cart
        - Checkout

        Copyright 2014

Luego hagamos un ``commit``:

.. code-block:: bash

    $ git commit -am "Added link to checkout page"
    [checkout_page 048ec79] Added link to checkout page
     1 file changed, 1 insertion(+)

Volver al branch ``master``:

.. code-block:: bash

    $ git checkout master Switched to branch 'master'
    Your branch is ahead of 'origin/master' by 19 commits.
      (use "git push" to publish your local commits)

Veamos el contenido del archivo ``home.htm``, comprobando que no se han registrado los cambios hechos con el branch ``checkout``.

.. code-block:: bash

    $ cat home.htm 
        Company logo

        Links:
        - Products
        - Categories
        - Cart

        Copyright 2014

Añadir un nuevo branch ``add_home_page_links`` y editemos el archivo:

.. code-block:: bash

    $ git checkout -b add_home_page_links
    Switched to a new branch 'add_home_page_links'

    $ vi home.htm

        Company logo

        Links:
        - Products
        - Categories
        - Cart
        - About
        - My Account

        Copyright 2014
    
    $ git commit -am "Added new links to the home page"
    [add_home_page_links d044e8e] Added new links to the home page
     1 file changed, 2 insertions(+)

Hemos creado una situación que presentará un conflicto cuando intentemos hacer un merge, pues hemos editado el mismo archivo con dos branches distintos.

Regresemos al branch ``master`` y hagamos merge con el branch ``add_home_page_links``, posteriormente borremos este branch:

.. code-block:: bash

    $ git checkout master
    Switched to branch 'master'
    Your branch is ahead of 'origin/master' by 19 commits.
      (use "git push" to publish your local commits)
    
    $ git merge --no-ff add_home_page_links
    Merge branch 'add_home_page_links'

    Merge made by the 'recursive' strategy.
     home.htm | 2 ++
     1 file changed, 2 insertions(+)

    $ git branch -d add_home_page_links
    Deleted branch add_home_page_links (was d044e8e).

Veamos el log para comprobar que el trabajo hecho con el branch ``add_home_page_links`` se ha unido con el branch ``master`` mediante merge:

.. code-block:: bash

    $ git lg
    *   c3f3863 (HEAD -> master) Merge branch 'add_home_page_links'
    |\  
    | * d044e8e Added new links to the home page
    |/  
    | * 048ec79 (checkout_page) Added link to checkout page
    | * a1b7834 Added checkout page
    |/  
    *   82ae112 Merge branch 'cart'
    |\  
    | * 7b4c481 Added link on home page to shopping cart
    | * 230d74e Added shopping cart
    * |   2bf9637 Merge branch 'home_page_redesign'
    |\ \  
    | |/  
    |/|   
    | * d2276e2 Implemented home page redesign
    |/  
    *   777cd1a Merge branch 'my_account'

Lo siguiente será hacer un merge del branch ``checkout`` con el ``master``. Es aquí donde obtendremos un conflicto:

.. code-block:: bash

    $ git merge checkout_page
    Auto-merging home.htm
    CONFLICT (content): Merge conflict in home.htm
    Automatic merge failed; fix conflicts and then commit the result.

Veamos ``home.htm`` para resolver el conflicto:

.. code-block:: bash

    $ vi home.htm

        Company logo

        Links:
        - Products
        - Categories
        - Cart
        <<<<<<< HEAD
        - About
        - My Account
        =======
        - Checkout
        >>>>>>> checkout_page

        Copyright 2014

En ambos lados del historial tenemos las líneas del logo y copyright, pero en el ``HEAD`` (merge con ``master`` branch) tenemos links ``About`` y ``My Account``. Mientras que en ``>>>>>>> checkout_page`` tenemos un link a ``Checkout``. Git no sabe qué hacer ni el orden en que debería posicionar los elementos si todos deberían estar. Por lo tanto, es nuestra labor editar el contenido según deseemos con nuestro editor:

.. code-block:: bash

    $ vi home.htm

        Company logo
        
        Links:
        - Products
        - Categories
        - Cart
        - About
        - My Account
        - Checkout

        Copyright 2014

.. Tip::

    Algunos editores como Visual Studio Code proveen funcionalidad adicionales para realizar acciones sobre estos archivos con conflicto.

    .. figure:: images/lesson5/visual-studio-code-git-conflict.png
        :align: center

        Visual Studio Code - Git Conflicts

Guardar los cambios del archivo editado y ver el estado del repo con los conflictos todavía presentes:

.. code-block:: bash

    $ git status
    On branch master
    Your branch is ahead of 'origin/master' by 21 commits.
    (use "git push" to publish your local commits)

    You have unmerged paths.
    (fix conflicts and run "git commit")
    (use "git merge --abort" to abort the merge)

    Changes to be committed:

            new file:   checkout.html

    Unmerged paths:
    (use "git add <file>..." to mark resolution)

            both modified:   home.htm

Ahora podemos resolver el conflicto en Git añadiendo y haciendo un ``commit``:

.. code-block:: bash

    $ git add .
    $ git status
    On branch master
    Your branch is ahead of 'origin/master' by 21 commits.
    (use "git push" to publish your local commits)

    All conflicts fixed but you are still merging.
    (use "git commit" to conclude merge)

    Changes to be committed:

            new file:   checkout.html
            modified:   home.htm

    $ git commit

        Merge branch 'checkout_page'

        # Conflicts:
        #       home.htm

    [master 064b2c7] Merge branch 'checkout_page'

Veamos el log para comprobar que hemos realizado un merge del trabajo realizado en ``checkout_page`` al ``master`` branch:

.. code-block:: bash

    $ git lg
    *   064b2c7 (HEAD -> master) Merge branch 'checkout_page'
    |\  
    | * 048ec79 (checkout_page) Added link to checkout page
    | * a1b7834 Added checkout page
    * |   c3f3863 Merge branch 'add_home_page_links'
    |\ \  
    | |/  
    |/|   
    | * d044e8e Added new links to the home page
    |/  
    *   82ae112 Merge branch 'cart'
    |\  
    | * 7b4c481 Added link on home page to shopping cart
    | * 230d74e Added shopping cart
    * |   2bf9637 Merge branch 'home_page_redesign'
    |\ \  
    | |/  
    |/|   
    | * d2276e2 Implemented home page redesign
    |/  
    *   777cd1a Merge branch 'my_account'

Eliminemos el branch ``checkout_page``:

.. code-block:: bash

    $ git branch -d checkout_page 
    Deleted branch checkout_page (was 048ec79).

    $ git lg
    *   064b2c7 (HEAD -> master) Merge branch 'checkout_page'
    |\  
    | * 048ec79 Added link to checkout page
    | * a1b7834 Added checkout page
    * |   c3f3863 Merge branch 'add_home_page_links'
    |\ \  
    | |/  
    |/|   
    | * d044e8e Added new links to the home page
    |/  
    *   82ae112 Merge branch 'cart'
    |\  
    | * 7b4c481 Added link on home page to shopping cart
    | * 230d74e Added shopping cart
    * |   2bf9637 Merge branch 'home_page_redesign'
    |\ \  
    | |/  
    |/|   
    | * d2276e2 Implemented home page redesign
    |/  
    *   777cd1a Merge branch 'my_account'

Git Diff
--------

``git diff`` nos permite ver las diferencias. Con el comando ``git help`` veremos las posibilidades y opciones del comando:

.. code-block:: bash

    $ git help diff 

Hagamos un par de cambios con el ``master`` branch:

.. code-block:: bash

    $ vi home.htm

        Company logo
        
        Links:
        - Products
        - Categories
        - Cart
        - About
        - History
        - My Account

        Copyright 2014

Si vemos el estado del repo, comprobaremos que existe un archivo modificado:

.. code-block:: bash

    $ git s
     M home.htm

¿Pero cual es la modificación de ese archivo?: es para esto que sirve ``git diff``

.. code-block:: bash
    :emphasize-lines: 3-7,11,13

    $ git diff

    diff --git a/home.htm b/home.htm
    index afd16cf..1fdd419 100644
    --- a/home.htm
    +++ b/home.htm
    @@ -5,7 +5,7 @@ Links:
    - Categories
    - Cart
    - About
    +- History
    - My Account
    -- Checkout
    
    Copyright 2014

Veremos que hemos agregado una línea para '- History' (``+``) y hemos eliminado una línea para '- Checkout' (``-``).

Pasemos este cambio a 'staged area'. Y veamos el resultado del comando ``git diff``:

.. code-block:: bash

    $ git add .

    $ git diff

    $

``git diff`` no nos muestra nada pues, solo muestra diferencias de cambios 'unstaged' por defecto.

Para ver los cambios 'staged' debemos agregar un parámetro:

.. code-block:: bash

    $ git diff --staged

    diff --git a/home.htm b/home.htm
    index afd16cf..1fdd419 100644
    --- a/home.htm
    +++ b/home.htm
    @@ -5,7 +5,7 @@ Links:
    - Categories
    - Cart
    - About
    +- History
    - My Account
    -- Checkout
    
    Copyright 2014

Con ``git diff HEAD`` veremos las diferencias con el directorio actual y el último ``commit`` realizado.

.. code-block:: bash

    $ git diff HEAD

    diff --git a/home.htm b/home.htm
    index afd16cf..1fdd419 100644
    --- a/home.htm
    +++ b/home.htm
    @@ -5,7 +5,7 @@ Links:
    - Categories
    - Cart
    - About
    +- History
    - My Account
    -- Checkout
    
    Copyright 2014

Ahora hagamos otros cambios:

.. code-block:: bash

    Company logo
    
    Links:
    - About
    - History
    - My Account

    Copyright 2014

Veamos el estado:

.. code-block:: bash

    $ git s
    MM home.htm

Esto nos dice que podemos tener cambios 'staged' y 'unstaged' del mismo archivo. Si corrieramos ``git commit`` cómo encontramos qué cambiaría, veamos las tres posibilidades:

.. code-block:: bash

    $ git diff --staged
    diff --git a/home.htm b/home.htm
    index afd16cf..1fdd419 100644
    --- a/home.htm
    +++ b/home.htm
    @@ -5,7 +5,7 @@ Links:
    - Categories
    - Cart
    - About
    +- History
    - My Account
    -- Checkout
    
    Copyright 2014

 
    $ git diff
    diff --git a/home.htm b/home.htm
    index 1fdd419..516fd1f 100644
    --- a/home.htm
    +++ b/home.htm
    @@ -1,9 +1,6 @@
    Company logo
    
    Links:
    -- Products
    -- Categories
    -- Cart
    - About
    - History
    - My Account

    $ git diff HEAD
    diff --git a/home.htm b/home.htm
    index afd16cf..516fd1f 100644
    --- a/home.htm
    +++ b/home.htm
    @@ -1,11 +1,8 @@
    Company logo
    
    Links:
    -- Products
    -- Categories
    -- Cart
    - About
    +- History
    - My Account
    -- Checkout
    
    Copyright 2014

- ``git diff --staged`` nos mostrará todas las diferencias que han sido añadidas al 'staged area'.
- ``git diff`` nos mostrará los cambios que no han sido añadidos al 'staged area'.
- ``git diff HEAD`` nos mostrará todos los cambios hechos desde el último ``commit`` al historial. Esto es lo que ocurrirá si añadimos y hacemos ``commit`` de todos los cambios.

.. code-block:: bash

    $ git add .
    $ git commit -m "Changed the home page links"
    [master 51975c0] Changed the home page links
     1 file changed, 1 insertion(+), 4 deletions(-)
    
.. Note::

    ``git diff --staged``, ``git diff`` y ``git diff HEAD`` son 3 comandos comúnes usados con ``git diff`` para ver qué pasará antes de hacer ``commit`` a los cambios.

Introducing rebasing
--------------------

Rebasing es una herramienta intermedia que no es imprescindible para un buen uso de Git. Es usada para mejorar la calidad de la experiencia cuando colaboramos con otras personas.

.. Note::

    En Git hay dos comandos que usan la palabra ``rebase`` pero son totalmente diferentes: ``git rebase`` y ``git rebase -i``. Debemos tratarlos como cosas diferentes que resulven problemas distintos. ``git rebase -i`` o "git rebase interfactive" se enfoca en reescribir y limpiar el historial, cambiar el orden de ``commits``, comprimir ``commits``. En cambio ``git rebase`` también sirve para limpiar el historial pero de una manera muy diferente.

Cuando el historial se vuelve muy complejo de leer (viendo el log), debemos considerar usar ``rebase``.

.. Note::

    ¿Debería usar ``rebase`` o ``merge``?:
    Usarás merge, la única pregunta será ¿harás un ``rebase`` primero?

Hacer un ``rebase``, equivale a decir cambiar la base o cambiar el punto inicial de ese branch antes de hacerle merge.

Rebasing a branch
-----------------

Creemos una situación en la que veamos el valor de 'rebasing'. Para esto crearemos 2 branches (``feature1`` y ``feature2``):

.. code-block:: bash

    $ git checkout -b feature1
    Switched to a new branch 'feature1'

    $ touch feature1.html
    $ git add .
    $ git commit -m "Added feature 1"
    [feature1 1e1bb9a] Added feature 1
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 feature1.html

    $ git checkout master
    Switched to branch 'master'
    Your branch is ahead of 'origin/master' by 25 commits.
    (use "git push" to publish your local commits)

    $ git checkout -b feature2
    Switched to a new branch 'feature2'

    $ touch feature2.html
    $ git add .
    $ git commit -m "Added feature 2"
    [feature2 b1c8223] Added feature 2
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 feature2.html

Acabamos en una situación con dos branches y un ``commit`` en cada uno:

.. code-block:: bash
    :emphasize-lines: 2,3

    $ git lg
    * b1c8223 (HEAD -> feature2) Added feature 2
    | * 1e1bb9a (feature1) Added feature 1
    |/  
    * 51975c0 (master) Changed the home page links
    *   064b2c7 Merge branch 'checkout_page'
    |\  
    | * 048ec79 Added link to checkout page
    | * a1b7834 Added checkout page
    * |   c3f3863 Merge branch 'add_home_page_links'
    |\ \  
    | |/  
    |/|   
    | * d044e8e Added new links to the home page
    |/  
    *   82ae112 Merge branch 'cart'
    |\  
    | * 7b4c481 Added link on home page to shopping cart
    | * 230d74e Added shopping cart
    * |   2bf9637 Merge branch 'home_page_redesign'
    |\ \  
    | |/  
    |/|   
    | * d2276e2 Implemented home page redesign
    |/  
    *   777cd1a Merge branch 'my_account'

Una vez que hemos acabado de desarrollar esos features queremos hacerles merge. Hagamos merge del branch ``feature1`` que será tipo recursive:

.. code-block:: bash

    $ git checkout master
    Switched to branch 'master'
    Your branch is ahead of 'origin/master' by 25 commits.
      (use "git push" to publish your local commits)

    $ git merge --no-ff feature1
    Merge branch 'feature1'

    Merge made by the 'recursive' strategy.
     feature1.html | 0
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 feature1.html

    $ git branch -d feature1
    Deleted branch feature1 (was 1e1bb9a).

Viendo el log comprobamos que hemos hecho merge de ``feature1`` en el ``master`` branch:

.. code-block:: bash

    $  git lg
    *   cdbc4aa (HEAD -> master) Merge branch 'feature1'
    |\  
    | * 1e1bb9a Added feature 1
    |/  
    | * b1c8223 (feature2) Added feature 2
    |/  
    * 51975c0 Changed the home page links
    *   064b2c7 Merge branch 'checkout_page'

Podríamos volver a hacer lo que hicimos antes: asegurarnos que estamos en el branch ``master`` y hacer merge de ``feature2``, esto funcionaría pero no se verá bien conforme el proyecto sea más grande.

Ahora haremos un rebase de ``feature2``. Esto significa que cambiaremos la base o el punto inicial de ``feature2``. Pretendremos que no comenzamos a trabajar en ``feature2`` hasta después que se hizo un merge de ``feature1`` satisfactoriamente. Esto facilitará el orden de lectura de desarrollo de trabajo.

Viendo nuevamente el log notamos que ``feature2`` tiene una base identificada con el ID ``51975c0``:

.. code-block:: bash
    :emphasize-lines: 8

    $  git lg
    *   cdbc4aa (HEAD -> master) Merge branch 'feature1'
    |\  
    | * 1e1bb9a Added feature 1
    |/  
    | * b1c8223 (feature2) Added feature 2
    |/  
    * 51975c0 Changed the home page links
    *   064b2c7 Merge branch 'checkout_page'

Deberemos hacer un rebase hacia el ``HEAD`` de ``master``, con punto inicial o base el ID ``cdbc4aa``. Para esto haremos checkout a ``feature2``, luego rebase a ``master`` y deshará cualquier trabajo que hayamos hecho en el branch ``feature2``, irá al ``HEAD`` de ``master`` y volverá a hacer el trabajo como si hubiera escrito el código recién:

.. code-block:: bash

    $ git checkout feature2 
    Switched to branch 'feature2'

    $ git rebase master
    First, rewinding head to replay your work on top of it...
    Applying: Added feature 2

    $ git lg
    * 9baf6a2 (HEAD -> feature2) Added feature 2
    *   cdbc4aa (master) Merge branch 'feature1'
    |\  
    | * 1e1bb9a Added feature 1
    |/  
    * 51975c0 Changed the home page links
    *   064b2c7 Merge branch 'checkout_page'

En el log comprobamos que ahora se ve como si no se hubiera trabajo en el branch ``feature2`` hasta que se hizo el merge de ``feature1``. Lo que sigue es hacerle merge hacia el ``master``:

.. code-block:: bash

    $ git checkout master
    Switched to branch 'master'
    Your branch is ahead of 'origin/master' by 27 commits.
      (use "git push" to publish your local commits)
    
    $ git merge --no-ff feature2 
    Merge made by the 'recursive' strategy.
     feature2.html | 0
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 feature2.html

    Merge branch 'feature2'

    $ git lg
    *   08875c4 (HEAD -> master) Merge branch 'feature2'
    |\  
    | * 9baf6a2 (feature2) Added feature 2
    |/  
    *   cdbc4aa Merge branch 'feature1'
    |\  
    | * 1e1bb9a Added feature 1
    |/  
    * 51975c0 Changed the home page links
    *   064b2c7 Merge branch 'checkout_page'

    $ git branch -d feature2 
    Deleted branch feature2 (was 9baf6a2).

Ahora se ve como si hubiésemos trabajado en ``feature1``, le hicimos merge y cuando acabamos trabajamos en ``feature2``.

El otro beneficio es que nos permite realizar todas nuestras pruebas de integración en nuestro branches de ``feature`` antes de hacer hacerle merge en el ``master``.

Handling rebase conflicts
-------------------------

Hemos visto conflicto con merge, ¿cómo será un conflicto con rebase?. Creemos un caso:

.. code-block:: bash

    $ git checkout -b feature3
    Switched to a new branch 'feature3'

    $ touch feature3.html
    $ git add .
    $ git commit -m "Added feature 3"
    [feature3 4d5f561] Added feature 3
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 feature3.html

    $ vi home.htm

        Company logo
    
        Links:
        - About
        - History
        - My Account
        - Feature 3

        Copyright 2014

Veamos el estado y hagamos un ``commit``:
    
.. code-block:: bash

    $ git s
     M home.htm
    
    $ git commit -am "Added link to feature 3"
    [feature3 07866ad] Added link to feature 3
     1 file changed, 1 insertion(+)
    
Para crear el conflicto haremos lo mismo con ``feature4``:


.. code-block:: bash

    $ git checkout master Switched to branch 'master'
    Your branch is ahead of 'origin/master' by 29 commits.
      (use "git push" to publish your local commits)

    $ git checkout -b feature4
    Switched to a new branch 'feature4'

    $ touch feature4.html

    $ git add .

    $ git commit -m "Added feature 4"
    [feature4 411e7b2] Added feature 4
     1 file changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 feature4.html
    
    $ vi home.htm

        Company logo
    
        Links:
        - About
        - History
        - My Account
        - Feature 4

        Copyright 2014
    
    $ git commit -am "Added link to feature 4"
    [feature4 df7ff8c] Added link to feature 4
     1 file changed, 1 insertion(+)
    
Hemos creado 2 features que harán conflicto, veamos el log:

.. code-block:: bash

    $ git lg
    * df7ff8c (HEAD -> feature4) Added link to feature 4
    * 411e7b2 Added feature 4
    | * 07866ad (feature3) Added link to feature 3
    | * 4d5f561 Added feature 3
    |/  
    *   08875c4 (master) Merge branch 'feature2'
    |\  
    | * 9baf6a2 Added feature 2
    |/  
    *   cdbc4aa Merge branch 'feature1'
    |\  
    | * 1e1bb9a Added feature 1
    |/  
    * 51975c0 Changed the home page links
    *   064b2c7 Merge branch 'checkout_page'

Una vez que hayamos acabado con ``feature3`` le haremos merge y luego rebase de ``feature4`` y resolveremos el conflicto.

.. code-block:: bash

    $ git checkout master
    Switched to branch 'master'
    Your branch is ahead of 'origin/master' by 29 commits.
      (use "git push" to publish your local commits)
    
    $ git merge --no-ff feature3

    Merge branch 'feature3'

    Merge made by the 'recursive' strategy.
     feature3.html | 0
     home.htm      | 1 +
     2 files changed, 1 insertion(+)
     create mode 100644 feature3.html
    
    $ git branch -d feature3
    Deleted branch feature3 (was 07866ad).

    $ git lg
    *   e59b16c (HEAD -> master) Merge branch 'feature3'
    |\  
    | * 07866ad Added link to feature 3
    | * 4d5f561 Added feature 3
    |/  
    | * df7ff8c (feature4) Added link to feature 4
    | * 411e7b2 Added feature 4
    |/  
    *   08875c4 Merge branch 'feature2'
    |\  
    | * 9baf6a2 Added feature 2
    |/  
    *   cdbc4aa Merge branch 'feature1'
    |\  
    | * 1e1bb9a Added feature 1
    |/  
    * 51975c0 Changed the home page links
    *   064b2c7 Merge branch 'checkout_page'

Viendo el log vemos que habrá un conflicto en ``df7ff8c``. La única pregunta será si es un conflicto de merge o de rebase. Lo bueno es que realmente no importa de qué tipo es, pues los resolvemos de la misma forma.

Hagamos el rebase de ``feature4`` para tener un orden en la construcción de los 4 features en el historial.

.. code-block:: bash

    $ git checkout feature4
    Switched to branch 'feature4'

    $ git rebase master 
    First, rewinding head to replay your work on top of it...
    Applying: Added feature 4
    Applying: Added link to feature 4
    Using index info to reconstruct a base tree...
    M       home.htm
    Falling back to patching base and 3-way merge...
    Auto-merging home.htm
    CONFLICT (content): Merge conflict in home.htm
    error: Failed to merge in the changes.
    Patch failed at 0002 Added link to feature 4
    Use 'git am --show-current-patch' to see the failed patch

    Resolve all conflicts manually, mark them as resolved with
    "git add/rm <conflicted_files>", then run "git rebase --continue".
    You can instead skip this commit: run "git rebase --skip".
    To abort and get back to the state before "git rebase", run "git rebase --abort".

Esta vez hemos encontrado un conflicto, similar al de merge. El mensaje nos dice que una vez arreglemos el conflicto, corramos ``git rebase --continue``. ``git status`` nos dirá qué hacer:

.. code-block:: bash

    $ git status
    rebase in progress; onto e59b16c
    You are currently rebasing branch 'feature4' on 'e59b16c'.
    (fix conflicts and then run "git rebase --continue")
    (use "git rebase --skip" to skip this patch)
    (use "git rebase --abort" to check out the original branch)

    Unmerged paths:
    (use "git reset HEAD <file>..." to unstage)
    (use "git add <file>..." to mark resolution)

            both modified:   home.htm

    no changes added to commit (use "git add" and/or "git commit -a")

El estado nos indica que estamos en medio de un rebase de ``e59b16c``, y debemos arreglar el archivo ``home.htm``. Veamos el log:

.. code-block:: bash

    $ git lg
    * 7eda1d6 (HEAD) Added feature 4
    *   e59b16c (master) Merge branch 'feature3'
    |\  
    | * 07866ad Added link to feature 3
    | * 4d5f561 Added feature 3
    |/  
    | * df7ff8c (feature4) Added link to feature 4
    | * 411e7b2 Added feature 4
    |/  
    *   08875c4 Merge branch 'feature2'
    |\  
    | * 9baf6a2 Added feature 2
    |/  
    *   cdbc4aa Merge branch 'feature1'
    |\  
    | * 1e1bb9a Added feature 1
    |/  
    * 51975c0 Changed the home page links
    *   064b2c7 Merge branch 'checkout_page'

Veremos el mismo commit 2 veces: ``7eda1d6`` y ``df7ff8c``: Added feature 4. Una vez que resolvamos el conflicto, finalizará el rebase y eliminará los commits sobrantes.

Arreglémoslo igual que un conflicto de merge, excepto que veremos una diferencia en el archivo conflictivo. Ahora no veremos el nombre del branch sino con un commit específico que está dando conflicto:

.. code-block:: bash

    $ cat home.htm

        Company logo
        
        Links:
        - About
        - History
        - My Account
        <<<<<<< HEAD
        - Feature 3
        =======
        - Feature 4
        >>>>>>> Added link to feature 4

        Copyright 2014
    
    $ vi home.htm
        
        Company logo
        
        Links:
        - About
        - History
        - My Account
        - Feature 3
        - Feature 4

        Copyright 2014
    
    $ git add .

    $ git status
    rebase in progress; onto e59b16c
    You are currently rebasing branch 'feature4' on 'e59b16c'.
    (all conflicts fixed: run "git rebase --continue")

    Changes to be committed:
    (use "git reset HEAD <file>..." to unstage)

            modified:   home.htm
    
El estado nos dice que se han arreglado todos los conflictos y solo corramos el siguiente comando:

.. code-block:: bash

    $ git rebase --continue
    Applying: Added link to feature 4

    $ git lg
    * 5f75f25 (HEAD -> feature4) Added link to feature 4
    * 7eda1d6 Added feature 4
    *   e59b16c (master) Merge branch 'feature3'
    |\  
    | * 07866ad Added link to feature 3
    | * 4d5f561 Added feature 3
    |/  
    *   08875c4 Merge branch 'feature2'
    |\  
    | * 9baf6a2 Added feature 2
    |/  
    *   cdbc4aa Merge branch 'feature1'
    |\  
    | * 1e1bb9a Added feature 1
    |/  
    * 51975c0 Changed the home page links
    *   064b2c7 Merge branch 'checkout_page'

Hemos hecho un rebase de ``feature4`` sobre el ``master`` y solo nos quedaría hacer merge:

.. code-block:: bash

    $ git checkout master Switched to branch 'master'
    Your branch is ahead of 'origin/master' by 32 commits.
      (use "git push" to publish your local commits)

    $ git merge --no-ff feature4
    Merge branch 'feature4'

    Merge made by the 'recursive' strategy.
     feature4.html | 0
     home.htm      | 1 +
     2 files changed, 1 insertion(+)
     create mode 100644 feature4.html

    $ git branch -d feature4 
    Deleted branch feature4 (was 5f75f25).

    $ git lg
    *   d0ade3c (HEAD -> master) Merge branch 'feature4'
    |\  
    | * 5f75f25 Added link to feature 4
    | * 7eda1d6 Added feature 4
    |/  
    *   e59b16c Merge branch 'feature3'
    |\  
    | * 07866ad Added link to feature 3
    | * 4d5f561 Added feature 3
    |/  
    *   08875c4 Merge branch 'feature2'
    |\  
    | * 9baf6a2 Added feature 2
    |/  
    *   cdbc4aa Merge branch 'feature1'
    |\  
    | * 1e1bb9a Added feature 1
    |/  
    * 51975c0 Changed the home page links
    *   064b2c7 Merge branch 'checkout_page'

Vemos que el historial está limpio y es linear en la construcción de ``feature1``, ``feature2``, ``feature3`` y ``feature4``.