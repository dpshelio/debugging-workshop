program analysis
  use mpi

  implicit none

  integer :: rank
  integer, parameter :: array_len = 20, total_len = 80

  call main()

contains

  ! main program
  subroutine main()

    implicit none

    integer :: ierr, size, i
    integer :: input_data(array_len), analysed_data(total_len)

    integer :: check = 0

    ! Initialize the MPI environment
    call MPI_Init(ierr)
    call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
    call MPI_Comm_size(MPI_COMM_WORLD, size, ierr)

    ! Ensure the program is running with exactly 4 processes
    if (size /= 4) then
      if (rank == 0) print *, 'This program requires exactly 4 processes.'
      call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
    end if

    ! generate fake input data (this would have been read from file normally)
    input_data = (/(rank * array_len + i, i = 1, array_len)/)
    print '("Process ", i1, " input_data:", 20(i4, ","))', rank, input_data

    call data_integrity_check(check)

    ! only analyse the data if it passes the integrity check
    if (check > 0) then
      call MPI_Gather(input_data, array_len, MPI_INTEGER, analysed_data, array_len, MPI_INTEGER, 0, MPI_COMM_WORLD, ierr)
    end if

    call MPI_Barrier(MPI_COMM_WORLD, ierr);

    if (rank == 1) then
      check = -1 ! again we will fake that check fails for 1 process (this time rank 1)
    end if
    call process_stage1(check, input_data)

    call MPI_Gather(input_data, array_len, MPI_INTEGER, analysed_data, array_len, MPI_INTEGER, 0, MPI_COMM_WORLD, ierr)
    call MPI_Barrier(MPI_COMM_WORLD, ierr);

    if (rank == 0) then
      call process_stage2(analysed_data)
      print *, "Processed data :: "
      print '(20(i3, ","))', analysed_data
    end if

    ! Finalize the MPI environment
    call MPI_Finalize(ierr)

  end subroutine main

  ! pretend to check the integrity of the analysis data
  subroutine data_integrity_check(check)
    implicit none

    integer, intent(out) :: check

    ! fake that every rank except 2 correctly sets check
    if (rank /= 2) then
      check = 1 + rank
    end if
  end subroutine data_integrity_check

  ! pretend to process the input_data
  subroutine process_stage1(check, data)
    implicit none

    integer, intent(in) :: check
    integer, intent(inout) :: data(:)
    integer :: i

    data = 0
    if (check > 0) then
      do i = 1, array_len
        data(i) = int(10*(sin(i*0.5)+2.0))
      end do
    end if

  end subroutine process_stage1

  ! pretend to process the input_data a second time
  subroutine process_stage2(data)
    implicit none

    integer, intent(inout) :: data(:)

    data = 1024 / data

  end subroutine process_stage2

end program analysis
