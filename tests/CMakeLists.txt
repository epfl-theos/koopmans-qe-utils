###########################################################
# koopmans-qe-utils test suite.
#
# This CMakeLists.txt supports two modes:
#
#   1. In-tree (the default): included via `add_subdirectory(tests)` from
#      the top-level project. Binary paths resolve to build-tree targets
#      via $<TARGET_FILE:...>, so there's no need to install anything
#      before running ctest.
#
#   2. Standalone: used by downstream packagers (conda-forge, Spack, …)
#      whose test environment contains the installed binaries but not
#      the build tree. Invoked as:
#
#          cmake -S tests -B tests/_build
#          ctest --test-dir tests/_build --output-on-failure
#
#      Binary paths are resolved from PATH via find_program; override
#      with -D<NAME>_EXECUTABLE=/abs/path to pin a specific binary.
#
# In both modes the per-test run.sh drivers are identical — only the
# source of the binary paths differs.
###########################################################

cmake_minimum_required(VERSION 3.14)

# Detect whether we are being configured standalone (cmake -S tests)
# or as a subdirectory of the parent koopmans-qe-utils project.
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    project(koopmans-qe-utils-tests LANGUAGES NONE)
    set(KQU_TESTS_STANDALONE ON)
    enable_testing()
else()
    set(KQU_TESTS_STANDALONE OFF)
endif()

find_package(Python3 REQUIRED COMPONENTS Interpreter)
find_program(BASH_EXECUTABLE bash REQUIRED)

# ---------------------------------------------------------
# Resolve binary paths.
# ---------------------------------------------------------
if(KQU_TESTS_STANDALONE)
    find_program(MERGE_EVC_EXECUTABLE merge_evc.x REQUIRED)
    find_program(WANN2KCP_EXECUTABLE  wann2kcp.x  REQUIRED)
    find_program(EPSILON_EXECUTABLE   epsilon.x)
else()
    set(MERGE_EVC_EXECUTABLE $<TARGET_FILE:qe_merge_evc_exe>)
    set(WANN2KCP_EXECUTABLE  $<TARGET_FILE:qe_wann2kcp_exe>)
    set(EPSILON_EXECUTABLE   $<TARGET_FILE:qe_epsilon_exe>)
endif()

# wannier90.x is an external runtime dep; optional in both modes.
find_program(WANNIER90_EXECUTABLE wannier90.x)

# ---------------------------------------------------------
# MPI launch configuration.
# ---------------------------------------------------------
if(KQU_TESTS_STANDALONE)
    find_package(MPI QUIET)
    if(MPI_FOUND)
        set(KQU_TEST_MPIEXEC     "${MPIEXEC_EXECUTABLE}")
        set(KQU_TEST_MPI_NP_FLAG "${MPIEXEC_NUMPROC_FLAG}")
        set(KQU_TEST_MPI_NP      "2")
    else()
        set(KQU_TEST_MPIEXEC     "")
        set(KQU_TEST_MPI_NP_FLAG "")
        set(KQU_TEST_MPI_NP      "1")
    endif()
elseif(QE_ENABLE_MPI)
    set(KQU_TEST_MPIEXEC     "${MPIEXEC_EXECUTABLE}")
    set(KQU_TEST_MPI_NP_FLAG "${MPIEXEC_NUMPROC_FLAG}")
    set(KQU_TEST_MPI_NP      "2")
else()
    set(KQU_TEST_MPIEXEC     "")
    set(KQU_TEST_MPI_NP_FLAG "")
    set(KQU_TEST_MPI_NP      "1")
endif()

# ---------------------------------------------------------
# merge_evc_basic
# ---------------------------------------------------------
add_test(
    NAME merge_evc_basic
    COMMAND ${BASH_EXECUTABLE}
        ${CMAKE_CURRENT_SOURCE_DIR}/merge_evc_basic/run.sh
        ${MERGE_EVC_EXECUTABLE}
        ${Python3_EXECUTABLE}
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_BINARY_DIR}/merge_evc_basic)
set_tests_properties(merge_evc_basic PROPERTIES
    LABELS "koopmans-qe-utils;merge_evc")

# ---------------------------------------------------------
# wann2kcp_basic — needs wannier90.x, a fixtures/ dir, and a ref.dat.
# ---------------------------------------------------------
if(WANNIER90_EXECUTABLE
   AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/wann2kcp_basic/ref.dat
   AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/wann2kcp_basic/fixtures)
    add_test(
        NAME wann2kcp_basic
        COMMAND ${BASH_EXECUTABLE}
            ${CMAKE_CURRENT_SOURCE_DIR}/wann2kcp_basic/run.sh
            ${WANN2KCP_EXECUTABLE}
            ${WANNIER90_EXECUTABLE}
            ${Python3_EXECUTABLE}
            "${KQU_TEST_MPIEXEC}"
            "${KQU_TEST_MPI_NP_FLAG}"
            "${KQU_TEST_MPI_NP}"
            ${CMAKE_CURRENT_SOURCE_DIR}
            ${CMAKE_CURRENT_BINARY_DIR}/wann2kcp_basic)
    set_tests_properties(wann2kcp_basic PROPERTIES
        LABELS "koopmans-qe-utils;wann2kcp")
else()
    message(STATUS
        "Skipping wann2kcp_basic test: "
        "wannier90.x not found, or fixtures/ref.dat missing")
endif()

# ---------------------------------------------------------
# epsilon_basic — needs a fixtures/ dir and a ref.dat.
# ---------------------------------------------------------
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/epsilon_basic/ref.dat
   AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/epsilon_basic/fixtures)
    add_test(
        NAME epsilon_basic
        COMMAND ${BASH_EXECUTABLE}
            ${CMAKE_CURRENT_SOURCE_DIR}/epsilon_basic/run.sh
            ${EPSILON_EXECUTABLE}
            ${Python3_EXECUTABLE}
            "${KQU_TEST_MPIEXEC}"
            "${KQU_TEST_MPI_NP_FLAG}"
            "${KQU_TEST_MPI_NP}"
            ${CMAKE_CURRENT_SOURCE_DIR}
            ${CMAKE_CURRENT_BINARY_DIR}/epsilon_basic)
    set_tests_properties(epsilon_basic PROPERTIES
        LABELS "koopmans-qe-utils;epsilon")
else()
    message(STATUS
        "Skipping epsilon_basic test: fixtures/ref.dat missing")
endif()
