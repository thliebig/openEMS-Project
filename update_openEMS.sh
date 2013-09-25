#!/bin/bash

# Compiling OpenEMS may require installing the following packages:
# apt-get install qt4-qmake libtinyxml-dev libcgal-dev libvtk5-qt4-dev
# Compiling hyp2mat may require installing the following packages:
# apt-get install gengetopt help2man groff pod2pdf bison flex libhpdf-dev libtool

read -r -p "Build & install hyp2mat? [y/n]: " -n 1 Q_BUILD_HYP2MAT
echo ""

read -r -p "Install circuit toolbox? [y/n]: " -n 1 Q_BUILD_CTB
echo ""

basedir=$(pwd)
INSTALL_PATH=$basedir
QMAKE=qmake-qt4

if [ $# -ne 1 ]
then
  echo "Usage: `basename $0` <path-to-install>"
  exit $E_BADARGS
fi

if [ $# -ne 2 ]; then
  INSTALL_PATH=${1%/}
  echo "setting install path to: $INSTALL_PATH"
fi

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

#build QCSXCAD
build QCSXCAD PREFIX=$INSTALL_PATH CSXCAD_ROOT=$INSTALL_PATH
install QCSXCAD

#build AppCSXCAD
build AppCSXCAD PREFIX=$INSTALL_PATH CSXCAD_ROOT=$INSTALL_PATH QCSXCAD_ROOT=$INSTALL_PATH
install AppCSXCAD

#build openEMS
build openEMS PREFIX=$INSTALL_PATH FPARSER_ROOT=$INSTALL_PATH CSXCAD_ROOT=$INSTALL_PATH
install openEMS

#build nf2ff
cd openEMS
build nf2ff PREFIX=$INSTALL_PATH
install nf2ff
cd ..

#####  addtional packages ####

if [ $Q_BUILD_HYP2MAT = "y" ]; then
  #build hyp2mat
  build hyp2mat --prefix=$INSTALL_PATH
  install hyp2mat
fi

if [ $Q_BUILD_CTB = "y" ]; then
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
if [ $Q_BUILD_HYP2MAT = "y" ]; then
  echo "addpath('$INSTALL_PATH/share/hyp2mat/matlab'); % hyp2mat package"
fi
if [ $Q_BUILD_CTB = "y" ]; then
  echo "addpath('$INSTALL_PATH/share/CTB/matlab'); % circuit toolbox"
fi
echo ""
echo "Have fun using openEMS"
