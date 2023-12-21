.. _install_readymade_package_src:

Installing Ready-Made Packages
===============================

.. _install_readymade_windows_package_src:

Windows
--------

- Download the latest 64bit openEMS_win_
- Unzip to a folder of your choice e.g. ``C:/`` (zip contains an openEMS folder)

Setup the Octave/Matlab or Python Interfaces
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Optional:** Setup the Octave/Matlab environment, see :ref:`Octave Interface Install <Octave Windows Install>`
- **Optional:** Install the Python modules, see :ref:`Python Interface Install <Python Windows Install>`

Check Installation
~~~~~~~~~~~~~~~~~~~

After completing installation, now it's a good test to verify that
the installation is functional according to :ref:`check_installation_src`.


.. _install_readymade_freebsd_package_src:

FreeBSD
-----------

- Sync FreeBSD Ports tree.

Then:

.. code-block:: console

    cd /usr/ports/science/openems
    make

Setup the Octave/Matlab or Python Interfaces
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Unfortunately, currently Python modules are not automatically installed,
they need manual installation.

- **Optional:** Setup the Octave/Matlab environment, see :ref:`Octave Interface Install <Octave Windows Install>`
- **Optional:** Install the Python modules, see :ref:`Python Interface Install <Python Windows Install>`

Check Installation
~~~~~~~~~~~~~~~~~~~

After completing installation, now it's a good test to verify that
the installation is functional according to :ref:`check_installation_src`.

.. _install_readymade_macos_package_src:

macOS
------

- Install Homebrew_
- Tap the openEMS-Project repository and build from source

.. code-block:: console

    brew tap thliebig/openems https://github.com/thliebig/openEMS-Project.git
    brew install --HEAD openems

Setup Octave/Matlab Interfaces
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- **Optional**: Install Octave

.. code-block:: console

    brew install octave

- **Optional**: Add openEMS Matlab files to your Octave/Matlab environment

.. code-block:: console

    echo "addpath('$(brew --prefix)/share/openEMS/matlab:$(brew --prefix)/share/CSXCAD/matlab');" >> ~/.octaverc

Setup Python Interfaces
~~~~~~~~~~~~~~~~~~~~~~~~~

- **Optional**: Build Python libraries.

If you install openEMS with Homebrew, the Python libraries will be automatically installed unless `--without-python@3` is passed.

If you prefer to build them manually, follow the following instructions.

First, install the needed dependencies...

.. code-block:: console

    pip3 install cython numpy h5py matplotlib --user

Next, go to Homebrew's cache directory that contains the previously
cloned git code:

.. code-block:: console

    cd ~/Library/Caches/Homebrew/openems--git/

1. Build CSXCAD's Python extension.

.. code-block:: console

    cd CSXCAD/python
    BREW=$(brew --prefix)
    python3 setup.py build_ext -I$BREW/include -L$BREW/lib -R$BREW/lib
    python3 setup.py install

    cd ../..

2. Build openEMS's Python extension:

.. code-block:: console

    cd openEMS/python
    BREW=$(brew --prefix)
    python3 setup.py build_ext -I$BREW/include -L$BREW/lib -R$BREW/lib
    python3 setup.py install

    cd ../..

Check Installation
~~~~~~~~~~~~~~~~~~~

After completing installation, now it's a good test to verify that
the installation is functional according to :ref:`check_installation_src`.

Troubleshooting
^^^^^^^^^^^^^^^^

If you see the error:

.. code-block:: console

    Couldn't find index page for 'CSXCAD' (maybe misspelled?)
    Scanning index of all packages (this may take a while)
    Reading https://pypi.org/simple/
    No local packages or working download links found for CSXCAD==0.6.2
    error: Could not find suitable distribution for Requirement.parse('CSXCAD==0.6.2')

Do NOT use `python3 setup.py` to install openEMS, it may trigger
this bug, seemingly related to search path. Use `pip3 install . --user`.

Updating
^^^^^^^^^

.. code-block:: console

    brew upgrade --fetch-HEAD openems

.. _openEMS_win: https://github.com/thliebig/openEMS-Project/releases
.. _Homebrew: https://brew.sh
