 ![openEMS](https://raw.github.com/thliebig/openEMS-Project/master/other/openEMS.png "openEMS")<br />
openEMS is a free and open electromagnetic field solver using the FDTD method. Matlab or Octave are used as an easy and flexible scripting interface.<br />

**Website**: [http://openEMS.de](http://openEMS.de)<br />
**Forum**: [http://openEMS.de/forum](http://openEMS.de/forum)<br />
**Wiki**: [http://openems.de/index.php](http://openems.de/index.php)<br />
**Github**: [https://github.com/thliebig/openEMS-Project](https://github.com/thliebig/openEMS-Project)<br />

# openEMS Features:
+ fully 3D Cartesian and cylindrical coordinates graded mesh.
+ Multi-threading, SIMD (SSE) and MPI support for high speed FDTD.
+ Octave and Matlab-Interface
+ Dispersive material (Drude/Lorentz/Debye type)
+ Field dumps in time and frequency domain as vtk or hdf5 file format
+ Flexible post-processing routines in Octave/Matlab
+ and [many more](http://openems.de/index.php/OpenEMS#Features)

# Install Instruction

## Requirements

### Ubuntu
+ Install all necessary dependencies, e.g. on *Ubuntu 14.04 and above*:<br />
```bash
sudo apt-get install build-essential cmake git libhdf5-dev libvtk5-dev libboost-all-dev libcgal-dev libtinyxml-dev libqt4-dev libvtk5-qt4-dev
```

+ Optional: Install [octave](http://www.gnu.org/software/octave/) and octave devel packages:<br />
```bash
sudo apt-get install octave liboctave-dev
```

+ Optional: For the package [hyp2mat](https://github.com/koendv/hyp2mat) you need additonal dependencies:<br />
```bash
sudo apt-get install gengetopt help2man groff pod2pdf bison flex libhpdf-dev libtool
```

### Fedora
+ Install all necessary dependencies, e.g. on *Fedora 19*:<br />
```bash
sudo yum install make gcc gcc-c++ git hdf5-devel vtk-devel boost-devel CGAL-devel tinyxml-devel qt-devel vtk-qt
```

## Clone, build and install
+ Clone this repository, build openEMS and install e.g. to "~/opt/openEMS":<br />
```bash
git clone https://github.com/thliebig/openEMS-Project.git
cd openEMS-Project
./update_openEMS.sh ~/opt/openEMS
```
or including [hyp2mat](https://github.com/koendv/hyp2mat) and [CTB](https://github.com/thliebig/CTB):<br />
```bash
./update_openEMS.sh ~/opt/openEMS --with-hyp2mat --with-CTB
```

+ Add the given paths to your Octave/Matlab environment (e.g.):<br />
```Matlab
addpath('~/opt/openEMS/share/openEMS/matlab');
addpath('~/opt/openEMS/share/CSXCAD/matlab');
```

+ Add the optional packages to your Octave/Matlab environment (e.g.):<br />
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
