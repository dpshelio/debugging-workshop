#include <cmath>
#include <iostream>

const int N = 50;

void compute_sums(int *array_ints, int *array_squares);
void initialize_ints(int *arr);
void initialize_squares(int *arr);
void validate_sum(int sum);
void validate_square_sum(int sum);

int main() {
  int big_array[2 * N] = {0};

  compute_sums(big_array, big_array + N);

  return 0;
}

void compute_sums(int *array_ints, int *array_squares) {
  int sum1 = 0, sum2 = 0;

  initialize_squares(array_squares);
  initialize_ints(array_ints);

  for (int i = 0; i < N; ++i) {
    sum1 += array_ints[i];
    sum2 += array_squares[i];
  }

  validate_sum(sum1);
  validate_square_sum(sum2);
}

void initialize_ints(int *arr) {
  for (int i = 0; i <= N; ++i) {
    arr[i] = i + 1;
  }
}

void initialize_squares(int *arr) {
  for (int i = 0; i < N; ++i) {
    arr[i] = (i + 1) * (i + 1);
  }
}

void validate_sum(int sum) {
  if (sum == N * (N + 1) / 2) {
    std::cout << "sum of integers from 1 to 50 is :: " << sum << std::endl;
  } else {
    std::cerr << "Error :: sum of integers from 1 to 50 is wrong." << std::endl;
    exit(1);
  }
}

void validate_square_sum(int sum) {
  if (sum == (N * (N + 1) * (2 * N + 1)) / 6) {
    std::cout << "sum of the squares of integers from 1 to 50 is :: " << sum
              << std::endl;
  } else {
    std::cerr
        << "Error :: sum of the squares of integers from 1 to 50 is wrong."
        << std::endl;
    exit(1);
  }
}
