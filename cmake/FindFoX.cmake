#[=======================================================================[.rst:
FindFoX
----------

Find FoX library

This module finds an installed FoX library.

Input Variables
^^^^^^^^^^^^^^^

The following variables may be set to influence this module's behavior:

``FoX_ROOT``
  The path to the installation folder of FoX library

Imported targets
^^^^^^^^^^^^^^^^

This module defines the following :prop_tgt:`IMPORTED` targets:

``FoX::FoX``
``FoX::DOM``
``FoX::SAX``
``FoX::WXML``
``FoX::Common``
``FoX::Utils``
``FoX::FSys``

Result Variables
^^^^^^^^^^^^^^^^

This module will set the following variables in your project:

``FoX_FOUND``
  FoX is found
``FoX_LIBRARIES``
  the libraries needed to use FoX.
``FoX_INCLUDE_DIRS``
  where to find modules and headers for FoX
``FoX_DOM_LIB``
  DOM interface of FoX
``FoX_SAX_LIB``
  SAX interface of FoX
``FoX_WXML_LIB``
  VoiceXML interface of FoX
``FoX_COMMON_LIB``
  Interface for common functions of FoX
``FoX_UTILS_LIB``
  Interface for util functions of FoX
``FoX_FSYS_LIB``
  Interface for file system functions of FoX

#]=======================================================================]
message(STATUS "Looking for FoX in ${FoX_ROOT}")

find_library(
    FoX_DOM_LIB
    NAMES "FoX_dom"
    HINTS ${FoX_ROOT}
    PATH_SUFFIXES "lib")

find_library(
    FoX_SAX_LIB
    NAMES "FoX_sax"
    HINTS ${FoX_ROOT}
    PATH_SUFFIXES "lib")

find_library(
    FoX_WXML_LIB
    NAMES "FoX_wxml"
    HINTS ${FoX_ROOT}
    PATH_SUFFIXES "lib")

find_library(
    FoX_COMMON_LIB
    NAMES "FoX_common"
    HINTS ${FoX_ROOT}
    PATH_SUFFIXES "lib")

find_library(
    FoX_UTILS_LIB
    NAMES "FoX_utils"
    HINTS ${FoX_ROOT}
    PATH_SUFFIXES "lib")

find_library(
    FoX_FSYS_LIB
    NAMES "FoX_fsys"
    HINTS ${FoX_ROOT}
    PATH_SUFFIXES "lib")

set(FoX_LIBRARIES 
    ${FoX_DOM_LIB}
    ${FoX_SAX_LIB}
    ${FoX_WXML_LIB}
    ${FoX_COMMON_LIB}
    ${FoX_UTILS_LIB}
    ${FoX_FSYS_LIB})

find_path(
    FoX_INCLUDE_DIRS
    NAMES "m_common_io.mod"
    HINTS ${FoX_ROOT}
    PATH_SUFFIXES
        "include"
        "finclude")

find_package_handle_standard_args(FoX
  REQUIRED_VARS
    FoX_LIBRARIES
    FoX_DOM_LIB
    FoX_SAX_LIB
    FoX_WXML_LIB
    FoX_COMMON_LIB
    FoX_UTILS_LIB
    FoX_FSYS_LIB)

if(FoX_FOUND)
  add_library(FoX::FoX INTERFACE IMPORTED)
  add_library(FoX::DOM INTERFACE IMPORTED)
  add_library(FoX::SAX INTERFACE IMPORTED)
  add_library(FoX::WXML INTERFACE IMPORTED)
  add_library(FoX::Common INTERFACE IMPORTED)
  add_library(FoX::Utils INTERFACE IMPORTED)
  add_library(FoX::FSys INTERFACE IMPORTED)

  target_link_libraries(FoX::FoX
    INTERFACE 
      FoX::DOM
      FoX::SAX
      FoX::WXML
      FoX::Common
      FoX::Utils
      FoX::FSys)

  target_link_libraries(FoX::DOM INTERFACE ${FoX_DOM_LIB})
  target_link_libraries(FoX::SAX INTERFACE ${FoX_SAX_LIB})
  target_link_libraries(FoX::WXML INTERFACE ${FoX_WXML_LIB})
  target_link_libraries(FoX::Common INTERFACE ${FoX_COMMON_LIB})
  target_link_libraries(FoX::Utils INTERFACE ${FoX_UTILS_LIB})
  target_link_libraries(FoX::FSys INTERFACE ${FoX_FSYS_LIB})
endif()
