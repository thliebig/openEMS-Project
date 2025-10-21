#!/usr/bin/env bash

if [ $# -lt 1 ]
then
  echo "Usage: `basename $0` <openEMS_install_path>"
  exit 1
fi

basedir=$(pwd)
INSTALL_PATH=${1%/}

echo $INSTALL_PATH

# are we running inside a Python venv?
PY_INST_IS_VENV=$(python3 -c "import sys; print(int(sys.prefix != sys.base_prefix))")

PY_INST_USER=''
if [[ $EUID != 0 ]] && [[ $PY_INST_IS_VENV != 1 ]]; then
    PY_INST_USER='--user'
fi
for PY_EXT in 'CSXCAD' 'openEMS'
do
    echo "build $PY_EXT python module ... please wait"
    cd $PY_EXT/python
    python3 setup.py build_ext -I $INSTALL_PATH/include -L $INSTALL_PATH/lib -R $INSTALL_PATH/lib && python3 setup.py install $PY_INST_USER
    EC=$?
    if [ $EC -ne 0 ]; then
        echo "Python module build failed!"
        exit $EC
    fi
    cd $basedir
done
