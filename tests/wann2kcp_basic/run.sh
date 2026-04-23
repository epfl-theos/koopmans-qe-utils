#!/bin/bash
#
# Driver for the wann2kcp_basic ctest case. The .save/ directory is shipped as
# a static HDF5 fixture (portable across machines when QE is built with
# -DQE_ENABLE_HDF5=ON). Wannier90's .chk is *not* portable — it's regenerated
# from the fixture .amn/.mmn/.eig/.win by running wannier90.x before wann2kcp.x.
#
# Scalar comparison is against the evcw*.dat files wann2kcp writes, via the
# pure-Python summarize_evc helper. Each label is prefixed by the filename so
# both blocks coexist in a single actual.dat.
#
#   $1: wann2kcp.x binary
#   $2: wannier90.x binary
#   $3: python3 interpreter
#   $4: mpiexec executable (empty string if MPI disabled)
#   $5: mpiexec numproc flag
#   $6: mpiexec numproc value
#   $7: tests/ source dir
#   $8: working dir (created fresh)
#
set -euo pipefail

WANN2KCP=$1
WANNIER90=$2
PYTHON=$3
MPIEXEC=$4
MPI_NP_FLAG=$5
MPI_NP=$6
TESTS_DIR=$7
WORK_DIR=$8

TEST_DIR=${TESTS_DIR}/wann2kcp_basic
COMMON=${TESTS_DIR}/common

rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"

# Stage fixture files + the wann2kcp namelist into the working directory.
cp -r "${TEST_DIR}/fixtures/." .
cp "${TEST_DIR}/wann2kcp.in" .

# The seedname must match the `seedname = '...'` value in wann2kcp.in and the
# basename of the shipped wannier90.* fixture files.
SEEDNAME=wannier90

# 1. Regenerate the Wannier90 checkpoint <seedname>.chk from .amn/.mmn/.eig/.win.
"${WANNIER90}" "${SEEDNAME}"

# 2. Run wann2kcp.x.
if [[ -n "${MPIEXEC}" ]]; then
    "${MPIEXEC}" "${MPI_NP_FLAG}" "${MPI_NP}" "${WANN2KCP}" < wann2kcp.in > wann2kcp.out
else
    "${WANN2KCP}" < wann2kcp.in > wann2kcp.out
fi

# 3. Summarise each evcw*.dat with a filename-prefixed label, then concat.
: > actual.dat
for f in evcw*.dat; do
    [[ -f "$f" ]] || continue
    "${PYTHON}" "${COMMON}/summarize_evc.py" "$f" \
        | awk -v f="$f" '{ printf "%s_%s", f, $1; for (i=2;i<=NF;i++) printf " %s", $i; printf "\n" }' \
        >> actual.dat
done

# 4. Compare.
"${PYTHON}" "${COMMON}/compare.py" actual.dat "${TEST_DIR}/ref.dat"
