.. _concept_simulation:

Simulation
============

Initialization
---------------

Before running the simulation, the FDTD solver object must be initialized.
In Python this means creating an ``openEMS`` instance; in Octave/Matlab the
equivalent is ``InitFDTD``. Key parameters set at this stage include the
end criterion (the energy decay level at which the simulation is considered
converged) and optionally a maximum number of time steps. See
:meth:`~openEMS.openEMS.SetEndCriteria` and
:meth:`~openEMS.openEMS.SetNumberOfTimeSteps`.

After creating the solver object, the excitation waveform is set (see
:ref:`signal_concept`) and the boundary conditions are applied (see
:ref:`concept_bc`). Finally the geometry description (the CSXCAD
``ContinuousStructure``) is linked to the solver before calling
``Run`` / ``RunOpenEMS``.

Running Simulation
--------------------

If everything works as expected, the following screen appears::

    $ python3 simulation.py
     ----------------------------------------------------------------------
     | openEMS 64bit -- version v0.37.0
     | (C) 2010-2026 Thorsten Liebig <thorsten.liebig@gmx.de>  GPL license
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

If there's a mesh or port alignment problem, openEMS may
generate the following warnings. See the linked sections for their
respective solution.

* :ref:`unused_plate`
* :ref:`unused_excite`
* :ref:`voltage_integral_error`

Solver Options
----------------

The solver takes a number of options, whether it is started as a program or
through the scripting interface. In Matlab/Octave they are passed as a string
to ``RunOpenEMS``, in Python as keyword arguments to
:meth:`~openEMS.openEMS.Run` with the dashes replaced by underscores
(``--debug-material`` becomes ``debug_material=True``). ``openEMS --help``
lists what the installed version supports.

.. list-table::
   :header-rows: 1
   :widths: 34 66

   * - Option
     - Effect
   * - ``--numThreads <n>``
     - Number of threads; 0 (default) uses all cores.
   * - ``--engine <name>``
     - ``fastest`` (default), ``basic``, ``sse``, ``sse-compressed`` or
       ``multithreaded``. Mainly for benchmarking and verification.
   * - ``--verbose`` (``-v``, ``-vv``, ``-vvv``)
     - Debug level 1 to 3.
   * - ``--no-simulation``
     - Preprocess only. Together with the debug dumps below, this checks a
       setup without running it.
   * - ``--disable-dumps``
     - Ignore all field dump boxes, for a faster run.
   * - ``--dump-statistics``
     - Write ``openEMS_run_stats.txt`` and ``openEMS_stats.txt``.
   * - ``--debug-material``, ``--debug-PEC``
     - Write the material and metal distribution *as discretized* to VTK
       files — the most direct way to see what the mesh actually made of the
       model.
   * - ``--debug-boxes``, ``--debug-operator``, ``--debug-CSX``
     - Write probe/dump boxes, the operator, and the parsed geometry to file.
   * - ``--showProbeDiscretization``
     - Report where each probe ended up after snapping to the grid.
   * - ``--legacyHDF5Dumps``
     - Write HDF5 dumps with reversed axis order, see
       :ref:`concept_dump_hdf5`.

The Python interface adds two arguments of its own to
:meth:`~openEMS.openEMS.Run`: ``setup_only``, which stops after the setup, and
``cleanup``, which deletes openEMS output files from the simulation directory
before starting, so results from an earlier run cannot be mistaken for new
ones.

.. tabs::

   .. code-tab:: octave

      RunOpenEMS(Sim_Path, 'simulation.xml', '--numThreads=4 --debug-PEC');

   .. code-tab:: python

      fdtd.Run(Sim_Path, cleanup=True, numThreads=4, debug_PEC=True)

Convergence and Divergence (Blow-up)
-------------------------------------

The simulation runs until the total energy in the simulation domain
decays to nearly zero, reaching e.g. 60 dB below the initial energy
injected by the excitation port. When this occurs, the simulation
achieves convergence, meaning the transients in the system have
dissipated, and the system has reached a steady-state. Thus, the
simulation terminates.

