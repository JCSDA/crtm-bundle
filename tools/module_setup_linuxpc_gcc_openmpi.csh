#!/bin/bash

# Set paths to required libraries and compilers.
# Users typically will need to edit these settings for their particular environment
setenv EIGEN_ROOT /usr
setenv NETCDF_ROOT /usr/lib/x86_64-linux-gnu
setenv CXX_COMPILER mpicxx
setenv C_COMPILER mpicc
setenv Fortran_COMPILER mpif90
setenv BOOST_ROOT /home/$LOGNAME/Downloads/boost_1_67_0/gnu
setenv MPIEXEC `which mpirun`
setenv PLATFORM_DEFS "-DENABLE_CUDA=OFF"
