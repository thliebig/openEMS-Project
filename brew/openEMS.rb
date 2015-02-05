require "formula"

class Openems < Formula
  homepage "http://openems.de"

  head do
    url "https://github.com/thliebig/openEMS-Project.git"
  end

  depends_on "cmake" => :build
  depends_on "flex"
  depends_on "bison"
  depends_on "qt"
  depends_on "tinyxml"
  depends_on "vtk" => ["with-qt", "c++11"]
  depends_on "cgal" => "c++11"
  depends_on "boost" => "c++11"

  def install
    system "cmake", ".", *std_cmake_args
    system "make" 
    # install is handled by ExternalProject_Add
  end

end

