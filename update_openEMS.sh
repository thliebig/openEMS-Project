
#!/bin/bash

# Compiling OpenEMS may require installing the following packages:
# apt-get install qt4-qmake libtinyxml-dev libcgal-dev libvtk5-qt4-dev
# Compiling hyp2mat may require installing the following packages:
# apt-get install gengetopt help2man groff pod2pdf bison flex libhpdf-dev libtool

if [ $# -lt 1 ]
then
  echo "Usage: `basename $0` <path-to-install> [<options>]"
  echo ""
  echo "  options:"
  echo "	--with-hyp2mat:		enable hyp2mat build"
  echo "	--with-CTB		enable circuit toolbox"
  echo "	--disable-GUI		disable GUI build (AppCSXCAD)"
  echo "	--disable-update	disable git submodule update"
  exit $E_BADARGS
fi

QMAKE=qmake-qt4

# defaults
BUILD_HYP2MAT=0
BUILD_CTB=0
BUILD_GUI=1
GIT_UPDATE=1  # perform submodule inti & update

VTK_LIB_DIR=$(dirname $(find /usr/lib*  -name 'libvtkCommon.so' 2>/dev/null))
echo "Detected vtk library path: $VTK_LIB_DIR"

for varg in ${@:2:$#}
do
  case "$varg" in
    "--with-hyp2mat")
      echo "enabling hyp2mat build"
      BUILD_HYP2MAT=1
      ;;
    "--with-CTB")
      echo "enabling CTB build"
      BUILD_CTB=1
      ;;
    "--disable-GUI")
      echo "disabling CTB build"
      BUILD_GUI=0
      ;;
    "--disable-update")
      echo "disabling git submodule update"
      GIT_UPDATE=0
      ;;
    *)
      echo "error, unknown argumennt: $varg"
      exit 1
      ;;
  esac
done

basedir=$(pwd)
INSTALL_PATH=${1%/}

mkdir -p $INSTALL_PATH
if [ $? -ne 0 ]; then
  echo "unable to create install path: $INSTALL_PATH"
  exit
fi

echo "setting install path to: $INSTALL_PATH"

if [ $GIT_UPDATE -eq 1 ]; then
  #update all
  echo "init & updating git submodules... please wait"
  git submodule init
  if [ $? -ne 0 ]; then
    echo "git submodule init failed!"
    exit
  fi

  git submodule update
  if [ $? -ne 0 ]; then
    echo "git submodule update failed!"
    exit
  fi
fi

function build {
cd $1
make clean &> /dev/null

if [ -f $1.pro ]; then
  $QMAKE ${@:2:$#} $1.pro
  if [ $? -ne 0 ]; then
    echo "qmake for $1 failed"
    cd ..
    exit
  fi
fi

if [ -f bootstrap.sh ]; then
  echo "bootstrapping $1 ... please wait"
  sh ./bootstrap.sh > /dev/null
  if [ $? -ne 0 ]; then
    echo "bootstrap for $1 failed"
    cd ..
    exit
  fi
fi

if [ -f configure ]; then
  echo "configuring $1 ... please wait"
  ./configure $2 > /dev/null
  if [ $? -ne 0 ]; then
    echo "configure for $1 failed"
    cd ..
    exit
  fi
fi

echo "compiling $1 ... please wait"
make -j4 > /dev/null
if [ $? -ne 0 ]; then
  echo "make for $1 failed"
  cd ..
  exit
fi
cd ..
}

function install {
cd $1
echo "installing $1 ... please wait"
make ${@:2:$#} install > /dev/null
if [ $? -ne 0 ]; then
  echo "make install for $1 failed"
  cd ..
  exit
fi
cd ..
}

#build fparser
build fparser PREFIX=$INSTALL_PATH
install fparser

#build CSXCAD
build CSXCAD PREFIX=$INSTALL_PATH FPARSER_ROOT=$INSTALL_PATH
install CSXCAD

if [ $BUILD_GUI -eq 1 ]; then
  #build QCSXCAD
  build QCSXCAD PREFIX=$INSTALL_PATH CSXCAD_ROOT=$INSTALL_PATH VTK_LIBRARYPATH=$VTK_LIB_DIR
  install QCSXCAD

  #build AppCSXCAD
  build AppCSXCAD PREFIX=$INSTALL_PATH CSXCAD_ROOT=$INSTALL_PATH QCSXCAD_ROOT=$INSTALL_PATH VTK_LIBRARYPATH=$VTK_LIB_DIR
  install AppCSXCAD
fi

#build openEMS
build openEMS PREFIX=$INSTALL_PATH FPARSER_ROOT=$INSTALL_PATH CSXCAD_ROOT=$INSTALL_PATH VTK_LIBRARYPATH=$VTK_LIB_DIR
install openEMS

#build nf2ff
cd openEMS
build nf2ff PREFIX=$INSTALL_PATH
install nf2ff
cd ..

#####  addtional packages ####

if [ $BUILD_HYP2MAT -eq 1 ]; then
  #build hyp2mat
  build hyp2mat --prefix=$INSTALL_PATH
  install hyp2mat
fi

if [ $BUILD_CTB -eq 1 ]; then
  #install circuit toolbox (CTB)
  install CTB PREFIX=$INSTALL_PATH
fi

#####

echo " -------- "
echo "openEMS and all modules have been updated successfully..."
echo ""
echo "% add the required paths to Octave/Matlab:"
echo "addpath('$INSTALL_PATH/share/openEMS/matlab')"
echo "addpath('$INSTALL_PATH/share/CSXCAD/matlab')"
echo ""
echo "% optional additional pckages:"
if [ $BUILD_HYP2MAT -eq 1 ]; then
  echo "addpath('$INSTALL_PATH/share/hyp2mat/matlab'); % hyp2mat package"
fi
if [ $BUILD_CTB -eq 1 ]; then
  echo "addpath('$INSTALL_PATH/share/CTB/matlab'); % circuit toolbox"
fi
echo ""
echo "Have fun using openEMS"
