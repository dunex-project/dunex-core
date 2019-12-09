#!/bin/sh

rm -f *.o
rm -fr build
rm -fr .dub
rm -f *.a
find -name *~ |xargs rm
rm dub.selections.json
