#!/usr/bin/env bash
# shellcheck disable=SC2207

# stop the shell on various errors
set -euo pipefail

function die {
  printf "%s\n" "$1"
  printf "%s\n" "See --help"
  exit 1
}

function print_python_help {
  printf -- "  Python options:\n"
  printf -- "	--python-venv-mode\tPython extensions installation mode\n"
  printf -- "	  \t\t\tauto: create a Python venv if no venv is already activated,\n"
  printf -- "	  \t\t\t      otherwise use the existing venv (default)\n"
  printf -- "	  \t\t\tvenv: create a Python venv\n"
  printf -- "	  \t\t\tsite: create a Python venv with --system-site-packages\n"
  printf -- "	  \t\t\tdisable: don't change venv, install Python extension directly to\n"
  printf -- "	  \t\t\t         default path (usually in home directory (e.g. ~/.local)\n"
  printf -- "	--python-venv-dir\toverride default Python venv creation path\n"
  printf -- "	  \t\t\t         by default, use \"venv\" subdirectory of the installation path\n"
  printf -- "	--python-use-network\tdownload needed Python pip packages from Internet\n"
  printf -- "	  \t\t\tauto: use Internet when needed (default)\n"
  printf -- "	  \t\t\tdisable: all dependencies must be manually installed, or installation\n"
  printf -- "     \t\t\t\t         fails (create venv with --system-site-packages, run pip with\n"
  printf -- "     \t\t\t\t         --no-build-isolation, disable pip self-update and setuptools_scm)\n"
}

function print_postinst_help {
  local venv_mode="$1"
  local venv_dir="$2"

  if [ "$venv_mode" == "disable" ]; then
    return 0
  else
    printf "# Python extensions are installed to an isolated virtual environment\n"
    printf "# (venv) by default. Prior to using CSXCAD and openEMS in Python, activate\n"
    printf "# your venv in bash/zsh via:\n"
    printf "source %s/bin/activate\n" "${venv_dir}"
  fi
}

function print_help {
  printf -- "Build:\n  %s --cpp-install-dir [CSXCAD/OPENEMS C++ INSTALL DIRECTORY]\n\n" "$0"
  print_python_help
}

function create_python_venv {
  local venv_mode="$1"
  local venv_dir="$2"
  local use_network="$3"

  local pip_opts=()
  if [ "$venv_mode" == "site" ]; then
    pip_opt+=( "--system-site-packages" )
  fi

  # are we running inside a Python venv?
  local in_venv; in_venv=$(python3 -c "import sys; print(int(sys.prefix != sys.base_prefix))")

  if [ "$venv_mode" == "disable" ]; then
    return 0
  elif [ "$venv_mode" == "auto" ] && [ "$in_venv" -eq 1 ]; then
    return 0
  else
    python3 -m venv ${pip_opts[@]+"${pip_opts[@]}"} "$venv_dir"
    source "$venv_dir/bin/activate"

    if [ "$use_network" == "auto" ]; then
      run_pip install --upgrade pip
    fi
  fi
}

function run_pip {
  local pipexec=""

  if command -v pip3 &>/dev/null; then
    pipexec="pip3"
  else
    pipexec="pip"
  fi
  $pipexec "$@"
}

function pip_use_break_system_packages {
  if run_pip install --help | grep -q break-system-packages; then
    # PIP 668 is supported
    echo "--break-system-packages"
  else
    echo ""
  fi
}

function pip_no_build_isolation {
  if run_pip install --help | grep -q no-build-isolation; then
    # build isolation is supported
    echo "--no-build-isolation"
  else
    echo ""
  fi
}

function build_python_extension {
  local venv_mode="$1"
  local use_network="$2"
  local ext="$3"
  local pip_opts=( "--verbose" )

  # are we running inside a Python venv?
  local in_venv; in_venv=$(python3 -c "import sys; print(int(sys.prefix != sys.base_prefix))")
  if [ "$in_venv" -eq 0 ]; then
    pip_opts+=( "--user" )
  fi

  if [ "$venv_mode" == "disable" ]; then
    pip_opts+=( $(pip_use_break_system_packages) )
  fi
  if [ "$use_network" == "disable" ]; then
    pip_opts+=( $(pip_no_build_isolation) )
    export CSXCAD_NOSCM=1
    export OPENEMS_NOSCM=1
  fi

  echo "Build $ext python extension ... please wait"
  cd "$ext/python"

  if ! run_pip install . "${pip_opts[@]}";
  then
    echo "Python module build failed!"
    exit 1
  fi
  cd -
}

