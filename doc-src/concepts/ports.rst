.. _concept_ports:

Ports
===========

At the start of a simulation, electric or magnetic fields are introduced
into the simulation box, applying an initial energy and signal input to
the system. Some excitations only last one timestep, while most excitations
are gradually applied over many timesteps. For the purpose of circuit designs,
voltages and currents are also calculated to measure time-domain waveforms.

Internally, it's implemented using *excitation sources* to set numerical values
of the field at specified Yee cells. *Weighting functions* are used to further
control the field's pattern and polarization. Voltage and current are measured
by *probes*, which integrate the electric and magnetic fields along 1D lines and
2D surfaces. Finally, *lumped resistances* often needed to present specific
impedances at locations where voltages are measured.

Controlling these low-level entities for every simulation is inconvenient for
the purpose of circuit designs. Hence, openEMS implements a high-level concept
called ports, which creates appropriate entities automatically for common port
types.  This allowing users to treat ports as the virtual 3D counterpart of
physical ports on RF/microwave components, such as the standard 50 Ω input or
output ports on circuit boards, signal generators, oscilloscopes, and especially
Vector Network Analyzers (VNA).

.. note::
   Ports are the most-commonly used form of excitations,
   this page presents a port-based view. For a description of
   non-port excitations (including Radar Cross Section), see
   :ref:`concept_excitations`.

.. figure:: images/vna_ports.svg
   :class: with-border
   :width: 49%

   The "port" in openEMS serves a purpose similar to the physical
   ports on Vector Network Analyzers and circuit boards. Both kinds of
   ports are used to inject an input signal at a particular point in the
   Device-Under-Test (DUT), and to measure what comes out at another point.
   The DUT is thus characterized as a black box, solely represented using
   its input-output relationships without an internal structure.
   Note that port implementations are fundamentally different in
   physical instruments (via circuits) and in openEMS simulations
   (by loading numerical values into Yee cells). Image by Julien Hillairet,
   from the ``scikit-rf`` project, licensed under BSD-3, modified for clarity.


Types
-------

One can classify ports into two types, lumped ports and distributed ports.

API Reference
~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1

   * - Port Type
     - Matlab/Octave
     - Python

   * - Lumped
     - :func:`AddLumpedPort()`
     - :meth:`~openEMS.openEMS.AddLumpedPort`

   * - Curved
     - :func:`AddCurvePort()`
     -

   * - Microstrip
     - :func:`AddMSLPort()`
     - :meth:`~openEMS.ports.MSLPort`

   * - Stripline
     - :func:`AddStripLinePort()`
     -

   * - Coplanar Waveguide
     - :func:`AddCPWPort()`
     -

   * - Coaxial
     - :func:`AddCoaxialPort()`
     -

   * - Generic Waveguide
     - :func:`AddWaveGuidePort()`
     - :meth:`~openEMS.ports.WaveguidePort`

   * - Rectangular Waveguide
     - :func:`AddRectWaveGuidePort()`
     - :meth:`~openEMS.ports.RectWGPort`

   * - Circular Waveguide
     - :func:`AddCircWaveGuidePort()`
     -

.. note::
   Some port types are not *ported* to Python yet.

Lumped Ports
~~~~~~~~~~~~

A lumped port is the simplest and basic port type.
It can be understood as a source that injects electromagnetic energy
into the simulation at a defined position, providing an initial stimulus for
the system.  Simultaneously, a lumped resistor and a probe are also created
at the same location as the port, allowing it to provide a matched load
for the signal, and to measure the voltage or current at this region.

Lumped ports play a role similar to signal generators in circuit
simulators. Both kinds of sources act like a voltage source or load
with a resistive impedance, which are used to inject a signal to the
Device-Under-Test or measure the DUT's response, either from its own signal
or from another port.

.. figure:: images/lumped-port.svg
   :class: with-border

   An ideal lumped port is connected vertically across a horizontal
   circuit. Its internal voltage source acting as both a wire and a
   source of electric field. A lumped excitation port in openEMS
   works similarly here.

Limitation of the Lumped Port
""""""""""""""""""""""""""""""

A lumped port uses a constant-value electric field as the excitation signal,
its physical size must be much smaller than the simulated structured to ensure
the validity of the lumped-circuit approximation. If a significant distance
exists between the end-points of a lumped port, simulation artifacts may
occur.

A lumped port is a small 2D surface or 3D cube filled by an electric field,
it can only be used to excite a two-conductor TEM transmission line, it cannot
be used to excite hollow waveguides, and will perform poorly if the transmission
lines requires an excitation field with a specific shape, polarization or
contains multiple conductors, such as striplines, coplanar waveguides,
differential pairs, or coaxial cables.

To avoid signal reflections, the lumped port must also have a lumped resistance
matched to the characteristic impedance of the transmission line, this is
problematic of the characteristic impedance of the transmission line is unknown.

