#!/bin/bash

# Set paths to required libraries and compilers.
# Users typically will need to edit these settings for their particular environment
# IMPORTANT: Before initiating a build, ensure "ecbuild" is available in $PATH
#            It can be downloaded from here: https://github.com/ecmwf/ecbuild

export EIGEN_ROOT=/usr
export NETCDF_ROOT=/usr/lib/x86_64-linux-gnu
export CXX_COMPILER=mpicxx
export C_COMPILER=mpicc
export Fortran_COMPILER=mpif90
export BOOST_ROOT=/home/$LOGNAME/Downloads/boost_1_67_0/gnu
export MPIEXEC=$(which mpirun)
export PLATFORM_DEFS="-DENABLE_CUDA=OFF"
