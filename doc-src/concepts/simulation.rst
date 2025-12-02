Simulation
============

Initialization
---------------

.. todo::

   Finish this section.

Running Simulation
--------------------

If everything works as expected, the following screen appears.
For this small simulation, it should finish within a few minutes::

    $ python3 Parallel_Plate_Capacitor_Waveguide.py
     ----------------------------------------------------------------------
     | openEMS 64bit -- version v0.0.36-16-g7d7688a
     | (C) 2010-2023 Thorsten Liebig <thorsten.liebig@gmx.de>  GPL license
     ----------------------------------------------------------------------
    	Used external libraries:
    		CSXCAD -- Version: v0.6.3-4-g9257bf1
    		hdf5   -- Version: 1.12.1
    		          compiled against: HDF5 library version: 1.12.1
    		tinyxml -- compiled against: 2.6.2
    		fparser
    		boost  -- compiled against: 1_76
    		vtk -- Version: 9.1.0
    		       compiled against: 9.1.0

    Create FDTD operator (compressed SSE + multi-threading)
    FDTD simulation size: 70x70x37 --> 181300 FDTD cells
    FDTD timestep is: 5.3429e-12 s; Nyquist rate: 9 timesteps @1.0398e+10 Hz
    Excitation signal length is: 108 timesteps (5.77033e-10s)
    Max. number of timesteps: 1000000000 ( --> 9.25926e+06 * Excitation signal length)
    Create FDTD engine (compressed SSE + multi-threading)
    Running FDTD engine... this may take a while... grab a cup of coffee?!?
    [@        4s] Timestep:         1602 || Speed:   72.5 MC/s (2.499e-03 s/TS) || Energy: ~2.70e-19 (-41.66dB)
    [@        8s] Timestep:         3820 || Speed:  100.5 MC/s (1.805e-03 s/TS) || Energy: ~5.35e-20 (-48.70dB)
    [@       12s] Timestep:         6510 || Speed:  121.9 MC/s (1.488e-03 s/TS) || Energy: ~1.86e-20 (-53.30dB)
    [@       16s] Timestep:         9320 || Speed:  127.3 MC/s (1.424e-03 s/TS) || Energy: ~1.09e-20 (-55.59dB)
    [@       20s] Timestep:        12136 || Speed:  127.6 MC/s (1.421e-03 s/TS) || Energy: ~5.33e-21 (-58.72dB)
    [@       24s] Timestep:        14748 || Speed:  118.4 MC/s (1.532e-03 s/TS) || Energy: ~3.62e-21 (-60.39dB)
    Multithreaded Engine: Best performance found using 5 threads.
    Time for 14748 iterations with 181300.00 cells : 24.01 sec
    Speed: 111.35 MCells/s

If there's a mesh or port alignment alignment problem, openEMS may
generate the following warnings. See the linked sections for their
respective solution.

* :ref:`unused_plate`
* :ref:`unused_excite`
* :ref:`voltage_integral_error`

Convergence and Divergence (Blow-up)
-------------------------------------

The simulation runs until the total energy in the simulation box
decays to nearly zero, reaching 60 dB below the initial energy
injected by the excitation port. When this occurs, the simulation
achieves convergence, meaning the transients in the system have
dissipated, and the system has reached a steady-state. Thus, the
simulation terminates.

Conversely, incorrect or unphysical
modeling or meshing may destabilize the simulation, causing
*blow-ups*. The simulation box's EM field strength diverges over
time due to the accumulation of small numerical errors. The
total energy may gradually increase unbounded, eventually
reaching the floating-point infinity.
If the energy shows signs of rapid increases, the simulation
should be stopped early via :kbd:`Control-C` to avoid wasting time.

Note that the displayed energy value is only a rough, indicative estimate.
Factors such as material properties are ignored for simulation speed.
For resonating structures (such as cavity resonators and antennas),
the energy indicator may fluctuate up and down repeatedly
due to the oscillating EM field strengths. The convergence time
required for low-loss (high Q) resonators which have minimal energy
dissipation, is notoriously long in FDTD simulations. The absence
of termination resistances or Absorbing Boundary Conditions
makes it difficult to dissipate the injected energy.

