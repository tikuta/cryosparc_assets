#!/bin/bash
#SBATCH -t 1-12:00:00
#SBATCH -N 1
#SBATCH -p cpu
#SBATCH --job-name cryosparcm
#SBATCH --ntasks-per-node=14 # 14/112 = 1/8 of the full node
#SBATCH --mem=32G # 32/256 < 1/8 of the full node
#SBATCH -o sbatch_cryosparcm.out
#SBATCH --open-mode=append

CSM="/home/tikuta/local/src/cryosparc_master/bin/cryosparcm"
RCLONE="/home/tikuta/local/src/rclone-v1.71.2-linux-amd64/rclone"

echo "CryoSPARC master is running on ${HOSTNAME}"
sed -i -e "s/^export CRYOSPARC_MASTER_HOSTNAME=.*$/export CRYOSPARC_MASTER_HOSTNAME=\"${HOSTNAME}\"/g"  ~/local/src/cryosparc_master/config.sh
echo "CryoSPARC master started at $(date -u +%s)"
$CSM start
echo "Sleep for a day..."
sleep $((1 * 24 * 60 * 60))
echo "CryoSPARC master backup started at $(date -u +%s)"
$CSM backup
echo "CryoSPARC master backup ended at $(date -u +%s)"
$CSM stop
echo "CryoSPARC master ended at $(date -u +%s)"
echo "Rclone started at $(date -u +%s)"
$RCLONE copy /home/tikuta/local/src/cryosparc_database/backup pCloud:/cryosparc_db_backup/tikuta@prews
echo "Rclone ended at $(date -u +%s)"
