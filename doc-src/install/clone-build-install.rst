.. _clone_build_install_src:

Clone, Build and Install
============================

This section describes how to install CSXCAD and openEMS from
source and build everything automatically via ``./update_openEMS.sh``.

For FreeBSD and Windows users, the easiest option is to install
ready-made packages instead, please refer to
:ref:`install_readymade_package_src` - although they may not be
up-to-date and can contain known problems.

Quick Start
--------------

Clone
~~~~~

Clone this repository, build openEMS and install e.g. to ``~/opt/openEMS``:

.. code-block:: bash

    git clone --recursive https://github.com/thliebig/openEMS-Project.git
    cd openEMS-Project

Build and Install
~~~~~~~~~~~~~~~~~~

To build and install openEMS automatically, run (assuming that
we want to install openEMS into ``~/opt/openEMS``):

.. code-block:: bash

   ./update_openEMS.sh ~/opt/openEMS

Extra features can be controlled by additional command-line arguments.
For example, to build openEMS with :program:`CTB` and :program:`Python`:

.. code-block:: bash

    ./update_openEMS.sh ~/opt/openEMS --with-CTB --python

.. seealso::

   * The ``--python`` argument accepts additional options for greater control over the
     installation process, see :ref:`pyinstall_auto` for details.

   * openEMS can be built manually by installing each component separately
     using :program:`CMake`, :program:`make`, and :program:`make install`.
     For brevity, only the automatic method is documented here. If it's
     necessary to build and install openEMS manually for development or
     or debugging, see :ref:`manual_build`.

openEMS search path
~~~~~~~~~~~~~~~~~~~

After the build is complete, add ``~/opt/openEMS/bin`` into your search
path::

    export PATH="$HOME/opt/openEMS/bin:$PATH"

You need to write this line into your shell's profile, such as ``~/.bashrc``
or ``~/.zshrc`` to make this change persistent.

Setup the Octave/Matlab or Python Interfaces
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Optional:** Setup the Matlab or Octave_ environment, see :ref:`Octave Interface Install <Octave Linux Install>`
- **Optional:** Install the Python_ extensions, see :ref:`Python Interface Install <pyinstall>`

Check Installation
~~~~~~~~~~~~~~~~~~~

After completing installation, now it's a good test to verify that
the installation is functional according to :ref:`check_installation_src`.


Advanced Install
---------------------

Optional Arguments
~~~~~~~~~~~~~~~~~~~

Passing these arguments to enable, disable, or adjust extra features:

.. option:: --verbose

   Print build outputs to the console, in addition to the log file.

.. option:: --njobs <JOBS>

   Use ``<JOBS>`` threads to compile the project. By default, it's
   set to the number of logical CPUs. If Out-Of-Memory errors occur,
   You may need to reduce its value.

.. option:: --python

   Build Python extensions, recommended.

   .. seealso::

      The ``--python`` argument accepts additional options for greater control over the
      installation process, see :ref:`pyinstall_auto` for details.

.. option:: --with-CTB

   Enable *Circuit Toolbox*, an optional Matlab/Octave library for processing
   RF circuit data, recommended for Matlab/Octave programmers.

.. option:: --with-hyp2mat

   Enable :program:`hyp2mat` for converting HyperLynx PCB layouts to simulation
   geometry. It still compiles, but is now unmaintained, not recommended.

.. option:: --with-MPI

   Build MPI engine version, the regular multi-thread engine is disabled. Only
   needed for cluster, not recommended.

.. option:: --disable-GUI

   Disable :program:`AppCSXCAD` GUI for viewing simulation models, useful for servers.

.. option:: --with-tinyxml

   Download and build a custom installation of TinyXML from source, need network
   access to SourceForge and GitHub. Enabled by default on macOS, as TinyXML
   is desupported by Homebrew.

Build TinyXML Without Network Access on macOS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

On macOS, TinyXML has been desupported by Homebrew. By default,
``./update_openEMS.sh`` automatically downloads and builds a local
copy of TinyXML from SourceForge and GitHub. In most cases, this step
is performed transparently without user intervention.

However, this can be a problem if network access is restricted or
unavailable. Ordinary users can overcome the problem using the following
solution.

.. tip::
  For packagers, sysadmins and developers who needs to understand inner working of
  the custom TinyXML build, read the source code of ``scripts/build_tinyxml.sh``.
  Additional technical information is also available in :ref:`manual_build`.

Pre-download TinyXML Files via a Proxy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Internally, ``./update_openEMS.sh`` calls ``scripts/build_tinyxml.sh``, which
uses ``curl`` for fetching files from HTTPS URLs.
If network access is restricted, it's possible to set a global proxy using the
standard environment variable ``https_proxy`` with the format
``[protocol://]<host>[:port]``.

.. code-block:: bash

   # HTTP proxy server for HTTPS URLs
   export https_proxy="http://proxy.example.com:8080"

   # SOCKS5 proxy server (with remote DNS) for HTTPS URLs
   export https_proxy="socks5h://proxy.example.com:8080"

   mkdir -p downloads
   scripts/build_tinyxml.sh --download

.. important::

   If a SOCKS proxy is used, one must disable this proxy before
   running ``./update_openEMS.sh``. By default, ``pip3`` is not
   compatible with a proxy, due to a missing optional dependency
   ``pysocks`` with the error ``ERROR: Could not install packages
   due to an OSError: Missing dependencies for SOCKS support``.
   For more information, see :ref:`pyinstall_qa_proxy`

   .. code-block:: bash

       unset https_proxy

Pre-download TinyXML Files Externally
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If all files in ``downloads`` have correct SHA-256 digests, all network accesses
and downloads are skipped, the existing files are reused. Thus, it's also
possible to manually download them from another machine or using other tools, then
copying them into ``downloads`` later to the target machine.

.. code-block:: console

   Skip download (file exists, hash valid): /home/fdtd/openEMS-Project/downloads/tinyxml-2.6.2.tar.gz
   Skip download (file exists, hash valid): /home/fdtd/openEMS-Project/downloads/tinyxml-2.6.2-defineSTL.patch
   Skip download (file exists, hash valid): /home/fdtd/openEMS-Project/downloads/tinyxml-2.6.1-entity.patch
   Skip download (file exists, hash valid): /home/fdtd/openEMS-Project/downloads/CVE-2021-42260.patch
   Skip download (file exists, hash valid): /home/fdtd/openEMS-Project/downloads/CVE-2023-34194.patch
   Skip download (file exists, hash valid): /home/fdtd/openEMS-Project/downloads/tinyxml_CMakeLists.patch

Build Python Extensions Without Network Access
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If Python is also needed for an offline installation, use:

.. code-block:: bash

    ./openEMS_Project.sh --python --python-use-network disable

Before running this script, all Python packages marked as optional
in the :ref:`install_requirements_src` page should be installed,
such as ``cython``. See :ref:`install_requirements_src` for the full
list.

.. seealso::

   For detailed guidance, see :ref:`pyinstall_auto`.

Update Instruction
-------------------

Perform an update in case of a new release.

.. code-block:: bash

    cd openEMS-Project
    git pull --recurse-submodules
    ./update_openEMS.sh ~/opt/openEMS --python

.. warning::

   Changes you may have made (e.g. to the tutorials or examples) may be overwritten.

.. _Python: https://www.python.org/
.. _Octave: https://octave.org/
