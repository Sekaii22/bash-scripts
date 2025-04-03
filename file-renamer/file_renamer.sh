#!/usr/bin/env bash

# HOW TO USE: .file_renamer.sh dirPath fileName <start>

# check if path and filename is given
if [ -z ${1:+x} ] || [ -z ${2:+x} ]; then
    echo "no directory path and/or filename argument given";
    exit 1;
fi

# check if path ends in /, then add if it does not
defaultPath=$1;
if [ ${defaultPath: -1} != / ]; then
    defaultPath="${defaultPath}/";
fi

currentPath=${defaultPath};
fileName=${2};
fileNameCount=${3:-1};           # default to 1
fileProcCount=0;                 # count number of files processed

# get all files into an array
fileArr=($(ls --file-type ${currentPath:-.} | awk '! /.+\// { print $0 }'));

for item in ${fileArr[@]}
do
    # extract extension to variable
    extension=".${item##*.}";           # remove longest matching *. from start

    # rename
    #mv "${currentPath}${item}" "${currentPath}${fileName}_${fileNameCount}${extension}";
    echo "${currentPath}${item}" "${currentPath}${fileName}_${fileNameCount}${extension}";
    fileNameCount=$((${fileNameCount}+1));
    fileProcCount=$((${fileProcCount}+1));
done

echo Files processed: ${fileProcCount};
