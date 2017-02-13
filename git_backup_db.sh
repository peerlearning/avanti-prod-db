#!/bin/bash
PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:/home/ec2-user/bin


################################################################################
# Make sure this script runs only on PROD Mongo
PROD_MONGO_INST_ID="i-d7a8ff73"
echo "Identifying current machine..."
SELF_INST_ID="`wget -q -O - http://instance-data/latest/meta-data/instance-id || echo not-ec2`"

if [ $SELF_INST_ID != $PROD_MONGO_INST_ID ]
then
	echo "FATAL: This script can only run on PROD-MONGO1 EC2 instance!"
	exit
fi
################################################################################

echo "Starting mongodump..."

CURTIME=$(zdump Asia/Kolkata)
CURTIME="${CURTIME/Asia\/Kolkata  }"

mongodump -o /home/ec2-user/backups/avanti-prod-db/

cd /home/ec2-user/backups/avanti-prod-db

# git checkout avanti-cms_production/problems.bson # We'll switch to LFS if needed.
rm avanti-service_production/oauth_access_* -f # Removed since this has been removed from git tracking
git checkout avanti-cms_production/cms_logs.bson

git gc # Garbage collection
git add .
git commit --all -m "[AvantiBot] Auto backed up on $CURTIME"
git pull --rebase
git push

echo "Done!"
