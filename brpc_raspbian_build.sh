#!/bin/bash
# check for cmake

date > build_progress.log
echo "Checking and installing required tools from repos..." >> build_progress.log
sudo apt-get update && sudo apt-get upgrade

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

echo "A FRIENDLY NOTICE:"
echo "WILL BEGIN BUILDING DEPENDENCIES AND BRPC NOW."
echo "THIS WILL USUALLY TAKE 3 - 4 HOURS SO I'D SUGGEST YOU GO DO SOMETHING ELSE WHILE WAITING"
echo "PRESS A KEY TO CONTINUE..."
read -n 1 -p "" ignored
echo "STARTING THE BUILD..."
date >> build_progress.log
echo "Building dependencies and brpc THIS WILL TAKE 3 - 4 HOURS, SUGGEST YOU'D GO DO SOMETHING ELSE WHILE WAITING..." >> build_progress.log
echo "Building protobuf..." >> build_progress.log
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

date >> build_progress.log
echo "Building gflags..." >> build_progress.log
# Clone and build gflags tag v2.2.2
git clone https://github.com/gflags/gflags.git
cd gflags
git checkout v2.2.2
cmake . -DBUILD_SHARED_LIBS=1 -DBUILD_STATIC_LIBS=1
make
cd ..

date >> build_progress.log
echo "Building leveldb..." >> build_progress.log
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

date >> build_progress.log
echo "Checking out incubator-brpc tag 0.9.5..." >> build_progress.log
# Clone and build Baidu RPC tag 0.9.5
git clone https://github.com/apache/incubator-brpc.git
cd incubator-brpc
git checkout 0.9.5
date >> build_progress.log
echo "Configuring brpc..." >> build_progress.log
./config_brpc.sh --headers="../gflags /usr/include" --libs="../gflags /usr/lib"
# Apply the patches to get the build to pass
cp ../raspberry_pi.patch ./
date >> build_progress.log
echo "Patching brpc for Raspberry PI..." >> build_progress.log
patch -p1 -i raspberry_pi.patch
# And build it...
date >> build_progress.log
echo "Building brpc..." >> build_progress.log
make

# Try to build an example
date >> build_progress.log
echo "Building asynchronous_echo example for brpc..." >> build_progress.log
cd ./example/asynchronous_echo_c++/
make

echo "Build script has finished, IF all is well, you should have echo_client and echo_server example programs available in ./incubator-brpc/example/asynchronous_echo_c++/"
echo "Try the example by ./incubator-brpc/example/asynchronous_echo_c++/echo_server & sleep 1 && ./incubator-brpc/example/asynchronous_echo_c++/echo_client"
date >> build_progress.log
echo "FINISHED" >> build_progress.log

