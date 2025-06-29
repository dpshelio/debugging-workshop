FC:=mpif90
CXX:=mpic++
FLAGS=-g -O0 -Wall -fno-omit-frame-pointer
FFLAGS=-ffpe-trap=invalid,zero,overflow
.PHONY: all

all: analysis-f90.exe analysis-cpp.exe

analysis-cpp.exe: analysis.cpp
	$(CXX) $(FLAGS) $^ -o $@

analysis-f90.exe: analysis.f90
	$(FC) $(FLAGS) $(FFLAGS) $^ -o $@

clean:
	rm -f *.exe
