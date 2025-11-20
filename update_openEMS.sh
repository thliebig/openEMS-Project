#!/usr/bin/env bash

# Compiling openEMS may require installing the following packages:
# https://openems.readthedocs.io/en/latest/install/requirements.html
#
# Compiling hyp2mat may require installing the following packages:
# apt-get install gengetopt help2man groff pod2pdf bison flex libhpdf-dev libtool

# stop the shell on various errors
set -uo pipefail

EINVAL=22
BASEDIR=$(pwd)

function die {
  printf "%s\n" "A fatal error has occurred!"
  exit 1
}

function help_msg {
  echo "Usage: $(basename "$0") [options] <path-to-install>"
  echo ""
  echo "  options:"
  echo "	--help			print this help message, and exit"
  echo "	--verbose 		output build info to terminal"
  echo "	--njobs=N 		build with N jobs (defaults to $NJOBS on your system)"
  echo "	--with-hyp2mat 		enable hyp2mat build"
  echo "	--with-CTB		enable circuit toolbox"
  echo "	--disable-GUI		disable GUI build (AppCSXCAD)"
  echo "	--with-MPI		enable MPI"
  echo "        --with-tinyxml          download and build custom TinyXML from source,"
  echo "                                enabled by default on macOS as TinyXML is desupported"
  echo "                                (need network access to SourceForge & GitHub)"
  echo "	--python		build python extensions"
  echo ""
  ./scripts/build_python.sh --help-python
}

function build {
  local srcdir; srcdir=$(readlink -f "$1")
  local builddir; builddir=$(readlink -f "$2")
  local njobs="$3"
  local logfile="$4"
  local output="$5"
  local extra_build_arguments=( "${@:6}" )

  cd "$srcdir" || die
  make clean &> /dev/null || true

  if [ -f "$srcdir/bootstrap.sh" ]; then
    echo "bootstrapping $srcdir ... please wait"
    if ! sh ./bootstrap.sh 2>&1 | tee -a "$logfile" >> "$output";
    then
      echo "bootstrap for $srcdir failed"
      cd "$BASEDIR" || die
      exit 1
    fi
  fi

  # build everything out of tree
  cd "$builddir" || die

  if [ -f "$srcdir/configure" ]; then
    echo "configuring $srcdir via autotools ... please wait"
    if ! "$srcdir/configure" "${extra_build_arguments[@]}" 2>&1 | tee -a "$logfile" >> "$output";
    then
      echo "configure for $srcdir failed"
      cd "$BASEDIR" || die
      echo "build incomplete, cleaning up tmp dir ..."
      rm -rf "$builddir"
      exit 1
    fi
  elif [ -f "$srcdir/CMakeLists.txt" ]; then
    echo "configuring $srcdir via CMake ... please wait"
    if ! cmake "$srcdir" "${extra_build_arguments[@]}" 2>&1 | tee -a "$logfile" >> "$output";
    then
      echo "cmake for $1 failed"
      cd "$BASEDIR" || die
      echo "build incomplete, cleaning up tmp dir ..."
      rm -rf "$builddir"
      exit 1
    fi
  fi

  echo "compiling $srcdir ... please wait"
  if ! make -j"$njobs" 2>&1 | tee -a "$logfile" >> "$output";
  then
    echo "make for $srcdir failed"
    cd "$BASEDIR" || die
    echo "build incomplete, cleaning up tmp dir ..."
    rm -rf "$builddir"
    exit 1
  fi

  cd "$BASEDIR" || die
}

function install {
  local builddir; builddir=$(readlink -f "$1")
  local extra_build_arguments=( "${@:2}" )

  cd "$builddir" || die
  echo "installing $builddir ... please wait"
  if ! make install "${extra_build_arguments[@]}" 2>&1 | tee -a "$LOG_FILE" >> "$STDOUT";
  then
    echo "make install for $builddir failed"
    cd "$BASEDIR" || die
    exit 1
  fi
  cd "$BASEDIR" || die
}

