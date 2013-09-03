#!/bin/bash

basedir=$(pwd)
QMAKE=qmake-qt4

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

#build CSXCAD
cd CSXCAD
make clean &> /dev/null
$QMAKE PREFIX=. CSXCAD.pro
if [ $? -ne 0 ]; then
  echo "qmake for CSXCAD failed"
  cd ..
  exit
fi

echo "compiling CSXCAD ... please wait"
make -j4 > /dev/null
if [ $? -ne 0 ]; then
  echo "make for CSXCAD failed"
  cd ..
  exit
fi
make install > /dev/null
if [ $? -ne 0 ]; then
  echo "make install for CSXCAD failed"
  cd ..
  exit
fi
cd ..

#build QCSXCAD
cd QCSXCAD
make clean &> /dev/null
$QMAKE PREFIX=. CSXCAD_ROOT=$basedir/CSXCAD QCSXCAD.pro
if [ $? -ne 0 ]; then
  echo "qmake for QCSXCAD failed"
  cd ..
  exit
fi

echo "compiling QCSXCAD ... please wait"
make -j4 > /dev/null
if [ $? -ne 0 ]; then
  echo "make for QCSXCAD failed"
  cd ..
  exit
fi
make install > /dev/null
if [ $? -ne 0 ]; then
  echo "make install for QCSXCAD failed"
  cd ..
  exit
fi
cd ..

#build AppCSXCAD
cd AppCSXCAD
make clean &> /dev/null
$QMAKE PREFIX=. CSXCAD_ROOT=$basedir/CSXCAD QCSXCAD_ROOT=$basedir/QCSXCAD AppCSXCAD.pro
if [ $? -ne 0 ]; then
  echo "qmake for AppCSXCAD failed"
  cd ..
  exit
fi

echo "compiling AppCSXCAD ... please wait"
make -j4 > /dev/null
if [ $? -ne 0 ]; then
  echo "make for AppCSXCAD failed"
  cd ..
  exit
fi
cd ..

#build openEMS
cd openEMS
make clean &> /dev/null
$QMAKE PREFIX=. CSXCAD_ROOT=$basedir/CSXCAD openEMS.pro
if [ $? -ne 0 ]; then
  echo "qmake for openEMS failed"
  cd ..
  exit
fi

echo "compiling openEMS ... please wait"
make -j4 > /dev/null
if [ $? -ne 0 ]; then
  echo "make for openEMS failed"
  cd ..
  exit
fi
cd ..

#build nf2ff
cd openEMS/nf2ff
make clean &> /dev/null
$QMAKE
echo "compiling nf2ff ... please wait"
make -j4 > /dev/null
if [ $? -ne 0 ]; then
  echo "make for nf2ff failed"
  cd ../..
  exit
fi
cd ../..

echo "openEMS and all modules have been updated successfully..."
echo ""
echo "add the required paths to Octave/Matlab:"
echo "addpath('$basedir/openEMS/matlab')"
echo "addpath('$basedir/CSXCAD/matlab')"
echo ""
echo "Have fun using openEMS"
