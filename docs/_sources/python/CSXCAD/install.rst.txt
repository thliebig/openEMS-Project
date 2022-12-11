.. _install:

Install
=======

Instructions how to install the CSXCAD python interface.

Linux
-----

* Make sure CSXCAD was build and installed correctly

* Simple version:

.. code-block:: console

    python setup.py install

* Extended options, e.g. for custom install path at */opt*:

.. code-block:: console

    python setup.py build_ext -I/opt/include -L/opt/lib -R/opt/lib"
    pyhton setup.py install

**Note:** The install command may require root on Linux, or add ``--user`` to install to *~/.local*

Windows
-------

The python interface for CSXCAD currently does not support MS Windows.
