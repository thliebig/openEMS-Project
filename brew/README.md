openEMS Homebrew
================

This is a [homebrew](http://brew.sh) formula to install [openEMS](http://openEMS.de) and all dependencies.

How to install openEMS:
-----------------------

You can install openEMS using this URL:
```bash
  brew install --HEAD https://raw.github.com/thliebig/openEMS-Project/master/brew/openEMS.rb
```

Then create a folder and symbolic link in your home folder with these commands

```
mkdir ~/opt
ln -s /usr/local/Cellar/openEMS/HEAD ~/opt/openEMS
```

Install Octave if it isn't already installed

```
brew install octave
```

Start Octave from the command line and add the openEMS paths

```
addpath('~/opt/openEMS/share/openEMS/matlab');
addpath('~/opt/openEMS/share/CSXCAD/matlab');
savepath()
```

Verify your installation by completing the First Steps section of the Tutorials. http://openems.de/index.php/Tutorial:_First_Steps
