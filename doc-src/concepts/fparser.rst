.. _concept_fparser:

Symbolic Expression Parser: ``fparser``
=======================================

In openEMS, user-defined symbolic mathematical expressions are used to
customize the simulation. These symbolic expressions are accepted as
strings, which is evaluated by the C++ engine using the ``fparser``
library. Thus, all strings for the purposes above must be legal
``fparser`` expressions.

These custom expressions are used for three purposes.

1. Vary a material's property in space, using a weighting function.

2. Construct a custom excitation signal :math:`e[t]` to simulate a custom
   input waveform.

3. Vary an excitation field's numerical value in space using a weighting function,
   to construct a custom field pattern or polarization. This is needed for hollow
   waveguide, which must be excited appropriately launch the desired propagation
   mode.  Transmission lines such as coaxial cables also work best with a custom
   field pattern to minimize artifacts due an abrupt field input.

``fparser`` expressions are written in an independent mini-programming language
(a *Domain-Specific Language*), and its syntax differs from the outer C++,
Matlab/Octave, or Python interface. It's necessary to have a quick review of
its syntax.

Variables
----------

- Universal constants

  - ``pi``, ``e``

  - These constants are CSXCAD / openEMS extensions.

- Temporal variables (:func:`SetCustomExcite` only)

  - ``t``: simulation time (seconds).

- Spatial variables (:func:`SetMaterialWeight`, :func:`SetExcitationWeight` only)

  - ``x``, ``y``, ``z``: Cartesian coordinates :math:`(x, y, z)`.

  - ``rho``, ``a``, ``z``: Cylindrical coordinates :math:`(\rho, \alpha, z)`.

  - ``r``, ``t``, ``a``: Spherical coordinates: :math:`(r, \theta, \alpha)`

Temporal variables can only be used in temporal expressions with
:func:`SetCustomExcite`, spatial variables can only be used in
spatial expressions with :func:`SetMaterialWeight`,
:func:`SetExcitationWeight`. Spatial variables cannot used in
temporal variables, temporal variables cannot be used in spatial
variables.

.. warning::

   The meaning of ``t`` is context-dependent, it's time in temporal
   expressions, and a coordinate in spatial expressions.

Coordinate Conversions
---------------------------

All spatial variables are always defined in all coordinate systems by internal
conversion in the software, regardless of the coordinate system of the mesh.
It's acceptable to use Cylindrical coordinates in Cartesian simulations,
and vice versa.

For reference, the exact software conversion rules from the native mesh
coordinates inputs to ``fparser`` output variables are given in the following
table. All formulas are identical to the actual code.
Note that Spherical coordinates are never used as inputs, as the simulator does
not support spherical mesh coordinates. They're defined for convenience in
Cartesian and Cylindrical simulations only.

+-------------+----------------------------------------+-----------------------------------------------------------+----------------------------------------+
|  Output     |               Definition               |                Cartesian                                  |        Cylindrical                     |
+=============+========================================+===========================================================+========================================+
|  ``x``      |  X-axis Distance to Origin             | :math:`x`                                                 | :math:`\rho \cos(\alpha)`              |
+-------------+----------------------------------------+-----------------------------------------------------------+----------------------------------------+
|  ``y``      |  Y-axis Distance to Origin             | :math:`y`                                                 | :math:`\rho \sin(\alpha)`              |
+-------------+----------------------------------------+-----------------------------------------------------------+----------------------------------------+
| ``rho``     |       Distance to Z-axis               | :math:`\sqrt{x ^ 2 + y ^ 2}`                              | :math:`\rho`                           |
|             |                                        |                                                           |                                        |
|             |       (Radius)                         |                                                           |                                        |
+-------------+----------------------------------------+-----------------------------------------------------------+----------------------------------------+
|  ``a``      |   Azimuthal Angle                      | :math:`\mathrm{atan2}(y, x)`                              | :math:`\alpha`                         |
+-------------+----------------------------------------+-----------------------------------------------------------+----------------------------------------+
|  ``z``      |  Z-axis Distance to Origin             | :math:`z`                                                 | :math:`z`                              |
|             |                                        |                                                           |                                        |
|             |  (Cylinder Cross-Section Height)       |                                                           |                                        |
+-------------+----------------------------------------+-----------------------------------------------------------+----------------------------------------+
|  ``r``      |      Distance to Origin                | :math:`\sqrt{x^2 + y^2 + z^2}`                            | :math:`\sqrt{\rho^2+z^2}`              |
+-------------+----------------------------------------+-----------------------------------------------------------+----------------------------------------+
|  ``t``      |      Polar Angle                       | :math:`\pi / 2 - \arctan(z / \sqrt{x ^ 2 + y ^ 2})`       | :math:`\pi / 2 - \arctan(z / \rho)`    |
+-------------+----------------------------------------+-----------------------------------------------------------+----------------------------------------+

