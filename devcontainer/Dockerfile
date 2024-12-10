FROM ubuntu:24.04 as igk-build
RUN apt update && apt install -y git cmake ninja-build g++ flex bison python3 liblua5.4-dev libicu-dev
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
	-DLIBCLANG_BUILD_STATIC=OFF \
	-DBUILD_SHARED_LIBS=OFF \
	-DLLVM_ENABLE_PIC=ON \
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
RUN apt update && apt install -y liblua5.4-dev libicu-dev
WORKDIR /
# Clone igk and build it using the libclang that we've just built.
RUN git clone https://github.com/davidchisnall/igk.git && cd igk
RUN mkdir -p igk/build
WORKDIR /igk/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DLLVM_DIR=/llvm/lib/cmake/llvm -DLLVM_SOURCE_DIR=/llvm-project -G Ninja -DCMAKE_MODULE_LINKER_FLAGS=-Wl,-rpath,/igk/lib/lib
RUN NINJA_STATUS='%p [%f:%s/%t] %o/s, %es ' ninja

# Now assemble the clean container.
FROM ubuntu:24.04
RUN apt update && apt install -y liblua5.4-dev libicu-dev
# Copy the igk version that we've just built.
COPY --from=igk-build /llvm/lib /llvm/lib
COPY --from=igk-build /igk/build/igk /igk/bin/
COPY --from=igk-build /igk/build/libigk-clang.so /igk/lib/
COPY --from=igk-build /igk/lua /igk/share/igk-lua

