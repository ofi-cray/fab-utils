# Instruction for building and running XSBench

Implementation: C, MPI+OpenMP

Useful links:
- GitHub repository: https://github.com/ANL-CESAR/XSBench

# How to build

1. Download from the GitHub repository
   ```
 % git clone https://github.com/ANL-CESAR/XSBench
   ```
 
   There is a top-level README.txt with useful information.

2.  Load the necessary PrgEnv module, set `PATH` and `LD_LIBRARY_PATH`
and set the recommended environment variables, e.g. for MPICH, etc.

3. Modify the Makefile in the `src` directory to enable MPI support:
   ```
   #MPI         = no
   MPI         = yes
   ```

   If using the Intel compiler and building for KNL, specify "intel"
   as compiler (under User Options)

   ```
   #COMPILER    = gnu
   COMPILER    = intel
   ```

   Then a bit further down in the Makefile under "Intel Compiler", fix
   the OpenMP flag and add a KNL option.

   ```
   #CFLAGS += -openmp
   CFLAGS += -qopenmp -axMIC-AVX512
   ```

You can optionally add `-qopt-report` if you want an optimization report.

3. Build
   ```
   % make
   ```

   This creates the executable `XSBench` in the same directory.

## Example runs

For each example, the number of nodes used can be varied depending on
whether Xeon or KNL nodes are used. When launching XSBench, run time
can be kept down by selecting `-s small` (instead of the default `-s
large`), and limiting lookups via `-l <value>`. The number of threads
is controlled via `-t`.

To run a small job:
```
% export OMP_NUM_THREADS=2
% srun -n 16 -N 2 -c 2 --exclusive ./XSBench -s small -t 2 -l 100
```
or
```
% export OMP_NUM_THREADS=2
% aprun -n 16 -N 8 -d 2 ./XSBench -s small -t 2 -l 100
```

To run on 128 ranks:
```
% export OMP_NUM_THREADS=2
% srun -n 128 -c 2 --exclusive ./XSBench -s small -t 2 -l 100
```
or
```
% export OMP_NUM_THREADS=2
% aprun -n 128 -d 2 -j 2 ./XSBench -s small -t 2 -l 100
```

Suitable for KNL systems:
```
% export OMP_NUM_THREADS=2
% srun -n 2048 --ntasks-per-node=64 -c 4 --exclusive ./XSBench -t 2 -s small -l 100
```
or
```
% export OMP_NUM_THREADS=2
% aprun -n 2048 -N 64 -d 2 -j 2 ./XSBench -s small -t 2 -l 100
```

## Expected output

For each run, look for a results section at the end, e.g.
```
================================================================================
                                     RESULTS
================================================================================
Threads:     2
MPI ranks:   128
Total Lookups/s:            76,941,839
Avg Lookups/s per MPI rank: 601,108
================================================================================
```

An output file results.txt is produced in the same directory and can
generally be ignored.

*None of the srun or aprun command line options should be assumed to
be optimal for performance investigations.*

## Caveats and other notes

These instructions were written using XSBench version 13.

XSBench is primarily used to investigate *on-node parallelism* and
uses MPI communication only during the final stats gathering phase of
the benchmark.
