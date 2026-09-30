Learn More
=============

Questions and Community
---------------------------

If you have any question on the use of openEMS, you can post a thread at GitHub
Discussion:

* https://github.com/thliebig/openEMS-Project/discussions

Additional community resources and legacy documentation can be found on the
openEMS wiki:

* https://wiki.openems.de/index.php/Main_Page.html

FDTD
---------

If you're new to FDTD, the following university-level textbooks provide a good
general introduction to the FDTD method:

* John B. Schneider (2010). Understanding the FDTD Method. available online. http://eecs.wsu.edu/~schneidj/ufdtd/index.php

* Allen Taflove; Susan C. Hagness (2005). Computational Electrodynamics: The Finite-Difference Time-Domain Method, 3rd ed. Artech House Publishers. ISBN 978-1-58053-832-9.

* Karl S. Kunz; Raymond J. Luebbers (1993). The Finite Difference Time Domain Method for Electromagnetics. CRC Press. ISBN 978-0-8493-8657-2.

* Wenhua Yu; Raj Mittra; Tao Su; Yongjun Liu; Xiaoling Yang (2006). Parallel Finite-Difference Time-Domain Method. Artech House Publishers. ISBN 978-1-59693-085-8.

openEMS
---------

The papers describing openEMS itself, and a collection of published work that
uses it, are on the :ref:`publications_src` page.

.. _third_party_tools:

Third-Party Modeling Tools
--------------------------

In principle, it's feasible to make or tweak a 3D model using the
:program:`AppCSXCAD` GUI. Geometries and mesh lines can be added
entirely by the GUI, which are then saved and read into Python later
via :meth:`~CSXCAD.ContinuousStructure.ReadFromXML` with additional
initialization and tweaks for simulations. Likewise, saving and
reloading makes it possible to tune a script-generated 3D model in
the :program:`AppCSXCAD` GUI.

This technique circumvents programmatic modeling
(as described in :ref:`concept_primitives`) entirely. However,
it has not been put in use by anyone to our best knowledge, possibly
because it's not a coherent method.
On the other hand, there are numerous attempts over the years
to create models using GUI-based or high-level tools, to varying
degrees of success.

The first general idea is to create the structure first in a
general-purpose CAD like FreeCAD. This can then be exported as
a 3D model and be loaded into CSXCAD via :func:`ImportSTL` for
simulation. By editing the CSXCAD object further, ports and
probes can also be modeled via a GUI.

The second general idea, specific to planar circuits and circuit
board simulations, is to first create the circuit board using an
EDA tool such as gEDA, pcb-rnd, or KiCad. The circuit layout
can then be exported as a 2D vector image format, such as
HyperLynx, Gerber, SVG or PDF. The polygons in these images
are then extracted and imported as CSXCAD polygons.

The third general idea is to create a high-level programming
library for defining high-level objects such as traces, vias,
circuit board layers, so that they can be created one object
at a time, rather than one polygon at a time.

A common subgoal of all tools is an automatic meshing algorithm,
which turned out to be far from straightforward. CSXCAD models
are usually designed as highly simplified test cases to check
specific design parameters. In manual modeling, geometries and
meshing are co-designed to simplify each other. However, automatic
meshing algorithms deal with arbitrary models imported by users,
a more difficult problem.

.. important::
   **Third-Party Tools.** These tools are developed by third
   parties, and not officially supported by the openEMS project.
   Most of them are highly experimental and incomplete.
   They're described here for completeness. The project forum
   is also open to the discussions of their uses.

   **Importing is easy, simulation is hard.** These tools
   should be considered advanced applications. Beginners are
   *not recommended* to try them before familiarizing themselves
   with the CSXCAD/openEMS workflow first via basic simulations,
   as described in the :ref:`tutorials`.
   Trying to import a circuit board without understanding the
   concept of ports, boundary conditions or meshing rules leads
   to failures, especially when most of these tools are highly
   experimental and incomplete.

   **Don't work in isolation.** So far there are already 7 different
   tools that attempt to automate modeling of circuit boards and
   3D objects for openEMS. Instead of creating another one from
   scratch, it's probably a good idea to have a discussion with
   the authors of these existing tools.

Examples of these tools include:

* :program:`OpenEMSH`, developed by Thomas Lepoix.

  * The next-generation automatic mesher for openEMS simulations,
    with funding from NLnet. It aims to overcome the difficulties
    encountered by all previous projects, but it's still in the
    early-development stage.

  * https://github.com/Open-RFlab/openemsh