function parse_args {
  # if no argument is given, show help message and exit
  if [ $# -lt 1 ]; then
    help_msg
    exit $EINVAL
  fi

  # extract all --python- arguments (excluding "--python") because
  # they're controlled by scripts/build_python.sh, not us.
  local basic_args=()

  local i=1
  local skip_next=0

  while (( i <= $# )); do
    if [ $skip_next -eq 1 ]; then
      skip_next=0
      ((i++))
      continue
    fi

    local arg="${!i}"
    if [[ $arg == --python-*=* ]] ; then
      # --python-key=value
      PYTHON_ARGS+=("$arg")
    elif [[ $arg == --python-* ]] ; then
      # --python-key value
      PYTHON_ARGS+=("$arg")

      if (( i + 1 <= $# )); then
	local j=$((i + 1))
        local next_arg="${!j}"

	# ignore --python-key -value or --python-key --value
        if [[ $next_arg != -* ]]; then
          PYTHON_ARGS+=("$next_arg")
          skip_next=1
        fi
      fi
    else
      basic_args+=("$arg")
    fi

    ((i++))
  done

  # override argument list using basic_args
  set -- "${basic_args[@]}"

  while true; do
    # "+x" checks whether the variable is unset (not just empty), needed
    # in strict "set -u" mode as it forbids the use of unbounded variables.
    if [ -z ${1+x} ]; then
      break
    fi

    case $1 in
      # parse --njobs
      --njobs)
        if [ "$2" ]; then
          NJOBS="$2"
          shift
        else
          die "ERROR: --njobs is specified with an empty value!"
        fi
        ;;
      --njobs=?*)
        NJOBS=${1#*=}
        ;;
      --njobs=)
        die "ERROR: --cpp-install-dir is specified with an empty value!"
        ;;

      -h|--help)
        help_msg
        exit $EINVAL
        ;;
      --verbose)
        STDOUT="$(tty)"
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
      --with-tinyxml)
        echo "enabling custom TinyXML download and build"
        BUILD_TINYXML=1
        ;;
      --python)
        echo "enabling Python Extension build"
        BUILD_PY_EXT=1
	;;
      --)
        shift
        break
        ;;
      -?*)
        echo "ERROR: Unknown option $1"
	exit $EINVAL
        ;;
      *)
        if [ -n "$INSTALL_PATH" ]; then
          echo "error, install path specified twice. First: '$INSTALL_PATH'; Second: '$1'"
          help_msg
          exit $EINVAL
        fi
        INSTALL_PATH=$1
    esac

    shift
  done

  if [ -z "$INSTALL_PATH" ]; then
    echo -e "\nerror, install path must be specified\n"
    help_msg
    exit $EINVAL
  fi

  if [ "$BUILD_PY_EXT" -eq 0 ] && [ -n "${PYTHON_ARGS[*]}" ]; then
    printf "%s\n" "--python must be enabled for ${PYTHON_ARGS[*]}"
    exit $EINVAL
  fi
}

function preinstall_python_dry_run {
  # Dry-run build_python.sh early to detect invalid "--python-xxx" arguments
  # that we don't control.
  if [ "$BUILD_PY_EXT" -eq 1 ]; then
    if ! ./scripts/build_python.sh \
       --dry-run --cpp-install-dir "$INSTALL_PATH" \
       ${PYTHON_ARGS[@]+"${PYTHON_ARGS[@]}"};
       # See https://stackoverflow.com/questions/7577052/unbound-variable-error-in-bash-when-expanding-empty-array
    then
      exit $EINVAL
    fi
  fi
}

function show_postinstall_help {
  local install_path; install_path=$(readlink -f "$1")
  local build_hyp2mat="$2"
  local build_ctb="$3"
  local python_help="$4"

  echo " -------- "
  echo "openEMS and all modules have been updated successfully..."
  echo ""
  echo "% add the required paths to Octave/Matlab:"
  echo "addpath('$install_path/share/openEMS/matlab')"
  echo "addpath('$install_path/share/CSXCAD/matlab')"

  if [ "$build_hyp2mat" -eq 1 ] ||
     [ "$build_ctb" -eq 1 ] ||
     [ -n "$python_help" ];
  then
    echo ""
    echo "% optional additional packages:"
    if [ "$build_hyp2mat" -eq 1 ]; then
      echo "addpath('$install_path/share/hyp2mat/matlab'); % hyp2mat package"
    fi
    if [ "$build_ctb" -eq 1 ]; then
      echo "addpath('$install_path/share/CTB/matlab'); % circuit toolbox"
    fi
    if [ -n "$python_help" ]; then
      echo "$python_help"
    fi
  fi
  echo ""
  echo "Have fun using openEMS"
}


