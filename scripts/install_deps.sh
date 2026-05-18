#!/usr/bin/env bash
# scripts/install_deps.sh — Check or install openEMS build dependencies.
#
# Supported package managers:
#   apt     Debian, Ubuntu, Mint, Pop!_OS
#   dnf     Fedora, AlmaLinux, Rocky Linux, RHEL
#   apk     Alpine Linux
#   pacman  Arch Linux, Manjaro, EndeavourOS, Garuda
#   brew    macOS (Homebrew)
#   pkg     FreeBSD
#
# Alpine note: bash is not installed by default. Run `apk add bash` first.
# FreeBSD note: bash is not installed by default. Run `pkg install bash` first.
# macOS note: tinyxml is not in Homebrew; update_openEMS.sh builds it from
#             source automatically (equivalent to its --with-tinyxml flag).

set -euo pipefail

# Prevent BASH_ENV from propagating set -euo pipefail into package manager
# post-install scripts (dpkg postinst etc.), which may reference unset variables.
unset BASH_ENV

PROG="$(basename "$0")"

# ── Usage ─────────────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
Usage: $PROG [MODE] [OPTIONS]

Check for or install openEMS build dependencies on the current system.

Modes (pick one; default: --check):
  --check     List missing packages and the command to install them.
              Exits 0 if all deps are present, 1 if anything is missing.
  --install   Ask for confirmation, then install missing packages.
  --auto      Install without prompting. Suitable for CI or root environments.

Options:
  --python      Include Python binding deps (Cython, numpy, h5py, matplotlib)
  --disable-gui Exclude Qt and VTK-Qt deps (headless / server builds)
  --with-mpi    Include MPI deps
  --with-ctb    Include Octave (Circuit Toolbox / Matlab interface)
  -h, --help    Show this help
EOF
}

# ── Argument parsing ──────────────────────────────────────────────────────────
MODE=check
WITH_PYTHON=false
WITH_GUI=true
WITH_MPI=false
WITH_OCTAVE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)       MODE=check ;;
    --install)     MODE=install ;;
    --auto)        MODE=auto ;;
    --python)      WITH_PYTHON=true ;;
    --disable-gui|--disable-GUI) WITH_GUI=false ;;
    --with-mpi)    WITH_MPI=true ;;
    --with-ctb)    WITH_OCTAVE=true ;;
    -h|--help)     usage; exit 0 ;;
    *) printf 'Unknown option: %s\n\n' "$1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

# ── OS / package-manager detection ───────────────────────────────────────────
OS_ID=""
PM=""   # apt | dnf | apk | pacman | brew | pkg

detect_system() {
  case "$(uname -s)" in
    Darwin)  OS_ID=macos;   PM=brew; return ;;
    FreeBSD) OS_ID=freebsd; PM=pkg;  return ;;
  esac

  if [[ ! -f /etc/os-release ]]; then
    echo "Cannot detect OS: /etc/os-release not found." >&2; exit 1
  fi
  # shellcheck disable=SC1091
  . /etc/os-release
  OS_ID="${ID:-unknown}"

  case "$OS_ID" in
    ubuntu|debian|linuxmint|pop)     PM=apt ;;
    fedora)                           PM=dnf ;;
    almalinux|rocky|rhel)            PM=dnf ;;
    alpine)                           PM=apk ;;
    arch|manjaro|endeavouros|garuda) PM=pacman ;;
    *)
      printf 'Unsupported distribution: %s\n' "$OS_ID" >&2
      printf 'Supported: Debian, Ubuntu, Fedora, AlmaLinux, Rocky, Alpine, Arch, Manjaro, macOS, FreeBSD\n' >&2
      exit 1 ;;
  esac
}

detect_system

# ── Package lists ─────────────────────────────────────────────────────────────
# Elements may be "pkg1|pkg2|pkg3" — any one alternative satisfies the dep.
# PKGS_VTK    : VTK base library (always included, even without GUI)
# PKGS_VTK_QT : VTK Qt rendering module (only with GUI)
# PKGS_GUI    : Other GUI deps (Qt headers, etc.)

