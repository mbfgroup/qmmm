#!/bin/bash
#SBATCH --image docker:nersc/namd:3.0.b5
#SBATCH -C cpu
#SBATCH -t 12:00:00
#SBATCH -J ABV_202512_0128_0131
#SBATCH -o ABV_202512_0128_0131.o%j
#SBATCH -A m4030
#SBATCH -N 1
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=16
#SBATCH -q regular
#SBATCH --mail-type=begin,end,fail
#SBATCH --mail-user=abvelez@lbl.gov

exe=namd3
flags="+setcpuaffinity"

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OMP_PROC_BIND=spread
export OMP_PLACES=threads

# this is a QM/MM equilibration script, intentionally excluding prod sim to force you to check
# QM/MM Minimization, 2kcal restraints on all heavy atoms (not CYC)
job1="srun --cpu-bind=cores --module mpich shifter $exe $input ./QMMM-Min.conf > ABV_202512_0128.out 2>&1" 
# QM/MM Annealing, 2kcal restraints on all heavy atoms (not CYC)
job2="srun --cpu-bind=cores --module mpich shifter $exe $input ./QMMM-Ann.conf > ABV_202512_0129.out 2>&1" 
# QM/MM Equilibration, 2kcal restraints on all heavy atoms (not CYC)
job3="srun --cpu-bind=cores --module mpich shifter $exe $input ./QMMM-Equi-res.conf > ABV_202512_0130.out 2>&1" 
# QM/MM Equilibration, no restraints
job4="srun --cpu-bind=cores --module mpich shifter $exe $input ./QMMM-Equi.conf > ABV_202512_0131.out 2>&1" 
# QM/MM Production Simulation, no restraints
job5="srun --cpu-bind=cores --module mpich shifter $exe $input ./QMMM-prod-sim.conf > ABV_202512_0103.out 2>&1" 

echo "$job1"
echo "$job2"
echo "$job3"
echo "$job4"
# echo "$job5"

eval "$job1" 
eval "$job2" 
eval "$job3" 
eval "$job4"
# eval "$job5"
