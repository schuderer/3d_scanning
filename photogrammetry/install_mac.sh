#!/bin/bash

echo "Installation for a macOS open-source photogrammetry pipeline which"
echo "uses OpenMVG and OpenMVS."
echo ""
echo "Please note: For this installation to work, you need:"
echo "  - homebrew (with correct permissions set)"
echo "  - git (can be installed using 'brew install git')"
echo ""
read -p "Press Enter to continue, Ctrl-C to abort"

# OpenMVG: https://github.com/openMVG/openMVG/blob/master/BUILD.md
git clone --recursive https://github.com/openMVG/openMVG.git
mkdir openMVG_Build && cd openMVG_Build
cmake -DCMAKE_BUILD_TYPE=RELEASE . ../openMVG/src/
cmake --build . --target install
cd ..


# OpenMVS: https://github.com/cdcseacave/openMVS/wiki/Building
#sudo port selfupdate
#sudo port install boost eigen opencv cgal4 ceres-solver
brew update
brew install boost eigen opencv cgal ceres-solver
main_path=`pwd`
git clone https://github.com/cdcseacave/VCG.git vcglib
git clone https://github.com/cdcseacave/openMVS.git
mkdir openMVS_build && cd openMVS_build
cmake . ../openMVS -DCMAKE_BUILD_TYPE=Release -DVCG_ROOT="$main_path/vcglib" # -DCGAL_DIR="/opt/local/lib"
cmake --build . --target install
cd ..

