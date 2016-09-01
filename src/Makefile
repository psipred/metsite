# Makefile for metsite
CC=gcc
CPP=g++
JAVAC=javac
LD=gcc
CFLAGS=-O3
LIBS=-lm
INC=/usr/include/

all: seedSiteFind MetPred mtx_pro returnNetCut

clean:
	rm -f seedSiteFind
	rm -f MetPred
	rm -f mtx_pro
	rm -f returnNetCut.class
	rm -f org/ucl/conf/ConfAssign.class

install:
	cp mtx_pro ../bin
	cp seedSiteFind ../bin
	cp MetPred ../bin

seedSiteFind:
	$(CPP) $(CFLAGS) seedSiteFind.cc $(LIBS) -o seedSiteFind

MetPred:
	$(CPP) $(CFLAGS) MetPred.cc $(LIBS) -o MetPred

mtx_pro:
	$(CPP) $(CFLAGS) mtx_pro.cc $(LIBS) -o mtx_pro

returnNetCut:
	$(JAVAC) returnNetCut.java
