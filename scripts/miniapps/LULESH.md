# Instruction for building and running LULESH

Implementation: C++, serial, OpenMP, MPI, or MPI+OpenMP

Useful links:
- LULESH web site: https://codesign.llnl.gov/lulesh.php
- Build instructions: https://asc.llnl.gov/CORAL-benchmarks/Summaries/LULESH_Summary_v1.pdf

## How to build

1. Download the most recent "CPU Models" tarball found at the web site
above.  A top-level README mostly describes recent changes and does
not provide build or run information.  See the above link for build
instructions.

2.  Load the necessary PrgEnv module, set `PATH` and `LD_LIBRARY_PATH`
and set the recommended environment variables, e.g. for MPICH, etc.

3. Modify `Makefile` to specify the compiler and flags.
   ``` 
   #MPICXX = mpig++ -DUSE_MPI=1
   MPICXX = mpic++ -DUSE_MPI=1
   ```
   
   If you want to use the Intel compiler and build for KNL, modify
   CXXFLAGS:
   
   ```
   #CXXFLAGS = -g -O3 -fopenmp -I. -Wall
   CXXFLAGS = -g -O3 -fopenmp -I. -Wall -axMIC-AVX512
   ```
   
   You can optionally add `-qopt-report` if you want an optimization report.

5. Build
   ```
   % make
   ```

   This creates the executable `lulesh2.0` in the same directory.

## Example runs

   For each example, the number of nodes used can be varied depending
   on whether Xeon or KNL nodes are used. A requirement when running
   LULESH is that the number of MPI tasks must always be the cube of
   an integer.  If this requirement is not satisfied, LULESH will just
   abort but not provide a hint as to what went wrong. LULESH is a
   strong scaling problem and run times may go up with the number of
   ranks or threads. The option `-i` can be used to limit the number
   of iterations and in turn reduce the run time. LULESH does not
   produce output while it is running, only the results at the end. Be
   patient.

   To run a small problem across 2 nodes:
   ```
   % export OMP_NUM_THREADS=4
   % srun -n 8 -N 2 -c 4 --exclusive ./lulesh2.0 -s 38
   ```
   or
   ```
   % export OMP_NUM_THREADS=4
   % aprun -n 8 -N 4 -d 4 ./lulesh2.0  -s 38 
   ```

   To run on 16 small nodes:
   ```
   % export OMP_NUM_THREADS=4
   % srun -n 64 -N 16 -c 4 --exclusive ./lulesh2.0 -s 38 -i 100
   ```
   or
   ```
   % export OMP_NUM_THREADS=4
   % aprun -n 64 -N 4 -d 4 -cc depth ./lulesh2.0 -s 38 -i 100
   ````
   
   To run a medium size job across however many nodes:
   ```
   % export OMP_NUM_THREADS=2
   % srun -n 216 -c 2 --exclusive ./lulesh2.0 -s 38 -i 100
   ```
   or
   ```
   % export OMP_NUM_THREADS=2
   % aprun -n 216 -d 2 -cc depth ./lulesh2.0 -s 38 -i 100
   ```

## Expected output

For each run, look for the following lines at the end of the output
```
Elapsed time         =      ..... (s)
Grind time (us/z/c)  =  ......... (per dom)  (........... overall)
FOM                  =  ......... (z/s)
```

The Figure of Merit (FOM) in the last line reports elements solved per
microsecond and is the most relevant performance data.

*None of the srun or aprun command line options should be assumed to
be optimal for performance investigations.*

## Caveats and other notes

These instructions were written using LULESH version 2.0.
