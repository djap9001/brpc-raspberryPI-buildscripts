# Background
I used the brpc framework quite a lot during my years working at Baidu and kind of liked it, so after getting my wery first raspberry PI as christmas present I thought that it might be nice first project to get the framework and some of the samples running on it.
There was some more work required than just running the config and build scripts, so I decided to create a simple script and a patch file to trace the steps that I took to build the framework. Most of the modifications done to the code are quite probably not optimal, just going on the path of minimal effort to get it to build and run, so anyone planning on doing any serious work with it should probably review the changes. And with that, have fun with it!

# Briefly
This repository contains build script and patch file to build the brpc framework available at https://github.com/apache/incubator-brpc for Raspberry PI 3 running Raspbian OS version 4.14 (Tested with the "Raspbian Stretch with desktop and recommended software" and "Raspbian Stretch with desktop", the Lite version should work too, but you may need to install git and build essential) available at https://www.raspberrypi.org/downloads/raspbian/

The script will build / install dependencies required to build brpc framework, apply several modifications to brpc code (from raspberry_pi.patch)  that are required to get the framework to build on Raspbian, build the framework and one of the example programs after building the framework. There is no error checking in the script so if the build fails for some reason, you, the user of the script should just trace back the steps the script was trying to do and figure out what went wrong.

# A few words of warning
- The script will install a few packages using apt-get and begins to build some other dependencies from source. The build phase will take 3 - 4 hours, so once the building starts, I'd recommend you go get a cup of coffee or use the time for something else (the script will notify you when it reaches this point).
- The modifications I have made for the source are just to get it to build on Raspbian, I haven't reviewed all the warnings that are still left and I'm not taking any responsibility for any issues that may arise, feedback and suggestions for improvements on the modifications are wellcome though.

# NOTE about building for older x86_64 CPU (to self and possibly anyone else encountering same issue)
While building the framework for x64_64 to run it on my laptop running Ubuntu 18.04, I encountered the issue that even though the framework and samples passed the build wihout issue, the examples cored with SIGILL after a few seconds. The reason could be that my laptop is from pre-stoneage era and doesn't support sse4 sse4.2 instructions so in case of similar issues remove the -msse4 and -msse4.2 flags from incubator-brpc/Makefile before running make:

```
diff --git a/Makefile b/Makefile
index 21e3081..1934d44 100644
--- a/Makefile
+++ b/Makefile
@@ -22,10 +22,6 @@ ifeq ($(SYSTEM),Darwin)
     TARGET_LIB_DY = libbrpc.dylib
 endif
 
-#required by butil/crc32.cc to boost performance for 10x
-ifeq ($(shell test $(GCC_VERSION) -ge 40400; echo $$?),0)
-       CXXFLAGS+=-msse4 -msse4.2
-endif
 #not solved yet
 ifeq ($(CC),gcc)
  ifeq ($(shell test $(GCC_VERSION) -ge 70000; echo $$?),0)
```
