#!/bin/bash
#
# Driver for the epsilon_basic ctest case. The .save/ directory is shipped as
# a static HDF5 fixture — no pw.x run required. Only epsilon.x is exercised.
#
#   $1: epsilon.x binary
#   $2: python3 interpreter
#   $3: mpiexec executable (empty string if MPI disabled)
#   $4: mpiexec numproc flag
#   $5: mpiexec numproc value
#   $6: tests/ source dir
#   $7: working dir
#
set -euo pipefail

EPSILON=$1
PYTHON=$2
MPIEXEC=$3
MPI_NP_FLAG=$4
MPI_NP=$5
TESTS_DIR=$6
WORK_DIR=$7

TEST_DIR=${TESTS_DIR}/epsilon_basic

rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"

cp -r "${TEST_DIR}/fixtures/." .

if [[ -n "${MPIEXEC}" ]]; then
    "${MPIEXEC}" "${MPI_NP_FLAG}" "${MPI_NP}" "${EPSILON}" < epsilon.in > epsilon.out
else
    "${EPSILON}" < epsilon.in > epsilon.out
fi

bash "${TEST_DIR}/extract.sh" > actual.dat

"${PYTHON}" "${TESTS_DIR}/common/compare.py" actual.dat "${TEST_DIR}/ref.dat"
