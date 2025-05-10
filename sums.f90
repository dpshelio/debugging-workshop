program sum
  implicit none

  integer :: big_array(100)
  integer :: N = 50

  big_array = 0

  call compute_sums(big_array(1:N), big_array(N+1:2*N))

contains

  subroutine compute_sums(array_ints, array_squares)

    implicit none
    integer, dimension(*) :: array_ints, array_squares
    integer :: i, sum1, sum2

    call initialize_squares(array_squares)
    call initialize_ints(array_ints)

    sum1 = 0
    sum2 = 0

    do i = 1, N
      sum1 = sum1 + array_ints(i)
      sum2 = sum2 + array_squares(i)
    end do

    call validate_sum(sum1)
    call validate_square_sum(sum2)

  end subroutine compute_sums

  subroutine initialize_ints(arr)

    implicit none
    integer, intent(inout) :: arr(*)
    integer :: i

    do i = 1, N + 1
      arr(i) = i
    end do

  end subroutine initialize_ints

  subroutine initialize_squares(arr)

    implicit none
    integer, intent(inout) :: arr(*)
    integer :: i

    do i = 1, N
      arr(i) = i**2
    end do

  end subroutine initialize_squares

  subroutine validate_sum(sum)

    implicit none
    integer, intent(in) :: sum

    if (sum - N*(N+1)/2 == 0) then
      print *, "sum of integers from 1 to 50 is ::", sum
    else
      print *, "Error :: sum of integers from 1 to 50 is wrong."
      stop 1
    end if

  end subroutine validate_sum

  subroutine validate_square_sum(sum)

    implicit none
    integer, intent(in) :: sum

    if (sum - (N*(N+1)*(2*N+1))/6 == 0) then
      print *, "sum of integers from 1 to 50 is ::", sum
    else
      print *, "Error :: sum of the square of integers from 1 to 50 is wrong."
      stop 1
    end if

  end subroutine validate_square_sum

end program sum
