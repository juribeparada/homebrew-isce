# ISCE Homebrew formula

This Homebrew formula provides binary (bottle) installation of the [Interferometric synthetic aperture radar Scientific Computing Environment (ISCE)](https://winsar.unavco.org/software/isce). It also builds from the ISCE open source code, which is available on [GitHub](https://github.com/isce-framework/isce2). For binary installation, High Sierra and Mojave are supported.

ISCE >= v2.3.1 is open source, but some applications will not work without obtaining [licensed components](https://github.com/isce-framework/isce2#license-required-for-dependencies-to-enable-some-workflows-in-isce).

Please, DO NOT mix with other package managers (MacPorts, Fink, Conda). If you have a Miniconda or Anaconda installation, make sure they are isolated and not using the PATH environment variable.

## ISCE installation using Homebrew

Follow these steps for ISCE installation. If you have problems about the ISCE setup using this formula, please report an issue.

### Install Homebrew

If you don't have Homebrew installed in your macOS system, please follow the instructions [here](https://brew.sh). If you have Homebrew installed, please be sure you have your system updated:

    brew update
    brew upgrade
    brew cleanup

### Install XQuartz

If you don't have XQuartz installed, please execute this command and follow the steps:

    brew cask install xquartz

### If you will build ISCE under Mojave from source code

This step is optional, but recommended. If you are planning to build the ISCE package from the source code, you need to install the macOS SDK headers if you are using Mojave:

    sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /

### Add this tap to your Homebrew

Please add this tap to access to the ISCE installation formula:

    brew tap juribeparada/isce

### Install ISCE

Run the following command to install ISCE. Please be patient to wait the installation of a big number of dependences. Re-run this command just in case if dependences installation stops early:

    brew install isce

### Post installation

Please add to your ~/.bash_profile (see "caveats" message with: brew info isce):

    export ISCE_HOME=/usr/local/opt/isce

Install additional python3 packages after ISCE setup, for example:

    pip3 install h5py
    pip3 install requests
    pip3 install matplotlib

Now your ISCE installation is ready to use.

### Stack processors

If you want to use the stack processors included in ISCE, you need to add to your .bash_profile the following lines, depending on what kind of stack processor you need:

- Sentinel-1 TOPS:

        export PATH=$PATH:/usr/local/share/isce/topsStack

- Stripmap data:

        export PATH=$PATH:/usr/local/share/isce/stripmapStack

If you are planning to use StaMPS, you also may add to your .bash_profile:

    export PATH=$PATH:/usr/local/share/isce/prepStackToStaMPS

## Additional installation options

- brew test isce: perform several ISCE modules tests.
- brew install --build-from-source isce: compile and install ISCE source code (released version).
- brew install --HEAD isce: compile and install latest GitHub ISCE source code.
- brew reinstall isce: reinstall ISCE software, for example to fix a damaged installation.
- brew remove isce: uninstall ISCE package.

## Common issues

- ISCE is not installed: probably dependences installation stops early. Re-run "brew install isce" to continue dependences installation.
- ISCE installation starts to build from the sources, with a "SHA256 mismatch" error: probably the binary bottles were updated recently. Please stops the building with Ctrl-C, and then execute "brew fetch --force isce". Then try to install ISCE again with "brew install isce".
- Runtime errors executing ISCE: try to reinstall critical packages for ISCE, for example "brew reinstall numpy scipy gcc", etc. Also, check the Homebrew environment health with "brew doctor" and check for unlinked formulas. Report an issue if you still have problems.
- When building from source code, scons hangs for long time: normally, scons build takes ~6 minutes, if that time is considerably larger, probably scons failed. Please be sure your Homebrew environment health is OK and you have the SDK headers installed (Mojave). If you are building from sources, it is a good idea to see the Homebrew log.

## Debug during compilation

The best way to debug for issues during ISCE source code compilation, it is looking at the Homebrew logs. Please see at ~/Library/Logs/Homebrew/isce/ for log files. For example:

- config.log: scons configuration log, useful to see why scons can't detect a particular dependence.
- 01.python3: cython installation log.
- 02.scons: complete scons output log during ISCE compilation, useful to find compilation issues. For example, during an ISCE compilation ("brew install --build-from-source isce"), it is a good idea to see the scons log on a separated Terminal window with:

        tail -f ~/Library/Logs/Homebrew/isce/02.scons
