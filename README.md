# QM/MM MD Tutorial
This is intended to be a tutorial for how to system build + launch QM/MM MD simulations from a single MD snapshot. This example will be for a CPC trimer with one position chromophorylated, but can be adapted for other protein systems.  
  
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

Load the coordinates you want to launch from + the associated psf:  
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
```
#   Set all beta and occupancy fields in the pdb to zero.
#   The QM region(s) will be defined by setting the beta value to integer numbers correpsonding to each region.
#   Since we will create bonds that span the QM/MM region boundary, we will also use the occupancy column to mark BOTH atoms that participate in a QM-MM bond
#   One atom will should have both beta 1.0 & occupancy 1.0
#   For this system, we will also be using 
[atomselect top all] set beta 0.0
[atomselect top all] set occupancy 0.0
#   set chain A to 1
[atomselect top "resname CYC and resid 300" ] set beta 1.0
[atomselect top "resname CYS and resid 84 and sidechain and segid PROA"] set beta 1.0
[atomselect top "resname CYS and resid 84 and segid PROA and (name CA or name CB)"] set occupancy 1.0
#   set chain C to 2
[atomselect top "resname CYC and resid 301" ] set beta 2.0
[atomselect top "resname CYS and resid 84 and sidechain and segid PROC"] set beta 2.0
[atomselect top "resname CYS and resid 84 and segid PROC and (name CA or name CB)"] set occupancy 2.0
#   set chain E to 3
[atomselect top "resname CYC and resid 302" ] set beta 3.0
[atomselect top "resname CYS and resid 84 and sidechain and segid PROE"] set beta 3.0
[atomselect top "resname CYS and resid 84 and segid PROE and (name CA or name CB)"] set occupancy 3.0
#   We load the topotools package to guess element names based on the atom's mass.
#   We do this for all atoms so the PDB file contain their elements, which will be used
#   by QM packages in their calculations.
package require topotools
topo guessatom element mass
#   Write all atoms in a new PDB file for the entire system.
set sel [atomselect top all]
$sel writepdb cpc_a84_WT_qm.pdb
#   Now we do some checks to make sure all the charges look okay.
set qm1 [atomselect top "beta 1.0"]
puts "charge for qm1:"
measure sumweights $qm1 weight charge
set qm2 [atomselect top "beta 2.0"]
puts "charge for qm2:"
measure sumweights $qm2 weight charge
set qm3 [atomselect top "beta 3.0"]
puts "charge for qm3:"
measure sumweights $qm3 weight charge
set cys [atomselect top "resname CYS and resid 84"]
puts "charge for all 3 cysteines (should be zero/neutral):"
measure sumweights $cys weight charge
set system [atomselect top "not (water or ions)"]
puts "charge for solute (no waters or ions)"
measure sumweights $system weight charge
set ions [atomselect top "ions"]
puts "charge for ions (should neutralize solute chrage):"
measure sumweights $ions weight charge
set all [atomselect top all]
puts "charge for the full system"
measure sumweights $all weight charge
```
