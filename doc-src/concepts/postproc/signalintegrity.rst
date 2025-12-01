Transient Analysis via ``SignalIntegrity``
""""""""""""""""""""""""""""""""""""""""""""

This tutorial has repeatedly claimed that the frequency response
is all you need: Once the DUT's S-parameters are known, linear
circuit analysis tools can evaluate its behavior under other
input signals, so there's no loss of generality. In fact, performing
a time-domain transient simulation using frequency-domain S-parameters
is a common feature in many proprietary commercial circuit simulators,
such as :program:`HyperLynx`, :program:`ADS`, or :program:`AWR`. A
third-party tool also exists for PSpice. [4]_

However, in the free and open source world, few (if any) free and
open source circuit simulators have this capability. For example,
Ngspice supports S-parameter calculation but not transient
simulation. [5]_ :program:`Qucs`, too, doesn't support transient
simulation with S-parameters, although it's possible to define
devices using them.

The Python package :program:`SignalIntegrity`, designed for signal
integrity and eye diagram simulations from the ground up, is a rare
exception. It's developed by Pete Pupalaikis, a former signal
integrity expert at LeCroy.

.. seealso::
   **Book.** The software's internal theory of operation is also published almost
   in full in the textbook *S-Parameters for Signal Integrity* [6]_. Each
   concept is accomplished by both formulas and executable code, making
   it an invaluable reference in this field. The author of this tutorial
   recommends everyone who simulates or measures RF/microwave devices to
   get a copy.

   **PyBERT.** It's another circuit simulator designed with time-domain
   S-parameter simulation and signal integrity in mind, developed by David
   Banas. See [23]_.

Install
''''''''

To install ``SignalIntegrity``, download the latest ``.zip`` file
at the project's release page using a Web browser::

    https://github.com/Nubis-Communications/SignalIntegrity/releases

As of writing, the latest version was 1.4.1. Once downloaded, unzip
the file and install it locally via :program:`pip`::

    unzip SignalIntegrity-1.4.1.zip
    cd SignalIntegrity-1.4.1

    pip3 install . --user

``SignalIntegrity`` is both a software library and a Tcl/Tk (Tkinter)
GUI application, installed to ``~/.local/bin/`` (or another standard
local path). You should be able to start it via::

    $ SignalIntegrity

If not, you may need to add this local :file:`bin` directory into
your shell's search path.

.. figure:: images/si1.png
   :class: with-border
   :width: 60%

   The classic 1990s Tcl/Tk (Tkinter) GUI may look old-fashioned,
   but it works, and will keep working until the end of time.

Impulse Signal Analysis
'''''''''''''''''''''''''

For the first example, let's examine the circuit's time-domain
response to a short impulse.

**Add an S-parameter defined 2-port network.** Right click on the
empty schematic, choose :guilabel:`Add Part`. In the :guilabel:`Add
Part` diagram, click :menuselection:`Files --> Two Port File`. In
the opened setting window, click
:guilabel:`browse` and select the ``s2p`` S-parameter file created
by our simulation. Click :guilabel:`OK`, and finally click the empty
schematic to place the item. The item can be moved by selecting it
and dragging it.

.. image:: images/transient_sim_1.png
   :width: 30%
.. image:: images/transient_sim_2.png
   :width: 30%
.. image:: images/transient_sim_3.png
   :width: 30%

**Add a voltage pulse generator.** In the :guilabel:`Add Part` dialog,
choose :menuselection:`Generators --> One Port Voltage Pulse Generators`.
In the opened setting window, change the :guilabel:`risetime (s)` property
to "100 ps", and place this item on the schematic.

.. image:: images/transient_sim_4.png
   :width: 30%
.. image:: images/transient_sim_5.png
   :width: 30%
.. image:: images/transient_sim_21.png
   :width: 30%

**Add a series resistor to represent the generator's output impedance.**
In the :guilabel:`Add Part` dialog, choose :menuselection:`Resistors --> Two
Port Resistor`. Place this item on the schematic.

.. image:: images/transient_sim_6.png
   :width: 30%
.. image:: images/transient_sim_7.png
   :width: 30%
.. image:: images/transient_sim_8.png
   :width: 30%

**Add a resistor to ground to represent the input impedance at the end
of the waveguide.** In the :guilabel:`Add Part` dialog, choose
:menuselection:`Resistors --> One Port Resistor to Ground`. Place this
item on the schematic.

.. image:: images/transient_sim_9.png
   :width: 30%
.. image:: images/transient_sim_10.png
   :width: 30%
.. image:: images/transient_sim_11.png
   :width: 30%

