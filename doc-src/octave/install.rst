.. _octave_install:

Install
=======

Instructions how to install the **CSXCAD & openEMS Octave/Matlab interface**.

Requirements
------------

Make sure openEMS and dependencies were installed correctly, and ensure
Ensure Octave_ (or Matlab_) has also been installed.

.. code-block:: bash

   octave --version

If not, see :ref:`Install from Source <install_requirements_src>` for
instructions.

Setup
-----

To run the simulation scripts it is necessary to tell Octave (or Matlab) where to find the interface scripts.

.. _Octave Linux Install:

Unix/Linux
^^^^^^^^^^^

Assuming that we've built openEMS from source and installed it into a
prefix ``~/opt/openEMS``, the required Matlab/Octave libraries can be
found at ``~/opt/openEMS/share/CSXCAD/matlab`` and
``~/opt/openEMS/share/openEMS/matlab``. You may add these folders
manually into ``~/.octaverc`` via:

.. code-block:: matlab

    % change the prefix ~/opt/openEMS to the path on your machine
    addpath('~/opt/openEMS/share/openEMS/matlab');
    addpath('~/opt/openEMS/share/CSXCAD/matlab');

For system-wide installation via root, these folders are usually
located ``/usr/share/openEMS/matlab`` and ``/usr/share/CSXCAD/matlab``.

Alternatively you can setup these path more permanently using the "Edit"-Menu
using "Set Path" in Octave.

.. _Octave Windows Install:

Windows
^^^^^^^

On **Windows** there is only one folder to add. If you unzipped the windows build e.g.
to ``C:\openEMS`` than the path would be ``C:\openEMS\matlab``. You may add this
folders manually using:

.. code-block:: matlab

    addpath('C:\openEMS\matlab');
    
Alternatively you can setup these path more permanently using the "Edit"-Menu using "Set Path" in Octave.

.. _Octave: https://octave.org/
.. _Matlab: https://en.wikipedia.org/wiki/MATLAB
