program analysis
  use mpi

  implicit none

  integer :: my_rank
  integer, parameter :: array_len = 20, total_len = 80

  call main()

contains

  ! main program
  subroutine main()

    implicit none

    integer :: ierr, size, i
    integer :: input_data(array_len)
    integer, allocatable :: analysed_data(:)
    integer :: ref_data(total_len)

    integer :: check = 0

    ! Initialize the MPI environment
    call MPI_Init(ierr)
    call MPI_Comm_rank(MPI_COMM_WORLD, my_rank, ierr)
    call MPI_Comm_size(MPI_COMM_WORLD, size, ierr)

    if (my_rank == 0) then
      allocate(analysed_data(total_len))
    end if

    ! Ensure the program is running with exactly 4 processes
    if (size /= 4) then
      if (my_rank == 0) print *, 'This program requires exactly 4 processes.'
      call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
    end if

    ! generate fake input data (this would have been read from file normally)
    input_data = (/(my_rank * array_len + i, i = 1, array_len)/)
    print '("Process ", i1, " input_data:", 20(i3, ","))', my_rank, input_data
    call flush()

    ! process data on each rank
    call process_partial_data(input_data)

    ! only gather the data if it passes the integrity check
    print *, "gathering data..."
    call flush()
    call data_integrity_check(input_data, check)
    if (check > 0) then
      call MPI_Gather(input_data, array_len, MPI_INTEGER, analysed_data, array_len, MPI_INTEGER, 0, MPI_COMM_WORLD, ierr)
    end if

    print '("Process ", i1, " data gathered")', my_rank
    call flush()
    call MPI_Barrier(MPI_COMM_WORLD, ierr)

    if (my_rank == 0) then
      print *, "processing final array..."
      call flush()

      call process_full_data(analysed_data)

      print *, "Processed data :: "
      print '(20(i3, ","))', analysed_data
      call flush()

      ref_data = [ &
      40, 34, 32, 31, 34, 37, 44, 51, 53, 51, 44, 35, 29, 25, 23, 22, 23, 24, 26, 30, &
      22, 20, 19, 19, 20, 21, 23, 25, 26, 25, 23, 20, 18, 17, 16, 15, 16, 16, 17, 18, &
      15, 14, 14, 14, 14, 15, 16, 17, 17, 17, 16, 14, 13, 12, 12, 12, 12, 12, 13, 13, &
      12, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 11, 10, 10,  9,  9,  9, 10, 10, 10  &
      ]

      call assert_equal(analysed_data, ref_data, print_result=.true.)

      ! clean up allocatable array
      deallocate(analysed_data)
    end if

    ! Finalize the MPI environment
    call MPI_Finalize(ierr)

  end subroutine main

  ! check the integrity of the analysis data
  ! fail (return check=0) if any of the data are negative
  subroutine data_integrity_check(data, check)
    implicit none

    integer, intent(in)  :: data(:)
    integer, intent(out) :: check
    integer :: i

    check = 1
    do i = 1, array_len
      if (data(i) < 0) then
        check = 0
      end if
    end do
  end subroutine data_integrity_check

  ! pretend to process the input_data on each rank
  subroutine process_partial_data(data)
    implicit none

    integer, intent(inout) :: data(:)
    integer :: i

    ! fake data processing
    do i = 1, array_len
      data(i) = int(10*(sin(i*0.5)+2.0)) + data(i)
    end do

    ! fake some erroneous data part 1
    if (my_rank == 2) then
      data(3) = -1
    end if
    ! fake some erroneous data part 2
    if (my_rank == 3) then
      data(3) = 0
    end if
  end subroutine process_partial_data

  ! pretend to process the gathered data
  subroutine process_full_data(data)
    implicit none

    integer, intent(inout) :: data(:)
    integer :: i

    do i = 1, total_len
      data(i) = 1024 / data(i)
    end do

  end subroutine process_full_data

  ! Asserts that two integer arrays are equal and prints the result
  subroutine assert_equal(got, expect, print_result)
    integer, dimension(:), intent(in) :: got          !! The value to be tested
    integer, dimension(:), intent(in) :: expect       !! The expected value
    logical, intent(in), optional     :: print_result !! Optionally print test result to screen (defaults to .true.)

    logical :: test_pass  !! Did the assertion pass?
    logical :: print_result_value
    character(len=15) :: report

    if (.not. present(print_result)) then
      print_result_value = .true.
    else
      print_result_value = print_result
    end if

    test_pass = maxval(got - expect) == 0

    if (print_result_value) then
      if (test_pass) then
        report = char(27)//'[32m'//'PASSED'//char(27)//'[0m'
      else
        report = char(27)//'[31m'//'FAILED'//char(27)//'[0m'
      end if
      write(*, '(A, " :: [", A, "] ")') report, "analysis code"
    end if
  end subroutine assert_equal

end program analysis
