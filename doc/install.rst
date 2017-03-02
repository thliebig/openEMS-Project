.. _install_src:

=======
Install
=======

Instructions how to install the **openEMS Project** and its dependencies.

Linux
=====

Requirements
------------

- Install all necessary packages and libraries: ``git, qt4, tinyxml, hdf5`` and ``boost``. For example on '''Ubuntu 14.04 LTS or above''':

.. code-block:: console

    sudo apt-get install build-essential git cmake libhdf5-dev libvtk5-dev libboost-all-dev libcgal-dev libtinyxml-dev libqt4-dev libvtk5-qt4-dev

*Note for Ubuntu 16.04:* Due to a bug in CGAL the package ``libcgal-qt5-dev`` may be required.

- Optional: Additional packages for *hyp2mat*:

For example on *Ubuntu 14.04 or above*:

.. code-block:: console

    sudo apt-get install gengetopt help2man groff pod2pdf bison flex libhpdf-dev libtool autoconf

- Optional: Install octave and octave devel packages:

.. code-block:: console

    sudo apt-get install octave liboctave-dev epstool transfig

Build and Install
-----------------

This instructions assume that you will install openEMS to ``~/opt/openEMS``

- Get the openEMS source code, extract, build and install:

.. code-block:: console

    cd /tmp
    wget http://openems.de/download/src/openEMS-v0.0.35.tar.bz2
    tar jxf openEMS-v0.0.35.tar.bz2
    cd openEMS
    ./update_openEMS.sh ~/opt/openEMS

Windows
=======

- Download the latest 64bit openEMS_
- Unzip to a folder of your choice e.g. ``C:/`` (zip contains an openEMS folder)

.. _openEMS: http://openems.de/download/win64/openEMS_x64_current.zip
