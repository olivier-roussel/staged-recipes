#!/bin/sh

set -ex

if [[ $target_platform == osx* ]] ; then
    # Dealing with modern C++ for Darwin in embedded catch library.
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

mkdir build-sofa-gui-common
cd build-sofa-gui-common

cmake ${CMAKE_ARGS} \
  -B . \
  -S ../Sofa/GUI/Common \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DSOFA_ALLOW_FETCH_DEPENDENCIES:BOOL=OFF

# build
cmake --build . --parallel ${CPU_COUNT}

# install
cmake --build . --parallel ${CPU_COUNT} --target install

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
