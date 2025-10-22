.. _install_requirements_src:

Requirements
=======================

The following section describes the dependency requirements of building
openEMS on many systems. It's used for both the semi-automatic installation
described in :ref:`clone_build_install_src`, and for :ref:`manual_build`.
The former is recommended for general use, while the latter is recommended
for development, troubleshooting, or usage on non-standard systems.

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

Alpine
----------

- openEMS depends on the following packages for minimum functionality:

  .. code-block:: console

      doas apk add bash \
                   build-base gmp-dev mpfr-dev git cmake \
                   boost-dev tinyxml-dev hdf5-dev cgal-dev vtk-dev \

- AppCSXCAD is used to visualize 3D models, but it's unsupported on
  Alpine due to missing vtk-qt support.

- To use Octave scripting (recommended):

  .. code-block:: console

      doas apk add octave

- To use Python scripting (recommended):

  .. code-block:: console

      doas apk add python3-dev cython \
                   py3-setuptools \
                   py3-matplotlib py3-numpy py3-h5py

- Skip to :ref:`clone_build_install_src` and continue installation.

AlmaLinux
------------

- openEMS requires additional packages not included in the standard repository,
  which can be enabled by the following command:

  .. code-block:: console

      sudo dnf install -y epel-release
      sudo dnf config-manager --set-enabled powertools
      sudo dnf config-manager --set-enabled crb

- openEMS depends on the following packages for minimum functionality:

  .. code-block:: console

      # install git first to avoid dependency graph conflicts
      sudo dnf install git

      sudo dnf install git gcc gcc-c++ cmake \
                       boost-devel tinyxml-devel hdf5-devel vtk-devel CGAL-devel

- To use AppCSXCAD to visualize 3D models (recommended):

  .. code-block:: console

      sudo dnf install vtk-qt

- To use Octave scripting (recommended):

  .. code-block:: console

      sudo dnf install octave

- To use Python scripting (recommended):

  .. code-block:: console

      sudo dnf install python3-Cython python3-h5py python3-matplotlib

- Skip to :ref:`clone_build_install_src` and continue installation.

CentOS 7
-----------

openEMS continues to support legacy systems when it's practical, including
CentOS 7, but additional steps are required.

- CentOS repos are EOL and desupported. For a fresh installation, the following
  steps are required to bring the package manager back into a functional state:

  .. warning::
     CentOS 7 no longer receives security updates. Use at your own risk.

  .. code-block:: console

      # change all mentions of mirror.centos.org to vault.centos.org
      sed -i 's|^mirrorlist|#mirrorlist|g; s|^#baseurl|baseurl|g; s|mirror.centos.org|vault.centos.org|g' \
          /etc/yum.repos.d/CentOS-Base.repo

- openEMS requires additional packages not included in the standard repository,
  which can be enabled by the following command:

  .. code-block:: console

      yum install centos-release-scl

      # change all mentions of mirror.centos.org to vault.centos.org
      sed -i 's|^mirrorlist|#mirrorlist|g; s|^#baseurl|baseurl|g;
              s|^# baseurl|baseurl|g; s|mirror.centos.org|vault.centos.org|g' \
          /etc/yum.repos.d/CentOS-SCLo-scl.repo \
          /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo

      yum install epel-release

- openEMS depends on the following packages for minimum functionality:

  .. code-block:: console

      # install git first to avoid dependency graph conflicts
      yum install git

      yum install gcc gcc-c++ gmp-devel mpfr-devel \
                  git tinyxml-devel hdf5-devel

- CentOS 7 has CMake 2 by default, but we require CMake 3:

  .. code-block:: console

      # use cmake3 instead of default cmake2
      yum install cmake3
      alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake3 99

- ``boost-predef`` is only available on Boost 1.55 and later. Without it,
  the error "fatal error: boost/predef.h: No such file or directory" occurs.
  We can build the latest version of Boost from source. But as CentOS 7 is
  already a frozen platform, we can try some non-standard tricks here
  and get away from it. Here, we borrow a copy of Boost 1.58 from rh repo's
  ``mariadb`` backport package.

  .. code-block:: console

      yum install -y rh-mariadb101-boost-devel

      # copy it into /usr/local, so it can be found in the standard system
      # search path
      ln -s /opt/rh/rh-mariadb101/root/usr/include/boost /usr/local/include/boost
      mkdir /usr/local/lib64 && cd /usr/local/lib64
      for i in /opt/rh/rh-mariadb101/root/usr/lib64/libboost*; do
          ln -s $i /usr/local/lib64/
      done

- CentOS 7 uses GCC 4.8, which lacks full C++11 support. CGAL v4.14.3.
  is the last version compatible with GCC 4.8. In newer CGAL versions,
  the following errors occur: ``The compiler feature "cxx_decltype_auto" is
  not known to CXX compiler "GNU" version 4.8.5.`` Thus we need to build
  CGAL from source.

  CGAL can be installed to a custom user directory. Here, we use
  ``$HOME/opt/openEMS`` as an example. This directory must match the
  directory later used for installing openEMS.

  .. code-block:: console

      git clone https://github.com/CGAL/cgal.git --depth=1 --branch=v4.14.3
      cd cgal && mkdir build && cd build

      cmake ../ -DCMAKE_INSTALL_PREFIX=$HOME/opt/openEMS
      make && make install

- To use AppCSXCAD to visualize 3D models (recommended):

  .. code-block:: console

      yum install vtk-qt

- To use Octave scripting (recommended):

  .. code-block:: console

     yum install octave

