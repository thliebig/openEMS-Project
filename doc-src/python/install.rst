.. _pyinstall:

Install
=======

Instructions how to install the **CSXCAD & openEMS python interface**.

Python Dependency Requirements
---------------------------------

Some Python modules are required to run openEMS simulations and tutorials.
These packages can be installed via several methods.

Recommended: Install as System Packages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The section :ref:`install_requirements_src` already contains the
commands to install Python dependencies as system-wide packages. If
these instructions are followed, no additional installation is
required. In fact, installing it twice as a user-package may create
version conflicts, doing so is discouraged.

Skip to :ref:`Install <Python Linux Install>`.

Alternative: Install as User Packages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sometimes, it's impractical to install Python dependencies as system-wide
package. For example, on macOS, the Cython package is provided but not meant
for use by end-users. Thus, installing Python dependencies as user-wide
packages remain an alternative option.

.. code-block:: console

    # Possible but NOT recommended! See text below.
    pip3 install setuptools cython numpy h5py matplotlib --user

To ensure Python packages are installed in a conflict-free manner, it's
strongly encouraged to make use of a ``venv`` instead,
Suppose that we've built openEMS from source and installed it into a
prefix ``~/opt/openEMS``, we can create a ``venv`` inside
the same prefix.

.. code-block:: console

     # Install to an isolated prefix $HOME/opt/openEMS
     python3 -m venv $HOME/opt/openEMS
     $HOME/opt/openEMS/bin/pip3 install setuptools cython numpy h5py matplotlib

Remember, if Python has been installed to an isolated ``venv``, all
openEMS simulations can only be executed *inside* that ``venv``. Likewise,
only Python packages installed into the ``venv`` can be seen. The
``venv`` can be entered via:

.. code-block:: console

     source $HOME/opt/openEMS/bin/activate

Once the ``venv`` is activated, skip to :ref:`Install <Python Linux Install>`.

.. _Python Linux Install:

Unix/Linux
------------

Recommended: Build Python Binding Automatically
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The section :ref:`Install from Source <install_src>` already contains the
commands to build Python bindings via ``./update_openEMS.sh`` automatically
using the ``python`` flag. See :ref:`Install from Source <install_src>` for
more details.

.. code-block:: console

    bash ./update_openEMS.sh ~/opt/openEMS --python

.. _python_binding_build_manual:

Alternative: Build Python Binding Manually
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Alternatively, if a manual Python binding installation is desirable,
following these instructions. This may be needed if you're using an
openEMS package without Python extensions, or if you need to install
Python modules into a ``venv``.

.. important::

   If Python dependencies were installed into a ``venv``, activate
   the ``venv`` first. Assume the ``venv`` is located in
   ``$HOME/opt/openEMS/bin``::

       source $HOME/opt/openEMS/bin/activate

If we've built openEMS from source and installed it into a custom
prefix, the following command-line arguments are needed by
``setup.py build_ext`` to find the needed headers and libraries.

* ``-I``: header include path, including the ``/include`` suffix, comma-separated.
* ``-L``: library linking path, including the ``/lib`` suffix, comma-separated.
* ``-R``: library runtime path, including the ``/lib`` suffix, comma-separated.

To use these options properly, one needs to understand the motivation
behind specifying them. Basically, building a Python module requires
headers and libraries from three distinct sources:

1. Global headers and libraries provided by the system, and used by
   default. Typical paths are ``/usr/include`` and ``/usr/lib``.
   They paths *do not* need any special listing, since they're used
   by default.

2. Project-specific headers and libraries, provided as part of the
   openEMS package, and installed to the openEMS installation prefix,
   as such ``-L $HOME/opt/include`` and ``-R $HOME/opt/lib``. These paths
   *must be* listed.

3. Custom headers and libraries installed to the local system, but
   not used by default. For example, if a custom *Boost* is installed
   on CentOS, the paths ``-L /usr/local/include`` and ``-R /usr/local/lib``
   *must be* listed. On macOS, all Homebrew packages belong to this
   category, and the required prefix are ``-L $(brew --prefix)/include``
   and ``-R $(brew --prefix)/lib`` respectively.

Comma is used as the separator between multiple paths within each option.