function parse_args {
  while true; do
    # "+x" checks whether the variable is unset (not just empty), needed
    # in strict "set -u" mode as it forbids the use of unbounded variables.
    if [ -z ${1+x} ]; then
      break
    fi

    case $1 in
      -h|--help)
        print_help
        exit
	;;
      --help-python)
	# used by update_openEMS.sh
        print_python_help
        exit
        ;;
      --help-postinst)
	# internal, used by update_openEMS.sh
        DRY_RUN=1
	POSTINST_HELP=1
        ;;
      --dry-run)
	# internal, used by update_openEMS.sh
        DRY_RUN=1
	;;

      # parse --cpp-install-dir
      --cpp-install-dir)
        if [ "$2" ]; then
          CPP_INSTALL_DIR="$2"
          shift
        else
          die "ERROR: --cpp-install-dir is specified with an empty value!"
        fi
        ;;
      --cpp-install-dir=?*)
        CPP_INSTALL_DIR=${1#*=}
        ;;
      --cpp-install-dir=)
        die "ERROR: --cpp-install-dir is specified with an empty value!"
        ;;

      # parse --python-venv-mode
      --python-venv-mode)
	if [ -z ${2+x} ] || [ -z "$2" ]; then
          die "ERROR: --python-venv-mode is specified with an empty value!"
        else
          PYTHON_VENV_MODE="$2"
          shift
        fi
        ;;
      --python-venv-mode=?*)
        PYTHON_VENV_MODE=${1#*=}
        ;;
      --python-venv-mode=)
        die "ERROR: --python-venv-mode is specified with an empty value!"
        ;;

      # parse --python-venv-dir
      --python-venv-dir)
	if [ -z ${2+x} ] || [ -z "$2" ]; then
          die "ERROR: --python-venv-dir is specified with an empty value!"
        else
          PYTHON_VENV_DIR="$2"
          shift
        fi
        ;;
      --python-venv-dir=?*)
        PYTHON_VENV_DIR=${1#*=}
        ;;
      --python-venv-dir=)
        die "ERROR: --python-venv-dir is specified with an empty value!"
        ;;

      # parse --python-use-network
      --python-use-network)
	if [ -z ${2+x} ] || [ -z "$2" ]; then
          die "ERROR: --python-use-network is specified with an empty value!"
        else
          PYTHON_USE_NETWORK="$2"
          shift
        fi
        ;;
      --python-use-network=?*)
        PYTHON_USE_NETWORK=${1#*=}
        ;;
      --python-use-network=)
        die "ERROR: --python-use-network is specified with an empty value!"
        ;;

      --)
        shift
        break
        ;;
      -?*)
        die "ERROR: Unknown option $1"
        ;;
      *)
        break
    esac

    shift
  done

  if [ -z "$CPP_INSTALL_DIR" ]; then
    die "No --cpp-install-dir is specified, installation aborted!"
  elif [ ! -d "$CPP_INSTALL_DIR" ]; then
    die "$CPP_INSTALL_DIR does not exist, installation aborted!"
  elif [ -z "$PYTHON_VENV_MODE" ]; then
    die "No --python-venv-mode is specified, installation aborted!"
  elif [ "$PYTHON_VENV_MODE" != "auto" ] &&
       [ "$PYTHON_VENV_MODE" != "venv" ] &&
       [ "$PYTHON_VENV_MODE" != "site" ] &&
       [ "$PYTHON_VENV_MODE" != "disable" ]; then
    die "Invalid --python-venv-mode is specified, see --help, installation aborted!"
  elif [ "$PYTHON_USE_NETWORK" != "auto" ] &&
       [ "$PYTHON_USE_NETWORK" != "disable" ]; then
    die "Invalid --python-use-network is specified, see --help, installation aborted!"
  elif [ -n "$PYTHON_VENV_DIR" ]; then
    if [ "$PYTHON_VENV_MODE" == "disable" ]; then
      die "--python-venv-dir is specified with --python-venv-mode=disable, installation aborted!"
    fi
  fi

  CPP_INSTALL_DIR=$(readlink -f "$CPP_INSTALL_DIR")

  if [ -z "$PYTHON_VENV_DIR" ]; then
    if [[ -n ${VIRTUAL_ENV+x} ]] &&
       [ -n "$VIRTUAL_ENV" ] &&
       [ "$PYTHON_VENV_MODE" == "auto" ]; then
      # A venv is already running, and we're in "auto" mode,
      # use this venv directly.
      PYTHON_VENV_DIR="$VIRTUAL_ENV"
    elif [ "$PYTHON_VENV_MODE" != "disable" ]; then
      # No venv is running, create a new venv at the default path
      PYTHON_VENV_DIR="$CPP_INSTALL_DIR/venv"
    fi
  fi

  if [ "$PYTHON_USE_NETWORK" == "disable" ] &&
     [ "$PYTHON_VENV_MODE" == "auto" ]; then
     PYTHON_VENV_MODE="site"
  fi
}

# default values
DRY_RUN=0
POSTINST_HELP=0
CPP_INSTALL_DIR=""
PYTHON_VENV_MODE="auto"
PYTHON_VENV_DIR=""
PYTHON_USE_NETWORK="auto"
PYTHON_EXT=( "CSXCAD" "openEMS" )

# modifies global variables above
parse_args "$@"

if [ $POSTINST_HELP -eq 1 ]; then
  print_postinst_help "$PYTHON_VENV_MODE" "$PYTHON_VENV_DIR"
fi

if [ $DRY_RUN -eq 1 ]; then
  exit 0;
fi

create_python_venv "$PYTHON_VENV_MODE" "$PYTHON_VENV_DIR" "$PYTHON_USE_NETWORK"

echo "Start building Python extensions against C++ path: $CPP_INSTALL_DIR..."
export CSXCAD_INSTALL_PATH="$CPP_INSTALL_DIR"
export OPENEMS_INSTALL_PATH="$CPP_INSTALL_DIR"

for ext in "${PYTHON_EXT[@]}"; do
  build_python_extension "$PYTHON_VENV_MODE" "$PYTHON_USE_NETWORK" "$ext"
done
