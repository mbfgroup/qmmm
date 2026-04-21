###     This is a script that incorporates all the separate VMD scripts used to prepare QM systems into one big thing.
###     starting from dumpming a specific frame (needed if you are NOT going from a checkpoint file)

#   dump frame from a trajectory and export as a pdb:
mol new ../system.solv.ionized.psf type {psf}
mol addfile ../ABV_202603_0041.dcd type dcd first 0 last -1 step 1 waitfor all
#   get the total number of frames
set numframes [expr {[molinfo top get numframes] - 1}]
puts "total number of frames: $numframes"
#   set ASL for which frame you want to dump from/launch QMMMM trajectory from
set qmmmAtoms [atomselect top all frame 1000]
#   write to a pdb file
$qmmmAtoms writepdb ABV_202603_0041_1000.pdb

#   load a new molecule so that we are using the pdb file instead of the dcd from here on out.
mol new ../system.solv.ionized.psf type {psf}
mol addfile ABV_202603_0041_1000.pdb
#   if you also need to generate a corresponding xsc file (pbc) for the frame
set a [molinfo top get a] 
set b [molinfo top get b] 
set c [molinfo top get c] 
set out [open system.solv.ionized.xsc w] 
puts $out "# NAMD extended system configuration restart file" 
puts $out "#\$LABELS step a_x a_y a_z b_x b_y b_z c_x c_y c_z o_x o_Y o_z s_x s_y s_z s_u s_v s_w" 
puts $out [list 0 $a 0 0 0 $b 0 0 0 $c 0 0 0 0 0 0 0 0 0] 
close $out

#   now we generate the pdb that defines the QM region
#   We will once more set all beta and occupancy fields to zero.
#   The QM regions will be defined by setting the beta value to integer numbers for each region.
#   Since we will create QM-MM bonds (where one atom of the bond is treated classically and the other is # treated quantum mechanically), we will also use the occupancy column, marking BOTH atoms that 
#   participate in a QM-MM bond → one atom overlap between beta 1.0 & occupancy 1.0
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

#   Lastly, this will generate position restraints needed for the QM/MM equilibration stages
#   Essentially, 2kcal restraints on all heavy and NOT CYC atoms in the solute.
#   Assumes that the scaling factor in the *conf file is 2
#   Now we use the two fields available in PDB files, "beta" and "occupancy"
[atomselect top all] set beta 0.0
[atomselect top all] set occupancy 0.0
#   The "beta" field will be used to indicate which atoms will have their movements contrained during the equilibration.
[atomselect top "protein and not hydrogen" ] set beta 1.0
#   Now we write the constraints file:
set sel [atomselect top all]
$sel writepdb system.solv.ionized-heavy-res-2kcal.pdb
#   and exit VMD
quit
