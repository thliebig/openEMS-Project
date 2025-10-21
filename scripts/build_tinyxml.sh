#!/usr/bin/env bash

# Unfortunately, TinyXML has been disabled by Homebrew at it has been
# unmaintained since 2011, TinyXML2 is not API-compatible. As a stop-gap,
# we have to build it from source. In the future, we should either
# maintain an openEMS-specific fork (if more systems remove it in the
# future, making it difficult to obtain) or migrate CSXCAD to TinyXML2
# in a big rewrite (non-trivial). As for now, this script is only needed
# for macOS.

# stop the shell on various errors
set -euo pipefail

ALPINE_PREFIX="https://raw.githubusercontent.com/alpinelinux/aports/b1ff376e83eb49c0127b039b3684eccdf9a60694"

FILES=(
  # First, we obtain the last available version of TinyXML.
  "https://sourceforge.net/projects/tinyxml/files/tinyxml/2.6.2/tinyxml_2_6_2.tar.gz"
  "tinyxml-2.6.2.tar.gz"
  "15bdfdcec58a7da30adc87ac2b078e4417dbe5392f3afb719f9ba6d062645593"

  # The first patch enforces use of stl strings, rather than a custom string type.
  "$ALPINE_PREFIX/community/tinyxml/tinyxml-2.6.2-defineSTL.patch"
  "tinyxml-2.6.2-defineSTL.patch"
  "3baf2c4dbc2c8f54a151dac8860113d2f549174f83ed85d552b094dfaebb52af"

  # The second patch is a fix for incorrect encoding of elements with special characters
  "$ALPINE_PREFIX/community/tinyxml/tinyxml-2.6.1-entity.patch"
  "tinyxml-2.6.1-entity.patch"
  "f3d4fba3f8ab884539750c52d51d57261f9e5c1f7035de12c8c284ed7048fd90"

  # The third and fourth patches are security fixes.
  "$ALPINE_PREFIX/community/tinyxml/CVE-2021-42260.patch"
  "CVE-2021-42260.patch"
  "20ab6cb3febcfeaf2e72b8f92ffc04b57995c29e919b1e64f24eb7861a80b676"

  "$ALPINE_PREFIX/community/tinyxml/CVE-2023-34194.patch"
  "CVE-2023-34194.patch"
  "62fc2d31aab823d3d18f725212063d775a553c641a2293a2a72716a40259e261"

  # The final patch adds a CMakeLists.txt file to build a shared library and provide an install target
  # submitted upstream as https://sourceforge.net/p/tinyxml/patches/66/
  "https://gist.githubusercontent.com/scpeters/6325123/raw/cfb079be67997cb19a1aee60449714a1dedefed5/tinyxml_CMakeLists.patch"
  "tinyxml_CMakeLists.patch"
  "32160135c27dc9fb7f7b8fb6cf0bf875a727861db9a07cf44535d39770b1e3c7"
)

function die {
  printf "%s\n" "$1"
  echo "See $0 --help for help"
  exit 1
}

function print_help {
  printf "(1) Build:\n  $0 --build-dir [TEMPORARY DIRECTORY] --install-dir [INSTALL DIRECTORY]\n\n"
  printf "(2) Optional pre-downloading:\n  $0 --download\n\n"
  printf "Optional override for (1) and (2):\n  $0 --download-dir [DOWNLOAD DIRECTORY]\n"
}

function print_sha256_message {
  local expect="$1"
  local actual="$2"

  echo "Expected SHA256: $expect"
  echo "Actual SHA256: $actual"
}

function print_download_hint {
  local download_dir="$1"
  echo ""
  echo "Installation aborted!"
  echo ""
  echo "Hint: If you believe this error occurs due to unreliable networking"
  echo "or unreachable/dead source URL, you can place a file of the same name"
  echo "into $download_dir manually."
}

function sha256 {
  if command -v shasum &>/dev/null; then
    shasum -b -a 256 "$1" | cut -d " " -f 1
  else
    sha256sum "$1" | cut -d " " -f 1
  fi
}

