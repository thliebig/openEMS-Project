.. _concept_fielddump:

Field Dump
==============

In most applications, the input and output signals at the :ref:`concept_ports`
are sufficient for characterizing a structure, such as its frequency response.

However, some special
applications make use of the raw electromagnetic fields, not just the
input and output signals. We can do this by creating a "dump box" (a region
in space where field values are recorded) to save field samples to disk.
For troubleshooting malfunctioning setups, this is especially helpful as one can
identify the problematic region through direct visualization.

Several kinds of dump boxes exist.

#. Time-domain dumps of electric field :math:`\mathbf{E}`, magnetic field
   :math:`\mathbf{H}`, electric conduction current :math:`\mathbf{J}`,
   total current density :math:`\mathrm{\nabla} \times \mathbf{H}`, electric
   displacement field :math:`\mathbf{D}`, and magnetic flux density
   :math:`\mathbf{B}`, with their ``dump_type`` numbered from ``0`` to ``5``.

   .. warning::
      Time-domain dumps generate one output file per timestep, which can
      result in very large amounts of data and noticeably slow down the
      simulation. Use them sparingly, and prefer frequency-domain dumps
      when only the steady-state response is needed.

#. Frequency-domain dumps of electric field, magnetic field,
   electric conduction current, total current density, electric displacement
   field, and magnetic flux density, numbered from ``10`` to ``15``.

   .. note::
      Frequency-domain dumps require at least one simulation frequency to
      be specified — they produce no output otherwise.

#. Specific Absorption Rate (SAR) for biological EM radiation exposure
   analysis, numbered ``20`` to ``22``, plus ``29`` for the raw data needed to
   compute SAR in post-processing instead of during the simulation
   (see :ref:`concept_sar`).

.. note::
   openEMS calculates the total current density via Ampere-Maxwell's
   law :math:`\mathrm{\nabla} \times \mathbf{H}`, which is
   :math:`\mathbf{J} + \frac{\partial \mathbf{D}}{\partial t}`
   (i.e. the sum of conduction current and displacement current).

The Near-Field to Far-Field Transformation (NF2FF) is **not** a dump type of
its own. ``CreateNF2FFBox`` in Octave/Matlab, or
:meth:`openEMS.openEMS.CreateNF2FFBox` in Python, sets up six ordinary E- and
H-field dumps on the faces of a box enclosing the antenna — ``dump_type``
``0``/``1`` for time-domain, or ``10``/``11`` if a frequency is given, always
in HDF5 format. The far field is computed from those recordings afterwards, by
a separate post-processing step. See :ref:`concept_nf2ff`.

Usage
-------

It’s added by the :func:`AddDump` method in Matlab/Octave.
In Python,
use the :meth:`CSXCAD.ContinuousStructure.AddDump` method (see
:class:`~CSXCAD.CSProperties.CSPropDumpBox` for a detailed list of
parameters).

The key parameters are:

* **DumpType** / ``dump_type``: selects the field quantity and domain
  (time-domain ``0``–``5``, frequency-domain ``10``–``15``, SAR ``20``–``22``).
* **FileType** / ``file_type``: output file format — ``0`` for VTK (default),
  ``1`` for HDF5. Both formats are supported for time-domain and
  frequency-domain dumps.
* **DumpMode** / ``dump_mode``: interpolation mode — ``0`` no interpolation,
  ``1`` node interpolation (default), ``2`` cell interpolation.
* **Frequency** / ``frequency``: list of frequencies required for frequency-domain
  dump types (``10``–``22``); no output is produced if omitted.

.. important::
   Like all CSXCAD :ref:`concept_properties`, field dumps
   are also "materials" albeit non-physical, so they should be associated
   with one or more :ref:`concept_primitives` (i.e. geometric shapes) as
   well.

Examples
-----------

All coordinates below are in the drawing unit set for the mesh, not in
metres.

Time-domain field animation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Record the E-field over the whole simulation domain in HDF5 format. Sampling
every second line in each direction keeps the output to an eighth of the full
size — a full-domain time-domain dump is by far the most expensive kind:

.. tabs::

   .. code-tab:: octave

      csx = AddDump(csx, 'Et', 'FileType', 1, 'SubSampling', '2,2,2');

      start = [mesh.x(1)   mesh.y(1)   mesh.z(1)];
      stop  = [mesh.x(end) mesh.y(end) mesh.z(end)];
      csx = AddBox(csx, 'Et', 0, start, stop);

   .. code-tab:: python

      et = csx.AddDump('Et', file_type=1, sub_sampling=[2, 2, 2])

      start = [mesh.GetLine('x', 0),  mesh.GetLine('y', 0),  mesh.GetLine('z', 0)]
      stop  = [mesh.GetLine('x', -1), mesh.GetLine('y', -1), mesh.GetLine('z', -1)]
      et.AddBox(start, stop)

Frequency-domain dump on a plane
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Record the steady-state H-field at 2.4 GHz on the plane ``z = 8``. Because the
dump box is flat in z, only that one plane is recorded. Unlike the time-domain
dump above, the cost does not grow with the number of timesteps — one dataset
per frequency is accumulated as the simulation runs:

.. tabs::

   .. code-tab:: octave

      csx = AddDump(csx, 'Hf', 'DumpType', 11, 'FileType', 1, ...
                    'Frequency', [2.4e9]);
      csx = AddBox(csx, 'Hf', 0, [-100 -100 8], [100 100 8]);

   .. code-tab:: python

      hf = csx.AddDump('Hf', dump_type=11, file_type=1, frequency=[2.4e9])
      hf.AddBox([-100, -100, 8], [100, 100, 8])

Note that ``dump_type=11`` is the frequency-domain counterpart of the
time-domain ``dump_type=1``; the frequency-domain types are simply the
time-domain ones plus ten.

Surface current density
~~~~~~~~~~~~~~~~~~~~~~~~~

Record the total current density :math:`\mathrm{\nabla} \times \mathbf{H}`
(``dump_type=3``) on the same plane. On a metal surface this visualizes the
current distribution, which is a useful diagnostic for antenna and patch
designs:

.. tabs::

   .. code-tab:: octave

      csx = AddDump(csx, 'Jt_patch', 'DumpType', 3, 'FileType', 1);
      csx = AddBox(csx, 'Jt_patch', 0, [-100 -100 8], [100 100 8]);

   .. code-tab:: python

      jt = csx.AddDump('Jt_patch', dump_type=3, file_type=1)
      jt.AddBox([-100, -100, 8], [100, 100, 8])

.. note::
   The Octave ``SubSampling`` and ``OptResolution`` arguments take a string
   such as ``'2,2,2'``, while their Python counterparts take a list of three
   numbers, ``[2, 2, 2]``.

Reading the results
~~~~~~~~~~~~~~~~~~~~~

VTK dumps (``file_type=0``) open directly in :program:`ParaView`. HDF5 dumps
(``file_type=1``) are read with :class:`openEMS.utilities.HDF5Dump` in Python
or ``ReadHDF5Dump`` in Octave/Matlab; see :ref:`concept_dump_hdf5`.

.. seealso::

   :ref:`concept_dump_hdf5` — HDF5 file format reference for all dump types

   :ref:`concept_sar` — SAR post-processing from raw dumps (``dump_type=29``)

   :ref:`concept_nf2ff` — near-field to far-field transformation
