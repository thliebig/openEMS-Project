.. _concept_properties:

Properties
============

*Properties* defines the material or simulation properties of geometrical
shapes (known as *primitives*). A *property* can be a metal, a thin
conducting sheet, a dielectric metarial, a magnetic material, or a lumped
element (resistor, capacitor, inductor).

Non-physical simulation entities such as excitation sources, probes, and
field dump boxes are also *properties*, they're used to enable a specific
function at a location or a shape. Hence, one can consider simulation
entities to be geometrical objects made of special materials.

Relationship to Primitives
---------------------------

A *property* is always used to derive one or more geometrical shapes,
known as *primitives*. Together, they form physical and non-physical
objects in the CSXCAD model.
In principle, any *properties* can derive any *primitives*. For example,
an excitation source is added to the model by creating a property
via :func:`AddExcitation`, and deriving a Box primitive from it via
:func:`AddBox`.

.. important::

   To create a meaningful object, remember to always derive at least one
   :ref:`concept_primitives` (such as a Box) from any property.

Metal
------

A metal is a modeled as a Perfect Electric Conductor (PEC) with infinite
conductivity.

Internally, the PEC is implemented by forcing the tangential
electric field in this region to be zero, which is characteristic of an
ideal conductor that can’t be penetrated by electric field lines.
If resistive losses are unimportant, one can use PEC rather than a realistic
material model for simplicity and efficiency.

Example
"""""""

It's added by the :func:`AddMetal` method in Matlab/Octave, or by the
:meth:`~CSXCAD.ContinuousStructure.AddMetal` method in Python.

Create a Perfect Electric Conductor named ``plate``::

    % Matlab/Octave
    csx = InitCSX();
    csx = AddMetal(csx, 'plate');
    % derive primitives via AddBox(), AddCylinder(), etc.

    # Python
    import CSXCAD
    csx = CSXCAD.ContinuousStructure()
    metal = csx.AddMetal('plate')
    # derive primitives via metal.AddBox(), metal.AddCylinder(), etc.

Thin Conducting Sheet
-----------------------

A Thin Conducting Sheet is a simplified model of a resistive conductor,
and is the standard choice for modeling resistive metal sheets, plates,
and traces.

Modeling thin metal sheets is challenging in FDTD. To capture effects like
surface current (skin effect) requires an impractically high resolution mesh.
Thus, Thin Conducting Sheet treats the metal as a zero-thickness 2D plane.
The resistive loss in metals is simulated using a simplified, behavioral model
to "fit" the observed loss rather than the full physics.

.. important::
   * A Thin Conducting Sheet can only be used to create a zero-thickness
     geometrical object, the created 3D shape (primitive) mush be a plane.
   * Surface roughness modeling is currently not supported.

Example
"""""""

It's added by the :func:`AddConductingSheet` method in Matlab/Octave, or by the
:meth:`~CSXCAD.ContinuousStructure.AddConductingSheet` method in Python.

The following example creates a Thin Conducting Sheet material named
``copper_foil``, with a conductivity of 59.6e6 S/m and a simulated thickness
of 35 µm (the shape created from it must be a 2D plane with zero thickness).
This is typical for a 1-oz circuit board::

    % Matlab/Octave
    csx = InitCSX();
    csx = AddConductingSheet(csx, 'copper', 59.6e6, 35e-6);
    % derive primitives via AddBox(), AddCylinder(), etc.

    # Python
    import CSXCAD
    csx = CSXCAD.ContinuousStructure()
    sheet = csx.AddConductingSheet('copper_foil', conductivity=59.6e6, thickness=35e-6)
    # derive primitives via sheet.AddBox(), sheet.AddCylinder(), etc.

General Material
-----------------

A general material is defined by a relative permittivity :math:`\epsilon_r`,
a relative permeability :math:`\mu_r`, an electric conductivity :math:`\kappa`,
and a hypothetical magnetic conductivity :math:`\sigma`.

