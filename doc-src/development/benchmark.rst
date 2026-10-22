.. _benchmark:

Speed Benchmark
===============

openEMS ships a small speed benchmark in ``openEMS/benchmark/``: five cases
that each isolate one cost of the solver — the bare update kernel, the PML,
an inhomogeneous model with a graded mesh and lumped ports, dispersive
materials and a cylindrical mesh — at a size that fits largely in
the CPU cache (S, ~1 M cells) and one that is limited by the memory bandwidth
(M, ~8 M cells). It needs the openEMS and CSXCAD Python modules.

.. code-block:: console

    python3 openEMS/benchmark/bench.py run

times the ``openEMS`` in ``PATH`` with the multithreaded engine on the
physical cores, plus the GPU engine if a GPU is available, and prints the
speed in million cells per second, the setup time and the memory per case.
Every run does 3 s of time-stepping (``--duration``), whatever the engine.
``--openems PATH`` times another build, ``--size``, ``--cases``,
``--engine`` and ``--threads`` select what runs.

Comparing builds
----------------

Given two binaries, the benchmark runs them interleaved, so that changes of
the CPU clock or background load hit both alike, and compares their speed
and their probe results:

.. code-block:: console

    python3 openEMS/benchmark/bench.py run --openems ~/opt/master/bin/openEMS --label master \
                                           --openems ~/opt/branch/bin/openEMS --label branch

``bench.py compare base.json other.json`` compares two separately recorded
results, also from different machines.

A pull request that claims a speed-up includes this comparison of master
against the branch. The options, the columns of the table and the cases
are described in
`benchmark/README.md <https://github.com/thliebig/openEMS/blob/master/benchmark/README.md>`_.