.. note::

   The energy decay threshold for termination is adjustable
   via :meth:`~openEMS.openEMS.SetEndCriteria`, but 60 dB is a
   good default. For advanced usage,
   :meth:`~openEMS.openEMS.SetNumberOfTimeSteps`
   and
   :meth:`~openEMS.openEMS.SetMaxTime` can limit the total
   number of timesteps (in iterations) or wall-clock time
   (in seconds) to truncate the simulation earlier before
   convergence.

Common Errors
----------------

.. _unused_plate:

Warning: Unused primitive (type: Box) detected in property: plate!
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you see the following warnings in the simulation::

    Create FDTD engine (compressed SSE + multi-threading)
    Warning: Unused primitive (type: Box) detected in property: plate!
    Warning: Unused primitive (type: Box) detected in property: plate!
    Running FDTD engine... this may take a while... grab a cup of coffee?!?
    [@        4s] Timestep:         1666 || Speed:   71.4 MC/s (2.401e-03 s/TS) || Energy: ~6.79e-22 (-68.99dB)
    Time for 1666 iterations with 171500.00 cells : 4.00 sec
    Speed: 71.42 MCells/s

It indicates the metal plates are not actually used in the simulation.

This is likely a meshing problem. All CSXCAD structure must pass at least a
single mesh line, including zero-thickness structures like thin metal plates.
Structures that stay in the middle of two mesh lines can't be simulated.

To fix this problem, add mesh lines at the exact coordinate of zero-thickness
plates::

    # zero-thickness metal plates need mesh lines at their exact levels
    mesh.AddLine('z', [-8, 8])

.. important::
   A zero-thickness plate must cross or align exactly with at least one mesh
   line, otherwise it can't be simulated.

.. _unused_excite:

Warning: Unused primitive (type: Box) detected in property: port_excite_1!
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you see the following warnings in the simulation::

    Create FDTD engine (compressed SSE + multi-threading)
    Warning: Unused primitive (type: Box) detected in property: port_excite_1!
    Running FDTD engine... this may take a while... grab a cup of coffee?!?
    [@        4s] Timestep:         1588 || Speed:   72.0 MC/s (2.519e-03 s/TS) || Energy: ~0.00e+00 (- 0.00dB)
    [@        8s] Timestep:         3882 || Speed:  104.0 MC/s (1.744e-03 s/TS) || Energy: ~0.00e+00 (- 0.00dB)

It indicates the excitation port is not actually used in the simulation, this
is further confirmed by the energy of ``~0.00e+00``: it means the port is disabled
so it didn't inject any energy into the simulation box.

This is likely a meshing problem. All CSXCAD structure must pass at least a
single mesh line, including zero-thickness structures like the ports.
Structures that stay in the middle of two mesh lines can't be simulated.

For example, because we used the 1/3-2/3 rule around the edges of the metal
plates, there's no mesh line at the left and right edge of the metal plates.
Thus the following code won't work::

    port[0] = fdtd.AddLumpedPort(1, z0, [-50, -2.5, -8], [-50, 2.5, 8], 'z', excite=1)
    port[1] = fdtd.AddLumpedPort(2, z0, [ 50, -2.5, -8], [ 50, 2.5, 8], 'z', excite=0)

As a compromise, we can shift the port's location to the nearest mesh lines
along the X axis instead, this may introduce a small error as the port's
measurement plane has shifted. But these issues is negligible for this demo::

    port[0] = fdtd.AddLumpedPort(1, z0, [-50 + 1/3 * res, -2.5, -8], [-50 + 1/3 * res, 2.5, 8], 'z', excite=1)
    port[1] = fdtd.AddLumpedPort(2, z0, [ 50 - 1/3 * res, -2.5, -8], [ 50 - 1/3 * res, 2.5, 8], 'z', excite=0)

