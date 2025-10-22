.. _clone_build_install_src:

Clone, Build and Install
============================

This section describes how to install openEMS from source
and build everything automatically via ``./update_openEMS.sh``.

For macOS and Windows users, the easiest option is to install
ready-made packages instead, please refer to
:ref:`install_readymade_package_src` - although they may not
be up-to-date and can contain known problems.

Clone
--------

- Clone this repository, build openEMS and install e.g. to ``~/opt/openEMS``:

.. code-block:: console

    git clone --recursive https://github.com/thliebig/openEMS-Project.git
    cd openEMS-Project

Python venv
-------------

On most systems, openEMS installs Python into the current user's home
directory, such as ``~/.local``, while all of its dependencies came from
the system's package manager. This is the "classical" behavior of openEMS,
no user intervention is needed, and this section can be safely skipped.

However, sometimes it can be desirable to keep Python packages in an
isolated environment, or even necessary (in case of macOS). If so, this
must be planned beforehand.
Here, we use ``$HOME/opt/openEMS`` as an example. For consistency, this
directory is the same directory later used to install openEMS.

.. code-block:: console

   python3 -m venv $HOME/opt/openEMS
   $HOME/opt/openEMS/bin/pip3 install setuptools cython numpy h5py matplotlib

Prior to invoking ``./update_openEMS.sh --python``, activate the venv first::

   source $HOME/opt/openEMS/bin/activate

Remember, if Python has been installed to an isolated venv,
all openEMS installations and simulations can only be executed inside that
venv. Likewise, only Python packages installed into the venv can be seen.

.. tip::
   See :ref:`Python Install <pyinstall>` for more information.

Build and Install
------------------

openEMS can be built automatically via ``./update_openEMS.sh``, or
manually by installing each component separately using CMake, make,
and make install. For brevity, only the automatic method is documented
here. If it's necessary to build and install openEMS manually for
development and testing, please go to Section Manual Build.

To build and install openEMS automatically, run (assuming that
we want to install openEMS into ``~/opt/openEMS``):

.. code-block:: console

   ./update_openEMS.sh ~/opt/openEMS

- **Optional:** Passing these options can be used to enable or disable extra features:

  * ``--python``: Build Python extensions (recommended).
  * ``--with-CTB``: Enable circuit toolbox (requires Matlab).
  * ``--with-hyp2mat``: Enable hyp2mat for HyperLynx PCB layouts (unmaintained, not recommended).
  * ``--with-MPI``: Build MPI engine (only needed for cluster, not recommended).
  * ``--disable-GUI``: Disable AppCSXCAD GUI, useful for servers.
  * ``--with-tinyxml``: Download and build custom TinyXML from source, need network access to
    SourceForge and GitHub. Enabled by default on macOS, as TinyXML is desupported by Homebrew.

For example, to build openEMS with CTB and python_:

.. code-block:: console

    ./update_openEMS.sh ~/opt/openEMS --with-CTB --python

Build TinyXML Without Network Access on macOS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

On macOS, TinyXML has been desupported by Homebrew. By default,
``./update_openEMS.sh`` automatically downloads and builds a local
copy of TinyXML from SourceForge and GitHub.
In most cases, this step is performed transparently without user intervention.

However, this can be a problem if network access is restricted or unavailable.
Internally, ``./update_openEMS.sh`` calls ``scripts/build_tinyxml.sh``, which
uses ``curl`` for fetching files from HTTPS URLs. If network access is restricted,
it's possible to set a global proxy using the standard environmental variable
``https_proxy`` with the format ``[protocol://]<host>[:port]``. After the proxy
is set, one can use ``./update_openEMS.sh`` as usual.

For example:

.. code-block:: console

   # HTTP proxy server for HTTPS URLs
   export https_proxy="http://proxy.example.com:8080"

   # SOCKS5 proxy server (with remote DNS) for HTTPS URLs
   export https_proxy="socks5h://proxy.example.com:8080"

If the system in question is completely offline, the openEMS build script
also supports predownloading files to overcome this problem:

.. code-block:: console

   mkdir -p downloads
   scripts/build_tinyxml.sh --download

After running this script, the ``downloads`` directory now contains necessary
files for building TinyXML from scratch. This directory can be copied to the
``openEMS-Project`` directory of the target system, allowing
``./update_openEMS.sh`` to run as usual.

If all files in ``downloads`` have correct SHA-256 digests, all network accesses
and downloads are skipped, the existing files are reused. Thus, it's also
possible to manually download them using other tools, and copying them into
``downloads`` later.

.. code-block:: console

   Skip download (file exists, hash valid): /home/fdtd/openEMS-Project/downloads/tinyxml-2.6.2.tar.gz
   Skip download (file exists, hash valid): /home/fdtd/openEMS-Project/downloads/tinyxml-2.6.2-defineSTL.patch
   Skip download (file exists, hash valid): /home/fdtd/openEMS-Project/downloads/tinyxml-2.6.1-entity.patch
   Skip download (file exists, hash valid): /home/fdtd/openEMS-Project/downloads/CVE-2021-42260.patch
   Skip download (file exists, hash valid): /home/fdtd/openEMS-Project/downloads/CVE-2023-34194.patch
   Skip download (file exists, hash valid): /home/fdtd/openEMS-Project/downloads/tinyxml_CMakeLists.patch

.. tip::
  For packagers, sysadmins and developers who needs to understand inner working of
  the custom TinyXML build, read the source code of ``scripts/build_tinyxml.sh``.
  Additional technical information is also available in :ref:`manual_build`.

openEMS search path
--------------------

After the build is complete, add ``~/opt/openEMS/bin`` into your search
path::

    export PATH="$HOME/opt/openEMS/bin:$PATH"

You need to write this line into your shell's profile, such as `~/.bashrc`
or `~/.zshrc` to make this change persistent.

Setup the Octave/Matlab or Python Interfaces
--------------------------------------------

- **Optional:** Setup the Octave/Matlab environment, see :ref:`Octave Interface Install <Octave Linux Install>`
- **Optional:** Install the Python modules, see :ref:`Python Interface Install <Python Linux Install>`

Check Installation
-------------------

After completing installation, now it's a good test to verify that
the installation is functional according to :ref:`check_installation_src`.

Update Instruction
-------------------

- Perform an update in case of a new release

  **Note:** Changes you may have made (e.g. to the tutorials or examples) may be overwritten!

  .. code-block:: console

      cd openEMS-Project
      git pull --recurse-submodules
      ./update_openEMS.sh ~/opt/openEMS --python

.. _python: https://www.python.org/
.. _octave: https://octave.org/
