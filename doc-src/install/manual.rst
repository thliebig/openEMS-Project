.. _manual_build:

Manual Build and Install
=====================================

During development and testing, it's often necessary to build and
install openEMS manually. Such cases are encountered when creating
a package of openEMS for a new system (especially with non-standard
library paths, like certain servers or HPC environments). It's also
useful when modifying the source code of openEMS without rebuilding
all the git submodules.

If you are an end-user, please try :ref:`clone_build_install_src`
and :ref:`install_readymade_package_src` first. This section is
only used as the last troubleshooting step.

.. tip::
   The following instructions are working as of writing, but it can become
   outdated. If you have difficulties building the project from source,
   refer to these official CI/CD test scripts in the source code. They
   contain all commands necessary for building openEMS on 10+ different
   systems.

   * `openEMS-Project (semi-automatic workflow)
     <https://github.com/thliebig/openEMS-Project/blob/master/.github/workflows/ci.yml>`_
   * `CSXCAD (manual workflow)
     <https://github.com/thliebig/CSXCAD/blob/master/.github/workflows/ci.yml>`_
   * `openEMS (manual workflow)
     <https://github.com/thliebig/openEMS/blob/master/.github/workflows/ci.yml>`_

Install Dependencies
------------------------

Refer to :ref:`install_requirements_src` for a list of dependencies.

To ensure compatibility, we first enable C++11 in the global ``CXXFLAGS``.
This is already the default for most systems, but we do this here to
be safe:

.. code-block:: console

   export CXXFLAGS="-std=c++11"

Install Basic Programs
------------------------

1. Build fparser:

.. code-block:: console

    cd fparser
    mkdir build
    cd build
    cmake ../ -DCMAKE_INSTALL_PREFIX=$HOME/opt/openEMS
    make
    make install

    cd ..

2. Build CSXCAD:

.. code-block:: console

    cd CSXCAD
    mkdir build
    cd build
    cmake ../ -DCMAKE_INSTALL_PREFIX=$HOME/opt/openEMS
    make
    make install

    cd ..

3. Build openEMS. The CMAke variales ``-DFPARSER_ROOT_DIR`` and
``-DCSXCAD_ROOT_DIR`` should be pointed to the install root paths
of fparser and CSXCAD, which are usually the same as
``-DCMAKE_INSTALL_PREFIX``.

.. code-block:: console

    cd openEMS
    mkdir build
    cd build
    cmake ../ -DCMAKE_INSTALL_PREFIX=$HOME/opt/openEMS -DFPARSER_ROOT_DIR=/tmp/opt -DCSXCAD_ROOT_DIR=/tmp/opt
    make
    make install

    cd ..

.. important::

   Don't forget to set ``-DFPARSER_ROOT_DIR`` and ``-DCSXCAD_ROOT_DIR``. They are
   NOT optional.

Download and Build TinyXML from Source
---------------------------------------

Unfortunately, openEMS depends on TinyXML, which is unmaintained since 2011 and
has been removed from Homebrew (TinyXML2 is not API-compatible). As a workaround,
on macOS, ``update_openEMS.sh`` will automatically download TinyXML and patches online,
building it from source.

.. tip::
   Only macOS Homebrew has removed TinyXML. As of writing, it's still available
   in the package manager of most operating systems.

Although no manual intervention is needed anymore, it's sometimes necessary to
understand the inner working of this process. Thus, this section describes the
manual build process without using any script.

- First, we obtain the last available version of TinyXML.

  .. code-block:: console

      # -L: follow redirect, REQUIRED!
      curl -L https://sourceforge.net/projects/tinyxml/files/tinyxml/2.6.2/tinyxml_2_6_2.tar.gz -o tinyxml-2.6.2.tar.gz
      tar -xf tinyxml-2.6.2.tar.gz
      cd tinyxml