function download {
  local download_dir="$1"

  local len=${#FILES[@]}
  for (( i = 0; i < len; i += 3 )); do
    local url="${FILES[i]}"
    local filename="${FILES[i+1]}"
    local digest="${FILES[i+2]}"

    if [ -f "$download_dir/$filename" ]; then
      local expect_hash="$(sha256 "$download_dir/$filename")"
      local actual_hash="$digest"
      if [ "$expect_hash" == "$actual_hash" ]; then
        echo "Skip download (file exists, hash valid): $download_dir/$filename"
        continue
      else
        echo "Force redownload (file exists, hash invalid): $download_dir/$filename"
        print_sha256_message "$digest" "$(sha256 "$download_dir/$filename")"
        print_download_hint "$download_dir"
     fi
    fi

    # always echo the commands because downloading has a high failure risk
    echo "curl -L $url -o $download_dir/$filename"

    # -L: follow redirect, REQUIRED!
    curl -L $url -o "$download_dir/$filename"

    if [ ! -f "$download_dir/$filename" ]; then
      echo ""
      echo "Unable to download: $download_dir/$filename"
      print_download_hint "$download_dir"
      exit 1
    fi

    local expect_hash="$(sha256 "$download_dir/$filename")"
    local actual_hash="$digest"
    if [ "$expect_hash" != "$actual_hash" ]; then
      echo ""
      echo "Corrupted download (file exists, hash invalid): $download_dir/$filename"
      print_sha256_message "$digest" "$(sha256 "$download_dir/$filename")"
      print_download_hint "$download_dir"
      exit 1
    fi
  done
}

function build {
  local download_dir="$1"
  local build_dir="$2"
  local install_dir="$3"

  cd "$build_dir"
  rm -rf "$build_dir/tinyxml"
  tar -xf "$download_dir/tinyxml-2.6.2.tar.gz"

  cd "$build_dir/tinyxml"
  patch -p1 < "$download_dir/tinyxml-2.6.2-defineSTL.patch"
  patch -p1 < "$download_dir/tinyxml-2.6.1-entity.patch"
  patch -p1 < "$download_dir/CVE-2021-42260.patch"
  patch -p1 < "$download_dir/CVE-2023-34194.patch"

  # You know something is truly deprecated when the patch itself needs
  # patching! In CMake 4, 3.10 is deprecated and 3.5 has been removed.
  # Replace "cmake_minimum_required(VERSION 2.4.6)" in the patch with
  # "cmake_minimum_required(VERSION 3.0...3.10)".
  sed "s/cmake_minimum_required(VERSION 2.4.6)/cmake_minimum_required(VERSION 3.0...3.10)/" \
      "$download_dir/tinyxml_CMakeLists.patch" | patch -p1

  mkdir build && cd build
  cmake ../ "-DCMAKE_INSTALL_PREFIX=$install_dir"
  make && make install
}

DOWNLOAD_ONLY=0
DOWNLOAD_DIR=$(realpath "./downloads")
INSTALL_DIR=""
BUILD_DIR=""

while :; do
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
    --download)
      DOWNLOAD_ONLY=1
      ;;
    --download-dir)
      if [ "$2" ]; then
        DOWNLOAD_DIR="$2"
        shift
      else
        die "ERROR: --download-dir is specified with an empty value!"
      fi
      ;;
    --download-dir=?*)
      DOWNLOAD_DIR=${1#*=}
      ;;
    --download-dir=)
      die "ERROR: --download-dir is specified with an empty value!"
      ;;
    --build-dir)
      if [ "$2" ]; then
        BUILD_DIR="$2"
        shift
      else
        die "ERROR: --build-dir is specified with an empty value!"
      fi
      ;;
    --build-dir=?*)
      BUILD_DIR=${1#*=}
      ;;
    --build-dir=)
      die "ERROR: --install-dir is specified with an empty value!"
      ;;
    --install-dir)
      if [ "$2" ]; then
        INSTALL_DIR="$2"
        shift
      else
        die "ERROR: --install-dir is specified with an empty value!"
      fi
      ;;
    --install-dir=?*)
      INSTALL_DIR=${1#*=}
      ;;
    --install-dir=)
      die "ERROR: --install-dir is specified with an empty value!"
      ;;
    --)
      shift
      break
      ;;
    -?*)
      die "ERROR: Unknown option"
      ;;
    *)
      break
  esac

  shift
done

if (( DOWNLOAD_ONLY )); then
  download "$DOWNLOAD_DIR"
  exit 0
fi

if [ -z "$BUILD_DIR" ]; then
  die "No --build-dir is specified, installation aborted!"
fi
if [ -z "$INSTALL_DIR" ]; then
  die "No --install-dir is specified, installation aborted!"
fi

if [ ! -d "$BUILD_DIR" ]; then
  die "$BUILD_DIR does not exist!"
fi
if [ ! -d "$INSTALL_DIR" ]; then
  die "$INSTALL_DIR does not exist!"
fi

DOWNLOAD_DIR=$(realpath "$DOWNLOAD_DIR")
BUILD_DIR=$(realpath "$BUILD_DIR")
INSTALL_DIR=$(realpath "$INSTALL_DIR")

download "$DOWNLOAD_DIR"
build "$DOWNLOAD_DIR" "$BUILD_DIR" "$INSTALL_DIR"
