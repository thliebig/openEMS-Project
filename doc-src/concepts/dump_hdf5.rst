.. _concept_dump_hdf5:

Field Dump HDF5 File Format
=============================

All field dump boxes with ``file_type=1`` (HDF5) write a common file layout
regardless of the dump type. This page documents that layout so that custom
post-processing code can read the files directly, without going through the
Octave or Python helper functions.

.. seealso::

   :ref:`concept_fielddump` — how to set up dump boxes and choose
   ``dump_type``, ``dump_mode``, and ``file_type``

   :ref:`concept_sar` — the raw SAR dump (``dump_type=29``) extends this
   format with extra groups (``/CellData``, ``/CellWidth``)

   :ref:`concept_nf2ff` — the NF2FF surface dumps (``dump_type=0/1``,
   ``file_type=1``) follow exactly this format

Root attributes
---------------

``openEMS_HDF5_version``
   Format version number (float). Currently ``0.3``. Absent in very old
   files (treated as version 0).

``dump_type``
   Integer dump type as configured in the simulation (e.g. ``0`` for
   E-field TD, ``10`` for E-field FD, ``20`` for local SAR).

``legacy_fmt``
   Boolean, present only in files with version > 0.2. ``True`` if the
   file was written with ``--legacyHDF5Dumps``; the axis order of all
   field datasets is then reversed (see `Axis order and legacy format`_
   below).

Mesh group ``/Mesh``
---------------------

The mesh group stores the coordinates at which field values are evaluated.
What exactly those coordinates represent depends on the interpolation mode
(``dump_mode``) chosen when setting up the dump box:

- **Node interpolation** (``dump_mode=1``, default): coordinates are the
  primal mesh node lines. All field components are interpolated to the same
  node positions, so the mesh describes the sample locations exactly.
- **Cell interpolation** (``dump_mode=2``): coordinates are dual mesh
  midpoints, i.e. cell-centre positions. All components are interpolated to
  the same cell centres.
- **No interpolation** (``dump_mode=0``): coordinates are the primal mesh
  node lines, but the field components are **not** co-located — each
  component sits at its native Yee-grid position (staggered half-cell offsets
  relative to the node). The mesh lines give the grid positions; the actual
  sample point of each component follows the `Yee staggering convention
  <https://en.wikipedia.org/wiki/Finite-difference_time-domain_method>`_.

The ``dual_mesh`` root attribute (boolean) records which mesh was used
(``False`` for primal/node, ``True`` for dual/cell).

.. list-table::
   :header-rows: 1
   :widths: 20 20 60

   * - Dataset
     - Unit
     - Contents
   * - ``/Mesh/x``
     - metres
     - x-coordinates (Cartesian) or ρ-coordinates (cylindrical)
   * - ``/Mesh/y``
     - metres
     - y-coordinates (Cartesian) or α-coordinates in radians (cylindrical)
   * - ``/Mesh/z``
     - metres
     - z-coordinates (both mesh types)

For cylindrical meshes the dataset names are ``rho``, ``alpha``, ``z``.
For the spherical NF2FF output mesh they are ``r``, ``theta``, ``phi``.

Coordinates are stored in **SI metres** (the simulation length unit is
applied as a scaling factor, stored in the ``mesh_scaling`` attribute on
the ``/Mesh`` group). Angles are stored as-is (no scaling applied).

``/Mesh`` group attributes:

``mesh_type``
   ``0`` = Cartesian, ``1`` = cylindrical, ``2`` = spherical (NF2FF only).

``mesh_scaling``
   The simulation length unit in metres (e.g. ``1e-3`` for a mm mesh).
   Mesh coordinates are already multiplied by this factor; it is stored
   for reference.

Field data group ``/FieldData``
--------------------------------

All recorded field samples live under ``/FieldData``, split into two
sub-groups depending on the recording domain.

Time-domain data ``/FieldData/TD``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

