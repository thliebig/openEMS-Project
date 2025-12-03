.. _concept_excitations:

Excitation Sources
====================

At the start of a simulation, electric or magnetic fields are introduced
into the simulation box, applying an initial energy and signal input to
the system. This is done by setting the numerical values of the field at
specified Yee cells. Some excitations only last one timestep, while most
excitations are gradually applied over many timesteps.

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
from reflections. For soft sources, the field values at source points are
the superposition of the defined source and other fields or traveling
waves.

.. tabs::

   .. tab:: Octave

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

   .. tab:: Python

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
~~~~~~~~

Add a 400 MHz sinusoidal line excitation (short dipole):

.. tabs::

   .. code-tab:: octave

      csx = InitCSX();
      fdtd = InitFDTD();

      f0 = 400e6;
      dipole_length = 10;

      csx = AddExcitation(
          csx, ...
          'infDipole', ...
          1, ...            % E-field
          [1 0 0] ...       % excitation vector
      );
      start = [-dipole_length/2 0 0];
      stop  = [+dipole_length/2 0 0];
      csx = AddBox(csx, 'infDipole', 1, start, stop);

      % Don't forget to assign a signal waveform to the simulation (not CSXCAD).
      fdtd = SetSinusExcite(fdtd, f0)

   .. code-tab:: python

      import CSXCAD
      import openEMS

      csx = CSXCAD.ContinuousStructure()
      fdtd = openEMS.openEMS()

      f0 = 400e6
      dipole_length = 10

      inf_dipole = csx.AddExcitation(
          'excite',
          0,         # E-field
          [1, 0, 0]  # excitation vector
      )

      start = [-dipole_length / 2, 0, 0]
      stop  = [+dipole_length / 2, 0, 0]
      inf_dipole.AddBox(start, stop)

      # Don't forget to assign a signal waveform to the simulation (not CSXCAD).
      fdtd.SetSinusExcite(f0)


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

.. tabs::

   .. tab:: Octave

      :func:`AddPlaneWaveExcite` function definition::

          CSX = AddPlaneWaveExcite(CSX, name, k_dir, E_dir, <f0, varargin>)

      * ``CSX``: CSX struct created by ``InitCSX``.
      * ``name``: Property name for the excitation.
      * ``k_dir``: Unit vector of wave progation direction.
      * ``E_dir``: Electric field polarization vector (must be orthogonal to ``k_dir``).
      * ``f0``: Frequency for numerical phase velocity compensation (optional).

   .. tab:: Python

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
~~~~~~~~

Add a Gaussian pulse as a TFSF source:

.. tabs::

   .. code-tab:: octave

      fdtd = SetGaussExcite(fdtd, 0.5 * (f_start + f_stop), 0.5 * (f_stop - f_start));
      inc_angle = 0 / 180 * pi; %incident angle on the x-axis
      k_dir = [cos(inc_angle) sin(inc_angle) 0]; % plane wave direction
      E_dir = [0 0 1]; % plane wave polarization --> E_z
      f0 = 500e6;      % frequency for numerical phase velocity compensation

      csx = AddPlaneWaveExcite(csx, 'plane_wave', k_dir, E_dir, f0);

      % source is in the box defined by start and stop
      start = [-100 -100 -100];
      stop = [100 100 100];
      csx = AddBox(csx, 'plane_wave', 0, start, stop);

   .. code-tab:: python

      # Python
      TBD.

Weighting Function
--------------------

An excitation can be a function of position (spatial coordinates)
by modulating its numerical field value by a weighting function via
:func:`SetExcitationWeight` (Octave) or
:meth:`~CSXCAD.CSProperties.CSPropExcitation.SetWeightFunction` (Python).

This feature is needed for hollow waveguides, which must be excited
appropriately to launch the desired propagation mode. Transmission
lines such as coaxial cables also work best with a custom field pattern
to minimize artifacts due an abrupt field input.

The electric and magnetic fields are vector fields. At each point in
space, they contain three values, representing their polarization along
three coordinate axes. Thus weighting functions are always passed as
arrays with three elements. Unwanted polarization can be masked by a
excitation function of ``'0'``.

.. note::
   * Each weighting function is a string, which contains the expression parsed
     by the ``fparser`` library, so the string should be a legal ``fparser``
     expression with proper syntax.

   * See :ref:`concept_fparser` for weighting function syntax.

Example
~~~~~~~~~~

- Excite a coaxial transmission line excitation in Cylindrical
  coordinates ``(r, a, z)``.

  .. tabs::

     .. code-tab:: octave

        coax_inner_od = 3;
        coax_outer_id = 5;

        csx = AddExcitation( ...
            csx, ...
            'excite', ...
            0, ...         % E-Field
            [1 0 0] ...    % excitation vector
        );
        csx = SetExcitationWeight(csx, 'excite', ['1 / rho' '0' '0']);

        % radial field
        start = [coax_inner_od     0   0];
        stop  = [coax_outer_id  2*pi   0];

        % Create a 2D disc to excite the region between the inner
        % and outer conductor.
        %
        % By default this region is a vacuum, you may want to fill
        % this region with your own materials too.
        csx = AddBox(csx, 'excite', 0, start, stop);

     .. code-tab:: python

        coax_inner_od = 3
        coax_outer_id = 5

        # add E-field excitation at port center
        excitation = csx.AddExcitation(
            'excite',
            0,         # E-field
            [1, 0, 0]  # excitation vector
        )
        # radial field
        excitation.SetWeightFunction(['1 / rho', '0', '0'])

        # Create a 2D disc to excite the region between the inner
        # and outer conductor.
        #
        # By default this region is a vacuum, you may want to fill
        # this region with your own materials too.
        start = [coax_inner_od, 0,         0]
        stop  = [coax_outer_id, 2 * np.pi, 0]
        excitation.AddBox(start, stop)

