# Makefile for metsite
CC=gcc
CPP=g++
LD=gcc
CFLAGS=-O3
LIBS=-lm
INC=/usr/include/

all: seedSiteFind MetPred mtx_pro

clean:
	rm -f seedSiteFind
	rm -f MetPred
	rm -f mtx_pro

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