declare -a PKGS_CORE=()
declare -a PKGS_VTK=()
declare -a PKGS_VTK_QT=()
declare -a PKGS_GUI=()
declare -a PKGS_PYTHON=()
declare -a PKGS_OCTAVE=()
declare -a PKGS_MPI=()

case "$PM" in
  apt)
    PKGS_CORE=(
      build-essential git cmake
      libhdf5-dev libtinyxml-dev libboost-all-dev libcgal-dev
    )
    PKGS_VTK=( "libvtk9-dev|libvtk7-dev|libvtk6-dev" )
    PKGS_VTK_QT=( "libvtk9-qt-dev|libvtk7-qt-dev" )
    # libqt6core5compat6-dev: required by QCSXCAD on distros where VTK uses Qt6
    # (Ubuntu 26.04+). Marked optional ('?') so older distros that don't carry
    # the package are not penalised.
    PKGS_GUI=( qtbase5-dev "?libqt6core5compat6-dev" )
    PKGS_PYTHON=(
      python3-pip python3-setuptools python3-setuptools-scm
      cython3 python3-numpy python3-h5py python3-matplotlib python3-venv
    )
    PKGS_OCTAVE=( octave )
    PKGS_MPI=( libopenmpi-dev openmpi-bin )
    ;;

  dnf)
    PKGS_CORE=(
      gcc gcc-c++ cmake git
      boost-devel tinyxml-devel hdf5-devel CGAL-devel
    )
    PKGS_VTK=( vtk-devel )
    PKGS_VTK_QT=( vtk-qt )
    PKGS_GUI=()   # Qt headers are pulled in via vtk-qt on Fedora/AlmaLinux
    PKGS_PYTHON=(
      python3-pip python3-setuptools python3-wheel python3-setuptools_scm
      python3-Cython python3-numpy python3-h5py python3-matplotlib
    )
    PKGS_OCTAVE=( octave )
    PKGS_MPI=( openmpi-devel )
    ;;

  apk)
    PKGS_CORE=(
      bash build-base git cmake
      hdf5-dev tinyxml-dev boost-dev cgal-dev gmp-dev mpfr-dev
    )
    PKGS_VTK=( vtk-dev )
    PKGS_VTK_QT=()   # Alpine VTK is built without Qt
    PKGS_GUI=()
    PKGS_PYTHON=(
      python3-dev py3-pip py3-setuptools py3-setuptools_scm
      cython py3-numpy py3-h5py py3-matplotlib
    )
    PKGS_OCTAVE=( octave )
    PKGS_MPI=( openmpi-dev )
    ;;

  pacman)
    # NOTE: Arch/Manjaro support is best-effort and has not been tested on a
    # clean install. Package names and transitive deps (especially for vtk)
    # may need adjustment. Please report issues or send a PR if you hit problems.
    PKGS_CORE=( gcc make pkgconf git cmake hdf5 tinyxml boost cgal vtk )
    PKGS_VTK=()     # vtk is already in CORE; Arch's vtk includes Qt rendering
    PKGS_VTK_QT=()
    PKGS_GUI=( qt5-base )
    PKGS_PYTHON=(
      python python-pip python-setuptools
      cython python-numpy python-h5py python-matplotlib
    )
    PKGS_OCTAVE=( octave )
    PKGS_MPI=( openmpi )
    ;;

  brew)
    PKGS_CORE=( cmake boost hdf5 cgal vtk )
    # tinyxml is not in Homebrew — update_openEMS.sh --with-tinyxml is auto-enabled on macOS
    PKGS_VTK=()     # vtk is already in CORE; Homebrew vtk includes Qt support
    PKGS_VTK_QT=()
    PKGS_GUI=( qt5compat )
    PKGS_PYTHON=( python3 python-setuptools cython numpy python-matplotlib )
    PKGS_OCTAVE=( octave )
    PKGS_MPI=( open-mpi )
    ;;

  pkg)
    # FreeBSD: Python packages carry a version prefix (py311-, py313-, …).
    # Derive it from the installed python3, fall back to empty.
    _PYVER=""
    if command -v python3 &>/dev/null; then
      _PYVER=$(python3 -c "import sys; print('py{}{}'.format(*sys.version_info[:2]))" 2>/dev/null || true)
    fi
    PKGS_CORE=( bash cmake git boost-libs tinyxml hdf5 cgal python3 )
    PKGS_VTK=( vtk9 )
    PKGS_VTK_QT=()   # Qt for FreeBSD VTK comes via explicit qt5 packages below
    PKGS_GUI=( qt5-core qt5-gui qt5-opengl qt5-xml )
    if [[ -n "$_PYVER" ]]; then
      PKGS_PYTHON=(
        python3
        "${_PYVER}-pip" "${_PYVER}-setuptools" "${_PYVER}-wheel"
        "${_PYVER}-setuptools-scm"
        "${_PYVER}-numpy" "${_PYVER}-h5py" "${_PYVER}-matplotlib"
      )
    else
      PKGS_PYTHON=( python3 )
    fi
    PKGS_OCTAVE=( octave )
    PKGS_MPI=( mpi/openmpi )
    ;;
