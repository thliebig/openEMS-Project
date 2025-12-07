.. _install_requirements_src:

Requirements
=======================

The following section describes the dependency requirements of building
CSXCAD and openEMS on many systems. It's used for both the semi-automatic
and manual installation, as described in :ref:`clone_build_install_src`,
:ref:`manual_build`.  and :ref:`manual_doc_build` respectively.
The former is recommended for general use, while the latter is recommended
for development, troubleshooting, or usage on non-standard systems.

.. tip::
   The following instructions are working at the time of writing, but it can become
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

Hardware Requirements
-----------------------

All CPU architectures are supported on Unix-like operating systems, such as
ARM, POWER, x86_64, RISC-V.
In addition, x86 and x86_64 CPUs are
supported on Windows via MSVC.

In the past, a "supported CPU check" was used , but it has been removed.
There's no hardcoded "CPU checks" to artificially limit the project to a
particular CPU.

The main simulation engine is known as the :program:`SSE` engine, but it's
misnomer. The :program:`SSE` engine uses GCC's vector extension with 64-bit
vectors, which compiles to *SSE* on x86 CPUs, *AltiVec* on IBM POWER, *NEON*
on ARM, and scalar code on a generic CPU with vectorization disabled.

.. tip::

   * 64-bit CPUs and operating systems are not required, but strongly recommended.
     32-bit systems impose severe limitations on the simulation problem size.

   * If you have a CPU-specific build failure (such as RISC-V), it's considered
     a bug. Please report the problem to the project's bug tracker.

Minimum Dependency Versions
----------------------------

The following list shows the minimum dependency versions supported by openEMS

* CMake 3.0
* GCC 4.8
* Boost 1.55
* VTK 6.0
* CGAL 4.0

  * CGAL 4.14.3 is the last version supported by GCC 4.8.

* Qt 4

  * VTK's Qt must be linked to the same Qt version as QCSXCAD/AppCSXCAD.

Install From Package Manager
-------------------------------

Alpine
~~~~~~~

- openEMS depends on the following packages for minimum functionality:

  .. code-block:: bash

      doas apk add bash \
                   build-base gmp-dev mpfr-dev git cmake \
                   boost-dev tinyxml-dev hdf5-dev cgal-dev vtk-dev

- AppCSXCAD is used to visualize 3D models (recommended, but optional):

  .. code-block:: bash

      # To build a custom VTK, first remove the system package's
      # development files
      doas apk del vtk-dev

      # Install VTK build-time dependencies, prepare to build it from source!
      doas apk add qt6-qtbase-dev qt6-qtdeclarative-dev qt6-qtdeclarative-private-dev \
                   qt6-qt5compat-dev

  .. warning::

     VTK with Qt does not exist on Alpine, installing it via the package
     manager is not possible. If you're using Alpine, please report a
     bug to Alpine developers.
     After installing the build-time dependencies above, use the workaround below:
     :ref:`build_deps_from_source`. Alternatively, disable the GUI while
     building openEMS with ``./update_openEMS.sh --disable-GUI``.

- To use Octave scripting (recommended):

  .. code-block:: bash

      doas apk add octave

- To use Python scripting (recommended):

  .. code-block:: bash

      doas apk add python3-dev py3-pip

- By default, one doesn't need to install other Python packages here.
  The ``update_openEMS.sh`` script installs them automatically via ``pip``
  into an isolated virtual environment (``venv``). However, if one
  wants to manage Python dependencies externally outside ``pip``, use
  the system's package manager (optional):

  .. code-block:: bash

      doas apk add py3-setuptools py3-setuptools_scm cython \
                   py3-numpy py3-h5py py3-matplotlib

- To use ParaView to visualize simulation results (recommended):

  .. warning::

     ParaView does not exist on Alpine, installing it via the package
     manager is not possible. If you're using Alpine, please open a
     feature request to Alpine developers. In the meantime, you can
     download a pre-compiled binary version of ParaView as a tarball at
     the official website: `<https://www.paraview.org/download/>`_.

