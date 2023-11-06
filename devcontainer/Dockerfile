FROM ubuntu:22.04 as doxygen-build
RUN apt update && apt install -y git cmake ninja-build g++ flex bison python3
RUN git clone --depth 1 https://github.com/CHERIoT-Platform/llvm-project
RUN mkdir llvm-project/build
WORKDIR llvm-project/build
# Build a minimal static libclang.
# Unfortunately, when statically linking, LLVM_DISTRIBUTION_COMPONENTS doesn't
# find any of the dependencies and so these all have to be listed explicitly.
RUN cmake \
	../llvm \
	-DCMAKE_BUILD_TYPE=Release \
	-DLLVM_ENABLE_PROJECTS="clang" \
	-DLLVM_ENABLE_UNWIND_TABLES=NO \
	-DLLVM_PARALLEL_LINK_JOBS=1 \
	-DCLANG_ENABLE_ARCMT=OFF \
	-DCLANG_ENABLE_STATIC_ANALYZER=OFF \
	-DLIBCLANG_BUILD_STATIC=ON \
	-DBUILD_SHARED_LIBS=OFF \
	-DLLVM_ENABLE_PIC=OFF \
	-DLLVM_BUILD_LLVM_DYLIB=OFF \
	-DLLVM_BUILD_LLVM_C_DYLIB=OFF \
	-DLLVM_TARGETS_TO_BUILD=RISCV \
	-DLLVM_ENABLE_TERMINFO=OFF \
	-DLLVM_DISTRIBUTION_COMPONENTS="libclang;LLVMAggressiveInstCombine;LLVMAnalysis;LLVMAsmPrinter;LLVMBinaryFormat;LLVMBitReader;LLVMBitWriter;LLVMBitstreamReader;LLVMCodeGen;LLVMCore;LLVMDebugInfoCodeView;LLVMDebugInfoDWARF;LLVMDebugInfoMSF;LLVMDemangle;LLVMFrontendOpenMP;LLVMGlobalISel;LLVMInstCombine;LLVMMC;LLVMMCDisassembler;LLVMMCParser;LLVMObject;LLVMOption;LLVMProfileData;LLVMRISCVAsmParser;LLVMRISCVCodeGen;LLVMRISCVDesc;LLVMRISCVDisassembler;LLVMRISCVInfo;LLVMRemarks;LLVMScalarOpts;LLVMSelectionDAG;LLVMSupport;LLVMTarget;LLVMTransformUtils;clangAST;clangASTMatchers;clangAnalysis;clangBasic;clangDriver;clangEdit;clangFormat;clangFrontend;clangIndex;clangLex;clangParse;clangRewrite;clangSema;clangSerialization;clangTooling;clangToolingCore;clangToolingInclusions;LLVMTextAPI"  \
	-DLLVM_INSTALL_TOOLCHAIN_ONLY=OFF \
	-DCMAKE_INSTALL_PREFIX=/llvm \
	-G Ninja
# Install libclang and any headers and CMake bits that we've built.
RUN NINJA_STATUS='%p [%f:%s/%t] %o/s, %es ' ninja install-distribution install-cmake-exports install-clang-cmake-exports install-llvm-headers install-clang-headers
WORKDIR /
# Clone doxygen and build it using the libclang that we've just built.
RUN git clone https://github.com/doxygen/doxygen.git && cd doxygen && git checkout Release_1_9_8
RUN mkdir -p doxygen/build
WORKDIR /doxygen/build
RUN cmake -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_FIND_ROOT_PATH=/llvm/lib/cmake \
	-DCMAKE_INSTALL_PREFIX=/doxygen \
	"-DCMAKE_FIND_LIBRARY_SUFFIXES=.a" \
	-DLLVM_ROOT=/llvm-project/build \
	-Duse_libclang=YES \
	-Dstatic_libclang=YES \
	-G Ninja \
	..
RUN NINJA_STATUS='%p [%f:%s/%t] %o/s, %es ' ninja install

# Now assemble the clean container.
FROM ubuntu:22.04
# AsciiDoxy depends on Python and Ruby, so install both
RUN apt update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt install -y pip rubygems
# Install the Ruby bits
RUN gem install asciidoctor asciidoctor-rouge asciidoctor-pdf asciidoctor-diagram
# Install the Python bits
RUN pip3 install asciidoxy
# Copy the doxygen version that we've just built
COPY --from=doxygen-build /doxygen /doxygen

