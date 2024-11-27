# nim --maxLoopIterationsVM:10000000000 c -d:futharkRebuild  create
# nim c -d:futharkRebuild -d:nodeclguards -d:noopaquetypes create
import futhark,os


importc:
  outputPath currentSourcePath.parentDir / "libduckdb.nim"
  #path "../FFmpeg-release-6.1/"
  # libavutil:
  #"libavutil/version.h"   
  #"libavutil/thread.h"   
  #"libavutil/buffer_internal.h"   
  #"libavutil/buffer.h" 
  "duckdb.h"
  
# FIX
# sed -i 's/structavchannellayout_u_t\ {/structavchannellayout_u_t\*\ {/' libav.nim 


# c2nim --header libavutil/error.h
