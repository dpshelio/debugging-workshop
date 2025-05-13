FC:=gfortran
CXX:=g++
FLAGS=-g -O0 -Wall -fno-omit-frame-pointer
FFLAGS=-ffpe-trap=invalid,zero,overflow
.PHONY: all

# all: sums-f90.exe sums-cpp.exe

# sums-cpp.exe: sums.cpp
# 	$(CXX) $(FLAGS) $^ -o $@

# sums-f90.exe: sums.f90
# 	$(FC) $(FLAGS) $(FFLAGS) $^ -o $@

clean:
	rm -f *.exe
