# Instruction for building and running HPGMG

Implementation: C, MPI+OpenMP, uses MPI_THREAD_FUNNELED

Useful links:
- HPGMG website: http://crd.lbl.gov/departments/computer-science/PAR/research/hpgmg/
- Bitbucket repository: https://bitbucket.org/hpgmg/hpgmg/

## How to build

1. Download from the Bitbucket repository
   ```
% git clone https://bitbucket.org/hpgmg/hpgmg/
   ```

   README.md has instructions which are slightly obsolete and
   incomplete.

2.  Load the necessary PrgEnv module, set `PATH` and `LD_LIBRARY_PATH`
and set the recommended environment variables, e.g. for MPICH, etc.

4. Configure
   ```
   % ./configure --CC=/path/to/mpicc --CFLAGS=-fopenmp
   ```
   
   Optionally add `-axMIC-AVX512` (the Intel compile option for KNL
   cpu auto detection) to CFLAGS.

5. Build (in the top-level directory)
   ```
   % make -j3 -C build
   ```

   This creates the executable `hpgmg-fv` under `build/bin`.  The
   build can take over an hour.

## Example runs

For each example, the number of nodes used can be varied depending on
whether Xeon or KNL nodes are used.  HPGMG-FV has 2 arguments: log
(base 2) of the length of the side of a box on the finest grid (6 is a
good approximation) and the target number of boxes per process (gives
a loose bound on memory per process).  These arguments are used to
determine the actual problem size.  HPGMG-FV seems to be relatively
flexible with respect to the number of ranks etc.  It is a weak
scaling problem and run times remain more or less constant.

```
% cd build/bin
```  

To run a small job:

```
% export OMP_NUM_THREADS=8
% srun -n 8 -N 4 --ntasks-per-node=2 -c 8 --exclusive ./hpgmg-fv 6 8
```
   or
```
% export OMP_NUM_THREADS=8
% aprun -n 8 -N 2 -d 8 -cc depth -j 4 ./hpgmg-fv 6 8
```

To run a somewhat larger job:
```
% export OMP_NUM_THREADS=8
% srun -n 32 -N 4 --ntasks-per-node=8 -c 8 --hint=multithread --exclusive ./hpgmg-fv 7 8
```
or
```
% export OMP_NUM_THREADS=8
% aprun -n 32 -N 8 -d 8 -cc depth -j 4 ./hpgmg-fv 7 8
```

To run on KNL nodes:
```
% export OMP_NUM_THREADS=8
% srun -n 128 -N 4 --ntasks-per-node=32 -c 8 --exclusive ./hpgmg-fv 7 8
```
or
```
% export OMP_NUM_THREADS=8
% aprun -n 128 -N 32 -d 8 -cc depth -j 4 ./hpgmg-fv 7 8
```

Another KNL example:
```
% export OMP_NUM_THREADS=8
% srun -n 512 -N 16 --ntasks-per-node=32 -c 8 --hint=multithread --exclusive ./hpgmg-fv 6 8
```
or
```
% export OMP_NUM_THREADS=8
% aprun -n 512 -N 32 -d 8 -cc depth -j 4 ./hpgmg-fv 6 8
```

# Expected output

The last line of the output should be
```
===== Done ========================
```

Various performance data is reported a little further up in the output, e.g.
```
   Total time in MGSolve      XXX seconds. 
```

*None of the srun or aprun command line options should be assumed to
 be optimal for performance investigations.*

## Caveats and other notes

HPGMG doesn't seem to have a release tarball, but we believe these
instructions should work for HPGMG version 0.3.
