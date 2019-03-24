# Background
I used the brpc framework quite a lot during my years working at Baidu and kind of liked it, so after getting my wery first raspberry PI as christmas present I thought that it might be nice first project to get the framework and some of the samples running on it.
There was some more work required than just running the config and build scripts, so I decided to create a simple script and a patch file to trace the steps that I took to build the framework. Most of the modifications done to the code are quite probably not optimal, just going on the path of minimal effort to get it to build and run, so anyone planning on doing any serious work with it should probably review the changes. And with that, have fun with it!

# Briefly
This repository contains build script and patch file to build the brpc framework available at https://github.com/apache/incubator-brpc for Raspberry PI 3 running Raspbian OS version 4.14 (Raspbian Stretch with desktop and recommended software) available at https://www.raspberrypi.org/downloads/raspbian/

The script will build / install dependencies required to build brpc framework, apply several modifications to brpc code (from raspberry_pi.patch)  that are required to get the framework to build on Raspbian, build the framework and one of the example programs after building the framework. There is no error checking in the script so if the build fails for some reason, you, the user of the script should just trace back the steps the script was trying to do and figure out what went wrong.

# A few words of warning
- The script will install a few packages using apt-get and begins to build some other dependencies from source. The build phase will take 3 - 4 hours, so once the building starts, I'd recommend you go get a cup of coffee or use the time for something else.
- The modifications I have made for the source are just to get it to build and I haven't reviewed all the warnings that are still left, I'm not taking any responsibility for any issues that may arise, feedback and suggestions for improvements on the modifications is welcome though.
- I'm yet to actually re-run through the whole build from scratch using the script here, so there may be some typos there I have made while gathering it up (I will remove this last warning once I've had time to test the script).

