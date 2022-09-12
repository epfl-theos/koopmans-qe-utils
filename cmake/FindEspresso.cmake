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
endif()

find_library(libqe_pp NAMES qe_pp pp
    PATHS ${QE_ROOT}
    PATH_SUFFIXES lib)

if(NOT libqe_pp)
    message(FATAL_ERROR "libqe_pp not found")
endif()

find_library(libqe_pw NAMES qe_pw pw
    PATHS ${QE_ROOT}
    PATH_SUFFIXES lib)

if(NOT libqe_pw)
    message(FATAL_ERROR "libqe_pw not found")
endif()

add_library(Espresso::Espresso INTERFACE IMPORTED)
target_link_libraries(Espresso::Espresso
  INTERFACE ${ESPRESSO_LIBRARIES})