- Next, we patch TinyXML to fix several known compatibility and security
  vulnerability. These patches came from various sources, and are applied
  by Homebrew, Debian, Alpine by their respective package maintainers.
  Here, we choose patches as maintained by AlpineLinux.

  .. code-block:: console

      # The first patch enforces use of stl strings, rather than a custom string type.
      # The second patch is a fix for incorrect encoding of elements with special characters
      # The third and fourth patches are security fixes.
      #
      # -L: follow redirect, REQUIRED!
      # -O: save to disk with an automatic file name.
      curl -L -O "https://raw.githubusercontent.com/alpinelinux/aports/b1ff376e83eb49c0127b039b3684eccdf9a60694/community/tinyxml/tinyxml-2.6.2-defineSTL.patch"
      curl -L -O "https://raw.githubusercontent.com/alpinelinux/aports/b1ff376e83eb49c0127b039b3684eccdf9a60694/community/tinyxml/tinyxml-2.6.1-entity.patch"
      curl -L -O "https://raw.githubusercontent.com/alpinelinux/aports/b1ff376e83eb49c0127b039b3684eccdf9a60694/community/tinyxml/CVE-2021-42260.patch"
      curl -L -O "https://raw.githubusercontent.com/alpinelinux/aports/b1ff376e83eb49c0127b039b3684eccdf9a60694/community/tinyxml/CVE-2023-34194.patch"

      patch -p1 < tinyxml-2.6.2-defineSTL.patch
      patch -p1 < tinyxml-2.6.1-entity.patch
      patch -p1 < CVE-2021-42260.patch
      patch -p1 < CVE-2023-34194.patch

- Then, we introduce CMake support to TinyXML:

  .. code-block:: console

      # The final patch adds a CMakeLists.txt file to build a shared library and provide an install target
      # submitted upstream as https://sourceforge.net/p/tinyxml/patches/66/
      curl -L -O "https://gist.githubusercontent.com/scpeters/6325123/raw/cfb079be67997cb19a1aee60449714a1dedefed5/tinyxml_CMakeLists.patch"

      # You know something is truly deprecated when the patch itself needs
      # patching! In CMake 4, 3.10 is deprecated and 3.5 has been removed.
      # Replace "cmake_minimum_required(VERSION 2.4.6)" in the patch with
      # "cmake_minimum_required(VERSION 3.0...3.10)".
      sed -i -e "s/cmake_minimum_required(VERSION 2.4.6)/cmake_minimum_required(VERSION 3.0...3.10)/" \
                tinyxml_CMakeLists.patch  # -e is not optional in BSD sed
      patch -p1 < tinyxml_CMakeLists.patch

- Finally, TinyXML can be installed to a custom user directory. Here, we use
  ``$HOME/opt/openEMS`` as an example. This directory must match the directory later
  used for installing openEMS.

  .. code-block:: console

      mkdir build && cd build
      cmake ../ -DCMAKE_INSTALL_PREFIX=$HOME/opt/openEMS
      make && make install

Install Python bindings (optional)
------------------------------------

See :ref:`python_binding_build_manual`.

Install AppCSXCAD GUI (optional)
------------------------------------

1. Build QCSXCAD:

.. code-block:: console

    cd QCSXCAD
    mkdir build
    cd build
    cmake ../ -DCMAKE_INSTALL_PREFIX=$HOME/opt/openEMS
    make
    make install

    cd ..

2. Build AppCSXCAD:

.. code-block:: console

    cd AppCSXCAD
    mkdir build
    cd build
    cmake ../ -DCMAKE_INSTALL_PREFIX=$HOME/opt/openEMS
    make
    make install

    cd ..

openEMS search path
--------------------

After the build is complete, add ``~/openEMS/bin`` into your search
path::

    export PATH="$HOME/openEMS/bin:$PATH"

You need to write this line into your shell's profile, such as ``~/.bashrc``
or ``~/.zshrc`` to make this change persistent.

Setup the Octave/Matlab or Python Interfaces
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Optional:** Setup the Octave/Matlab environment, see :ref:`Octave Interface Install <octaveinstall>`
- **Optional:** Install the Python modules, see :ref:`Python Interface Install <pyinstall>`