- Excite a coaxial transmission line excitation in Cartesian
  coordinates ``(x, y, z)``, for a wave traveling along the ``z``
  axis.

  .. tabs::

     .. code-tab:: octave

        coax_inner_od = 3;
        coax_outer_id = 5;

        % r_o, r_i are placeholders
        func_x = 'x / (x * x + y * y) * (sqrt(x * x + y * y) < r_o) * (sqrt(x * x + y * y) > r_i)';
        func_y = 'y / (x * x + y * y) * (sqrt(x * x + y * y) < r_o) * (sqrt(x * x + y * y) > r_i)';

        % substitute variable names in weighting function strings
        func_x = strrep(func_x, 'r_i', num2str(coax_inner_od));
        func_y = strrep(func_y, 'r_o', num2str(coax_outer_id));

        % Construct excitation vector [1 1 0] shown here for clarity,
        % not necessary, [1 1 1] is also acceptable since the unused
        % polarization is masked by the zero weighting function
        % [func_x func_y '0'] anyway
        csx = AddExcitation(csx, "excite", 0, [1 1 0]);
        csx = SetExcitationWeight(csx, "excite", [func_x func_y '0']);

        % Create a 2D disc to excite the region between the inner
        % and outer conductor.
        %
        % By default this region is a vacuum, you may want to fill
        % this region with your own materials too.
        start = [0 0 0]
        stop  = [0 0 0]
        csx = AddCylindricalShell(
            csx, "excite", ...
            0, ...
            ex_start, ...
            ex_stop, ...
            (coax_inner_od + coax_outer_id) * 0.5, ...
            (coax_outer_id - coax_inner_od) ...
        );

- Excite a coaxial transmission line excitation in Cartesian
  coordinates ``(x, y, z)``, for a wave traveling along any axis.

  .. tabs::

     .. code-tab:: octave

        % x, y, r_o, r_i are placeholders
        func_x = 'x / (x * x + y * y) * (sqrt(x * x + y * y) < r_o) * (sqrt(x * x + y * y) > r_i)';
        func_y = 'y / (x * x + y * y) * (sqrt(x * x + y * y) < r_o) * (sqrt(x * x + y * y) > r_i)';

        % In a coax, the electric field's polarization is zero along the
        % axis of propagation, and only exists along two axes orthogonal
        % to the propagation direction.
        %
        % Depending on the actual field, the weighting function can be
        %
        %   * (  0, f_y, f_z)
        %   * (f_x,   0, f_y)
        %   * (f_x, f_y,   0)
        %
        % So our first problem is to rewrite the "x", "y" in the strings
        % to the actual two axes orthogonal to the propagation direction

        % change dir to {0, 1, 2} for propagating along the {x, y, z} axis
        dir = 0;

        % determine two direction indexes orthogonal to propagation direction
        dir_ortho1 = mod(dir + 1, 3)
        dir_ortho2 = mod(dir + 2, 3)

        % determine the variable names orthogonal to propagation direction
        dir_names = {'x', 'y', 'z'};

        % Matlab/Octave uses 1-based index
        dir_str = dir_names{dir + 1};
        dir_ortho1_str = dir_names{dir_ortho1 + 1};
        dir_ortho2_str = dir_names{dir_ortho2 + 2};

        % substitute variable names in weighting function strings
        func_x = strrep(func_x, 'x', dir_ortho1_str)
        func_x = strrep(func_x, 'y', dir_ortho1_str)
        func_y = strrep(func_y, 'x', dir_ortho2_str)
        func_y = strrep(func_y, 'y', dir_ortho2_str)

        % construct weighting function arrays
        func_E{dir + 1} = '0';
        func_E{dir_ortho1 + 1} = func_x;
        func_E{dir_ortho2 + 1} = func_y;

        % construct excitation vector
        %
        % shown here for clarity, it's not necessary, the unused polarization
        % is masked by the zero weighting function anyway
        excv = [1 1 1]
        excv{dir + 1} = 0

        csx = AddExcitation(csx, "excite", 0, excv);
        csx = SetExcitationWeight(csx, "excite", func_E);

        % Create a 2D disc to excite the region between the inner
        % and outer conductor.
        %
        % By default this region is a vacuum, you may want to fill
        % this region with your own materials too.
        start = [0 0 0]
        stop  = [0 0 0]
        csx = AddCylindricalShell(
            csx, "excite", ...
            0, ...
            ex_start, ...
            ex_stop, ...
            (coax_inner_od + coax_outer_id) * 0.5, ...
            (coax_outer_id - coax_inner_od) ...
        );

  .. tip::

     This is why choosing the correct coordinate system is important
     in electromagnetic problems!
