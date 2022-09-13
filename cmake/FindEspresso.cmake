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


if(QE_ROOT)
    message(STATUS "Loading Quantum ESPRESSO libraries from ${QE_ROOT}")
else()
    message(FATAL_ERROR "QE_ROOT not provided")
endif()

find_library(libqe_modules NAMES qe_modules qemod
    PATHS ${QE_ROOT}
    PATH_SUFFIXES lib
    REQUIRED)

find_library(libqe_pp NAMES qe_pp pp
    PATHS ${QE_ROOT}
    PATH_SUFFIXES lib
    REQUIRED)

find_library(libqe_pw NAMES qe_pw pw
    PATHS ${QE_ROOT}
    PATH_SUFFIXES lib
    REQUIRED)

set(QE_INCLUDE_DIRS "")
foreach(mod IN ITEMS "kinds" "mp" "klist" "fft_types" "uspp")
    file(GLOB_RECURSE mod_file
        ${QE_ROOT}/**/${mod}.mod)
    get_filename_component(_include_dir ${mod_file} DIRECTORY)
    if(NOT _include_dir)
        message(FATAL_ERROR "Failed to find the ${mod}.mod file")
    endif()
    list (APPEND QE_INCLUDE_DIRS ${_include_dir})
endforeach()
# 
# add_library(Espresso::Espresso INTERFACE IMPORTED)
# set_target_properties(Espresso::Espresso PROPERTIES
#     INTERFACE_INCLUDE_DIRECTORIES "${libqe_include_dir}"
#     INTERFACE_LINK_LIBRARIES "${libqe_modules};${libqe_pp};${libqe_pw}")