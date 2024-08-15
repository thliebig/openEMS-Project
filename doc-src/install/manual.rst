
Manual Build and Install
=====================================

During development and testing, it's often necessary to build and
install openEMS manually. Such cases are encountered when creating
a package of openEMS for a new system (especially with non-standard
library paths, like certain servers or HPC environments). It's also
useful when modifying the source code of openEMS without rebuilding
all the git submodules.

If you are an end-user, please refer to :ref:`clone_build_install_src`
and :ref:`install_readymade_package_src` instead.

Install Dependencies
------------------------

Refer to :ref:`install_requirements_src` for a list of dependencies.

Install Basic Programs
------------------------

1. Build fparser:

.. code-block:: console

    cd fparser
    mkdir build
    cd build
    cmake ../ -DCMAKE_INSTALL_PREFIX=/home/user/openEMS
    make
    make install

    cd ..

2. Build CSXCAD:

.. code-block:: console

    cd CSXCAD
    mkdir build
    cd build
    cmake ../ -DCMAKE_INSTALL_PREFIX=/home/user/openEMS
    make
    make install

    cd ..

3. Build openEMS. The CMAke variales `-DFPARSER_ROOT_DIR` and
`-DCSXCAD_ROOT_DIR` should be pointed to the install root paths
of fparser and CSXCAD, which are usually the same as
`-DCMAKE_INSTALL_PREFIX`.

.. code-block:: console

    cd openEMS
    mkdir build
    cd build
    cmake ../ -DCMAKE_INSTALL_PREFIX=/home/user/openEMS -DFPARSER_ROOT_DIR=/tmp/opt -DCSXCAD_ROOT_DIR=/tmp/opt
    make
    make install

    cd ..


Install Python bindings (optional)
------------------------------------

1. Build CSXCAD's Python extension.

.. code-block:: console

    cd CSXCAD
    cd python
    python3 setup.py install --user

    cd ..

2. Build openEMS's Python extension:

.. code-block:: console

    cd openEMS
    cd python
    python3 setup.py install --user

    cd ..


Install AppCSXCAD GUI (optional)
------------------------------------

1. Build QCSXCAD:

.. code-block:: console

    cd QCSXCAD
    mkdir build
    cd build
    cmake ../ -DCMAKE_INSTALL_PREFIX=/home/user/openEMS
    make
    make install

    cd ..

2. Build AppCSXCAD:

.. code-block:: console

    cd AppCSXCAD
    mkdir build
    cd build
    cmake ../ -DCMAKE_INSTALL_PREFIX=/home/user/openEMS
    make
    make install

    cd ..

openEMS search path
--------------------

After the build is complete, add `~/openEMS/bin` into your search
path:

    export PATH="$HOME/openEMS/bin:$PATH"

You need to write this line into your shell's profile, such as `~/.bashrc`
or `~/.zshrc` to make this change persistent.

Setup the Octave/Matlab or Python Interfaces
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Optional:** Setup the Octave/Matlab environment, see :ref:`Octave Interface Install <Octave Windows Install>`
- **Optional:** Install the Python modules, see :ref:`Python Interface Install <Python Windows Install>`

Troubleshooting
----------------

.. _manual_freebsd_workaround_src:

HDF5 Not Found
^^^^^^^^^

On FreeBSD, the default CMake has a bug, causing it unable to find
HDF5 for CSXCAD and openEMS (the version in FreeBSD Ports is fine).
This can also happen on macOS.

.. code-block:: console

    CMake Error at /usr/local/share/cmake/Modules/FindPackageHandleStandardArgs.cmake:230 (message):
      Could NOT find HDF5 (missing: HDF5_LIBRARIES HDF5_HL_LIBRARIES) (found
      suitable version "1.12.2", minimum required is "1.8")
    Call Stack (most recent call first):
      /usr/local/share/cmake/Modules/FindPackageHandleStandardArgs.cmake:600 (_FPHSA_FAILURE_MESSAGE)
      /usr/local/share/cmake/Modules/FindHDF5.cmake:1007 (find_package_handle_standard_args)
      CMakeLists.txt:116 (find_package)

If it happens, please change the following line in `CMakeLists.txt`:

.. code-block:: console

    find_package(HDF5 1.8 COMPONENTS C HL REQUIRED)

To:

.. code-block:: console

    find_package(HDF5 COMPONENTS C HL REQUIRED)
