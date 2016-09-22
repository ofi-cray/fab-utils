This directory contains useful tidbits for building and running a
selection of DOE MiniApps for Cray XC systems with Xeon and KNL nodes.
Though the information is not specific to a particular implemenatation
of MPI, the instructions and test examples were done using OpenMPI and
MPICH built on top of the libfabric GNI provider.

Contents:
- Notes for building MiniApps
  - [CoMD](./CoMD.md)
  - [HPGMG](./HPGMG.md)
  - [LULESH](./LULESH.md)
  - [MiniAMR](./MiniAMR.md)
  - [Nekbone](./Nekbone.md)
  - [SNAP](./SNAP.md)
  - [XSBench](./XSBench.md)
- Input files
  - SNAP: 6MT.input, 512MT.input, 8192MT.input, 96ST4nodes.input
  - Nekbone: data.rea
- run_miniapps: A script to run a each of the MiniApps for correctness