- Skip to :ref:`clone_build_install_src` and continue installation.

AlmaLinux
~~~~~~~~~~

- openEMS requires additional packages not included in the standard repository,
  which can be enabled by the following command:

  .. code-block:: bash

      sudo dnf install -y epel-release

      # use "crb" for AlmaLinux 8 and later, use "powertools" for AlmaLinux 7
      sudo dnf config-manager --set-enabled crb
      sudo dnf config-manager --set-enabled powertools

- openEMS depends on the following packages for minimum functionality:

  .. code-block:: bash

      # install git first to avoid dependency graph conflicts
      sudo dnf install git

      sudo dnf install git gcc gcc-c++ cmake \
                       boost-devel tinyxml-devel hdf5-devel vtk-devel CGAL-devel

  .. warning::

     On AlmaLinux 10, at the time of writing, packages ``vtk-devel``, ``vtk-qt``
     and ``octave`` doesn't exist, openEMS cannot be installed on AlmaLinux 10.
     See:

     * https://bugzilla.redhat.com/show_bug.cgi?id=2374130
     * https://bugzilla.redhat.com/show_bug.cgi?id=2419727

- To use AppCSXCAD to visualize 3D models (recommended):

  .. code-block:: bash

      sudo dnf install vtk-qt

- To use Octave scripting (recommended):

  .. code-block:: bash

      sudo dnf install octave

- To use Python scripting (recommended):

  .. code-block:: bash

      sudo dnf install python3-pip

- By default, one doesn't need to install other Python packages here.
  The ``update_openEMS.sh`` script installs them automatically via ``pip``
  into an isolated virtual environment (``venv``). However, if one
  wants to manage Python dependencies externally outside ``pip``, use
  the system's package manager (optional):

  .. code-block:: bash

      sudo dnf install python3-setuptools python3-wheel python3-setuptools_scm \
                       python3-Cython python3-numpy python3-h5py \
                       python3-matplotlib

- To use ParaView to visualize simulation results (recommended):

  .. code-block:: bash

      sudo dnf install paraview

- Skip to :ref:`clone_build_install_src` and continue installation.

CentOS 7
~~~~~~~~~~~

openEMS continues to support legacy systems when it's practical, including
CentOS 7, but additional steps are required.

- CentOS repos are EOL and desupported. For a fresh installation, the following
  steps are required to bring the package manager back into a functional state:

  .. warning::
     CentOS 7 no longer receives security updates. Use at your own risk.

  .. code-block:: bash

      # change all mentions of mirror.centos.org to vault.centos.org
      sed -i 's|^mirrorlist|#mirrorlist|g; s|^#baseurl|baseurl|g; s|mirror.centos.org|vault.centos.org|g' \
          /etc/yum.repos.d/CentOS-Base.repo

- openEMS requires additional packages not included in the standard repository,
  which can be enabled by the following command:

  .. code-block:: bash

      yum install centos-release-scl

      # change all mentions of mirror.centos.org to vault.centos.org
      sed -i 's|^mirrorlist|#mirrorlist|g; s|^#baseurl|baseurl|g;
              s|^# baseurl|baseurl|g; s|mirror.centos.org|vault.centos.org|g' \
          /etc/yum.repos.d/CentOS-SCLo-scl.repo \
          /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo

      yum install epel-release

- openEMS depends on the following packages for minimum functionality:

  .. code-block:: bash

      # install git first to avoid dependency graph conflicts
      yum install git

      yum install gcc gcc-c++ gmp-devel mpfr-devel \
                  git tinyxml-devel hdf5-devel

- CentOS 7 has CMake 2 by default, but we require CMake 3:

  .. code-block:: bash

      # use cmake3 instead of default cmake2
      yum install cmake3
      alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake3 99

