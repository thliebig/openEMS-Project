.. _concept_modeling:

Modeling Basics
=================

Initialization
---------------

An openEMS simulation always starts by creating a 3D model of the structure
using the CSXCAD library. All created entities for the simulation are stored
in the ``csx`` data structure (or Python object), which must be initialized
first. It's done by either the :func:`InitCSX` method in Matlab/Octave, or
the :class:`~CSXCAD.ContinuousStructure` class in Python:

.. tabs::

   .. code-tab:: octave

       csx = InitCSX();

   .. code-tab:: python

       import CSXCAD
       csx = CSXCAD.ContinuousStructure()

Once initialized, 3D models can be created by the functions provided by CSXCAD.
In Matlab/Octave, nearly all of them accept an old instance of the ``csx`` data
structure, and return a modified new one. The Python binding has a more modern
coding style in comparison, which achieves this via class methods rather than
functions:

.. tabs::

   .. code-tab:: octave

       % create a property (e.g. AddMetal, AddMaterial)
       csx = AddExample(csx, arg1, arg2, arg3, ...)

   .. code-tab:: python

       # create a property (e.g. AddMetal, AddMaterial)
       prop = csx.AddExample(arg1, arg2, arg3, ...)

These CSXCAD functions can be classified into two types, *primitives*
and *properties*. They define shapes and their material properties respectively.

*Primitives* are the building blocks to create 1D, 2D, 3D shapes at given
coordinates, so that one can create a simple object at a specific position,
such as a Curve, a Polygon, a Box, or a Sphere.

*Properties* are always created before *Primitives* to give physical
meanings to the created objects. A *property* can represent
an ideal or imperfect material such as a metal, a thin conducting sheet,
a dielectric material, a magnetic material, a lumped circuit component
(resistor, capacitor, inductor), etc. Non-physical simulation entities
are also *properties*, such as excitation sources, probes, and field
dump boxes.

More complex structures can be created by combining various *primitives*.
If the same position contains overlapping *primitives*, the primitive
with the highest *priority* takes effect.
For example, a metal sheet with cylindrical holes can be achieved by
creating a *metal* (or *thin conducting sheet*) property, and deriving
a box primitive without holes. Then, create another *material*
property with :math:`\epsilon_r = \mu_r = 1.0`, and deriving several
cylinder primitives with higher *priorities*.

.. tip::
   Primitives tell the simulation where objects are, properties tell the
   simulation what objects do, priorities tell the simulation which object
   "wins."

   See :ref:`concept_properties` and :ref:`concept_primitives` for details.

Coordinate Systems
-------------------

By default, a Cartesian coordinate system is used, which is suitable for
most simulations. If the simulated structure is predominantly circular, the
Cartesian mesh may have a difficult time aligning itself with an object's
shape. Hence openEMS provides the alternative cylindrical coordinate system
to minimize staircasing errors — see :ref:`concept_cylindrical_fdtd` for why
this matters and what it costs:

.. tabs::

   .. code-tab:: octave

       csx = InitCSX('CoordSystem', '1');

   .. code-tab:: python

       import CSXCAD
       csx = CSXCAD.ContinuousStructure(CoordSystem=1)

.. note::

   This mainly affects mesh coordinates of the simulation box, not
   the coordinates of 3D model themselves. When creating 3D models,
   one can choose both Cartesian and Cylindrical coordinates independently
   from the mesh (by default, models do follow the mesh coordinate system,
   but it can always be overridden).

Once modeled, the CSXCAD data structure is usually saved to disk as an
``.xml`` file and can be inspected in the :program:`AppCSXCAD` 3D viewer.
Saving, reloading, importing/exporting other formats, and third-party
modeling tools are covered separately in :ref:`concept_model_io`.
