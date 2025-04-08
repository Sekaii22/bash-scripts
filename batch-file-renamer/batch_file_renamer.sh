#!/usr/bin/env bash

# HOW TO USE: .file_renamer.sh dirPath fileName <start>

# arg: directory path
renameFiles() {
    local currentPath=$1;

    # get all files into an array
    local fileArr=($(ls --file-type ${currentPath} | awk '! /.+\// { print $0 }'));

    # get all dir into an array
    local dirArr=($(ls --file-type ${currentPath} | awk '/.+\// { print $0 }'));

    for item in ${fileArr[@]}
    do
        # extract file extension
        if [[ $item =~ \..* ]]; then
            local extension=".${item##*.}";           # remove longest matching *. from start
        else
            local extension="";
        fi

        # rename file
        mv "${currentPath}${item}" "${currentPath}${fileName}_${fileNameCount}${extension}";
        #echo "${currentPath}${item}" "${currentPath}${fileName}_${fileNameCount}${extension}";
        fileNameCount=$((${fileNameCount}+1));
        fileProcCount=$((${fileProcCount}+1));
    done

    # rename recursively
    for dir in ${dirArr[@]}
    do
        #echo ${currentPath}${dir};
        renameFiles "${currentPath}${dir}";
    done
}

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
fileName=${2};
fileNameCount=${3:-1};           # default to 1
fileProcCount=0;                 # count number of files processed

renameFiles "$defaultPath";

echo Files renamed: ${fileProcCount};

