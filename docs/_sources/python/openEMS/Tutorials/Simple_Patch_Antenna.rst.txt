.. _simple_patch_antenna:

Simple Patch Antenna
====================

Introduction
------------
A simple patch antenna for 2.4 GHz.

**This tutorial covers:**

* Setup a patch, substrate and ground.
* Setup of a lumped feeding port.
* Adding a near-field to far-field (nf2ff) recording box.
* Calculate the S-Parameter of the antenna.
* Calculate and plot the far-field pattern

Python Script
-------------
Get the latest version `from git <http://www.openems.de/gitweb/?p=openEMS.git;a=blob_plain;f=matlab/Tutorials/Simple_Patch_Antenna.m;hb=refs/heads/master>`_.

.. include:: ./__Simple_Patch_Antenna.txt

Images
------
.. figure:: images/Simp_Patch_S11.png
    :width: 49%
    :alt: S11 over Frequency
    
    S-Parameter over Frequency

.. figure:: images/Simp_Patch_Zin.png
    :width: 49%
    :alt: Input Impedance
    
    Antenna Input Impedance

.. figure:: images/Simp_Patch_Pattern.png
    :width: 49%
    :alt: Farfield pattern
    
    Farfield pattern for the  xy- and yz-plane.