.. important::
   A port must cross or align exactly with at least one mesh line, otherwise
   it can't be simulated.

An alternative solution is to create a mesh line aligned with the port,
using the :meth:`CSX.ContinuousStructure.AddLine` function. This violates
the 1/3-2/3 rule, but is acceptable for long and narrow structures like
a transmission line with weak fringe fields on both ends.

.. _voltage_integral_error:

CalcVoltageIntegral: Error, only a 1D/line integration is allowed
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the openEMS output is flooded with the following error message::

    Engine_Interface_FDTD::CalcVoltageIntegral: Error, only a 1D/line integration is allowed
    Engine_Interface_FDTD::CalcVoltageIntegral: Error, only a 1D/line integration is allowed
    Engine_Interface_FDTD::CalcVoltageIntegral: Error, only a 1D/line integration is allowed
    Engine_Interface_FDTD::CalcVoltageIntegral: Error, only a 1D/line integration is allowed
    Engine_Interface_FDTD::CalcVoltageIntegral: Error, only a 1D/line integration is allowed
    Engine_Interface_FDTD::CalcVoltageIntegral: Error, only a 1D/line integration is allowed

It means that openEMS is not able to calculate the voltage at a port
because the port is located at an ill-defined position. This happens
if the start and stop coordinates are different (i.e. not a 1D port),
but the size is smaller than a single mesh cell (i.e. when the port
is built from its start coordinate to its stop coordinate on each axis,
it does not overlap with at least two mesh lines).

For example, the following port is functional because it's strictly
a 1D port, with identical start and stop coordinates::

    port[0] = fdtd.AddLumpedPort(1, z0, [any_x, any_y, -8], [any_x, any_y, -8], 'y', excite=1)
    port[1] = fdtd.AddLumpedPort(2, z0, [any_x, any_y, -8], [any_x, any_y, -8], 'y', excite=0)

The following port is also functional because the 2D port passes
(overlaps with) at least two mesh lines when it's built from Z = -8
to Z = 8::

    port[0] = fdtd.AddLumpedPort(1, z0, [any_x, any_y, -8], [any_x, any_y, 8], 'z', excite=1)
    port[1] = fdtd.AddLumpedPort(2, z0, [any_x, any_y, -8], [any_x, any_y, 8], 'z', excite=0)

The following port is also functional, because although there
is no mesh line at the stop position Z = 8.1, but the 2D port has
already crossed at least one mesh cell (two mesh lines) when it's
built from Z = -8 to its stop coordinate::

    port[0] = fdtd.AddLumpedPort(1, z0, [any_x, any_y, -8], [any_x, any_y, 8.1], 'z', excite=1)
    port[1] = fdtd.AddLumpedPort(2, z0, [any_x, any_y, -8], [any_x, any_y, 8.1], 'z', excite=0)

But the following port is not functional, because the 2D port
does not cross a single mesh cell (two mesh lines) when it's
built from Z = -8 to Z = -7.9. Although there's a mesh line at Z = -8,
there is no mesh line between Z = -8 and Z = -7.9::

    port[0] = fdtd.AddLumpedPort(1, z0, [any_x, any_y, -8], [any_x, any_y, -7.9], 'z', excite=1)
    port[1] = fdtd.AddLumpedPort(2, z0, [any_x, any_y, -8], [any_x, any_y, -7.9], 'z', excite=0)

To fix the problem, either redefine the port with the correct
coordinates, or to add additional mesh lines.

.. important::
   On each axis, a port must either be one-dimensional and aligned to a
   mesh line, or two-dimensional and crosses (or overlaps) with two
   mesh lines (a single mesh cell). Otherwise it can't be simulated.

   Furthermore, a port's excitation direction must be two-dimensional.
   If the port excites the Z direction, it must have a length on the Z axis,
   satisfying the two constraints mentioned.
