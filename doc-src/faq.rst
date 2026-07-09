.. _faq:

Frequently Asked Questions
==========================

Structure Setup
---------------

.. rubric:: How do I create a "hole" in a structure?

Use the priority system: assign a higher priority to the material that
should "win" inside the overlapping region. See :ref:`concept_primitives`
for details on how priorities are resolved.

.. rubric:: openEMS warns about an unused property or primitive. What does it mean?

The property or primitive was present in the structure but had no effect
on the simulation. Common causes:

- **Mesh error** — a 2D metal plane has no mesh line at its z-level, so
  no Yee cells are assigned to it.
- **Priority shadowing** — another primitive with a higher priority
  completely overlaps this one.
- **Empty property** — a material property was defined but no primitive
  was assigned to it.

.. rubric:: My 2D metal structure (zero-thickness box) is reported as unused. Why?

This is the most common instance of the unused-primitive warning. It
applies to **PEC** (``AddMetal``) and **conducting sheet**
(``AddConductingSheet``) properties only — they are the only material
types that can be represented as infinitely thin 2D sheets in the FDTD
mesh.

A 2D primitive — an ``AddBox`` where start and stop are identical in one
axis — requires **exactly one mesh line** at that coordinate. Without a
mesh line passing through the plane, no Yee cells are assigned to it and
openEMS reports it as unused.

Add a mesh line at the sheet's coordinate in the relevant axis:

.. tabs::

   .. code-tab:: octave

      mesh.z = [mesh.z 0];   % for a sheet at z = 0

   .. code-tab:: python

      mesh.AddLine('z', 0)   # for a sheet at z = 0

For any other material type (including copper modelled as a finite
conductivity material), a zero-thickness box has no physical volume and
cannot be used. The primitive must be **3D**, with start and stop
separated far enough in all three axes that at least one Yee cell is
fully enclosed.

.. rubric:: How do I model PCB vias?

Use ``AddCylinder`` with a PEC material, connecting the z-coordinates of
the two copper layers:

.. tabs::

   .. code-tab:: octave

      CSX = AddMetal(CSX, 'via');
      CSX = AddCylinder(CSX, 'via', priority, [x y z_bottom], [x y z_top], via_radius);

   .. code-tab:: python

      via = CSX.AddMetal('via')
      via.AddCylinder([x, y, z_bottom], [x, y, z_top], radius=via_radius)

Set ``radius`` to the via drill radius. Add mesh lines at the via
centre and at the cylinder surface to ensure the via is resolved by the
mesh.

Simulation
----------

.. rubric:: My timestep is very small and the simulation is slow. Why?

The FDTD timestep is set by the smallest cell in the mesh. A very small
timestep almost always means there is at least one very small cell.
Check the mesh for unintended narrow gaps or excessively fine lines. If
the small cells are required to resolve a structural feature, you may
need to accept the longer runtime or consider whether FDTD is the right
method for the problem.

.. rubric:: Why does the stored energy go up and down during the simulation?

While the excitation is active, energy is continuously fed into the
domain, so the stored energy rises and falls depending on how fast it
leaves through absorbing boundaries or is dissipated. After the
excitation ends the energy should decay monotonically. Note that the
energy display is a fast approximation that ignores material properties,
so small transient increases after the excitation ends are possible and
not a sign of instability.

.. rubric:: The simulation reports "Active cells: 0". What is wrong?

This means the mesh is degenerate — either no mesh lines were added at
all, or fewer than two lines exist in at least one axis, so there are no
intervals between lines and hence no Yee cells to simulate.

Check that mesh lines have been defined in all three axes before calling
``WriteOpenEMS`` / ``RunOpenEMS``. Visualising the structure with
AppCSXCAD beforehand is a quick sanity check.

Note that a unit mismatch or a structure placed outside the mesh
boundary does **not** produce this error — those cases still result in
a valid (all-air) mesh and the simulation runs, but the structure has no
effect on the fields.

.. rubric:: The energy end criterion is never reached. What should I do?

High-Q structures — narrow-band antennas, resonant cavities, filters
with steep roll-off — store energy for a long time and may need many
more timesteps than the default to reach the end criterion. Options:

- Increase ``NrTS`` (number of timesteps) in ``InitFDTD``.
- Relax ``EndCriteria`` (e.g. from ``1e-5`` to ``1e-4``).
- Check that absorbing boundaries (PML or Mur) are correctly placed and
  not too close to the structure, as this can cause reflections that
  prevent the energy from decaying.

A less obvious cause is using an **unmodulated Gaussian pulse** (centre
frequency ``f0 = 0``). Such a pulse has a strong DC component that
excites a static charge in the structure. In a lossless simulation this
charge has nowhere to dissipate — the stored energy never reaches zero
regardless of how many timesteps are run. The fix is to use a modulated Gaussian pulse with ``f0 > 0``.

Small oscillations in the energy after the excitation ends are normal
(see above); a steady plateau or slow rise usually points to a boundary
condition problem or the DC issue described above.

.. rubric:: Can I use a sinusoidal excitation for frequency-domain analysis?

Yes. ``SetSinusExcite`` drives the structure at a single continuous-wave
frequency. Once the transient has died out and the fields have reached
steady state, frequency-domain field dumps give accurate amplitude and
phase information at that frequency.

In practice, a **Gaussian pulse** combined with DFT field dumps is
usually more efficient: one simulation covers a wide frequency range and
the DFT is evaluated at any number of frequencies during the run. The
sinusoidal excitation is most useful when you only need one frequency
and want to visualise the instantaneous field distribution.

.. tabs::

   .. code-tab:: octave

      % Gaussian pulse — broadband
      FDTD = SetGaussExcite(FDTD, f0, fc);

      % Sinusoidal — single frequency
      FDTD = SetSinusExcite(FDTD, f0);

   .. code-tab:: python

      # Gaussian pulse — broadband
      fdtd.SetGaussExcite(f0, fc)

      # Sinusoidal — single frequency
      fdtd.SetSinusExcite(f0)

.. rubric:: How do I abort a running simulation without losing results?

Create an empty file named ``ABORT`` (all capitals, no extension) inside
the simulation folder. openEMS checks for this file at regular intervals
and will stop cleanly — flushing all field dumps and post-processing
output — at the next check. Do not kill the process directly, as that
will lose buffered output.

When running via the **Python interface**, pressing :kbd:`Ctrl+C` once
sends a clean stop signal equivalent to the ``ABORT`` file — the
simulation finishes the current interval and exits gracefully. Pressing
:kbd:`Ctrl+C` a second time kills the process immediately.
