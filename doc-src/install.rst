.. _install_src:

=======
Install
=======

Instructions how to install the **openEMS Project** and its dependencies.

Linux
=====

Requirements
------------

- Install all necessary dependencies, e.g. on *Ubuntu 18.04 and above*:

.. code-block:: console

    sudo apt-get install build-essential cmake git libhdf5-dev libvtk7-dev libboost-all-dev libcgal-dev libtinyxml-dev qtbase5-dev libvtk7-qt-dev

**Note:** For later versions of Ubuntu you may have to choose a later version of vtk.


- **Optional**: Install octave_ and octave devel packages:

.. code-block:: console

    sudo apt-get install octave liboctave-dev

- **Optional**: For the package hyp2mat_ you need additonal dependencies:

.. code-block:: console

    sudo apt-get install gengetopt help2man groff pod2pdf bison flex libhpdf-dev libtool

- **Optional**: For the python_ interface, python with numpy, matplotlib, cython and h5py is required:

.. code-block:: console

    sudo pip install numpy matplotlib cython h5py

Clone, build and install
------------------------

- Clone this repository, build openEMS and install e.g. to "~/opt/openEMS":

.. code-block:: console

    git clone --recursive https://github.com/thliebig/openEMS-Project.git
    cd openEMS-Project
    ./update_openEMS.sh ~/opt/openEMS

- **Optional:** Build all including hyp2mat, CTB and python_:

.. code-block:: console

    ./update_openEMS.sh ~/opt/openEMS --with-hyp2mat --with-CTB --python

Setup the Octave/Matlab or Python Interfaces
--------------------------------------------

- **Optional:** Setup the Octave/Matlab environment, see :ref:`Octave Interface Install <Octave Linux Install>`
- **Optional:** Install the Python modules, see :ref:`Python Interface Install <Python Linux Install>`


Update Instruction:
-------------------

- Perform an update in case of a new release

**Note:** Changes you may have made (e.g. to the tutorials or examples) may be overwritten!

.. code-block:: console

    cd openEMS-Project
    git pull --recurse-submodules
    ./update_openEMS.sh ~/opt/openEMS --python


Windows
=======

- Download the latest 64bit openEMS_win_
- Unzip to a folder of your choice e.g. ``C:/`` (zip contains an openEMS folder)

Setup the Octave/Matlab or Python Interfaces
--------------------------------------------

- **Optional:** Setup the Octave/Matlab environment, see :ref:`Octave Interface Install <Octave Windows Install>`
- **Optional:** Install the Python modules, see :ref:`Python Interface Install <Python Windows Install>`

macOS
=====

- Install Homebrew_
- Tap the openEMS-Project repository and build from source

.. code-block:: console

    brew tap thliebig/openems https://github.com/thliebig/openEMS-Project.git
    brew install --HEAD openems

- **Optional**: Install Octave

.. code-block:: console

    brew install octave

- **Optional**: Add openEMS Matlab files to your Octave/Matlab environment

.. code-block:: console

    echo "addpath('$(brew --prefix)/share/openEMS/matlab:$(brew --prefix)/share/CSXCAD/matlab');" >> ~/.octaverc

Updating
--------

.. code-block:: console

    brew upgrade --fetch-HEAD openems

.. _python: https://www.python.org/
.. _openEMS_win: https://github.com/thliebig/openEMS-Project/releases
.. _octave: https://octave.org/
.. _hyp2mat: https://github.com/koendv/hyp2mat
.. _Homebrew: https://brew.sh
