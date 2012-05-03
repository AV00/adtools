#
# This makefile drives the native build done on a non-native system, i.e.,
# before building the native compiler, a cross compiler will be build.
# We then build the native compiler using the freshly-built cross
# compiler.
#

ROOT_DIR=$(realpath .)

GMP_ARCHIVE=gmp-5.0.4.tar.bz2
MPFR_ARCHIVE=mpfr-3.1.0.tar.bz2
MPC_ARCHIVE=mpc-0.9.tar.gz

all: gcc-native-done

#
# Downloads the SDK and libraries necesseary to build the cross compiler
#
downloads-done:
	mkdir -p downloads
	wget "http://www.hyperion-entertainment.biz/index.php?option=com_registration&amp;view=download&amp;format=raw&amp;file=38&amp;Itemid=63" -O downloads/SDK_53.20.lha
	cd downloads && wget -N ftp://ftp.gmplib.org/pub/gmp-5.0.4/$(GMP_ARCHIVE)
	cd downloads && wget -N http://www.mpfr.org/mpfr-current/$(MPFR_ARCHIVE)
	cd downloads && wget -N http://www.multiprecision.org/mpc/download/$(MPC_ARCHIVE)
	touch $@

#
# Builds the cross binutils package (assembler, etc).
#
binutils-cross-done:
	make -C ../binutils-build PREFIX=$(ROOT_DIR)/root-cross CROSS_BUILD_DIR=$(ROOT_DIR)/binutils-cross-build
	make -C $(ROOT_DIR)/binutils-cross-build install
	touch $@

#
# Prepares the includes
#
includes-done: downloads-done
	mkdir -p $(ROOT_DIR)/root-cross/ppc-amigaos/SDK/include
	cd downloads && lha x SDK_53.20.lha
	cd downloads/SDK_Install && lha xf clib2*.lha
	cd downloads/SDK_Install && lha xf newlib*.lha
	cd downloads/SDK_Install && lha xf base.lha
	cd downloads/SDK_Install && rm -Rf *.lha
	cd downloads/SDK_Install && mv clib2* newlib* $(ROOT_DIR)/root-cross/ppc-amigaos/SDK
	cd downloads/SDK_Install && mv Include/* $(ROOT_DIR)/root-cross/ppc-amigaos/SDK/include
	rm -Rf downloads/SDK_Install downloads/SDK_Install.info
	touch $@

#
# Build the cross compiler
#
gcc-cross-done: includes-done binutils-cross-done
	make -C ../gcc-build SRC_DIR=../../branches/gcc/4.5.x/ PREFIX=$(ROOT_DIR)/root-cross CROSS_BUILD_DIR=$(ROOT_DIR)/gcc-cross-build VERSION=4.5.3
	make -C $(ROOT_DIR)/gcc-cross-build install
	touch $@

#
# Build and install the libraries
#
libraries-done: gcc-cross-done
	cd downloads && tar -xjf $(GMP_ARCHIVE)
	cd downloads && tar -xjf $(MPFR_ARCHIVE)
	cd downloads && tar -xzf $(MPC_ARCHIVE)
	cd $(basename $(basename downloads/$(GMP_ARCHIVE))) && PATH="$(ROOT_DIR)/root-cross/bin:$(PATH)" ./configure --host=ppc-amigaos --prefix=$(ROOT_DIR)/root-cross && PATH="$(ROOT_DIR)/root-cross/bin:$(PATH)" make install
	cd $(basename $(basename downloads/$(MPFR_ARCHIVE))) && PATH="$(ROOT_DIR)/root-cross/bin:$(PATH)" ./configure --host=ppc-amigaos --prefix=$(ROOT_DIR)/root-cross -with-gmp=$(ROOT_DIR)/root-cross && PATH="$(ROOT_DIR)/root-cross/bin:$(PATH)" make install
	cd $(basename $(basename downloads/$(MPC_ARCHIVE))) && PATH="$(ROOT_DIR)/root-cross/bin:$(PATH)" ./configure --host=ppc-amigaos --prefix=$(ROOT_DIR)/root-cross --with-gmp=$(ROOT_DIR)/root-cross --with-mpfr=$(ROOT_DIR)/root-cross && PATH="$(ROOT_DIR)/root-cross/bin:$(PATH)" make install
	touch $@

#
# Build the native binutils
#
binutils-native-done: libraries-done
	PATH="$(ROOT_DIR)/root-cross/bin:$(PATH)" make -C ../binutils-build PREFIX=/gcc NATIVE_BUILD_DIR=$(ROOT_DIR)/binutils-native-build native
	touch $@

#
# Build the native gcc
#
gcc-native-done: binutils-native-done
	mkdir -p $(ROOT_DIR)/root-native/gcc/include
	PATH="$(ROOT_DIR)/root-cross/bin:$(PATH)" make -C ../gcc-build native \
			SRC_DIR=../../branches/gcc/4.5.x/ \
			PREFIX=/gcc \
			NATIVE_BUILD_DIR=$(ROOT_DIR)/gcc-native-build \
			VERSION=4.5.3 \
			LIB_PATH=$(ROOT_DIR)/root-cross \
			NATIVE_SYS_ROOT=$(ROOT_DIR)/root-native
	touch $@

#
# Install native compiler into /gcc. Needs write acess to this directory
#
native-install: gcc-native-done
	rm -Rf /gcc/*
	make -C binutils-native-build install
	make -C gcc-native-build install
	cp -R $(ROOT_DIR)/root-cross/ppc-amigaos/SDK /gcc
	cp -Rf $(ROOT_DIR)/root-cross/lib/gcc/ppc-amigaos /gcc/lib/gcc/
	# Move lib archives (e.g., libgcc.a into the proper directory)
	cd /gcc/lib/gcc ; for lib in `find -name *.a`; do mkdir -p `dirname $$lib`/lib; mv $$lib `dirname $$lib`/lib ; done

#
# Cleanup everything
#
.PHONY: clean
clean:
	rm -Rf binutils-cross-build binutils-native-build root-cross build-cross-done downloads-done downloads binutils-cross-done binutils-native-done gcc-cross-build gcc-cross-done gcc-native-build includes-done libraries-done