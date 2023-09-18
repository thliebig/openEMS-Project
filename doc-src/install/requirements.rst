.. _install_requirements_src:

Requirements
=======================

Debian/Ubuntu
--------------

- openEMS depends on the following packages for minimum functionality:

.. code-block:: console

    sudo apt-get install build-essential cmake git libhdf5-dev libvtk9-dev \
                         libboost-all-dev libcgal-dev libtinyxml-dev 

**Note:** For earlier versions of Ubuntu you may have to choose an older later
version of vtk, such as libvtk7-dev. VTK7 is the lowest version supported.

- To use AppCSXCAD to visualize 3D models (recommended):

.. code-block:: console

    sudo apt-get install qtbase5-dev libvtk9-qt-dev

- To use Octave scripting (recommended):

.. code-block:: console

    sudo apt-get install octave liboctave-dev

- To use Python scripting (recommended):

.. code-block:: console

    sudo apt-get install python3-numpy python3-matplotlib cython3 python3-h5py

- To use Paraview to visualize simulation results (recommended):

.. code-block:: console

    sudo apt-get install paraview

- For the package hyp2mat_ you need additional dependencies (optional):

.. code-block:: console

    sudo apt-get install gengetopt help2man groff pod2pdf bison flex \
                         libhpdf-dev libtool

Fedora
-------

- openEMS depends on the following packages for minimum functionality:

.. code-block:: console

    sudo dnf install cmake git \
                     boost-devel tinyxml-devel \
                     vtk-devel hdf5-devel CGAL-devel

- To use AppCSXCAD to visualize 3D models (recommended):

.. code-block:: console

    sudo dnf install vtk-qt

- To use Octave scripting (recommended):

.. code-block:: console

    sudo dnf install octave

- To use Python scripting (recommended):

.. code-block:: console

    sudo dnf install python3-Cython python3-h5py python3-matplotlib

- To use Paraview to visualize simulation results (recommended):

.. code-block:: console

    sudo dnf install paraview

- For the package hyp2mat_ you need additional dependencies (optional):

.. code-block:: console

    sudo dnf install gengetopt help2man groff perl-pod2pdf bison flex \
                     libharu-devel

FreeBSD
--------

openEMS can be installed directly via FreeBSD Ports, there's no need to
install dependencies manually.
Please skip to
:ref:`Install Ready-Made Package on FreeBSD <install_readymade_freebsd_package_src>`
for more information.

Also, note that On FreeBSD, the default CMake has a bug, causing it unable
to find HDF5 for CSXCAD and openEMS (the ready-made package in FreeBSD Ports
is fine). If you want to build openEMS manually, see :ref:`_manual_freebsd_workaround_src`
for its workaround.

.. code-block:: console

    sudo pkg install cmake git boost-libs tinyxml \
                     vtk9 hdf5 cgal qt5


- To use AppCSXCAD to visualize 3D models (recommended):

.. code-block:: console

    sudo pkg install qt5

macOS
-----

openEMS can be installed via a Homebrew formula, there's no need to install
dependencies manually.
Please skip to
:ref:`Install Ready-Made Package on macOS <install_readymade_macos_package_src>`
for more information.

The follow instructions are given for developers only, one should follow
these instructions only if a manual install is needed during development.

.. code-block:: console

    brew install cmake boost tinyxml hdf5 cgal vtk

- To use Octave scripting (recommended):

.. code-block:: console

    brew install octave

- To use Python scripting (recommended):

.. code-block:: console

    pip3 install cython numpy h5py matplotlib --user

- To use Paraview to visualize simulation results (recommended):

.. code-block:: console

    brew install paraview

Windows
------------

openEMS can be installed directly as a pre-built binary package, there is
no need to install dependencies (or build openEMS from source) manually.
Please skip to
:ref:`Install Ready-Made Package on Windows <install_readymade_windows_package_src>`
for more information.

The follow instructions are given for developers only, one should follow
these instructions only if a manual install is needed during development.

One can build openEMS on Windows using two different methods. The first
method is using MSVC, this is how the official pre-built package is prepared,
but it has a long and complicated procedure, and is currently undocumented.

Alternatively, MinGW-w64 and MSYS2 can be used.

.. _hyp2mat: https://github.com/koendv/hyp2mat
.. _MSYS2: https://www.msys2.org/
