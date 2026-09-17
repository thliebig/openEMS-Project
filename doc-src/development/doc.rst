.. _manual_doc_build:

Manual Documentation Build
=============================

During development and testing, it's often necessary to build
CSXCAD and openEMS documentation manually. 

If you are an end-user, please view the documentation online via
`<https://docs.openems.de>`_. The *latest* version follows the ``master``
branch, *stable* shows the latest release. There's no need to manually
build documentation for end users.

.. tip::
   The following instructions are working as the time of writing, but it
   can become outdated. If you have difficulties building the project from source,
   refer to these official CI/CD test scripts in the source code.

   * `openEMS-Project documentation
     <https://github.com/thliebig/openEMS-Project/blob/master/.readthedocs.yaml>`_

Install Project Dependencies
-----------------------------

It's only possible on build project documentation after CSXCAD and openEMS
has already been installed.

Before proceeding...

1. Refer to :ref:`install_requirements_src` for a list of dependencies,
   including GNU Octave and Python.

2. Refer to :ref:`clone_build_install_src` and :ref:`pyinstall_auto` to
   install CSXCAD, openEMS, and Python extensions automatically.

3. Alternatively, refer to :ref:`manual_build` and :ref:`pyinstall_manual`
   to install CSXCAD, openEMS, and Python extensions manually.

.. important::

   GNU Octave and all Python extensions must also be installed.

Activate Python ``venv``
--------------------------

By default, Python extensions and their dependencies are installed
into an isolated "virtual environment" in the ``venv`` subdirectory
of openEMS's installation path. If openEMS is installed to ``~/opt/openEMS``,
the Python ``venv`` exists in ``~/opt/openEMS/venv``.

This environment *must be activated* before building documentation
for CSXCAD and openEMS.

.. code-block:: bash

    source ~/opt/openEMS/venv/bin/activate

Install Documentation-Specific Dependencies
---------------------------------------------

Documentation is available in the ``doc-src`` subdirectory of
``openEMS-Project.git``:

.. code-block:: bash

    cd openEMS-Project/doc-src

    # install documentation-specific dependencies
    pip3 install -r requirements.txt

Build Documentation
---------------------

One builds the documentation via Python Sphinx.

.. code-block:: bash

    cd openEMS-Project/doc-src

    # build documentation
    make html

Documentation Locations
-------------------------

- **Documentation Homepage**: Most pages are located within
  ``openEMS-Project/doc-src``.

  - Submit Pull Requests directly against ``openEMS-Project.git``.

- **API Documentation**: It's located within
  ``openEMS-Project/CSXCAD/matlab`` and
  ``openEMS-Project/openEMS/matlab``.

  - A custom script ``openEMS-Project/doc-src/octave/generate_octave_docs.py``
    is used to extract Octave docstrings as Markdown
    documentation (not restructuredText).

  - The Python documentation is generated from Python docstrings
    natively by Sphinx.

  - Submit Pull Requests against ``CSXCAD.git`` and ``openEMS.git``.

- **Examples and Tutorials**: Both the Python and the Octave/Matlab
  tutorials are generated from the example source code itself:

  - ``openEMS-Project/openEMS/python/Tutorials/*.py`` via
    ``doc-src/python/openEMS/convert_tutorials.py``.

  - ``openEMS-Project/openEMS/matlab/Tutorials/*.m`` via
    ``openEMS-Project/openEMS/matlab/doc/convert_tutorials.py``.

  - Both converters extract the comments of an example and interleave
    them with its code to form an "article". Submit new examples to
    ``openEMS.git``; no separate documentation page has to be written
    for them.

.. note::
   Several paths below ``doc-src`` are symbolic links into the
   submodules, so the page you are editing may well live in another
   repository:

   * ``doc-src/python/CSXCAD`` → ``CSXCAD/python/doc``
   * ``doc-src/python/openEMS`` → ``openEMS/python/doc``
   * ``doc-src/octave/Tutorials`` → ``openEMS/matlab/doc/Tutorials``

   Check with ``ls -l`` before opening a Pull Request, and submit it
   against the repository that actually holds the file.
