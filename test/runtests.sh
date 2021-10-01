#!/bin/bash
set -euox pipefail

abspath() {
    [[ $1 = /* ]] && echo "$1" || echo "${PWD}/${1#./}"
}
REPO_ROOT=$(dirname "$(dirname "$(abspath "$0")")")
rm -rf "${REPO_ROOT}"/build
rm -rf "${REPO_ROOT}"/Project.toml
rm -rf "${REPO_ROOT}"/Manifest.toml

YGGBINDIR=$(mktemp -d)
trap 'rm -rf "${REPO_ROOT}"/build "${YGGBINDIR}"' EXIT

# Installation
## default location
make
if [ ! -x "${REPO_ROOT}"/build/bin/ygg ]; then exit 1; fi
rm ./build/bin/ygg
if [ -x "${REPO_ROOT}"/build/bin/ygg ]; then exit 1; fi
make ygg
if [ ! -x "${REPO_ROOT}"/build/bin/ygg ]; then exit 1; fi
rm ./build/bin/ygg
if [ -x "${REPO_ROOT}"/build/bin/ygg ]; then exit 1; fi
make install-ygg
if [ ! -x "${REPO_ROOT}"/build/bin/ygg ]; then exit 1; fi
## specified location
YGGBINDIR="${YGGBINDIR}" make ygg
if [ ! -x "${YGGBINDIR}"/ygg ]; then exit 1; fi
export PATH=${YGGBINDIR}:${PATH}
if [ ! "$(which ygg)" = "${YGGBINDIR}"/ygg ]; then exit 1; fi

# ygg binary
## no arguments -- print help and exit with 1
ygghelp=$(ygg || exit 0 )
if [[ "${ygghelp}" != "Usage:"* ]]; then exit 1; fi
if [[ "${ygghelp}" != *"ygg install <binary>"* ]]; then exit 1; fi
## self-update
ygg update ygg
if [ ! -x "${YGGBINDIR}"/ygg ]; then exit 1; fi
## suicide
ygg uninstall ygg
if [ -x "${YGGBINDIR}"/ygg ]; then exit 1; fi
## rise like a phoenix
YGGBINDIR="${YGGBINDIR}" make ygg
if [ ! -x "${YGGBINDIR}"/ygg ]; then exit 1; fi

# Test installation of jll binaries
test_binary() {
    ygg install "$1"
    if [ ! -x "${YGGBINDIR}"/"$1" ]; then exit 1; fi
    ygg update "$1"
    if [ ! -x "${YGGBINDIR}"/"$1" ]; then exit 1; fi
    if [ ! "$(which "$1")" = "${YGGBINDIR}"/"$1" ]; then exit 1; fi
    local smoketest=${2-$1 --version}
    if [ -n "${smoketest}" ]; then
        ${smoketest}
    fi
    ygg uninstall "$1"
    if [ -x "${YGGBINDIR}"/"$1" ]; then exit 1; fi
    hash -r # forget the cached path
}

test_binary git
test_binary zstd

if [ "${YGG_FULL_TEST-}" = 1 ]; then
    test_binary convert
    test_binary duf
    test_binary ffmpeg "ffmpeg -version"
    test_binary ffprobe "ffprobe -version"
    test_binary fzf
    test_binary gh
    test_binary ghr
    test_binary git-crypt
    test_binary gof3r
    test_binary identify
    test_binary kubectl "kubectl --help"
    test_binary pandoc
    test_binary pandoc-crossref
    test_binary rr
    test_binary unpaper
    test_binary tectonic
    test_binary tokei
    test_binary zstdmt
    test_binary rclone
    test_binary node
    test_binary clang
    test_binary clang++
    test_binary pdfattach "" # No command with error code 0...
    test_binary pdfdetach "" # No command with error code 0...
    test_binary pdffonts "pdffonts -v"
    test_binary pdfimages "pdfimages -v"
    test_binary pdfinfo "pdfinfo -v"
    test_binary pdfseparate "pdfseparate -v"
    test_binary pdftocairo "pdftocairo -v"
    test_binary pdftohtml "pdftohtml -v"
    test_binary pdftoppm "pdftoppm -v"
    test_binary pdftops "pdftops -v"
    test_binary pdftotext "pdftotext -v"
    test_binary pdfunite "pdfunite -v"
fi

echo "Test pass"
