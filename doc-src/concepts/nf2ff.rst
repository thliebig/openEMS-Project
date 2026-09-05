.. _concept_nf2ff:

Near-Field to Far-Field Transformation (NF2FF)
===============================================

The near-field to far-field transformation converts the tangential E and H fields
recorded on a closed surface around the antenna into far-field quantities:
directivity, radiated power, and the complex far-field pattern (E_theta, E_phi)
on a sphere at an arbitrary radius.

The transformation is performed by the ``nf2ff`` binary (or the equivalent C++
library used by the Python interface).

Setup overview
--------------

#. Surround the antenna with a virtual box of six E/H field dump surfaces
   using ``CreateNF2FFBox`` (Octave) or :class:`openEMS.nf2ff.nf2ff` (Python).
   Each surface records the tangential fields during the FDTD run.
#. After the simulation, call ``CalcNF2FF`` (Octave) or
   ``nf2ff.CalcNF2FF`` (Python) to run the transformation.
#. Read the result from the output HDF5 file.

The box must fully enclose all radiating structures, must not intersect any
metallic objects or lossy materials, and must be placed at least a few cells
away from the PML.

Recording modes
---------------

**Time-domain (broadband)** — default.

The FDTD engine writes the full time series to HDF5. The nf2ff tool computes
the DFT on-the-fly for every frequency listed in the control file. This is the
most flexible mode: any frequency within the simulation bandwidth can be
evaluated after the fact.

**Frequency-domain (single or multi-frequency)**.

Requested by setting ``dump_type = 10/11`` (E/H FD dump). The engine writes
pre-computed Fourier coefficients at a fixed set of frequencies. Useful when
only a few frequencies are needed and disk space or post-processing time is
a concern. The frequencies requested from ``CalcNF2FF`` must exactly match
the frequencies used for the FD dump.

The ``nf2ff`` binary
---------------------

Usage::

    nf2ff <nf2ff-xml-file>

The binary takes a single argument: the path to an XML control file. All
parameters (frequencies, angle grids, surface file paths, output file) are
specified in the XML. ``CalcNF2FF`` writes this file automatically before
invoking the binary.

.. note::
   The Python interface calls the same C++ code through a Cython extension
   and does not use the binary or the XML file at all.

XML control file format
-----------------------

The control file is an XML document with a single root element ``<nf2ff>``.

.. code-block:: xml

    <nf2ff freq="2.4e9 5e9"
           Outfile="nf2ff_result.h5"
           Center="0 0 0"
           Radius="1"
           Eps_r="1"
           Mue_r="1"
           NumThreads="0"
           Verbose="0">
        <theta>0 0.0175 0.0349 ... 3.1416</theta>
        <phi>0 1.5708 3.1416 4.7124</phi>

        <Planes E_Field="nf2ff_E_xn.h5" H_Field="nf2ff_H_xn.h5"/>
        <Planes E_Field="nf2ff_E_xp.h5" H_Field="nf2ff_H_xp.h5"/>
        <Planes E_Field="nf2ff_E_yn.h5" H_Field="nf2ff_H_yn.h5"/>
        <Planes E_Field="nf2ff_E_yp.h5" H_Field="nf2ff_H_yp.h5"/>
        <Planes E_Field="nf2ff_E_zn.h5" H_Field="nf2ff_H_zn.h5"/>
        <Planes E_Field="nf2ff_E_zp.h5" H_Field="nf2ff_H_zp.h5"/>

        <Mirror Type="PEC" Dir="2" Pos="0"/>
    </nf2ff>