- ``boost-predef`` is only available on Boost 1.55 and later. Without it,
  the error "fatal error: boost/predef.h: No such file or directory" occurs.
  We can build the latest version of Boost from source. But as CentOS 7 is
  already a frozen platform, we can try some non-standard tricks here
  and get away from it. Here, we borrow a copy of Boost 1.58 from rh repo's
  ``mariadb`` backport package.

  .. code-block:: bash

      yum install -y rh-mariadb101-boost-devel

      # copy it into /usr/local, so it can be found in the standard system
      # search path
      ln -s /opt/rh/rh-mariadb101/root/usr/include/boost /usr/local/include/boost
      mkdir /usr/local/lib64 && cd /usr/local/lib64
      for i in /opt/rh/rh-mariadb101/root/usr/lib64/libboost*; do
          ln -s $i /usr/local/lib64/
      done

- CentOS 7 uses GCC 4.8, which has only partial C++11 support, but it's currently
  sufficient to build CSXCAD or openEMS.

  .. warning::
     Manual ``-std=`` options are no longer needed in ``CXXFLAGS``. Before
     building CSXCAD or openEMS, one should remove all ``-std=`` options
     from ``CXXFLAGS``. This flag is now managed by CMake. See
     :ref:`remove_cxx11` for details.

- Install CGAL:

  .. important::

     CGAL v4.14.3 must be built from source, see :ref:`build_deps_from_source`.

- To use AppCSXCAD to visualize 3D models (recommended):

  .. code-block:: bash

      yum install vtk-qt

- To use Octave scripting (recommended):

  .. code-block:: bash

     yum install octave

- To use Python scripting (recommended):

  .. code-block:: bash

     yum install python3-devel python3-pip

- By default, one doesn't need to install other Python packages here.
  The ``update_openEMS.sh`` script installs them automatically via ``pip``
  into an isolated virtual environment (``venv``). However, if one
  wants to manage Python dependencies manually:

  .. code-block:: bash

      yum install python3-Cython

      # system packages are incompatible, must be manually
      # installed via pip
      pip3 install numpy h5py matplotlib --user

- Skip to :ref:`clone_build_install_src` and continue installation.

Debian/Ubuntu
~~~~~~~~~~~~~~

- openEMS depends on the following packages for minimum functionality:

  .. code-block:: bash

      sudo apt-get install build-essential cmake git libhdf5-dev libvtk9-dev \
                           libboost-all-dev libcgal-dev libtinyxml-dev

- To use AppCSXCAD to visualize 3D models (recommended):

  .. code-block:: bash

      sudo apt-get install qtbase5-dev libvtk9-qt-dev

- To use Octave scripting (recommended):

  .. code-block:: bash

      sudo apt-get install octave liboctave-dev

- To use Python scripting (recommended):

  .. code-block:: bash

      sudo apt-get install python3-pip python3-venv

- By default, one doesn't need to install other Python packages here.
  The ``update_openEMS.sh`` script installs them automatically via ``pip``
  into an isolated virtual environment (``venv``). However, if one
  wants to manage Python dependencies externally outside ``pip``, use
  the system's package manager (optional):

  .. code-block:: bash

      sudo apt-get install python3-setuptools python3-setuptools-scm \
                           python3-numpy python3-matplotlib python3-h5py

- To use ParaView to visualize simulation results (recommended):

  .. code-block:: bash

      sudo apt-get install paraview

- For the package hyp2mat_ you need additional dependencies (optional):

  .. code-block:: bash

      sudo apt-get install gengetopt help2man groff pod2pdf bison flex \
                           libhpdf-dev libtool

- Skip to :ref:`clone_build_install_src` and continue installation.

Legacy Debian/Ubuntu
^^^^^^^^^^^^^^^^^^^^^^

openEMS continues to support legacy systems when it's practical, including
Debian ``oldoldstable`` and Ubuntu 14.04. These additional steps are
required.

