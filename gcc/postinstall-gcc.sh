#!/bin/bash
ARCH=$1
VER=$2
SHORTARCH=${ARCH%%-*}
SHORTVER=${VER:0:3}

echo $ARCH $VER $SHORTARCH $SHORTVER

if [[ x$ARCH == x"" || x$VER == x"" || x$ARCH == x$SHORTARCH || x$VER == x$SHORTVER ]]; then
    exit 0
fi

if [[ x$VER > x"3.4" ]]; then
    LIBPATH="/usr/local/lib/gcc"
else
    LIBPATH="/usr/local/lib/gcc-lib"
fi

function makelink() {
    e=$1
    mv -v $e-$SHORTVER $ARCH-x$e-$VER
    rm -v $ARCH-$e-$SHORTVER
    echo "#!/bin/sh" > $e-$SHORTVER
    if [ x$SHORTARCH == x"x86_64" ]; then
        if [[ x$VER > x"4.8" ]]; then
            echo "$ARCH-x$e-$VER -Wl,-rpath,$LIBPATH/$ARCH/$VER/:$LIBPATH/$ARCH/$VER/32/:$LIBPATH/$ARCH/$VER/x32/ \"\$@\"" >> $e-$SHORTVER
        else
            echo "$ARCH-x$e-$VER -Wl,-rpath,$LIBPATH/$ARCH/$VER/:$LIBPATH/$ARCH/$VER/32/ \"\$@\"" >> $e-$SHORTVER
        fi
    else
        echo "$ARCH-x$e-$VER -Wl,-rpath,$LIBPATH/$ARCH/$VER/ \"\$@\"" >> $e-$SHORTVER
    fi
    chmod +x $e-$SHORTVER
    ln -v $e-$SHORTVER $ARCH-$e-$SHORTVER
}

rm c++filt* > /dev/null 2>&1
ln -v cpp-$SHORTVER $ARCH-cpp-$SHORTVER
rm -v c++-$SHORTVER $ARCH-c++-$SHORTVER $ARCH-gcc-$VER
makelink "gcc"
ln -v gcc-$SHORTVER $ARCH-gcc-$VER
makelink "g++"
ln -v g++-$SHORTVER c++-$SHORTVER
ln -v g++-$SHORTVER $ARCH-c++-$SHORTVER
if [[ x$VER < x"3.5" ]]; then
    makelink "g77" 
fi
if [[ x$VER > x"4.0" ]]; then
    makelink "gfortran"
fi
if [[ x$VER > x"4.7" ]]; then
    makelink "gccgo"
fi

if [[ x$SHORTVER > x"5.0" ]]; then
    mv -v go-$SHORTVER $ARCH-xgo-$VER
    mv -v gofmt-$SHORTVER $ARCH-xgofmt-$VER
    echo "#!/bin/sh" > go-$SHORTVER
    echo "#!/bin/sh" > gofmt-$SHORTVER
    echo "LD_LIBRARY_PATH=$LIBPATH/$ARCH/$VER/ $ARCH-xgo-$VER \"\$@\"" >> go-$SHORTVER
    echo "LD_LIBRARY_PATH=$LIBPATH/$ARCH/$VER/ $ARCH-xgofmt-$VER \"\$@\"" >> gofmt-$SHORTVER
    chmod +x go-$SHORTVER gofmt-$SHORTVER
    ln -v go-$SHORTVER $ARCH-go-$SHORTVER
    ln -v gofmt-$SHORTVER $ARCH-gofmt-$SHORTVER
fi