.. hint::

   It's useful to start from a 2D plane: ``(x, y)`` or ``(rho, a)``
   describe a point's location in 2D Cartesian or 2D polar coordinates.
   Adding the third coordinate ``z`` determines its height, thus
   forming the 3D Cartesian or 3D Cylindrical coordinate system.

.. warning::

   * Although all spatial variables are always defined in all coordinate
     systems, they're not interchangeable because of vector component
     (field polarization) differences.
     In a Cartesian simulation, the weighting functions ``[E_1, E_2, E_3]``
     apply to :math:`E_x`, :math:`E_y`, :math:`E_z`. But in a Cylindrical
     simulation, they're applied to :math:`E_\rho`, :math:`E_\alpha`,
     :math:`E_z`. Changing the simulation mesh's coordinate system requires
     changing all weighting functions.

   * The azimuthal angle is always safe to use, :math:`\mathrm{atan2}(y, x)`
     is defined everywhere.

   * The polar angle ``t`` is singular (``t = NaN``) at the origin ``(0, 0, 0)``, but
     it's otherwise safe to use if :math:`x = y = 0` because
     :math:`\arctan(z / 0) = \arctan(\pm \infty) = \pm \pi` in IEEE-754.

Syntax
--------

fparser supports a complete set of built-in functions, including
trigonometry functions, conditional functions, and Boolean expressions.
This makes functions expressive, if tricky.

.. seealso::

   See the ``fparser`` project documentation [1]_ for full syntax. The
   following list is only a quick and incomplete reference. ``fparser``
   has advanced features such as defining variables.

Math Functions
~~~~~~~~~~~~~~~~~

- Trigonometry

  - ``acos(x)``, ``acosh(x)``, ``asin(x)``, ``asinh(x)``, ``atan(x)``,
    ``atan2(y, x)``, ``atanh(x)``, ``cos(x)``, ``cosh(x)``, ``cot(x)``,
    ``csc(x)``, ``sec(x)``, ``sin(x)``, ``sinh(x)``, ``tan(x)``,
    ``tanh(x)``.

- Floating Point

  - ``int(x)``, ``ceil(x)``, ``floor(x)``, ``trunc(x)``, ``hypot(x, y)``.

- Complex Number

  - ``arg(z)``, ``conj(z)``, ``real(z)``, ``imag(z)``, ``abs(z)``,
    ``polar(mag, phase)``.

- Arithmetic

  - ``abs(x)``, ``sqrt(x)``, ``cbrt(x)``, ``exp(x)``, ``exp2(x)``,
    ``pow(x, y)``, ``log(x)``, ``log2(x)``, ``log10(x)``, ``max(x, y)``,
    ``min(x, y)``.

- Bessel functions of the first and second kinds

  - ``j0(x)``, ``j1(x)``, ``jn(n, x)``

  - ``y0(x)``, ``y1(x)``, ``yn(n, x)``

  - These functions are CSXCAD extensions for spatial expressions
    only. It's currently unimplemented for temporal expressions.

Other Syntax
~~~~~~~~~~~~~

- Boolean expressions, evaluates to ``0`` or ``1``

  - ``(x = y)``,
    ``(x < y)``,
    ``(x <= y)``,
    ``(x != y)``,
    ``(x > y)``,
    ``(x >= y)``

- Conditonal Function

  - ``if(cond, value_if_true, value_if_false)``

.. note::
   All non-zero values are treated as ``True``.

Examples
----------------

- Set a radial field pattern to excite a coaxial cable (in Cylindrical
  coordinates only)::

      '1 / rho'

- Create a weighting function that alternates between 1 and 2,
  depending on a sinusoid's "signal level", using the spatial
  coordinate ``z`` as the independent variable, using a Boolean
  expression::

      '(sin(4 * z / 1000 * 2 * pi) > 0) + 1'

- The same task, using the ``if`` function for better readability::

      'if(sin(4 * z / 1000 * 2 * pi) > 0, 2, 1)'

- Set a radial field pattern to excite a coaxial cable (in Cartesian
  coordinates only)::

      'x / (x * x + y * y) * (sqrt(x * x + y * y) < r_o) * (sqrt(x * x + y * y) > r_i)'

  .. tip::

     * Replace ``r_o``, ``r_i`` with the actual numerical coordinates.
       Depending on the propagation direction, ``x`` and ``y`` can be
       ``y`` and ``z``

     * For readability, you can construct a string dynamically in
       Octave/Python using string substitution from a common template.

     * This is one of the most complex ``fparser`` expressions commonly
       used, showing the advantage of the cylindrical coordinate system
       for symmetrical problems.

Bibliography
--------------

.. [1] fparser, `fparser project documentation
   <http://warp.povusers.org/FunctionParser/fparser.html#literals>`_.
