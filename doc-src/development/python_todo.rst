.. _develop_unimpl_python:

Unimplemented Python Features
================================

Introduction
-------------

CSXCAD and openEMS began as C++ programs driven by users via Matlab/Octave,
the Python bindings came relatively late in the project's history. As a
result, not all C++ and Matlab/Octave features are currently implemented
in Python.

One can classify these missing features into two categories.

1. The C++ API was not linked to Python.

 - Solving this problem is relatively easy. One can add the missing
   C++ API binding without reimplementing any logic.

2. Both developers and ordinary openEMS users have contributed
   high-level pre-processing and
   post-processing features, but only specific to Matlab/Octave.
   Examples include numerical fitting code and model exporting code.

 - This problem is more difficult to solve, as the same logic must
   be reimplemented in Python.

The following list of missing Python features is meant for reference by
developers and end users.

Known Problems
---------------

Some model importing and exporting functions are unimplemented
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Type 2: Missing high-level feature.

- Affected APIs: :func:`ImportPLY`, :func:`ImportSTL`,
  :func:`export_gerber`, :func:`export_excellon`, :func:`export_povray`.

- Workaround: To import an STL file, use
  :meth:`~CSXCAD.CSProperties.CSProperties.AddPolyhedronReader`.
  To export models, use :program:`AppCSXCAD`.

Mur ABC phase velocity parameter adjustment is unimplemented
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Type 1: Missing C++ binding.

- Affected APIs: :func:`SetBoundaryCond`'s optional argument
  ``MUR_PhaseVelocity`` is unimplemented. Mur's ABC cannot be
  further optimized by tuning ``MUR_PhaseVelocity`` if the
  boundary doesn't end at a vacuum.

- Workaround: None.

- Comment: The underlying ``Set_Mur_PhaseVel()`` is already declared in
  ``openEMS/python/openEMS/openEMS.pxd``, it is only never called. The
  missing piece is an optional argument of
  :meth:`~openEMS.openEMS.SetBoundaryCond` that forwards it.
  Note that this is unrelated to the *local* absorbing boundary
  property :class:`~CSXCAD.CSProperties.CSPropAbsorbingBC`, whose
  ``PhaseVelocity`` is available in Python.

Dispersive material fitting helpers are unimplemented
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Type 2: Missing high-level feature.

- Affected APIs: :func:`AddDjordjevicSarkarMaterial`,
  :func:`CalcDebyeMaterial`, :func:`CalcDjordjevicSarkarApprox`,
  :func:`CalcDrudeMaterial`, :func:`CalcLorentzMaterial`.

- Workaround: None. These Octave functions are helper functions that
  calculate the model's output curves for the purpose of fitting
  parameters and preparing a simulation. No C++ APIs exist because
  they're not actually used in the simulation.

- Comment: The Debye and Lorentz *materials* themselves are available
  in Python as :class:`~CSXCAD.CSProperties.CSPropDebyeMaterial` and
  :class:`~CSXCAD.CSProperties.CSPropLorentzMaterial`, including their
  model parameters. Only the fitting helpers listed above, and the
  Djordjevic-Sarkar model built on top of them, are missing. See
  :ref:`dispersive_materials`.

Delay fidelity post-processing for UWB systems is unimplemented
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Type 2: Missing high-level feature.

- Affected API: :func:`DelayFidelity`

- Workaround: None.

- Comment: This is a specialized post-processing function involved
  in the design of ultra-wideband radios and radars.
  In these applications it is important to know the
  delay and fidelity of RF pulses. The delay is the retardation of the
  signal from the source to the phase center of the antenna. It is
  composed out of linear delay, dispersion and minimum-phase
  delay. Dispersion due to waveguides or frequency-dependent
  permittivity and minimum-phase delay due to resonances will degrade
  the fidelity which is the normalized similarity between excitation and
  radiated signal.

CTB and scikit-rf Post-Processing
----------------------------------

You may encounter Circuit Toolbox (CTB) in openEMS simulations,
which is Matlab/Octave exclusive. However, this is not a "missing
feature".

CTB is developed by openEMS's author Thorsten Liebig and
is used with openEMS in some examples, but it's an independent
library outside openEMS's codebase. It contains network parameter
calculation functions to help analyzing simulation outputs,
but they're themselves not part of the simulator.

To analyze RF circuits in Python, use other Python RF
engineering libraries, such as :program:`scikit-rf`. This is a 3rd-party
project not associated with openEMS.

Conversely, :program:`scikit-rf` contains many sophisticated
calibration, de-embedding and signal transform algorithms
which represented multiple years of work. If you encounter openEMS
examples with :program:`scikit-rf`, Matlab/Octave alternatives
would be even less straightforward to find.
