class IsceAT231 < Formula
  desc "Interferometric synthetic aperture radar Scientific Computing Environment (ISCE)"
  homepage "https://winsar.unavco.org/software/isce"
  url "https://github.com/isce-framework/isce2/archive/v2.3.1.tar.gz"
  sha256 "0ff07d8d86bab899b0855baabdb949eb7b0d5df8eef70a0a4c530c75ca033ad0"
  head "https://github.com/isce-framework/isce2.git"

  bottle do
    cellar :any_skip_relocation
    root_url "https://github.com/juribeparada/homebrew-isce/releases/download/bottles-isce"
    sha256 "572bfbbea4040f818256c35cada9069317790aa63eb992782efcf85a92233038" => :mojave
    sha256 "f0d98ecc0281620cd88978328da40f3d7c7e12ee12a4caed465b83bb5333edca" => :high_sierra
  end

  depends_on "scons" => :build
  depends_on "python3"
  depends_on "numpy"
  depends_on "scipy"
  depends_on "gcc@8"
  depends_on "fftw"
  depends_on "gdal"
  depends_on "hdf5"
  depends_on "openmotif"
  depends_on "imagemagick"
  depends_on "grace"
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "mpc"
  depends_on "szip"
  depends_on "opencv"
  depends_on :x11

  resource "Cython" do
    url "https://files.pythonhosted.org/packages/e0/31/4a166556f92c469d8291d4b03a187f325c773c330fffc1e798bf83d947f2/Cython-0.29.5.tar.gz"
    sha256 "9d5290d749099a8e446422adfb0aa2142c711284800fb1eb70f595101e32cbf1"
  end

  def install
    ENV["SCONS_CONFIG_DIR"] = buildpath

    gcc_lib = HOMEBREW_PREFIX/"opt/gcc/lib/gcc/9/"
    py_version = Language::Python.major_minor_version "python3"
    py_include = HOMEBREW_PREFIX/"Frameworks/Python.framework/Versions/#{py_version}/include/python#{py_version}m/"
    x11_inc = OS::Mac::XQuartz.include
    x11_lib = OS::Mac::XQuartz.lib

    resource("Cython").stage do
      system "python3", *Language::Python.setup_install_args(buildpath/"tools")
    end

    ENV.prepend_create_path "PYTHONPATH", buildpath/"tools/lib/python#{py_version}/site-packages"
    ENV.prepend_create_path "PATH", buildpath/"tools/bin"
    ln_sf buildpath/"tools/bin/cython", buildpath/"tools/bin/cython3"

    # Generate scons configuration file
    config = <<~EOS
      PRJ_SCONS_BUILD = #{buildpath}/build
      PRJ_SCONS_INSTALL = #{prefix}

      CPPPATH = /usr/local/include/ #{x11_inc} #{py_include}
      LIBPATH = #{gcc_lib} /usr/local/lib/ #{x11_lib}
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
    # Copy contrib/stack files into share folder
    share.install Dir[buildpath/"contrib/stack/*"]
    # Copy prepStackToStaMPS files into share folder
    (share/"prepStackToStaMPS").install Dir[buildpath/"contrib/timeseries/prepStackToStaMPS/bin/*"]
    (share/"prepStackToStaMPS").install buildpath/"contrib/timeseries/prepStackToStaMPS/README"
    # Copy examples folder into share folder
    share.install Dir[buildpath/"examples"]
  end

  def post_install
    homebrew_site_packages = Language::Python.homebrew_site_packages "python3"
    # Make isce symlink in python3 site_packages
    homebrew_site_packages.install_symlink opt_prefix
    # Make /usr/local/share/isce symlink
    ln_sf share, HOMEBREW_PREFIX/"share/isce"
  end

  def caveats; <<~EOS
    * Please add to your .bash_profile:
      export ISCE_HOME=#{opt_prefix}

    * You may want to add the following to your .bash_profile to activate one of the two stack processors:
    1) Sentinel-1 TOPS:
      export PATH=$PATH:#{HOMEBREW_PREFIX}/share/isce/topsStack
    2) Stripmap data:
      export PATH=$PATH:#{HOMEBREW_PREFIX}/share/isce/stripmapStack

    * If you are planning to use StaMPS, you also may add to your .bash_profile:
      export PATH=$PATH:#{HOMEBREW_PREFIX}/share/isce/prepStackToStaMPS
  EOS
  end

  test do
    system "python3", "-c", "import isce"
    %w[
      contrib.Snaphu.Snaphu
      isceobj.Filter
      isceobj.StripmapProc.StripmapProc
      isceobj.TopsProc.TopsProc
      isceobj.Orbit.Orbit
      isceobj.Planet.Planet
      isceobj.Util.Poly2D
      iscesys.ImageUtil.ImageUtil
      mroipac.ampcor.DenseAmpcor
      mroipac.correlation.correlation
      mroipac.grass.grass
      mroipac.icu.Icu
      mroipac.filter.Filter
      stdproc.rectify.geocode.Geocodable
      stdproc.stdproc.crossmul
      zerodop.geo2rdr
      zerodop.geozero
      zerodop.topozero
    ].each { |item| system "python3", "-c", "import isce, #{item}" }
    system "python3", "-c", <<~EOS
      import isce
      from contrib.splitSpectrum import SplitRangeSpectrum as splitSpectrum
      ss = splitSpectrum()
    EOS
    system "python3", "-c", "import isce, isceobj.Sensor.COSMO_SkyMed_SLC"
  end
end
