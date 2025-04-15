#!/usr/bin/env bash

# scans for any online host (host discovery), then scans the top 1000 ports to check if open (port scan).
# HOW TO USE: sudo .network_scanner.sh <subnet?=hostSubnet>

hostname=$(hostname -I);
if [ -z "${hostname}" ]; then
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
subnet=${1:-${mySubnet}};
newfile="output.nmap";
oldfile="output.old.nmap";

echo "Network scan initiated on ${subnet}:"
# check if there is an existing output.nmap
if [ -f ${newfile} ]; then
    mv -f ${newfile} ${oldfile};
fi

# scan
sudo nmap -sS --min-rate 2000 -T4 -oN ${newfile} ${subnet} > /dev/null;

# check if nmap scan is successful
if [ $? -ge 1 ]; then
    exit 1;
fi

# -v RS= sets the RS variable before program execution
noOfReports=$(awk -v RS= '{print $1}' ${newfile} | wc -l);
ips=()                  # stores all ip address of online hosts
ipsWOpenPorts=()        # stores all ip address of hosts with opened ports
ports=()                # stores opened ports of each online hosts as ("port1,port2,...", "port43,port55", ...)

table="|Id:\tIP Address:\tMAC Address:\tPorts:\t\n";
for ((i=1; i<=${noOfReports}; i++))
do
    # if not last paragraph
    if [ ! ${i} -eq ${noOfReports} ]; then
        # report is the scan report for one ip address
        # gets report number i
        report=$(awk -v RS= -v reportNo=${i} 'NR==reportNo {print $0}' ${newfile});

        ipAddr=$(echo "${report}" | grep "scan report" | cut -d " " -f 5-);
        ips+=("${ipAddr}");

        macAddr=$(echo "${report}" | grep "MAC" | cut -d " " -f 3);
        # check if mac is empty
        if [ -z "${macAddr}" ]; then
            macAddr="UNKNOWN";
        else
            # check if it is a new device by searching MAC against old reports
            if [ -f ${oldfile} ] && [ -z "$(grep ${macAddr} ${oldfile})" ]; then
                macAddr="${macAddr} (NEW)";
            fi
        fi

        # openPorts is an array or opened ports
        openPorts=($(echo "${report}" | grep "open" | cut -d " " -f 1 | cut -d / -f 1));
        alt="";
        # check if openPorts is empty
        if [ -z "${openPorts}" ]; then
            # openPorts is empty, all closed and/or filtered
            if [[ ${report} =~ closed ]] && [[ ${report} =~ filtered ]]; then
                alt="Closed and filtered";
                 
            elif [[ ${report} =~ closed ]]; then
                alt="All closed";

            elif [[ ${report} =~ filtered ]]; then
                alt="All filtered";
            fi
            ports+=("");                                      # add empty string to ports array since no opened ports
        else
            # openPorts not empty
            openPorts=$(echo ${openPorts[@]});                # array to string
            openPorts=${openPorts// /, };                     # replace " " with ", "
            ports+=("${openPorts//, /,}");                    # replace ", " with "," and add to ports array
            ipsWOpenPorts+=("${ipAddr}");                     # is an ip with open ports
        fi

        table="${table}|${i}\t${ipAddr}\t${macAddr}\t${openPorts:-${alt}}\t\n";
    else
        # last paragraph is not a scan report
        noOfIPsAndHostsUp=$(awk -v RS= -v lastLine=${i} 'NR==lastLine {print $0}' ${newfile} | cut -d " " -f 11-16);
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
echo;

# further scans
opsCount=6;
echo "Options for further scans: "
echo "1. Scan all hosts for OS and identify the version of any running services";
echo "2. Scan only hosts with opened ports for OS and identify the version of any running services";
echo "3. Scan a specific host for OS and identify the version of any running services";
echo "4. Scan all hosts for any vulnerabilities";
echo "5. Scan only hosts with opened ports for any vulnerabilities";
echo "6. Scan a specific host for any vulnerabilities";
echo;

while true; do
    read -p "Enter scan option (CTRL+C to exit): " scanChoice;
    if [ $scanChoice -le $opsCount ] && [ $scanChoice -ge 1 ]; then
        if [ $scanChoice -eq 1 ]; then
        
            sudo nmap -A --min-rate 1000 -T4 -oN - ${ips[@]};

        elif [ $scanChoice -eq 2 ]; then

            sudo nmap -A --min-rate 1000 -T4 -oN - ${ipsWOpenPorts[@]};

        elif [ $scanChoice -eq 3 ]; then

            while true ; do
                read -p "Enter Id of specific host: " ipIndex;
                ipIndex=$(($ipIndex - 1));

                # check if ip chosen is valid
                if [[ $ipIndex =~ [[:digit:]]+ ]] && [ $ipIndex -lt ${#ips[@]} ] && [ $ipIndex -ge 0 ]; then
                    sudo nmap -A --min-rate 1000 -T4 -oN - -p ${ports[${ipIndex}]} ${ips[${ipIndex}]};
                    echo;
                    break;
                else
                    echo "Not a valid index, please try again";
                    echo;
                fi
            done

        elif [ $scanChoice -eq 4 ]; then
            sudo nmap --script vuln -T4 -oN - ${ips[@]};
        elif [ $scanChoice -eq 5 ]; then
            sudo nmap --script vuln -T4 -oN - ${ipsWOpenPorts[@]};
        elif [ $scanChoice -eq 6 ]; then

            while true ; do
                read -p "Enter Id of specific host: " ipIndex;
                ipIndex=$(($ipIndex - 1));

                # check if ip chosen is valid
                if [[ $ipIndex =~ [[:digit:]]+ ]] && [ $ipIndex -lt ${#ips[@]} ] && [ $ipIndex -ge 0 ]; then
                    sudo nmap --script vuln -T4 -oN - -p ${ports[${ipIndex}]} ${ips[${ipIndex}]};
                    echo;
                    break;
                else
                    echo "Not a valid index, please try again";
                    echo;
                fi
            done

        fi

        #break;
    else
        echo "Invalid choice, please try again";
        echo;
    fi
done

