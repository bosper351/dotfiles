#!/bin/zsh

fontsdir="$HOME/Library/Fonts"

cp -rv /System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-* $fontsdir

colima start
for f in $fontsdir/SF-Mono-*; do
    docker run --rm -v ${f}:/in/${f:t} -v ${fontsdir}:/out:Z nerdfonts/patcher --makegroups 4 --boxdrawing --complete --single-width-glyphs
done
