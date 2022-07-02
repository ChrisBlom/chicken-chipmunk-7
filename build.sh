#!/bin/sh

args="$@"
includeCpSrc=true

# hack to include c files in build but not when linking
while test $# -gt 0
do
    case "$1" in
        compiling-static-extension) includeCpSrc=false
	    ;;
    esac
    shift
done

if [ "$includeCpSrc" == "true" ] ; then
    echo ">>> INCLUDE *.c files"
    "$CHICKEN_CSC" $args -I./Chipmunk2D/include/chipmunk -I./Chipmunk2D/include ./Chipmunk2D/src/*.c
else
    echo ">>> SKIP *.c files"
    "$CHICKEN_CSC" $args -I./Chipmunk2D/include/chipmunk -I./Chipmunk2D/include
fi