esac

# Alpine: VTK is built without Qt support — GUI builds are not possible
if [[ "$OS_ID" == alpine && "$WITH_GUI" == true ]]; then
  echo "Note: Alpine Linux builds VTK without Qt. Forcing --disable-gui."
  WITH_GUI=false
fi

# ── Assemble the final package list ───────────────────────────────────────────
declare -a ALL_PKGS=()
ALL_PKGS+=( "${PKGS_CORE[@]}" )
[[ ${#PKGS_VTK[@]}     -gt 0 ]] && ALL_PKGS+=( "${PKGS_VTK[@]}" )
if [[ "$WITH_GUI" == true ]]; then
  [[ ${#PKGS_VTK_QT[@]} -gt 0 ]] && ALL_PKGS+=( "${PKGS_VTK_QT[@]}" )
  [[ ${#PKGS_GUI[@]}    -gt 0 ]] && ALL_PKGS+=( "${PKGS_GUI[@]}" )
fi
[[ "$WITH_PYTHON" == true && ${#PKGS_PYTHON[@]} -gt 0 ]] && ALL_PKGS+=( "${PKGS_PYTHON[@]}" )
[[ "$WITH_OCTAVE" == true && ${#PKGS_OCTAVE[@]} -gt 0 ]] && ALL_PKGS+=( "${PKGS_OCTAVE[@]}" )
[[ "$WITH_MPI"    == true && ${#PKGS_MPI[@]}    -gt 0 ]] && ALL_PKGS+=( "${PKGS_MPI[@]}" )

# ── Privilege helper ──────────────────────────────────────────────────────────
# brew: never sudo; everything else: passthrough if root, sudo otherwise.
_run_privileged() {
  if [[ "$PM" == brew ]]; then
    "$@"
  elif [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  elif command -v sudo &>/dev/null; then
    sudo "$@"
  else
    echo "Error: not running as root and sudo is not available." >&2
    echo "       Re-run as root or install sudo." >&2
    exit 1
  fi
}

# ── Package query / install primitives ───────────────────────────────────────
# Packages prefixed with '?' are optional: if the package is not available in
# the distro's repos at all it is treated as already satisfied (the distro
# version simply doesn't provide or need it). If it IS in the repo but not
# installed it is still reported as missing and installed normally.
_pm_has() {
  local pkg="$1"
  if [[ "$pkg" == \?* ]]; then
    pkg="${pkg:1}"
    case "$PM" in
      apt) apt-cache show "$pkg" &>/dev/null 2>&1 || return 0 ;;
    esac
  fi
  case "$PM" in
    apt)    dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed" ;;
    dnf)    rpm -q --whatprovides "$pkg" &>/dev/null ;;
    apk)    apk info -e "$pkg" &>/dev/null ;;
    pacman) pacman -Q "$pkg" &>/dev/null 2>&1 ;;
    brew)   brew list --formula "$pkg" &>/dev/null 2>&1 ;;
    pkg)    pkg info -e "$pkg" &>/dev/null ;;
  esac
}

# Returns 0 if any alternative in "a|b|c" is installed; sets INSTALLED_ALT.
INSTALLED_ALT=""
_spec_installed() {
  local spec="$1" alt
  IFS='|' read -ra _alts <<< "$spec"
  for alt in "${_alts[@]}"; do
    if _pm_has "$alt"; then INSTALLED_ALT="$alt"; return 0; fi
  done
  INSTALLED_ALT=""; return 1
}

_pm_install_one() {
  local pkg="$1"
  local is_optional=false
  [[ "$pkg" == \?* ]] && { is_optional=true; pkg="${pkg:1}"; }
  local _rc=0
  case "$PM" in
    apt)    _run_privileged env DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg" || _rc=$? ;;
    dnf)    _run_privileged dnf install -y "$pkg" || _rc=$? ;;
    apk)    _run_privileged apk add "$pkg" || _rc=$? ;;
    pacman) _run_privileged pacman -S --noconfirm --needed "$pkg" || _rc=$? ;;
    brew)   brew install "$pkg" || _rc=$? ;;
    pkg)    _run_privileged pkg install -y "$pkg" || _rc=$? ;;
  esac
  if [[ $_rc -ne 0 ]] && ! $is_optional; then return $_rc; fi
  return 0
}

# Install first available alternative in "a|b|c".
_spec_install() {
  local spec="$1" alt
  IFS='|' read -ra _alts <<< "$spec"
  for alt in "${_alts[@]}"; do
    if _pm_install_one "$alt" 2>/dev/null; then return 0; fi
  done
  # Last try with visible error output
  _pm_install_one "${_alts[0]}"
}

_pm_update_index() {
  case "$PM" in
    apt) _run_privileged apt-get update -q ;;
    *)   : ;;   # dnf/apk/pacman/pkg refresh automatically; brew updates on install
  esac
}

_pm_install_prefix() {
  case "$PM" in
    apt)    echo "sudo apt-get install -y" ;;
    dnf)    echo "sudo dnf install -y" ;;
    apk)    echo "sudo apk add" ;;
    pacman) echo "sudo pacman -S" ;;
    brew)   echo "brew install" ;;
    pkg)    echo "sudo pkg install -y" ;;
  esac
}

