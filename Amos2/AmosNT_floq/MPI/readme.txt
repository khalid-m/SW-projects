To run MPI under Windows:

1. Download and install MPICH2 from http://www-unix.mcs.anl.gov/mpi/mpich2/

2. Set environment variable MPI_HOME to home of MPICH2, e.g. C:\Program\MPICH2

3. Include MPICH2\bin in PATH

4. Open with MicroSoft Visual Studio C++ Demo.dsw in subfolder Demo and build 

5. In subfolder Demo\Debug do:
    mpiexec -n 10 Demo.exec

 