.. _clone_build_install_src:

Clone, Build and Install
============================

This section describes how to install openEMS from source
and build everything automatically via `./update_openEMS.sh`.
For macOS and Windows users, it's recommended to install the
ready-made packages instead, please refer to
:ref:`install_readymade_package_src` instead.

Clone
--------

- Clone this repository, build openEMS and install e.g. to "~/opt/openEMS":

.. code-block:: console

    git clone --recursive https://github.com/thliebig/openEMS-Project.git
    cd openEMS-Project

Build and Install
------------------

openEMS can be built automatically via `./update_openEMS.sh`, or
manually by installing each component separately using CMake, make,
and make install. For brevity, only the automatic method is documented
here. If it's necessary to build and install openEMS manually for
development and testing, please go to Section Manual Build.

To build and install openEMS automatically, run (assuming that
we want to install openEMS into `~/opt/openEMS`:

.. code-block:: console

    ./update_openEMS.sh ~/opt/openEMS

- **Optional:** Passing these options can be used to enable or disable extra features:

* `--python`: Build Python extensions (recommended).
* `--with-CTB`: Enable circuit toolbox (requires Matlab).
* `--with-hyp2mat`: enable hyp2mat build
* `--with-MPI`: Build MPI engine (only needed for cluster).
* `--disable-GUI`: Disable AppCSXCAD GUI, useful for servers.

For example, to build openEMS with hyp2mat, CTB and python_:

.. code-block:: console

    ./update_openEMS.sh ~/opt/openEMS --with-hyp2mat --with-CTB --python

openEMS search path
--------------------

After the build is complete, add `~/opt/openEMS/bin` into your search
path:

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
