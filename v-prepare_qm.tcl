# Load the structure from the results of the classical equillibration.
# This isn't strictly necessary since we will only be using this script to create a PDB file that will mark the  # QM region. 
# atom positions have to be taken from the 'xr.coor' file; the final coor output is not recognized as binary output
mol new system.solv.ionized.psf
mol addfile ABV_202602_0003_1000.pdb

# We will once more set all beta and occupancy fields to zero.
# The QM regions will be defined by setting the beta value to integer numbers for each region.
# Since we will create QM-MM bonds (where one atom of the bond is treated classically and the other is # treated quantum mechanically), we will also use the occupancy column, marking BOTH atoms that 
# participate in a QM-MM bond → one atom overlap between beta 1.0 & occupancy 1.0
[atomselect 0 all] set beta 0.0
[atomselect 0 all] set occupancy 0.0
# set chain A to 1
[atomselect 0 "resname CYC and resid 300" ] set beta 1.0
[atomselect 0 "resname CYS and resid 84 and sidechain and segid PROA"] set beta 1.0
[atomselect 0 "resname CYS and resid 84 and segid PROA and (name CA or name CB)"] set occupancy 1.0
# set chain C to 2
[atomselect 0 "resname CYC and resid 301" ] set beta 2.0
[atomselect 0 "resname CYS and resid 84 and sidechain and segid PROC"] set beta 2.0
[atomselect 0 "resname CYS and resid 84 and segid PROC and (name CA or name CB)"] set occupancy 2.0
# set chain E to 3
[atomselect 0 "resname CYC and resid 302" ] set beta 3.0
[atomselect 0 "resname CYS and resid 84 and sidechain and segid PROE"] set beta 3.0
[atomselect 0 "resname CYS and resid 84 and segid PROE and (name CA or name CB)"] set occupancy 3.0

# We load the topotools package to guess element names based on the atom's mass.
# We do this for all atoms so the PDB file contain their elements, which will be used
#   by QM packages in their calculations.
package require topotools
topo guessatom element mass

# Write all atoms in a new PDB file for the entire system.
set sel [atomselect 0 all]
$sel writepdb cpc_a84_bY76A_qm.pdb

# Exit VMD
quit