**Wire the circuit.**
Right click on the schematic, choose :guilabel:`Add Wire`,
connect the components following this order: pulse generator, series
resistor, DUT Port 1, DUT Port 2, resistor to ground.

.. image:: images/transient_sim_12.png
   :width: 30%

**Add an input probe.** In the :guilabel:`Add Part` window, choose
:menuselection:`Ports and Probes --> Output`. Place this probe on
the wire after the series resistor at the DUT Port 1.

.. image:: images/transient_sim_13.png
   :width: 30%
.. image:: images/transient_sim_14.png
   :width: 30%
.. image:: images/transient_sim_15.png
   :width: 30%

**Add an output probe.** Repeat the above step, add another probe on top
(in parallel) of the resistor to ground, at the DUT Port 2.

.. image:: images/transient_sim_13.png
   :width: 30%
.. image:: images/transient_sim_16.png
   :width: 30%
.. image:: images/transient_sim_17.png
   :width: 30%

**Run simulation.** Click :guilabel:`Calculate` on the menu bar, and choose
:guilabel:`Simulate`. After simulation finishes, it opens a time-domain
line chart. After pressing the "Zoom" (magnifying glass) button and
dragging a rectangle on a part of the waveform of interest, one can finally
see the pulse response of the DUT.

.. image:: images/transient_sim_18.png
   :width: 30%
.. image:: images/transient_sim_19.png
   :width: 30%

**Results.** As expected, the +/- 1 V input signal (+/- 0.5 V with 50 Ω
output and input impedance) has severe overshoots and undershoots due to
port impedance mismatches, while the output shows significant rise
time degradation due to high insertion loss above 2 GHz.

.. image:: images/transient_sim_20.png
   :width: 60%

Eye Diagram Analysis
''''''''''''''''''''''

For the next example, let's examine the circuit's time-domain signal
integrity using a Pseudo-Random Bit Stream (PRBS) generator as the
input, and to plot its output on an eye diagram.

**Delete the voltage pulse generator.** Right-click the voltage
pulse generator we added previously, select :guilabel:`delete`.

.. important::
   Don't select :guilabel:`convert`, it seems buggy and would prevent
   the generation of eye diagram after simulation.

.. image:: images/eye_sim_1.png
   :width: 30%
.. image:: images/eye_sim_2.png
   :width: 30%

**Add a Pseudo-Random Bitstream Generator (PSBG).** In the
:guilabel:`Add Part` dialog, choose
:menuselection:`Generators --> One-Port Voltage PRBS`. Change its
:guilabel:`risetime (s)` to "100 ps". Place this item on the schematic.

.. image:: images/eye_sim_3.png
   :width: 30%
.. image:: images/eye_sim_4.png
   :width: 30%

**Add an eye probe.** In the :guilabel:`Add Part` dialog, choose
:menuselection:`Ports and Probes --> EyeProbe`. Click :guilabel:`Eye
Diagram Configuration`. Set :guilabel:`Measure Eye Parameters` to
``True``, and change the ::guilabel::`Color` to yellow (255, 255, 0)
to improve diagram readability. By default, the eye diagram is
black-and-white. Then close this window.

.. tip::
   Press :kbd:`Enter` to apply changed R, G, or B values. It's
   *not* necessary to click :guilabel:`Save Properties to Global
   Preferences`, by default these options are already applied
   to a single schematic.

.. image:: images/eye_sim_5.png
   :width: 30%
.. image:: images/eye_sim_6.png
   :width: 30%
.. image:: images/eye_sim_7.png
   :width: 30%

**Place the probe and wire the circuit.** Place the eye probe on
the schematic. Wire the eye probe to DUT's Port 2.

.. image:: images/eye_sim_8.png
   :width: 30%
.. image:: images/eye_sim_9.png
   :width: 30%

**Run simulation.** Click :guilabel:`Calculate` on the menu, choose
:guilabel:`Simulate`. After simulation finishes, it opens two plots,
an eye diagram plot and a time-domain line chart.

.. image:: images/transient_sim_18.png
   :width: 30%

**Results.** The eye diagram clearly shows our parallel-plate waveguide
has an extremely poor signal integrity. We will discuss the significance
of this result at the end of this tutorial.

.. image:: images/eye_sim_10.png
   :width: 30%
.. image:: images/eye_sim_11.png
   :width: 30%

**Zoom in.** The time-domain line chart can be zoomed by pressing the
"Magnifying Glass" button and drag a rectangle on a part of the waveform
of interest.  One can see that the overshoots, undershoots and
rise-time degradation is similar to the previous impulse signal
analysis.

