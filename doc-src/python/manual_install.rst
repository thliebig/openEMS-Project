.. _pyinstall_manual:

Install Python Extensions Manually
===================================

Instructions how to install the **CSXCAD & openEMS Python interface**.

Methods
--------

CSXCAD and Python extensions can be installed using two methods:
automatic install via ``./update_openEMS.sh`` using the ``--python``
flag, or building each Python extension separately.



Recommended: Install Python Extensions Automatically
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The section :ref:`Install from Source <install_src>` already contains the
commands to build openEMS and its Python binding at the same time via
``./update_openEMS.sh`` automatically, using the ``python`` flag.

.. code-block:: bash

    ./update_openEMS.sh ~/opt/openEMS --python

See :ref:`install_requirements_src` and :ref:`clone_build_install_src` first
for more details.

Installation Strategies
^^^^^^^^^^^^^^^^^^^^^^^^

In the past, the CSXCAD and openEMS Python extensions were installed
directly into Python's default search paths (such as  ``~/.local`` in
the home directory). However, this practice is now discouraged on most
operating systems as a policy of `PEP 668 <https://peps.python.org/pep-0668/>`_.
Due to the risk of dependency conflicts between a system-supplied and
a user-installed Python package. Creating an isolated "virtual environment"
is now recommended.

In the latest openEMS development version (to be released as v0.0.37),
``update_openEMS.sh`` automatically creates a Python venv under an
installation subdirectory ``venv`` (i.e. ``~/opt/openEMS/venv``), and
automatically installs all extensions to this location. The Python
dependencies bypasses the operating system's own package management,
and requires Internet access to PyPI.

Advanced Install
^^^^^^^^^^^^^^^^^^

One can install Python packages using several different methods, controlled
by the following options.

