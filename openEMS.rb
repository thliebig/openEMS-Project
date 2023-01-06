# Homebrew formula for installing on macOS

require "formula"

class Openems < Formula
  desc "Electromagnetic field solver using the FDTD method"
  homepage "https://www.openems.de"

  head do
    url "https://github.com/thliebig/openEMS-Project.git"
  end

  depends_on "cmake" => :build
  depends_on "qt@5"
  depends_on "vtk"
  depends_on "tinyxml"
  depends_on "hdf5"
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "cgal"
  depends_on "boost"

  def install
    system "cmake", ".", *std_cmake_args
    system "make"
    # install is handled by ExternalProject_Add
  end

end

