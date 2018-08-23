#!/bin/sh

# This script is used to build an Amazon Machine Image (AMI) Using the Amazon Linux 2 operating system
# for use with JEDI and other JCSDA applications

# Before running this script it's advised that you create and mount an Elastic File System (EFS)
# as follows
# sudo yum install -y amazon-efs-utils
# mkdir efs
# sudo mount -t efs fs-f63f425f:/ efs

# enter the number of threads here or specify it on the command line
if [ $# -eq 1 ]; then
  nthreads=$1
else
  nthreads=1
fi
nhreads=4
echo "WARNING: nthreads = "$nthreads

# Stop if anything goes wrong
set -ex

# create an empty build directory
builddir="/home/ec2-user/efs/build-aws"
rm -rf $builddir
mkdir -p $builddir

# update packages
sudo yum update

# start with basic tools, including gcc, gfortran, python, doxygen, etc
skip=true
if ! $skip
then
    sudo yum groupinstall "Development Tools"
    git config --global credential.helper 'cache --timeout=3600'
    git config --global --add credential.helper 'store'
    sudo yum install libcurl-devel
    sudo yum install lapack-devel
fi

# Use GNU Compilers
export CC=gcc
export CXX=g++
export FC=gfortran
export F9X=$FC
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="-fPIC"

# install most packages in /usr
export prefix="/usr"

# openmpi
skip=true
if ! $skip
then
    software="openmpi-3.1.1"
    tag="v3.1"
    cd $builddir
    wget https://download.open-mpi.org/release/open-mpi/$tag/$software.tar.gz
    rm -rf $software; tar xvf $software.tar.gz
    cd $software

    export CFLAGS='-fPIC'
    ./configure --prefix=$prefix
    make -j${nthreads}
    make -j${nthreads} check
    sudo make install
    sudo ldconfig
fi

# for parallel builds
export CC=mpicc
export CXX=mpicxx
export FC=mpifort

# cmake
# At last check, the yum package install of cmake is too old - install from source instead
skip=true
if ! $skip
then
    #sudo yum install cmake
    software="cmake-3.12.1"
    name=$(echo $software | cut -d"-" -f1)
    version=$(echo $software | cut -d"-" -f2-)

    cd $builddir
    wget "https://cmake.org/files/v${version%.*}/cmake-$version.tar.gz"
    tar xvf $software.tar.gz
    cd $software
    sudo ./bootstrap
    sudo make -j${nthreads}
    sudo make install
fi

# git-lfs
skip=true
if ! $skip
then
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash
    sudo yum install git-lfs
fi

# boost
skip=true
if ! $skip
then
    software="boost_1_68_0"
    name=$(echo $software | cut -d"_" -f1)
    version=$(echo $software | cut -d"_" -f2-)
    tag=$(echo $version | tr _ .)

    build_boost=$builddir/build_boost

    cd $builddir
    wget https://dl.bintray.com/boostorg/release/$tag/source/$software.tar.gz
    rm -rf $software ; tar -xvf $software.tar.gz
    rm $software.tar.gz
    cd $software/tools/build

    ./bootstrap.sh --with-toolset=gcc
    sudo ./b2 install --prefix=$prefix

    cd $builddir/$software
    b2 --build-dir=$build_boost address-model=64 toolset=gcc stage

    # install
    sudo mv stage/lib/* $prefix/lib
    sudo mv boost $prefix/include

fi

# eigen3
skip=true
if ! $skip
then
    version="3.3.5"
    software="eigen-eigen-b3f3d4950030"
    cd $builddir
    wget http://bitbucket.org/eigen/eigen/get/$version.tar.gz
    rm -rf $software
    tar xvf $version.tar.gz ; cd $software
    mkdir build && cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$prefix
    sudo make install
fi

# zlib
skip=true
if ! $skip
then
    software="zlib-1.2.11"
    cd $builddir
    wget "https://zlib.net/$software.tar.gz"
    rm -rf $software ; tar xvf $software.tar.gz
    cd $software
    ./configure --prefix=$prefix
    make -j${nthreads}
    make -j${nthreads} check
    sudo make install
fi

# szip
skip=true
if ! $skip
then
    software="szip-2.1.1"
    version=$(echo $software | cut -d"-" -f2)
    cd $builddir
    wget "https://support.hdfgroup.org/ftp/lib-external/szip/$version/src/$software.tar.gz"
    rm -rf $software ; tar xvf $software.tar.gz
    cd $software
    ./configure --prefix=$prefix
    make -j${nthreads}
    make -j${nthreads} check
    sudo make install
fi

# JasPer
skip=true
if ! $skip
then
    software="jasper-2.0.14"
    cd $builddir
    wget "http://www.ece.uvic.ca/~frodo/jasper/software/$software.tar.gz"
    rm -rf $software ; tar xvf $software.tar.gz
    
    cd $software
    mkdir build-jasper && cd build-jasper
    cmake -DCMAKE_INSTALL_PREFIX=/usr \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_SKIP_INSTALL_RPATH=YES \
          -DJAS_ENABLE_DOC=NO ../
    make -j${nthreads}
    sudo make install
fi

# hdf5
skip=true
if ! $skip
then
    software="hdf5-1.10.1"
    cd $builddir
    wget https://support.hdfgroup.org/ftp/HDF5/current/src/$software.tar
    rm -rf $software; tar xvf $software.tar
    cd $software
    ./configure --prefix=$prefix --enable-fortran --enable-cxx --enable-hl --enable-shared --with-szlib=$prefix/lib --with-zlib=$prefix/lib
    make -j${nthreads}
    #make -j${nthreads} check
    sudo make install
fi

# netcdf
skip=true
if ! $skip
then
    software="netcdf-4.6.1"
    cd $builddir
    wget https://www.unidata.ucar.edu/downloads/netcdf/ftp/$software.tar.gz
    rm -rf $software; tar xvf $software.tar.gz
    cd $software
    ./configure --prefix=$prefix
    make -j${nthreads}
    make -j${nthreads} check
    sudo make install
fi

# netcdf-fortran
skip=true
if ! $skip
then
    software="netcdf-fortran-4.4.4"
    NCDIR="/usr"
    cd $builddir
    wget https://www.unidata.ucar.edu/downloads/netcdf/ftp/$software.tar.gz
    rm -rf $software; tar xvf $software.tar.gz
    cd $software

    ./configure --prefix=$prefix
    make -j${nthreads}
    make -j${nthreads} check
    sudo make install
fi

# ecbuild
skip=false
if ! $skip
then
   cd $builddir
   git clone https://github.com/ecmwf/ecbuild.git
   git checkout 2.9.0
   mkdir ecbuild-build ; cd ecbuild-build
   cmake ../ecbuild
   sudo make install
fi


# eckit and fckit
skip=false
if ! $skip
then
   installdir="/usr/local"
   sudo yum install ncurses ncurses-devel
   cd $builddir
   git clone https://github.com/ecmwf/eckit.git
   cd eckit
   git checkout 0.22.0
   mkdir ../eckit-build ; cd ../eckit-build
   ecbuild --prefix=$installdir ../eckit
   make -j${nthreads}
   sudo make install

   cd $builddir
   git clone https://github.com/ecmwf/fckit.git
   cd fckit
   git checkout 0.5.2
   mkdir ../fckit-build ; cd ../fckit-build
   ecbuild --prefix=$installdir ../fckit
   make -j${nthreads}
   sudo make install
fi

