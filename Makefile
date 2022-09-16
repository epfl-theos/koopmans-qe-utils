# Makefile for koopmans-qe-utils

QE_ROOT ?= ../../q-e

QE_ROOT_ABS = $(realpath $(QE_ROOT))

default : all

all : bindir
	if test -d src ; then \
	( cd src ; $(MAKE) QE_ROOT=$(QE_ROOT_ABS) || exit 1 ) ; fi

bindir :
	test -d bin || mkdir bin

links : bindir
	( cd bin/ ; \
	rm -f *.x ; \
	for exe in ../src/*.x ; do \
	    if test ! -L $$exe ; then ln -fs $$exe . ; fi \
	done ; )

clean :
	if test -d src ; then \
	( cd src ; $(MAKE) clean ) ; fi
	- /bin/rm -f bin/*.x
