# 3d_scanning
Ways to do 3D scanning on a Mac for free. It has to be free because you've spent all you have on that Mac. :o)

I put this up here because, as someone who just wanted to try out 3D scanning out of curiosity, I spent a disproportionate of time searching in vain for 3D scanning tools that are (a) available for macOS, (b) easy to use without a lot of learning, (c) free. Everything ready-to-use that I came across is either discontinued or requires extra hardware or a different operating system.

But the stuff here works! :)

## Photogrammetry

I'd say that this is the most user-friendly free solution I could find. Except for the little bit of initial shell wizardry, it is a relatively self-contained pipeline and comes close to what I would call a one-click (or one-command) process.

The directory `photogrammetry` contains a working open source solution to create 3D scans from photos on a Mac (that does not have CUDA). It is based on [Peter Falkingham's extensive tests](https://peterfalkingham.com/2018/05/22/photogrammetry-testing-12-revisiting-openmvg-with-openmvs/), but adapted for macOS. It has been tested on macOS 10.13 High Sierra and contains the following files:
- `install_mac.sh`: Installation script for the necessary open source software [openMVG](https://github.com/openMVG/openMVG) and [openMVS](http://cdcseacave.github.io/openMVS/).
- `process_directory.sh`: Script to analyze a folder with images and create a 3D mesh (.obj file).

Installation:
1. Install [homebrew](https://brew.sh/) (A tool to install packages on macOS in a Linux-like fashion. This will also install XCode command line tools if necessary.)
2. Download `install_mac.sh` and `process_directory.sh` and put them into a folder you created specifically for 3D scanning (e.g. `3D-Scanning`).
3. In the Terminal application, navigate to this folder (type `cd ` and then drag the folder from Finder into the Terminal window, and press Enter)
4. Run the command `chmod u+x *.sh` (and as for all commands, press Enter)
5. Run the command `./install_mac.sh`. This will install all needed components.

Usage:
1. Take suitable photos of your object. There are [many guides](https://peterfalkingham.com/2019/01/16/small-object-photogrammetry-how-to-take-photos/) on how to do this properly. In a nutshell
  - a good camera with a lot of details necessary (modern smartphones are usually sufficient), RAW format would be great, but big (multi-MB) JPEG might be sufficient as well.
  - you want good lighting,
  - you need a lot of photos (50+),
  - the object has to be perfectly in focus in all pictures (easy to misjudge when you are too close to small objects),
  - the object must not be moved nor must there be lighting variation (turn off/lock your camera's white balance and automatic exposure),
  - there must not be any glare/reflection *at all* (baby powder is useful for making glossy surfaces matte),
  - have as little irrelevant non-object details in the picture as possible -- if there are, you might have to edit them out in a photo editing software, or, better still, apply [the void technique](https://www.youtube.com/watch?v=Il6LVXqSlRg).
2. Save your photos in a subfolder of your `3D-Scanning` folder, e.g. `Banana` (no spaces allowed).
3. In the `3D-Scanning` folder in Terminal, run the command `./process_directory.sh Banana`.
4. The result will be placed in the `3D-Scanning` folder, in this case `Banana.obj'.

Notes and caveats:
- Reconstruction of the 3D object is a multi-hour process (I saw anything between 2 and 6 hours). The file `process_directory.sh` contains some rough indications of how long which steps might take. I usually run this process overnight.
- If the process finishes suspiciously fast, somethings wrong. This is because the underlying tools don't show error messages if they are missing files. I also had the situation that my photos were just too *bad* for it to actually reconstruct anything, and it just sayd that it's finished, but without any result. I then re-took the pictures, paying more attention to focus, quality and the absence of glare/specular reflection. Then it worked nicely! See the provided example.
- If your Mac is not very powerful, and particularly if does not have a lot (e.g. 16GB) of RAM, it is advisable to close all other applications and not use the computer, in order to free up processing power and particularly to free up ram. Otherwise, macOS will constantly swap data between RAM and SSD, and the process slows to a crawl by an order of magnitude (think 30 hours instead of 3 hours).
- If you do have a CUDA-able Mac, you should use CUDA-able software to speed the process up by an order of magnitude. If you don't know what CUDA is, you probably haven't and should be fine with the scripts here.
- I'm aware that there are other solutions like iPhone apps where you put the object on a sheet with markers, using newer iPhones with depth sensors, etc. But I did not like the performance of the former, and don't have the latter. :)
