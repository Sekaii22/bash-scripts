#!/usr/bin/env bash

subnet=$1;

# if subnet argument not given, use host's subnet
if [ -z ${subnet:+x} ]; then
    echo "Subnet arg not given";

    hostname=$(hostname -I);
    if [ -z ${hostname:+x} ]; then
        echo "Error: cannot find host name";
        echo "exiting...";
        exit 1;
    fi

    netmask=$(ifconfig | grep $hostname | awk '{print $4}');
    echo "hostname: $hostname";
    echo "netmask: $netmask";

    # parse address into parts 
    IFS=. read -r h1 h2 h3 h4 <<< $hostname;
    IFS=. read -r m1 m2 m3 m4 <<< $netmask;

    # bitwise AND operation on hostname and netmask to get network address
    network=$(echo "$((h1 & m1)).$((h2 & m2)).$((h3 & m3)).$((h4 & m4))");
    netprefix=$(ip addr show | grep $hostname | awk '{print $2}' | cut -d / -f 2);
    subnet="${network}/${netprefix}";     # CIDR notation
    echo "subnet: ${subnet}";
    echo;
fi

#sudo nmap -sS -T4 -oN n_output.nmap ${subnet};

# -v RS= sets the RS variable before program execution
noOfParas=$(awk -v RS= '{print $1}' n_output.nmap | wc -l);
for ((i=1; i<=${noOfParas}; i++))
do
    if [ ! ${i} -eq ${noOfParas} ]; then
        para=$(awk -v RS= -v lineNo=${i} 'NR==lineNo {print $0}' n_output.nmap);

        ipAddr=$(echo "${para}" | grep "scan report" | cut -d " " -f 5-);
        macAddr=$(echo "${para}" | grep MAC | cut -d " " -f 3);
        # check if mac is empty
        macAddr=${macAddr:-UNKNOWN}
        openPorts=($(echo "${para}" | grep open | cut -d " " -f 1 | cut -d / -f 1));

        echo $ipAddr;
        echo $macAddr;
        for port in ${openPorts[@]}
        do
            echo "$port";
        done

        #if [ -z ${openPorts:+x} ]; then
            # check for number of filtered and closed ports

        #fi
        echo;
    fi
done

