# vcpkg triplet for the Windows package.
#
# Same as the built-in x64-windows-release triplet (dynamic CRT, dynamic
# libraries, release only), except that HDF5 is linked statically.
#
# The h5py wheels ship their own hdf5.dll inside site-packages, under exactly
# that name. Windows resolves a DLL import by base name against the modules
# already loaded in the process, so whichever HDF5 is loaded first serves
# everybody: importing CSXCAD loads ours, and h5py then binds to it. That only
# works while both are ABI compatible -- we follow vcpkg to HDF5 2.x while h5py
# is still on 1.14, so the import fails with "DLL load failed while importing
# defs: The specified procedure could not be found".
#
# Linking HDF5 into CSXCAD.dll/openEMS.dll keeps hdf5.dll out of the process
# entirely and leaves h5py with its own copy.
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_BUILD_TYPE release)
set(VCPKG_PROVIDED_FORTRAN ON)

if(PORT STREQUAL "hdf5")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()
