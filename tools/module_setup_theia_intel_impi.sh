#!/bin/sh

#######################
# Module commands for:
#
#      Host: Theia
#  compiler: Intel
#       MPI: IMPI
#######################

module purge

# Load Intel compilers, NetCDF and HDF5 libraries
module load intel/18.1.163
module load impi/5.1.2.150
module load hdf5/1.8.14
module load netcdf/4.4.0

# Load ecbuild, cmake, boost, eigen
module use /scratch4/BMC/gsd-hpcs/opt/modules/modulefiles
module load ecbuild
module load cmake
module load boost
module load eigen

# Set compilers
export CXX_COMPILER=mpiicpc
export C_COMPILER=mpiicc
export Fortran_COMPILER=mpiifort

# Set additional environment variables required
export NETCDF_ROOT=${NETCDF}

# Set mpi launch command for Theia
MPIEXEC=$(which mpirun)

# Set theia-specific build settings
export PLATFORM_DEFS="-DENABLE_CUDA=OFF"

# List loaded modules
module list