The following example assumes the openEMS installation prefix is
``$HOME/opt/openEMS``, and some libraries have been installed to
``/usr/local``.

.. code-block:: bash

    cd openEMS-Project/CSXCAD/python

    python3 setup.py build_ext \
      -I "$HOME/opt/include:/usr/local/include" \
      -L "$HOME/opt/lib:/usr/local/lib" \
      -R $HOME/opt/lib

    python3 setup.py install --user
    # if using a venv, remove --user so the venv path is respected
    # python setup.py install

    cd openEMS-Project/openEMS

    python3 setup.py build_ext \
      -I "$HOME/opt/include:/usr/local/include" \
      -L "$HOME/opt/lib:/usr/local/lib" \
      -R $HOME/opt/lib

    python3 setup.py install --user
    # if using a venv, remove --user so the venv path is respected
    # python setup.py install

.. tip::

   Alternatively, the header and link search paths can also be
   controlled by the classical, global ``CXXFLAGS`` and ``LDFLAGS``
   without touching Python's ``built_ext`` flags.
   For example::

     export CXXFLAGS="-std=c++11 -I$HOME/opt/include -I/usr/local/include"
     export LDFLAGS="-L$HOME/opt/lib -L/usr/local/lib"

.. important::

   Not all operating systems use ``/usr/local`` for local packages.
   If Boost is located in a different path, the following error
   may occur:

   .. code-block:: console

      openems.h:30:10: fatal error: 'boost/program_options.hpp' file not found
      30 | #include <boost/program_options.hpp>
         |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~
      1 error generated.

   For example, if Homebrew is used on macOS, the prefix should be
   ``$(brew --prefix)``, not ``/usr/local``. Either obtain the
   correct prefix by running ``brew --prefix`` and manually type
   that prefix in, or leaving ``$(brew --prefix)`` intact as a
   variable, as in:

   .. code-block:: console

       python3 setup.py build_ext \
         -I "$HOME/opt/include:$(brew --prefix)/include" \
         -L "$HOME/opt/lib:$(brew --prefix)/lib" \
         -R $HOME/opt/lib

   Alternatively, you can install a copy of Boost directly into
   the openEMS installation prefix ``$HOME/opt/``, if you're
   compiling your own Boost just for this purpose.

macOS
^^^^^^^^

Follow the instructions
for :ref:`Unix/Linux <_Python Linux Install>`, both the automatic and
manual methods can be used.

.. _Python Windows Install:

Windows
-------

The python interface for CSXCAD & openEMS requires a build with a `MS Visual Compiler`_.
Download the latest windows build with the "msvc" label: openEMS_win_

Install Pre-build Modules
^^^^^^^^^^^^^^^^^^^^^^^^^

For some python versions, pre-build wheel files can be found in the python sub-directory. E.g. for python 3.10 (using pip):

.. code-block:: console

    cd C:\opt\openEMS\python
    pip install CSXCAD-0.6.2-cp310-cp310-win_amd64.whl
    pip install openEMS-0.0.33-cp310-cp310-win_amd64.whl

Build Modules From Source
^^^^^^^^^^^^^^^^^^^^^^^^^

Download the sources using git_. Assuming the MSVC binary build of openEMS is install at "C:\\opt\\openEMS",
run from a working python command prompt (e.g. using WinPython_):

.. code-block:: console

   git clone --recursive https://github.com/thliebig/openEMS-Project.git
   cd openEMS-Project/CSXCAD/python
   python setup.py build_ext -IC:\opt\openEMS\include -LC:\opt\openEMS
   python setup.py install

   cd ../../openEMS/python
   python setup.py build_ext -IC:\opt\openEMS\include -LC:\opt\openEMS
   python setup.py install

Setup
^^^^^

**Important Note:** Python needs to find the dependent libraries (dll's) during module import.
To allow this, it is necessary to set an environment variable (permantently, terminal restart my be necessary):

.. code-block:: console

    setx OPENEMS_INSTALL_PATH C:\opt\openEMS

.. _git: https://git-scm.com
.. _MS Visual Compiler: https://wiki.python.org/moin/WindowsCompilers
.. _openEMS_win: https://github.com/thliebig/openEMS-Project/releases
.. _WinPython: https://winpython.github.io/
