#!/bin/sh

# clean up dub / build artifacts
rm -f *.o
rm -fr build
rm -fr .dub
rm -f *.a
rm -f dub.selections.json

# clean up temp, backup files
find -name '*~' |xargs rm -f

# clean up generated doc files
rm -fr doc/man/man
rm -fr doc/man/html
