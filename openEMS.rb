# Homebrew formula for installing on macOS

require "formula"

class Openems < Formula
  include Language::Python::Virtualenv

  desc "Electromagnetic field solver using the FDTD method"
  homepage "https://www.openems.de"

  head "https://github.com/thliebig/openEMS-Project.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "qt@6"
  depends_on "vtk"
  depends_on "tinyxml"
  depends_on "hdf5"
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "cgal"
  depends_on "boost"
  depends_on "python@3" => :recommended

  if build.with? "python@3"
    depends_on "numpy"
    depends_on "python-matplotlib"
    depends_on "python-setuptools"
  end

  def install
    
    ENV["SDKROOT"] = MacOS.sdk_path
    system "cmake", ".", *std_cmake_args
    system "make"
    # install is handled by ExternalProject_Add

    if build.with? "python@3"
      # Get python 3 sub-version we are currently using (3.x)
      python_version = Formula["python@3"].version.to_s.split(".")[0..1].join(".")
      python = "python#{python_version}"

      # Install non-bottled dependencies into a virtual environment
      venv = virtualenv_create(libexec, "python3")
      venv.pip_install "h5py"
      venv.pip_install "cython"

      # Create .pth file to reference packages in venv
      (lib/"#{python}/site-packages/homebrew-openems-dependencies.pth").write <<~EOS
        #{libexec}/lib/#{python}/site-packages
      EOS

      # Build and install bindings
      ENV.prepend_path "CXXFLAGS", "-std=c++14"
      cd "CSXCAD/python" do
        system venv.root/"bin/python3", "setup.py", "build_ext", "-I", include, "-L", lib, "-R", lib, "-j", ENV.make_jobs
        system venv.root/"bin/python3", *Language::Python.setup_install_args(prefix)
      end

      cd "openEMS/python" do
        system venv.root/"bin/python3", "setup.py", "build_ext", "-I", include, "-L", lib, "-R", lib, "-j", ENV.make_jobs
        system venv.root/"bin/python3", *Language::Python.setup_install_args(prefix)
      end
    end
  end

end

