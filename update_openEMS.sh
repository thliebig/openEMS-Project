#!/bin/bash

basedir=$(pwd)
INSTALL_PATH=$basedir
QMAKE=qmake-qt4

if [ $# -ne 1 ]
then
  echo "Usage: `basename $0` <path-to-install>"
  exit $E_BADARGS
fi

if [ $# -ne 2 ]; then
  echo "setting install path to: $1"
  INSTALL_PATH=$1
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
$QMAKE ${@:2:$#} $1.pro
if [ $? -ne 0 ]; then
  echo "qmake for $1 failed"
  cd ..
  exit
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
make install > /dev/null
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

echo "openEMS and all modules have been updated successfully..."
echo ""
echo "add the required paths to Octave/Matlab:"
echo "addpath('$INSTALL_PATH/share/openEMS/matlab')"
echo "addpath('$INSTALL_PATH/share/CSXCAD/matlab')"
echo ""
echo "Have fun using openEMS"
