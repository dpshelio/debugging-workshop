program occasional
  implicit none
  integer :: randomNumber
  integer, allocatable :: arr(:)
  real :: r

  call random_number(r)
  randomNumber = int(r * 100)

  print *, "Generated number:", randomNumber

  ! Sleep for 1 second
  call sleep(1)

  ! Crash the program if the number is greater than 75
  if (randomNumber > 75) then
    print *, "Number is greater than 75. Crashing the program..."
    deallocate(arr) ! attempt to deallocate unallocated array
  end if

  print *, "Program completed successfully."
end program occasional
