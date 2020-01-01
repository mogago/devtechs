Lesson 8
========

*Lesson 8: Reviewing a Project on GitHub*

.. contents:: Table of Contents 

Getting an overview of a project on GitHub using the README
-----------------------------------------------------------

Veamos la forma recomendada de ver un repositorio en GitHub. Por ejemplo el `repositorio de Ruby on Rails <https://github.com/rails/rails>`__.

Si fuese un proyecto que nunca hemos visto antes, primero deberíamos leer el archivo ``README.md``. Aquí encontraremos información general del proyecto.

En la descripción podemos usar medallas (badges) en el archivo README.md. Por ejemplo en código markdown:

.. code-block:: md

    [![Build Status](https://badge.buildkite.com/ab1152b6a1f6a61d3ea4ec5b3eece8d4c2b830998459c75352.svg?branch=master)](https://buildkite.com/rails/rails)

Getting more information about a project
----------------------------------------

Luego de leer el archivo README deberíamos mirar los ``commits`` recientes. No veremos el último trabajo que las personas han hecho sino el último trabajo que se le ha hecho merge hacia el branch ``master``, que presuntamente ya debe estar listo para producción.

Ver los ``commits``:

.. figure:: images/lesson8/commits.png
    :align: center

    GitHub - Commits

Si queremos obtener actividades aún más recientes, no solo los features que han sigo añadidos con merge, debemos ver los ``pull request``:

.. figure:: images/lesson8/pull-requests.png
    :align: center

    GitHub - Pull requests

Estas son las unidades de trabajo que se están trabajando, siendo arreglos de bugs o nuevos features.

Introducing issues
------------------

Otro lugar que vale la pena ver es "Issues". Es usado para dos casos distintos:

1. Track de bugs
2. Administrar feature requests

Viewing project state through pulse and graphs
----------------------------------------------

Otra área recomendable de mirar para obtener un sentido del proyecto es "Pulse" y "Graphs":

Podemos ver quienes han contribuido al proyecto y quienes lo han hecho más:

.. figure:: images/lesson8/graph-contributors.png
    :align: center

    GitHub - Gráfico de contribuidores

Las gráficas de ``commits`` mostrará la cantidad de ``commits`` por semana a lo largo del tiempo de vida del proyecto en forma de barras:

.. figure:: images/lesson8/graph-commits.png
    :align: center

    GitHub - Gráficas de commits

La gráfica de code frequency nos mostrará el número de líneas añadidas y eliminadas del código:

.. figure:: images/lesson8/graph-code-frequency.png
    :align: center

    GitHub - Gráficas de Code frequency

Si Graph nos muestra qué pasa a lo largo de la historia de nuestro proyecto, Pulse nos dice qué ha pasado recientemente en el proyecto (el último día, semana, mes):

.. figure:: images/lesson8/pulse.png
    :align: center

    GitHub - Pulse

Estos números no nos dicen cúantos ``pull request`` o issues están abiertos, nos dice cuántos han sido cambiados:
