.. _dispersive_materials:

Dispersive Materials
======================

Nearly all real-world materials exhibit a phenomenon known as dispersion. That
is, the speed of light in the medium depends on the EM wave's frequency. In
optics, it manifests as a frequency-dependent refractive index, causing the
separation of sunlight when it passes through a prism. In RF/microwave engineering, 
it appears as a frequency-dependent permittivity and permeability, often causing
unexpected changes in a filter's resonant frequency, or a transmission
line's characteristic impedance. In high-speed digital data lines,
dispersion may cause the smearing of signal edges and the
broadening of signal pulses. In metamaterial research, one can even deliberately
introduce dispersion to control electromagnetic wave propagation in unusual ways.

As a result, while the basic material model with constant permittivity and
permeability is sufficient if dispersion is negligible, more demanding
simulations call for dispersion models for accurately calculating a material's
wideband response.
In fact, strictly speaking, neglecting this frequency dependence violates
fundamental physical principles. The assumption of constant material properties
implies instantaneous polarization or magnetization in a material, thus it
violates the causality requirement as formalized in the Kramers-Kronig relations.

In openEMS, three dispersive material models known as Debye, Drude and Lorentz
materials are used to simulate dispersion.
These models were originally proposed by solid-state physicists
in the early 20th century to explain the microscopic origins of
electrical
and optical properties of matter.

Due to their compatibility with Maxwell's
equations, FDTD borrows these models for simulating dispersive materials.
Because these are analytical models, they do not directly take inputs
in the form of a raw frequency-dependent curve or lookup table of material
properties. Instead, a material's permittivity and permeability must
be parameterized using terms such as *plasma frequency*, *plasma relaxation time*,
and *Lorentz pole frequency*.

Although these solid-state physics parameters may appear unrelated to practical
RF/microwave engineering, in FDTD, they mainly act as calculation tools rather
than providing physical interpretations.
The required parameters are obtained by numerically fitting the model to
measured material response curves for the purpose of simulations. Both single-term
and multi-term models are supported, using one or more sets of parameters.
There are many
"degrees of freedom" in the fitting process. If a single-term fit fails to
produce the desired curves, more parameters can be added until one obtains a
satisfactory fit.

.. note::
   **Physics vs. Fitting**. FDTD only borrows these solid-state physics models as
   calculation tools. The fitted parameters are usually purely numerical (i.e.
   they fit measured
   data), or phenomenological at best (i.e. they match experimental
   outcomes without explaining the underlying mechanism). As such, they're generally
   not physically meaningful. As von Neumann famously joked, 
   "With four parameters I can fit an elephant,
   and with five I can make him wiggle his trunk."

   **Python**. The functions described below are not ported to Python yet.

   **Djordjevic-Sarkar**. This is a special helper model for creating
   an approximate but realistic Debye model for a FR-4 circuit board,
   using the reported real permittivity and loss tangent at a single
   frequency.

Complex Permittivity and Permeability
--------------------------------------

In circuit design, the permittivity of a dielectric material or the
permeability of a magnetic material is often given as a real-valued
constant.
However, this is an incomplete definition that is only suitable for
narrowband applications, or high-performance materials with low dispersion
throughout the spectrum. For wideband EM simulation with dispersion and
loss, one needs the full definition.

The complex permittivity and permeability are functions of frequency:

.. math::
   \begin{align}
   \epsilon(\omega) &= \epsilon'(\omega) + j\epsilon''(\omega) \\
   \mu(\omega) &= \mu'(\omega) + j\mu''(\omega)
   \end{align}

In dielectric materials, the complex permittivity describes
the polarization and associated energy loss.
In magnetic materials, the complex permeability describes the magnetization
and associated energy loss.

The imaginary part of a complex permittivity or permeability represents
the energy loss. Alternatively, one can describe the the same loss by
*loss tangent*. The electric and magnetic loss tangents can be defined
as:

.. math::
   \tan{\delta_\epsilon} = \frac{\epsilon''}{\epsilon'},\space\space \tan{\delta_\mu} = \frac{\mu''}{\mu'}

.. tip::

   Knowing the real permittivity (or permeability) and loss tangent at
   a given frequency is equivalent to knowing one data point on the
   complex permittivity (or permeability) function.

Debye Model
""""""""""""

Usage
''''''

:func:`AddDebyeMaterial` creates a material governed by the Debye model of dielectric
relaxation::

    CSX = AddDebyeMaterial(CSX, name, varargin)

The model is defined by the following parameters:

* ``Epsilon``: Relative permittivity when frequency approaches infinity
  (:math:`\epsilon_{r,\infty}`).

* ``EpsilonDelta_n``: n-th delta dielectric permittivity, a fitted phenomenological
  term that represents relaxation strength (:math:`\Delta \epsilon_r`).
  
* ``EpsilonRelaxTime_n``: n-th relaxation time, inverse of the damping factor,
  a dissipative term
  (:math:`\tau_\mathrm{relax}`).

* ``Kappa``: Electric conductivity, an ohmic loss term (:math:`\kappa`).
  Not to be confused with electric permittivity, sometimes also denoted by the
  same letter.

.. warning::
   ``Kappa`` (:math:`\kappa`) always stands for electric conductivity in openEMS.
   It's not to be confused with electric permittivity :math:`\epsilon`, which is
   sometimes also denoted as :math:`\kappa` in the literature (e.g. high-κ
   dielectric). This convention is never used in openEMS, its use in simulation
   code is strongly discouraged.

For the single-term model, use one set of parameters (i.e. ``EpsilonDelta_1``,
``EpsilonRelaxTime_1``). For higher-order modeling, add more parameters with
increasing indices in their suffixes ``n`` (e.g. ``EpsilonDelta_2``, ``EpsilonRelaxTime_2``,
...)

Example::

    CSX = AddDebyeMaterial(CSX, 'debye_example');
    CSX = SetMaterialProperty(CSX, 'debye_example', 'Epsilon', 5, 'EpsilonDelta_1', 0.1, 'EpsilonRelaxTime_1', 1e-9);

    % create geometry
    CSX = AddBox(CSX, 'debye_example', 10, start, stop);

Calculation
'''''''''''''

:func:`CalcDebyeMaterial` is a helper function to calculate the numerical values of
permittivity at specified frequency points in an array. It's useful for fitting
material parameters for simulation preparation as part of a numerical optimization
routine.

Definition::

    eps_debye = CalcDebyeMaterial(f, eps_r, kappa, eps_Delta, t_relax)

Parameters:

* ``f``: (vector) Frequency points of interest.
* ``eps_r``: Relative permittivity when frequency approaches infinity
  (:math:`\epsilon_{r,\infty}`).
* ``kappa``: Electric conductivity, an ohmic loss term
  (:math:`\kappa`).
* ``eps_Delta``: (vector) Delta relative permittivity, a fitted phenomenological
  term that represents oscillator strength (:math:`\Delta \epsilon_r`)
* ``t_relax``: (vector) Relaxation time, the inverse of damping factor, a dissipative term
  (:math:`\tau_\mathrm{relax}`).

Djordjevic-Sarkar Model
""""""""""""""""""""""""""

Usage
''''''

:func:`AddDjordjevicSarkarMaterial` creates an FR-4 circuit board
substrate material governed by the Djordjevic-Sarkar model [6]_, which
is based on the Debye model::

    CSX = AddDjordjevicSarkarMaterial(CSX, name, varargin)

This model is defined by the following parameters:

* ``fMeas``: Measurement frequency, in hertz.
* ``epsRMeas`` : Relative permittivity :math:`\epsilon_r` at ``fMeas``.
* ``tandMeas`` : Loss tangent :math:`\tan(\delta)` at ``fMeas``.
* ``f2`` : Upper corner frequency of the model, in hertz.

The following optional parameters are available:

* ``lowFreqEvalType``: Low-frequency behavior.

  - 0: use ``f1`` (default), typical Djordjevic–Sarkar.
  - 1: use ``epsRdc``.

* ``f1`` : Lower corner frequency [Hz] (used if ``lowFreqEvalType = 0``).
* ``epsRdc`` : Permittivity at DC (used if ``lowFreqEvalType = 1``).
* ``sigmaDC`` : DC conductivity (S/m).
* ``nTermsPerDec`` : Number of Debye terms per frequency decade.
* ``plotEn``: Enable/Disable plots of the model.

Example::

    CSX = AddDjordjevicSarkarMaterial(
        'ds_example', ...
        'fMeas', 1e9, 'epsRMeas', 4.2, 'tandMeas', 0.02, ...
        'f1', 1e6, 'f2', 200e9 ...
    );

Internally, this function performs a three-step computation. First,
it calculates the approximate wideband complex permittivity of a Printed
Circuit Board (PCB) substrate according to the Djordjevic-Sarkar model,
extrapolating one data point to a wideband curve. Next, the corresponding
Debye model parameters are fitted. Finally, :func:`AddDebyeMaterial`
is called to add the fitted Debye material into the simulation.

.. tip::

   This model is especially useful in circuit board designs because the
   wideband complex permittivity curves of the FR-4 (fiberglass-epoxy)
   substrate are rarely provided by PCB manufacturers, preventing one to
   fit any model due to lack of input data. The empirical Djordjevic-Sarkar
   model allows one to approximate such input data using one data point.

Calculation
'''''''''''''

:func:`CalcDjordjevicSarkarApprox` is a helper function to calculate the
Debye model parameters of an FR-4 circuit board substrate material, by
first calculating the wideband complex permittivity using the Djordjevic-Sarkar
model, and fitting the corresponding Debye model parameters. It's used
internally by :func:`AddDjordjevicSarkarMaterial`. Users can use it for
checking the model and fitting quality.

Definition::

    [paramDebye, paramSarkar] = CalcDjordjevicSarkarApprox(varargin)

The parameters are nearly identical to :func:`AddDjordjevicSarkarMaterial`,
see :func:`CalcDjordjevicSarkarApprox` for details.

Example::

    [pDebye, pSarkar] = calcDjordjevicSarkarApprox( ...
        'fMeas', 1e9, 'epsRMeas', 4.2, 'tandMeas', 0.02, ...
        'f1', 1e6, 'f2', 200e9, 'plotEn', 1 ...
    );

Drude Model
"""""""""""""

Usage
''''''

:func:`AddLorentzMaterial` creates a material governed by either the Drude 
model or the Lorentz model. The Drude model is obtained as a special case
of Lorentz when relevant parameters are omitted::

    CSX = AddLorentzMaterial(CSX, name, varargin)

For dielectric materials, this model is defined by the following parameters:

* ``Epsilon``: Relative permittivity when frequency approaches infinity
  (:math:`\epsilon_{r,\infty}`).
* ``EpsilonPlasmaFrequency_n``: n-th electric plasma frequency in hertz
  (:math:`f_{p\epsilon}`).
* ``EpsilonRelaxTime_n``: n-th electric plasma relaxation time
  (:math:`\tau_\epsilon`), a dissipative term.
* ``Kappa``: Electric conductivity (:math:`\kappa`), an ohmic loss term, optional
  but recommended to improve curve fitting.
  Not to be confused with electric permittivity, sometimes also denoted by the
  same letter.

.. warning::
   ``Kappa`` (:math:`\kappa`) always stands for electric conductivity in openEMS.
   It's not to be confused with electric permittivity :math:`\epsilon`, which is
   sometimes also denoted as :math:`\kappa` in the literature (e.g. high-κ
   dielectric). This convention is never used in openEMS, its use in simulation
   code is strongly discouraged.

For magnetic materials, this model is defined by the following parameters:

* ``Mue``: Relative permeability when frequency approaches infinity
  (:math:`\mu_{r,\infty}`).
* ``MuePlasmaFrequency_n``: n-th magnetic plasma frequency in hertz
  (:math:`f_{p\mu}`).
* ``MueRelaxTime_n``: n-th magnetic plasma relaxation time (:math:`\tau_\mu`),
  a dissipative term.
* ``Sigma``: Magnetic conductivity (:math:`\sigma`), an ohmic-like loss term.
  This is a non-physical property due to a hypothetical magnetic conduction
  current, optional but useful to improve fitting by introducing artificial
  losses.

Both the dielectric and magnetic parameters can be used simultaneously. If
the material is not magnetic, magnetic parameters can be omitted.

The terms ``Epsilon``, ``Mue``, ``Kappa`` and ``Sigma`` are the effects of the
basic constant-property material model, and are not implemented in
the Drude/Lorentz model per se. But they should be considered in the curve
fitting process.

For the single-term model, use one set of parameters (i.e. ``EpsilonPlasmaFrequency``,
``EpsilonRelaxTime``) without suffix ``_n``. For higher-order modeling, add more parameters
with increasing indices in their suffixes `n` (e.g.  ``EpsilonPlasmaFrequency_1``,
``EpsilonRelaxTime_1``, ``EpsilonPlasmaFrequency_2``, ``EpsilonRelaxTime_2``, ...)

Example::

    CSX = AddLorentzMaterial(CSX, 'drude_example');
    CSX = SetMaterialProperty(CSX, 'drude_example', 'Epsilon', 5, 'EpsilonPlasmaFrequency', 5e9, 'EpsilonRelaxTime', 1e-9);

    % optional, for magnetic materials
    CSX = SetMaterialProperty(CSX, 'drude_example', 'Mue', 5, 'MuePlasmaFrequency', 5e9, 'MueRelaxTime', 1e-9);

    % create geometry
    CSX = AddBox(CSX, 'drude_example', 10, start, stop);

Calculation
'''''''''''''

:func:`CalcDrudeMaterial` is a helper function to calculate the numerical values of
permittivity at specified frequency points in an array. It's useful for fitting
material parameters for simulation preparation as part of a numerical optimization
routine.

Definition::

    eps_drude = CalcDrudeMaterial(f, eps_r, kappa, plasmaFreq, t_relax)

Parameters:

* ``f``: (vector) Frequency points of interest.
* ``eps_r``: Relative permittivity when frequency approaches infinity
  (:math:`\epsilon_{r,\infty}`).
* ``kappa``: Electric conductivity, an ohmic loss term
  (:math:`\kappa`).
* ``plasmaFreq``: (vector) Plasma frequencies in hertz
  (:math:`f_p`)
* ``t_relax``: (vector) Relaxation time, the inverse of damping factor, a dissipative term
  (:math:`\tau_\mathrm{relax}`).

Since the Drude model can fit both dielectric and magnetic materials with the same formula,
this function can be used to calculate permeability as well by symmetry - reinterpreting all
inputs as permeability parameters.

Example::

    % silver (AG) at optical frequencies (Drude model)
    f = linspace(300e12, 1100e12, 201);
    eps_model = CalcDrudeMaterial(f, 3.942, 7.97e3, 7e15/2/pi, 0, 1/2.3e13);
    
    figure
    plot(f,real(eps_model))
    hold on;
    grid on;
    plot(f,imag(eps_model),'r--')

Lorentz Model
""""""""""""""

Usage
''''''

:func:`AddLorentzMaterial` creates a material governed by the Lorentz
model::

    CSX = AddLorentzMaterial(CSX, name, varargin)

The Lorentz model is defined by all Drude parameters as previously
described, and two additional Lorentz parameters.

* ``f_eps_Lor_Pole_n``:  Electric Lorentz pole frequency in hertz
  (:math:`f_{\mathrm{Lor}\epsilon}`).
* ``f_mue_Lor_Pole_n``:  Magnetic Lorentz pole frequency in hertz
  (:math:`f_{\mathrm{Lor}\mu}`).

If the material is non-magnetic, ``f_mue_Lor_Pole_n`` is optional.

For the single-term model, use one set of parameters (i.e. ``f_eps_Lor_Pole``)
without suffix ``_n``. For higher-order modeling, add more parameters with increasing
indices in their suffixes `n` (e.g. ``f_mue_Lor_Pole_1``, ``f_mue_Lor_Pole_2``, ...)

Calculation
'''''''''''''

:func:`CalcLorentzMaterial` is a helper function to calculate the numerical values of
permittivity at specified frequency points in an array. It's useful for fitting
material parameters for simulation preparation as part of a numerical optimization
routine.

Definition::

    eps_lorentz = CalcLorentzMaterial(f, eps_r, kappa, plasmaFreq, LorPoleFreq, t_relax)

Parameters:

* ``f``: (vector) Frequency points of interest.
* ``eps_r``: Relative permittivity when frequency approaches infinity
  (:math:`\epsilon_{r,\infty}`).
* ``kappa``: Electric conductivity, an ohmic loss term
  (:math:`\kappa`).
* ``plasmaFreq``: (vector) Plasma frequencies in hertz
  (:math:`f_p`)
* ``LorPoleFreq``: (vector) Lorentz pole frequencies in hertz
  (:math:`f_{\mathrm{Lor}\epsilon}`). If zeroed, Lorentz model reduces to Drude model.
* ``t_relax``: (vector) Relaxation time, the inverse of damping factor, a dissipative term
  (:math:`\tau_\mathrm{relax}`).

Since the Lorentz model can fit both dielectric and magnetic materials with the same formula,
it can be used to calculate permeability as well by reinterpreting all inputs as permeability
parameters.

Example::

    % silver (AG) at optical frequencies (Drude+Lorentz model)
    f = linspace(300e12, 1100e12, 201);
    eps_model = CalcLorentzMaterial(f, 1.138, 4.04e3, [13e15 9.61e15]/2/pi, [0 7.5e15]/2/pi,[1/2.59e13 1/3e14]);
    
    figure
    plot(f,real(eps_model))
    hold on;
    grid on;
    plot(f,imag(eps_model),'r--')

Math Notes
------------

Debye Model
""""""""""""

The Debye model of dielectric relaxation (not to be confused with
Debye model of specific heat) is defined by the following equation
( [1]_, page 222, equation 37; [3]_, page 354, equation 9.3; [4]_,
page 294, equation 10.27):

.. math::
   \epsilon(\omega) = \epsilon_0 \left[ \epsilon_{r,\infty} +
                   \sum^N_{n=1}{\frac{\Delta \epsilon_{r}(n)}{1+ j \omega t_\mathrm{relax}(n)}} \right]
                   - j \frac{\kappa}{\omega}

where:

* :math:`n` is the index of the higher-order model term being evaluated.
* :math:`N` is the number of model terms in total.
* :math:`\omega = 2\pi f` is the angular frequency.
* :math:`\epsilon(\omega)` is the material's permittivity.
* :math:`\epsilon_0` is the vacuum permittivity.
* :math:`\epsilon_{r,\infty}` is the material's relative permittivity
  at :math:`f \to \infty`.
* :math:`\kappa` is the material's electric conductivity.

  * Note that electric conductivity :math:`\kappa` is
    not to be confused with material permittivity, which is sometimes
    also denoted by :math:`\kappa` in the literature.

* :math:`\Delta \epsilon_{r}(n)` is the n-th oscillator strength.
* :math:`t_\mathrm{relax}(n)` is the n-th relaxation time (inverse of
  the damping factor).

This model is only implemented for dielectric materials, not magnetic
materials.

Drude Model
""""""""""""

The Drude model of dielectric and magnetic materials is defined
by the following equations ( [1]_, page 220, equation 27, 28):

.. math::
   \begin{align}
   \epsilon(\omega) = \epsilon_0 \epsilon_{r,\infty} &\left[ 1 - \sum_{n=1}^{N}
   \frac{\omega^{2}_{p\epsilon}(n)}{\omega^2 - j \omega \frac{1}{\tau_{\epsilon}(n)}} \right]
   - j \frac{\kappa}{\omega} \\
   \mu(\omega) = \mu_0 \mu_{r,\infty} &\left[ 1 - \sum_{n=1}^{N}
   \frac{\omega^{2}_{p\mu}(n)}{\omega^2 - j \omega \frac{1}{\tau_{\mu}(n)}} \right]
   - j \frac{\sigma}{\omega}
   \end{align}

where:

* :math:`n` is the index of the higher-order model term being evaluated.
* :math:`N` is the number of model terms in total.
* :math:`\omega = 2\pi f` is the angular frequency.
* :math:`\omega_\mathrm{p\epsilon}(n)` is
  the material's n-th electric plasma frequency.
* :math:`\tau_\epsilon(n)` is the n-th
  electric relaxation time (inverse of the damping factor).
* :math:`\epsilon(\omega)` is the material's permittivity.
* :math:`\epsilon_0` is the vacuum permittivity.
* :math:`\epsilon_{r,\infty}` is the material's relative permittivity
  at :math:`f \to \infty`.
* :math:`\kappa` is the material's electric conductivity.

  * Note that electric conductivity :math:`\kappa` is
    not to be confused with material permittivity, which is sometimes
    also denoted by :math:`\kappa` in the literature.

Analogously, the Drude model of magnetic materials is defined by a
substitution of variables. 

* :math:`\omega_\mathrm{p\mu}(n)` is
  the material's n-th magnetic plasma frequency.
* :math:`\tau_\mu(n)` is the n-th magnetic relaxation time
  (inverse of the damping factor).
* :math:`\mu(\omega)` is the material's permeability.
* :math:`\mu_{r,\infty}` is the material's relative
  permeability at :math:`f \to \infty`.
* :math:`\sigma` is the material's magnetic conductivity. It's a
  non-physical property due to a hypothetical magnetic current.
  In most formulations, :math:`\sigma = 0`. In openEMS, this term
  is optional but useful to improve fitting by introducing
  artificial losses.

Lorentz Model
"""""""""""""

The Lorentz model of dielectric and magnetic materials is defined
by the following equations:

.. math::
   \begin{align}
   \epsilon(\omega) = \epsilon_0 \epsilon_{r,\infty} &\left[ 1 - \sum_{n=1}^{N}
   \frac{\omega^{2}_{p\epsilon}(n)}{\omega^2 -\omega^2_\mathrm{Lor\epsilon}(n) - j \omega \frac{1}{\tau_{\epsilon}(n)}} \right] -
   j \frac{\kappa}{\omega} \\
   \mu(\omega) = \mu_0 \mu_{r,\infty} &\left[ 1 - \sum_{n=1}^{N}
   \frac{\omega^{2}_{p\mu}(n)}{\omega^2 -\omega^2_\mathrm{Lor\mu}(n) - j \omega \frac{1}{\tau_{\mu}(n)}} \right] -
   j \frac{\sigma}{\omega} \\
   \end{align}

where :math:`f_\mathrm{\mathrm{Lor}\epsilon}(n)` and
:math:`f_\mathrm{\mathrm{Lor}\mu}(n)` are the material's
n-th electric and magnetic Lorentz pole frequencies. Zeroing
these terms reduces the Lorentz model to the Drude model.

Other definitions are identical to the Drude model.

Relation to Other Formulations
""""""""""""""""""""""""""""""""

The Drude/Lorentz formulation used by openEMS is not identical
to the common formulations found in textbooks and the literature.
In fact, many different variations are in use due to their flexibility.
They can be formulated as single-term or multi-term models,
with or without the conductivity term, with or
without the asymptotic term, with different definitions of the
asymptotic terms, and with different symbols and sign conventions.

Thus, it's necessary to clarify the relationship between openEMS's
formulation with other textbooks to understand how these differences
arise.

This section is not exhaustive due to the numerous possible
combinations of the mentioned factors. However, after reading
this section, readers will hopefully understand how to rewrite
one formulation to another by simple algebra.

Single-Term Lorentz Model
''''''''''''''''''''''''''

When there's only one term, these models reduces to their single-term form. For
example, the single-term Lorentz model of dielectric materials is defined by:

.. math::
   \epsilon(\omega) = \epsilon_0 \epsilon_{r,\infty} \left[ 1 -
   \frac{\omega^{2}_{p\epsilon}}{\omega^2 - \omega^2_\mathrm{Lor\mu} - j \omega \frac{1}{\tau_{\epsilon}}} \right]
   - j \frac{\kappa}{\omega}

Single-Term Drude Model
'''''''''''''''''''''''''

When the Lorentz pole frequency term :math:`\omega^2_\mathrm{Lor\mu} = 0`,
the Lorentz model reduces to the Drude model. For example, the single-term
Drude model of dielectric materials is defined by:

.. math::
   \epsilon(\omega) = \epsilon_0 \epsilon_{r,\infty} \left[ 1 -
   \frac{\omega^{2}_{p\epsilon}}{\omega^2 - j \omega \frac{1}{\tau_{\epsilon}}} \right]
   - j \frac{\kappa}{\omega}

Single-Term Drude Model w/o Asymptotic and Conductivity Terms
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

The openEMS's Drude model contains a conductivity term :math:`\kappa`.
For non-conductive material, the single-term Drude model reduces to:

.. math::
   \epsilon(\omega) = \epsilon_0 \epsilon_{r,\infty} \left[ 1 -
   \frac{\omega^{2}_{p\epsilon}}{\omega^2 - j \omega \frac{1}{\tau_{\epsilon}}} \right]

This formulation is consistent with [3]_ page 355, equation 9.9;
[4]_ page 292, equation 10.17.

At high frequencies, a material's relative permittivity decreases, but
never to exactly 1. This residue effect is captured by the asymptotic term
:math:`\epsilon_{r,\infty}`. Without the asymptotic term, the Drude model
reduces to:

.. math::
   \epsilon(\omega) = \epsilon_0 \left[ 1 -
   \frac{\omega^{2}_{p\epsilon}}{\omega^2 - j \omega \frac{1}{\tau_{\epsilon}}} \right]

Oscillator Strength Term Definitions
''''''''''''''''''''''''''''''''''''''

There's a common parameter :math:`\Delta \epsilon_{r}` that appears
in all three models.
It's understood as the different between the electrostatic
relative permittivity and the infinite-frequency permittivity ( [3]_,
page 254, equation 9.2).

.. math::
   \Delta \epsilon_{r} = \epsilon_{r,\mathrm{static}} - \epsilon_{r,\infty}

In solid-state physics, it has the physical meaning that ( [5]_,
page 32, equation 2.19):

.. math::
   \Delta \epsilon_{r} = \frac{N e^2}{\epsilon_0 m_0 \omega_0^2}

where :math:`N` is the numeber of atoms per unit volume, :math:`e` is
the electron charge, :math:`\epsilon_0` is the vacuum permittivity,
:math:`m_0` is the electron mass, :math:`\omega_0` is the natural
frequency of the atoms.

However, in material modeling and simulation rather than solid-state
physics, :math:`\Delta \epsilon_{r}` is used as a fitting parameter
and does not represent physical processes at the atomic level.

Relaxation Time Definitions
'''''''''''''''''''''''''''

Taflove's formulation of the single-term Lorentz model
is ( [3]_, page 355, equation 9.6):

.. math::
   \epsilon_r(\omega) = \epsilon_{r,\infty} + \Delta \epsilon_r \frac{\omega_p^2}{\omega^2_p + 2j\omega\delta_p-\omega^2}

where :math:`\epsilon_p` is the frequency of the pole pair (the undamped resonant
frequency of the medium), :math:`\delta_p` is the damping coefficient.
In comparison, openEMS absorbs the constant term 2 into the time constant
:math:`\tau_p = \frac{1}{2\delta_p}`.

After algebraic manipulations, we obtain the following equation.

.. math::
   \begin{align}
   \epsilon_r(\omega) &= \epsilon_{r,\infty} + \Delta \epsilon_r \frac{\omega_p^2}{\omega^2_p + j\omega\frac{1}{\tau_p}-\omega^2} \left( \frac{-1}{-1} \right) \\
   &= \epsilon_{r,\infty} + \Delta \epsilon_r \frac{\omega_p^2}{\omega^2 -\omega^2_p - j\omega\frac{1}{\tau_p}}
   \end{align}

This is the standard textbook Lorentz model, rewritten with variable definitions
similar to those used in openEMS. However, in addition to the
time constant definition, textbooks also define the asymptotic term differently.
See the next section.

Asymptotic Term Definitions
''''''''''''''''''''''''''''

The formulation of Drude and Lorentz models are slightly different in
comparison to the forms in standard textbooks, due to how the asymptotic
term is defined. In most textbooks, the single-term Lorentz model
(without the conductivity term) is defined as ( [3]_, page 355, equation 9.6;
[4]_, page 293, equation 10.25):

.. math::

   \begin{align}
   \epsilon(\omega)_\mathrm{book} &= \epsilon_0 \left[ \epsilon_{r,\infty} - \Delta \epsilon_r
   \frac{\omega^{2}_{p\epsilon\mathrm{(book)}}}{\omega^2 - \omega^2_{\mathrm{Lor}\epsilon} - j \omega \frac{1}{\tau_{\epsilon}(n)}} \right] \\
   &= \epsilon_0 \epsilon_{r,\infty} - \epsilon_0 \Delta \epsilon_r
   \frac{\omega^{2}_{p\epsilon\mathrm{(book)}}}{\omega^2 - \omega^2_{\mathrm{Lor}\epsilon} - j \omega \frac{1}{\tau_{\epsilon}(n)}}
   \end{align}

But openEMS follows Rennings's formulation and defines it as
( [1]_, page 235, equation 58, 59):

.. math::
   \begin{align}
   \epsilon(\omega)_\mathrm{openEMS} &= \epsilon_0 \epsilon_{r,\infty} \left[ 1 -
   \frac{\omega^{2}_{p\epsilon\mathrm{(openEMS)}}}{\omega^2 -\omega^2_\mathrm{Lor\epsilon} - j \omega \frac{1}{\tau_{\epsilon}}} \right] \\
   &= \epsilon_0 \epsilon_{r,\infty} - \epsilon_0 \epsilon_{r,\infty}
   \frac{\omega^{2}_{p\epsilon\mathrm{(openEMS)}}}{\omega^2 -\omega^2_{\mathrm{Lor}\epsilon} -
   j \omega \frac{1}{\tau_{\epsilon}}}
   \end{align}

The textbook formulation contains two free parameters :math:`\Delta \epsilon_r` and
:math:`\epsilon_{r,\infty}`, but openEMS only uses :math:`\epsilon_{r,\infty}`.
The :math:`\Delta \epsilon_r` term is implicitly absorbed into
:math:`\omega^{2}_{p\epsilon}`. To convert the textbook
formulation to openEMS's formulation, the plasma frequency must be redefined:

.. math::

   \omega_{p\epsilon\mathrm{(openEMS)}} =
    \omega_{p\epsilon\mathrm{(book)}}
    \sqrt{\frac{\Delta \epsilon_r}{\epsilon_{r,\infty}}}

Sign Conventions
'''''''''''''''''''

Researchers in physics often adopt a different sign convention, in which they
use :math:`e^{-j\omega t}` for time-harmonic quantities rather than
:math:`e^{j \omega t}` in engineering.