The opposite outcome is a *blow-up*: the field strength diverges instead of
decaying, the energy climbs without bound and eventually reaches floating-point
infinity. If the energy starts rising quickly, stop the run with
:kbd:`Control-C` rather than waiting for it.

A blow-up is not caused by a poorly built model. The FDTD update itself is
inherently stable as long as the timestep respects the CFL/Rennings2 limit,
and openEMS derives that limit per cell from the local mesh *and* material
properties — so a coarse mesh, a badly shaped structure or an unusual
permittivity make the result inaccurate, not unstable. There are two real
sources:

* **The PML.** It is an artificial absorbing material rather than part of the
  stability criterion, and fringe fields or evanescent waves reaching into it
  can destabilize it. This is by far the common case, and it applies to
  unintentional radiators — a stray open trace, an unterminated port — as
  much as to antennas. See the :ref:`PML boundary <concept_bc_pml>`.
* **A manually forced timestep.** :meth:`~openEMS.openEMS.SetTimeStep`
  overrides the calculated value and can set one above the stability limit;
  it exists for engine verification and should otherwise be left alone. To
  tune a marginally stable simulation use
  :meth:`~openEMS.openEMS.SetTimeStepFactor`, which only ever reduces it.

.. seealso::
   :ref:`concept_numerical_method` for why the update is stable, and the
   :ref:`FAQ <faq>` for what to check when a simulation does diverge.

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
   good default. A run can also be cut short before it converges:
   :meth:`~openEMS.openEMS.SetNumberOfTimeSteps` caps the number of
   iterations, and :meth:`~openEMS.openEMS.SetMaxTime` caps the
   *simulated* time — the physical time the wave is propagated for,
   in seconds, which openEMS turns into a timestep count by dividing
   by the timestep. It is not a wall-clock limit. Typical RF values
   are in the nanosecond range, and since the simulated duration sets
   the frequency resolution of the result, a run of duration
   :math:`T` resolves :math:`\Delta f = 1/T`.

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

This is likely a meshing problem. All CSXCAD structures must pass at least a
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
so it didn't inject any energy into the simulation domain.

This is likely a meshing problem. All CSXCAD structures must pass at least a
single mesh line, including zero-thickness structures like the ports.
Structures that stay in the middle of two mesh lines can't be simulated.

.. important::
   A port must cross or align exactly with at least one mesh line, otherwise
   it can't be simulated.

.. _voltage_integral_error:

CalcVoltageIntegral: Error, only a 1D/line integration is allowed
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the openEMS output is flooded with the following error message::

    Engine_Interface_FDTD::CalcVoltageIntegral: Error, only a 1D/line integration is allowed
    Engine_Interface_FDTD::CalcVoltageIntegral: Error, only a 1D/line integration is allowed

openEMS cannot calculate the voltage at a port, because the port sits at an
ill-defined position: its start and stop coordinates differ, so it is not a 1D
port, but it is smaller than one mesh cell, so it is not a 2D port either.

With a mesh line at ``z = -8`` and the next one somewhere beyond ``z = 8``:

.. list-table::
   :header-rows: 1
   :widths: 30 14 56

   * - ``start`` → ``stop`` in z
     - Works?
     - Why
   * - ``-8`` → ``-8``
     - yes
     - A 1D port, exactly on a mesh line.
   * - ``-8`` → ``8``
     - yes
     - A 2D port spanning two mesh lines, i.e. one full cell.
   * - ``-8`` → ``8.1``
     - yes
     - Still spans a full cell; the stop coordinate need not be on a line.
   * - ``-8`` → ``-7.9``
     - **no**
     - Neither 1D nor a full cell: there is no mesh line between the two.

To fix it, either give the port coordinates that satisfy one of the working
cases, or add the mesh lines it needs.

.. important::
   On each axis, a port must either be one-dimensional and aligned to a
   mesh line, or two-dimensional and crosses (or overlaps) with two
   mesh lines (a single mesh cell). Otherwise it can't be simulated.

   Furthermore, a port's excitation direction must be two-dimensional.
   If the port excites the Z direction, it must have a length on the Z axis,
   satisfying the two constraints mentioned.
