#!/bin/bash
#SBATCH -t 1-12:00:00
#SBATCH -N 1
#SBATCH -p cpu
#SBATCH --job-name csmaster
#SBATCH --ntasks-per-node=14 # 14/112 = 1/8 of the full node
#SBATCH --mem=32G # 32/256 < 1/8 of the full node
#SBATCH -o sbatch_cryosparcm.out
#SBATCH --open-mode=append
#SBATCH -d afterok:2471
#SBATCH --nodelist=prews-cpu09

START_AT=$(date -u +%s)
TIME_LIMIT=$((36 * 60 * 60)) # Job time limit set above
MAINTENANCE=$((60 * 60)) # Switch to maintenance mode 60 min before exit
WAIT=$((15 * 60)) # 15 min margin for cryosparcm to stop
END_AT=$(($START_AT + $TIME_LIMIT))
EXIT_AT=$(($END_AT - $WAIT))

CSM="/home/tikuta/local/src/cryosparc_master/bin/cryosparcm"
RCLONE="/home/tikuta/local/src/rclone-v1.71.2-linux-amd64/rclone"

cat << @
==============================
Job started at $(date --date "@${START_AT}") ($START_AT),
will end at $(date --date "@${END_AT}") ($END_AT).
cryosparcm: $CSM
rclone: $RCLONE
==============================
@

echo "CryoSPARC master job is running on ${HOSTNAME}"
sed -i -e "s/^export CRYOSPARC_MASTER_HOSTNAME=.*$/export CRYOSPARC_MASTER_HOSTNAME=\"${HOSTNAME}\"/g"  ~/local/src/cryosparc_master/config.sh
echo "CryoSPARC master started at $(date -u +%s)"
$CSM start
$CSM maintenancemode off

$CSM cli "set_instance_banner(True, 'Scheduled restart', 'CryoSPARC will restart at $(date --date @${END_AT}). Do not queue long jobs that will span across the restart.')"

echo "CryoSPARC master backup started at $(date -u +%s)"
$CSM backup
echo "CryoSPARC master backup ended at $(date -u +%s)"
echo "Rclone started at $(date -u +%s)"
$RCLONE copy /home/tikuta/local/src/cryosparc_database/backup pCloud:/cryosparc_db_backup/tikuta@prews
echo "Rclone ended at $(date -u +%s)"

NOW=$(date -u +%s)
SLEEP_TIME=$(($START_AT + $TIME_LIMIT - $NOW - $MAINTENANCE))

echo "Sleep for $(($SLEEP_TIME / 60 / 60)) hours ($SLEEP_TIME seconds)"
sleep $SLEEP_TIME
$CSM maintenancemode on
echo "CryoSPARC is under maintenace"
$CSM cli "set_instance_banner(True, 'Restart soon', 'CryoSPARC is under maintenance and will restart at $(date --date @${END_AT}). You may queue jobs, but the jobs will start after CryoSPARC restarts.')"
NOW=$(date -u +%s)
SLEEP_TIME=$(($START_AT + $TIME_LIMIT - $NOW - $WAIT))
sleep $SLEEP_TIME
echo "CryoSPARC master start to stop at $(date -u +%s)"
$CSM stop
echo "CryoSPARC master stopped at $(date -u +%s)"
