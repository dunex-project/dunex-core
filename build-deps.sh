#!/bin/sh
# This creates dynamic libraries from the dependencies listed in deps.txt, for future dynamic linking.
#
set -e
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
BUILDPATH=$SCRIPTPATH/libsBuild
OUTPATH=$SCRIPTPATH/libs
DUB="dub build --compiler=ldc2 -q"

mkdir $OUTPATH || /bin/true
mkdir $BUILDPATH || /bin/true
cd $BUILDPATH
for lib in $(cat ../deps.txt); do
    echo $lib
    read path gitpath version <<EOF 
$(echo $lib | tr '=' ' ')  
EOF
    echo $version $gitpath 
    git clone --depth 1 --branch $version $gitpath $path 2>/dev/null
    cd $path
    if [ -e dub.json ]; then
	mv dub.json dub.json.orig
	jq '.targetType = "dynamicLibrary"' < dub.json.orig > dub.json
    fi
    if [ -e dub.sdl ]; then
	cp dub.sdl dub.sdl.orig
	if grep -q 'targetType' dub.sdl; then
	    sed -i 's/targetType "library"/targetType "dynamicLibrary"/' dub.sdl
	else
	    echo 'targetType "dynamicLibrary"' >> dub.sdl
	fi
    fi
    $DUB
    cp "lib$path.so" $OUTPATH
    cd $BUILDPATH
done
cd $SCRIPTPATH