.. warning::
   ``Kappa`` (:math:`\kappa`) always stands for electric conductivity in openEMS.
   It's not to be confused with electric permittivity :math:`\epsilon`, which is
   sometimes also denoted as :math:`\kappa` in the literature (e.g. high-κ
   dielectric). This convention is never used in openEMS, its use in simulation
   code is strongly discouraged.

All parameters are constants that don't vary with frequency.
It can model dielectric materials (such as circuit board substrate), magnetic
materials (such as magnetic cores), resistive materials, and 3D metals.
Due to the constant-property assumption, this model is not realistic. But
it produces acceptable results in simpler applications, and has no simulation
overhead.

.. seealso::
   :ref:`dispersive_materials`

Example
""""""""

It's added by the :func:`AddMaterial` method in Matlab/Octave, or by the
:meth:`~CSXCAD.ContinuousStructure.AddMaterial` method in Python.

Create a plexiglass material::

    % Matlab/Octave
    csx = InitCSX();
    csx = AddMaterial(csx, 'plexiglass');
    csx = SetMaterialProperty(csx, 'plexiglass', 'Epsilon', 2.22);
    % derive primitives via AddBox(), AddCylinder(), etc.
    
    # Python
    import CSXCAD
    csx = CSXCAD.ContinuousStructure()
    plexiglass = csx.AddMaterial('plexiglass', epsilon=2.22)
    # derive primitives via plexiglass.AddBox(), plexiglass.AddCylinder(), etc.

Anisotropic Material
"""""""""""""""""""""

A material property such as permittivity may differ along the X, Y, and Z axes,
This is known as an *anisotropic* material. If only one axis has a different
value from the conventional value (two values in total), it's known as *uniaxial
anisotropy*. If two axes have different values (three values in total), it's known
as *biaxial anisotropy*.

In optics, many crystals exhibit a phenomenon known as *birefringence* due
to the anisotropic refractive indexes. In high-speed eletronics, the propagation
delays of signals on an FR-4 circuit board have measurable differences depending
on the excitation mode (single-ended vs. differential) due to anisotropic
permittivity of the fiberglass-epoxy mixture.

To model anisotropic effects, set the respective material property as
an array ``[x, y, z]``::

    % Matlab/Octave
    csx = InitCSX();
    csx = AddMaterial(csx, 'yso');

    % YSO (Y2SiO5) crystal, 8 - 22.3 GHz, room temperature.
    % source: https://arxiv.org/abs/1503.04089
    csx = SetMaterialProperty(csx, 'yso', 'Epsilon', [9.60, 11.22, 10.39]);
    % derive primitives via AddBox(), AddCylinder(), etc.

    # Python
    import CSXCAD
    csx = CSXCAD.ContinuousStructure()

    # YSO (Y2SiO5) crystal, 8 - 22.3 GHz, room temperature.
    # source: https://arxiv.org/abs/1503.04089
    yso = csx.AddMaterial("YSO", epsilon=[9.60, 11.22, 10.39])

    # derive primitives via yso.AddBox(), yso.AddCylinder(), etc.

.. important::

   A material can be anisotropic and dispersive (described later)
   at the same time, but this usage is currently untested.

Weighting Function
""""""""""""""""""""

A material property can be a function of position (spatial coordinates)
by modulating its constant value by a weighting function via
:func:`SetMaterialWeight` (Octave) or
:meth:`~CSXCAD.CSProperties.CSPropMaterial.SetMaterialWeight` (Python).
The weighting function is a string, which contains the expression parsed
by the ``fparser`` library, so the string should be a legal ``fparser``
expression with proper syntax.

In the following example, a material with a permittivity that alternates
between 1 and 2 in space is defined::

    % Matlab/Octave
    csx = AddMaterial(csx, 'material');
    csx = SetMaterialProperty(csx, 'material', 'Epsilon', 1);
    csx = SetMaterialWeight(csx, 'material', 'Epsilon', ['(sin(4 * z / 1000 * 2 * pi) > 0) + 1']);
    
    # Python
    import CSXCAD
    csx = CSXCAD.ContinuousStructure()
    material = csx.AddMaterial("material", epsilon=1)
    material.SetMaterialWeight(epsilon='(sin(4 * z / 1000 * 2 * pi) > 0) + 1')

.. tip::

   Three built-in coordinates are defined.
   In Cartesian coordinates they're ``x``, ``y``, and ``z``. In cylindrical
   coordinates they're ``r`` (distance to the origin), ``rho`` (distance to
   the Z axis), ``a`` (phase angle), and ``z`` (height).
   Two special constants ``pi`` and ``e`` are pre-defined and recognized as well
   by openEMS.

   fparser supports a complete set of built-in functions, including
   trigonometry functions such as ``sin(x)``, conditional functions
   such as ``if(cond, eval_when_true, eval_when_false)``, and Boolean
   expressions such as ``(x > 0)``. This makes functions
   expressive if tricky. See the fparser project documentation [1]_
   for syntax.

.. _concept_magnetic_conductivity:

Magnetic Conductivity
"""""""""""""""""""""""

