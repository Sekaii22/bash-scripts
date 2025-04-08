#!/usr/bin/env bash

# get all absolute paths that needs to be backed up
# cpy files into a backup location
# compress individually
# tar -czvf archive_$(date +%d%m%y).tar.gz folder_to_rename/
# keep 5 archive, delete old ones
# cron jobs for automating backup

paths=$(awk '{ print $0 }' < $1);
archive="backup_$(date +%d%m%y_%H%M%S)";

# create dir if not exists
mkdir -p $HOME/auto-backups;

cd $HOME/auto-backups/;

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
if [ $(wc -l .created | awk '{print $1}') -ge 5 ]; then
    delPath=$(awk 'NR==1 { print $2 }' .created);         # get the oldest archive
    sed -i '1d' .created;                                 # remove line 1
    echo "removing ${delPath}.tar.gz ..."
    rm ${delPath}.tar.gz;
fi

# add timestamp
echo $(date +%d%m%y_%R:%S) ${archive} >> .created;
echo "${archive}.tar.gz created."
