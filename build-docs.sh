#!/bin/sh
#
# Use pandoc to build documentation as manpages, html
#

rm -r doc/man/man
rm -r doc/man/html

mkdir doc/man/man
mkdir doc/man/html

for page in doc/man/*.md; do
    base=$(basename $page .md)
    pandoc  --standalone --to html5 $page -o "doc/man/html/$basename.html"
    chap=$(echo $page | cut -d. -f2)
    mkdir doc/man/man/"man$chap"
    pandoc  --standalone --to man $page -o "doc/man/man/man$chap/$base"
done
