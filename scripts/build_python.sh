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

# In additional to libraries in $INSTALL_PATH, we also need to list
# custom headers and libraries installed to the local system which are
# not used by default. For example, if a custom Boost is installed on
# CentOS, the paths -L /usr/local/include and -R /usr/local/lib must
# be listed.
SYSLOCAL="/usr/local"

# On macOS, all Homebrew packages belong to this category, and the
# required prefix are -L $(brew --prefix)/include and
# -R $(brew --prefix)/lib respectively.
if [[ "$OSTYPE" == "darwin"* ]]; then
    SYSLOCAL="$(brew --prefix)"
fi

# "+x" checks whether the variable is unset (not just empty), needed
# in strict "set -u" mode as it forbids the use of unbounded variables.
if [ -z ${CXXFLAGS+x} ]; then
  EXTERNAL_CXXFLAGS=""
else
  EXTERNAL_CXXFLAGS="$CXXFLAGS"
fi

if [ -z ${LDFLAGS+x} ]; then
  EXTERNAL_LDFLAGS=""
else
  EXTERNAL_LDFLAGS="$LDFLAGS"
fi

for PY_EXT in 'CSXCAD' 'openEMS'
do
    echo "build $PY_EXT python module ... please wait"
    cd $PY_EXT/python

    export CXXFLAGS="\"-I$INSTALL_PATH/include\" \"-I$SYSLOCAL/include\" $EXTERNAL_CXXFLAGS"
    export LDFLAGS="\"-L$INSTALL_PATH/lib\" \"-L$SYSLOCAL/lib\" \"-Wl,-rpath,$INSTALL_PATH/lib\" $EXTERNAL_LDFLAGS"

    if [ $PY_INST_IS_VENV == 1 ]; then
        # In pip, build-time package dependencies MUST be defined in pyproject.toml,
	# because pip uses an internal isolated venv (even different from the user's
	# own venv) to build the package. But we currently do not, thus we use
	# --no-build-isolation
        pip3 install . $PY_INST_USER --no-build-isolation
    else
        # --break-system-packages means we install directly to a user's
	# home directory, this is safe because openEMS currently doesn't
	# auto-install dependencies - the old setup.py does the same.
	#
	# TODO: add a "--python-venv" option in update_openEMS.sh, allowing
	# users to switch between both behaviors using a single command.
        pip3 install . $PY_INST_USER --no-build-isolation --break-system-packages
    fi

    EC=$?
    if [ $EC -ne 0 ]; then
        echo "Python module build failed!"
        exit $EC
    fi
    cd $basedir
done
