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

# Construct a list of Quantum ESPRESSO static libraries
set(QE_LIBRARIES "")
foreach(libname qe_pw qe_pp qe_kssolver_dense qe_modules qe_modules_c qe_xclib qe_libbeef qe_lax qe_upflib qe_xml qe_utilx qe_utilx_c qe_fftx qe_dftd3 qe_devxlib mbd)
    set(libvar "lib${libname}")
    find_library(${libvar} NAMES ${libname}
        PATHS ${QE_ROOT}
        PATH_SUFFIXES lib build/lib
        NO_DEFAULT_PATH)
    if(${libvar})
        list (APPEND QE_LIBRARIES ${${libvar}})
    endif()
endforeach()

message(STATUS "Found Quantum ESPRESSO libraries: ${QE_LIBRARIES}")