.. todo::

   Finish this section.

Transmission Line Ports
~~~~~~~~~~~~~~~~~~~~~~~~

Transmission line ports have several functions.

* Create the transimission line.
* Automatically inserts several voltage and current probes.
* Apply appropriate weighting functions.
* Extract characteristic impedance.

But it doesn't support:

* Lumped resistance, need to use boundary.

.. todo::

   Finish this section.

Feature Reference
-------------------

.. list-table::
   :header-rows: 1

   * - Port Type
     - Field Profile
     - How many?
     - Impedance Extraction

   * - Lumped
     - Constant
     - 1
     - No

   * - Curved
     - Constant
     - 1
     - No

   * - Microstrip
     - Constant
     - 1
     - Yes

   * - Stripline
     - Constant
     - 2
     - Yes

   * - Coplanar Waveguide
     - Constant
     - 2
     - Yes

   * - Coaxial
     - Radial
     - 1
     - Yes

   * - Generic Waveguide
     - Manual Weighting Function
     - 1
     - No - Formula Only

   * - Rectangular Waveguide
     - TE/TM Mode
     - 1
     - No - Formula Only

   * - Circular Waveguide
     - TE/TM Mode
     - 1
     - No - Formula Only



Usage
------

The following example adds two lumped ports to the simulation.

.. tabs::

   .. code-tab:: octave

      z0 = 50;

      start = [-100 0 0];
      stop  = [-100 0 50];
      [CSX port{1}] = AddLumpedPort(CSX, 5, 1, z0, start, stop, [0 0 1], true);

      start = [100 0 0];
      stop  = [100 0 50];
      [CSX port{2}] = AddLumpedPort(CSX, 5, 2, z0, start, stop, [0 0 1], false);

   .. code-tab:: python

      z0 = 50

      port = [None, None]

      start = [-100 0 0]
      stop  = [-100 0 50]
      port[0] = fdtd.AddLumpedPort(1, z0, start, stop, 'z', excite=1)

      start = [-100 0 0]
      stop  = [-100 0 50]
      port[1] = fdtd.AddLumpedPort(2, z0, start, stop, 'z', excite=0)

.. seealso::
   This page is incomplete. See the
   `Legacy Wiki <https://wiki.openems.de/index.php/Ports.html>`_ for more information.

Selection
-----------

In openEMS, ports are ideal sources of EM fields, but they are not ideal
*launchers* of EM waves into structures due to a discontinuity at the
boundary between the port and the structure.
If port placement is not optimized,
this region of discontinuity may introduce artifacts such
as reflections or excitation of spurious modes. Optimizing the placement
and implementation of a port reduces these artifacts. This can be done
by using smooth transitions or by shaping the electric fields initially
injected by the port.

In openEMS, the standard port is the lumped port that works with most
structures. If an optimal transition is needed, openEMS also provides
optimized implementations of curved, microstrip, stripline, coplanar
waveguide, and coax cable ports.

Most specialized ports in openEMS are signal integrity optimizations
rather than strict requirements. However, in enclosed waveguides,
specialized ports are *required* to excite those structures properly.
These waveguides only have one conductor, unlike the usual two-conductor
transmission lines. An ordinary port can't excite them correctly,
as the waveguide is essentially a DC short circuit. Special waveguide
ports must be used to excite the unique TE-mode waves. These include
general waveguide ports, rectangular waveguides ports, and circular
waveguides ports

.. note::
   Like physical ports on real devices, the virtual ports in openEMS are not
   perfect. They're ideal sources of EM fields, but they are not ideal
   *launchers* of EM waves into structures. A port creates a region of
   discontinuity, so they may introduce artifacts.
   Optimizing the placement and implementation of a port reduces artifacts.
   Alternatively, these artifacts
   can be removed through calibration or de-embedding algorithms, an
   advanced topic beyond the scope of this tutorial.

   .. figure:: images/error-box.svg
      :class: with-border
      :width: 60%

      The artifacts introduced by a two-port measurement can be viewed
      as two linear circuits (left error box, right error box) cascaded in
      series with the DUT. All three circuits are represented as three matrices,
      called their S-parameters. Measurement error can be reduced by making
      error boxes nearly transparent using optimized port transitions.
      Alternatively, by mathematically removing the port's contributions from
      the measured response using linear algebra, a process known as
      calibration or de-embedding (image by Ziad Hatab et, al., licensed
      under CC BY-SA 4.0 [1]_)

Implementation
----------------

Ports are a high-level concept in openEMS. Internally, they're
implemented by first calling :meth:`~CSXCAD.ContinuousStructure.AddExcitation`
to create a source of EM field. Later, :meth:`~CSXCAD.ContinuousStructure.AddLumpedElement`
and :meth:`~CSXCAD.ContinuousStructure.AddProbe` are used to add termination
resistances and probes. One can create new port types based on these
low-level primitives.

