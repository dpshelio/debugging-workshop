# default make will build cpu only e.g.
# $ make
# which is equivalent to
# $ make cpu
# If you want to build the gpu example, specify gpu or all e.g.,
# $ make all
# or
# $ make gpu

FC:=mpif90
CC:=mpicc
CXX:=mpic++
FLAGS=-g -O0 -Wall -fno-omit-frame-pointer
FFLAGS=-ffpe-trap=invalid,zero,overflow
.PHONY: all cpu gpu

cpu: array.exe analysis.exe sums.exe
gpu: saxpy-mpi.exe
all: cpu gpu

array.exe: array.cpp
	$(CXX) $(FLAGS) $^ -o $@

analysis.exe: analysis.f90
	$(FC) $(FLAGS) $(FFLAGS) $^ -o $@

sums.exe: sums.f90
	$(FC) $(FLAGS) $(FFLAGS) $^ -o $@

saxpy-mpi.exe: saxpy-mpi.cu
	$(CXX) $(FLAGS) $^ -o $@

clean:
	rm -f *.exe
