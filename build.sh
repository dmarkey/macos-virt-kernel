#!/bin/sh
wget https://github.com/cli/cli/releases/download/v2.17.0/gh_2.17.0_linux_amd64.deb
dpkg -i gh_2.17.0_linux_amd64.deb
if [ ! -d mnt ]; then
   apt update
   apt install -y wget xz-utils patch bc make clang llvm lld flex bison libelf-dev libncurses-dev libssl-dev git 
fi

if [ ! -d linux ]; then
    wget -O linux.tar.xz https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$(cat linux.version).tar.xz
    mkdir linux
    cd linux
    tar xf ../linux.tar.xz --strip-components=1
    cd ..
    rm linux.tar.xz
fi
cd linux
cp ../linux.config .config
#make
if [ ! "aarch64" = "$(uname -m)" ]; then
    echo "cross compiling on $(uname -m)"
    export CROSS_COMPILE=aarch64-pc-linux-gnu
fi
#ARCH=arm64 make CC=clang LLVM=1 LLVM_IAS=1 -j2 $*
cp .config ../linux.config
#cp arch/arm64/boot/Image ../vmlinuz-arm64
#cp arch/x86/boot/bzImage ../vmlinuz-amd64
touch ../vmlinuz-arm64
touch ../vmlinuz-amd64

cd ..
gzip vmlinuz-arm64
mv vmlinuz-arm64.gz vmlinuz-arm64
echo 
echo Branch:$BRANCH
if [ "$BRANCH" = "master" ] ; then
    mkdir release_assets
    cp vmlinuz-arm64 release_assets
    cp vmlinuz-amd64 release_assets
    $release_name=$(git log -1 --format=%cd-%h --date=format:'%Y-%m-%d')
    gh release create $release_name release_assets/*
fi
