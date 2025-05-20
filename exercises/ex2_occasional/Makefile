FC:=gfortran
CXX:=g++
FLAGS=-g -O0 -Wall -fno-omit-frame-pointer
FFLAGS=-ffpe-trap=invalid,zero,overflow
.PHONY: all

all: occasional-f90.exe occasional-cpp.exe

occasional-cpp.exe: occasional.cpp
	$(CXX) $(FLAGS) $^ -o $@

occasional-f90.exe: occasional.f90
	$(FC) $(FLAGS) $(FFLAGS) $^ -o $@

clean:
	rm -f *.exe