* :program:`Qucs-RFlayout`, developed by Thomas Lepoix.

  * Convert planar microwave circuit schematics created in the Qucs RF
    circuit simulator to KiCad layouts and openEMS models.

  * https://github.com/thomaslepoix/Qucs-RFlayout

* :program:`FreeCAD-OpenEMS-Export`, developed by Lubomir Jagos.

  * FreeCAD-based model and port edits, with CSXCAD export.

  * https://github.com/LubomirJagos/FreeCAD-OpenEMS-Export

* :program:`IntuitionRF`, developed by Juleinn.

  * It allows one to mesh structures interactively via Blender.

  * https://github.com/Juleinn/IntuitionRF

* :program:`pcb2csx`, developed by Evan Foss.

  * It's a plugin to the EDA tool :program:`pcb-rnd`,
    allowing one to export an existing circuit board layout to CSXCAD.

  * http://repo.hu/cgi-bin/pool.cgi?project=pcb-rnd&cmd=show&node=s_param

  * Tutorial: `Direct Path to openEMS for S-parameters
    <http://repo.hu/cgi-bin/pool.cgi?project=pcb-rnd&cmd=show&node=s_param>`_

* :program:`gerber2ems`, developed by Antmicro.

  * It allows one to export an existing PCB layout as a Gerber file,
    which can then be converted and imported as a CSXCAD model.

  * https://github.com/antmicro/gerber2ems

* :program:`pcbmodelgen`, developed by jcyrax.

  * It converts a KiCad layout file into the CSXCAD model,
    also with experimental auto-meshing support.

  * https://github.com/jcyrax/pcbmodelgen

* :program:`pyems`, developed by Matt Huszagh.

  * It's a high-level Python interface to openEMS, which allows
    the programmatic creation of high-level structures such as
    circuit boards, traces, vias, PCB layers. It has also an
    experimental auto-mesh generation algorithm.

  * https://github.com/matthuszagh/pyems

* :program:`hyp2mat`, developed by Koen De Vleeschauwer and
  distributed officially as part of openEMS.

  * It converts a
    HyperLynx layout file (can be generated by PCB EDA tools,
    including EAGLE or KiCad 6). The geometries are extracted
    to generate an Octave script with commands to create
    the CSXCAD model.

  * In principle, it can be used with Python
    as well, by exporting the model to XML in Octave via
    :func:`WriteOpenEMS`, and importing the model via
    :meth:`~CSXCAD.ContinuousStructure.ReadFromXML`. But
    no one has tested it.

  * Currently it's retired and no longer maintained.

  * https://github.com/koendv/hyp2mat

Developer Notes
"""""""""""""""""

The old project wiki also described this following idea to
convert circuit board layouts from Gerber, PDF, DXF, or
SVG into CSXCAD models. This idea may be of interest to
developers working on automated CSXCAD model generation.

.. note::

   PCB layers in Gerber files can be converted to PDF by means of
   gerber2pdf which can be found on Sourceforge (editor's note:
   native PDF, SVG and DXF exports are available in many EDA packages).
   The PDF can be imported into Inkscape just as it is the case
   for DXF files. Within Inkscape, the usually closed paths can be
   modified (either manually or with filters) such that they result
   in a suitable list of polygon nodes for openEMS.

   Sometimes these polygons or curves have too many nodes. The number
   of nodes can be reduced with the Inkscape function "Path" > "Simplify".
   The amount of reduction is controlled by the parameter "Simplification
   Threshold" which can be found under "Preferences" > "Behavior". These
   paths are still Bézier curves which must be converted into polygons.
   This is achieved with "Extensions" > "Modify Path" > "Flatten Béziers".
   The parameter in this dialog also controls the number of resulting
   points.

   When all nodes are as required, the paths can be exported as a HTML5
   Canvas. The resulting file can then be processed with an ASCII Editor.
   The numbers after the moveTo and lineTo statements are the polygon nodes
   X- and Y- coordinates respectively. However, they still must be
   transformed by a linear transform given in the transform statement. The
   first four numbers a matrix by which the node coordinates have to be
   multiplied and the remaining two numbers are a vector which has to
   be added.

   The result will be the node coordinates in HTML pixels with X counting
   from left to right and Y counting from top to bottom, which does not
   conform to the coordinate system of the Inkscape canvas.

   In order to have the same axes as in Inkscape (X left to right and Y
   bottom to top), the fourth and sixth number have to be multiplied by -1
   and the image height has to be added to the sixth number. Now the
   coordinates are in the usual coordinate system but still in HTML5 pixels.
   The ratio of pixels to mm or other units of length can finally be found
   under the document properties in Inkscape. This factor can be applied in
   Octave/Matlab. This finally gives polygons which can be processed by openEMS.
