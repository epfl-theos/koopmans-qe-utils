#[=======================================================================[.rst:
FindEspresso
----------

Find Espresso libraries

This module finds installed libraries associated with Quantum ESPRESSO

Input Variables
^^^^^^^^^^^^^^^

The following variables may be set to influence this module's behavior:

``QE_ROOT``
  The path to the installation folder of Quantum ESPRESSO

Result Variables
^^^^^^^^^^^^^^^^

This module will set the following variables in your project:

``ESPRESSO_LIBRARIES``
  the libraries provided by QE

#]=======================================================================]

if(NOT QE_ROOT)
    message(FATAL_ERROR "QE_ROOT not provided")
elseif(NOT EXISTS ${QE_ROOT})
    message(FATAL_ERROR "QE_ROOT=${QE_ROOT} does not exist")
else()
    message(STATUS "Looking for Quantum ESPRESSO libraries in ${QE_ROOT}")
endif()

# Construct list of directories containing *.mod files
set(QE_INCLUDE_DIRS "")
file(GLOB_RECURSE mod_files
    ${QE_ROOT}/**/*.mod)
foreach(mod_file IN LISTS mod_files)
    get_filename_component(_include_dir ${mod_file} DIRECTORY)
    if(NOT _include_dir)
        message(FATAL_ERROR "Failed to find ${mod_file}")
    endif()
    list (APPEND QE_INCLUDE_DIRS ${_include_dir})
endforeach()
list (REMOVE_DUPLICATES QE_INCLUDE_DIRS)

if(QE_INCLUDE_DIRS)
    message(STATUS "Found Quantum ESPRESSO modules: ${QE_INCLUDE_DIRS}")
else()
    message(FATAL_ERROR "Failed to find Quantum ESPRESSO modules")
endif()

# Construct a list of Quantum ESPRESSO static libraries.
# This is the full set required to link koopmans-qe-utils against a
# static QE build:
#   - qe_pw, qe_pp, qe_modules, qe_fftx, qe_utilx, qe_upflib: provide
#     Fortran modules USEd directly by our sources.
#   - qe_lax, qe_xclib, qe_devxlib, qe_dftd3, qe_device_lapack,
#     qe_kssolver_dense, mbd, qe_xml, qe_libbeef: PRIVATE link-time
#     dependencies of qe_pw / qe_pp / qe_xclib that must be on the
#     link line because QE ships static archives with unresolved
#     transitive references.
#   - qe_modules_c, qe_utilx_c, qe_fftx_c: C-side companions holding
#     BIND(C) implementations the Fortran libraries call.
set(QE_LIBRARIES "")
foreach(libname
        qe_pw qe_pp qe_modules qe_modules_c
        qe_fftx qe_fftx_c qe_utilx qe_utilx_c qe_upflib
        qe_lax qe_xclib qe_libbeef qe_xml qe_devxlib qe_dftd3
        qe_device_lapack qe_kssolver_dense mbd)
    set(libvar "lib${libname}")
    find_library(${libvar} NAMES ${libname}
        PATHS ${QE_ROOT}
        PATH_SUFFIXES lib build/lib
        NO_DEFAULT_PATH
        REQUIRED)
    list (APPEND QE_LIBRARIES ${${libvar}})
endforeach()

message(STATUS "Found Quantum ESPRESSO libraries: ${QE_LIBRARIES}")

# QE's static archives have circular references (e.g. qe_kssolver_dense
# → qe_lax), so single-pass linkers (GNU ld / LLD on Linux and *BSD)
# can't resolve symbols without being told to rescan. Wrap the list in
# --start-group / --end-group on those platforms. macOS ld64 and
# Windows link.exe iterate by default and reject these options.
if(NOT APPLE AND NOT WIN32)
    set(QE_LIBRARIES
        "-Wl,--start-group" ${QE_LIBRARIES} "-Wl,--end-group")
endif()
