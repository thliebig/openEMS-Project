#!/usr/bin/env bash

# Compiling OpenEMS may require installing the following packages:
# apt-get install cmake qt4-qmake libtinyxml-dev libcgal-dev libvtk5-qt4-dev
# Compiling hyp2mat may require installing the following packages:
# apt-get install gengetopt help2man groff pod2pdf bison flex libhpdf-dev libtool

set -o pipefail

EOK=0
EINVAL=22

function help_msg {
  echo "Usage: `basename $0` [options] <path-to-install>"
  echo ""
  echo "  options:"
  echo "	--verbose 		output build info to terminal"
  echo "	--njobs=N 		build with N jobs (defaults to $NJOBS on your system)"
  echo "	--with-hyp2mat:		enable hyp2mat build"
  echo "	--with-CTB		enable circuit toolbox"
  echo "	--disable-GUI		disable GUI build (AppCSXCAD)"
  echo "	--with-MPI		enable MPI"
  echo "	--python		build python extensions"
  echo "	--help			print this help message, and exit"
}


if [ $# -lt 1 ]
then
  help_msg
  exit $EINVAL
fi

# defaults
STDOUT="/dev/null"
NJOBS=$(nproc)
BUILD_HYP2MAT=0
BUILD_CTB=0
BUILD_GUI="YES"
WITH_MPI=0
BUILD_PY_EXT=0
INSTALL_PATH=

# parse arguments
for varg in $@
do
  case "$varg" in
    --verbose)
      STDOUT="$(tty)"
      ;;
    --njobs=*)
      NJOBS="${varg#*=}"
      ;;
    --with-hyp2mat)
      echo "enabling hyp2mat build"
      BUILD_HYP2MAT=1
      ;;
    --with-CTB)
      echo "enabling CTB build"
      BUILD_CTB=1
      ;;
    --disable-GUI)
      echo "disabling AppCSXCAD build"
      BUILD_GUI="NO"
      ;;
    --with-MPI)
      echo "enabling MPI"
      WITH_MPI=1
      ;;
    --python)
      echo "enabling Python Extension build"
      BUILD_PY_EXT=1
      ;;
    --help)
      help_msg
      exit $EOK
      ;;
    --*)
      echo "error, unknown argument: $varg"
      help_msg
      exit $EINVAL
      ;;
    *)
      if [ -n "$INSTALL_PATH" ]; then
        echo "error, install path specified twice. First: '$INSTALL_PATH'; Second: '$varg' $NJOBS"
        help_msg
        exit $EINVAL
      fi
      INSTALL_PATH=$varg
  esac
done

if [ -z "$INSTALL_PATH" ]; then
  echo -e "\nerror, install path must be specified\n"
  help_msg
  exit $EINVAL
fi

basedir=$(pwd)
LOG_FILE=$basedir/build_$(date +%Y%m%d_%H%M%S).log

echo "setting install path to: $INSTALL_PATH"
echo "logging build output to: $LOG_FILE"

function build {
cd $1
make clean &> /dev/null

if [ -f bootstrap.sh ]; then
  echo "bootstrapping $1 ... please wait"
  sh ./bootstrap.sh | tee $LOG_FILE >> $STDOUT
  if [ $? -ne 0 ]; then
    echo "bootstrap for $1 failed"
    cd ..
    exit 1
  fi
fi

if [ -f configure ]; then
  echo "configuring $1 ... please wait"
  ./configure $2 | tee $LOG_FILE >> $STDOUT
  if [ $? -ne 0 ]; then
    echo "configure for $1 failed"
    cd ..
    exit 1
  fi
fi

echo "compiling $1 ... please wait"
make -j$NJOBS | tee $LOG_FILE >> $STDOUT
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
make ${@:2:$#} install | tee $LOG_FILE >> $STDOUT
if [ $? -ne 0 ]; then
  echo "make install for $1 failed"
  cd ..
  exit 1
fi
cd ..
}

# cmake 4 does not work without this:
export CMAKE_POLICY_VERSION_MINIMUM=3.5

##### build openEMS and dependencies ####
tmpdir=`mktemp -d` && cd $tmpdir
echo "running cmake in tmp dir: $tmpdir"
cmake -DBUILD_APPCSXCAD=$BUILD_GUI -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH -DWITH_MPI=$WITH_MPI $basedir 2>&1 | tee $LOG_FILE >> $STDOUT
if [ $? -ne 0 ]; then
  echo "cmake failed"
  cd $basedir
  echo "build incomplete, cleaning up tmp dir ..."
  rm -rf $tmpdir
  exit 1
fi
echo "build openEMS and dependencies ... please wait"
make -j$NJOBS 2>&1 | tee $LOG_FILE >> $STDOUT
if [ $? -ne 0 ]; then
  echo "make failed, build incomplete, please see logfile for more details... $LOG_FILE"
  cd $basedir
  echo "build incomplete, cleaning up tmp dir ..."
  rm -rf $tmpdir
  exit 1
fi
echo "build successful, cleaning up tmp dir ..."
rm -rf $tmpdir
cd $basedir

#####  additional packages ####

if [ $BUILD_HYP2MAT -eq 1 ]; then
  #build hyp2mat
  build hyp2mat --prefix=$INSTALL_PATH
  install hyp2mat
fi

if [ $BUILD_CTB -eq 1 ]; then
  #install circuit toolbox (CTB)
  install CTB PREFIX=$INSTALL_PATH
fi

#####  python extension build ####
if [ $BUILD_PY_EXT -eq 1 ]; then
    echo "Building python modules ... please wait"
    ./build_python.sh $INSTALL_PATH 2>&1 | tee $LOG_FILE >> $STDOUT
    EC=$?
    if [ $EC -ne 0 ]; then
        echo "Python modules build failed, please see logfile for more details... $LOG_FILE"
        exit $EC
    fi
    cd $basedir
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
