.. _concept_fparser:

fparser
==========

In openEMS, user-defined symbolic mathematical expressions are used to customize
the simulation for three different purposes.

1. Vary a material's property in space, using a weighting function.

2. Construct a custom excitation signal :math:`e[t]` to simulate a custom
   input waveform.

3. Vary an excitation field's numerical value in space using a weighting function,
   to construct a custom field pattern or polarization. This is needed for hollow
   waveguide, which must be excited appropriately launch the desired propagation
   mode.  Transmission lines such as coaxial cables also work best with a custom
   field pattern to minimize artifacts due an abrupt field input.

These symbolic expressions are accepted as strings, which is evaluated by the
C++ engine using the ``fparser`` library. This, all strings must be legal
``fparser`` expressions with proper variables and syntax.

Variables
----------

- Universal constants

  - ``pi``, ``e``

  - These constants are CSXCAD / openEMS extensions.

- Temporal variables 

  - ``t``: simulation time (seconds).
  - Only for :func:`SetCustomExcite`.
  
- Spatial variables

    - ``x``, ``y``, ``z``: Cartesian coordinates :math:`(x, y, z)`.

       - In Cylindrical coordinates: :math:`[\rho \cos(\alpha), \rho \sin(\alpha), z]`

    - ``rho``, ``a``, ``z``: Cylindrical coordinates :math:`(\rho, \alpha, z)`.

       - In Cartesian coordinates: :math:`[\sqrt{x ^ 2 + y ^ 2}, \mathrm{atan2}(y, x), z]`

    - ``r``: distance to the origin :math:`(0, 0, 0)`.

      - In Cartesian coordinates: :math:`\sqrt{x^2 + y^2 + z^2}`

        (distance to the intersection point of the X, Y, Z axes).

      - In Cylindrical coordinates: :math:`\sqrt{\rho ^ 2 + z ^ 2}`

        (distance to the center of the cylinder's base).

    - ``t``: polar angle :math:`\theta` in Spherical coordinates: :math:`\arcsin(1) - \arctan(\frac{z}{\rho})`

  - Only for :func:`SetMaterialWeight` or :func:`SetExcitationWeight`.

.. tip::

   All spatial variables are always defined in all coordinate systems,
   internally converted if necessary. To avoid confusion, it's recommended
   to use the current simulation's native coordinate system.

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

  - These functions are CSXCAD extensions, for weighting functions
    only.

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
