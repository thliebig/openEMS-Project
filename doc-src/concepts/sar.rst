.. _concept_sar:

Specific Absorption Rate (SAR)
================================

The Specific Absorption Rate (SAR) quantifies the power absorbed per unit mass
in biological tissue (W/kg). openEMS computes it from the simulated electric
field and the tissue conductivity and density distributions.

SAR is used, for example, to verify compliance with RF exposure limits in MRI
coil and antenna design, or to estimate heating in implant safety studies.

.. note::
   None of the spatial averaging methods — ``SIMPLE``, ``IEEE_C95_3`` and
   ``IEEE_62704`` alike — has been validated against IEC/IEEE-62704-1. Use
   averaged results for research and design guidance only, not for regulatory
   compliance. Local SAR involves no averaging at all and is unaffected.

Material averaging
-------------------

.. important::
   Set ``CellConstantMaterial`` on any simulation that will be evaluated for
   SAR.

By default openEMS derives the material coefficients of each Yee cell by
probing the geometry at four *quarter-cell* positions per field component
(``Operator::AverageMatQuarterCell``). A cell straddling a tissue boundary
therefore ends up with a blended effective conductivity and permittivity, which
generally models the boundary more accurately.

The SAR calculation cannot represent that blend. It takes exactly one
conductivity and one density per cell, probed at the **cell centre**, and
computes the local power density as

.. math::

   p(i) = \tfrac{1}{2}\, \sigma_i \, |E_i|^2

At every material boundary the conductivity used here differs from the one the
FDTD run actually stepped with, so the local SAR is wrong in exactly those
cells — and since the averaging cubes near a tissue surface are built from
them, the 1 g and 10 g results inherit the error.

``CellConstantMaterial`` switches the operator to probing at cell centres only
(``Operator::AverageMatCellCenter``), which makes every cell materially
homogeneous. The conductivity and density the SAR calculation assumes are then
the ones the simulation used.

IEC/IEEE 62704-1 defines its averaging on a voxel model with a single material
per voxel, so this is a prerequisite for a standards-compliant result rather
than a mere accuracy tweak. It does make the boundary representation itself
coarser (plain staircasing), which is the trade-off the standard accepts.

.. tabs::

   .. code-tab:: octave

      FDTD = InitFDTD('CellConstantMaterial', 1);

   .. code-tab:: python

      FDTD = openEMS(CellConstantMaterial=True)

Dump types
----------

The FDTD engine writes SAR-related data through field dump boxes. Four dump
types are relevant:

``dump_type=20`` — ``SAR_LOCAL_DUMP``
   Local SAR computed on-the-fly during the simulation. Quick to read back,
   but the averaging step cannot be performed afterward.

``dump_type=21`` — ``SAR_1G_DUMP``
   1 g averaged SAR, computed on-the-fly. Convenient but inflexible — the
   mass cannot be changed after the run.

``dump_type=22`` — ``SAR_10G_DUMP``
   10 g averaged SAR, computed on-the-fly.

``dump_type=29`` — ``SAR_RAW_DATA``
   Raw E-field, conductivity, density, and cell geometry data are written to
   an HDF5 file. The ``sar_calc`` binary then computes local or averaged SAR
   as a post-processing step. **This is the recommended mode** — it preserves
   all information and allows the averaging method and mass to be chosen (or
   changed) after the simulation.

Use ``SAR_RAW_DATA`` unless storage space is severely constrained.

The ``sar_calc`` binary
------------------------

Usage::

    sar_calc -i <input.h5> -o <output.h5> [options]

``-i``, ``--input`` *(required)*
   Path to the raw SAR HDF5 file written by the FDTD engine
   (``dump_type=29``).

``-o``, ``--output`` *(required)*
   Path for the result HDF5 file.

``--method`` *(default:* ``SIMPLE`` *)*
   Spatial averaging method: ``SIMPLE``, ``IEEE_C95_3``, or ``IEEE_62704``.
   Has no effect when ``--mass`` is ``0``.

``-m``, ``--mass`` *(default:* ``0`` *)*
   Averaging mass in **grams**. ``0`` selects local SAR regardless of method.

``-a``, ``--autorange`` *(default: disabled)*
   Restrict averaging to cells whose local power density is within this many
   dB of the peak. Speeds up computation on large meshes with a localised hot
   spot.

``-n``, ``--numThreads`` *(default: all CPUs)*
   Number of worker threads.

``-v``, ``--verbose`` *(default: off)*
   Print per-frequency summary (power, max SAR, peak position).

``-p``, ``--progress`` *(default: off)*
   Show a progress indicator during averaging.

``-e``, ``--export_cube_stats`` *(default: off)*
   Write per-cell cube statistics (type, mass, volume) to the output file,
   see `Averaging cube statistics`_. Needed to validate the averaging against
   IEC/IEEE 62704-1. Single frequency only.

``--legacyHDF5Dumps`` *(default: off)*
   Write results using the legacy HDF5 layout required by older Octave
   readers. Always set by ``CalcSAR.m``; not needed from Python.

