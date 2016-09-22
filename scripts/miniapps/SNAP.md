# Instruction for building and running SNAP

Implementation: Fortran, MPI+OpenMPI, uses MPI_THREAD_SERIALIZE

Useful links:
- GitHub repository: https://github.com/losalamos/SNAP
- Useful build and run info: http://www.nersc.gov/users/computational-systems/cori/nersc-8-procurement/trinity-nersc-8-rfp/nersc-8-trinity-benchmarks/snap

1. Download from the GitHub repository
   ```
% git clone https://github.com/losalamos/SNAP.git
   ```

   The top-level README.md contains useful information about building
   and expected output.

2.  Load the necessary PrgEnv module, set `PATH` and `LD_LIBRARY_PATH`
and set the recommended environment variables, e.g. for MPICH, etc.

3. Modify the Makefile in the `src` directory as necessary.  At most,
three changes may be needed.
   ```
   #FORTRAN = mpif90
   #For Gnu and Intel compilers, mpifort works
   FORTRAN = mpifort
   ```

   Select one target. When using GNU, choose `gsnap`; when using Intel
   for KNL, choose `ksnap`; when using Intel for non-KNL choose `isnap`.
   ```
   TARGET = gsnap
   #TARGET = isnap
   #TARGET = ksnap
   ```

   If KNL is targeted, specify automatic cpu dispatch so that
   executable can run on KNL and non-KNL.
   ```
   #FFLAGS = -O3 $(OMPFLAG) -xmic-avx512 -ip -align array64byte -qopt-streaming-cache-evict=0 -qno-opt-dynamic-align -fp-model fast -fp-speculation fast -fno-alias -fno-fnalias
   FFLAGS = -O3 $(OMPFLAG) -axMIC-AVX512 -ip -align array64byte -qopt-streaming-cache-evict=0 -qno-opt-dynamic-align -fp-model fast -fp-speculation fast -fno-alias -fno-fnalias
   ```
   
4. Build
   ```
   % make
   ```

   This creates the above selected executable in the same directory.

### Example runs

For each example, the number of nodes used can be varied depending on
whether Xeon or KNL nodes are used. SNAP requires an input deck which
matches the job launch command line with respect to the number of
ranks etc.  Thus is is not trivial to modify number of ranks, threads
etc. to be used. The user also has to specify an output file which
will contain, among other things, performance data.  See
[Caveats and other notes](#caveats-and-other-notes) below for more information on how to change
these parameters.

The following examples refer to inputs files available in this repository.

To run small sanity check:
```
% export OMP_NUM_THREADS=2
% export OMP_WAIT_POLICY=passive
% srun -n 6 -N 2 --ntasks-per-node=3 -c 4 --threads-per-core 2 --hint=multithread --exclusive <path/exec> 6MT.input <outputfile>
```
or 
```
% export OMP_NUM_THREADS=2
% aprun -n 6 -N 3 -d 2 -cc depth -j 2 <path/exec> 6MT.input <outputfile>
```

To run NERSC small problem on 96 ranks and 4 nodes:
```
% export OMP_NUM_THREADS=1
% srun -n 96 -N 4 --ntasks-per-node=24 --threads-per-core 1 --exclusive <path/exec> 96ST4nodes.input <outputfile>
```
   or
```
% export OMP_NUM_THREADS=1
% aprun -n 96 -N 24 <path/exec> 96ST4nodes.input  <outputfile>
```

To run problem on 512 ranks:
```
% export OMP_NUM_THREADS=4   # must match input deck, see below
% export OMP_WAIT_POLICY=passive
% srun -n 512 -N 8 --ntasks-per-node=64 -c 4 --threads-per-core 4 --hint=multithread --exclusive <path/exec> 512MT.input <outputfile>
```
   or
```
% export OMP_NUM_THREADS=4   # must match input deck, see below
% export OMP_WAIT_POLICY=passive
% aprun -n 512 -N 64 -d 4 -cc depth -j 4 <path/exec> ./512MT.input <outputfile>
```

where `<path/exec>` refers to `gsnap`, `ksnap`, or `isnap`.

## Expected output

For each run, look for "Success! Done in a SNAP!" on stdout to confirm
completion.

Performance data is summarized at the end in `<outputfile>`. In
particular look for "Solve" time and "Grind Time".  Solve time is the
total time minus the setup and input/output times. Grind time is an
important performance metric, representing the time to solve for a
single phase-space variable.

*None of the srun or aprun command line options should be assumed to
 be optimal for performance investigations.*

## Caveats and other notes

These instructions were written using SNAP version 1.07.

SNAP does not support long file names. If this becomes a problem,
change this line in global.f90:
```
"CHARACTER(LEN=64) :: ifile, ofile"
```

When running SNAP, input and output filenames need to be provided, and
the input file and values of input parameters specified in the file
need to follow strict rules.  For multi-threaded runs, OMP_NUM_THREADS
must be set.  The number of threads to be used are specified by
`nthreads` and `nnested` in the input file and needs to be modified by
hand if desired. The default is 1. These variables allow the user to
specify using fewer threads than the number of threads specified by
OMP_NUM_THREADS. The condition `nthreads * nnested <= OMP_NUM_THREADS`
must be satisfied.  If you see "*WARNING: PINIT_OMP:
NTHREADS>MAX_THREADS; reset to MAX_THREADS" at the beginning of the
run, there is a mismatch between total threads specified in the input
deck and OMP_NUM_THREADS.

