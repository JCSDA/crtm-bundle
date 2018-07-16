#!/bin/bash

# Stop if anything goes wrong
set -e

# Get build options from command line
if [ $# -ne 4 ] && [ $# -ne 5 ]; then
  echo "Usage:  $0 host compiler mpi debug|release [#threads for parallel make]"
  exit 1
fi
host=$1
compiler=$2
mpi=$3
buildtype=$4
if [ $# -eq 5 ]; then
  nthreads=$5
else
  nthreads=1
fi

# Set up the modules for building JEDI
source ./module_setup_${host}_${compiler}_${mpi}.sh

# Create an empty build directory
builddir=../build_${host}_${compiler}_${mpi}_${buildtype}
rm -rf $builddir
mkdir -p $builddir
cd $builddir

# Make sure eckit and fckit are included in the CMakeLists.txt file
sed -i 's/#ecbuild_bundle( PROJECT eckit/ecbuild_bundle( PROJECT eckit/' ..//CMakeLists.txt
sed -i 's/#ecbuild_bundle( PROJECT fckit/ecbuild_bundle( PROJECT fckit/' ..//CMakeLists.txt

# Run ecbuild cmake wrapper
ecbuild \
    --build=${buildtype} \
    -DCMAKE_CXX_COMPILER=${CXX_COMPILER} \
    -DCMAKE_C_COMPILER=${C_COMPILER} \
    -DCMAKE_Fortran_COMPILER=${Fortran_COMPILER} \
    -DBOOST_ROOT=$BOOST_ROOT -DBoost_NO_SYSTEM_PATHS=ON \
    -DMPIEXEC=$MPIEXEC \
    -DMPIEXEC_EXECUTABLE=$MPIEXEC \
    -- \
    ${PLATFORM_DEFS} \
    ..

# Build JEDI
make -j${nthreads} VERBOSE=1

# Test JEDI
#ctest

# Install
#make install
