.. _concept_numerical_method:

Numerical Method
==================

openEMS is a full-wave, time-domain electromagnetic field solver based on the
Finite-Difference Time-Domain (FDTD) method. This page introduces FDTD at a
conceptual level: what kind of method it is, why openEMS implements it as an
*Equivalent-Circuit* (EC) formulation, and what FDTD is (and isn't) good at
compared to other computational electromagnetics (CEM) approaches. For the
concrete mechanics of the grid itself — Yee cells, the staggered leapfrog
update, and the CFL stability limit — see :ref:`concept_mesh`.

FDTD in a Nutshell
--------------------

FDTD discretizes both space and time. Maxwell's curl equations are
approximated by finite differences on a spatial grid (the Yee mesh) and
advanced one small timestep at a time (*time-marching*). Every timestep only
updates each cell from its immediate neighbors, so the algorithm is entirely
*explicit*: there's no global system of equations to assemble or invert, and
propagation delay across the model falls out naturally from the number of
timesteps a wave takes to physically travel across it.

Because the simulation runs directly in the time domain, a single run can
cover a wide frequency band at once: exciting the structure with a short,
broadband pulse (e.g. a Gaussian) and Fourier-transforming the recorded
time-domain response yields S-parameters, impedances, or far-fields across
the entire excited spectrum, see :ref:`signal_concept`. This is the main
practical payoff of choosing a time-domain method in the first place, and
it's true of any time-domain solver, not something specific to FDTD or to
openEMS.

The Equivalent-Circuit (EC) Formulation
------------------------------------------

openEMS implements FDTD using the *Equivalent-Circuit* (EC-FDTD) formulation
described in the openEMS and Rennings/Liebig publications (see
:ref:`concept_mesh`'s bibliography, and :ref:`publications_src`). Instead of
updating raw electric and magnetic field samples, EC-FDTD reformulates the
same Yee-grid update in terms of the *integrated* voltages and currents along
each cell's edges and faces. Concretely, every Yee cell becomes a small
lumped-element circuit: capacitances and conductances sit on the
electric-field edges, inductances and resistances on the magnetic-field
faces, and the familiar Yee leapfrog update becomes a set of discrete-time
circuit (Kirchhoff) equations instead of discretized curl equations.

.. important::
   **EC-FDTD is a reformulation, not a different physical model.** Standard
   Yee-FDTD (fields) and EC-FDTD (voltages/currents) are mathematically
   equivalent — anything that can be expressed and simulated in one can, in
   principle, also be expressed and simulated in the other. Choosing one over
   the other is an implementation and derivation decision, not a difference
   in what the solver can compute or how accurate it is. The name mainly
   describes *how openEMS's internals are derived and expressed*, not a
   separate numerical method sitting alongside FDTD.

Where the circuit formulation does earn its keep is convenience, in a few
recurring places:

* **Lumped elements.** Because the solver's state is already voltages and
  currents, discrete resistors, capacitors and inductors — see
  :ref:`concept_lumped` — drop in as additional circuit branches without a
  separate field-to-circuit translation layer.
* **Dispersive materials.** Representing a Debye/Drude/Lorentz pole as an
  extra RC/RLC-like branch makes deriving both the update equations and the
  *stability criteria* for these materials considerably more tractable, see
  :ref:`dispersive_materials`.
* **Non-orthogonal, graded and cylindrical meshes.** Circuit quantities are
  integrals over a cell's edge or face rather than point samples of a field,
  which carries over more directly to non-uniform or curved cell geometry.
  This is part of why the same solver core handles both the graded Cartesian
  mesh and the cylindrical mesh (see :ref:`concept_mesh` and
  :ref:`concept_cylindrical_fdtd`) without needing a distinct formulation per
  coordinate system. The same lineage of thinking — using integrated
  quantities on a grid rather than raw field samples, to generalize beyond
  simple Cartesian grids — traces back to Weiland's Finite Integration
  Technique (FIT).

In short: EC-FDTD is best understood as *an implementation choice that makes
certain features easier to derive and prove stable*, not a capability
Cartesian-field FDTD inherently lacks. Whether it's worth adopting for a
given FDTD implementation is, in the end, largely a matter of the developer's
taste.

Why FDTD? Pros and Cons
--------------------------

Choosing FDTD (in either formulation) over another CEM method — such as the
frequency-domain Method of Moments (MoM) or Finite Element Method (FEM) —
involves trade-offs. None of these are specific to openEMS; they're inherent
to the explicit, time-domain, volumetric nature of FDTD itself.

**Advantages**

* **Broadband in a single run.** As above, one simulation plus a Fourier
  transform covers a whole band, instead of one frequency-domain solve per
  frequency point.
* **Geometric flexibility.** Arbitrary, inhomogeneous 3D geometry — including
  curved and layered dielectrics, metals, and lumped or dispersive materials
  — is handled directly by assigning per-cell material properties. There's no
  need for surface meshing with a Green's function (as in MoM), nor for
  generating basis functions on an unstructured volume mesh (as in FEM).
* **No global linear system.** Because updates are local and explicit, there
  is no dense or sparse system to factor or iteratively solve for every
  excitation, unlike MoM or FEM.
* **Straightforward parallelization.** Local, stencil-like updates scale well
  across threads, SIMD and GPUs; openEMS itself uses multi-threading and SSE.
* **Direct physical insight.** Because the wave genuinely propagates
  timestep by timestep, field dumps in time make it easy to visually debug
  a setup (e.g. to catch a stray reflection or an incorrectly placed port).

**Disadvantages**

* **Volumetric meshing.** FDTD must discretize the *entire* computational
  domain, including all surrounding free space out to the absorbing
  boundary — not just conductor or dielectric surfaces as in MoM. Memory and
  runtime therefore scale with the physical volume of the problem (in
  wavelengths cubed), which can be costly for electrically large, mostly
  empty problems.
* **Grid (staircasing) error.** A Cartesian grid approximates curved or
  diagonal boundaries as steps; even where the boundary is well resolved,
  numerical dispersion accumulates with propagation distance. See
  :ref:`concept_cylindrical_fdtd` for openEMS's main mitigation for round
  structures, and :ref:`concept_mesh` for non-uniform (graded) Cartesian
  meshing.
* **Conditional stability.** The timestep is tied to the smallest cell
  anywhere in the mesh (the CFL limit, see :ref:`concept_mesh`), so one small
  geometric feature can dominate the runtime of an otherwise coarse
  simulation.
* **Inefficient for narrowband, high-Q problems.** A high-Q resonator's
  energy decays slowly, so reaching the convergence criterion can require
  very many timesteps compared to a frequency-domain solve at a single
  frequency of interest.
* **Low-frequency / small-structure mismatch.** As covered in
  :ref:`concept_mesh`'s CFL discussion, a physically small structure operated
  far below its natural resonance (e.g. a 10 cm board at 1 MHz) needs an
  impractically large number of timesteps; FDTD (of either formulation) is
  simply the wrong tool for that regime.

.. note::
   **Stability in practice.** As long as the CFL/Rennings2 timestep limit is
   respected, the FDTD (and EC-FDTD) update itself is inherently numerically
   stable — it doesn't drift or "blow up" on its own. The main known
   exception is the :ref:`PML absorbing boundary <concept_bc_pml>`: it's a
   very effective absorber for transmission-line, waveguide-mode, and
   otherwise well-behaved radiating fields, but is itself an artificial
   material — this is a property of PML in any FDTD implementation, not
   something specific to openEMS. Fringe fields and evanescent waves
   reaching into it can destabilize it. Keep radiating structures —
   intentional or not — at least :math:`\lambda/4` away from any PML
   boundary.

.. seealso::
   :ref:`concept_mesh` — Yee cells, the staggered leapfrog update, meshing
   requirements, and the CFL/Rennings2 timestep criteria.

   :ref:`concept_cylindrical_fdtd` — openEMS's cylindrical-coordinate
   extension, its origin-singularity challenge, and its trade-offs against a
   refined Cartesian mesh.

   :ref:`concept_lumped` and :ref:`dispersive_materials` — two areas where
   the equivalent-circuit formulation is used directly.