``<nf2ff>`` attributes
~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Attribute
     - Default
     - Description
   * - ``freq``
     - (required)
     - Space-separated list of frequencies in Hz at which to evaluate the
       far field.
   * - ``Outfile``
     - (required)
     - Path to the output HDF5 result file.
   * - ``Center``
     - ``0 0 0``
     - Phase centre of the antenna in simulation coordinates (same unit as
       the mesh). Must lie inside the recording box.
   * - ``Radius``
     - ``1``
     - Radius of the far-field sphere in metres. Used only for scaling the
       radiated power density; the pattern shape is independent of it.
   * - ``Eps_r``
     - ``1``
     - Relative electric permittivity of the medium surrounding the antenna.
       Can be a single value or a space-separated list matching ``freq``.
   * - ``Mue_r``
     - ``1``
     - Relative magnetic permeability. Same format as ``Eps_r``.
   * - ``NumThreads``
     - ``0`` (all CPUs)
     - Number of threads for the transformation. ``0`` lets the runtime
       choose.
   * - ``Verbose``
     - ``0``
     - Verbosity level: ``0`` = silent, ``1`` = progress, ``2`` = detailed.

``<theta>`` and ``<phi>``
~~~~~~~~~~~~~~~~~~~~~~~~~~

Text content is a space-separated list of angles **in radians** defining the
evaluation grid on the far-field sphere.

``theta`` runs from 0 (z+ pole) to π (z− pole).
``phi`` runs from 0 to 2π in the x-y plane.

``<Planes>``
~~~~~~~~~~~~~

Each ``<Planes>`` element points to one pair of surface dump files:

- ``E_Field``: path to the HDF5 file containing the E-field surface dump.
- ``H_Field``: path to the HDF5 file containing the H-field surface dump.

The E and H meshes must be identical. Up to six surfaces are typical (one per
face of the bounding box). Disabled faces (set via the ``directions`` option
in ``CreateNF2FFBox``) simply have no ``<Planes>`` entry.

``<Mirror>``
~~~~~~~~~~~~~

Symmetry planes that halve the simulation domain can be accounted for by
mirroring:

- ``Type``: ``"PEC"`` or ``"PMC"``.
- ``Dir``: direction axis — ``0`` (x), ``1`` (y), ``2`` (z).
- ``Pos``: position of the symmetry plane in simulation coordinates.

Multiple ``<Mirror>`` elements are allowed.

Input HDF5 surface dump format
-------------------------------

Each ``<Planes>`` pair references one E-field file and one H-field file
written by the FDTD engine. Both are standard openEMS field dump HDF5 files
(see :ref:`concept_dump_hdf5`) — there is nothing NF2FF-specific about their
layout.

Because each surface is a 2D plane, one of the three ``/Mesh`` coordinate
arrays contains a single entry. The nf2ff tool detects the normal direction
automatically from whichever axis has only one grid line.

The tool accepts both time-domain dumps (broadband; DFT computed on-the-fly)
and frequency-domain dumps (``dump_type=10/11``; frequencies must match
exactly). If FD data is present and matches the requested frequencies it is
used directly; otherwise it falls back to DFT of the TD data.

Output HDF5 result format
--------------------------

The result file is written to the path given in ``Outfile``. It contains both
the far-field pattern and scalar summary quantities.

**Mesh group** ``/Mesh``

.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Dataset / Attribute
     - Shape
     - Contents
   * - ``/Mesh/theta``
     - ``(Nθ,)``
     - Theta angles in radians (same as the input grid)
   * - ``/Mesh/phi``
     - ``(Nφ,)``
     - Phi angles in radians
   * - ``/Mesh/r``
     - ``(1,)``
     - Far-field radius in metres
   * - Attribute ``MeshType``
     - scalar
     - Always ``2`` (spherical coordinate system)

**Summary attributes** on ``/nf2ff``

.. list-table::
   :header-rows: 1
   :widths: 25 15 60

   * - Attribute
     - Shape
     - Contents
   * - ``Frequency``
     - ``(Nf,)``
     - Frequencies in Hz (same as the input list)
   * - ``Prad``
     - ``(Nf,)``
     - Total radiated power in watts, integrated over the full sphere
   * - ``Dmax``
     - ``(Nf,)``
     - Maximum directivity (dimensionless, linear scale)
   * - ``Eps_r``
     - ``(Nf,)``
     - Relative permittivity used (present only when set)
   * - ``Mue_r``
     - ``(Nf,)``
     - Relative permeability used (present only when set)

