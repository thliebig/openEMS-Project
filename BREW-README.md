openEMS Homebrew
================

This is a [homebrew](http://brew.sh) formula to install [openEMS](http://openEMS.de) and all dependencies.

How to install openEMS:
-----------------------

You can install openEMS using this URL:
```bash
brew tap thliebig/openems https://github.com/thliebig/openEMS-Project.git
brew install --HEAD openems
```

Install Octave if it isn't already installed

```bash
brew install octave
```

Add the openEMS paths to your `~/.octaverc` file

```
echo "addpath('/usr/local/share/openEMS/matlab:/usr/local/share/CSXCAD/matlab');" >> ~/.octaverc
```

Verify your installation by completing the [First Steps section of the Tutorials](http://openems.de/index.php/Tutorial:_First_Steps).
