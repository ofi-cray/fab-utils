# Instruction for building and running MiniAMR

Implementation: C, MPI (single threaded)

Useful links:
- Mantevo web site: https://mantevo.org/packages/

# How to build

1. Download the most recent version from
https://mantevo.org/download/.  There is a top-level README with basic
build and run information.

2.  Load the necessary PrgEnv module, set `PATH` and `LD_LIBRARY_PATH`
and set the recommended environment variables, e.g. for MPICH, etc.

4. Modify the compiler flags in Makefile.mpi in the `miniAMR_ref`
directory for the appropriate compiler:

   For example, if the Intel compiler is use to build for KNL:
   ```
   #CFLAGS = -O3
   CFLAGS = -O3 -axMIC-AVX512
   ```

5. Build (in the `miniARM_ref` directory)
   ```
   % make -f Makefile.mpi
   ```

   This creates the executable `miniAMR.x` in the same directory.

# Example runs

The program has many possible input parameters but most importantly,
the product of `npx`, `npy`, and `npz` must equal `nranks`.  Other
input parameters here were chosen to extend run time beyond the
default ~30 seconds and are optional.  MiniAMR is single threaded, so
aprun launch parameters can easily be derived from the srun examples.

To run a small test:
```
% srun -n 16 -N 2 --exclusive ./miniAMR.x --npx 2 --npy 2 --npz 4 --num_tsteps 100 --stages_per_ts 100
```

To run on 128 or more ranks:
```
% srun -n 128 --exclusive ./miniAMR.x --npx 8 --npy 4 --npz 4 --num_tsteps 100
```

Suitable for non-KNL and KNL systems:
```
% srun -n 4096 --exclusive ./miniAMR.x --npx 16 --npy 16 --npz 16 --num_tsteps 100 --stages_per_ts 100
```

## Expected output

For each run, look for end of report message:
```
================== End report ===================
```

Relevant performance data is sprinkled throughout the report.

*None of the srun command line options should be assumed to be optimal
for performance investigations.*

## Caveats and other notes

These instructions were written using MiniAMR version 1.0.
