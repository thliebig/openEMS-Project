.. _concept_disc_material:

Discrete (Voxelized) Material
==============================

A *discrete material* (``DiscMaterial``) maps spatially varying material
properties onto an FDTD mesh by reading a voxel grid from an HDF5 file.
Each voxel carries an integer tissue index; a small lookup table stored in the
same file provides the electromagnetic and physical properties (εr, κ, ρ) for
each index.

This is the standard approach whenever the material distribution is too complex
to describe analytically — human body models for MRI safety assessment (SAR),
heterogeneous tissue phantoms, geological or biological samples, or any dataset
derived from CT/MRI imaging.

Use in a Simulation
--------------------

``AddDiscMaterial`` registers the HDF5 file as a material property.
At least one primitive (usually an ``AddBox``) must then bound the region where
the material is active.

.. tabs::

   .. code-tab:: octave

      unit = 1e-3;  % drawing unit: mm

      CSX = AddDiscMaterial(CSX, 'tissue', ...
          'File',      'my_phantom.h5', ...
          'Scale',     1/unit, ...
          'Transform', {'Rotate_Z', pi/2, 'Translate', [0 0 -50]});

      % bound the active region
      CSX = AddBox(CSX, 'tissue', 0, [-120 -120 -100], [120 120 100]);

   .. code-tab:: python

      Not yet available in the Python interface — use the Octave/Matlab
      interface or call openEMS via the XML workflow.

``Scale`` and ``Transform`` control coordinate lookup:

1. The incoming FDTD cell-centre coordinate is inverse-transformed by
   ``Transform``.
2. The result is divided by ``Scale``.
3. The scaled coordinate is looked up in the HDF5 mesh.

If the HDF5 mesh is in **metres**, use ``Scale = 1/unit`` (where
``unit = 1e-3`` gives ``Scale = 1000``). If the mesh is in **millimetres**,
use ``Scale = 1``.

.. important::

   The bounding box primitive clips the material to a rectangular region.
   Voxels outside the bounding box are ignored regardless of their index.
   Index 0 is always treated as the background material (air by default).

Cylindrical Simulations
""""""""""""""""""""""""

A Cartesian disc-material file works correctly in a cylindrical FDTD
simulation (``CoordSystem = 1``). openEMS converts each cell-centre
position from cylindrical ``(r, α, z)`` to Cartesian ``(x, y, z)`` before
querying the disc-material lookup, so the Cartesian phantom mesh is sampled
at the correct physical location.


HDF5 File Format
-----------------

All disc-material files use **CSXCAD DiscMaterial version 2**. The layout is:

.. code-block:: text

   /                    attr  Version = 2.0  (float64)
   /DiscData             uint8 ndarray, shape (nz, ny, nx) in C/numpy order
     attr DB_Size        int32 — number of tissue types (incl. background)
     attr epsR           float32[DB_Size] — relative permittivity
     attr kappa          float32[DB_Size] — electric conductivity (S/m)
     attr density        float32[DB_Size] — mass density (kg/m³)
     attr Name           str — comma-separated tissue names
   /mesh/x               float32[nx+1] — x cell-boundary positions
   /mesh/y               float32[ny+1] — y cell-boundary positions
   /mesh/z               float32[nz+1] — z cell-boundary positions

Array ordering
   ``/DiscData`` is indexed ``[iz, iy, ix]`` in C/numpy row-major order
   (x varies fastest in flat memory). The cell at mesh position
   ``(ix, iy, iz)`` carries index ``DiscData[iz, iy, ix]``.

Tissue index 0
   Always treated as background. Typically set to air
   (εr = 1, κ = 0, ρ = 0).

Mesh units
   The mesh positions must be consistent with the ``Scale`` parameter
   passed to ``AddDiscMaterial``. Using metres throughout and
   ``Scale = 1/unit`` is the recommended convention.


Creating a Disc-Material File — Octave/Matlab
----------------------------------------------

Use ``CreateDiscMaterial`` from the CSXCAD Matlab interface:

.. code-block:: octave

   % tissue index array: size (nx, ny, nz) — Matlab column-major
   % index 0 = air, 1 = tissue A, 2 = tissue B
   data = zeros(nx, ny, nz, 'uint8');
   data(ix_range, iy_range, iz_range) = 1;  % fill a rectangular block

   % material database (index 0 first)
   mat_db.epsR    = [1.0   52.7  11.4];   % air, tissue A, tissue B
   mat_db.kappa   = [0.0    0.95  0.29];
   mat_db.density = [0.0   1046  1908];
   mat_db.Name    = {'Background', 'TissueA', 'TissueB'};

   % mesh: nx+1 x-lines, ny+1 y-lines, nz+1 z-lines (in metres)
   mesh.x = linspace(-0.10, 0.10, nx + 1);
   mesh.y = linspace(-0.08, 0.08, ny + 1);
   mesh.z = linspace(-0.10, 0.10, nz + 1);

   CreateDiscMaterial('my_phantom.h5', data, mat_db, mesh);

.. note::

   ``CreateDiscMaterial`` currently requires **Matlab** — Octave's HDF5
   write support is incomplete. Use the Python path (below) if Octave is
   your only scripting environment.


Creating a Disc-Material File — Python
----------------------------------------

The ``h5py`` library provides full HDF5 write support on all platforms and
is the recommended way to generate disc-material files programmatically.

