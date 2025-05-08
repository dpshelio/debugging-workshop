program gather
  use mpi

  implicit none
  integer :: ierr, rank, size, i
  integer, parameter :: array_len = 10, total_len = 40
  integer :: sendbuf(array_len), recvbuf(total_len)

  integer :: check

  ! Initialize the MPI environment
  call MPI_Init(ierr)
  call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
  call MPI_Comm_size(MPI_COMM_WORLD, size, ierr)

  ! Ensure the program is running with exactly 4 processes
  if (size /= 4) then
    if (rank == 0) print *, 'This program requires exactly 4 processes.'
    call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
  end if

  ! Fill the local array with some data
  sendbuf = (/(rank * array_len + i, i = 1, array_len)/)
  print '("Process", i1, " sending array:", 10(i4, ","))', rank, sendbuf

  call mimic_computation(check)

  if (check > 0) then
    ! Gather the data at process 0
    call MPI_Gather(sendbuf, array_len, MPI_INTEGER, recvbuf, array_len, MPI_INTEGER, 0, MPI_COMM_WORLD, ierr)
  end if

  call MPI_Barrier(MPI_COMM_WORLD, ierr);

  ! Print the gathered result on process 0
  if (rank == 0) then
    print *, "Gathered array on process 0: "
    print '(20(i3, ","))', recvbuf
  end if

  ! Finalize the MPI environment
  call MPI_Finalize(ierr)

  if (check > 0) then
    ! Gather the data at process 0
    call MPI_Gather(sendbuf, array_len, MPI_INTEGER, recvbuf, array_len, MPI_INTEGER, 0, MPI_COMM_WORLD, ierr)
  end if

  call mimic_computation(check)

  call MPI_Barrier(MPI_COMM_WORLD, ierr);

  ! Print the gathered result on process 0
  if (rank == 0) then
    print *, "Gathered array on process 0: "
    print '(20(i3, ","))', recvbuf
  end if

  contains
    !this subroutine mimics computation
    subroutine mimic_computation(check)
      implicit none

      integer, intent(out) :: check

      check = 1

      if (rank == 2) then
        check = 0
      end if
    end subroutine mimic_computation
end program gather
