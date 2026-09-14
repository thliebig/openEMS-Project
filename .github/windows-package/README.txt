openEMS for Windows
===================

Package: @PACKAGE_NAME@

openEMS runs directly from this folder, there is nothing to install. The
examples below assume the package was extracted to C:\openEMS, i.e. that
C:\openEMS\openEMS.exe exists. Adjust the path if you chose another folder.


Contents
--------

    (this folder)    openEMS.exe, AppCSXCAD.exe and all required DLLs
    matlab\          Octave/Matlab interface and tutorials
    CTB\             Circuit Toolbox for Octave/Matlab
    resources\       data files used by some tutorials
    python\          Python modules and tutorials, see python\README.txt
    include\, lib\   C++ headers and import libraries for custom extensions


Octave/Matlab
-------------

Add the interface (and optionally the Circuit Toolbox) to the search path:

    addpath('C:\openEMS\matlab');
    addpath('C:\openEMS\CTB');

openEMS.exe and AppCSXCAD.exe are found relative to the matlab folder.
To keep the setting, add these lines to your .octaverc or startup.m.


Python
------

See python\README.txt.


Command line
------------

To call openEMS.exe or AppCSXCAD.exe from any command prompt, add C:\openEMS
to the Path environment variable. Octave/Matlab and Python do not need this.


More
----

Project page:   https://openEMS.de
Documentation:  https://docs.openems.de