# ── AlmaLinux / Rocky: enable EPEL + CRB before installing ───────────────────
_repos_ready=false
_ensure_epel_crb() {
  [[ "$_repos_ready" == true ]] && return 0
  echo "  Enabling EPEL and CRB/powertools repositories..."
  _run_privileged dnf install -y epel-release
  _run_privileged dnf config-manager --set-enabled powertools 2>/dev/null || \
    _run_privileged dnf config-manager --set-enabled crb 2>/dev/null || true
  _repos_ready=true
}

# ── Check phase ───────────────────────────────────────────────────────────────
declare -a MISSING=()

_check_all() {
  MISSING=()
  local spec
  for spec in "${ALL_PKGS[@]}"; do
    _spec_installed "$spec" || MISSING+=( "$spec" )
  done
}

# ── Main ──────────────────────────────────────────────────────────────────────
printf 'openEMS dependency check  [%s, pm: %s]\n' "$OS_ID" "$PM"
printf 'Options: GUI=%-3s  Python=%-3s  Octave=%-3s  MPI=%-3s\n\n' \
  "$([[ $WITH_GUI    == true ]] && echo yes || echo no)" \
  "$([[ $WITH_PYTHON == true ]] && echo yes || echo no)" \
  "$([[ $WITH_OCTAVE == true ]] && echo yes || echo no)" \
  "$([[ $WITH_MPI    == true ]] && echo yes || echo no)"