Example: Taflove's Drude Model Formulation
...........................................

The second edition of Taflove's book defines the Drude model in
physics convention, as ( [2]_, page 230, equation 9.9a):

.. math::
   \begin{align}
   \chi(\omega) &= - \frac{\omega_p^2}{\omega^2 + j\omega\gamma}
   \end{align}

In the third edition, it's redefined in engineering convention,
for consistency ( [3]_, page 354, equation 9.1):

.. math::
   \begin{align}
   \chi(\omega) = - \frac{\omega_p^2}{\omega^2 - j'\omega\gamma}
   \end{align}

These two equations are the same equation, where:

* :math:`j' = -j` due to the sign convention difference.
* :math:`\gamma = 1/\tau_p` is the damping factor, which is the inverse of
  pole relaxation time. It's
  sometimes also denoted as the collision frequency of electrons :math:`\nu_e`
  in the context of physics.

From the relationship between electric susceptibility and permittivity,
without the asymptotic term:

.. math::
   \begin{align}
   \epsilon(\omega) = \epsilon_0 \left[ 1 + \chi(\omega) \right]
                    &= \epsilon_0 \left[ 1 - \frac{\omega_p^2}{\omega^2 - j'\omega\gamma} \right] \\
                    &= \epsilon_0 \left[ 1 - \frac{\omega_p^2}{\omega^2 - j'\omega\frac{1}{\tau_p}} \right]
   \end{align}

This is our single-term Drude model without asymptotic and conductivity
terms, which matching the description above. Introducing both additional
terms according to the aforementioned procedure would reproduce the exact
openEMS equations.

Example: Fox's Lorentz Model Formulation
.........................................

The textbook *Optical Properties of Solids* by Mark Fox defines the
Lorentz model as ( [5]_, page 36, equation 2.24):

.. math::
   \epsilon_r(\omega) = 1 + \Delta \epsilon_r \frac{f_j}{\omega_0^2-\omega^2-j\omega\gamma}

where :math:`\omega_0` is the plasmonic resonant frequency, :math:`f_j` is
a phenomenological oscillator strength parameter (used together with
:math:`\Delta \epsilon_r`).

This equation uses the opposite sign convention in comparison to
most engineering books. By substituting :math:`j' = -j`, :math:`\gamma = 1/\tau_p`,
:math:`f_j = \omega_p^2`
and multiplying by :math:`\frac{-1}{-1}`, we obtain:

.. math::
   \begin{align}
   \epsilon_r(\omega) &= 1 + \Delta \epsilon_r \frac{f_j}{\omega_0^2-\omega^2+j'\omega\gamma} \cdot \left( \frac{-1}{-1} \right) \\
   \epsilon_r(\omega) &= 1 - \Delta \epsilon_r \frac{\omega_p^2}{\omega^2-\omega_0^2-j'\omega \frac{1}{\tau_p}} \\
   \end{align}

This is our single-term Lorentz model without asymptotic and conductivity
terms, which matching the description above. Introducing both additional
terms according to the aforementioned procedure would reproduce the exact
openEMS equations.

Bibliography
---------------

.. [1] Andreas Rennings, et, al.,
   `Equivalent Circuit (EC) FDTD Method for Dispersive Materials: Derivation,
   Stability Criteria and Application Examples
   <https://www.researchgate.net/publication/227133697_Equivalent_Circuit_EC_FDTD_Method_for_Dispersive_Materials_Derivation_Stability_Criteria_and_Application_Examples>`_, Time Domain Methods in Electrodynamics.

.. [2] Allen Taflove, Susan. C. Hagness,
   Computational Electrodynamics: The Finite-Difference Time-Domain Method, 2nd ed. Artech House, 1995.

.. [3] Allen Taflove, Susan. C. Hagness,
   Computational Electrodynamics: The Finite-Difference Time-Domain Method, 3rd ed. Artech House, 2005.

.. [4] John B. Schneider. `Understanding the FDTD Method. <https://eecs.wsu.edu/~schneidj/ufdtd/index.php>`_

.. [5] Mark Fox, Optical Properties of Solids. Oxford, UK: Oxford University Press, 2001.

.. [6] Djordjevic, Antonije R., et al., `Wideband frequency-domain characterization of FR-4
   and time-domain causality
   <https://web.archive.org/web/20250319102138/https://mtt.etf.bg.ac.rs/Mikrotalasna.Tehnika/Clanci/FR4_EMC_2001.pdf>`_,
   IEEE Transactions on Electromagnetic Compatibility 43.4 (2001): 662–667.
