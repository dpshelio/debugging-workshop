#include <cmath>
#include <cstdlib>
#include <iostream>
#include <mpi.h>
#include <vector>

// Asserts that two integer arrays are equal
void assert_equal(const std::vector<int> &got, const std::vector<int> &expect,
                  bool print_result);

// check the integrity of the analysis data
// fail (return false) if any of the data are negative
bool data_integrity_check(const std::vector<int> &data);

// pretend to process the input_data on each rank
void process_partial_data(std::vector<int> &data, int my_rank);

// pretend to process the gathered data
void process_full_data(std::vector<int> &data);

int main(int argc, char *argv[]) {
  int my_rank, size;
  const int array_len = 20, total_len = 80;
  std::vector<int> input_data(array_len);
  std::vector<int> analysed_data;

  // Initialize the MPI environment
  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  if (my_rank == 0) {
    analysed_data.resize(total_len);
  }

  // Ensure the program is running with exactly 4 processes
  if (size != 4) {
    if (my_rank == 0)
      std::cout << "This program requires exactly 4 processes." << std::endl;
    MPI_Abort(MPI_COMM_WORLD, 1);
  }

  // generate fake input data (this would have been read from file normally)
  for (int i = 0; i < array_len; ++i) {
    input_data[i] = my_rank * array_len + (i + 1);
  }
  std::cout << "Process " << my_rank << " input_data:";
  for (int i = 0; i < array_len; ++i)
    std::cout << " " << input_data[i] << ",";
  std::cout << std::endl;

  // process data on each rank
  process_partial_data(input_data, my_rank);

  // only gather the data if it passes the integrity check
  std::cout << "gathering data..." << std::endl;
  bool check = data_integrity_check(input_data);
  if (check) {
    MPI_Gather(input_data.data(), array_len, MPI_INT, analysed_data.data(),
               array_len, MPI_INT, 0, MPI_COMM_WORLD);
  }

  std::cout << "Process " << my_rank << " data gathered" << std::endl;
  MPI_Barrier(MPI_COMM_WORLD);

  if (my_rank == 0) {
    std::cout << "processing final array..." << std::endl;
    process_full_data(analysed_data);
    std::cout << "Processed data :: " << std::endl;
    for (int i = 0; i < total_len; ++i) {
      std::cout << analysed_data[i] << ", ";
      if (i % 20 == 19) {
        std::cout << std::endl;
      }
    }

    std::vector<int> ref_data = {
        40, 34, 32, 31, 34, 37, 44, 51, 53, 51, 44, 35, 29, 25, 23, 22,
        23, 24, 26, 30, 22, 20, 19, 19, 20, 21, 23, 25, 26, 25, 23, 20,
        18, 17, 16, 15, 16, 16, 17, 18, 15, 14, 14, 14, 14, 15, 16, 17,
        17, 17, 16, 14, 13, 12, 12, 12, 12, 12, 13, 13, 12, 11, 11, 11,
        11, 11, 12, 12, 12, 12, 12, 11, 10, 10, 9,  9,  9,  10, 10, 10};

    assert_equal(analysed_data, ref_data, true);
  }

  // Finalize the MPI environment
  MPI_Finalize();
}

// check the integrity of the analysis data
// fail (return false) if any of the data are negative
bool data_integrity_check(const std::vector<int> &data) {
  for (size_t i = 0; i < data.size(); ++i) {
    if (data[i] < 0)
      return false;
  }
  return true;
}

// pretend to process the input_data on each rank
void process_partial_data(std::vector<int> &data, int my_rank) {
  const int array_len = data.size();

  // fake data processing
  for (int i = 0; i < array_len; ++i) {
    data[i] = static_cast<int>(10 * (std::sin((i + 1) * 0.5) + 2.0)) + data[i];
  }

  // fake some erroneous data part 1
  if (my_rank == 2) {
    data[2] = -1;
  }
  // fake some erroneous data part 2
  if (my_rank == 3) {
    data[2] = 0;
  }
}

// pretend to process the gathered data
void process_full_data(std::vector<int> &data) {
  const int total_len = data.size();
  for (int i = 0; i < total_len; ++i) {
    data[i] = 1024 / data[i];
  }
}

// Asserts that two integer arrays are equal
void assert_equal(const std::vector<int> &got, const std::vector<int> &expect,
                  bool print_result = true) {
  bool test_pass = (got.size() == expect.size());
  if (test_pass) {
    for (size_t i = 0; i < got.size(); ++i) {
      if (got[i] != expect[i]) {
        test_pass = false;
        break;
      }
    }
  }
  if (print_result) {
    if (test_pass) {
      std::cout << "\033[32mPASSED\033[0m :: [analysis code]" << std::endl;
    } else {
      std::cout << "\033[31mFAILED\033[0m :: [analysis code]" << std::endl;
    }
  }
  return;
}
