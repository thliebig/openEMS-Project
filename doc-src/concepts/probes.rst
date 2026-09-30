.. _concept_probes:

Probes
======

A *probe* records a single scalar or vector quantity over the course of the
simulation and writes it to a text file. Where a :ref:`field dump
<concept_fielddump>` saves the fields over a whole region, a probe integrates
them over one line or one face and gives one number per timestep — a voltage, a
current, or the field at a point.

Probes are what :ref:`concept_ports` are built from: every port creates its own
voltage and current probes, places them correctly on the staggered grid, and
turns their output into S-parameters. Adding probes by hand is needed when no
port fits the structure, when a quantity has to be measured somewhere other
than at a port, or to check what a port is actually seeing.

Probe Types
-----------

.. list-table::
   :header-rows: 1
   :widths: 8 26 66

   * - Type
     - Quantity
     - Geometry
   * - ``0``
     - Voltage
     - Line integral of **E** along the primitive, from ``start`` to ``stop``.
   * - ``1``
     - Current
     - Integral of **H** around the boundary of a 2D primitive, i.e. the
       current through that face.
   * - ``2``
     - E-field
     - All three components at a single point; no integration.
   * - ``3``
     - H-field
     - All three components at a single point; no integration.
   * - ``10``
     - Waveguide voltage
     - Mode matching: **E** on a 2D primitive weighted by a mode profile.
   * - ``11``
     - Waveguide current
     - Mode matching: **H** on a 2D primitive weighted by a mode profile.

Like every other :ref:`property <concept_properties>`, a probe does nothing
until a primitive is assigned to it, and the primitive's dimensionality has to
match the type: a line for a voltage probe, a plane for a current or
mode-matching probe, a point for a field probe.

Placement on the Staggered Grid
-------------------------------

Voltage and current probes do not live on the same grid. Voltage follows the
electric field and is evaluated on the primary mesh lines; current follows the
magnetic field and is evaluated on the dual mesh, half a cell away. A current
probe placed at a mesh line is therefore snapped to the nearest dual line, and
a voltage and a current probe given identical coordinates measure at positions
half a cell apart — and half a timestep apart in time. See :ref:`concept_mesh`
for what that means for accuracy and how to interpolate around it.

A current probe needs to know which way is "through" the face. If the
primitive is genuinely two-dimensional this is unambiguous, but otherwise
``NormDir`` (``norm_dir`` in Python) has to name the axis.

Usage
-----

A voltage probe along z and a current probe on the plane it passes through:

.. tabs::

   .. code-tab:: octave

      csx = AddProbe(csx, 'ut1', 0);
      csx = AddBox(csx, 'ut1', 0, [0 0 0], [0 0 10]);

      csx = AddProbe(csx, 'it1', 1, 'NormDir', 2);
      csx = AddBox(csx, 'it1', 0, [-5 -5 5], [5 5 5]);

   .. code-tab:: python

      ut1 = csx.AddProbe('ut1', 0)
      ut1.AddBox([0, 0, 0], [0, 0, 10])

      it1 = csx.AddProbe('it1', 1, norm_dir=2)
      it1.AddBox([-5, -5, 5], [5, 5, 5])

The optional parameters are the same in both interfaces (key/value pairs in
Matlab/Octave, keywords in Python):

``weight``
   Scale factor applied to the recorded value. Ports use it to account for
   symmetry or for a probe that spans only part of the structure.
``frequency``
   List of frequencies. The probe then also accumulates a discrete Fourier
   transform during the run and writes it to a second file, instead of
   requiring an FFT in post-processing.
``NormDir`` / ``norm_dir``
   Normal axis of a current probe whose primitive is not flat.
``ModeFunction`` / ``mode_function``
   Mode profile for types ``10`` and ``11``, as three
   :ref:`fparser <concept_fparser>` expressions. ``ModeFile`` reads the
   profile from an HDF5 mode file instead, and ``ModeOrigin`` shifts the
   origin the profile is evaluated against.
``StartTime`` / ``StopTime``
   Window (in seconds) outside which the probe stays inactive.
``OverSampling`` / ``over_sampling``
   Record more often than the global sampling rate, see
   :ref:`signal_concept`.

Mode Matching
-------------

A hollow waveguide has no unique voltage or current, so probe types ``10`` and
``11`` project the field onto a known mode profile instead: the recorded
"voltage" is the amplitude of that mode. Alongside it, these probes write a
second column, ``mode_purity``, giving the fraction of the energy on the face
that actually belongs to the requested mode — a direct check on whether the
waveguide is carrying the mode intended, or whether a discontinuity has
excited others. The waveguide ports use exactly this mechanism.

Output Files
------------

Each probe writes one file in the simulation directory, named after the
property — ``AddProbe(csx, 'ut1', 0)`` produces a file called ``ut1``. If
``frequency`` was given, a second file ``ut1_FD`` holds the frequency-domain
result. Both are plain text with ``%``-prefixed header lines recording the
openEMS version and the snapped start and stop coordinates, followed by
tab-separated columns:

.. code-block:: none

   % time-domain voltage probe by openEMS v0.37.0 @Sat Sep 26 18:22:41 2026
   % start-coordinates: (0,0,0) m -> [21,21,11]
   % stop-coordinates: (0,0,0.01) m -> [21,21,21]
   % t/s	voltage
   5.34292e-12	-1.71069e-07
   1.06858e-11	-4.02843e-07

The first column is time in seconds (frequency in Hz for a ``_FD`` file); the
remaining columns are named in the last header line — ``voltage``, ``current``,
the three field components, or ``voltage``/``mode_purity`` for a mode-matching
probe. Frequency-domain files carry two columns per quantity, real and
imaginary.

Reading the Results
-------------------

.. tabs::

   .. code-tab:: octave

      U = ReadUI('ut1', Sim_Path);
      I = ReadUI('it1', Sim_Path, freq_list);

      plot(U.TD{1}.t, U.TD{1}.val);

   .. code-tab:: python

      from openEMS.ports import UI_data

      U = UI_data('ut1', Sim_Path, freq_list)

      plt.plot(U.ui_time[0], U.ui_val[0])

Both helpers read the time-domain file and derive the frequency-domain values
from it — they do not read the ``_FD`` file, which is there for post-processing
that wants the solver's own accumulated DFT instead. ``ReadUI`` can also fit an
auto-regressive model to the time series (``'AR', 'auto'``) to get usable
frequency-domain values from a simulation that was truncated before the signal
had fully decayed.

.. seealso::

   :ref:`concept_ports` — the high-level wrapper that places probes for you

   :ref:`concept_fielddump` — recording fields over a region instead of a
   single integral

   :ref:`concept_mesh` — the staggered grid, and why voltage and current are
   never sampled at quite the same place