Post-Processing
-----------------

After the simulation is complete, a circuit's frequency response or
time-domain waveform is extracted to obtain meaningful results.

Attributes
""""""""""

+-------------------------+--------------------------+-----------------+--------------------------------------------------+
|      Matlab / Octave    |    Python                |    Domain       |  Definition                                      |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
|   ``ZL_ref``            | ``Z_ref``                | Impedance       | Reference Impedance                              |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| ``uf_inc{n}``           | ``uf_inc[n]``            | Frequency       | Incident Voltage                                 |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| ``uf_ref{n}``           | ``uf_ref[n]``            | Frequency       | Reflected Voltage                                |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| ``if_tot{n}``           | ``if_tot[n]``            | Frequency       | Total Voltage                                    |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| ``if_inc{n}``           | ``if_inc[n]``            | Frequency       | Incident Current                                 |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| ``if_ref{n}``           | ``if_ref[n]``            | Frequency       | Reflected Current                                |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| ``if_tot{n}``           | ``if_tot[n]``            | Frequency       | Total Current                                    |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| ``P_inc{n}``            | ``P_inc[n]``             | Frequency       | Incident Power                                   |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| ``P_ref{n}``            | ``P_ref[n]``             | Frequency       | Reflected Power                                  |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| ``P_acc{n}``            | ``P_acc[n]``             | Frequency       | Accepted Power (Incident - Reflected)            |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| N/A (see notes)         | ``ut_inc[n]``            | Time            | Incident Voltage                                 |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| N/A (see notes)         | ``ut_ref[n]``            | Time            | Reflected Voltage                                |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| ``ut_tot{n}``           | ``ut_tot[n]``            | Time            | Total Voltage                                    |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| N/A (see notes)         | ``it_inc[n]``            | Time            | Incident Current                                 |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| N/A (see notes)         | ``it_ref[n]``            | Time            | Reflected Current                                |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| ``it_tot{n}``           | ``it_tot[n]``            | Time            | Total Current                                    |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| ``raw.U.TD{1}.val{n}``  | ``u_data.ui_val[0][n]``  | Time            | Raw Voltage (``ut_tot`` Recommended)             |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| ``raw.U.TD{1}.t{n}``    | ``u_data.ui_time[0][n]`` | Time            | Raw Time of Voltage Samples                      |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| ``raw.I.TD{1}.val{n}``  | ``i_data.ui_val[0][n]``  | Time            | Raw Current (``it_tot`` Recommended)             |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+
| ``raw.I.TD{1}.t{n}``    | ``i_data.ui_time[0][n]`` | Time            | Raw Time of Current Samples                      |
+-------------------------+--------------------------+-----------------+--------------------------------------------------+

.. note::

  **Voltage symbol**. ``u`` is the unambiguous symbol of voltage (:math:`U`) in ISO/IEC
  convention,
  so frequency-domain variables have the prefix ``uf``, time-domain variables have the
  prefix ``ut``. In American literature, symbols such as :math:`V`, :math:`E` and
  :math:`\mathcal{E}` are used.

  **Incident and reflected signals.** In Matlab/Octave, only total time-domain port
  voltage and current are given, while their incident, reflected components are not.
  They can be calculated using the following expressions::

      ut_inc = 0.5 * (ut_tot + it_tot * ZL_ref)
      ut_ref = ut_tot - ut_inc

      it_inc = 0.5 * (it_tot + ut_tot ./ ZL_ref)
      it_ref = it_inc - it_tot

Usage
""""""""

Matlab/Octave::

    f_min = 100e6
    f_max = 1e9
    points = 1000
    freq_list = linspace(f_min, f_max, points);

    for i = 1:numel(port)
        port{i} = calcPort(port{i}, simpath, freq_list);
    endfor

    s11_list = port{1}.uf.ref ./ port{1}.uf.inc;
    s21_list = port{2}.uf.ref ./ port{1}.uf.inc;
    z21_list = port{1}.uf.tot ./ port{1}.if_tot;

Python::

    import numpy as np
    from matplotlib import pyplot as plt

    f_min = 100e6
    f_max = 1e9
    points = 1000
    z0 = 50
    freq_list = np.linspace(f_min, f_max, points)

    # after running the simulation
    for p in port:
        p.CalcPort(simdir, freq_list, ref_impedance=z0)

    s11_list = port[0].uf_ref / port[0].uf_inc
    s21_list = port[1].uf_ref / port[0].uf_inc
    z11_list = port[0].uf_tot / port[0].if_tot

    plt.figure()
    plt.plot(port[0].u_data.ui_time[0], port[0].ut_tot, label="Input Voltage")
    plt.plot(port[1].u_data.ui_time[0], port[1].ut_tot, label="Output Voltage")
    plt.grid()
    plt.legend()
    plt.xlabel('Time (s)')
    plt.ylabel('Voltage (V)')
    plt.show()

