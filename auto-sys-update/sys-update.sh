#!/usr/bin/env bash

red=$(tput setaf 1);
green=$(tput setaf 2);
reset=$(tput sgr0);

apt update && apt upgrade -y;
if [ $? -eq 0 ]; then
     echo "${green}Successfully updated packages${reset}";
else
    echo "${red}Error occurred while updating packages!${reset}";
fi

apt autoremove && apt autoclean;
if [ $? -eq 0 ]; then
     echo "${green}Successfully removed unused dependencies and cleared package caches${reset}";
else
    echo "${red}Error occurred while removing unused dependencies and package caches!${reset}";
fi