**Far-field datasets** under ``/nf2ff``

For each frequency index *n* (0-based):

.. list-table::
   :header-rows: 1
   :widths: 40 15 45

   * - Dataset
     - Shape
     - Contents
   * - ``/nf2ff/E_theta/FD/f{n}_real``
     - ``(Nφ, Nθ)``
     - Real part of the theta component of the far electric field (V/m at radius r)
   * - ``/nf2ff/E_theta/FD/f{n}_imag``
     - ``(Nφ, Nθ)``
     - Imaginary part of E_theta
   * - ``/nf2ff/E_phi/FD/f{n}_real``
     - ``(Nφ, Nθ)``
     - Real part of the phi component
   * - ``/nf2ff/E_phi/FD/f{n}_imag``
     - ``(Nφ, Nθ)``
     - Imaginary part of E_phi
   * - ``/nf2ff/P_rad/FD/f{n}``
     - ``(Nφ, Nθ)``
     - Radiated power density in W/sr (Poynting vector magnitude × r²)

.. note::
   Datasets are stored **phi-major** (outer index φ, inner index θ) — this
   matches the column-major convention expected by Octave/Matlab readers and
   is a historical artefact of the format. Both the Python reader
   (``np.swapaxes``) and the Octave reader transpose on load, so the returned
   array always follows ``[theta_idx, phi_idx]`` regardless of language. The
   on-disk axis order may be normalised to match the rest of the field dump
   format in a future release.

Derived quantities
~~~~~~~~~~~~~~~~~~

The following quantities can be computed from the datasets above:

.. code-block:: python

    # directivity pattern  (dimensionless, per frequency index n)
    D = 4*np.pi * P_rad[n] / Prad[n]        # shape (Ntheta, Nphi)

    # normalised E-field magnitude
    E_norm = np.sqrt(np.abs(E_theta[n])**2 + np.abs(E_phi[n])**2)

    # right/left-hand circular polarisation
    THETA, PHI = np.meshgrid(theta, phi, indexing='ij')
    E_cprh = (np.cos(PHI) + 1j*np.sin(PHI)) * (E_theta[n] + 1j*E_phi[n]) / np.sqrt(2)
    E_cplh = (np.cos(PHI) - 1j*np.sin(PHI)) * (E_theta[n] - 1j*E_phi[n]) / np.sqrt(2)

How ``CalcNF2FF`` drives the binary
------------------------------------

**Octave / Matlab**

``CalcNF2FF`` serialises all parameters into an XML control file, then calls
the ``nf2ff`` binary as a shell command.  The binary writes the result HDF5,
which is read back by ``ReadNF2FF``.  If a cached result file already exists
and ``Mode`` is 0 (the default), the binary is skipped and the cached file is
read directly — provided the frequency, theta, and phi arrays match.

**Python**

``nf2ff.CalcNF2FF`` calls the same C++ transformation code directly through
the ``_nf2ff`` Cython extension.  It constructs an ``_nf2ff._nf2ff`` object,
feeds it the surface HDF5 files with ``AnalyseFile``, and writes the result
with ``Write2HDF5``.  No XML file or external binary process is involved.
The ``read_cached`` parameter (default ``False``) controls whether an existing
result file is reused.

.. seealso::

   :ref:`concept_fielddump` — field dump types and parameters used to record
   the NF2FF surfaces during the simulation

   :ref:`concept_dump_hdf5` — HDF5 file format shared by all field dumps,
   including the NF2FF surface input files

   Simple Patch Antenna tutorial:
   :ref:`Octave <octave_tutorial_simple_patch>` /
   :ref:`Python <simple_patch_antenna>` — minimal example demonstrating
   ``CreateNF2FFBox`` and ``CalcNF2FF``
