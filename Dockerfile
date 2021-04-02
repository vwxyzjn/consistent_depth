# enable cuda support
FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04

# install native dependencies
RUN apt-get update && apt-get -y install \
    # general
    sudo \
    curl \
    git \
    cmake \
    build-essential \
    ffmpeg \
    # opencv dependencies
    libsm6 \
    libxext6 \
    libxrender-dev \
    libglib2.0-0 \
    # colmap dependencies
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

# install miniconda
RUN curl -OL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash ./Miniconda3-latest-Linux-x86_64.sh -p /opt/miniconda -b && rm ./Miniconda3-latest-Linux-x86_64.sh
ENV PATH=/opt/miniconda/bin:${PATH}

# copy source
WORKDIR /opt/consistent_depth
COPY . .

# install python requirements
RUN conda create -n consistent_depth python=3.6
SHELL ["conda", "run", "-n", "consistent_depth", "bash", "-c"]
RUN bash ./scripts/install.sh

# install colmap
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

RUN mkdir -p colmap-packages && \
    cd colmap-packages && \
    # Install ceres-solver [10-20 min] && \
    sudo apt-get install libatlas-base-dev libsuitesparse-dev && \
    git clone https://ceres-solver.googlesource.com/ceres-solver && \
    cd ceres-solver && \
    git checkout $(git describe --tags) # Checkout the latest release && \
    mkdir build && \
    cd build && \
    cmake .. -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF && \
    make && \
    sudo make install && \

RUN git clone https://github.com/colmap/colmap && \
    cd colmap && \
    git checkout dev && \
    git checkout tags/3.6-dev.3 -b dev-3.6 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    sudo make install && \
    CC=/usr/bin/gcc-6 CXX=/usr/bin/g++-6 cmake .. && \

# download model
RUN bash ./scripts/download_model.sh

# make sure to run commands through conda to setup proper environment
ENTRYPOINT ["conda", "run", "-n", "consistent_depth"]