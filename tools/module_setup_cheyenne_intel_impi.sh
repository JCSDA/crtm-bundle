#!/bin/sh

#######################
# Module commands for:
#
#      Host: Cheyenne
#  compiler: Intel
#       MPI: IMPI
#######################

module purge

# Load Intel compilers, NetCDF and HDF5 libraries
module load intel/18.0.1
module load mkl/2018.0.1
module load impi/2018.1.163
module load netcdf/4.6.0 

# Load ecbuild, cmake, boost, eigen
module load cmake/3.9.1
module use /glade/u/home/harrop/opt/modules/modulefiles
module load ecbuild
module load boost
module load eigen

# Set additional environment variables required
export NETCDF_ROOT=${NETCDF}

# Set mpi launch command for Cheyenne
MPIEXEC=$(which mpirun)

# List loaded modules
module list