*Magnetic Conductivity* is a hypothetical material property in computational
electromagnetics by assuming the existence of magnetic charges (magnetic
monopoles) and magnetic conduction currents.

Faraday's law in Maxwell's curl equations is modified to the following form
[2]_.  :math:`\kappa` and :math:`\sigma` are the electric and magnetic
conductivity terms, respectively.

.. math::
   \begin{aligned}
   \begin{cases}
   \nabla \times \mathbf{H} =
     \space\space\space
     \kappa \mathbf{E}+ \epsilon \dfrac{\partial \mathbf{E}}{\partial t} \\
   \nabla \times \mathbf{E} =
     -\sigma \mathbf{H} - \mu \dfrac{\partial \mathbf{H}}{\partial t}
   \end{cases}
   \end{aligned}

The modified Faraday's law allows one to introduce both electric and
magnetic conduction losses, which simplifies certain aspects of a
simulation. For example, the Perfect Magnetic Conductor (PMC)
:ref:`boundary condition <concept_bc>` is a wall with
:math:`\sigma \to \infty`, which allowing cutting a symmetrical
simulation domain by half by implicitly enforcing field symmetry.
The Perfectly Matched Layer's internal implementation makes use
of magnetic conductivity to enable EM wave absorption.

.. tip::
   In the physical universe, magnetic monopoles don't exist according
   to our best knowledge, the modified Faraday's law degenerates to the
   standard form by setting :math:`\sigma = 0`.

User simulations can also take advantage of this advanced feature,
an example of a custom localized EM wave absorber for transmission
line simulations can be found in ``matlab/examples/transmission_lines/MSL.m``,
which combines electric conductivity, magnetic conductivity, and two
custom weighting functions, creating a hypothetical "tapered conductivity"
and achieving low reflections. It demonstrates a non-standard and advanced
simulation by a clever combination of different features::

    % this "pml" is a normal material with graded losses
    % electric and magnetic losses are related to give low reflection
    % for normally incident TEM waves
    finalKappa = 1 / abs_length ^ 2;
    finalSigma = finalKappa * MUE0 / EPS0;
    csx = AddMaterial(csx, 'fakepml');
    csx = SetMaterialProperty(csx, 'fakepml', 'Kappa', finalKappa);
    csx = SetMaterialProperty(csx, 'fakepml', 'Sigma', finalSigma);
    csx = SetMaterialWeight(csx, 'fakepml', 'Kappa', ['pow(z-' num2str(length - abs_length) ',2)']);
    csx = SetMaterialWeight(csx, 'fakepml', 'Sigma', ['pow(z-' num2str(length - abs_length) ',2)']);

Lumped Element
---------------

Lumped elements are ideal resistors, capacitors and inductors with sizes
assumed to be negligible. They're especially useful for modeling surface-mount
circuit components.

Example
""""""""

It's added by the :func:`AddLumpedElement` method in Matlab/Octave, or by the
:meth:`~CSXCAD.ContinuousStructure.AddLumpedElement` method in Python.
If argument ``caps`` is enabled, a small PEC plate is added to each end of the
lumped element to ensure electrical contact to the connected lines.

