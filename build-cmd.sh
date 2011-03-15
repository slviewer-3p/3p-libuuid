#!/bin/sh

# turn on verbose debugging output for parabuild logs.
set -x
# make errors fatal
set -e

TOP="$(dirname "$0")"

PROJECT=uuid
LICENSE=README
VERSION="1.6.2"
SOURCE_DIR="$PROJECT-$VERSION"


if [ -z "$AUTOBUILD" ] ; then 
    fail
fi

if [ "$OSTYPE" = "cygwin" ] ; then
    export AUTOBUILD="$(cygpath -u $AUTOBUILD)"
fi

# load autbuild provided shell functions and variables
set +x
eval "$("$AUTOBUILD" source_environment)"
set -x

stage="$(pwd)"
case "$AUTOBUILD_PLATFORM" in
    "linux")
        pushd "$TOP/$SOURCE_DIR"
            # libtool was ingoring the LDFLAGS option so the only way to force
            # both the compile and link steps to use -m32 was to redefine CC
            # as below.  Sorry for the hack.
            CC="$CC -m32" ./configure --prefix="$stage"
            make
            make install
        popd
        mv lib release
        mkdir -p lib
        mv release lib
    ;;
    *)
        echo "platform not supported"
        exit -1
    ;;
esac


mkdir -p "$stage/LICENSES"
cp "$TOP/$SOURCE_DIR/$LICENSE" "$stage/LICENSES/$PROJECT.txt"

pass

