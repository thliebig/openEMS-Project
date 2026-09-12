
## usage: cmake -DCMAKE_INSTALL_PREFIX=<install/path> .
## use -DBUILD_APPCSXCAD=NO to not build QCSXCAD and AppCSXCAD

# In CMake 4, 3.10 is deprecated and 3.5 has been removed.
# use 3.0...3.10 so all of these versions are acceptable as min. version.
# https://cmake.org/cmake/help/latest/command/cmake_minimum_required.html
cmake_minimum_required(VERSION 3.0...3.10)

PROJECT(openEMS-Project CXX)

if (CMAKE_TOOLCHAIN_FILE)
    message(STATUS "Using CMAKE_TOOLCHAIN_FILE: " ${CMAKE_TOOLCHAIN_FILE})
endif()

if (CMAKE_INSTALL_PREFIX)
    message(STATUS "Using CMAKE_INSTALL_PREFIX: " ${CMAKE_INSTALL_PREFIX})
endif()

if (NOT DEFINED BUILD_APPCSXCAD)
    set(BUILD_APPCSXCAD "YES")
endif()

message(STATUS "Build AppCSXCAD: " ${BUILD_APPCSXCAD})

IF(EXISTS ${PROJECT_SOURCE_DIR}/localConfig.cmake)
   message(STATUS "include local config" )
   include(${PROJECT_SOURCE_DIR}/localConfig.cmake)
ENDIF()

include(ExternalProject)

# build fparser
ExternalProject_Add( fparser
  SOURCE_DIR  ${PROJECT_SOURCE_DIR}/fparser
  CMAKE_ARGS -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
)

# dynamically locate vtk directories

# check if a user explicitly passed a path via command line first
if(NOT VTK_SEARCH_DIR AND DEFINED PARAVIEW_VTK_DIR)
  set(VTK_SEARCH_DIR "${PARAVIEW_VTK_DIR}")
endif()

# if still not found, use cmake's native package finder
if(NOT VTK_SEARCH_DIR)
  # look for vtk quietly, this respects CMAKE_PREFIX_PATH and CONDA_PREFIX automatically.
  find_package(VTK QUIET)
  if(VTK_FOUND)
    set(VTK_SEARCH_DIR "${VTK_DIR}")
  else()
    # fallback to checking paraview's embedded vtk
    find_package(ParaView QUIET)
    if(PARAVIEW_FOUND AND DEFINED PARAVIEW_VTK_DIR)
      set(VTK_SEARCH_DIR "${PARAVIEW_VTK_DIR}")
    endif()
  endif()
endif()

# fallback: broad, true recursive glob if find_package fails
if(NOT VTK_SEARCH_DIR)
  set(BASE_SEARCH_PATHS "/usr" "/usr/local")
  if(DEFINED ENV{CONDA_PREFIX})
    list(INSERT BASE_SEARCH_PATHS 0 "$ENV{CONDA_PREFIX}")
  endif()

  foreach(base_dir ${BASE_SEARCH_PATHS})
    if(IS_DIRECTORY "${base_dir}")
      # Use a genuine, non-restrictive recursive wildcard match
      file(GLOB_RECURSE detected_configs FOLLOW_SYMLINKS "${base_dir}/*VTKConfig.cmake")

      if(detected_configs)
        list(GET detected_configs 0 first_match)
        get_filename_component(VTK_SEARCH_DIR "${first_match}" DIRECTORY)
        break()
      endif()
    endif()
  endforeach()
endif()

# validate
if(VTK_SEARCH_DIR)
  message(STATUS "Auto-detected VTK directory for subprojects: ${VTK_SEARCH_DIR}")
else()
  message(FATAL_ERROR "Could not automatically resolve VTKConfig.cmake pathway inside conda or system paths.")
endif()

# build CSXCAD and pass the dynamically resolved VTK directory
ExternalProject_Add( CSXCAD 
  DEPENDS     fparser
  SOURCE_DIR  ${PROJECT_SOURCE_DIR}/CSXCAD
  CMAKE_ARGS  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} -DFPARSER_ROOT_DIR=${CMAKE_INSTALL_PREFIX} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DVTK_DIR:PATH=${VTK_SEARCH_DIR} INSTALL_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --target install
)

message(STATUS "with MPI: ${WITH_MPI}" )
# build openEMS and pass the dynamically resolved VTK directory
ExternalProject_Add( openEMS
  DEPENDS     fparser CSXCAD
  SOURCE_DIR  ${PROJECT_SOURCE_DIR}/openEMS
  CMAKE_ARGS  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} -DFPARSER_ROOT_DIR=${CMAKE_INSTALL_PREFIX} -DCSXCAD_ROOT_DIR=${CMAKE_INSTALL_PREFIX} -DWITH_MPI=${WITH_MPI} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} -DVTK_DIR:PATH=${VTK_SEARCH_DIR} INSTALL_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --target install
)

if (${BUILD_APPCSXCAD})
    # build QCSXCAD
    ExternalProject_Add( QCSXCAD
    DEPENDS     CSXCAD
    SOURCE_DIR  ${PROJECT_SOURCE_DIR}/QCSXCAD
    CMAKE_ARGS  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} -DCSXCAD_ROOT_DIR=${CMAKE_INSTALL_PREFIX} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    )

    # build AppCSXCAD
    ExternalProject_Add( AppCSXCAD
    DEPENDS     QCSXCAD
    SOURCE_DIR  ${PROJECT_SOURCE_DIR}/AppCSXCAD
    CMAKE_ARGS  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} -DCSXCAD_ROOT_DIR=${CMAKE_INSTALL_PREFIX} -DQCSXCAD_ROOT_DIR=${CMAKE_INSTALL_PREFIX} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    )
endif()
