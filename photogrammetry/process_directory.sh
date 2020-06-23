#!/bin/bash

# Photogrammetry pipeline adapted to macOS from:
# https://peterfalkingham.com/2018/05/22/photogrammetry-testing-12-revisiting-openmvg-with-openmvs/

# You need to have OpenMVG and OpenMVS installed. You can use install_mac.sh for that.
# Unfortunately, Macs don't tend to support CUDA, so many steps take about 10x longer
# than with CUDA. Here's a rough indication of what to expect without CUDA for
# a simple 45-picture photogrammetry scan:
#
# OpenMVG:
#    List Images:—————————————— 1 sec
#    Compute Features——————————— 6 min
#    Compute Matches——————————— 4 min
#    SfM reconstruction——————————- 6 min
#    Compute Structure from Known Poses– 9 min
#    Colour the sparse cloud————————- 10 sec
#    Convert to openMVS format—————— 1 min
#
# (total openMVG time:  ~26 min)
#
# OpenMVS:
#
#    Densify point cloud——————————- 2 hrs 30 min
#    Reconstruct Mesh———————————- 20 min
#    Refine Mesh——————————————- 25 min
#    Texture Mesh—————————————- 10 min
#
# (total openMVS time:  ~)
#
# Total Time: ~ 


mvsbin=/usr/local/bin/OpenMVS


if [ ! -d "$1" ]; then
  echo "Parameter must be a directory."
  exit 1
fi

if [ ! -f "/usr/local/bin/openMVG_main_SfMInit_ImageListing" ]; then
  echo "OpenMVG does not seem to be installed. Please run ./install_mac.sh"
  exit 2
fi

if [ ! -d "$mvsbin" ]; then
  echo "OpenMVS does not seem to be installed. Please run ./install_mac.sh"
  exit 3
fi

imgdir="${1%/}"
workdir="${imgdir}_temp"

mkdir "$workdir"
cp $imgdir/* $workdir/
cd $workdir/

time openMVG_main_SfMInit_ImageListing -i . -d /usr/local/share/openMVG/sensor_width_camera_database.txt -o matches
echo "End of imagelisting"

time openMVG_main_ComputeFeatures -p HIGH -i matches/sfm_data.json -o matches
echo "End of features"

time openMVG_main_ComputeMatches -r .8 -i matches/sfm_data.json -o matches
echo "End of matches"

time openMVG_main_IncrementalSfM -i matches/sfm_data.json -m matches -o out_Incremental_Reconstruction
echo "End of SfM"

mkdir mvs_dir
time openMVG_main_ComputeStructureFromKnownPoses -i out_Incremental_Reconstruction/sfm_data.bin -m matches -f matches/matches.f.bin -o out_Incremental_Reconstruction/robust.bin
echo "End of structure"

time openMVG_main_ComputeSfM_DataColor -i out_Incremental_Reconstruction/robust.bin -o out_Incremental_Reconstruction/robust_colorized.ply
echo "End of color"

time openMVG_main_openMVG2openMVS -i out_Incremental_Reconstruction/sfm_data.bin -o mvs_dir/model.mvs -d mvs_dir
echo "End of conversion to mvs"

time $mvsbin/DensifyPointCloud -i mvs_dir/model.mvs
echo "End of MVS densify"

time $mvsbin/ReconstructMesh mvs_dir/model_dense.mvs
echo "End of MVS reconstruct mesh"

time $mvsbin/RefineMesh --resolution-level 2 mvs_dir/model_dense_mesh.mvs
echo "End of MVS refine mesh"

time $mvsbin/TextureMesh --export-type obj mvs_dir/model_dense_mesh_refine.mvs
echo "End of MVS texture mesh"

target=$imgdir.obj
cd ..
cp "$workdir/mvs_dir/model_dense_mesh_refine_texture.obj" "$target"

echo "Done and result copied to $target"
echo "If you need a textured model, use $workdir/mvs_dir/model_dense_mesh_refine_texture.obj."
echo ""
echo "The directory $workdir contains intermediate results. If you want to tweak intermediate steps,"
echo "you can reuse these intermediate results. Otherwise, you can delete the directory $workdir."
exit 0

