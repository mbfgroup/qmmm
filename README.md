# qmmm
This is intended to be a tutorial for how to system build + launch QM/MM MD simulations from a single MD snapshot.

Software needed:
--> VMD
--> catdcd
--> NAMD (for running)
--> MDAnalysis (for analysis)

Input files needed:
--> system.pdb # coordinate file to launch QM/MM from
--> system.psf # topology file for the system
--> system.xsc # extended system coordinates, has box dimensions associated with frame
--> system.coor # optional, if you're going from restart files this is a binary coordinate file you can use instead of system.pdb
--> ALL topology/forcefield files previously generated # for protein, ligand, etc.

Scripts that help automate the process:
--> v-prepare_qm.tcl
--> v-prepare_qm_res.tcl
--> v-prep_qm_bulk.tcl

