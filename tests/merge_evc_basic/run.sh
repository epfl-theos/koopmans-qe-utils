#!/bin/bash
#
# Driver for the merge_evc_basic ctest case. Invoked from tests/CMakeLists.txt
# with paths supplied as arguments so the script has no knowledge of where
# the build tree lives.
#
#   $1: merge_evc.x binary
#   $2: python3 interpreter
#   $3: tests/ source dir (for common/ helpers and ref.dat)
#   $4: working dir (created fresh for this test)
#
set -euo pipefail

MERGE_EVC=$1
PYTHON=$2
TESTS_DIR=$3
WORK_DIR=$4

TEST_DIR=${TESTS_DIR}/merge_evc_basic
COMMON=${TESTS_DIR}/common

rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"

# 1. Generate deterministic input wavefunction files.
#    Each of nbnd1 and nbnd2 must be divisible by nrtot; here nrtot=1.
NPW=12
NBND1=2
NBND2=2
"${PYTHON}" "${COMMON}/gen_merge_evc_inputs.py" \
    input1.evc input2.evc ${NPW} ${NBND1} ${NBND2}

# 2. Merge them.
"${MERGE_EVC}" -nr 1 -i input1.evc -i input2.evc -o merged.evc

# 3. Produce a deterministic scalar summary of the merged output.
"${PYTHON}" "${COMMON}/summarize_evc.py" merged.evc > actual.dat

# 4. Compare against the checked-in reference.
"${PYTHON}" "${COMMON}/compare.py" actual.dat "${TEST_DIR}/ref.dat"