Debian/Ubuntu
"""""""""""""""

- Instead of ``libvtk9-dev``, on earlier versions of Debian/Ubuntu, you need to
  choose an older version of vtk. Both ``libvtk7-dev`` and ``libvtk6-dev`` are
  still supported.

  .. code-block:: bash

      # you can use VTK9
      sudo apt-get install libvtk9-dev libvtk9-qt-dev

      # or VTK7
      sudo apt-get install libvtk7-dev libvtk7-qt-dev

      # or VTK6
      # note: libvtk6-qt-dev is not used on Ubuntu 14.04, only libvtk6-dev is required
      sudo apt-get install libvtk6-dev

Ubuntu 14.04 only
""""""""""""""""""

- Ubuntu 14.04 has CMake 2 by default, but we require CMake 3:

  .. code-block:: bash

      sudo apt-get install cmake3

- Ubuntu 14.04 ships Boost 1.54 and is required by ``libcgal-dev``,
  but we need Boost 1.55, so we install Boost 1.55 first, then
  install CGAL from source.

  .. code-block:: bash

      sudo apt-get install boost1.55 boost1.55-dev

- Ubuntu 14.04 uses GCC 4.8, which has only partial C++11 support, but it's currently
  sufficient to build CSXCAD or openEMS.

  .. warning::
     Manual ``-std=`` options are no longer needed in ``CXXFLAGS``. Before
     building CSXCAD or openEMS, one should remove all ``-std=`` options
     from ``CXXFLAGS``. This flag is now managed by CMake. See
     :ref:`remove_cxx11` for details.

- Install CGAL:

  .. important::

     CGAL v4.14.3 must be built from source, see :ref:`build_deps_from_source`.

- Ubuntu 14.04's Python packages are ancient. Python 3.4 frequently encounters
  ``SyntaxError``. For a minimum viable setup, suggested to install Python 3.5
  from ``apt-get``, and installing other packages via ``pip`` into an isolated
  virtual environment (``venv``) instead. Here, we use ``$HOME/opt/openEMS`` as
  an example. This directory must match the directory later used to install
  openEMS.

  .. code-block:: bash

      apt-get install -y curl python3.5-dev

      # create an isolated virtual environment, without pip
      # (because Python 3.5 pip is broken on Ubuntu 14.04)
      python3.5 -m venv $HOME/opt/openEMS --without-pip

      # activate the venv, and manually bootstrap pip ourselves
      curl -O https://bootstrap.pypa.io/pip/3.5/get-pip.py
      source ~/venv/bin/activate
      python3.5 get-pip.py

  .. warning::

      Python 3.5 is not fully supported, use at your own risk.
      This setup is intended for testing purposes.
      From limited testing, one can run a trivial openEMS script,
      but ``SyntaxError`` may still be encountered in some APIs.
      If possible, it's strongly recommended to install a
      custom Python interpreter, either from a third-party repository
      (PPA), or building from source.

Fedora
~~~~~~~~~~~~~~

- openEMS depends on the following packages for minimum functionality:

  .. code-block:: bash

      sudo dnf install gcc gcc-c++ cmake git \
                       boost-devel tinyxml-devel vtk-devel hdf5-devel \
                       CGAL-devel

- To use AppCSXCAD to visualize 3D models (recommended):

  .. code-block:: bash

      sudo dnf install vtk-qt

- To use Octave scripting (recommended):

  .. code-block:: bash

      sudo dnf install octave

- To use Python scripting (recommended):

  .. code-block:: bash

      sudo dnf install python3-pip

- By default, one doesn't need to install other Python packages here.
  The ``update_openEMS.sh`` script installs them automatically via ``pip``
  into an isolated virtual environment (``venv``). However, if one
  wants to manage Python dependencies externally outside ``pip``, use
  the system's package manager (optional):

  .. code-block:: bash

      sudo dnf install python3-setuptools python3-setuptools_scm \
                       python3-Cython python3-numpy python3-h5py python3-matplotlib

- To use ParaView to visualize simulation results (recommended):

  .. code-block:: bash

      sudo dnf install paraview

- For the package hyp2mat_ you need additional dependencies (optional):

  .. code-block:: bash

      sudo dnf install gengetopt help2man groff perl-pod2pdf bison flex \
                       libharu-devel

- Skip to :ref:`clone_build_install_src` and continue installation.

Void Linux
~~~~~~~~~~~~

- openEMS depends on the following packages for minimum functionality:

  .. code-block:: bash

      sudo xbps-install -S base-devel cmake git hdf5-devel boost-devel \
                           cgal-devel tinyxml-devel vtk-devel

- To use AppCSXCAD to visualize 3D models (recommended, but optional):

  .. code-block:: bash

      # To build a custom VTK, first remove the system package's
      # development files
      sudo xkps-remove vtk-dev

      # Install VTK build-time dependencies, prepare to build it from source!
      sudo xbps-install -S qt6-base-devel qt6-declarative-devel qt6-qt5compat-devel

  .. warning::

     VTK with Qt does not exist on Void Linux, installing it via the package
     manager is not possible. If you're using Void Linux, please report a
     bug to Void Linux developers.
     After installing the build-time dependencies above, use the workaround below:
     :ref:`build_deps_from_source`. Alternatively, disable the GUI while
     building openEMS with ``./update_openEMS.sh --disable-GUI``.

- To use Octave scripting (recommended):

  .. code-block:: bash

      sudo xbps-install -S octave

- To use Python scripting (recommended):

  .. code-block:: bash

      sudo xbps-install -S python3 python3-pip

- By default, one doesn't need to install other Python packages here.
  The ``update_openEMS.sh`` script installs them automatically via ``pip``
  into an isolated virtual environment (``venv``). However, if one
  wants to manage Python dependencies externally outside ``pip``, use
  the system's package manager (optional):

  .. code-block:: bash

      sudo xbps-install -S python3-setuptools python3-setuptools_scm \
                           python3-Cython python3-matplotlib python3-h5py

- To use ParaView to visualize simulation results (recommended):

  .. warning::

     ParaView does not exist on Void Linux, installing it via the package
     manager is not possible. If you're using Void Linux, please open a
     feature request to Void Linux developers. In the meantime, you can
     download a pre-compiled binary version of ParaView as a tarball at
     the official website: `<https://www.paraview.org/download/>`_.

- Skip to :ref:`clone_build_install_src` and continue installation.

FreeBSD
~~~~~~~~~~

openEMS can be installed directly via FreeBSD Ports. For first-time users
who are just getting started, there's no need to install dependencies
manually. Please skip to
:ref:`Install Ready-Made Package on FreeBSD <install_readymade_freebsd_package_src>`
for more information.

However, the FreeBSD package may not be up-to-date and can contain known
problems. Often it's necessary to build your own development version, if
so, follow this guide.

- openEMS depends on the following packages for minimum functionality:

  .. code-block:: bash

      sudo pkg install bash cmake git boost-libs tinyxml \
                       vtk9 hdf5 cgal

- To use AppCSXCAD to visualize 3D models (recommended):

  .. code-block:: bash

      sudo pkg install qt5

- For Octave scripting (recommended):

  .. code-block:: bash

      sudo pkg install octave

- For Python scripting (recommended):

  .. code-block:: bash

      sudo pkg install python3

      # DO NOT copy and paste this command, pause and check,
      # see the note below.
      sudo pkg install py311-pip

  .. important::

      After installing ``python3``, check the default Python version
      on your FreeBSD system ``python3 --version``.  If a newer Python
      is used on FreeBSD, replace the ``py311`` package prefix with
      your Python version, such as ``py314-pip``.

- By default, one doesn't need to install other Python packages here.
  The ``update_openEMS.sh`` script installs them automatically via ``pip``
  into an isolated virtual environment (``venv``). However, if one
  wants to manage Python dependencies externally outside ``pip``, use
  the system's package manager (optional):

  .. code-block:: bash

      sudo pkg install py311-setuptools py311-wheel py311-setuptools-scm \
                       py311-cython3 py311-numpy py311-h5py py311-matplotlib

- To use ParaView to visualize simulation results (recommended):

  .. code-block:: bash

      sudo pkg install paraview

- Skip to :ref:`clone_build_install_src` and continue installation.

macOS
~~~~~

.. warning::
   In the past, a Homebrew formula for macOS was provided. However,
   at the time of writing, the formula is broken and unmaintained, manual
   installation is *required*!

- openEMS depends on the following packages for minimum functionality:

  .. code-block:: bash

      brew install cmake boost hdf5 cgal vtk

- To use AppCSXCAD to visualize 3D models (recommended):

  .. code-block:: bash

      brew install qt5compat

- openEMS also depends on TinyXML, which is unmaintained since 2011 and has
  been removed from Homebrew (TinyXML2 is not API-compatible). As a workaround,
  ``update_openEMS.sh`` will automatically download TinyXML and patches online,
  building it from source. It's even possible to do so on a system without
  network access, explained later in the next section.

  For packagers, sysadmins and developers who needs to understand inner working of
  the custom TinyXML build, technical information is available in :ref:`manual_build`.
  For regular users, no manual intervention is needed anymore.

- To use ParaView to visualize simulation results (recommended):

  .. code-block:: bash

      brew install paraview

- To use Octave scripting (recommended):

  .. code-block:: bash

      brew install octave

- To use Python scripting (recommended):

  .. code-block:: bash

      brew install python3

- By default, one doesn't need to install other Python packages here.
  The ``update_openEMS.sh`` script installs them automatically via ``pip``
  into an isolated virtual environment (``venv``). However, if one
  wants to manage Python dependencies externally outside ``pip``, use
  the system's package manager (optional):

  .. code-block:: bash

      brew install python-setuptools cython numpy python-matplotlib

- To use ParaView to visualize simulation results (recommended):

  .. code-block:: bash

      brew install paraview

- Skip to :ref:`clone_build_install_src` and continue installation.

Windows
~~~~~~~~~

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

.. _build_deps_from_source:

Build From Source
------------------

.. important::

   The following examples install third-party packages to a custom user directory
   ``$HOME/opt/openEMS``. If you use this directory, CSXCAD and openEMS must also
   be installed to the same location, for example:

   .. code-block:: bash

       ./update_openEMS.sh ~/opt/openEMS

VTK with Qt
~~~~~~~~~~~~

.. important::

   * For Alpine and Void Linux only.

   * :program:`AppCSXCAD` can always be disabled via ``./update_openEMS.sh
     --disable-GUI``, making the following step optional if visualization
     is not needed.

Alpine and Void Linux doesn't provide Qt support for VTK applications. If one
want to use :program:`AppCSXCAD` for visualization, building a custom VTK version
from source is required.

.. code-block:: bash

    git clone https://gitlab.kitware.com/vtk/vtk.git --depth=1
    cd vtk && mkdir build && cd build
    cmake ../ -DCMAKE_BUILD_TYPE=Release -DVTK_GROUP_ENABLE_Qt=YES -DVTK_QT_VERSION=6 \
             -DCMAKE_INSTALL_PREFIX=$HOME/opt/openEMS
    make -j$(nproc)
    make install

CGAL v4.14.3
~~~~~~~~~~~~~~~

.. important::

   For Ubuntu 14.04 and CentOS 7 only.

On legacy systems such as Ubuntu 14.04 and CentOS 7, CGAL relies on an
obsolete Boost version which is in conflict with openEMS's requirements.
To use openEMS, CGAL must be built from source.

.. code-block:: bash

    git clone https://github.com/CGAL/cgal.git --depth=1 --branch=v4.14.3
    cd cgal && mkdir build && cd build

    cmake ../ -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME/opt/openEMS
    make && make install

CGAL v4.14.3 is the last version compatible with GCC 4.8. In newer
CGAL versions, the following errors occur: ``The compiler feature
"cxx_decltype_auto" is not known to CXX compiler "GNU" version
4.8.5.``

.. _hyp2mat: https://github.com/koendv/hyp2mat
.. _MSYS2: https://www.msys2.org/