One dataset per recorded timestep, named with a zero-padded integer matching
the simulation step counter (e.g. ``000100``, ``000200``, …).

Each dataset is a 4-D array of shape:

- **New format** (``openEMS_HDF5_version > 0.2``, ``legacy_fmt`` absent or
  ``False``): ``(3, Nx, Ny, Nz)`` — component-major, x-inner.
- **Legacy format**: ``(3, Nz, Ny, Nx)`` — component-major, z-inner.

The first dimension is the vector component: index 0 = x (or ρ), 1 = y (or
α), 2 = z.

Each dataset carries a scalar ``time`` attribute (float, seconds) giving the
simulation time at which the snapshot was taken.

Frequency-domain data ``/FieldData/FD``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Written when the dump has a frequency list attached (``dump_type`` 10–15,
and SAR on-the-fly types 20–22). The group carries:

- Attribute ``frequency``: 1-D array of all recorded frequencies in Hz.

One dataset per frequency index *n* (0-based), named ``f{n}``. The dataset
format differs between the two file versions:

**New format** (``legacy_fmt`` absent or ``False``)

A single dataset ``f{n}`` with an HDF5 compound datatype ``{r: float32,
i: float32}``, shape ``(3, Nx, Ny, Nz)``. The member names ``r`` and ``i``
are the ones h5py looks for by default (``h5py.get_config().complex_names``),
so h5py reads the dataset straight into a ``numpy.complex64`` array — no
manual conversion is needed. The dataset carries a scalar ``frequency``
attribute (Hz).

**Legacy format** (``legacy_fmt = True``)

Two separate float32 datasets: ``f{n}_real`` and ``f{n}_imag``, each of
shape ``(3, Nz, Ny, Nx)``. Each carries a scalar ``frequency`` attribute
(Hz).

For real-valued FD quantities (e.g. local SAR written on-the-fly by
``dump_type`` 20–22) there is no complex pair — a single dataset ``f{n}``
holds the scalar field, shape ``(Nx, Ny, Nz)`` (new) or ``(Nz, Ny, Nx)``
(legacy).

Axis order and legacy format
-----------------------------

Every dataset carries a ``d_order`` string attribute that records the axis
ordering as written to disk:

- ``"NXYZ"`` — component index N is outermost, x is innermost (new default).
  Reading with h5py gives shape ``(3, Nx, Ny, Nz)`` with natural index
  order ``[component, ix, iy, iz]``.
- ``"NZYX"`` — z is outermost (legacy). Reading with h5py gives shape
  ``(3, Nz, Ny, Nx)``; transpose or swap axes before use.
- Scalar fields use ``"XYZ"`` or ``"ZYX"`` respectively (no N dimension).

**Version detection rule** (mirrors the C++ reader):

- ``openEMS_HDF5_version`` absent or ``0``: always legacy.
- ``openEMS_HDF5_version`` > 0 and ≤ 0.2: always legacy.
- ``openEMS_HDF5_version`` > 0.2: read the ``legacy_fmt`` boolean attribute;
  if absent, assume new format.

The ``d_order`` attribute is the authoritative source — if present, always
prefer it over version inference.

Reading field dumps
--------------------

**Python**

:class:`openEMS.utilities.HDF5Dump` reads any of the dump variants described
above — complex or real, vector or scalar, current or legacy axis order — and
always returns the data in the natural, x-inner order. Opening the file only
reads the metadata, so the dump can be inspected before any field data is
read:

.. code-block:: python

    from openEMS.utilities import HDF5Dump

    with HDF5Dump('Ef.h5') as dump:
        print(dump)                    # dump type, domain, grid size, region
        dump.DumpType, dump.DumpTypeName
        dump.IsTD, dump.IsFD           # which domain(s) the file holds
        dump.Shape                     # (Nx, Ny, Nz)
        dump.Frequencies               # recorded frequencies in Hz
        dump.Times                     # recorded timesteps in s

        E = dump.GetFieldAtFrequency(2.4e9)
        # complex ndarray (3, Nx, Ny, Nz), first index = x/y/z component

        mesh = dump.GetMesh()
        x = mesh['lines'][0] / mesh['scaling']    # x-lines in drawing units

