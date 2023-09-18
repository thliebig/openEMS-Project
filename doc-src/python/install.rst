.. _pyinstall:

Install
=======

Instructions how to install the **CSXCAD & openEMS python interface**.

Module requirements
-------------------

Some python modules are required to run openEMS simulations and tutorials: numpy, h5py, matplotlib

.. code-block:: console

    pip install numpy h5py matplotlib

Additionally Cython is required to compile CSXCAD and openEMS e.g. on Linux.

.. code-block:: console

    pip install cython

.. _Python Linux Install:

Linux
-----

Build Modules Automatically
^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Build or update **CSXCAD** and **openEMS** using the "--python" flag (Recommended). See :ref:`Install from Source <install_src>` for more details.

.. code-block:: console

    ./update_openEMS.sh ~/opt/openEMS --python

Build Modules From Source Manually
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Alternative: Manual build and install (if installed to /usr/local):

.. code-block:: console

    cd CSXCAD 
    python setup.py install
    cd ..

    cd openEMS
    python setup.py install
    cd ..

* Extended options, e.g. for custom install path at */opt*:

.. code-block:: console

    python setup.py build_ext -I/opt/include -L/opt/lib -R/opt/lib"
    python setup.py install

**Note:** The install command may require root on Linux, or add ``--user`` to install to *~/.local*

.. _Python Windows Install:

Windows
-------

The python interface for CSXCAD & openEMS requires a build with a `MS Visual Compiler`_.
Download the latest windows build with the "msvc" label: openEMS_win_

Install Pre-build Modules
^^^^^^^^^^^^^^^^^^^^^^^^^

For some python versions, pre-build wheel files can be found in the python sub-directory. E.g. for python 3.10 (using pip):

.. code-block:: console

    cd C:\opt\openEMS\python
    pip install CSXCAD-0.6.2-cp310-cp310-win_amd64.whl
    pip install openEMS-0.0.33-cp310-cp310-win_amd64.whl

Build Modules From Source
^^^^^^^^^^^^^^^^^^^^^^^^^

Download the sources using git_. Assuming the MSVC binary build of openEMS is install at "C:\\opt\\openEMS",
run from a working python command prompt (e.g. using WinPython_):

.. code-block:: console

   git clone --recursive https://github.com/thliebig/openEMS-Project.git
   cd openEMS-Project/CSXCAD/python
   python setup.py build_ext -IC:\opt\openEMS\include -LC:\opt\openEMS
   python setup.py install

   cd ../../openEMS/python
   python setup.py build_ext -IC:\opt\openEMS\include -LC:\opt\openEMS
   python setup.py install


Setup
^^^^^

**Important Note:** Python needs to find the dependent libraries (dll's) during module import.
To allow this, it is necessary to set an environment variable (permantently, terminal restart my be necessary):

.. code-block:: console

    setx OPENEMS_INSTALL_PATH C:\opt\openEMS

.. _git: https://git-scm.com
.. _MS Visual Compiler: https://wiki.python.org/moin/WindowsCompilers
.. _openEMS_win: https://github.com/thliebig/openEMS-Project/releases
.. _WinPython: https://winpython.github.io/