- To use Python scripting (recommended):

  .. code-block:: console

     yum install python3-pip python3-devel python3-Cython

     # system packages are incompatible, must be manually
     # installed via pip
     pip3 install numpy h5py matplotlib --user

- Skip to :ref:`clone_build_install_src` and continue installation.

Debian/Ubuntu
--------------

- openEMS depends on the following packages for minimum functionality:

  .. code-block:: console

      sudo apt-get install build-essential cmake git libhdf5-dev libvtk9-dev \
                           libboost-all-dev libcgal-dev libtinyxml-dev

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

  .. code-block:: console

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

  .. code-block:: console

      sudo apt-get install cmake3

- Ubuntu 14.04 ships Boost 1.54 and is required by ``libcgal-dev``,
  but we need Boost 1.55, so we install Boost 1.55 first, then
  install CGAL from source.

  .. code-block:: console

      sudo apt-get install boost1.55 boost1.55-dev

- Ubuntu 14.04 uses GCC 4.8, which lacks full C++11 support. CGAL v4.14.3.
  is the last version compatible with GCC 4.8. In newer CGAL versions,
  the following errors occur: ``The compiler feature "cxx_decltype_auto" is
  not known to CXX compiler "GNU" version 4.8.5.`` Thus we need to build
  CGAL from source.

  CGAL can be installed to a custom user directory. Here, we use
  ``$HOME/opt/openEMS`` as an example. This directory must match the
  directory later used for installing openEMS.

  .. code-block:: console

      sudo apt-get install libgmp-dev libmpfr-dev
      git clone https://github.com/CGAL/cgal.git --depth=1 --branch=v4.14.3
      cd cgal && mkdir build && cd build

      cmake ../ -DCMAKE_INSTALL_PREFIX=$HOME/opt/openEMS
      make && make install

- Ubuntu 14.04's cython3 package is ancient, install via pip instead. Also,
  note that Cython 3.0 or lower must be used, since 3.1 uses f-string which is
  incompatible with Python 3.4.

  .. code-block:: console

     apt-get install -y python3-pip
     pip3 install "cython<3.1"

Fedora
-------

- openEMS depends on the following packages for minimum functionality:

  .. code-block:: console

      sudo dnf install gcc gcc-c++ cmake git \
                       boost-devel tinyxml-devel vtk-devel hdf5-devel \
                       CGAL-devel octave \

- To use AppCSXCAD to visualize 3D models (recommended):

  .. code-block:: console

      sudo dnf install vtk-qt

- To use Octave scripting (recommended):

  .. code-block:: console

      sudo dnf install octave

- To use Python scripting (recommended):

  .. code-block:: console

      sudo dnf install python3-setuptools python3-Cython python3-h5py \
                       python3-matplotlib

- To use Paraview to visualize simulation results (recommended):

  .. code-block:: console

      sudo dnf install paraview

- For the package hyp2mat_ you need additional dependencies (optional):

  .. code-block:: console

      sudo dnf install gengetopt help2man groff perl-pod2pdf bison flex \
                       libharu-devel

- Skip to :ref:`clone_build_install_src` and continue installation.

FreeBSD
--------

openEMS can be installed directly via FreeBSD Ports. For first-time users
who are just getting started, there's no need to install dependencies
manually. Please skip to
:ref:`Install Ready-Made Package on FreeBSD <install_readymade_freebsd_package_src>`
for more information.

However, the FreeBSD package may not be up-to-date and can contain known
problems. Often it's necessary to build your own development version, if
so, follow this guide.

- openEMS depends on the following packages for minimum functionality:

  .. code-block:: console

      sudo pkg install bash cmake git boost-libs tinyxml \
                       vtk9 hdf5 cgal

- To use AppCSXCAD to visualize 3D models (recommended):

  .. code-block:: console

      sudo pkg install qt5

- For Octave scripting (recommended):

  .. code-block:: console

      sudo pkg install octave

- For Python scripting (recommended):

  .. code-block:: console

      sudo pkg install py311-setuptools py311-cython3 py311-numpy \
                       py311-h5py py311-matplotlib

- Skip to :ref:`clone_build_install_src` and continue installation.

macOS
-----

.. warning::
   In the past, a Homebrew formula for macOS was provided. However,
   as of writing, the formula is broken and unmaintained, manual
   installation is *required*!

- openEMS depends on the following packages for minimum functionality:

  .. code-block:: console

      brew install cmake boost hdf5 cgal vtk

- openEMS also depends on TinyXML, which is unmaintained since 2011 and has
  been removed from Homebrew (TinyXML2 is not API-compatible). As a workaround,
  ``update_openEMS.sh`` will automatically download TinyXML and patches online,
  building it from source. It's even possible to do so on a system without
  network access, explained later in the next section.

  For packagers, sysadmins and developers who needs to understand inner working of
  the custom TinyXML build, technical information is available in :ref:`manual_build`.
  For regular users, no manual intervention is needed anymore.

- To use Paraview to visualize simulation results (recommended):

  .. code-block:: console

      brew install paraview

- To use Octave scripting (recommended):

  .. code-block:: console

      brew install octave

- To use Python scripting (recommended):

  Python packages must be installed in a custom user directory, as
  Homebrew doesn't provide a full Cython meant for end-user usage.
  Thus, the best way to avoid package conflicts is to install Python
  packages in an isolated virtualenv.

  Here, we use ``$HOME/opt/openEMS`` as an example. This directory must
  match the directory later used to install openEMS.

  .. code-block:: console

     python3 -m venv $HOME/opt/openEMS
     $HOME/opt/openEMS/bin/pip3 install setuptools cython numpy h5py matplotlib

- Skip to :ref:`clone_build_install_src` and continue installation.

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
