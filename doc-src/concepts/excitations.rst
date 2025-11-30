.. _concept_excitations:

Excitation Sources
====================

At the start of a simulation, electric or magnetic fields are introduced
into the simulation box, helping establish initial conditions for the
system.
This is done by setting the numerical values of the field at
specified Yee cells.
Usually, the excitation source is created indirectly using high-level
:ref:`concept_ports`. However, sometimes a satisfactory port is
unavailable for the simulated structure, making it necessary to create
custom excitation sources using low-level functions.
This allows one to introduce an excitation with a specific location,
field type, distribution, and weighting function.

Custom excitation is also needed for calculating a structure's Radar
Cross Section (RCS), which requires simulating a free-space plane wave
in a special mode called *Total-Field Scattered-Field* (TFSF).

Standard Excitation
--------------------

A standard excitation source is created by assigning it to a
box primitive, which defines it position and size. Both E-field
and H-field excitations are supported.

The excitation can either be *hard* or *soft*.
A hard excitation forces the field at the source points to exactly take
the field values of the source, ignoring any other incoming wave e.g.
from reflections. For soft sources the field values at source points are
the superposition of the defined source and other travelling waves.

Matlab/Octave
"""""""""""""

:func:`AddExcitation` function definition::

    CSX = AddExcitation(CSX, name, type, excite, varargin)

* ``CSX``: CSX-struct created by InitCSX
* ``name``: Property name for the excitation.
* ``type``:

  * ``0``: E-field soft excitation.
  * ``1``: E-field hard excitation.
  * ``2``: H-field soft excitation.
  * ``3``: H-field hard excitation.
  * ``10``: Plane wave excitation.
* ``excite``: Excitation vector, e.g. ``[2 0 0]`` for excitation of
  2 V/m in ``x`` direction.
* ``varargin``: Additional options:

  * ``Delay``: Setup an excitation time delay in seconds.
  * ``PropDir``: Direction of plane wave propagation (plane wave excitation only).

Python
"""""""

:func:`~CSXCAD.ContinuousStructure.AddExcitation` function definition::

    excitation = AddExcitation(name, exc_type, exc_val, **kw)

* ``excitation``: An instance of :class:`~CSXCAD.CSProperties.CSPropExcitation`.
* ``name``: Property name for the excitation.
* ``type``:

  * ``0``: E-field soft excitation.
  * ``1``: E-field hard excitation.
  * ``2``: H-field soft excitation.
  * ``3``: H-field hard excitation.
  * ``10``: Plane wave excitation.
* ``exc_val``: Excitation vector, e.g. ``[2, 0, 0]`` for excitation of
  2 V/m in ``x`` direction.
* ``**kw``: Additional options, currently unimplemented.

The created :class:`~CSXCAD.CSProperties.CSPropExcitation` instance
has the following useful methods (not exhaustive):

* ``SetDelay(val)``: Set signal delay for this property.
* ``SetPropagationDir(val)``: Set the propagation direction (plane wave
  excitation only).

Example
"""""""""

Add a 400 MHz sinusoidal line excitation (short dipole)::

    % Octave
    f0 = 400e6;

    FDTD = SetSinusExcite(FDTD, f0)
    CSX = AddExcitation(CSX, 'infDipole', 1, [1 0 0]);
    start = [-dipole_length/2, 0, 0];
    stop  = [+dipole_length/2, 0, 0];
    CSX = AddBox(CSX, 'infDipole', 1, start, stop);

    # Python
    TBD.

Total Field / Scattered Field Excitation
-------------------------------------------

To create a plane wave excitation in the sense of a Total Field / Scattered
Field (TFSF) approach, the :func:`AddPlaneWaveExcite()` function is used.
This type of source becomes useful if the scattered field of an object is
of interest, such as in Radar Cross Section (RCS) simulations.

The field from the excitation is confined to the box defined for the source,
the scattered field will propagate beyond the box. A plane wave excitation
must not intersect with any kind of material. This excitation type can only
be applies in air/vacuum and completely surrounding a structure. The plane
wave source has to be assigned to a box primitive which defines the position
and extend of the field.

As an example, see the *Metal Sphere Radar Cross Section* example
in the *Tutorial* section.

Matlab/Octave
"""""""""""""""

:func:`AddPlaneWaveExcite` function definition::

    CSX = AddPlaneWaveExcite(CSX, name, k_dir, E_dir, <f0, varargin>)

* ``CSX``: CSX struct created by ``InitCSX``.
* ``name``: Property name for the excitation.
* ``k_dir``: Unit vector of wave progation direction.
* ``E_dir``: Electric field polarization vector (must be orthogonal to ``k_dir``).
* ``f0``: Frequency for numerical phase velocity compensation (optional).

Python
""""""""

The same :func:`~CSXCAD.ContinuousStructure.AddExcitation` is used for plane wave
excitations. Its function definitions are repetedly here for cross-referencing::

    excitation = AddExcitation(name, exc_type, exc_val, **kw)

* ``excitation``: An instance of :class:`~CSXCAD.CSProperties.CSPropExcitation`.
* ``name``: Property name for the excitation.
* ``type``:

  * ``10``: Plane wave excitation.
* ``exc_val``: Electric field polarization vector (must be orthogonal to ``k_dir``).
* ``**kw``: Additional options, currently unimplemented.

The created :class:`~CSXCAD.CSProperties.CSPropExcitation` instance
has the following useful methods (not exhaustive):

* ``SetPropagationDir(k_dir)``: Unit vector of wave progation direction.
* ``SetFrequency(f0)``: Frequency for numerical phase velocity compensation
  (optional).

Example
"""""""""

Add a Gaussian pulse as a TFSF source::

    FDTD = SetGaussExcite(FDTD, 0.5 * (f_start + f_stop), 0.5 * (f_stop - f_start));
    inc_angle = 0 / 180 * pi; %incident angle on the x-axis
    k_dir = [cos(inc_angle) sin(inc_angle) 0]; % plane wave direction
    E_dir = [0 0 1]; % plane wave polarization --> E_z
    f0 = 500e6;      % frequency for numerical phase velocity compensation

    CSX = AddPlaneWaveExcite(CSX, 'plane_wave', k_dir, E_dir, f0);

    % source is in the box defined by start and stop
    start = [-100 -100 -100];
    stop = [100 100 100];
    CSX = AddBox(CSX, 'plane_wave', 0, start, stop); 

    # Python
    TBD.
