#!/bin/bash
set -e

echo "Installing DVMDOSTEM dependencies..."

MODINSTALLPATH=/usr/local
DOWNLOADPATH=/dependencies

mkdir -p ${DOWNLOADPATH}
cd ${DOWNLOADPATH}

# Install system packages
echo "Installing system packages..."
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential git-all libbz2-dev libffi-dev libgdbm-dev \
    libjsoncpp-dev liblapacke-dev liblzma-dev libncurses-dev \
    libreadline-dev libssl-dev libsqlite3-dev libxml2-dev libz-dev \
    nco ncview python3-pip tk-dev wget curl openmpi-bin openmpi-common libopenmpi-dev

# Create symlink for jsoncpp headers
echo "Creating jsoncpp symlink..."
ln -sf /usr/include/jsoncpp/json /usr/include/json

# Install Boost
echo "Installing Boost 1.80.0..."
cd ${DOWNLOADPATH}
wget https://archives.boost.io/release/1.80.0/source/boost_1_80_0.tar.gz
tar -xzf boost_1_80_0.tar.gz
cd boost_1_80_0
./bootstrap.sh
echo "using mpi : mpicc ;" >> project-config.jam 
./b2 -j$(nproc) install 2>&1 | tee ${DOWNLOADPATH}/boost_install.out

# Install HDF5
echo "Installing HDF5 1.10.9..."
cd ${DOWNLOADPATH}
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.9/src/hdf5-1.10.9.tar.gz
tar -xzf hdf5-1.10.9.tar.gz
cd hdf5-1.10.9
CC=mpicc ./configure --enable-parallel --prefix=${MODINSTALLPATH} CFLAGS=-fPIC
make -j$(nproc) install 2>&1 | tee ${DOWNLOADPATH}/hdf5_install.out

# Install NetCDF with parallel support
echo "Installing NetCDF 4.4.1.1 with parallel support..."
cd ${DOWNLOADPATH}
wget https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.4.1.1.tar.gz
tar -xzf v4.4.1.1.tar.gz
cd netcdf-c-4.4.1.1/
CC=mpicc CPPFLAGS="-I${MODINSTALLPATH}/include" LDFLAGS="-L${MODINSTALLPATH}/lib" ./configure --enable-parallel --prefix=${MODINSTALLPATH}
make -j$(nproc) install 2>&1 | tee ${DOWNLOADPATH}/netcdf_install.out

# Update library path
echo "export LD_LIBRARY_PATH=${MODINSTALLPATH}/lib:\$LD_LIBRARY_PATH" >> /etc/profile.d/netcdf.sh
ldconfig

echo "DVMDOSTEM dependencies installed successfully!"
