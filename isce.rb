class Isce < Formula
  desc "Interferometric synthetic aperture radar Scientific Computing Environment (ISCE)"
  homepage "https://winsar.unavco.org/software/isce"
  url "https://github.com/isce-framework/isce2/archive/v2.3.1.tar.gz"
  sha256 "b46b9c5b590bdddb1cb4ae8e2777b6c4b6e52bfc8084595aee7e1774b6ffa69d"
  head "https://github.com/isce-framework/isce2.git"

  bottle do
    root_url "https://github.com/juribeparada/homebrew-isce/releases/download/bottles-isce"
    sha256 "858df62fee3281b8d9325d81e6a4b5232be4550b9bf483a84e3a90fdb5405f5b" => :mojave
  end

  depends_on "scons" => :build
  depends_on "python3"
  depends_on "gcc@8"
  depends_on "cython"
  depends_on "fftw"
  depends_on "gdal"
  depends_on "hdf5"
  depends_on "openmotif"
  depends_on "imagemagick"
  depends_on "grace"
  depends_on "mpfr"
  depends_on "mpc"
  depends_on "szip"
  depends_on "opencv"
  depends_on :x11

  def install
    ENV["SCONS_CONFIG_DIR"] = buildpath

    py_version = Language::Python.major_minor_version "python3"
    py_include = HOMEBREW_PREFIX/"Frameworks/Python.framework/Versions/#{py_version}/include/python#{py_version}m/"
    x11_inc = OS::Mac::XQuartz.include
    x11_lib = OS::Mac::XQuartz.lib

    system "pip3", "install", "numpy"
    system "pip3", "install", "cython"
    system "pip3", "install", "scipy"
    system "pip3", "install", "opencv-python"
    system "pip3", "install", "h5py"
    system "pip3", "install", "requests"
    system "pip3", "install", "matplotlib"

    # Generate scons configuration file
    config = <<~EOS
      PRJ_SCONS_BUILD = #{buildpath}/build
      PRJ_SCONS_INSTALL = #{prefix}

      CPPPATH = /usr/local/include/ #{x11_inc} #{py_include}
      LIBPATH = /usr/lib /usr/local/lib/ #{x11_lib}
      FORTRANPATH = /usr/local/include/

      FORTRAN = /usr/local/bin/gfortran-8
      CC = /usr/local/bin/gcc-8
      CXX = /usr/local/bin/g++-8

      X11INCPATH = #{x11_inc}
      X11LIBPATH = #{x11_lib}
      MOTIFINCPATH = /usr/local/include/
      MOTIFLIBPATH = /usr/local/lib/

      ENABLE_CUDA = False
      CUDA_TOOLKIT_PATH = /usr/local/cuda
    EOS

    # Write to SConfigISCE file
    Pathname("SConfigISCE").write config

    # Run builder tool
    system "scons"

    # Make ISCE applications symlinks
    bin.install_symlink Dir[prefix/"applications/*"]
  end

  def post_install
    homebrew_site_packages = Language::Python.homebrew_site_packages "python3"
    # Make isce symlink in site_packages
    homebrew_site_packages.install_symlink opt_prefix
  end
end
