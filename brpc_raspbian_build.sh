#!/bin/bash
# check for cmake

if [ "$(command -v cmake)" == "" ]
then
	echo "cmake is needed but seems to be missing, installing..."
	sudo apt-get update && sudo apt-get upgrade
	sudo apt-get install cmake
fi

if [ "$(command -v autoreconf)" == "" ]
then
	echo "autoconf is needed but seems to be missing, installing..."
	sudo apt-get install autoconf
fi

if [ "$(command -v libtoolize)" == "" ]
then
	echo "libtool is needed but seems to be missing, installing..."
	sudo apt-get install libtool
fi

# Check for openssl headers and install if not found
if [ ! -f /usr/include/openssl/ssl.h ]
then
	echo "Openssl development files don't seem to be installed, installing..."
	sudo apt-get install libssl-dev
fi

# TODO the following steps require no input from user and take 3 - 4 hours to run, might be nice to notify user about this...

if [ "$(command -v protoc)" == "" ]
then
	echo "protocompiler (protoc) is needed but seems to be missing, installing..."
	git clone https://github.com/protocolbuffers/protobuf.git
	cd protobuf
	# v3.7.0 is not compatible
	git checkout v3.6.1.3
	git submodule update --init --recursive
	./autogen.sh
	./configure --prefix=/usr
	make
	make check
	sudo make install
	sudo ldconfig
	cd ..
fi

# Clone and build gflags tag v2.2.2
git clone https://github.com/gflags/gflags.git
cd gflags
git checkout v2.2.2
cmake . -DBUILD_SHARED_LIBS=1 -DBUILD_STATIC_LIBS=1
make
cd ..

if [ ! -f /usr/include/leveldb/db.h ]
then
	# Clone, build and install leveldb at v1.20
	# (master requires min version 3.9 of cmake and raspbian came with version 3.7.2 at the time of writing this)
	git clone https://github.com/google/leveldb.git
	cd leveldb
	git checkout v1.20
	make
	sudo mv include/leveldb /usr/include/
	sudo chown root:root /usr/include/leveldb
	sudo chown root:root /usr/include/leveldb/*
	sudo chown root:root out-static/*.a
	sudo mv out-static/*.a /usr/lib/
	sudo chown root:root out-shared/libleveldb.so.1.20
	sudo mv out-shared/libleveldb.so.1.20 /usr/lib/
	sudo ln -s /usr/lib/libleveldb.so.1.20 /usr/lib/libleveldb.so.1
	sudo ln -s /usr/lib/libleveldb.so.1.20 /usr/lib/libleveldb.so
	cd ..
fi

# Clone and build Baidu RPC tag 0.9.5
git clone https://github.com/apache/incubator-brpc.git
cd incubator-brpc
git checkout 0.9.5
./config_brpc.sh --headers="../gflags /usr/include" --libs="../gflags /usr/lib"
# Apply the patches to get the build to pass
cp ../raspberry_pi.patch ./
patch -p1 -i raspberry_pi.patch
# And build it...
make

# Try to build an example
cd ./example/asynchronous_echo_c++/
make

echo "Build script has finished, IF all is well, you should have echo_client and echo_server example programs available in this directory"
echo "Run the test by running ./echo_server & sleep 1 && ./echo_client"

