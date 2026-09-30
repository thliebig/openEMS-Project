.. _pyinstall_auto:

Install Python Extensions Automatically
========================================

Installing the **CSXCAD & openEMS Python interface** with
``./update_openEMS.sh --python``, which is the recommended way.

.. seealso::

   * For context, see :ref:`install_requirements_src` and
     :ref:`clone_build_install_src`.

   * To build the extensions by hand instead, see :ref:`pyinstall_manual`.

Quick Start
------------

In the simplest cases, all one needs is adding the ``--python`` flag
in ``./update_openEMS.sh``. For example, to install the C++ project and
its Python extensions simultaneously to the prefix ``~/opt/openEMS``,
run:

.. code-block:: bash

    ./update_openEMS.sh ~/opt/openEMS --python

Since openEMS 0.37, Python extensions and their dependencies are installed
into an isolated "virtual environment" in the ``venv`` subdirectory (e.g.
``~/opt/openEMS/venv``). This environment *must be activated* before
using Python with CSXCAD or openEMS.

.. code-block:: bash

    source ~/opt/openEMS/venv/bin/activate

    # leave the venv with "deactivate"

.. important::

    In a ``venv``, its environment is isolated from the operating
    system's own. System-wide Python packages are invisible, only
    Python packages installed specifically here can be seen. If you
    need other third-party packages, install them via ``pip3``
    provided *within* this ``venv``.

    For example, to analyze S-parameters via scikit-rf:

    .. code-block:: bash

        source ~/opt/openEMS/venv/bin/activate  # if not activated
        pip3 install scikit-rf

Customize Install
------------------

To satisfy the needs of users from different backgrounds, users are:

1. *Not required* to install Python extensions to an isolated ``venv``,
   the ``venv`` can be disabled.

2. *Not required* to use the created ``venv`` environment, a pre-existing
   ``venv`` or an alternative venv path can be used.

3. *Not required* to manage packages via ``pip3``, or to have Internet access
   to PyPI. It's possible to manage dependencies manually using the system's
   package manager, without ``pip3``.

Arguments
~~~~~~~~~~~

The Python installation behavior of ``update_openEMS.sh`` can be
customized using the following arguments:

