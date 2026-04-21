# We now create the TCL file that will prepare the backbone restraints for the QM/MM minimization.

# Load the structure from the results of the classical equillibration.
mol new system.solv.ionized.psf
mol addfile ABV_202601_0046.1r.coor type namdbin

# We will once more set all beta and occupancy fields to zero.
# The backbone restraints will be done by setting the beta value to 1 for all protein backbone atoms.
[atomselect 0 all] set beta 0.0
[atomselect 0 all] set occupancy 0.0
[atomselect 0 "resname CYC and not element H" ] set beta 1.0

# We load the topotools package to guess element names based on the atom's mass.
# We do this for all atoms so the PDB file contain their elements, which will be used by QM packages in 
# their calculations.
package require topotools
topo guessatom element mass

# Write all atoms in a new PDB file for the entire system.
set sel [atomselect 0 all]
$sel writepdb pcb_qm-restr.pdb

# Exit VMD
quit

