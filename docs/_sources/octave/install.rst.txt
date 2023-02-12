.. _octave_install:

Install
=======

Instructions how to install the **CSXCAD & openEMS Octave/Matlab interface**.

Requirements
------------

Install Octave_ or Matlab_ and make sure openEMS and dependencies were installed correctly.
See :ref:`Install from Source <install_src>` for more details.

Setup
-----

To run the simulation scripts it is necessary to tell Octave (or Matlab) where to find the interface scripts.

.. _Octave Linux Install:

Linux
^^^^^

On **Linux** these folders are usually located under e.g. ``/usr/share/openEMS/matlab`` and ``/usr/share/CSXCAD/matlab`` or 
if you installed from source (e.g. to ``/opt``) under ``/opt/share/openEMS/matlab`` and ``/opt/share/CSXCAD/matlab``.
You may add this folders manually using:

.. code-block:: matlab

    addpath('/opt/share/openEMS/matlab');
    addpath('/opt/share/CSXCAD/matlab');
    
Alternatively you can setup these path more permanently using the "Edit"-Menu using "Set Path" in Octave.

.. _Octave Windows Install:

Windows
^^^^^^^

On **Windows** there is only one folder to add. If you unzipped the windows build e.g. to ``C:\openEMS`` than the path would be ``C:\openEMS\matlab``.
You may add this folders manually using:

.. code-block:: matlab

    addpath('C:\openEMS\matlab');
    
Alternatively you can setup these path more permanently using the "Edit"-Menu using "Set Path" in Octave.

.. _Octave: https://octave.org/
.. _Matlab: https://en.wikipedia.org/wiki/MATLAB
