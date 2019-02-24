# ISCE Homebrew formula

This Homebrew formula provides binary (bottle) installation of the [Interferometric synthetic aperture radar Scientific Computing Environment (ISCE)](https://winsar.unavco.org/software/isce). It also provides the installation of local compiled source code, which is available on [GitHub](https://github.com/isce-framework/isce2). For binary installation, High Sierra and Mojave are supported.

DO NOT mix with other package managers (MacPorts, Fink, Conda). If you have a Miniconda or Anaconda installation, make sure they are isolated and not using the PATH environment variable.

## ISCE installation using Homebrew

Follow these steps for ISCE installation. If you have problems about the ISCE setup using this formula, please report an issue.

### Install Homebrew

If you don't have Homebrew installed in your macOS system, please follow the instructions [here](https://brew.sh). If you have Homebrew installed, please be sure you have your system updated:

    brew update
    brew upgrade
    brew cleanup

### Install XQuartz

If you don't have XQuartz installed, please execute the following command and follow the steps:

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

Install additional python3 packages after ISCE installation, for example:

    pip3 install h5py
    pip3 install requests
    pip3 install matplotlib

## Additional installation options

- brew install --build-from-source isce: compile and install ISCE released source code
- brew install --HEAD isce: compile and install latest GitHub ISCE source code
- brew reinstall isce: reinstall ISCE software, for example to fix a damaged installation
- brew remove isce: uninstall ISCE package

## Common issues

- ISCE is not installed: probably dependences installation stops early. Re-run "brew install isce" to continue dependences installation.
- ISCE installation starts to build from the sources, with a "SHA256 mismatch" error: probably the binary bottles were updated recently. Please stops the building with Ctrl-C, and then execute "brew fetch --force isce". Then try to install ISCE again with "brew install isce".
- Runtime errors executing ISCE: try to reinstall critical packages for ISCE, for example "brew reinstall numpy scipy gcc", etc. Also, check the Homebrew environment health with "brew doctor" and check for unlinked formulas. Report an issue if you still have problems.
- When building from sources, scons hangs for long time: probably scons failed. Please be sure your Homebrew environment health is OK and you have the SDK headers installed (Mojave). If you are building from sources, it is a good idea to see the Homebrew log.

## Debug for issues

The best way to debug for issues during ISCE source code compilation, it is looking at the Homebrew logs. Please see at ~/Library/Logs/Homebrew/isce/ for log files. For example:

- config.log: scons configuration log, useful to see why scons can't find a particular dependence.
- 01.python3: cython installation log
- 02.scons: complete scons output log during ISCE compilation, useful to find compilation issues. For example, during an ISCE compilation ("brew install --build-from-source isce"), it is a good idea to see the scons log in a separated Terminal window with:

        tail -f ~/Library/Logs/Homebrew/isce/02.scons
