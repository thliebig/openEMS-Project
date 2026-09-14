openEMS Python Interface
========================

This folder contains the pre-built Python modules (wheels) for CSXCAD and
openEMS, the Python tutorials, and the Cython declarations (*.pxd) for
building your own extensions.

Each wheel is built for one 64-bit Python version, e.g. "cp313" in the file
name means Python 3.13. You do not have to pick one, pip does that for you.

The commands below assume the package was extracted to C:\openEMS, i.e. that
C:\openEMS\openEMS.exe exists. Adjust the path if you chose another folder.


1. Install
----------

In a command prompt or PowerShell, run:

    python -m pip install numpy h5py matplotlib
    python -m pip install --no-index --find-links C:\openEMS\python openEMS

The first command installs the dependencies from PyPI. The second installs
openEMS and CSXCAD from this folder only, so they always match the DLLs of
this package; --no-index keeps pip from fetching anything else, which is
also why the dependencies are installed separately. If it reports
"No matching distribution found", there is no wheel for your Python version
(see "python --version").

With several Python versions installed, use e.g. "py -3.13 -m pip" instead
of "python -m pip". Installing into a virtual environment works the same way.


2. Tell Python where the DLLs are
---------------------------------

    setx CSXCAD_INSTALL_PATH C:\openEMS

This has to be the folder containing CSXCAD.dll, not this python folder.
setx stores the setting permanently, but only command prompts opened
afterwards see it.


3. Check the installation
-------------------------

In a new command prompt:

    python -c "import openEMS; print(openEMS.__version__)"

"ImportError: DLL load failed" means CSXCAD_INSTALL_PATH does not point to
the folder containing CSXCAD.dll. Watch out for an extra directory level such
as C:\openEMS\openEMS when the ZIP was extracted into a folder of the same
name.


4. Run a tutorial
-----------------

    cd C:\openEMS\python\Tutorials
    python Simple_Patch_Antenna.py

The tutorials write their simulation data to the temp folder, so you can copy
them anywhere and modify them.


More
----

Documentation:
    https://docs.openems.de
Windows installation details and troubleshooting:
    https://docs.openems.de/en/latest/python/manual_install.html#python-windows-install
