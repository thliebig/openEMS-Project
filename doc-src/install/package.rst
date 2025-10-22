.. _install_readymade_package_src:

Installing Ready-Made Packages
===============================

.. _install_readymade_windows_package_src:

Windows
--------

- Download the latest 64bit openEMS_win_
- Unzip to a folder of your choice e.g. ``C:/`` (zip contains an openEMS folder)
- **Optional:** Setup the Octave/Matlab or Python Interfaces

  - Setup the Octave/Matlab environment, see :ref:`Octave Interface Install <Octave Windows Install>`

  - Install the Python modules, see :ref:`Python Interface Install <Python Windows Install>`

- After completing installation, verify that the installation is functional according
  to :ref:`check_installation_src`.

.. important::
  The Windows package is provided for the latest stable release only, so it
  may not be up-to-date and can contain known problems. Furthermore, we've
  observed pathological performance degradations in certain situations due
  to MSVC-related behaviors. Its solution is still on our TODO list.

  Consider the pre-built Windows package as a "quick start". If problems are
  later encountered, consider switching to the Unix/Linux version for production
  runs. Building your own development version on Windows via MSYS2/GCC is also
  an option, which avoids known compiler problems.

.. _install_readymade_freebsd_package_src:

FreeBSD
-----------

- Sync FreeBSD Ports tree.
- Install the port package ``science/openems``.

  .. code-block:: console

      cd /usr/ports/science/openems
      make

- **Optional:** Setup the Octave/Matlab or Python Interfaces

  - Setup the Octave/Matlab environment, see :ref:`Octave Interface Install <Octave Linux Install>`

  - Install the Python modules, see :ref:`Python Interface Install <pyinstall>`

- After completing installation, verify that the installation is functional according
  to :ref:`check_installation_src`.

.. important::
   The FreeBSD package may not be up-to-date and can contain known
   problems. If problems are found, consider building your own development
   version. Consider the package as a "quick start". If problems are
   later encountered, consider building your own development version
   according to :ref:`clone_build_install_src`.

.. _install_readymade_macos_package_src:

macOS
------

.. warning::
   In the past, a Homebrew formula for macOS was provided. However,
   as of writing, the formula is broken and unmaintained, manual
   installation is *required*!

.. _openEMS_win: https://github.com/thliebig/openEMS-Project/releases
.. _Homebrew: https://brew.sh
