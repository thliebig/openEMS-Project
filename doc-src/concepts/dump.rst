.. _concept_fielddump:

Field Dump
==============

In most applications, the input and output signals at the :ref:`concept_ports`
is sufficient for characterizing a structure, such as its frequency response.

However, some special
applications make use of the raw electromagnetic fields, not just the
input and output signals. We can do this by creating a "dump box" (a region
in space where field values are recorded) to save field samples to disk.
For troubleshooting malfunctioning setups, this is especially helpful as one can
identify the problematic region through direct visualization.

Several kinds of dump boxes exist.

#. Time-domain dumps of electric field :math:`\mathbf{E}`, auxiliary magnetic
   field :math:`\mathbf{H}`, electric conduction current :math:`\mathbf{J}`,
   total current density :math:`\mathrm{\nabla} \times \mathbf{H}`, electric
   displacement field :math:`\mathbf{D}`, and magnetic field (flux density)
   :math:`\mathbf{B}`, with their ``dump_type`` numbered from ``0`` to ``5``.
#. Frequency-domain dumps of electric field, auxiliary magnetic field,
   electric conduction current, total current density, electric displacement
   field, and magnetic field (flux density), numbered from ``10`` to ``15``.
#. Specific Absorption Rate (SAR) for biological EM radiation exposure analysis.
#. Near-Field to Far-Field Transformation (NF2FF) for antenna analysis
   (special setup required, via :meth:`openEMS.openEMS.CreateNF2FFBox` and a
   separate post-processing tool).

.. note::
   openEMS calculates the total current density via Ampere-Maxwell's
   law :math:`\mathrm{\nabla} \times \mathbf{H}`, which is
   :math:`\mathbf{J} + \frac{\partial \mathbf{D}}{\partial t}`
   (i.e. the sum of conduction current and displacement current).

Usage
-------

It’s added by the :func:`AddDump` method in Matlab/Octave.
In Python,
use the :meth:`CSXCAD.ContinuousStructure.AddDump` method (see
:class:`~CSXCAD.CSProperties.CSPropDumpBox` for a detailed list of
parameters).

.. important::
   Like all CSXCAD :ref:`concept_properties`, field dumps
   are also "materials" albeit non-physical, so they should be associated
   with one or more :ref:`concept_primitives` (i.e. geometric shapes) as
   well.

Example
-----------

Dump the total current density (``dump_type=3``) on at 2D surface from
(-100, -100) to (100, 100) at Z = 8::

    % Octave
    %TODO

    # Python
    dump = csx.AddDump("curl_H_upper", dump_type=3)
    dump.AddBox(start=[-100, -100, 8], stop=[100, 100, 8])
