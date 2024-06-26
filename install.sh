#!/bin/bash

# Ensure dependencies are installed (adjust package names based on your system)
sudo apt-get update -qq
sudo apt-get -y install \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  libass-dev \
  libfreetype6-dev \
  libgnutls28-dev \
  libmp3lame-dev \
  libsdl2-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  libdav1d-dev \
  libopus-dev \
  libfdk-aac-dev \
  meson \
  pkg-config \
  texinfo \
  yasm \
  wget \
  ninja-build \
  zlib1g-dev \
  libssl-dev \
  nasm \
  libbz2-dev

# Make Dir
mkdir -p ~/ffmpeg_sources ~/bin

# Build and install NASM
echo "----------------------------- nasm ----------------------------"
cd ~/ffmpeg_sources && \
wget https://www.nasm.us/pub/nasm/releasebuilds/2.16rc12/nasm-2.16rc12-xdoc.tar.bz2 && \
tar xxjvf nasm-2.16rc12-xdoc.05.tar.bz2 && \
cd nasm-2.16rc12-xdoc && \
./autogen.sh && \
PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" && \
make && \
make install

# Build and install libx264
echo "----------------------------- lib x264 ----------------------------"
cd ~/ffmpeg_sources && \
git -C x264 pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/x264.git && \
cd x264 && \
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static --enable-pic && \
make && \
make install

# Build and install libx265
echo "----------------------------- libx265 ----------------------------"
sudo apt-get install libnuma-dev && \
cd ~/ffmpeg_sources && \
wget -O x265.tar.bz2 https://bitbucket.org/multicoreware/x265_git/get/master.tar.bz2 && \
tar xjvf x265.tar.bz2 && \
cd multicoreware*/build/linux && \
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED=off ../../source && \
make && \
make install

# Build and install libaom
echo "----------------------------- libaom ----------------------------"
cd ~/ffmpeg_sources && \
git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom && \
mkdir -p aom_build && \
cd aom_build && \
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_TESTS=OFF -DENABLE_NASM=on ../aom && \
make && \
make install

# Build and install libsvtav1
echo "----------------------------- libsvtav1 --------------------------"
cd ~/ffmpeg_sources && \
git -C SVT-AV1 pull 2> /dev/null || git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git && \
mkdir -p SVT-AV1/build && \
cd SVT-AV1/build && \
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DCMAKE_BUILD_TYPE=Release -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=OFF .. && \
make && \
make install

# Build and install srt
echo "----------------------------- srt --------------------------------"
sudo apt-get -y install libssl-dev tclsh && \
cd ~/ffmpeg_sources && \
git clone https://github.com/Haivision/srt.git && \
cd srt && \
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_BINDIR="$HOME/ffmpeg_build/bin" -DCMAKE_INSTALL_INCLUDEDIR="$HOME/ffmpeg_build/include" -DCMAKE_INSTALL_LIBDIR="$HOME/ffmpeg_build/lib" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off && \
make && \
make install

# Update the environment to include the new binaries

# Navigate to the FFmpeg sources directory and proceed with the installation
cd ~/ffmpeg_sources && \
wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
tar xjvf ffmpeg-snapshot.tar.bz2 && \
cd ffmpeg && \
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --extra-libs="-lpthread -lm" \
  --ld="g++" \
  --bindir="$HOME/bin" \
  --enable-libaom \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-gpl \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libsvtav1 \
  --enable-libdav1d \
  --enable-libvorbis \
  --enable-nonfree \
  --enable-openssl \
  --enable-postproc \
  --enable-version3 \
  --enable-libx264 \
  --enable-libx265 \
  --enable-gmp \
  --enable-libfribidi \
  --enable-libfontconfig \
  --enable-libpulse \
  --enable-libsrt && \
make && \
make install && \
hash -r


