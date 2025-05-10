#include <cmath>
#include <iostream>
#include <mpi.h>
#include <vector>

int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);

  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  const int N = 100;
  std::vector<double> data(N);

  if (rank == 0) {
    // Generate sine values between 0 and 4*Pi
    double step = (4.0 * M_PI) / (N - 1);
    for (int i = 0; i < N; ++i) {
      double x = i * step;
      data[i] = std::sin(x);
    }

    // Send to rank 1
    MPI_Send(data.data(), N, MPI_DOUBLE, 1, 0, MPI_COMM_WORLD);
    std::cout << "Rank 0: Sent sine array to Rank 1." << std::endl;
  } else if (rank == 1) {
    // Receive from rank 0
    MPI_Recv(data.data(), N, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD,
             MPI_STATUS_IGNORE);
    std::cout << "Rank 1: Received array. First 5 values:" << std::endl;
    for (int i = 0; i < 5; ++i) {
      std::cout << "  sin[" << i << "] = " << data[i] << std::endl;
    }
  }

  MPI_Finalize();
  return 0;
}