Create a lumped 1 pF capacitor in ``y`` direction::

    % Matlab/Octave
    csx = InitCSX();
    CSX = AddLumpedElement(CSX, 'capacitor', 'y', 'Caps', 1, 'C', 1e-12);
    % derive primitives via AddBox(), AddCylinder(), etc.

    # Python
    import CSXCAD
    csx = CSXCAD.ContinuousStructure()
    capacitor = csx.AddLumpedElement('capacitor', 'y', C=1e-12, caps=True)
    # derive primitives via capacitor.AddBox(), capacitor.AddCylinder(), etc.

.. important::
   **Axis Alignment.** Lumped elements must have an orientation aligned to
   the X, Y, or Z axis. If a misaligned resistor or capacitor must be used,
   rather than modeling it as a lumped element, constructing a distributed element
   based on a hypothetical material (via :func:`AddMaterial` with an artificial
   conductivity or permittivity) may be a workaround.

For most of the project history, a lumped element can only be an isolated
resistor or capacitor (even inductors are not implemented). In the latest
development version of openEMS (v0.0.37, unreleased), a contributed
new extension has been submitted to openEMS, allowing the lumped element
to be an entire RLC circuit, with resistance, capacitor, inductance values
simultaneously.
It's controlled by the parameter ``LEtype`` in Python's
:meth:`~CSXCAD.ContinuousStructure.AddLumpedElement`. A value of ``0``
denotes a parallel RLC circuit, when a value of ``1`` denotes a series
RLC circuit. It's not implemented by the Matlab/Octave binding as of
now.

Limitation: Parasitic Ambiguity
"""""""""""""""""""""""""""""""

Lumped elements are ideal throughout the region occupied by the derived
primitives. However, the intermediate connections between a lumped element
to the external circuit still introduce parasitic effects (e.g., inductance
from the overall loop area, partial inductance of terminal leads or mounting
height). Full-wave simulations inherently capture them through the electric
and magnetic fields in space.

Furthermore, the existence and modeling of parasitics effects can be
context-dependent and ambiguous. It's not always clear whether a parasitics
effect should be explicitly modeled as a lumped element (such as an LC
circuit), implicitly modeled using the geometries, or modeled as a combination
of both.

Due to these ambiguities, it's recommended to run simple test cases to
determine the best way to model a lumped component for your application.
To learn more, see :ref:`concept_lumped`.

Dispersive Materials
----------------------

Debye, Drude, Lorentz materials are advanced models to model dispersive
materials. They're added by the functions :func:`AddDebyeMaterial` and
:func:`AddLorentzMaterial`.

Nearly all real-world materials exhibit a phenomenon known as dispersion. That
is, the speed of light in the medium depends on the EM wave's frequency. In
optics, it manifests as a frequency-dependent refractive index. In RF/microwave
engineering, it appears as a frequency-dependent permittivity and permeability.
In metamaterial research, one can even deliberately introduce dispersion to
control electromagnetic wave propagation in unusual ways.

As a result, while the basic material model with constant permittivity and
permeability is sufficient if dispersion is negligible, more demanding
simulations call for dispersion models for accurately calculating a material's
wideband response.

See :ref:`dispersive_materials` for detailed descriptions.

Probes and Dumps
-------------------

Technically, excitation sources, probes, and field dump boxes are also
*Properties*. The associated geometrical shape determines the locations
of these excitations, probes and dumps.

They're added by Matlab/Octave functions :func:`AddExcitation`,
:func:`AddPlaneWaveExcite`, :func:`AddProbe`, and :func:`AddDump`. In Python,
they're added by :meth:`~CSXCAD.ContinuousStructure.AddExcitation`,
:meth:`~CSXCAD.ContinuousStructure.AddProbe` and
:meth:`~CSXCAD.ContinuousStructure.AddDump`.

To learn more, see :ref:`concept_excitations` and :ref:`concept_fielddump`.

Bibliography
--------------

.. [1] fparser, `fparser project documentation
   <http://warp.povusers.org/FunctionParser/fparser.html#literals>`_.

.. [2] John B. Schneider. `Understanding the FDTD Method.
   <https://eecs.wsu.edu/~schneidj/ufdtd/index.php>`_,
   page 66, equation 3.53.
