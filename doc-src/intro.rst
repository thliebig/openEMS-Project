.. _intro_src:

=============
Introduction
=============

openEMS is a free and open source electromagnetic field solver based on the
Finite-Difference Time Domain (FDTD) method. Using an improved version of
the highly-successful FDTD method (known as Equivalent-Circuit FDTD, or
EC-FDTD), openEMS solves Maxwell's equations in discretized space and time
to directly simulates the propagation of electromagnetic waves, in a 3D
full-wave manner. It has the potential to analyze problems in important
applications such as RF/microwave circuit design, antenna, radar,
meta-material, and medical research.

The engine is written in C++, and simulations are defined via an extensive
set of Matlab/Octave or Python interfaces for flexible programming. A separate
library CSXCAD, also part of the openEMS project, is used for handling geometry
used in the FDTD simulations. To help programming, a simple graphical user
interface for CSXCAD, called AppCSXCAD, is also included for inspecting 3D
models.

The project is started and maintained by Thorsten Liebig at the laboratory for
General and Theoretical Electrical Engineering (ATE), University of Duisburg-Essen
since February 2010.

openEMS is licensed under the GNU General Public License, Version 3 or later,
CSXCAD is licensed under the GNU Lesser General Public License, Version 3 or
later.

Features
================

* 3D cartesian coordinates (x,y,z) and cylindrical coordinates (ρ, φ, z).
* Fully graded mesh.
* Subgrids to reduce simulation time in cylindrical coordinates
* Absorbing boundary conditions (MUR, PML)
* Field dumps in time and frequency domain as vtk or hdf5 file format
* Near-field to Far-field (NF2FF) transform for antenna simulation.
* Coordinate dependent material definitions
* Coordinate dependent excitation definitions (e.g. mode-profiles)
* Matlab/Octave and Python-Interface
* Flexible post-processing routines (mostly in Matlab/Octave)
* Multi-threading, SIMD (SSE) and MPI support for parallel FDTD.
* Cross-platform support, including Linux, FreeBSD, macOS and Windows, and has been successfully built on x86, ARM, and POWER9 CPUs.

Citation
============================

If you are using openEMS for any publication, we kindly ask you to cite
openEMS using the following reference.

BibTex::

    @ELECTRONIC{openEMS,
      author = {Thorsten Liebig},
      title = {openEMS - Open Electromagnetic Field Solver},
      organization = {General and Theoretical Electrical Engineering (ATE), University of Duisburg-Essen},
      url = {https://www.openEMS.de}
    }
