.. _concept_cylindrical_fdtd:

Cylindrical FDTD
==================

Besides the standard Cartesian mesh, openEMS can solve the same
:ref:`EC-FDTD equations <concept_numerical_method>` in cylindrical
:math:`(\rho, \alpha, z)` coordinates instead of Cartesian
:math:`(x, y, z)`. Support for cylindrical coordinates is one of openEMS's
distinguishing features among open-source FDTD tools, originally developed
for simulating RF coils in traveling-wave Magnetic Resonance Imaging (MRI),
where the antennas and the surrounding structure are naturally
axisymmetric. This page covers why it exists and its trade-offs; for the
practical steps to build a cylindrical mesh, see :ref:`concept_mesh`.

Why Cylindrical Coordinates?
--------------------------------

A Cartesian mesh approximates any boundary that isn't axis-aligned as a
staircase of small steps. For round or axisymmetric structures — circular
waveguides and resonators, disk or ring antennas, coaxial lines, MRI coils —
this "staircasing" error only shrinks as the mesh is refined; it never
vanishes, and figures of merit that are sensitive to the exact radius (a
resonant or cutoff frequency, for instance) inherit that error.

A cylindrical mesh sidesteps the problem for the geometry that actually
benefits from it: because mesh lines run exactly along :math:`\rho` and
:math:`\alpha`, a boundary at constant radius is represented *exactly*,
independent of resolution. The gain is specific to curved or rotationally
symmetric features — it doesn't help (and isn't meant to help) with
axis-misaligned rectilinear geometry, which stair-steps in a cylindrical
mesh just as it would in a Cartesian one.

The Origin Singularity
-------------------------

Cylindrical coordinates introduce a problem that has no Cartesian
counterpart: the origin (:math:`\rho = 0`) is a coordinate singularity. At a
fixed angular resolution :math:`\Delta\alpha`, a cell's arc length
(:math:`\rho \cdot \Delta\alpha`) shrinks toward zero as :math:`\rho`
decreases, so cells near the axis become extremely thin wedges.

Because the FDTD timestep is bounded by the *smallest* cell anywhere in the
mesh (the CFL limit, see :ref:`concept_mesh`), a naively-generated
cylindrical mesh forces a timestep far smaller than the structure's
electrical size would otherwise call for — the tiny cells near the axis end
up dominating the runtime of the whole simulation, not just the region near
the axis.

Subgridding
--------------

openEMS mitigates this with *subgridding*: at one or more chosen radii, half
of the azimuthal mesh lines are dropped, halving the angular resolution.
Repeating this while moving inward keeps a cell's arc length roughly
constant instead of shrinking linearly with radius, which keeps the timestep
close to what the *outer*, physically relevant mesh would require rather
than what the innermost ring would otherwise force.

This is a coarsening applied at specific radii the user chooses, not a fully
automatic or continuously graded refinement — getting the trade-off right
between angular resolution, subgridding radii, and runtime still takes some
manual tuning, similar in spirit to (but a separate mechanism from) the
non-uniform Cartesian mesh described in :ref:`concept_mesh`.

.. note::
   Each subgridding radius requires interpolating field values between the
   staggered sub-grids on either side of it. This interpolation is mostly
   stable, but it is one of the few known exceptions to FDTD's otherwise
   inherent numerical stability (see :ref:`concept_numerical_method`):
   inhomogeneous material crossing a subgridding interface can destabilize
   the simulation. If a simulation using subgridding becomes unstable,
   consider moving the affected material boundary away from the subgridding
   radius, or moving the radius itself.

Practical Trade-offs and Rough Edges
----------------------------------------

Cylindrical support isn't a drop-in replacement for Cartesian everywhere in
openEMS; a few areas need extra care:

* **Primitives.** Not every primitive is equally well-suited to a
  cylindrical mesh — for example, a full cylinder is usually better
  represented with :func:`AddBox` over the radial/angular/z ranges than with
  :func:`AddCylindricalShell`, which can mesh incorrectly in some cases. See
  the note in :ref:`concept_primitives`.
* **Disc-material files.** Voxel-based material files (CT/MRI phantoms) are
  inherently Cartesian; openEMS re-samples them at each cylindrical cell's
  Cartesian position, which works but is an added conversion step per cell.
  See :ref:`concept_disc_material`.
* **Excitations and mode profiles.** Radial or azimuthal field patterns
  (coax lines, circular waveguide modes) need explicit :math:`\rho, \alpha`
  expressions rather than reusable Cartesian mode profiles, see
  :ref:`concept_fparser`.
* **Ports.** Only some port types are cylindrical-mesh aware; the circular
  waveguide port is one, see the
  :ref:`circular waveguide tutorial <octave_tutorial_circ_waveguide>` and
  :ref:`concept_ports`.
* **Structure.** The mesh is still fundamentally a 2D radial/axial profile
  extruded around the axis — it doesn't provide arbitrary local (h-adaptive)
  refinement the way an unstructured mesh in FEM might for an isolated
  hotspot away from the axis.

Cylindrical vs. a Refined Cartesian Mesh
--------------------------------------------

Cylindrical coordinates are worth the extra setup effort when a structure
has genuine rotational symmetry (or close to it) at a scale where
staircasing would otherwise perturb the result that matters — small
resonators, curved traces, RF coils. For structures that are only loosely
round, or where a circular feature is incidental to an otherwise rectilinear
design (e.g. one arc trace on a PCB), a locally-refined Cartesian mesh is
usually the simpler and sufficiently accurate choice — consistent with the
general "importing is easy, meshing is hard" caution that applies to
openEMS modeling overall, see :ref:`concept_modeling`.

.. seealso::
   :ref:`concept_numerical_method` — the EC-FDTD formulation this coordinate
   system is built on.

   :ref:`concept_mesh` — Yee cells, the CFL timestep limit, and how to build
   both Cartesian and cylindrical meshes in practice.

   :ref:`concept_primitives`, :ref:`concept_disc_material`,
   :ref:`concept_fparser`, :ref:`concept_ports` — practical, cylindrical-aware
   details for modeling, materials, excitations, and ports.