.. note::
   The Python interface calls the same C++ averaging code directly through
   the ``sar_calculation`` Cython extension and does not invoke the binary.

Input HDF5 format (``SAR_RAW_DATA``, dump\_type 29)
------------------------------------------------------

The raw SAR dump is a standard openEMS field dump HDF5 file
(see :ref:`concept_dump_hdf5`) with two additional groups that carry the
material information needed for averaging.

The standard ``/Mesh`` and ``/FieldData/FD`` groups are present as
documented in :ref:`concept_dump_hdf5`. The E-field is written as a complex
FD vector field using the new compound HDF5 type (``f{n}``, not split into
``_real``/``_imag``) regardless of the global legacy flag.

**Cell-width group** ``/CellWidth``

Cell widths at each mesh node, used by the averaging algorithm:

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Dataset
     - Contents
   * - ``/CellWidth/x``
     - Width of each cell in the x-direction, shape ``(Nx,)``
   * - ``/CellWidth/y``
     - Width in y, shape ``(Ny,)``
   * - ``/CellWidth/z``
     - Width in z, shape ``(Nz,)``

**Cell-data group** ``/CellData``

Per-cell material properties sampled at cell centres:

All three datasets have shape ``(Nx, Ny, Nz)``.

``/CellData/Density``
   Mass density ρ in kg/m³. Zero marks air/background cells that are excluded
   from SAR averaging.

``/CellData/Conductivity``
   Electric conductivity σ in S/m.

``/CellData/Volume``
   Cell volume in m³ (pre-computed from the non-uniform mesh for efficiency).

Output HDF5 format
-------------------

The result file written by ``sar_calc`` (or ``SAR_Calculation::WriteToHDF5``)
has the following structure.

**Root attributes**

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Attribute
     - Contents
   * - ``openEMS_HDF5_version``
     - Format version (currently ``0.3``). ``readSAR`` checks this to
       decide whether axis-swap is needed.
   * - ``mass``
     - Total tissue mass enclosed by the dump box in kg.
   * - ``proc_time``
     - Wall-clock time of the averaging calculation in seconds.
   * - ``legacy_fmt``
     - Present (and ``True``) only when ``--legacyHDF5Dumps`` was set.

**Mesh group** ``/Mesh``

Node coordinates of the output mesh (may be a subset of the input mesh if
``autorange`` trimmed air-only regions):

``/Mesh/x``, ``/Mesh/y``, ``/Mesh/z`` — same unit as the simulation.

**Field-data group** ``/FieldData/FD``

Group attributes:

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Attribute
     - Contents
   * - ``frequency``
     - Array of frequencies in Hz (same as input)
   * - ``valid_cubes``
     - Number of cells where a full averaging cube was found
   * - ``used_cubes``
     - Cells assigned SAR from a partial or neighbour cube
   * - ``unused_cubes``
     - Cells where no averaging cube could be constructed
   * - ``air_cubes``
     - Cells skipped because density is zero (air/background)

**SAR datasets** — one per frequency index *n* (0-based):

.. list-table::
   :header-rows: 1
   :widths: 30 15 55

   * - Dataset
     - Shape
     - Contents
   * - ``/FieldData/FD/f{n}``
     - ``(Nx, Ny, Nz)``
     - SAR in W/kg. Zero in air cells (density = 0).

Dataset attributes on each ``/FieldData/FD/f{n}``:

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Attribute
     - Contents
   * - ``frequency``
     - Frequency in Hz for this dataset
   * - ``power``
     - Total absorbed power in W integrated over all tissue cells
   * - ``maxSAR``
     - Peak SAR value in W/kg
   * - ``maxSAR_idx``
     - 3-element index ``[ix, iy, iz]`` of the peak SAR cell

Averaging cube statistics
~~~~~~~~~~~~~~~~~~~~~~~~~~

When ``--export_cube_stats`` is set, three additional datasets are written
alongside each ``f{n}``. They record how the averaging cube was found for
every cell, and are the main handle for validating the averaging against the
conformance requirements of IEC/IEEE 62704-1 — they show which cells got a
proper centred cube, which fell back to a neighbouring one, and what mass and
volume each cube actually enclosed.

.. list-table::
   :header-rows: 1
   :widths: 35 65

   * - Dataset
     - Contents
   * - ``f{n}_CubeType``
     - How the cube was obtained (unsigned byte), see the table below
   * - ``f{n}_CubeMass``
     - Mass enclosed by the averaging cube (kg). Compare against the requested
       averaging mass to check the convergence tolerance.
   * - ``f{n}_CubeVol``
     - Volume of the averaging cube (m³)

``f{n}_CubeType`` values:

.. list-table::
   :header-rows: 1
   :widths: 15 85

   * - Value
     - Meaning
   * - ``0``
     - No averaging cube — background/air, or no cube could be built
   * - ``1``–``6``
     - Second pass: the cube was built with one face pinned to the cell.
       ``1``/``2`` = lower/upper x face, ``3``/``4`` = y, ``5``/``6`` = z
   * - ``7``
     - First pass: a valid cube enclosing the target mass was found centred
       on the cell itself
   * - ``8``
     - The cell was covered by another cell's cube but never got a valid cube
       of its own

