#!/bin/bash

# Compiling OpenEMS may require installing the following packages:
# apt-get install cmake qt4-qmake libtinyxml-dev libcgal-dev libvtk5-qt4-dev
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
  echo "	--with-MPI		enable MPI"
  echo "	--python		build python extentions"
  exit $E_BADARGS
fi

# defaults
BUILD_HYP2MAT=0
BUILD_CTB=0
BUILD_GUI="YES"
WITH_MPI=0
BUILD_PY_EXT=0

# parse arguments
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
      echo "disabling AppCSXCAD build"
      BUILD_GUI="NO"
      ;;
    "--with-MPI")
      echo "enabling MPI"
      WITH_MPI=1
      ;;
    "--python")
      echo "enabling Python Extension build"
      BUILD_PY_EXT=1
      ;;
    *)
      echo "error, unknown argumennt: $varg"
      exit 1
      ;;
  esac
done

basedir=$(pwd)
INSTALL_PATH=${1%/}
LOG_FILE=$basedir/build_$(date +%Y%m%d_%H%M%S).log

echo "setting install path to: $INSTALL_PATH"
echo "logging build output to: $LOG_FILE"

function build {
cd $1
make clean &> /dev/null

if [ -f bootstrap.sh ]; then
  echo "bootstrapping $1 ... please wait"
  sh ./bootstrap.sh >> $LOG_FILE
  if [ $? -ne 0 ]; then
    echo "bootstrap for $1 failed"
    cd ..
    exit 1
  fi
fi

if [ -f configure ]; then
  echo "configuring $1 ... please wait"
  ./configure $2 >> $LOG_FILE
  if [ $? -ne 0 ]; then
    echo "configure for $1 failed"
    cd ..
    exit 1
  fi
fi

echo "compiling $1 ... please wait"
make -j4 >> $LOG_FILE
if [ $? -ne 0 ]; then
  echo "make for $1 failed"
  cd ..
  exit 1
fi
cd ..
}

function install {
cd $1
echo "installing $1 ... please wait"
make ${@:2:$#} install >> $LOG_FILE
if [ $? -ne 0 ]; then
  echo "make install for $1 failed"
  cd ..
  exit 1
fi
cd ..
}

##### build openEMS and dependencies ####
tmpdir=`mktemp -d` && cd $tmpdir
echo "running cmake in tmp dir: $tmpdir"
cmake -DBUILD_APPCSXCAD=$BUILD_GUI -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DWITH_MPI=$WITH_MPI $basedir >> $LOG_FILE
if [ $? -ne 0 ]; then
  echo "cmake failed"
  cd $basedir
  echo "build incomplete, cleaning up tmp dir ..."
  rm -rf $tmpdir
  exit 1
fi
echo "build openEMS and dependencies ... please wait"
make -j5 >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
  echo "make failed, build incomplete, please see logfile for more details..."
  cd $basedir
  echo "build incomplete, cleaning up tmp dir ..."
  rm -rf $tmpdir
  exit 1
fi
echo "build successful, cleaning up tmp dir ..."
rm -rf $tmpdir
cd $basedir

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

#####  python extention build ####

if [ $BUILD_PY_EXT -eq 1 ]; then
    PY_INST_USER=''
    if (( $EUID != 0 )); then
        PY_INST_USER='--user'
    fi
    for PY_EXT in 'CSXCAD' 'openEMS'
    do
        echo "build $PY_EXT python module ... please wait"
        cd $PY_EXT/python
        python3 setup.py build_ext -I $INSTALL_PATH/include -L $INSTALL_PATH/lib -R $INSTALL_PATH/lib >> $LOG_FILE 2>&1
        python3 setup.py install $PY_INST_USER >> $LOG_FILE 2>&1
        if [ $? -ne 0 ]; then
            echo "python module failed, please see logfile for more details..."
        fi
        cd $basedir
    done
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
