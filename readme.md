 ![openEMS](https://raw.github.com/thliebig/openEMS-Project/master/other/openEMS.png "openEMS")<br />
openEMS is a free and open electromagnetic field solver using the FDTD method. Matlab or Octave are used as an easy and flexible scripting interface.<br />

**Website**: [http://openEMS.de](http://openEMS.de)<br />
**Forum**: [http://openEMS.de/forum](http://openEMS.de/forum)<br />
**Wiki**: [http://openems.de/index.php](http://openems.de/index.php)<br />
**Github**: [https://github.com/thliebig/openEMS-Project](https://github.com/thliebig/openEMS-Project)<br />

# openEMS Features:
+ fully 3D Cartesian and cylindrical coordinates graded mesh.
+ Multi-threading, SIMD (SSE) and MPI support for high speed FDTD.
+ Octave/Matlab and Pyhon-Interface
+ Dispersive material (Drude/Lorentz/Debye type)
+ Field dumps in time and frequency domain as vtk or hdf5 file format
+ Flexible post-processing routines in Octave/Matlab and Python
+ and [many more](http://openems.de/index.php/OpenEMS#Features)

# Install Instruction

## Requirements

### Ubuntu
+ Install all necessary dependencies, e.g. on *Ubuntu 18.04 and above*:<br />
```bash
sudo apt-get install build-essential cmake git libhdf5-dev libvtk7-dev libboost-all-dev libcgal-dev libtinyxml-dev qtbase5-dev libvtk7-qt-dev
```
**Note:** For later versions of Ubuntu you may have to choose a later version of vtk.

+ Optional: Install [octave](http://www.gnu.org/software/octave/) and octave devel packages:<br />
```bash
sudo apt-get install octave liboctave-dev
```

+ Optional: For the package [hyp2mat](https://github.com/koendv/hyp2mat) you need additonal dependencies:<br />
```bash
sudo apt-get install gengetopt help2man groff pod2pdf bison flex libhpdf-dev libtool
```

+ Optional: For MPI support:<br />
```bash
sudo apt-get install libopenmpi-dev
```

+ Optional: For the python interface, python3 with matplotlib, cython and h5py is required:<br />
```bash
sudo pip3 install matplotlib cython h5py
```

## Clone, build and install
+ Clone this repository, build openEMS and install e.g. to "~/opt/openEMS":<br />
```bash
git clone --recursive https://github.com/thliebig/openEMS-Project.git
cd openEMS-Project
./update_openEMS.sh ~/opt/openEMS
```
+ Optional: Build all including [hyp2mat](https://github.com/koendv/hyp2mat) and [CTB](https://github.com/thliebig/CTB) and MPI:<br />
```bash
./update_openEMS.sh ~/opt/openEMS --with-hyp2mat --with-CTB --with-MPI
```

+ Optional: Build all including the new python extensions:<br />
```bash
./update_openEMS.sh ~/opt/openEMS --python
```

+ Add the given paths to your Octave/Matlab environment (e.g.):<br />
```Matlab
addpath('~/opt/openEMS/share/openEMS/matlab');
addpath('~/opt/openEMS/share/CSXCAD/matlab');
```

+ Optional: Add the optional packages to your Octave/Matlab environment (e.g.):<br />
```Matlab
addpath('~/opt/openEMS/share/hyp2mat/matlab');
addpath('~/opt/openEMS/share/CTB/matlab');
```

For more informations and other platforms see:
[http://www.openems.de/index.php/OpenEMS#Installation](http://www.openems.de/index.php/OpenEMS#Installation)<br />

## Update Instruction:
+ Perform an update in case of a new release

**Note:** Changes you may have made (e.g. to the tutorials or examples) may be overwritten!<br />
```bash
cd openEMS-Project
git pull
./update_openEMS.sh ~/opt/openEMS
```