[[ "$PM" == pacman ]] && \
  echo "Warning: Arch/Manjaro support is largely untested. Package names may be" \
       "incomplete or incorrect — please report issues or send a PR." && echo ""

echo "Checking installed packages..."
_check_all

if [[ ${#MISSING[@]} -eq 0 ]]; then
  echo "All required dependencies are installed."
  exit 0
fi

# Print missing packages and the suggested install command
printf '\nMissing (%d):\n' "${#MISSING[@]}"
declare -a _MISSING_PREFERRED=()   # first/preferred name per missing spec
for spec in "${MISSING[@]}"; do
  IFS='|' read -ra _alts <<< "$spec"
  _first="${_alts[0]#\?}"   # strip optional marker for display
  _MISSING_PREFERRED+=( "$_first" )
  if [[ ${#_alts[@]} -gt 1 ]]; then
    printf '  %-36s  (alternatives: %s)\n' "$_first" "${_alts[*]:1}"
  else
    printf '  %s\n' "$_first"
  fi
done

printf '\nSuggested install command:\n'
printf '  %s \\\n    %s\n' "$(_pm_install_prefix)" "${_MISSING_PREFERRED[*]}"

if [[ "$PM" == brew ]]; then
  printf '\nNote: tinyxml is not in Homebrew. update_openEMS.sh builds it from source\n'
  printf '      automatically on macOS (equivalent to its --with-tinyxml flag).\n'
fi

echo ""
[[ "$MODE" == check ]] && exit 1

# ── Install phase ─────────────────────────────────────────────────────────────
if [[ "$MODE" == install ]]; then
  read -r -p "Install missing packages now? [y/N] " _answer
  case "$_answer" in [Yy]*) ;; *) echo "Aborted."; exit 1 ;; esac
  echo ""
fi

# AlmaLinux / Rocky: repos must be enabled before installing
[[ "$OS_ID" =~ ^(almalinux|rocky|rhel)$ ]] && _ensure_epel_crb

echo "Updating package index..."
_pm_update_index

echo "Installing..."
_install_failed=()
for spec in "${MISSING[@]}"; do
  IFS='|' read -ra _alts <<< "$spec"
  printf '  %s' "${_alts[0]#\?}"   # strip optional marker for display
  [[ ${#_alts[@]} -gt 1 ]] && printf ' (or: %s)' "${_alts[*]:1}"
  printf '... '
  if _spec_install "$spec"; then
    echo "ok"
  else
    echo "FAILED" >&2
    _install_failed+=( "$spec" )
  fi
done

# Re-check to confirm everything landed
echo ""
echo "Verifying..."
_check_all

if [[ ${#MISSING[@]} -eq 0 ]]; then
  echo "All dependencies satisfied."
else
  _required_missing=()
  _optional_missing=()
  for spec in "${MISSING[@]}"; do
    IFS='|' read -ra _alts <<< "$spec"
    _all_opt=true
    for _a in "${_alts[@]}"; do [[ "$_a" == \?* ]] || { _all_opt=false; break; }; done
    if $_all_opt; then _optional_missing+=( "$spec" ); else _required_missing+=( "$spec" ); fi
  done

  if [[ ${#_required_missing[@]} -eq 0 ]]; then
    echo "All required dependencies satisfied."
    printf 'Optional packages not available on this distro (%d):\n' "${#_optional_missing[@]}"
    for spec in "${_optional_missing[@]}"; do
      IFS='|' read -ra _alts <<< "$spec"
      printf '  - %s\n' "${_alts[0]#\?}"
    done
  else
    printf 'Still missing after install (%d):\n' "${#_required_missing[@]}"
    for spec in "${_required_missing[@]}"; do
      IFS='|' read -ra _alts <<< "$spec"
      printf '  - %s\n' "${_alts[0]#\?}"
    done
    exit 1
  fi
fi
