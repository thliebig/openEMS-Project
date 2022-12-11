.. _install_py:

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

The python interface for CSXCAD currently does not support MS Windows.