.. note::
   Cube statistics can only be recorded for a **single** frequency. With more
   than one frequency of interest the calculation prints a warning and writes
   no statistics.

Axis convention
~~~~~~~~~~~~~~~

The SAR array is stored **x-major** (outer index x, inner index z) in the
HDF5 file, which is the native openEMS array order. When reading with h5py,
the array shape is ``(Nx, Ny, Nz)`` with index order ``[ix, iy, iz]``.
Files written with ``openEMS_HDF5_version <= 0.2`` used the opposite
convention; ``readSAR`` detects this and swaps axes automatically.

Averaging methods
------------------

The averaging method only takes effect when an averaging mass is requested.
With ``--mass 0`` — which is also what ``dump_type=20`` uses — no cube is
built at all and the method is irrelevant: the local power density at each
cell is simply divided by the local density,

.. math::

   \mathrm{SAR}_\mathrm{local}(i) = \frac{\sigma_i |E_i|^2}{2\,\rho_i}

Cells with ρ = 0 mark air/background: no SAR is computed for them and they are
left at zero in the output. They are counted separately in the ``air_cubes``
attribute.

All three methods share the same core algorithm. A cube is centred on each
tissue cell and grown until it encloses the target mass, and the averaged SAR
is the total absorbed power in that cube divided by its mass. Partial cells at
the cube boundary are weighted by their fractional volume, and air cells
contribute zero power and zero mass. What separates the methods is how
strictly a cube must qualify as *valid* before its result is accepted, and
what happens to the cells whose cube is rejected.

**SIMPLE** — cubical mass averaging without the validity constraints.

The default, and despite the name a full 1 g or 10 g averaging algorithm —
not local SAR. It runs the same cube search as ``IEEE_C95_3`` and differs in a
single respect: any cube reaching the target mass is accepted, even one
clipped by the edge of the dump box. An averaging cube is therefore
constructed for essentially every tissue cell, so the fill-in step that the
standards methods depend on is rarely reached.

That fill-in is the practical difference between the methods. Where a
standards method rejects a cube it has to substitute a value taken from a
neighbouring cell's cube, and along tissue surfaces — where rejections
cluster — this can leave visible artifacts in the SAR distribution.
``SIMPLE`` produces a smooth distribution instead, at the price of not
following the validity rules the standards prescribe.

**IEEE_C95_3** — cubical mass averaging, IEEE C95.3 (2005) variant.

Adds the requirement that the cube fit inside the dump box without being
clipped at its edge. The mass must match the target to within 5 %. Cells whose
cube is rejected are assigned the SAR of a neighbouring valid cube.

**IEEE_62704** — cubical mass averaging, IEC/IEEE 62704-1 variant.

The strictest variant: the enclosed mass must match the target to within
0.0001 %, and no more than 10 % of the cube volume may be background (air).
It is this background limit that rejects cubes sitting on a tissue surface. In
the first pass every cell gets a fully-enclosed, sufficiently tissue-filled
cube; cells that cannot get one are assigned the SAR from the nearest valid
cube in a second pass.

The target mass is set with ``--mass`` (in grams). Typical values are 1 g
(``--mass 1``) or 10 g (``--mass 10``).

How ``CalcSAR`` drives the binary
-----------------------------------

**Octave / Matlab**

``CalcSAR(sar_fn, sar_out, ...)`` maps its keyword arguments to
``sar_calc`` command-line flags and always appends ``--legacyHDF5Dumps``
so the result can be read back by ``ReadHDF5Dump``.

**Python**

``openEMS.sar_calculation.SAR_Calculation`` wraps the same C++ class
directly. Call ``CalcFromHDF5(input, output)`` to run the full pipeline, or
use the lower-level API to supply field data manually. Results are read back
with :func:`openEMS.sar_utils.readSAR`.

Reading SAR results
--------------------

**Python**

.. code-block:: python

    from openEMS.sar_utils import readSAR

    sar, mesh, info = readSAR('SAR_result.h5', f_idx=0)
    # sar:  ndarray (Nx, Ny, Nz), W/kg
    # mesh: [x, y, z] arrays of node coordinates, in metres
    # info: dict with 'mass', 'frequency', 'power', 'maxSAR', ...

**Octave / Matlab**

.. code-block:: matlab

    SAR_field = ReadHDF5Dump('SAR_result.h5');
    % SAR_field.FD{1}.values  — 3-D array of SAR values
    % SAR_field.FD{1}.mesh    — mesh coordinates

.. seealso::

   :ref:`concept_fielddump` — field dump types including ``SAR_RAW_DATA``

   :ref:`concept_dump_hdf5` — HDF5 file format shared by all field dumps;
   the SAR raw input file extends it with ``/CellData`` and ``/CellWidth``

   :ref:`concept_disc_material` — tissue properties from voxelized body
   models, which provide the density and conductivity inputs for SAR
