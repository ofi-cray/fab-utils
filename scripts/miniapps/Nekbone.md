# Instruction for building and running Nekbone

Implementation: Fortran, C, MPI (single threaded)

Useful links:
- CESAR Thermal Hydraulics web site: https://cesar.mcs.anl.gov/content/software/thermal_hydraulics

## How to build

1. Download Nekbone from
https://cesar.mcs.anl.gov/content/software/thermal_hydraulics.  You
must register to get a copy of the source code.  There is a top-level
readme.pdf with build and run instructions.

2.  Load the necessary PrgEnv module, set `PATH` and `LD_LIBRARY_PATH`
and set the recommended environment variables, e.g. for MPICH, etc.

3. Modify the make script `makenek` in the directory `test/example1`

   Set the source directory to where the Nekbone source was
   downloaded, e.g.
   ```
   # source path 
   #SOURCE_ROOT="$HOME/nekbone-3.0/src" 
   SOURCE_ROOT="/path/to/nekbone/nekbone-3.1/src"
   ```

   If using the Intel compiler and building for KNL, specify automatic
   cpu dispatch to allow the executable to be run on KNL and non-KNL.

   For the Fortran compilation:
   ```
   #F77="mpif77"
   F77="mpif77 -axMIC-AVX512"
   ```

   For the C compilation:
   ```
   #CC="mpicc"
   CC="mpicc -axMIC-AVX512"
   ```
   
4. The build is problem-size specific, so you must modify the `SIZE`
file. Increase the maximum number of ranks from 10 to 8192 to allow
more flexibility in how to run the program later.
   ```
   C     parameter (lp = 10)                     ! max number of processors
         parameter (lp = 8192)                   ! max number of processors
   ```

5. Build
   ```
   % ./makenek ex1
   ```
   
   This creates an executable called `nekbone` in the same directory.

## Example runs

For each example, the number of nodes used can be varied depending on
whether Xeon or KNL nodes are used.  The problem size is built into
the executable, and there are no parameters to allow you to vary the
problem size or other aspects of the program.  Nekbone is a
single-threaded application, so aprun launch parameters can easily be
derived from the srun examples.

The input deck has to be copied into the run directory if it is not
already there.

```
   % cp /path/to/nekbone/nekbone-3.1/test/example/data.rea .
```

A few examples
```
% srun -n 4 -N 2 --exclusive ./nekbone ex1
```

```
% srun -n 16 -N 2 --exclusive ./nekbone ex1
```

```
% srun -n 96 -N 4 --ntasks-per-node=24 --hint=nomultithread --exclusive ./nekbone ex1
```

```
% srun -n 128 -N 2 --exclusive ./nekbone ex1
```

```
% srun -n 216 --exclusive ./nekbone ex1
```

Suitable for KNL systems:
```
% srun -n 2048 --ntasks-per-node=64 --hint=nomultithread --exclusive ./nekbone ex1
```

```
% srun -n 8192 --hint=nomultithread --exclusive ./nekbone ex1
```

## Expected output
Before terminating, the program prints:
```
 Exitting....
```
(No, that is not a type-o.)

A performance summary is printed just before termination, e.g.
```
nelt =      50, np =      8192, nx1 =      10, elements =    409600
Tot MFlops =   0.0000E+00, MFlops      =   0.0000E+00
Setup Flop =   6.9500E+08, Solver Flop =   7.5750E+07
Solve Time =   0.0000E+00
Avg MFlops =   0.0000E+00
 Exitting....
```

*None of the srun command line options should be assumed to be optimal
for performance investigations.*

## Caveats and other notes

These instructions were written using Nekbone version 3.1.
