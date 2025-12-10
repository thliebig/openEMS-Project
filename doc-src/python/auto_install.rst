.. _pyinstall_auto:

Install Python Extensions Automatically
========================================

Instructions how to install the **CSXCAD & openEMS Python interface**.

Methods
--------

CSXCAD and Python extensions can be installed using two methods:
automatic install via ``./update_openEMS.sh`` using the ``--python``
flag, or building each Python extension separately.

This page exclusively deals with the recommended script-assisted
auto-installation process.

.. seealso::

   * For context, see :ref:`install_requirements_src` and
     :ref:`clone_build_install_src`.

   * For manual installation, see :ref:`pyinstall_manual`.

Quick Start
------------

In the simplest cases, all one needs is adding the ``--python`` flag
in ``./update_openEMS.sh``. For example, to install the C++ project and
its Python extensions simultaneously to the prefix ``~/opt/openEMS``,
run:

.. code-block:: bash

    ./update_openEMS.sh ~/opt/openEMS --python

In the latest openEMS development version (to be released as v0.0.37),
Python extensions and their dependencies are installed into
an isolated "virtual environment" in the ``venv`` subdirectory (e.g.
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

Your have three possible solutions, pick one of them.

1. **Use** ``--python-use-network disable``: If you're using the system
   on a regular basis, you probably already have a solution for downloading
   new packages using the OS package manager via a proxy. In this case,
   treat the system as a special case of an "offline system" or "system with
   manual package management".

   Therefore, use the ``--python-use-network disable`` argument, see
   :ref:`pyinstall_qa_offline_system`

2. **Use an HTTP Proxy**: See :ref:`pyinstall_qa_http_proxy`

3. **Use a SOCKS Proxy**: See :ref:`pyinstall_qa_socks_proxy`

.. _pyinstall_qa_http_proxy:

Q: I have Internet access, but behind an HTTP proxy.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to use ``pip3`` to manage packages (rather than manage
it manually), but behind a proxy, it's possible to set a global
proxy using the standard environment variable ``https_proxy``
with the format ``[protocol://]<host>[:port]``:

.. code-block:: bash

   # HTTP proxy server for HTTP/HTTPS URLs
   export http_proxy="http://proxy.example.com:8080"
   export https_proxy="http://proxy.example.com:8080"

   # build and install openEMS as usual
   ./update_openEMS.sh ~/opt/openEMS --python

.. _pyinstall_qa_socks_proxy:

Q: I have Internet access, but behind a SOCKS proxy.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A SOCKS proxy has an additional complication.

.. code-block:: bash

   # SOCKS5 proxy server (with remote DNS) for HTTP/HTTPS URLs
   export http_proxy="socks5h://proxy.example.com:8080"
   export https_proxy="socks5h://proxy.example.com:8080"

By default, ``pip3`` is not
compatible with a proxy, due to a missing optional dependency named
``pysocks``. The error ``ERROR: Could not install packages due to an
OSError: Missing dependencies for SOCKS support`` is raised if the
package is not installed. This forces one to ``unset http_proxy && unset
https_porxy``, making the proxy unusable.

.. important::

   To use a SOCKS proxy with ``pip3``, an optional dependency ``pysocks``
   must be installed. This package is usually named ``pysocks``,
   ``python3-socks``, or a similar name. Check your package manager.

However, this brings us to the next problem: a standard ``venv`` is
isolated from all system packages by default. If ``pysocks`` is installed
via the system's package manager, it's still invisible and unusable,
even if it has already been installed!

To solve this sub-problem, there are three sub-solutions, pick one of them.

1. Treat the system as a special case of an "offline system" or "system with
   manual package management". Use the ``--python-use-network disable`` argument.

   See :ref:`pyinstall_qa_offline_system`

2. Expose system packages via ``--python-venv-mode site``.

   See :ref:`pyinstall_qa_use_system_packages`

3. Prepare a "good" venv with ``pysocks`` preinstalled, and active your ``venv``
   before calling ``./update_openEMS.sh``. This is a special case of
   :ref:`pyinstall_qa_use_existing_venv`

   .. code-block:: bash

      # create and activate your own venv
      python3 -m venv ~/venvs/snake/
      source ~/venvs/snake/bin/activate

      # Install pysocks manually while you still have Internet access,
      # pip3 install pysocks

      # or if you have an alternative proxy solution without using
      # Python, such as proxychains.
      # proxychains pip3 install pysocks

      # SOCKS5 proxy server (with remote DNS) for HTTP/HTTPS URLs
      export http_proxy="socks5h://proxy.example.com:8080"
      export https_proxy="socks5h://proxy.example.com:8080"

      # build and install openEMS as usual
      ./update_openEMS.sh ~/opt/openEMS --python


   The third solution is exceedingly difficult on a fully offline system.
   In a fresh ``venv``, there's no ``setuptools`` or ``pysocks``, making it
   difficult to bootstrap the ``venv`` to a usable state. It is practical,
   only if the ``venv`` has already been prepared while direct Internet access
   is still available, or if an external tool such as ``proxychains`` can
   be used to enable the proxy without relying on ``pip3``. Otherwise, the
   bootstrapping process would be a long battle. Make sure to make a backup
   copy of the ``venv`` directory to save your work after completion.

   .. tip::

    If using ``proxychains-ng``, you may have to uncomment the last line
    of ``/etc/proxychains.conf``, and replace it with the parameters of the
    SOCKS proxy, such as::

      socks5 127.0.0.1 8080

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