.. code-block:: python

   import numpy as np
   import h5py, os

   # --- geometry ----------------------------------------------------------
   res = 2.5e-3          # 2.5 mm voxel size
   mesh_x = np.linspace(-0.100, 0.100, 81)   # 80 cells
   mesh_y = np.linspace(-0.080, 0.080, 65)   # 64 cells
   mesh_z = np.linspace(-0.100, 0.100, 81)   # 80 cells

   xc = 0.5 * (mesh_x[:-1] + mesh_x[1:])    # cell centres
   yc = 0.5 * (mesh_y[:-1] + mesh_y[1:])
   zc = 0.5 * (mesh_z[:-1] + mesh_z[1:])

   nx, ny, nz = len(xc), len(yc), len(zc)

   # --- tissue index array ------------------------------------------------
   # shape (nx, ny, nz) with indexing='ij' — x first
   Xc, Yc, Zc = np.meshgrid(xc, yc, zc, indexing='ij')

   # example: ellipsoidal inclusion at origin, semi-axes 80x60x80 mm
   r = np.sqrt((Xc/0.080)**2 + (Yc/0.060)**2 + (Zc/0.080)**2)
   data_xyz = np.zeros((nx, ny, nz), dtype=np.uint8)
   data_xyz[r <= 1.0] = 1

   # --- write HDF5 --------------------------------------------------------
   # CSXCAD reads /DiscData with x varying fastest (Fortran-like flat index).
   # h5py writes C-order arrays where the LAST axis varies fastest,
   # so transpose to shape (nz, ny, nx) before writing.
   data_c = np.ascontiguousarray(data_xyz.transpose(2, 1, 0))

   fname = 'my_phantom.h5'
   if os.path.exists(fname):
       os.remove(fname)

   with h5py.File(fname, 'w') as f:
       f.attrs['Version'] = np.float64(2.0)

       ds = f.create_dataset('/DiscData', data=data_c, dtype=np.uint8,
                             compression='gzip', compression_opts=9)
       ds.attrs['DB_Size']  = np.int32(2)
       ds.attrs['epsR']     = np.array([1.0, 52.7], dtype=np.float32)
       ds.attrs['kappa']    = np.array([0.0,  0.95], dtype=np.float32)
       ds.attrs['density']  = np.array([0.0, 1046.], dtype=np.float32)
       ds.attrs['Name']     = 'Background,Brain'

       f.create_dataset('/mesh/x', data=mesh_x.astype(np.float32))
       f.create_dataset('/mesh/y', data=mesh_y.astype(np.float32))
       f.create_dataset('/mesh/z', data=mesh_z.astype(np.float32))

The key axis-ordering rule is: ``data_xyz[ix, iy, iz]`` gives the tissue
index at the voxel whose centre is at ``(xc[ix], yc[iy], zc[iz])``.
Transposing to ``(nz, ny, nx)`` before writing ensures the flat HDF5 storage
order matches what the CSXCAD C++ reader expects.


Converting the IT'IS Virtual Family Model
------------------------------------------

The IT'IS *Virtual Family* provides whole-body voxel models with realistic,
frequency-dependent tissue properties. The models are free for academic and
non-commercial use but require registration at https://itis.swiss/virtual-population/.

Once downloaded, ``Convert_VF_DiscMaterial`` (CSXCAD Matlab interface)
converts the raw ``.raw``/``.txt`` files to a CSXCAD-readable HDF5 file
at a specified frequency. The conversion is slow (~6 GB RAM, several minutes)
but needs to run only once; subsequent runs detect the cached output and skip
it automatically.

.. code-block:: octave

   % Convert Ella head/shoulder region at 298 MHz (7 T MRI)
   Convert_VF_DiscMaterial('/data/Ella_26y_V2_1mm', ...
                           '/data/DB_h5_20120711_SEMCADv14.8.h5', ...
                           'Ella_head_298MHz.h5', ...
                           'Frequency', 298e6, ...
                           'Center', 1, ...
                           'Range', {[], [], [-0.85 -0.40]});


Bundled Tutorial Phantoms
--------------------------

The MRI tutorials include pre-generated phantom files in
``resources/phantoms/`` (accessible to both Octave and Python interfaces)
that serve as a fallback when the Virtual Family dataset is not available:

``phantom_head_298MHz.h5``
   3-layer ellipsoidal head phantom (skin / skull / brain) with tissue
   properties at 298 MHz from the IT'IS database. Used by the
   :ref:`7 T Loop Coil <octave_tutorial_mri_loop_coil>` tutorial.
   Domain: ±115 × ±90 × ±115 mm, 2.5 mm voxels (92 × 72 × 92 cells, 24 kB).

``phantom_body_128MHz.h5``
   3-layer cylindrical phantom (skin / bone / soft tissue, radius 100 mm)
   with tissue properties at 128 MHz from the IT'IS database. Used by the
   :ref:`3 T Birdcage <octave_tutorial_mri_lp_birdcage>` tutorial.
   Domain: ±115 × ±115 × ±130 mm, 2.5 mm voxels (92 × 92 × 104 cells, 19 kB).

The source script ``resources/phantoms/create_phantoms.py`` reproduces
both files and documents the tissue properties used.


.. seealso::

   * :ref:`octave_tutorial_mri_loop_coil` — 7 T MRI loop coil SAR simulation
   * :ref:`octave_tutorial_mri_lp_birdcage` — 3 T birdcage coil B1 and SAR
   * :ref:`octave_tutorial_dipole_sar` — dipole SAR with a layered head phantom
   * :func:`AddDiscMaterial`, :func:`CreateDiscMaterial`,
     :func:`Convert_VF_DiscMaterial` — Octave/Matlab API reference
