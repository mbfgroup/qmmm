# QM/MM MD Tutorial
This is intended to be a tutorial for how to system build + launch QM/MM MD simulations from a single MD snapshot.  
  
## Software needed:  
--> VMD  
--> catdcd  
--> NAMD (for running)  
--> MDAnalysis (for analysis)  
  
## Input files needed:  
--> system.pdb # coordinate file to launch QM/MM from  
--> system.psf # topology file for the system  
--> system.xsc # extended system coordinates, has box dimensions associated with frame  
--> system.coor # optional, if you're going from restart files this is a binary coordinate file you can use instead of system.pdb  
--> ALL topology/forcefield files previously generated # for protein, ligand, etc.  
  
## Scripts that help automate the process:  
--> v-prepare_qm.tcl  
--> v-prepare_qm_res.tcl  
--> v-prep_qm_bulk.tcl  <-- this is sort of the mother script that contains a lot of separate steps in one thing.

## Preparing the system  
There is an automated version of this at 'v-prep_qm_bulk.tcl', but this is an explanation of everything that the script goes through:  

Starting from an MD trajectory:  
`#   dump frame from a trajectory and export as a pdb:
mol new ../system.solv.ionized.psf type {psf}
mol addfile ../ABV_202603_0041.dcd type dcd first 0 last -1 step 1 waitfor all
#   get the total number of frames
set numframes [expr {[molinfo top get numframes] - 1}]
puts "total number of frames: $numframes"
#   set ASL for which frame you want to dump from/launch QMMMM trajectory from
set qmmmAtoms [atomselect top all frame 1000]
#   write to a pdb file
$qmmmAtoms writepdb ABV_202603_0041_1000.pdb`  
