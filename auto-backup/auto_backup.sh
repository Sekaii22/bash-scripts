#!/usr/bin/env bash

# HOW TO USE: .auto_backup.sh backupPaths.txt <backupLocation?=$HOME> <maxKeep?=5>

paths=$(awk '{ print $0 }' < $1);
backupLocation=${2:-$HOME};
maxKeep=${3:-5}
archive="backup_$(date +%d%m%y_%H%M%S)";

# create dir if not exists
mkdir -p $backupLocation/auto-backups;

cd $backupLocation/auto-backups/;

mkdir -p ${archive};

for path in ${paths[@]}
do
    cp -r ${path} ${archive}/;
done

tar -czf ${archive}.tar.gz ${archive}/;

# remove copied files
rm -rf ${archive};

touch .created
# check if no of archive created is >= 5
if [ $(wc -l .created | awk '{print $1}') -ge ${maxKeep} ]; then
    delPath=$(awk 'NR==1 { print $2 }' .created);         # get the oldest archive
    sed -i '1d' .created;                                 # remove line 1
    echo "removing ${delPath}.tar.gz ...";
    rm ${delPath}.tar.gz;
fi

# add timestamp
echo $(date +%d%m%y_%R:%S) ${archive} >> .created;
echo "${archive}.tar.gz created.";
