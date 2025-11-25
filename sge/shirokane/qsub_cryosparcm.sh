#!/bin/bash
#$ -pe def_slot 8
#$ -l s_vmem=4G,ljob
#$ -o qsub_cryosparcm.out
#$ -j y
#$ -N cryosparcm
##$ -cwd
#$ -S /bin/bash

CSM="/home/tikuta/local/src/cryosparc_master/bin/cryosparcm"
RCLONE="/home/tikuta/local/src/rclone-v1.71.2-linux-amd64/rclone"

echo "CryoSPARC master is running on ${HOSTNAME}i"
sed -i -e "s/^export CRYOSPARC_MASTER_HOSTNAME=.*$/export CRYOSPARC_MASTER_HOSTNAME=\"${HOSTNAME}i\"/g"  ~/local/src/cryosparc_master/config.sh
echo "CryoSPARC master started at $(date -u +%s)"
$CSM start
echo "Sleep for a month..."
sleep $((31 * 24 * 60 * 60))
echo "CryoSPARC master backup started at $(date -u +%s)"
$CSM backup
echo "CryoSPARC master backup ended at $(date -u +%s)"
$CSM stop
echo "CryoSPARC master ended at $(date -u +%s)"
echo "Rclone started at $(date -u +%s)"
$RCLONE copy /home/tikuta/local/src/cryosparc_database/backup pCloud:/cryosparc_db_backup/tikuta@shirokane
echo "Rclone ended at $(date -u +%s)"
