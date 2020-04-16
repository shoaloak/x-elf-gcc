#!/bin/bash
#
# Install i686 crosscompiler. 
# Based on: https://wiki.osdev.org/GCC_Cross-Compiler

readonly GCC_URL='ftp://ftp.nluug.nl/mirror/languages/gcc/releases/gcc-9.3.0/gcc-9.3.0.tar.xz'
readonly BINUTILS_URL='http://ftp.gnu.org/gnu/binutils/binutils-2.34.tar.xz'
readonly BIN_DIR="$PWD/binutils"
readonly GCC_DIR="$PWD/gcc"

export TARGET=i686-elf
export PREFIX="$HOME/opt/cross"
export PATH="$PREFIX/bin:$PATH"
mkdir -p $PREFIX

function install_binutils() {
	echo -e "\nInstalling Binutils..."

	mkdir $BIN_DIR
	cd $BIN_DIR
	wget $BINUTILS_URL
	tar -vJxf $(ls *.xz)

	SRC=$(echo */)
	mkdir build
	cd build
	../"$SRC"configure --target="$TARGET" --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
	make -j$(nproc)
	make install
}

function install_gcc() {
	echo -e "\nInstalling GCC..."
	which -- $TARGET-as || echo $TARGET-as is not in the path

	mkdir $GCC_DIR
	cd $GCC_DIR
	wget $GCC_URL
	tar -vJxf $(ls *.xz)

	SRC=$(echo */)
	mkdir build
	cd build
	../"$SRC"configure --target="$TARGET" --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers

	make -j$(nproc) all-gcc
	make -j$(nproc) all-target-libgcc
	make install-gcc
	make install-target-libgcc
}

function main() {
	echo "Selected versions:"
	echo $BINUTILS_URL
	echo $GCC_URL
	printf "%0.s-" {1..80}
	echo "This will install $TARGET cross compiler in $PREFIX"
	read -p "Press [Enter] to continue..."

	install_binutils
	printf "%0.s-" {1..80}
	install_gcc
	echo Done!
	echo "Don't forget to add $PREFIX/bin to your path."
}

main "$@"
