# Instruction for building and running CoMD

Implementation: C, MPI+OpenMP

Useful links:
- ExMatEx CoMD website: http://www.exmatex.org/comd.html
- Build instructions: http://exmatex.github.io/CoMD/doxygen-mpi/pg_building_comd.html
- GitHub repository: https://github.com/exmatex/CoMD

## How to build

1. Download from the GitHub repository
   ```
% git clone https://github.com/exmatex/CoMD
   ```

   There is a top-level README.md with a somewhat useful link in it.

2.  Load the necessary PrgEnv module, set `PATH` and `LD_LIBRARY_PATH`
and set the recommended environment variables, e.g. for MPICH, etc.

3. Create and modify `Makefile` in the `src-openmp` directory:
   ```
   % cp Makefile.vanilla Makefile
   ```

   If you want to use the Intel compiler and build for KNL, modify
   CFLAGS:

   ```
   #CFLAGS = -std=c99 -fopenmp
   CFLAGS = -std=c99 -fopenmp -axMIC-AVX512 -v
   ```

   You can optionally add `-qopt-report` if you want an optimization report.

5. Build (in the `src-openmp` directory)
   ```
   % make
   ```

   This creates the executable `CoMD-openmp-mpi` under ../bin.

## Example runs

For each example, the number of nodes used can be varied depending on
whether Xeon or KNL nodes are used. When launching CoMD, the number of
MPI ranks must match the product of the values supplied by the `-i`,
`-j`, and `-k` parameters. If a run fails with "Simulation to small"
use the `-x`, `-y`, and `-z` problem size parameters to increase
simulation size.

To run a small job:
```
% export OMP_NUM_THREADS=2
% srun -n 8 -N 2 -c 2 --exclusive ./bin/CoMD-openmp-mpi -i2 -j2 -k2
```
or
```
% export OMP_NUM_THREADS=2
% aprun -n 8 -N 4 -d 2 ./bin/CoMD-openmp-mpi -i2 -j2 -k2
```

To run a somewhat larger job:
```
% export OMP_NUM_THREADS=4
% srun -n 64 -N 8 -c 4 --exclusive ./bin/CoMD-openmp-mpi -i4 -j4 -k4
```
or
```
% export OMP_NUM_THREADS=4
% aprun -n 64 -N 8 -d 4 ./bin/CoMD-openmp-mpi -i4 -j4 -k4
```

Suitable for a Xeon system:
```
% export OMP_NUM_THREADS=4
% srun -n 216 -N 18 -c 4 --exclusive ./bin/CoMD-openmp-mpi -i6 -j6 -k6
```
or
```
% export OMP_NUM_THREADS=4
% aprun -n 216 -N 18 -d 4 -cc depth ./bin/CoMD-openmp-mpi -i6 -j6 -k6
```

Suitable for KNL systems:
```
% export OMP_NUM_THREADS=4
% srun -n 512 --ntasks-per-node=32 -c 4 --exclusive ./bin/CoMD-openmp-mpi -i8 -j8 -k8 -x40 -y40 -z40
```
or
```
% export OMP_NUM_THREADS=4
% aprun -n 512 -N 32 -d 4 -j 2 ./bin/CoMD-openmp-mpi -i8 -j8 -k8 -x40 -y40 -z40
```

## Expected output

For each run, look for a date and time stamp and "CoMD Ending" as the
last line of output.  A unique output file *CoMD...* with date and time
stamp is created in the same directory but generally can be ignored.

Performance data is summarized at the end of each run. Look for
"Average atom rate" and possibly also atom updated rates.

*None of the srun or aprun command line options above should be
assumed to be optimal for performance investigations.*

## Caveats and other notes

These instructions were written using CoMD version 1.1.