# defaults
STDOUT="/dev/null"
NJOBS=$(python3 -c "import os; print(os.cpu_count())" || nproc || sysctl -n hw.ncpu)
BUILD_HYP2MAT=0
BUILD_CTB=0
BUILD_GUI="YES"
WITH_MPI=0
BUILD_PY_EXT=0
BUILD_TINYXML=0
INSTALL_PATH=
PYTHON_ARGS=()
LOG_FILE="$BASEDIR/build_$(date +%Y%m%d_%H%M%S).log"

# Unfortunately, TinyXML has been desupported by Homebrew, so we must
# download and build it from source, see comments in scripts/build_tinyxml.sh
if [[ "$OSTYPE" == "darwin"* ]]; then
  BUILD_TINYXML=1
fi

# modifies global variables above
parse_args "$@"

echo "setting install path to: $INSTALL_PATH"
echo "logging build output to: $LOG_FILE"

##### build openEMS and dependencies #####
TMPDIR=$(mktemp -d)
mkdir -p "$INSTALL_PATH"

preinstall_python_dry_run

# build TinyXML
if [ "$BUILD_TINYXML" -eq 1 ]; then
  echo "downloading and building custom TinyXML in tmp dir: $TMPDIR"
  echo "Make sure you have network access to SourceForge and GitHub,"
  echo "if not, check the online manual."
  mkdir -p ./downloads
  if ! ./scripts/build_tinyxml.sh --build-dir "$TMPDIR" --install-dir "$INSTALL_PATH" \
    2>&1 | tee -a "$LOG_FILE" >> "$STDOUT";
  then
    echo "TinyXML build failed, please see logfile for more details... $LOG_FILE"
    exit 1
  fi
fi

# build openEMS Project
build "$BASEDIR" "$TMPDIR" "$NJOBS" "$LOG_FILE" "$STDOUT" \
      "-DBUILD_APPCSXCAD=$BUILD_GUI" \
      "-DCMAKE_INSTALL_PREFIX=$INSTALL_PATH" \
      "-DWITH_MPI=$WITH_MPI"

##### additional packages #####

# hyp2mat
if [ $BUILD_HYP2MAT -eq 1 ]; then
  mkdir -p "$TMPDIR/hyp2mat"
  build hyp2mat "$TMPDIR/hyp2mat" "$NJOBS" "$LOG_FILE" "$STDOUT" \
        "--prefix=$INSTALL_PATH"
  install "$TMPDIR/hyp2mat"
fi

# circuit toolbox (CTB)
if [ $BUILD_CTB -eq 1 ]; then
  install CTB "PREFIX=$INSTALL_PATH"
fi

#### python extension build ####
PYTHON_HELP=""
if [ "$BUILD_PY_EXT" -eq 1 ]; then
  echo "Building python modules ... please wait"
  if ! ./scripts/build_python.sh \
       --cpp-install-dir "$INSTALL_PATH" \
       ${PYTHON_ARGS[@]+"${PYTHON_ARGS[@]}"} \
       2>&1 | tee -a "$LOG_FILE" >> "$STDOUT";
  then
    echo "Python modules build failed, please see logfile for more details... $LOG_FILE"
    exit 1
  fi
  PYTHON_HELP=$(./scripts/build_python.sh --cpp-install-dir "$INSTALL_PATH" ${PYTHON_ARGS[@]+"${PYTHON_ARGS[@]}"} --help-postinst)
fi
cd "$BASEDIR" || die

echo "build successful, cleaning up tmp dir ..."
rm -rf "$TMPDIR"

#####
show_postinstall_help "$INSTALL_PATH" "$BUILD_HYP2MAT" "$BUILD_CTB" "$PYTHON_HELP"
