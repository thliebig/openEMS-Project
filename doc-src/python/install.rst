.. _pyinstall:

Install
=======

Instructions how to install the **CSXCAD & openEMS python interface**.

Linux
-----

* Make sure **CSXCAD** and **openEMS** was build and installed correctly. See :ref:`Install from Source <install_src>`.

.. code-block:: console

    ./update_openEMS.sh ~/opt/openEMS

* Simple version (if installed to /usr/local):

.. code-block:: console

    cd CSXCAD 
    python setup.py install
    cd ..

    cd openEMS
    python setup.py install
    cd ..

* Extended options, e.g. for custom install path at *~/opt/openEMS*:

.. code-block:: console

    python setup.py build_ext -I/opt/include -L/opt/lib -R/opt/lib"
    pyhton setup.py install

**Note:** The install command may require root on Linux, or add ``--user`` to install to *~/.local*

Windows
-------

The python interface for CSXCAD & openEMS requires a build with a `MS Visual Compiler`_.
Download the latest windows build with the "msvc" label: openEMS_win_

Install Pre-build Modules
^^^^^^^^^^^^^^^^^^^^^^^^^

For some python versions a pre-build egg files can be found in the python sub-directory. E.g. for python 3.9:

.. code-block:: console

    python -m easy_install CSXCAD-0.6.2-py3.9-win-amd64.egg
    python -m easy_install openEMS-0.0.33-py3.9-win-amd64.egg

Build Modules From Source
^^^^^^^^^^^^^^^^^^^^^^^^^

Download the sources using git and assuming the MSVC build openEMS is install at "C:\opt\openEMS"
and running from a working python command prompt (e.g. using WinPython_):

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

**Important Note:** Python needs to find the dependent libraries (dll's) during module.
To allow this, it is necessary to set an environment variable (permantently):

.. code-block:: console

    setx OPENEMS_INSTALL_PATH C:\opt\openEMS


.. _MS Visual Compiler: https://wiki.python.org/moin/WindowsCompilers
.. _openEMS_win: https://github.com/thliebig/openEMS-Project/releases
.. _WinPython: https://winpython.github.io/
