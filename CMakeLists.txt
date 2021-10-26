# (C) Copyright 2017 UCAR
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

#
# CRTM bundle
#

#----------------------------------------------------
cmake_minimum_required( VERSION 3.12 FATAL_ERROR )
project(crtm-bundle VERSION 1.0.0 LANGUAGES Fortran)

if(NOT GIT_FOUND)
  find_package(Git QUIET)
endif()

find_package(ecbuild)
set( CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake;${CMAKE_CURRENT_SOURCE_DIR}/ecbuild/cmake;${CMAKE_MODULE_PATH}")
include( ecbuild_bundle )
#-----------------------------------------------------

ecbuild_bundle_initialize()

message("cloning the CRTM repository")
ecbuild_bundle( PROJECT crtm GIT "https://github.com/jcsda/crtm.git" BRANCH master UPDATE )

#message("cloning the CRTM documentation")
#execute_process(
#	COMMAND "${GIT_EXECUTABLE}" clone https://github.com/JCSDA-internal/crtm-documentation.git
#	RESULT_VARIABLE nok ERROR_VARIABLE error
#	WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
#message("${error}")

message("cloning the pycrtm project")
execute_process(
	COMMAND "${GIT_EXECUTABLE}" clone --branch=feature/scikit-build https://github.com/jcsda/pycrtm.git
	RESULT_VARIABLE nok ERROR_VARIABLE error
	WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
message("${error}")


# Build Doxygen documentation
option(BUILD_CRTM_BUNDLE_DOC "Build documentation" OFF)   #to-do with CRTM documentation
if(BUILD_CRTM_BUNDLE_DOC)
   add_subdirectory( Documentation )
endif(BUILD_CRTM_BUNDLE_DOC)

ecbuild_bundle_finalize()

include(CTest)

