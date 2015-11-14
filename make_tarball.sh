#!/bin/bash

cd openEMS
GITREV=`git describe --tags`
cd ..

rm -f openEMS-$GITREV.tar
rm -f openEMS-$GITREV.tar.bz2

git archive --format=tar --prefix=openEMS/ HEAD -o openEMS-$GITREV.tar

for mod in fparser CSXCAD QCSXCAD AppCSXCAD openEMS CTB hyp2mat; do
  cd $mod || exit 1
  tmpfn=`mktemp --suffix=tar`
  git archive --format=tar --prefix=openEMS/$mod/ HEAD -o $tmpfn
  cd ..
  tar --concatenate --file=openEMS-$GITREV.tar $tmpfn
  rm -f $tmpfn
done

bzip2 openEMS-$GITREV.tar
rm -f openEMS-$GITREV.tar
