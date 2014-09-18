
PROJECT(openEMS-Project CXX)

cmake_minimum_required(VERSION 2.8)

#
# Set up RPATH for the project
#
option(ENABLE_RPATH "Enable rpath support on Linux and Mac" ON)
if(NOT CMAKE_INSTALL_RPATH)
  set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
endif()
if(APPLE AND NOT CMAKE_INSTALL_NAME_DIR)
  set(CMAKE_INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib")
endif()
if(UNIX AND ENABLE_RPATH)
  set(CMAKE_SKIP_BUILD_RPATH FALSE)
  set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
  set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
endif()


# TODO use CMake ExternalProjced to download/configure/build modules (replace update_openEMS.sh)

ADD_SUBDIRECTORY( fparser )
INCLUDE_DIRECTORIES ( fparser )

ADD_SUBDIRECTORY( CSXCAD )

ADD_SUBDIRECTORY( openEMS )

ADD_SUBDIRECTORY( QCSXCAD )

ADD_SUBDIRECTORY( AppCSXCAD )