- ``--python-venv-mode``

  - ``auto``: create a Python venv if no venv is already activated,
    otherwise use the existing venv (default)
  - ``venv``: create a Python venv
  - ``site``: create a Python venv with --system-site-packages
  - ``disable``: don't change venv, install Python extension directly to
    default path (usually in home directory (e.g. ``~/.local``)

- ``--python-venv-dir``: override default Python venv creation path,
  by default, use "venv" subdirectory of the installation path.

- ``--python-use-network`` Download needed Python pip packages from Internet
  - ``auto``: use Internet when needed (default)
  - ``disable``: all dependencies must be manually installed, or installation
    fails (create venv with ``--system-site-packages``, run pip with
    ``--no-build-isolation``, disable pip self-update and setuptools_scm)

Alternative: Install Python Extensions Manually
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This page contains information for installing CSXCAD and
openEMS Python extensions via ``pip``, without using the
monolithic ``./update_openEMS.sh``.

Requirements
--------------

Python version
~~~~~~~~~~~~~~~

Ensure the system's Python interpreter is officially supported by
Python developers, such as Python 3.9. Use unsupported versions at your
own risk.

Installation is allowed using practically all Python versions (Python
3.4+), but for testing purposes only. Use at your own risk. At the time of
writing, Python 3.5 is known to partially work (i.e., run a trivial script),
while Python 3.6 is likely the lowest fully-functional version.
In Python 3.5 and lower versions, ``SyntaxError`` may be encountered.

Other Dependencies
~~~~~~~~~~~~~~~~~~

This file assumes readers have already installed required C++
and Python dependencies (including compiling and installing
the C++ CSXCAD library and openEMS field solver into the system,
and installing the CSXCAD Python extension). If not, follow
:ref:`install_requirements_src` and :ref:`clone_build_install_src`.

Quick Start
--------------

If the C++ CSXCAD library and openEMS field solver were both installed into
``~/opt/openEMS``, install this package with:

.. code-block:: bash

    # create an isolated venv in ~/opt/openEMS/venv and activate it
    python3 -m venv $HOME/opt/openEMS/venv
    source $HOME/opt/openEMS/venv/bin/activate

    # CSXCAD_INSTALL_PATH and OPENEMS_INSTALL_PATH must be set!
    export CSXCAD_INSTALL_PATH=$HOME/opt/openEMS
    export OPENEMS_INSTALL_PATH=$HOME/opt/openEMS

    # build and install CSXCAD Python extension
    cd openEMS-Project/CSXCAD/python
    pip3 install .

    # build and install openEMS Python extension
    cd openEMS-Project/openEMS/python
    pip3 install .

Replace ``$HOME/opt/openEMS`` with the path prefix to CSXCAD/openEMS.
Both projects should be installed to the same prefix (installation
to different prefixes are unsupported and untested).

.. tip::
   By default, it's not necessary to explicitly install
   ``openEMS-Project/CSXCAD/python``, if you plan to install
   ``openEMS-Project/openEMS/python`` too - pip detects it
   automatically as a dependency.

Once installed, test Python extensions from a neutral directory.
Don't test Python extensions in the source code directories
(``CSXCAD/python``, ``openEMS/python``) to avoid importing local
files.

.. code-block:: console

    $ cd /  # Important: always leave "python" first.

    $ cd / && python3 -c "import CSXCAD; print(CSXCAD.ContinuousStructure())"
    <CSXCAD.CSXCAD.ContinuousStructure object at 0x7f5957943fd0>

    $ cd / && python3 -c "import CSXCAD; print(CSXCAD.__version__)"
    0.6.4.dev76+gccb4c218e

    $ cd / && python3 -c "import openEMS; print(openEMS.openEMS())"
    <openEMS.openEMS.openEMS object at 0x7f47f8dffb20>

    $ cd / && python3 -c "import openEMS; print(openEMS.__version__)"
    '0.0.36.post1.dev115+gfbb03a107.d20251112'

Environment Variables
---------------------

The following environment variables control the behaviors of the
Python extension installation.

1. **(Required)** ``CSXCAD_INSTALL_PATH``, ``OPENEMS_INSTALL_PATH``:
   path prefix of the CSXCAD and openEMS C++ installation. Without
   these variables, installation is terminated with an error.

2. **(Optional)** ``CSXCAD_PYSRC_PATH``: path to the CSXCAD Python
   source code. By default, it's auto-detected by checking a few files
   in the directory structure ``openEMS-Projects``. If they don't exist,
   CSXCAD source is auto-downloaded from GitHub. It can be overridden
   with a filesystem path or a ``git+https://`` URL if auto-detection fails.

3. **(Optional)** ``VIRTUAL_ENV``: path prefix of the Python ``venv``,
   set automatically if a Python ``venv`` is activated. If ``venv`` exists
   in the C++ path prefix's ``/venv`` subdirectory
   (``VIRTUAL_ENV=$OPENEMS_INSTALL_PATH/venv``) or overlaps
   (``VIRTUAL_ENV=$OPENEMS_INSTALL_PATH``),
   both ``CSXCAD_INSTALL_PATH`` and ``OPENEMS_INSTALL_PATH`` can be omitted,
   activating the venv is sufficient.

4. **(Optional)** ``CSXCAD_INSTALL_PATH_IGNORE``,
   ``OPENEMS_INSTALL_PATH_IGNORE``: disable ``CSXCAD_INSTALL_PATH``
   and ``OPENEMS_INSTALL_PATH`` usages and error checking. Useful only
   if their installation paths are specified manually through other
   methods, such as ``CXXFLAGS`` or ``LDFLAGS``.

5. **(Optional)** ``CSXCAD_NOSCM`` and ``OPENEMS_NOSCM``: ``pip`` no
   longer downloads ``setuptools_scm``, git-based version numbers are
   no longer generated.

If build isolation is disabled (see below), ``CSXCAD_`` variables
are only needed when installing the ``CSXCAD`` extension, and are all
made optional for the openEMS extension - ``pip`` won't rebuild the ``CSXCAD``
extension if it has already been installed prior to installing the
``openEMS`` extension.

Basic Install
---------------

Step 1: Set ``CSXCAD_INSTALL_PATH`` and ``OPENEMS_INSTALL_PATH``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The environment variable ``CSXCAD_INSTALL_PATH`` and ``OPENEMS_INSTALL_PATH``
must be set to ensure a successful installation. If either of them is not
set, a ``RuntimeError`` is generated.

If CSXCAD/openEMS were installed into ``~/opt/openEMS``, set
``CSXCAD_INSTALL_PATH`` and ``OPENEMS_INSTALL_PATH`` with:

.. code-block:: bash

    export CSXCAD_INSTALL_PATH="$HOME/opt/openEMS"
    export OPENEMS_INSTALL_PATH="$HOME/opt/openEMS"

Replace ``$HOME/opt/openEMS`` with the path prefix to CSXCAD/openEMS.
Both projects should be installed to the same prefix (installation
to different prefixes are unsupported and untested).

You should be able to find ``/lib`` and ``/include`` in this prefix:

.. code-block:: console

    $ ls $OPENEMS_INSTALL_PATH
    bin  include  lib  lib64  share

    $ ls $OPENEMS_INSTALL_PATH/include
    CSXCAD  fparser.hh  openEMS

    $ ls $OPENEMS_INSTALL_PATH/lib
    libCSXCAD.so    libCSXCAD.so.0.6.3  libfparser.so.4      libnf2ff.so    libnf2ff.so.0.1.0  libopenEMS.so.0
    libCSXCAD.so.0  libfparser.so       libfparser.so.4.5.1  libnf2ff.so.0  libopenEMS.so      libopenEMS.so.0.0.36

As a hardcoded special case, the path of the current Python venv
(``VIRTUAL_ENV``) is also considered as a search path prefix by default.
If your C++ and Python ``venv`` paths exactly overlap, one doesn't need
to set any environment variables if a Python venv is activated prior
to installation. We still use ``$CSXCAD_INSTALL_PATH`` and
``$OPENEMS_INSTALL_PATH`` throughout the documentation for consistency.

Step 2: venv
~~~~~~~~~~~~

Installing Python packages into Python's default search paths
(such as ``/usr/`` in the base system, or ``~/.local`` in the home
directory) is discouraged by most operating systems, because
there's a risk of dependency conflicts between a system-supplied
and a user-installed Python package.

To ensure Python packages are installed in a conflict-free manner,
it's suggested by most systems to create an isolated environment
for Python packages, known as a *virtual environment* (``venv``).

If you have never created your own ``venv`` before, create a
``venv`` specifically for CSXCAD and openEMS now:

.. code-block:: bash

    python3 -m venv $HOME/opt/openEMS/venv/

This creates the Python venv in a subdirectory of ``$OPENEMS_INSTALL_PATH``.
But if you prefer separation, you can use a different path, such
as ``~/venvs/openems``, or activate an existing ``venv`` you already
have.

Remember, if the Python extension has been installed to an isolated
``venv``, all Python scripts that use CSXCAD or openEMS can only be
executed inside this ``venv`` while it's activated.  Likewise, only Python
packages installed into the ``venv`` can be seen.

The ``venv`` can be entered via:

.. code-block:: bash

    source $HOME/opt/openEMS/venv/bin/activate

    # leave the venv with "deactivate"

Once the ``venv`` is activated, follow the next steps.

Step 3: pip
~~~~~~~~~~~~

Assuming that the correct ``CSXCAD_INSTALL_PATH`` and ``OPENEMS_INSTALL_PATH``
have already been set, and a ``venv`` has been activated, run:

.. code-block:: bash

    # build and install CSXCAD Python extension
    cd openEMS-Project/CSXCAD/python
    pip3 install .

    # build and install openEMS Python extension
    cd openEMS-Project/openEMS/python
    pip3 install .

When installing packages inside a ``venv``, avoid using ``--user`` because
it doesn't respect the activated ``venv``, effectively undoing it.

Offline Install or Manual Package Management
---------------------------------------------

By default, ``pip`` prefers to ignore existing packages in the
system, aggressively redownloading them, either for constructing
a fresh user ``venv``, or for constructing the isolated build
environment. This includes building CSXCAD twice.

It can be
problematic if you want to manage packages using the operating
system's own package manager externally, or if Internet access to
PyPI is not always online.
It's possible to suppress most redownloading behaviors, making
it a useful solution for external package management.

.. tip::

   Technical concepts used within this section are elaborated below
   in :ref:`python_advanced_install`.

Install Dependencies
~~~~~~~~~~~~~~~~~~~~~~

To manage packages manually, ensure that all Python
dependencies have been installed via your system's package
manager.

A full list of package manager dependencies on
various systems can be found in :ref:`install_requirements_src`.
Many Python packages are marked as optional (because they are
usually installed via ``pip``), they must be installed for
this use case.

.. tip::

   In theory, one can use a DVD, a USB drive, or any ``file://``
   path as a software repository, this use case is supported
   by mature package managers such as ``apt``, ``rpm``, ``dnf`` ,
   and was widely used in the past for DVD installations.
   Today, it's still a potential solution for offline systems.
   See `Use a Debian DVD ISO as an Upgrade Source
   <https://web.archive.org/web/20251128091254/https://fragdev.com/blog/use-a-debian-dvd-iso-as-an-upgrade-source>`_
   and `How to Set Up yum Repository for
   Locally-mounted DVD on Red Hat Enterprise Linux 7
   <https://web.archive.org/web/20251004212440/https://access.redhat.com/solutions/1355683>`_.

Expose System Packages to ``venv``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create a ``venv``, and expose existing system packages, so we don't
need to install anything into the venv if the system already has
them (only needed to run once during installation).

.. code-block:: bash

    python3 -m venv --system-site-packages $HOME/opt/openEMS/venv
    source $HOME/opt/openEMS/venv/bin/activate

Disable Build Isolation
~~~~~~~~~~~~~~~~~~~~~~~~

During installation via ``pip``, ``pip`` will redownload build-time
dependencies such as ``setuptools``, or ``cython``, even when those
dependencies are already available to the system or a ``venv``.
In particular, CSXCAD is built twice for this reason. This is
why one has to set both ``CSXCAD_`` and ``OPENEMS_`` environment
variables, even if CSXCAD has already been installed.

This is the result of the *build isolation* feature in ``pip``.
When building packages, ``pip`` creates an internal ``venv`` for itself,
isolated from both the base system and a user's own ``venv``. This way,
it allows users to install packages with conflicting build-time
dependencies.

By default, CSXCAD/openEMS also uses ``setuptools_scm`` to automatically
create a version number based on the current ``git`` history. Since a
fairly new version is required, pre-installation via a system's package
manager may be impractical.

Both behaviors can disabled via:

.. code-block:: bash

    cd openEMS-Project/CSXCAD/python
    export CSXCAD_NOSCM=1
    pip3 install . --no-build-isolation

    cd openEMS-Project/openEMS/python
    export OPENEMS_NOSCM=1
    pip3 install . --no-build-isolation

The variables ``CSXCAD_NOSCM`` and ``OPENEMS_NOSCM`` is specific to
CSXCAD and openEMS, respectively.

Without build isolation, when installing the openEMS extension
after the CSXCAD extension, the ``CSXCAD_`` variables are *not*
needed. CSXCAD won't be rebuilt again while installing openEMS,
the existing installation is used.


.. _override_csxcad_pysrc:

Override ``CSXCAD_PYSRC_PATH``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. tip::

   If *Build Isolation* has been disabled, this section is not
   needed. Without build isolation, the CSXCAD Python extension which
   you've already installed will be used. Just ensure to install
   ``CSXCAD/python`` before ``openEMS/python``.

Internally, ``pip`` requires source code to CSXCAD's Python extension
while building openEMS. Due to build isolation, CSXCAD is built
twice by ``pip``: once for ``pip``'s internal build use, once for actual
end-user use.

Its path is automatically detected by assuming the following
directory structure with respect to ``CSXCAD/python``.

.. code-block:: console

    ├── CSXCAD
    │   ├── python
    ├── openEMS
    │   ├── openems.h
    │   ├── python
    └── update_openEMS.sh

If detection fails, we assume ``openEMS`` is used individually,
so a fallback URL ``git+https://github.com/thliebig/CSXCAD.git#subdirectory=python``
is used instead.

The auto-detection and the fallback GitHub URL can be overridden
simultaneously by the environment variable ``CSXCAD_PYSRC_PATH``,
such as:

.. code-block:: bash

    # use a local copy of CSXCAD
    export CSXCAD_PYSRC_PATH="$HOME/openEMS-Project/CSXCAD/python"

    # use a different Git repo
    export CSXCAD_PYSRC_PATH="git+https://example.com/CSXCAD.git#subdirectory=python"

.. _python_advanced_install:

Advanced Install Concepts
---------------------------

This section is written for troubleshooting an installations, or for
experienced users, sysadmins and developers who need to troubleshoot
or customize their installations. Ordinary users can skip this section.

Suppress ``RuntimeError``
~~~~~~~~~~~~~~~~~~~~~~~~~

CSXCAD/openEMS is usually installed to a non-standard location such as
``~/opt/openEMS`` in the user home directory. By default, system compilers
are unable to find necessary C++ libraries, because only global path
prefixes such as ``/usr/`` or ``/usr/local`` are considered.

A ``RuntimeError`` is generated if ``CSXCAD_INSTALL_PATH`` or
``OPENEMS_INSTALL_PATH`` are not set. If you know what you're doing
(e.g., both libraries are already added to the compiler search paths
manually), you can bypass these errors with:

.. code-block:: bash

    export CSXCAD_INSTALL_PATH_IGNORE=1
    export OPENEMS_INSTALL_PATH_IGNORE=1

Search Path Management
~~~~~~~~~~~~~~~~~~~~~~~

By default, all necessary search paths are configured automatically
by ``CSXCAD_INSTALL_PATH`` and ``OPENEMS_INSTALL_PATH``, or ``VIRTUAL_ENV``.
On all Unix-like system, ``/usr/local`` is also always added into the search
paths as another hardcoded special case, regardless of the system's
default search paths.  Likewise, on macOS, the prefix reported by
``brew --prefix`` is automatically added to the search paths.

If manual control is needed, set ``CXXFLAGS`` and ``LDFLAGS`` instead of
``CSXCAD_INSTALL_PATH`` or ``OPENEMS_INSTALL_PATH``. These flags include
the following arguments:

* ``-I``: header include path, including the ``/include`` suffix.
* ``-L``: library linking path, including the ``/lib`` suffix.
* ``-Wl,-rpath,``: library runtime path, including the ``/lib`` suffix.

The following example assumes the installation prefix is
``$HOME/opt/openEMS``, and some dependent libraries have been installed
to ``/usr/local``.

.. code-block:: bash

    export CSXCAD_INSTALL_PATH_IGNORE=1
    export OPENEMS_INSTALL_PATH_IGNORE=1
    
    export CXXFLAGS="-I$HOME/opt/openEMS/include -I/usr/local/include $CXXFLAGS"
    export LDFLAGS="-L$HOME/opt/openEMS/lib -L/usr/local/lib -Wl,-rpath,$HOME/opt/openEMS/lib $LDFLAGS"

To use these options properly, one needs to understand the motivation
behind specifying them. Basically, building a Python module requires
headers and libraries from three distinct sources:

1. Standard global headers and libraries provided by the system,
   and used by compilers by default. Typical paths are ``/usr/include``
   and ``/usr/lib``.
   They paths *do not* need any special listing, since they're used
   by default. All dependencies installed by the system's package
   manager typically also belong to this category, without special
   treatment (but exceptions exist, such as macOS Homebrew).

2. Non-standard global headers and libraries installed by the user
   (usually dependencies such as a custom Boost or VTK newer than the
   system's own version). They're outside the system's control, and
   not used by compilers by default.
   For example, on CentOS, the paths
   ``-L/usr/local/include`` and ``-Wl,-rpath,/usr/local/lib`` *must be*
   listed if any custom packages are installed to ``/usr/local``.
   Unlike other system-wide package managers, macOS's Homebrew
   also belong to this category, because it's a 3rd-party package
   manager, thus it requires
   ``-L$(brew --prefix)/include`` and ``-Wl,-rpath,$(brew --prefix)/lib``.

3. Non-standard local CSXCAD/openEMS headers and libraries.
   These files are usually installed to an arbitrary prefix in the user's
   home directory, not used by any compilers by default, as such
   ``-L$HOME/opt/openEMS/include`` and ``-Wl,-rpath,$HOME/opt/openEMS/lib``.
   These paths *must be* listed.

If multiple paths are needed, repeat the option for each path, and
separate each option by spaces.

Expose System Packages in venv
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In an isolated ``venv``, only Python packages installed into the ``venv``
can be seen. Optionally, one can expose external system-wide packages to a
``venv`` via ``--system-site-packages`` during ``venv`` creation:

.. code-block:: bash

    # create venv, expose system packages
    # (run once during installation)
    python3 -m venv --system-site-packages $HOME/opt/openEMS/venv

In this ``venv``, the packages within ``venv`` stays within
the ``venv``, but system-wide packages are also available.
Activation is still needed prior to using CSXCAD/openEMS in
Python.

.. code-block:: bash

    source $HOME/opt/openEMS/venv/bin/activate

Install Python Extension to Home Directory Instead of venv
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It's possible to install a package via ``pip`` into the default
Python search path under a user's home directory (e.g. ``~/.local``)
via ``--user``.

After 2021, this practice is deprecated on most systems by
`PEP 668 <https://peps.python.org/pep-0668/>`_, since it bypasses
a system's own package manager, risking dependency conflicts.
The new option ``--break-system-packages`` is required.

.. code-block:: bash

    pip3 install . --user --break-system-packages
    source $HOME/opt/openEMS/venv/bin/activate

As suggested by the option ``--break-system-packages``, it has the
risk of creating dependency conflicts between the same package
from the system and from ``pip``. Using ``--break-system-packages``
is only considered safe if all Python dependencies are installed via
your system's package manager (e.g. ``apt``, ``dnf``), as recommended
in :ref:`install_requirements_src` prior to running ``pip3 install .``.
Otherwise, ``pip`` may attempt to install dependent packages on its
own, risking dependency conflicts with system packages.


Legacy Installation via ``setup.py``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``setup.py`` method was the traditional way of building and installing
Python extensions. It has been deprecated by Python developers in favor
of ``pip``. Follow this section only for the purpose of debugging a build.

Assuming that the correct ``CSXCAD_INSTALL_PATH`` and ``OPENEMS_INSTALL_PATH``
have already been set (or have been bypassed via ``CSXCAD_INSTALL_PATH_IGNORE``
and ``OPENEMS_INSTALL_PATH_IGNORE``), both extensions can be built manually
via:

.. code-block:: bash

    python setup.py build_ext
    
    # install to user's home directory, equivalent to
    # pip3 install . --user --break-system-packages
    python setup.py install --user
    
    # if using a venv, remove --user so the venv path is respected
    # python setup.py install

Without build isolation, when installing the openEMS extension
after the CSXCAD extension, the ``CSXCAD_`` variables are *not*
needed. CSXCAD won't be rebuilt again while installing openEMS,
the existing installation is used.

Advanced: setup.py search path management
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

On Unix-like systems, one can use the standard ``CXXFLAGS`` and
``LDFLAGS`` to control compiler headers and libraries paths for
both ``pip`` and ``setup.py`` in the beginning of this tutorial.

In ``setup.py``, it also provides its own custom options. Their
uses are not necessary, they're introduced there:

* ``-I``: header include path, including the ``/include`` suffix, colon-separated.
* ``-L``: library linking path, including the ``/lib`` suffix, colon-separated.
* ``-R``: library runtime path, including the ``/lib`` suffix, colon-separated.

The following example assumes the CSXCAD/openEMS installation prefix is
``$HOME/opt/openEMS/``, and some libraries have been installed to
``/usr/local``.

.. code-block:: bash

    export CSXCAD_INSTALL_PATH_IGNORE=1
    export OPENEMS_INSTALL_PATH_IGNORE=1
    
    python3 setup.py build_ext \
      -I "$HOME/opt/openEMS/include:/usr/local/include" \
      -L "$HOME/opt/openEMS/lib:/usr/local/lib" \
      -R "$HOME/opt/openEMS/lib"

Windows
-------

The python interface for CSXCAD & openEMS requires a build with a
`MS Visual Compiler`_. Download the latest Windows build with the "msvc"
label: openEMS_win_

Install Pre-build Modules
~~~~~~~~~~~~~~~~~~~~~~~~~~

For some python versions, pre-build wheel files can be found in the
``python`` sub-directory. E.g. for Python 3.10 (using ``pip``):

.. code-block:: batch

    cd C:\opt\openEMS\python
    pip3 install CSXCAD-0.6.2-cp310-cp310-win_amd64.whl
    pip3 install openEMS-0.0.33-cp310-cp310-win_amd64.whl

Setup
~~~~~~~

**Important Note:** Python needs to find the dependent libraries (dll's) during module import.
To allow this, it is necessary to set an environment variable (permantently, terminal restart my be necessary):

.. code-block:: batch

    setx OPENEMS_INSTALL_PATH C:\opt\openEMS

Build Modules From Source
~~~~~~~~~~~~~~~~~~~~~~~~~~

Download the sources using ``git``. Assuming the MSVC binary build of openEMS is
install at ``C:\opt\openEMS``, run from a working Python command prompt
(e.g. using WinPython_):

.. code-block:: batch

   git clone --recursive https://github.com/thliebig/openEMS-Project.git
   cd openEMS-Project/CSXCAD/python
   python3 setup.py build_ext -IC:\opt\openEMS\include -LC:\opt\openEMS
   python3 setup.py install

   cd ../../openEMS/python
   python3 setup.py build_ext -IC:\opt\openEMS\include -LC:\opt\openEMS
   python3 setup.py install

.. warning::

   This section has not been updated for the new ``pip`` method for Windows
   due to lack of a test environment. Please submit a Pull Request against
   openEMS-Project.git if you have success using the modern ``pip`` method
   on Windows.

Troubleshooting
----------------

AttributeError: module 'CSXCAD.CSRectGrid' has no attribute...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ensure your CSXCAD and Python installation matches.

There could be an old copy of CSXCAD inside your system somewhere, which
is built with a newer Python extension that uses then non-existent properties.
Delete all older copies of CSXCAD from your system, and reinstall CSXCAD and
the Python extension.

FileNotFoundError: [Errno 2] No such file or directory: ``/CSXCAD/python``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you see a similar error message during installation:

.. code-block:: console

    ERROR: Could not install packages due to an OSError.
    FileNotFoundError: [Errno 2] No such file or directory: '/CSXCAD/python'
    error: subprocess-exited-with-error

It means the installer detected an incorrect CSXCAD Python source code path,
and it's unable to install the CSXCAD Python extension as a dependency.

Rerun pip with ``pip3 install . --no-build-isolation``. Without build isolation,
the CSXCAD Python extension which you've already installed will be used. Just
ensure to install ``CSXCAD/python`` before ``openEMS/python``.

Alternatively, provide the path manually via ``CSXCAD_PYSRC_PATH`` instead, and
rerun pip. See the section :ref:`override_csxcad_pysrc`.

Unable to detect CSXCAD's Python source code path
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you see the following error message during installation:

.. code-block:: console

      File "/home/fdtd/openEMS/python/bootstrap/setuptools_build_meta_custom.py", line 44, in add_csxcad
        raise RuntimeError(
          RuntimeError: Unable to detect CSXCAD's Python source code path. You're likely using an old pip without 'in-tree build' support. You can pick one solution below: (1) Rerun pip with 'pip install . --no-build-isolation' if CSXCAD Python extension is already installed (recommended). (2) Provide the path via CSXCAD_PYSRC_PATH and rerun pip (e.g. 'export CSXCAD_PYSRC_PATH=/home/user/openEMS-Project/CSXCAD/python/ && pip install . '). (3) Upgrade to pip 21.3 or newer.
          [end of output]
    
      note: This error originates from a subprocess, and is likely not a problem with pip.

It means the auto-CSXCAD detection result is ambiguous. You can choose
*one* solution from the following three.

1. Rerun pip with ``pip3 install . --no-build-isolation``.

   Without build isolation, the CSXCAD Python extension which
   you've already installed will be used. Just ensure to install
   ``CSXCAD/python`` before ``openEMS/python``. This is recommended,
   as it's the easiest solution.

2. Provide the path via ``CSXCAD_PYSRC_PATH`` and rerun ``pip``.

   See the section :ref:`override_csxcad_pysrc`.

3. Upgrade to pip 21.3.

   .. code-block:: bash

       # Activate the Python venv first (important) if you didn't.
       source $HOME/opt/physics/venv/bin/activate

       # Upgrade pip
       pip3 install --upgrade pip

       # Check version
       pip3 --version

   If the system's Python interpreter is older than Python 3.6,
   pip 21.3 cannot be installed. Upgrade your system to Python 3.6,
   or try an alternative solution above. Note that the openEMS
   extension is not fully-functional under Python 3.5 and below,
   ``SyntaxError`` may occur.

ModuleNotFoundError: No module named 'CSXCAD.CSXCAD'
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ensure you're not running ``python`` under ``openEMS/python`` of the
source code tree. Otherwise, Python attempts to import the incomplete
source code instead of the complied Python extension.

If the error persists, debug the installation by running ``pip`` in
verbose mode.

.. code-block:: bash

    pip3 install . --verbose

The ``setup.py`` method can also be used for troubleshooting.

If you are unable to solve the problem, create a post in the
`discussion forum <https://github.com/thliebig/openEMS-Project/discussions>`_.
Make sure to provide detailed information about your system
(operating systems name and version, any error messages and
debugging outputs).

ModuleNotFoundError: No module named 'openEMS.openEMS'
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

See *ModuleNotFoundError: No module named 'CSXCAD.CSXCAD'*.

CSXCAD Tests and Examples
---------------------------

Although CSXCAD is often used together with openEMS, it's a general-purpose
geometry library on its own. A CSXCAD model contains material and excitation
source parameters. In principle, You can develop your own solver backend
based on CSXCAD's input. A single example is available in ``python/examples``.

CSXCAD unit tests are also available in the ``python/tests`` directory. They
can be executed via:

.. code-block:: bash

    cd openEMS-Project/CSXCAD/python/tests
    python3 -m unittest

.. _MS Visual Compiler: https://wiki.python.org/moin/WindowsCompilers
.. _openEMS_win: https://github.com/thliebig/openEMS-Project/releases
.. _WinPython: https://winpython.github.io/
