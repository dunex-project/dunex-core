#!/bin/sh

# clean up dub / build artifacts
rm -fr build
rm -fr .dub
rm -f *.a *.so *.o
rm -f dub.selections.json
rm -rf out
rm -rf libs
rm -rf libsBuild

# clean up temp, backup files
find -name '*~' |xargs rm -f

# clean up generated doc files
rm -fr doc/man/man
rm -fr doc/man/html

# clean up test artifacts
rm -f *test-library
