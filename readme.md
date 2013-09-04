 ![openEMS](https://raw.github.com/thliebig/openEMS-Project/master/other/openEMS.png "openEMS")<br />
openEMS is a free and open electromagnetic field solver using the FDTD method. Matlab or Octave are used as an easy and flexible scripting interface.<br />

**Website**: [http://openEMS.de](http://openEMS.de)<br />
**Forum**: [http://openEMS.de/forum](http://openEMS.de/forum)<br />
**Wiki**: [http://openems.de/index.php](http://openems.de/index.php)<br />
**IRC**: #openEMS on freenode <br />

## openEMS Features:
+ fully 3D Cartesian and cylindrical coordinates graded mesh.
+ Multi-threading, SIMD (SSE) and MPI support for high speed FDTD.
+ Octave and Matlab-Interface
+ Dispersive material (Drude/Lorentz/Debye type)
+ Field dumps in time and frequency domain as vtk or hdf5 file format
+ Flexible post-processing routines in Octave/Matlab
+ and [many more](http://openems.de/index.php/OpenEMS#Features)

## Install Instruction:
+ Install all necessary dependencies, e.g. on Ubuntu 12.04:
```bash
sudo apt-get install build-essential git libhdf5-openmpi-dev libvtk5-dev libboost-all-dev libcgal-dev libtinyxml-dev libfparser-dev libqt4-dev libvtk5-qt4-dev
```
**Note:** On Ubuntu 12.10 or higher, the package _libfparser-dev_ is no longer available. Use it from here:
[fparser](http://packages.debian.org/squeeze-backports/libfparser-4.3) and [fparser-dev](http://packages.debian.org/squeeze-backports/libfparser-dev)

+ Clone this repository and build openEMS:
```bash
git clone git://openEMS.de/openEMS-Project.git
cd openEMS-Project
./update_openEMS.sh
```

+ Add the given paths to your Octave/Matlab environment (e.g.):
```Matlab
addpath('<path-to-project/openEMS/matlab');
addpath('<path-to-project/CSXCAD/matlab');
```

For more informations and other platforms see:
[http://www.openems.de/index.php/OpenEMS#Installation](http://www.openems.de/index.php/OpenEMS#Installation)<br />

## Update Instruction:
+ Perform an update in case of a new release

**Note:** Changes you may have made (e.g. to the tutorials or examples) may be overwritten!<br />
```bash
cd openEMS-Project
git pull
./update_openEMS.sh
```
