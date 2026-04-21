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

## Preparing the files you need to build the system  
There is an automated version of this at 'v-prep_qm_bulk.tcl', but this is an explanation of everything that the script goes through:  

Starting from an MD trajectory: 
```
#   dump frame from a trajectory and export as a pdb:
mol new system.solv.ionized.psf type {psf}
mol addfile some_traj.dcd type dcd first 0 last -1 step 1 waitfor all
#   get the total number of frames
set numframes [expr {[molinfo top get numframes] - 1}]
puts "total number of frames: $numframes"
#   set ASL for which frame you want to dump from/launch QMMMM trajectory from
set qmmmAtoms [atomselect top all frame 1000]
#   write to a pdb file
$qmmmAtoms writepdb pre_system.pdb  
```  

Done with the MD trajectory, now load the coordinates you want to launch from + the associated psf:  
```
mol new system.solv.ionized.psf type {psf}
mol addfile some_traj_frame.pdb
#   if you also need to generate a corresponding xsc file (pbc) for the frame
#   will likely need to do this section if you are NOT using checkpoint files
set a [molinfo top get a] 
set b [molinfo top get b] 
set c [molinfo top get c] 
set out [open qm.system.solv.ionized.xsc w] 
puts $out "# NAMD extended system configuration restart file" 
puts $out "#\$LABELS step a_x a_y a_z b_x b_y b_z c_x c_y c_z o_x o_Y o_z s_x s_y s_z s_u s_v s_w" 
puts $out [list 0 $a 0 0 0 $b 0 0 0 $c 0 0 0 0 0 0 0 0 0] 
close $out
```

## Generating the pdb file that defines the QM region:  
