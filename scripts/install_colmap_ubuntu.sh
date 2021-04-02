# Copyright (c) Facebook, Inc. and its affiliates.

# Install packages
RUN sudo apt-get install -y \
    git \
    cmake \
    build-essential \
    libboost-program-options-dev \
    libboost-filesystem-dev \
    libboost-graph-dev \
    libboost-regex-dev \
    libboost-system-dev \
    libboost-test-dev \
    libeigen3-dev \
    libsuitesparse-dev \
    libfreeimage-dev \
    libgoogle-glog-dev \
    libgflags-dev \
    libglew-dev \
    qtbase5-dev \
    libqt5opengl5-dev \
    libcgal-dev \
    libcgal-qt5-dev

RUN mkdir -p colmap-packages
RUN pushd colmap-packages

RUN # Install ceres-solver [10-20 min]
RUN sudo apt-get install libatlas-base-dev libsuitesparse-dev
RUN git clone https://ceres-solver.googlesource.com/ceres-solver
RUN pushd ceres-solver
RUN git checkout $(git describe --tags) # Checkout the latest release
RUN mkdir build
RUN cd build
RUN cmake .. -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF
RUN make
RUN sudo make install
RUN popd  # pop ceres-solver

RUN # Install colmap-3.6
RUN git clone https://github.com/colmap/colmap
RUN pushd colmap
RUN git checkout dev
RUN git checkout tags/3.6-dev.3 -b dev-3.6
RUN mkdir build
RUN cd build
RUN cmake ..
RUN make
RUN sudo make install
RUN CC=/usr/bin/gcc-6 CXX=/usr/bin/g++-6 cmake ..
RUN popd  # pop colmap
RUN popd
