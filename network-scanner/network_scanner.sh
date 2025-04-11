#!/usr/bin/env bash

# scans for any online host (host discovery), then scans the top 1000 ports to check if open (port scan).
# HOW TO USE: .network_scanner.sh <subnet?=hostSubnet>

hostname=$(hostname -I);
if [ -z ${hostname:+x} ]; then
    echo "Error: cannot find host name";
    echo "exiting...";
    exit 1;
fi

# get subnet mask
netmask=$(ifconfig | grep $hostname | awk '{print $4}');

# parse address into parts 
IFS=. read -r h1 h2 h3 h4 <<< $hostname;
IFS=. read -r m1 m2 m3 m4 <<< $netmask;

# bitwise AND operation on hostname and netmask to get network address
network=$(echo "$((h1 & m1)).$((h2 & m2)).$((h3 & m3)).$((h4 & m4))");
netprefix=$(ip addr show | grep $hostname | awk '{print $2}' | cut -d / -f 2);
mySubnet="${network}/${netprefix}";     # CIDR notation

echo;
echo "Your local IP address is: $hostname";
echo "Subnet mask: $netmask";
echo "Subnet (CIDR): ${mySubnet}";
echo;

# if subnet argument not given, use host's subnet
subnet=${1:-${mySubnet}}

echo "Network scan initiated on ${subnet}:"
#sudo nmap -sS -T4 -oN output.nmap ${subnet};

# -v RS= sets the RS variable before program execution
noOfReports=$(awk -v RS= '{print $1}' output.nmap | wc -l);

table="|IP Address:\tMAC Address:\tPorts:\t\n";
for ((i=1; i<=${noOfReports}; i++))
do
    # if not last paragraph
    if [ ! ${i} -eq ${noOfReports} ]; then
        # report is the scan report for one ip address
        # gets report number i
        report=$(awk -v RS= -v reportNo=${i} 'NR==reportNo {print $0}' output.nmap);

        ipAddr=$(echo "${report}" | grep "scan report" | cut -d " " -f 5-);

        macAddr=$(echo "${report}" | grep "MAC" | cut -d " " -f 3);
        # check if mac is empty
        macAddr=${macAddr:-UNKNOWN};

        # openPorts is an array or opened ports
        openPorts=($(echo "${report}" | grep "open" | cut -d " " -f 1 | cut -d / -f 1));
        alt="";
        # check if openPorts is empty
        if [ -z ${openPorts:+x} ]; then
            # openPorts is empty, all closed and/or filtered
            if [[ ${report} =~ closed ]]; then

                if [[ ${report} =~ filtered ]]; then
                    alt="All closed or filtered";
                else
                    alt="All closed";
                fi

            else
                alt="All filtered";
            fi
        else
            # openPorts not empty
            openPorts=$(echo ${openPorts[@]});                # array to string
            openPorts=$(echo ${openPorts// /, });             # replace " " with ", "
        fi

        table="${table}|${ipAddr}\t${macAddr}\t${openPorts:-${alt}}\t\n";
    else
        noOfIPsAndHostsUp=$(awk -v RS= 'NR==10 {print $0}' output.nmap | cut -d " " -f 11-16);
        echo $noOfIPsAndHostsUp;
        echo;
    fi
done
    # $'' is a special form of quoting with backslashed escaped char 
    # replaced as specified by the ANSI C standard.
    charLen=$(echo -e $table | column -t -s $'\t' -o " | " | awk 'NR==1' | wc -m);
    horizontalLine="";
    for ((i=1; i<=((${charLen}-2)); i++)); 
        do 
        horizontalLine="${horizontalLine}*"; 
    done

    # print summary table
    echo -e "$horizontalLine";
    echo -e $table | column -t -s $'\t' -o " | ";
    echo -e "$horizontalLine";