The frequency requested from :meth:`GetFieldAtFrequency` must match one stored
in the file. If the file holds **time-domain** data instead, the frequency is
computed by an on-the-fly DFT, so the same post-processing code works whether
the dump was recorded as TD or FD. The DFT reads every timestep but holds only
one of them in memory at a time.

A region of interest can be configured on the object and then applies to every
subsequent read. The selection is passed down to HDF5, so only the requested
data is read from disk — reading a single plane out of a large 3D dump is much
faster than reading all of it:

.. code-block:: python

    with HDF5Dump('Et.h5') as dump:
        dump.SetPlane('z', pos=10e-3)      # nearest z-line to 10 mm
        dump.SetRange('x', start=-5e-3, stop=5e-3)
        dump.SetSampling(2, 2, 1)          # every other x- and y-line

        for time, field in dump.IterTD(component='z'):
            ...                            # Ez in the selected plane

        mesh = dump.GetMesh(region=True)   # mesh lines matching the data
        dump.ResetRegion()                 # back to the full dump

``SetLine`` reduces the read to a single line, collapsing the two
perpendicular directions:

.. code-block:: python

    dump.SetLine('x', idx=(None, 3, 5))        # along x at y-index 3, z-index 5
    dump.SetLine('z', pos=(0.0, 1e-3, None))   # along z at x = 0, y = 1 mm

The entry for each direction is given by its **position in the sequence**, so
there is no ambiguity about the order — the entry for the line direction
itself must be ``None``.

There is only ever one plane, and only ever one line: calling ``SetPlane`` or
``SetLine`` again — for the same direction or a different one — replaces the
previous collapse, so stepping through slices or switching the slice
orientation needs no reset. Ranges and sampling on the directions that stay
open are kept. ``SetRange`` is per-direction and composes across directions as
expected.

``SetLine`` always collapses its two perpendicular directions, replacing
whatever was set for them. For the line direction itself, a setting that would
leave fewer than two lines — a former plane normal, or a previous line — is
reset to the full extent, while an existing range of two or more lines is kept.

Setting a *plane* and a *range* on the **same** direction contradicts itself
and raises; clear that direction first with ``ResetRegion(ny)``, which resets a
single direction and leaves the others untouched.

Directions are given as ``0``/``1``/``2`` or by coordinate name (``'x'``,
``'y'``, ``'z'``, or ``'rho'``, ``'alpha'``, ``'z'`` for a cylindrical mesh).
Positions passed as ``pos``/``start``/``stop`` are in SI units and are snapped
to the nearest mesh line; ``idx``/``idx_start``/``idx_stop`` take mesh line
indices instead. :meth:`NearestIndex` converts a coordinate to an index.

The ``File`` property exposes the underlying open ``h5py.File`` for anything
not wrapped by the class, such as the ``/CellData`` and ``/CellWidth`` groups
of a raw SAR dump.

:func:`openEMS.sar_utils.readSAR` is a small convenience wrapper around the
class for the common case of reading a complete SAR result in one call.

Reading the file directly with ``h5py`` is of course possible, but then the
version, ``legacy_fmt`` and ``d_order`` handling described above has to be
repeated in your own code.

**Octave / Matlab**

.. code-block:: matlab

    [field, mesh] = ReadHDF5Dump('Et.h5');
    % field.FD.values{1}  — complex array (Nx, Ny, Nz, 3) after transposing
    % mesh.lines{1/2/3}   — coordinate vectors in metres
    % mesh.type           — 0 Cartesian, 1 cylindrical

``ReadHDF5Dump`` handles legacy/new detection and axis transposition
automatically. Use it in preference to reading the HDF5 file directly.
