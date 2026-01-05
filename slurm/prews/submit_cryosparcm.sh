#/bin/bash
set -eu

RUN_AFTER="2351" # job id to wait
NJOB=10 # cryosparc master will run for (NJOB * 36) hours
JOBSCRIPT="sbatch_cryosparcm.sh"

for N in $(seq 1 $NJOB); do
	echo -n "$N: "
	if [[ ${#RUN_AFTER} -eq 0 ]]; then
		sed -i -e 's/^#SBATCH -d afterok:.*$/##SBATCH -d afterok:0000/g' $JOBSCRIPT
	else
		sed -i -e 's/^.*#SBATCH -d afterok:.*$/#SBATCH -d afterok:'"$RUN_AFTER"'/g' $JOBSCRIPT
	fi
	# Example output of sbatch: Submitted batch job 2104
	echo -n "sbatch $JOBSCRIPT"
	RUN_AFTER=$(sbatch $JOBSCRIPT | awk '{print $4}')
	echo " -> $RUN_AFTER"
done

set +eu