.. option:: --python-venv-mode <mode>

    Python extensions installation mode:

    - ``auto``: create a new Python venv if no venv is already activated,
      otherwise use the existing venv (default).

    - ``venv``: create a new Python venv.

    - ``site``: create a new Python venv with ``--system-site-packages``.

    - ``disable``: don't create a new venv, install Python extension directly to a
      default path (usually in home directory (e.g. ``~/.local``).

.. option:: --python-venv-dir

   Override default Python venv creation path. By default, use the ``venv``
   subdirectory of the installation path.

.. option:: --python-use-network <option>

    Download needed Python pip packages from Internet

    - ``auto``: use Internet when needed (default).

    - ``disable``: all dependencies must be manually installed, or installation
      fails (create venv with ``--system-site-packages``, run pip with
      ``--no-build-isolation``, disable pip self-update and setuptools_scm).

Typical Customization Cases
-----------------------------

.. _pyinstall_qa_use_existing_venv:

Q: I don't want ``update_openEMS.sh`` to create a new ``venv`` for me, because I have my own.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Active your ``venv`` before calling ``./update_openEMS.sh``. By default,
``--python-venv-mode auto`` means that no new ``venv`` is created if an
``venv`` has already been activated.

.. code-block:: bash

   # activate your own venv
   source ~/venvs/snake/bin/activate
   ./update_openEMS.sh ~/opt/openEMS --python


.. _pyinstall_qa_use_alt_venv_path:

Q: I want to create a new ``venv``, but not under the ``/venv`` subdirectory of openEMS.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the ``--python-venv-dir`` argument to specify an alternative path.
If the same path contains an existing ``venv``, it will be overwritten.

.. code-block:: bash

   ./update_openEMS.sh ~/opt/openEMS --python-venv-dir ~/venvs/openEMS

.. _pyinstall_qa_use_system_packages:

Q: All system packages are invisible in the Python ``venv``. I don't want to reinstall them via ``pip3`` for the ``venv``, I want to use the existing system Python packages.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the ``--python-venv-mode site`` argument to create a Python venv
with the flag ``--system-site-packages``. In this mode, all existing
system packages are exposed, at the same time, you can still install
your own packages in this ``venv``.

.. code-block:: bash

   ./update_openEMS.sh ~/opt/openEMS --python --python-venv-mode site

.. warning::

   It's recommended to install as many packages as possible using the
   system's own package manager, and only to install a package via ``pip3``
   if it doesn't exist within the system. Otherwise, it's possible to
   install incompatible versions of the same packages.

   All Python packages marked as optional in the :ref:`install_requirements_src`
   page should be installed to ensure this.

.. _pyinstall_qa_offline_system:

Q: I don't want ``./update_openEMS.sh`` to download dependencies using ``pip3`` because I don't have Internet access.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the ``--python-use-network disable`` argument. In this mode,
you're required to manage Python dependencies manually using your
operating system's package manager.
It enables ``--python-venv-mode site`` implicitly, in addition, it
disables many other behaviors that trigger network downloads, such as
self-updating ``pip3``.

.. code-block:: bash

   ./update_openEMS.sh ~/opt/openEMS --python --python-use-network disable

.. warning::

   All Python packages marked as optional in the :ref:`install_requirements_src`
   page should be already installed, because the operating system is responsible
   for package management here.

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

.. _pyinstall_qa_use_os_package_manager:

Q: I don't want to use ``pip3`` to manage Python package dependencies, I want to use my system's own package manager.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the ``--python-use-network disable`` argument, see
:ref:`pyinstall_qa_offline_system`

.. _pyinstall_qa_proxy:

Q: I have Internet access, but behind a proxy.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For an HTTP proxy, set the standard environment variables in the format
``[protocol://]<host>[:port]`` and build as usual:

.. code-block:: bash

   export http_proxy="http://proxy.example.com:8080"
   export https_proxy="http://proxy.example.com:8080"

   ./update_openEMS.sh ~/opt/openEMS --python

A SOCKS proxy (``socks5h://proxy.example.com:8080``) additionally needs
``pysocks``, an optional ``pip3`` dependency, otherwise pip fails with
``ERROR: Could not install packages due to an OSError: Missing dependencies
for SOCKS support``. The package is usually called ``pysocks`` or
``python3-socks``, but installing it from the system package manager is not
enough on its own: a fresh ``venv`` cannot see system packages. Either expose
them with ``--python-venv-mode site``
(:ref:`pyinstall_qa_use_system_packages`), or prepare a ``venv`` that has
``pysocks`` installed and activate it before running the script
(:ref:`pyinstall_qa_use_existing_venv`).

.. tip::
   If you already have a working way to fetch packages through the proxy —
   the OS package manager, or a tool such as ``proxychains`` — it is simpler
   to treat the machine as an offline system and pass
   ``--python-use-network disable``, see :ref:`pyinstall_qa_offline_system`.

   Bootstrapping a ``venv`` behind a SOCKS proxy from nothing is a long
   battle: the fresh ``venv`` has neither ``setuptools`` nor ``pysocks``.
   Prepare it while direct Internet access is available, and keep a backup
   copy of the directory.

Q: I don't want to use a Python ``venv`` at all, I want to install Python extensions to the default paths, which is the legacy behavior in previous openEMS versions.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use ``--python-venv-mode disable``.

.. code-block:: bash

   ./update_openEMS.sh ~/opt/openEMS --python --python-venv-mode disable

However, it's strongly recommended to use ``--python-venv-mode site`` as an
alternative to this legacy mode. You can still manage your Python packages
manually like the legacy behavior, but it's both supported by default (e.g.
you can use ``pip3`` to install packages without overriding it via
``--break-system-packages``), and it allows multiple Python environments
and openEMS installations to coexist without polluting ``~/.local`` (e.g.
``~/opt/openEMS_stable/venv`` and ``~/opt/openEMS_dev/venv``).

.. warning::

   To avoid installing conflicting versions of packages, install as few packages
   as possible, meaning that all Python packages marked as optional in the
   :ref:`install_requirements_src` page are recommended be installed.

Q: I'm debugging ``./update_openEMS.sh --python``, but the Python errors are incomprehensible
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Try :ref:`pyinstall_manual` instead to manually perform the Python extension
installation process to better understand the context of the error message.
Check if the relevant error message is documented in the
:ref:`pyinstall_manual_troubleshooting` subsection.

If you are unable to solve the problem, create a post in the
`discussion forum <https://github.com/thliebig/openEMS-Project/discussions>`_.
Make sure to provide detailed information about your system
(operating systems name and version, any error messages, logs,
and debugging outputs).

Q: ``./update_openEMS.sh`` is a black box, I need explicit control over the installation.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* See :ref:`manual_build` to manually perform the C++ installation process.
* See :ref:`pyinstall_manual` to manually perform the Python extension installation process.
